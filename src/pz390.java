import java.lang.reflect.Array;
import java.math.BigDecimal;
import java.math.BigInteger;
import java.math.MathContext;
import java.math.RoundingMode;
import java.nio.ByteBuffer;
import java.util.Arrays;
import java.util.Date;

/**
 * Copyright 2011 Automated Software Tools Corporation
 * Copyright 2013 Cat Herder Software, LLC
 * Copyright 2018 Joachim Bartz, Germany
 *
 * z390 is free software; you can redistribute it and/or modify it under the
 * terms of the GNU General Public License as published by the Free Software
 * Foundation; either version 2 of the License, or (at your option) any later
 * version.
 *
 * z390 is distributed in the hope that it will be useful, but WITHOUT ANY
 * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE.
 * See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with
 * z390; if not, write to the
 *    Free Software Foundation, Inc.
 *    59 Temple Place, Suite 330,
 *    Boston, MA  02111-1307  USA
 */

/**
 * pz390 is the processor emulator component of z390<br>
 * which is called from ez390 to execute 390 code loaded in memory.<br>
 * Both ez390 and pz390 call sz390 svc component to perform OS functions
 * such as memory allocation and loading.
 */
public class pz390
{
	// limits

	/**
	 * PC, PR, PT stack for psw and regs
	 */
	private final static int max_pc_stk = 50;

	/**
	 *  Maximum register offset 16*8
	 */
	final static int max_reg_off = 128;

	/**
	 * shared tables and functions
	 */
	public tz390 tz390 = null;

	/**
	 * Shared service handler, also accessed by ez390.
	 */
	private sz390 sz390 = null;

	/*
	 * date variables
	 */
	public  Date cur_date = null;
	public  long ibm_mil  = 0; // milliseconds from 1900 to 1970 Epoch
	public  long ibm_ms   = 0; // microseconds from 1900 to now
	private long java_mil = 0; // milliseconds from 1970 to now

	/*
	 * PSW and instruction decode variables.
	 */
	public  int test_trace_count = 0;
	private boolean trace_psw = false; // prevent ex_mode reset RPI-0538
	private String ins_trace_line = null;

	private final static long cpu_id = 0x390;

	public  int psw_loc = 0;
//	private int psw_short = 0;    // JBA-unused
//	private short ins_short0 = 0; // JBA-unused
//	private short ins_short1 = 0; // JBA-unused
//	private short ins_short2 = 0; // JBA-unused

	private final static long long_high_bit = ((long) -1) << 63;

	public  final static int int_high_bit = 0x80000000;

	public  final static int max_pos_int = 0x7fffffff;

	private final static int min_neg_int = 0x80000000;

	private final static long max_pos_long = ((long) -1) >>> 1;

	private final static long min_neg_long = ((long) 1) << 63;
	private final static long max_srp_long = max_pos_long / 10; // RPI-0781
	private final static long min_srp_long = min_neg_long / 10; // RPI-0781
	private final static BigInteger bi_max_pos_long = BigInteger.valueOf(max_pos_long);
	private final static BigDecimal bd_max_pos_long = BigDecimal.valueOf(max_pos_long); // RPI-0791
	private final static BigDecimal bd_min_neg_long = BigDecimal.valueOf(min_neg_long); // RPI-0791
	private final static BigDecimal bd_max_log_long = bd_max_pos_long.add(BigDecimal.ONE).multiply(BigDecimal.valueOf(2)); // RPI-1125

	private final static BigInteger bi_min_neg_long = BigInteger.valueOf(min_neg_long);
	private final static BigInteger bi_max_pos_int = BigInteger.valueOf(max_pos_int); // RPI-781

	private final static BigInteger bi_min_neg_int = BigInteger.valueOf(min_neg_int); // RPI-781
	private final static long long_num_bits    = ((long) -1) ^ long_high_bit;
	private final static long long_low32_bits  = (((long) 1) << 32) - 1;
	private final static long long_low48_bits  = (((long) 1) << 48) - 1;
//	private final static long long_high32_bits = ((long) -1) << 32;
	private final static long long_sign_bits   = ((long) -1) << 31;
	private final static long long_zone_ones   = (((long) 0xf0f0f0f0) << 32)
												| ((long) 0xf0f0f0f0 & long_low32_bits);
	private final static long long_num_ones    = (((long) 0x0f0f0f0f) << 32) | (long) 0x0f0f0f0f;
	public  final static int psw_amode24 = 0x00ffffff;
	public  final static int psw_amode31 = 0x7fffffff;
	public  int              psw_amode   = psw_amode31;
	private final static int psw_amode24_high_bits = 0xff000000; // RPI-0828
	private final static int psw_amode31_high_bits = 0;          // RPI-0828
	private int psw_amode_high_bits = psw_amode31_high_bits;             // RPI-0828
	public  final static int psw_amode24_bit = 0;
	public  final static int psw_amode31_bit = 0x80000000;

	public int psw_amode_bit = psw_amode31_bit;

	private long cur_stck = 0;
	private long last_stck = long_high_bit;

	/*
	 * psw_cc program condition code
	 */
	private final static int psw_cc0 = 8; // EQUAL, ZERO.
	private final static int psw_cc1 = 4; // LOW, LT
	private final static int psw_cc2 = 2; // HIGH, GT
	public  final static int psw_cc3 = 1; // OVERFLOW, ONES

	// PSW CODE FROM MASK 1 2 4 8
	public  final static int[] psw_cc_code = { -1, 3, 2, -1, 1, -1, -1, -1, 0 };
	private final static int[] psw_cc_mask = { 8, 4, 2, 1 };

	private final static int psw_cc_equal = psw_cc0; // mask 8
	private final static int psw_cc_low   = psw_cc1; // mask 4
	private final static int psw_cc_high  = psw_cc2; // mask 2
	private final static int psw_cc_ovf   = psw_cc3; // mask 1
	public               int psw_cc       = psw_cc_equal;

	/*
	 * psw_pgm_mask fields and pgm interruption fields.
	 */
	private final static int psw_pgm_mask_fix = 0x8; // fixed point overflow
	private final static int psw_pgm_mask_dec = 0x4; // decimal overflow
	private final static int psw_pgm_mask_exp = 0x2; // fp exponent overflow
	private final static int psw_pgm_mask_sig = 0x1; // fp significance
	public               int psw_pgm_mask     = 0x6; // Enable all but fixed and fp signals. // RPI-33

	/*
	 * PSW trace table
	 */
	private final static int    max_trace_table = 10; // also change trace_table_next RPI-819
	public               byte   trace_table_index = 9;
	public               int[]  trace_table_addr  = new int[max_trace_table];
	public               byte[] trace_table_next  = {1,2,3,4,5,6,7,8,9,0};

	/*
	 * FPC IEEE BFP/DFP control registers
	 */
	private final static int fp_fpc_mask_inv = 0x80000000;
	private final static int fp_fpc_mask_div = 0x40000000;
	private final static int fp_fpc_mask_ovf = 0x20000000;
	private final static int fp_fpc_mask_unf = 0x10000000;
	private final static int fp_fpc_mask_sig = 0x08000000;

	//								fp_dd_mod_bi to truncate digits 1234567890123456
	private final static BigInteger fp_dd_mod_bi = new BigInteger("10000000000000000");

	//								fp_ld_mod_bi to truncate digits 1234567890123456789012345678901234
	private final static BigInteger fp_ld_mod_bi = new BigInteger("10000000000000000000000000000000000");

	private int alt_rnd_mode = 0; // RPI-1125 set alternate round mode if ?=A
	private int alt_fpe_mode = 0; // RPI-1125 set alt FP extension if bits 20-23 set

	private final static int fp_bfp_rnd_mask = 0x00000007; // bfp rounding mode   RPI-1125 was 3
	private final static int fp_bfp_rnd_not  = 0xfffffff8; // not round mode bits RPI-1125 was c
	private final static int fp_bfp_rnd_even = 0x0; // round to nearest (default)
//	private int fp_bfp_rnd_zero = 0x1; // round toward zero (discard bits to right)
//	private int fp_bfp_rnd_pi   = 0x2; // round toward plus infinity
//	private int fp_bfp_rnd_ni   = 0x3; // round toward negative infinity
	public  int fp_bfp_rnd = fp_bfp_rnd_even; // default rounding mode
	private int fp_bfp_rnd_default = fp_bfp_rnd;

	private final static int fp_dfp_rnd_mask  = 0x00000070; // dfp rounding mode
	private final static int fp_dfp_rnd_not   = 0xffffff8f; // not round mode bits
	private final static int fp_rnd_near_even = 0x0; // round to nearest with ties to even (default)
//	private final static int fp_rnd_zero       = 0x1; // round toward zero (discard bits to right)
//	private final static int fp_rnd_pi         = 0x2; // round toward plus infinity
//	private final static int fp_rnd_ni         = 0x3; // round toward negative infinity
	private final static int fp_rnd_near_nzero = 0x4; // round to hearest with ties to not zero
//	private final static int fp_rnd_near_zero  = 0x5; // round to nearest with ties to zero
//	private final static int fp_rnd_nzero      = 0x6; // round to not zero
//	private final static int fp_rnd_shorter    = 0x7; // round to shorter precision
	private int fp_sig_req = 0; // dfp significant digits requested
	private int fp_sig_dig = 0; // dfp significant digits found
	public  int fp_dfp_rnd = fp_rnd_near_even; // default rounding mode
	private int fp_dfp_rnd_default = fp_dfp_rnd; // RPI-1125
	private int fp_fpc_reg = 0x70000000; // div+ovf+unf

	private final static int fp_dxc_dec  = 0x00; // packed decimal data exception
	private final static int fp_dxc_it   = 0x08; // IEEE inexact and truncated
	private final static int fp_dxc_ii   = 0x0C; // IEEE inexact and incremented
	private final static int fp_dxc_ue   = 0x10; // IEEE underflow, exact
//	private final static int fp_dxc_uit  = 0x18; // IEEE underflow, inexact and truncated
//	private final static int fp_dxc_uii  = 0x1C; // IEEE underflow, inexact and incremented
	private final static int fp_dxc_oe   = 0x20; // IEEE overflow, exact
//	private final static int fp_dxc_oit  = 0x28; // IEEE overflow, inexact and truncated
//	private final static int fp_dxc_oii  = 0x2C; // IEEE overflow, inexact and incremented
	private final static int fp_dxc_div  = 0x40; // IEEE division by zero

//	private final static int fp_dxc_oper = 0x80; // IEEE invalid operation
	private final static int fp_dxc_trap = 0xff; // compare and trap exception RPI-817
	private              int fp_dxc = 0;         // byte 2 of fp_fpc_reg with IEEE exceptions

	String fp_dfp_digits = null;

	/*
	 * ASSIST global execution data areas RPI-812
	 */
	private int ast_xdump_addr = 0; // default xdump area
	private int ast_xdump_len  = 0; // default xdump area length
			int ast_xread_tiot = -1;
			int ast_xprnt_tiot = -1;
			int ast_xpnch_tiot = -1;
			int ast_xget_tiot  = -1;
			int ast_xput_tiot  = -1;
	private final static int    ast_xread_dcb = 0xe00;
	private final static int    ast_xprnt_dcb = 0xe02;
	private final static int    ast_xpnch_dcb = 0xe04;
	private final static int    ast_xget_dcb  = 0xe0a;
	private final static int    ast_xput_dcb  = 0xe0c;
	private              String ast_file_line;

	/*
	 * Program check and program interruption fields
	 */
	public  boolean psw_check = false;
	public  boolean psw_abend = false; // RPI-1054 once per cycle
	private boolean fp_signal = false;

	public  int psw_pic = 0;
	// psw_cc? code = 3 2 1 0
	// psw_cc value = 1 2 4 8 //RPI-f174
	private final static int[] psw_carry  = { -1, 1, 1, -1, 0, -1, -1, -1, 0 }; // index by psw_cc
	private final static int[] psw_borrow = { -1, 0, 0, -1, 1, -1, -1, -1, 1 }; // index by psw_cc

	public  byte      psw_ins_len = 0;
	private byte last_psw_ins_len = 0; // RPI-845

	public  int opcode1 =  0;
	public  int opcode2 = -1;

	private final static int opcode_clc = 0xd5; // allow psw clc RPI-538
	private final static int opcode_srp = 0xf0; // RPI-820 don't S0c5 on neg shift
	private final static int opcode2_offset_e   = 1; // E PR oooo
	private final static int opcode2_offset_ri  = 1; // RI IIHH ooroiiii
	private final static int opcode2_offset_rie = 5; // RIE BRXLG oorriiii00oo
	private final static int opcode2_offset_ril = 1; // RIL BRCL oomollllllll
//	private final static int opcode2_offset_rrf = 1; // RRF MAER oooor0rr
	private final static int opcode2_offset_rre = 1; // RRE MSR oooo00rr
//	private final static int opcode2_offset_rsl = 5; // RSL TP oor0bddd00oo
	private final static int opcode2_offset_rsy = 5; // RSY LMG oorrbdddhhoo
//	private final static int opcode2_offset_rxf = 5; // RXF MAE oorxbdddr0oo
	private final static int opcode2_offset_rxe = 5; // RXE ADB oorxbddd00oo
	private final static int opcode2_offset_rxy = 5; // RXY MLG oorxbdddhhoo
	private final static int opcode2_offset_s   = 1; // S SSM oooobddd
//	private final static int opcode2_offset_siy = 5; // SIY TMY ooiibdddhhoo
	private final static int opcode2_offset_sse = 1; // SSE LASP oooobdddbddd
	private final static int opcode2_offset_ssf = 1; // SSF MVCOS oorobdddbddd

//	private int dup_opcodes = 0; // count of duplicate opcodes

	public final static int max_espie = 50;

	public  int  tot_espie = 0;
	public  int  espie_psw_cc        = 0; // RPI-809
	public  int  espie_psw_amode     = 0; // RPI-809
	public  int  espie_psw_amode_bit = 0; // RPI-809
	public  long espie_last_ins_cnt  = 0; // RPI-825

	public  boolean espie_exit_running = false;

	public  int[] espie_pie  = (int[]) Array.newInstance(int.class, max_espie);	// espie psw_pic bit mask from R0
	public  int[] espie_exit = (int[]) Array.newInstance(int.class, max_espie);	// espie exit addr from R1
	public  int[] espie_parm = (int[]) Array.newInstance(int.class, max_espie); // parm address if not zero from R15

	public  final static int max_estae = 50;

	public  int  tot_estae = 0;
	public  int  estae_psw_cc        = 0; // RPI-809
	public  int  estae_psw_amode     = 0; // RPI-809
	public  int  estae_psw_amode_bit = 0; // RPI-809
	public  long estae_last_ins_cnt  = 0; // RPI-825

	public  boolean estae_exit_running = false;

	public  int[] estae_exit = (int[]) Array.newInstance(int.class, max_estae);
	public  int[] estae_parm = (int[]) Array.newInstance(int.class, max_estae);
	public  int[] estae_link = (int[]) Array.newInstance(int.class, max_estae);

	private int if1 = 0;
	private int if2 = 0;
	private int if3 = 0; // RIE8 RNSBG RPI-817
	private int if4 = 0; // RIE4 RNSBG and CGIJ  RPI-817
	private int if5 = 0; // RIE8 RNSBG RPI-817

	private int sv1 = 0;

	private int rflen = 0;
	private int rflen1 = 0;
	private int rflen2 = 0;

	private int rf1 = 0;
	private int rf2 = 0;
	private int rf3 = 0;

	private int mf1 = 0;
	private int mf2 = 0;
	private int mf3 = 0;
	private int mf4 = 0;

	private final static int[] mask_bits = { 0, 1, 1, 2, 1, 2, 2, 3, 1, 2, 2, 3, 2, 3, 3, 4 };

	private int rv1 = 0;
	private int rv2 = 0;
	private int rv3 = 0;
	private int rvw = 0;

	private long rlv1 = 0;
	private long rlv2 = 0;
	private long rlv3 = 0;
	private long rlvw = 0;

	private int bf1 = 0;
	private int df1 = 0;
	private int xf1 = 0; // RPI-812 for ASSIST
	private int xf2 = 0;
	private int bf2 = 0;
	private int df2 = 0;

	private int bd1_loc = 0;
	private int bd2_loc = 0;
	private int bf4     = 0;
	private int df4     = 0;
	private int bd4_loc = 0;  // RRS1/RRS3 RPI-817
	private int bd1_start = 0;

	private int bd2_start = 0;

	private int xbd2_loc = 0;
	private int xbd1_loc = 0; // RPI-812 for ASSIST

	private int bd1_end = 0;

	private byte string_eod = 0;

	private byte test_control = 0; // RPI-454

	private byte test_byte1 = 0; // RPI-454

	private byte test_byte2 = 0; // RPI-454
	private byte function_byte1 = 0; // RPI-580
	private byte function_byte2 = 0; // RPI-580;

//	private boolean string_eod_found = false;

	private boolean fields_equal = true;

	private int bd2_end = 0;

	private int data_len = 0;

	private int pad_len = 0;

	private byte fill_char;
	private byte fill_mem_char = (byte)0xF5; // RPI-819
	private byte fill_reg_char = (byte)0xF4; // RPI-819

	private boolean ex_mode = false;

	private final static int ex_opcode1 = 0x44;   // EX   "44"   RPI-817
	private final static int exrl_opcode1 = 0xc6; // EXRL "C6x0" RPI-817
	private final static int exrl_opcode2 = 0x00; // EXR: "C6x0" RPI-817
	private byte ex_mod_byte = 0; // save targe+1 byte

	private int ex_psw_return = 0; // return from ex

//	private byte[] pd_bytes = (byte[]) Array.newInstance(byte.class, 16);
//	private ByteBuffer pd_byte = ByteBuffer.wrap(pd_bytes, 0, 16);

	private String pdf_str = null;

	private int pdf_str_len = 0;

	private int pdf_zeros = 0;

	private char pdf_sign = '+';
	private boolean pdf_trunc = false; // RPI-788
	private int pdf_zone = 0xf0;

	private byte pdf_next_out = 0;

	private byte pdf_next_in = 0;

	private boolean pdf_next_right = true;

//	private BigInteger big_int = null;
	private BigInteger big_int1 = null;
	private BigInteger big_int2 = null;

	private boolean pdf_is_big = false;
	private boolean pdf_signed = true;

	private BigInteger pdf_big_int = null;
	private BigInteger pdf_big_int1 = null;
	private BigInteger pdf_big_int2 = null;

	private long pdf_long = 0;
	private long pdf_long1 = 0;
	private long pdf_long2 = 0;

	private BigInteger[] big_int_array = null;

	private int pd_cc = 0;
	/*
	 * R?SBG rotate selected bits data RPI-817
	 */
	private boolean rsbg_test = false;
	private boolean rsbg_zero = false;
	private long    rsbg_mask_zeros = 0;
	private long    rsbg_mask_ones = 0;
	private boolean risb_zero = false; // RPI-1125
	private int     risb_mask_zeros = 0; // RPI-1125
	private int     risb_mask_ones = 0;  // RPI-1125

	/*
	 * 16 gpr registers
	 */
	private final static int reg_len = 128; // 16 * 8
	private byte[] reg_byte = (byte[]) Array.newInstance(byte.class, reg_len);
	public  ByteBuffer reg = ByteBuffer.wrap(reg_byte, 0, reg_len);

	private byte[] work_reg_byte = (byte[]) Array.newInstance(byte.class, 16);
	private ByteBuffer work_reg = ByteBuffer.wrap(work_reg_byte, 0, 16);

//	private byte[] log_reg_byte = new byte[9];
//	private ByteBuffer log_reg = ByteBuffer.wrap(log_reg_byte, 0, 9);

	final static int r0 = 4;
	final static int r1 = 12;
	final static int r2 = 20;
	final static int r3 = 28;
	final static int r4 = 36;
	final static int r5 = 44;
	final static int r6 = 52;
	final static int r7 = 60;
	final static int r8 = 68;
	final static int r9 = 76;
	final static int r10 = 84;
	final static int r11 = 92;
	final static int r12 = 100;
	final static int r13 = 108;
	final static int r14 = 116;
	final static int r15 = 124;

	/*
	 * 16 fp registers with eb, db, and bd co-regs to avoid conversions when
	 * possible fp_ctl defines fp reg state as follows: 0 = fp_ctl_ld no co-reg
	 * defined (set by LE,LD) 1 = fp_ctl_eb set for EB float operations 2 =
	 * fp_ctl_db set for EH, DH, DB operations 3 = fp_ctl_bd set for LH, LB
	 * operations Notes: 1. LE and LD set fp_reg with fp_ctl_ld 2. STE and STD
	 * store from fp_reg or co_reg 3. fp_reg is indexed by reg * 8 byte index 4.
	 * fp_ctl and co-regs are indexed by reg #
	 */
	public  final static byte[] fp_reg_byte = (byte[]) Array.newInstance(byte.class, 16 * 8);
	public  ByteBuffer fp_reg = ByteBuffer.wrap(fp_reg_byte, 0, 16 * 8);

	private final static byte[] trace_reg_byte = (byte[]) Array.newInstance(byte.class, 16 * 8);
	public  ByteBuffer trace_reg = ByteBuffer.wrap(trace_reg_byte, 0, 16 * 8);

	public  byte fp_ctl_ld = 0;
	private byte fp_ctl_eb = 1;  // EB
	private byte fp_ctl_db = 2;  // EH, DB
	private byte fp_ctl_bd1 = 3; // DH, ED, DD, or first half LB, LH, LD
	private byte fp_ctl_bd2 = 4; // second half LB, LH, LD
	private byte[] fp_reg_type = (byte[]) Array.newInstance(byte.class, 16);
	public  byte[] fp_reg_ctl = (byte[]) Array.newInstance(byte.class, 16);
	private float[] fp_reg_eb = (float[]) Array.newInstance(float.class, 16);
	private double[] fp_reg_db = (double[]) Array.newInstance(double.class, 16);
	private BigDecimal[] fp_reg_bd = (BigDecimal[]) Array.newInstance(BigDecimal.class, 16);
	private byte[] work_fp_reg_byte = (byte[]) Array.newInstance(byte.class, 16);
	private ByteBuffer work_fp_reg = ByteBuffer.wrap(work_fp_reg_byte, 0, 16);
	private final static boolean[] fp_pair_type  = {
			false, false, false, // DB, DD, DH
			false, false, false, // EB, ED, EH
			true,  true,  true};  // LB, LD, LH
	public  final static boolean[] fp_pair_valid = { // RPI-229
			/* 0 1 2 3 */
			true, true, false, false, // 0 - 3 (0,2) (1,3)
			true, true, false, false, // 4 - 7 (4,6) (5,7)
			true, true, false, false, // 8 - 11 (8,10) (9,11)
			true, true, false, false }; // 12 - 15 (12,14) (13,15)
	private byte[] ar_reg_byte = (byte[]) Array.newInstance(byte.class, 16 * 4); // RPI-1055
	private ByteBuffer ar_reg = ByteBuffer.wrap(ar_reg_byte, 0, 16 * 4); // RPI-1055

	// fp work variables
//	private long lrv1 = 0; // JBA-unused
	private float fp_rev1 = 0;
	private float fp_rev2 = 0;
	private double fp_rdv1 = 0;
	private double fp_rdv2 = 0;
	private double fp_rdv3 = 0;
	private double fp_rdv4 = 0;

	private BigDecimal fp_rbdv1 = null;
	private BigDecimal fp_rbdv2 = null;
	private BigDecimal fp_rbdv3 = null;
	private final static BigDecimal fp_bd_half = BigDecimal.ONE.divide(BigDecimal.valueOf(2));
	private final static BigDecimal fp_bd_two  = BigDecimal.valueOf(2);
	private BigDecimal[] fp_bd_int_rem = null; // RPI-333 bd integer and remainder
	private BigDecimal fp_bd_inc = null;

//	private int fp_bd_sqrt_scale = 0; // JBA-unused

	private byte[] work_fp_bi1_bytes = (byte[]) Array.newInstance(byte.class, 15);

	private BigInteger work_fp_bi1 = null;
	private BigDecimal work_fp_bd1 = null;
//	private BigDecimal work_fp_bd2 = null; // RPI-407 // JBA-unused

//	private long long_dh_zero = 0; // RPI-384 // JBA-unused
	private final static long long_dh_exp_bits =  (long) (0x7f) << 56;
	private final static long long_dh_man_bits = ((long) (1)    << 56) - 1;

	private int fp_round = 0;
	private long long_work = 0;
	private long long_sign = 0;
	private long long_exp = 0;
	private long long_man = 0;

	private final static long long_db_exp_bits =  (long) (0x7ff) << 52;
	private final static long long_db_one_bits = ((long) (1)     << 53) - 1;
	private final static long long_db_one_bit  = ((long) (1)     << 52);
	private final static long long_db_man_bits = ((long) (1)     << 52) - 1;
	private final static int  int_eh_exp_bits  = 0x7f << 24;
	private final static int  int_eh_zero      = 0x00000000; // RPI-384

	private final static int int_eh_man_bits = 0xffffff;
	private MathContext fp_dhg_context = null; // RPI-821 for DH
	public  MathContext fp_lxg_context = null; // RPI-821 for LB/LH
	private MathContext fp_dbg_context = null; //         for EH, DB
//	private MathContext fp_ebg_context = null; //         for EB
	public  MathContext fp_dh_context = null; // RPI-821
	public  MathContext fp_lh_context = null; // RPI-821
//	private MathContext fp_ld_context = null; // RPI-1211 // JBA-unused

	// RPI-1125 use array for BFP context
/*	private final static RoundingMode[] fp_bfp_rnd_mode = {
			RoundingMode.HALF_EVEN, // 0
			RoundingMode.DOWN,      // 1
			RoundingMode.CEILING,   // 2
			RoundingMode.FLOOR,     // 3
			RoundingMode.HALF_EVEN, // 4 not valid
			RoundingMode.HALF_EVEN, // 5 not valid
			RoundingMode.HALF_EVEN, // 6 not valid
			RoundingMode.HALF_UP,   // 7 (prepare for shorter)
	};
*/	private final static MathContext[] fp_db_rnd_context = {
			new MathContext(16,RoundingMode.HALF_EVEN), // 0
			new MathContext(16,RoundingMode.DOWN),      // 1
			new MathContext(16,RoundingMode.CEILING),   // 2
			new MathContext(16,RoundingMode.FLOOR),     // 3
			new MathContext(16,RoundingMode.HALF_EVEN), // 4 not used
			new MathContext(16,RoundingMode.HALF_EVEN), // 5 not used
			new MathContext(16,RoundingMode.HALF_EVEN), // 6 not used
			new MathContext(16,RoundingMode.HALF_UP),   // 7 (prevare for shorter)
	};
	private final static MathContext[] fp_eb_rnd_context = {
			new MathContext(7,RoundingMode.HALF_EVEN), // 0
			new MathContext(7,RoundingMode.DOWN),      // 1
			new MathContext(7,RoundingMode.CEILING),   // 2
			new MathContext(7,RoundingMode.FLOOR),     // 3
			new MathContext(7,RoundingMode.HALF_EVEN),   // 4 not used
			new MathContext(7,RoundingMode.HALF_EVEN),   // 5 not used
			new MathContext(7,RoundingMode.HALF_EVEN),   // 6 not used
			new MathContext(7,RoundingMode.HALF_UP),   // 7
	};
	public  final static MathContext[] fp_lb_rnd_context = {
			new MathContext(34,RoundingMode.HALF_EVEN), // 0
			new MathContext(34,RoundingMode.DOWN),      // 1
			new MathContext(34,RoundingMode.CEILING),   // 2
			new MathContext(34,RoundingMode.FLOOR),     // 3
			new MathContext(34,RoundingMode.HALF_EVEN), // 4 not used
			new MathContext(34,RoundingMode.HALF_EVEN), // 5 not used
			new MathContext(34,RoundingMode.HALF_EVEN), // 6 not used
			new MathContext(34,RoundingMode.HALF_UP),   // 7
	};
//	private final static byte fp_hfp_class = 0; // JBA-unused
	private final static byte fp_bfp_class = 1;
	private final static byte fp_dfp_class = 3;
	private final static RoundingMode[] fp_dfp_rnd_mode = {
			RoundingMode.HALF_EVEN, // 0
			RoundingMode.DOWN,      // 1
			RoundingMode.CEILING,   // 2
			RoundingMode.FLOOR,     // 3
			RoundingMode.HALF_UP,   // 4
			RoundingMode.HALF_DOWN, // 5
			RoundingMode.UP,        // 6
			RoundingMode.HALF_UP,   // 7 (prepare for shorter)
	};
	public  final static MathContext[] fp_dd_rnd_context = {
			new MathContext(16,RoundingMode.HALF_EVEN), // 0
			new MathContext(16,RoundingMode.DOWN),      // 1
			new MathContext(16,RoundingMode.CEILING),   // 2
			new MathContext(16,RoundingMode.FLOOR),     // 3
			new MathContext(16,RoundingMode.HALF_UP),   // 4
			new MathContext(16,RoundingMode.HALF_DOWN), // 5
			new MathContext(16,RoundingMode.UP),        // 6
			new MathContext(16,RoundingMode.HALF_UP),   // 7 (prevare for shorter)
	};
	public  final static MathContext[] fp_ed_rnd_context = {
			new MathContext(7,RoundingMode.HALF_EVEN), // 0
			new MathContext(7,RoundingMode.DOWN),      // 1
			new MathContext(7,RoundingMode.CEILING),   // 2
			new MathContext(7,RoundingMode.FLOOR),     // 3
			new MathContext(7,RoundingMode.HALF_UP),   // 4
			new MathContext(7,RoundingMode.HALF_DOWN), // 5
			new MathContext(7,RoundingMode.UP),        // 6
			new MathContext(7,RoundingMode.HALF_UP),   // 7
	};
	public  final static MathContext[] fp_ld_rnd_context = {
			new MathContext(34,RoundingMode.HALF_EVEN), // 0
			new MathContext(34,RoundingMode.DOWN),      // 1
			new MathContext(34,RoundingMode.CEILING),   // 2
			new MathContext(34,RoundingMode.FLOOR),     // 3
			new MathContext(34,RoundingMode.HALF_UP),   // 4
			new MathContext(34,RoundingMode.HALF_DOWN), // 5
			new MathContext(34,RoundingMode.UP),        // 6
			new MathContext(34,RoundingMode.HALF_UP),   // 7
	};
	private final static MathContext[] fp_dh_rnd_context = { // RPI-1211
			new MathContext(15,RoundingMode.HALF_EVEN), // 0
			new MathContext(15,RoundingMode.DOWN),      // 1
			new MathContext(15,RoundingMode.CEILING),   // 2
			new MathContext(15,RoundingMode.FLOOR),     // 3
			new MathContext(15,RoundingMode.HALF_UP),   // 4
			new MathContext(15,RoundingMode.HALF_DOWN), // 5
			new MathContext(15,RoundingMode.UP),        // 6
			new MathContext(15,RoundingMode.HALF_UP),   // 7
	};

	private final static double     fp_log2     = Math.log(2);
	private final static double     fp_log10    = Math.log(10);
//	private final static BigDecimal fp_bd       = new BigDecimal("0"); // JBA-unused
	private              BigInteger fp_big_int1 = new BigInteger("0");
	private              BigInteger fp_big_int2 = new BigInteger("0");
	private              BigDecimal fp_big_dec2 = new BigDecimal("0");
//	private final static BigDecimal fp_big_dec3 = new BigDecimal("0"); // JBA-unused

	private final BigInteger fp_big_int_one_bits    = BigInteger.ONE.shiftLeft(113).subtract(BigInteger.ONE);
	private final BigInteger fp_big_int_lx_man_bits = BigInteger.ONE.shiftLeft(112).subtract(BigInteger.ONE);
	private final BigInteger fp_big_int_dh_man_bits = BigInteger.ONE.shiftLeft( 56).subtract(BigInteger.ONE);
	private int fp_int1 = 0;
	private int fp_int2 = 0; // RPI-767

//	private final int fp_int_eb_one_bits = 0xffffff; // JBA - Unused at the moment.
//	private final int fp_int_eb_man_bits = 0x7fffff; // JBA - Unused at the moment.
//	private final int fp_int_eh_man_bits = 0xffffff; // JBA - Unused at the moment.

	private long fp_long1 = 0;
	private long fp_long2 = 0;
	private long fp_long3 = 0;
	private byte fp_exp1  = 0;
	private byte fp_exp2  = 0;
	private byte fp_exp3  = 0;
	private byte fp_sign1 = 0;
	private byte fp_sign2 = 0;
//	private byte fp_sign3 = 0; // JBA-unused
//	private final static long  fp_long_db_one_bits = ((long) (1) << 53) - 1; // JBA - Unused at the moment.
//	private final static long  fp_long_db_man_bits = ((long) (1) << 52) - 1; // JBA - Unused at the moment.
//	private final static long  fp_long_dh_man_bits = ((long) (1) << 56) - 1; // JBA - Unused at the moment.
	private final static int   fp_eb_pos_inf = 0x7f8 << 23; // RPI-830
	private final static int   fp_eb_neg_inf = 0xff8 << 23; // RPI-830
	private final static long  fp_db_pos_inf = (long)(0x7ff) << 52; // RPI-830
	private final static long  fp_db_neg_inf = (long)(0xfff) << 52; // RPI-830
	private final static long  fp_dd_pos_inf = (long)(0x7a) << 56;
	private final static long  fp_dd_neg_inf = (long)(0xfa) << 56;
	private final static long  fp_lb_pos_inf = (long)(0x7a) << 56; // RPI-830
	private final static long  fp_lb_neg_inf = (long)(0xfa) << 56; // RPI-830
	private final static long  fp_ld_pos_inf = (long)(0x7fff) << 48;
	private final static long  fp_ld_neg_inf = (long)(0xffff) << 48;
	private final static float fp_eb_min = (float) 1.2e-38; // BFP range ref. pop 19-5
	private final static float fp_eb_max = (float) 3.4e+38;
	private final static double fp_db_min = 2.2e-308;
	private final static double fp_db_max = 1.79e+308; // (1.8 too big?)
	private final static double fp_eh_min = 5.41e-79; // HFP range ref. pop 18-4
	private final static double fp_eh_max = 7.2e+75;
	private final static BigDecimal fp_dh_min = BigDecimal.valueOf(5.41e-79); // RPI-821
	private final static BigDecimal fp_dh_max = BigDecimal.valueOf(7.2e+75);  // RPI-821

	private BigDecimal fp_lh_min = null;
	private BigDecimal fp_lh_max = null;

	private BigDecimal fp_lb_min = null; // RPI-367 allow (MIN)
	private BigDecimal fp_lb_neg_zero = null; // RPI-834
	private BigDecimal fp_lb_max = null;
	private BigDecimal fp_dd_pos_max = null;
	private BigDecimal fp_dd_pos_min = null;
	private BigDecimal fp_dd_neg_max = null;
	private BigDecimal fp_dd_neg_min = null;
	private BigDecimal fp_ed_pos_max = null;
	private BigDecimal fp_ed_pos_min = null;
	private BigDecimal fp_ed_neg_max = null;
	private BigDecimal fp_ed_neg_min = null;
	private BigDecimal fp_ld_pos_max = null;
	private BigDecimal fp_ld_pos_min = null;
	private BigDecimal fp_ld_neg_max = null;
	private BigDecimal fp_ld_neg_min = null;
	private final static int fp_dd_exp_min = -398;
	private final static int fp_dd_exp_max =  369;
	private final static int fp_ed_exp_min = -101;
	private final static int fp_ed_exp_max =   90;
	private final static int fp_ld_exp_min = -6178;
	private final static int fp_ld_exp_max =  6111;

	/*
	 * PC, PR, PT stack for psw and regs
	 */
	private int cur_pc_stk = 0;
	private int cur_pc_stk_reg = 0;

	private byte[] pc_stk_reg_byte = (byte[]) Array.newInstance(byte.class, max_pc_stk * reg_len);

	private ByteBuffer pc_stk_reg = ByteBuffer.wrap(pc_stk_reg_byte, 0, max_pc_stk * reg_len);

	private int[] pc_stk_psw_loc = (int[]) Array.newInstance(int.class, max_pc_stk);

	private int[] pc_stk_psw_cc = (int[]) Array.newInstance(int.class, max_pc_stk);
	private boolean[] pc_stk_type_pc = (boolean[]) Array.newInstance(boolean.class,max_pc_stk); // RPI-1026 PC vs BAKR

	// virtual memory with 24 bit and 31 bit fqes all initialized by init_mem()
	private final static int mem24_start =    0x8000; // RPI-276 start at 32k RPI-894 was 64k
	private final static int mem24_line  = 0x1000000; // start at 1MB if avail.

	public  byte[] mem_byte = null; // see init_mem
	public  ByteBuffer mem = null; // see init_mem

	public  int dsa24_start = 0;
	public  int dsa24_end = 0;
	public  int dsa31_start = 0;
	public  int dsa31_end = 0;

	public  int tot_mem = 0;
	public  int tot_mem_alloc = 0;

	/**
	 * psa low memory supported fields
	 */
	private final static int psa_cvt         =   0x10; // pointer to os cvt
	private final static int psa_svc_old_psw =   0x20;
	private final static int psa_svc_new_psw =   0x60;
	private final static int psa_pgm_old_psw =   0x28; // RPI-1063 see update_psa
//	private final static int psa_pgm_nwq_paq =   0x68; // RPI-63 // JBA-unused
	private final static int psa_cvt2        =   0x4c; // pointer to os cvt
	private final static int psa_psw_ins_len =   0x8d; // RPI-1063 see update_psa
	private final static int psa_len         = 0x2000; // length of PSA (see PSAD macro) RPI-538
	/*
	 * z390 communication vector table at x'2000';
	 */
	private final static int zcvt_start       = 0x2000; // RPI-286 // cvt start
	public  final static int zcvt_user_pgm    = zcvt_start +  0x00; // user pgm name
	public  final static int zcvt_ipl_pgm     = zcvt_start +  0x08; // ipl pgm name
	public  final static int zcvt_fqe24       = zcvt_start +  0x10; // amode 24 fqe
	public  final static int zcvt_fqe31       = zcvt_start +  0x14; // amode 31 fqe
	public  final static int zcvt_exit        = zcvt_start +  0x18; // svc 3 exit to last link or term
	public  final static int zcvt_tget_ecb    = zcvt_start +  0x1c; // ecb for tget reply in non GUAM GUI mode
	public  final static int zcvt_save        = zcvt_start + 0x100; // user save
	public  final static int zcvt_stimer_save = zcvt_start + 0x200;
	public  final static int zcvt_exec_parma  = zcvt_start + 0x300; // address of exec_parm RPI-582
	public  final static int zcvt_exec_parm   = zcvt_start + 0x304; // half word length followed by EBCDIC/ASCII value of PARM(.)
	private final static int zcvt_epie        = zcvt_start + 0x400; // espie passed in r1
	private final static int zcvt_sdwa        = zcvt_start + 0x500; // sdwa passed in r1 to ESTAE exit RPI-845
	private final static int zcvt_comrg       = zcvt_start + 0x600; // start of VSE COMRG area RPI-558

	/*
	 * OS/MVS compatible CVT with pointer at x'10'
	 */
	private final static int cvt_start = 0x2000;           // RPI-894 was 0x8000
//	private final static int cvt_date  = cvt_start + 0x38; // IPL date // JBA-unused

	private final static int cvt_dcb   = cvt_start + 0x74; // OS flags (x'80' 31 bit, x'13' MVS+) RPI
	public  final static int cvt_cde   = cvt_start + 208;  // RPI-1063

	/*
	 * cde offsets (see mac\CDED.MAC)
	 */
	public  final static int cde_cdchain   =  0; // next CDE (first pointed to by cvtcde)
	public  final static int cde_cdname    =  8; // load module name in EBCDIC
	public  final static int cde_cdentpt   = 16; // entry point
	public  final static int cde_cduse     = 24; // use count 0 = deleted cde
	public  final static int cde_cdloadpt  = 32; // load address
	public  final static int cde_cdmodlen  = 36; // module length
//	private final static int cde_len       = 40; // length of CDE entry block // JBA-unused

	/*
	 * VSE COMRG data fields
	 */
	private final static int zcvt_comrg_jobdate = zcvt_comrg +  0; // COMRG JOBDATE  0  8 MM/DD/YY
	private final static int zcvt_comrg_comname = zcvt_comrg + 24; // COMRG COMNAME 24  8 JOB NAME
	/*
	 * epie fields
	 */
	private final static int epie_id = zcvt_epie; // C'EPIE'

	private final static int epie_parm  = zcvt_epie + 0x04; // ESPIE PARAM addr

	public  final static int epie_psw   = zcvt_epie + 0x48; // PSW int,addr RPI-845
	private final static int epie_ilc   = zcvt_epie + 0x51; // RPI-845 last instruction length byte (2,4,6)
	private final static int epie_inc   = zcvt_epie + 0x52; // RPI-845 interruption code (2 bytes)
	private final static int epie_flags = zcvt_epie + 0x99; // RPI-845 set X'40' 64 bit reg flag
	public  final static int epie_gpr   = zcvt_epie + 0xA0; // GPR 64 bit regs R0-R15 RPI-845

	/*
	 * sdwa dsect fields (r1 at exit entry)
	 */
	private final static int sdwa_parm = zcvt_sdwa +  0x00; // SDWA ESPIE PARAM addr
	private final static int sdwa_cmp  = zcvt_sdwa +  0x04; // SDWA SDWAABSS completion code FFSSSUUU RPI-845
	private final static int sdwa_psw  = zcvt_sdwa +  0x68; // SDWA SDWAEC1 PSW at error RPI-845
	private final static int sdwa_xpad = zcvt_sdwa + 0x170; // SDWA addr extensions RPI-845
	private final static int sdwa_ptrs = zcvt_sdwa + 0x200; // SDWA address for extensions RPI-845
	private final static int sdwa_xeme = sdwa_ptrs +  0x18; // SDWA PTRS addr of SDWARC4 regs RPI-845
	private final static int sdwa_rc4  = zcvt_sdwa + 0x300; // SDWA RC4 registers extension RPI-834
	public  final static int sdwa_g64  = sdwa_rc4  +  0x00; // SDWA RC4 extension 16 - 64 bit regs at error RPI-845

	/**
	 * byte bit count lookup table
	 */
	private final static byte[] bit_cnt = {  // RPI-1125 for use by POPCNT instr
			00,01,01,02,01,02,02,03,01,02,02,03,02,03,03,04, //  0
			01,02,02,03,02,03,03,04,02,03,03,04,03,04,04,05, //  1
			01,02,02,03,02,03,03,04,02,03,03,04,03,04,04,05, //  2
			02,03,03,04,03,04,04,05,03,04,04,05,04,05,05,06, //  3
			01,02,02,03,02,03,03,04,02,03,03,04,03,04,04,05, //  4
			02,03,03,04,03,04,04,05,03,04,04,05,04,05,05,06, //  5
			02,03,03,04,03,04,04,05,03,04,04,05,04,05,05,06, //  6
			03,04,04,05,04,05,05,06,04,05,05,06,05,06,06,07, //  7
			01,02,02,03,02,03,03,04,02,03,03,04,03,04,04,05, //  8
			02,03,03,04,03,04,04,05,03,04,04,05,04,05,05,06, //  9
			02,03,03,04,03,04,04,05,03,04,04,05,04,05,05,06, //  A
			03,04,04,05,04,05,05,06,04,05,05,06,05,06,06,07, //  B
			02,03,03,04,03,04,04,05,03,04,04,05,04,05,05,06, //  C
			03,04,04,05,04,05,05,06,04,05,05,06,05,06,06,07, //  D
			03,04,04,05,04,05,05,06,04,05,05,06,05,06,06,07, //  E
			04,05,05,06,05,06,06,07,05,06,06,07,06,07,07, 8  //  F
	};

	/**
	 * opcode lookup tables unique to ez390
	 */
			final static int[] op_type_offset = new int[256];
	private	final static int[] op_type_mask   = new int[256];
			final static int[] opcode2_offset = new int[256];
			final static int[] opcode2_mask   = new int[256];

	/*
	 * End of pz390 global variables
	 */

	/**
	 * Execute 390 code at psw_addr in mem[].
	 */
	public void exec_pz390()
	{
		psw_check = false;
		last_psw_ins_len = 0;
		while (!tz390.z390_abort && !psw_check) { // RPI-208 run until check or	// abort
			if (sz390.stimer_exit_request) { // RPI-323 allow opcode break on	// first stimer exit opcode
				sz390.start_stimer_exit();
			}
			if (tz390.opt_test) {
				sz390.process_test_cmd();
			}
			tz390.systerm_ins++;
			trace_table_index = trace_table_next[trace_table_index];
			if (psw_amode == psw_amode31) {
				trace_table_addr[trace_table_index] = psw_loc | int_high_bit;
			} else {
				trace_table_addr[trace_table_index] = psw_loc;
			}
			last_psw_ins_len = psw_ins_len; // RPI-845
			opcode1 = mem_byte[psw_loc] & 0xff;
			opcode2 = -1;
			psw_check = true;
			psw_abend = false; // RPI-1054
			psw_pic = Constants.psw_pic_oper;
			if (opcode1 < 0x80) {
				if (opcode1 < 0x40) {
					ins_lt_40();
				} else {
					ins_lt_80();
				}
			} else {
				if (opcode1 < 0xc0) {
					ins_lt_c0();
				} else {
					ins_lt_ff();
				}
			}
			if (psw_check) {
				if (tz390.timeout) { // RPI-1094
					set_psw_check(Constants.psw_pic_timeout); // RPI-1054
				} else if (psw_pic != 0) { // RPI-301
					if (psw_pic == Constants.psw_pic_oper && tz390.opt_trace) { // RPI-474
						trace_psw();
					}
					set_psw_check(Constants.psw_pic_oper);
				}
			}
			if (ex_mode
				&& !(opcode1 == ex_opcode1)
				&& !((opcode1 == exrl_opcode1)
					&& opcode2 == exrl_opcode2)
				) {
				set_psw_loc(ex_psw_return);
			}
		}
	}

	/**
	 * Execute opcodes < x'40'.
	 */
	private void ins_lt_40()
	{
		switch (opcode1) {
		case 0x01:
			ins_01XX();
			break;
		case 0x04: // 90 "04" "SPM" "RR"
			psw_check = false;
			ins_setup_rr();
			rv1 = (reg.getInt(rf1 + 4) >> 24) & 0x3f;
			psw_pgm_mask = rv1 & 0xf;
			psw_cc = psw_cc_mask[rv1 >> 4];
			break;
		case 0x05: // 100 "05" "BALR" "RR"
			psw_check = false;
			ins_setup_rr();
			if (rf2 != 0) {
				rv2 = reg.getInt(rf2 + 4); // RPI-65
			}
			reg.putInt(rf1 + 4, psw_loc | psw_amode_bit);
			if (rf2 != 0) {
				set_psw_loc(rv2); // RPI-65
			}
			break;
		case 0x06: // 110 "06" "BCTR" "RR"
			psw_check = false;
			ins_setup_rr();
			rv1 = reg.getInt(rf1 + 4) - 1;
			reg.putInt(rf1 + 4, rv1);
			if (rf2 != 0 && rv1 != 0) {
				set_psw_loc(reg.getInt(rf2 + 4));
			}
			break;
		case 0x07: // 120 "07" "BCR" "RR"
			psw_check = false;
			ins_setup_rr();
			if ((psw_cc & mf1) > 0 && (rf1 != 0)) {
				set_psw_loc(reg.getInt(rf2 + 4));
			}

			break;
		case 0x0A: // 290 "0A" "SVC" "I"
			psw_check = false;
			ins_setup_i();
			if (mem.get(psa_svc_new_psw) == 0) { // native svc call
				sz390.svc(if1);
			} else { // user svc exit
				mem.putShort(psa_svc_old_psw + 2, (short) if1);
				mem.putInt(psa_svc_old_psw + 4, psw_loc);
				set_psw_loc(mem.getInt(psa_svc_new_psw + 4));
			}
			break;
		case 0x0B: // 300 "0B" "BSM" "RR"
			psw_check = false;
			ins_setup_rr();
			if (rf1 != 0) {
				if (psw_amode == psw_amode31) {
					reg.putInt(rf1 + 4, reg.getInt(rf1 + 4) | psw_amode31_bit);
				} else {
					reg.putInt(rf1 + 4, reg.getInt(rf1 + 4) & psw_amode31);
				}
			}
			if (rf2 != 0) {
				rv2 = reg.getInt(rf2 + 4);
				if ((rv2 & psw_amode31_bit) != 0) {
					set_psw_amode(psw_amode31_bit);
				} else {
					set_psw_amode(psw_amode24_bit);
				}
				set_psw_loc(rv2);
			}
			break;
		case 0x0C: // 310 "0C" "BASSM" "RR"
			psw_check = false;
			ins_setup_rr();
			if (rf2 != 0) {
				rv2 = reg.getInt(rf2 + 4); // RPI-65
			}
			reg.putInt(rf1 + 4, psw_loc | psw_amode_bit);
			if (rf2 != 0) {
				if ((rv2 & psw_amode31_bit) != 0) {
					set_psw_amode(psw_amode31_bit);
				} else {
					set_psw_amode(psw_amode24_bit);
				}
				set_psw_loc(rv2);
			}
			break;
		case 0x0D: // 320 "0D" "BASR" "RR"
			psw_check = false;
			ins_setup_rr();
			if (rf2 != 0) {
				rv2 = reg.getInt(rf2 + 4); // RPI-65
			}
			reg.putInt(rf1 + 4, psw_loc | psw_amode_bit);
			if (rf2 != 0) {
				set_psw_loc(rv2); // RPI-65
			}
			break;
		case 0x0E: // 330 "0E" "MVCL" "RR"
			psw_check = false;
			ins_setup_rr();
			if ((mf1 & 1) != 0) { // RPI-758
				set_psw_check(Constants.psw_pic_spec);
			}
			if ((mf2 & 1) != 0) { // RPI-758
				set_psw_check(Constants.psw_pic_spec);
			}
			exec_mvcl();
			break;
		case 0x0F: // 340 "0F" "CLCL" "RR"
			psw_check = false;
			ins_setup_rr();
			if ((mf1 & 1) != 0) { // RPI-758
				set_psw_check(Constants.psw_pic_spec);
			}
			if ((mf2 & 1) != 0) { // RPI-758
				set_psw_check(Constants.psw_pic_spec);
			}
			exec_clcl();
			break;
		case 0x10: // 350 "10" "LPR" "RR"
			psw_check = false;
			ins_setup_rr();
			rv1 = reg.getInt(rf2 + 4);
			if (rv1 < 0) {
				if (rv1 == int_high_bit) {
					psw_cc = psw_cc3;
					break;
				}
				rv1 = -rv1;
			}
			reg.putInt(rf1 + 4, rv1);
			psw_cc = get_int_comp_cc(rv1, 0);
			break;
		case 0x11: // 360 "11" "LNR" "RR"
			psw_check = false;
			ins_setup_rr();
			rv1 = reg.getInt(rf2 + 4);
			if (rv1 > 0) {
				rv1 = -rv1;
			}
			reg.putInt(rf1 + 4, rv1);
			psw_cc = get_int_comp_cc(rv1, 0);
			break;
		case 0x12: // 370 "12" "LTR" "RR"
			psw_check = false;
			ins_setup_rr();
			rv1 = reg.getInt(rf2 + 4);
			reg.putInt(rf1 + 4, rv1);
			psw_cc = get_int_comp_cc(rv1, 0);
			break;
		case 0x13: // 380 "13" "LCR" "RR"
			psw_check = false;
			ins_setup_rr();
			rv1 = reg.getInt(rf2 + 4);
			if (rv1 == int_high_bit) {
				psw_cc = psw_cc3;
				break;
			}
			rv1 = -rv1;
			reg.putInt(rf1 + 4, rv1);
			psw_cc = get_int_comp_cc(rv1, 0);
			break;
		case 0x14: // 390 "14" "NR" "RR"
			psw_check = false;
			ins_setup_rr();
			rv1 = reg.getInt(rf1 + 4) & reg.getInt(rf2 + 4);
			reg.putInt(rf1 + 4, rv1);
			if (rv1 == 0) {
				psw_cc = psw_cc0;
			} else {
				psw_cc = psw_cc1;
			}
			break;
		case 0x15: // 400 "15" "CLR" "RR"
			psw_check = false;
			ins_setup_rr();
			psw_cc = get_int_log_comp_cc(reg.getInt(rf1 + 4), reg
					.getInt(rf2 + 4));
			break;
		case 0x16: // 410 "16" "OR" "RR"
			psw_check = false;
			ins_setup_rr();
			rv1 = reg.getInt(rf1 + 4) | reg.getInt(rf2 + 4);
			reg.putInt(rf1 + 4, rv1);
			if (rv1 == 0) {
				psw_cc = psw_cc0;
			} else {
				psw_cc = psw_cc1;
			}
			break;
		case 0x17: // 420 "17" "XR" "RR"
			psw_check = false;
			ins_setup_rr();
			rv1 = reg.getInt(rf1 + 4) ^ reg.getInt(rf2 + 4);
			reg.putInt(rf1 + 4, rv1);
			if (rv1 == 0) {
				psw_cc = psw_cc0;
			} else {
				psw_cc = psw_cc1;
			}
			break;
		case 0x18: // 430 "18" "LR" "RR"
			psw_check = false;
			ins_setup_rr();
			reg.putInt(rf1 + 4, reg.getInt(rf2 + 4));
			break;
		case 0x19: // 440 "19" "CR" "RR"
			psw_check = false;
			ins_setup_rr();
			psw_cc = get_int_comp_cc(reg.getInt(rf1 + 4), reg.getInt(rf2 + 4));
			break;
		case 0x1A: // 450 "1A" "AR" "RR"
			psw_check = false;
			ins_setup_rr();
			rv1 = reg.getInt(rf1 + 4);
			rv2 = reg.getInt(rf2 + 4);
			rv3 = rv1 + rv2;
			reg.putInt(rf1 + 4, rv3);
			psw_cc = get_int_add_cc();
			break;
		case 0x1B: // 460 "1B" "SR" "RR"
			psw_check = false;
			ins_setup_rr();
			rv1 = reg.getInt(rf1 + 4);
			rv2 = reg.getInt(rf2 + 4);
			rv3 = rv1 - rv2;
			reg.putInt(rf1 + 4, rv3);
			psw_cc = get_int_sub_cc();
			break;
		case 0x1C: // 470 "1C" "MR" "RR"
			psw_check = false;
			ins_setup_rr();
			if ((mf1 & 1) != 0) { // RPI-758
				set_psw_check(Constants.psw_pic_spec);
			}
			rlv1 = (long) reg.getInt(rf1 + 12) * (long) reg.getInt(rf2 + 4); // RPI-272
			reg.putInt(rf1 + 4, (int) (rlv1 >> 32));
			reg.putInt(rf1 + 12, (int) (rlv1 & long_low32_bits));
			break;
		case 0x1D: // 480 "1D" "DR" "RR"
			psw_check = false;
			ins_setup_rr();
			if ((mf1 & 1) != 0) { // RPI-758
				set_psw_check(Constants.psw_pic_spec);
			}
			rlv1 = (long) (reg.getInt(rf1 + 4)) << 32
					| ((long) reg.getInt(rf1 + 12) & long_low32_bits); // RPI-398
			rv2 = reg.getInt(rf2 + 4);
			if (rv2 == 0) {
				set_psw_check(Constants.psw_pic_fx_div);
				break;
			}
			rv1 = (int) (rlv1 / rv2); // RPI-398
			rv2 = (int) rlv1 - rv1 * rv2;
			reg.putInt(rf1 + 4, rv2);
			reg.putInt(rf1 + 12, rv1);
			break;
		case 0x1E: // 490 "1E" "ALR" "RR"
			psw_check = false;
			ins_setup_rr();
			rvw = reg.getInt(rf1 + 4);
			rv2 = reg.getInt(rf2 + 4);
			rv1 = rvw + rv2;
			reg.putInt(rf1 + 4, rv1);
			psw_cc = get_int_log_add_cc();
			break;
		case 0x1F: // 500 "1F" "SLR" "RR"
			psw_check = false;
			ins_setup_rr();
			rvw = reg.getInt(rf1 + 4);
			rv2 = reg.getInt(rf2 + 4);
			rv1 = rvw - rv2;
			reg.putInt(rf1 + 4, rv1);
			psw_cc = get_int_log_sub_cc();
			break;
		case 0x20: // 510 "20" "LPDR" "RR"
			psw_check = false;
			ins_setup_rr();
			fp_rbdv1 = fp_get_bd_from_dh(fp_reg, rf2).abs();      // RPI-821
			fp_put_bd(rf1, tz390.fp_dh_type, fp_rbdv1);           // RPI-821
			psw_cc = fp_get_dh_comp_cc(fp_rbdv1,BigDecimal.ZERO); // RPI-821
			break;
		case 0x21: // 520 "21" "LNDR" "RR"
			psw_check = false;
			ins_setup_rr();
			fp_rbdv1 = fp_get_bd_from_dh(fp_reg, rf2).negate();   // RPI-821
			fp_put_bd(rf1, tz390.fp_dh_type, fp_rbdv1);           // RPI-821
			psw_cc = fp_get_dh_comp_cc(fp_rbdv1,BigDecimal.ZERO); // RPI-821
			break;
		case 0x22: // 530 "22" "LTDR" "RR"
			psw_check = false;
			ins_setup_rr();
			fp_rbdv1 = fp_get_bd_from_dh(fp_reg, rf2);  // RPI-821
			fp_put_bd(rf1, tz390.fp_dh_type, fp_rbdv1); // RPI-821
			psw_cc = fp_get_dh_comp_cc(fp_rbdv1,BigDecimal.ZERO); // RPI-821
			break;
		case 0x23: // 540 "23" "LCDR" "RR"
			psw_check = false;
			ins_setup_rr();
			fp_rbdv1 = fp_get_bd_from_dh(fp_reg, rf2);  // RPI-821
			if (fp_rbdv1.signum() != 0) {
				fp_rbdv1 = fp_rbdv1.negate();  // RPI-821
			}
			fp_put_bd(rf1, tz390.fp_dh_type, fp_rbdv1); // RPI-821
			psw_cc = fp_get_dh_comp_cc(fp_rbdv1,BigDecimal.ZERO); // RPI-821
			break;
		case 0x24: // 550 "24" "HDR" "RR"
			psw_check = false;
			ins_setup_rr();
			fp_rbdv1 = fp_get_bd_from_dh(fp_reg, rf2).divide(fp_bd_two);  // RPI-821
			fp_put_bd(rf1, tz390.fp_dh_type, fp_rbdv1);  // RPI-821
			break;
		case 0x25: // 560 "25" "LDXR" "RR"
			psw_check = false;
			ins_setup_rr();
			fp_load_reg(rf1, tz390.fp_dh_type, fp_reg, rf2, tz390.fp_lh_type);
			break;
		case 0x26: // 580 "26" "MXR" "RR"
			psw_check = false;
			ins_setup_rr();
			fp_rbdv1 = fp_get_bd_from_lh(fp_reg, rf1)
					.multiply(fp_get_bd_from_lh(fp_reg, rf2), fp_lxg_context); // RPI-821
			fp_put_bd(rf1, tz390.fp_lh_type, fp_rbdv1);
			check_lh_mpy();
			break;
		case 0x27: // 590 "27" "MXDR" "RR"
			psw_check = false;
			ins_setup_rr();
			fp_rbdv1 = fp_get_bd_from_dh(fp_reg, rf1).round(fp_dh_context)
					.multiply(fp_get_bd_from_dh(fp_reg, rf2).round(fp_dh_context), fp_lxg_context); // RPI-821
			fp_put_bd(rf1, tz390.fp_lh_type, fp_rbdv1);
			check_lh_mpy();
			break;
		case 0x28: // 600 "28" "LDR" "RR"
			psw_check = false;
			ins_setup_rr();
			int fp_ctl_index1 = rf1 >>> 3;
			int fp_ctl_index2 = rf2 >>> 3;
			fp_copy_reg(fp_ctl_index1,fp_ctl_index2); // RPI-816
			break;
		case 0x29: // 610 "29" "CDR" "RR"
			psw_check = false;
			ins_setup_rr();
			psw_cc = fp_get_dh_comp_cc(fp_get_bd_from_dh(fp_reg, rf1),
					fp_get_bd_from_dh(fp_reg, rf2));  // RPI-821
			break;
		case 0x2A: // 620 "2A" "ADR" "RR"
			psw_check = false;
			ins_setup_rr();
			fp_rbdv1 = fp_get_bd_from_dh(fp_reg, rf1)
					 .add(fp_get_bd_from_dh(fp_reg, rf2));  // RPI-821
			fp_put_bd(rf1, tz390.fp_dh_type, fp_rbdv1);  // RPI-821
			psw_cc = fp_get_dh_add_sub_cc();
			break;
		case 0x2B: // 630 "2B" "SDR" "RR"
			psw_check = false;
			ins_setup_rr();
			fp_rbdv1 = fp_get_bd_from_dh(fp_reg,rf1)
					.subtract(fp_get_bd_from_dh(fp_reg,rf2)); // RPI-821
			fp_put_bd(rf1, tz390.fp_dh_type, fp_rbdv1);  // RPI-821
			psw_cc = fp_get_dh_add_sub_cc();
			break;
		case 0x2C: // 640 "2C" "MDR" "RR"
			psw_check = false;
			ins_setup_rr();
			fp_rbdv1 = fp_get_bd_from_dh(fp_reg, rf1)
					.multiply(fp_get_bd_from_dh(fp_reg, rf2));  // RPI-821
			fp_put_bd(rf1, tz390.fp_dh_type, fp_rbdv1);  // RPI-821
			check_dh_mpy();
			break;
		case 0x2D: // 650 "2D" "DDR" "RR"
			psw_check = false;
			ins_setup_rr();
			fp_rbdv1 = fp_get_bd_from_dh(fp_reg, rf1);  // RPI-821
			fp_rbdv2 = fp_get_bd_from_dh(fp_reg, rf2);  // RPI-821
			if (fp_rbdv2.signum() != 0) {
				fp_rbdv1 = fp_rbdv1.divide(fp_rbdv2, fp_dhg_context).round(
						fp_dhg_context); // RPI-821
			} else {
				fp_rbdv1 = BigDecimal.ZERO; // RPI-824
			}
			fp_put_bd(rf1, tz390.fp_dh_type, fp_rbdv1);  // RPI-821
			check_dh_div();
			break;
		case 0x2E: // 660 "2E" "AWR" "RR"
			psw_check = false;
			ins_setup_rr();
			// unnormalized HFP RPI-767
			fp_store_reg(fp_reg,rf1);
			fp_long1 = fp_reg.getLong(rf1);
			fp_long2 = fp_reg.getLong(rf2);
			fp_add_unnorm_dh(); // RPI-767 add unnormalized long and set cc
			fp_reg.putLong(rf1,fp_long1);
			break;
		case 0x2F: // 670 "2F" "SWR" "RR"
			psw_check = false;
			ins_setup_rr();
			// unnormalized HFP RPI-767
			fp_store_reg(fp_reg,rf1);
			fp_long1 = fp_reg.getLong(rf1);
			fp_long2 = fp_reg.getLong(rf2) ^ long_high_bit;
			fp_add_unnorm_dh(); // RPI-767 add unnormalized long and set cc
			fp_reg.putLong(rf1,fp_long1);
			break;
		case 0x30: // 680 "30" "LPER" "RR"
			psw_check = false;
			ins_setup_rr();
			fp_rdv1 = Math.abs(fp_get_db_from_eh(fp_reg, rf2));
			fp_put_db(rf1, tz390.fp_eh_type, fp_rdv1);
			psw_cc = fp_get_eh_comp_cc(fp_rdv1, 0);
			break;
		case 0x31: // 690 "31" "LNER" "RR"
			psw_check = false;
			ins_setup_rr();
			fp_rdv1 = -Math.abs(fp_get_db_from_eh(fp_reg, rf2));
			fp_put_db(rf1, tz390.fp_eh_type, fp_rdv1);
			psw_cc = fp_get_eh_comp_cc(fp_rdv1, 0);
			break;
		case 0x32: // 700 "32" "LTER" "RR"
			psw_check = false;
			ins_setup_rr();
			fp_rdv1 = fp_get_db_from_eh(fp_reg, rf2);
			fp_put_db(rf1, tz390.fp_eh_type, fp_rdv1);
			psw_cc = fp_get_eh_comp_cc(fp_rdv1, 0);
			break;
		case 0x33: // 710 "33" "LCER" "RR"
			psw_check = false;
			ins_setup_rr();
			fp_rdv1 = fp_get_db_from_eh(fp_reg, rf2);
			if (fp_rdv1 != 0) {
				fp_rdv1 = -fp_rdv1;
			}
			fp_put_db(rf1, tz390.fp_eh_type, fp_rdv1);
			psw_cc = fp_get_eh_comp_cc(fp_rdv1, 0);
			break;
		case 0x34: // 720 "34" "HER" "RR"
			psw_check = false;
			ins_setup_rr();
			fp_rdv1 = fp_get_db_from_eh(fp_reg, rf2) / 2;
			fp_put_db(rf1, tz390.fp_eh_type, fp_rdv1);
			break;
		case 0x35: // 730 "35" "LEDR" "RR"
			psw_check = false;
			ins_setup_rr();
			fp_load_reg(rf1, tz390.fp_eh_type, fp_reg, rf2, tz390.fp_dh_type);
			break;
		case 0x36: // 750 "36" "AXR" "RR"
			psw_check = false;
			ins_setup_rr();
			fp_rbdv1 = fp_get_bd_from_lh(fp_reg, rf1)
			         .add(fp_get_bd_from_lh(fp_reg, rf2), fp_lxg_context); // RPI-821
			fp_put_bd(rf1, tz390.fp_lh_type, fp_rbdv1);
			psw_cc = fp_get_lh_add_sub_cc();
			break;
		case 0x37: // 760 "37" "SXR" "RR"
			psw_check = false;
			ins_setup_rr();
			fp_rbdv1 = fp_get_bd_from_lh(fp_reg, rf1)
			         .subtract(fp_get_bd_from_lh(fp_reg, rf2), fp_lxg_context);  // RPI-821
			fp_put_bd(rf1, tz390.fp_lh_type, fp_rbdv1);
			psw_cc = fp_get_lh_add_sub_cc();
			break;
		case 0x38: // 770 "38" "LER" "RR"
			psw_check = false;
			ins_setup_rr();
			fp_load_reg(rf1, tz390.fp_eh_type, fp_reg, rf2, tz390.fp_eh_type);
			break;
		case 0x39: // 780 "39" "CER" "RR"
			psw_check = false;
			ins_setup_rr();
			psw_cc = fp_get_eh_comp_cc(fp_get_db_from_eh(fp_reg, rf1),
					fp_get_db_from_eh(fp_reg, rf2));
			break;
		case 0x3A: // 790 "3A" "AER" "RR"
			psw_check = false;
			ins_setup_rr();
			fp_rdv1 = fp_get_db_from_eh(fp_reg, rf1)
					+ fp_get_db_from_eh(fp_reg, rf2);
			fp_put_db(rf1, tz390.fp_eh_type, fp_rdv1);
			psw_cc = fp_get_eh_add_sub_cc();
			break;
		case 0x3B: // 800 "3B" "SER" "RR"
			psw_check = false;
			ins_setup_rr();
			fp_rdv1 = fp_get_db_from_eh(fp_reg, rf1)
					- fp_get_db_from_eh(fp_reg, rf2);
			fp_put_db(rf1, tz390.fp_eh_type, fp_rdv1);
			psw_cc = fp_get_eh_add_sub_cc();
			break;
		case 0x3C: // 810 "3C" "MDER" "RR"
			psw_check = false;
			ins_setup_rr();
			fp_rbdv1 = BigDecimal.valueOf(fp_get_db_from_eh(fp_reg, rf1))
					 .multiply(BigDecimal.valueOf(fp_get_db_from_eh(fp_reg, rf2)));
			fp_put_bd(rf1, tz390.fp_dh_type, fp_rbdv1);
			check_dh_mpy();
			break;
		case 0x3D: // 830 "3D" "DER" "RR"
			psw_check = false;
			ins_setup_rr();
			fp_rdv2 = fp_get_db_from_eh(fp_reg, rf2);
			fp_rdv1 = fp_get_db_from_eh(fp_reg, rf1) / fp_rdv2;
			fp_put_db(rf1, tz390.fp_eh_type, fp_rdv1);
			check_eh_div();
			break;
		case 0x3E: // 840 "3E" "AUR" "RR"
			psw_check = false;
			ins_setup_rr();
			// unnormalized HFP RPI-767
			fp_store_reg(fp_reg,rf1);
			fp_int1 = fp_reg.getInt(rf1);
			fp_int2 = fp_reg.getInt(rf2);
			fp_add_unnorm_eh(); // RPI-767 add unnormalized long and set cc
			fp_reg.putInt(rf1,fp_int1);
			break;
		case 0x3F: // 850 "3F" "SUR" "RR"
			psw_check = false;
			ins_setup_rr();
			// unnormalized HFP RPI-767
			fp_store_reg(fp_reg,rf1);
			fp_int1 = fp_reg.getInt(rf1);
			fp_int2 = fp_reg.getInt(rf2) ^ int_high_bit;
			fp_add_unnorm_eh(); // RPI-767 add unnormalized long and set cc
			fp_reg.putInt(rf1,fp_int1);
			break;
		}
	}

	/**
	 * Execute instr < x'80'.
	 */
	private void ins_lt_80()
	{
		switch (opcode1) {
		case 0x40: // 860 "40" "STH" "RX"
			psw_check = false;
			ins_setup_rx();
			if (tz390.opt_protect // RPI-538
					&& xbd2_loc < psa_len) {
					set_psw_check(Constants.psw_pic_addr);
					break;
			}
			mem.putShort(xbd2_loc, (short) reg.getInt(rf1 + 4));
			break;
		case 0x41: // 870 "41" "LA" "RX"
			psw_check = false;
			ins_setup_rx();
			reg.putInt(rf1 + 4, xbd2_loc & psw_amode);
			break;
		case 0x42: // 880 "42" "STC" "RX"
			psw_check = false;
			ins_setup_rx();
			if (tz390.opt_protect // RPI-538
					&& xbd2_loc < psa_len) {
					set_psw_check(Constants.psw_pic_addr);
					break;
			}
			mem_byte[xbd2_loc] = reg.get(rf1 + 4 + 3);
			break;
		case 0x43: // 890 "43" "IC" "RX"
			psw_check = false;
			ins_setup_rx();
			reg.put(rf1 + 7, mem_byte[xbd2_loc]);
			break;
		case 0x44: // 900 "44" "EX" "RX"
			psw_check = false;
			ins_setup_rx();
			exec_ex(xbd2_loc);
			break;
		case 0x45: // 910 "45" "BAL" "RX"
			psw_check = false;
			ins_setup_rx();
			if (ex_mode) {
				reg.putInt(rf1 + 4, ex_psw_return | psw_amode_bit);
			} else {
				reg.putInt(rf1 + 4, psw_loc | psw_amode_bit);
			}
			set_psw_loc(xbd2_loc);
			break;
		case 0x46: // 920 "46" "BCT" "RX"
			psw_check = false;
			ins_setup_rx();
			rv1 = reg.getInt(rf1 + 4) - 1;
			reg.putInt(rf1 + 4, rv1);
			if (rv1 != 0) {
				set_psw_loc(xbd2_loc);
			}
			break;
		case 0x47: // 930 "47" "BC" "RX"
			psw_check = false;
			ins_setup_rx();
			if ((psw_cc & mf1) > 0) {
				set_psw_loc(xbd2_loc);
			}
			break;
		case 0x48: // 1100 "48" "LH" "RX"
			psw_check = false;
			ins_setup_rx();
			reg.putInt(rf1 + 4, mem.getShort(xbd2_loc));
			break;
		case 0x49: // 1110 "49" "CH" "RX"
			psw_check = false;
			ins_setup_rx();
			psw_cc = get_int_comp_cc(reg.getInt(rf1 + 4), mem
					.getShort(xbd2_loc));
			break;
		case 0x4A: // 1120 "4A" "AH" "RX"
			psw_check = false;
			ins_setup_rx();
			rv1 = reg.getInt(rf1 + 4);
			rv2 = mem.getShort(xbd2_loc);
			rv3 = rv1 + rv2;
			reg.putInt(rf1 + 4, rv3);
			psw_cc = get_int_add_cc();
			break;
		case 0x4B: // 1130 "4B" "SH" "RX"
			psw_check = false;
			ins_setup_rx();
			rv1 = reg.getInt(rf1 + 4);
			rv2 = mem.getShort(xbd2_loc);
			rv3 = rv1 - rv2;
			reg.putInt(rf1 + 4, rv3);
			psw_cc = get_int_sub_cc();
			break;
		case 0x4C: // 1140 "4C" "MH" "RX"
			psw_check = false;
			ins_setup_rx();
			rv1 = reg.getInt(rf1 + 4) * mem.getShort(xbd2_loc);
			reg.putInt(rf1 + 4, rv1);
			break;
		case 0x4D: // 1150 "4D" "BAS" "RX"
			psw_check = false;
			ins_setup_rx();
			if (ex_mode) {
				reg.putInt(rf1 + 4, ex_psw_return | psw_amode_bit);
			} else {
				reg.putInt(rf1 + 4, psw_loc | psw_amode_bit);
			}
			set_psw_loc(xbd2_loc);
			break;
		case 0x4E: // 1160 "4E" "CVD" "RX"
			psw_check = false;
			ins_setup_rx();
			if (tz390.opt_protect // RPI-538
					&& xbd2_loc < psa_len) {
					set_psw_check(Constants.psw_pic_addr);
					break;
			}
			pdf_is_big = false;
			pdf_long = reg.getInt(rf1 + 4);
			put_pd(mem_byte, xbd2_loc, 8);
			break;
		case 0x4F: // 1170 "4F" "CVB" "RX"
			psw_check = false;
			ins_setup_rx();
			if (get_pd(mem,xbd2_loc, 8)) { // RPI-305
				if (pdf_is_big) { // RPI-389
					if (pdf_big_int.compareTo(bi_max_pos_int) <= 0  // RPI-781
						&& pdf_big_int.compareTo(bi_min_neg_int) >= 0) {
						reg.putInt(rf1 + 4, pdf_big_int.intValue());
					} else {
						set_psw_check(Constants.psw_pic_fx_div);
					}
				} else {
					if (pdf_long <= max_pos_int && pdf_long >= min_neg_int) {
						reg.putInt(rf1 + 4, (int) pdf_long);
					} else {
						set_psw_check(Constants.psw_pic_fx_div);
					}
				}
			}
			break;
		case 0x50: // 1180 "50" "ST" "RX"
			psw_check = false;
			ins_setup_rx();
			if (tz390.opt_protect // RPI-538
				&& xbd2_loc < psa_len) {
				set_psw_check(Constants.psw_pic_addr);
				break;
			}
			mem.putInt(xbd2_loc, reg.getInt(rf1 + 4));
			break;
		case 0x51: // 1190 "51" "LAE" "RX"
			psw_check = false;
			ins_setup_rx();
			reg.putInt(rf1+4,xbd2_loc);
			break;
		case 0x52: // 1193 "52" "XDECO" "RX" 37 RPI-812
			if (tz390.opt_assist) {
				psw_check = false;
				ins_setup_rx();
				sz390.put_ascii_string(tz390.right_justify("" + reg.getInt(rf1+4),12),xbd2_loc,12,' ');
			}
			break;
		case 0x53: // 1196 "53" "XDECI" "RX" 37 RPI-812
			if (tz390.opt_assist) {
				psw_check = false;
				ins_setup_rx();
				rv1 = 0;
				boolean digit_found = false;
				boolean minus = false;
				int     digit=0;
				if (!tz390.opt_ascii) { // RPI-878
					while (mem.get(xbd2_loc) == 0x40) {
						xbd2_loc++;
					}
					digit = mem.get(xbd2_loc) & 0xff;
					while ((digit >= 0xf0
							&& digit <= 0xf9) // ASCII digit RPI-1179
							|| digit == 0x4E  // EBCDIC +
							|| digit == 0x60  // EBCDIC -
							) {
						if (digit == 0x60) {
							minus = true;
						} else if (digit != 0x4E) {
							digit_found = true;
							rv1 = rv1*10 + (digit & 0xf);
						}
						xbd2_loc++;
						digit = mem.get(xbd2_loc) & 0xff;
					}
				} else {
					while (mem.get(xbd2_loc) == 0x20) {
						xbd2_loc++;
					}
					digit = mem.get(xbd2_loc) & 0xff;
					while ((digit >= 0x30
							&& digit <= 0x39) // ASCII digit RPI-1179
							|| digit == 0x2b  // ASCII +
							|| digit == 0x2d  // ASCII -
							) {
						if (digit == 0x2d) {
							minus = true;
						} else if (digit != 0x2b) {
							digit_found = true;
							rv1 = rv1*10 + (digit & 0XF);
						}
						xbd2_loc++;
						digit = mem.get(xbd2_loc) & 0xff;
					}
				}
				if (digit_found) {
					if (minus) {     // RPI-1179
						rv1 = -rv1;
					}
					reg.putInt(rf1+4,rv1);
					reg.putInt(r1,xbd2_loc);
					psw_cc = psw_cc0;
				} else {
					psw_cc = psw_cc3;
				}
			}
			break;
		case 0x54: // 1200 "54" "N" "RX"
			psw_check = false;
			ins_setup_rx();
			rv1 = reg.getInt(rf1 + 4) & mem.getInt(xbd2_loc);
			reg.putInt(rf1 + 4, rv1);
			if (rv1 == 0) {
				psw_cc = psw_cc0;
			} else {
				psw_cc = psw_cc1;
			}
			break;
		case 0x55: // 1210 "55" "CL" "RX"
			psw_check = false;
			ins_setup_rx();
			psw_cc = get_int_log_comp_cc(reg.getInt(rf1 + 4), mem
					.getInt(xbd2_loc));
			break;
		case 0x56: // 1220 "56" "O" "RX"
			psw_check = false;
			ins_setup_rx();
			rv1 = reg.getInt(rf1 + 4) | mem.getInt(xbd2_loc);
			reg.putInt(rf1 + 4, rv1);
			if (rv1 == 0) {
				psw_cc = psw_cc0;
			} else {
				psw_cc = psw_cc1;
			}
			break;
		case 0x57: // 1230 "57" "X" "RX"
			psw_check = false;
			ins_setup_rx();
			rv1 = reg.getInt(rf1 + 4) ^ mem.getInt(xbd2_loc);
			reg.putInt(rf1 + 4, rv1);
			if (rv1 == 0) {
				psw_cc = psw_cc0;
			} else {
				psw_cc = psw_cc1;
			}
			break;
		case 0x58: // 1240 "58" "L" "RX"
			psw_check = false;
			ins_setup_rx();
			reg.putInt(rf1 + 4, mem.getInt(xbd2_loc));
			break;
		case 0x59: // 1250 "59" "C" "RX"
			psw_check = false;
			ins_setup_rx();
			psw_cc = get_int_comp_cc(reg.getInt(rf1 + 4), mem.getInt(xbd2_loc));
			break;
		case 0x5A: // 1260 "5A" "A" "RX"
			psw_check = false;
			ins_setup_rx();
			rv1 = reg.getInt(rf1 + 4);
			rv2 = mem.getInt(xbd2_loc);
			rv3 = rv1 + rv2;
			reg.putInt(rf1 + 4, rv3);
			psw_cc = get_int_add_cc();
			break;
		case 0x5B: // 1270 "5B" "S" "RX"
			psw_check = false;
			ins_setup_rx();
			rv1 = reg.getInt(rf1 + 4);
			rv2 = mem.getInt(xbd2_loc);
			rv3 = rv1 - rv2;
			reg.putInt(rf1 + 4, rv3);
			psw_cc = get_int_sub_cc();
			break;
		case 0x5C: // 1280 "5C" "M" "RX"
			psw_check = false;
			ins_setup_rx();
			if ((mf1 & 1) != 0) { // RPI-758
				set_psw_check(Constants.psw_pic_spec);
			}
			rlv1 = (long) reg.getInt(rf1 + 8 + 4) * (long) mem.getInt(xbd2_loc);
			work_reg.putLong(0, rlv1);
			reg.putInt(rf1 + 4, work_reg.getInt(0));
			reg.putInt(rf1 + 8 + 4, work_reg.getInt(4));
			break;
		case 0x5D: // 1290 "5D" "D" "RX"
			psw_check = false;
			ins_setup_rx();
			if ((mf1 & 1) != 0) { // RPI-758
				set_psw_check(Constants.psw_pic_spec);
			}
			rlv1 = (long) (reg.getInt(rf1 + 4)) << 32
					| ((long) reg.getInt(rf1 + 12) & long_low32_bits); // RPI-398
			rv2 = mem.getInt(xbd2_loc);
			if (rv2 == 0) {
				set_psw_check(Constants.psw_pic_fx_div);
				break;
			}
			rv1 = (int) (rlv1 / rv2); // RPI-398
			rv2 = (int) rlv1 - rv1 * rv2;
			reg.putInt(rf1 + 4, rv2);
			reg.putInt(rf1 + 12, rv1);
			break;
		case 0x5E: // 1300 "5E" "AL" "RX"
			psw_check = false;
			ins_setup_rx();
			rvw = reg.getInt(rf1 + 4);
			rv2 = mem.getInt(xbd2_loc);
			rv1 = rvw + rv2;
			reg.putInt(rf1 + 4, rv1);
			psw_cc = get_int_log_add_cc();
			break;
		case 0x5F: // 1310 "5F" "SL" "RX"
			psw_check = false;
			ins_setup_rx();
			rvw = reg.getInt(rf1 + 4);
			rv2 = mem.getInt(xbd2_loc);
			rv1 = rvw - rv2;
			reg.putInt(rf1 + 4, rv1);
			psw_cc = get_int_log_sub_cc();
			break;
		case 0x60: // 1320 "60" "STD" "RX"
			psw_check = false;
			ins_setup_rx();
			if (tz390.opt_protect // RPI-538
					&& xbd2_loc < psa_len) {
					set_psw_check(Constants.psw_pic_addr);
					break;
				}
			if (fp_reg_ctl[mf1] != fp_ctl_ld) {
				fp_store_reg(fp_reg, rf1);
			}
			mem.putLong(xbd2_loc, fp_reg.getLong(rf1));
			break;
		case 0x61: // 1323 "61" "XHEXI" "RX" 37 RPI-812
			if (tz390.opt_assist) {
				psw_check = false;
				ins_setup_rx();
				rv1 = 0;
				boolean hex_digit_found = false;
				while (mem.get(xbd2_loc) == 0x40) {
					xbd2_loc++;
				}
				while (((mem.get(xbd2_loc) & 0xff) >= 0xf0
						&& (mem.get(xbd2_loc) & 0xff) <= 0xf9)
						||
						((mem.get(xbd2_loc) & 0xff) >= 0xc1
								&& (mem.get(xbd2_loc) & 0xff) <= 0xc6)
						) {
					hex_digit_found = true;
					int hex_digit = mem.get(xbd2_loc) & 0xff;
					if (hex_digit >= 0xf0) {
						hex_digit = hex_digit - 0xf0;
					} else {
						hex_digit = hex_digit - 0xc1 + 10;
					}
					rv1 = rv1*16 + hex_digit;
					xbd2_loc++;
				}
				if (hex_digit_found) {
					reg.putInt(rf1+4,rv1);
					reg.putInt(r1,xbd2_loc);
					psw_cc = psw_cc0;
				} else {
					psw_cc = psw_cc3;
				}
			}
			break;
		case 0x62: // 1326 "62" "XHEXO" "RX" 37 RPI-812
			if (tz390.opt_assist) {
				psw_check = false;
				ins_setup_rx();
				sz390.put_ascii_string(
						tz390.get_hex(reg.getInt(rf1+4),8)
						,xbd2_loc,8,' ');
			}
			break;
		case 0x67: // 1330 "67" "MXD" "RX"
			psw_check = false;
			ins_setup_rx();
			fp_rbdv1 = fp_get_bd_from_dh(fp_reg, rf1).round(fp_dh_context)
					.multiply(fp_get_bd_from_dh(mem, xbd2_loc).round(fp_dh_context), fp_lxg_context); // RPI-821
			fp_put_bd(rf1, tz390.fp_lh_type, fp_rbdv1);
			check_lh_mpy();
			break;
		case 0x68: // 1340 "68" "LD" "RX"
			psw_check = false;
			ins_setup_rx();
			fp_load_reg(rf1, tz390.fp_dh_type, mem, xbd2_loc, tz390.fp_dh_type);
			break;
		case 0x69: // 1350 "69" "CD" "RX"
			psw_check = false;
			ins_setup_rx();
			psw_cc = fp_get_dh_comp_cc(fp_get_bd_from_dh(fp_reg, rf1),
					fp_get_bd_from_dh(mem, xbd2_loc)); // RPI-821
			break;
		case 0x6A: // 1360 "6A" "AD" "RX"
			psw_check = false;
			ins_setup_rx();
			fp_rbdv1 = fp_get_bd_from_dh(fp_reg, rf1)
					 .add(fp_get_bd_from_dh(mem, xbd2_loc),fp_dhg_context);  // RPI-821
			fp_put_bd(rf1, tz390.fp_dh_type, fp_rbdv1);// RPI-821
			psw_cc = fp_get_dh_add_sub_cc();
			break;
		case 0x6B: // 1370 "6B" "SD" "RX"
			psw_check = false;
			ins_setup_rx();
			fp_rbdv1 = fp_get_bd_from_dh(fp_reg, rf1)
					 .subtract(fp_get_bd_from_dh(mem, xbd2_loc),fp_dhg_context);  // RPI-821
			fp_put_bd(rf1, tz390.fp_dh_type, fp_rbdv1);  // RPI-821
			psw_cc = fp_get_dh_add_sub_cc();
			break;
		case 0x6C: // 1380 "6C" "MD" "RX"
			psw_check = false;
			ins_setup_rx();
			fp_rbdv1 = fp_get_bd_from_dh(fp_reg, rf1)
					 .multiply(fp_get_bd_from_dh(mem, xbd2_loc));  // RPI-821
			fp_put_bd(rf1, tz390.fp_dh_type, fp_rbdv1);  // RPI-821
			check_dh_mpy();
			break;
		case 0x6D: // 1390 "6D" "DD" "RX"
			psw_check = false;
			psw_check = false;
			ins_setup_rx();
			fp_rbdv1 = fp_get_bd_from_dh(fp_reg, rf1); // RPI-821
			fp_rbdv2 = fp_get_bd_from_dh(mem, xbd2_loc); // RPI-821
			if (fp_rbdv2.signum() != 0) {
				fp_rbdv1 = fp_rbdv1.divide(fp_rbdv2, fp_dhg_context).round(fp_dhg_context); // RPI-821
			} else {
				fp_rbdv1 = BigDecimal.ZERO; // RPI-824
			}
			fp_put_bd(rf1, tz390.fp_dh_type, fp_rbdv1);  // RPI-821
			check_dh_div();
			break;
		case 0x6E: // 1400 "6E" "AW" "RX"
			psw_check = false;
			ins_setup_rx();
			// unnormalized HFP RPI-767
			fp_store_reg(fp_reg,rf1);
			fp_long1 = fp_reg.getLong(rf1);
			fp_long2 = mem.getLong(xbd2_loc);
			fp_add_unnorm_dh(); // RPI-767 add unnormalized long and set cc
			fp_reg.putLong(rf1,fp_long1);
			break;
		case 0x6F: // 1410 "6F" "SW" "RX"
			psw_check = false;
			ins_setup_rx();
			// unnormalized HFP RPI-767
			fp_store_reg(fp_reg,rf1);
			fp_long1 = fp_reg.getLong(rf1);
			fp_long2 = mem.getLong(xbd2_loc) ^ long_high_bit;
			fp_add_unnorm_dh(); // RPI-767 add unnormalized long and set cc
			fp_reg.putLong(rf1,fp_long1);
			break;
		case 0x70: // 1420 "70" "STE" "RX"
			psw_check = false;
			ins_setup_rx();
			if (tz390.opt_protect // RPI-538
					&& xbd2_loc < psa_len) {
					set_psw_check(Constants.psw_pic_addr);
					break;
				}
			if (fp_reg_ctl[mf1] != fp_ctl_ld) {
				fp_store_reg(fp_reg, rf1);
			}
			mem.putInt(xbd2_loc, fp_reg.getInt(rf1));
			break;
		case 0x71: // 1430 "71" "MS" "RX"
			psw_check = false;
			ins_setup_rx();
			reg.putInt(rf1 + 4, reg.getInt(rf1 + 4) * mem.getInt(xbd2_loc));
			break;
		case 0x78: // 1440 "78" "LE" "RX"
			psw_check = false;
			ins_setup_rx();
			fp_load_reg(rf1, tz390.fp_eh_type, mem, xbd2_loc, tz390.fp_eh_type);
			break;
		case 0x79: // 1450 "79" "CE" "RX"
			psw_check = false;
			ins_setup_rx();
			psw_cc = fp_get_eh_comp_cc(fp_get_db_from_eh(fp_reg, rf1),
					fp_get_db_from_eh(mem, xbd2_loc));
			break;
		case 0x7A: // 1460 "7A" "AE" "RX"
			psw_check = false;
			ins_setup_rx();
			fp_rdv1 = fp_get_db_from_eh(fp_reg, rf1)
					+ fp_get_db_from_eh(mem, xbd2_loc);
			fp_put_db(rf1, tz390.fp_eh_type, fp_rdv1);
			psw_cc = fp_get_eh_add_sub_cc();
			break;
		case 0x7B: // 1470 "7B" "SE" "RX"
			psw_check = false;
			ins_setup_rx();
			fp_rdv1 = fp_get_db_from_eh(fp_reg, rf1)
					- fp_get_db_from_eh(mem, xbd2_loc);
			fp_put_db(rf1, tz390.fp_eh_type, fp_rdv1);
			psw_cc = fp_get_eh_add_sub_cc();
			break;
		case 0x7C: // 1480 "7C" "MDE" "RX"
			psw_check = false;
			ins_setup_rx();
			fp_rbdv1 = fp_get_bd_from_eh(fp_reg, rf1)    // RPI-1003
					.multiply(fp_get_bd_from_eh(mem, xbd2_loc),fp_dh_context);
			fp_put_bd(rf1, tz390.fp_dh_type,fp_rbdv1); // RPI-821 RPI-1003
			check_dh_mpy();
			break;
		case 0x7D: // 1500 "7D" "DE" "RX"
			psw_check = false;
			ins_setup_rx();
			fp_rdv2 = fp_get_db_from_eh(mem, xbd2_loc);
			fp_rdv1 = fp_get_db_from_eh(fp_reg, rf1) / fp_rdv2;
			fp_put_db(rf1, tz390.fp_eh_type, fp_rdv1);
			check_eh_div();
			break;
		case 0x7E: // 1510 "7E" "AU" "RX"
			psw_check = false;
			ins_setup_rx();
			// unnormalized HFP RPI-767
			fp_store_reg(fp_reg,rf1);
			fp_int1 = fp_reg.getInt(rf1);
			fp_int2 = mem.getInt(xbd2_loc);
			fp_add_unnorm_eh(); // RPI-767 add unnormalized long and set cc
			fp_reg.putInt(rf1,fp_int1);
			break;
		case 0x7F: // 1520 "7F" "SU" "RX"
			psw_check = false;
			ins_setup_rx();
			// unnormalized HFP RPI-767
			fp_store_reg(fp_reg,rf1);
			fp_int1 = fp_reg.getInt(rf1);
			fp_int2 = mem.getInt(xbd2_loc) ^ int_high_bit;
			fp_add_unnorm_eh(); // RPI-767 add unnormalized long and set cc
			fp_reg.putInt(rf1,fp_int1);
			break;
		}
	}

	/**
	 * Execute opcodes >= x'80'.
	 */
	private void ins_lt_c0()
	{
		switch (opcode1) {
		case 0x80: // 1530 "8000" "SSM" "S"
			ins_setup_s();
			break;
		case 0x82: // 1540 "8200" "LPSW" "S"
			psw_check = false;
			ins_setup_s();
			set_psw_loc(mem.getInt(bd2_loc + 4));
			break;
		case 0x83: // 1550 "83" "DIAGNOSE" "DM"
			ins_setup_dm();
			break;
		case 0x84: // 1560 "84" "BRXH" "RSI"
			psw_check = false;
			ins_setup_rsi();
			rv3 = reg.getInt(rf3 + 4);
			rv1 = reg.getInt(rf1 + 4) + rv3;
			reg.putInt(rf1 + 4, rv1);
			if (rf3 == ((rf3 >> 4) << 4)) {
				rv3 = reg.getInt(rf3 + 12);
			}
			if (rv1 > rv3) {
				set_psw_loc(psw_loc - 4 + 2 * if2);
			}
			break;
		case 0x85: // 1580 "85" "BRXLE" "RSI"
			psw_check = false;
			ins_setup_rsi();
			rv3 = reg.getInt(rf3 + 4);
			rv1 = reg.getInt(rf1 + 4) + rv3;
			reg.putInt(rf1 + 4, rv1);
			if (rf3 == ((rf3 >> 4) << 4)) {
				rv3 = reg.getInt(rf3 + 12);
			}
			if (rv1 <= rv3) {
				set_psw_loc(psw_loc - 4 + 2 * if2);
			}
			break;
		case 0x86: // 1600 "86" "BXH" "RS"
			psw_check = false;
			ins_setup_rs();
			rv3 = reg.getInt(rf3 + 4);
			rv1 = reg.getInt(rf1 + 4) + rv3;
			reg.putInt(rf1 + 4, rv1);
			if (rf3 == ((rf3 >> 4) << 4)) {
				rv3 = reg.getInt(rf3 + 12);
			}
			if (rv1 > rv3) {
				set_psw_loc(bd2_loc);
			}
			break;
		case 0x87: // 1610 "87" "BXLE" "RS"
			psw_check = false;
			ins_setup_rs();
			rv3 = reg.getInt(rf3 + 4);
			rv1 = reg.getInt(rf1 + 4) + rv3;
			reg.putInt(rf1 + 4, rv1);
			if (rf3 == ((rf3 >> 4) << 4)) {
				rv3 = reg.getInt(rf3 + 12);
			}
			if (rv1 <= rv3) {
				set_psw_loc(bd2_loc);
			}
			break;
		case 0x88: // 1620 "88" "SRL" "RS"
			psw_check = false;
			ins_setup_rs_shift(); // RPI-820
			reg.putInt(rf1 + 4, reg.getInt(rf1 + 4) >>> (bd2_loc & 0x3f));
			break;
		case 0x89: // 1630 "89" "SLL" "RS"
			psw_check = false;
			ins_setup_rs_shift(); // RPI-820
			reg.putInt(rf1 + 4, reg.getInt(rf1 + 4) << (bd2_loc & 0x3f));
			break;
		case 0x8A: // 1640 "8A" "SRA" "RS"
			psw_check = false;
			ins_setup_rs_shift(); // RPI-820
			reg.putInt(rf1 + 4, get_sra32(reg.getInt(rf1 + 4), bd2_loc & 0x3f));
			break;
		case 0x8B: // 1650 "8B" "SLA" "RS"
			psw_check = false;
			ins_setup_rs_shift(); // RPI-820
			reg.putInt(rf1 + 4, get_sla32(reg.getInt(rf1 + 4), bd2_loc & 0x3f));
			break;
		case 0x8C: // 1660 "8C" "SRDL" "RS"
			psw_check = false;
			ins_setup_rs_shift(); // RPI-820
			if ((mf1 & 1) != 0) { // RPI-758
				set_psw_check(Constants.psw_pic_spec);
			}
			rlv1 = ((long) (reg.getInt(rf1 + 4)) << 32 | ((long) reg
					.getInt(rf1 + 12) & long_low32_bits)) >>> (bd2_loc & 0x3f); // RPI-398
			reg.putInt(rf1 + 4, (int) (rlv1 >>> 32));
			reg.putInt(rf1 + 12, (int) rlv1);
			break;
		case 0x8D: // 1670 "8D" "SLDL" "RS"
			psw_check = false;
			ins_setup_rs_shift(); // RPI-820
			if ((mf1 & 1) != 0) { // RPI-758
				set_psw_check(Constants.psw_pic_spec);
			}
			rlv1 = ((long) (reg.getInt(rf1 + 4)) << 32 | ((long) reg
					.getInt(rf1 + 12) & long_low32_bits)) << (bd2_loc & 0x3f); // RPI-398
			reg.putInt(rf1 + 4, (int) (rlv1 >>> 32));
			reg.putInt(rf1 + 12, (int) rlv1);
			break;
		case 0x8E: // 1680 "8E" "SRDA" "RS"
			psw_check = false;
			ins_setup_rs_shift(); // RPI-820
			if ((mf1 & 1) != 0) { // RPI-758
				set_psw_check(Constants.psw_pic_spec);
			}
			rlv1 = ((long) (reg.getInt(rf1 + 4)) << 32 | ((long) reg
					.getInt(rf1 + 12) & long_low32_bits)) >> (bd2_loc & 0x3f); // RPI-398
			reg.putInt(rf1 + 4, (int) (rlv1 >>> 32));
			reg.putInt(rf1 + 12, (int) rlv1);
			psw_cc = get_long_comp_cc(rlv1, 0);
			break;
		case 0x8F: // 1690 "8F" "SLDA" "RS"
			psw_check = false;
			ins_setup_rs_shift(); // RPI-820
			if ((mf1 & 1) != 0) { // RPI-758
				set_psw_check(Constants.psw_pic_spec);
			}
			rlv1 = get_sla64(((long) (reg.getInt(rf1 + 4)) << 32 | ((long) reg
					.getInt(rf1 + 12) & long_low32_bits)), bd2_loc & 0x3f); // RPI-398
			reg.putInt(rf1 + 4, (int) (rlv1 >>> 32));
			reg.putInt(rf1 + 12, (int) rlv1);
			break;
		case 0x90: // 1700 "90" "STM" "RS"
			psw_check = false;
			ins_setup_rs();
			if (rf1 > rf3) {
				while (rf1 < reg_len) {
					mem.putInt(bd2_loc, reg.getInt(rf1 + 4));
					bd2_loc = bd2_loc + 4;
					rf1 = rf1 + 8;
				}
				rf1 = 0;
			}
			while (rf1 <= rf3) {
				mem.putInt(bd2_loc, reg.getInt(rf1 + 4));
				bd2_loc = bd2_loc + 4;
				rf1 = rf1 + 8;
			}
			break;
		case 0x91: // 1710 "91" "TM" "SI"
			psw_check = false;
			ins_setup_si();
			psw_cc = get_tm_mem_cc(mem_byte[bd1_loc],if2); // RPI-844
			break;
		case 0x92: // 1720 "92" "MVI" "SI"
			psw_check = false;
			ins_setup_si();
			if (tz390.opt_protect // RPI-538
					&& bd1_loc < psa_len) {
					set_psw_check(Constants.psw_pic_addr);
					break;
				}
			mem_byte[bd1_loc] = (byte) if2;
			break;
		case 0x93: // 1730 "9300" "TS" "S"
			psw_check = false;
			ins_setup_s();
			if ((mem_byte[bd2_loc] & 0x80) != 0) {
				psw_cc = psw_cc1;
			} else {
				psw_cc = psw_cc0;
			}
			mem_byte[bd2_loc] = (byte) 0xff;
			break;
		case 0x94: // 1740 "94" "NI" "SI"
			psw_check = false;
			ins_setup_si();
			if (tz390.opt_protect // RPI-538
					&& bd1_loc < psa_len) {
					set_psw_check(Constants.psw_pic_addr);
					break;
			}
			sv1 = mem_byte[bd1_loc] & if2;
			mem_byte[bd1_loc] = (byte) sv1;
			if (sv1 == 0) {
				psw_cc = psw_cc0;
			} else {
				psw_cc = psw_cc1;
			}
			break;
		case 0x95: // 1750 "95" "CLI" "SI"
			psw_check = false;
			ins_setup_si();
			psw_cc = get_int_comp_cc((mem_byte[bd1_loc] & 0xff), if2);
			break;
		case 0x96: // 1760 "96" "OI" "SI"
			psw_check = false;
			ins_setup_si();
			if (tz390.opt_protect // RPI-538
					&& bd1_loc < psa_len) {
					set_psw_check(Constants.psw_pic_addr);
					break;
				}
			sv1 = mem_byte[bd1_loc] | if2;
			mem_byte[bd1_loc] = (byte) sv1;
			if (sv1 == 0) {
				psw_cc = psw_cc0;
			} else {
				psw_cc = psw_cc1;
			}
			break;
		case 0x97: // 1770 "97" "XI" "SI"
			psw_check = false;
			ins_setup_si();
			if (tz390.opt_protect // RPI-538
					&& bd1_loc < psa_len) {
					set_psw_check(Constants.psw_pic_addr);
					break;
				}
			sv1 = mem_byte[bd1_loc] ^ if2;
			mem_byte[bd1_loc] = (byte) sv1;
			if (sv1 == 0) {
				psw_cc = psw_cc0;
			} else {
				psw_cc = psw_cc1;
			}
			break;
		case 0x98: // 1780 "98" "LM" "RS"
			psw_check = false;
			ins_setup_rs();
			if (rf1 > rf3) {
				while (rf1 < reg_len) {
					reg.putInt(rf1 + 4, mem.getInt(bd2_loc));
					bd2_loc = bd2_loc + 4;
					rf1 = rf1 + 8;
				}
				rf1 = 0;
			}
			while (rf1 <= rf3) {
				reg.putInt(rf1 + 4, mem.getInt(bd2_loc));
				bd2_loc = bd2_loc + 4;
				rf1 = rf1 + 8;
			}
			break;
		case 0x99: // 1790 "99" "TRACE" "RS"
			ins_setup_rs();
			break;
		case 0x9A: // 1800 "9A" "LAM" "RS"
			ins_setup_rs();
			break;
		case 0x9B: // 1810 "9B" "STAM" "RS"
			ins_setup_rs();
			break;
		case 0xA5:
			ins_A5XX();
			break;
		case 0xA7:
			ins_A7XX();
			break;
		case 0xA8: // 2500 "A8" "MVCLE" "RS"
			psw_check = false;
			ins_setup_rs();
			if ((mf3 & 1) != 0) { // RPI-758
				set_psw_check(Constants.psw_pic_spec);
			}
			if ((mf1 & 1) != 0) { // RPI-758
				set_psw_check(Constants.psw_pic_spec);
			}
			exec_mvcle();
			break;
		case 0xA9: // 2510 "A9" "CLCLE" "RS"
			psw_check = false;
			ins_setup_rs();
			if ((mf1 & 1) != 0) { // RPI-758
				set_psw_check(Constants.psw_pic_spec);
			}
			if ((mf3 & 1) != 0) { // RPI-758
				set_psw_check(Constants.psw_pic_spec);
			}
			exec_clcle();
			break;
		case 0xAC: // 2520 "AC" "STNSM" "SI"
			ins_setup_si();
			break;
		case 0xAD: // 2530 "AD" "STOSM" "SI"
			ins_setup_si();
			break;
		case 0xAE: // 2540 "AE" "SIGP" "RS"
			ins_setup_rs();
			break;
		case 0xAF: // 2550 "AF" "MC" "SI"
			ins_setup_si();
			break;
		case 0xB1: // 2560 "B1" "LRA" "RX"
			ins_setup_rx();
			break;
		case 0xB2:
			ins_B2XX();
			break;
		case 0xB3:
			ins_B3XX();
			break;
		case 0xB6: // 4430 "B6" "STCTL" "RS"
			ins_setup_rs();
			break;
		case 0xB7: // 4440 "B7" "LCTL" "RS"
			ins_setup_rs();
			break;
		case 0xB9:
			ins_B9XX();
			break;
		case 0xBA: // 5120 "BA" "CS" "RS"
			psw_check = false;
			ins_setup_rs();
			if (reg.getInt(rf1 + 4) == mem.getInt(bd2_loc)) {
				psw_cc = psw_cc0;
				mem.putInt(bd2_loc, reg.getInt(rf3 + 4));
			} else {
				psw_cc = psw_cc1;
				reg.putInt(rf1 + 4, mem.getInt(bd2_loc));
			}
			break;
		case 0xBB: // 5130 "BB" "CDS" "RS"
			psw_check = false;
			ins_setup_rs();
			if ((mf1 & 1) != 0) { // RPI-758
				set_psw_check(Constants.psw_pic_spec);
			}
			if (reg.getInt(rf1 + 4) == mem.getInt(bd2_loc)
					&& reg.getInt(rf1 + 12) == mem.getInt(bd2_loc + 4)) {
				psw_cc = psw_cc0;
				mem.putInt(bd2_loc, reg.getInt(rf3 + 4));
				mem.putInt(bd2_loc + 4, reg.getInt(rf3 + 12));
			} else {
				psw_cc = psw_cc1;
				reg.putInt(rf1 + 4, mem.getInt(bd2_loc));
				reg.putInt(rf1 + 12, mem.getInt(bd2_loc + 4));
			}
			break;
		case 0xBD: // 5140 "BD" "CLM" "RS"
			psw_check = false;
			ins_setup_rs();
			rv1 = reg.getInt(rf1 + 4);
			exec_clm();
			break;
		case 0xBE: // 5150 "BE" "STCM" "RS"
			psw_check = false;
			ins_setup_rs();
			rv1 = reg.getInt(rf1 + 4);
			exec_stcm();
			break;
		case 0xBF: // 5160 "BF" "ICM" "RS"
			psw_check = false;
			ins_setup_rs();
			rv1 = reg.getInt(rf1 + 4);
			exec_icm();
			reg.putInt(rf1 + 4, rv1);
			break;
		}
	}

	/**
	 * Execute instructions <= x'ff'.
	 */
	private void ins_lt_ff()
	{
		switch (opcode1) {
		case 0xC0:
			ins_C0XX();
			break;
		case 0xC2:
			ins_C2XX();
			break;
		case 0xC4: // "C42" LLHRL RPI-817
			ins_C4XX();
			break;
		case 0xC6: // "C60" EXRL RPI-817
			ins_C6XX();
			break;
		case 0xC8: // 5630 "C80" "MVCOS" "SSF" Z9-41
			ins_C8XX();
			break; // RPI-606
		case 0xCC: // "CC6" "BRCTH" "RIL" RPI-1125 Z196
			ins_CCXX();
			break;
		case 0xD0: // 5230 "D0" "TRTR" "SS"
			psw_check = false;
			ins_setup_ss();
			psw_cc = psw_cc0;
			bd1_end = bd1_loc - rflen;
			boolean trt_hit = false;
			while (bd1_loc > bd1_end) {
				if (!trt_hit
						&& (mem_byte[bd2_loc + (mem_byte[bd1_loc] & 0xff)]) != 0) {
					trt_hit = true;
					if (bd1_loc - 1 == bd1_end) {
						psw_cc = psw_cc2;
					} else {
						psw_cc = psw_cc1;
					}
					reg.putInt(r1, (reg.getInt(r1) & psw_amode_high_bits) // RPI-828
							| bd1_loc);
					reg.put(r2 + 3, mem_byte[bd2_loc
							+ (mem_byte[bd1_loc] & 0xff)]);
				}
				bd1_loc--;
			}
			break;
		case 0xD1: // 5240 "D1" "MVN" "SS"
			psw_check = false;
			ins_setup_ss();
			while (rflen >= 8) {
				mem.putLong(bd1_loc, (mem.getLong(bd1_loc) & long_zone_ones)
						| (mem.getLong(bd2_loc) & long_num_ones));
				bd1_loc = bd1_loc + 8;
				bd2_loc = bd2_loc + 8;
				rflen = rflen - 8;
			}
			if (rflen >= 4) {
				mem.putInt(bd1_loc, (mem.getInt(bd1_loc) & 0xf0f0f0f0)
						| (mem.getInt(bd2_loc) & 0x0f0f0f0f));
				bd1_loc = bd1_loc + 4;
				bd2_loc = bd2_loc + 4;
				rflen = rflen - 4;
			}
			if (rflen >= 2) {
				mem.putShort(bd1_loc,
							(short) ((mem.getShort(bd1_loc) & (short) 0xf0f0) | (mem.getShort(bd2_loc) & (short) 0x0f0f)));
				bd1_loc = bd1_loc + 2;
				bd2_loc = bd2_loc + 2;
				rflen = rflen - 2;
			}
			if (rflen >= 1) {
				mem_byte[bd1_loc] = (byte) ((mem_byte[bd1_loc] & 0xf0) | (mem_byte[bd2_loc] & 0x0f));
			}
			break;
		case 0xD2: // 5250 "D2" "MVC" "SS"
			psw_check = false;
			ins_setup_ss();
			exec_mvc_rflen();
			break;
		case 0xD3: // 5260 "D3" "MVZ" "SS"
			psw_check = false;
			ins_setup_ss();
			while (rflen >= 8) {
				mem.putLong(bd1_loc, (mem.getLong(bd1_loc) & long_num_ones)
						| (mem.getLong(bd2_loc) & long_zone_ones));
				bd1_loc = bd1_loc + 8;
				bd2_loc = bd2_loc + 8;
				rflen = rflen - 8;
			}
			if (rflen >= 4) {
				mem.putInt(bd1_loc, (mem.getInt(bd1_loc) & 0x0f0f0f0f)
						| (mem.getInt(bd2_loc) & 0xf0f0f0f0));
				bd1_loc = bd1_loc + 4;
				bd2_loc = bd2_loc + 4;
				rflen = rflen - 4;
			}
			if (rflen >= 2) {
				mem.putShort(bd1_loc,
						(short) ((mem.getShort(bd1_loc) & 0x0f0f) | (mem
								.getShort(bd2_loc) & 0xf0f0)));
				bd1_loc = bd1_loc + 2;
				bd2_loc = bd2_loc + 2;
				rflen = rflen - 2;
			}
			if (rflen >= 1) {
				mem_byte[bd1_loc] = (byte) ((mem_byte[bd1_loc] & 0x0f) | (mem_byte[bd2_loc] & 0xf0));
			}
			break;
		case 0xD4: // 5270 "D4" "NC" "SS"
			psw_check = false;
			ins_setup_ss();
			psw_cc = psw_cc0;
			while (rflen >= 8) {
				rlv1 = mem.getLong(bd1_loc) & mem.getLong(bd2_loc);
				mem.putLong(bd1_loc, rlv1);
				if (rlv1 != 0)
					psw_cc = psw_cc1;
				bd1_loc = bd1_loc + 8;
				bd2_loc = bd2_loc + 8;
				rflen = rflen - 8;
			}
			if (rflen >= 4) {
				rv1 = mem.getInt(bd1_loc) & mem.getInt(bd2_loc);
				mem.putInt(bd1_loc, rv1);
				if (rv1 != 0)
					psw_cc = psw_cc1;
				bd1_loc = bd1_loc + 4;
				bd2_loc = bd2_loc + 4;
				rflen = rflen - 4;
			}
			if (rflen >= 2) {
				rv1 = (mem.getShort(bd1_loc) & mem.getShort(bd2_loc)) & 0xffff;
				mem.putShort(bd1_loc, (short) rv1);
				if (rv1 != 0)
					psw_cc = psw_cc1;
				bd1_loc = bd1_loc + 2;
				bd2_loc = bd2_loc + 2;
				rflen = rflen - 2;
			}
			if (rflen >= 1) {
				rv1 = (mem_byte[bd1_loc] & mem_byte[bd2_loc]) & 0xff;
				mem.put(bd1_loc, (byte) rv1);
				if (rv1 != 0)
					psw_cc = psw_cc1;
			}
			break;
		case 0xD5: // 5280 "D5" "CLC" "SS"
			psw_check = false;
			ins_setup_ss();
			psw_cc = psw_cc_equal;
			fields_equal = true;
			while (rflen >= 8 && fields_equal) {
				if (mem.getLong(bd1_loc) == mem.getLong(bd2_loc)) {
					bd1_loc = bd1_loc + 8;
					bd2_loc = bd2_loc + 8;
					rflen = rflen - 8;
				} else {
					fields_equal = false;
				}
			}
			if (rflen >= 4 && mem.getInt(bd1_loc) == mem.getInt(bd2_loc)) {
				bd1_loc = bd1_loc + 4;
				bd2_loc = bd2_loc + 4;
				rflen = rflen - 4;
			}
			if (rflen >= 2 && mem.getShort(bd1_loc) == mem.getShort(bd2_loc)) {
				bd1_loc = bd1_loc + 2;
				bd2_loc = bd2_loc + 2;
				rflen = rflen - 2;
			}
			while (rflen > 0) {
				if (mem.get(bd1_loc) != mem.get(bd2_loc)) {
					if ((mem_byte[bd1_loc] & 0xff) > (mem_byte[bd2_loc] & 0xff)) {
						psw_cc = psw_cc_high;
					} else {
						psw_cc = psw_cc_low;
					}
					break;
				} else {
					bd1_loc++;
					bd2_loc++;
					rflen--;
				}
			}
			break;
		case 0xD6: // 5290 "D6" "OC" "SS"
			psw_check = false;
			ins_setup_ss();
			psw_cc = psw_cc0;
			while (rflen >= 8) {
				rlv1 = mem.getLong(bd1_loc) | mem.getLong(bd2_loc);
				mem.putLong(bd1_loc, rlv1);
				if (rlv1 != 0)
					psw_cc = psw_cc1;
				bd1_loc = bd1_loc + 8;
				bd2_loc = bd2_loc + 8;
				rflen = rflen - 8;
			}
			if (rflen >= 4) {
				rv1 = mem.getInt(bd1_loc) | mem.getInt(bd2_loc);
				mem.putInt(bd1_loc, rv1);
				if (rv1 != 0)
					psw_cc = psw_cc1;
				bd1_loc = bd1_loc + 4;
				bd2_loc = bd2_loc + 4;
				rflen = rflen - 4;
			}
			if (rflen >= 2) {
				rv1 = (mem.getShort(bd1_loc) | mem.getShort(bd2_loc)) & 0xffff;
				mem.putShort(bd1_loc, (short) rv1);
				if (rv1 != 0)
					psw_cc = psw_cc1;
				bd1_loc = bd1_loc + 2;
				bd2_loc = bd2_loc + 2;
				rflen = rflen - 2;
			}
			if (rflen >= 1) {
				rv1 = (mem_byte[bd1_loc] | mem_byte[bd2_loc]) & 0xff;
				mem.put(bd1_loc, (byte) rv1);
				if (rv1 != 0)
					psw_cc = psw_cc1;
			}
			break;
		case 0xD7: // 5300 "D7" "XC" "SS"
			psw_check = false;
			ins_setup_ss();
			psw_cc = psw_cc0;
			if (bd1_loc == bd2_loc) {
				Arrays.fill(mem_byte,bd1_loc,bd1_loc+rflen,(byte)0); // RPI-985
				break;
			}
			while (rflen >= 8) {
				rlv1 = mem.getLong(bd1_loc) ^ mem.getLong(bd2_loc);
				mem.putLong(bd1_loc, rlv1);
				if (rlv1 != 0)
					psw_cc = psw_cc1;
				bd1_loc = bd1_loc + 8;
				bd2_loc = bd2_loc + 8;
				rflen = rflen - 8;
			}
			if (rflen >= 4) {
				rv1 = mem.getInt(bd1_loc) ^ mem.getInt(bd2_loc);
				mem.putInt(bd1_loc, rv1);
				if (rv1 != 0)
					psw_cc = psw_cc1;
				bd1_loc = bd1_loc + 4;
				bd2_loc = bd2_loc + 4;
				rflen = rflen - 4;
			}
			if (rflen >= 2) {
				rv1 = (mem.getShort(bd1_loc) ^ mem.getShort(bd2_loc)) & 0xffff;
				mem.putShort(bd1_loc, (short) rv1);
				if (rv1 != 0)
					psw_cc = psw_cc1;
				bd1_loc = bd1_loc + 2;
				bd2_loc = bd2_loc + 2;
				rflen = rflen - 2;
			}
			if (rflen >= 1) {
				rv1 = (mem_byte[bd1_loc] ^ mem_byte[bd2_loc]) & 0xff;
				mem.put(bd1_loc, (byte) rv1);
				if (rv1 != 0)
					psw_cc = psw_cc1;
			}
			break;
		case 0xD9: // 5310 "D9" "MVCK" "SS"
			ins_setup_ss();
			break;
		case 0xDA: // 5320 "DA" "MVCP" "SS"
			ins_setup_ss();
			break;
		case 0xDB: // 5330 "DB" "MVCS" "SS"
			ins_setup_ss();
			break;
		case 0xDC: // 5340 "DC" "TR" "SS"
			psw_check = false;
			ins_setup_ss();
			bd1_end = bd1_loc + rflen;
			while (bd1_loc < bd1_end) {
				mem_byte[bd1_loc] = mem_byte[bd2_loc + (mem_byte[bd1_loc] & 0xff)];
				bd1_loc++;
			}
			break;
		case 0xDD: // 5350 "DD" "TRT" "SS"
			psw_check = false;
			ins_setup_ss();
			psw_cc = psw_cc0;
			bd1_end = bd1_loc + rflen;
			while (bd1_loc < bd1_end) {
				if ((mem_byte[bd2_loc + (mem_byte[bd1_loc] & 0xff)]) != 0) {
					if (bd1_loc + 1 == bd1_end) {
						psw_cc = psw_cc2;
					} else {
						psw_cc = psw_cc1;
					}
					reg.putInt(r1, (reg.getInt(r1) & psw_amode_high_bits) // RPI-828
							| bd1_loc);
					reg.put(r2 + 3, mem_byte[bd2_loc + (mem_byte[bd1_loc] & 0xff)]);
					bd1_end = 0; // RPI-441
				}
				bd1_loc++;
			}
			break;
		case 0xDE: // 5360 "DE" "ED" "SS"
			psw_check = false;
			ins_setup_ss();
			exec_ed_edmk(false);
			break;
		case 0xDF: // 5370 "DF" "EDMK" "SS"
			psw_check = false;
			ins_setup_ss();
			exec_ed_edmk(true);
			break;
		case 0xE0: // 5375 "E00" "XREAD" "RXSS" 38 RPI-812
			if (tz390.opt_assist) {
				ins_E0X(); // RPI-802 ASSIST extended I/O instructions
			}
			break;
		case 0xE1: // 5380 "E1" "PKU" "SS"
			ins_setup_ss();
			break;
		case 0xE2: // 5390 "E2" "UNPKU" "SS"
			ins_setup_ss();
			break;
		case 0xE3:
			ins_E3XX();  // RPI-1207
			break;
		case 0xE5:
			ins_E5XX();
			break;
		case 0xE8: // 6170 "E8" "MVCIN" "SS"
			psw_check = false;
			ins_setup_ss();
			int index = 0;           // RPI-823
			while (index < rflen) {  // RPI-823
				mem_byte[bd1_loc + index] = mem_byte[bd2_loc - index];  // RPI-823
				index++;
			}
			break;
		case 0xE9: // 6180 "E9" "PKA" "SS"
			psw_check = false;
			ins_setup_ss();
			bd1_end = bd1_loc - 1;
			bd2_end = bd2_loc - 1;
			rflen1 = 16;
			if (rflen <= 32) {
				rflen2 = rflen;
			} else {
				set_psw_check(Constants.psw_pic_spec);
				break;
			}
			bd1_loc = bd1_loc + rflen1 - 1;
			bd2_loc = bd2_loc + rflen2 - 1;
			pdf_next_out = 0xc;
			while (bd1_loc > bd1_end) {
				if (bd2_loc > bd2_end) {
					pdf_next_in = mem_byte[bd2_loc];
					bd2_loc--;
				} else {
					pdf_next_in = 0;
				}
				mem_byte[bd1_loc] = (byte) (pdf_next_out | ((pdf_next_in & 0xf) << 4));
				bd1_loc--;
				if (bd2_loc > bd2_end) {
					pdf_next_out = (byte) (mem_byte[bd2_loc] & 0xf);
					bd2_loc--;
				} else {
					pdf_next_out = 0;
				}
			}
			break;
		case 0xEA: // 6190 "EA" "UNPKA" "SS"
			psw_check = false;
			ins_setup_ss();
			exec_unpka();
			break;
		case 0xEB:
			ins_EBXX();
			break;
		case 0xEC:
			ins_ECXX();
			break;
		case 0xED:
			ins_EDXX();
			break;
		case 0xEE: // 7020 "EE" "PLO" "SS"
			ins_setup_ss();
			break;
		case 0xEF: // 7030 "EF" "LMD" "SS"
			psw_check = false;
			ins_setup_ss();
			rf1 = ((rflen - 1) & 0xf0) >> 1;
			rf3 = ((rflen - 1) & 0xf) << 3;
			if (rf1 > rf3) {
				while (rf1 < reg_len) {
					reg.putInt(rf1, mem.getInt(bd1_loc));
					reg.putInt(rf1 + 4, mem.getInt(bd2_loc));
					bd1_loc = bd1_loc + 4;
					bd2_loc = bd2_loc + 4;
					rf1 = rf1 + 8;
				}
				rf1 = 0;
			}
			while (rf1 <= rf3) {
				reg.putInt(rf1, mem.getInt(bd1_loc));
				reg.putInt(rf1 + 4, mem.getInt(bd2_loc));
				bd1_loc = bd1_loc + 4;
				bd2_loc = bd2_loc + 4;
				rf1 = rf1 + 8;
			}
			break;
		case 0xF0: // 7040 "F0" "SRP" "SS"
			psw_check = false;
			ins_setup_ssp();
			if (!get_pd(mem,bd1_loc, rflen1)) { // RPI-305
				break;
			}
			int round_digit = rflen2 - 1;
			int shift = bd2_loc & 0x3f;
			if (shift < 0x20) {
				while (shift > 0) {
					if (!pdf_is_big   // RPI-781
						&& (pdf_long > max_srp_long
							|| pdf_long < min_srp_long)) {
						pdf_is_big = true;
						pdf_big_int = BigInteger.valueOf(pdf_long);
					}
					if (pdf_is_big) {
						pdf_big_int = pdf_big_int.multiply(BigInteger.valueOf(10));
					} else {
						pdf_long = pdf_long * 10;
					}
					shift--;
				}
			} else {
				shift = 0x3f - shift + 1;
				while (shift > 1) {
					if (pdf_is_big) {
						pdf_big_int = pdf_big_int.divide(BigInteger.valueOf(10));
					} else {
						pdf_long = pdf_long / 10;
					}
					shift--;
				}
				if (pdf_is_big) {
					pdf_big_int = pdf_big_int.add(BigInteger.valueOf(round_digit));
					pdf_big_int = pdf_big_int.divide(BigInteger.valueOf(10));
				} else {
					pdf_long = (pdf_long + round_digit) / 10;
				}
			}
			put_pd(mem_byte, bd1_loc, rflen1);
			psw_cc = pd_cc;
			break;
		case 0xF1: // 7050 "F1" "MVO" "SS"
			psw_check = false;
			ins_setup_ssp();
			bd1_end = bd1_loc - 1;
			bd2_end = bd2_loc - 1;
			bd1_loc = bd1_loc + rflen1 - 1;
			bd2_loc = bd2_loc + rflen2 - 1;
			pdf_next_in = mem_byte[bd2_loc];
			bd2_loc--;
			pdf_next_out = (byte) (mem_byte[bd1_loc] & 0xf);
			mem_byte[bd1_loc] = (byte) (pdf_next_out | ((pdf_next_in & 0xf) << 4));
			bd1_loc--;
			while (bd1_loc > bd1_end) {
				pdf_next_out = (byte) ((pdf_next_in & 0xf0) >> 4);
				if (bd2_loc > bd2_end) {
					pdf_next_in = mem_byte[bd2_loc];
					bd2_loc--;
				} else {
					pdf_next_in = 0;
				}
				mem_byte[bd1_loc] = (byte) (pdf_next_out | ((pdf_next_in & 0xf) << 4));
				bd1_loc--;
			}
			break;
		case 0xF2: // 7060 "F2" "PACK" "SS"
			psw_check = false;
			ins_setup_ssp();
			bd1_end = bd1_loc - 1;
			bd2_end = bd2_loc - 1;
			bd1_loc = bd1_loc + rflen1 - 1;
			bd2_loc = bd2_loc + rflen2 - 1;
			pdf_next_out = (byte) ((mem_byte[bd2_loc] & 0xf0) >> 4);
			while (bd1_loc > bd1_end) {
				if (bd2_loc > bd2_end) {
					pdf_next_in = mem_byte[bd2_loc];
					bd2_loc--;
				} else {
					pdf_next_in = 0;
				}
				mem_byte[bd1_loc] = (byte) (pdf_next_out | ((pdf_next_in & 0xf) << 4));
				bd1_loc--;
				if (bd2_loc > bd2_end) {
					pdf_next_out = (byte) (mem_byte[bd2_loc] & 0xf);
					bd2_loc--;
				} else {
					pdf_next_out = 0;
				}
			}
			break;
		case 0xF3: // 7070 "F3" "UNPK" "SS"
			psw_check = false;
			ins_setup_ssp();
			bd1_end = bd1_loc - 1;
			bd2_end = bd2_loc - 1;
			bd1_loc = bd1_loc + rflen1 - 1;
			bd2_loc = bd2_loc + rflen2 - 1;
			mem_byte[bd1_loc] = (byte) (((mem_byte[bd2_loc] & 0xf0) >> 4) | ((mem_byte[bd2_loc] & 0xf) << 4));
			bd1_loc--;
			bd2_loc--;
			pdf_next_right = true;
			while (bd1_loc > bd1_end) {
				if (pdf_next_right) {
					if (bd2_loc > bd2_end) {
						pdf_next_right = false;
						pdf_next_in = mem_byte[bd2_loc];
						bd2_loc--;
					} else {
						pdf_next_in = 0;
					}
					mem_byte[bd1_loc] = (byte) ((pdf_next_in & 0xf) | pdf_zone);
					bd1_loc--;
				} else {
					pdf_next_right = true;
					mem_byte[bd1_loc] = (byte) (((pdf_next_in & 0xf0) >> 4) | pdf_zone);
					bd1_loc--;
				}
			}
			break;
		case 0xF8: // 7080 "F8" "ZAP" "SS"
			psw_check = false;
			ins_setup_ssp();
			if (get_pd(mem,bd2_loc, rflen2)) {
				put_pd(mem_byte, bd1_loc, rflen1);
				psw_cc = pd_cc;
			}
			break;
		case 0xF9: // 7090 "F9" "CP" "SS"
			psw_check = false;
			ins_setup_ssp();
			if (get_pdf_ints()) { // RPI-981
				if (pdf_is_big) {
					psw_cc = get_big_int_comp_cc(pdf_big_int1, pdf_big_int2);
				} else {
					psw_cc = get_long_comp_cc(pdf_long1, pdf_long2);
				}
			}
			break;
		case 0xFA: // 7100 "FA" "AP" "SS"
			psw_check = false;
			ins_setup_ssp();
			if (get_pdf_ints()) { // RPI-981
				if (pdf_is_big) {
					pdf_big_int = pdf_big_int1.add(pdf_big_int2);
				} else {
					pdf_long = pdf_long1 + pdf_long2;
				}
				put_pd(mem_byte, bd1_loc, rflen1);
			}
			psw_cc = pd_cc;
			break;
		case 0xFB: // 7110 "FB" "SP" "SS"
			psw_check = false;
			ins_setup_ssp();
			if (get_pdf_ints()) { // RPI-981
				if (pdf_is_big) {
					pdf_big_int = pdf_big_int1.subtract(pdf_big_int2);
				} else {
					pdf_long = pdf_long1 - pdf_long2;
				}
			}
			put_pd(mem_byte, bd1_loc, rflen1);
			psw_cc = pd_cc;
			break;
		case 0xFC: // 7120 "FC" "MP" "SS"
			psw_check = false;
			ins_setup_ssp();
			if (get_pdf_ints()) { // RPI-981
				if (pdf_is_big) {
					pdf_big_int = pdf_big_int1.multiply(pdf_big_int2);
				} else {
					if (pdf_long1 < max_pos_int && pdf_long1 > min_neg_int
						&& pdf_long2 < max_pos_int && pdf_long2 > min_neg_int) {
						pdf_long = pdf_long1 * pdf_long2;
					} else {
						pdf_is_big = true;
						pdf_big_int1 = BigInteger.valueOf(pdf_long1);
						pdf_big_int2 = BigInteger.valueOf(pdf_long2);
						pdf_big_int = pdf_big_int1.multiply(pdf_big_int2);
					}
				}
				put_pd(mem_byte, bd1_loc, rflen1);
			}
			break;
		case 0xFD: // 7130 "FD" "DP" "SS"
			psw_check = false;
			ins_setup_ssp();
			if (get_pdf_ints()) {  // RPI-981
				if (pdf_is_big) {
					if (pdf_big_int2.signum() == 0) {
						psw_cc = psw_cc3;
						set_psw_check(Constants.psw_pic_pd_div);
					}
					BigInteger[] big_quo_rem = pdf_big_int1.divideAndRemainder(pdf_big_int2);
					pdf_big_int = big_quo_rem[0];
					put_pd(mem_byte, bd1_loc, rflen1 - rflen2);
					pdf_big_int = big_quo_rem[1];
					put_pd(mem_byte, bd1_loc + rflen1 - rflen2, rflen2);
				} else {
					if (pdf_long2 == 0) {
						psw_cc = psw_cc3;
						set_psw_check(Constants.psw_pic_pd_div);
						break;
					}
					pdf_long = pdf_long1 / pdf_long2;
					put_pd(mem_byte, bd1_loc, rflen1 - rflen2);
					pdf_long = pdf_long1 - pdf_long * pdf_long2;
					put_pd(mem_byte, bd1_loc + rflen1 - rflen2, rflen2);
				}
			}
			break;
		}
	}

	/**
	 *
	 */
	private void ins_01XX()
	{
		opcode2 = mem_byte[psw_loc + opcode2_offset_e] & 0xff;
		switch (opcode2) {
		case 0x01: // 10 "0101" "PR" "E"
			psw_check = false;
			ins_setup_e();
			pop_pc_stack();
			break;
		case 0x02: // 20 "0102" "UPT" "E"
			ins_setup_e();
			break;
		case 0x04: // 30 "0104" "PTFF" "E" Z9-1
			/*
			 * perform timing facility function
			 * r0 = function
			 * r1 - parm block address
			 * Notes: 1. Map functions 0x00-0x43 to timing functions 0x80-C3 in svc(11)
			 */
			psw_check = false;
			ins_setup_e();
			reg.put(rf1 + 7, (byte) (reg.get(rf1 + 7) | 0x80 - 0x80));
			sz390.svc(11);
			break;
		case 0x07: // 30 "0107" "SCKPF" "E"
			ins_setup_e();
			break;
		case 0x0A: // 40 "010A" "PFPO" "E"   RPI-1013
			psw_check = false;
			ins_setup_e();
			exec_pfpo();
			break;
		case 0x0B: // 40 "010B" "TAM" "E"
			ins_setup_e();
			break;
		case 0x0C: // 50 "010C" "SAM24" "E"
			psw_check = false;
			ins_setup_e();
			set_psw_amode(psw_amode24_bit);
			break;
		case 0x0D: // 60 "010D" "SAM31" "E"
			psw_check = false;
			ins_setup_e();
			set_psw_amode(psw_amode31_bit);
			break;
		case 0x0E: // 70 "010E" "SAM64" "E"
			ins_setup_e();
			break;
		case 0xFF: // 80 "01FF" "TRAP2" "E"
			ins_setup_e();
			break;
		}
	}

	/**
	 *
	 */
	private void ins_A5XX()
	{
		opcode2 = mem_byte[psw_loc + opcode2_offset_ri] & 0x0f;
		switch (opcode2) {
		case 0x0: // 1820 "A50" "IIHH" "RI"
			psw_check = false;
			ins_setup_ri();
			reg.putShort(rf1, (short) if2);
			break;
		case 0x1: // 1830 "A51" "IIHL" "RI"
			psw_check = false;
			ins_setup_ri();
			reg.putShort(rf1 + 2, (short) if2);
			break;
		case 0x2: // 1840 "A52" "IILH" "RI"
			psw_check = false;
			ins_setup_ri();
			reg.putShort(rf1 + 4, (short) if2);
			break;
		case 0x3: // 1850 "A53" "IILL" "RI"
			psw_check = false;
			ins_setup_ri();
			reg.putShort(rf1 + 6, (short) if2);
			break;
		case 0x4: // 1860 "A54" "NIHH" "RI"
			psw_check = false;
			ins_setup_ri();
			rv1 = reg.getInt(rf1) & ((if2 << 16) | 0xffff);
			reg.putInt(rf1, rv1);
			if (rv1 == 0) {
				psw_cc = psw_cc0;
			} else {
				psw_cc = psw_cc1;
			}
			break;
		case 0x5: // 1870 "A55" "NIHL" "RI"
			psw_check = false;
			ins_setup_ri();
			rv1 = reg.getInt(rf1) & (0xffff0000 | (if2 & 0xffff));
			reg.putInt(rf1, rv1);
			if (rv1 == 0) {
				psw_cc = psw_cc0;
			} else {
				psw_cc = psw_cc1;
			}
			break;
		case 0x6: // 1880 "A56" "NILH" "RI"
			psw_check = false;
			ins_setup_ri();
			rv1 = reg.getInt(rf1 + 4) & (0xffff | (if2 << 16));
			reg.putInt(rf1 + 4, rv1);
			if (rv1 == 0) {
				psw_cc = psw_cc0;
			} else {
				psw_cc = psw_cc1;
			}
			break;
		case 0x7: // 1890 "A57" "NILL" "RI"
			psw_check = false;
			ins_setup_ri();
			rv1 = reg.getInt(rf1 + 4) & (0xffff0000 | (if2 & 0xffff));
			reg.putInt(rf1 + 4, rv1);
			if (rv1 == 0) {
				psw_cc = psw_cc0;
			} else {
				psw_cc = psw_cc1;
			}
			break;
		case 0x8: // 1900 "A58" "OIHH" "RI"
			psw_check = false;
			ins_setup_ri();
			rv1 = reg.getInt(rf1) | (if2 << 16);
			reg.putInt(rf1, rv1);
			if (rv1 == 0) {
				psw_cc = psw_cc0;
			} else {
				psw_cc = psw_cc1;
			}
			break;
		case 0x9: // 1910 "A59" "OIHL" "RI"
			psw_check = false;
			ins_setup_ri();
			rv1 = reg.getInt(rf1) | (if2 & 0xffff);
			reg.putInt(rf1, rv1);
			if (rv1 == 0) { // RPI-295
				psw_cc = psw_cc0;
			} else {
				psw_cc = psw_cc1;
			}
			break;
		case 0xA: // 1920 "A5A" "OILH" "RI"
			psw_check = false;
			ins_setup_ri();
			rv1 = reg.getInt(rf1 + 4) | (if2 << 16); // RPI-295
			reg.putInt(rf1 + 4, rv1);
			if (rv1 == 0) {
				psw_cc = psw_cc0;
			} else {
				psw_cc = psw_cc1;
			}
			break;
		case 0xB: // 1930 "A5B" "OILL" "RI"\
			psw_check = false;
			ins_setup_ri();
			rv1 = reg.getInt(rf1 + 4) | (if2 & 0xffff);
			reg.putInt(rf1 + 4, rv1);
			if (rv1 == 0) {
				psw_cc = psw_cc0;
			} else {
				psw_cc = psw_cc1;
			}
			break;
		case 0xC: // 1940 "A5C" "LLIHH" "RI"
			psw_check = false;
			ins_setup_ri();
			reg.putLong(rf1, (long) if2 << 48); // RPI-158
			break;
		case 0xD: // 1950 "A5D" "LLIHL" "RI"
			psw_check = false;
			ins_setup_ri();
			reg.putLong(rf1, ((long) if2 << 32) & long_low48_bits); // RPI-158
			break;
		case 0xE: // 1960 "A5E" "LLILH" "RI"
			psw_check = false;
			ins_setup_ri();
			reg.putLong(rf1, ((long) if2 << 16) & long_low32_bits); // RPI-158
			break;
		case 0xF: // 1970 "A5F" "LLILL" "RI"
			psw_check = false;
			ins_setup_ri();
			reg.putLong(rf1, (long) (if2 & 0xffff)); // RPI-158
			break;
		}
	}

	/**
	 *
	 */
	private void ins_A7XX()
	{
		opcode2 = mem_byte[psw_loc + opcode2_offset_ri] & 0x0f;
		switch (opcode2) {
		case 0x0: // 1980 "A70" "TMLH" "RI"
			psw_check = false;
			ins_setup_ri();
			psw_cc = get_tm_reg_cc(reg.getShort(rf1 + 4), if2); // RPI-844
			break;
		case 0x1: // 2000 "A71" "TMLL" "RI"
			psw_check = false;
			ins_setup_ri();
			psw_cc = get_tm_reg_cc(reg.getShort(rf1 + 6), if2); // RPI-844
			break;
		case 0x2: // 2020 "A72" "TMHH" "RI"
			psw_check = false;
			ins_setup_ri();
			psw_cc = get_tm_reg_cc(reg.getShort(rf1), if2); // RPI-844
			break;
		case 0x3: // 2030 "A73" "TMHL" "RI"
			psw_check = false;
			ins_setup_ri();
			psw_cc = get_tm_reg_cc(reg.getShort(rf1 + 2), if2); // RPI-844
			break;
		case 0x4: // 2040 "A74" "BRC" "RI"
			psw_check = false;
			ins_setup_ri();
			if ((psw_cc & mf1) > 0) {
				set_psw_loc(psw_loc - 4 + 2 * if2);
			}
			break;
		case 0x5: // 2360 "A75" "BRAS" "RI"
			psw_check = false;
			ins_setup_ri();
			reg.putInt(rf1 + 4, psw_loc | psw_amode_bit);
			set_psw_loc(psw_loc - 4 + 2 * if2);
			break;
		case 0x6: // 2380 "A76" "BRCT" "RI"
			psw_check = false;
			ins_setup_ri();
			rv1 = reg.getInt(rf1 + 4) - 1;
			reg.putInt(rf1 + 4, rv1);
			if (rv1 != 0) {
				set_psw_loc(psw_loc - 4 + if2 + if2); // RPI-357
			}
			break;
		case 0x7: // 2400 "A77" "BRCTG" "RI"
			psw_check = false;
			ins_setup_ri();
			rlv1 = reg.getLong(rf1) - 1;
			reg.putLong(rf1, rlv1);
			if (rlv1 != 0) {
				set_psw_loc(psw_loc - 4 + 2 * if2);
			}
			break;
		case 0x8: // 2420 "A78" "LHI" "RI"
			psw_check = false;
			ins_setup_ri();
			reg.putInt(rf1 + 4, if2);
			break;
		case 0x9: // 2430 "A79" "LGHI" "RI"
			psw_check = false;
			ins_setup_ri();
			reg.putLong(rf1, if2);
			break;
		case 0xA: // 2440 "A7A" "AHI" "RI"
			psw_check = false;
			ins_setup_ri();
			rv1 = reg.getInt(rf1 + 4);
			rv2 = if2;
			rv3 = rv1 + rv2;
			reg.putInt(rf1 + 4, rv3);
			psw_cc = get_int_add_cc();
			break;
		case 0xB: // 2450 "A7B" "AGHI" "RI"
			psw_check = false;
			ins_setup_ri();
			rlv1 = reg.getLong(rf1);
			rlv2 = if2;
			rlv3 = rlv1 + rlv2;
			reg.putLong(rf1, rlv3);
			psw_cc = get_long_add_cc();
			break;
		case 0xC: // 2460 "A7C" "MHI" "RI"
			psw_check = false;
			ins_setup_ri();
			reg.putInt(rf1 + 4, reg.getInt(rf1 + 4) * if2);
			break;
		case 0xD: // 2470 "A7D" "MGHI" "RI"
			psw_check = false;
			ins_setup_ri();
			reg.putLong(rf1, reg.getLong(rf1) * if2);
			break;
		case 0xE: // 2480 "A7E" "CHI" "RI"
			psw_check = false;
			ins_setup_ri();
			psw_cc = get_int_comp_cc(reg.getInt(rf1 + 4), if2);
			break;
		case 0xF: // 2490 "A7F" "CGHI" "RI"
			psw_check = false;
			ins_setup_ri();
			psw_cc = get_long_comp_cc(reg.getLong(rf1), if2);
			break;
		}
	}

	/**
	 *
	 */
	private void ins_B2XX()
	{
		opcode2 = mem_byte[psw_loc + opcode2_offset_s] & 0xff;
		switch (opcode2) {
		case 0x02: // 2570 "B202" "STIDP" "S"
			psw_check = false;
			ins_setup_s();
			mem.putLong(bd2_loc, cpu_id);
			break;
		case 0x04: // 2580 "B204" "SCK" "S"
			ins_setup_s();
			break;
		case 0x05: // 2590 "B205" "STCK" "S"
			psw_check = false;
			ins_setup_s();
			/*
			 * Notes:
			 * 1. The Java time stored is milliseconds since Jan. 1, 1970.
			 * 2. For IBM OS compatibility the STCK instruction converts Java time to base
			 *    of January 1, 1900 with bit 51 being incremented each microsecond.
			 * 3. The low bits are incremented to prevent duplicate values from being returned when timing on.
			 */
			if (tz390.opt_timing) {
				java_mil = System.currentTimeMillis();
			} else {
				java_mil = cur_date.getTime();
			}
			ibm_ms = (java_mil + ibm_mil) * 1000;
			cur_stck = ibm_ms << (63 - 51);
			if (cur_stck > last_stck) {
				last_stck = cur_stck;
			} else {
				last_stck++;
			}
			mem.putLong(bd2_loc, last_stck);
			break;
		case 0x06: // 2600 "B206" "SCKC" "S"
			ins_setup_s();
			break;
		case 0x07: // 2610 "B207" "STCKC" "S"
			ins_setup_s();
			break;
		case 0x08: // 2620 "B208" "SPT" "S"
			ins_setup_s();
			break;
		case 0x09: // 2630 "B209" "STPT" "S"
			ins_setup_s();
			break;
		case 0x0A: // 2640 "B20A" "SPKA" "S"
			ins_setup_s();
			break;
		case 0x0B: // 2650 "B20B" "IPK" "S"
			ins_setup_s();
			break;
		case 0x0D: // 2660 "B20D" "PTLB" "S"
			ins_setup_s();
			break;
		case 0x10: // 2670 "B210" "SPX" "S"
			ins_setup_s();
			break;
		case 0x11: // 2680 "B211" "STPX" "S"
			ins_setup_s();
			break;
		case 0x12: // 2690 "B212" "STAP" "S"
			ins_setup_s();
			break;
		case 0x18: // 2700 "B218" "PC" "S"
			psw_check = false;
			ins_setup_s();
			push_pc_stack(true,psw_loc);
			set_psw_loc(bd2_loc);
			break;
		case 0x19: // 2710 "B219" "SAC" "S"
			ins_setup_s();
			break;
		case 0x1A: // 2720 "B21A" "CFC" "S"
			ins_setup_s();
			break;
		case 0x21: // 2730 "B221" "IPTE" "RRE"
			ins_setup_rre();
			break;
		case 0x22: // 2740 "B222" "IPM" "RRE"
			psw_check = false;
			ins_setup_rre();
			final int int_work = (psw_cc_code[psw_cc] << 4) | psw_pgm_mask;
			rv1 = reg.getInt(rf1 + 4) & 0xffffff; // RPI-106
			reg.putInt(rf1 + 4, rv1 | (int_work << 24)); // RPI-106
			break;
		case 0x23: // 2750 "B223" "IVSK" "RRE"
			ins_setup_rre();
			break;
		case 0x24: // 2760 "B224" "IAC" "RRE"
			ins_setup_rre();
			break;
		case 0x25: // 2770 "B225" "SSAR" "RRE"
			ins_setup_rre();
			break;
		case 0x26: // 2780 "B226" "EPAR" "RRE"
			ins_setup_rre();
			break;
		case 0x27: // 2790 "B227" "ESAR" "RRE"
			ins_setup_rre();
			break;
		case 0x28: // 2800 "B228" "PT" "RRE"
			ins_setup_rre();
			break;
		case 0x29: // 2810 "B229" "ISKE" "RRE"
			ins_setup_rre();
			break;
		case 0x2A: // 2820 "B22A" "RRBE" "RRE"
			ins_setup_rre();
			break;
		case 0x2B: // 2830 "B22B" "SSKE" "RRE"
			ins_setup_rre();
			break;
		case 0x2C: // 2840 "B22C" "TB" "RRE"
			ins_setup_rre();
			break;
		case 0x2D: // 2850 "B22D" "DXR" "RRE"
			psw_check = false;
			ins_setup_rre();
			fp_rbdv1 = fp_get_bd_from_lh(fp_reg, rf1);
			fp_rbdv2 = fp_get_bd_from_lh(fp_reg, rf2);
			if (fp_rbdv2.signum() != 0) {
				fp_rbdv1 = fp_rbdv1.divide(fp_rbdv2, fp_lxg_context); // RPI-821
			} else {
				fp_rbdv1 = BigDecimal.ZERO; // RPI-824
			}
			fp_put_bd(rf1, tz390.fp_lh_type, fp_rbdv1);
			check_lh_div();
			break;
		case 0x2E: // 2860 "B22E" "PGIN" "RRE"
			ins_setup_rre();
			break;
		case 0x2F: // 2870 "B22F" "PGOUT" "RRE"
			ins_setup_rre();
			break;
		case 0x30: // 2880 "B230" "CSCH" "S"
			ins_setup_s();
			break;
		case 0x31: // 2890 "B231" "HSCH" "S"
			ins_setup_s();
			break;
		case 0x32: // 2900 "B232" "MSCH" "S"
			ins_setup_s();
			break;
		case 0x33: // 2910 "B233" "SSCH" "S"
			ins_setup_s();
			break;
		case 0x34: // 2920 "B234" "STSCH" "S"
			ins_setup_s();
			break;
		case 0x35: // 2930 "B235" "TSCH" "S"
			ins_setup_s();
			break;
		case 0x36: // 2940 "B236" "TPI" "S"
			ins_setup_s();
			break;
		case 0x37: // 2950 "B237" "SAL" "S"
			ins_setup_s();
			break;
		case 0x38: // 2960 "B238" "RSCH" "S"
			ins_setup_s();
			break;
		case 0x39: // 2970 "B239" "STCRW" "S"
			ins_setup_s();
			break;
		case 0x3A: // 2980 "B23A" "STCPS" "S"
			ins_setup_s();
			break;
		case 0x3B: // 2990 "B23B" "RCHP" "S"
			ins_setup_s();
			break;
		case 0x3C: // 3000 "B23C" "SCHM" "S"
			ins_setup_s();
			break;
		case 0x40: // 3010 "B240" "BAKR" "RRE"
			psw_check = false;
			ins_setup_rre();
			if (rf1 == 0) {
				push_pc_stack(false,psw_loc);
			} else {
				push_pc_stack(false,reg.getInt(rf1 + 4));
			}
			if (rf2 != 0) {
				set_psw_loc(reg.getInt(rf2 + 4));
			}
			break;
		case 0x41: // 3020 "B241" "CKSM" "RRE"
			ins_setup_rre();
			break;
		case 0x44: // 3030 "B244" "SQDR" "RRE"
			psw_check = false;
			ins_setup_rre();
			fp_rbdv2 = fp_get_bd_from_dh(fp_reg, rf2); // RPI-364 RPI-821
			fp_get_bd_sqrt();                            // RPI-821
			fp_put_bd(rf1, tz390.fp_dh_type, fp_rbdv1);  // RPI-821
			break;
		case 0x45: // 3040 "B245" "SQER" "RRE"
			psw_check = false;
			ins_setup_rre();
			fp_rdv1 = Math.sqrt(fp_get_db_from_eh(fp_reg, rf2));
			fp_put_db(rf1, tz390.fp_eh_type, fp_rdv1);
			break;
		case 0x46: // 3050 "B246" "STURA" "RRE"
			ins_setup_rre();
			break;
		case 0x47: // 3060 "B247" "MSTA" "RRE"
			ins_setup_rre();
			break;
		case 0x48: // 3070 "B248" "PALB" "RRE"
			ins_setup_rre();
			break;
		case 0x49: // 3080 "B249" "EREG" "RRE"
			psw_check = false;
			ins_setup_rre();
			if (cur_pc_stk_reg <= 0) {
				set_psw_check(Constants.psw_pic_stkerr);
				return;
			}
			int pc_stk_reg_base = cur_pc_stk_reg - reg_len;
			if (rf1 > rf3) {
				while (rf1 < reg_len) {
					reg.putInt(rf1 + 4, pc_stk_reg.getInt(pc_stk_reg_base
							+ rf1 + 4));
					rf1 = rf1 + 8;
				}
				rf1 = 0;
			}
			while (rf1 <= rf3) {
				reg.putInt(rf1 + 4, pc_stk_reg.getInt(pc_stk_reg_base + rf1
						+ 4));
				rf1 = rf1 + 8;
			}
			break;
		case 0x4A: // 3090 "B24A" "ESTA" "RRE"
			psw_check = false;
			ins_setup_rre();
			if ((rf1 & 1) != 0 || cur_pc_stk <= 0) {
				set_psw_check(Constants.psw_pic_spec); // r1 must be even
				break;
			}
			if (pc_stk_type_pc[cur_pc_stk-1]) {
				psw_cc = psw_cc1; // PC entry
			} else {
				psw_cc = psw_cc0;  // BAKR entry
			}
			switch (reg.get(rf2+7)) { // RPI-1026
			case 2: // place PSW in R1+1
				reg.putInt(rf1+4,0);
				reg.putInt(rf1+12,pc_stk_psw_loc[cur_pc_stk-1]);
				break;
			default:
				set_psw_check(Constants.psw_pic_spec); // only 13/31 amode supported
			}
			break;
		case 0x4B: // 3100 "B24B" "LURA" "RRE"
			ins_setup_rre();
			break;
		case 0x4C: // 3110 "B24C" "TAR" "RRE"
			ins_setup_rre();
			break;
		case 0x4D: // 3120 "B24D" "CPYA" "RRE"
			psw_check = false; // RPI-1055
			ins_setup_rre();
			ar_reg.putInt(rf1 >> 1,ar_reg.getInt(rf2 >> 1)); // RPI-1055
			break;
		case 0x4E: // 3130 "B24E" "SAR" "RRE"
			psw_check = false; // RPI-1055
			ins_setup_rre();
			ar_reg.putInt(rf1 >> 1,reg.getInt(rf2 + 4)); // RPI-1055
			break;
		case 0x4F: // 3140 "B24F" "EAR" "RRE"
			psw_check = false; // RPI-1055
			ins_setup_rre();
			reg.putInt(rf1 + 4,ar_reg.getInt(rf2 >> 1)); // RPI-1055
			break;
		case 0x50: // 3150 "B250" "CSP" "RRE"
			ins_setup_rre();
			break;
		case 0x52: // 3160 "B252" "MSR" "RRE"
			psw_check = false;
			ins_setup_rre();
			reg.putInt(rf1 + 4, reg.getInt(rf1 + 4) * reg.getInt(rf2 + 4));
			break;
		case 0x54: // 3170 "B254" "MVPG" "RRE"
			ins_setup_rre();
			break;
		case 0x55: // 3180 "B255" "MVST" "RRE"
			psw_check = false; // RPI-441
			ins_setup_rre();
			bd1_loc = reg.getInt(rf1 + 4) & psw_amode;
			bd2_loc = reg.getInt(rf2 + 4) & psw_amode;
			bd2_start = bd2_loc;
			string_eod = reg.get(7);
			while (mem_byte[bd2_loc] != string_eod) { // RPI-453
				bd2_loc++; // RPI-476
			}
			rflen = bd2_loc - bd2_start + 1;
			System.arraycopy(mem_byte, bd2_start, mem_byte, bd1_loc, rflen); // RPI-411
			reg.putInt(rf1 + 4, bd1_loc + rflen - 1);  // rpi-758
			psw_cc = psw_cc1;
			break;
		case 0x57: // 3190 "B257" "CUSE" "RRE"
			psw_check = false;
			ins_setup_rre();
			if ((mf1 & 1) != 0      // RPI-758
				|| (mf2 & 1) != 0) { // RPI-1195
				set_psw_check(Constants.psw_pic_spec);
			}
			exec_cuse();
			break;
		case 0x58: // 3200 "B258" "BSG" "RRE"
			ins_setup_rre();
			break;
		case 0x5A: // 3210 "B25A" "BSA" "RRE"
			ins_setup_rre();
			break;
		case 0x5D: // 3220 "B25D" "CLST" "RRE"
			psw_check = false;
			ins_setup_rre();
			exec_clst();
			break;
		case 0x5E: // 3230 "B25E" "SRST" "RRE"
			psw_check = false;
			ins_setup_rre();
			exec_srst();
			break;
		case 0x63: // 3240 "B263" "CMPSC" "RRE"
			ins_setup_rre();
			break;
		case 0x76: // 3250 "B276" "XSCH" "S"
			ins_setup_s();
			break;
		case 0x77: // 3260 "B277" "RP" "S"
			ins_setup_s();
			break;
		case 0x78: // 3270 "B278" "STCKE" "S"
			psw_check = false;
			ins_setup_s();
			/*
			 * Notes:
			 * 1. The Java time stored is milliseconds since Jan. 1, 1970.
			 * 2. For IBM OS compatibility the STCKE instruction converts
			 *    Java time to base of January 1, 1900 with bit 59
			 *    being incremented each microsecond.
			 */
			if (tz390.opt_timing) {
				java_mil = System.currentTimeMillis();
			} else {
				java_mil = cur_date.getTime();
			}
			ibm_ms = (java_mil + ibm_mil) * 1000;
			mem.putLong(bd2_loc, ibm_ms << (63 - 59));
			mem.putLong(bd2_loc + 8, 0);
			break;
		case 0x79: // 3280 "B279" "SACF" "S"
			ins_setup_s();
			break;
		case 0x7C: // 3300 "B27C" "STCKF" "S" Z9-2
			psw_check = false;
			ins_setup_s();
			/*
			 * Notes:
			 * 1. The Java time stored is milliseconds since Jan. 1, 1970.
			 * 2. For IBM OS compatibility the STCK instruction converts Java time to
			 *    base of January 1, 1900 with bit 51 being incremented each microsecond.
			 */
			if (tz390.opt_timing) {
				java_mil = System.currentTimeMillis();
			} else {
				java_mil = cur_date.getTime();
			}
			ibm_ms = (java_mil + ibm_mil) * 1000;
			mem.putLong(bd2_loc, ibm_ms << (63 - 51));
			psw_cc = psw_cc0;
			break;
		case 0x7D: // 3290 "B27D" "STSI" "S"
			ins_setup_s();
			break;
		case 0x99: // 3300 "B299" "SRNM" "S"
			psw_check = false;
			ins_setup_s();
			fp_bfp_rnd = (bd2_loc & 0x3); // set bfp rounding mode
			fp_bfp_rnd_default = fp_bfp_rnd; // RPI-1125
			fp_fpc_reg = (fp_fpc_reg & fp_bfp_rnd_not) | fp_bfp_rnd;
			break;
		case 0x9C: // 3310 "B29C" "STFPC" "S"
			psw_check = false;
			ins_setup_s();
			mem.putInt(bd2_loc, fp_fpc_reg | (fp_dxc << 8));
			break;
		case 0x9D: // 3320 "B29D" "LFPC" "S"
			psw_check = false;
			ins_setup_s();
			set_fpc_reg(mem.getInt(bd2_loc));
			break;
		case 0xA5: // 3330 "B2A5" "TRE" "RRE"
			psw_check = false; // RPI-454
			ins_setup_rre();
			string_eod = reg.get(r0 + 3);
			bd1_loc = reg.getInt(rf1 + 4) & psw_amode;
			bd2_loc = reg.getInt(rf2 + 4) & psw_amode;
			bd1_end = bd1_loc + reg.getInt(rf1 + 12);
			psw_cc = psw_cc3;
			while (psw_cc == psw_cc3) {
				if (mem_byte[bd1_loc] == string_eod) {
					psw_cc = psw_cc1;
				} else {
					mem_byte[bd1_loc] = mem_byte[bd2_loc
							+ (mem_byte[bd1_loc] & 0xff)];
					bd1_loc++;
					if (bd1_loc >= bd1_end) {
						psw_cc = psw_cc0;
					}
				}
			}
			reg.putInt(rf1 + 4, bd1_loc);
			reg.putInt(rf1 + 12, bd1_end - bd1_loc);
			break;
		case 0xA6: // 3340 "B2A6" "CUUTF" "RRE"
			ins_setup_rre();
			break;
		case 0xA7: // 3360 "B2A7" "CUTFU" "RRE"
			ins_setup_rre();
			break;
		case 0xB0: // 3400 "B2B0" "STFLE" "S" Z9-3
			psw_check = false;
			ins_setup_s();
			/*
			 * store feature bit list
			 */
			mem.putLong(bd2_loc, sz390.get_feature_bits());
			reg.put(r0 + 7, (byte) 0); // number of feature doulbe words-1
			psw_cc = psw_cc0;
			break;
		case 0xB1: // 3380 "B2B1" "STFL" "S"
			ins_setup_s();
			break;
		case 0xB2: // 3390 "B2B2" "LPSWE" "S"
			ins_setup_s();
			break;
		case 0xB8: // 3300 "B2B8" "SRNMB" "S" RPI-1125
			psw_check = false;
			ins_setup_s();
			fp_bfp_rnd = (bd2_loc & 0x7); // set bfp rounding mode
			fp_bfp_rnd_default = fp_bfp_rnd; // RPI-1125
			fp_fpc_reg = (fp_fpc_reg & fp_bfp_rnd_not) | fp_bfp_rnd;
			if (fp_bfp_rnd > 3 && fp_bfp_rnd < 7) {
				set_psw_check(Constants.psw_pic_spec);
			}
			break;
		case 0xB9: // 3395 "B2B9" "SRNMT" "S" DFP 56
			psw_check = false;
			ins_setup_s();
			fp_dfp_rnd = (bd2_loc & 0x7); // set dfp rounding mode
			fp_dfp_rnd_default = fp_dfp_rnd; // RPI-1125
			fp_fpc_reg = (fp_fpc_reg & fp_dfp_rnd_not) | (fp_dfp_rnd << 4);
			break;
		case 0xBD: // 3395 "B2BD" "LFAS" "S" DFP 55
			psw_check = false;
			ins_setup_s();
			set_fpc_reg(mem.getInt(bd2_loc));
			break;
		case 0xFF: // 3400 "B2FF" "TRAP4" "S"
			ins_setup_s();
			break;
		}
	}

	/**
	 *
	 */
	private void ins_B3XX()
	{
		opcode2 = mem_byte[psw_loc + opcode2_offset_rre] & 0xff;
		switch (opcode2) {
		case 0x00: // 3410 "B300" "LPEBR" "RRE"
			psw_check = false;
			ins_setup_rre();
			fp_rev1 = Math.abs(fp_get_eb_from_eb(fp_reg, rf2));
			fp_put_eb(rf1, tz390.fp_eb_type, fp_rev1);
			psw_cc = fp_get_eb_comp_cc(fp_rev1, 0);
			break;
		case 0x01: // 3420 "B301" "LNEBR" "RRE"
			psw_check = false;
			ins_setup_rre();
			fp_rev1 = Math.abs(fp_get_eb_from_eb(fp_reg, rf2));
			if (fp_rev1 != 0) {
				fp_rev1 = -fp_rev1;
			}
			fp_put_eb(rf1, tz390.fp_eb_type, fp_rev1);
			psw_cc = fp_get_eb_comp_cc(fp_rev1, 0);
			break;
		case 0x02: // 3430 "B302" "LTEBR" "RRE"
			psw_check = false;
			ins_setup_rre();
			fp_rev1 = fp_get_eb_from_eb(fp_reg, rf2);
			fp_put_eb(rf1, tz390.fp_eb_type, fp_rev1);
			psw_cc = fp_get_eb_comp_cc(fp_rev1, 0);
			break;
		case 0x03: // 3440 "B303" "LCEBR" "RRE"
			psw_check = false;
			ins_setup_rre();
			fp_rev1 = fp_get_eb_from_eb(fp_reg, rf2);
			if (fp_rev1 != 0) {
				fp_rev1 = -fp_rev1;
			}
			fp_put_eb(rf1, tz390.fp_eb_type, fp_rev1);
			psw_cc = fp_get_eb_comp_cc(fp_rev1, 0);
			break;
		case 0x04: // 3450 "B304" "LDEBR" "RRE"
			psw_check = false;
			ins_setup_rre();
			fp_rdv1 = fp_get_db_from_eb(fp_reg, rf2);
			fp_put_db(rf1, tz390.fp_db_type, fp_rdv1);
			break;
		case 0x05: // 3460 "B305" "LXDBR" "RRE"
			psw_check = false;
			ins_setup_rre();
			fp_rbdv1 = fp_get_bd_from_db(fp_reg, rf2);
			fp_put_bd(rf1, tz390.fp_lb_type, fp_rbdv1);
			break;
		case 0x06: // 3470 "B306" "LXEBR" "RRE"
			psw_check = false;
			ins_setup_rre();
			fp_rbdv1 = fp_get_bd_from_eb(fp_reg, rf2);
			fp_put_bd(rf1, tz390.fp_lb_type, fp_rbdv1);
			break;
		case 0x07: // 3480 "B307" "MXDBR" "RRE"
			psw_check = false;
			ins_setup_rre();
			fp_rbdv1 = fp_get_bd_from_db(fp_reg, rf1)
					.multiply(fp_get_bd_from_db(fp_reg, rf2), fp_dbg_context).round(fp_lxg_context); // RPI-821
			fp_put_bd(rf1, tz390.fp_lb_type, fp_rbdv1);
			check_lb_mpy();
			break;
		case 0x08: // 3490 "B308" "KEBR" "RRE"
			psw_check = false;
			ins_setup_rre();
			fp_signal = true;
			psw_cc = fp_get_eb_comp_cc(fp_get_eb_from_eb(fp_reg, rf1),
					fp_get_eb_from_eb(fp_reg, rf2));
			break;
		case 0x09: // 3500 "B309" "CEBR" "RRE"
			psw_check = false;
			ins_setup_rre();
			psw_cc = fp_get_eb_comp_cc(fp_get_eb_from_eb(fp_reg, rf1),
					fp_get_eb_from_eb(fp_reg, rf2));
			break;
		case 0x0A: // 3510 "B30A" "AEBR" "RRE"
			psw_check = false;
			ins_setup_rre();
			fp_rev1 = fp_get_eb_from_eb(fp_reg, rf1)
					+ fp_get_eb_from_eb(fp_reg, rf2);
			fp_put_eb(rf1, tz390.fp_eb_type, fp_rev1);
			psw_cc = fp_get_eb_add_sub_cc();
			break;
		case 0x0B: // 3520 "B30B" "SEBR" "RRE"
			psw_check = false;
			ins_setup_rre();
			fp_rev1 = fp_get_eb_from_eb(fp_reg, rf1)
					- fp_get_eb_from_eb(fp_reg, rf2);
			fp_put_eb(rf1, tz390.fp_eb_type, fp_rev1);
			psw_cc = fp_get_eb_add_sub_cc();
			break;
		case 0x0C: // 3530 "B30C" "MDEBR" "RRE"
			psw_check = false;
			ins_setup_rre();
			fp_rdv1 = fp_get_db_from_eb(fp_reg, rf1)
					* fp_get_db_from_eb(fp_reg, rf2);
			fp_put_db(rf1, tz390.fp_db_type, fp_rdv1);
			check_db_mpy();
			break;
		case 0x0D: // 3540 "B30D" "DEBR" "RRE"
			psw_check = false;
			ins_setup_rre();
			fp_rev1 = fp_get_eb_from_eb(fp_reg, rf1);
			fp_rev2 = fp_get_eb_from_eb(fp_reg, rf2);
			fp_rev1 = fp_rev1 / fp_rev2;
			fp_put_eb(rf1, tz390.fp_eb_type, fp_rev1);
			check_eb_div();
			break;
		case 0x0E: // 3550 "B30E" "MAEBR" "RRF"
			psw_check = false;
			ins_setup_rrf1();
			fp_rev1 = fp_get_eb_from_eb(fp_reg, rf1)
					+ fp_get_eb_from_eb(fp_reg, rf2)
					* fp_get_eb_from_eb(fp_reg, rf3);
			fp_put_eb(rf1, tz390.fp_eb_type, fp_rev1);
			check_eb_mpy();
			break;
		case 0x0F: // 3560 "B30F" "MSEBR" "RRF"
			psw_check = false;
			ins_setup_rrf1();
			fp_rev1 = fp_get_eb_from_eb(fp_reg, rf2)
					* fp_get_eb_from_eb(fp_reg, rf3)
					- fp_get_eb_from_eb(fp_reg, rf1); // RPI-834
			fp_put_eb(rf1, tz390.fp_eb_type, fp_rev1);
			check_eb_mpy();
			break;
		case 0x10: // 3570 "B310" "LPDBR" "RRE"
			psw_check = false;
			ins_setup_rre();
			fp_rdv1 = Math.abs(fp_get_db_from_db(fp_reg, rf2));
			fp_put_db(rf1, tz390.fp_db_type, fp_rdv1);
			psw_cc = fp_get_db_comp_cc(fp_rdv1, 0);
			break;
		case 0x11: // 3580 "B311" "LNDBR" "RRE"
			psw_check = false;
			ins_setup_rre();
			fp_rdv1 = -Math.abs(fp_get_db_from_db(fp_reg, rf2));
			fp_put_db(rf1, tz390.fp_db_type, fp_rdv1);
			psw_cc = fp_get_db_comp_cc(fp_rdv1, 0);
			break;
		case 0x12: // 3590 "B312" "LTDBR" "RRE"
			psw_check = false;
			ins_setup_rre();
			fp_rdv1 = fp_get_db_from_db(fp_reg, rf2);
			fp_put_db(rf1, tz390.fp_db_type, fp_rdv1);
			psw_cc = fp_get_db_comp_cc(fp_rdv1, 0);
			break;
		case 0x13: // 3600 "B313" "LCDBR" "RRE"
			psw_check = false;
			ins_setup_rre();
			fp_rdv1 = -fp_get_db_from_db(fp_reg, rf2);
			fp_put_db(rf1, tz390.fp_db_type, fp_rdv1);
			psw_cc = fp_get_db_comp_cc(fp_rdv1, 0);
			break;
		case 0x14: // 3610 "B314" "SQEBR" "RRE"
			psw_check = false;
			ins_setup_rre();
			fp_rev1 = (float) Math.sqrt(fp_get_db_from_eb(fp_reg, rf2));
			fp_put_eb(rf1, tz390.fp_eb_type, fp_rev1);
			break;
		case 0x15: // 3620 "B315" "SQDBR" "RRE"
			psw_check = false;
			ins_setup_rre();
			fp_rdv1 = Math.sqrt(fp_get_db_from_db(fp_reg, rf2));
			fp_put_db(rf1, tz390.fp_db_type, fp_rdv1);
			break;
		case 0x16: // 3630 "B316" "SQXBR" "RRE"
			psw_check = false;
			ins_setup_rre();
			fp_rbdv2 = fp_get_bd_from_lb(fp_reg, rf2);
			fp_get_bd_sqrt();
			fp_put_bd(rf1, tz390.fp_lb_type, fp_rbdv1);
			break;
		case 0x17: // 3640 "B317" "MEEBR" "RRE"
			psw_check = false;
			ins_setup_rre();
			fp_rev1 = fp_get_eb_from_eb(fp_reg, rf1)
					* fp_get_eb_from_eb(fp_reg, rf2);
			fp_put_eb(rf1, tz390.fp_eb_type, fp_rev1);
			check_eh_mpy();
			break;
		case 0x18: // 3650 "B318" "KDBR" "RRE"
			psw_check = false;
			ins_setup_rre();
			fp_signal = true;
			psw_cc = fp_get_db_comp_cc(fp_get_db_from_db(fp_reg, rf1),
					fp_get_db_from_db(fp_reg, rf2));
			break;
		case 0x19: // 3660 "B319" "CDBR" "RRE"
			psw_check = false;
			ins_setup_rre();
			psw_cc = fp_get_db_comp_cc(fp_get_db_from_db(fp_reg, rf1),
					fp_get_db_from_db(fp_reg, rf2));
			break;
		case 0x1A: // 3670 "B31A" "ADBR" "RRE"
			psw_check = false;
			ins_setup_rre();
			fp_rdv1 = fp_get_db_from_db(fp_reg, rf1)
					+ fp_get_db_from_db(fp_reg, rf2);
			fp_put_db(rf1, tz390.fp_db_type, fp_rdv1);
			psw_cc = fp_get_db_add_sub_cc();
			break;
		case 0x1B: // 3680 "B31B" "SDBR" "RRE"
			psw_check = false;
			ins_setup_rre();
			fp_rdv1 = fp_get_db_from_db(fp_reg, rf1)
					- fp_get_db_from_db(fp_reg, rf2);
			fp_put_db(rf1, tz390.fp_db_type, fp_rdv1);
			psw_cc = fp_get_db_add_sub_cc();
			break;
		case 0x1C: // 3690 "B31C" "MDBR" "RRE"
			psw_check = false;
			ins_setup_rre();
			fp_rdv1 = fp_get_db_from_db(fp_reg, rf1)
					* fp_get_db_from_db(fp_reg, rf2);
			fp_put_db(rf1, tz390.fp_db_type, fp_rdv1);
			check_db_mpy();
			break;
		case 0x1D: // 3700 "B31D" "DDBR" "RRE"
			psw_check = false;
			ins_setup_rre();
			fp_rdv1 = fp_get_db_from_db(fp_reg, rf1);
			fp_rdv2 = fp_get_db_from_db(fp_reg, rf2);
			fp_rdv1 = fp_rdv1 / fp_rdv2;
			fp_put_db(rf1, tz390.fp_db_type, fp_rdv1);
			check_db_div();
			break;
		case 0x1E: // 3710 "B31E" "MADBR" "RRF"
			psw_check = false;
			ins_setup_rrf1();
			fp_rdv1 = fp_get_db_from_db(fp_reg, rf1)
					+ fp_get_db_from_db(fp_reg, rf2)
					* fp_get_db_from_db(fp_reg, rf3);
			fp_put_db(rf1, tz390.fp_db_type, fp_rdv1);
			check_db_mpy();
			break;
		case 0x1F: // 3720 "B31F" "MSDBR" "RRF"
			psw_check = false;
			ins_setup_rrf1();
			fp_rdv1 = fp_get_db_from_db(fp_reg, rf2)
					* fp_get_db_from_db(fp_reg, rf3)
					- fp_get_db_from_db(fp_reg, rf1); // RPI-834
			fp_put_db(rf1, tz390.fp_db_type, fp_rdv1);
			check_db_mpy();
			break;
		case 0x24: // 3730 "B324" "LDER" "RRE"
			psw_check = false;
			ins_setup_rre();
			fp_load_reg(rf1, tz390.fp_dh_type, fp_reg, rf2,
					tz390.fp_eh_type);
			break;
		case 0x25: // 3740 "B325" "LXDR" "RRE"
			psw_check = false;
			ins_setup_rre();
			fp_load_reg(rf1, tz390.fp_lh_type, fp_reg, rf2,
					tz390.fp_dh_type);
			break;
		case 0x26: // 3750 "B326" "LXER" "RRE"
			psw_check = false;
			ins_setup_rre();
			fp_load_reg(rf1, tz390.fp_lh_type, fp_reg, rf2,
					tz390.fp_eh_type);
			break;
		case 0x2E: // 3760 "B32E" "MAER" "RRF"
			psw_check = false;
			ins_setup_rrf1();
			fp_rdv1 = fp_get_db_from_eh(fp_reg, rf1)
					+ fp_get_db_from_eh(fp_reg, rf2)
					* fp_get_db_from_eh(fp_reg, rf3);
			fp_put_db(rf1, tz390.fp_eh_type, fp_rdv1);
			check_eh_mpy();
			break;
		case 0x2F: // 3770 "B32F" "MSER" "RRF"
			psw_check = false;
			ins_setup_rrf1();
			fp_rdv1 = fp_get_db_from_eh(fp_reg, rf2)
					* fp_get_db_from_eh(fp_reg, rf3)
					- fp_get_db_from_eh(fp_reg, rf1);  // RPI-834
			fp_put_db(rf1, tz390.fp_eh_type, fp_rdv1);
			check_eh_mpy();
			break;
		case 0x36: // 3780 "B336" "SQXR" "RRE"
			psw_check = false;
			ins_setup_rre();
			fp_rbdv2 = fp_get_bd_from_lh(fp_reg, rf2);
			fp_get_bd_sqrt();
			fp_put_bd(rf1, tz390.fp_lh_type, fp_rbdv1);
			break;
		case 0x37: // 3790 "B337" "MEER" "RRE"
			psw_check = false;
			ins_setup_rre();
			fp_rdv1 = fp_get_db_from_eh(fp_reg, rf1)
					* fp_get_db_from_eh(fp_reg, rf2);
			fp_put_db(rf1, tz390.fp_eh_type, fp_rdv1);
			check_eh_mpy();
			break;
		case 0x38: // 3830 "B338" "MAYLR" "RRF" Z9-4
			psw_check = false; // RPI-298
			ins_setup_rrf1();
			// unnormalized HFP RPI-767
			fp_store_reg(fp_reg,rf1);
			fp_long2 = fp_reg.getLong(rf2);
			fp_long3 = fp_reg.getLong(rf3);
			fp_mpy_unnorm_dh(); // RPI-767 big_int1=long2*long3
			tz390.fp_exp = tz390.fp_exp - 14; // use low half exponent
			fp_get_bi_unnorm_dh();
			fp_add_bi_unnorm_dh();
			tz390.fp_exp = tz390.fp_exp + 14; // restore exp for LH store
			fp_put_bi_to_lh_wreg();
			fp_reg.putLong(rf1,tz390.fp_work_reg.getLong(8));
			break;
		case 0x39: // 3840 "B339" "MYLR" "RRF" Z9-5
			psw_check = false; // RPI-298
			ins_setup_rrf1();
			// unnormalized HFP RPI-767
			fp_store_reg(fp_reg,rf1);
			fp_long2 = fp_reg.getLong(rf2);
			fp_long3 = fp_reg.getLong(rf3);
			fp_mpy_unnorm_dh(); // RPI-767 big_int1=long2*long3
			fp_put_bi_to_lh_wreg();
			fp_reg.putLong(rf1,tz390.fp_work_reg.getLong(8));
			break;
		case 0x3A: // 3850 "B33A" "MAYR" "RRF" Z9-6
			psw_check = false;
			ins_setup_rrf1();
			// unnormalized HFP RPI-767
			if (!fp_pair_valid[mf1]) { // RPI-229
				set_psw_check(Constants.psw_pic_spec);
			}
			fp_store_reg(fp_reg,rf1);
			fp_store_reg(fp_reg,rf1+16);
			fp_long2 = fp_reg.getLong(rf2);
			fp_long3 = fp_reg.getLong(rf3);
			fp_mpy_unnorm_dh(); // RPI-767 big_int1=long2*long3
			fp_get_bi_unnorm_lh();
			fp_add_bi_unnorm_dh();
			fp_put_bi_to_lh_wreg();
			fp_reg.putLong(rf1   ,tz390.fp_work_reg.getLong(0));
			fp_reg.putLong(rf1+16,tz390.fp_work_reg.getLong(8));
			break;
		case 0x3B: // 3860 "B33B" "MYR" "RRF" Z9-7
			psw_check = false;
			ins_setup_rrf1();
			// unnormalized HFP RPI-767
			if (!fp_pair_valid[mf1]) { // RPI-229
				set_psw_check(Constants.psw_pic_spec);
			}
			fp_store_reg(fp_reg,rf1   );
			fp_store_reg(fp_reg,rf1+16);
			fp_long2 = fp_reg.getLong(rf2);
			fp_long3 = fp_reg.getLong(rf3);
			fp_mpy_unnorm_dh(); // RPI-767 big_int1=long2*long3
			fp_put_bi_to_lh_wreg();
			fp_reg.putLong(rf1,tz390.fp_work_reg.getLong(0));
			fp_reg.putLong(rf1+16,tz390.fp_work_reg.getLong(8));
			break;
		case 0x3C: // 3870 "B33C" "MAYHR" "RRF" Z9-8
			psw_check = false; // RPI-298
			ins_setup_rrf1();
			// unnormalized HFP RPI-767
			fp_store_reg(fp_reg,rf1);
			fp_long2 = fp_reg.getLong(rf2);
			fp_long3 = fp_reg.getLong(rf3);
			fp_mpy_unnorm_dh(); // RPI-767 big_int1=long2*long3
			fp_get_bi_unnorm_dh();
			tz390.fp_exp = tz390.fp_exp - 14; // use low half exponent
			fp_add_bi_unnorm_dh();
			tz390.fp_exp = tz390.fp_exp + 14; // use low half exponent
			fp_put_bi_to_lh_wreg();
			fp_reg.putLong(rf1,tz390.fp_work_reg.getLong(0));
			break;
		case 0x3D: // 3880 "B33D" "MYHR" "RRF" Z9-9
			psw_check = false; // RPI-298
			ins_setup_rrf1();
			// unnormalized HFP RPI-767
			fp_store_reg(fp_reg,rf1);
			fp_long2 = fp_reg.getLong(rf2);
			fp_long3 = fp_reg.getLong(rf3);
			fp_mpy_unnorm_dh(); // RPI-767 big_int1=long2*long3
			fp_put_bi_to_lh_wreg();
			fp_reg.putLong(rf1,tz390.fp_work_reg.getLong(0));
			break;
		case 0x3E: // 3800 "B33E" "MADR" "RRF"
			psw_check = false;
			ins_setup_rrf1();
			fp_rbdv1 = fp_get_bd_from_dh(fp_reg, rf2)
					 .multiply(fp_get_bd_from_dh(fp_reg, rf3))
					 .add(fp_get_bd_from_dh(fp_reg, rf1));  // RPI-821
			fp_put_bd(rf1, tz390.fp_dh_type, fp_rbdv1);  // RPI-821
			check_dh_mpy();
			break;
		case 0x3F: // 3810 "B33F" "MSDR" "RRF"
			psw_check = false;
			ins_setup_rrf1();
			fp_rbdv1 = fp_get_bd_from_dh(fp_reg, rf2)
					 .multiply(fp_get_bd_from_dh(fp_reg, rf3))
					 .subtract(fp_get_bd_from_dh(fp_reg, rf1));  // RPI-834 RPI-821
			fp_put_bd(rf1, tz390.fp_dh_type, fp_rbdv1);  // RPI-821
			check_dh_mpy();
			break;
		case 0x40: // 3820 "B340" "LPXBR" "RRE"
			psw_check = false;
			ins_setup_rre();
			fp_rbdv1 = fp_get_bd_from_lb(fp_reg, rf2).abs();
			fp_put_bd(rf1, tz390.fp_lb_type, fp_rbdv1);
			psw_cc = fp_get_lb_comp_cc(fp_rbdv1, BigDecimal.ZERO);
			break;
		case 0x41: // 3830 "B341" "LNXBR" "RRE"
			psw_check = false;
			ins_setup_rre();
			fp_rbdv1 = fp_get_bd_from_lb(fp_reg, rf2).abs().negate();
			fp_put_bd(rf1, tz390.fp_lb_type, fp_rbdv1);
			psw_cc = fp_get_lb_comp_cc(fp_rbdv1, BigDecimal.ZERO);
			break;
		case 0x42: // 3840 "B342" "LTXBR" "RRE"
			psw_check = false;
			ins_setup_rre();
			fp_rbdv1 = fp_get_bd_from_lb(fp_reg, rf2);
			fp_put_bd(rf1, tz390.fp_lb_type, fp_rbdv1);
			psw_cc = fp_get_lb_comp_cc(fp_rbdv1, BigDecimal.ZERO);
			break;
		case 0x43: // 3850 "B343" "LCXBR" "RRE"
			psw_check = false;
			ins_setup_rre();
			fp_rbdv1 = fp_get_bd_from_lb(fp_reg, rf2).negate();
			fp_put_bd(rf1, tz390.fp_lb_type, fp_rbdv1);
			psw_cc = fp_get_lb_comp_cc(fp_rbdv1, BigDecimal.ZERO);
			break;
		case 0x44: // 3860 "B344" "" "RRE"
			psw_check = false;
			set_bfp_alt_mode_rr(); // RPI-1125
			ins_setup_rre();
			fp_load_reg(rf1, tz390.fp_eb_type, fp_reg, rf2,
					tz390.fp_db_type);
			reset_bfp_alt_mode(); // RPI-1125
			break;
		case 0x45: // 3870 "B345" "LDXBR" "RRE"
			psw_check = false;
			ins_setup_rre();
			fp_load_reg(rf1, tz390.fp_db_type, fp_reg, rf2,
					tz390.fp_lb_type);
			break;
		case 0x46: // 3880 "B346" "LEXBR" "RRE"
			psw_check = false;
			ins_setup_rre();
			fp_load_reg(rf1, tz390.fp_eb_type, fp_reg, rf2,
					tz390.fp_lb_type);
			break;
		case 0x47: // 3890 "B347" "FIXBR" "RRF"
			psw_check = false;
			set_bfp_alt_mode_rr(); // RPI-1125
			ins_setup_rrf2();
			fp_bd_int_rem = fp_get_bd_from_lb(fp_reg, rf2)
					.divideAndRemainder(BigDecimal.ONE);
			fp_put_bd(rf1, tz390.fp_lb_type, fp_get_bd_rnd_int(fp_bfp_class,mf3));
			reset_bfp_alt_mode(); // RPI-1125
			break;
		case 0x48: // 3900 "B348" "KXBR" "RRE"
			psw_check = false;
			ins_setup_rre();
			fp_signal = true;
			psw_cc = fp_get_lb_comp_cc(fp_get_bd_from_lb(fp_reg, rf1),
					fp_get_bd_from_lb(fp_reg, rf2));
			break;
		case 0x49: // 3910 "B349" "CXBR" "RRE"
			psw_check = false;
			ins_setup_rre();
			psw_cc = fp_get_lb_comp_cc(fp_get_bd_from_lb(fp_reg, rf1),
					fp_get_bd_from_lb(fp_reg, rf2));
			break;
		case 0x4A: // 3920 "B34A" "AXBR" "RRE"
			psw_check = false;
			ins_setup_rre();
			if ((mf1 & 1) != 0) { // RPI-758
				set_psw_check(Constants.psw_pic_spec);
			}
			fp_rbdv1 = fp_get_bd_from_lb(fp_reg, rf1);
			fp_rbdv2 = fp_get_bd_from_lb(fp_reg, rf2);
			fp_rbdv1 = fp_rbdv1.add(fp_rbdv2, fp_lxg_context); // RPI-821
			fp_put_bd(rf1, tz390.fp_lb_type, fp_rbdv1);
			psw_cc = fp_get_lb_add_sub_cc();
			break;
		case 0x4B: // 3930 "B34B" "SXBR" "RRE"
			psw_check = false;
			ins_setup_rre();
			fp_rbdv1 = fp_get_bd_from_lb(fp_reg, rf1).subtract(
					fp_get_bd_from_lb(fp_reg, rf2), fp_lxg_context);
			fp_put_bd(rf1, tz390.fp_lb_type, fp_rbdv1);
			psw_cc = fp_get_lb_add_sub_cc();
			break;
		case 0x4C: // 3940 "B34C" "MXBR" "RRE"
			psw_check = false;
			ins_setup_rre();
			fp_rbdv1 = fp_get_bd_from_lb(fp_reg, rf1).round(fp_lb_rnd_context[fp_bfp_rnd])
					.multiply(fp_get_bd_from_lb(fp_reg, rf2).round(fp_lb_rnd_context[fp_bfp_rnd]), fp_lxg_context); // RPI-821
			fp_put_bd(rf1, tz390.fp_lb_type, fp_rbdv1);
			check_lb_mpy();
			break;
		case 0x4D: // 3950 "B34D" "DXBR" "RRE"
			psw_check = false;
			ins_setup_rre();
			fp_rbdv1 = fp_get_bd_from_lb(fp_reg, rf1);
			fp_rbdv2 = fp_get_bd_from_lb(fp_reg, rf2);
			if (fp_rbdv2.signum() != 0) {
				fp_rbdv1 = fp_rbdv1.divide(fp_rbdv2, fp_lxg_context); // RPI-821
			} else {
				fp_rbdv1 = BigDecimal.ZERO; // RPI-824
			}
			fp_put_bd(rf1, tz390.fp_lb_type, fp_rbdv1);
			check_lb_div();
			break;
		case 0x50: // 3960 "B350" "TBEDR" "RRF"
			psw_check = false;
			ins_setup_rrf2();
			fp_bd_int_rem = fp_get_bd_from_dh(fp_reg, rf2)
					.divideAndRemainder(BigDecimal.ONE);
			fp_rev1 = fp_get_bd_rnd_int(fp_bfp_class,mf3).floatValue(); // RPI-333
			fp_put_eb(rf1, tz390.fp_eb_type, fp_rev1);
			psw_cc = fp_get_eb_comp_cc(fp_rev1, 0);
			break;
		case 0x51: // 3970 "B351" "TBDR" "RRF"
			psw_check = false;
			ins_setup_rrf2();
			fp_bd_int_rem = fp_get_bd_from_dh(fp_reg, rf2)
					.divideAndRemainder(BigDecimal.ONE);
			fp_rdv1 = fp_get_bd_rnd_int(fp_bfp_class,mf3).doubleValue(); // RPI-333
			fp_put_db(rf1, tz390.fp_db_type, fp_rdv1);
			psw_cc = fp_get_db_comp_cc(fp_rdv1, 0);
			break;
		case 0x53: // 3980 "B353" "DIEBR" "RR4"
			psw_check = false;
			ins_setup_rrf3();
			if (mf4 != 0) { // only def. rounding for now
				set_psw_check(Constants.psw_pic_spec);
			}
			fp_rdv1 = fp_get_db_from_eb(fp_reg, rf1);
			fp_rdv2 = fp_get_db_from_eb(fp_reg, rf2);
			fp_rdv3 = (long) (fp_rdv1 / fp_rdv2);
			fp_rdv4 = fp_rdv1 - fp_rdv3 * fp_rdv2;
			fp_put_eb(rf3, tz390.fp_eb_type, (float) fp_rdv3);
			fp_put_eb(rf1, tz390.fp_eb_type, (float) fp_rdv4);
			psw_cc = fp_get_di_cc();
			break;
		case 0x57: // 3990 "B357" "FIEBR" "RRF"
			psw_check = false;
			set_bfp_alt_mode_rr(); // RPI-1125
			ins_setup_rrf2();
			fp_bd_int_rem = fp_get_bd_from_eb(fp_reg, rf2)
					.divideAndRemainder(BigDecimal.ONE);
			fp_put_eb(rf1, tz390.fp_eb_type, fp_get_bd_rnd_int(fp_bfp_class,mf3)
					.floatValue());
			reset_bfp_alt_mode(); // RPI-1125
			break;
		case 0x58: // 4000 "B358" "THDER" "RRE"
			psw_check = false;
			ins_setup_rre();
			fp_rbdv1 = BigDecimal.valueOf(fp_get_db_from_eb(fp_reg, rf2)); // RPI-821
			fp_put_bd(rf1, tz390.fp_dh_type, fp_rbdv1);                // RPI-821
			psw_cc = fp_get_dh_comp_cc(fp_rbdv1,BigDecimal.ZERO);      // RPI-821
			break;
		case 0x59: // 4010 "B359" "THDR" "RRE"
			psw_check = false;
			ins_setup_rre();
			fp_rbdv1 = BigDecimal.valueOf(fp_get_db_from_db(fp_reg, rf2));// RPI-821
			fp_put_bd(rf1, tz390.fp_dh_type, fp_rbdv1);          	  // RPI-821
			psw_cc = fp_get_dh_comp_cc(fp_rbdv1,BigDecimal.ZERO);     // RPI-821
			break;
		case 0x5B: // 4020 "B35B" "DIDBR" "RR4"
			psw_check = false;
			ins_setup_rrf3();
			if (mf4 != 0) { // only def. rounding for now
				set_psw_check(Constants.psw_pic_spec);
			}
			fp_rdv1 = fp_get_db_from_db(fp_reg, rf1);
			fp_rdv2 = fp_get_db_from_db(fp_reg, rf2);
			fp_rdv3 = (long) (fp_rdv1 / fp_rdv2);
			fp_rdv4 = fp_rdv1 - fp_rdv3 * fp_rdv2;
			fp_put_db(rf3, tz390.fp_db_type, fp_rdv3);
			fp_put_db(rf1, tz390.fp_db_type, fp_rdv4);
			psw_cc = fp_get_di_cc();
			break;
		case 0x5F: // 4030 "B35F" "FIDBR" "RRF"
			psw_check = false;
			set_bfp_alt_mode_rr(); // RPI-1125
			ins_setup_rrf2();
			fp_bd_int_rem = fp_get_bd_from_db(fp_reg, rf2)
					.divideAndRemainder(BigDecimal.ONE);
			fp_put_db(rf1, tz390.fp_db_type, fp_get_bd_rnd_int(fp_bfp_class,mf3)
					.doubleValue());
			reset_bfp_alt_mode(); // RPI-1125
			break;
		case 0x60: // 4040 "B360" "LPXR" "RRE"
			psw_check = false;
			ins_setup_rre();
			fp_rbdv1 = fp_get_bd_from_lh(fp_reg, rf2).abs();
			fp_put_bd(rf1, tz390.fp_lh_type, fp_rbdv1);
			psw_cc = fp_get_lh_comp_cc(fp_rbdv1, BigDecimal.ZERO);
			break;
		case 0x61: // 4050 "B361" "LNXR" "RRE"
			psw_check = false;
			ins_setup_rre();
			fp_rbdv1 = fp_get_bd_from_lh(fp_reg, rf2).abs().negate();
			fp_put_bd(rf1, tz390.fp_lh_type, fp_rbdv1);
			psw_cc = fp_get_lh_comp_cc(fp_rbdv1, BigDecimal.ZERO);
			break;
		case 0x62: // 4060 "B362" "LTXR" "RRE"
			psw_check = false;
			ins_setup_rre();
			fp_rbdv1 = fp_get_bd_from_lh(fp_reg, rf2);
			fp_put_bd(rf1, tz390.fp_lh_type, fp_rbdv1);
			psw_cc = fp_get_lh_comp_cc(fp_rbdv1, BigDecimal.ZERO);

			break;
		case 0x63: // 4070 "B363" "LCXR" "RRE"
			psw_check = false;
			ins_setup_rre();
			fp_rbdv1 = fp_get_bd_from_lh(fp_reg, rf2).negate();
			fp_put_bd(rf1, tz390.fp_lh_type, fp_rbdv1);
			psw_cc = fp_get_lh_comp_cc(fp_rbdv1, BigDecimal.ZERO);

			break;
		case 0x65: // 4080 "B365" "LXR" "RRE"
			psw_check = false;
			ins_setup_rre();
			int fp_ctl_index1 = rf1 >>> 3;
			int fp_ctl_index2 = rf2 >>> 3;
			fp_copy_reg(fp_ctl_index1,fp_ctl_index2);  // RPI-816
			fp_copy_reg(fp_ctl_index1+2,fp_ctl_index2+2);
			break;
		case 0x66: // 4090 "B366" "LEXR" "RRE"
			psw_check = false;
			ins_setup_rre();
			fp_load_reg(rf1, tz390.fp_eh_type, fp_reg, rf2,
					tz390.fp_lh_type);
			break;
		case 0x67: // 4100 "B367" "FIXR" "RRE"
			psw_check = false;
			ins_setup_rre();
			fp_rbdv1 = fp_get_bd_from_lh(fp_reg, rf2);
			fp_rbdv1 = fp_rbdv1.subtract(fp_rbdv1.remainder(BigDecimal.ONE,
					fp_lxg_context));
			fp_put_bd(rf1, tz390.fp_lh_type, fp_rbdv1);
			break;
		case 0x69: // 4110 "B369" "CXR" "RRE"
			psw_check = false;
			ins_setup_rre();
			psw_cc = fp_get_lh_comp_cc(fp_get_bd_from_lh(fp_reg, rf1),
					fp_get_bd_from_lh(fp_reg, rf2)); // RPI-821
			break;
		case 0x70: // 4115 "B370" "LPDFR" "RRE"  14 DFP
			psw_check = false;
			ins_setup_rre();
			fp_put_bd(rf1, tz390.fp_dd_type, fp_get_bd_from_dd(fp_reg,rf2).abs());
			break;
		case 0x71: // 4115 "B371" "LNDFR" "RRE"  14 DFP
			psw_check = false;
			ins_setup_rre();
			fp_put_bd(rf1, tz390.fp_dd_type, fp_get_bd_from_dd(fp_reg,rf2).abs().negate());
			break;
		case 0x72: // 4115 "B372" "CPSDR" "RRF2" 34 DFP
			psw_check = false;
			ins_setup_rrf2();
			if (fp_get_bd_from_dd(fp_reg,rf3).signum() >= 0) {
				fp_put_bd(rf1, tz390.fp_dd_type, fp_get_bd_from_dd(fp_reg,rf2).abs());
			} else {
				fp_put_bd(rf1, tz390.fp_dd_type, fp_get_bd_from_dd(fp_reg,rf2).abs().negate());
			}
			break;
		case 0x73: // 4115 "B373" "LCDFR" "RRE"  14 DFP
			psw_check = false;
			ins_setup_rre();
			fp_put_bd(rf1, tz390.fp_dd_type, fp_get_bd_from_dd(fp_reg,rf2).negate());
			break;
		case 0x74: // 4120 "B374" "LZER" "RRE"
			psw_check = false;
			ins_setup_rre();
			fp_put_db(rf1, tz390.fp_eh_type, 0);
			break;
		case 0x75: // 4130 "B375" "LZDR" "RRE"
			psw_check = false;
			ins_setup_rre();
			fp_put_bd(rf1, tz390.fp_dh_type,BigDecimal.ZERO);// RPI-821
			break;
		case 0x76: // 4140 "B376" "LZXR" "RRE"
			psw_check = false;
			ins_setup_rre();
			fp_put_bd(rf1, tz390.fp_lh_type, BigDecimal.ZERO);
			break;
		case 0x77: // 4150 "B377" "FIER" "RRE"
			psw_check = false;
			ins_setup_rre();
			fp_rdv1 = (long) fp_get_db_from_eh(fp_reg, rf2);
			fp_put_db(rf1, tz390.fp_eh_type, fp_rdv1);
			break;
		case 0x7F: // 4160 "B37F" "FIDR" "RRE"
			psw_check = false;
			ins_setup_rre();
			fp_rbdv1 = BigDecimal.valueOf(fp_get_bd_from_dh(fp_reg, rf2).longValue());  // RPI-821
			fp_put_bd(rf1, tz390.fp_dh_type, fp_rbdv1); // RPI-821
			break;
		case 0x84: // 4170 "B384" "SFPC" "RRE"
			psw_check = false;
			ins_setup_rre();
			fp_fpc_reg = reg.getInt(rf1 + 4);
			fp_dxc = (fp_fpc_reg & 0xff00) >>> 8;
			fp_fpc_reg = fp_fpc_reg & 0xffff00ff;
			break;
		case 0x85: // 4175 "B385" "SFASR" "RRE" DFP 57
			psw_check = false;
			ins_setup_rre();
			set_fpc_reg(reg.getInt(rf1+4));
			break;
		case 0x8C: // 4180 "B38C" "EFPC" "RRE"
			psw_check = false;
			ins_setup_rre();
			reg.putInt(rf1 + 4, fp_fpc_reg | (fp_dxc << 8));
			break;
		case 0x90: // RPI-1125 "B390" "CELFBR" "RRF3"
			psw_check = false;
			set_bfp_alt_mode_rr(); // RPI-1125
			ins_setup_rrf3();
			fp_rbdv1 = new BigDecimal(reg.getLong(rf2) & 0xffffffff)
			           .round(fp_eb_rnd_context[fp_get_rnd_mode(fp_bfp_class,mf3)]);
			fp_put_bd(rf1, tz390.fp_eb_type, fp_rbdv1);
			fp_store_reg(fp_reg, rf1); // RPI-787
			reset_bfp_alt_mode(); // RPI-1125
			break;
		case 0x91: // RPI-1125 "B391" "CDLFBR" "RRF3"
			psw_check = false;
			set_bfp_alt_mode_rr(); // RPI-1125
			ins_setup_rrf3();
			fp_rbdv1 = new BigDecimal(reg.getLong(rf2) & 0xffffffff)
			           .round(fp_db_rnd_context[fp_get_rnd_mode(fp_bfp_class,mf3)]);
			fp_put_bd(rf1, tz390.fp_db_type, fp_rbdv1);
			fp_store_reg(fp_reg, rf1); // RPI-787
			reset_bfp_alt_mode(); // RPI-1125
			break;
		case 0x92: // RPI-1125 "B392" "CXLFBR" "RRF3"
			psw_check = false;
			set_bfp_alt_mode_rr(); // RPI-1125
			ins_setup_rrf3();
			fp_rbdv1 = new BigDecimal(reg.getLong(rf2) & 0xffffffff)
			           .round(fp_lb_rnd_context[fp_get_rnd_mode(fp_bfp_class,mf3)]);
			fp_put_bd(rf1, tz390.fp_lb_type, fp_rbdv1);
			fp_store_reg(fp_reg, rf1); // RPI-787
			reset_bfp_alt_mode(); // RPI-1125
			break;
		case 0x94: // 4190 "B394" "CEFBR" "RRE"
			psw_check = false;
			set_bfp_alt_mode_rr(); // RPI-1125
			ins_setup_rre();
			fp_put_eb(rf1, tz390.fp_eb_type, (float) reg.getInt(rf2 + 4));
			reset_bfp_alt_mode(); // RPI-1125
			break;
		case 0x95: // 4200 "B395" "CDFBR" "RRE"
			psw_check = false;
			set_bfp_alt_mode_rr(); // RPI-1125
			ins_setup_rre();
			fp_put_db(rf1, tz390.fp_db_type, (double) reg.getInt(rf2 + 4));
			reset_bfp_alt_mode(); // RPI-1125
			break;
		case 0x96: // 4210 "B396" "CXFBR" "RRE"
			psw_check = false;
			set_bfp_alt_mode_rr(); // RPI-1125
			ins_setup_rre();
			fp_put_bd(rf1, tz390.fp_lb_type, BigDecimal.valueOf(reg
					.getInt(rf2 + 4))); // RPI-1013 was EB vs LB
			reset_bfp_alt_mode(); // RPI-1125
			break;
		case 0x98: // 4220 "B398" "CFEBR" "RRF"
			psw_check = false;
			set_bfp_alt_mode_rr(); // RPI-1125
			ins_setup_rrf2();
			fp_bd_int_rem = fp_get_bd_from_eb(fp_reg, rf2)
					.divideAndRemainder(BigDecimal.ONE);
			rv1 = fp_get_bd_rnd_int(fp_bfp_class,mf3).intValue(); // RPI-333
			reg.putInt(rf1 + 4, rv1);
			psw_cc = get_int_comp_cc(rv1, 0);
			reset_bfp_alt_mode(); // RPI-1125
			break;
		case 0x99: // 4230 "B399" "CFDBR" "RRF"
			psw_check = false;
			set_bfp_alt_mode_rr(); // RPI-1125
			ins_setup_rrf2();
			fp_bd_int_rem = fp_get_bd_from_db(fp_reg, rf2)
					.divideAndRemainder(BigDecimal.ONE);
			rv1 = fp_get_bd_rnd_int(fp_bfp_class,mf3).intValue(); // RPI-333
			reg.putInt(rf1 + 4, rv1);
			psw_cc = get_int_comp_cc(rv1, 0);
			reset_bfp_alt_mode(); // RPI-1125
			break;
		case 0xA0: // RPI-1125 "B3A0" "CELGBR" "RRF3"
			psw_check = false;
			set_bfp_alt_mode_rr(); // RPI-1125
			ins_setup_rrf3();
			fp_rbdv1 = BigDecimal.valueOf(reg.getLong(rf2));
			if (fp_rbdv1.signum() < 0) {
				fp_rbdv1 = fp_rbdv1.add(bd_max_log_long);
			}
			fp_rbdv1 = fp_rbdv1.round(fp_eb_rnd_context[fp_get_rnd_mode(fp_bfp_class,mf3)]);
			fp_put_bd(rf1, tz390.fp_eb_type, fp_rbdv1);
			fp_store_reg(fp_reg, rf1); // RPI-787
			reset_bfp_alt_mode(); // RPI-1125
			break;
		case 0xA1: // RPI-1125 "B3A1" "CDLGBR" "RRF3"
			psw_check = false;
			set_bfp_alt_mode_rr(); // RPI-1125
			ins_setup_rrf3();
			fp_rbdv1 = BigDecimal.valueOf(reg.getLong(rf2));
			if (fp_rbdv1.signum() < 0) {
				fp_rbdv1 = fp_rbdv1.add(bd_max_log_long);
			}
			fp_rbdv1 = fp_rbdv1.round(fp_db_rnd_context[fp_get_rnd_mode(fp_bfp_class,mf3)]);
			fp_put_bd(rf1, tz390.fp_db_type, fp_rbdv1);
			fp_store_reg(fp_reg, rf1); // RPI-787
			reset_bfp_alt_mode(); // RPI-1125
			break;
		case 0xA2: // RPI-1125 "B3A2" "CXLGBR" "RRF3"
			psw_check = false;
			set_bfp_alt_mode_rr(); // RPI-1125
			ins_setup_rrf3();
			fp_rbdv1 = BigDecimal.valueOf(reg.getLong(rf2));
			if (fp_rbdv1.signum() < 0) {
				fp_rbdv1 = fp_rbdv1.add(bd_max_log_long);
			}
			fp_rbdv1 = fp_rbdv1.round(fp_lb_rnd_context[fp_get_rnd_mode(fp_bfp_class,mf3)]);
			fp_put_bd(rf1, tz390.fp_lb_type, fp_rbdv1);
			fp_store_reg(fp_reg, rf1); // RPI-787
			reset_bfp_alt_mode(); // RPI-1125
			break;
		case 0x9A: // 4240 "B39A" "CFXBR" "RRF"
			psw_check = false;
			set_bfp_alt_mode_rr(); // RPI-1125
			ins_setup_rrf2();
			fp_bd_int_rem = fp_get_bd_from_lb(fp_reg, rf2)
					.divideAndRemainder(BigDecimal.ONE);
			rv1 = fp_get_bd_rnd_int(fp_bfp_class,mf3).intValue(); // RPI-333
			reg.putInt(rf1 + 4, rv1);
			psw_cc = get_int_comp_cc(rv1, 0);
			reset_bfp_alt_mode(); // RPI-1125
			break;
		case 0x9C: // "B39C" "CLFEBR" "RRF" RPI-1125
			psw_check = false;
			set_bfp_alt_mode_rr(); // RPI-1125
			ins_setup_rrf3();
			fp_bd_int_rem = fp_get_bd_from_eb(fp_reg, rf2)
					.divideAndRemainder(BigDecimal.ONE);
			fp_rbdv1 = fp_get_bd_rnd_int(fp_bfp_class,mf3); // RPI-1125
			reg.putInt(rf1 + 4, fp_rbdv1.abs().intValue());
			psw_cc = get_int_comp_cc(fp_rbdv1.signum(), 0);
			reset_bfp_alt_mode(); // RPI-1125
			break;
		case 0x9D: // "B39D" "CLFDBR" "RRF" RPI-1125
			psw_check = false;
			set_bfp_alt_mode_rr(); // RPI-1125
			ins_setup_rrf2();
			fp_bd_int_rem = fp_get_bd_from_db(fp_reg, rf2)
					.divideAndRemainder(BigDecimal.ONE);
			fp_rbdv1 = fp_get_bd_rnd_int(fp_bfp_class,mf3); // RPI-1125
			reg.putInt(rf1 + 4, fp_rbdv1.abs().intValue());
			psw_cc = get_int_comp_cc(fp_rbdv1.signum(), 0);
			reset_bfp_alt_mode(); // RPI-1125
			break;
		case 0x9E: // "B39E" "CLFXBR" "RRF" RPI-1125
			psw_check = false;
			set_bfp_alt_mode_rr(); // RPI-1125
			ins_setup_rrf2();
			fp_bd_int_rem = fp_get_bd_from_lb(fp_reg, rf2)
					.divideAndRemainder(BigDecimal.ONE);
			fp_rbdv1 = fp_get_bd_rnd_int(fp_bfp_class,mf3); // RPI-1125
			reg.putInt(rf1 + 4, fp_rbdv1.abs().intValue());
			psw_cc = get_int_comp_cc(fp_rbdv1.signum(), 0);
			reset_bfp_alt_mode(); // RPI-1125
			break;
		case 0xA4: // 4250 "B3A4" "CEGBR" "RRE"
			psw_check = false;
			set_bfp_alt_mode_rr(); // RPI-1125
			ins_setup_rre();
			fp_put_eb(rf1, tz390.fp_eb_type, (float) reg.getLong(rf2));
			reset_bfp_alt_mode(); // RPI-1125
			break;
		case 0xA5: // 4260 "B3A5" "CDGBR" "RRE"
			psw_check = false;
			set_bfp_alt_mode_rr(); // RPI-1125
			ins_setup_rre();
			fp_put_db(rf1, tz390.fp_db_type, (double) reg.getLong(rf2));
			reset_bfp_alt_mode(); // RPI-1125
			break;
		case 0xA6: // 4270 "B3A6" "CXGBR" "RRE"
			psw_check = false;
			set_bfp_alt_mode_rr(); // RPI-1125
			ins_setup_rre();
			fp_put_bd(rf1, tz390.fp_lb_type, BigDecimal
					.valueOf((double) reg.getLong(rf2)));
			reset_bfp_alt_mode(); // RPI-1125
			break;
		case 0xA8: // 4280 "B3A8" "CGEBR" "RRF"
			psw_check = false;
			set_bfp_alt_mode_rr(); // RPI-1125
			ins_setup_rrf2();
			fp_bd_int_rem = fp_get_bd_from_eb(fp_reg, rf2)
					.divideAndRemainder(BigDecimal.ONE);
			rlv1 = fp_get_bd_rnd_int(fp_bfp_class,mf3).longValue(); // RPI-333
			reg.putLong(rf1, rlv1);
			psw_cc = get_long_comp_cc(rlv1, 0);
			reset_bfp_alt_mode(); // RPI-1125
			break;
		case 0xA9: // 4290 "B3A9" "CGDBR" "RRF"
			psw_check = false;
			set_bfp_alt_mode_rr(); // RPI-1125
			ins_setup_rrf2();
			fp_bd_int_rem = fp_get_bd_from_db(fp_reg, rf2)
					.divideAndRemainder(BigDecimal.ONE);
			rlv1 = fp_get_bd_rnd_int(fp_bfp_class,mf3).longValue(); // RPI-333
			reg.putLong(rf1, rlv1);
			psw_cc = get_long_comp_cc(rlv1, 0);
			reset_bfp_alt_mode(); // RPI-1125
			break;
		case 0xAA: // 4300 "B3AA" "CGXBR" "RRF"
			psw_check = false;
			set_bfp_alt_mode_rr(); // RPI-1125
			ins_setup_rrf2();
			fp_bd_int_rem = fp_get_bd_from_lb(fp_reg, rf2)
					.divideAndRemainder(BigDecimal.ONE);
			rlv1 = fp_get_bd_rnd_int(fp_bfp_class,mf3).longValue(); // RPI-333
			reg.putLong(rf1, rlv1);
			psw_cc = get_long_comp_cc(rlv1, 0);
			reset_bfp_alt_mode(); // RPI-1125
			break;
		case 0xAC: // "B3AC" "CLGEBR" "RRF" RPI-1125
			psw_check = false;
			set_bfp_alt_mode_rr(); // RPI-1125
			ins_setup_rrf3();
			fp_bd_int_rem = fp_get_bd_from_eb(fp_reg, rf2)
					.divideAndRemainder(BigDecimal.ONE);
			fp_rbdv1 = fp_get_bd_rnd_int(fp_bfp_class,mf3); // RPI-1125
			reg.putLong(rf1, fp_rbdv1.abs().longValue());
			psw_cc = get_int_comp_cc(fp_rbdv1.signum(), 0);
			reset_bfp_alt_mode(); // RPI-1125
			break;
		case 0xAD: // "B3AD" "CLGDBR" "RRF" RPI-1125
			psw_check = false;
			set_bfp_alt_mode_rr(); // RPI-1125
			ins_setup_rrf3();
			fp_bd_int_rem = fp_get_bd_from_db(fp_reg, rf2)
					.divideAndRemainder(BigDecimal.ONE);
			fp_rbdv1 = fp_get_bd_rnd_int(fp_bfp_class,mf3); // RPI-1125
			reg.putLong(rf1, fp_rbdv1.abs().longValue());
			psw_cc = get_int_comp_cc(fp_rbdv1.signum(), 0);
			reset_bfp_alt_mode(); // RPI-1125
			break;
		case 0xAE: // "B3AE" "CLGXBR" "RRF" RPI-1125
			psw_check = false;
			set_bfp_alt_mode_rr(); // RPI-1125
			ins_setup_rrf3();
			fp_bd_int_rem = fp_get_bd_from_lb(fp_reg, rf2)
					.divideAndRemainder(BigDecimal.ONE);
			fp_rbdv1 = fp_get_bd_rnd_int(fp_bfp_class,mf3); // RPI-1125
			reg.putLong(rf1, fp_rbdv1.abs().longValue());
			psw_cc = get_int_comp_cc(fp_rbdv1.signum(), 0);
			reset_bfp_alt_mode(); // RPI-1125
			break;
		case 0xB4: // 4310 "B3B4" "CEFR" "RRE"
			psw_check = false;
			ins_setup_rre();
			fp_put_db(rf1, tz390.fp_eh_type, (float) reg.getInt(rf2 + 4));
			break;
		case 0xB5: // 4320 "B3B5" "CDFR" "RRE"
			psw_check = false;
			ins_setup_rre();
			fp_put_bd(rf1, tz390.fp_dh_type,BigDecimal.valueOf(reg.getInt(rf2 + 4)));// RPI-821
			break;
		case 0xB6: // 4330 "B3B6" "CXFR" "RRE"
			psw_check = false;
			ins_setup_rre();
			fp_put_bd(rf1, tz390.fp_lh_type, BigDecimal.valueOf(reg
					.getInt(rf2 + 4)));
			break;
		case 0xB8: // 4340 "B3B8" "CFER" "RRF"
			psw_check = false;
			ins_setup_rrf2();
			fp_bd_int_rem = fp_get_bd_from_eh(fp_reg, rf2)
					.divideAndRemainder(BigDecimal.ONE);
			rv1 = fp_get_bd_rnd_int(fp_bfp_class,mf3).intValue(); // RPI-333
			reg.putInt(rf1 + 4, rv1);
			psw_cc = get_int_comp_cc(rv1, 0);
			break;
		case 0xB9: // 4350 "B3B9" "CFDR" "RRF"
			psw_check = false;
			ins_setup_rrf2();
			fp_bd_int_rem = fp_get_bd_from_dh(fp_reg, rf2)
					.divideAndRemainder(BigDecimal.ONE);
			rv1 = fp_get_bd_rnd_int(fp_bfp_class,mf3).intValue(); // RPI-333
			reg.putInt(rf1 + 4, rv1);
			psw_cc = get_int_comp_cc(rv1, 0);
			break;
		case 0xBA: // 4360 "B3BA" "CFXR" "RRF"
			psw_check = false;
			ins_setup_rrf2();
			fp_bd_int_rem = fp_get_bd_from_lh(fp_reg, rf2)
					.divideAndRemainder(BigDecimal.ONE);
			rv1 = fp_get_bd_rnd_int(fp_bfp_class,mf3).intValue(); // RPI-333
			reg.putInt(rf1 + 4, rv1);
			psw_cc = get_int_comp_cc(rv1, 0);
			break;
		case 0xC1: // 4365 "B3C1" "LDGR" "RRE" 14 DFP
			psw_check = false;
			ins_setup_rre();
			fp_load_reg(rf1, tz390.fp_dd_type, reg, rf2, tz390.fp_dd_type);
			break;
		case 0xC4: // 4370 "B3C4" "CEGR" "RRE"
			psw_check = false;
			ins_setup_rre();
			fp_put_db(rf1, tz390.fp_eh_type, (float) reg.getLong(rf2));
			break;
		case 0xC5: // 4380 "B3C5" "CDGR" "RRE"
			psw_check = false;
			ins_setup_rre();
			fp_put_bd(rf1, tz390.fp_dh_type,BigDecimal.valueOf(reg.getLong(rf2)));
			break;
		case 0xC6: // 4390 "B3C6" "CXGR" "RRE"
			psw_check = false;
			ins_setup_rre();
			fp_put_bd(rf1, tz390.fp_lh_type, BigDecimal.valueOf(reg.getLong(rf2))); // RPI-821
			break;
		case 0xC8: // 4400 "B3C8" "CGER" "RRF"
			psw_check = false;
			ins_setup_rrf2();
			fp_bd_int_rem = fp_get_bd_from_eh(fp_reg, rf2)
					.divideAndRemainder(BigDecimal.ONE);
			rlv1 = fp_get_bd_rnd_int(fp_bfp_class,mf3).longValue(); // RPI-333
			reg.putLong(rf1, rlv1);
			psw_cc = get_long_comp_cc(rlv1, 0);
			break;
		case 0xC9: // 4410 "B3C9" "CGDR" "RRF"
			psw_check = false;
			ins_setup_rrf2();
			fp_bd_int_rem = fp_get_bd_from_dh(fp_reg, rf2)
					.divideAndRemainder(BigDecimal.ONE);
			rlv1 = fp_get_bd_rnd_int(fp_bfp_class,mf3).longValue(); // RPI-333
			reg.putLong(rf1, rlv1);
			psw_cc = get_long_comp_cc(rlv1, 0);
			break;
		case 0xCA: // 4420 "B3CA" "CGXR" "RRF"
			psw_check = false;
			ins_setup_rrf2();
			fp_bd_int_rem = fp_get_bd_from_lh(fp_reg, rf2)
					.divideAndRemainder(BigDecimal.ONE);
			rlv1 = fp_get_bd_rnd_int(fp_bfp_class,mf3).longValue(); // RPI-333
			reg.putLong(rf1, rlv1);
			psw_cc = get_long_comp_cc(rlv1, 0);
			break;
		case 0xCD: // 4425 "B3CD" "LGDR" "RRE" 14 DFP
			psw_check = false;
			ins_setup_rre();
			if (fp_reg_ctl[mf2] != fp_ctl_ld) {
				fp_store_reg(fp_reg, rf2);
			}
			reg.putLong(rf1,fp_reg.getLong(rf2));
			break;
		case 0xD0: // "MDTR" "B3D0" "RRR" DFP 1
			psw_check = false;
			set_dfp_alt_mode_rrr(); // RPI-1125
			ins_setup_rrr();
			fp_rbdv1 = fp_get_bd_from_dd(fp_reg, rf2)
					.multiply(fp_get_bd_from_dd(fp_reg, rf3),fp_dd_rnd_context[fp_dfp_rnd]); // RPI-517
			fp_put_bd(rf1, tz390.fp_dd_type, fp_rbdv1);
			check_dd_mpy(); // RPI-820
			reset_dfp_alt_mode(); // RPI-1125
			break;
		case 0xD1: // "DDTR" "B3D1" "RRR" DFP 2
			psw_check = false;
			set_dfp_alt_mode_rrr(); // RPI-1125
			ins_setup_rrr();
			fp_rbdv3 = fp_get_bd_from_dd(fp_reg, rf3);
			if (fp_rbdv3.signum() != 0) {  // RPI-820
				fp_rbdv1 = fp_get_bd_from_dd(fp_reg, rf2)
				.divide(fp_rbdv3,fp_dd_rnd_context[fp_dfp_rnd]); // RPI-517
			} else {
				fp_rbdv1 = BigDecimal.ZERO; // RPI-824
			}
			fp_put_bd(rf1, tz390.fp_dd_type, fp_rbdv1);
			check_dd_div(); // RPI-820
			reset_dfp_alt_mode(); // RPI-1125
			break;
		case 0xD2: // "ADTR" "B3D2" "RRR" DFP 3
			psw_check = false;
			set_dfp_alt_mode_rrr(); // RPI-1125
			ins_setup_rrr();
			fp_rbdv1 = fp_get_bd_from_dd(fp_reg, rf2)
					.add(fp_get_bd_from_dd(fp_reg, rf3),fp_dd_rnd_context[fp_dfp_rnd]); // RPI-517
			fp_put_bd(rf1, tz390.fp_dd_type, fp_rbdv1);
			psw_cc = fp_get_dfp_add_sub_cc();
			reset_dfp_alt_mode(); // RPI-1125
			break;
		case 0xD3: // "SDTR" "B3D3" "RRR" DFP 4
			psw_check = false;
			set_dfp_alt_mode_rrr(); // RPI-1125
			ins_setup_rrr();
			fp_rbdv1 = fp_get_bd_from_dd(fp_reg, rf2)
					.subtract(fp_get_bd_from_dd(fp_reg, rf3),fp_dd_rnd_context[fp_dfp_rnd]); // RPI-517
			fp_put_bd(rf1, tz390.fp_dd_type, fp_rbdv1);
			psw_cc = fp_get_dfp_add_sub_cc();
			reset_dfp_alt_mode(); // RPI-1125
			break;
		case 0xD4: // "LDETR" "B3D4" "RRF4" DFP 5
			psw_check = false;
			ins_setup_rrf4();
			fp_rbdv1 = fp_get_bd_from_ed(fp_reg, rf2);
			fp_put_bd(rf1, tz390.fp_dd_type, fp_rbdv1);
			fp_store_reg(fp_reg, rf1); // RPI-787
			break;
		case 0xD5: // "LEDTR" "B3D5" "RRF4" DFP 6
			psw_check = false;
			ins_setup_rrf3();
			fp_rbdv1 = fp_get_bd_from_dd(fp_reg,rf2)
					.round(fp_ed_rnd_context[fp_get_rnd_mode(fp_dfp_class,mf3)]);
			fp_put_bd(rf1, tz390.fp_ed_type, fp_rbdv1);
			fp_store_reg(fp_reg, rf1); // RPI-787
			break;
		case 0xD6: // "LTDTR" "B3D6" "RRE" DFP 7
			psw_check = false;
			ins_setup_rre();
			fp_rbdv1 = fp_get_bd_from_dd(fp_reg, rf2);
			fp_put_bd(rf1, tz390.fp_dd_type, fp_rbdv1);
			psw_cc = fp_get_dd_comp_cc(fp_rbdv1,BigDecimal.ZERO);
			break;
		case 0xD7: // "FIDTR" "B3D7" "RRF3" DFP 8
			psw_check = false;
			ins_setup_rrf3();
			fp_rbdv2 = fp_get_bd_from_dd(fp_reg, rf2);
			if (fp_rbdv2.scale() <= 0) {
				fp_put_bd(rf1, tz390.fp_dd_type, fp_rbdv2);
			} else {
				fp_bd_int_rem = fp_rbdv2
				.divideAndRemainder(BigDecimal.ONE);
				fp_rbdv1 = fp_get_bd_rnd_int(fp_dfp_class,mf3);
				fp_put_bd(rf1, tz390.fp_dd_type, fp_rbdv1);
				if ((mf4 & 0x2) == 1) {
					check_bd12_exact();
				}
			}
			break;
		case 0xD8: // "MXTR" "B3D8" "RRR" DFP 9
			psw_check = false;
			set_dfp_alt_mode_rrr(); // RPI-1125
			ins_setup_rrr();
			fp_rbdv1 = fp_get_bd_from_ld(fp_reg, rf2)
					.multiply(fp_get_bd_from_ld(fp_reg, rf3),fp_ld_rnd_context[fp_dfp_rnd]);  // RPI-517
			fp_put_bd(rf1, tz390.fp_ld_type, fp_rbdv1);
			check_ld_mpy(); // RPI-820
			reset_dfp_alt_mode(); // RPI-1125
			break;
		case 0xD9: // "DXTR" "B3D9" "RRR" DFP 10
			psw_check = false;
			set_dfp_alt_mode_rrr(); // RPI-1125
			ins_setup_rrr();
			fp_rbdv2 = fp_get_bd_from_ld(fp_reg, rf2); // RPI-1214
			fp_rbdv3 = fp_get_bd_from_ld(fp_reg, rf3);
			if (fp_rbdv3.signum() != 0) {
				fp_rbdv1 = fp_rbdv2                    // RPI-214
				.divide(fp_rbdv3,fp_ld_rnd_context[fp_dfp_rnd]);  // RPI-517
			} else {
				fp_rbdv1 = BigDecimal.ZERO; // RPI-824
			}
			fp_put_bd(rf1, tz390.fp_ld_type, fp_rbdv1);
			check_ld_div(); // RPI-820
			reset_dfp_alt_mode(); // RPI-1125
			break;
		case 0xDA: // "AXTR" "B3DA" "RRR" DFP 11
			psw_check = false;
			set_dfp_alt_mode_rrr(); // RPI-1125
			ins_setup_rrr();
			fp_rbdv1 = fp_get_bd_from_ld(fp_reg, rf2)
					.add(fp_get_bd_from_ld(fp_reg, rf3),fp_ld_rnd_context[fp_dfp_rnd]); // RPI-517
			fp_put_bd(rf1, tz390.fp_ld_type, fp_rbdv1);
			psw_cc = fp_get_dfp_add_sub_cc();
			reset_dfp_alt_mode(); // RPI-1125
			break;
		case 0xDB: // "SXTR" "B3DB" "RRR" DFP 12
			psw_check = false;
			set_dfp_alt_mode_rrr(); // RPI-1125
			ins_setup_rrr();
			fp_rbdv1 = fp_get_bd_from_ld(fp_reg, rf2)
					.subtract(fp_get_bd_from_ld(fp_reg, rf3),fp_ld_rnd_context[fp_dfp_rnd]); // RPI-517
			fp_put_bd(rf1, tz390.fp_ld_type, fp_rbdv1);
			psw_cc = fp_get_dfp_add_sub_cc();
			reset_dfp_alt_mode(); // RPI-1125
			break;
		case 0xDC: // "LXDTR" "B3DC" "RRF4" DFP 13
			psw_check = false;
			ins_setup_rrf4();
			fp_rbdv1 = fp_get_bd_from_dd(fp_reg, rf2);
			fp_put_bd(rf1, tz390.fp_ld_type, fp_rbdv1);
			fp_store_reg(fp_reg, rf1); // RPI-787
			break;
		case 0xDD: // "LDXTR" "B3DD" "RRF4" DFP 14
			psw_check = false;
			ins_setup_rrf3();
			fp_rbdv1 = fp_get_bd_from_ld(fp_reg,rf2)
					.round(fp_dd_rnd_context[fp_get_rnd_mode(fp_dfp_class,mf3)]);
			fp_put_bd(rf1, tz390.fp_dd_type, fp_rbdv1);
			fp_store_reg(fp_reg, rf1); // RPI-787
			break;
		case 0xDE: // "LTXTR" "B3DE" "RRE" DFP 15
			psw_check = false;
			ins_setup_rre();
			fp_rbdv1 = fp_get_bd_from_ld(fp_reg, rf2);
			fp_put_bd(rf1, tz390.fp_ld_type, fp_rbdv1);
			psw_cc = fp_get_ld_comp_cc(fp_rbdv1,BigDecimal.ZERO);
			break;
		case 0xDF: // "FIXTR" "B3DF" "RRF4" DFP 16
			psw_check = false;
			ins_setup_rrf4();
			fp_rbdv2 = fp_get_bd_from_ld(fp_reg, rf2);
			if (fp_rbdv2.scale() <= 0) {
				fp_put_bd(rf1, tz390.fp_ld_type, fp_rbdv2);
			} else {
				fp_bd_int_rem = fp_rbdv2
				.divideAndRemainder(BigDecimal.ONE);
				fp_rbdv1 = fp_get_bd_rnd_int(fp_dfp_class,mf3);
				fp_put_bd(rf1, tz390.fp_ld_type, fp_rbdv1);
				if ((mf4 & 0x2) == 1
					&& fp_rbdv1.compareTo(fp_rbdv2) != 0) {
					fp_dxc = fp_dxc_it; // raise inexact
					set_psw_check(Constants.psw_pic_data);
				}
			}
			break;
		case 0xE0: // "KDTR" "B3E0" "RRE" DFP 17
			psw_check = false;
			ins_setup_rre();
			fp_signal = true;
			psw_cc = fp_get_dd_comp_cc(
				fp_get_bd_from_dd(fp_reg, rf1),
				fp_get_bd_from_dd(fp_reg, rf2));
			break;
		case 0xE1: // "CGDTR" "B3E1" "RRF2" DFP 18
			psw_check = false;
			set_dfp_alt_mode_rr(); // RPI-1125 RPI-1158
			ins_setup_rrf2();
			fp_bd_int_rem = fp_get_bd_from_dd(fp_reg, rf2)
					.divideAndRemainder(BigDecimal.ONE);
			if (fp_bd_int_rem[0].compareTo(bd_max_pos_long) != 1
			 && fp_bd_int_rem[0].compareTo(bd_min_neg_long) != -1) { // RPI-791
				big_int1 = fp_get_bd_rnd_int(fp_dfp_class,mf3)
						.toBigInteger();	// RPI-527
				rlv1 = big_int1.longValue(); // RPI-540
				reg.putLong(rf1, rlv1);
				psw_cc = get_long_comp_cc(rlv1,0);
			} else {
				psw_cc = psw_cc3;
			}
			reset_dfp_alt_mode(); // RPI-1125 RPI-1158
			break;
		case 0xE2: // "CUDTR" "B3E2" "RRE" DFP 19
			psw_check = false;
			ins_setup_rre();
			pdf_big_int = fp_get_bd_from_dd(fp_reg, rf2).unscaledValue();
			pdf_is_big = true;
			pdf_signed = false;
			pdf_trunc = true; // RPI-788
			put_pd(reg_byte, rf1, 8);
			pdf_trunc = false; // RPI-788
			break;
		case 0xE3: // "CSDTR" "B3E3" "RRF4" DFP 20
			psw_check = false;
			ins_setup_rrf4();
			pdf_big_int = fp_get_bd_from_dd(fp_reg, rf2).unscaledValue();
			pdf_is_big = true;
			pdf_trunc = true; // RPI-788
			put_pd(reg_byte, rf1, 8);
			pdf_trunc = false; // RPI-788
			if (mf4 == 1 && pdf_big_int.signum() >= 0) {
				reg.put(rf1 + 7, (byte) (reg.get(rf1 + 7) | 0xf));
			}
			break;
		case 0xE4: // "CDTR" "B3E4" "RRE" DFP 21
			psw_check = false;
			ins_setup_rre();
			fp_signal = false;
			psw_cc = fp_get_dd_comp_cc(
				fp_get_bd_from_dd(fp_reg, rf1),
				fp_get_bd_from_dd(fp_reg, rf2));
			break;
		case 0xE5: // "EEDTR" "B3E5" "RRE" DFP 22
			psw_check = false;
			ins_setup_rre();
			fp_rbdv1 = fp_get_bd_from_dd(fp_reg, rf2);
			reg.putLong(rf1,tz390.fp_exp_bias[tz390.fp_dd_type] - fp_rbdv1.scale());
			break;
		case 0xE7: // "ESDTR" "B3E7" "RRE" DFP 23
			psw_check = false;
			ins_setup_rre();
			tz390.dfp_digits = fp_get_bd_from_dd(fp_reg, rf2)
					.unscaledValue()
					.abs()
					.toString();
			rv1 = tz390.dfp_digits.length(); // RPI-787
			if (rv1 == 1 && tz390.dfp_digits.charAt(0) == '0') {
				rv1 = 0;
			}
			reg.putLong(rf1,rv1);
			break;
		case 0xE8: // "KXTR" "B3E8" "RRE" DFP 24
			psw_check = false;
			ins_setup_rre();
			fp_signal = true;
			psw_cc = fp_get_ld_comp_cc(
				fp_get_bd_from_ld(fp_reg, rf1),
				fp_get_bd_from_ld(fp_reg, rf2));
			break;
		case 0xE9: // "CGXTR" "B3E9" "RRF4" DFP 25
			psw_check = false;
			set_dfp_alt_mode_rr(); // RPI-1125 RPI-1158
			ins_setup_rrf2();
			fp_bd_int_rem = fp_get_bd_from_ld(fp_reg, rf2)
					.divideAndRemainder(BigDecimal.ONE);
			if (fp_bd_int_rem[0].compareTo(bd_max_pos_long) != 1
			 && fp_bd_int_rem[0].compareTo(bd_min_neg_long) != -1) { // RPI-791
				big_int1 = fp_get_bd_rnd_int(fp_dfp_class,mf3)
						.toBigInteger();	// RPI-527
				rlv1 = big_int1.longValue(); // RPI-540
				reg.putLong(rf1, rlv1);
				psw_cc = get_long_comp_cc(rlv1,0);
			} else {
				psw_cc = psw_cc3;
			}
			reset_dfp_alt_mode();  // RPI-1125 RPI-1158
			break;
		case 0xEA: // "CUXTR" "B3EA" "RRE" DFP 26
			psw_check = false;
			ins_setup_rre();
			pdf_big_int = fp_get_bd_from_ld(fp_reg, rf2).unscaledValue();
			pdf_is_big = true;
			pdf_signed = false;
			pdf_trunc = true; // RPI-788
			put_pd(reg_byte, rf1,16);
			pdf_trunc = false; // RPI-788
			break;
		case 0xEB: // "CSXTR" "B3EB" "RRF4" DFP 27
			psw_check = false;
			ins_setup_rrf4();
			pdf_big_int = fp_get_bd_from_ld(fp_reg, rf2).unscaledValue();
			pdf_is_big = true;
			pdf_trunc = true; // RPI-788
			put_pd(reg_byte, rf1,16);
			pdf_trunc = false; // RPI-788
			if (mf4 == 1 && pdf_big_int.signum() >= 0) {
				reg.put(rf1 + 15, (byte) (reg.get(rf1 + 15) | 0xf));
			}
			break;
		case 0xEC: // "CXTR" "B3EC" "RRE" DFP 28
			psw_check = false;
			ins_setup_rre();
			fp_signal = false;
			psw_cc = fp_get_ld_comp_cc(
				fp_get_bd_from_ld(fp_reg, rf1),
				fp_get_bd_from_ld(fp_reg, rf2));
			break;
		case 0xED: // "EEXTR" "B3ED" "RRE" DFP 29
			psw_check = false;
			ins_setup_rre();
			fp_rbdv1 = fp_get_bd_from_ld(fp_reg, rf2);
			reg.putLong(rf1,tz390.fp_exp_bias[tz390.fp_ld_type] - fp_rbdv1.scale());
			break;
		case 0xEF: // "ESXTR" "B3EF" "RRE" DFP 30
			psw_check = false;
			ins_setup_rre();
			tz390.dfp_digits = fp_get_bd_from_ld(fp_reg, rf2)
					.unscaledValue()
					.abs()
					.toString();
			rv1 = tz390.dfp_digits.length(); // RPI-787
			if (rv1 == 1 && tz390.dfp_digits.charAt(0) == '0') {
				rv1 = 0;
			}
			reg.putLong(rf1,rv1);
			break;
		case 0xF1: // "CDGTR" "B3F1" "RRE" DFP 31
			psw_check = false;
			set_dfp_alt_mode_rr(); // RPI-1125 RPI-1158
			ins_setup_rre();
			fp_rbdv2 = BigDecimal.valueOf(reg.getLong(rf2));
			fp_rbdv1 = fp_rbdv2.round(fp_dd_rnd_context[fp_dfp_rnd]);
			if (fp_rbdv1.compareTo(fp_rbdv2) != 0) {
				fp_dxc = fp_dxc_it;
				set_psw_check(Constants.psw_pic_data);
			}
			fp_put_bd(rf1, tz390.fp_dd_type, fp_rbdv1);
			reset_dfp_alt_mode(); // RPI-1125 RPI-1158
			break;
		case 0xF2: // "CDUTR" "B3F2" "RRE" DFP 32
			psw_check = false;
			ins_setup_rre();
			pdf_signed = false;
			if (get_pd(reg,rf2,8)) {
				if (pdf_is_big) {
					fp_put_bd(rf1,tz390.fp_dd_type,new BigDecimal(pdf_big_int));
				} else {
					fp_put_bd(rf1,tz390.fp_dd_type,BigDecimal.valueOf(pdf_long));
				}
			}
			break;
		case 0xF3: // "CDSTR" "B3F3" "RRE" DFP 33
			psw_check = false;
			ins_setup_rre();
			if (get_pd(reg,rf2,8)) {
				if (pdf_is_big) {
					fp_put_bd(rf1,tz390.fp_dd_type,new BigDecimal(pdf_big_int));
				} else {
					fp_put_bd(rf1,tz390.fp_dd_type,BigDecimal.valueOf(pdf_long));
				}
			}
			break;
		case 0xF4: // "CEDTR" "B3F4" "RRE" DFP 34
			psw_check = false;
			ins_setup_rre();
			psw_cc = get_int_comp_cc(
					-fp_get_bd_from_dd(fp_reg, rf1).scale(),
					-fp_get_bd_from_dd(fp_reg, rf2).scale());
			break;
		case 0xF5: // "QADTR" "B3F5" "RRF3" DFP 35
			psw_check = false;
			ins_setup_rrf3();
			fp_rbdv1 = fp_get_bd_from_dd(fp_reg,rf3);
			fp_rbdv2 = fp_get_bd_from_dd(fp_reg,rf2);
			if (fp_rbdv1.scale() != fp_rbdv2.scale()) {
				fp_rbdv1 = fp_rbdv1.setScale(fp_rbdv2.scale(), fp_get_rnd_mode(fp_dfp_class,mf4));
			} else {
				fp_rbdv1 = fp_rbdv1.round(fp_dd_rnd_context[fp_get_rnd_mode(fp_dfp_class,mf4)]);
			}
			check_bd12_exact();
			fp_put_bd(rf1, tz390.fp_dd_type, fp_rbdv1);
			break;
		case 0xF6: // "IEDTR" "B3F6" "RRF2" DFP 36
			psw_check = false;
			ins_setup_rrf2();
			fp_rbdv1 = new BigDecimal(fp_get_bd_from_dd(fp_reg, rf3)
							.round(fp_dd_rnd_context[fp_dfp_rnd])  // RPI-527
							.unscaledValue())
							.scaleByPowerOfTen((int)(reg.getLong(rf2)
									- tz390.fp_exp_bias[tz390.fp_dd_type]
							));
			if (fp_get_bd_from_dd(fp_reg,rf3).signum() >= 0) { // RPI-527
				fp_put_bd(rf1,tz390.fp_dd_type,fp_rbdv1.abs());
			} else {
				fp_put_bd(rf1,tz390.fp_dd_type,fp_rbdv1.abs().negate());
			}
			fp_store_reg(fp_reg, rf1); // RPI-787
			break;
		case 0xF7: // "RRDTR" "B3F7" "RRF3" DFP 37
			psw_check = false;
			ins_setup_rrf3();
			fp_rbdv1 = fp_get_bd_from_dd(fp_reg,rf3);
			fp_sig_req = reg.get(rf2+7) & 0x3f;
			if (fp_sig_req > 0) {
				fp_sig_dig = fp_rbdv1.unscaledValue().abs().toString().length();
				if (fp_sig_dig > fp_sig_req) {
					fp_rbdv1 = fp_rbdv1.round(new MathContext(fp_sig_req,fp_dfp_rnd_mode[fp_get_rnd_mode(fp_dfp_class,mf4)]));
				}
			}
			fp_put_bd(rf1, tz390.fp_dd_type, fp_rbdv1);
			break;
		case 0xF9: // "CXGTR" "B3F9" "RRE" DFP 38
			psw_check = false;
			set_dfp_alt_mode_rr(); // RPI-1125 RPI-1158
			ins_setup_rre();
			fp_rbdv1 = BigDecimal.valueOf(reg.getLong(rf2));
			fp_put_bd(rf1, tz390.fp_ld_type, fp_rbdv1); // RPI-1015 was DD vs LD
			reset_dfp_alt_mode(); // RPI-1125
			break;
		case 0xFA: // "CXUTR" "B3FA" "RRE" DFP 39
			psw_check = false;
			ins_setup_rre();
			if ((rf2 & 0x8) != 0) {
				set_psw_check(Constants.psw_pic_spec);
			}
			pdf_signed = false;
			if (get_pd(reg,rf2,16)) {
				if (pdf_is_big) {
					fp_put_bd(rf1,tz390.fp_ld_type,new BigDecimal(pdf_big_int));
				} else {
					fp_put_bd(rf1,tz390.fp_ld_type,BigDecimal.valueOf(pdf_long));
				}
			}
			break;
		case 0xFB: // "CXSTR" "B3FB" "RRE" DFP 40
			psw_check = false;
			ins_setup_rre();
			if ((rf2 & 0x8) != 0) {
				set_psw_check(Constants.psw_pic_spec);
			}
			if (get_pd(reg,rf2,16)) {
				if (pdf_is_big) {
					fp_put_bd(rf1,tz390.fp_ld_type,new BigDecimal(pdf_big_int));
				} else {
					fp_put_bd(rf1,tz390.fp_ld_type,BigDecimal.valueOf(pdf_long));
				}
			}
			break;
		case 0xFC: // "CEXTR" "B3FC" "RRE" DFP 41
			psw_check = false;
			ins_setup_rre();
			psw_cc = get_int_comp_cc(
					-fp_get_bd_from_ld(fp_reg, rf1).scale(),
					-fp_get_bd_from_ld(fp_reg, rf2).scale());
			break;
		case 0xFD: // "QAXTR" "B3FD" "RRF3" DFP 42
			psw_check = false;
			ins_setup_rrf3();
			fp_rbdv1 = fp_get_bd_from_ld(fp_reg,rf3);
			fp_rbdv2 = fp_get_bd_from_ld(fp_reg,rf2);
			if (fp_rbdv1.scale() != fp_rbdv2.scale()) {
				fp_rbdv1 = fp_rbdv1.setScale( fp_rbdv2.scale(), fp_get_rnd_mode(fp_dfp_class,mf4) );
			} else {
				fp_rbdv1 = fp_rbdv1.round(fp_dd_rnd_context[fp_get_rnd_mode(fp_dfp_class,mf4)]);
			}
			check_bd12_exact();
			fp_put_bd(rf1, tz390.fp_ld_type, fp_rbdv1);
			break;
		case 0xFE: // "IEXTR" "B3FE" "RRF2" DFP 43
			psw_check = false;
			ins_setup_rrf2();
			if (!fp_pair_valid[mf3]
			 || !fp_pair_valid[mf1]) { // RPI-842
				set_psw_check(Constants.psw_pic_spec);
			}
			fp_rbdv1 = new BigDecimal(fp_get_bd_from_ld(fp_reg, rf3)
					.round(fp_ld_rnd_context[fp_dfp_rnd])  // RPI-527
					.unscaledValue())
					.scaleByPowerOfTen((int)(reg.getLong(rf2)
						- tz390.fp_exp_bias[tz390.fp_ld_type]
					));
			if (fp_get_bd_from_ld(fp_reg,rf3).signum() >= 0) { /// RPI-527
				fp_put_bd(rf1,tz390.fp_ld_type,fp_rbdv1.abs());
			} else {
				fp_put_bd(rf1,tz390.fp_ld_type,fp_rbdv1.abs().negate());
			}
			fp_store_reg(fp_reg, rf1); // RPI-787
			break;
		case 0xFF: // "RRXTR" "B3FF" "RRF3" DFP 44
			psw_check = false;
			ins_setup_rrf3();
			if (!fp_pair_valid[mf3]
			 || !fp_pair_valid[mf1]) { // RPI-842
				set_psw_check(Constants.psw_pic_spec);
			}
			fp_rbdv1 = fp_get_bd_from_ld(fp_reg,rf3);
			fp_sig_req = reg.get(rf2+7) & 0x3f;
			if (fp_sig_req > 0) {
				fp_sig_dig = fp_rbdv1.unscaledValue().abs().toString().length();
				if (fp_sig_dig > fp_sig_req) {
					fp_rbdv1 = fp_rbdv1.round(new MathContext(fp_sig_req,fp_dfp_rnd_mode[fp_get_rnd_mode(fp_dfp_class,mf4)]));
				}
			}
			fp_put_bd(rf1, tz390.fp_ld_type, fp_rbdv1); // RPI-842 was fp_dd_type in error
			break;
		}
	}

	/**
	 *
	 */
	private void ins_B9XX()
	{
		opcode2 = mem_byte[psw_loc + opcode2_offset_rre] & 0xff;
		switch (opcode2) {
		case 0x00: // 4450 "B900" "LPGR" "RRE"
			psw_check = false;
			ins_setup_rre();
			rlv1 = reg.getLong(rf2);
			if (rlv1 < 0) {
				if (rlv1 == long_high_bit) {
					psw_cc = psw_cc3;
					break;
				}
				rlv1 = -rlv1;
			}
			reg.putLong(rf1, rlv1);
			psw_cc = get_long_comp_cc(rlv1, 0);
			break;
		case 0x01: // 4460 "B901" "LNGR" "RRE"
			psw_check = false;
			ins_setup_rre();
			rlv1 = reg.getLong(rf2);
			if (rlv1 > 0) {
				rlv1 = -rlv1;
			}
			reg.putLong(rf1, rlv1);
			psw_cc = get_long_comp_cc(rlv1, 0);
			break;
		case 0x02: // 4470 "B902" "LTGR" "RRE"
			psw_check = false;
			ins_setup_rre();
			rlv1 = reg.getLong(rf2);
			psw_cc = get_long_comp_cc(rlv1, 0);
			break;
		case 0x03: // 4480 "B903" "LCGR" "RRE"
			psw_check = false;
			ins_setup_rre();
			rlv1 = reg.getLong(rf2);
			if (rlv1 == long_high_bit) {
				psw_cc = psw_cc3;
				break;
			}
			rlv1 = -rlv1;
			reg.putLong(rf1, rlv1);
			psw_cc = get_long_comp_cc(rlv1, 0);
			break;
		case 0x04: // 4490 "B904" "LGR" "RRE"
			psw_check = false;
			ins_setup_rre();
			reg.putLong(rf1, reg.getLong(rf2));
			break;
		case 0x05: // 4500 "B905" "LURAG" "RRE"
			ins_setup_rre();
			break;
		case 0x06: // 4600 "B906" "LGBR" "RRE" Z9-10
			psw_check = false;
			ins_setup_rre();
			reg.putLong(rf1, reg.get(rf2 + 7));
			break;
		case 0x07: // 4610 "B907" "LGHR" "RRE" Z9-11
			psw_check = false;
			ins_setup_rre();
			reg.putLong(rf1, reg.getShort(rf2 + 6));
			break;
		case 0x08: // 4510 "B908" "AGR" "RRE"
			psw_check = false;
			ins_setup_rre();
			rlv1 = reg.getLong(rf1);
			rlv2 = reg.getLong(rf2);
			rlv3 = rlv1 + rlv2;
			reg.putLong(rf1, rlv3);
			psw_cc = get_long_add_cc();
			break;
		case 0x09: // 4520 "B909" "SGR" "RRE"
			psw_check = false;
			ins_setup_rre();
			rlv1 = reg.getLong(rf1);
			rlv2 = reg.getLong(rf2);
			rlv3 = rlv1 - rlv2;
			reg.putLong(rf1, rlv3);
			psw_cc = get_long_sub_cc();
			break;
		case 0x0A: // 4530 "B90A" "ALGR" "RRE"
			psw_check = false;
			ins_setup_rre();
			rlvw = reg.getLong(rf1);
			rlv2 = reg.getLong(rf2);
			rlv1 = rlvw + rlv2;
			reg.putLong(rf1, rlv1);
			psw_cc = get_long_log_add_cc();
			break;
		case 0x0B: // 4540 "B90B" "SLGR" "RRE"
			psw_check = false;
			ins_setup_rre();
			rlvw = reg.getLong(rf1);
			rlv2 = reg.getLong(rf2);
			rlv1 = rlvw - rlv2;
			reg.putLong(rf1, rlv1);
			psw_cc = get_long_log_sub_cc();
			break;
		case 0x0C: // 4550 "B90C" "MSGR" "RRE"
			psw_check = false;
			ins_setup_rre();
			reg.putLong(rf1, reg.getLong(rf1) * reg.getLong(rf2));
			break;
		case 0x0D: // 4560 "B90D" "DSGR" "RRE"
			psw_check = false;
			ins_setup_rre();
			if ((mf1 & 1) != 0) { // RPI-758
				set_psw_check(Constants.psw_pic_spec);
			}
			rlv1 = reg.getLong(rf1 + 8);
			rlv2 = reg.getLong(rf2);
			if (rlv2 != 0) {
				rlvw = rlv1 / rlv2;
			} else {
				set_psw_check(Constants.psw_pic_fx_div);
				break;
			}
			rlv1 = rlv1 - rlvw * rlv2;
			reg.putLong(rf1, rlv1);
			reg.putLong(rf1 + 8, rlvw);
			break;
		case 0x0E: // 4570 "B90E" "EREGG" "RRE"
			psw_check = false;
			ins_setup_rre();
			if (cur_pc_stk_reg <= 0) {
				set_psw_check(Constants.psw_pic_stkerr);
				return;
			}
			final int pc_stk_reg_base = cur_pc_stk_reg - reg_len;
			if (rf1 > rf3) {
				while (rf1 < reg_len) {
					reg.putLong(rf1, pc_stk_reg.getLong(pc_stk_reg_base + rf1));
					rf1 = rf1 + 8;
				}
				rf1 = 0;
			}
			while (rf1 <= rf3) {
				reg.putLong(rf1, pc_stk_reg.getLong(pc_stk_reg_base + rf1));
				rf1 = rf1 + 8;
			}
			break;
		case 0x0F: // 4580 "B90F" "LRVGR" "RRE"
			psw_check = false;
			ins_setup_rre();
			work_reg.putLong(0, reg.getLong(rf2)); // RPI-1200
			rflen = 7;
			while (rflen >= 0) {
				reg.put(rf1 + rflen, work_reg.get(7 - rflen)); // RPI-1200
				rflen--;
			}
			break;
		case 0x10: // 4590 "B910" "LPGFR" "RRE"
			psw_check = false;
			ins_setup_rre();
			rlv1 = reg.getInt(rf2 + 4);
			if (rlv1 < 0) {
				rlv1 = -rlv1;
			}
			reg.putLong(rf1, rlv1);
			psw_cc = get_long_comp_cc(rlv1, 0);
			break;
		case 0x11: // 4600 "B911" "LNGFR" "RRE"
			psw_check = false;
			ins_setup_rre();
			rlv1 = reg.getInt(rf2 + 4);
			if (rlv1 >= 0) {
				rlv1 = -rlv1;
			}
			reg.putLong(rf1, rlv1);
			psw_cc = get_long_comp_cc(rlv1, 0);
			break;
		case 0x12: // 4610 "B912" "LTGFR" "RRE"
			psw_check = false;
			ins_setup_rre();
			rlv1 = reg.getInt(rf2 + 4);
			reg.putLong(rf1, rlv1);
			psw_cc = get_long_comp_cc(rlv1, 0);
			break;
		case 0x13: // 4620 "B913" "LCGFR" "RRE"
			psw_check = false;
			ins_setup_rre();
			rlv1 = reg.getInt(rf2 + 4);
			rlv1 = -rlv1;
			reg.putLong(rf1, rlv1);
			psw_cc = get_long_comp_cc(rlv1, 0);
			break;
		case 0x14: // 4630 "B914" "LGFR" "RRE"
			psw_check = false;
			ins_setup_rre();
			reg.putLong(rf1, reg.getInt(rf2 + 4));
			break;
		case 0x16: // 4640 "B916" "LLGFR" "RRE"
			psw_check = false;
			ins_setup_rre();
			reg.putLong(rf1, (long) reg.getInt(rf2 + 4) & long_low32_bits);
			break;
		case 0x17: // 4650 "B917" "LLGTR" "RRE"
			psw_check = false;
			ins_setup_rre();
			reg.putLong(rf1, reg.getInt(rf2 + 4) & max_pos_int);
			break;
		case 0x18: // 4660 "B918" "AGFR" "RRE"
			psw_check = false;
			ins_setup_rre();
			rlv1 = reg.getLong(rf1);
			rlv2 = reg.getInt(rf2 + 4);
			rlv3 = rlv1 + rlv2;
			reg.putLong(rf1, rlv3);
			psw_cc = get_long_add_cc();
			break;
		case 0x19: // 4670 "B919" "SGFR" "RRE"
			psw_check = false;
			ins_setup_rre();
			rlv1 = reg.getLong(rf1);
			rlv2 = reg.getInt(rf2 + 4);
			rlv3 = rlv1 - rlv2;
			reg.putLong(rf1, rlv3);
			psw_cc = get_long_sub_cc();
			break;
		case 0x1A: // 4680 "B91A" "ALGFR" "RRE"
			psw_check = false;
			ins_setup_rre();
			rlvw = reg.getLong(rf1);
			rlv2 = ((long) reg.getInt(rf2 + 4) & long_low32_bits);
			rlv1 = rlvw + rlv2;
			reg.putLong(rf1, rlv1);
			psw_cc = get_long_log_add_cc();
			break;
		case 0x1B: // 4690 "B91B" "SLGFR" "RRE"
			psw_check = false;
			ins_setup_rre();
			rlvw = reg.getLong(rf1);
			rlv2 = (long) reg.getInt(rf2 + 4) & long_low32_bits;
			rlv1 = rlvw - rlv2;
			reg.putLong(rf1, rlv1);
			psw_cc = get_long_log_sub_cc();
			break;
		case 0x1C: // 4700 "B91C" "MSGFR" "RRE"
			psw_check = false;
			ins_setup_rre();
			reg.putLong(rf1, reg.getLong(rf1) * reg.getInt(rf2 + 4));
			break;
		case 0x1D: // 4710 "B91D" "DSGFR" "RRE"
			psw_check = false;
			ins_setup_rre();
			if ((mf1 & 1) != 0) { // RPI-758
				set_psw_check(Constants.psw_pic_spec);
			}
			rlv1 = reg.getLong(rf1 + 8);
			rlv2 = (long) reg.getInt(rf2 + 4);
			if (rlv2 != 0) {
				rlvw = rlv1 / rlv2;
			} else {
				set_psw_check(Constants.psw_pic_fx_div);
				break;
			}
			rlv1 = rlv1 - rlvw * rlv2;
			reg.putLong(rf1, rlv1);
			reg.putLong(rf1 + 8, rlvw);
			break;
		case 0x1E: // 4720 "B91E" "KMAC" "RRE"
			ins_setup_rre();
			break;
		case 0x1F: // 4730 "B91F" "LRVR" "RRE"
			psw_check = false;
			ins_setup_rre();
			work_reg.putInt(0, reg.getInt(rf2 + 4)); // RPI-1200
			rflen = 3;
			while (rflen >= 0) {
				reg.put(rf1 + 4 + rflen, work_reg.get(3 - rflen)); // RPI-1200
				rflen--;
			}
			break;
		case 0x20: // 4740 "B920" "CGR" "RRE"
			psw_check = false;
			ins_setup_rre();
			psw_cc = get_long_comp_cc(reg.getLong(rf1), reg.getLong(rf2));
			break;
		case 0x21: // 4750 "B921" "CLGR" "RRE"
			psw_check = false;
			ins_setup_rre();
			psw_cc = get_long_log_comp_cc(reg.getLong(rf1), reg.getLong(rf2));
			break;
		case 0x25: // 4760 "B925" "STURG" "RRE"
			ins_setup_rre();
			break;
		case 0x26: // 4880 "B926" "LBR" "RRE" Z9-12
			psw_check = false;
			ins_setup_rre();
			reg.putInt(rf1 + 4, reg.get(rf2 + 7));
			break;
		case 0x27: // 4890 "B927" "LHR" "RRE" Z9-13
			psw_check = false;
			ins_setup_rre();
			reg.putInt(rf1 + 4, reg.getShort(rf2 + 6));
			break;
		case 0x28: // "B928" "PCKMO" "RRE" RPI-1125
			ins_setup_rre();
			break;
		case 0x2A: // "B92A" "KMF" "RRE" RPI-1125
			ins_setup_rre();
			break;
		case 0x2B: // "B92B" "KMO" "RRE" RPI-1125
			ins_setup_rre();
			break;
		case 0x2C: // "B92C" "PCC" "RRE" RPI-1125
			ins_setup_rre();
			break;
		case 0x2D: // "B92D" "KMCTR" "RRF" RPI-1125
			ins_setup_rrf1();
			break;
		case 0x2E: // 4770 "B92E" "KM" "RRE"
			ins_setup_rre();
			break;
		case 0x2F: // 4780 "B92F" "KMC" "RRE"
			ins_setup_rre();
			break;
		case 0x30: // 4790 "B930" "CGFR" "RRE"
			psw_check = false;
			ins_setup_rre();
			psw_cc = get_long_comp_cc(reg.getLong(rf1), (long) reg
					.getInt(rf2 + 4));
			break;
		case 0x31: // 4800 "B931" "CLGFR" "RRE"
			psw_check = false;
			ins_setup_rre();
			psw_cc = get_long_log_comp_cc(reg.getLong(rf1), (long) reg
					.getInt(rf2 + 4));
			break;
		case 0x3E: // 4810 "B93E" "KIMD" "RRE"
			ins_setup_rre();
			break;
		case 0x3F: // 4820 "B93F" "KLMD" "RRE"
			ins_setup_rre();
			break;
		case 0x41: // "B941" "CFDTR" "RRF3" r1,m4,r2,m4 RPI-1125
			psw_check = false;
			set_dfp_alt_mode_rr(); // RPI-1125
			ins_setup_rrf3();
			fp_rbdv1 = fp_get_bd_from_dd(fp_reg, rf2);
			fp_bd_int_rem = fp_rbdv1
			.divideAndRemainder(BigDecimal.ONE);
			reg.putInt(rf1 + 4, fp_get_bd_rnd_int(fp_dfp_class,mf3).intValue());
			psw_cc = get_int_comp_cc(fp_rbdv1.signum(), 0);
			reset_dfp_alt_mode(); // RPI-1125
			break;
		case 0x42: // "B942" "CLGDTR" "RRF3" r1,m4,r2,m4 RPI-1125
			psw_check = false;
			set_dfp_alt_mode_rr(); // RPI-1125
			ins_setup_rrf3();
			fp_bd_int_rem = fp_get_bd_from_dd(fp_reg, rf2)
			.divideAndRemainder(BigDecimal.ONE);
			fp_rbdv1 = fp_get_bd_rnd_int(fp_dfp_class,mf3); // RPI-1125
			reg.putLong(rf1, fp_rbdv1.abs().longValue());
			psw_cc = get_int_comp_cc(fp_rbdv1.signum(), 0);
			reset_dfp_alt_mode(); // RPI-1125
			break;
		case 0x43: // "B943" "CLFDTR" "RRF3" r1,m4,r2,m4 RPI-1125
			psw_check = false;
			set_dfp_alt_mode_rr(); // RPI-1125
			ins_setup_rrf3();
			fp_bd_int_rem = fp_get_bd_from_dd(fp_reg, rf2)
			.divideAndRemainder(BigDecimal.ONE);
			fp_rbdv1 = fp_get_bd_rnd_int(fp_dfp_class,mf3); // RPI-1125
			reg.putInt(rf1+4, fp_rbdv1.abs().intValue());
			psw_cc = get_int_comp_cc(fp_rbdv1.signum(), 0);
			reset_dfp_alt_mode(); // RPI-1125
			break;
		case 0x46: // 4830 "B946" "BCTGR" "RRE"
			psw_check = false;
			ins_setup_rre();
			rlv1 = reg.getLong(rf1) - 1;
			reg.putLong(rf1, rlv1);
			if (rf2 != 0 && rlv1 != 0) {
				set_psw_loc(reg.getInt(rf2 + 4));
			}
			break;
		case 0x49: // "B949" "CFXTR" "RRF3" r1,m4,r2,m4 RPI-1125
			psw_check = false;
			set_dfp_alt_mode_rr(); // RPI-1125
			ins_setup_rrf3();
			fp_rbdv1 = fp_get_bd_from_ld(fp_reg, rf2);
			reg.putInt(rf1+4,fp_rbdv1.intValue());
			psw_cc = get_int_comp_cc(fp_rbdv1.signum(),0);
			reset_dfp_alt_mode(); // RPI-1125
			break;
		case 0x4A: // "B94A" "CLGXTR" "RRF3" r1,m4,r2,m4 RPI-1125
			psw_check = false;
			set_dfp_alt_mode_rr(); // RPI-1125
			ins_setup_rrf3();
			fp_bd_int_rem = fp_get_bd_from_ld(fp_reg, rf2)
			.divideAndRemainder(BigDecimal.ONE);
			fp_rbdv1 = fp_get_bd_rnd_int(fp_dfp_class,mf3); // RPI-1125
			reg.putLong(rf1, fp_rbdv1.abs().longValue());
			psw_cc = get_int_comp_cc(fp_rbdv1.signum(), 0);
			reset_dfp_alt_mode(); // RPI-1125
			break;
		case 0x4B: // "B94B" "CLFXTR" "RRF3" r1,m4,r2,m4 RPI-1125
			psw_check = false;
			set_dfp_alt_mode_rr(); // RPI-1125
			ins_setup_rrf3();
			fp_bd_int_rem = fp_get_bd_from_ld(fp_reg, rf2)
			.divideAndRemainder(BigDecimal.ONE);
			fp_rbdv1 = fp_get_bd_rnd_int(fp_dfp_class,mf3); // RPI-1125
			reg.putInt(rf1+4, fp_rbdv1.abs().intValue());
			psw_cc = get_int_comp_cc(fp_rbdv1.signum(), 0);
			reset_dfp_alt_mode(); // RPI-1125
			break;
		case 0x51: // "B951" "CDFTR" "RRF3" r1,m4,r2,m4 RPI-1125
			psw_check = false;
			set_dfp_alt_mode_rr(); // RPI-1125
			ins_setup_rrf3();
			fp_put_bd(rf1, tz390.fp_dd_type,BigDecimal.valueOf((long)reg.getInt(rf2+4)));
			reset_dfp_alt_mode(); // RPI-1125
			break;
		case 0x52: // "B952" "CDLGTR" "RRF3" r1,m4,r2,m4 RPI-1125
			psw_check = false;
			set_dfp_alt_mode_rr(); // RPI-1125
			ins_setup_rrf3();
			fp_rbdv1 = BigDecimal.valueOf(reg.getLong(rf2));
			if (fp_rbdv1.signum() < 0) {
				fp_rbdv1 = fp_rbdv1.add(bd_max_log_long);
			}
			fp_rbdv1 = fp_rbdv1
			         .round(fp_dd_rnd_context[fp_get_rnd_mode(fp_dfp_class,mf3)]);
			fp_put_bd(rf1, tz390.fp_dd_type, fp_rbdv1);
			fp_store_reg(fp_reg, rf1); // RPI-787
			reset_dfp_alt_mode(); // RPI-1125
			break;
		case 0x53: // "B953" "CDLFTR" "RRF3" r1,m4,r2,m4 RPI-1125
			psw_check = false;
			set_dfp_alt_mode_rr(); // RPI-1125
			ins_setup_rrf3();
			fp_rbdv1 = BigDecimal.valueOf(reg.getLong(rf2) & 0xffffffff);
			fp_put_bd(rf1, tz390.fp_dd_type, fp_rbdv1);
			fp_store_reg(fp_reg, rf1); // RPI-787
			reset_dfp_alt_mode(); // RPI-1125
			break;
		case 0x59: // "B959" "CXFTR" "RRF3" r1,m4,r2,m4 RPI-1125
			psw_check = false;
			set_dfp_alt_mode_rr(); // RPI-1125
			ins_setup_rrf3();
			fp_put_bd(rf1, tz390.fp_ld_type,BigDecimal.valueOf((long)reg.getInt(rf2+4)));
			fp_store_reg(fp_reg, rf1); // RPI-787
			reset_dfp_alt_mode(); // RPI-1125
			break;
		case 0x5A: // "B95A" "CXLGTR" "RRF3" r1,m4,r2,m4 RPI-1125
			psw_check = false;
			set_dfp_alt_mode_rr(); // RPI-1125
			ins_setup_rrf3();
			fp_rbdv1 = BigDecimal.valueOf(reg.getLong(rf2));
			if (fp_rbdv1.signum() < 0) {
				fp_rbdv1 = fp_rbdv1.add(bd_max_log_long);
			}
			fp_rbdv1 = fp_rbdv1.round(fp_ld_rnd_context[fp_get_rnd_mode(fp_dfp_class,mf3)]);
			fp_put_bd(rf1, tz390.fp_ld_type, fp_rbdv1);
			fp_store_reg(fp_reg, rf1); // RPI-787
			reset_dfp_alt_mode(); // RPI-1125
			break;
		case 0x5B: // "B95B3" "CXFTR" "RRF3" r1,m4,r2,m4 RPI-1125
			psw_check = false;
			set_dfp_alt_mode_rr(); // RPI-1125
			ins_setup_rrf3();
			fp_rbdv1 = BigDecimal.valueOf(reg.getLong(rf2) & 0xffffffff);
			fp_put_bd(rf1, tz390.fp_ld_type, fp_rbdv1);
			fp_store_reg(fp_reg, rf1); // RPI-787
			reset_dfp_alt_mode(); // RPI-1125
			break;
		case 0x60:  // 10 "B960" "CGRT" "RRF5" RPI-817
			psw_check = false;
			ins_setup_rrf5();
			if ((mf3 & get_long_comp_cc(reg.getLong(rf1), reg.getLong(rf2)))
					!= 0) {
				fp_dxc = fp_dxc_trap; // raise trap
				set_psw_check(Constants.psw_pic_data);
			}
			break;
		case 0x61:  // 10 "B961" "CLGRT" "RRF5"
			psw_check = false;
			ins_setup_rrf5();
			if ((mf3 & get_long_log_comp_cc(reg.getLong(rf1), reg.getLong(rf2)))
				!= 0) {
				fp_dxc = fp_dxc_trap; // raise trap
				set_psw_check(Constants.psw_pic_data);
			}
			break;
		case 0x72:  // 80 "B972" "CRT" "RRF5" RPI-817
			psw_check = false;
			ins_setup_rrf5();
			if ((mf3 & get_int_comp_cc(reg.getInt(rf1+4),reg.getInt(rf2+4)))
					!= 0) {
				fp_dxc = fp_dxc_trap; // raise trap
				set_psw_check(Constants.psw_pic_data);
			}
			break;
		case 0x73:  // 80 "B973" "CLRT" "RRF5"
			psw_check = false;
			ins_setup_rrf5();
			if ((mf3 & get_int_log_comp_cc(reg.getInt(rf1+4),reg.getInt(rf2+4)))
						!= 0) {
				fp_dxc = fp_dxc_trap; // raise trap
				set_psw_check(Constants.psw_pic_data);
			}
			break;
		case 0x80: // 4840 "B980" "NGR" "RRE"
			psw_check = false;
			ins_setup_rre();
			rlv1 = reg.getLong(rf1) & reg.getLong(rf2);
			reg.putLong(rf1, rlv1);
			if (rlv1 == 0) {
				psw_cc = psw_cc0;
			} else {
				psw_cc = psw_cc1;
			}
			break;
		case 0x81: // 4850 "B981" "OGR" "RRE"
			psw_check = false;
			ins_setup_rre();
			rlv1 = reg.getLong(rf1) | reg.getLong(rf2);
			reg.putLong(rf1, rlv1);
			if (rlv1 == 0) {
				psw_cc = psw_cc0;
			} else {
				psw_cc = psw_cc1;
			}
			break;
		case 0x82: // 4860 "B982" "XGR" "RRE"
			psw_check = false;
			ins_setup_rre();
			rlv1 = reg.getLong(rf1) ^ reg.getLong(rf2);
			reg.putLong(rf1, rlv1);
			if (rlv1 == 0) {
				psw_cc = psw_cc0;
			} else {
				psw_cc = psw_cc1;
			}
			break;
		case 0x83: // 5000 "B983" "FLOGR" "RRE" Z9-14
			psw_check = false;
			ins_setup_rre();
			if ((mf1 & 1) != 0) { // RPI-758
				set_psw_check(Constants.psw_pic_spec);
			}
			rlv2 = reg.getLong(rf2);
			reg.putLong(rf1, Long.numberOfLeadingZeros(rlv2));
			reg.putLong(rf1 + 8, rlv2 ^ Long.highestOneBit(rlv2));
			if (rlv2 != 0) {
				psw_cc = psw_cc2; // bit found
			} else {
				psw_cc = psw_cc0; // no bits found
			}
			break;
		case 0x84: // 5010 "B984" "LLGCR" "RRE" Z9-15
			psw_check = false;
			ins_setup_rre();
			reg.putLong(rf1, reg.get(rf2 + 7) & 0xff);
			break;
		case 0x85: // 5020 "B985" "LLGHR" "RRE" Z9-16
			psw_check = false;
			ins_setup_rre();
			reg.putLong(rf1, reg.getShort(rf2 + 6) & 0xffff);
			break;
		case 0x86: // 4870 "B986" "MLGR" "RRE"
			psw_check = false;
			ins_setup_rre();
			if ((mf1 & 1) != 0) { // RPI-758
				set_psw_check(Constants.psw_pic_spec);
			}
			big_int1 = new BigInteger(get_log_bytes(reg_byte, rf1 + 8, 8)); // RPI-383
			big_int2 = new BigInteger(get_log_bytes(reg_byte, rf2, 8));
			big_int1 = big_int1.multiply(big_int2);
			fp_bi_to_wreg(reg_byte,rf1,big_int1, 16); // RPI-540
			break;
		case 0x87: // 4880 "B987" "DLGR" "RRE"
			psw_check = false;
			ins_setup_rre();
			if ((mf1 & 1) != 0) { // RPI-758
				set_psw_check(Constants.psw_pic_spec);
			}
			big_int1 = new BigInteger(get_log_bytes(reg_byte, rf1, 16)); // RPI-540
			big_int2 = new BigInteger(get_log_bytes(reg_byte, rf2, 8));
			if (big_int2.signum() == 0) {
				set_psw_check(Constants.psw_pic_fx_div);
				break;
			}
			big_int_array = big_int1.divideAndRemainder(big_int2);
			if (big_int_array[0].bitLength() > 64) {
				set_psw_check(Constants.psw_pic_fx_ovf); // RPI-781
				break;
			}
			fp_bi_to_wreg(reg_byte,rf1,big_int_array[1], 8);   // RPI-540	// remainder
			fp_bi_to_wreg(reg_byte,rf1+8,big_int_array[0], 8); // RPI-540	// quotent
			break;
		case 0x88: // 4890 "B988" "ALCGR" "RRE"
			psw_check = false;
			ins_setup_rre();
			rlvw = reg.getLong(rf1);
			rlv2 = reg.getLong(rf2);
			rlv1 = rlvw + rlv2 + psw_carry[psw_cc];
			reg.putLong(rf1, rlv1);
			psw_cc = get_long_log_add_cc();
			break;
		case 0x89: // 4900 "B989" "SLBGR" "RRE"
			psw_check = false;
			ins_setup_rre();
			rlvw = reg.getLong(rf1);
			rlv2 = reg.getLong(rf2);
			rlv1 = rlvw - rlv2 - psw_borrow[psw_cc];
			reg.putLong(rf1, rlv1);
			psw_cc = get_long_log_sub_cc();
			break;
		case 0x8A: // 4910 "B98A" "CSPG" "RRE"
			ins_setup_rre();
			break;
		case 0x8D: // 4920 "B98D" "EPSW" "RRE"
			ins_setup_rre();
			break;
		case 0x8E: // 4930 "B98E" "IDTE" "RRF"
			ins_setup_rrf2();
			break;
		case 0x90: // 4940 "B990" "TRTT" "RRE"
			psw_check = false; // RPI-454
			ins_setup_rre();
			if ((mf1 & 1) != 0) { // RPI-758
				set_psw_check(Constants.psw_pic_spec);
			}
			test_control = (byte) (mem_byte[psw_loc - 2] & 0x10); // eft2
			test_byte1 = reg.get(r0 + 2);
			test_byte2 = reg.get(r0 + 3);
			xbd2_loc = reg.getInt(r1) & psw_amode;
			if ((xbd2_loc & 0x7) != 0) { // RPI-844 require dword
				set_psw_check(Constants.psw_pic_spec);
			}
			bd1_loc = reg.getInt(rf1 + 4) & psw_amode;
			bd2_loc = reg.getInt(rf2 + 4) & psw_amode;
			bd2_end = bd2_loc + reg.getInt(rf1 + 12);
			if (((bd2_end - bd2_loc) & 1) != 0) {
				set_psw_check(Constants.psw_pic_spec);
			}
			psw_cc = psw_cc3;
			while (psw_cc == psw_cc3) {
				int index = xbd2_loc
				+ ((mem.getShort(bd2_loc) & 0xffff) << 1); // RPI-580
				function_byte1 = mem_byte[index];          // RPI-580
				function_byte2 = mem_byte[index + 1];      // RPI-580
				if (test_control == 0
						&& test_byte1 == function_byte1
						&& test_byte2 == function_byte2) {
					psw_cc = psw_cc1;
				} else {
					mem_byte[bd1_loc] = function_byte1;
					mem_byte[bd1_loc + 1] = function_byte2;
					bd1_loc = bd1_loc + 2;
					bd2_loc = bd2_loc + 2;
					if (bd2_loc >= bd2_end) {
						psw_cc = psw_cc0;
					}
				}
			}
			reg.putInt(rf1 + 4, bd1_loc);
			reg.putInt(rf1 + 12, bd2_end - bd2_loc); // bytes not translated
			reg.putInt(rf2 + 4, bd2_loc);
			break;
		case 0x91: // 4950 "B991" "TRTO" "RRE"
			psw_check = false; // RPI-454
			ins_setup_rre();
			if ((mf1 & 1) != 0) { // RPI-758
				set_psw_check(Constants.psw_pic_spec);
			}
			test_control = (byte) (mem_byte[psw_loc - 2] & 0x10); // eft2
			test_byte1 = reg.get(r0 + 3);
			xbd2_loc = reg.getInt(r1) & psw_amode;
			if ((xbd2_loc & 0x7) != 0) { // RPI-844 require dword
				set_psw_check(Constants.psw_pic_spec);
			}
			bd1_loc = reg.getInt(rf1 + 4) & psw_amode;
			bd2_loc = reg.getInt(rf2 + 4) & psw_amode;
			bd2_end = bd2_loc + reg.getInt(rf1 + 12);
			if (((bd2_end - bd2_loc) & 1) != 0) {
				set_psw_check(Constants.psw_pic_spec);
			}
			psw_cc = psw_cc3;
			while (psw_cc == psw_cc3) {
				int index = xbd2_loc + (mem.getShort(bd2_loc) & 0xffff);
				function_byte1 = mem_byte[index];
				if (test_control == 0
					&& test_byte1 == function_byte1) {
					psw_cc = psw_cc1;
				} else {
					mem_byte[bd1_loc] = function_byte1;
					bd1_loc++;
					bd2_loc = bd2_loc + 2;
					if (bd2_loc >= bd2_end) {
						psw_cc = psw_cc0;
					}
				}
			}
			reg.putInt(rf1 + 4, bd1_loc);
			reg.putInt(rf1 + 12, bd2_end - bd2_loc); // bytes not translated
			reg.putInt(rf2 + 4, bd2_loc);
			break;
		case 0x92: // 4960 "B992" "TROT" "RRE"
			psw_check = false; // RPI-454
			ins_setup_rre();
			if ((mf1 & 1) != 0) { // RPI-758
				set_psw_check(Constants.psw_pic_spec);
			}
			test_control = (byte) (mem_byte[psw_loc - 2] & 0x10); // eft2	// bit
			test_byte1 = reg.get(r0 + 2); // RPI-580
			test_byte2 = reg.get(r0 + 3); // RPI-580
			xbd2_loc = reg.getInt(r1) & psw_amode;
			if ((xbd2_loc & 0x7) != 0) { // RPI-844 require dword
				set_psw_check(Constants.psw_pic_spec);
			}
			bd1_loc = reg.getInt(rf1 + 4) & psw_amode;
			bd2_loc = reg.getInt(rf2 + 4) & psw_amode;
			bd2_end = bd2_loc + reg.getInt(rf1 + 12);
			psw_cc = psw_cc3;
			while (psw_cc == psw_cc3) {
				int index = xbd2_loc
				+ ((mem_byte[bd2_loc] & 0xff) << 1); // RPI-580
				function_byte1 = mem_byte[index];    // RPI-580
				function_byte2 = mem_byte[index+1];  // RPI-580
				if (test_control == 0
					&& test_byte1 == function_byte1
					&& test_byte2 == function_byte2) {  // RPI-580
					psw_cc = psw_cc1;
				} else {
					mem_byte[bd1_loc] = function_byte1;     // RPI-580
					mem_byte[bd1_loc + 1] = function_byte2; // RPI- 580
					bd1_loc = bd1_loc + 2;
					bd2_loc++;
					if (bd2_loc >= bd2_end) {
						psw_cc = psw_cc0;
					}
				}
			}
			reg.putInt(rf1 +  4, bd1_loc);
			reg.putInt(rf1 + 12, bd2_end - bd2_loc); // bytes not translated
			reg.putInt(rf2 + 4, bd2_loc);
			break;
		case 0x93: // 4970 "B993" "TROO" "RRE"
			psw_check = false; // RPI-454
			ins_setup_rre();
			if ((mf1 & 1) != 0) { // RPI-758
				set_psw_check(Constants.psw_pic_spec);
			}
			test_control = (byte) (mem_byte[psw_loc - 2] & 0x10); // eft2	// bit
			test_byte1 = reg.get(r0 + 3);
			xbd2_loc = reg.getInt(r1) & psw_amode;
			if ((xbd2_loc & 0x7) != 0) { // RPI-844 require dword
				set_psw_check(Constants.psw_pic_spec);
			}
			bd1_loc = reg.getInt(rf1 + 4) & psw_amode;
			bd2_loc = reg.getInt(rf2 + 4) & psw_amode;
			bd2_end = bd2_loc + reg.getInt(rf1 + 12);
			psw_cc = psw_cc3;
			while (psw_cc == psw_cc3) {
				function_byte1 = mem_byte[xbd2_loc  // RPI-580
												+ (mem_byte[bd2_loc] & 0xff)];
				if (test_control == 0
					&& test_byte1 == function_byte1) { // RPI-580
					psw_cc = psw_cc1;
				} else {
					mem_byte[bd1_loc] = function_byte1; // RPI-580
					bd1_loc++;
					bd2_loc++;
					if (bd2_loc >= bd2_end) {
						psw_cc = psw_cc0;
					}
				}
			}
			reg.putInt(rf1 +  4, bd1_loc);
			reg.putInt(rf1 + 12, bd2_end - bd2_loc); // bytes not translated
			reg.putInt(rf2 +  4, bd2_loc);
			break;
		case 0x94: // 5140 "B994" "LLCR" "RRE" Z9-17
			psw_check = false;
			ins_setup_rre();
			reg.putInt(rf1 + 4, reg.get(rf2 + 7) & 0xff);
			break;
		case 0x95: // 5150 "B995" "LLHR" "RRE" Z9-18
			psw_check = false;
			ins_setup_rre();
			reg.putInt(rf1 + 4, reg.getShort(rf2 + 6) & 0xffff);
			break;
		case 0x96: // 4980 "B996" "MLR" "RRE"
			psw_check = false;
			ins_setup_rre();
			if ((mf1 & 1) != 0) { // RPI-758
				set_psw_check(Constants.psw_pic_spec);
			}
			big_int1 = new BigInteger(get_log_bytes(reg_byte, rf1 + 12, 4)); // RPI-275
			big_int2 = new BigInteger(get_log_bytes(reg_byte, rf2 +  4, 4));
			big_int1 = big_int1.multiply(big_int2);
			fp_bi_to_wreg(work_reg_byte,0,big_int1, 8);
			reg.putInt(rf1 + 4, work_reg.getInt(0));
			reg.putInt(rf1 + 12, work_reg.getInt(4));
			break;
		case 0x97: // 4990 "B997" "DLR" "RRE"
			psw_check = false;
			ins_setup_rre();
			if ((mf1 & 1) != 0) { // RPI-758
				set_psw_check(Constants.psw_pic_spec);
			}
			work_reg.putInt(0, reg.getInt(rf1 + 4));
			work_reg.putInt(4, reg.getInt(rf1 + 12));
			big_int1 = new BigInteger(get_log_bytes(work_reg_byte, 0, 8));
			big_int2 = new BigInteger(get_log_bytes(reg_byte, rf2 + 4, 4));
			if (big_int2.signum() == 0) {
				set_psw_check(Constants.psw_pic_fx_div);
				break;
			}
			BigInteger[] temp_big = big_int1.divideAndRemainder(big_int2);
			fp_bi_to_wreg(reg_byte,rf1+ 4,temp_big[1], 4); // get big remainder RPI-540
			fp_bi_to_wreg(reg_byte,rf1+12,temp_big[0], 4); // get big quotent RPI-540
			break;
		case 0x98: // 5000 "B998" "ALCR" "RRE"
			psw_check = false;
			ins_setup_rre();
			rvw = reg.getInt(rf1 + 4);
			rv2 = reg.getInt(rf2 + 4);
			rv1 = rvw + rv2 + psw_carry[psw_cc];
			reg.putInt(rf1 + 4, rv1);
			psw_cc = get_int_log_add_cc();
			break;
		case 0x99: // 5010 "B999" "SLBR" "RRE"
			psw_check = false;
			ins_setup_rre();
			rvw = reg.getInt(rf1 + 4);
			rv2 = reg.getInt(rf2 + 4);
			rv1 = rvw - rv2 - psw_borrow[psw_cc];
			reg.putInt(rf1 + 4, rv1);
			psw_cc = get_int_log_sub_cc();
			break;
		case 0x9A: // 5020 "B99A" "EPAIR" "RRE"
			ins_setup_rre();
			break;
		case 0x9B: // 5030 "B99B" "ESAIR" "RRE"
			ins_setup_rre();
			break;
		case 0x9D: // 5040 "B99D" "ESEA" "RRE"
			ins_setup_rre();
			break;
		case 0x9E: // 5050 "B99E" "PTI" "RRE"
			ins_setup_rre();
			break;
		case 0x9F: // 5060 "B99F" "SSAIR" "RRE"
			ins_setup_rre();
			break;
		case 0xA2:  // 10 "B9A2" "PTF" "RRE" 14 RPI-817
			ins_setup_rre();
			break;
		case 0xAA: // 5250 "B9AA" "LPTEA" "RRE" Z9-19
			ins_setup_rre();
			break;
		case 0xAE: // "B9AE" "RRBM" "RRE" RPI-1125 Z196
			ins_setup_rre();
			break;
		case 0xAF:  // 20 "B9AF" "PFMF" "RRF5" 39 RPI-817
			ins_setup_rrf5();
			break;
		case 0xB0: // 5070 "B9B0" "CU14" "RRE"
			ins_setup_rre();
			break;
		case 0xB1: // 5080 "B9B1" "CU24" "RRE"
			ins_setup_rre();
			break;
		case 0xB2: // 5090 "B9B2" "CU41" "RRE"
			ins_setup_rre();
			break;
		case 0xB3: // 5100 "B9B3" "CU42" "RRE"
			ins_setup_rre();
			break;
		case 0xBD:  // 30 "B9BD" "TRTRE" "RRF5" 39 RPI-817
			psw_check = false;
			ins_setup_rrf5();
			exec_trt_ext(true);
			break;
		case 0xBE: // 5110 "B9BE" "SRSTU" "RRE"
			ins_setup_rre();
			break;
		case 0xBF:  // 40 "B9BF" "TRTE" "RRF5" 39 RPI-817
			psw_check = false;
			ins_setup_rrf5();
			exec_trt_ext(false);;
			break;
		case 0xC8:  // "B9C8" "AHHHR" R1,R2,R3 RPI-1125 z196
			psw_check = false;
			ins_setup_rrf5();
			rv1 = reg.getInt(rf2);
			rv2 = reg.getInt(rf3);
			rv3 = rv1 + rv2;
			reg.putInt(rf1, rv3);
			psw_cc = get_int_add_cc();
			break;
		case 0xC9:  // "B9C9" "SHHHR" R1,R2,R3 RPI-1125 z196
			psw_check = false;
			ins_setup_rrf5();
			rv1 = reg.getInt(rf2);
			rv2 = reg.getInt(rf3);
			rv3 = rv1 - rv2;
			reg.putInt(rf1, rv3);
			psw_cc = get_int_sub_cc();
			break;
		case 0xCA:  // "B9CA" "ALHHHR" R1,R2,R3 RPI-1125 z196
			psw_check = false;
			ins_setup_rrf5();
			rvw = reg.getInt(rf2);
			rv2 = reg.getInt(rf3);
			rv1 = rvw + rv2;
			reg.putInt(rf1, rv1);
			psw_cc = get_int_log_add_cc();
			break;
		case 0xCB:  // "B9CB" "SLHHHR" R1,R2,R3 RPI-1125 z196
			psw_check = false;
			ins_setup_rrf5();
			rvw = reg.getInt(rf2);
			rv2 = reg.getInt(rf3);
			rv1 = rvw - rv2;
			reg.putInt(rf1, rv1);
			psw_cc = get_int_log_sub_cc();
			break;
		case 0xCD: // "B9CD" "CHHR" "RRE" RPI-1125
			psw_check = false;
			ins_setup_rre();
			psw_cc = get_int_comp_cc(reg.getInt(rf1), reg.getInt(rf2));
			break;
		case 0xCF: // "B9CF" "CLHHR" "RRE" RPI-1125
			psw_check = false;
			ins_setup_rre();
			psw_cc = get_int_log_comp_cc(reg.getInt(rf1), reg.getInt(rf2));
			break;
		case 0xD8:  // "B9D8" "AHHLR" R1,R2,R3 RPI-1125 z196
			psw_check = false;
			ins_setup_rrf5();
			rv1 = reg.getInt(rf2);
			rv2 = reg.getInt(rf3+4);
			rv3 = rv1 + rv2;
			reg.putInt(rf1, rv3);
			psw_cc = get_int_add_cc();
			break;
		case 0xD9:  // "B9D9" "SHHLR" R1,R2,R3 RPI-1125 z196
			psw_check = false;
			ins_setup_rrf5();
			rv1 = reg.getInt(rf2);
			rv2 = reg.getInt(rf3+4);
			rv3 = rv1 - rv2;
			reg.putInt(rf1, rv3);
			psw_cc = get_int_sub_cc();
			break;
		case 0xDA:  // "B9DA" "ALHHLR" R1,R2,R3 RPI-1125 z196
			psw_check = false;
			ins_setup_rrf5();
			rvw = reg.getInt(rf2);
			rv2 = reg.getInt(rf3+4);
			rv1 = rvw + rv2;
			reg.putInt(rf1, rv1);
			psw_cc = get_int_log_add_cc();
			break;
		case 0xDB:  // "B9DB" "SLHHLR" R1,R2,R3 RPI-1125 z196
			psw_check = false;
			ins_setup_rrf5();
			rvw = reg.getInt(rf2);
			rv2 = reg.getInt(rf3+4);
			rv1 = rvw - rv2;
			reg.putInt(rf1, rv1);
			psw_cc = get_int_log_sub_cc();
			break;
		case 0xDD: // "B9DD" "CHLR" "RRE" RPI-1125
			psw_check = false;
			ins_setup_rre();
			psw_cc = get_int_comp_cc(reg.getInt(rf1), reg.getInt(rf2+4));
			break;
		case 0xDF: // "B9DF" "CLHLR" "RRE" RPI-1125
			psw_check = false;
			ins_setup_rre();
			psw_cc = get_int_log_comp_cc(reg.getInt(rf1), reg
					.getInt(rf2+4));
			break;
		case 0xE1:  // 5115 "B9E1" "POPCNT" "RRE" 14 RPI-1125
			psw_check = false;
			ins_setup_rre();
			reg.put(rf1++,bit_cnt[reg.get(rf2++) & 0xff]);
			reg.put(rf1++,bit_cnt[reg.get(rf2++) & 0xff]);
			reg.put(rf1++,bit_cnt[reg.get(rf2++) & 0xff]);
			reg.put(rf1++,bit_cnt[reg.get(rf2++) & 0xff]);
			reg.put(rf1++,bit_cnt[reg.get(rf2++) & 0xff]);
			reg.put(rf1++,bit_cnt[reg.get(rf2++) & 0xff]);
			reg.put(rf1++,bit_cnt[reg.get(rf2++) & 0xff]);
			reg.put(rf1++,bit_cnt[reg.get(rf2++) & 0xff]);
			if (reg.getLong(rf1) == 0) {
				psw_cc = psw_cc0;
			} else {
				psw_cc = psw_cc2;
			}
			break;
		case 0xE2: // "B9E2" "LOCGR" R1,R2,M3 RPI-1125
			psw_check = false;
			ins_setup_rrf5();
			if ((psw_cc & mf3) > 0) {
				reg.putLong(rf1, reg.getLong(rf2));
			}
			break;
		case 0xE4: // "B9E4" "NGRK" R1,R2,R3 RPI-1125
			psw_check = false;
			ins_setup_rrf5();
			rlv1 = reg.getLong(rf2) & reg.getLong(rf3);
			reg.putLong(rf1, rlv1);
			if (rlv1 == 0) {
				psw_cc = psw_cc0;
			} else {
				psw_cc = psw_cc1;
			}
			break;
		case 0xE6: // "B9E6" "OGRK" R1,R2,R3 RPI-1125
			psw_check = false;
			ins_setup_rrf5();
			rlv1 = reg.getLong(rf2) | reg.getLong(rf3);
			reg.putLong(rf1, rlv1);
			if (rlv1 == 0) {
				psw_cc = psw_cc0;
			} else {
				psw_cc = psw_cc1;
			}
			break;
		case 0xE7: // "B9E7" "XGRK" R1,R2,R3 RPI-1125
			psw_check = false;
			ins_setup_rrf5();
			rlv1 = reg.getLong(rf2) ^ reg.getLong(rf3);
			reg.putLong(rf1, rlv1);
			if (rlv1 == 0) {
				psw_cc = psw_cc0;
			} else {
				psw_cc = psw_cc1;
			}
			break;
		case 0xE8: // "B9E8" "AGRK" R1,R2,R3 RPI-1125
			psw_check = false;
			ins_setup_rrf5();
			rlv1 = reg.getLong(rf2);
			rlv2 = reg.getLong(rf3);
			rlv3 = rlv1 + rlv2;
			reg.putLong(rf1, rlv3);
			psw_cc = get_long_add_cc();
			break;
		case 0xE9: // "B9E9" "SGRK" R1,R2,R3 RPI-1125
			psw_check = false;
			ins_setup_rrf5();
			rlv1 = reg.getLong(rf2);
			rlv2 = reg.getLong(rf3);
			rlv3 = rlv1 - rlv2;
			reg.putLong(rf1, rlv3);
			psw_cc = get_long_sub_cc();
			break;
		case 0xEA: // "B9EA" "ALGRK" R1,R2,R3 RPI-1125
			psw_check = false;
			ins_setup_rrf5();
			rlv1 = reg.getLong(rf2);
			rlv2 = reg.getLong(rf3);
			rlv3 = rlv1 + rlv2;
			reg.putLong(rf1, rlv3);
			psw_cc = get_long_log_add_cc();
			break;
		case 0xEB: // "B9EB" "SLGRK" R1,R2,R3 RPI-1125
			psw_check = false;
			ins_setup_rrf5();
			rlv1 = reg.getLong(rf2);
			rlv2 = reg.getLong(rf3);
			rlv3 = rlv1 - rlv2;
			reg.putLong(rf1, rlv3);
			psw_cc = get_long_log_sub_cc();
			break;
		case 0xF2: // "B9F2" "LOCR" R1,R2,M3 RPI-1125
			psw_check = false;
			ins_setup_rrf5();
			if ((psw_cc & mf3) > 0) {
				reg.putInt(rf1+4, reg.getInt(rf2+4));
			}
			break;
		case 0xF4: // "B9F4" "NRK" R1,R2,R3 RPI-1125
			psw_check = false;
			ins_setup_rrf5();
			rv1 = reg.getInt(rf2+4) & reg.getInt(rf3+4);
			reg.putInt(rf1+4, rv1);
			if (rv1 == 0) {
				psw_cc = psw_cc0;
			} else {
				psw_cc = psw_cc1;
			}
			break;
		case 0xF6: // "B9F6" "ORK" R1,R2,R3 RPI-1125
			psw_check = false;
			ins_setup_rrf5();
			rv1 = reg.getInt(rf2+4) | reg.getInt(rf3+4);
			reg.putInt(rf1+4, rv1);
			if (rv1 == 0) {
				psw_cc = psw_cc0;
			} else {
				psw_cc = psw_cc1;
			}
			break;
		case 0xF7: // "B9F7" "XRK" R1,R2,R3 RPI-1125
			psw_check = false;
			ins_setup_rrf5();
			rv1 = reg.getInt(rf2+4) ^ reg.getInt(rf3+4);
			reg.putInt(rf1+4, rv1);
			if (rv1 == 0) {
				psw_cc = psw_cc0;
			} else {
				psw_cc = psw_cc1;
			}
			break;
		case 0xF8: // "B9F8" "ARK" R1,R2,R3 RPI-1125
			psw_check = false;
			ins_setup_rrf5();
			rv1 = reg.getInt(rf2+4);
			rv2 = reg.getInt(rf3+4);
			rv3 = rv1 + rv2;
			reg.putInt(rf1+4, rv3);
			psw_cc = get_int_add_cc();
			break;
		case 0xF9: // "B9F9" "SRK" R1,R2,R3 RPI-1125
			psw_check = false;
			ins_setup_rrf5();
			rv1 = reg.getInt(rf2+4);
			rv2 = reg.getInt(rf3+4);
			rv3 = rv1 - rv2;
			reg.putInt(rf1+4, rv3);
			psw_cc = get_int_sub_cc();
			break;
		case 0xFA: // "B9FA" "ALRK" R1,R2,R3 RPI-1125
			psw_check = false;
			ins_setup_rrf5();
			rv1 = reg.getInt(rf2+4);
			rv2 = reg.getInt(rf3+4);
			rv3 = rv1 + rv2;
			reg.putInt(rf1+4, rv3);
			psw_cc = get_int_log_add_cc();
			break;
		case 0xFB: // "B9FB" "SLRK" R1,R2,R3 RPI-1125
			psw_check = false;
			ins_setup_rrf5();
			rv1 = reg.getInt(rf2+4);
			rv2 = reg.getInt(rf3+4);
			rv3 = rv1 - rv2;
			reg.putInt(rf1+4, rv3);
			psw_cc = get_int_log_sub_cc();
			break;
		}
	}

	/**
	 *
	 */
	private void ins_C0XX()
	{
		opcode2 = mem_byte[psw_loc + opcode2_offset_ril] & 0x0f;
		switch (opcode2) {
		case 0x0: // 5170 "C00" "LARL" "RIL"
			psw_check = false;
			ins_setup_ril();
			reg.putInt(rf1 + 4, bd2_loc); // RPI-817
			break;
		case 0x1: // 5370 "C01" "LGFI" "RIL" Z9-20
			psw_check = false;
			ins_setup_ril();
			reg.putLong(rf1, if2);
			break;
		case 0x4: // 5180 "C04" "BRCL" "RIL"
			psw_check = false;
			ins_setup_ril();
			if ((mf1 & psw_cc) != 0) {
				set_psw_loc(bd2_loc); // RPI-817
			}
			break;
		case 0x5: // 5210 "C05" "BRASL" "RIL"
			psw_check = false;
			ins_setup_ril();
			if (ex_mode) {
				reg.putInt(rf1 + 4, ex_psw_return | psw_amode_bit);
			} else {
				reg.putInt(rf1 + 4, psw_loc | psw_amode_bit);
			}
			set_psw_loc(bd2_loc); // RPI-817
			break;
		case 0x6: // 5430 "C06" "XIHF" "RIL" Z9-21
			psw_check = false;
			ins_setup_ril();
			reg.putInt(rf1, reg.getInt(rf1) ^ if2);
			break;
		case 0x7: // 5440 "C07" "XILF" "RIL" Z9-22
			psw_check = false;
			ins_setup_ril();
			reg.putInt(rf1 + 4, reg.getInt(rf1 + 4) ^ if2);
			break;
		case 0x8: // 5450 "C08" "IIHF" "RIL" Z9-23
			psw_check = false;
			ins_setup_ril();
			reg.putInt(rf1, if2);
			break;
		case 0x9: // 5460 "C09" "IILF" "RIL" Z9-24
			psw_check = false;
			ins_setup_ril();
			reg.putInt(rf1 + 4, if2);
			break;
		case 0xA: // 5470 "C0A" "NIHF" "RIL" Z9-25
			psw_check = false;
			ins_setup_ril();
			reg.putInt(rf1, reg.getInt(rf1) & if2);
			break;
		case 0xB: // 5480 "C0B" "NILF" "RIL" Z9-26
			psw_check = false;
			ins_setup_ril();
			reg.putInt(rf1 + 4, reg.getInt(rf1 + 4) & if2);
			break;
		case 0xC: // 5490 "C0C" "OIHF" "RIL" Z9-27
			psw_check = false;
			ins_setup_ril();
			reg.putInt(rf1, reg.getInt(rf1) | if2);
			break;
		case 0xD: // 5500 "C0D" "OILF" "RIL" Z9-28
			psw_check = false;
			ins_setup_ril();
			reg.putInt(rf1 + 4, reg.getInt(rf1 + 4) | if2);
			break;
		case 0xE: // 5510 "C0E" "LLIHF" "RIL" Z9-29
			psw_check = false;
			ins_setup_ril();
			reg.putLong(rf1, ((long) if2) << 32);
			break;
		case 0xF: // 5520 "C0F" "LLILF" "RIL" Z9-30
			psw_check = false;
			ins_setup_ril();
			reg.putLong(rf1, ((long) if2) & long_low32_bits);
			break;
		}
	}

	/**
	 *
	 */
	private void ins_C2XX()
	{
		opcode2 = mem_byte[psw_loc + opcode2_offset_ril] & 0x0f; // RPI-202
		switch (opcode2) {
		case 0x0:  // 50 "C20" "MSGFI" "RIL" 16 RPI-817
			psw_check = false;
			ins_setup_ril();
			reg.putLong(rf1, reg.getLong(rf1) * if2);
			break;
		case 0x1:  // 60 "C21" "MSFI" "RIL" 16 RPI-817
			psw_check = false;
			ins_setup_ril();
			reg.putInt(rf1+4, reg.getInt(rf1+4) * if2);
			break;
		case 0x4: // 5530 "C24" "SLGFI" "RIL" Z9-31
			psw_check = false;
			ins_setup_ril();
			rlvw = reg.getLong(rf1);
			rlv2 = (long) if2 & long_low32_bits;
			rlv1 = rlvw - rlv2;
			reg.putLong(rf1, rlv1);
			psw_cc = get_long_log_sub_cc();
			break;
		case 0x5: // 5540 "C25" "SLFI" "RIL" Z9-32
			psw_check = false;
			ins_setup_ril();
			rvw = reg.getInt(rf1 + 4);
			rv2 = if2;
			rv1 = rvw - rv2;
			reg.putInt(rf1 + 4, rv1);
			psw_cc = get_int_log_sub_cc();
			break;
		case 0x8: // "C28" "AGFI" "RIL" Z9-33
			psw_check = false;
			ins_setup_ril();
			rlv1 = reg.getLong(rf1);
			rlv2 = if2;
			rlv3 = rlv1 + rlv2;
			reg.putLong(rf1, rlv3);
			psw_cc = get_long_add_cc();
			break;
		case 0x9: // "C29" "AFI" "RIL" Z9-34
			psw_check = false;
			ins_setup_ril();
			rv1 = reg.getInt(rf1 + 4);
			rv2 = if2;
			rv3 = rv1 + rv2;
			reg.putInt(rf1 + 4, rv3);
			psw_cc = get_int_add_cc();
			break;
		case 0xA: // "C2A" "ALGFI" "RIL" Z9-35
			psw_check = false;
			ins_setup_ril();
			rlvw = reg.getLong(rf1);
			rlv2 = ((long) if2 & long_low32_bits);
			rlv1 = rlvw + rlv2;
			reg.putLong(rf1, rlv1);
			psw_cc = get_long_log_add_cc();
			break;
		case 0xB: // "C2B" "ALFI" "RIL" Z9-36
			psw_check = false;
			ins_setup_ril();
			rvw = reg.getInt(rf1 + 4);
			rv2 = if2;
			rv1 = rvw + rv2;
			reg.putInt(rf1 + 4, rv1);
			psw_cc = get_int_log_add_cc();
			break;
		case 0xC: // "C2C" "CGFI" "RIL" Z9-37
			psw_check = false;
			ins_setup_ril();
			psw_cc = get_long_comp_cc(reg.getLong(rf1), if2);
			break;
		case 0xD: // "C2D" "CFI" "RIL" Z9-38
			psw_check = false;
			ins_setup_ril();
			psw_cc = get_int_comp_cc(reg.getInt(rf1 + 4), if2);
			break;
		case 0xE: // "C2E" "CLGFI" "RIL" Z9-39
			psw_check = false;
			ins_setup_ril();
			psw_cc = get_long_log_comp_cc(reg.getLong(rf1), (long) if2
					& long_low32_bits);
			break;
		case 0xF: // "C2F" "CLFI" "RIL" Z9-40
			psw_check = false;
			ins_setup_ril();
			psw_cc = get_int_log_comp_cc(reg.getInt(rf1 + 4), if2);
			break;
		}
	}

	/**
	 *
	 */
	private void ins_C4XX()
	{
		opcode2 = mem_byte[psw_loc + opcode2_offset_ril] & 0x0f; // RPI-202
		switch (opcode2) {
		case 0x2:  // 70 "C42" "LLHRL" "RIL" 16 RPI-817
			psw_check = false;
			ins_setup_ril();
			reg.putInt(rf1 + 4,mem.getShort(bd2_loc) & 0xffff);
			break;
		case 0x4:  // 80 "C44" "LGHRL" "RIL" 16 RPI-817
			psw_check = false;
			ins_setup_ril();
			reg.putLong(rf1,mem.getShort(bd2_loc));
			break;
		case 0x5:  // 90 "C45" "LHRL" "RIL" 16 RPI-817
			psw_check = false;
			ins_setup_ril();
			reg.putInt(rf1 + 4,mem.getShort(bd2_loc));
			break;
		case 0x6:  // 100 "C46" "LLGHRL" "RIL" 16 RPI-817
			psw_check = false;
			ins_setup_ril();
			reg.putLong(rf1,mem.getShort(bd2_loc) & 0xffff);
			break;
		case 0x7:  // 110 "C47" "STHRL" "RIL" 16 RPI-817
			psw_check = false;
			ins_setup_ril();
			mem.putShort(bd2_loc,reg.getShort(rf1+6));
			break;
		case 0x8:  // 120 "C48" "LGRL" "RIL" 16 RPI-817
			psw_check = false;
			ins_setup_ril();
			reg.putLong(rf1,mem.getLong(bd2_loc));
			break;
		case 0xB:  // 130 "C4B" "STGRL" "RIL" 16 RPI-817
			psw_check = false;
			ins_setup_ril();
			mem.putLong(bd2_loc,reg.getLong(rf1));
			break;
		case 0xC:  // 140 "C4C" "LGFRL" "RIL" 16 RPI-817
			psw_check = false;
			ins_setup_ril();
			reg.putLong(rf1,mem.getInt(bd2_loc));
			break;
		case 0xD:  // 150 "C4D" "LRL" "RIL" 16 RPI-817
			psw_check = false;
			ins_setup_ril();
			reg.putInt(rf1 + 4,mem.getInt(bd2_loc));
			break;
		case 0xE:  // 160 "C4E" "LLGFRL" "RIL" 16 RPI-817
			psw_check = false;
			ins_setup_ril();
			reg.putLong(rf1,mem.getInt(bd2_loc) & long_low32_bits);
			break;
		case 0xF:  // 170 "C4F" "STRL" "RIL" 16 RPI-817
			psw_check = false;
			ins_setup_ril();
			mem.putInt(bd2_loc,reg.getInt(rf1+4));
			break;
		}
	}

	/**
	 *
	 */
	private void ins_C6XX() // RPI-817
	{
		opcode2 = mem_byte[psw_loc+opcode2_offset_ril] & 0x0f;
		switch (opcode2) {
		case 0x0:  // 180 "C60" "EXRL" "RIL" 16 RPI-817
			psw_check = false;
			ins_setup_ril();
			exec_ex(bd2_loc);
			break;
		case 0x2:  // 190 "C62" "PFDRL" "RIL" 16 RPI-817
			psw_check = false;
			ins_setup_ril(); // nothing to do but trace this one
			break;
		case 0x4:  // 200 "C64" "CGHRL" "RIL" 16 RPI-817
			psw_check = false;
			ins_setup_ril();
			psw_cc = get_long_comp_cc(reg.getLong(rf1), mem.getShort(bd2_loc));
			break;
		case 0x5:  // 210 "C65" "CHRL" "RIL" 16 RPI-817
			psw_check = false;
			ins_setup_ril();
			psw_cc = get_int_comp_cc(reg.getInt(rf1+4), mem.getShort(bd2_loc));
			break;
		case 0x6:  // 220 "C66" "CLGHRL" "RIL" 16 RPI-817
			psw_check = false;
			ins_setup_ril();
			psw_cc = get_long_log_comp_cc(reg.getLong(rf1), mem.getShort(bd2_loc) & 0xffff);
			break;
		case 0x7:  // 230 "C67" "CLHRL" "RIL" 16 RPI-817
			psw_check = false;
			ins_setup_ril();
			psw_cc = get_int_log_comp_cc(reg.getInt(rf1+4), mem.getShort(bd2_loc) & 0xffff);
			break;
		case 0x8:  // 240 "C68" "CGRL" "RIL" 16 RPI-817
			psw_check = false;
			ins_setup_ril();
			psw_cc = get_long_comp_cc(reg.getLong(rf1), mem.getLong(bd2_loc));
			break;
		case 0xA:  // 250 "C6A" "CLGRL" "RIL" 16 RPI-817
			psw_check = false;
			ins_setup_ril();
			psw_cc = get_long_log_comp_cc(reg.getLong(rf1), mem.getLong(bd2_loc));
			break;
		case 0xC:  // 260 "C6C" "CGFRL" "RIL" 16 RPI-817
			psw_check = false;
			ins_setup_ril();
			psw_cc = get_long_comp_cc(reg.getLong(rf1), mem.getInt(bd2_loc));
			break;
		case 0xD:  // 270 "C6D" "CRL" "RIL" 16 RPI-817
			psw_check = false;
			ins_setup_ril();
			psw_cc = get_int_comp_cc(reg.getInt(rf1+4), mem.getInt(bd2_loc));
			break;
		case 0xE:  // 280 "C6E" "CLGFRL" "RIL" 16 RPI-817
			psw_check = false;
			ins_setup_ril();
			psw_cc = get_long_log_comp_cc(reg.getLong(rf1), mem.getInt(bd2_loc) & long_low32_bits);
			break;
		case 0xF:  // 290 "C6F" "CLRL" "RIL" 16 RPI-817
			psw_check = false;
			ins_setup_ril();
			psw_cc = get_int_log_comp_cc(reg.getInt(rf1+4), mem.getInt(bd2_loc));
			break;
		}
	}

	/**
	 *
	 */
	private void ins_CCXX() // RPI-1125
	{
		opcode2 = mem_byte[psw_loc + opcode2_offset_ril] & 0x0f;
		switch (opcode2) {
		case 0x6: // "CC6" "BRCTH" "RIL" R1,S2
			psw_check = false;
			ins_setup_ril();
			rv1 = reg.getInt(rf1) - 1;
			reg.putInt(rf1, rv1);
			if (rv1 != 0) {
				set_psw_loc(psw_loc - 4 + if2 + if2); // RPI-357
			}
			break;
		case 0x8: // "CC8" "AIH" "RIL" R1,S2
			psw_check = false;
			ins_setup_ril();
			rv1 = reg.getInt(rf1);
			rv2 = if2;
			rv3 = rv1 + rv2;
			reg.putInt(rf1, rv3);
			psw_cc = get_int_add_cc();
			break;
		case 0xA: // "CC6" "ALSIH" "RIL" R1,S2
			psw_check = false;
			ins_setup_ril();
			rvw = reg.getInt(rf1);
			rv2 = if2;
			rv1 = rvw + rv2;
			reg.putInt(rf1, rv1);
			psw_cc = get_int_lsi_add_cc();
			break;
		case 0xB: // "CC6" "ALSIHN" "RIL" R1,S2
			psw_check = false;
			ins_setup_ril();
			rvw = reg.getInt(rf1);
			rv2 = if2;
			rv1 = rvw + rv2;
			reg.putInt(rf1, rv1); get_int_add_cc();
			break;
		case 0xD: // "CC6" "CIH" "RIL" R1,S2
			psw_check = false;
			ins_setup_ril();
			psw_cc = get_int_comp_cc(reg.getInt(rf1), if2);
			break;
		case 0xF: // "CC6" "CLIH" "RIL" R1,S2
			psw_check = false;
			ins_setup_ril();
			psw_cc = get_int_log_comp_cc(reg.getInt(rf1), if2);
			break;
		}
	}

	/**
	 *
	 */
	private void ins_C8XX()
	{
		opcode2 = mem_byte[psw_loc + opcode2_offset_ssf] & 0x0f; // RPI-202 RPI-606
		switch (opcode2) {
		case 0x0: // 5630 "C80" "MVCOS" "SSF" Z9-41
			psw_check = false; // RPI-606
			ins_setup_ssf();   // RPI-606
			if (reg.getInt(r0) == 0) {
				if (rflen > 0
					&& bd1_loc > bd2_loc
					&& bd1_loc < bd2_loc + rflen) {
					set_psw_check(Constants.psw_pic_spec);  // RPI-859
					return;
				}
				psw_cc = psw_cc0;
				if (rflen > 0) {
					if (rflen > 4096) {
						psw_cc = psw_cc3;
					}
					exec_mvc_rflen();
				}
			} else {
				set_psw_check(Constants.psw_pic_spec);
			}
			break;
		case 0x1: // "ECTG" RPI-1013
			ins_setup_ssf();
			break;
		case 0x2: // "CSST" RPI-1013
			ins_setup_ssf();
			break;
		case 0x4: // "C84" "LPD" "SSF2" RPI-1125
			psw_check = false; // RPI-606
			ins_setup_ssf2();   // RPI-606
			if ((mf3 & 1) != 0) { // RPI-758
				set_psw_check(Constants.psw_pic_spec);
			}
			reg.putInt(rf3+4,mem.getInt(bd1_loc));
			reg.putInt(rf3+4+8,mem.getInt(bd2_loc));
			break;
		case 0x5: // "C85" "LPDG" "SSF2" RPI-1125
			psw_check = false; // RPI-606
			ins_setup_ssf2();   // RPI-606
			if ((mf3 & 1) != 0) { // RPI-758
				set_psw_check(Constants.psw_pic_spec);
			}
			reg.putLong(rf3,mem.getLong(bd1_loc));
			reg.putLong(rf3+8,mem.getLong(bd2_loc));
			break;
		}
	}

	/**
	 * ASSIST extended I/O instructions RPI-812
	 */
	private void ins_E0X()
	{
		opcode2 = (mem_byte[psw_loc + 1] & 0xf0) >>> 4;
		switch (opcode2) {
		case 0x00:  // 5375 "E00" "XREAD" "RXSS" 38 RPI-812
			psw_check = false;
			ins_setup_rxss();
			psw_cc = psw_cc0;
			if (bd2_loc == 0) {
				bd2_loc = 80;
			}
			if (ast_xread_tiot == -1) {
				ast_xread_tiot = sz390.ast_open_file("XREAD",true,ast_xread_dcb);
			}
			if (ast_xread_tiot != -1) {
				try {
					ast_file_line = sz390.tiot_file[ast_xread_tiot].readLine();
					if (ast_file_line == null) {
						sz390.ast_close_file(ast_xread_tiot);
						ast_xread_tiot = -1;
						psw_cc = psw_cc1;
					} else {
						sz390.put_ascii_string(ast_file_line,xbd1_loc,bd2_loc,' ');
					}
				} catch (final Exception e) {
					set_psw_check(Constants.psw_pic_io);
				}
			}
			break;
		case 0x02:  // 5375 "E02" "XPRNT" "RXSS" 38 RPI-812
			psw_check = false;
			ins_setup_rxss();
			if (bd2_loc == 0) {
				bd2_loc = 133;
			}
			ast_file_line = sz390.get_ascii_string(xbd1_loc,bd2_loc,false);
			sz390.put_log(ast_file_line);
			if (ast_xprnt_tiot == -1) {
				ast_xprnt_tiot = sz390.ast_open_file("XPRNT",false,ast_xprnt_dcb);
				if (ast_xprnt_tiot == -1) {
					set_psw_check(Constants.psw_pic_io);
				}
			}
			if (ast_xprnt_tiot >= 0) {
				try {
					sz390.tiot_file[ast_xprnt_tiot].writeBytes(ast_file_line + tz390.newline);
				} catch (final Exception e) {
					set_psw_check(Constants.psw_pic_io);
				}
			}
			break;
		case 0x04:  // 5375 "E04" "XPNCH" "RXSS" 38 RPI-812
			psw_check = false;
			ins_setup_rxss();
			if (bd2_loc == 0) {
				bd2_loc = 80;
			}
			ast_file_line = sz390.get_ascii_string(xbd1_loc,bd2_loc,false);
			if (ast_xpnch_tiot == -1) {
				ast_xpnch_tiot = sz390.ast_open_file("XPNCH",false,ast_xpnch_dcb);
				if (ast_xpnch_tiot == -1) {
					set_psw_check(Constants.psw_pic_io);
				}
			}
			if (ast_xpnch_tiot >= 0) {
				try {
					sz390.tiot_file[ast_xpnch_tiot].writeBytes(ast_file_line + tz390.newline);
				} catch (final Exception e) {
					set_psw_check(Constants.psw_pic_io);
				}
			}
			break;
		case 0x06:  // 5375 "E06" "XDUMP" "RXSS" 38 RPI-812
			psw_check = false;
			ins_setup_rxss();
			sz390.dump_gpr(-1);
			sz390.dump_fpr(-1);
			if (bd2_loc == 0) {
				// dump default regs and area
				if (ast_xdump_len != 0) {
					sz390.dump_mem(mem,ast_xdump_addr,ast_xdump_len);
				} else {
					sz390.dump_mem(mem,0,tot_mem);
				}
			} else {
				sz390.dump_mem(mem,xbd1_loc,bd2_loc);
			}
			break;
		case 0x08:  // 5375 "E08" "XLIMD" "RXSS" 38 RPI-812
			psw_check = false;
			ins_setup_rxss();
			ast_xdump_addr = xbd1_loc;
			ast_xdump_len  = bd2_loc;
			break;
		case 0x0A:  // 5375 "E0A" "XGET" "RXSS" 38 RPI-812
			psw_check = false;
			ins_setup_rxss();
			psw_cc = psw_cc0;
			if (bd2_loc == 0) {
				psw_cc = psw_cc2;
				break;
			}
			if (ast_xget_tiot < 0) {
				if (ast_xget_tiot == -1) {
					ast_xget_tiot = sz390.ast_open_file("XGET",true,ast_xget_dcb);
				}
				if (ast_xget_tiot < 0) {
					ast_xget_tiot = -2; // prevent mult open errors
					psw_cc = psw_cc3;
				}
			}
			if (ast_xget_tiot >= 0) {
				try {
					ast_file_line = sz390.tiot_file[ast_xget_tiot].readLine();
					if (ast_file_line == null) {
						sz390.ast_close_file(ast_xget_tiot);
						ast_xget_tiot = -1;
						psw_cc = psw_cc1;
					} else {
						sz390.put_ascii_string(ast_file_line,xbd1_loc,bd2_loc,' ');
					}
				} catch (final Exception e) {
					psw_cc = psw_cc2;
				}
			}
			break;
		case 0x0C:  // 5375 "E0C" "XPUT" "RXSS" 38 RPI-812
			psw_check = false;
			ins_setup_rxss();
			psw_cc = psw_cc0;
			if (bd2_loc == 0) {
				psw_cc = psw_cc2;
				break;
			}
			ast_file_line = sz390.get_ascii_string(xbd1_loc,bd2_loc,false);
			if (ast_xput_tiot < 0) {
				if (ast_xput_tiot == -1) {
					ast_xput_tiot = sz390.ast_open_file("XPUT",false,ast_xput_dcb);
				}
				if (ast_xput_tiot < 0) {
					psw_cc = psw_cc3;
					ast_xput_tiot = -2; // prevent opens and just log
				}
			}
			if (ast_xput_tiot >= 0) {
				try {
					sz390.tiot_file[ast_xput_tiot].writeBytes(ast_file_line + tz390.newline);
				} catch (final Exception e) {
					psw_cc = psw_cc2;
				}
			}
			break;
		}
	}

	/**
	 *
	 */
	private void ins_E3XX() // RPI-1207
	{
		opcode2 = mem_byte[psw_loc + opcode2_offset_rxy] & 0xff;
		switch (opcode2) {
		case 0x02: // 5810 "E302" "LTG" "RXY" Z9-42
			psw_check = false;
			ins_setup_rxy();
			rlv1 = mem.getLong(xbd2_loc);
			reg.putLong(rf1, rlv1);
			psw_cc = get_long_comp_cc(rlv1, 0);
			break;
		case 0x03: // 5400 "E303" "LRAG" "RXY"
			ins_setup_rxy();
			break;
		case 0x04: // 5410 "E304" "LG" "RXY"
			psw_check = false;
			ins_setup_rxy();
			reg.putLong(rf1, mem.getLong(xbd2_loc));
			break;
		case 0x06: // 5420 "E306" "CVBY" "RXY"
			psw_check = false;
			ins_setup_rxy();
			if (get_pd(mem,xbd2_loc, 8)) { // RPI-305
				if (pdf_is_big) { // RPI-389
					if (pdf_big_int.compareTo(bi_max_pos_int) <= 0  // RPI-781
							&& pdf_big_int.compareTo(bi_min_neg_int) >= 0) {
							reg.putInt(rf1 + 4, pdf_big_int.intValue());
						} else {
							set_psw_check(Constants.psw_pic_fx_div);
						}
				} else {
					if (pdf_long <= max_pos_int && pdf_long >= min_neg_int) {
						reg.putInt(rf1 + 4, (int) pdf_long);
					} else {
						set_psw_check(Constants.psw_pic_fx_div);
					}
				}
			}
			break;
		case 0x08: // 5430 "E308" "AG" "RXY"
			psw_check = false;
			ins_setup_rxy();
			rlv1 = reg.getLong(rf1);
			rlv2 = mem.getLong(xbd2_loc);
			rlv3 = rlv1 + rlv2;
			reg.putLong(rf1, rlv3);
			psw_cc = get_long_add_cc();
			break;
		case 0x09: // 5440 "E309" "SG" "RXY"
			psw_check = false;
			ins_setup_rxy();
			rlv1 = reg.getLong(rf1);
			rlv2 = mem.getLong(xbd2_loc);
			rlv3 = rlv1 - rlv2;
			reg.putLong(rf1, rlv3);
			psw_cc = get_long_sub_cc();
			break;
		case 0x0A: // 5450 "E30A" "ALG" "RXY"
			psw_check = false;
			ins_setup_rxy();
			rlvw = reg.getLong(rf1);
			rlv2 = mem.getLong(xbd2_loc);
			rlv1 = rlvw + rlv2;
			reg.putLong(rf1, rlv1);
			psw_cc = get_long_log_add_cc();
			break;
		case 0x0B: // 5460 "E30B" "SLG" "RXY"
			psw_check = false;
			ins_setup_rxy();
			rlvw = reg.getLong(rf1);
			rlv2 = mem.getLong(xbd2_loc);
			rlv1 = rlvw - rlv2;
			reg.putLong(rf1, rlv1);
			psw_cc = get_long_log_sub_cc();
			break;
		case 0x0C: // 5470 "E30C" "MSG" "RXY"
			psw_check = false;
			ins_setup_rxy();
			reg.putLong(rf1, reg.getLong(rf1) * mem.getLong(xbd2_loc));
			break;
		case 0x0D: // 5480 "E30D" "DSG" "RXY"
			psw_check = false;
			ins_setup_rxy();
			if ((mf1 & 1) != 0) { // RPI-758
				set_psw_check(Constants.psw_pic_spec);
			}
			rlv1 = reg.getLong(rf1 + 8);
			rlv2 = mem.getLong(xbd2_loc);
			if (rlv2 != 0) {
				rlvw = rlv1 / rlv2;
			} else {
				set_psw_check(Constants.psw_pic_fx_div);
				break;
			}
			rlv1 = rlv1 - rlvw * rlv2;
			reg.putLong(rf1, rlv1);
			reg.putLong(rf1 + 8, rlvw);
			break;
		case 0x0E: // 5490 "E30E" "CVBG" "RXY"
			psw_check = false;
			ins_setup_rxy();
			if (get_pd(mem,xbd2_loc, 16)) { // RPI-305
				if (pdf_is_big) {  // RPI-781
					if (pdf_big_int.compareTo(bi_max_pos_long) != 1
						&& pdf_big_int.compareTo(bi_min_neg_long) != -1) {
						reg.putLong(rf1, pdf_big_int.longValue());
					} else {
						set_psw_check(Constants.psw_pic_fx_div);
					}
				} else {
					reg.putLong(rf1, pdf_long);
				}
			}
			break;
		case 0x0F: // 5500 "E30F" "LRVG" "RXY"
			psw_check = false;
			ins_setup_rxy();
			rflen = 7;
			while (rflen >= 0) {
				reg.put(rf1 + rflen, mem_byte[xbd2_loc + 7 - rflen]);
				rflen--;
			}
			break;
		case 0x12: // 5930 "E312" "LT" "RXY" Z9-43
			psw_check = false;
			ins_setup_rxy();
			rv1 = mem.getInt(xbd2_loc);
			reg.putInt(rf1 + 4, rv1);
			psw_cc = get_int_comp_cc(rv1, 0);
			break;
		case 0x13: // 5510 "E313" "LRAY" "RXY"
			ins_setup_rxy();
			break;
		case 0x14: // 5520 "E314" "LGF" "RXY"
			psw_check = false;
			ins_setup_rxy();
			reg.putLong(rf1, mem.getInt(xbd2_loc));
			break;
		case 0x15: // 5530 "E315" "LGH" "RXY"
			psw_check = false;
			ins_setup_rxy();
			reg.putLong(rf1, mem.getShort(xbd2_loc));
			break;
		case 0x16: // 5540 "E316" "LLGF" "RXY"
			psw_check = false;
			ins_setup_rxy();
			reg.putLong(rf1, (long) mem.getInt(xbd2_loc) & long_low32_bits);
			break;
		case 0x17: // 5550 "E317" "LLGT" "RXY"
			psw_check = false;
			ins_setup_rxy();
			reg.putLong(rf1, mem.getInt(xbd2_loc) & max_pos_int); // RPI-160 - was LOC+4
			break;
		case 0x18: // 5560 "E318" "AGF" "RXY"
			psw_check = false;
			ins_setup_rxy();
			rlv1 = reg.getLong(rf1);
			rlv2 = mem.getInt(xbd2_loc);
			rlv3 = rlv1 + rlv2;
			reg.putLong(rf1, rlv3);
			psw_cc = get_long_add_cc();
			break;
		case 0x19: // 5570 "E319" "SGF" "RXY"
			psw_check = false;
			ins_setup_rxy();
			rlv1 = reg.getLong(rf1);
			rlv2 = mem.getInt(xbd2_loc);
			rlv3 = rlv1 - rlv2;
			reg.putLong(rf1, rlv3);
			psw_cc = get_long_sub_cc();
			break;
		case 0x1A: // 5580 "E31A" "ALGF" "RXY"
			psw_check = false;
			ins_setup_rxy();
			rlvw = reg.getLong(rf1);
			rlv2 = ((long) mem.getInt(xbd2_loc) & long_low32_bits);
			rlv1 = rlvw + rlv2;
			reg.putLong(rf1, rlv1);
			psw_cc = get_long_log_add_cc();
			break;
		case 0x1B: // 5590 "E31B" "SLGF" "RXY"
			psw_check = false;
			ins_setup_rxy();
			rlvw = reg.getLong(rf1);
			rlv2 = (long) mem.getInt(xbd2_loc) & long_low32_bits;
			rlv1 = rlvw - rlv2;
			reg.putLong(rf1, rlv1);
			psw_cc = get_long_log_sub_cc();
			break;
		case 0x1C: // 5600 "E31C" "MSGF" "RXY"
			psw_check = false;
			ins_setup_rxy();
			reg.putLong(rf1, reg.getLong(rf1) * mem.getInt(xbd2_loc));
			break;
		case 0x1D: // 5610 "E31D" "DSGF" "RXY"
			psw_check = false;
			ins_setup_rxy();
			if ((mf1 & 1) != 0) { // RPI-758
				set_psw_check(Constants.psw_pic_spec);
			}
			rlv1 = reg.getLong(rf1 + 8);
			rlv2 = (long) mem.getInt(xbd2_loc);
			if (rlv2 != 0) {
				rlvw = rlv1 / rlv2;
			} else {
				set_psw_check(Constants.psw_pic_fx_div);
				break;
			}
			rlv1 = rlv1 - rlvw * rlv2;
			reg.putLong(rf1, rlv1);
			reg.putLong(rf1 + 8, rlvw);
			break;
		case 0x1E: // 5620 "E31E" "LRV" "RXY"
			psw_check = false; // RPI-173
			ins_setup_rxy();
			rflen = 3;
			while (rflen >= 0) {
				reg.put(rf1 + 4 + rflen, mem_byte[xbd2_loc + 3 - rflen]);
				rflen--;
			}
			break;
		case 0x1F: // 5630 "E31F" "LRVH" "RXY"
			psw_check = false;
			ins_setup_rxy();
			rflen = 1;
			while (rflen >= 0) {
				reg.put(rf1 + 6 + rflen, mem_byte[xbd2_loc + 1 - rflen]);
				rflen--;
			}
			break;
		case 0x20: // 5640 "E320" "CG" "RXY"
			psw_check = false;
			ins_setup_rxy();
			psw_cc = get_long_comp_cc(reg.getLong(rf1), mem
					.getLong(xbd2_loc));
			break;
		case 0x21: // 5650 "E321" "CLG" "RXY"
			psw_check = false;
			ins_setup_rxy();
			psw_cc = get_long_log_comp_cc(reg.getLong(rf1), mem
					.getLong(xbd2_loc));
			break;
		case 0x24: // 5660 "E324" "STG" "RXY"
			psw_check = false;
			ins_setup_rxy();
			mem.putLong(xbd2_loc & psw_amode, reg.getLong(rf1));
			break;
		case 0x26: // 5670 "E326" "CVDY" "RXY"
			psw_check = false;
			ins_setup_rxy();
			// big_int = BigInteger.valueOf(reg.getInt(rf1 + 4)); // JBA - unused
			put_pd(mem_byte, xbd2_loc, 8);
			break;
		case 0x2E: // 5680 "E32E" "CVDG" "RXY"
			psw_check = false;
			ins_setup_rxy();
			pdf_is_big = false; // RPI-389
			pdf_long = reg.getLong(rf1);
			put_pd(mem_byte, xbd2_loc, 16);
			break;
		case 0x2F: // 5690 "E32F" "STRVG" "RXY"
			psw_check = false;
			ins_setup_rxy();
			rflen = 7;
			while (rflen >= 0) {
				mem_byte[xbd2_loc + rflen] = reg.get(rf1 + 7 - rflen);
				rflen--;
			}
			break;
		case 0x30: // 5700 "E330" "CGF" "RXY"
			psw_check = false;
			ins_setup_rxy();
			psw_cc = get_long_comp_cc(reg.getLong(rf1), (long) mem.getInt(xbd2_loc));
			break;
		case 0x31: // 5710 "E331" "CLGF" "RXY"
			psw_check = false;
			ins_setup_rxy();
			psw_cc = get_long_log_comp_cc(reg.getLong(rf1), (long) mem.getInt(xbd2_loc) & long_low32_bits);
			break;
		case 0x32:  // 310 "E332" "LTGF" "RXY" 18 RPI-817
			psw_check = false;
			ins_setup_rxy();
			rv1 = mem.getInt(xbd2_loc);
			reg.putLong(rf1,rv1);
			psw_cc = get_int_comp_cc(rv1,0);
			break;
		case 0x34:  // 320 "E334" "CGH" "RXY" 18 RPI-817
			psw_check = false;
			ins_setup_rxy();
			psw_cc = get_long_comp_cc(reg.getLong(rf1), (long) mem.getShort(xbd2_loc));
			break;
		case 0x36:  // 330 "E336" "PFD" "RXY" 18 RPI-817
			psw_check = false;
			ins_setup_rxy(); // othing to do but trace
			break;
		case 0x3E: // 5720 "E33E" "STRV" "RXY"
			psw_check = false;
			ins_setup_rxy();
			rflen = 3;
			while (rflen >= 0) {
				mem_byte[xbd2_loc + rflen] = reg.get(rf1 + 7 - rflen);
				rflen--;
			}
			break;
		case 0x3F: // 5730 "E33F" "STRVH" "RXY"
			psw_check = false;
			ins_setup_rxy();
			rflen = 1;
			while (rflen >= 0) {
				mem_byte[xbd2_loc + rflen] = reg.get(rf1 + 7 - rflen);
				rflen--;
			}
			break;
		case 0x46: // 5740 "E346" "BCTG" "RXY"
			psw_check = false;
			ins_setup_rxy();
			rlv1 = reg.getLong(rf1) - 1;
			reg.putLong(rf1, rlv1);
			if (rlv1 != 0) {
				set_psw_loc(xbd2_loc);
			}
			break;
		case 0x50: // 5750 "E350" "STY" "RXY"
			ins_setup_rxy();
			psw_check = false;
			mem.putInt(xbd2_loc, reg.getInt(rf1 + 4));
			break;
		case 0x51: // 5760 "E351" "MSY" "RXY"
			psw_check = false;
			ins_setup_rxy();
			reg.putInt(rf1 + 4, reg.getInt(rf1 + 4) * mem.getInt(xbd2_loc));
			break;
		case 0x54: // 5770 "E354" "NY" "RXY"
			psw_check = false;
			ins_setup_rxy();
			rv1 = reg.getInt(rf1 + 4) & mem.getInt(xbd2_loc);
			reg.putInt(rf1 + 4, rv1);
			if (rv1 == 0) {
				psw_cc = psw_cc0;
			} else {
				psw_cc = psw_cc1;
			}
			break;
		case 0x55: // 5780 "E355" "CLY" "RXY"
			psw_check = false;
			ins_setup_rxy();
			psw_cc = get_int_log_comp_cc(reg.getInt(rf1 + 4), mem.getInt(xbd2_loc));
			break;
		case 0x56: // 5790 "E356" "OY" "RXY"
			psw_check = false;
			ins_setup_rxy();
			rv1 = reg.getInt(rf1 + 4) | mem.getInt(xbd2_loc);
			reg.putInt(rf1 + 4, rv1);
			if (rv1 == 0) {
				psw_cc = psw_cc0;
			} else {
				psw_cc = psw_cc1;
			}
			break;
		case 0x57: // 5800 "E357" "XY" "RXY"
			psw_check = false;
			ins_setup_rxy();
			rv1 = reg.getInt(rf1 + 4) ^ mem.getInt(xbd2_loc);
			reg.putInt(rf1 + 4, rv1);
			if (rv1 == 0) {
				psw_cc = psw_cc0;
			} else {
				psw_cc = psw_cc1;
			}
			break;
		case 0x58: // 5810 "E358" "LY" "RXY"
			psw_check = false;
			ins_setup_rxy();
			reg.putInt(rf1 + 4, mem.getInt(xbd2_loc));
			break;
		case 0x59: // 5820 "E359" "CY" "RXY"
			psw_check = false;
			ins_setup_rxy();
			psw_cc = get_int_comp_cc(reg.getInt(rf1 + 4), mem.getInt(xbd2_loc));
			break;
		case 0x5A: // 5830 "E35A" "AY" "RXY"
			psw_check = false;
			ins_setup_rxy();
			rv1 = reg.getInt(rf1 + 4);
			rv2 = mem.getInt(xbd2_loc);
			rv3 = rv1 + rv2;
			reg.putInt(rf1 + 4, rv3);
			psw_cc = get_int_add_cc();
			break;
		case 0x5B: // 5840 "E35B" "SY" "RXY"
			psw_check = false;
			ins_setup_rxy();
			rv1 = reg.getInt(rf1 + 4);
			rv2 = mem.getInt(xbd2_loc);
			rv3 = rv1 - rv2;
			reg.putInt(rf1 + 4, rv3);
			psw_cc = get_int_sub_cc();
			break;
		case 0x5C:  // 340 "E35C" "MFY" "RXY" 18 RPI-817
			psw_check = false;
			ins_setup_rxy();
			if ((mf1 & 0x1) != 0) {
				set_psw_check(Constants.psw_pic_spec);
			}
			rlv1 = reg.getInt(rf1 + 12);
			rlv2 = mem.getInt(xbd2_loc);
			rlv3 = rlv1 * rlv2;
			reg.putInt(rf1+4,(int)(rlv3 >> 32));
			reg.putInt(rf1+12,(int)(rlv3));
			break;
		case 0x5E: // 5850 "E35E" "ALY" "RXY"
			psw_check = false;
			ins_setup_rxy();
			rvw = reg.getInt(rf1 + 4);
			rv2 = mem.getInt(xbd2_loc);
			rv1 = rvw + rv2;
			reg.putInt(rf1 + 4, rv1);
			psw_cc = get_int_log_add_cc();
			break;
		case 0x5F: // 5860 "E35F" "SLY" "RXY"
			psw_check = false;
			ins_setup_rxy();
			rvw = reg.getInt(rf1 + 4);
			rv2 = mem.getInt(xbd2_loc);
			rv1 = rvw - rv2;
			reg.putInt(rf1 + 4, rv1);
			psw_cc = get_int_log_sub_cc();
			break;
		case 0x70: // 5870 "E370" "STHY" "RXY"
			psw_check = false;
			ins_setup_rxy();
			mem.putShort(xbd2_loc, (short) reg.getInt(rf1 + 4));
			break;
		case 0x71: // 5880 "E371" "LAY" "RXY"
			psw_check = false;
			ins_setup_rxy();
			reg.putInt(rf1 + 4, xbd2_loc & psw_amode);
			break;
		case 0x72: // 5890 "E372" "STCY" "RXY"
			psw_check = false;
			ins_setup_rxy();
			mem_byte[xbd2_loc] = reg.get(rf1 + 4 + 3);
			break;
		case 0x73: // 5900 "E373" "ICY" "RXY"
			psw_check = false;
			ins_setup_rxy();
			reg.put(rf1 + 7, mem_byte[xbd2_loc]);
			break;
		case 0x75:  // 350 "E375" "LAEY" "RXY" 18 RPI-817
			psw_check = false;
			ins_setup_rxy();
			reg.putInt(rf1+4,xbd2_loc);
			break;
		case 0x76: // 5910 "E376" "LB" "RXY"
			psw_check = false;
			ins_setup_rxy();
			reg.putInt(rf1 + 4, mem_byte[xbd2_loc]);
			break;
		case 0x77: // 5920 "E377" "LGB" "RXY"
			psw_check = false;
			ins_setup_rxy();
			reg.putLong(rf1, mem_byte[xbd2_loc]);
			break;
		case 0x78: // 5930 "E378" "LHY" "RXY"
			psw_check = false;
			ins_setup_rxy();
			reg.putInt(rf1 + 4, mem.getShort(xbd2_loc));
			break;
		case 0x79: // 5940 "E379" "CHY" "RXY"
			psw_check = false;
			ins_setup_rxy();
			psw_cc = get_int_comp_cc(reg.getInt(rf1 + 4), mem.getShort(xbd2_loc));
			break;
		case 0x7A: // 5950 "E37A" "AHY" "RXY"
			psw_check = false;
			ins_setup_rxy();
			rv1 = reg.getInt(rf1 + 4);
			rv2 = mem.getShort(xbd2_loc);
			rv3 = rv1 + rv2;
			reg.putInt(rf1 + 4, rv3);
			psw_cc = get_int_add_cc();
			break;
		case 0x7B: // 5960 "E37B" "SHY" "RXY"
			psw_check = false;
			ins_setup_rxy();
			rv1 = reg.getInt(rf1 + 4);
			rv2 = mem.getShort(xbd2_loc);
			rv3 = rv1 - rv2;
			reg.putInt(rf1 + 4, rv3);
			psw_cc = get_int_sub_cc();
			break;
		case 0x7C:  // 360 "E37C" "MHY" "RXY" 18 RPI-817
			psw_check = false;
			ins_setup_rxy();
			reg.putInt(rf1+4,reg.getInt(rf1+4) * mem.getShort(xbd2_loc));
			break;
		case 0x80: // 5970 "E380" "NG" "RXY"
			psw_check = false;
			ins_setup_rxy();
			rlv1 = reg.getLong(rf1) & mem.getLong(xbd2_loc);
			reg.putLong(rf1, rlv1);
			if (rlv1 == 0) {
				psw_cc = psw_cc0;
			} else {
				psw_cc = psw_cc1;
			}
			break;
		case 0x81: // 5980 "E381" "OG" "RXY"
			psw_check = false;
			ins_setup_rxy();
			rlv1 = reg.getLong(rf1) | mem.getLong(xbd2_loc);
			reg.putLong(rf1, rlv1);
			if (rlv1 == 0) {
				psw_cc = psw_cc0;
			} else {
				psw_cc = psw_cc1;
			}
			break;
		case 0x82: // 5990 "E382" "XG" "RXY"
			psw_check = false;
			ins_setup_rxy();
			rlv1 = reg.getLong(rf1) ^ mem.getLong(xbd2_loc);
			reg.putLong(rf1, rlv1);
			if (rlv1 == 0) {
				psw_cc = psw_cc0;
			} else {
				psw_cc = psw_cc1;
			}
			break;
		case 0x86: // 6000 "E386" "MLG" "RXY"
			psw_check = false;
			ins_setup_rxy();
			if ((mf1 & 1) != 0) { // RPI-758
				set_psw_check(Constants.psw_pic_spec);
			}
			big_int1 = new BigInteger(get_log_bytes(reg_byte, rf1 + 8, 8)); // RPI-383
			big_int2 = new BigInteger(get_log_bytes(mem_byte, xbd2_loc, 8));
			big_int1 = big_int1.multiply(big_int2);
			fp_bi_to_wreg(reg_byte,rf1,big_int1, 16); // RPI-540
			break;
		case 0x87: // 6010 "E387" "DLG" "RXY"
			psw_check = false;
			ins_setup_rxy();
			if ((mf1 & 1) != 0) { // RPI-758
				set_psw_check(Constants.psw_pic_spec);
			}
			big_int1 = new BigInteger(get_log_bytes(reg_byte, rf1, 16)); // RPI-540
			big_int2 = new BigInteger(get_log_bytes(mem_byte, xbd2_loc, 8));
			if (big_int2.signum() == 0) { // RPI-540
				set_psw_check(Constants.psw_pic_fx_div);
				break;
			}
			big_int_array = big_int1.divideAndRemainder(big_int2);
			if (big_int_array[0].bitLength() > 64) {
				set_psw_check(Constants.psw_pic_fx_ovf); // RPI-781
				break;
			}
			fp_bi_to_wreg(reg_byte,rf1  ,big_int_array[1], 8); // get remainder RPI-540
			fp_bi_to_wreg(reg_byte,rf1+8,big_int_array[0], 8); // get big quotient RPI-540
			break;
		case 0x88: // 6020 "E388" "ALCG" "RXY"
			psw_check = false;
			ins_setup_rxy();
			rlvw = reg.getLong(rf1);
			rlv2 = mem.getLong(xbd2_loc);
			rlv1 = rlvw + rlv2 + psw_carry[psw_cc];
			reg.putLong(rf1, rlv1);
			psw_cc = get_long_log_add_cc();
			break;
		case 0x89: // 6030 "E389" "SLBG" "RXY"
			psw_check = false;
			ins_setup_rxy();
			rlvw = reg.getLong(rf1);
			rlv2 = mem.getLong(xbd2_loc);
			rlv1 = rlvw - rlv2 - psw_borrow[psw_cc];
			reg.putLong(rf1, rlv1);
			psw_cc = get_long_log_sub_cc();
			break;
		case 0x8E: // 6040 "E38E" "STPQ" "RXY"
			psw_check = false;
			ins_setup_rxy();
			if ((mf1 & 1) != 0) { // RPI-758
				set_psw_check(Constants.psw_pic_spec);
			}
			mem.putLong(xbd2_loc, reg.getLong(rf1));
			mem.putLong(xbd2_loc + 8, reg.getLong(rf1 + 8));
			break;
		case 0x8F: // 6050 "E38F" "LPQ" "RXY"
			psw_check = false;
			ins_setup_rxy();
			if ((mf1 & 1) != 0) { // RPI-758
				set_psw_check(Constants.psw_pic_spec);
			}
			reg.putLong(rf1, mem.getLong(xbd2_loc));
			reg.putLong(rf1 + 8, mem.getLong(xbd2_loc + 8));
			break;
		case 0x90: // 6060 "E390" "LLGC" "RXY"
			psw_check = false;
			ins_setup_rxy();
			reg.putLong(rf1, mem_byte[xbd2_loc] & 0xff);
			break;
		case 0x91: // 6070 "E391" "LLGH" "RXY"
			psw_check = false;
			ins_setup_rxy();
			reg.putLong(rf1, mem.getShort(xbd2_loc) & 0xffff);
			break;
		case 0x94: // 6510 "E394" "LLC" "RXY" Z9-44
			psw_check = false;
			ins_setup_rxy();
			reg.putInt(rf1 + 4, mem.get(xbd2_loc) & 0xff);
			break;
		case 0x95: // 6520 "E395" "LLH" "RXY" Z9-45
			psw_check = false;
			ins_setup_rxy();
			reg.putInt(rf1 + 4, mem.getShort(xbd2_loc) & 0xffff);
			break;
		case 0x96: // 6080 "E396" "ML" "RXY"
			psw_check = false;
			ins_setup_rxy();
			if ((mf1 & 1) != 0) { // RPI-758
				set_psw_check(Constants.psw_pic_spec);
			}
			big_int1 = new BigInteger(get_log_bytes(reg_byte, rf1 + 12, 4)); // RPI-275
			big_int2 = new BigInteger(get_log_bytes(mem_byte, xbd2_loc, 4));
			big_int1 = big_int1.multiply(big_int2);
			fp_bi_to_wreg(work_reg_byte,0,big_int1, 8);
			reg.putInt(rf1 + 4, work_reg.getInt(0));
			reg.putInt(rf1 + 12, work_reg.getInt(4));
			break;
		case 0x97: // 6090 "E397" "DL" "RXY"
			psw_check = false;
			ins_setup_rxy();
			if ((mf1 & 1) != 0) { // RPI-758
				set_psw_check(Constants.psw_pic_spec);
			}
			work_reg.putInt(0, reg.getInt(rf1 + 4));
			work_reg.putInt(4, reg.getInt(rf1 + 12));
			big_int1 = new BigInteger(get_log_bytes(work_reg_byte, 0, 8));
			big_int2 = new BigInteger(get_log_bytes(mem_byte, xbd2_loc, 4));
			if (big_int2.signum() == 0) { // RPI-540
				set_psw_check(Constants.psw_pic_fx_div);
				break;
			}
			big_int_array = big_int1.divideAndRemainder(big_int2);
			fp_bi_to_wreg(reg_byte,rf1+ 4,big_int_array[1], 4); // RPI-540
			fp_bi_to_wreg(reg_byte,rf1+12,big_int_array[0], 4); // RPI-540
			break;
		case 0x98: // 6100 "E398" "ALC" "RXY"
			psw_check = false;
			ins_setup_rxy();
			rvw = reg.getInt(rf1 + 4);
			rv2 = mem.getInt(xbd2_loc);
			rv1 = rvw + rv2 + psw_carry[psw_cc];
			reg.putInt(rf1 + 4, rv1);
			psw_cc = get_int_log_add_cc();
			break;
		case 0x99: // 6110 "E399" "SLB" "RXY"
			psw_check = false;
			ins_setup_rxy();
			rvw = reg.getInt(rf1 + 4);
			rv2 = mem.getInt(xbd2_loc);
			rv1 = rvw - rv2 - psw_borrow[psw_cc];
			reg.putInt(rf1 + 4, rv1);
			psw_cc = get_int_log_sub_cc();
			break;
		case 0xC0: // "E3C0" "LBH" "RXY" 18 RPI-1125
			psw_check = false;
			ins_setup_rxy();
			reg.putInt(rf1, mem.get(xbd2_loc));
			break;
		case 0xC2: // "E3C2" "LLCH" "RXY" 18 RPI-1125
			psw_check = false;
			ins_setup_rxy();
			reg.putInt(rf1, mem.get(xbd2_loc) & 0xff);
			break;
		case 0xC3: // "E3C3" "STCH" "RXY" 18 RPI-1125
			psw_check = false;
			ins_setup_rxy();
			mem.put(xbd2_loc, reg.get(rf1+3));
			break;
		case 0xC4: // "E3C4" "LHH" "RXY" 18 RPI-1125
			psw_check = false;
			ins_setup_rxy();
			reg.putInt(rf1, mem.getShort(xbd2_loc));
			break;
		case 0xC6: // "E3C6" "LLHH" "RXY" 18 RPI-1125
			psw_check = false;
			ins_setup_rxy();
			reg.putInt(rf1, mem.getShort(xbd2_loc) & 0xffff);
			break;
		case 0xC7: // "E3C3" "STHH" "RXY" 18 RPI-1125
			psw_check = false;
			ins_setup_rxy();
			mem.putShort(xbd2_loc, reg.getShort(rf1+2));
			break;
		case 0xCA: // "E3CA" "LFH" "RXY" 18 RPI-1125
			psw_check = false;
			ins_setup_rxy();
			reg.putInt(rf1, mem.getInt(xbd2_loc));
			break;
		case 0xCB: // "E3CB" "STFH" "RXY" 18 RPI-1125
			psw_check = false;
			ins_setup_rxy();
			mem.putInt(xbd2_loc, reg.getInt(rf1));
			break;
		case 0xCD: // "E3CD" "CHF" "RXY" 18 RPI-1125
			psw_check = false;
			ins_setup_rxy();
			psw_cc = get_int_comp_cc(reg.getInt(rf1), mem.getInt(xbd2_loc));
			break;
		case 0xCF: // "E3CF" "CLHF" "RXY" 18 RPI-1125
			psw_check = false;
			ins_setup_rxy();
			psw_cc = get_int_log_comp_cc(reg.getInt(rf1), mem
					.getInt(xbd2_loc));
			break;
		}
	}

	/**
	 *
	 */
	private void ins_E5XX()
	{
		opcode2 = mem_byte[psw_loc + opcode2_offset_sse] & 0xff;
		switch (opcode2) {
		case 0x00: // 6120 "E500" "LASP" "SSE"
			ins_setup_sse();
			break;
		case 0x01: // 6130 "E501" "TPROT" "SSE"
			ins_setup_sse();
			break;
		case 0x02: // 6140 "E502" "STRAG" "SSE"
			ins_setup_sse();
			break;
		case 0x0E: // 6150 "E50E" "MVCSK" "SSE"
			ins_setup_sse();
			break;
		case 0x0F: // 6160 "E50F" "MVCDK" "SSE"
			ins_setup_sse();
			break;
		case 0x44:  // 370 "E544" "MVHHI" "SIL" 51 RPI-817
			psw_check = false;
			ins_setup_sil();
			mem.putShort(bd1_loc,(short)if2);
			break;
		case 0x48:  // 380 "E548" "MVGHI" "SIL" 51 RPI-817
			psw_check = false;
			ins_setup_sil();
			mem.putLong(bd1_loc,if2);
			break;
		case 0x4C:  // 390 "E54C" "MVHI" "SIL" 51 RPI-817
			psw_check = false;
			ins_setup_sil();
			mem.putInt(bd1_loc,if2);
			break;
		case 0x54:  // 400 "E554" "CHHSI" "SIL" 51 RPI-817
			psw_check = false;
			ins_setup_sil();
			psw_cc = get_int_comp_cc(mem.getShort(bd1_loc), if2);
			break;
		case 0x55:  // 410 "E555" "CLHHSI" "SIL" 51 RPI-817
			psw_check = false;
			ins_setup_sil();
			psw_cc = get_int_log_comp_cc(mem.getShort(bd1_loc) & 0xffff, if2 & 0xffff);
			break;
		case 0x58:  // 420 "E558" "CGHSI" "SIL" 51 RPI-817
			psw_check = false;
			ins_setup_sil();
			psw_cc = get_long_comp_cc(mem.getLong(bd1_loc), if2);
			break;
		case 0x59:  // 430 "E559" "CLGHSI" "SIL" 51 RPI-817
			psw_check = false;
			ins_setup_sil();
			psw_cc = get_long_log_comp_cc(mem.getLong(bd1_loc), if2 & 0xffff);
			break;
		case 0x5C:  // 440 "E55C" "CHSI" "SIL" 51 RPI-817
			psw_check = false;
			ins_setup_sil();
			psw_cc = get_int_comp_cc(mem.getInt(bd1_loc), if2);
			break;
		case 0x5D:  // 450 "E55D" "CLFHSI" "SIL" 51 RPI-817
			psw_check = false;
			ins_setup_sil();
			psw_cc = get_int_log_comp_cc(mem.getInt(bd1_loc), if2 & 0xffff);
			break;
		}
	}

	/**
	 *
	 */
	private void ins_EBXX()
	{
		opcode2 = mem_byte[psw_loc + opcode2_offset_rsy] & 0xff;
		switch (opcode2) {
		case 0x04: // 6200 "EB04" "LMG" "RSY"
			psw_check = false;
			ins_setup_rsy();
			if (rf1 > rf3) {
				while (rf1 < reg_len) {
					reg.putLong(rf1, mem.getLong(bd2_loc));
					bd2_loc = bd2_loc + 8;
					rf1 = rf1 + 8;
				}
				rf1 = 0;
			}
			while (rf1 <= rf3) {
				reg.putLong(rf1, mem.getLong(bd2_loc));
				bd2_loc = bd2_loc + 8;
				rf1 = rf1 + 8;
			}
			break;
		case 0x0A: // 6210 "EB0A" "SRAG" "RSY"
			psw_check = false;
			ins_setup_rsy_shift(); // RPI-1015
			rlv1 = reg.getLong(rf3) >> (bd2_loc & 0x3f);
			reg.putLong(rf1, rlv1);
			psw_cc = get_long_comp_cc(rlv1, 0);
			break;
		case 0x0B: // 6220 "EB0B" "SLAG" "RSY"
			psw_check = false;
			ins_setup_rsy_shift(); // RPI-1015
			reg.putLong(rf1, get_sla64(reg.getLong(rf3), bd2_loc & 0x3f));
			break;
		case 0x0C: // 6230 "EB0C" "SRLG" "RSY"
			psw_check = false;
			ins_setup_rsy_shift(); // RPI-1015
			reg.putLong(rf1, reg.getLong(rf3) >>> (bd2_loc & 0x3f));
			break;
		case 0x0D: // 6240 "EB0D" "SLLG" "RSY"
			psw_check = false;
			ins_setup_rsy_shift(); // RPI-1015
			reg.putLong(rf1, reg.getLong(rf3) << (bd2_loc & 0x3f));
			break;
		case 0x0F: // 6250 "EB0F" "TRACG" "RSY"
			ins_setup_rsy();
			break;
		case 0x14: // 6260 "EB14" "CSY" "RSY"
			psw_check = false;
			ins_setup_rsy();
			if (reg.getInt(rf1 + 4) == mem.getInt(bd2_loc)) {
				psw_cc = psw_cc0;
				mem.putInt(bd2_loc, reg.getInt(rf3 + 4));
			} else {
				psw_cc = psw_cc1;
				reg.putInt(rf1 + 4, mem.getInt(bd2_loc));
			}
			break;
		case 0x1C: // 6270 "EB1C" "RLLG" "RSY"
			psw_check = false;
			ins_setup_rsy_shift(); // RPI-820
			reg.putLong(rf1,long_rotate_left(reg.getLong(rf3),bd2_loc & 0x3f)); // RPI-820
			break;
		case 0x1D: // 6280 "EB1D" "RLL" "RSY"
			psw_check = false;
			ins_setup_rsy_shift();
			reg.putInt(rf1 + 4,int_rotate_left(reg.getInt(rf3 + 4),bd2_loc & 0x1f));
			break;
		case 0x20: // 6290 "EB20" "CLMH" "RSY"
			psw_check = false;
			ins_setup_rsy();
			rv1 = reg.getInt(rf1);
			exec_clm();
			break;
		case 0x21: // 6300 "EB21" "CLMY" "RSY"
			psw_check = false;
			ins_setup_rsy();
			rv1 = reg.getInt(rf1 + 4);
			exec_clm();
			break;
		case 0x24: // 6310 "EB24" "STMG" "RSY"
			psw_check = false;
			ins_setup_rsy();
			if (rf1 > rf3) {
				while (rf1 < reg_len) {
					mem.putLong(bd2_loc, reg.getLong(rf1));
					bd2_loc = bd2_loc + 8;
					rf1 = rf1 + 8;
				}
				rf1 = 0;
			}
			while (rf1 <= rf3) {
				mem.putLong(bd2_loc, reg.getLong(rf1));
				bd2_loc = bd2_loc + 8;
				rf1 = rf1 + 8;
			}
			break;
		case 0x25: // 6320 "EB25" "STCTG" "RSY"
			ins_setup_rsy();
			break;
		case 0x26: // 6330 "EB26" "STMH" "RSY"
			psw_check = false;
			ins_setup_rsy();
			if (rf1 > rf3) {
				while (rf1 < reg_len) {
					mem.putInt(bd2_loc, reg.getInt(rf1));
					bd2_loc = bd2_loc + 4;
					rf1 = rf1 + 8;
				}
				rf1 = 0;
			}
			while (rf1 <= rf3) {
				mem.putInt(bd2_loc, reg.getInt(rf1));
				bd2_loc = bd2_loc + 4;
				rf1 = rf1 + 8;
			}
			break;
		case 0x2C: // 6340 "EB2C" "STCMH" "RSY"
			psw_check = false;
			ins_setup_rsy();
			rv1 = reg.getInt(rf1);
			exec_stcm();
			break;
		case 0x2D: // 6350 "EB2D" "STCMY" "RSY"
			psw_check = false;
			ins_setup_rsy();
			rv1 = reg.getInt(rf1 + 4);
			exec_stcm();
			break;
		case 0x2F: // 6360 "EB2F" "LCTLG" "RSY"
			ins_setup_rsy();
			break;
		case 0x30: // 6370 "EB30" "CSG" "RSY"
			psw_check = false;
			ins_setup_rsy();
			if (reg.getLong(rf1) == mem.getLong(bd2_loc)) {
				psw_cc = psw_cc0;
				mem.putLong(bd2_loc, reg.getLong(rf3));
			} else {
				psw_cc = psw_cc1;
				reg.putLong(rf1, mem.getLong(bd2_loc));
			}
			break;
		case 0x31: // 6380 "EB31" "CDSY" "RSY"
			psw_check = false;
			ins_setup_rsy();
			if ((mf1 & 1) != 0) { // RPI-758
				set_psw_check(Constants.psw_pic_spec);
			}
			if (reg.getInt(rf1 + 4) == mem.getInt(bd2_loc)
					&& reg.getInt(rf1 + 12) == mem.getInt(bd2_loc + 4)) {
				psw_cc = psw_cc0;
				mem.putInt(bd2_loc, reg.getInt(rf3 + 4));
				mem.putInt(bd2_loc + 4, reg.getInt(rf3 + 12));
			} else {
				psw_cc = psw_cc1;
				reg.putInt(rf1 + 4, mem.getInt(bd2_loc));
				reg.putInt(rf1 + 12, mem.getInt(bd2_loc + 4));
			}
			break;
		case 0x3E: // 6390 "EB3E" "CDSG" "RSY"
			psw_check = false;
			ins_setup_rsy();
			if ((mf1 & 1) != 0) { // RPI-758
				set_psw_check(Constants.psw_pic_spec);
			}
			if (reg.getLong(rf1) == mem.getLong(bd2_loc)
					&& reg.getLong(rf1 + 8) == mem.getLong(bd2_loc + 8)) {
				psw_cc = psw_cc0;
				mem.putLong(bd2_loc, reg.getLong(rf3));
				mem.putLong(bd2_loc + 8, reg.getLong(rf3 + 8));
			} else {
				psw_cc = psw_cc1;
				reg.putLong(rf1, mem.getLong(bd2_loc));
				reg.putLong(rf1 + 8, mem.getLong(bd2_loc + 8));
			}
			break;
		case 0x44: // 6400 "EB44" "BXHG" "RSY"
			psw_check = false;
			ins_setup_rsy();
			rlv3 = reg.getLong(rf3);
			rlv1 = reg.getLong(rf1) + rlv3;
			reg.putLong(rf1, rlv1);
			if (rf3 == ((rf3 >> 4) << 4)) {
				rlv3 = reg.getLong(rf3 + 8);
			}
			if (rlv1 > rlv3) {
				set_psw_loc(bd2_loc);
			}
			break;
		case 0x45: // 6410 "EB45" "BXLEG" "RSY"
			psw_check = false;
			ins_setup_rsy();
			rlv3 = reg.getLong(rf3);
			rlv1 = reg.getLong(rf1) + rlv3;
			reg.putLong(rf1, rlv1);
			if (rf3 == ((rf3 >> 4) << 4)) {
				rlv3 = reg.getLong(rf3 + 8);
			}
			if (rlv1 <= rlv3) {
				set_psw_loc(bd2_loc);
			}
			break;
		case 0x4C:  // 460 "EB4C" "ECAG" "RSY" 20 RPI-817
			ins_setup_rsy();
			break;
		case 0x51: // 6420 "EB51" "TMY" "SIY"
			psw_check = false;
			ins_setup_siy();
			psw_cc = get_tm_mem_cc(mem_byte[bd1_loc],if2); // RPI-844
			break;
		case 0x52: // 6430 "EB52" "MVIY" "SIY"
			psw_check = false;
			ins_setup_siy();
			mem_byte[bd1_loc] = (byte) if2;
			break;
		case 0x54: // 6440 "EB54" "NIY" "SIY"
			psw_check = false;
			ins_setup_siy();
			sv1 = mem_byte[bd1_loc] & if2;
			mem_byte[bd1_loc] = (byte) sv1;
			if (sv1 == 0) {
				psw_cc = psw_cc0;
			} else {
				psw_cc = psw_cc1;
			}
			break;
		case 0x55: // 6450 "EB55" "CLIY" "SIY"
			psw_check = false;
			ins_setup_siy();
			psw_cc = get_int_comp_cc((mem_byte[bd1_loc]) & 0xff, if2 & 0xff);  // RPI-875
			break;
		case 0x56: // 6460 "EB56" "OIY" "SIY"
			psw_check = false;
			ins_setup_siy();
			sv1 = mem_byte[bd1_loc] | if2;
			mem_byte[bd1_loc] = (byte) sv1;
			if (sv1 == 0) {
				psw_cc = psw_cc0;
			} else {
				psw_cc = psw_cc1;
			}
			break;
		case 0x57: // 6470 "EB57" "XIY" "SIY"
			psw_check = false;
			ins_setup_siy();
			sv1 = mem_byte[bd1_loc] ^ if2;
			mem_byte[bd1_loc] = (byte) sv1;
			if (sv1 == 0) {
				psw_cc = psw_cc0;
			} else {
				psw_cc = psw_cc1;
			}
			break;
		case 0x6A:  // 470 "EB6A" "ASI" "SIY" 21 RPI-817
			psw_check = false;
			ins_setup_siy();
			rv1 = mem.getInt(bd1_loc);
			rv2 = if2;
			rv3 = rv1 + rv2;
			mem.putInt(bd1_loc, rv3);
			psw_cc = get_int_add_cc();
			break;
		case 0x6E:  // 480 "EB6E" "ALSI" "SIY" 21 RPI-817
			psw_check = false;
			ins_setup_siy();
			rvw = mem.getInt(bd1_loc);
			rv2 = if2; // RPI-859
			rv1 = rvw + rv2;
			mem.putInt(bd1_loc, rv1);
			psw_cc = get_int_lsi_add_cc(); // RPI-1125
			break;
		case 0x7A:  // 490 "EB7A" "AGSI" "SIY" 21 RPI-817
			psw_check = false;
			ins_setup_siy();
			rlv1 = mem.getLong(bd1_loc);
			rlv2 = if2;
			rlv3 = rlv1 + rlv2;
			mem.putLong(bd1_loc, rlv3);
			psw_cc = get_long_add_cc();
			break;
		case 0x7E:  // 500 "EB7E" "ALGSI" "SIY" 21 RPI-817
			psw_check = false;
			ins_setup_siy();
			rlvw = mem.getLong(bd1_loc);
			rlv2 = if2; // RPI-859
			rlv1 = rlvw + rlv2;
			mem.putLong(bd1_loc, rlv1);
			psw_cc = get_long_lsi_add_cc(); // RPI-1125
			break;
		case 0x80: // 6480 "EB80" "ICMH" "RSY"
			psw_check = false;
			ins_setup_rsy();
			rv1 = reg.getInt(rf1);
			exec_icm();
			reg.putInt(rf1, rv1);
			break;
		case 0x81: // 6490 "EB81" "ICMY" "RSY"
			psw_check = false;
			ins_setup_rsy();
			rv1 = reg.getInt(rf1 + 4);
			exec_icm();
			reg.putInt(rf1 + 4, rv1);
			break;
		case 0x8E: // 6500 "EB8E" "MVCLU" "RSY"
			ins_setup_rsy();
			break;
		case 0x8F: // 6510 "EB8F" "CLCLU" "RSY"
			ins_setup_rsy();
			break;
		case 0x90: // 6520 "EB90" "STMY" "RSY"
			psw_check = false;
			ins_setup_rsy();
			if (rf1 > rf3) {
				while (rf1 < reg_len) {
					mem.putInt(bd2_loc, reg.getInt(rf1 + 4));
					bd2_loc = bd2_loc + 4;
					rf1 = rf1 + 8;
				}
				rf1 = 0;
			}
			while (rf1 <= rf3) {
				mem.putInt(bd2_loc, reg.getInt(rf1 + 4));
				bd2_loc = bd2_loc + 4;
				rf1 = rf1 + 8;
			}
			break;
		case 0x96: // 6530 "EB96" "LMH" "RSY"
			psw_check = false;
			ins_setup_rsy();
			if (rf1 > rf3) {
				while (rf1 < reg_len) {
					reg.putInt(rf1, mem.getInt(bd2_loc));
					bd2_loc = bd2_loc + 4;
					rf1 = rf1 + 8;
				}
				rf1 = 0;
			}
			while (rf1 <= rf3) {
				reg.putInt(rf1, mem.getInt(bd2_loc));
				bd2_loc = bd2_loc + 4;
				rf1 = rf1 + 8;
			}
			break;
		case 0x98: // 6540 "EB98" "LMY" "RSY"
			psw_check = false;
			ins_setup_rsy();
			if (rf1 > rf3) {
				while (rf1 < reg_len) {
					reg.putInt(rf1 + 4, mem.getInt(bd2_loc));
					bd2_loc = bd2_loc + 4;
					rf1 = rf1 + 8;
				}
				rf1 = 0;
			}
			while (rf1 <= rf3) {
				reg.putInt(rf1 + 4, mem.getInt(bd2_loc));
				bd2_loc = bd2_loc + 4;
				rf1 = rf1 + 8;
			}
			break;
		case 0x9A: // 6550 "EB9A" "LAMY" "RSY"
			ins_setup_rsy();
			break;
		case 0x9B: // 6560 "EB9B" "STAMY" "RSY"
			ins_setup_rsy();
			break;
		case 0xC0: // 6570 "EBC0" "TP" "RSL"
			psw_check = false;
			ins_setup_rsl();
			get_pd(mem,bd1_loc, rflen1);
			psw_cc = pd_cc;
			break;
		case 0xDC: //  "EBDC","SRAK","RSY  "  20 RPI-1125 Z196
			psw_check = false;
			ins_setup_rsy_shift(); // RPI-1015
			rv1 = reg.getInt(rf3+4) >> (bd2_loc & 0x3f);
			reg.putInt(rf1+4, rv1);
			psw_cc = get_int_comp_cc(rv1, 0);
			break;
			case 0xDD: //  "EBDD","SLAK","RSY  "  20 RPI-1125 Z196
				psw_check = false;
				ins_setup_rsy_shift(); // RPI-1015
				reg.putInt(rf1 + 4, get_sla32(reg.getInt(rf3 + 4), bd2_loc & 0x3f));
				break;
			case 0xDE: //  "EBDE","SRLK","RSY  "  20 RPI-1125 Z196
				psw_check = false;
				ins_setup_rsy_shift(); // RPI-1015
				reg.putInt(rf1+4, reg.getInt(rf3+4) >>> (bd2_loc & 0x3f));
				break;
			case 0xDF: //  //  "EBDF","SLLK","RSY  "  20 RPI-1125 Z196
				psw_check = false;
				ins_setup_rsy_shift(); // RPI-1015
				reg.putInt(rf1+4, reg.getInt(rf3+4) << (bd2_loc & 0x3f));
				break;
			case 0xE2: //  "EBE2","LOCG","RSY2 "  20 RPI-1125 Z196
				psw_check = false;
				ins_setup_rsy();
				if ((psw_cc & mf3) > 0) {
					reg.putLong(rf1, mem.getLong(bd2_loc));
				}
				break;
			case 0xE3: //  "EBE3","STOCG","RSY2 " 20 RPI-1125 Z196
				psw_check = false;
				ins_setup_rsy();
				if ((psw_cc & mf3) > 0) {
					mem.putLong(bd2_loc, reg.getLong(rf1));
				}
				break;
			case 0xE4: //  "EBE4","LANG","RSY  "  20 RPI-1125 Z196
				psw_check = false;
				ins_setup_rsy();
				if ((bd2_loc & 0x7) != 0) {
					set_psw_check(Constants.psw_pic_spec);
				}
				rlv1 = reg.getLong(rf3);
				rlv2 = mem.getLong(bd2_loc);
				rlv3 = rlv1 & rlv2;
				mem.putLong(bd2_loc,rlv3);
				reg.putLong(rf1,rlv2);
				if (rlv3 == 0) {
					psw_cc = psw_cc0;
				} else {
					psw_cc = psw_cc1;
				}
				break;
			case 0xE6: //  "EBE6","LAOG","RSY  "  20 RPI-1125 Z196
				psw_check = false;
				ins_setup_rsy();
				if ((bd2_loc & 0x7) != 0) {
					set_psw_check(Constants.psw_pic_spec);
				}
				rlv1 = reg.getLong(rf3);
				rlv2 = mem.getLong(bd2_loc);
				rlv3 = rlv1 | rlv2;
				mem.putLong(bd2_loc,rlv3);
				reg.putLong(rf1,rlv2);
				if (rlv3 == 0) {
					psw_cc = psw_cc0;
				} else {
					psw_cc = psw_cc1;
				}
				break;
			case 0xE7: //  "EBE7","LAXG","RSY  "  20 RPI-1125 Z196
				psw_check = false;
				ins_setup_rsy();
				if ((bd2_loc & 0x7) != 0) {
					set_psw_check(Constants.psw_pic_spec);
				}
				rlv1 = reg.getLong(rf3);
				rlv2 = mem.getLong(bd2_loc);
				rlv3 = rlv1 ^ rlv2;
				mem.putLong(bd2_loc,rlv3);
				reg.putLong(rf1,rlv2);
				if (rlv3 == 0) {
					psw_cc = psw_cc0;
				} else {
					psw_cc = psw_cc1;
				}
				break;
			case 0xE8: //  "EBE8","LAAG","RSY  "  20 RPI-1125 Z196
				psw_check = false;
				ins_setup_rsy();
				if ((bd2_loc & 0x7) != 0) {
					set_psw_check(Constants.psw_pic_spec);
				}
				rlv1 = reg.getLong(rf3);
				rlv2 = mem.getLong(bd2_loc);
				rlv3 = rlv1 + rlv2;
				mem.putLong(bd2_loc,rlv3);
				reg.putLong(rf1,rlv2);
				psw_cc = get_long_add_cc();
				break;
			case 0xEA: //  "EBEA","LAALG","RSY  " 20 RPI-1125 Z196
				psw_check = false;
				ins_setup_rsy();
				if ((bd2_loc & 0x7) != 0) {
					set_psw_check(Constants.psw_pic_spec);
				}
				rlv1 = reg.getLong(rf3);
				rlv2 = mem.getLong(bd2_loc);
				rlv3 = rlv1 + rlv2;
				mem.putLong(bd2_loc,rlv3);
				reg.putLong(rf1,rlv2);
				psw_cc = get_long_log_add_cc();
				break;
			case 0xF2: //  "EBF2","LOC","RSY2 "   20 RPI-1125 Z196
				psw_check = false;
				ins_setup_rsy();
				if ((psw_cc & mf3) > 0) {
					reg.putInt(rf1+4, mem.getInt(bd2_loc));
				}
				break;
			case 0xF3: //  "EBF3","STOC","RSY2 "  20 RPI-1125 Z196
				psw_check = false;
				ins_setup_rsy();
				if ((psw_cc & mf3) > 0) {
					mem.putInt(bd2_loc, reg.getInt(rf1+4));
				}
				break;
			case 0xF4: //  "EBF4","LAN","RSY  "   20 RPI-1125 Z196
				psw_check = false;
				ins_setup_rsy();
				if ((bd2_loc & 0x3) != 0) {
					set_psw_check(Constants.psw_pic_spec);
				}
				rv1 = reg.getInt(rf3 + 4);
				rv2 = mem.getInt(bd2_loc);
				rv3 = rv1 & rv2;
				mem.putInt(bd2_loc,rv3);
				reg.putInt(rf1+4,rv2);
				if (rv3 == 0) {
					psw_cc = psw_cc0;
				} else {
					psw_cc = psw_cc1;
				}
				break;
			case 0xF6: //  "EBF6","LAO","RSY  "   20 RPI-1125 Z196
				psw_check = false;
				ins_setup_rsy();
				if ((bd2_loc & 0x3) != 0) {
					set_psw_check(Constants.psw_pic_spec);
				}
				rv1 = reg.getInt(rf3 + 4);
				rv2 = mem.getInt(bd2_loc);
				rv3 = rv1 | rv2;
				mem.putInt(bd2_loc,rv3);
				reg.putInt(rf1+4,rv2);
				if (rv3 == 0) {
					psw_cc = psw_cc0;
				} else {
					psw_cc = psw_cc1;
				}
				break;
			case 0xF7: //  "EBF7","LAX","RSY  "   20 RPI-1125 Z196
				psw_check = false;
				ins_setup_rsy();
				if ((bd2_loc & 0x3) != 0) {
					set_psw_check(Constants.psw_pic_spec);
				}
				rv1 = reg.getInt(rf3 + 4);
				rv2 = mem.getInt(bd2_loc);
				rv3 = rv1 ^ rv2;
				mem.putInt(bd2_loc,rv3);
				reg.putInt(rf1+4,rv2);
				if (rv3 == 0) {
					psw_cc = psw_cc0;
				} else {
					psw_cc = psw_cc1;
				}
				break;
			case 0xF8: //  "EBF8","LAA","RSY  "   20 RPI-1125 Z196
				psw_check = false;
				ins_setup_rsy();
				if ((bd2_loc & 0x3) != 0) {
					set_psw_check(Constants.psw_pic_spec);
				}
				rv1 = reg.getInt(rf3 + 4);
				rv2 = mem.getInt(bd2_loc);
				rv3 = rv1 + rv2;
				mem.putInt(bd2_loc,rv3);
				reg.putInt(rf1+4,rv2);
				psw_cc = get_int_add_cc();
				break;
			case 0xFA: //  "EBFA","LAAL","RSY  "  20 RPI-1125 Z196
				psw_check = false;
				ins_setup_rsy();
				if ((bd2_loc & 0x3) != 0) {
					set_psw_check(Constants.psw_pic_spec);
				}
				rv1 = reg.getInt(rf3 + 4);
				rv2 = mem.getInt(bd2_loc);
				rv3 = rv1 + rv2;
				mem.putInt(bd2_loc,rv3);
				reg.putInt(rf1+4,rv2);
				psw_cc = get_int_log_add_cc();
				break;
		}
	}

	/**
	 *
	 */
	private void ins_ECXX()
	{
		opcode2 = mem_byte[psw_loc + opcode2_offset_rie] & 0xff;
		switch (opcode2) {
		case 0x44: // 6580 "EC44" "BRXHG" "RIE"
			psw_check = false;
			ins_setup_rie();
			rlv3 = reg.getLong(rf3);
			rlv1 = reg.getLong(rf1) + rlv3;
			reg.putLong(rf1, rlv1);
			if (rf3 == ((rf3 >> 4) << 4)) {
				rlv3 = reg.getLong(rf3 + 8);
			}
			if (rlv1 > rlv3) {
				set_psw_loc(psw_loc - 6 + 2 * if2);
			}
			break;
		case 0x45: // 6600 "EC45" "BRXLG" "RIE"
			psw_check = false;
			ins_setup_rie();
			rlv3 = reg.getLong(rf3);
			rlv1 = reg.getLong(rf1) + rlv3;
			reg.putLong(rf1, rlv1);
			if (rf3 == ((rf3 >> 4) << 4)) {
				rlv3 = reg.getLong(rf3 + 8);
			}
			if (rlv1 <= rlv3) {
				set_psw_loc(psw_loc - 6 + 2 * if2);
			}
			break;
		case 0x51:  // "EC51","RISBLG","RIE8"  52 RPI-1125 Z196
			psw_check = false;
			set_risb_zero(); // RPI-1164
			ins_setup_rie8();
			risb_rotate_insert_high(false); // not high = store low 32 bits
			break;
		case 0x54:  // 510 "EC54" "RNSBG" "RIE2" 52 RPI-817
			psw_check = false;
			ins_setup_rie8();
			rsbg_setup_and_rotate();
			rlv1 = rlv1 & (rlv2 | rsbg_mask_zeros);
			if (!rsbg_test) {
				reg.putLong(rf1,rlv1);
			}
			if ((rlv1 & rsbg_mask_ones) == 0) {
				psw_cc = psw_cc0;
			} else {
				psw_cc = psw_cc1;
			}
			break;
		case 0x55:  // 530 "EC55" "RISBG" "RIE8" 52 RPI-817
			psw_check = false;
			ins_setup_rie8();
			rsbg_setup_and_rotate();
			rlv2 = rlv2 & rsbg_mask_ones;
			if (rsbg_zero) {
				rlv1 = rlv2;
			} else {
				rlv1 = (reg.getLong(rf1) & rsbg_mask_zeros) | rlv2; // RPI-1164
			}
			reg.putLong(rf1,rlv1);
			if (rlv1 == 0) {
				psw_cc = psw_cc0;
			} else if (rlv1 < 0) {
				psw_cc = psw_cc1;
			} else {
				psw_cc = psw_cc2;
			}
			break;
		case 0x56:  // 550 "EC56" "ROSBG" "RIE8" 52 RPI-817
			psw_check = false;
			ins_setup_rie8();
			rsbg_setup_and_rotate();
			rlv1 = rlv1 | (rlv2 & rsbg_mask_ones);
			if (!rsbg_test) {
				reg.putLong(rf1,rlv1);
			}
			if ((rlv1 & rsbg_mask_ones) == 0) {
				psw_cc = psw_cc0;
			} else {
				psw_cc = psw_cc1;
			}
			break;
		case 0x57:  // 570 "EC57" "RXSBG" "RIE8" 52 RPI-817
			psw_check = false;
			ins_setup_rie8();
			rsbg_setup_and_rotate();
			rlv1 = rlv1 ^ (rlv2 & rsbg_mask_ones);
			if (!rsbg_test) {
				reg.putLong(rf1,rlv1);
			}
			if ((rlv1 & rsbg_mask_ones) == 0) {
				psw_cc = psw_cc0;
			} else {
				psw_cc = psw_cc1;
			}
			break;
		case 0x5D:  // "EC5D","RISBHG","RIE8"  52 RPI-1125 Z196
			psw_check = false;
			set_risb_zero(); // RPI-1164
			ins_setup_rie8();
			risb_rotate_insert_high(true); // not high = store low 32 bits
			break;
		case 0x64:  // 10 "EC64" "CGRJ" "RIE6"
			psw_check = false;
			ins_setup_rie6();
			if ((mf3 & get_long_comp_cc(reg.getLong(rf1), reg.getLong(rf2)))
					!= 0) {
				set_psw_loc(bd4_loc);
			}
			break;
		case 0x65:  // 80 "EC65" "CLGRJ" "RIE6"
			psw_check = false;
			ins_setup_rie6();
			if ((mf3 & get_long_log_comp_cc(reg.getLong(rf1), reg.getLong(rf2)))
					!= 0) {
				set_psw_loc(bd4_loc);
			}
			break;
		case 0x70:  // 150 "EC70" "CGIT" "RIE2" RPI-817
			psw_check = false;
			ins_setup_rie2();
			if ((mf3 & get_long_comp_cc(reg.getLong(rf1),if2))
					!= 0) {
				fp_dxc = fp_dxc_trap; // raise trap
				set_psw_check(Constants.psw_pic_data);
			}
			break;
		case 0x71:  // 150 "EC71" "CLGIT" "RIE2"
			psw_check = false;
			ins_setup_rie2();
			if ((mf3 & get_long_log_comp_cc(reg.getLong(rf1),if2 & 0xffff))
					!= 0) {
				fp_dxc = fp_dxc_trap; // raise trap
				set_psw_check(Constants.psw_pic_data);
			}
			break;
		case 0x72:  // 220 "EC72" "CIT" "RIE2" RPI-817
			psw_check = false;
			ins_setup_rie2();
			if ((mf3 & get_int_comp_cc(reg.getInt(rf1+4),if2))
					!= 0) {
				fp_dxc = fp_dxc_trap; // raise trap
				set_psw_check(Constants.psw_pic_data);
			}
			break;
		case 0x73:  // 220 "EC73" "CLFIT" "RIE2"
			psw_check = false;
			ins_setup_rie2();
			if ((mf3 & get_int_log_comp_cc(reg.getInt(rf1+4),if2 & 0xffff))
					!= 0) {
				fp_dxc = fp_dxc_trap; // raise trap
				set_psw_check(Constants.psw_pic_data);
			}
			break;
		case 0x76:  // 150 "EC76" "CRJ" "RIE6"
			psw_check = false;
			ins_setup_rie6();
			if ((mf3 & get_int_comp_cc(reg.getInt(rf1+4), reg.getInt(rf2+4)))
					!= 0) {
				set_psw_loc(bd4_loc);
			}
			break;
		case 0x77:  // 220 "EC77" "CLRJ" "RIE6"
			psw_check = false;
			ins_setup_rie6();
			if ((mf3 & get_int_log_comp_cc(reg.getInt(rf1+4), reg.getInt(rf2+4)))
					!= 0) {
				set_psw_loc(bd4_loc);
			}
			break;
		case 0x7C:  // 290 "EC7C" "CGIJ" "RIE4"
			psw_check = false;
			ins_setup_rie4();
			if ((mf3 & get_long_comp_cc(reg.getLong(rf1), if2))
					!= 0) {
				set_psw_loc(bd4_loc);
			}
			break;
		case 0x7D:  // 360 "EC7D" "CLGIJ" "RIE4"
			psw_check = false;
			ins_setup_rie4();
			if ((mf3 & get_long_log_comp_cc(reg.getLong(rf1), if2))
					!= 0) {
				set_psw_loc(bd4_loc);
			}
			break;
		case 0x7E:  // 430 "EC7E" "CIJ" "RIE4"
			psw_check = false;
			ins_setup_rie4();
			if ((mf3 & get_int_comp_cc(reg.getInt(rf1+4), if2))
					!= 0) {
				set_psw_loc(bd4_loc);
			}
			break;
		case 0x7F:  // 500 "EC7F" "CLIJ" "RIE4"
			psw_check = false;
			ins_setup_rie4();
			if ((mf3 & get_int_log_comp_cc(reg.getInt(rf1+4), if2))
					!= 0) {
				set_psw_loc(bd4_loc);
			}
			break;
		case 0xD8: // "ECD8","AHIK","RIE9"    57 RPI-1125 Z196
			psw_check = false;
			ins_setup_rie9();
			rv1 = reg.getInt(rf3 + 4);
			rv2 = if2;
			rv3 = rv1 + rv2;
			reg.putInt(rf1 + 4, rv3);
			psw_cc = get_int_add_cc();
			break;
		case 0xD9: // "ECD9","AGHIK","RIE9"   57 RPI-1125 Z196
			psw_check = false;
			ins_setup_rie9();
			rlv1 = reg.getLong(rf3);
			rlv2 = if2;
			rlv3 = rlv1 + rlv2;
			reg.putLong(rf1, rlv3);
			psw_cc = get_long_add_cc();
			break;
		case 0xDA: // "ECDA","ALHSIK","RIE9"  57 RPI-1125 Z196
			psw_check = false;
			ins_setup_rie9();
			rvw = reg.getInt(rf3+4);
			rv2 = if2;
			rv1 = rvw + rv2;
			reg.putInt(rf1+4, rv1);
			psw_cc = get_int_lsi_add_cc(); // RPI-1125
			break;
		case 0xDB: // "ECDB","ALGHSIK","RIE9" 57 RPI-1125 Z196
			psw_check = false;
			ins_setup_rie9();
			rlvw = reg.getLong(rf3);
			rlv2 = if2;
			rlv1 = rlvw + rlv2;
			reg.putLong(rf1, rlv1);
			psw_cc = get_long_lsi_add_cc(); // RPI-1125
			break;
		case 0xE4:  // 570 "ECE4" "CGRB" "RRS1"
			psw_check = false;
			ins_setup_rrs1();
			if ((mf3 & get_long_comp_cc(reg.getLong(rf1), reg.getLong(rf2)))
					!= 0) {
				set_psw_loc(bd4_loc);
			}
			break;
		case 0xE5:  // 640 "ECE5" "CLGRB" "RRS1"
			psw_check = false;
			ins_setup_rrs1();
			if ((mf3 & get_long_log_comp_cc(reg.getLong(rf1), reg.getLong(rf2)))
					!= 0) {
				set_psw_loc(bd4_loc);
			}
			break;
		case 0xF6:  // 710 "ECF6" "CRB" "RRS1"
			psw_check = false;
			ins_setup_rrs1();
			if ((mf3 & get_int_comp_cc(reg.getInt(rf1+4), reg.getInt(rf2+4)))
					!= 0) {
				set_psw_loc(bd4_loc);
			}
			break;
		case 0xF7:  // 780 "ECF7" "CLRB" "RRS1"
			psw_check = false;
			ins_setup_rrs1();
			if ((mf3 & get_int_log_comp_cc(reg.getInt(rf1+4), reg.getInt(rf2+4)))
					!= 0) {
				set_psw_loc(bd4_loc);
			}
			break;
		case 0xFC:  // 850 "ECFC" "CGIB" "RRS3"
			psw_check = false;
			ins_setup_rrs3();
			if ((mf3 & get_long_comp_cc(reg.getLong(rf1), if2))
					!= 0) {
				set_psw_loc(bd4_loc);
			}
			break;
		case 0xFD:  // 920 "ECFD" "CLGIB" "RRS3"
			psw_check = false;
			ins_setup_rrs3();
			if ((mf3 & get_long_log_comp_cc(reg.getLong(rf1), if2))
					!= 0) {
				set_psw_loc(bd4_loc);
			}
			break;
		case 0xFE:  // 990 "ECFE" "CIB" "RRS3"
			psw_check = false;
			ins_setup_rrs3();
			if ((mf3 & get_int_comp_cc(reg.getInt(rf1+4), if2))
					!= 0) {
				set_psw_loc(bd4_loc);
			}
			break;
		case 0xFF:  // 1060 "ECFF" "CLIB" "RRS3"
			psw_check = false;
			ins_setup_rrs3();
			if ((mf3 & get_int_log_comp_cc(reg.getInt(rf1+4), if2))
					!= 0) {
				set_psw_loc(bd4_loc);
			}
			break;
		}
	}

	/**
	 *
	 */
	private void ins_EDXX()
	{
		opcode2 = mem_byte[psw_loc + opcode2_offset_rxe] & 0xff;
		switch (opcode2) {
		case 0x04: // 6620 "ED04" "LDEB" "RXE"
			psw_check = false;
			ins_setup_rxe();
			fp_rdv1 = fp_get_db_from_eb(mem, xbd2_loc);
			fp_put_db(rf1, tz390.fp_db_type, fp_rdv1);
			break;
		case 0x05: // 6630 "ED05" "LXDB" "RXE"
			psw_check = false;
			ins_setup_rxe();
			fp_rbdv1 = fp_get_bd_from_db(mem, xbd2_loc);
			fp_put_bd(rf1, tz390.fp_lb_type, fp_rbdv1);
			break;
		case 0x06: // 6640 "ED06" "LXEB" "RXE"
			psw_check = false;
			ins_setup_rxe();
			fp_rbdv1 = fp_get_bd_from_eb(mem, xbd2_loc);
			fp_put_bd(rf1, tz390.fp_lb_type, fp_rbdv1);
			break;
		case 0x07: // 6650 "ED07" "MXDB" "RXE"
			psw_check = false;
			ins_setup_rxe();
			fp_rbdv1 = fp_get_bd_from_db(fp_reg, rf1)
					.multiply(fp_get_bd_from_db(mem, xbd2_loc), fp_lxg_context); // RPI-821
			fp_put_bd(rf1, tz390.fp_lb_type, fp_rbdv1);
			check_lb_mpy();
			break;
		case 0x08: // 6660 "ED08" "KEB" "RXE"
			psw_check = false;
			ins_setup_rxe();
			fp_signal = true;
			psw_cc = fp_get_eb_comp_cc(fp_get_eb_from_eb(fp_reg, rf1),
					fp_get_eb_from_eb(mem, xbd2_loc));
			break;
		case 0x09: // 6670 "ED09" "CEB" "RXE"
			psw_check = false;
			ins_setup_rxe();
			psw_cc = fp_get_eb_comp_cc(fp_get_eb_from_eb(fp_reg, rf1),
					fp_get_eb_from_eb(mem, xbd2_loc));
			break;
		case 0x0A: // 6680 "ED0A" "AEB" "RXE"
			psw_check = false;
			ins_setup_rxe();
			fp_rev1 = fp_get_eb_from_eb(fp_reg, rf1)
					+ fp_get_eb_from_eb(mem, xbd2_loc);
			fp_put_eb(rf1, tz390.fp_eb_type, fp_rev1);
			psw_cc = fp_get_eb_add_sub_cc();
			break;
		case 0x0B: // 6690 "ED0B" "SEB" "RXE"
			psw_check = false;
			ins_setup_rxe();
			fp_rev1 = fp_get_eb_from_eb(fp_reg, rf1)
					- fp_get_eb_from_eb(mem, xbd2_loc);
			fp_put_eb(rf1, tz390.fp_eb_type, fp_rev1);
			psw_cc = fp_get_eb_add_sub_cc();
			break;
		case 0x0C: // 6700 "ED0C" "MDEB" "RXE"
			psw_check = false;
			ins_setup_rxe();
			fp_rdv1 = fp_get_db_from_eb(fp_reg, rf1)
					* fp_get_db_from_eb(mem, xbd2_loc);
			fp_put_db(rf1, tz390.fp_db_type, fp_rdv1);
			check_db_mpy();
			break;
		case 0x0D: // 6710 "ED0D" "DEB" "RXE"
			psw_check = false;
			ins_setup_rxe();
			fp_rev2 = fp_get_eb_from_eb(mem, xbd2_loc);
			fp_rev1 = fp_get_eb_from_eb(fp_reg, rf1) / fp_rev2;
			fp_put_eb(rf1, tz390.fp_eb_type, fp_rev1);
			check_eb_div();
			break;
		case 0x0E: // 6720 "ED0E" "MAEB" "RXF"
			psw_check = false;
			ins_setup_rxf();
			fp_rev1 = fp_get_eb_from_eb(fp_reg, rf1)
					+ fp_get_eb_from_eb(mem, xbd2_loc)
					* fp_get_eb_from_eb(fp_reg, rf3);
			fp_put_eb(rf1, tz390.fp_eb_type, fp_rev1);
			check_eb_mpy();
			break;
		case 0x0F: // 6730 "ED0F" "MSEB" "RXF"
			psw_check = false;
			ins_setup_rxf();
			fp_rev1 = fp_get_eb_from_eb(mem, xbd2_loc)
					* fp_get_eb_from_eb(fp_reg, rf3)
					- fp_get_eb_from_eb(fp_reg, rf1); // RPI-834
			fp_put_eb(rf1, tz390.fp_eb_type, fp_rev1);
			check_eb_mpy();
			break;
		case 0x10: // 6740 "ED10" "TCEB" "RXE"
			psw_check = false;
			ins_setup_rxe();
			fp_rev1 = fp_get_eb_from_eb(fp_reg, rf1); // RPI-326
			psw_cc = psw_cc0;
			if ((xbd2_loc & 0x800) != 0 && fp_rev1 == 0) {
				psw_cc = psw_cc1; // +0
			}
			if ((xbd2_loc & 0x400) != 0
				&& Math.copySign(1,fp_rev1) == -1  // RPI-834
				&& Math.abs(fp_rev1) == 0) {
				psw_cc = psw_cc1; // -0
			}
			if ((xbd2_loc & 0x200) != 0 && fp_rev1 > 0) {
				psw_cc = psw_cc1; // +normalized
			}
			if ((xbd2_loc & 0x100) != 0 && fp_rev1 < 0) {
				psw_cc = psw_cc1; // -normalized
			}
			if ((xbd2_loc & 0x080) != 0) {
				// psw_cc = psw_cc1; //+denormalized (never)
			}
			if ((xbd2_loc & 0x040) != 0) {
				// psw_cc = psw_cc1; //-denormalized (never)
			}
			if ((xbd2_loc & 0x020) != 0) {
				// psw_cc = psw_cc1; //+infinity
			}
			if ((xbd2_loc & 0x010) != 0) {
				// psw_cc = psw_cc1; //-infinity
			}
			if ((xbd2_loc & 0x008) != 0) {
				// psw_cc = psw_cc1; //+quiet nan
			}
			if ((xbd2_loc & 0x004) != 0) {
				// psw_cc = psw_cc1; //-quiet nan
			}
			if ((xbd2_loc & 0x002) != 0) {
				// psw_cc = psw_cc1; //+signaling nan
			}
			if ((xbd2_loc & 0x001) != 0) {
				// psw_cc = psw_cc1; //-signaling nan
			}
			break;
		case 0x11: // 6750 "ED11" "TCDB" "RXE"
			psw_check = false;
			ins_setup_rxe();
			fp_rdv1 = fp_get_db_from_db(fp_reg, rf1); // RPI-326 RPI-849
			psw_cc = psw_cc0;
			if ((xbd2_loc & 0x800) != 0 && fp_rdv1 == 0) {
				psw_cc = psw_cc1; // +0
			}
			if ((xbd2_loc & 0x400) != 0
				&& Math.copySign(1,fp_rdv1) == -1  // RPI-834
				&& Math.abs(fp_rdv1) == 0) {
				psw_cc = psw_cc1; // -0
			}
			if ((xbd2_loc & 0x200) != 0 && fp_rdv1 > 0) {
				psw_cc = psw_cc1; // +normalized
			}
			if ((xbd2_loc & 0x100) != 0 && fp_rdv1 < 0) {
				psw_cc = psw_cc1; // -normalized
			}
			if ((xbd2_loc & 0x080) != 0) {
				// psw_cc = psw_cc1; //+denormalized (never)
			}
			if ((xbd2_loc & 0x040) != 0) {
				// psw_cc = psw_cc1; //-denormalized (never)
			}
			if ((xbd2_loc & 0x020) != 0) {
				// psw_cc = psw_cc1; //+infinity
			}
			if ((xbd2_loc & 0x010) != 0) {
				// psw_cc = psw_cc1; //-infinity
			}
			if ((xbd2_loc & 0x008) != 0) {
				// psw_cc = psw_cc1; //+quiet nan
			}
			if ((xbd2_loc & 0x004) != 0) {
				// psw_cc = psw_cc1; //-quiet nan
			}
			if ((xbd2_loc & 0x002) != 0) {
				// psw_cc = psw_cc1; //+signaling nan
			}
			if ((xbd2_loc & 0x001) != 0) {
				// psw_cc = psw_cc1; //-signaling nan
			}
			break;
		case 0x12: // 6760 "ED12" "TCXB" "RXE"
			psw_check = false;
			ins_setup_rxe();
			fp_rbdv1 = fp_get_bd_from_lb(fp_reg, rf1); // RPI-326
			psw_cc = psw_cc0;
			if ((xbd2_loc & 0x800) != 0
					&& fp_rbdv1.signum() == 0) {
				psw_cc = psw_cc1; // +0
			}
			if ((xbd2_loc & 0x400) != 0
				&& fp_rbdv1.compareTo(fp_lb_neg_zero) == 0
				&& fp_rbdv1.toString().charAt(0) == '-' // RPI-834
				) {
				psw_cc = psw_cc1; // -0
			}
			if ((xbd2_loc & 0x200) != 0
					&& fp_rbdv1.signum() > 0) {
				psw_cc = psw_cc1; // +normalized
			}
			if ((xbd2_loc & 0x100) != 0
					&& fp_rbdv1.signum() < 0) {
				psw_cc = psw_cc1; // -normalized
			}
			if ((xbd2_loc & 0x080) != 0) {
				// psw_cc = psw_cc1; //+denormalized (never)
			}
			if ((xbd2_loc & 0x040) != 0) {
				// psw_cc = psw_cc1; //-denormalized (never)
			}
			if ((xbd2_loc & 0x020) != 0) {
				// psw_cc = psw_cc1; //+infinity
			}
			if ((xbd2_loc & 0x010) != 0) {
				// psw_cc = psw_cc1; //-infinity
			}
			if ((xbd2_loc & 0x008) != 0) {
				// psw_cc = psw_cc1; //+quiet nan
			}
			if ((xbd2_loc & 0x004) != 0) {
				// psw_cc = psw_cc1; //-quiet nan
			}
			if ((xbd2_loc & 0x002) != 0) {
				// psw_cc = psw_cc1; //+signaling nan
			}
			if ((xbd2_loc & 0x001) != 0) {
				// psw_cc = psw_cc1; //-signaling nan
			}
			break;
		case 0x14: // 6770 "ED14" "SQEB" "RXE"
			psw_check = false;
			ins_setup_rxe();
			fp_rev1 = (float) Math.sqrt(fp_get_db_from_eb(mem, xbd2_loc));
			fp_put_eb(rf1, tz390.fp_eb_type, fp_rev1);
			break;
		case 0x15: // 6780 "ED15" "SQDB" "RXE"
			psw_check = false;
			ins_setup_rxe();
			fp_rdv1 = Math.sqrt(fp_get_db_from_db(mem, xbd2_loc));
			fp_put_db(rf1, tz390.fp_db_type, fp_rdv1);
			break;
		case 0x17: // 6790 "ED17" "MEEB" "RXE"
			psw_check = false;
			ins_setup_rxe();
			fp_rev1 = fp_get_eb_from_eb(fp_reg, rf1)
					* fp_get_eb_from_eb(mem, xbd2_loc);
			fp_put_eb(rf1, tz390.fp_eb_type, fp_rev1);
			check_eh_mpy();
			break;
		case 0x18: // 6800 "ED18" "KDB" "RXE"
			psw_check = false;
			ins_setup_rxe();
			fp_signal = true;
			psw_cc = fp_get_db_comp_cc(fp_get_db_from_db(fp_reg, rf1),
					fp_get_db_from_db(mem, xbd2_loc));
			break;
		case 0x19: // 6810 "ED19" "CDB" "RXE"
			psw_check = false;
			ins_setup_rxe();
			psw_cc = fp_get_db_comp_cc(fp_get_db_from_db(fp_reg, rf1),
					fp_get_db_from_db(mem, xbd2_loc));
			break;
		case 0x1A: // 6820 "ED1A" "ADB" "RXE"
			psw_check = false;
			ins_setup_rxe();
			fp_rdv1 = fp_get_db_from_db(fp_reg, rf1)
					+ fp_get_db_from_db(mem, xbd2_loc);
			fp_put_db(rf1, tz390.fp_db_type, fp_rdv1);
			psw_cc = fp_get_db_add_sub_cc();
			break;
		case 0x1B: // 6830 "ED1B" "SDB" "RXE"
			psw_check = false;
			ins_setup_rxe();
			fp_rdv1 = fp_get_db_from_db(fp_reg, rf1)
					- fp_get_db_from_db(mem, xbd2_loc);
			fp_put_db(rf1, tz390.fp_db_type, fp_rdv1);
			psw_cc = fp_get_db_add_sub_cc();
			break;
		case 0x1C: // 6840 "ED1C" "MDB" "RXE"
			psw_check = false;
			ins_setup_rxe();
			fp_rdv1 = fp_get_db_from_db(fp_reg, rf1)
					* fp_get_db_from_db(mem, xbd2_loc);
			fp_put_db(rf1, tz390.fp_db_type, fp_rdv1);
			check_db_mpy();
			break;
		case 0x1D: // 6850 "ED1D" "DDB" "RXE"
			psw_check = false;
			ins_setup_rxe();
			fp_rdv2 = fp_get_db_from_db(mem, xbd2_loc);
			fp_rdv1 = fp_get_db_from_db(fp_reg, rf1) / fp_rdv2;
			fp_put_db(rf1, tz390.fp_db_type, fp_rdv1);
			check_db_div();
			break;
		case 0x1E: // 6860 "ED1E" "MADB" "RXF"
			psw_check = false;
			ins_setup_rxf();
			fp_rdv1 = fp_get_db_from_db(mem, xbd2_loc)
					* fp_get_db_from_db(fp_reg, rf3)
					+ fp_get_db_from_db(fp_reg, rf1); // RPI-821
			fp_put_db(rf1, tz390.fp_db_type, fp_rdv1); // RPI-821
			check_db_mpy();
			break;
		case 0x1F: // 6870 "ED1F" "MSDB" "RXF"
			psw_check = false;
			ins_setup_rxf();
			fp_rdv1 = fp_get_db_from_db(mem, xbd2_loc)
					* fp_get_db_from_db(fp_reg, rf3)
					- fp_get_db_from_db(fp_reg, rf1);  // RPI-834
			fp_put_db(rf1, tz390.fp_db_type, fp_rdv1); // RPI-821
			check_db_mpy();
			break;
		case 0x24: // 6880 "ED24" "LDE" "RXE"
			psw_check = false;
			ins_setup_rxe();
			fp_load_reg(rf1, tz390.fp_dh_type, mem, xbd2_loc,
					tz390.fp_eh_type);
			break;
		case 0x25: // 6890 "ED25" "LXD" "RXE"
			psw_check = false;
			ins_setup_rxe();
			fp_load_reg(rf1, tz390.fp_lh_type, mem, xbd2_loc,
					tz390.fp_lh_type);
			fp_reg.putLong(rf1+16,0); // RPI-1015
			break;
		case 0x26: // 6900 "ED26" "LXE" "RXE"
			psw_check = false;
			ins_setup_rxe();

			fp_load_reg(rf1, tz390.fp_lh_type, mem, xbd2_loc,
					tz390.fp_eh_type);
			fp_reg.putLong(rf1+16,0); // RPI-1015
			break;
		case 0x2E: // 6910 "ED2E" "MAE" "RXF"
			psw_check = false;
			ins_setup_rxf();
			fp_rdv1 = fp_get_db_from_eh(fp_reg, rf1)
					+ fp_get_db_from_eh(mem, xbd2_loc)
					* fp_get_db_from_eh(fp_reg, rf3);
			fp_put_db(rf1, tz390.fp_eh_type, fp_rdv1);
			check_eh_mpy();
			break;
		case 0x2F: // 6920 "ED2F" "MSE" "RXF"
			psw_check = false;
			ins_setup_rxf();
			fp_rdv1 = fp_get_db_from_eh(mem, xbd2_loc)
					* fp_get_db_from_eh(fp_reg, rf3)
					- fp_get_db_from_eh(fp_reg, rf1); // RPI-834
			fp_put_db(rf1, tz390.fp_eh_type, fp_rdv1);
			check_eh_mpy();
			break;
		case 0x34: // 6930 "ED34" "SQE" "RXE"
			psw_check = false;
			ins_setup_rxe();
			fp_rdv1 = Math.sqrt(fp_get_db_from_eh(mem, xbd2_loc));
			fp_put_db(rf1, tz390.fp_eh_type, fp_rdv1);
			break;
		case 0x35: // 6940 "ED35" "SQD" "RXE"
			psw_check = false;
			ins_setup_rxe();
			fp_rbdv2 = fp_get_bd_from_dh(mem, xbd2_loc);  // RPI-821
			fp_get_bd_sqrt();                             // RPI-821
			fp_put_bd(rf1, tz390.fp_dh_type, fp_rbdv1);   // RPI-821
			break;
		case 0x37: // 6950 "ED37" "MEE" "RXE"
			psw_check = false;
			ins_setup_rxe();
			fp_rdv1 = fp_get_db_from_eh(fp_reg, rf1)
					* fp_get_db_from_eh(mem, xbd2_loc);
			fp_put_db(rf1, tz390.fp_eh_type, fp_rdv1);
			check_eh_mpy();
			break;
		case 0x38: // 7410 "ED38" "MAYL" "RXF" Z9-46
			psw_check = false; // RPI-298
			ins_setup_rxf();
			// unnormalized HFP RPI-767
			fp_store_reg(fp_reg,rf1);
			fp_long2 = mem.getLong(xbd2_loc);
			fp_long3 = fp_reg.getLong(rf3);
			fp_mpy_unnorm_dh(); // RPI-767 big_int1=long2*long3
			tz390.fp_exp = tz390.fp_exp - 14; // use low half exponent
			fp_get_bi_unnorm_dh();
			fp_add_bi_unnorm_dh();
			tz390.fp_exp = tz390.fp_exp + 14; // restore exp for LH store
			fp_put_bi_to_lh_wreg();
			fp_reg.putLong(rf1,tz390.fp_work_reg.getLong(8));
			break;
		case 0x39: // 7420 "ED39" "MYL" "RXF" Z9-47
			psw_check = false; // RPI-298
			ins_setup_rxf();
			// unnormalized HFP RPI-767
			fp_store_reg(fp_reg,rf1);
			fp_long2 = mem.getLong(xbd2_loc);
			fp_long3 = fp_reg.getLong(rf3);
			fp_mpy_unnorm_dh(); // RPI-767 big_int1=long2*long3
			fp_put_bi_to_lh_wreg();
			fp_reg.putLong(rf1,tz390.fp_work_reg.getLong(8));
			break;
		case 0x3A: // 7430 "ED3A" "MAY" "RXF" Z9-48
			psw_check = false;
			ins_setup_rxf();
			// unnormalized HFP RPI-767
			if (!fp_pair_valid[mf1]) { // RPI-229
				set_psw_check(Constants.psw_pic_spec);
			}
			fp_store_reg(fp_reg,rf1);
			fp_store_reg(fp_reg,rf1+16);
			fp_long2 = mem.getLong(xbd2_loc);
			fp_long3 = fp_reg.getLong(rf3);
			fp_mpy_unnorm_dh(); // RPI-767 big_int1=long2*long3
			fp_get_bi_unnorm_lh();
			fp_add_bi_unnorm_dh();
			fp_put_bi_to_lh_wreg();
			fp_reg.putLong(rf1,tz390.fp_work_reg.getLong(0));
			fp_reg.putLong(rf1+16,tz390.fp_work_reg.getLong(8));
			break;
		case 0x3B: // 7440 "ED3B" "MY" "RXF" Z9-49 RPI-298
			psw_check = false;
			ins_setup_rxf();
			// unnormalized HFP RPI-767
			if (!fp_pair_valid[mf1]) { // RPI-229
				set_psw_check(Constants.psw_pic_spec);
			}
			fp_store_reg(fp_reg,rf1);
			fp_store_reg(fp_reg,rf1+16);
			fp_long2 = mem.getLong(xbd2_loc);
			fp_long3 = fp_reg.getLong(rf3);
			fp_mpy_unnorm_dh(); // RPI-767 big_int1=long2*long3
			fp_put_bi_to_lh_wreg();
			fp_reg.putLong(rf1,tz390.fp_work_reg.getLong(0));
			fp_reg.putLong(rf1+16,tz390.fp_work_reg.getLong(8));
			break;
		case 0x3C: // 7450 "ED3C" "MAYH" "RXF" Z9-50
			psw_check = false; // RPI-298
			ins_setup_rxf();
			// unnormalized HFP RPI-767
			fp_store_reg(fp_reg,rf1);
			fp_long2 = mem.getLong(xbd2_loc);
			fp_long3 = fp_reg.getLong(rf3);
			fp_mpy_unnorm_dh(); // RPI-767 big_int1=long2*long3
			fp_get_bi_unnorm_dh();
			fp_get_bi_unnorm_dh();
			tz390.fp_exp = tz390.fp_exp - 14; // use low half exponent
			fp_add_bi_unnorm_dh();
			tz390.fp_exp = tz390.fp_exp + 14; // use low half exponent
			fp_put_bi_to_lh_wreg();
			fp_reg.putLong(rf1,tz390.fp_work_reg.getLong(0));
			break;
		case 0x3D: // 7460 "ED3D" "MYH" "RXF" Z9-51 // RPI-298
			psw_check = false; // RPI-298
			ins_setup_rxf();
			// unnormalized HFP RPI-767
			fp_store_reg(fp_reg,rf1);
			fp_long2 = mem.getLong(xbd2_loc);
			fp_long3 = fp_reg.getLong(rf3);
			fp_mpy_unnorm_dh(); // RPI-767 big_int1=long2*long3
			fp_put_bi_to_lh_wreg();
			fp_reg.putLong(rf1,tz390.fp_work_reg.getLong(0));
			break;
		case 0x3E: // 6960 "ED3E" "MAD" "RXF"
			psw_check = false;
			ins_setup_rxf();
			fp_rbdv1 = fp_get_bd_from_dh(mem, xbd2_loc)
					 .multiply(fp_get_bd_from_dh(fp_reg, rf3))
					 .add(fp_get_bd_from_dh(fp_reg, rf1));  // RPI-821
			fp_put_bd(rf1, tz390.fp_dh_type, fp_rbdv1);  // RPI-821
			check_dh_mpy();
			break;
		case 0x3F: // 6970 "ED3F" "MSD" "RXF"
			psw_check = false;
			ins_setup_rxf();
			fp_rbdv1 = fp_get_bd_from_dh(mem, xbd2_loc)        // RPI-821
					.multiply(fp_get_bd_from_dh(fp_reg, rf3))  // RPI-821
					.subtract(fp_get_bd_from_dh(fp_reg, rf1)); // RPI-834 // RPI-821
			fp_put_bd(rf1, tz390.fp_dh_type, fp_rbdv1);        // RPI-821
			check_dh_mpy();
			break;
		case 0x40: // "SLDT" "ED40" "RXF" DFP 45
			psw_check = false;
			ins_setup_rxf();
			fp_rbdv1 = fp_get_bd_from_dd(fp_reg,rf3);
			if ((xbd2_loc & 0x3f) != 0) {  // RPI-1015
				work_fp_bi1 = fp_rbdv1
						.unscaledValue()
						.multiply(BigInteger.TEN.pow(xbd2_loc & 0x3f))
						.mod(fp_dd_mod_bi);
				fp_rbdv1 = new BigDecimal(work_fp_bi1).scaleByPowerOfTen(-fp_rbdv1.scale()); // RPI-811
			}
			fp_put_bd(rf1, tz390.fp_dd_type, fp_rbdv1);
			fp_store_reg(fp_reg, rf1); // RPI-787
			break;
		case 0x41: // "SRDT" "ED41" "RXF" DFP 46
			psw_check = false;
			ins_setup_rxf();
			fp_rbdv1 = fp_get_bd_from_dd(fp_reg,rf3);
			work_fp_bi1 = fp_rbdv1
					.unscaledValue()
					.divide(BigInteger.TEN.pow((xbd2_loc & 0x3f)));
				fp_rbdv1 = new BigDecimal(work_fp_bi1).scaleByPowerOfTen(-fp_rbdv1.scale()); // RPI-811
			fp_put_bd(rf1, tz390.fp_dd_type, fp_rbdv1);
			fp_store_reg(fp_reg, rf1); // RPI-787
			break;
		case 0x48: // "SLXT" "ED48" "RXF" DFP 47
			psw_check = false;
			ins_setup_rxf_shift(); // RPI-1015
			fp_rbdv1 = fp_get_bd_from_ld(fp_reg,rf3);
			if ((xbd2_loc & 0x3f) != 0) {  // RPI-1015
				work_fp_bi1 = fp_rbdv1
						.unscaledValue()
						.multiply(BigInteger.TEN.pow(xbd2_loc & 0x3f))
						.mod(fp_ld_mod_bi);
				fp_rbdv1 = new BigDecimal(work_fp_bi1).scaleByPowerOfTen(-fp_rbdv1.scale()); // RPI-811
			}
			fp_put_bd(rf1, tz390.fp_ld_type, fp_rbdv1);
			fp_store_reg(fp_reg, rf1); // RPI-787
			break;
		case 0x49: // "SRXT" "ED49" "RXF" DFP 48
			psw_check = false;
			ins_setup_rxf_shift(); // RPI-1015
			fp_rbdv1 = fp_get_bd_from_ld(fp_reg,rf3);
			work_fp_bi1 = fp_rbdv1
					.unscaledValue()
					.divide(BigInteger.TEN.pow(xbd2_loc & 0x3f));
			fp_rbdv1 = new BigDecimal(work_fp_bi1).movePointLeft(fp_rbdv1.scale());
			fp_put_bd(rf1, tz390.fp_ld_type, fp_rbdv1);
			fp_store_reg(fp_reg, rf1); // RPI-787
			break;
		case 0x50: // "TDCET" "ED50" "RXE" DFP 49
			psw_check = false;
			ins_setup_rxe();
			fp_rbdv1 = fp_get_bd_from_ed(fp_reg, rf1);
			psw_cc = psw_cc0;
			if ((xbd2_loc & 0x800) != 0 && fp_rbdv1.signum() == 0) {
				psw_cc = psw_cc1; // +0
			}
			if ((xbd2_loc & 0x400) != 0 && fp_rbdv1.signum() == 0) {
				psw_cc = psw_cc1; // -0
			}
			if ((xbd2_loc & 0x200) != 0
				&& fp_rbdv1.signum() > 0
				&& (fp_rbdv1.compareTo(fp_ed_pos_min) < 0
					|| fp_rbdv1.compareTo(fp_ed_pos_max) > 0)
				) {
				psw_cc = psw_cc1; // +subnormal
			}
			if ((xbd2_loc & 0x100) != 0
				&& fp_rdv1 < 0
				&& (fp_rbdv1.compareTo(fp_ed_neg_min) > 0
						|| fp_rbdv1.compareTo(fp_ed_neg_max) < 0)
				) {
				psw_cc = psw_cc1; // -subnormal
			}
			if ((xbd2_loc & 0x080) != 0
				 && fp_rbdv1.signum() > 0
				 && fp_rbdv1.compareTo(fp_ed_pos_min) >= 0
				 && fp_rbdv1.compareTo(fp_ed_pos_max) <= 0
				 ) {
				psw_cc = psw_cc1; //+normal
			}
			if ((xbd2_loc & 0x040) != 0
				 && fp_rbdv1.signum() < 0
				 && fp_rbdv1.compareTo(fp_ed_neg_min) <= 0
				 && fp_rbdv1.compareTo(fp_ed_neg_max) >= 0
				 ) {
				psw_cc = psw_cc1; //-normal
			}
			if ((xbd2_loc & 0x020) != 0) {
				// psw_cc = psw_cc1; //+infinity
			}
			if ((xbd2_loc & 0x010) != 0) {
				// psw_cc = psw_cc1; //-infinity
			}
			if ((xbd2_loc & 0x008) != 0) {
				// psw_cc = psw_cc1; //+quiet nan
			}
			if ((xbd2_loc & 0x004) != 0) {
				// psw_cc = psw_cc1; //-quiet nan
			}
			if ((xbd2_loc & 0x002) != 0) {
				// psw_cc = psw_cc1; //+signaling nan
			}
			if ((xbd2_loc & 0x001) != 0) {
				// psw_cc = psw_cc1; //-signaling nan
			}
			break;
		case 0x51: // "TDGET" "ED51" "RXE" DFP 50
			psw_check = false;
			ins_setup_rxe();
			fp_rbdv1 = fp_get_bd_from_ed(fp_reg, rf1);
			psw_cc = psw_cc0;
			if ((xbd2_loc & 0x800) != 0
				&& fp_rbdv1.signum() == 0
				&& fp_rbdv1.scale() >= fp_ed_exp_min
				&& fp_rbdv1.scale() <= fp_ed_exp_max
				) {
				psw_cc = psw_cc1; // + safe 0
			}
			if ((xbd2_loc & 0x400) != 0
				&& fp_rbdv1.signum() == 0
				&& fp_rbdv1.scale() >= fp_ed_exp_min
				&& fp_rbdv1.scale() <= fp_ed_exp_max
			) {
				psw_cc = psw_cc1; // - safe 0
			}
			if ((xbd2_loc & 0x200) != 0
				&& fp_rbdv1.signum() == 0
				&& (fp_rbdv1.scale() < fp_ed_exp_min
					|| fp_rbdv1.scale() > fp_ed_exp_max)
				) {
				psw_cc = psw_cc1; // + extreme zero
			}
			if ((xbd2_loc & 0x100) != 0
				&& fp_rdv1 < 0
				&& (fp_rbdv1.scale() < fp_ed_exp_min
					|| fp_rbdv1.scale() > fp_ed_exp_max)
				) {
				psw_cc = psw_cc1; // - extreme zero
			}
			if ((xbd2_loc & 0x080) != 0
				 && fp_rbdv1.signum() > 0
				 && (fp_rbdv1.scale() < fp_ed_exp_min
					 ||	fp_rbdv1.scale() > fp_ed_exp_max)
				 ) {
				psw_cc = psw_cc1; //+ extreme finite
			}
			if ((xbd2_loc & 0x040) != 0
				 && fp_rbdv1.signum() < 0
					 && (fp_rbdv1.scale() < fp_ed_exp_min
					|| fp_rbdv1.scale() > fp_ed_exp_max)
				 ) {
				psw_cc = psw_cc1; // - extreme finite
			}
			if ((xbd2_loc & 0x020) != 0
				&& fp_rbdv1.signum() > 0
				&& fp_rbdv1.scale() >= fp_ed_exp_min
				&& fp_rbdv1.scale() <= fp_ed_exp_max
				&& fp_rbdv1.abs().unscaledValue()
				   .toString().length() < tz390.fp_ed_digits
				) {
				psw_cc = psw_cc1; //+ safe finite
			}
			if ((xbd2_loc & 0x010) != 0
				&& fp_rbdv1.signum() < 0
				&& fp_rbdv1.scale() >= fp_ed_exp_min
				&& fp_rbdv1.scale() <= fp_ed_exp_max
				&& fp_rbdv1.abs().unscaledValue()
				   .toString().length() < tz390.fp_ed_digits
				) {
				psw_cc = psw_cc1; // - safe finite
			}
			if ((xbd2_loc & 0x008) != 0
				&& fp_rbdv1.signum() > 0
				&& fp_rbdv1.scale() >= fp_ed_exp_min
				&& fp_rbdv1.scale() <= fp_ed_exp_max
				&& fp_rbdv1.abs().unscaledValue()
				   .toString().length() >= tz390.fp_ed_digits
			    ) {
				psw_cc = psw_cc1; // + non zero lmd non extreem exp
			}
			if ((xbd2_loc & 0x004) != 0
					&& fp_rbdv1.signum() < 0
					&& fp_rbdv1.scale() >= fp_ed_exp_min
					&& fp_rbdv1.scale() <= fp_ed_exp_max
					&& fp_rbdv1.abs().unscaledValue()
					   .toString().length() >= tz390.fp_ed_digits
				) {
				psw_cc = psw_cc1; // - non zero lmd non extreme exp
			}
			if ((xbd2_loc & 0x002) != 0) {
				// psw_cc = psw_cc1; //+ infinity or nan
			}
			if ((xbd2_loc & 0x001) != 0) {
				// psw_cc = psw_cc1; // - infinity or nan
			}
			break;
		case 0x54: // "TDCDT" "ED54" "RXE" DFP 51
			psw_check = false;
			ins_setup_rxe();
			fp_rbdv1 = fp_get_bd_from_dd(fp_reg, rf1);
			psw_cc = psw_cc0;
			if ((xbd2_loc & 0x800) != 0 && fp_rbdv1.signum() == 0) {
				psw_cc = psw_cc1; // +0
			}
			if ((xbd2_loc & 0x400) != 0 && fp_rbdv1.signum() == 0) {
				psw_cc = psw_cc1; // -0
			}
			if ((xbd2_loc & 0x200) != 0
				&& fp_rbdv1.signum() > 0
				&& (fp_rbdv1.compareTo(fp_dd_pos_min) < 0
					|| fp_rbdv1.compareTo(fp_dd_pos_max) > 0)
				) {
				psw_cc = psw_cc1; // +subnormal
			}
			if ((xbd2_loc & 0x100) != 0
				&& fp_rdv1 < 0
				&& (fp_rbdv1.compareTo(fp_dd_neg_min) > 0
						|| fp_rbdv1.compareTo(fp_dd_neg_max) < 0)
				) {
				psw_cc = psw_cc1; // -subnormal
			}
			if ((xbd2_loc & 0x080) != 0
				 && fp_rbdv1.signum() > 0
				 && fp_rbdv1.compareTo(fp_dd_pos_min) >= 0
				 && fp_rbdv1.compareTo(fp_dd_pos_max) <= 0
				 ) {
				psw_cc = psw_cc1; //+normal
			}
			if ((xbd2_loc & 0x040) != 0
				 && fp_rbdv1.signum() < 0
				 && fp_rbdv1.compareTo(fp_dd_neg_min) <= 0
				 && fp_rbdv1.compareTo(fp_dd_neg_max) >= 0
				 ) {
				psw_cc = psw_cc1; //-normal
			}
			if ((xbd2_loc & 0x020) != 0) {
				// psw_cc = psw_cc1; //+infinity
			}
			if ((xbd2_loc & 0x010) != 0) {
				// psw_cc = psw_cc1; //-infinity
			}
			if ((xbd2_loc & 0x008) != 0) {
				// psw_cc = psw_cc1; //+quiet nan
			}
			if ((xbd2_loc & 0x004) != 0) {
				// psw_cc = psw_cc1; //-quiet nan
			}
			if ((xbd2_loc & 0x002) != 0) {
				// psw_cc = psw_cc1; //+signaling nan
			}
			if ((xbd2_loc & 0x001) != 0) {
				// psw_cc = psw_cc1; //-signaling nan
			}
			break;
		case 0x55: // "TDGDT" "ED55" "RXE" DFP 52
			psw_check = false;
			ins_setup_rxe();
			fp_rbdv1 = fp_get_bd_from_dd(fp_reg, rf1);
			psw_cc = psw_cc0;
			if ((xbd2_loc & 0x800) != 0
				&& fp_rbdv1.signum() == 0
				&& fp_rbdv1.scale() >= fp_dd_exp_min
				&& fp_rbdv1.scale() <= fp_dd_exp_max
			    ) {
				psw_cc = psw_cc1; // + safe 0
			}
			if ((xbd2_loc & 0x400) != 0
				&& fp_rbdv1.signum() == 0
				&& fp_rbdv1.scale() >= fp_dd_exp_min
				&& fp_rbdv1.scale() <= fp_dd_exp_max
			) {
				psw_cc = psw_cc1; // - safe 0
			}
			if ((xbd2_loc & 0x200) != 0
				&& fp_rbdv1.signum() == 0
				&& (fp_rbdv1.scale() < fp_dd_exp_min
					|| fp_rbdv1.scale() > fp_dd_exp_max)
				) {
				psw_cc = psw_cc1; // + extreme zero
			}
			if ((xbd2_loc & 0x100) != 0
				&& fp_rdv1 < 0
				&& (fp_rbdv1.scale() < fp_dd_exp_min
					|| fp_rbdv1.scale() > fp_dd_exp_max)
				) {
				psw_cc = psw_cc1; // - extreme zero
			}
			if ((xbd2_loc & 0x080) != 0
				 && fp_rbdv1.signum() > 0
				 && (fp_rbdv1.scale() < fp_dd_exp_min
					 ||	fp_rbdv1.scale() > fp_dd_exp_max)
				 ) {
				psw_cc = psw_cc1; //+ extreme finite
			}
			if ((xbd2_loc & 0x040) != 0
				 && fp_rbdv1.signum() < 0
					 && (fp_rbdv1.scale() < fp_dd_exp_min
					|| fp_rbdv1.scale() > fp_dd_exp_max)
				 ) {
				psw_cc = psw_cc1; // - extreme finite
			}
			if ((xbd2_loc & 0x020) != 0
				&& fp_rbdv1.signum() > 0
				&& fp_rbdv1.scale() >= fp_dd_exp_min
				&& fp_rbdv1.scale() <= fp_dd_exp_max
				&& fp_rbdv1.abs().unscaledValue()
				   .toString().length() < tz390.fp_dd_digits
				) {
				psw_cc = psw_cc1; //+ safe finite
			}
			if ((xbd2_loc & 0x010) != 0
				&& fp_rbdv1.signum() < 0
				&& fp_rbdv1.scale() >= fp_dd_exp_min
				&& fp_rbdv1.scale() <= fp_dd_exp_max
				&& fp_rbdv1.abs().unscaledValue()
				   .toString().length() < tz390.fp_dd_digits
			    ) {
				psw_cc = psw_cc1; // - safe finite
			}
			if ((xbd2_loc & 0x008) != 0
				&& fp_rbdv1.signum() > 0
				&& fp_rbdv1.scale() >= fp_dd_exp_min
				&& fp_rbdv1.scale() <= fp_dd_exp_max
				&& fp_rbdv1.abs().unscaledValue()
				   .toString().length() >= tz390.fp_dd_digits
			    ) {
				psw_cc = psw_cc1; // + non zero lmd non extreem exp
			}
			if ((xbd2_loc & 0x004) != 0
					&& fp_rbdv1.signum() < 0
					&& fp_rbdv1.scale() >= fp_dd_exp_min
					&& fp_rbdv1.scale() <= fp_dd_exp_max
					&& fp_rbdv1.abs().unscaledValue()
					   .toString().length() >= tz390.fp_dd_digits
				) {
				psw_cc = psw_cc1; // - non zero lmd non extreme exp
			}
			if ((xbd2_loc & 0x002) != 0) {
				// psw_cc = psw_cc1; //+ infinity or nan
			}
			if ((xbd2_loc & 0x001) != 0) {
				// psw_cc = psw_cc1; // - infinity or nan
			}
			break;
		case 0x58: // "" "ED58" "RXE" DFP 53
			psw_check = false;
			ins_setup_rxe();
			fp_rbdv1 = fp_get_bd_from_ld(fp_reg, rf1);
			psw_cc = psw_cc0;
			if ((xbd2_loc & 0x800) != 0 && fp_rbdv1.signum() == 0) {
				psw_cc = psw_cc1; // +0
			}
			if ((xbd2_loc & 0x400) != 0 && fp_rbdv1.signum() == 0) {
				psw_cc = psw_cc1; // -0
			}
			if ((xbd2_loc & 0x200) != 0
				&& fp_rbdv1.signum() > 0
				&& (fp_rbdv1.compareTo(fp_ld_pos_min) < 0
					|| fp_rbdv1.compareTo(fp_ld_pos_max) > 0)
				) {
				psw_cc = psw_cc1; // +subnormal
			}
			if ((xbd2_loc & 0x100) != 0
				&& fp_rdv1 < 0
				&& (fp_rbdv1.compareTo(fp_ld_neg_min) > 0
					|| fp_rbdv1.compareTo(fp_ld_neg_max) < 0)
				) {
				psw_cc = psw_cc1; // -subnormal
			}
			if ((xbd2_loc & 0x080) != 0
				 && fp_rbdv1.signum() > 0
				 && fp_rbdv1.compareTo(fp_ld_pos_min) >= 0
				 && fp_rbdv1.compareTo(fp_ld_pos_max) <= 0
				 ) {
				psw_cc = psw_cc1; //+normal
			}
			if ((xbd2_loc & 0x040) != 0
				 && fp_rbdv1.signum() < 0
				 && fp_rbdv1.compareTo(fp_ld_neg_min) <= 0
				 && fp_rbdv1.compareTo(fp_ld_neg_max) >= 0
				 ) {
				psw_cc = psw_cc1; //-normal
			}
			if ((xbd2_loc & 0x020) != 0) {
				// psw_cc = psw_cc1; //+infinity
			}
			if ((xbd2_loc & 0x010) != 0) {
				// psw_cc = psw_cc1; //-infinity
			}
			if ((xbd2_loc & 0x008) != 0) {
				// psw_cc = psw_cc1; //+quiet nan
			}
			if ((xbd2_loc & 0x004) != 0) {
				// psw_cc = psw_cc1; //-quiet nan
			}
			if ((xbd2_loc & 0x002) != 0) {
				// psw_cc = psw_cc1; //+signaling nan
			}
			if ((xbd2_loc & 0x001) != 0) {
				// psw_cc = psw_cc1; //-signaling nan
			}
			break;
		case 0x59: // "TDGXT" "ED59" "RXE" DFP 54
			psw_check = false;
			ins_setup_rxe();
			fp_rbdv1 = fp_get_bd_from_ld(fp_reg, rf1);
			psw_cc = psw_cc0;
			if ((xbd2_loc & 0x800) != 0
				&& fp_rbdv1.signum() == 0
				&& fp_rbdv1.scale() >= fp_ld_exp_min
				&& fp_rbdv1.scale() <= fp_ld_exp_max
			    ) {
				psw_cc = psw_cc1; // + safe 0
			}
			if ((xbd2_loc & 0x400) != 0
				&& fp_rbdv1.signum() == 0
				&& fp_rbdv1.scale() >= fp_ld_exp_min
				&& fp_rbdv1.scale() <= fp_ld_exp_max
			) {
				psw_cc = psw_cc1; // - safe 0
			}
			if ((xbd2_loc & 0x200) != 0
				&& fp_rbdv1.signum() == 0
				&& (fp_rbdv1.scale() < fp_ld_exp_min
					|| fp_rbdv1.scale() > fp_ld_exp_max)
				) {
				psw_cc = psw_cc1; // + extreme zero
			}
			if ((xbd2_loc & 0x100) != 0
				&& fp_rdv1 < 0
				&& (fp_rbdv1.scale() < fp_ld_exp_min
					|| fp_rbdv1.scale() > fp_ld_exp_max)
				) {
				psw_cc = psw_cc1; // - extreme zero
			}
			if ((xbd2_loc & 0x080) != 0
				 && fp_rbdv1.signum() > 0
				 && (fp_rbdv1.scale() < fp_ld_exp_min
					 ||	fp_rbdv1.scale() > fp_ld_exp_max)
				 ) {
				psw_cc = psw_cc1; //+ extreme finite
			}
			if ((xbd2_loc & 0x040) != 0
				 && fp_rbdv1.signum() < 0
					 && (fp_rbdv1.scale() < fp_ld_exp_min
					|| fp_rbdv1.scale() > fp_ld_exp_max)
				 ) {
				psw_cc = psw_cc1; // - extreme finite
			}
			if ((xbd2_loc & 0x020) != 0
				&& fp_rbdv1.signum() > 0
				&& fp_rbdv1.scale() >= fp_ld_exp_min
				&& fp_rbdv1.scale() <= fp_ld_exp_max
				&& fp_rbdv1.abs().unscaledValue()
				   .toString().length() < tz390.fp_ld_digits
				) {
				psw_cc = psw_cc1; //+ safe finite
			}
			if ((xbd2_loc & 0x010) != 0
				&& fp_rbdv1.signum() < 0
				&& fp_rbdv1.scale() >= fp_ld_exp_min
				&& fp_rbdv1.scale() <= fp_ld_exp_max
				&& fp_rbdv1.abs().unscaledValue()
				   .toString().length() < tz390.fp_ld_digits
				) {
				psw_cc = psw_cc1; // - safe finite
			}
			if ((xbd2_loc & 0x008) != 0
				&& fp_rbdv1.signum() > 0
				&& fp_rbdv1.scale() >= fp_ld_exp_min
				&& fp_rbdv1.scale() <= fp_ld_exp_max
				&& fp_rbdv1.abs().unscaledValue()
				   .toString().length() >= tz390.fp_ld_digits
				) {
				psw_cc = psw_cc1; // + non zero lmd non extreem exp
			}
			if ((xbd2_loc & 0x004) != 0
					&& fp_rbdv1.signum() < 0
					&& fp_rbdv1.scale() >= fp_ld_exp_min
					&& fp_rbdv1.scale() <= fp_ld_exp_max
					&& fp_rbdv1.abs().unscaledValue()
					   .toString().length() >= tz390.fp_ld_digits
				) {
				psw_cc = psw_cc1; // - non zero lmd non extreme exp
			}
			if ((xbd2_loc & 0x002) != 0) {
				// psw_cc = psw_cc1; //+ infinity or nan
			}
			if ((xbd2_loc & 0x001) != 0) {
				// psw_cc = psw_cc1; // - infinity or nan
			}
			break;
		case 0x64: // 6980 "ED64" "LEY" "RXY"
			psw_check = false;
			ins_setup_rxy();
			fp_load_reg(rf1, tz390.fp_eh_type, mem, xbd2_loc,
					tz390.fp_eh_type);
			break;
		case 0x65: // 6990 "ED65" "LDY" "RXY"
			psw_check = false;
			ins_setup_rxy();
			fp_load_reg(rf1, tz390.fp_dh_type, mem, xbd2_loc,
					tz390.fp_dh_type);
			break;
		case 0x66: // 7000 "ED66" "STEY" "RXY"
			psw_check = false;
			ins_setup_rxy();
			if (fp_reg_ctl[mf1] != fp_ctl_ld) {
				fp_store_reg(fp_reg, rf1);
			}
			mem.putInt(xbd2_loc, fp_reg.getInt(rf1));
			break;
		case 0x67: // 7010 "ED67" "STDY" "RXY"
			psw_check = false;
			ins_setup_rxy();
			if (fp_reg_ctl[mf1] != fp_ctl_ld) {
				fp_store_reg(fp_reg, rf1);
			}
			mem.putLong(xbd2_loc, fp_reg.getLong(rf1));
			break;
		}
	}

	/*
	 * end of ez390 emulator while switch code
	 */

	/*
	 * ********************************************* instruction setup routines ********************************************
	 */
	private void ins_setup_dm() { // "DM" 1 DIAGNOSE 83000000
		psw_ins_len = 4;
		if (tz390.opt_trace) {
			trace_ins();
		}
		if (ex_mode) {
			ex_restore();
		}
		psw_loc = psw_loc + 4;
	}

	private void ins_setup_e() { // "E" 8 PR oooo
		psw_ins_len = 2;
		if (tz390.opt_trace) {
			trace_ins();
		}
		if (ex_mode) {
			ex_restore();
		}
		psw_loc = psw_loc + 2;
	}

	private void ins_setup_i() { // "I" 1 SVC 00ii
		if1 = mem_byte[psw_loc + 1] & 0xff;
		psw_ins_len = 2;
		if (tz390.opt_trace
			|| (tz390.opt_tracet // RPI-689 TRACET TCPIO and TGET/TPUT
				&& (if1 == 93 || if1 == 0x7c))) {
			trace_ins();
		}
		if (ex_mode) {
			ex_restore();
		}
		psw_loc = psw_loc + 2;
	}

	private void ins_setup_ri() { // "RI" 37 IIHH ooroiiii
		/*
		 * fetch rf1 and if2
		 */
		rf1 = (mem_byte[psw_loc + 1] & 0xf0) >> 1;
		mf1 = rf1 >> 3;
		if2 = mem.getShort(psw_loc + 2);
		psw_ins_len = 4;
		if (tz390.opt_trace) {
			trace_ins();
		}
		if (ex_mode) {
			ex_restore();
		}
		psw_loc = psw_loc + 4;
	}

	private void ins_setup_rie() { // "RIE" 4 BRXLG oorriiii00oo
		psw_ins_len = 6;
		rf1 = mem_byte[psw_loc + 1] & 0xff;
		mf3 = rf1 & 0xf;
		rf3 = mf3 << 3;
		rf1 = (rf1 & 0xf0) >> 1;
		mf1 = rf1 >> 3;
		if2 = mem.getShort(psw_loc + 2);
		if (tz390.opt_trace) {
			trace_ins();
		}
		if (ex_mode) {
			ex_restore();
		}
		psw_loc = psw_loc + 6;
	}
	private void ins_setup_rie2() { // "RIE2" CIT oor0iiiim0oo
		psw_ins_len = 6;
		rf1 = (mem_byte[psw_loc + 1] & 0xf0) >> 1;
		mf1 = rf1 >> 3;
		if2 = mem.getShort(psw_loc + 2);
		mf3 = (mem_byte[psw_loc +4] & 0xf0) >> 4;
		if (tz390.opt_trace) {
			trace_ins();
		}
		if (ex_mode) {
			ex_restore();
		}
		psw_loc = psw_loc + 6;
	}
	private void ins_setup_rie4() { // "RIE4" CGIJ oorm444422oo r1,i2,m3,i4
		psw_ins_len = 6;
		mf3 = mem_byte[psw_loc + 1];
		rf1 = (mf3 & 0xf0) >> 1;
		mf1 = rf1 >> 3;
		if2 = mem.get(psw_loc + 4);
		mf3 = mf3 & 0xf;
		if4 = mem.getShort(psw_loc+2);
		bd4_loc = psw_loc + 2 * if4;
		if (tz390.opt_trace) {
			trace_ins();
		}
		if (ex_mode) {
			ex_restore();
		}
		psw_loc = psw_loc + 6;
	}
	private void ins_setup_rie6() { // "RIE6" CGRJ oorr4444m0oo r1,r2,m3,i4
		psw_ins_len = 6;
		rf1 = mem_byte[psw_loc + 1] & 0xff;
		mf2 = rf1 & 0xf;
		rf2 = mf2 << 3;
		rf1 = (rf1 & 0xf0) >> 1;
		mf1 = rf1 >> 3;
		if4 = mem.getShort(psw_loc + 2);
		bd4_loc = psw_loc + 2 * if4;
		mf3 = (mem_byte[psw_loc+4] & 0xf0) >> 4;
		if (tz390.opt_trace) {
			trace_ins();
		}
		if (ex_mode) {
			ex_restore();
		}
		psw_loc = psw_loc + 6;
	}
	private void ins_setup_rie8() { // "RIE8" RNSBG oo12334455oo r1,r2,i3,i4,i5
		psw_ins_len = 6;
		rf1 = mem_byte[psw_loc + 1] & 0xff;
		mf2 = rf1 & 0xf;
		rf2 = mf2 << 3;
		rf1 = (rf1 & 0xf0) >> 1;
		mf1 = rf1 >> 3;
		rlv1 = reg.getLong(rf1);
		rlv2 = reg.getLong(rf2);
		if3 = mem.get(psw_loc + 2);
		if4 = mem.get(psw_loc + 3);
		if5 = mem.get(psw_loc + 4) & 0x3f;
		if (tz390.opt_trace) {
			trace_ins();
		}
		if (ex_mode) {
			ex_restore();
		}
		psw_loc = psw_loc + 6;
	}
	private void ins_setup_rie9() { // "RIE9" AHIK r1,r3,i2 oo13iiii00oo RPI-1125
		psw_ins_len = 6;
		rf1 = mem_byte[psw_loc + 1] & 0xff;
		mf3 = rf1 & 0xf;
		rf3 = mf3 << 3;
		rf1 = (rf1 & 0xf0) >> 1;
		mf1 = rf1 >> 3;
		if2 = mem.getShort(psw_loc + 2);
		if (ex_mode) {
			ex_restore();
		}
		psw_loc = psw_loc + 6;
	}
	private void ins_setup_rrs1() { // "RRS1" CGRB oo12dbbbm0oo r1,r2,m3,s4
		psw_ins_len = 6;
		rf1 = mem_byte[psw_loc + 1] & 0xff;
		mf2 = rf1 & 0xf;
		rf2 = mf2 << 3;
		mf1 = rf1 >> 4;
		rf1 = mf1 << 3;
		if2 = mem.get(psw_loc + 4);
		mf3 = (mem_byte[psw_loc + 4] & 0xf0) >> 4;
		bf4 = mem.getShort(psw_loc + 2) & 0xffff;
		df4 = bf4 & 0xfff;
		bf4 = (bf4 & 0xf000) >> 9;
		if (bf4 > 0) {
			bd4_loc = (reg.getInt(bf4 + 4) + df4) & psw_amode; // RPI-815
		} else {
			bd4_loc = df4;
		}
		if (tz390.opt_trace) {
			trace_ins();
		}
		if (ex_mode) {
			ex_restore();
		}
		psw_loc = psw_loc + 6;
	}
	private void ins_setup_rrs3() { // "RRS3" CGIB oormdbbb22oo r1,i2,m3,i4
		psw_ins_len = 6;
		mf3 = mem_byte[psw_loc + 1];
		rf1 = (mf3 & 0xf0) >> 1;
		mf1 = rf1 >> 3;
		if2 = mem.get(psw_loc + 4);
		mf3 = mf3 & 0xf;
		bf4 = mem.getShort(psw_loc + 2) & 0xffff;
		df4 = bf4 & 0xfff;
		bf4 = (bf4 & 0xf000) >> 9;
		if (bf4 > 0) {
			bd4_loc = (reg.getInt(bf4 + 4) + df4) & psw_amode; // RPI-815
		} else {
			bd4_loc = df4;
		}
		if (tz390.opt_trace) {
			trace_ins();
		}
		if (ex_mode) {
			ex_restore();
		}
		psw_loc = psw_loc + 6;
	}
	private void ins_setup_ril() { // "RIL" 6 BRCL oomollllllll
		psw_ins_len = 6;
		rf1 = (mem_byte[psw_loc + 1] & 0xf0) >> 1;
		mf1 = rf1 >> 3;
		if2 = mem.getInt(psw_loc + 2);
		bd2_loc = (psw_loc + 2 * if2) & psw_amode; // RPI-817
		if (tz390.opt_trace) {
			trace_ins();
		}
		if (ex_mode) {
			ex_restore();
		}
		psw_loc = psw_loc + 6;
	}

	private void ins_setup_rr() { // "RR" 60 LR oorr
		/*
		 * fetch rf1,rf2 and update psw
		 */
		rf1 = mem_byte[psw_loc + 1] & 0xff;
		mf2 = rf1 & 0xf;
		rf2 = mf2 << 3;
		rf1 = (rf1 & 0xf0) >> 1;
		mf1 = rf1 >> 3;
		psw_ins_len = 2;
		if (tz390.opt_trace) {
			trace_ins();
		}
		if (ex_mode) {
			ex_restore();
		}
		psw_loc = psw_loc + 2;
	}

	private void ins_setup_rre() { // "RRE" 185 MSR oooo00rr
		psw_ins_len = 4;
		rf1 = mem_byte[psw_loc + 3] & 0xff;
		mf2 = rf1 & 0xf;
		rf2 = mf2 << 3;
		rf1 = (rf1 & 0xf0) >> 1;
		mf1 = rf1 >> 3;
		if (tz390.opt_trace) {
			trace_ins();
		}
		if (ex_mode) {
			ex_restore();
		}
		psw_loc = psw_loc + 4;
	}

	private void ins_setup_rrf1() { // RPI-206 "RRF1" 28 MAER oooor0rr
		// maps r1,r3,r2 to oooo1032
		psw_ins_len = 4;
		rf1 = (mem_byte[psw_loc + 2] & 0xf0) >> 1;
		mf1 = rf1 >> 3;
		rf3 = mem_byte[psw_loc + 3];
		mf2 = rf3 & 0x0f;
		rf2 = mf2 << 3;
		rf3 = (rf3 & 0xf0) >> 1;
		mf3 = rf3 >> 3;
		if (tz390.opt_trace) {
           trace_ins();
		}
		if (ex_mode) {
			ex_restore();
		}
		psw_loc = psw_loc + 4;
	}

	private void ins_setup_rrf2() { // RPI-206 "RRF2" 28 FIEBR oooo3012
		// maps r1,r3,r2 to 3012
		psw_ins_len = 4;
		rf3 = (mem_byte[psw_loc + 2] & 0xf0) >> 1; // RPI-206 RPI-335
		mf3 = rf3 >> 3; // RPI-335
		rf1 = mem_byte[psw_loc + 3];
		mf2 = rf1 & 0x0f;
		rf2 = mf2 << 3;
		rf1 = (rf1 & 0xf0) >> 1;
		mf1 = rf1 >> 3;
		if (tz390.opt_trace) {
			trace_ins();
		}
		if (ex_mode) {
			ex_restore();
		}
		psw_loc = psw_loc + 4;
	}

	private void ins_setup_rrf3() { // RPI-206 "RRF3" 28 DIEBR/DIDBR oooor0rr
		// maps r1,r3,r2,m4 to oooo3412)
		psw_ins_len = 4;
		rf3 = mem_byte[psw_loc + 2];
		mf4 = rf3 & 0xf;
		rf3 = (rf3 & 0xf0) >> 1;
		mf3 = rf3 >> 3;
		rf1 = mem_byte[psw_loc + 3];
		mf2 = rf1 & 0xf;
		rf2 = mf2 << 3;
		rf1 = (rf1 & 0xf0) >> 1;
		mf1 = rf1 >> 3;
		if (tz390.opt_trace) {
			trace_ins();
		}
		if (ex_mode) {
			ex_restore();
		}
		psw_loc = psw_loc + 4;
	}

	private void ins_setup_rrf4() { // RPI-407 "RRF4" 28 CSDTR oooo0412
		// maps r1,r2,m4 to 0412
		psw_ins_len = 4;
		mf3 = mem_byte[psw_loc + 2] & 0xff; // RPI-533
		mf4 = mf3 & 0xf;
		mf3 = mf3 >>> 4;
		rf1 = mem_byte[psw_loc + 3];
		mf2 = rf1 & 0x0f;
		rf2 = mf2 << 3;
		rf1 = (rf1 & 0xf0) >> 1;
		mf1 = rf1 >> 3;
		if (tz390.opt_trace) {
			trace_ins();
		}
		if (ex_mode) {
			ex_restore();
		}
		psw_loc = psw_loc + 4;
	}
	private void ins_setup_rrf5() { // RPI-817 "RRF2" 28 FIEBR oooo3012
		// maps r1,r2,m3 to 3012
		psw_ins_len = 4;
		mf3 = (mem_byte[psw_loc + 2] & 0xf0) >> 4;
		rf3 = mf3 << 3; // RPI-1125
		rf1 = mem_byte[psw_loc + 3];
		mf2 = rf1 & 0x0f;
		rf2 = mf2 << 3;
		rf1 = (rf1 & 0xf0) >> 1;
		mf1 = rf1 >> 3;
		if (tz390.opt_trace) {
			trace_ins();
		}
		if (ex_mode) {
			ex_restore();
		}
		psw_loc = psw_loc + 4;
	}

	private void ins_setup_rrr() { // RPI-407 "ADTR" oooo3012 (r1,r2,r3
		psw_ins_len = 4;
		rf3 = (mem_byte[psw_loc + 2] & 0xf0) >> 1;
		mf3 = rf3 >> 3;
		rf1 = mem_byte[psw_loc + 3];
		mf2 = rf1 & 0x0f;
		rf2 = mf2 << 3;
		rf1 = (rf1 & 0xf0) >> 1;
		mf1 = rf1 >> 3;
		if (tz390.opt_trace) {
			trace_ins();
		}
		if (ex_mode) {
			ex_restore();
		}
		psw_loc = psw_loc + 4;
	}

	private void ins_setup_rs() { // "RS" 25 oorrbddd
		/*
		 * fetch rf1,rf3,bf2,df2 and update psw
		 */
		rf1 = mem_byte[psw_loc + 1] & 0xff;
		mf3 = rf1 & 0xf;
		rf3 = mf3 << 3;
		rf1 = (rf1 & 0xf0) >> 1;
		mf1 = rf1 >> 3;
		bf2 = mem.getShort(psw_loc + 2) & 0xffff;
		df2 = bf2 & 0xfff;
		bf2 = (bf2 & 0xf000) >> 9;
		if (bf2 > 0) {
			bd2_loc = (reg.getInt(bf2 + 4) + df2) & psw_amode;  // RPI-815
		} else {
			bd2_loc = df2;
		}
		psw_ins_len = 4;
		if (tz390.opt_trace) {
			trace_ins();
		}
		if (ex_mode) {
			ex_restore();
		}
		psw_loc = psw_loc + 4;
		if (bd2_loc >= tot_mem) {  // RPI-820
			set_psw_check(Constants.psw_pic_addr);
		}
	}
	private void ins_setup_rs_shift() { // "RS" 25 SLL oorrbddd RPI-820
		/*
		 * fetch rf1,rf3,bf2,df2 and update psw
		 * with no bd2 addr check for shifts
		 */
		rf1 = mem_byte[psw_loc + 1] & 0xff;
		mf3 = rf1 & 0xf;
		rf3 = mf3 << 3;
		rf1 = (rf1 & 0xf0) >> 1;
		mf1 = rf1 >> 3;
		bf2 = mem.getShort(psw_loc + 2) & 0xffff;
		df2 = bf2 & 0xfff;
		bf2 = (bf2 & 0xf000) >> 9;
		if (bf2 > 0) {
			bd2_loc = (reg.getInt(bf2 + 4) + df2) & psw_amode;  // RPI-815
		} else {
			bd2_loc = df2;
		}
		psw_ins_len = 4;
		if (tz390.opt_trace) {
			trace_ins();
		}
		if (ex_mode) {
			ex_restore();
		}
		psw_loc = psw_loc + 4;
	}
	private void ins_setup_rsi() { // "RSI" 4 BRXH oorriiii
		psw_ins_len = 4;
		rf1 = mem_byte[psw_loc + 1] & 0xff;
		mf3 = rf1 & 0xf;
		rf3 = mf3 << 3;
		rf1 = (rf1 & 0xf0) >> 1;
		mf1 = rf1 >> 3;
		if2 = mem.getShort(psw_loc + 2);
		if (tz390.opt_trace) {
			trace_ins();
		}
		if (ex_mode) {
			ex_restore();
		}
		psw_loc = psw_loc + 4;
	}

	private void ins_setup_rsl() { // "RSL" 1 TP oor0bddd00oo
		psw_ins_len = 6;
		rflen1 = ((mem_byte[psw_loc + 1] & 0xff) >> 4) + 1;
		bf1 = mem.getShort(psw_loc + 2) & 0xffff;
		df1 = bf1 & 0xfff;
		bf1 = (bf1 & 0xf000) >> 9;
		if (bf1 > 0) {
			bd1_loc = (reg.getInt(bf1 + 4) + df1) & psw_amode; // RPI-815
		} else {
			bd1_loc = df1;
		}
		if (tz390.opt_trace) {
			trace_ins();
		}
		if (ex_mode) {
			ex_restore();
		}
		psw_loc = psw_loc + 6;
	}

	private void ins_setup_rsy() { // "RSY" 31 LMG oorrbdddhhoo
		psw_ins_len = 6;
		rf1 = mem_byte[psw_loc + 1] & 0xff;
		mf3 = rf1 & 0xf;
		rf3 = mf3 << 3;
		rf1 = (rf1 & 0xf0) >> 1;
		mf1 = rf1 >> 3;
		bf2 = mem.getShort(psw_loc + 2);
		df2 = (bf2 & 0xfff) | (mem.get(psw_loc + 4) << 12); // RPI-387
		bf2 = (bf2 & 0xf000) >> 9;
		if (bf2 > 0) {
			bd2_loc = (reg.getInt(bf2 + 4) + df2) & psw_amode; // RPI-815
		} else {
			bd2_loc = df2;
		}
		if (tz390.opt_trace) {
			trace_ins();
		}
		if (ex_mode) {
			ex_restore();
		}
		psw_loc = psw_loc + 6;
		if (bd2_loc >= tot_mem) {
			set_psw_check(Constants.psw_pic_addr);
		}
	}
	private void ins_setup_rsy_shift() { // "RSY" 31 RLL/RLLG oorrbdddhhoo RPI-820
		psw_ins_len = 6;
		rf1 = mem_byte[psw_loc + 1] & 0xff;
		mf3 = rf1 & 0xf;
		rf3 = mf3 << 3;
		rf1 = (rf1 & 0xf0) >> 1;
		mf1 = rf1 >> 3;
		bf2 = mem.getShort(psw_loc + 2);
		df2 = (bf2 & 0xfff) | (mem.get(psw_loc + 4) << 12); // RPI-387
		bf2 = (bf2 & 0xf000) >> 9;
		if (bf2 > 0) {
			bd2_loc = (reg.getInt(bf2 + 4) + df2) & psw_amode; // RPI-815
		} else {
			bd2_loc = df2;
		}
		if (tz390.opt_trace) {
			trace_ins();
		}
		if (ex_mode) {
			ex_restore();
		}
		psw_loc = psw_loc + 6;
	}

	private void ins_setup_rx() { // "RX" 52 L oorxbddd
		/*
		 * fetch rf1,xf2,bf2,df2 and update psw
		 */
		rf1 = mem_byte[psw_loc + 1] & 0xff;
		mf1 = rf1 >> 4;
		xf2 = (rf1 & 0xf) << 3;
		rf1 = (rf1 & 0xf0) >> 1;
		bf2 = mem.getShort(psw_loc + 2) & 0xffff;
		df2 = bf2 & 0xfff;
		bf2 = (bf2 & 0xf000) >> 9;
		if (xf2 > 0) {
			xbd2_loc = (reg.getInt(xf2 + 4) + df2) & psw_amode;  // RPI-815
		} else {
			xbd2_loc = df2;
		}
		if (bf2 > 0) {
			xbd2_loc = (xbd2_loc + reg.getInt(bf2 + 4)) & psw_amode; // RPI-815
		}
		psw_ins_len = 4;
		if (tz390.opt_trace) {
			trace_ins();
		}
		if (ex_mode) {
			ex_restore();
		}
		psw_loc = psw_loc + 4;
		if (xbd2_loc >= tot_mem && opcode1 != 0x41) { // RPI-299
			set_psw_check(Constants.psw_pic_addr);
		}
	}
	private void ins_setup_rxss() { // "RX" 52 L oorxbddd
		/*
		 * Fetch rf1,xf1,bf1,df1, bf2, and df2 for ASSIST extended I/O instructions.
		 */
		xf1 = (mem_byte[psw_loc + 1] & 0xf) << 3;
		bf1 = mem.getShort(psw_loc + 2) & 0xffff;
		df1 = bf1 & 0xfff;
		bf1 = (bf1 & 0xf000) >> 9;
		if (xf1 > 0) {
			xbd1_loc = (reg.getInt(xf1 + 4) + df1) & psw_amode;  // RPI-815
		} else {
			xbd1_loc = df1;
		}
		if (bf1 > 0) {
			xbd1_loc = (xbd1_loc + reg.getInt(bf1 + 4)) & psw_amode; // RPI-815
		}
		bf2 = mem.getShort(psw_loc + 4) & 0xffff;
		df2 = bf2 & 0xfff;
		bf2 = (bf2 & 0xf000) >> 9;
		if (bf2 > 0) {
			bd2_loc = (reg.getInt(bf2 + 4) + df2) & psw_amode; // PRI 815
		} else {
			bd2_loc = df2;
		}
		psw_ins_len = 6;
		if (tz390.opt_trace) {
			trace_ins();
		}
		if (ex_mode) {
			ex_restore();
		}
		psw_loc = psw_loc + 6;
		if (xbd2_loc >= tot_mem && opcode1 != 0x41) { // RPI-299
			set_psw_check(Constants.psw_pic_addr);
		}
	}

	private void ins_setup_rxf() { // "RXF" 8 MAE oorxbdddr0oo (note r3 before r1)
		psw_ins_len = 6;
		rf3 = mem_byte[psw_loc + 1] & 0xff;
		xf2 = (rf3 & 0xf) << 3;
		rf3 = (rf3 & 0xf0) >> 1;
		mf3 = rf3 >> 3;
		rf1 = mem_byte[psw_loc + 4] & 0xf0;
		rf1 = rf1 >> 1;
		mf1 = rf1 >> 3;
		bf2 = mem.getShort(psw_loc + 2) & 0xffff;
		df2 = bf2 & 0xfff;
		bf2 = (bf2 & 0xf000) >> 9;
		if (xf2 > 0) {
			xbd2_loc = (reg.getInt(xf2 + 4) + df2) & psw_amode;  // RPI-815
		} else {
			xbd2_loc = df2;
		}
		if (bf2 > 0) {
			xbd2_loc = (xbd2_loc + reg.getInt(bf2 + 4)) & psw_amode; // RPI-815
		}
		if (tz390.opt_trace) {
			trace_ins();
		}
		if (ex_mode) {
			ex_restore();
		}
		psw_loc = psw_loc + 6;
		if (xbd2_loc >= tot_mem) { // RPI-299
			set_psw_check(Constants.psw_pic_addr);
		}
	}
	private void ins_setup_rxf_shift() { // "RXF" 8 MAE oorxbdddr0oo (note r3 before // RPI-1015
		// r1)
		psw_ins_len = 6;
		rf3 = mem_byte[psw_loc + 1] & 0xff;
		xf2 = (rf3 & 0xf) << 3;
		rf3 = (rf3 & 0xf0) >> 1;
		mf3 = rf3 >> 3;
		rf1 = mem_byte[psw_loc + 4] & 0xf0;
		rf1 = rf1 >> 1;
		mf1 = rf1 >> 3;
		bf2 = mem.getShort(psw_loc + 2) & 0xffff;
		df2 = bf2 & 0xfff;
		bf2 = (bf2 & 0xf000) >> 9;
		if (xf2 > 0) {
			xbd2_loc = (reg.getInt(xf2 + 4) + df2) & psw_amode; // RPI-815
		} else {
			xbd2_loc = df2;
		}
		if (bf2 > 0) {
			xbd2_loc = (xbd2_loc + reg.getInt(bf2 + 4)) & psw_amode; // rpi-815
		}
		if (tz390.opt_trace) {
			trace_ins();
		}
		if (ex_mode) {
			ex_restore();
		}
		psw_loc = psw_loc + 6;
	}
	private void ins_setup_rxe() { // "RXE" 28 ADB oorxbddd00oo
		psw_ins_len = 6;
		rf1 = mem_byte[psw_loc + 1] & 0xff;
		xf2 = (rf1 & 0xf) << 3;
		rf1 = (rf1 & 0xf0) >> 1;
		mf1 = rf1 >> 3;
		bf2 = mem.getShort(psw_loc + 2) & 0xffff;
		df2 = bf2 & 0xfff;
		bf2 = (bf2 & 0xf000) >> 9;
		if (xf2 > 0) {
			xbd2_loc = (reg.getInt(xf2 + 4) + df2) & psw_amode;  // RPI-815
		} else {
			xbd2_loc = df2;
		}
		if (bf2 > 0) {
			xbd2_loc = (xbd2_loc + reg.getInt(bf2 + 4)) & psw_amode; // RPI-815
		}
		if (tz390.opt_trace) {
			trace_ins();
		}
		if (ex_mode) {
			ex_restore();
		}
		psw_loc = psw_loc + 6;
		if (xbd2_loc >= tot_mem) { // RPI-299
			set_psw_check(Constants.psw_pic_addr);
		}
	}

	private void ins_setup_rxy() { // "RXY" 76 MLG oorxbdddhhoo
		psw_ins_len = 6;
		rf1 = mem_byte[psw_loc + 1] & 0xff;
		xf2 = (rf1 & 0xf) << 3;
		rf1 = (rf1 & 0xf0) >> 1;
		mf1 = rf1 >> 3;
		bf2 = mem.getShort(psw_loc + 2);
		df2 = (bf2 & 0xfff) | (mem.get(psw_loc + 4) << 12); // RPI-387
		bf2 = (bf2 & 0xf000) >> 9;
		if (xf2 > 0) {
			xbd2_loc = (reg.getInt(xf2 + 4) + df2) & psw_amode;  // RPI-815
		} else {
			xbd2_loc = df2;
		}
		if (bf2 > 0) {
			xbd2_loc = (xbd2_loc + reg.getInt(bf2 + 4)) & psw_amode;  // RPI-815
		}
		if (tz390.opt_trace) {
			trace_ins();
		}
		if (ex_mode) {
			ex_restore();
		}
		psw_loc = psw_loc + 6;
		if (xbd2_loc >= tot_mem && opcode2 != 0x71) { // RPI-299 RPI-738 LAY
			set_psw_check(Constants.psw_pic_addr);
		}
	}

	private void ins_setup_s() { // "S" 43 SPM oo00bddd
		bf2 = mem.getShort(psw_loc + 2) & 0xffff;
		df2 = bf2 & 0xfff;
		bf2 = (bf2 & 0xf000) >> 9;
		if (bf2 > 0) {
			bd2_loc = (reg.getInt(bf2 + 4) + df2) & psw_amode; // RPI-815
		} else {
			bd2_loc = df2;
		}
		psw_ins_len = 4;
		if (tz390.opt_trace) {
			trace_ins();
		}
		if (ex_mode) {
			ex_restore();
		}
		psw_loc = psw_loc + 4;
		if (bd2_loc >= tot_mem) { // RPI-299
			set_psw_check(Constants.psw_pic_addr);
		}
	}

	private void ins_setup_si() { // "SI" 9 CLI ooiibddd
		/*
		 * fetch bd1,if2
		 */
		if2 = mem_byte[psw_loc + 1] & 0xff;
		bf1 = mem.getShort(psw_loc + 2) & 0xffff;
		df1 = bf1 & 0xfff;
		bf1 = (bf1 & 0xf000) >> 9;
		if (bf1 > 0) {
			bd1_loc = (reg.getInt(bf1 + 4) + df1) & psw_amode;  // RPI-815
		} else {
			bd1_loc = df1;
		}
		psw_ins_len = 4;
		if (tz390.opt_trace) {
			trace_ins();
		}
		if (ex_mode) {
			ex_restore();
		}
		psw_loc = psw_loc + 4;
		if (bd1_loc >= tot_mem) { // RPI-299
			set_psw_check(Constants.psw_pic_addr);
		}
	}
	private void ins_setup_sil() { // "SIL" MVHHI oooobdddiiii RPI-817
		/*
		 * fetch bd1,if2
		 */
		if2 = mem.getShort(psw_loc + 4);
		bf1 = mem.getShort(psw_loc + 2) & 0xffff;
		df1 = bf1 & 0xfff;
		bf1 = (bf1 & 0xf000) >> 9;
		if (bf1 > 0) {
			bd1_loc = (reg.getInt(bf1 + 4) + df1) & psw_amode;  // RPI-815
		} else {
			bd1_loc = df1;
		}
		psw_ins_len = 6;
		if (tz390.opt_trace) {
			trace_ins();
		}
		if (ex_mode) {
			ex_restore();
		}
		psw_loc = psw_loc + 6;
		if (bd1_loc >= tot_mem) { // RPI-299
			set_psw_check(Constants.psw_pic_addr);
		}
	}

	private void ins_setup_siy() { // "SIY" 6 TMY ooiibdddhhoo
		psw_ins_len = 6;
		if2 = mem_byte[psw_loc + 1];
		bf1 = mem.getShort(psw_loc + 2);
		df1 = (bf1 & 0xfff) | (mem.get(psw_loc + 4) << 12); // RPI-387
		bf1 = (bf1 & 0xf000) >> 9;
		if (bf1 > 0) {
			bd1_loc = (reg.getInt(bf1 + 4) + df1) & psw_amode;  // RPI-815
		} else {
			bd1_loc = df1;
		}
		if (tz390.opt_trace) {
			trace_ins();
		}
		if (ex_mode) {
			ex_restore();
		}
		psw_loc = psw_loc + 6;
		if (bd1_loc >= tot_mem) { // RPI-299
			set_psw_check(Constants.psw_pic_addr);
		}
	}

	private void ins_setup_ssp() { // AP SS2 oollbdddbddd
		/*
		 * fetch rflen1, rflen2, bd1_loc, and bd2_loc and update psw
		 */
		rflen1 = mem_byte[psw_loc + 1] & 0xff;
		rflen2 = (rflen1 & 0xf) + 1;
		rflen1 = ((rflen1 >> 4) & 0xf) + 1;
		bf1 = mem.getShort(psw_loc + 2) & 0xffff;
		df1 = bf1 & 0xfff;
		bf1 = (bf1 & 0xf000) >> 9;
		if (bf1 > 0) {
			bd1_loc = (reg.getInt(bf1 + 4) + df1) & psw_amode; // RPI-815
		} else {
			bd1_loc = df1;
		}
		bf2 = mem.getShort(psw_loc + 4) & 0xffff;
		df2 = bf2 & 0xfff;
		bf2 = (bf2 & 0xf000) >> 9;
		if (bf2 > 0) {
			bd2_loc = (reg.getInt(bf2 + 4) + df2) & psw_amode;  // RPI-815
		} else {
			bd2_loc = df2;
		}
		psw_ins_len = 6;
		if (tz390.opt_trace) {
			trace_ins();
		}
		if (ex_mode) {
			ex_restore();
		}
		psw_loc = psw_loc + 6;
		if (bd1_loc + rflen1 > tot_mem
			|| (opcode1 != opcode_srp && bd2_loc + rflen2 > tot_mem)) { // RPI-299, RPI-820
			set_psw_check(Constants.psw_pic_addr);
		}
		if (tz390.opt_protect // RPI-538
			&& bd1_loc < psa_len) {
			set_psw_check(Constants.psw_pic_addr);
		}
	}

	private void ins_setup_ss() { // "SS" 32 MVC oollbdddbddd
		/*
		 * fetch rflen,bd1_loc, bd2_loc, and update psw
		 */
		rflen = (mem_byte[psw_loc + 1] & 0xff) + 1;
		bf1 = mem.getShort(psw_loc + 2) & 0xffff;
		df1 = bf1 & 0xfff;
		bf1 = (bf1 & 0xf000) >> 9;
		if (bf1 > 0) {
			bd1_loc = (reg.getInt(bf1 + 4) + df1) & psw_amode; // RPI-815
		} else {
			bd1_loc = df1;
		}
		bf2 = mem.getShort(psw_loc + 4) & 0xffff;
		df2 = bf2 & 0xfff;
		bf2 = (bf2 & 0xf000) >> 9;
		if (bf2 > 0) {
			bd2_loc = (reg.getInt(bf2 + 4) + df2) & psw_amode; // PRI 815
		} else {
			bd2_loc = df2;
		}
		psw_ins_len = 6;
		if (tz390.opt_trace) {
			trace_ins();
		}
		if (ex_mode) {
			ex_restore();
		}
		psw_loc = psw_loc + 6;
		if (bd2_loc > tot_mem || bd1_loc + rflen > tot_mem) { // RPI-299 RPI-528
			set_psw_check(Constants.psw_pic_addr);
		}
		if (tz390.opt_protect // RPI-538
				&& opcode1 != opcode_clc
				&& bd1_loc < psa_len) {
				set_psw_check(Constants.psw_pic_addr);
		}
	}

	private void ins_setup_sse() { // "SSE" 5 LASP oooobdddbddd
		psw_ins_len = 6;
		bf1 = mem.getShort(psw_loc + 2) & 0xffff;
		df1 = bf1 & 0xfff;
		bf1 = (bf1 & 0xf000) >> 9;
		if (bf1 > 0) {
			bd1_loc = (reg.getInt(bf1 + 4) + df1) & psw_amode; // RPI-815
		} else {
			bd1_loc = df1;
		}
		bf2 = mem.getShort(psw_loc + 4) & 0xffff;
		df2 = bf2 & 0xfff;
		bf2 = (bf2 & 0xf000) >> 9;
		if (bf2 > 0) {
			bd2_loc = (reg.getInt(bf2 + 4) + df2) & psw_amode; // RPI-815
		} else {
			bd2_loc = df2;
		}
		if (tz390.opt_trace) {
			trace_ins();
		}
		if (ex_mode) {
			ex_restore();
		}
		psw_loc = psw_loc + 6;
		if (bd2_loc + rflen > tot_mem || bd1_loc + rflen > tot_mem) { // RPI-299
			set_psw_check(Constants.psw_pic_addr);
		}
		if (tz390.opt_protect // RPI-538
			&& bd1_loc < psa_len) {
			set_psw_check(Constants.psw_pic_addr);
		}
	}
	private void ins_setup_ssf() { // "SSF" 32 MVCOS oor0bdddbddd
		/*
		 * fetch rf3,bd1_loc, bd2_loc, and update psw
		 */
		rf3 = (mem_byte[psw_loc + 1] & 0xf0) >>> 1;
		rflen = reg.getInt(rf3+4); // RPI-619
		mf3 = rf3 >>> 3;
		bf1 = mem.getShort(psw_loc + 2) & 0xffff;
		df1 = bf1 & 0xfff;
		bf1 = (bf1 & 0xf000) >> 9;
		if (bf1 > 0) {
			bd1_loc = (reg.getInt(bf1 + 4) + df1) & psw_amode; // RPI-815
		} else {
			bd1_loc = df1;
		}
		bf2 = mem.getShort(psw_loc + 4) & 0xffff;
		df2 = bf2 & 0xfff;
		bf2 = (bf2 & 0xf000) >> 9;
		if (bf2 > 0) {
			bd2_loc = (reg.getInt(bf2 + 4) + df2) & psw_amode; // RPI-815
		} else {
			bd2_loc = df2;
		}
		psw_ins_len = 6;
		if (tz390.opt_trace) {
			trace_ins();
		}
		if (ex_mode) {
			ex_restore();
		}
		psw_loc = psw_loc + 6;
		if (bd2_loc > tot_mem || bd1_loc + rflen > tot_mem) { // RPI-299 RPI-528
			set_psw_check(Constants.psw_pic_addr);
		}
		if (tz390.opt_protect // RPI-538
				&& opcode1 != opcode_clc
				&& bd1_loc < psa_len) {
				set_psw_check(Constants.psw_pic_addr);
		}
	}
	private void ins_setup_ssf2() { // "SSF2" 55 LPD/LPDG oorobdddbddd
		/*
		 * fetch rf3,bd1_loc, bd2_loc, and update psw
		 */
		rf3 = (mem_byte[psw_loc + 1] & 0xf0) >>> 1;
		mf3 = rf3 >>> 3;
		bf1 = mem.getShort(psw_loc + 2) & 0xffff;
		df1 = bf1 & 0xfff;
		bf1 = (bf1 & 0xf000) >> 9;
		if (bf1 > 0) {
			bd1_loc = (reg.getInt(bf1 + 4) + df1) & psw_amode; // RPI-815
		} else {
			bd1_loc = df1;
		}
		bf2 = mem.getShort(psw_loc + 4) & 0xffff;
		df2 = bf2 & 0xfff;
		bf2 = (bf2 & 0xf000) >> 9;
		if (bf2 > 0) {
			bd2_loc = (reg.getInt(bf2 + 4) + df2) & psw_amode; // RPI-815
		} else {
			bd2_loc = df2;
		}
		psw_ins_len = 6;
		if (tz390.opt_trace) {
			trace_ins();
		}
		if (ex_mode) {
			ex_restore();
		}
		psw_loc = psw_loc + 6;
		if (bd2_loc > tot_mem || bd1_loc > tot_mem) { // RPI-299 RPI-528
			set_psw_check(Constants.psw_pic_addr);
		}
	}
	public String get_ins_name(int ins_loc) {
		/*
		 * return opcode or ????? for given op1 and op2
		 */
		tz390.op_code_index = -1; // assume not found RPI-251
		ins_loc = ins_loc & psw_amode;
		if (ins_loc >= tot_mem) {
			return "?????";
		}
		int op1 = mem_byte[ins_loc] & 0xff;
		int op2 = -1;
		int op2_offset = opcode2_offset[op1];
		if (op2_offset > 0) {
			switch (opcode2_mask[op1]) {
			case 0xff: // full byte
				op2 = mem_byte[ins_loc + op2_offset] & 0xff;
				break;
			case 0xf0: // left nibble
				op2 = (mem_byte[ins_loc + op2_offset] >> 4) & 0x0f;
				break;
			case 0x0f: // right nibble
				op2 = mem_byte[ins_loc + op2_offset] & 0x0f;
				break;
			default:
				set_psw_check(Constants.psw_pic_operr);
			}
		}
		String ins_name = null;
		String hex_op1 = null;
		String hex_op2 = null;
		String hex_mf1 = null;
		String hex_key = null;
		hex_op1 = Integer.toHexString(op1).toUpperCase();
		if (hex_op1.length() == 1) {
			hex_op1 = "0" + hex_op1;
		}
		if (op2 == -1) {
			hex_op2 = "";
		} else {
			hex_op2 = Integer.toHexString(op2).toUpperCase();
			if (hex_op2.length() == 1) {
				hex_op2 = "0" + hex_op2;
			}
		}
		hex_mf1 = Integer.toHexString((mem_byte[ins_loc + 1] & 0xff) >> 4)
				.toUpperCase();
		if (op1 == 0x47 || op1 == 0x07) {
			hex_key = "BC=" + hex_op1 + "0" + hex_mf1;
		} else if (op1 == 0xa7 && ((op2 & 0xf) == 4)) {
			hex_key = "BR=" + hex_op1 + "4" + hex_mf1;
		} else if (op1 == 0xC0 && ((op2 & 0xf) == 4)) { // RPI-200
			hex_key = "BL=" + hex_op1 + "4" + hex_mf1;
		} else {
			hex_key = hex_op1 + hex_op2;
		}
		tz390.op_code_index = tz390.find_key_index('H', hex_key);
		if (tz390.op_code_index != -1) {
			ins_name = OpNames.op_name[tz390.op_code_index];
			if (ins_name.charAt(ins_name.length()-1) == '?') { // RPI-1125
				// replace ? with A if bytes 2-3 not zero else remove ?
				if (alt_rnd_mode == 0 && alt_fpe_mode == 0) {
					ins_name = ins_name.substring(0,ins_name.length()-1);
				} else {
					ins_name = ins_name.substring(0,ins_name.length()-1).concat("A");
				}
			}
			if (ins_name.length() < 5) {
				ins_name = (ins_name + "     ").substring(0, 5);
			}
		} else {
			ins_name = "?????";
		}
		return ins_name;
	}

	/*
	 * *************************************** instruction support routines **************************************
	 */
	public void set_psw_check(int pic_type) {
		/*
		 * set psw_pic interruption type if pgm mask type interrupt if mask bit
		 * 0, set CC3 and continue. if espie exit defined, exit to it else set
		 * psw_check for exit to abend handler
		 */
		psw_pic = pic_type;
		if (psw_pic == Constants.psw_pic_exit) {
			psw_check = true; // normal exit
		} else {
			psw_pic_handler();
		}
	}

	public void psw_pic_handler() {
		/*
		 * set psw_loc and turn on psw_retry if any of the following conditions
		 * found: 1. If psw_pic has corresponding psw_pgm_mask bit off, continue
		 * at next instruction. 2. If psw_pic has corresponding bit on in ESPIE
		 * PIE mask bits, restart at espie_exit if defined. 3. If estae_exit
		 * defined, then restart at estae_exit. 4. If option test on 4. else
		 * issue svc_abend for psw_pic code.
		 */
		boolean try_espie = false;
		boolean ignore_pic = false;
		switch (psw_pic) {
		case 0x0c1:
			try_espie = true;
			if (!psw_check) {
				psw_pic = Constants.psw_pic_addr; // default 0C5 for ins trap
			}
			break;
		case 0x0c7: // decimal data or IEEE BFP exception
			switch (fp_dxc) {
			case 0x00: // packed decimal data exception
				try_espie = true;
				break;
			case 0x08: // IEEE inexact and truncated
			case 0x0C: // IEEE inexact and incremented
				if ((fp_fpc_reg & fp_fpc_mask_sig) != 0) {
					try_espie = true;
				} else {
					ignore_pic = true;
				}
				break;
			case 0x10: // IEEE underflow, exact
			case 0x18: // IEEE underflow, inexact and
			case 0x1C: // IEEE underflow, inexact and
				if ((fp_fpc_reg & fp_fpc_mask_unf) != 0) {
					try_espie = true;
				} else {
					ignore_pic = true;
				}
				break;
			case 0x20: // IEEE overflow, exact
			case 0x28: // IEEE overflow, inexact and
			case 0x2C: // IEEE overflow, inexact and
				if ((fp_fpc_reg & fp_fpc_mask_ovf) != 0) {
					try_espie = true;
				} else {
					ignore_pic = true;
				}
				break;
			case 0x40: // IEEE division by zero
				if ((fp_fpc_reg & fp_fpc_mask_div) != 0) {
					try_espie = true;
				} else {
					ignore_pic = true;
				}
				break;
			case 0x80: // IEEE invalid operation
				if ((fp_fpc_reg & fp_fpc_mask_inv) != 0) {
					try_espie = true;
				} else {
					ignore_pic = true;
				}
				break;
			}
			break;
		case 0x0c8: // fixed point overflow
			if ((psw_pgm_mask & psw_pgm_mask_fix) != 0) {
				try_espie = true; // try spie then stae
			} else {
				ignore_pic = true;
			}
			break;
		case 0x0ca: // decimal overflow
			if ((psw_pgm_mask & psw_pgm_mask_dec) != 0) {
				try_espie = true; // try spie then stae
			} else {
				ignore_pic = true;
			}
			break;
		case 0x0cd: // floating point exponent underflow
			if ((psw_pgm_mask & psw_pgm_mask_exp) != 0) {
				try_espie = true; // try spie then stae
			} else {
				ignore_pic = true;
			}
			break;
		case 0x0ce: // floating point significance
			if ((psw_pgm_mask & psw_pgm_mask_sig) != 0) {
				try_espie = true; // try spie then stae
			} else {
				ignore_pic = true;
			}
			break;
		case 0x0c2: // privilege
		case 0x0c3: // execute
		case 0x0c4: // protection
		case 0x0c5: // addressing (default for ins trap above
		case 0x0c6: // specification
		case 0x0c9: // fixed point divide
		case 0x0cb: // decimal divide
		case 0x0cc: // HFP floating point exp overflow
		case 0x0cf: // HFP floating point divide
			try_espie = true;
			break;
		}
		if (ignore_pic) {
			psw_check = false;
			return;
		}
		if (try_espie && tot_espie > 0 && !espie_exit_running // RPI-305 - prevent recursion
				&& !estae_exit_running) {
			int psw_int = psw_pic & 0xf;
			if ((espie_pie[tot_espie - 1] & (int_high_bit >>> psw_int)) != 0) {
				setup_espie_exit();
				return;
			}
		}
		if (tot_estae > 0 && !espie_exit_running // RPI-305 prevent recursion
				&& !estae_exit_running) {
			setup_estae_exit();
			return;
		}
		sz390.svc_abend(psw_pic, sz390.system_abend, sz390.tz390.opt_dump);
		test_trace_count = 0;
		psw_check = false;
	}

	/**
	 * Initialize zcvt_epie and pass addr to espie exit via r1.
	 */
	private void setup_espie_exit() {
		mem.putInt(epie_id, 0xc5d7c9c5); // id=c'EPIE'
		mem.putInt(epie_parm, espie_parm[tot_espie - 1]);
		mem.putShort(epie_psw,(short) 0x07ED); // EC PSW 7=dat,I/O,ext E=key D=EMWP
		mem_byte[epie_psw+2] = (byte)(psw_cc_code[psw_cc] << 4 | psw_pgm_mask); // PRI 845 00ccmmmm
		update_psa();  // RPI-1063
		mem.putInt(epie_psw + 4, psw_loc); // EC PSW amode bit and 24/31 bit addr
		mem_byte[epie_ilc] = last_psw_ins_len; // RPI-845 last instruction length 2,4, 6
		mem.putShort(epie_inc,(short)psw_pic); // RPI-845 interrupt code
		mem_byte[epie_flags] = 0x40; // RPI-845 set 64 bit reg flag
		mem.position(epie_gpr); // gpr64 r0-r15
		reg.position(0); // RPI-357
		mem.put(reg);
		reg.putInt(r1, zcvt_epie); // r1 = epie
		reg.putInt(r14, zcvt_exit); // r14 = exit
		reg.putInt(r15, espie_exit[tot_espie - 1]);
		set_psw_loc(espie_exit[tot_espie - 1]);
		espie_psw_cc        = psw_cc;        // RPI-809
		espie_psw_amode     = psw_amode;     // RPI-809
		espie_psw_amode_bit = psw_amode_bit; // RPI-809
		espie_exit_running = true;
		psw_check = false;
		if (tz390.opt_trace) {
			tz390.put_trace("ESPIE EXIT STARTING");
		}
	}

	public void update_psa() {
		/*
		 * Called for ESPIE and ABEND  RPI-1063
		 * to update PSA pgm old psw and instr. len
		 * store FLCPOPSW+2=00CCMMMM
		 * store FLCPOPSW+3=interrupt code
		 * store FLCPOPSW+4=addr with amode high bit
		 * store FLCPIILC+0=instruction length
		 */
		mem_byte[psa_pgm_old_psw+2]= (byte)(psw_cc_code[psw_cc] << 4 | psw_pgm_mask); // PRI 845 00ccmmmm
		mem_byte[psa_pgm_old_psw+3]= (byte)psw_pic;
		mem.putInt(psa_pgm_old_psw + 4, psw_loc); // EC PSW amode bit and 24/31 bit addr
		mem_byte[psa_psw_ins_len] = (byte) psw_ins_len;
	}

	/**
	 * Initialize zcvt_sdwa and pass addr to estae exit via r1.
	 */
	public void setup_estae_exit() { // RPI-636 used by sz390 percolate
		mem.putInt(sdwa_parm,estae_parm[tot_estae - 1]); // RPI-845
		mem.putInt(sdwa_cmp,psw_pic); // RPI-845
		mem.putShort(sdwa_psw,(short) 0x07ED); // EC PSW 7=dat,I/O,ext E=key D=EMWP RPI-845
		mem_byte[sdwa_psw+2] = (byte)(psw_cc_code[psw_cc] << 4 | psw_pgm_mask); // PRI 845 00ccmmmm
		mem.putInt(sdwa_psw + 4, psw_loc); // psw addr
		mem.putInt(sdwa_xpad,sdwa_ptrs); // addr extension ptrs RPI-845
		mem.putInt(sdwa_xeme,sdwa_g64); // addr RC4 regsiter extension RPI-845
		mem.position(sdwa_g64); // gpr64 r0-r15
		reg.position(0); // RPI-357
		mem.put(reg);
		reg.putInt(r1, zcvt_sdwa);                 // r1 = sdwa RPI-845
		reg.putInt(r2, estae_parm[tot_estae - 1]); // r2 = ESTAE PARM RPI-845
		reg.putInt(r14, zcvt_exit); // r14 = exit
		reg.putInt(r15, estae_exit[tot_estae - 1]);
		set_psw_loc(estae_exit[tot_estae - 1]);
		estae_psw_cc        = psw_cc;        // RPI-809
		estae_psw_amode     = psw_amode;     // RPI-809
		estae_psw_amode_bit = psw_amode_bit; // RPI-809
		estae_exit_running = true;
		psw_check = false;
		if (tz390.opt_trace) {
			tz390.put_trace("ESTAE EXIT STARTING");
		}
	}

	/**
	 * Set psw_amode based on amode high bit.
	 * @param amode_bit
	 */
	public void set_psw_amode(int amode_bit) {
		if ((amode_bit & psw_amode31_bit) != 0) {
			psw_amode = psw_amode31;
			psw_amode_bit = psw_amode31_bit;
			psw_amode_high_bits = psw_amode31_high_bits;
		} else {
			psw_amode = psw_amode24;
			psw_amode_bit = psw_amode24_bit;
			psw_amode_high_bits = psw_amode24_high_bits;
		}
	}

	/**
	 * Set psw_loc based on psw_amode and turn off ex_mode and add space if trace on.
	 * @param addr
	 */
	public void set_psw_loc(final int addr) {
		psw_loc = addr & psw_amode;
		if (psw_loc >= tot_mem) {
			set_psw_check(Constants.psw_pic_addr);
		}
		if (tz390.opt_trace && !tz390.opt_test) {
			tz390.put_trace(""); // RPI-348
		}
		ex_mode = false;
	}

	/**
	 * Return psw_cc for TM, TMY.
	 * @param mem
	 * @param mask
	 * @return
	 */
	private int get_tm_mem_cc(final int mem, int mask) {
		mask = mask & 0xff;
		final int bits = mem & mask;
		if (bits == 0) {
			return psw_cc0;
		} else if (bits == mask) {
			return psw_cc3;
		} else {
			return psw_cc1;
		}
	}

	/**
	 * Return psw_cc for TMHH, THHL, TMLH, TMLL.
	 * @param reg
	 * @param mask
	 * @return
	 */
	private int get_tm_reg_cc(final int reg, int mask) {
		mask = mask &0xffff; // RPI-844
		int bits = reg & mask;
		if (bits == 0) {
			// all selected bits or mask 0
			return psw_cc0;
		} else if (bits == mask) { // RPI-844 was reg vs mask
			// all selected bits 1
			return psw_cc3;
		} else if (bits > (mask >>> 1)) { // RPI-844
			// mixed bits and left most selected bit 1
			return psw_cc2;
		} else {
			// mixed bits and left most selected bit 0
			return psw_cc1;
		}
	}

	/**
	 * Return int shifted left arith and set psw_cc.
	 * @param int_reg
	 * @param shift_count
	 * @return
	 */
	private int get_sla32(final int int_reg, final int shift_count) {
		long long_result = ((long) int_reg) << shift_count;
		if (int_reg > 0) {
			if ((long_result & long_sign_bits) != 0) {
				psw_cc = psw_cc3;
				long_result = long_result & max_pos_int;
			} else {
				psw_cc = psw_cc2;
			}
		} else if (int_reg < 0) {
			if ((long_result & long_sign_bits) != long_sign_bits) {
				psw_cc = psw_cc3;
				long_result = long_result | long_sign_bits;
			} else {
				psw_cc = psw_cc1;
			}
		} else {
			psw_cc = psw_cc0;
		}
		return (int) long_result;
	}

	/**
	 * Return long_reg shifted left arith and set psw_cc.
	 * @param long_reg
	 * @param shift_count
	 * @return
	 */
	private long get_sla64(final long long_reg, final int shift_count) {
		long long_result = long_reg << shift_count;
		long shift_out_bits = long_reg >> 63 - shift_count;
		if (long_reg > 0) {
			if (shift_out_bits != 0) {
				psw_cc = psw_cc3;
				long_result = long_result & long_num_bits;
			} else {
				psw_cc = psw_cc2;
			}
		} else if (long_reg < 0) {
			if (shift_out_bits != -1) {
				psw_cc = psw_cc3;
				long_result = long_result | long_high_bit;
			} else {
				psw_cc = psw_cc1;
			}
		} else {
			psw_cc = psw_cc0;
		}
		return long_result;
	}

	/**
	 * Return int shifted right arith and set psw_cc.
	 * @param int_reg
	 * @param shift_count
	 * @return
	 */
	private int get_sra32(final int int_reg, final int shift_count) {
		int int_result = int_reg >> shift_count;
		psw_cc = get_int_comp_cc(int_result, 0);
		return int_result;
	}

	private int get_int_log_add_cc() {
		/*
		 * Set psw_carry and return cc for logical add as follows:
		 *   rv1 carry
		 *    0 0 - cc0
		 *   !0 0 cc1
		 *    0 1 cc2
		 *   !0 1 cc3
		 * Notes:
		 *   1. rvw = r1 input
		 *   2. rv2 = r2 input
		 *   3. rv1 = result r1
		 *
		 *   R1 = RW + R2
		 *
		 *R1      RW        R2       RPI-1125 DOC
		 * +       +         +   NC
		 * +       +         -   C
		 * +       -         +   C
		 * +       -         -   C
		 * -       +         +   NC
		 * -       +         -   NC
		 * -       -         +   NC
		 * -       -         -   C
		 */
		boolean rv1_carry = false;
		if (rv1 >= 0) { // RPI-376
			if (rvw < 0 || rv2 < 0) {
				rv1_carry = true;
			}
		} else if (rvw < 0 && rv2 < 0) {
			rv1_carry = true;
		}
		if (rv1 == 0) {
			if (!rv1_carry) {
				return psw_cc0;
			} else {
				return psw_cc2;
			}
		} else {
			if (!rv1_carry) {
				return psw_cc1;
			} else {
				return psw_cc3;
			}
		}
	}

	/**
	 *
	 * @return
	 */
	private int get_int_lsi_add_cc() { // RPI-1125 ALSIH and ALSI
		/*
		 * Set psw_carry and return cc for logical add with signed value in rv2.
		 * For negative rv2, the carry bit may indicate borrow.
		 *
		 *   rv1 carry/borrow
		 *    0  0 - cc0
		 *   !0  0 cc1
		 *    0  1 cc2
		 *   !0  1 cc3
		 * Notes:
		 *   1. rvw = r1 input
		 *   2. rv2 = r2 input
		 *   3. rv1 = result r1
		 *
		 *   R1 = RW + R2
		 *
		 *R1      RW        R2       RPI-1125 DOC
		 * +       +         +   NC
		 * +       +         -   NB
		 * +       -         +   C
		 * +       -         -   NB
		 * -       +         +   NC
		 * -       +         -   B
		 * -       -         +   NC
		 * -       -         -   NB
		 */
		boolean rv1_carry = false;
		if (rv1 >= 0) { // RPI-376
			if (rvw < 0 && rv2 > 0) {
				rv1_carry = true;
			}
		} else if (rvw >= 0 && rv2 < 0) {
			rv1_carry = true; // borrow
		}
		if (rv1 == 0) {
			if (!rv1_carry) {
				return psw_cc0;
			} else {
				return psw_cc2;
			}
		} else {
			if (!rv1_carry) {
				return psw_cc1;
			} else {
				return psw_cc3;
			}
		}
    }
    private int get_long_lsi_add_cc() { // RPI-1125 ALGSI
		/*
		 * set psw_carry and return cc for logical add
		 * with signed value in rv2.  For negative rv2,
		 * the carry bit may indicate borrow.
		 *
		 *   rlv1 carry/borrow
		 *    0  0 - cc0
		 *   !0  0 cc1
		 *    0  1 cc2
		 *   !0  1 cc3
		 * Notes:
		 *   1. rlvw = r1 input
		 *   2. rlv2 = r2 input
		 *   3. rlv1 = result r1
		 *
		 *   R1 = RW + R2
		 *
         *R1      RW        R2       RPI-1125 DOC
         * +       +         +   NC
         * +       +         -   NB
         * +       -         +   C
         * +       -         -   NB
         * -       +         +   NC
         * -       +         -   B
         * -       -         +   NC
         * -       -         -   NB
		 */
		boolean rlv1_carry = false;
		if (rlv1 >= 0) { // RPI-376
			if (rlvw < 0 && rlv2 > 0) {
				rlv1_carry = true;
			}
		} else if (rlvw >= 0 && rlv2 < 0) {
			rlv1_carry = true; // borrow
		}
		if (rlv1 == 0) {
			if (!rlv1_carry) {
				return psw_cc0;
			} else {
				return psw_cc2;
			}
		} else {
			if (!rlv1_carry) {
				return psw_cc1;
			} else {
				return psw_cc3;
			}
		}
    }


	private int get_long_log_add_cc() {
		/*
		 * set psw_carry and return cc for logical add as follows:
		 *  rlv1 carry
		 *   0     0 cc0
		 *  !0     0 cc1
		 *   0 1 cc2
		 *  !0 1 cc3
		 */
		boolean rlv1_carry = false;
		if (rlv1 >= 0) { // RPI-376
			if (rlvw < 0 || rlv2 < 0) {
				rlv1_carry = true;
			}
		} else if (rlvw < 0 && rlv2 < 0) {
			rlv1_carry = true;
		}
		if (rlv1 == 0) {
			if (!rlv1_carry) {
				return psw_cc0;
			} else {
				return psw_cc2;
			}
		} else {
			if (!rlv1_carry) {
				return psw_cc1;
			} else {
				return psw_cc3;
			}
		}
	}

	private int get_int_log_sub_cc() {
		/*
		 * return cc for logical subtract as follows:
		 * rv1 borrow
		 *   0 1 cc0 (slb only)
		 *  !0 1 cc1
		 *   0 0 cc2
		 *  !0 0 cc3
		 * Notes:
		 *  1. rvw = r1 input
		 *  2. rv2 = r2 input
		 *  3. rv1 = result
		 */
		boolean rv1_borrow = false;
		int signs = rvw ^ rv2; // RPI-879
		if (signs >= 0) {
			// signs same
			if (rvw < rv2) {
				rv1_borrow = true; // RPI-879
			}
		} else {
			// signs different
			if (rvw > rv2) {
				rv1_borrow = true;  // RPI-879
			}
		}
		if (rv1 == 0) {
			if (!rv1_borrow) {
				return psw_cc2; // Z,NB
			} else {
				return psw_cc0; // Z,B
			}
		} else {
			if (!rv1_borrow) {
				return psw_cc3; // NZ,NB
			} else {
				return psw_cc1; // NZ,B
			}
		}
	}

	private int get_long_log_sub_cc() {
		/*
		 * return cc for logical subtract as follows:
		 *  rlv borrow
		 *    0 1 cc0 (slb only)
		 *   !0 1 cc1
		 *    0 0 cc2
		 *   !0 0 cc3
		 * Notes:
		 *   1.  rlvw = orig. rlv1
		 *   2.  rlv1 = result
		 *   3.  rlv2 = orig. rlv2
		 */
		boolean rlv1_borrow = false;
		long signs = rlvw ^ rlv2; // RPI-879
		if (signs >= 0) {
			// same signs
			if (rlvw < rlv2) {
				rlv1_borrow = true; // RPI-879
			}
		} else {
			// different signs
			if (rlvw > rlv2) {
				rlv1_borrow = true;  // RPI-879
			}
		}
		if (rlv1 == 0) {
			if (!rlv1_borrow) {
				return psw_cc2; // Z,NB
			} else {
				return psw_cc0; // Z,B
			}
		} else {
			if (!rlv1_borrow) {
				return psw_cc3; // NZ,NB
			} else {
				return psw_cc1; // NZ,B
			}
		}
	}

	/**
	 * Return byte array with leading 0 byte followed by data bytes.
	 * This array format is used to initialize BigInteger with logical unsigned value.
	 * @param data_byte
	 * @param data_offset
	 * @param data_len
	 * @return
	 */
	private byte[] get_log_bytes(final byte[] data_byte, final int data_offset, final int data_len) {
		final byte[] new_byte = new byte[data_len + 1];
		System.arraycopy(data_byte, data_offset, new_byte, 1, data_len); // RPI-411
		return new_byte;
	}

	/**
	 * Copy big integer bytes to work reg with work reg size up to 16.
	 * @param store_bytes
	 * @param store_offset
	 * @param big_int
	 * @param store_length
	 */
	private void fp_bi_to_wreg(final byte[] store_bytes, final int store_offset, final BigInteger big_int, final int store_length) {
		final byte[] work_byte = big_int.toByteArray();
		byte extend_byte = 0;
		if (work_byte[0] < 0)
			extend_byte = -1;
		final int extend_len = store_length - work_byte.length;
		if (extend_len > 0) {
			Arrays.fill(store_bytes, store_offset, store_offset + extend_len, extend_byte); // RPI-411
			System.arraycopy(work_byte, 0, store_bytes, store_offset + extend_len, work_byte.length);
		} else {
			System.arraycopy(work_byte, work_byte.length - store_length, store_bytes, store_offset, store_length);
		}
	}

	/**
	 *
	 */
	private void exec_clcl() {
		fill_char = reg.get(rf2 + 12);
		bd1_loc = reg.getInt(rf1 + 4) & psw_amode;
		bd2_loc = reg.getInt(rf2 + 4) & psw_amode;
		bd1_start = bd1_loc;
		bd2_start = bd2_loc;
		rflen1 = reg.getInt(rf1 + 12) & psw_amode24;
		rflen2 = reg.getInt(rf2 + 12) & psw_amode24;
		data_len = rflen1;
		pad_len = 0;
		psw_cc = psw_cc0;
		if (rflen1 < rflen2) {
			data_len = rflen1;
			pad_len = rflen2 - rflen1;
		} else if (rflen1 > rflen2) {
			data_len = rflen2;
			pad_len = rflen1 - rflen2;
		}
		if (bd1_loc + data_len + pad_len > tot_mem) {
			set_psw_check(Constants.psw_pic_addr); // RPI-397
			return;
		}
		bd1_end = bd1_loc + data_len;
		while (bd1_loc < bd1_end) {
			if (mem_byte[bd1_loc] != mem_byte[bd2_loc]) {
				if ((mem_byte[bd1_loc] & 0xff) > (mem_byte[bd2_loc] & 0xff)) {
					psw_cc = psw_cc_high;
				} else {
					psw_cc = psw_cc_low;
				}
				bd1_end = bd1_loc;
			} else {
				bd1_loc++;
				bd2_loc++;
			}
		}
		if (psw_cc == psw_cc_equal & pad_len > 0) {
			if (rflen1 > rflen2) {
				bd1_end = bd1_loc + pad_len;
				while (bd1_loc < bd1_end) {
					if (mem_byte[bd1_loc] != fill_char) {
						if ((mem_byte[bd1_loc] & 0xff) > (fill_char & 0xff)) {
							psw_cc = psw_cc_high;
						} else {
							psw_cc = psw_cc_low;
						}
						bd1_end = bd1_loc;
					} else {
						bd1_loc++;
					}
				}
			} else {
				bd2_end = bd2_loc + pad_len;
				while (bd2_loc < bd2_end) {
					if (mem_byte[bd2_loc] != fill_char) {
						if ((mem_byte[bd2_loc] & 0xff) > (fill_char & 0xff)) {
							psw_cc = psw_cc_high;
						} else {
							psw_cc = psw_cc_low;
						}
						bd2_end = bd2_loc;
					} else {
						bd2_loc++;
					}
				}
			}
		}
		reg.putInt(rf1 +  4, (reg.getInt(rf1 +  4) & psw_amode_high_bits)	| bd1_loc);
		reg.putInt(rf1 + 12, (reg.getInt(rf1 + 12) & psw_amode24_high_bits)	| (rflen1 - (bd1_loc - bd1_start)));
		reg.putInt(rf2 +  4, (reg.getInt(rf2 +  4) & psw_amode_high_bits)	| bd2_loc);
		reg.putInt(rf2 + 12, (reg.getInt(rf2 + 12) & psw_amode24_high_bits)	| (rflen2 - (bd2_loc - bd2_start)));
	}

	private void exec_clcle() {
		fill_char = (byte) bd2_loc;
		bd1_loc = reg.getInt(rf1 + 4) & psw_amode;
		bd2_loc = reg.getInt(rf3 + 4) & psw_amode;
		bd1_start = bd1_loc;
		bd2_start = bd2_loc;
		rflen1 = reg.getInt(rf1 + 12) & max_pos_int;
		rflen2 = reg.getInt(rf3 + 12) & max_pos_int;
		data_len = rflen1;
		pad_len = 0;
		psw_cc = psw_cc0;
		if (rflen1 < rflen2) {
			data_len = rflen1;
			pad_len = rflen2 - rflen1;
		} else if (rflen1 > rflen2) {
			data_len = rflen2;
			pad_len = rflen1 - rflen2;
		}
		if (bd1_loc + data_len + pad_len > tot_mem) {
			set_psw_check(Constants.psw_pic_addr); // RPI-397
			return;
		}
		bd1_end = bd1_loc + data_len;
		while (bd1_loc < bd1_end) {
			if (mem_byte[bd1_loc] != mem_byte[bd2_loc]) {
				if ((mem_byte[bd1_loc] & 0xff) > (mem_byte[bd2_loc] & 0xff)) {
					psw_cc = psw_cc_high;
				} else {
					psw_cc = psw_cc_low;
				}
				bd1_end = bd1_loc;
			} else {
				bd1_loc++;
				bd2_loc++;
			}
		}
		if (psw_cc == psw_cc_equal & pad_len > 0) {
			if (rflen1 > rflen2) {
				bd1_end = bd1_loc + pad_len;
				while (bd1_loc < bd1_end) {
					if (mem_byte[bd1_loc] != fill_char) {
						if ((mem_byte[bd1_loc] & 0xff) > (fill_char & 0xff)) {
							psw_cc = psw_cc_high;
						} else {
							psw_cc = psw_cc_low;
						}
						bd1_end = bd1_loc;
					} else {
						bd1_loc++;
					}
				}
			} else {
				bd2_end = bd2_loc + pad_len;
				while (bd2_loc < bd2_end) {
					if (mem_byte[bd2_loc] != fill_char) {
						if ((mem_byte[bd2_loc] & 0xff) > (fill_char & 0xff)) {
							psw_cc = psw_cc_high;
						} else {
							psw_cc = psw_cc_low;
						}
						bd2_end = bd2_loc;
					} else {
						bd2_loc++;
					}
				}
			}
		}
		reg.putInt(rf1 +  4, (reg.getInt(rf1 + 4) & psw_amode_high_bits) | bd1_loc);
		reg.putInt(rf1 + 12, rflen1 - (bd1_loc - bd1_start));
		reg.putInt(rf3 +  4, (reg.getInt(rf3 + 4) & psw_amode_high_bits) | bd2_loc);
		reg.putInt(rf3 + 12, rflen2 - (bd2_loc - bd2_start));
	}

	/**
	 * Exec clmh or clm using rv1, db2_loc.
	 */
	private void exec_clm() {
		psw_cc = psw_cc_equal;
		if ((mf3 & 0x8) != 0) {
			rv2 = (rv1 >> 24) & 0xff;
			if2 = mem_byte[bd2_loc & psw_amode] & 0xff;
			bd2_loc++;
			if (rv2 != if2) {
				if (rv2 > if2) {
					psw_cc = psw_cc_high;
				} else {
					psw_cc = psw_cc_low;
				}
				return;
			}
		}
		if ((mf3 & 0x4) != 0) {
			rv2 = (rv1 >> 16) & 0xff;
			if2 = mem_byte[bd2_loc & psw_amode] & 0xff;
			bd2_loc++;
			if (rv2 != if2) {
				if (rv2 > if2) {
					psw_cc = psw_cc_high;
				} else {
					psw_cc = psw_cc_low;
				}
				return;
			}
		}
		if ((mf3 & 0x2) != 0) {
			rv2 = (rv1 >> 8) & 0xff;
			if2 = mem_byte[bd2_loc & psw_amode] & 0xff;
			bd2_loc++;
			if (rv2 != if2) {
				if (rv2 > if2) {
					psw_cc = psw_cc_high;
				} else {
					psw_cc = psw_cc_low;
				}
				return;
			}
		}
		if ((mf3 & 0x1) != 0) {
			rv2 = rv1 & 0xff;
			if2 = mem_byte[bd2_loc & psw_amode] & 0xff;
			if (rv2 != if2) {
				if (rv2 > if2) {
					psw_cc = psw_cc_high;
				} else {
					psw_cc = psw_cc_low;
				}
				return;
			}
		}
	}

	/**
	 * compare strings r0 - ending byte rf1,rf2 - string addresses.
	 */
	private void exec_clst() {
		final byte str_end_byte = reg.get(r0 + 3);
		final int str1_loc = reg.getInt(rf1 + 4) & psw_amode;
		final int str2_loc = reg.getInt(rf2 + 4) & psw_amode;
		int index = 0;
		psw_cc = psw_cc3;
		byte str1_byte;
		byte str2_byte;
		boolean str_ended = false;
		psw_cc = psw_cc0;
		while (!str_ended) {
			str1_byte = mem_byte[str1_loc + index];
			str2_byte = mem_byte[str2_loc + index];
			if (str1_byte == str_end_byte || str2_byte == str_end_byte) {
				return;
			} else {
				if (str1_byte == str2_byte) {
					index++;
				} else if (str1_byte > str2_byte) {
					psw_cc = psw_cc2;
					str_ended = true;
				} else {
					psw_cc = psw_cc1;
					str_ended = true;
				}
			}
		}
		reg.putInt(rf1 + 4, str1_loc + index);
		reg.putInt(rf2 + 4, str2_loc + index);
	}

	private void exec_cuse() {
		/*
		 * Search for matching string at same offset in two fields: r0 = length
		 * up to 255 r1 = pad char rf1,rf2 = addr and lengh regs cc0 - key found
		 * and rf1, rf2 updated cc1 - ended at longer operand, last byte = cc2 -
		 * ended at longer operand, last byte != cc3 - search incomplete retry
		 */
		final int  key_len  = reg.getInt(r0);
		final byte str_pad  = reg.get(r1 + 3);
		final int  str1_loc = reg.getInt(rf1 + 4) & psw_amode;
		final int  str1_len = reg.getInt(rf1 + 12);
		final int  str2_loc = reg.getInt(rf2 + 4) & psw_amode;
		final int  str2_len = reg.getInt(rf2 + 12);

		int max_str_len = str1_len;
		if (str2_len > str1_len) {
			max_str_len = str2_len;
		}
		int index1 = 0;
		int index2 = 0;
		byte str1_byte;
		byte str2_byte;
		psw_cc = psw_cc1;
		while (index1 < max_str_len && psw_cc != psw_cc0) {
			if (index1 < str1_len) {
				str1_byte = mem_byte[str1_loc + index1];
			} else {
				str1_byte = str_pad;
			}
			if (index1 < str2_len) {
				str2_byte = mem_byte[str2_loc + index1];
			} else {
				str2_byte = str_pad;
			}
			if (str1_byte == str2_byte) {
				psw_cc = psw_cc1;
				index2++;
				if (index2 == key_len) {
					psw_cc = psw_cc0;
				}
			} else {
				psw_cc = psw_cc2;
				index2 = 0;
			}
			index1++;
		}
		if (index1 < str1_len) {
			reg.putInt(rf1 +  4, str1_loc + index1 - key_len);
			reg.putInt(rf1 + 12, str1_len - index1 + key_len);
		} else {
			reg.putInt(rf1 +  4, str1_loc + str1_len);
			reg.putInt(rf1 + 12, 0);
		}
		if (index1 < str2_len) {
			reg.putInt(rf2 +  4, str2_loc + index1 - key_len);
			reg.putInt(rf2 + 12, str2_len - index1 + key_len);
		} else {
			reg.putInt(rf2 +  4, str2_loc + str2_len);
			reg.putInt(rf2 + 12, 0);
		}
	}
	private void exec_srst() {
		/*
		 * find char in r2 field which ends at r1 char is in r0 cc 1 = char
		 * found and r1 set to address cc 2 = char not found, no update cc 3 =
		 * instruction incomplete retry
		 */
		if (reg.getInt(r0) >>> 8 != 0) { // RPI-1030
			set_psw_check(Constants.psw_pic_spec);
			return;
		}
		byte key_byte = reg.get(r0 + 3);
		int str_loc = reg.getInt(rf2 + 4) & psw_amode;
		int str_end = reg.getInt(rf1 + 4) & psw_amode;
		psw_cc = psw_cc2;
		while (str_loc != str_end) { // RPI-579 was <
			if (mem_byte[str_loc] == key_byte) {
				psw_cc = psw_cc1;
				reg.putInt(rf1 + 4, str_loc);
				str_loc = str_end;
			} else { // RPI-579
				str_loc++;
			}
		}
	}

	/**
	 * Execute stcmh, stcmy, or stcm using rv1, db2_loc.
	 */
	private void exec_stcm() {
		if ((mf3 & 0x8) != 0) {
			mem_byte[bd2_loc & psw_amode] = (byte) (rv1 >> 24);
			bd2_loc++;
		}
		if ((mf3 & 0x4) != 0) {
			mem_byte[bd2_loc & psw_amode] = (byte) (rv1 >> 16);
			bd2_loc++;
		}
		if ((mf3 & 0x2) != 0) {
			mem_byte[bd2_loc & psw_amode] = (byte) (rv1 >> 8);
			bd2_loc++;
		}
		if ((mf3 & 0x1) != 0) {
			mem_byte[bd2_loc & psw_amode] = (byte) rv1;
			bd2_loc++;
		}
	}

	/**
	 * Perform TRTE or TRTRE.
	 * @param reversed
	 */
	private void exec_trt_ext(final boolean reversed) {
		if ((mf1 & 1) != 0) {
			// check even/odd arg register pair
			set_psw_check(Constants.psw_pic_spec);
		}
		bd1_loc = reg.getInt(rf1+4) & psw_amode;
		rflen1 = reg.getInt(rf1+12);
		// get table addr forcing double word bound
		bd2_loc = reg.getInt(r1) & psw_amode & 0xfffffff8;
		boolean limit = (mf3 & 2) != 0;
		int incr;
		int bd1_end;
		int arg_val;
		int funct_val;
		try { // catch S0C5 on table accesses
			if ((mf3 & 8) == 0) {     // 1 byte arg ent
				if (reversed) {
					incr = -1;
					bd1_end = bd1_loc - rflen1;
				} else {
					incr = 1;
					bd1_end = bd1_loc + rflen1;
				}
				if ((mf3 & 4) == 0) { // 1 byte tab ent
					while (bd1_loc != bd1_end) {
						funct_val = mem_byte[bd2_loc + (mem.get(bd1_loc) & 0xff)];
						if (funct_val != 0) {
							psw_cc = psw_cc1;
							reg.putInt(rf2+4,funct_val & 0xff);
							reg.putInt(rf1+4,bd1_loc);
							if (reversed) {
								reg.putInt(rf1+12,bd1_loc - bd1_end);
							} else {
								reg.putInt(rf1+12,bd1_end - bd1_loc);
							}
							return;
						}
						bd1_loc = bd1_loc + incr;
					}
				} else {
					// 1 byte arg
					// 2 byte fun in 512 table
					while (bd1_loc != bd1_end) {
						funct_val = mem.getShort(bd2_loc + ((mem.get(bd1_loc) & 0xff) << 1));
						if (funct_val != 0) {
							psw_cc = psw_cc1;
							reg.putInt(rf2+4,funct_val & 0xffff);
							reg.putInt(rf1+4,bd1_loc);
							if (reversed) {
								reg.putInt(rf1+12,bd1_loc - bd1_end);
							} else {
								reg.putInt(rf1+12,bd1_end - bd1_loc);
							}
							return;
						}
						bd1_loc = bd1_loc + incr;
					}
				}
			} else {
				// 2 byte arugments
				if ((rflen1 & 1) != 0) {
					// check for odd length
					set_psw_check(Constants.psw_pic_spec);
				}
				if (reversed) {
					incr = -2;
					bd1_end = bd1_loc - rflen1;
				} else {
					incr = 2;
					bd1_end = bd1_loc + rflen1;
				}
				if ((mf3 & 4) == 0) {
					// 2 byte argument
					// 1 byte function in 65k table
					while (bd1_loc != bd1_end) {
						arg_val   = mem.getShort(bd1_loc) & 0xffff;
						if (!limit || arg_val <= 255) {
							funct_val = mem_byte[bd2_loc + (arg_val & 0xffff)];
							if (funct_val != 0) {
								psw_cc = psw_cc1;
								reg.putInt(rf2+4,funct_val &0xff);
								reg.putInt(rf1+4,bd1_loc);
								if (reversed) {
									reg.putInt(rf1+12,bd1_loc - bd1_end);
								} else {
									reg.putInt(rf1+12,bd1_end - bd1_loc);
								}
								return;
							}
						}
						bd1_loc = bd1_loc + incr;
					}
				} else {
					// 2 byte arg
					// 2 byte function 128k table
					while (bd1_loc != bd1_end) {
						arg_val   = mem.getShort(bd1_loc) & 0xffff;
						if (!limit || arg_val <= 255) {
							funct_val = mem.getShort(bd2_loc + ((mem.getShort(bd1_loc) & 0xff) << 1));
							if (funct_val != 0) {
								psw_cc = psw_cc1;
								reg.putInt(rf2+4,funct_val);
								reg.putInt(rf1+4,bd1_loc);
								if (reversed) {
									reg.putInt(rf1+12,bd1_loc - bd1_end);
								} else {
									reg.putInt(rf1+12,bd1_end - bd1_loc);
								}
								return;
							}
						}
						bd1_loc = bd1_loc + incr;
					}
				}
			}
		} catch (final Exception e) {
			set_psw_check(Constants.psw_pic_addr);
		}
		psw_cc = psw_cc0;
		reg.putInt(rf2+4,0);
		reg.putInt(rf1+4,bd1_loc);
		reg.putInt(rf1+12,0);
	}

	private void exec_unpka() {
		if (rflen <= 32) {
			rflen1 = rflen;
		} else {
			set_psw_check(Constants.psw_pic_spec);
			return;
		}
		rflen2 = 16;
		bd1_end = bd1_loc - 1;
		bd2_end = bd2_loc - 1;
		bd1_loc = bd1_loc + rflen1 - 1;
		bd2_loc = bd2_loc + rflen2 - 1;
		int sign_byte = mem_byte[bd2_loc];
		int sign_nib = sign_byte & 0xf;
		mem_byte[bd1_loc] = (byte) (((sign_byte & 0xf0) >> 4) | 0x30);
		bd1_loc--;
		bd2_loc--;
		pdf_next_right = true;
		while (bd1_loc > bd1_end) {
			if (pdf_next_right) {
				if (bd2_loc > bd2_end) {
					pdf_next_right = false;
					pdf_next_in = mem_byte[bd2_loc];
					bd2_loc--;
				} else {
					pdf_next_in = 0;
				}
				mem_byte[bd1_loc] = (byte) ((pdf_next_in & 0xf) | 0x30);
				bd1_loc--;
			} else {
				pdf_next_right = true;
				mem_byte[bd1_loc] = (byte) (((pdf_next_in & 0xf0) >> 4) | 0x30);
				bd1_loc--;
			}
		}
		switch (sign_nib) {
		case 0xa:
		case 0xc:
		case 0xe:
		case 0xf:
			psw_cc = psw_cc0;
			break;
		case 0xb:
		case 0xd:
			psw_cc = psw_cc1;
			break;
		default:
			psw_cc = psw_cc3;
		}
	}

	/**
	 *
	 */
	private void exec_icm() {
		/*
		 * Exec icmh, icmy, or icm using rv1, db2_loc
		 * Notes:
		 * 1. psw_cc = all inserted bits 0 or mask 0
		 * 2. psw_cc = 1 if first inserted bit 1
		 * 3. psw_cc = 2 if first inserted bit 0 and not all 0
		 */
		psw_cc = psw_cc_equal; // assume all zeros
		boolean first_insert = true;
		if ((mf3 & 0x8) != 0) {
			if2 = mem_byte[bd2_loc & psw_amode] & 0xff;
			rv1 = (rv1 & 0x00ffffff) | (if2 << 24);
			bd2_loc++;
			if (first_insert) { // RPI-303
				first_insert = false;
				if (if2 >= 0x80) {
					psw_cc = psw_cc_low; // RPI-295
				} else if (if2 != 0) {
					psw_cc = psw_cc_high; // RPI-295
				}
			}
		}
		if ((mf3 & 0x4) != 0) {
			if2 = mem_byte[bd2_loc & psw_amode] & 0xff;
			rv1 = (rv1 & 0xff00ffff) | (if2 << 16);
			bd2_loc++;
			if (first_insert) { // RPI-303
				first_insert = false;
				if (if2 >= 0x80) {
					psw_cc = psw_cc_low; // RPI-295
				} else if (if2 != 0) {
					psw_cc = psw_cc_high; // RPI-295
				}
			} else if (if2 != 0 & psw_cc == psw_cc_equal) {
				psw_cc = psw_cc_high;
			}
		}
		if ((mf3 & 0x2) != 0) {
			if2 = mem_byte[bd2_loc & psw_amode] & 0xff;
			rv1 = (rv1 & 0xffff00ff) | (if2 << 8);
			bd2_loc++;
			if (first_insert) { // RPI-303
				first_insert = false;
				if (if2 >= 0x80) {
					psw_cc = psw_cc_low; // RPI-295
				} else if (if2 != 0) {
					psw_cc = psw_cc_high; // RPI-295
				}
			} else if (if2 != 0 & psw_cc == psw_cc_equal) {
				psw_cc = psw_cc_high;
			}
		}
		if ((mf3 & 0x1) != 0) {
			if2 = mem_byte[bd2_loc & psw_amode] & 0xff;
			rv1 = ((rv1 & 0xffffff00) | if2);
			bd2_loc++;
			if (first_insert) { // RPI-303
				first_insert = false;
				if (if2 >= 0x80) {
					psw_cc = psw_cc_low; // RPI-295
				} else if (if2 != 0) {
					psw_cc = psw_cc_high; // RPI-295
				}
			} else if (if2 != 0 & psw_cc == psw_cc_equal) {
				psw_cc = psw_cc_high;
			}
		}
	}

	private void exec_mvcl() {
		bd1_loc = reg.getInt(rf1 + 4) & psw_amode;
		bd2_loc = reg.getInt(rf2 + 4) & psw_amode;
		rflen1 = reg.getInt(rf1 + 12) & psw_amode24;
		rflen2 = reg.getInt(rf2 + 12) & psw_amode24;
		data_len = rflen1;
		pad_len = 0;
		psw_cc = psw_cc0;
		if (rflen1 < rflen2) {
			psw_cc = psw_cc1;
		} else if (rflen1 > rflen2) {
			psw_cc = psw_cc2;
			data_len = rflen2;
			pad_len = rflen1 - rflen2;
			fill_char = reg.get(rf2 + 12);
		}
		if (bd1_loc + data_len + pad_len > tot_mem) {
			set_psw_check(Constants.psw_pic_addr); // RPI-397
			return;
		}
		if (data_len > 0 && bd1_loc > bd2_loc
				&& bd1_loc < bd2_loc + data_len) {
			psw_cc = psw_cc3;
			return;
		}
		if (data_len > 0) { // RPI-386
			System
					.arraycopy(mem_byte, bd2_loc, mem_byte, bd1_loc,
							data_len); // RPI-411
			bd1_loc = bd1_loc + data_len;
			bd2_loc = bd2_loc + data_len;
		}
		if (pad_len > 0) {
			Arrays.fill(mem_byte, bd1_loc, bd1_loc + pad_len, fill_char);
			bd1_loc = bd1_loc + pad_len;
		}
		reg.putInt(rf1 +  4, (reg.getInt(rf1 +  4) & psw_amode_high_bits) | bd1_loc);
		reg.putInt(rf1 + 12,  reg.getInt(rf1 + 12) & psw_amode24_high_bits);
		reg.putInt(rf2 +  4, (reg.getInt(rf2 +  4) & psw_amode_high_bits) | bd2_loc);
		reg.putInt(rf2 + 12, (reg.getInt(rf2 + 12) & psw_amode24_high_bits) | (rflen2 - data_len));
	}

	private void exec_mvcle() {
		fill_char = (byte) bd2_loc;
		bd1_loc = reg.getInt(rf1 +  4) & psw_amode;
		bd2_loc = reg.getInt(rf3 +  4) & psw_amode;
		rflen1  = reg.getInt(rf1 + 12) & max_pos_int;
		rflen2  = reg.getInt(rf3 + 12) & max_pos_int;
		data_len = rflen1;
		pad_len = 0;
		psw_cc = psw_cc0;
		if (rflen1 < rflen2) {
			psw_cc = psw_cc1;
		} else if (rflen1 > rflen2) {
			psw_cc = psw_cc2;
			data_len = rflen2;
			pad_len = rflen1 - rflen2;
		}
		if (bd1_loc + data_len + pad_len > tot_mem) {
			set_psw_check(Constants.psw_pic_addr); // RPI-397
			return;
		}
		if (bd1_loc + data_len <= bd2_loc || bd2_loc + data_len <= bd1_loc) {
			System.arraycopy(mem_byte, bd2_loc, mem_byte, bd1_loc, data_len); // RPI-411
			bd1_loc = bd1_loc + data_len;
			bd2_loc = bd2_loc + data_len;
		} else if (bd2_loc + 1 == bd1_loc) {
			Arrays.fill(mem_byte, bd1_loc, bd1_loc + data_len, mem_byte[bd2_loc]);
			bd1_loc = bd1_loc + data_len;
			bd2_loc = bd2_loc + data_len;
		} else {
			bd1_end = bd1_loc + data_len;
			// destructive overlap with gap > 1
			bd1_end = bd1_loc + data_len;
			while (bd1_loc < bd1_end) {
				mem_byte[bd1_loc] = mem_byte[bd2_loc];
				bd1_loc++;
				bd2_loc++;
			}
		}
		bd1_end = bd1_loc + pad_len;
		if (bd1_loc < bd1_end) {
			Arrays.fill(mem_byte, bd1_loc, bd1_loc + pad_len, fill_char);
			bd1_loc = bd1_loc + pad_len;
		}
		reg.putInt(rf1 + 4, (reg.getInt(rf1 + 4) & psw_amode_high_bits) | bd1_loc);
		reg.putInt(rf1 + 12, 0);
		reg.putInt(rf3 + 4, (reg.getInt(rf3 + 4) & psw_amode_high_bits) | bd2_loc);
		reg.putInt(rf3 + 12, rflen2 - data_len);
	}

	/**
	 * Move from bd2_loc to bd1_loc for length rflen
	 * Notes:
	 *   1.  Used by MVC and MVCOS
	 */
	private void exec_mvc_rflen() {
		if (bd1_loc + rflen <= bd2_loc || bd2_loc + rflen <= bd1_loc) {
			System.arraycopy(mem_byte, bd2_loc, mem_byte, bd1_loc, rflen); // RPI-411
		} else if (bd2_loc + 1 == bd1_loc) {
			Arrays.fill(mem_byte, bd1_loc, bd1_loc + rflen,
					mem_byte[bd2_loc]);
		} else {
			bd1_end = bd1_loc + rflen;
			while (bd1_loc < bd1_end) {
				// destructive overlap with gap > 1
				mem_byte[bd1_loc] = mem_byte[bd2_loc];
				bd1_loc++;
				bd2_loc++;
			}
		}
	}

	/**
	 * Push PSW and registers on PC stack.
	 * @param pc_type
	 * @param link_addr
	 */
	private void push_pc_stack(final boolean pc_type, final int link_addr) {
		if (cur_pc_stk < max_pc_stk) {
			pc_stk_type_pc[cur_pc_stk] = pc_type;
			pc_stk_psw_loc[cur_pc_stk] = link_addr;
			pc_stk_psw_cc[cur_pc_stk] = psw_cc;
			pc_stk_reg.position(cur_pc_stk_reg);
			reg.position(0); // RPI-357
			pc_stk_reg.put(reg);
			cur_pc_stk++;
			cur_pc_stk_reg = cur_pc_stk_reg + reg_len;
		} else {
			set_psw_check(Constants.psw_pic_stkerr);
		}
	}

	/**
	 * Pop PSW and registers on PC stack.
	 */
	private void pop_pc_stack() {
		if (cur_pc_stk > 0) {
			cur_pc_stk--;
			cur_pc_stk_reg = cur_pc_stk_reg - reg_len;
			set_psw_loc(pc_stk_psw_loc[cur_pc_stk]);
			psw_cc = pc_stk_psw_cc[cur_pc_stk];
			reg.position(16);  // RPI-1111 was 8 vs 16
			reg.put(pc_stk_reg_byte, cur_pc_stk_reg + 16, reg_len - 24); // RPI-1111 was +8 and - 16
		} else {
			set_psw_check(Constants.psw_pic_stkerr);
		}
	}

	/**
	 * Return hex ins plus ins name with 1 space.
	 * @param ins_loc
	 * @return
	 */
	public String get_ins_target(final int ins_loc) {
		return get_ins_hex(ins_loc).trim() + " " + get_ins_name(ins_loc);
	}

	/**
	 * Return 2, 4, or 6 byte hex instruction.
	 * @param ins_loc
	 * @return
	 */
	public String get_ins_hex(int ins_loc) {
		String hex;
		ins_loc = ins_loc & psw_amode;
		if (ins_loc >= tot_mem) {
			return "????????????";
		}
		final int ins_op = mem_byte[ins_loc] & 0xff;
		if (ins_op < 0x40) {
			hex = bytes_to_hex(mem, ins_loc, 2, 0) + "        ";
		} else if (ins_op < 0xc0) {
			hex = bytes_to_hex(mem, ins_loc, 4, 0) + "    ";
		} else {
			hex = bytes_to_hex(mem, ins_loc, 6, 0);
		}
		return hex;
	}

	/**
	 * Format fp reg into 16 byte hex string after flushing co-reg.
	 * Note:
	 * This trace function slows donw fp by adding extra conversions.
	 * @param reg_index
	 * @return
	 */
	public String get_fp_long_hex(int reg_index) {
		fp_store_reg(trace_reg, reg_index);
		final String work_hex = Long.toHexString(trace_reg.getLong(reg_index));
		return ("0000000000000000" + work_hex).substring(work_hex.length()).toUpperCase();
	}

	/**
	 * Format long into 16 byte hex string.
	 * @param work_long
	 * @return
	 */
	public String get_long_hex(final long work_long) {
		final String work_hex = Long.toHexString(work_long);
		return ("0000000000000000" + work_hex).substring(work_hex.length()).toUpperCase();
	}

	/**
	 * Set opcode1 and opcode2 from psw_loc and then execute setup routine
	 * with trace on to generate formated instruction trace.
	 */
	public void trace_psw() {
		trace_psw = true;  // RPI-538
		boolean save_opt_trace = tz390.opt_trace;
		int save_psw_loc = psw_loc;
		tz390.opt_trace = true;
		opcode1 = mem_byte[psw_loc] & 0xff;
		opcode2 = opcode2_offset[opcode1];
		if (opcode2 > 0) {
			opcode2 = mem_byte[psw_loc + opcode2] & opcode2_mask[opcode1];
		}
		get_ins_name(psw_loc); // set op_code_index for RPI-251
		int ins_type = -1;  // RPI-672
		if (tz390.op_code_index >= 0) {
			ins_type = OpTypes.op_type[tz390.op_code_index];
		}
		switch (ins_type) { // RPI-251
		case 1: // "E" 8 PR oooo
			ins_setup_e();
			break;
		case 2: // "RR" 60 LR oorr
			ins_setup_rr();
			break;
		case 3:// "BRX" 16 BER oomr
			ins_setup_rr();
			break;
		case 4:// "I" 1 SVC 00ii
			ins_setup_i();
			break;
		case 5:// "RX" 52 L oorxbddd
			ins_setup_rx();
			break;
		case 6:// "BCX" 16 BE oomxbddd
			ins_setup_rx();
			break;
		case 7:// "S" 43 SPM oo00bddd
			ins_setup_s();
			break;
		case 8:// "DM" 1 DIAGNOSE 83000000
			ins_setup_dm();
			break;
		case 9:// "RSI" 4 BRXH oorriiii
			ins_setup_rsi();
			break;
		case 10:// "RS" 25 oorrbddd
			ins_setup_rs();
			break;
		case 11:// "SI" 9 CLI ooiibddd
			ins_setup_si();
			break;
		case 12:// "RI" 37 IIHH ooroiiii
			ins_setup_ri();
			break;
		case 13:// "BRC" 31 BRE oomoiiii
			ins_setup_ri();
			break;
		case 14:// "RRE" 185 MSR oooo00rr
			ins_setup_rre();
			break;
		case 15:// "RRF" 28 MAER oooor0rr
			ins_setup_rrf1();
			break;
		case 16:// "RIL" 6 BRCL oomollllllll
			ins_setup_ril();
			break;
		case 17:// "SS" 32 MVC oollbdddbddd
			ins_setup_ss();
			break;
		case 18:// "RXY" 76 MLG oorxbdddhhoo
			ins_setup_rxy();
			break;
		case 19:// "SSE" 5 LASP oooobdddbddd
			ins_setup_sse();
			break;
		case 20:// "RSY" 31 LMG oorrbdddhhoo
			ins_setup_rsy();
			break;
		case 21:// "SIY" 6 TMY ooiibdddhhoo
			ins_setup_siy();
			break;
		case 22:// "RSL" 1 TP oor0bddd00oo
			ins_setup_rsl();
			break;
		case 23:// "RIE" 4 BRXLG oorriiii00oo
			ins_setup_rie();
			break;
		case 24:// "RXE" 28 ADB oorxbddd00oo
			ins_setup_rxe();
			break;
		case 25:// "RXF" 8 MAE oorxbdddr0oo (note r3 before r1)
			ins_setup_rxf();
			break;
		case 26:// AP SS2 oollbdddbddd
			ins_setup_ssp();
			break;
		case 27:// PLO SS3 oorrbdddbddd r1,s2,r3,s4
			ins_setup_ss();
			break;
		case 28:// LMD SS5 oorrbdddbddd r1,r3,s2,s4
			ins_setup_ss();
			break;
		case 29:// SRP SS2 oolibdddbddd s1(l1),s2,i3
			ins_setup_ss();
			break;
		case 30:// RPI-206 "RRF3" 30 DIEBR/DIDBR oooormrr (r1,r3,r2,m4 maps to
				// oooo3412)
			ins_setup_rrf3();
			break;
		case 31:// "SS" PKA oollbdddbddd ll from S2
			ins_setup_ss();
			break;
		case 32: // "SSF" MVCOS oor0bdddbddd (s1,s2,r3) z9-41
			ins_setup_ssf();  // RPI-619 was ss()
			break;
		case 33: // "BLX" BRCL extended mnemonics
			ins_setup_ril();
			break;
		case 34: // RPI-206 "RRF2" FIEBR (r1,m3,r2 maps to oooo3012)
			ins_setup_rrf2();
			break;
		case 35: // RPI-527 "RRF4" FIXTR
			ins_setup_rrf4();
			break;
		case 36: // RPI-527 "RRF4" FIXTR
			ins_setup_rrr();
			break;
		case 37: // RPI-812 ASSIST "XDECO"
			ins_setup_rx();
			break;
		case 38: // RPI-812 ASSIST "XREAD"
			ins_setup_rxss();
			break;
		case 39: // RPI-817 "CGRT"
		case 40: // RPI-817 "CGRTE"
			ins_setup_rrf5();
			break;
		case 41: // RPI-817 "CGIT"
		case 42: // RPI-817 "GGITE"
			ins_setup_rie2();
			break;
		case 43: // RPI-817 "CGIJ"
		case 44: // RPI-817 "CGIJE"
			ins_setup_rie4();
			break;
		case 45: // RPI-817 "CGRB:
		case 46: // RPI-817 "CGRBE"
			ins_setup_rrs1();
			break;
		case 47: // RPI-817 "CGIB"
		case 48: // RPI-817 "CGIBE"
			ins_setup_rrs3();
			break;
		case 49: // RPI-817 "CGRJ"
		case 50: // RPI-817 "CGRJE"
			ins_setup_rie6();
			break;
		case 51: // RPI-1125 "MVHHI" RPI-1125
			ins_setup_sil();
			break;
		case 52: // RPI-1125 "RNSBG" RPI-1125
			ins_setup_rie8();
			break;
		case 53: // RPI-1125 "LEDBR?" RPI-1125
			ins_setup_rre();
			break;
		case 54: // RPI-1125 "FIXBR?" RPI-1125
			ins_setup_rrf2();
			break;
		case 55: // RPI-1125 "LPD" RPI-1125
			ins_setup_ssf2();
			break;
		case 56: // RPI-1125 "LOC"
			ins_setup_rsy();
			break;
		case 57: // RPI-1125 "AHIK"
			ins_setup_rie9();
			break;
			// update max_op_type_setup and add cases to match
		default:
			trace_ins(); // unknown op RPI-527
		}
		tz390.opt_trace = save_opt_trace;
		psw_loc = save_psw_loc;
		trace_psw = false;  // RPI-538
	}

	/**
	 * Return extended svc trace information including svc function name and
	 * any key parmeters available such as pgm name or ddname where appropriate.
	 * @return
	 */
	private String trace_svc() { // RPI-312
		switch (if1) {
		case 0x01: // WAIT
			return "WAIT R0=0/COUNT R1=ECB/ECBLIST";
		case 0x02: // POST
			return "POST R1=ECB";
		case 0x03: // EXIT
			return "EXIT";
		case 0x04: // GETMAIN R0_BIT0=AMODE31, R0_BIT1=COND, R1=length
			return "GETMAIN R0 B0=RMODE31, R0B1=CONT, R1=LEN";
		case 0x05: // FREEMAIN R0=LEN, R1=ADDR RPI-244
			return "FREEMAIN R0=LEN, R1=ADDR";
		case 0x06: // LINK R0=PGMID, R1=PARMS
			return "LINK R1=PARMS R0=PGM("
					+ sz390.get_ascii_string(reg.getInt(r0) & psw_amode, 8,true).toUpperCase() + ")";
		case 0x07: // XCTL R15=PGMID, R1=PARMS
			return "XCTL R1=PARMS R0=PGM("
					+ sz390.get_ascii_string(reg.getInt(r0) & psw_amode, 8,true).toUpperCase() + ")";
		case 0x08: // LOAD R15=PGMID
			return "LOAD R1=PARMS R0=PGM("
					+ sz390.get_ascii_string(reg.getInt(r0) & psw_amode, 8,true).toUpperCase() + ")";
		case 0x09: // DELETE R0=A(NAME)
			return "DELETE R1=PARMS R0=PGM("
					+ sz390.get_ascii_string(reg.getInt(r0) & psw_amode, 8,true).toUpperCase() + ")";
		case 0x0b: // TIME R0_LH=DATETYPE, R0_LL=TIMETYPE, R1=ADDR
			return "TIME R0 LH=DATETYPE, R0 LL=TIMETYPE, R1=ADDR";
		case 0x0d: // ABEND R1=abend code
			return "ABEND R1=ABEND CODE";
		case 0x12: // BLDL FIND PGMS IN SYS390
			return "BLDL R1=BLDL LIST";
		case 0x13: // OPEN DCB R0=(x'40' input,x'20' output) R1=DCB
			return "OPEN R0(X'40'=INPUT.X'20'=OUTPUT), R1=DCB";
		case 0x14: // CLOSE DCB R1=DCB
			return "CLOSE R1=DCB";
		case 0x22: // SVC 34 R1=COMMAND R0+2=ID, R0+3=OP
			return "CMDPROC R0+2=ID, R0+3=OP, R1=COMMAND";
		case 0x23: // WTO R1=ADDR
			return "WTO R1=ADDR(AL2(LEN),AL2(FLAGS),C'MSG')";
		case 0x28: // EXTRACE r0=1 GETENV R1=NAME set R2=VALUE
			int op = reg.getInt(r0);
			switch (op) {
			case 1: // GETENV R1=name set R2=value
				return "EXTRACT GETENV R1=NAME, SET R2=VALUE";
			default:
				return "UNKNOWN";
			}
		case 0x2e: // TTIMER r0=function, r1=mic addr
			return "TTIMER R0=OP, R1=ADDR";
		case 0x2f: // STIMER r0=flags, r1=rx storage arg.
			return "STIMER R0=OP, R1=ADDR";
		case 0x33: // SNAP r0hh=flags,r0ll=id,r14-15 storage
			return "SNAP R0 HH=FLAGS, R0 LL=ID, R14=START, R15=END";
		case 0x3c:
			return "ESTAE R0=EXIT ADDR  R1=PARAM"; // set abend exit R0=addr RPI-636
		case 0x67:
			return "XLATE R0=ADDR(+ASC>ECB,-EBC>ASC), R1=LENGTH"; // translate ASCII/EBCDIC
		case 0x6d:
			return "ESPIE R0=TYPE INT, R1=EXIT ADDR"; // set program check
		case 0x79: // VSAM	R0=type
			final int vsam_op = reg.get(r0+3);
			switch (vsam_op) {
			case 1:
				return "VSAM GET   R1=A(RPL)";
			case 2:
				return "VSAM PUT   R1=A(RPL)";
			case 3:
				return "VSAM ERASE R1=A(RPL)";
			case 4:
				return "VSAM POINT R1=A(RPL)";
			default:
				return "VSAM ????? R1=A(RPL)";
			}
		case 0x7c: // TCPIO
			final int tcpio_op = reg.get(r0+3);
			switch (tcpio_op) {
			case 1:
				return "TCPIO OPENC R1=PORT R14=HOST/MSG R15=LMAX";
			case 2:
				return "TCPIO OPENS R1=PORT R14=HOST/MSG R15=LMAX";
			case 3:
				return "TCPIO CLOSE R1=PORT R14=HOST/MSG R15=LMAX";
			case 4:
				return "TCPIO SEND  R1=PORT R14=HOST/MSG R15=LMAX";
			case 5:
				return "TCPIO RECV  R1=PORT R14=HOST/MSG R15=LMAX";
			default:
				return "TCPIO ????? R1=PORT R14=HOST/MSG R15=LMAX";
			}
		case 84: // GUAM GUI application window I/O
			return "GUAM R0+2=MAJOR, R0+3=MINOR, R1=ADDR";
		case 93: // TGET/TPUT TN3290 data stream for GUAM GUI
			int flags = reg.get(r1) & 0xff;
			int len = reg.getShort(r0 + 2) & 0xffff;
			int show = len * 2;
			if (show > 16)
				show = 16;
			int addr = reg.getInt(r1) & psw_amode24;  // RPI-671
			if (flags >= 0x80) {
				return "TGET" + " FLAGS=" + tz390.get_hex(flags, 2) + " LEN="
						+ tz390.get_hex(reg.getShort(r0 + 2), 4) + " ADDR="  // RPI-671
						+ tz390.get_hex(addr, 6);
			} else {
				return "TPUT" + " FLAGS=" + tz390.get_hex(flags, 2) + " LEN="
						+ tz390.get_hex(reg.getShort(r0 + 2), 4) + " ADDR="  // RPI-671
						+ tz390.get_hex(addr, 6);
			}
		case 151: // dcb get R0=REC,R1=DCB
			return "GET R0=REC ADDR FOR GM, R1=DCB/BUFF FOR GL"; // RPI-764
		case 152: // dcb put R0=REC, R1=DCB
			return "PUT R0=REC ADDR FOR PM, R1=DCB/BUFF FOR PL"; // RPI-764
		case 153: // dcb read R1=DECB
			return "READ R1=DECB";
		case 154: // dcb write R1=DECB
			return "WRITE R1=DECB";
		case 155: // decb check R1=DECB
			return "CHECK R1=DECB";
		case 156: // dcb point R1=DCB
			return "POINT R1=DCB";
		case 160: // wtor
			return "WTOR R0=REPLY, R1=MSG, R14=LEN, R15=ECB";
		case 161: // zsort
			return "ZSORT R0=OP(1-IS,2-PUT,3-GET),R1=A(OPT,LREC,KO,KL,MEM)";
		case 170: // CTD
			return "CTD R1=A(TYPE,IN,OUT)";
		case 171: // CFD
			return "CFD R1=A(TYPE,OUT,IN)";
		case 172: // x'ac' SYSTRACE options
			return "SYSTRACE R1=A(TRACE OPTIONS EGQTV ";
		default:
			return "UNKNOWN";
		}
	}

	/**
	 * Return psw cc for big int comp.
	 * @param big_int1
	 * @param big_int2
	 * @return
	 */
	public int get_big_int_comp_cc(final BigInteger big_int1, final BigInteger big_int2) { // RPI-1092
		switch (big_int1.compareTo(big_int2)) {
		case -1:
			return psw_cc_low;
		case 0:
			return psw_cc_equal;
		case 1:
			return psw_cc_high;
		default:
			set_psw_check(Constants.psw_pic_interr);
			return psw_cc_ovf;
		}
	}

	/**
	 * Check rlv3 = rlv1 + rlv2 for fixed overflow and set psw_cc or gen fixed exception.
	 * @return
	 */
	private int get_long_add_cc() {
		if (rlv1 >= 0) {
			if (rlv2 > 0) {
				if (rlv3 < 0) {
					set_psw_check(Constants.psw_pic_fx_ovf);
				}
			}
		} else if (rlv2 < 0) {
			if (rlv3 >= 0) {
				set_psw_check(Constants.psw_pic_fx_ovf);
			}
		}
		if (rlv3 == 0) {
			return psw_cc_equal;
		} else {
			if (rlv3 > 0) {
				return psw_cc_high;
			} else {
				return psw_cc_low;
			}
		}
	}

	/**
	 * Check rlv3 = rlv1 - rlv2 for fixed overflow and set psw_cc or gen fixed exception.
	 * @return
	 */
	private int get_long_sub_cc() {
		if (rlv1 >= 0) {
			if (rlv2 < 0) {
				if (rlv3 < 0) {
					set_psw_check(Constants.psw_pic_fx_ovf);
				}
			}
		} else if (rlv2 > 0) {
			if (rlv3 >= 0) {
				set_psw_check(Constants.psw_pic_fx_ovf);
			}
		}
		if (rlv3 == 0) {
			return psw_cc_equal;
		} else {
			if (rlv3 > 0) {
				return psw_cc_high;
			} else {
				return psw_cc_low;
			}
		}
	}

	/**
	 * Return psw_cc for long compare.
	 * @param long1
	 * @param long2
	 * @return
	 */
	public int get_long_comp_cc(final long long1, final long long2) {  // RPI-1092
		if (long1 == long2) {
			return psw_cc_equal;
		} else {
			if (long1 > long2) {
				return psw_cc_high;
			} else {
				return psw_cc_low;
			}
		}
	}

	/**
	 * Check rv3 = rv1 + rv2 for fixed overflow and set psw_cc or gen fixed exception.
	 * @return
	 */
	private int get_int_add_cc() {
		if (rv1 >= 0) {
			if (rv2 > 0) {
				if (rv3 < 0) {
					set_psw_check(Constants.psw_pic_fx_ovf);
				}
			}
		} else if (rv2 < 0) {
			if (rv3 >= 0) {
				set_psw_check(Constants.psw_pic_fx_ovf);
			}
		}
		if (rv3 == 0) {
			return psw_cc_equal;
		} else {
			if (rv3 > 0) {
				return psw_cc_high;
			} else {
				return psw_cc_low;
			}
		}
	}

	/**
	 * Check rv3 = rv1 - rv2 for fixed overflow and set psw_cc or gen fixed exception.
	 * @return
	 */
	private int get_int_sub_cc() {
		if (rv1 >= 0) {
			if (rv2 < 0) {
				if (rv3 < 0) {
					set_psw_check(Constants.psw_pic_fx_ovf);
				}
			}
		} else if (rv2 > 0) {
			if (rv3 >= 0) {
				set_psw_check(Constants.psw_pic_fx_ovf);
			}
		}
		if (rv3 == 0) {
			return psw_cc_equal;
		} else {
			if (rv3 > 0) {
				return psw_cc_high;
			} else {
				return psw_cc_low;
			}
		}
	}

	/**
	 * Return psw_cc for int compare.
	 * @param int1
	 * @param int2
	 * @return
	 */
	private int get_int_comp_cc(int int1, int int2) {
		if (int1 == int2) {
			return psw_cc_equal;
		} else {
			if (int1 > int2) {
				return psw_cc_high;
			} else {
				return psw_cc_low;
			}
		}
	}

	/**
	 * Raise inexact exception if fp_rbdv1 not = fp_rbdv2
	 */
	private void check_bd12_exact() {
		int comp12 = fp_rbdv1.compareTo(fp_rbdv2);
		if (comp12 != 0) {
			if (comp12 > 0) {
				fp_dxc = fp_dxc_ii; // inexact round up
			} else {
				fp_dxc = fp_dxc_it; // inexact truncate
			}
			set_psw_check(Constants.psw_pic_data);
		}
	}

	/**
	 * Check for EB overflow or underflow.
	 */
	private void check_eb_mpy() {
		if (fp_rev1 != 0.) { // RPI-808
			if (Math.abs(fp_rev1) >= fp_eb_max) {
				fp_dxc = fp_dxc_oe;
				set_psw_check(Constants.psw_pic_data);
			} else if (Math.abs(fp_rev1) <= fp_eb_min) {
				fp_dxc = fp_dxc_ue;
				set_psw_check(Constants.psw_pic_data);
			}
		}
	}

	/**
	 * Check for EH overflow or underflow.
	 */
	private void check_eh_mpy() {
		if (fp_rdv1 != 0.) { // RPI-808
			if (Math.abs(fp_rdv1) >= fp_eh_max) {
				set_psw_check(Constants.psw_pic_fp_ovf);
			} else if (Math.abs(fp_rdv1) <= fp_eh_min) {
				set_psw_check(Constants.psw_pic_fp_unf);
			}
		}
	}

	/**
	 * Check for DB overflow or underflow.
	 */
	private void check_db_mpy() {
		if (fp_rdv1 != 0.) { // RPI-808
			if (Math.abs(fp_rdv1) >= fp_db_max) {
				fp_dxc = fp_dxc_oe;
				set_psw_check(Constants.psw_pic_data);
			} else if (Math.abs(fp_rdv1) <= fp_db_min) {
				fp_dxc = fp_dxc_ue;
				set_psw_check(Constants.psw_pic_data);
			}
		}
	}

	/**
	 * Check for DD overflow or underflow.
	 */
	private void check_dd_mpy() { // RPI-820
		if (fp_rbdv1.signum() != 0) {
			if (fp_rbdv1.abs().compareTo(fp_dd_pos_max) >= 0) {
				fp_dxc = fp_dxc_oe;
				set_psw_check(Constants.psw_pic_data);
			} else if (fp_rbdv1.abs().compareTo(fp_dd_pos_min) <= 0) {
				fp_dxc = fp_dxc_ue;
				set_psw_check(Constants.psw_pic_data);
			}
		}
	}

	/**
	 * Check for DH overflow or underflow.
	 */
	private void check_dh_mpy() {
		if (fp_rbdv1.signum() != 0.) { // RPI-808 RPI-821
			if (fp_rbdv1.abs().compareTo(fp_dh_max) >= 0) {  // RPI-821
				set_psw_check(Constants.psw_pic_fp_ovf);
			} else if (fp_rbdv1.abs().compareTo(fp_dh_min) <= 0) { // RPI-821
				set_psw_check(Constants.psw_pic_fp_unf);
			}
		}
	}

	/**
	 * Check for LB overflow or underflow.
	 */
	private void check_lb_mpy() {
		if (fp_rbdv1.signum() != 0) { // RPI-808
			if (fp_rbdv1.abs().compareTo(fp_lh_max) >= 0) {
				fp_dxc = fp_dxc_oe;
				set_psw_check(Constants.psw_pic_data);
			} else if (fp_rbdv1.abs().compareTo(fp_lh_min) <= 0) {
				fp_dxc = fp_dxc_ue;
				set_psw_check(Constants.psw_pic_data);
			}
		}
	}

	/**
	 * Check for LD overflow or underflow.
	 */
	private void check_ld_mpy() {  // RPI-820
		if (fp_rbdv1.signum() != 0) { // RPI-808
			if (fp_rbdv1.abs().compareTo(fp_ld_pos_max) >= 0) {
				fp_dxc = fp_dxc_oe;
				set_psw_check(Constants.psw_pic_data);
			} else if (fp_rbdv1.abs().compareTo(fp_ld_pos_min) <= 0) {
				fp_dxc = fp_dxc_ue;
				set_psw_check(Constants.psw_pic_data);
			}
		}
	}

	/**
	 * Check for LH overflow or underflow.
	 */
	private void check_lh_mpy() {
		if (fp_rbdv1.signum() != 0) { // RPI-808
			if (fp_rbdv1.abs().compareTo(fp_lh_max) >= 0) {
				fp_dxc = fp_dxc_oe;
				set_psw_check(Constants.psw_pic_fp_ovf);
			} else if (fp_rbdv1.abs().compareTo(fp_lh_min) <= 0) {
				fp_dxc = fp_dxc_ue;
				set_psw_check(Constants.psw_pic_fp_unf);
			}
		}
	}

	/**
	 * Check for EB overflow or underflow.
	 */
	private void check_eb_div() {
		if (fp_rev2 == 0) {
			if (fp_rev1 >= 0) { // RPI-830
				fp_reg.putInt(rf1,fp_eb_pos_inf);
			} else {
				fp_reg.putInt(rf1,fp_eb_neg_inf);
			}
			fp_dxc = fp_dxc_div;
			set_psw_check(Constants.psw_pic_data);
		} else if (fp_rev1 != 0.) { // RPI-808
			if (Math.abs(fp_rev1) >= fp_eb_max) {
				fp_dxc = fp_dxc_oe;
				set_psw_check(Constants.psw_pic_data);
			} else if (Math.abs(fp_rev1) <= fp_eb_min) {
				fp_dxc = fp_dxc_ue;
				set_psw_check(Constants.psw_pic_data);
			}
		}
	}

	/**
	 * Check for EH overflow or underflow.
	 */
	private void check_eh_div() {
		if (fp_rdv2 == 0) {
			set_psw_check(Constants.psw_pic_fp_div);
		} else if (fp_rdv1 != 0.) { // RPI-808
			if (Math.abs(fp_rdv1) >= fp_eh_max) {
				set_psw_check(Constants.psw_pic_fp_ovf);
			} else if (Math.abs(fp_rdv1) <= fp_eh_min) {
				set_psw_check(Constants.psw_pic_fp_unf);
			}
		}
	}

	/**
	 * Check for DB overflow or underflow.
	 */
	private void check_db_div() {
		if (fp_rdv2 == 0) {
			if (fp_rdv1 >= 0) { // RPI-830
				fp_reg.putLong(rf1,fp_db_pos_inf);
			} else {
				fp_reg.putLong(rf1,fp_db_neg_inf);
			}
			fp_dxc = fp_dxc_div;
			set_psw_check(Constants.psw_pic_data);
		} else if (fp_rdv1 != 0.) { // RPI-808
			if (Math.abs(fp_rdv1) >= fp_db_max) {
				fp_dxc = fp_dxc_oe;
				set_psw_check(Constants.psw_pic_data);
			} else if (Math.abs(fp_rdv1) <= fp_db_min) {
				fp_dxc = fp_dxc_ue;
				set_psw_check(Constants.psw_pic_data);
			}
		}
	}

	/**
	 * Check for DDTR overflow or underflow.
	 */
	private void check_dd_div() // RPI-820
	{
		if (fp_rbdv3.signum() == 0) {
			if (fp_rbdv2.signum() >= 0) { // RPI-830
				fp_reg.putLong(rf1,fp_dd_pos_inf);
			} else {
				fp_reg.putLong(rf1,fp_dd_neg_inf);
			}
			fp_dxc = fp_dxc_div;
			set_psw_check(Constants.psw_pic_data);
		} else if (fp_rbdv1.signum() != 0) { // RPI-808
			if (fp_rbdv1.abs().compareTo(fp_dd_pos_max) >= 0) {
				fp_dxc = fp_dxc_oe;
				set_psw_check(Constants.psw_pic_data);
			} else if (fp_rbdv1.abs().compareTo(fp_dd_pos_min) <= 0) {
				fp_dxc = fp_dxc_ue;
				set_psw_check(Constants.psw_pic_data);
			}
		}
	}

	/**
	 * Check for DH overflow or underflow.
	 */
	private void check_dh_div() // RPI-821
	{
		if (fp_rbdv2.signum() == 0) {
			set_psw_check(Constants.psw_pic_fp_div);
		} else if (fp_rbdv1.signum() != 0) { // RPI-808
			if (fp_rbdv1.abs().compareTo(fp_dh_max) >= 0) {
				set_psw_check(Constants.psw_pic_fp_ovf);
			} else if (fp_rbdv1.abs().compareTo(fp_dh_min) <= 0) {
				fp_dxc = fp_dxc_ue;
				set_psw_check(Constants.psw_pic_fp_unf);
			}
		}
	}

	/**
	 * Check for LB overflow or underflow.
	 */
	private void check_lb_div()
	{
		if (fp_rbdv2.signum() == 0) {
			if (fp_rbdv1.signum() >= 0) { // RPI-830
				fp_reg.putLong(rf1,fp_lb_pos_inf);
				fp_reg.putLong(rf1+16,0);
			} else {
				fp_reg.putLong(rf1,fp_lb_neg_inf);
				fp_reg.putLong(rf1+16,0);
			}
			fp_dxc = fp_dxc_div;
			set_psw_check(Constants.psw_pic_data);
		} else if (fp_rbdv1.signum() != 0) { // RPI-808
			if (fp_rbdv1.abs().compareTo(fp_lh_max) >= 0) {
				fp_dxc = fp_dxc_oe;
				set_psw_check(Constants.psw_pic_data);
			} else if (fp_rbdv1.abs().compareTo(fp_lh_min) <= 0) {
				fp_dxc = fp_dxc_ue;
				set_psw_check(Constants.psw_pic_data);
			}
		}
	}

	/**
	 * Check for DXTR overflow or underflow.
	 */
	private void check_ld_div() // RPI-820
	{
		if (fp_rbdv3.signum() == 0) {
			if (fp_rbdv2.signum() >= 0) { // RPI-830
				fp_reg.putLong(rf1,fp_ld_pos_inf);
				fp_reg.putLong(rf1+16,0);
			} else {
				fp_reg.putLong(rf1,fp_ld_neg_inf);
				fp_reg.putLong(rf1+16,0);
			}
			fp_dxc = fp_dxc_div;
			set_psw_check(Constants.psw_pic_data);
		} else if (fp_rbdv1.signum() != 0.) { // RPI-808
			if (fp_rbdv1.abs().compareTo(fp_ld_pos_max) >= 0) {
				fp_dxc = fp_dxc_oe;
				set_psw_check(Constants.psw_pic_data);
			} else if (fp_rbdv1.abs().compareTo(fp_ld_pos_min) <= 0) {
				fp_dxc = fp_dxc_ue;
				set_psw_check(Constants.psw_pic_data);
			}
		}
	}

	/**
	 * Check for LH overflow or underflow
	 */
	private void check_lh_div()
	{
		if (fp_rbdv2.signum() == 0) {
			set_psw_check(Constants.psw_pic_fp_div);
		} else if (fp_rbdv1.signum() != 0) { // RPI-808
			if (fp_rbdv1.abs().compareTo(fp_lh_max) >= 0) {
				set_psw_check(Constants.psw_pic_fp_ovf);
			} else if (fp_rbdv1.abs().compareTo(fp_lh_min) <= 0) {
				fp_dxc = fp_dxc_ue;
				set_psw_check(Constants.psw_pic_fp_unf);
			}
		}
	}

	/**
	 * Return psw_cc for fp divide to integer.
	 */
	private int fp_get_di_cc()
	{
		fp_rdv3 = Math.abs(fp_rdv3);
		fp_rdv4 = Math.abs(fp_rdv4);
		if (fp_rdv3 >= fp_db_max) {
			fp_dxc = fp_dxc_oe;
			set_psw_check(Constants.psw_pic_data);
			return psw_cc1;
		} else if (fp_rdv3 != 0 && fp_rdv3 <= fp_db_min) {
			fp_dxc = fp_dxc_ue;
			set_psw_check(Constants.psw_pic_data);
			return psw_cc1;
		} else if (fp_rdv4 >= fp_db_max) {
			fp_dxc = fp_dxc_oe;
			set_psw_check(Constants.psw_pic_data);
			return psw_cc2;
		} else if (fp_rdv4 != 0 && fp_rdv4 <= fp_db_min) {
			fp_dxc = fp_dxc_ue;
			set_psw_check(Constants.psw_pic_data);
			return psw_cc2;
		} else {
			return psw_cc0;
		}
	}

	/**
	 * Return psw_cc for float compare.
	 *
	 * @param eb1
	 * @param eb2
	 * @return
	 */
	private int fp_get_eb_comp_cc(final float eb1, final float eb2)
	{
		if (fp_signal) {
			fp_signal = false;
			if (Math.abs(eb1) >= fp_db_max || Math.abs(eb2) >= fp_eb_max) {
				fp_dxc = fp_dxc_oe;
				set_psw_check(Constants.psw_pic_data);
			} else if ((Math.abs(eb1) <= fp_eb_min && eb1 != 0.) // RPI-325
					|| (Math.abs(eb2) <= fp_eb_min && eb2 != 0.)) {
				fp_dxc = fp_dxc_ue;
				set_psw_check(Constants.psw_pic_data);
			}
		}
		if (eb1 == eb2) {
			return psw_cc_equal;
		} else {
			if (eb1 > eb2) {
				return psw_cc_high;
			} else {
				return psw_cc_low;
			}
		}
	}

	/**
	 * Return psw_cc for eb add/sub result fp_rev1 and raise BFP sig, ovf, or unf exceptions.
	 *
	 * @return
	 */
	private int fp_get_eb_add_sub_cc()
	{
		if (fp_rev1 == 0) {
			fp_dxc = fp_dxc_it;
			set_psw_check(Constants.psw_pic_data);
			return psw_cc_equal;
		} else {
			if (fp_rev1 > 0) {
				if (fp_rev1 >= fp_eb_max) {
					fp_dxc = fp_dxc_oe;
					set_psw_check(Constants.psw_pic_data);
				} else if (fp_rev1 <= fp_eb_min) {
					fp_dxc = fp_dxc_ue;
					set_psw_check(Constants.psw_pic_data);
				}
				return psw_cc_high;
			} else {
				if (fp_rev1 <= -fp_eb_max) {
					fp_dxc = fp_dxc_oe;
					set_psw_check(Constants.psw_pic_data);
				} else if (fp_rev1 >= -fp_eh_min) {
					fp_dxc = fp_dxc_ue;
					set_psw_check(Constants.psw_pic_data);
				}
				return psw_cc_low;
			}
		}
	}

	/**
	 * Return psw_cc for DB double compare.
	 *
	 * @param db1
	 * @param db2
	 * @return
	 */
	private int fp_get_db_comp_cc(final double db1, final double db2)
	{
		if (fp_signal) {
			fp_signal = false;
			if (Math.abs(db1) >= fp_db_max || Math.abs(db2) >= fp_db_max) {
				fp_dxc = fp_dxc_oe;
				set_psw_check(Constants.psw_pic_data);
			} else if ((Math.abs(db1) <= fp_db_min && db1 != 0.) // RPI-325
					|| (Math.abs(db2) <= fp_db_min && db2 != 0.)) {
				fp_dxc = fp_dxc_ue;
				set_psw_check(Constants.psw_pic_data);
			}
		}
		if (db1 == db2) {
			return psw_cc_equal;
		} else {
			if (db1 > db2) {
				return psw_cc_high;
			} else {
				return psw_cc_low;
			}
		}
	}

	/**
	 * Return psw_cc for EH double compare.
	 *
	 * @param db1
	 * @param db2
	 * @return
	 */
	private int fp_get_eh_comp_cc(final double db1, final double db2)
	{
		if (db1 == db2) {
			return psw_cc_equal;
		} else {
			if (db1 > db2) {
				return psw_cc_high;
			} else {
				return psw_cc_low;
			}
		}
	}

	/**
	 * Return psw_cc for DD compare with or without signal.
	 *
	 * @param dd1
	 * @param dd2
	 * @return
	 */
	private int fp_get_dd_comp_cc(final BigDecimal dd1, final BigDecimal dd2)
	{
		if (fp_signal) {
			fp_signal = false;
			if (dd1.abs().compareTo(fp_dd_pos_max) > 0
			 || dd2.abs().compareTo(fp_dd_pos_max) > 0) {
				fp_dxc = fp_dxc_oe;
				set_psw_check(Constants.psw_pic_data);
			} else if ((dd1.abs().compareTo(fp_dd_pos_min) < 0 && dd1.signum() != 0) // RPI-325
					|| (dd2.abs().compareTo(fp_dd_pos_min) < 0 && dd2.signum() != 0)) {
				fp_dxc = fp_dxc_ue;
				set_psw_check(Constants.psw_pic_data);
			}
		}
		if (dd1.compareTo(dd2) == 0) {
			return psw_cc_equal;
		} else {
			if (dd1.compareTo(dd2) > 0) {
				return psw_cc_high;
			} else {
				return psw_cc_low;
			}
		}
	}

	/**
	 * Return psw_cc for LD compare with or without signal.
	 *
	 * @param ld1
	 * @param ld2
	 * @return
	 */
	private int fp_get_ld_comp_cc(BigDecimal ld1, BigDecimal ld2)
	{
		if (fp_signal) {
			fp_signal = false;
			if (ld1.abs().compareTo(fp_ld_pos_max) > 0
				|| ld2.abs().compareTo(fp_ld_pos_max) > 0) {
				fp_dxc = fp_dxc_oe;
				set_psw_check(Constants.psw_pic_data);
			} else if ((ld1.abs().compareTo(fp_ld_pos_min) < 0 && ld1.signum() != 0) // RPI-325
					|| (ld2.abs().compareTo(fp_ld_pos_min) < 0 && ld2.signum() != 0)) {
				fp_dxc = fp_dxc_ue;
				set_psw_check(Constants.psw_pic_data);
			}
		}
		if (ld1.compareTo(ld2) == 0) {
			return psw_cc_equal;
		} else {
			if (ld1.compareTo(ld2) > 0) {
				return psw_cc_high;
			} else {
				return psw_cc_low;
			}
		}
	}

	/**
	 * Return psw_cc for eh add/sub result fp_rdv1 and raise HFP sig, ovf, or unf exceptions.
	 *
	 * @return
	 */
	private int fp_get_eh_add_sub_cc()
	{
		if (fp_rdv1 == 0) {
			set_psw_check(Constants.psw_pic_fp_sig);
			return psw_cc_equal;
		} else {
			if (fp_rdv1 > 0) {
				if (fp_rdv1 >= fp_eh_max) {
					set_psw_check(Constants.psw_pic_fp_ovf);
				} else if (fp_rdv1 <= fp_eh_min) {
					set_psw_check(Constants.psw_pic_fp_unf);
				}
				return psw_cc_high;
			} else {
				if (fp_rdv1 <= -fp_eh_max) {
					set_psw_check(Constants.psw_pic_fp_ovf);
				} else if (fp_rdv1 >= -fp_eh_min) {
					set_psw_check(Constants.psw_pic_fp_unf);
				}
				return psw_cc_low;
			}
		}
	}

	/**
	 * Return psw_cc for dh add/sub result fp_rbdv1 and raise HFP sig, ovf, or unf exceptions.
	 *
	 * @return
	 */
	private int fp_get_dh_add_sub_cc()
	{
		if (fp_rbdv1.signum() == 0) {  // RPI-821
			set_psw_check(Constants.psw_pic_fp_sig);
			return psw_cc_equal;
		} else {
			if (fp_rbdv1.abs().compareTo(fp_dh_max) >= 0) {  // RPI-821
				set_psw_check(Constants.psw_pic_fp_ovf);
			} else if (fp_rbdv1.abs().compareTo(fp_dh_min) <= 0) {
				set_psw_check(Constants.psw_pic_fp_unf);
			}
		}
		if (fp_rbdv1.signum() > 0) {  // RPI-821
			return psw_cc_high;
		} else { // <= 0
			return psw_cc_low;
		}
	}

	/**
	 * Return psw_cc for db add/sub result fp_rdv1 and raise BFP sig, ovf, or unf exceptions.
	 *
	 * @return
	 */
	private int fp_get_db_add_sub_cc()
	{
		if (fp_rdv1 == 0) {
			fp_dxc = fp_dxc_it;
			set_psw_check(Constants.psw_pic_data);
			return psw_cc_equal;
		} else {
			if (fp_rdv1 > 0) {
				if (fp_rdv1 >= fp_db_max) {
					fp_dxc = fp_dxc_oe;
					set_psw_check(Constants.psw_pic_data);
				} else if (fp_rdv1 <= fp_db_min) {
					fp_dxc = fp_dxc_ue;
					set_psw_check(Constants.psw_pic_data);
				}
				return psw_cc_high;
			} else {
				if (fp_rdv1 <= -fp_db_max) {
					fp_dxc = fp_dxc_oe;
					set_psw_check(Constants.psw_pic_data);
				} else if (fp_rdv1 >= -fp_db_min) {
					fp_dxc = fp_dxc_ue;
					set_psw_check(Constants.psw_pic_data);
				}
				return psw_cc_low;
			}
		}
	}

	/**
	 * Return psw_cc for big decimal compare.
	 *
	 * @param bd1
	 * @param bd2
	 * @return
	 */
	private int fp_get_lb_comp_cc(BigDecimal bd1, BigDecimal bd2)
	{
		bd1 = bd1.round(fp_lb_rnd_context[fp_bfp_rnd]); // RPI-821
		bd2 = bd2.round(fp_lb_rnd_context[fp_bfp_rnd]); // RPI-821
		if (fp_signal) {
			fp_signal = false;
			if (bd1.abs().compareTo(fp_lb_max) >= 0
			 || bd2.abs().compareTo(fp_lb_max) >= 0) {
				fp_dxc = fp_dxc_oe;
				set_psw_check(Constants.psw_pic_data);
			} else if ((bd1.abs().compareTo(fp_lb_min) <= 0 // RPI-325
					&& !(bd1.signum() == 0))
					|| (bd2.abs().compareTo(fp_lb_min) <= 0
					&& !(bd2.signum() == 0))) {
				fp_dxc = fp_dxc_ue;
				set_psw_check(Constants.psw_pic_data);
			}
		}
		final int int_work = bd1.compareTo(bd2);
		if (int_work == 0) {
			return psw_cc_equal;
		} else {
			if (int_work > 0) {
				return psw_cc_high;
			} else {
				return psw_cc_low;
			}
		}
	}

	/**
	 * Return psw_cc for DH big decimal compare.
	 *
	 * @param bd1
	 * @param bd2
	 * @return
	 */
	private int fp_get_dh_comp_cc(BigDecimal bd1, BigDecimal bd2)
	{
		bd1 = bd1.round(fp_dh_context); // RPI-821
		bd2 = bd2.round(fp_dh_context); // RPI-821
		final int int_work = bd1.compareTo(bd2);
		if (int_work == 0) {
			return psw_cc_equal;
		} else {
			if (int_work > 0) {
				return psw_cc_high;
			} else {
				return psw_cc_low;
			}
		}
	}

	/**
	 * Return psw_cc for LH big decimal compare.
	 *
	 * @param bd1
	 * @param bd2
	 * @return
	 */
	private int fp_get_lh_comp_cc(BigDecimal bd1, BigDecimal bd2)
	{
		bd1 = bd1.round(fp_lb_rnd_context[fp_bfp_rnd]); // RPI-821
		bd2 = bd2.round(fp_lb_rnd_context[fp_bfp_rnd]); // RPI-821
		final int int_work = bd1.compareTo(bd2);
		if (int_work == 0) {
			return psw_cc_equal;
		} else {
			if (int_work > 0) {
				return psw_cc_high;
			} else {
				return psw_cc_low;
			}
		}
	}

	/**
	 * Return psw_cc for lh add/sub result fp_rbdv1 * and raise HFP sig, ovf, or unf exceptions.
	 *
	 * @return
	 */
	private int fp_get_lh_add_sub_cc()
	{
		if (fp_rbdv1.signum() == 0) {
			set_psw_check(Constants.psw_pic_fp_sig);
			return psw_cc_equal;
		} else {
			if (fp_rbdv1.signum() > 0) {
				if (fp_rbdv1.compareTo(fp_lh_max) >= 0) {
					set_psw_check(Constants.psw_pic_fp_ovf);
				} else if (fp_rbdv1.compareTo(fp_lh_min) <= 0) {
					set_psw_check(Constants.psw_pic_fp_unf);
				}
				return psw_cc_high;
			} else {
				if (fp_rbdv1.compareTo(fp_lh_max.negate()) <= 0) {
					set_psw_check(Constants.psw_pic_fp_ovf);
				} else if (fp_rbdv1.compareTo(fp_lh_min.negate()) >= 0) {
					set_psw_check(Constants.psw_pic_fp_unf);
				}
				return psw_cc_low;
			}
		}
	}

	/**
	 * Return psw_cc for lb add/sub result fp_rbdv1 and raise BFP sig, ovf, or unf exceptions.
	 *
	 * @return
	 */
	private int fp_get_lb_add_sub_cc()
	{
		fp_rbdv1 = fp_rbdv1.round(fp_lb_rnd_context[fp_bfp_rnd]); // RPI-821
		int int_work = fp_rbdv1.signum();
		if (int_work == 0) {
			fp_dxc = fp_dxc_it;
			set_psw_check(Constants.psw_pic_data);
			return psw_cc_equal;
		} else {
			if (int_work > 0) {
				if (fp_rbdv1.compareTo(fp_lb_max) >= 0) {
					fp_dxc = fp_dxc_oe;
					set_psw_check(Constants.psw_pic_data);
				} else if (fp_rbdv1.compareTo(fp_lb_min) <= 0) {
					fp_dxc = fp_dxc_ue;
					set_psw_check(Constants.psw_pic_data);
				}
				return psw_cc_high;
			} else {
				if (fp_rbdv1.compareTo(fp_lb_max.negate()) <= 0) {
					fp_dxc = fp_dxc_oe;
					set_psw_check(Constants.psw_pic_data);
				} else if (fp_rbdv1.compareTo(fp_lb_min.negate()) >= 0) {
					fp_dxc = fp_dxc_ue;
					set_psw_check(Constants.psw_pic_data);
				}
				return psw_cc_low;
			}
		}
	}

	/**
	 * Return psw_cc for bd add/sub result fp_rdv1 and raise sig, ovf, or unf exceptions.
	 *
	 * @return
	 */
	private int fp_get_dfp_add_sub_cc()
	{
		if (fp_rbdv1.signum() == 0) {
			return psw_cc_equal;
		} else {
			if (fp_rbdv1.signum() > 0) {
				if (fp_rbdv1.compareTo(fp_dd_pos_max) >= 0) {
					fp_dxc = fp_dxc_oe;
					set_psw_check(Constants.psw_pic_data);
				} else if (fp_rbdv1.compareTo(fp_dd_pos_min) <= 0) {
					fp_dxc = fp_dxc_ue;
					set_psw_check(Constants.psw_pic_data);
				}
				return psw_cc_high;
			} else {
				if (fp_rbdv1.compareTo(fp_dd_neg_max) < 0) {
					fp_dxc = fp_dxc_oe;
					set_psw_check(Constants.psw_pic_data);
				} else if (fp_rbdv1.compareTo(fp_dd_neg_min) > 0) {
					fp_dxc = fp_dxc_ue;
					set_psw_check(Constants.psw_pic_data);
				}
				return psw_cc_low;
			}
		}
	}

	/**
	 * Return psw_cc for integer logical compare.
	 *
	 * @param int1
	 * @param int2
	 * @return
	 */
	private int get_int_log_comp_cc(final int int1, final int int2)
	{
		if (int1 == int2) {
			return psw_cc_equal;
		} else {
			if (int1 > int2) {
				if ((int1 & 0x80000000) == (int2 & 0x80000000)) {
					return psw_cc_high;
				} else {
					return psw_cc_low;
				}
			} else {
				if ((int1 & 0x80000000) == (int2 & 0x80000000)) {
					return psw_cc_low;
				} else {
					return psw_cc_high;
				}
			}
		}
	}

	/**
	 * Return psw_cc for long logical compare.
	 *
	 * @param long1
	 * @param long2
	 * @return
	 */
	private int get_long_log_comp_cc(final long long1, final long long2)
	{
		if (long1 == long2) {
			return psw_cc_equal;
		} else {
			if (long1 > long2) {
				if ((long1 & long_high_bit) == (long2 & long_high_bit)) {
					return psw_cc_high;
				} else {
					return psw_cc_low;
				}
			} else {
				if ((long1 & long_high_bit) == (long2 & long_high_bit)) {
					return psw_cc_low;
				} else {
					return psw_cc_high;
				}
			}
		}
	}

	/**
	 * Get float for EB from fp_reg or memory.
	 * If fp_reg then check for co-reg to avoid conversion.
	 * Notes:
	 * 1. Float is used to support EB only.
	 * 2. EH is supported using double since exponent (4*0x7f) exceeds EB (0xff).
	 *
	 * @param fp_buff
	 * @param fp_index
	 * @return
	 */
	public float fp_get_eb_from_eb(final ByteBuffer fp_buff, final int fp_index)
	{
		final int fp_ctl_index = fp_index >> 3;
		if (fp_buff == fp_reg && fp_reg_ctl[fp_ctl_index] != fp_ctl_ld) {
			if (fp_reg_ctl[fp_ctl_index] != fp_ctl_bd2) {
				return fp_ctl_reg_to_eb(fp_ctl_index);
			} else {
				fp_store_reg(fp_reg, (fp_ctl_index -2) << 3); // RPI-824
			}
		}
		return fp_buff.getFloat(fp_index);
	}

	/**
	 * Get double from EH short hex in fp_reg or memory.
	 * If fp_reg, then check for double co-reg to avoid conversion.
	 *
	 * @param fp_buff
	 * @param fp_index
	 * @return
	 */
	public double fp_get_db_from_eh(final ByteBuffer fp_buff, final int fp_index)
	{
		final int fp_ctl_index = fp_index >> 3;
		if (fp_buff == fp_reg && fp_reg_ctl[fp_ctl_index] != fp_ctl_ld) {
			if (fp_reg_ctl[fp_ctl_index] != fp_ctl_bd2) {
				return fp_ctl_reg_to_db(fp_ctl_index);
			} else {
				fp_store_reg(fp_reg, (fp_ctl_index -2) << 3); // RPI-824
			}
		}
		return fp_eh_reg_to_db(fp_buff.getInt(fp_index));
	}

	/**
	 * Get double from EB short binary in fp_reg or memory.
	 * If fp_reg, then check for float co-reg to avoid conversion.
	 *
	 * @param fp_buff
	 * @param fp_index
	 * @return
	 */
	private double fp_get_db_from_eb(final ByteBuffer fp_buff, final int fp_index)
	{
		final int fp_ctl_index = fp_index >> 3;
		if (fp_buff == fp_reg && fp_reg_ctl[fp_ctl_index] != fp_ctl_ld) {
			if (fp_reg_ctl[fp_ctl_index] != fp_ctl_bd2) {
				return fp_ctl_reg_to_db(fp_ctl_index);
			} else {
				fp_store_reg(fp_reg, (fp_ctl_index -2) << 3); // RPI-824
			}
		}
		return fp_buff.getFloat(fp_index);
	}

	/**
	 * Get double from DB Long binary in fp_reg or memory.
	 * If fp_reg, then check for float co-reg to avoid conversion.
	 *
	 * @param fp_buff
	 * @param fp_index
	 * @return
	 */
	public double fp_get_db_from_db(final ByteBuffer fp_buff, final int fp_index)
	{
		final int fp_ctl_index = fp_index >> 3;
		if (fp_buff == fp_reg && fp_reg_ctl[fp_ctl_index] != fp_ctl_ld) {
			if (fp_reg_ctl[fp_ctl_index] != fp_ctl_bd2) {
				return fp_ctl_reg_to_db(fp_ctl_index);
			} else {
				fp_store_reg(fp_reg, (fp_ctl_index -2) << 3); // RPI-824
			}
		}
		return fp_buff.getDouble(fp_index);
	}

	/**
	 * Get double from LH ext hex in fp_reg or memory.
	 * If fp_reg, then check for bd co-reg to avoid external conversion.
	 *
	 * @param fp_buff
	 * @param fp_index
	 * @return
	 */
	private double fp_get_db_from_lh(final ByteBuffer fp_buff, final int fp_index)
	{
		final int fp_ctl_index = fp_index >> 3;
		if (fp_buff == fp_reg && fp_reg_ctl[fp_ctl_index] != fp_ctl_ld) {
			if (fp_reg_ctl[fp_ctl_index] != fp_ctl_bd2) {
				return fp_ctl_reg_to_db(fp_ctl_index);
			} else {
				fp_store_reg(fp_reg, (fp_ctl_index -2) << 3); // RPI-824
			}
		}
		return fp_lh_to_bd(fp_buff, fp_index).doubleValue();
	}

	/**
	 * Add unnormalized HFP DH fp_long1 = fp_long1 + fp_long2 and set psw_cc.
	 */
	private void fp_add_unnorm_dh()
	{
		if (fp_long1 >= 0) {
			fp_sign1 = 0x00;
		} else {
			fp_sign1 = (byte)0x80;
		}
		if (fp_long2 >= 0) {
			fp_sign2 = 0x00;
		} else {
			fp_sign2 = (byte)0x80;
		}
		fp_exp1 =(byte)((fp_long1 >>> 56) & 0x7f);
		fp_exp2 =(byte)((fp_long2 >>> 56) & 0x7f);
		if (fp_exp1 >= fp_exp2) {
			fp_long1 = (fp_long1 & long_dh_man_bits);
			fp_long2 = (fp_long2 & long_dh_man_bits) >>> ((fp_exp1-fp_exp2)*4);
		} else if (fp_exp1 < fp_exp2) {
			fp_long1 = (fp_long1 & long_dh_man_bits) >>> ((fp_exp2-fp_exp1)*4);
			fp_long2 = (fp_long2 & long_dh_man_bits);
			fp_exp1  = fp_exp2;
		}
		if (fp_sign1 == fp_sign2) {
			fp_long1 = fp_long1 + fp_long2;
		} else {
			if (fp_long1 >= fp_long2) {
				fp_long1 = fp_long1 - fp_long2;
			} else {
				fp_sign1 = fp_sign2;
				fp_long1 = fp_long2 - fp_long1;
			}
		}
		if (fp_long1 == 0) {
			psw_cc = psw_cc0;
		} else {
			if (fp_sign1 == 0) {
				fp_long1 = fp_long1 | ((long)(fp_exp1) << 56);
				psw_cc = psw_cc2;
			} else {
				fp_long1 = fp_long1 | ((long)(fp_exp1 | fp_sign1) << 56);
				psw_cc = psw_cc1;
			}
		}
	}

	/**
	 * Add unnormalized HFP DH fp_long1 = fp_long1 + fp_long2 and set psw=cc.
	 */
	private void fp_add_unnorm_eh()
	{
		if (fp_int1 >= 0) {
			fp_sign1 = 0x00;
		} else {
			fp_sign1 = (byte)0x80;
		}
		if (fp_int2 >= 0) {
			fp_sign2 = 0x00;
		} else {
			fp_sign2 = (byte)0x80;
		}
		fp_exp1 =(byte)((fp_int1 >>> 24) & 0x7f);
		fp_exp2 =(byte)((fp_int2 >>> 24) & 0x7f);
		if (fp_exp1 >= fp_exp2) {
			fp_int1 = (fp_int1 & int_eh_man_bits);
			fp_int2 = (fp_int2 & int_eh_man_bits) >>> ((fp_exp1-fp_exp2)*4);
		} else if (fp_exp1 < fp_exp2) {
			fp_int1 = (fp_int1 & int_eh_man_bits) >>> ((fp_exp2-fp_exp1)*4);
			fp_int2 = (fp_int2 & int_eh_man_bits);
			fp_exp1  = fp_exp2;
		}
		if (fp_sign1 == fp_sign2) {
			fp_int1 = fp_int1 + fp_int2;
		} else {
			if (fp_int1 >= fp_int2) {
				fp_int1 = fp_int1 - fp_int2;
			} else {
				fp_sign1 = fp_sign2;
				fp_int1 = fp_int2 - fp_int1;
			}
		}
		if (fp_int1 == 0) {
			psw_cc = psw_cc0;
		} else {
			if (fp_sign1 == 0) {
				fp_int1 = fp_int1 | ((int)(fp_exp1) << 24);
				psw_cc = psw_cc2;
			} else {
				fp_int1 = fp_int1 | ((int)(fp_exp1 | fp_sign1) << 24);
				psw_cc = psw_cc1;
			}
		}
	}

	/**
	 * Multiply fp_long2 and fp_long3 dh unnormalized
	 * and set fp_big_int1 and tz390.fp_exp and tz390.fp_sign high bit.
	 */
	private void fp_mpy_unnorm_dh()
	{
		tz390.fp_sign = (int)((fp_long1 ^ fp_long2) >>> 32) & int_high_bit;
		fp_exp2 =(byte)((fp_long2 >>> 56) & 0x7f);
		fp_exp3 =(byte)((fp_long3 >>> 56) & 0x7f);
		tz390.fp_exp = (fp_exp2 + fp_exp3 - 0x40) & 0x7f;
		fp_big_int1 = BigInteger.valueOf(fp_long2 & long_dh_man_bits)
						.multiply(BigInteger.valueOf(fp_long3 & long_dh_man_bits));
	}

	/**
	 * Add LH at rf1 to fp_big_int1 unnormalized
	 * and update tz390.fp_sign high bit if change.
	 * Notes:
	 * LH at rf1 stored in fp_big_int2 and fp_exp2 for add
	 */
	private void fp_add_bi_unnorm_dh()
	{
		if (tz390.fp_exp > fp_exp2) {
			fp_big_int2 = fp_big_int2.shiftRight((tz390.fp_exp-fp_exp2)*4);
		} else if (tz390.fp_exp < fp_exp2) {
			fp_big_int1 = fp_big_int1.shiftRight((fp_exp2-tz390.fp_exp)*4);
			tz390.fp_exp = fp_exp2;
		}
		if (fp_sign1 == fp_sign2) {
			fp_big_int1 = fp_big_int1.add(fp_big_int2);
		} else {
			if (fp_big_int1.compareTo(fp_big_int2) >= 0) {
				fp_big_int1 = fp_big_int1.subtract(fp_big_int2);
			} else {
				tz390.fp_sign = fp_sign2;
				fp_big_int1 = fp_big_int2.subtract(fp_big_int1);
			}
		}
	}

	/**
	 * Set fp_big_int2, fp_exp2, fp_sign2 from rf1 LH.
	 */
	private void fp_get_bi_unnorm_lh()
	{
		fp_exp2 = fp_reg.get(rf1);
		if (fp_exp2 >= 0) {
			fp_sign2 = 0;
		} else {
			fp_sign2 = (byte)0x80;
			fp_exp2 = (byte)(fp_exp2 & 0x7f);
		}
		fp_big_int2 = BigInteger
				.valueOf(fp_reg.getLong(rf1) & long_dh_man_bits)
				.shiftLeft(56)
				.add(BigInteger.valueOf(fp_reg.getLong(rf1+16) & long_dh_man_bits));
	}

	/**
	 * Set fp_big_int2, fp_exp2, fp_sign2 from rf1 DH.
	 */
	private void fp_get_bi_unnorm_dh()
	{
		fp_exp2 = fp_reg.get(rf1);
		if (fp_exp2 >= 0) {
			fp_sign2 = 0;
		} else {
			fp_sign2 = (byte)0x80;
			fp_exp2 = (byte)(fp_exp2 & 0x7f);
		}
		fp_big_int2 = BigInteger.valueOf(fp_reg.getLong(rf1) & long_dh_man_bits);
	}

	/**
	 * Set fp_rbdv1 to square root of fp_rbdv2.<br><br>
	 * Notes:
	 * <ol><li>Return 0 for 0 and issue data exception if negative.
	 *     <li>Scale number to within double range to calculate estimate to 14 decimal places.
	 *     <li>Use Newton Rapson iteration to reduce error to fp_lxg_context limit.</ol>
	 */
	private void fp_get_bd_sqrt()
	{
		// First handle 0 and negative values.
		if (fp_rbdv2.signum() <= 0) {
			if (fp_rbdv2.signum() < 0) {
				set_psw_check(Constants.psw_pic_data);
			}
			fp_rbdv1 = BigDecimal.ZERO;
			return;
		}
		// First fp_rbdv2 = x * 10 ** N
		// where N is even so x is within double range and sqrt = sqrt(x) * 10 ** (N/2)
		int fp_bd_sqrt_scale = fp_rbdv2.scale();
		if ((fp_bd_sqrt_scale & 1) != 0) {
			fp_rbdv2 = fp_rbdv2.setScale(fp_bd_sqrt_scale - 1,fp_lxg_context.getRoundingMode());  // RPI-768
			fp_bd_sqrt_scale--;
		}
		fp_rbdv2 = fp_rbdv2.multiply(BigDecimal.TEN.pow(fp_bd_sqrt_scale, fp_lxg_context), fp_lxg_context);

		// Now calculate initial guess at sqrt of fp_rbdv2
		fp_rbdv1 = BigDecimal.valueOf(Math.sqrt(fp_rbdv2.doubleValue()));

		// Now iterate using Newton Rapson until error is less than fp_bd_min.
		fp_rbdv3 = fp_rbdv1; // save prev
		fp_rbdv1 = fp_rbdv2.divide(fp_rbdv1, fp_lxg_context).add(fp_rbdv1,
				fp_lxg_context).multiply(fp_bd_half, fp_lxg_context);
		while (fp_rbdv1.compareTo(fp_rbdv3) != 0) {
			fp_rbdv3 = fp_rbdv1; // save previous
			fp_rbdv1 = fp_rbdv2.divide(fp_rbdv1, fp_lxg_context).add(fp_rbdv1,
										fp_lxg_context).multiply(fp_bd_half, fp_lxg_context);
		}
		fp_rbdv1 = fp_rbdv1.scaleByPowerOfTen(-fp_bd_sqrt_scale / 2).round(
				fp_lb_rnd_context[fp_bfp_rnd]);
	}

	/**
	 * Get big decimal from LH extended hex in fp_reg or memory.
	 * If fp_reg, then check for big decimal co-reg to avoid conversion.
	 *
	 * @param fp_buff
	 * @param fp_index
	 * @return
	 */
	public BigDecimal fp_get_bd_from_lh(final ByteBuffer fp_buff, final int fp_index)
	{
		final int fp_ctl_index = fp_index >> 3;
		if (fp_buff == fp_reg && fp_reg_ctl[fp_ctl_index] != fp_ctl_ld) {
			if (fp_reg_ctl[fp_ctl_index] != fp_ctl_bd2) {
				return fp_ctl_reg_to_bd(fp_ctl_index).round(fp_lh_context); // RPI-821
			} else {
				fp_store_reg(fp_reg, (fp_ctl_index -2) << 3); // RPI-824
			}
		}
		return fp_lh_to_bd(fp_buff, fp_index);
	}

	/**
	 * Get big decimal from LH extended binary in fp_reg or memory.
	 * If fp_reg, then check for big decimal co-reg to avoid conversion.
	 *
	 * @param fp_buff
	 * @param fp_index
	 * @return
	 */
	public BigDecimal fp_get_bd_from_lb(final ByteBuffer fp_buff, final int fp_index)
	{
		final int fp_ctl_index = fp_index >> 3;
		if (fp_buff == fp_reg && fp_reg_ctl[fp_ctl_index] != fp_ctl_ld) {
			if (fp_reg_ctl[fp_ctl_index] != fp_ctl_bd2) {
				return fp_ctl_reg_to_bd(fp_ctl_index).round(fp_lb_rnd_context[fp_dfp_rnd]); // RPI-1211
			} else {
				fp_store_reg(fp_reg, (fp_ctl_index -2) << 3); // RPI-824
			}
		}
		return fp_lb_to_bd(fp_buff, fp_index);
	}

	/**
	 * Get big decimal from ED dpd short in fp_reg or memory.
	 * If fp_reg, then check for big decimal co-reg to avoid conversion.
	 *
	 * @param fp_buff
	 * @param fp_index
	 * @return
	 */
	public BigDecimal fp_get_bd_from_ed(final ByteBuffer fp_buff, final int fp_index)
	{
		final int fp_ctl_index = fp_index >> 3;
		if (fp_buff == fp_reg && fp_reg_ctl[fp_ctl_index] != fp_ctl_ld) {
			if (fp_reg_ctl[fp_ctl_index] != fp_ctl_bd2) {
				return fp_ctl_reg_to_bd(fp_ctl_index);
			} else {
				fp_store_reg(fp_reg, (fp_ctl_index -2) << 3); // RPI-824
			}
		}
		return fp_ed_to_bd(fp_buff, fp_index);
	}

	/**
	 * Get big decimal from ED dpd long in fp_reg or memory.
	 * If fp_reg, then check for big decimal co-reg to avoid conversion.
	 *
	 * @param fp_buff
	 * @param fp_index
	 * @return
	 */
	public BigDecimal fp_get_bd_from_dd(final ByteBuffer fp_buff, final int fp_index)
	{
		final int fp_ctl_index = fp_index >> 3;
		if (fp_buff == fp_reg && fp_reg_ctl[fp_ctl_index] != fp_ctl_ld) {
			if (fp_reg_ctl[fp_ctl_index] != fp_ctl_bd2) {
				return fp_ctl_reg_to_bd(fp_ctl_index).round(fp_dd_rnd_context[fp_dfp_rnd]); // RPI-1211
			} else {
				fp_store_reg(fp_reg, (fp_ctl_index -2) << 3); // RPI-824
			}
		}
		return fp_dd_to_bd(fp_buff, fp_index);
	}

	/**
	 * Get big decimal from LD dpd extended in fp_reg or memory.
	 * 1. If fp_reg, then check for big decimal co-reg to avoid conversion.
	 *
	 * @param fp_buff
	 * @param fp_index
	 * @return
	 */
	public BigDecimal fp_get_bd_from_ld(final ByteBuffer fp_buff, final int fp_index)
	{
		final int fp_ctl_index = fp_index >> 3;
		if (fp_buff == fp_reg && fp_reg_ctl[fp_ctl_index] != fp_ctl_ld) {
			if (fp_reg_ctl[fp_ctl_index] != fp_ctl_bd2) {
				return fp_ctl_reg_to_bd(fp_ctl_index).round(fp_ld_rnd_context[fp_dfp_rnd]); // RPI-1211
			} else {
				fp_store_reg(fp_reg, (fp_ctl_index -2) << 3); // RPI-824
			}
		}
		return fp_ld_to_bd(fp_buff, fp_index);
	}

	/**
	 * Return float from fp_reg.
	 *
	 * @param fp_ctl_index
	 * @return
	 */
	private Float fp_ctl_reg_to_eb(final int fp_ctl_index)
	{
		switch (fp_reg_ctl[fp_ctl_index]) {
		case 1: // fp_ctl_eb
			return fp_reg_eb[fp_ctl_index];
		case 2: // fp_ctl_db
			return (float) fp_reg_db[fp_ctl_index];
		case 3: // fp_ctl_bd
			return fp_reg_bd[fp_ctl_index].floatValue();
		default:
			set_psw_check(Constants.psw_pic_spec);
			return (float) 0;
		}
	}

	/**
	 * Return double from fp_reg.
	 *
	 * @param fp_ctl_index
	 * @return
	 */
	private Double fp_ctl_reg_to_db(int fp_ctl_index)
	{
		switch (fp_reg_ctl[fp_ctl_index]) {
		case 1: // fp_ctl_eb
			return (double) fp_reg_eb[fp_ctl_index];
		case 2: // fp_ctl_db
			return fp_reg_db[fp_ctl_index];
		case 3: // fp_ctl_bd
			return fp_reg_bd[fp_ctl_index].doubleValue();
		default:
			set_psw_check(Constants.psw_pic_spec);
			return (double) 0;
		}
	}

	/**
	 * Return BigDecimal from fp_reg cache.
	 *
	 * @param fp_ctl_index
	 * @return
	 */
	private BigDecimal fp_ctl_reg_to_bd(final int fp_ctl_index)
	{
		switch (fp_reg_ctl[fp_ctl_index]) {
		case 1: // fp_ctl_eb
			return BigDecimal.valueOf(fp_reg_eb[fp_ctl_index]);
		case 2: // fp_ctl_db
			return BigDecimal.valueOf(fp_reg_db[fp_ctl_index]);
		case 3: // fp_ctl_bd
			return fp_reg_bd[fp_ctl_index];
		default:
			set_psw_check(Constants.psw_pic_spec);
			return BigDecimal.ZERO;
		}
	}

	/**
	 * Get big decimal from DH long hex in fp_reg or memory.
	 * If fp_reg, then check for big decimal co-reg to avoid conversion.
	 *
	 * @param fp_buff
	 * @param fp_index
	 * @return
	 */
	public BigDecimal fp_get_bd_from_dh(final ByteBuffer fp_buff, final int fp_index)
	{
		final int fp_ctl_index = fp_index >> 3;
		if (fp_buff == fp_reg && fp_reg_ctl[fp_ctl_index] != fp_ctl_ld) {
			if (fp_reg_ctl[fp_ctl_index] != fp_ctl_bd2) {
				return fp_ctl_reg_to_bd(fp_ctl_index).round(fp_dh_rnd_context[fp_dfp_rnd]); // RPI-1211

			} else {
				fp_store_reg(fp_reg, (fp_ctl_index -2) << 3); // RPI-824
			}
		}
		return fp_dh_to_bd(fp_buff.getLong(fp_index)); // RPI-821
	}

	/**
	 * Get big decimal from DB long bin in fp_reg or mem
	 * If fp_reg, then check for big decimal co-reg to avoid conversion.
	 *
	 * @param fp_buff
	 * @param fp_index
	 * @return
	 */
	private BigDecimal fp_get_bd_from_db(final ByteBuffer fp_buff, final int fp_index)
	{
		return new BigDecimal(fp_get_db_from_db(fp_buff, fp_index), fp_db_rnd_context[fp_bfp_rnd]);
	}

	/**
	 * Copy fp reg for LD or LXD. RPI-816
	 *
	 * @param index1
	 * @param index2
	 */
	private void fp_copy_reg(int index1,int index2)
	{
		fp_reg_ctl[ index1] = fp_reg_ctl[index2];
		fp_reg_type[index1] = fp_reg_type[index2];
		switch (fp_reg_ctl[index2]) {
		case 0:
			fp_reg.putLong(index1 << 3,fp_reg.getLong(index2 << 3));
			break;
		case 1:
			fp_reg_eb[index1] = fp_reg_eb[index2];
			break;
		case 2:
			fp_reg_db[index1] = fp_reg_db[index2];
			break;
		case 3:
		case 4:
			fp_reg_bd[index1] = fp_reg_bd[index2];
			break;
		}
	}

	/**
	 * Set fpc reg and bfp/dfp rounding for LFPC, LFAS, and SFASR
	 * Notes:
	 * LFAS and SFASR signaling not supported for now
	 *
	 * @param fpc_reg
	 */
	private void set_fpc_reg(final int fpc_reg)
	{
		fp_fpc_reg = fpc_reg;
		fp_dxc = (fp_fpc_reg & 0xff00) >>> 8;
		fp_dfp_rnd = (fp_fpc_reg & fp_dfp_rnd_mask) >> 4;
		fp_dfp_rnd_default = fp_dfp_rnd; // RPI-1125
		fp_bfp_rnd = fp_fpc_reg & fp_bfp_rnd_mask;
		fp_bfp_rnd_default = fp_bfp_rnd; // RPI-1125
		fp_fpc_reg = fp_fpc_reg & 0xffff00ff;
	}

	/**
	 * Get bd rounded to integer from fp_bd_int_rnd[]
	 * Notes:
	 *   1.  For BFP - mode = 0-3
	 *   2.  For DFP - mode - 0-7
	 *
	 * @param fp_class
	 * @param rnd_mode
	 * @return
	 */
	private BigDecimal fp_get_bd_rnd_int(final byte fp_class, int rnd_mode)
	{
		rnd_mode = fp_get_rnd_mode(fp_class,rnd_mode);
		if (fp_bd_int_rem[0].signum() >= 0) {
			fp_bd_inc = BigDecimal.ONE;
		} else {
			fp_bd_inc = BigDecimal.ONE.negate();
		}
		int rem_comp_half = fp_bd_int_rem[1].abs().compareTo(fp_bd_half);
		switch (rnd_mode) {
		case 0: // round to nearest with half even
			if (rem_comp_half > 0) {
				return fp_bd_int_rem[0].add(fp_bd_inc);
			} else if (rem_comp_half < 0) {
				return fp_bd_int_rem[0];
			} else if (fp_bd_int_rem[0].toBigInteger().testBit(0)) { // RPI-533
				return fp_bd_int_rem[0].add(fp_bd_inc); // round to even
			} else {
				return fp_bd_int_rem[0];
			}
		case 1: // round nearest, half toward 0
			if (rem_comp_half > 0) {
				return fp_bd_int_rem[0].add(fp_bd_inc);
			} else {  // RPI-533
				return fp_bd_int_rem[0];
			}
		case 2: // round toward + infinity
			if (fp_bd_int_rem[1].signum() > 0) {
				return fp_bd_int_rem[0].add(fp_bd_inc);
			} else {
				return fp_bd_int_rem[0];
			}
		case 3: // round toward -infinity
			if (fp_bd_int_rem[1].signum() < 0) {
				return fp_bd_int_rem[0].add(fp_bd_inc);
			} else {
				return fp_bd_int_rem[0];
			}
		case 4: // round to nearest with ties away from 0
			if (rem_comp_half >= 0) {
				return fp_bd_int_rem[0].add(fp_bd_inc);
			} else {
				return fp_bd_int_rem[0];
			}
		case 5: // round to nearest with ties toward 0
			if (rem_comp_half > 0) {
				return fp_bd_int_rem[0].add(fp_bd_inc);
			} else {
				return fp_bd_int_rem[0];
			}
		case 6: // round away from zero
			if (fp_bd_int_rem[1].signum() != 0) {  // RPI-533
				return fp_bd_int_rem[0].add(fp_bd_inc);
			} else {
				return fp_bd_int_rem[0];
			}
		case 7: // prepare for shorter (round to nearest with ties away from 0 for now)
			if (rem_comp_half >= 0) {
				return fp_bd_int_rem[0].add(fp_bd_inc);
			} else {
				return fp_bd_int_rem[0];
			}
		default:
			set_psw_check(Constants.psw_pic_spec);
			return fp_bd_int_rem[0];
		}
	}

	/**
	 * Return requested rounding mode 0-7 based on explicit rounding mode request
	 *   0   - use default for fp_class
	 *   1   - use round near half nzero (bfp only)
	 *   4-7 - maps to 0-3 for bfp
	 *   8-15- maps to 0-8 for dfp
	 *
	 * @return
	 */
	private int fp_get_rnd_mode(final byte fp_class, int rnd_mode)
	{
		if (rnd_mode == 0) {
			if (fp_class == fp_dfp_class) {
				rnd_mode = fp_dfp_rnd; // current dfp rounding mode
			} else {
				rnd_mode = fp_bfp_rnd;
			}
		} else {
			if (fp_class == fp_dfp_class) {
				rnd_mode = rnd_mode - 8; // map dfp explicit 8-15 to 0-7
			} else {
				if (rnd_mode == 1) {
					rnd_mode = fp_rnd_near_nzero;
				} else {
					rnd_mode = rnd_mode - 4; // map bfp explicit 4-7 to 0-3
				}
			}
		}
		if (rnd_mode < 0 || rnd_mode > 7) {
			set_psw_check(Constants.psw_pic_spec);
			rnd_mode = 0;
		}
		return rnd_mode;
	}

	/**
	 * Get big decimal from DB long bin in fp_reg or memory.<br>
	 * If fp_reg, then check for big dec co-reg to avoid conversion.
	 *
	 * @param fp_buff
	 * @param fp_index
	 * @return
	 */
	private BigDecimal fp_get_bd_from_eb(final ByteBuffer fp_buff, final int fp_index)
	{
		return new BigDecimal(fp_get_eb_from_eb(fp_buff, fp_index), fp_eb_rnd_context[fp_bfp_rnd]);
	}

	/**
	 * Get big decimal from EH short hex in fp_reg or memory.
	 * If fp_reg, then check for big dec co-reg to avoid conversion.
	 *
	 * @param fp_buff
	 * @param fp_index
	 * @return
	 */
	private BigDecimal fp_get_bd_from_eh(final ByteBuffer fp_buff, final int fp_index)
	{
		final int fp_ctl_index = fp_index >> 3;
		if (fp_buff == fp_reg && fp_reg_ctl[fp_ctl_index] != fp_ctl_ld) {
			if (fp_reg_ctl[fp_ctl_index] != fp_ctl_bd2) {
				return fp_ctl_reg_to_bd(fp_ctl_index);
			} else {
				fp_store_reg(fp_reg, (fp_ctl_index -2) << 3); // RPI-824
			}
		}
		return fp_eh_to_bd(fp_buff, fp_index);
	}

	/**
	 * Store float co-reg as EB and set type Note: 1. Only tz390.fp_eb_type.
	 * Uses float co-reg due to exponent range exceeded for tz390.fp_eh_type.
	 *
	 * @param fp_index
	 * @param reg_type
	 * @param reg_value
	 */
	private void fp_put_eb(int fp_index, byte reg_type, float reg_value)
	{
		final int fp_ctl_index = fp_index >> 3;
		fp_reset_reg(fp_ctl_index, fp_ctl_eb, reg_type);
		fp_reg_eb[fp_ctl_index] = reg_value;
	}

	/**
	 * Store db co-reg as EH, DH, or DB and set type
	 * (EH used double due to exponent range of float is too small).
	 *
	 * @param fp_index
	 * @param reg_type
	 * @param reg_value
	 */
	private void fp_put_db(final int fp_index, final byte reg_type, final double reg_value)
	{
		final int fp_ctl_index = fp_index >> 3;
		fp_reset_reg(fp_ctl_index, fp_ctl_db, reg_type);
		fp_reg_db[fp_ctl_index] = reg_value;
	}

	/**
	 * Store bd co-reg as DD, DH, LD, LH or LB and set type for reg pair.
	 *
	 * @param fp_index
	 * @param reg_type
	 * @param reg_value
	 */
	private void fp_put_bd(final int fp_index, final byte reg_type, final BigDecimal reg_value)
	{
		final int fp_ctl_index = fp_index >> 3;
		fp_reset_reg(fp_ctl_index, fp_ctl_bd1, reg_type);
		fp_reg_bd[fp_ctl_index] = reg_value;
	}

	/**
	 * Load fp_ctl from fp_reg or fp_ctl Load fp_reg from memory with no conversion.
	 * Notes:
	 * 1. bd1/bd2 co-reg pair being partially replaced is discarded without conversion.
	 * 2. This function is called recursively when two co-registers of different types are involved.
	 *
	 * @param reg_buff_index1
	 * @param reg_type1
	 * @param reg_buff2
	 * @param reg_buff_index2
	 * @param reg_type2
	 */
	private void fp_load_reg(int reg_buff_index1, byte reg_type1,
			ByteBuffer reg_buff2, int reg_buff_index2, byte reg_type2)
	{
		final int fp_ctl_index1 = reg_buff_index1 >>> 3;
		int fp_ctl_index2 = -1;
		int fp_reg_ctl2 = fp_ctl_ld;
		byte fp_reg_type2 = reg_type2;
		if (reg_buff2 == fp_reg) {
			fp_ctl_index2 = reg_buff_index2 >>> 3;
			if (fp_reg_ctl[fp_ctl_index2] != fp_ctl_ld) {
				// save ctl type before reset incase reg1 = reg2
				fp_reg_ctl2 = fp_reg_ctl[fp_ctl_index2];
				fp_reg_type2 = fp_reg_type[fp_ctl_index2];
			}
		}
		fp_reset_reg(fp_ctl_index1, fp_ctl_ld, reg_type1);
		if (reg_buff2 == fp_reg
				&& (fp_reg_ctl2 != fp_ctl_ld
					|| (opcode1 != 0x28 && opcode1 != 0x38))) { // RPI-1003
			// Load fp_ctl reg from reg or other fp_ctl reg.
			fp_load_ctl(fp_ctl_index1, reg_type1, fp_reg_ctl2, reg_buff_index2, fp_reg_type2);
		} else {
			// Load fp_reg from memory without conversion.
			fp_load_mem(reg_buff2,reg_buff_index1, reg_type1, reg_buff_index2, reg_type2);
		}
	}

	/**
	 * Load fp_reg memory without conversion.
	 *
	 * @param mem_buff
	 * @param reg_buff_index1
	 * @param reg_type1
	 * @param mem_index2
	 * @param mem_type2
	 */
	private void fp_load_mem(final ByteBuffer mem_buff, int reg_buff_index1, final byte reg_type1, final int mem_index2, final byte mem_type2)
	{
		fp_reg_ctl[reg_buff_index1 >>> 3] = fp_ctl_ld;
		switch (mem_type2) {
		case 0: // tz390.fp_db_type
		case 1: // tz390.fp_dd_type
		case 2: // tz390.fp_dh_type
			fp_reg.putLong(reg_buff_index1, mem_buff.getLong(mem_index2));
			break;
		case 3: // tz390.fp_eb_type
		case 4: // tz390.fp_ed_type
		case 5: // tz390.fp_eh_type
			fp_reg.putLong(reg_buff_index1,(long) mem_buff.getInt(mem_index2) << 32);
			break;
		case 6: // tz390.fp_lb_type
		case 7: // tz390.fp_ld_type
		case 8: // tz390.fp_lh_type
			fp_reg.putLong(reg_buff_index1, mem_buff.getLong(mem_index2));
			break;
		default:
			set_psw_check(Constants.psw_pic_spec);
		}
	}

	/**
	 * Load fp control register from register memory or other fp control register.
	 *
	 * @param fp_ctl_index1
	 * @param reg_type1
	 * @param fp_ctl_type2
	 * @param fp_buff_index2
	 * @param reg_type2
	 */
	private void fp_load_ctl(final int fp_ctl_index1, final byte reg_type1, final int fp_ctl_type2, final int fp_buff_index2, final byte reg_type2)
	{
		final int fp_ctl_index2 = fp_buff_index2 >>> 3;
		switch (fp_ctl_type2) {
		case 0: // from fp_ctl_ld external register
			fp_load_ctl_from_ext_reg(fp_ctl_index1, reg_type1, fp_reg, fp_buff_index2, reg_type2);
			return;
		case 1: // from fp_ctl_eb float for EB
			switch (reg_type1) {
			case 0: // to tz390.fp_db_type
				fp_reg_db[fp_ctl_index1] = fp_reg_eb[fp_ctl_index2];
				fp_reg_ctl[fp_ctl_index1] = fp_ctl_db;
				return;
			case 1: // tz390.fp_dd_type RPI-1003
				fp_reg_bd[fp_ctl_index1] = BigDecimal
						.valueOf(fp_reg_eb[fp_ctl_index2]);
				fp_reg_ctl[fp_ctl_index1] = fp_ctl_bd1;
				return;
			case 2: // tz390.fp_dh_type
				fp_reg_db[fp_ctl_index1] = fp_reg_eb[fp_ctl_index2];
				fp_reg_ctl[fp_ctl_index1] = fp_ctl_db;
				return;
			case 3: // tz390.fp_eb_type
				fp_reg_eb[fp_ctl_index1] = fp_reg_eb[fp_ctl_index2];
				fp_reg_ctl[fp_ctl_index1] = fp_ctl_eb;
				return;
			case 4: // tz390.fp_ed_type RPI-1003
				fp_reg_bd[fp_ctl_index1] = BigDecimal
						.valueOf(fp_reg_eb[fp_ctl_index2]);
				fp_reg_ctl[fp_ctl_index1] = fp_ctl_bd1;
				return;
			case 5: // tz390.fp_eh_type
				fp_reg_db[fp_ctl_index1] = fp_reg_eb[fp_ctl_index2];
				fp_reg_ctl[fp_ctl_index1] = fp_ctl_db;
				return;
			case 6: // tz390.fp_lb_type
				fp_reg_bd[fp_ctl_index1] = BigDecimal
						.valueOf(fp_reg_eb[fp_ctl_index2]);
				fp_reg_ctl[fp_ctl_index1] = fp_ctl_bd1;
				fp_reg_ctl[fp_ctl_index1+2] = fp_ctl_bd2;  // RPI-768
				return;
			case 7: // tz390.fp_lH_type // RPI-1013 missing
				fp_reg_bd[fp_ctl_index1] = fp_reg_bd[fp_ctl_index2];
				fp_reg_ctl[fp_ctl_index1] = fp_ctl_bd1;
				fp_reg_ctl[fp_ctl_index1+2] = fp_ctl_bd2;  // RPI-768
				return;
			case 8: // tz390.fp_lh_type
				fp_reg_bd[fp_ctl_index1] = BigDecimal
						.valueOf(fp_reg_eb[fp_ctl_index2]);
				fp_reg_ctl[fp_ctl_index1] = fp_ctl_bd1;
				fp_reg_ctl[fp_ctl_index1+2] = fp_ctl_bd2;  // RPI-768
				return;
			}
			break;
		case 2: // from fp_ctl_db double for EH and DB
			switch (reg_type1) {
			case 0: // tz390.fp_db_type
				fp_reg_db[fp_ctl_index1] = fp_reg_db[fp_ctl_index2];
				fp_reg_ctl[fp_ctl_index1] = fp_ctl_db;
				return;
			case 1: // tz390.fp_dd_type RPI-1003
				fp_reg_bd[fp_ctl_index1] = BigDecimal
				.valueOf(fp_reg_db[fp_ctl_index2]);
				fp_reg_ctl[fp_ctl_index1] = fp_ctl_bd1;
				return;
			case 2: // tz390.fp_dh_type
				fp_reg_bd[fp_ctl_index1] = BigDecimal.valueOf(fp_reg_db[fp_ctl_index2]); // RPI-1003
				fp_reg_ctl[fp_ctl_index1] = fp_ctl_bd1; // RPI-1003
				return;
			case 3: // tz390.fp_eb_type
				fp_reg_eb[fp_ctl_index1] = (float) fp_reg_db[fp_ctl_index2];
				fp_reg_ctl[fp_ctl_index1] = fp_ctl_eb;
				return;
			case 4: // tz390.fp_ed_type RPI-1003
				fp_reg_bd[fp_ctl_index1] = BigDecimal
				.valueOf(fp_reg_db[fp_ctl_index2]);
				fp_reg_ctl[fp_ctl_index1] = fp_ctl_bd1;
				return;
			case 5: // tz390.fp_eh_type
				fp_reg_db[fp_ctl_index1] = fp_reg_db[fp_ctl_index2];
				fp_reg_ctl[fp_ctl_index1] = fp_ctl_db;
				return;
			case 6: // tz390.fp_lb_type
				fp_reg_bd[fp_ctl_index1] = BigDecimal
						.valueOf(fp_reg_db[fp_ctl_index2]);
				fp_reg_ctl[fp_ctl_index1] = fp_ctl_bd1;
				fp_reg_ctl[fp_ctl_index1+2] = fp_ctl_bd2;  // RPI-768
				return;
			case 7: // tz390.fp_ld_type   // RPI-1003
				fp_reg_bd[fp_ctl_index1] = BigDecimal
						.valueOf(fp_reg_db[fp_ctl_index2]);
				fp_reg_ctl[fp_ctl_index1] = fp_ctl_bd1;
				fp_reg_ctl[fp_ctl_index1+2] = fp_ctl_bd2;  // RPI-768
				return;
			case 8: // tz390.fp_lh_type
				fp_reg_bd[fp_ctl_index1] = BigDecimal
						.valueOf(fp_reg_db[fp_ctl_index2]);
				fp_reg_ctl[fp_ctl_index1] = fp_ctl_bd1;
				fp_reg_ctl[fp_ctl_index1+2] = fp_ctl_bd2;  // RPI-768
				return;
			}
			break;
		case 3: // from fp_ctl_bd1
			switch (reg_type1) {
			case 0: // tz390.fp_db_type
				fp_reg_db[fp_ctl_index1] = fp_reg_bd[fp_ctl_index2]
						.doubleValue();
				fp_reg_ctl[fp_ctl_index1] = fp_ctl_db;
				return;
			case 1: // tz390.fp_dd_type
				fp_reg_bd[fp_ctl_index1] = fp_reg_bd[fp_ctl_index2];
				fp_reg_ctl[fp_ctl_index1] = fp_ctl_bd1;
				return;
			case 2: // tz390.fp_dh_type
				fp_reg_bd[fp_ctl_index1] = fp_reg_bd[fp_ctl_index2]; // RPI-1003
				fp_reg_ctl[fp_ctl_index1] = fp_ctl_bd1; // RPI-1003
				return;
			case 3: // tz390.fp_eb_type
				fp_reg_eb[fp_ctl_index1] = fp_reg_bd[fp_ctl_index2]
						.floatValue();
				fp_reg_ctl[fp_ctl_index1] = fp_ctl_eb;
				return;
			case 4: // tz390.fp_ed_type // RPI-1015 was missing
				fp_reg_bd[fp_ctl_index1] = fp_reg_bd[fp_ctl_index2];
				fp_reg_ctl[fp_ctl_index1] = fp_ctl_bd1;
				return;
			case 5: // tz390.fp_eh_type
				fp_reg_db[fp_ctl_index1] = fp_reg_bd[fp_ctl_index2]
						.floatValue();
				fp_reg_ctl[fp_ctl_index1] = fp_ctl_db;
				return;
			case 6: // tz390.fp_lb_type
				fp_reg_bd[fp_ctl_index1] = fp_reg_bd[fp_ctl_index2];
				fp_reg_ctl[fp_ctl_index1] = fp_ctl_bd1;
				fp_reg_ctl[fp_ctl_index1+2] = fp_ctl_bd2;  // RPI-768
				return;
			case 7: // tz390.fp_ld_type // RPI-1013 missing
				fp_reg_bd[fp_ctl_index1] = fp_reg_bd[fp_ctl_index2];
				fp_reg_ctl[fp_ctl_index1] = fp_ctl_bd1;
				fp_reg_ctl[fp_ctl_index1+2] = fp_ctl_bd2;  // RPI-768
				return;
			case 8: // tz390.fp_lh_type
				fp_reg_bd[fp_ctl_index1] = fp_reg_bd[fp_ctl_index2];
				fp_reg_ctl[fp_ctl_index1] = fp_ctl_bd1;
				fp_reg_ctl[fp_ctl_index1+2] = fp_ctl_bd2;  // RPI-768
				return;
			}
			break;
		default: // from invalid control reg type
			set_psw_check(Constants.psw_pic_spec); // invalid LH/LB reg ref.
			return;
		}
	}

	/**
	 * Load fp_ctl reg1 from fp_reg2 external format.
	 *
	 * @param fp_ctl_index1
	 * @param reg_type1
	 * @param reg_buff2
	 * @param reg_buff_index2
	 * @param reg_type2
	 */
	private void fp_load_ctl_from_ext_reg(final int fp_ctl_index1, final byte reg_type1, final ByteBuffer reg_buff2, final int reg_buff_index2, final byte reg_type2)
	{
		switch (reg_type2) {
		case 0: // from tz390.fp_db_type
			switch (reg_type1) {
			case 0: // to tz390.fp_db_type
				fp_reg_db[fp_ctl_index1] = fp_get_db_from_db(reg_buff2, reg_buff_index2);
				fp_reg_ctl[fp_ctl_index1] = fp_ctl_db;
				return;
			case 1: // DB to DD  RPI-1013
				fp_reg_bd[fp_ctl_index1] = fp_get_bd_from_db(reg_buff2, reg_buff_index2);
				fp_reg_ctl[fp_ctl_index1] = fp_ctl_bd1;
				return;
			case 2: // tz390.fp_dh_type
				fp_reg_bd[fp_ctl_index1] = fp_get_bd_from_db(reg_buff2, reg_buff_index2); // RPI-821
				fp_reg_ctl[fp_ctl_index1] = fp_ctl_bd1;  // RPI-821
				return;
			case 3: // tz390.fp_eb_type
				fp_reg_eb[fp_ctl_index1] = (float) fp_get_db_from_db(reg_buff2, reg_buff_index2);
				fp_reg_ctl[fp_ctl_index1] = fp_ctl_eb;
				return;
			case 4: // DB to ED  RPI-1013
				fp_reg_bd[fp_ctl_index1] = fp_get_bd_from_db(reg_buff2, reg_buff_index2);
				fp_reg_ctl[fp_ctl_index1] = fp_ctl_bd1;
				return;
			case 5: // tz390.fp_eh_type
				fp_reg_db[fp_ctl_index1] = fp_get_db_from_db(reg_buff2, reg_buff_index2);
				fp_reg_ctl[fp_ctl_index1] = fp_ctl_db;
				return;
			case 6: // tz390.fp_lb_type
				fp_reg_bd[fp_ctl_index1] = fp_get_bd_from_db(reg_buff2, reg_buff_index2);
				fp_reg_ctl[fp_ctl_index1] = fp_ctl_bd1;
				fp_reg_ctl[fp_ctl_index1+2] = fp_ctl_bd2; //RPI-1003
				return;
			case 7: // DB to LD  RPI-1013
				fp_reg_bd[fp_ctl_index1] = fp_get_bd_from_db(reg_buff2, reg_buff_index2);
				fp_reg_ctl[fp_ctl_index1] = fp_ctl_bd1;
				fp_reg_ctl[fp_ctl_index1+2] = fp_ctl_bd2; // RPI-1013
				return;
			case 8: // tz390.fp_lh_type
				fp_reg_bd[fp_ctl_index1] = fp_get_bd_from_db(reg_buff2, reg_buff_index2);
				fp_reg_ctl[fp_ctl_index1] = fp_ctl_bd1;
				fp_reg_ctl[fp_ctl_index1+2] = fp_ctl_bd2; // RPI-1013
				return;
			}
			break;
		case 1: // tz390.fp_dd_type
			switch (reg_type1) {
			case 0: // DD to DB  RPI-1013
				fp_reg_db[fp_ctl_index1] = fp_get_bd_from_dd(reg_buff2, reg_buff_index2).doubleValue();
				fp_reg_ctl[fp_ctl_index1] = fp_ctl_db;
				return;
			case 1: // DD to DD  RPI-1013
				fp_reg_bd[fp_ctl_index1] = fp_get_bd_from_dd(reg_buff2, reg_buff_index2);
				fp_reg_ctl[fp_ctl_index1] = fp_ctl_bd1;
				return;
			case 2: // DD to DH  RPI-1013
				fp_reg_bd[fp_ctl_index1] = fp_get_bd_from_dd(reg_buff2, reg_buff_index2);
				fp_reg_ctl[fp_ctl_index1] = fp_ctl_bd1;
				return;
			case 3: // DD to EB  RPI-1013
				fp_reg_eb[fp_ctl_index1] = fp_get_bd_from_dd(reg_buff2, reg_buff_index2).floatValue();
				fp_reg_ctl[fp_ctl_index1] = fp_ctl_eb;
				return;
			case 4: // to tz390.fp_ed_type
				fp_reg_bd[fp_ctl_index1] = fp_get_bd_from_dd(reg_buff2, reg_buff_index2);
				fp_reg_ctl[fp_ctl_index1] = fp_ctl_bd1;
				return;
			case 5: // DD to EH  RPI-1013
				fp_reg_db[fp_ctl_index1] = fp_get_bd_from_dd(reg_buff2, reg_buff_index2).doubleValue();
				fp_reg_ctl[fp_ctl_index1] = fp_ctl_db;
				return;
			case 6: // DD to LD  RPI-1013
				fp_reg_bd[fp_ctl_index1] = fp_get_bd_from_dd(reg_buff2, reg_buff_index2);
				fp_reg_ctl[fp_ctl_index1] = fp_ctl_bd1;
				fp_reg_ctl[fp_ctl_index1+2] = fp_ctl_bd2; // RPI-1013
				return;
			case 7: // tz390.fp_ld_type
				fp_reg_bd[fp_ctl_index1] = fp_get_bd_from_dd(reg_buff2, reg_buff_index2);
				fp_reg_ctl[fp_ctl_index1] = fp_ctl_bd1; // RPI-1013 was fp_ctl_db
				fp_reg_ctl[fp_ctl_index1+2] = fp_ctl_bd2; // RPI-1013 was missing
				return;
			case 8: // DD to LH  RPI-1013
				fp_reg_bd[fp_ctl_index1] = fp_get_bd_from_dd(reg_buff2, reg_buff_index2);
				fp_reg_ctl[fp_ctl_index1] = fp_ctl_bd1;
				fp_reg_ctl[fp_ctl_index1+2] = fp_ctl_bd2; // RPI-1013
				return;
			}
			break;
		case 2: // tz390.fp_dh_type
			switch (reg_type1) {
			case 0: // tz390.fp_db_type
				fp_reg_db[fp_ctl_index1] = fp_get_bd_from_dh(reg_buff2, reg_buff_index2).doubleValue();
				fp_reg_ctl[fp_ctl_index1] = fp_ctl_db;
				return;
			case 1: // DH to DD  RPI-1013
				fp_reg_bd[fp_ctl_index1] = fp_get_bd_from_dh(reg_buff2, reg_buff_index2);
				fp_reg_ctl[fp_ctl_index1] = fp_ctl_bd1;
				return;
			case 2: // tz390.fp_dh_type
				fp_reg_bd[fp_ctl_index1] = fp_get_bd_from_dh(reg_buff2, reg_buff_index2); // RPI-821
				fp_reg_ctl[fp_ctl_index1] = fp_ctl_bd1; // RPI-821
				return;
			case 3: // tz390.fp_eb_type
				fp_reg_eb[fp_ctl_index1] = fp_get_bd_from_dh(reg_buff2, reg_buff_index2).floatValue(); // RPI-821
				fp_reg_ctl[fp_ctl_index1] = fp_ctl_eb;
				return;
			case 4: // DH to ED  RPI-1013
				fp_reg_bd[fp_ctl_index1] = fp_get_bd_from_dh(reg_buff2, reg_buff_index2);
				fp_reg_ctl[fp_ctl_index1] = fp_ctl_bd1;
				return;
			case 5: // tz390.fp_eh_type
				fp_reg_db[fp_ctl_index1] = fp_get_db_from_eh(reg_buff2, reg_buff_index2); // RPI-849
				fp_reg_ctl[fp_ctl_index1] = fp_ctl_db;
				return;
			case 6: // tz390.fp_lb_type
				fp_reg_bd[fp_ctl_index1] = fp_get_bd_from_dh(reg_buff2, reg_buff_index2);
				fp_reg_ctl[fp_ctl_index1] = fp_ctl_bd1;
				fp_reg_ctl[fp_ctl_index1+2] = fp_ctl_bd2; // RPI-1013
				return;
			case 7: // DH to LD  RPI-1013
				fp_reg_bd[fp_ctl_index1] = fp_get_bd_from_dh(reg_buff2, reg_buff_index2);
				fp_reg_ctl[fp_ctl_index1] = fp_ctl_bd1;
				fp_reg_ctl[fp_ctl_index1+2] = fp_ctl_bd2; // RPI-1013
				return;
			case 8: // tz390.fp_lh_type
				fp_reg_bd[fp_ctl_index1] = fp_get_bd_from_dh(reg_buff2, reg_buff_index2);
				fp_reg_ctl[fp_ctl_index1] = fp_ctl_bd1;
				fp_reg_ctl[fp_ctl_index1+2] = fp_ctl_bd2; // RPI-1013
				return;
			}
			break;
		case 3: // tz390.fp_eb_type
			switch (reg_type1) {
			case 0: // tz390.fp_db_type
				fp_reg_db[fp_ctl_index1] = fp_get_db_from_eb(reg_buff2, reg_buff_index2);
				fp_reg_ctl[fp_ctl_index1] = fp_ctl_db;
				return;
			case 1: // EB to DD  RPI-1013
				fp_reg_bd[fp_ctl_index1] = fp_get_bd_from_eb(reg_buff2, reg_buff_index2);
				fp_reg_ctl[fp_ctl_index1] = fp_ctl_bd1;
				return;
			case 2: //
				fp_reg_bd[fp_ctl_index1] = fp_get_bd_from_eb(reg_buff2, reg_buff_index2);
				fp_reg_ctl[fp_ctl_index1] = fp_ctl_bd1; // RPI-1003
				return;
			case 3: // tz390.fp_eb_type
				fp_reg_eb[fp_ctl_index1] = fp_get_eb_from_eb(reg_buff2, reg_buff_index2);
				fp_reg_ctl[fp_ctl_index1] = fp_ctl_eb;
				return;
			case 4: // EB to ED  RPI-1013
				fp_reg_bd[fp_ctl_index1] = fp_get_bd_from_eb(reg_buff2, reg_buff_index2);
				fp_reg_ctl[fp_ctl_index1] = fp_ctl_bd1;
				return;
			case 5: // tz390.fp_eh_type
				fp_reg_db[fp_ctl_index1] = fp_get_db_from_eb(reg_buff2, reg_buff_index2);
				fp_reg_ctl[fp_ctl_index1] = fp_ctl_db;
				return;
			case 6: // tz390.fp_lb_type
				fp_reg_bd[fp_ctl_index1] = fp_get_bd_from_eb(reg_buff2, reg_buff_index2);
				fp_reg_ctl[fp_ctl_index1] = fp_ctl_bd1;
				fp_reg_ctl[fp_ctl_index1+2] = fp_ctl_bd2; // RPI-1013
				return;
			case 7: // EB to LD  RPI-1013

				fp_reg_bd[fp_ctl_index1] = fp_get_bd_from_eb(reg_buff2, reg_buff_index2);
				fp_reg_ctl[fp_ctl_index1] = fp_ctl_bd1;
				fp_reg_ctl[fp_ctl_index1+2] = fp_ctl_bd2; // RPI-1013
				return;
			case 8: // tz390.fp_lh_type
				fp_reg_bd[fp_ctl_index1] = fp_get_bd_from_eb(reg_buff2, reg_buff_index2);
				fp_reg_ctl[fp_ctl_index1] = fp_ctl_bd1;
				fp_reg_ctl[fp_ctl_index1+2] = fp_ctl_bd2; // RPI-1013
				return;
			}
			break;
		case 4: // tz390.fp_ed_type
			switch (reg_type1) {
			case 0: // ED to DB  RPI-1013
				fp_reg_db[fp_ctl_index1] = fp_get_bd_from_ed(reg_buff2, reg_buff_index2).doubleValue();
				fp_reg_ctl[fp_ctl_index1] = fp_ctl_db;
				return;
			case 1: // to tz390.fp_dd_type
				fp_reg_bd[fp_ctl_index1] = fp_get_bd_from_ed(reg_buff2, reg_buff_index2);
				fp_reg_ctl[fp_ctl_index1] = fp_ctl_bd1;
				return;
			case 2: // ED to DH  RPI-1013
				fp_reg_bd[fp_ctl_index1] = fp_get_bd_from_ed(reg_buff2, reg_buff_index2);
				fp_reg_ctl[fp_ctl_index1] = fp_ctl_bd1;
				return;
			case 3: // ED to EB  RPI-1013
				fp_reg_eb[fp_ctl_index1] = fp_get_bd_from_ed(reg_buff2, reg_buff_index2).floatValue();
				fp_reg_ctl[fp_ctl_index1] = fp_ctl_eb;
				return;
			case 4: // ED to ED  RPI-1013
				fp_reg_bd[fp_ctl_index1] = fp_get_bd_from_ed(reg_buff2, reg_buff_index2);
				fp_reg_ctl[fp_ctl_index1] = fp_ctl_bd1;
				return;
			case 5: // ED to EH  RPI-1013
				fp_reg_db[fp_ctl_index1] = fp_get_bd_from_ed(reg_buff2, reg_buff_index2).doubleValue();
				fp_reg_ctl[fp_ctl_index1] = fp_ctl_db;
				return;
			case 6: // ED to LB  RPI-1013
				fp_reg_bd[fp_ctl_index1] = fp_get_bd_from_ed(reg_buff2, reg_buff_index2);
				fp_reg_ctl[fp_ctl_index1] = fp_ctl_bd1;
				fp_reg_ctl[fp_ctl_index1+2] = fp_ctl_bd2; // RPI-1003
				return;
			case 7: // tz390.fp_ld_type
				fp_reg_bd[fp_ctl_index1] = fp_get_bd_from_ed(reg_buff2, reg_buff_index2);
				fp_reg_ctl[fp_ctl_index1] = fp_ctl_bd1;
				fp_reg_ctl[fp_ctl_index1+2] = fp_ctl_bd2; // RPI-1013
				return;
			case 8: // ED to LH  RPI-1013
				fp_reg_bd[fp_ctl_index1] = fp_get_bd_from_ed(reg_buff2, reg_buff_index2);
				fp_reg_ctl[fp_ctl_index1] = fp_ctl_bd1;
				fp_reg_ctl[fp_ctl_index1+2] = fp_ctl_bd2; // RPI-1013
				return;
			}
			break;
		case 5: // tz390.fp_eh_type
			switch (reg_type1) {
			case 0: // tz390.fp_db_type
				fp_reg_db[fp_ctl_index1] = fp_get_db_from_eh(reg_buff2, reg_buff_index2);
				fp_reg_ctl[fp_ctl_index1] = fp_ctl_db;
				return;
			case 1: // EH to DD  RPI-1013
				fp_reg_bd[fp_ctl_index1] = fp_get_bd_from_eh(reg_buff2, reg_buff_index2);
				fp_reg_ctl[fp_ctl_index1] = fp_ctl_bd1;
				return;
			case 2: // tz390.fp_dh_type
				fp_reg_bd[fp_ctl_index1] = fp_get_bd_from_eh(reg_buff2, reg_buff_index2);
				fp_reg_ctl[fp_ctl_index1] = fp_ctl_bd1;
				return;
			case 3: // tz390.fp_eb_type
				fp_reg_eb[fp_ctl_index1] = (float) fp_get_db_from_eh(reg_buff2, reg_buff_index2);
				fp_reg_ctl[fp_ctl_index1] = fp_ctl_eb;
				return;
			case 4: // EH to ED  RPI-1013
				fp_reg_bd[fp_ctl_index1] = fp_get_bd_from_eh(reg_buff2, reg_buff_index2);
				fp_reg_ctl[fp_ctl_index1] = fp_ctl_bd1;
				return;
			case 5: // tz390.fp_eh_type
				fp_reg_bd[fp_ctl_index1] = fp_get_bd_from_eh(reg_buff2, reg_buff_index2);
				fp_reg_ctl[fp_ctl_index1] = fp_ctl_bd1; // RPI-1003
				return;
			case 6: // tz390.fp_lb_type
				fp_reg_bd[fp_ctl_index1] = fp_get_bd_from_eh(reg_buff2, reg_buff_index2);
				fp_reg_ctl[fp_ctl_index1] = fp_ctl_bd1;
				fp_reg_ctl[fp_ctl_index1+2] = fp_ctl_bd2; // RPI-1013
				return;
			case 7: // EH to LD  RPI-1013
				fp_reg_bd[fp_ctl_index1] = fp_get_bd_from_eh(reg_buff2, reg_buff_index2);
				fp_reg_ctl[fp_ctl_index1] = fp_ctl_bd1;
				fp_reg_ctl[fp_ctl_index1+2] = fp_ctl_bd2; // RPI-1013
				return;
			case 8: // tz390.fp_lh_type
				fp_reg_bd[fp_ctl_index1] = fp_get_bd_from_eh(reg_buff2, reg_buff_index2);
				fp_reg_ctl[fp_ctl_index1] = fp_ctl_bd1;
				fp_reg_ctl[fp_ctl_index1+2] = fp_ctl_bd2; // RPI-1013
				return;
			}
			break;
		case 6: // tz390.fp_lb_type
			switch (reg_type1) {
			case 0: // tz390.fp_db_type
				fp_reg_db[fp_ctl_index1] = fp_get_bd_from_lb(reg_buff2, reg_buff_index2).doubleValue();
				fp_reg_ctl[fp_ctl_index1] = fp_ctl_db;
				return;
			case 1: // LB to DD  RPI-1013
				fp_reg_bd[fp_ctl_index1] = fp_get_bd_from_lb(reg_buff2, reg_buff_index2);
				fp_reg_ctl[fp_ctl_index1] = fp_ctl_bd1;
				return;
			case 2: // tz390.fp_dh_type
				fp_reg_bd[fp_ctl_index1] = fp_get_bd_from_lb(reg_buff2, reg_buff_index2); // RPI-1003
				fp_reg_ctl[fp_ctl_index1] = fp_ctl_bd1;
				return;
			case 3: // tz390.fp_eb_type
				fp_reg_eb[fp_ctl_index1] = fp_get_bd_from_lb(reg_buff2, reg_buff_index2).floatValue();
				fp_reg_ctl[fp_ctl_index1] = fp_ctl_eb;
				return;
			case 4: // ED to ED  RPI-1013
				fp_reg_bd[fp_ctl_index1] = fp_get_bd_from_lb(reg_buff2, reg_buff_index2);
				fp_reg_ctl[fp_ctl_index1] = fp_ctl_bd1;
				return;
			case 5: // tz390.fp_eh_type
				fp_reg_db[fp_ctl_index1] = fp_get_bd_from_lb(reg_buff2, reg_buff_index2).doubleValue();
				fp_reg_ctl[fp_ctl_index1] = fp_ctl_db;
				return;
			case 6: // tz390.fp_lb_type
				fp_reg_bd[fp_ctl_index1] = fp_get_bd_from_lb(reg_buff2, reg_buff_index2);
				fp_reg_ctl[fp_ctl_index1] = fp_ctl_bd1;
				fp_reg_ctl[fp_ctl_index1+2] = fp_ctl_bd2; // RPI-1013
				return;
			case 7: // tz390.fp_ld-type  RPI-1013
				fp_reg_bd[fp_ctl_index1] = fp_get_bd_from_lb(reg_buff2, reg_buff_index2);
				fp_reg_ctl[fp_ctl_index1] = fp_ctl_bd1;
				fp_reg_ctl[fp_ctl_index1+2] = fp_ctl_bd2; // RPI-1013
				return;
			case 8: // tz390.fp_lh_type
				fp_reg_bd[fp_ctl_index1] = fp_get_bd_from_lb(reg_buff2, reg_buff_index2);
				fp_reg_ctl[fp_ctl_index1] = fp_ctl_bd1;
				fp_reg_ctl[fp_ctl_index1+2] = fp_ctl_bd2; // RPI-1013
				return;
			}
			break;
		case 7: // tz390.fp_ld_type
			switch (reg_type1) {
			case 0: // LD to DB  RPI-1013
				fp_reg_db[fp_ctl_index1] = fp_get_bd_from_ld(reg_buff2, reg_buff_index2).doubleValue();
				fp_reg_ctl[fp_ctl_index1] = fp_ctl_db;
				return;
			case 1: // to tz390.fp_dd_type
				fp_reg_bd[fp_ctl_index1] = fp_get_bd_from_ld(reg_buff2, reg_buff_index2);
				fp_reg_ctl[fp_ctl_index1] = fp_ctl_bd1;
				return;
			case 2: // LD to DH  RPI-1013
				fp_reg_bd[fp_ctl_index1] = fp_get_bd_from_ld(reg_buff2, reg_buff_index2);
				fp_reg_ctl[fp_ctl_index1] = fp_ctl_bd1;
				return;
			case 3: // LD to EB  RPI-1013
				fp_reg_eb[fp_ctl_index1] = fp_get_bd_from_ld(reg_buff2, reg_buff_index2).floatValue();
				fp_reg_ctl[fp_ctl_index1] = fp_ctl_eb;
				return;
			case 4: // tz390.fp_ed_type
				fp_reg_bd[fp_ctl_index1] = fp_get_bd_from_ld(reg_buff2, reg_buff_index2);
				fp_reg_ctl[fp_ctl_index1] = fp_ctl_bd1;
				return;
			case 5: // LD to EH  RPI-1013
				fp_reg_db[fp_ctl_index1] = fp_get_bd_from_ld(reg_buff2, reg_buff_index2).doubleValue();
				fp_reg_ctl[fp_ctl_index1] = fp_ctl_db;
				return;
			case 6: // LD to LB  RPI-1013
				fp_reg_bd[fp_ctl_index1] = fp_get_bd_from_ld(reg_buff2, reg_buff_index2);
				fp_reg_ctl[fp_ctl_index1] = fp_ctl_bd1;
				fp_reg_ctl[fp_ctl_index1+2] = fp_ctl_bd2; // RPI-1013
				return;
			case 7: // LD to LD  RPI-1013
				fp_reg_bd[fp_ctl_index1] = fp_get_bd_from_ld(reg_buff2, reg_buff_index2);
				fp_reg_ctl[fp_ctl_index1] = fp_ctl_bd1;
				fp_reg_ctl[fp_ctl_index1+2] = fp_ctl_bd2; // RPI-1013
				return;
			case 8: // LD to LH  RPI-1013
				fp_reg_bd[fp_ctl_index1] = fp_get_bd_from_ld(reg_buff2, reg_buff_index2);
				fp_reg_ctl[fp_ctl_index1] = fp_ctl_bd1;
				fp_reg_ctl[fp_ctl_index1+2] = fp_ctl_bd2; // RPI-1013
				return;
			}
			break;
		case 8: // tz390.fp_lh_type
			switch (reg_type1) {
			case 0: // tz390.fp_db_type
				fp_reg_db[fp_ctl_index1] = fp_get_db_from_lh(reg_buff2, reg_buff_index2);
				fp_reg_ctl[fp_ctl_index1] = fp_ctl_db;
				return;
			case 1: // LH to DD  RPI-1013
				fp_reg_bd[fp_ctl_index1] = fp_get_bd_from_lh(reg_buff2, reg_buff_index2);
				fp_reg_ctl[fp_ctl_index1] = fp_ctl_bd1;
				return;
			case 2: // tz390.fp_dh_type
				fp_reg_bd[fp_ctl_index1] = fp_get_bd_from_lh(reg_buff2, reg_buff_index2);
				fp_reg_ctl[fp_ctl_index1] = fp_ctl_bd1; // RPI-1003 was db
				return;
			case 3: // tz390.fp_eb_type
				fp_reg_eb[fp_ctl_index1] = (float) fp_get_db_from_lh(reg_buff2, reg_buff_index2);
				fp_reg_ctl[fp_ctl_index1] = fp_ctl_eb;
				return;
			case 4: // LH to ED  RPI-1013
				fp_reg_bd[fp_ctl_index1] = fp_get_bd_from_lh(reg_buff2, reg_buff_index2);
				fp_reg_ctl[fp_ctl_index1] = fp_ctl_bd1;
				return;
			case 5: // tz390.fp_eh_type
				fp_reg_db[fp_ctl_index1] = fp_get_db_from_lh(reg_buff2, reg_buff_index2);
				fp_reg_ctl[fp_ctl_index1] = fp_ctl_db;
				return;
			case 6: // tz390.fp_lb_type
				fp_reg_bd[fp_ctl_index1] = fp_get_bd_from_lh(reg_buff2, reg_buff_index2);
				fp_reg_ctl[fp_ctl_index1] = fp_ctl_bd1;
				fp_reg_ctl[fp_ctl_index1+2] = fp_ctl_bd2;  // RPI-768
				return;
			case 7: // LH to LD  RPI-1013
				fp_reg_bd[fp_ctl_index1] = fp_get_bd_from_lh(reg_buff2, reg_buff_index2);
				fp_reg_ctl[fp_ctl_index1] = fp_ctl_bd1;
				fp_reg_ctl[fp_ctl_index1+2] = fp_ctl_bd2;  // RPI-768
				return;
			case 8: // tz390.fp_lh_type
				fp_reg_bd[fp_ctl_index1] = fp_get_bd_from_lh(reg_buff2, reg_buff_index2);
				fp_reg_ctl[fp_ctl_index1] = fp_ctl_bd1;
				fp_reg_ctl[fp_ctl_index1+2] = fp_ctl_bd2;  // RPI-768
				return;
			}
			break;
		}
		set_psw_check(Constants.psw_pic_spec); // should not occur
	}

	/**
	 * Reset register and co-reg to specified type
	 *
	 * @param reg_ctl_index
	 * @param ctl_type
	 * @param reg_type
	 */
	private void fp_reset_reg(final int reg_ctl_index, final byte ctl_type, final byte reg_type)
	{
		if (fp_reg_ctl[reg_ctl_index] == fp_ctl_bd1
		 && fp_pair_type[fp_reg_type[reg_ctl_index]]) { // RPI-229
			fp_reg_ctl[reg_ctl_index + 2] = fp_ctl_ld; // cancel replaced bd
		} else if (fp_reg_ctl[reg_ctl_index] == fp_ctl_bd2
				&& fp_pair_type[fp_reg_type[reg_ctl_index]]) { // RPI-229
			fp_reg_ctl[reg_ctl_index - 2] = fp_ctl_ld; // cancel replaced bd
		}
		fp_reg_ctl[reg_ctl_index] = ctl_type;
		fp_reg_type[reg_ctl_index] = reg_type;
		if (ctl_type == fp_ctl_bd1
		 && fp_pair_type[reg_type]) {
			if (!fp_pair_valid[reg_ctl_index]) { // RPI-229
				set_psw_check(Constants.psw_pic_spec);
			}
			fp_reg_ctl[reg_ctl_index + 2] = fp_ctl_bd2; // RPI-229
			fp_reg_type[reg_ctl_index + 2] = reg_type; // RPI-229
		}
	}

	/**
	 * Store fp zero in tz390.fp_workreg.
	 */
	private void fp_store_work_zero()
	{
		tz390.fp_work_reg.putLong(0,0);
		tz390.fp_work_reg.putLong(8,0);
	}

	/**
	 * Convert co-reg back to fp_reg storage format for use by STE or STD.
	 * If byte buffer is not fp_reg, copy fp_reg to byte buffer if needed
	 * for use in non destructive trace out of regs.
	 *
	 * @param reg_buff
	 * @param reg_index
	 */
	public void fp_store_reg(final ByteBuffer reg_buff, final int reg_index)
	{
		final int fp_ctl_index = reg_index >> 3;
		switch (fp_reg_ctl[fp_ctl_index]) {
		case 0: // fp_ctl_ld
			if (reg_buff != fp_reg) {
				reg_buff.putLong(reg_index, fp_reg.getLong(reg_index));
			}
			break;
		case 1: // fp_ctl_eb
			reg_buff.putFloat(reg_index, fp_reg_eb[fp_ctl_index]);
			if (reg_buff == fp_reg) {  // RPI-767
				fp_reg_ctl[fp_ctl_index] = fp_ctl_ld;
			}
			break;
		case 2: // fp_ctl_db
			switch (fp_reg_type[fp_ctl_index]) {
			case 0: // tz390.fp_db_type
				reg_buff.putDouble(reg_index, fp_reg_db[fp_ctl_index]);
				break;
			case 5: // tz390.fp_eh_type
				reg_buff.putInt(reg_index, fp_db_to_eh(fp_reg_db[fp_ctl_index]));
				break;
			}
			if (reg_buff == fp_reg) {  // RPI-767
				fp_reg_ctl[fp_ctl_index] = fp_ctl_ld;
			}
			break;
		case 3: // fp_ctl_bd1
			switch (fp_reg_type[fp_ctl_index]) {
			case 1: // tz390.fp_dd_type
				fp_bd_to_wreg(tz390.fp_dd_type, fp_reg_bd[fp_ctl_index]);
				reg_buff.putLong(reg_index, tz390.fp_work_reg.getLong(0));
				if (reg_buff == fp_reg) {  // RPI-767
					fp_reg_ctl[fp_ctl_index] = fp_ctl_ld;
				}
				break;
			case 2: // tz390.fp_dh_type
				fp_bd_to_wreg(tz390.fp_dh_type, fp_reg_bd[fp_ctl_index]);
				reg_buff.putLong(reg_index, tz390.fp_work_reg.getLong(0));
				if (reg_buff == fp_reg) {  // RPI-767
					fp_reg_ctl[fp_ctl_index] = fp_ctl_ld;
				}
				break;
			case 4: // tz390.fp_ed_type
				fp_bd_to_wreg(tz390.fp_ed_type, fp_reg_bd[fp_ctl_index]);
				reg_buff.putInt(reg_index, tz390.fp_work_reg.getInt(0));
				if (reg_buff == fp_reg) {  // RPI-767
					fp_reg_ctl[fp_ctl_index] = fp_ctl_ld;
				}
				break;
			case 6: // tz390.fp_lb_type
				if (fp_reg_ctl[fp_ctl_index + 2] == fp_ctl_bd2) {
					fp_bd_to_wreg(tz390.fp_lb_type, fp_reg_bd[fp_ctl_index]);
					reg_buff.putLong(reg_index, tz390.fp_work_reg.getLong(0));
					reg_buff.putLong(reg_index+16, tz390.fp_work_reg.getLong(8));  // RPI-767
					if (reg_buff == fp_reg) {  // RPI-767
						fp_reg_ctl[fp_ctl_index] = fp_ctl_ld;
						fp_reg_ctl[fp_ctl_index+2] = fp_ctl_ld;
					}
				}
				break;
			case 7: // tz390.fp_ld_type
				if (fp_reg_ctl[fp_ctl_index + 2] == fp_ctl_bd2) {
					fp_bd_to_wreg(tz390.fp_ld_type, fp_reg_bd[fp_ctl_index]);
					reg_buff.putLong(reg_index, tz390.fp_work_reg.getLong(0));
					reg_buff.putLong(reg_index+16, tz390.fp_work_reg.getLong(8));  // RPI-767
					if (reg_buff == fp_reg) {  // RPI-767
						fp_reg_ctl[fp_ctl_index] = fp_ctl_ld;
						fp_reg_ctl[fp_ctl_index+2] = fp_ctl_ld;
					}
				}
				break;
			case 8: // tz390.fp_lh_type
				if (fp_reg_ctl[fp_ctl_index + 2] == fp_ctl_bd2) {
					fp_bd_to_wreg(tz390.fp_lh_type, fp_reg_bd[fp_ctl_index]);
					reg_buff.putLong(reg_index, tz390.fp_work_reg.getLong(0));
					reg_buff.putLong(reg_index+16, tz390.fp_work_reg.getLong(8));  // RPI-767
					if (reg_buff == fp_reg) {  // RPI-767
						fp_reg_ctl[fp_ctl_index] = fp_ctl_ld;
						fp_reg_ctl[fp_ctl_index+2] = fp_ctl_ld;
					}
				}
				break;
			}
			break;
		case 4: // fp_ctl_bd2
			switch (fp_reg_type[fp_ctl_index - 2]) { // RPI-229
			case 6: // tz390.fp_lb_type
				if (fp_reg_ctl[fp_ctl_index - 2] == fp_ctl_bd1) {
					fp_bd_to_wreg(tz390.fp_lb_type, fp_reg_bd[fp_ctl_index - 2]); // RPI-229
					reg_buff.putLong(reg_index, tz390.fp_work_reg.getLong(8));
					reg_buff.putLong(reg_index-16, tz390.fp_work_reg.getLong(0));  // RPI-767
					if (reg_buff == fp_reg) {  // RPI-767
						fp_reg_ctl[fp_ctl_index] = fp_ctl_ld;
						fp_reg_ctl[fp_ctl_index-2] = fp_ctl_ld;
					}
				}
				break;
			case 7: // tz390.fp_ld_type
				if (fp_reg_ctl[fp_ctl_index - 2] == fp_ctl_bd1) {
					fp_bd_to_wreg(tz390.fp_ld_type, fp_reg_bd[fp_ctl_index - 2]); // RPI-229
					reg_buff.putLong(reg_index, tz390.fp_work_reg.getLong(8));
					reg_buff.putLong(reg_index-16, tz390.fp_work_reg.getLong(0));  // RPI-767
					if (reg_buff == fp_reg) {  // RPI-767
						fp_reg_ctl[fp_ctl_index] = fp_ctl_ld;
						fp_reg_ctl[fp_ctl_index-2] = fp_ctl_ld;
					}
				}
				break;
			case 8: // tz390.fp_lh_type
				if (fp_reg_ctl[fp_ctl_index - 2] == fp_ctl_bd1) {
					fp_bd_to_wreg(tz390.fp_lh_type, fp_reg_bd[fp_ctl_index - 2]); // RPI-229
					reg_buff.putLong(reg_index, tz390.fp_work_reg.getLong(8));
					reg_buff.putLong(reg_index-16, tz390.fp_work_reg.getLong(0));  // RPI-767
					if (reg_buff == fp_reg) {  // RPI-767
						fp_reg_ctl[fp_ctl_index] = fp_ctl_ld;
						fp_reg_ctl[fp_ctl_index-2] = fp_ctl_ld;
					}
				}
				break;
			}
			break;
		}
	}

	/**
	 * Convert ED format to big decimal.
	 *
	 * @param fp_buff
	 * @param fp_index
	 * @return
	 */
	private BigDecimal fp_ed_to_bd(final ByteBuffer fp_buff, final int fp_index)
	{
		final int ed1 = fp_buff.getInt(fp_index);
		if (ed1 == 0) {
			return BigDecimal.ZERO;
		}
		final int cf5   = (ed1 >> 26) & 0x1f;
		final int bxcf6 = (ed1 >> 20) & 0x3f;
		final int exp   = ((tz390.dfp_cf5_to_exp2[cf5] << 6) + bxcf6)
						- tz390.fp_exp_bias[tz390.fp_ed_type];
		int digits = (int) (tz390.dfp_dpd_to_bcd[ed1 & 0x3ff] + 1000 * (tz390.dfp_dpd_to_bcd[(ed1 >>> 10) & 0x3ff] + 1000 * tz390.dfp_cf5_to_bcd[cf5]));
		if (ed1 < 0) {
			digits = -digits;
		}
		return BigDecimal.valueOf((long) digits).scaleByPowerOfTen(exp);
	}

	/**
	 * Convert DD format to big decimal.
	 *
	 * @param fp_buff
	 * @param fp_index
	 * @return
	 */
	private BigDecimal fp_dd_to_bd(ByteBuffer fp_buff, int fp_index)
	{
		final long dd1 = fp_buff.getLong(fp_index);
		if (dd1 == 0) {
			return BigDecimal.ZERO;
		}
		final int cf5   = (int) (dd1 >>> 58) & 0x1f;
		final int bxcf8 = (int) (dd1 >>> 50) & 0xff;
		final int exp2  = tz390.dfp_cf5_to_exp2[cf5];
		if (exp2 > 2) { // RPI-536
			fp_dxc = fp_dxc_oe; // NaN's and Infinity not supported
			set_psw_check(Constants.psw_pic_data);
			return BigDecimal.ZERO;
		}
		final int exp = ((exp2 << 8) | bxcf8) // or in 2 high bits of exp from cf5
						- tz390.fp_exp_bias[tz390.fp_dd_type]; // adjust exp by bias
		long digits = tz390.dfp_dpd_to_bcd[(int) (dd1 & 0x3ff)]
					+ 1000 * (tz390.dfp_dpd_to_bcd[(int) ((dd1 >>> 10) & 0x3ff)]
					+ 1000 * (tz390.dfp_dpd_to_bcd[(int) ((dd1 >>> 20) & 0x3ff)]
					+ 1000 * (tz390.dfp_dpd_to_bcd[(int) ((dd1 >>> 30) & 0x3ff)]
					+ 1000 * (tz390.dfp_dpd_to_bcd[(int) ((dd1 >>> 40) & 0x3ff)]
					+ 1000 * (tz390.dfp_cf5_to_bcd[cf5])))));
		if (dd1 < 0) {
			digits = -digits;
		}
		return BigDecimal.valueOf(digits).scaleByPowerOfTen(exp);
	}

	/**
	 * Convert LD format to big decimal.
	 *
	 * @param fp_buff
	 * @param fp_index
	 * @return
	 */
	private BigDecimal fp_ld_to_bd(final ByteBuffer fp_buff, final int fp_index)
	{
		final long ld1 = fp_buff.getLong(fp_index);
		long ld2 = 0;
		if (fp_buff == fp_reg) {
			if (!fp_pair_valid[fp_index >>> 3]) { // RPI-518
				set_psw_check(Constants.psw_pic_spec);
				return BigDecimal.ZERO;
			}
			ld2 = fp_reg.getLong(fp_index + 16);
		} else {
			ld2 = fp_buff.getLong(fp_index + 8);
		}
		if (ld1 == 0 && ld2 == 0) {
			return BigDecimal.ZERO;
		}
		final int cf5 = (int) (ld1 >> 58) & 0x1f;
		final int bxcf12 = (int) (ld1 >> 46) & 0xfff;
		final int exp = ((tz390.dfp_cf5_to_exp2[cf5] << 12) + bxcf12)
						- tz390.fp_exp_bias[tz390.fp_ld_type];
		final long digits1 = tz390.dfp_dpd_to_bcd[(int) (((ld1 & 0x3f) << 4) | (ld2 >>> 60))]
				+ 1000 * (tz390.dfp_dpd_to_bcd[(int) ((ld1 >>>  6) & 0x3ff)]
				+ 1000 * (tz390.dfp_dpd_to_bcd[(int) ((ld1 >>> 16) & 0x3ff)]
				+ 1000 * (tz390.dfp_dpd_to_bcd[(int) ((ld1 >>> 26) & 0x3ff)]
				+ 1000 * (tz390.dfp_dpd_to_bcd[(int) ((ld1 >>> 36) & 0x3ff)]
				+ 1000 * tz390.dfp_cf5_to_bcd[cf5]   // RPI-518
						))));
		final long digits2 = tz390.dfp_dpd_to_bcd[(int) (ld2 & 0x3ff)]
				+ 1000 * (tz390.dfp_dpd_to_bcd[(int) ((ld2 >>> 10) & 0x3ff)]
				+ 1000 * (tz390.dfp_dpd_to_bcd[(int) ((ld2 >>> 20) & 0x3ff)]
				+ 1000 * (tz390.dfp_dpd_to_bcd[(int) ((ld2 >>> 30) & 0x3ff)]
				+ 1000 * (tz390.dfp_dpd_to_bcd[(int) ((ld2 >>> 40) & 0x3ff)]
				+ 1000 * (tz390.dfp_dpd_to_bcd[(int) ((ld2 >>> 50) & 0x3ff)]
						)))));
		if (ld1 < 0) {
			return BigDecimal.valueOf(digits1).scaleByPowerOfTen(18).add(
					BigDecimal.valueOf(digits2)).scaleByPowerOfTen(exp)
					.negate();
		} else {
			return BigDecimal.valueOf(digits1).scaleByPowerOfTen(18).add(
					BigDecimal.valueOf(digits2)).scaleByPowerOfTen(exp);
		}
	}

	/**
	 * Convert EH format to double.
	 *
	 * @param eh1
	 * @return
	 */
	private double fp_eh_reg_to_db(final int eh1)
	{
		if (eh1 < 0) {
			long_sign = long_high_bit;
		} else {
			long_sign = 0;
		}
		long_exp = (long) ((((eh1 & int_eh_exp_bits) >>> 24) - 0x40) << 2) - 4;
		long_man = (long) (eh1 & int_eh_man_bits) << (52 - 24 + 4);
		if (long_man == 0) {
			return 0;
		}
		align_db_first_bit(); // RPI-820
		work_fp_reg.putLong(0, long_sign | ((long_exp + 0x3ff) << 52)
				| (long_man & long_db_man_bits));
		return work_fp_reg.getDouble(0);
	}

	/**
	 * Convert DH long hex format to BigDecimal in order to preserve 56 mantissa bits (double has 52).
	 *
	 * @param dh1
	 * @return
	 */
	private BigDecimal fp_dh_to_bd(final long dh1) // RPI-821
	{
		final int int_exp = (int) ((((dh1 & long_dh_exp_bits) >>> 56) - 0x40) << 2) - 56; // RPI-821
		long_man = dh1 & long_dh_man_bits;
		if (long_man == 0) {
			return BigDecimal.ZERO; // 821
		}
		if (dh1 > 0) {
			return new BigDecimal(long_man).multiply( // RPI-821
				BigDecimal.valueOf(2).pow(int_exp, fp_dhg_context), // RPI-821
				fp_dhg_context); // RPI-821
		} else {
			return new BigDecimal(long_man).multiply(
					BigDecimal.valueOf(2).pow(int_exp, fp_dhg_context),
					fp_dhg_context).negate(); // RPI-821
		}
	}

	/**
	 * Shift right or left to align unnormalized mantissa
	 * to db normalized format where first bit is assumed.
	 */
	private void align_db_first_bit()
	{
		if (long_man >= long_db_one_bit) { // RPI-820
			// shift right to align 1st bit
			fp_round = 0;
			while (long_man > long_db_one_bits) { // RPI-820 was _bits
				fp_round = (int) (long_man & 1);
				long_man = long_man >> 1;
				long_exp++;
				if (fp_round == 1 && long_man <= long_db_one_bit) {
					long_man++;
				}
			}
		} else { // RPI-820 add unnormalized input support
			// shift left to align 1st bit
			while (long_man < long_db_one_bit) {
				long_man = long_man << 1;
				long_exp--;
			}
		}
	}

	/**
	 * Convert db float to eh int.
	 *
	 * @param db1
	 * @return
	 */
	public int fp_db_to_eh(final double db1)
	{
		work_fp_reg.putDouble(0, db1);
		long_work = work_fp_reg.getLong(0);
		if (long_work == 0) {
			return int_eh_zero;
		}
		tz390.fp_exp = (int) ((long) (long_work & long_db_exp_bits) >>> 52) - 0x3ff - 4;
		int int_man = (int) (((long_work & long_db_man_bits) | long_db_one_bit) >>> (52 - 24 - 4));
		fp_round = 0;
		while ((tz390.fp_exp & 3) != 0  // RPI-821
				|| int_man > int_eh_man_bits ) {
			fp_round = int_man & 1;
			int_man = int_man >>> 1;
			tz390.fp_exp++;
			if (fp_round == 1
				&& (tz390.fp_exp & 3) == 0 // RPI-821
				&& int_man <= int_eh_man_bits) {
				int_man++;
			}
		}
		if (long_work < 0) {
			tz390.fp_sign = int_high_bit;
		} else {
			tz390.fp_sign = 0;
		}
		return tz390.fp_sign | (((tz390.fp_exp >> 2) + 0x40) << 24) | int_man;
	}

	/**
	 * Convert EH in fp_reg or mem to big_dec.
	 *
	 * @param eh1_buff
	 * @param eh1_index
	 * @return
	 */
	private BigDecimal fp_eh_to_bd(final ByteBuffer eh1_buff, final int eh1_index)
	{
		return new BigDecimal(fp_eh_reg_to_db(eh1_buff.getInt(eh1_index)),
				fp_eb_rnd_context[fp_bfp_rnd]);
	}

	/**
	 * Convert LH in fp_reg or mem to big_dec.
	 *
	 * @param lh1_buff
	 * @param lh1_index
	 * @return
	 */
	private BigDecimal fp_lh_to_bd(final ByteBuffer lh1_buff, final int lh1_index)
	{
		// First copy 112 bit mantissa into 15 byte array with leading 0 byte
		// and convert to bd1 big decimal with 128 bit precision.
		if (lh1_buff == fp_reg) { // RPI-229
			if (!fp_pair_valid[lh1_index >>> 3]) { // RPI-518
				set_psw_check(Constants.psw_pic_spec);
				return BigDecimal.ZERO;
			}
			lh1_buff.position(lh1_index + 1);
			lh1_buff.get(work_fp_bi1_bytes, 1, 7);
			lh1_buff.position(lh1_index + 17);
			lh1_buff.get(work_fp_bi1_bytes, 8, 7);
		} else {
			lh1_buff.position(lh1_index + 1);
			lh1_buff.get(work_fp_bi1_bytes, 1, 7);
			lh1_buff.position(lh1_index + 9);
			lh1_buff.get(work_fp_bi1_bytes, 8, 7);
		}
		work_fp_bi1_bytes[0] = 0;
		work_fp_bd1 = new BigDecimal(new BigInteger(1, work_fp_bi1_bytes), fp_lxg_context);  // RPI-821

		// If mantissa zero exit with big decimal zero
		if (work_fp_bd1.signum() == 0) {
			return work_fp_bd1;
		}

		// Get sign and exponent as integer.
		final int int_work = (int) lh1_buff.get(lh1_index);
		tz390.fp_exp = (((int_work & 0x7f) - 0x40) << 2) - 112;

		// Multiply big decimal by 2 ** exp
		work_fp_bd1 = work_fp_bd1.multiply(
				BigDecimal.valueOf(2).pow(tz390.fp_exp, fp_lxg_context), fp_lxg_context); // RPI-821

		// Return positive or negative big decimal value
		if (int_work >= 0) {
			return work_fp_bd1;
		} else {
			return work_fp_bd1.negate();
		}
	}

	/**
	 * Convert LB in fp_reg or mem to big_dec.
	 *
	 * @param lb1_buff
	 * @param lb1_index
	 * @return
	 */
	private BigDecimal fp_lb_to_bd(ByteBuffer lb1_buff, int lb1_index)
	{
		// First get sign bit and 15 bit exponent
		final int int_work = lb1_buff.getShort(lb1_index);

		// Next copy 112 bit mantissa into 15 byte array with leading 0 byte
		if (lb1_buff == fp_reg) { // RPI-229
			if (!fp_pair_valid[lb1_index >>> 3]) { // RPI-518
				set_psw_check(Constants.psw_pic_spec);
				return BigDecimal.ZERO;
			}
			lb1_buff.position(lb1_index + 2);
			lb1_buff.get(work_fp_bi1_bytes, 1, 6);
			lb1_buff.position(lb1_index + 16);
			lb1_buff.get(work_fp_bi1_bytes, 7, 8);
		} else {
			lb1_buff.position(lb1_index + 2);
			lb1_buff.get(work_fp_bi1_bytes, 1, 14);
		}

		// If zero exponent, check for plus or minus zero now to avoid exp mult and underflow calc
		if ((int_work & 0x7FFF) == 0) {
			work_fp_bi1_bytes[0] = 0;
			work_fp_bd1 = new BigDecimal(new BigInteger(1, work_fp_bi1_bytes));
			if (work_fp_bd1.signum() == 0) {
				if (int_work == 0) {
					return BigDecimal.ZERO;
				} else {
					return fp_lb_neg_zero;
				}
			}
		}

		// Convert to bd1 big decimal with assumed 1 bit plus 112 bits
		work_fp_bi1_bytes[0] = 1;
		work_fp_bd1 = new BigDecimal(new BigInteger(1, work_fp_bi1_bytes));

		// Get exponent as integer without bias
		tz390.fp_exp = (int_work & 0x7fff) - 0x3fff - 112;

		// Multiply big decimal by 2 ** exp
		work_fp_bd1 = work_fp_bd1.multiply(
				BigDecimal.valueOf(2).pow(tz390.fp_exp, fp_lxg_context),
				fp_lxg_context).round(fp_lxg_context); // RPI-821

		// Return positive or negative big decimal value
		if (int_work >= 0) {
			return work_fp_bd1;
		} else {
			return work_fp_bd1.negate();
		}
	}

	/**
	 * Store DD, DH, ED, LB, LD, LH  RPI-514, RPI-821 add DH
	 * format in 16 byte fp_work_reg from big decimal
	 *
	 * @param fp_type
	 * @param fp_bd
	 */
	public void fp_bd_to_wreg(int fp_type, BigDecimal fp_bd)
	{
		if (fp_bd.signum() > 0) {
			tz390.fp_sign = 0;
		} else if (fp_bd.signum() < 0) {
			tz390.fp_sign = tz390.fp_sign_bit[fp_type];
			fp_bd = fp_bd.abs();
		} else {
			fp_store_work_zero();
			return;
		}
		switch (fp_type) {
		case 1: // fp_dd_type
			fp_bd = fp_bd.round(fp_dd_rnd_context[fp_dfp_rnd]);
			if (!tz390.fp_get_dfp_bin(tz390.fp_dd_type, fp_bd)) { // RPI-786
				set_psw_check(Constants.psw_pic_fp_ovf);
				return;
			}
			break;
		case 2: // fp_dh_type  // RPI-821
			fp_bd_to_dh_wreg(fp_bd.round(fp_dh_context)); // RPI-821
			break;
		case 4: // fp_ed_type
			fp_bd = fp_bd.round(fp_ed_rnd_context[fp_dfp_rnd]);
			if (!tz390.fp_get_dfp_bin(tz390.fp_ed_type, fp_bd)) {  // RPI-786
				set_psw_check(Constants.psw_pic_fp_ovf);
				return;
			}
			break;
		case 6: // fp_lb_type
			fp_bd_to_lx_wreg(fp_type,fp_bd.round(fp_lb_rnd_context[fp_bfp_rnd])); // RPI-821
			break;
		case 7: // fp_ld_type
			fp_bd = fp_bd.round(fp_ld_rnd_context[fp_dfp_rnd]);
			if (!tz390.fp_get_dfp_bin(tz390.fp_ld_type, fp_bd)) { // RPI-786
				set_psw_check(Constants.psw_pic_fp_ovf);
			}
			break;
		case 8: // fp_lh_type
			fp_bd_to_lx_wreg(fp_type, fp_bd.round(fp_lh_context));  // RPI-821
			break;
		default:
			tz390.abort_case(); // RPI-849
		}
	}

	/**
	 * Convert fp_bd to dh format in work_reg binary format RPI-821
	 *
	 * @param fp_bd
	 */
	private void fp_bd_to_dh_wreg(BigDecimal fp_bd)
	{
		/***********************************************************************
		 * Calculate tz390.fp_exp and big_dec2 such that:
		 * big_dec1 = big_dec2 * 2 ** tz390.fp_exp
		 ***********************************************************************
		 *
		 * tz390.fp_exp = log(big_dec1) / log(2)
		 *
		 * Since the exponent of LH/LB values can exceed the range of double,
		 * the log of big_dec1 is calculated using equivalent form
		 * log(x*10*scale) = log(x_man) + scale * log(10)
		 *
		 * tz390.fp_exp must then be offset by the number of bits in the
		 * required mantissa in order to retain significant bits when big_dec2
		 * is converted to big_int format. The exponent is also reduced by 1 for
		 * assumed bit in binary formats plus 1 additional to insure rounding
		 * for irrational values is done by shifting right.
		 */
		fp_bd = fp_bd.stripTrailingZeros(); // RPI-821
		final int work_scale = -fp_bd.scale();
		final double work_man = fp_bd.multiply(
				BigDecimal.TEN.pow(-work_scale, fp_dhg_context), fp_dhg_context).doubleValue(); // RPI-821
		tz390.fp_exp = (int) ((Math.log(work_man) + ((double) work_scale * fp_log10)) / fp_log2)
				- tz390.fp_man_bits[tz390.fp_dh_type] - tz390.fp_one_bit_adj[tz390.fp_dh_type];
		/*
		 * Now calculate big_dec2 mantissa truncated integer tz390.fp_exp calculated
		 * above. This calculation may produce an irrational number with the
		 * precision specified due to base 10 to base 2 exponent conversion.
		 *
		 * Set context for DH
		 */
		fp_big_dec2 = fp_bd.multiply(BigDecimal.valueOf(2).pow(-tz390.fp_exp,
				fp_dhg_context), fp_dhg_context); // RPI-821

		// Retrieve fp_big_dec2 mantissa bits as big_int and adjust tz390.fp_exp by mantissa bits
		fp_big_int1 = fp_big_dec2.toBigInteger();
		tz390.fp_exp = tz390.fp_exp + tz390.fp_man_bits[tz390.fp_dh_type];
		/*
		 * Adjust mantissa and base 2 exponent to align for assumed 1 bit for
		 * IEEE binary or IBM base 16 hex exponent and return hex sign bit,
		 * exponent, and mantissa bytes
		 */
		fp_round = 0;
		while ((tz390.fp_exp & 0x3) != 0  // RPI-821
				|| fp_big_int1.compareTo(fp_big_int_dh_man_bits) > 0
				) {
			if (fp_big_int1.testBit(0)) {
				fp_round = 1;
			} else {
				fp_round = 0;
			}
			fp_big_int1 = fp_big_int1.shiftRight(1);
			tz390.fp_exp++;
			if (fp_round == 1
				&& (tz390.fp_exp & 0x3) == 0	// RPI-821
				&& fp_big_int1.compareTo(fp_big_int_dh_man_bits) <= 0
				) {
				fp_big_int1 = fp_big_int1.add(BigInteger.ONE);
			}
		}
		tz390.fp_exp = (tz390.fp_exp >> 2) + tz390.fp_exp_bias[tz390.fp_dh_type];
		if (tz390.fp_exp >= 0 && tz390.fp_exp <= tz390.fp_exp_max[tz390.fp_dh_type]) {
			tz390.fp_work_reg.put(0, (byte) (tz390.fp_sign | tz390.fp_exp));
			tz390.fp_work_reg.position(0 + 2);
			tz390.fp_work_reg.put(fp_big_int1.toByteArray());
			if (tz390.fp_work_reg.get(2) == 0) { // check 0 lead byte
				tz390.fp_work_reg.position(1);
				tz390.fp_work_reg.put(fp_big_int1.toByteArray());
			}
			tz390.fp_work_reg.putLong(0 + 1, tz390.fp_work_reg.getLong(0 + 2));
		} else {
			set_psw_check(Constants.psw_pic_fp_sig);
			fp_store_work_zero();
		}
	}

	/**
	 * Convert fp_bd to lh/lb format based ib fp_type in work_reg binary format.
	 *
	 * @param fp_type
	 * @param fp_bd
	 */
	private void fp_bd_to_lx_wreg(final int fp_type, final BigDecimal fp_bd)
	{
		/***********************************************************************
		 * Calculate tz390.fp_exp and big_dec2 such that:
		 * big_dec1 = big_dec2 * 2 ** tz390.fp_exp
		 * *********************************************************************
		 *
		 * tz390.fp_exp = log(big_dec1) / log(2)
		 *
		 * Since the exponent of LH/LB values can exceed the range of double,
		 * the log of big_dec1 is calculated using equivalent form
		 * log(x*10*scale) = log(x_man) + scale * log(10)
		 *
		 * tz390.fp_exp must then be offset by the number of bits in the
		 * required mantissa in order to retain significant bits when big_dec2
		 * is converted to big_int format. The exponent is also reduced by 1 for
		 * assumed bit in binary formats plus 1 additional to insure rounding
		 * for irrational values is done by shifting right.
		 */
		final int work_scale = -fp_bd.stripTrailingZeros().scale();
		final double work_man = fp_bd.multiply(BigDecimal.TEN.pow(-work_scale, fp_lxg_context),
										 fp_lxg_context).doubleValue();
		tz390.fp_exp = (int) ((Math.log(work_man) + ((double) work_scale * fp_log10)) / fp_log2)
				- tz390.fp_man_bits[fp_type] - tz390.fp_one_bit_adj[fp_type];

		// Now calculate big_dec2 mantissa truncated integer tz390.fp_exp calculated
		// above. This calculation may produce an irrational number with the
		// precision specified due to base 10 to base 2 exponent conversion.
		fp_big_dec2 = fp_bd.multiply(BigDecimal.valueOf(2).pow(-tz390.fp_exp, fp_lxg_context), fp_lxg_context); // RPI-821

		// Retrieve fp_big_dec2 mantissa bits as big_int and adjust tz390.fp_exp by mantissa bits
		fp_big_int1 = fp_big_dec2.toBigInteger();
		tz390.fp_exp = tz390.fp_exp + tz390.fp_man_bits[fp_type];

		// Adjust mantissa and base 2 exponent to align for assumed 1 bit for IEEE binary or
		// IBM base 16 hex exponent and return hex sign bit, exponent, and mantissa bytes.

		switch (fp_type) { // Generate byte array for fp type
		case 6: // tz390.fp_lb_type s1,e15,m112 with assumed 1
			fp_round = 0;
			while (fp_big_int1.compareTo(fp_big_int_one_bits) > 0) {
				if (fp_big_int1.testBit(0)) {
					fp_round = 1;
				} else {
					fp_round = 0;
				}
				fp_big_int1 = fp_big_int1.shiftRight(1);
				tz390.fp_exp++;
				if (fp_round == 1
						&& fp_big_int1.compareTo(fp_big_int_one_bits) <= 0) {
					fp_big_int1 = fp_big_int1.add(BigInteger.ONE);
				}
			}
			tz390.fp_exp = tz390.fp_exp + tz390.fp_exp_bias[fp_type];
			if (tz390.fp_exp >= 0 && tz390.fp_exp <= tz390.fp_exp_max[fp_type]) {
				tz390.fp_work_reg.position(0 + 1); // first byte value 0x01 replaced with exp
				tz390.fp_work_reg.put(fp_big_int1.toByteArray());
				tz390.fp_work_reg.putShort(0, (short) (tz390.fp_sign | tz390.fp_exp));
			} else {
				set_psw_check(Constants.psw_pic_fp_sig);
				fp_store_work_zero();
			}
			break;
		case 8: // tz390.fp_lh_type s1,e7,m112 with split hex
			fp_round = 0;
			while ((tz390.fp_exp & 0x3) != 0
					|| fp_big_int1.compareTo(fp_big_int_lx_man_bits) > 0
					) {
				if (fp_big_int1.testBit(0)) {
					fp_round = 1;
				} else {
					fp_round = 0;
				}
				fp_big_int1 = fp_big_int1.shiftRight(1);
				tz390.fp_exp++;
				if (fp_round == 1
					&&	(tz390.fp_exp & 0x3) == 0 // RPI-821
					&& fp_big_int1.compareTo(fp_big_int_lx_man_bits) <= 0) {
					fp_big_int1 = fp_big_int1.add(BigInteger.ONE);
				}
			}
			tz390.fp_exp = (tz390.fp_exp >> 2) + tz390.fp_exp_bias[fp_type];
			if (tz390.fp_exp >= 0 && tz390.fp_exp <= tz390.fp_exp_max[fp_type]) {
				fp_put_bi_to_lh_wreg();
			} else {
				set_psw_check(Constants.psw_pic_fp_sig);
				fp_store_work_zero();
			}
			break;
		default:
			tz390.abort_case(); // RPI-849
		}
	}

	/**
	 * Store tz390 fp_big_int1 with tz390.fp_exp and
	 * tz390.fp_sign high bit in tz390 fp_work_reg in LH format.
	 */
	private void fp_put_bi_to_lh_wreg()
	{
		tz390.fp_work_reg.put(0, (byte) (tz390.fp_sign | tz390.fp_exp));
		int bi_bytes = (fp_big_int1.bitLength()+7)/8;
		fp_store_work_zero();
		if (bi_bytes == 0) {
			return;
		}
		// put 128 bit man in last 14 bytes
		tz390.fp_work_reg.position(16-fp_big_int1.toByteArray().length);
		tz390.fp_work_reg.put(fp_big_int1.toByteArray());
		// put exp and first 7 bytes of main at 0
		tz390.fp_work_reg.put(0,(byte)(tz390.fp_sign | tz390.fp_exp));
		tz390.fp_work_reg.putLong(1, tz390.fp_work_reg.getLong(2));
		tz390.fp_work_reg.put(8, (byte)(tz390.fp_sign | ((tz390.fp_exp-14) & 0x7f))); // RPI-767
	}

	/**
	 * Execute ed or edmk with store into r1<br><br>
	 * Notes:
	 * <ol><li>mask must be EBCDIC in both modes.
	 *     <li>output will be translated to ASCII if ascii mode.</ol>
	 *
	 * @param edmk_store
	 */
	private void exec_ed_edmk(boolean edmk_store)
	{
		psw_cc = psw_cc_equal; // assume last field zero;
		byte target_byte = ' ';
		byte source_byte = ' ';
		int next_digit = 0;
		int source_sign = 0;
		byte fill_byte = (byte) (mem_byte[bd1_loc] & 0xff);
		boolean sig_digit = false;
		boolean left_digit = true;
		while (rflen > 0) {
			target_byte = mem_byte[bd1_loc];
			switch (target_byte) {
			case 0x21: // select significant digit
			case 0x20: // select digit
				if (left_digit) {
					source_byte = mem_byte[bd2_loc];
					next_digit = (source_byte & 0xf0) >> 4;
					bd2_loc++;
					source_sign = source_byte & 0xf;
					if (source_sign <= 9) {
						left_digit = false;
					}
				} else {
					left_digit = true;
					next_digit = source_byte & 0x0f;
				}
				if (!sig_digit && next_digit == 0) {
					mem_byte[bd1_loc] = fill_byte;
					if (target_byte == 0x21) { // RPI-43
						sig_digit = true;
					}
				} else {
					mem_byte[bd1_loc] = (byte) (next_digit | 0xf0);
					sig_digit = true;
					if (edmk_store) {
						edmk_store = false;
						reg.putInt(r1,(reg.getInt(r1) & psw_amode_high_bits) | bd1_loc);  // RPI-828
					}
					if (next_digit != 0) { // assume pos if not zero
						psw_cc = psw_cc_high;
					}
				}
				if (source_sign > 9) {
					if (source_sign == 0xc || source_sign >= 0xe) {
						sig_digit = false;
					} else if (psw_cc == psw_cc_high) {
						psw_cc = psw_cc_low;
					}
				}
				break;
			case 0x22: // field separator
				sig_digit = false;
				mem_byte[bd1_loc] = fill_byte;
				psw_cc = psw_cc_equal;
				break;
			default: // any other char in mask
				if (!sig_digit) {
					mem_byte[bd1_loc] = fill_byte;
				}
				break;
			}
			if (tz390.opt_ascii) {
				mem_byte[bd1_loc] = tz390.ebcdic_to_ascii[mem_byte[bd1_loc] & 0xff];
			}
			bd1_loc++;
			rflen--;
		}
	}

	/**
	 * Share code for EX and EXRL. RPI-817
	 *
	 * @param target_addr
	 */
	private void exec_ex(final int target_addr)
	{
		if (!ex_mode) {
			ex_psw_return = psw_loc;
			set_psw_loc(target_addr);
			ex_mode = true;
			ex_mod_byte = mem_byte[psw_loc + 1];
			if (rf1 != 0) {
				mem_byte[psw_loc + 1] = (byte) (ex_mod_byte | reg.get(rf1 + 7));
			}
		} else {
			set_psw_check(Constants.psw_pic_exec);
		}
	}

	/**
	 * Return true if OK else false. RPI-981
	 * Set pdf_is_big to true or false and set pdf_big_int1 and pdf_big_int2 or pdf_long1 and pdf_long2.
	 *
	 * @return
	 */
	public boolean get_pdf_ints() // RPI-981, RPI-1092
	{
		if (get_pd(mem,bd1_loc, rflen1)) { // RPI-305
			if (pdf_is_big) {
				pdf_big_int1 = pdf_big_int;
				if (get_pd(mem,bd2_loc, rflen2)) { // RPI-305
					if (pdf_is_big) {
						pdf_big_int2 = pdf_big_int;
					} else {
						pdf_is_big = true;
						pdf_big_int2 = BigInteger.valueOf(pdf_long);
					}
				} else {
					return false;
				}
			} else {
				pdf_long1 = pdf_long;
				if (get_pd(mem,bd2_loc, rflen2)) { // RPI-305
					if (pdf_is_big) {
						pdf_big_int2 = pdf_big_int;
						pdf_big_int1 = BigInteger.valueOf(pdf_long1);
					} else {
						pdf_long2 = pdf_long;
					}
				}
			}
		} else {
			return false;
		}
		return true;
	}

	/**
	 * Convert pd field to BigInt or Long in pdf_big_int or pdf_long.<br><br>
	 * Notes:
	 * <ol><li>Set true if OK.
	 *   <li>Set pd_cc to<br>
	 *       0 = ok<br>
	 *       1 = sign invalid<br>
	 *       2 = digit invalid
	 *   <li>Raise 0C7 if not TP opcode.
	 *   <li>If pdf_signed = false, return value including low order digit if OK.</ol>
	 *
	 * @param pd_buff
	 * @param pdf_loc
	 * @param pdf_len
	 * @return
	 */
	private boolean get_pd(final ByteBuffer pd_buff, final int pdf_loc, final int pdf_len)
	{
		pdf_is_big = false; // RPI-389
		pd_cc = psw_cc0;
		if (pdf_len <= 4) {
			pdf_str = Integer.toHexString(pd_buff.getInt(pdf_loc));
			pdf_zeros = 8 - pdf_str.length();
		} else if (pdf_len <= 8) {
			pdf_str = Long.toHexString(pd_buff.getLong(pdf_loc));
			pdf_zeros = 16 - pdf_str.length(); // RPI-389 was 16
		} else {
			pdf_str = Long.toHexString(pd_buff.getLong(pdf_loc));
			String last_half = Long.toHexString(pd_buff.getLong(pdf_loc + 8));
			pdf_str = pdf_str + ("0000000000000000" + last_half).substring(last_half.length());
			pdf_zeros = 32 - pdf_str.length();
		}
		pdf_str_len = 2 * pdf_len - 1 - pdf_zeros; // assume positive
		if (pdf_str_len < 0) {
			pdf_signed = true;
			pdf_str_len = 0; // RPI-109 catch 0 sign nibble
			pd_cc = psw_cc1;
			if (opcode1 != 0xeb || opcode2 != 0xc0) { // not TP
				fp_dxc = fp_dxc_dec;
				set_psw_check(Constants.psw_pic_data); // RPI-441
				return false; // RPI-305
			}
			return false; // RPI-305
		}
		if (pdf_signed) {
			pdf_sign = pdf_str.charAt(pdf_str_len);
			if (pdf_str_len == 0) {
				pdf_str = "0";
				pdf_str_len = 1;
			}
			switch (pdf_sign) {
			case '3': // ASCII plus
				pdf_str = pdf_str.substring(0, pdf_str_len);
				if (!tz390.opt_ascii) { // RPI-844
					pd_cc = psw_cc1;
					if (opcode1 != 0xeb || opcode2 != 0xc0) { // not TP
						fp_dxc = fp_dxc_dec;
						set_psw_check(Constants.psw_pic_data);
						return false; // RPI-305
					}
				}
				break;
			case 'a': // EBCDIC plus
			case 'c': // EBCDIC plus (default for P'..')
			case 'e': // EBCDIC plus
			case 'f': // EBCDIC plus (from PACK)
				pdf_str = pdf_str.substring(0, pdf_str_len);
				break;
			case 'b': // ASCII negative
			case 'd': // EBCDIC negative
				pdf_str = "-" + pdf_str.substring(0, pdf_str_len);
				break;
			default:
				pdf_str = pdf_str.substring(0, pdf_str_len);
				pd_cc = psw_cc1;
				if (opcode1 != 0xeb || opcode2 != 0xc0) { // not TP
					fp_dxc = fp_dxc_dec;
					set_psw_check(Constants.psw_pic_data);
					return false; // RPI-305
				}
				break;
			}
		} else {
			pdf_signed = true;
		}
		try {
			if (pdf_str.length() < 9) {  // RPI-389 <= 18 digits, RPI-781 <= 16 digits to allow carry w/o ovf
				pdf_long = Long.valueOf(pdf_str);
			} else {
				pdf_big_int = new BigInteger(pdf_str);
				pdf_is_big = true;
			}
		} catch (final Exception e) {
			if (pd_cc == psw_cc0) {
				pd_cc = psw_cc2; // digit error only
			} else {
				pd_cc = psw_cc3; // digit and sign errors
			}
			if (opcode1 != 0xeb || opcode2 != 0xc0) { // not TP
				fp_dxc = fp_dxc_dec;
				set_psw_check(Constants.psw_pic_data);
				return false; // RPI-305
			}
			return false; // RPI-781
		}
		return true;
	}

	/**
	 * If pdf_is_big store pdf_big_int value into pd field and set pd_cc
	 * else store pdf_long into pdf field and set pd_cc.<br><br>
	 *
	 * Notes:
	 * <ol><li>If pdf_signed is false store unsigned value with low order
	 *         digit in low nibble, and do not set psw_cc.
	 *     <li>If pdf_trunc, truncate to fit else raise pgm exception.</ol>
	 *
	 * @param pd_stor
	 * @param pdf_loc
	 * @param pdf_len
	 */
	private void put_pd(final byte[] pd_stor, final int pdf_loc, final int pdf_len)
	{
		final int save_psw_cc = psw_cc;
		if (pdf_is_big) {
			pdf_str = pdf_big_int.toString();
		} else {
			pdf_str = Long.valueOf(pdf_long).toString();
		}
		byte next_byte = 0xc;
		int end_index = 0;
		boolean left_digit = true;
		if (pdf_signed) {
			if (pdf_str.charAt(0) == '-') {
				next_byte = 0xd;
				pd_cc = psw_cc_low;
				end_index = 1;
			} else if (pdf_str.length() == 1 && pdf_str.charAt(0) == '0') {
				pd_cc = psw_cc_equal;
			} else {
				pd_cc = psw_cc_high;
			}
			if (pdf_trunc) {
				int skip = pdf_str.length()- pdf_len * 2 + 1;
				if (pd_cc == psw_cc_low) {
					skip--;  // RPI-811
				}
				if (skip > 0) {  // RPI-788
					pdf_str = pdf_str.substring(skip);
				}
			}
			pdf_trunc = false;
		} else {
			if (pdf_str.charAt(0) == '-') {
				pdf_str = pdf_str.substring(1);
			}
			if (pdf_trunc) {
				final int skip = pdf_str.length()- pdf_len * 2;
				if (skip > 0) { // RPI-788
					pdf_str = pdf_str.substring(skip);
				}
			}
			pdf_trunc  = false;
			left_digit = false;
		}
		int index = pdf_str.length() - 1;
		int pdf_index = pdf_loc + pdf_len - 1;
		while (index >= end_index && pdf_index >= pdf_loc) {
			if (left_digit) {
				pd_stor[pdf_index] = (byte) (next_byte | ((pdf_str.charAt(index) & 0xf) << 4));
				next_byte = 0;
				pdf_index--;
				left_digit = false;
			} else {
				next_byte = (byte) (pdf_str.charAt(index) & 0xf);
				left_digit = true;
			}
			index--;
		}
		while (pdf_index >= pdf_loc) {
			pd_stor[pdf_index] = next_byte;
			next_byte = 0;
			pdf_index--;
		}
		if (index >= end_index) {
			pd_cc = psw_cc3;
			set_psw_check(Constants.psw_pic_pd_ovf);
		}
		if (!pdf_signed) {
			psw_cc = save_psw_cc;
			pdf_signed = true;
		}
	}

	/**
	 * Restore ex target instruction 2nd byte
	 */
	private void ex_restore()
	{
		if (!trace_psw) {
			mem_byte[psw_loc + 1] = ex_mod_byte;
		}
	}

	/**
	 * Format bytes into hex string.
	 *
	 * @param bytes
	 * @param byte_start
	 * @param byte_length
	 * @param chunk
	 * @return
	 */
	public String bytes_to_hex(final ByteBuffer bytes, int byte_start, int byte_length, final int chunk)
	{
		if (byte_start < 0) {
			return "";
		}
		final StringBuffer hex = new StringBuffer(72);
		int index1 = 0;
		int hex_bytes = 0;
		byte_start = byte_start & psw_amode;
		if (byte_start + byte_length > bytes.capacity()) {
			byte_length = bytes.capacity() - byte_start;
		}
		while (index1 < byte_length) {
			int work_int = bytes.get(byte_start + index1) & 0xff;
			String temp_string = Integer.toHexString(work_int);
			if (temp_string.length() == 1) {
				hex.append("0" + temp_string);
			} else {
				hex.append(temp_string);
			}
			index1++;
			if (chunk > 0) {
				hex_bytes++;
				if (hex_bytes >= chunk && index1 < byte_length) {
					hex.append(" ");
					hex_bytes = 0;
				}
			}
		}
		if (hex.length() > 0) {
			return hex.toString().toUpperCase();
		} else {
			return "";
		}
	}

	/**
	 * Initialize tz390
	 *
	 * @param shared_tz390
	 * @param shared_sz390
	 */
	public void init_pz390(final tz390 shared_tz390, final sz390 shared_sz390)
	{
		tz390 = shared_tz390;
		sz390 = shared_sz390;
		if (!tz390.opt_init) { // RPI-827
			fill_reg_char = 0;
			fill_mem_char = 0;
		}
		init_gpr();
		init_ar();
		init_fpr();
		init_opcode_keys();
		init_mem();
		if (tz390.opt_ascii) {
			pdf_zone = 0x30; // Zone for UNPK
		}
	}

	/**
	 * Initialize gpr registers to x'F4'  RPI-819
	 */
	private void init_gpr()
	{
		Arrays.fill(reg_byte, 0, reg_byte.length, fill_reg_char);
	}

	/**
	 * Initialize ar registers to x'F4'  RPI-819
	 */
	private void init_ar() // RPI-1055
	{
		Arrays.fill(ar_reg_byte, 0, ar_reg_byte.length, fill_reg_char);
	}

	/**
	 * Initialize FPR registers to x'F5' RPI-819
	 * Initialize fp constants that use tz390 shared variables.
	 */
	private void init_fpr()
	{
		Arrays.fill(fp_reg_byte, 0, fp_reg_byte.length, fill_reg_char);

		fp_dh_context = new MathContext(17,RoundingMode.HALF_EVEN); // RPI-821 required for TESTFP1 high/low bit test
		fp_lh_context = new MathContext(34,RoundingMode.HALF_EVEN); // RPI-821 required for TESTFP1 high/low bit test
		fp_lxg_context = new MathContext(tz390.fp_precision[tz390.fp_lb_type],RoundingMode.HALF_EVEN); // RPI-843
		fp_dbg_context = new MathContext(tz390.fp_precision[tz390.fp_db_type],RoundingMode.HALF_EVEN); // RPI-843
		fp_dhg_context = new MathContext(tz390.fp_precision[tz390.fp_dh_type],RoundingMode.HALF_EVEN); // RPI-843 // RPI-821
	//	fp_ebg_context = new MathContext(tz390.fp_precision[tz390.fp_eb_type],RoundingMode.HALF_EVEN); // RPI-843 // JBA-unused
		fp_lh_min = new BigDecimal("5.41e-79",										fp_lxg_context);
		fp_lh_max = new BigDecimal("7.2e+75",										fp_lxg_context);
		fp_lb_min = new BigDecimal("3.3e-4932",										fp_lxg_context); // RPI-367 allow (MIN)
		fp_lb_neg_zero = new BigDecimal("-1e-6177",									fp_ld_rnd_context[fp_dfp_rnd]); // RPI-834 work-around for no BigDecimal -0.
		fp_lb_max = new BigDecimal("1.2e+4932",										fp_lxg_context);
		fp_dd_pos_max = new BigDecimal("9999999999999999e+369",						fp_dd_rnd_context[fp_dfp_rnd]);
		fp_dd_neg_max = new BigDecimal("-9999999999999999e+369",					fp_dd_rnd_context[fp_dfp_rnd]);
		fp_dd_pos_min = new BigDecimal("1e-398",									fp_dd_rnd_context[fp_dfp_rnd]);
		fp_dd_neg_min = new BigDecimal("-1e-398",									fp_dd_rnd_context[fp_dfp_rnd]);
		fp_ed_pos_max = new BigDecimal("9999999e+90",								fp_ed_rnd_context[fp_dfp_rnd]);
		fp_ed_neg_max = new BigDecimal("-9999999e+101",								fp_ed_rnd_context[fp_dfp_rnd]);
		fp_ed_pos_min = new BigDecimal("1e-101",									fp_ed_rnd_context[fp_dfp_rnd]);
		fp_ed_neg_min = new BigDecimal("-1e-101",									fp_ed_rnd_context[fp_dfp_rnd]);
		fp_ld_pos_max = new BigDecimal("9999999999999999999999999999999999e+6111",	fp_ld_rnd_context[fp_dfp_rnd]);
		fp_ld_neg_max = new BigDecimal("-999999999999999999999999999999999e+6176",	fp_ld_rnd_context[fp_dfp_rnd]);
		fp_ld_pos_min = new BigDecimal("1e-6176",									fp_ld_rnd_context[fp_dfp_rnd]);
		fp_ld_neg_min = new BigDecimal("-1e-6176",									fp_ld_rnd_context[fp_dfp_rnd]);
	}

	/**
	 * Add all opcodes to key index table for use by trace and test options.<br><br>
	 * Notes:
	 * <ol><li>Verify tz390 and ptz390 trace type tables match.
	 *     <li>Trace and test do lookup by hex for display.
	 *     <li>Test break on opcode does lookup by name to get hex code for break.
	 *     <li>op_type_index is used by test break on opcode to get opcode2 offset and mask.</ol>
	 */
	private void init_opcode_keys()
	{
		tz390.init_opcode_name_keys();
		if (OpCodes.op_code.length != OpTraceTypes.op_trace_type.length) {
			tz390.abort_error(22,"OpCode and OpTraceType tables out of sync "
				+ OpCodes.op_code.length + " vs " + OpTraceTypes.op_trace_type.length);
		}
		String hex_key = null;
		int index = 1;
		while (index < OpCodes.op_code.length) {
			// Add key by hex code
			hex_key = OpCodes.op_code[index];
			if (hex_key.length() == 3) {
				hex_key = hex_key.substring(0, 2) + "0" + hex_key.charAt(2);
				if (hex_key.charAt(1) == '7'
						&& (hex_key.charAt(0) == '4' || hex_key.charAt(0) == '0')) {
					hex_key = "BC=" + hex_key;
				}
			} else if (hex_key.length() == 4) {
				if (hex_key.substring(0, 3).equals("A74")) {
					hex_key = "BR=" + hex_key;
				} else if (hex_key.substring(0, 3).equals("C04")) {
					hex_key = "BL=" + hex_key; // RIP200
				}
			}
			if (tz390.find_key_index('H', hex_key) == -1) {
				if (!tz390.add_key_index(index)) {
					set_psw_check(Constants.psw_pic_operr);
				}
			} else {
				// dup_opcodes++; // JBA-unused
			}
			index++;
		}

		// Initialize opcode2_offsets and masks for each type.
		op_type_offset[ 1] = 1; // E    PR    oooo
		op_type_offset[ 7] = 1; // S    SSM   oooobddd
		op_type_offset[12] = 1; // RI   IIHH  ooroiiii
		op_type_offset[13] = 1; // BRE  BRC   oomoiiii
		op_type_offset[14] = 1; // RRE  MSR   oooo00rr
		op_type_offset[15] = 1; // RRF1 MAER  oooo1032
		op_type_offset[16] = 1; // RIL  BRCL  oomollllllll
		op_type_offset[18] = 5; // RXY  MLG   oorxbdddhhoo
		op_type_offset[19] = 1; // SSE  LASP  oooobdddbddd
		op_type_offset[20] = 5; // RSY  LMG   oorrbdddhhoo
		op_type_offset[21] = 5; // SIY  TMY   ooiibdddhhoo
		op_type_offset[22] = 5; // RSL  TP    oor0bddd00oo
		op_type_offset[23] = 5; // RIE  BRXLG oorriiii00oo
		op_type_offset[24] = 5; // RXE  ADB   oorxbddd00oo
		op_type_offset[25] = 5; // RXF  MAE   oorxbdddr0oo
		op_type_offset[30] = 1; // RRF3 DIEBR oooo3412
		op_type_offset[32] = 1; // SSF  MVCOS oor0bdddbddd
		op_type_offset[34] = 1; // RRF2 FIEBR ooooM012
		op_type_offset[35] = 1; // RRF4 CSDTR oooo0m12 RPI-407
		op_type_offset[36] = 1; // RRR  ADTR oooo3012
		op_type_offset[38] = 1; // RXSS ASSIST I/O E0X RPI-812
		op_type_offset[39] = 1; // RRF5 CRT  RPI-817
		op_type_offset[40] = 1; // RRF6 CRTE RPI-817
		op_type_offset[41] = 5; // RIE2 CIT  RPI-817
		op_type_offset[42] = 5; // RIE3 CITE RPI-817
		op_type_offset[43] = 5; // RIE4 CGIJ RPI-817
		op_type_offset[44] = 5; // RIE5 CGIJE RPI-817
		op_type_offset[45] = 5; // RRS1 CGRB  RPI-817
		op_type_offset[46] = 5; // RRS2 CGRBE RPI-817
		op_type_offset[47] = 5; // RRS3 CGIB  RPI-817
		op_type_offset[48] = 5; // RRS4 CGIBE RPI-817
		op_type_offset[49] = 5; // RIE6 CGRJ  RPI-817
		op_type_offset[50] = 5; // RIE7 CGRJE RPI-817
		op_type_offset[51] = 1; // SIL  MVHHI RPI-817
		op_type_offset[52] = 5; // RIE8 RNSBG RPI-81
		op_type_offset[53] = 1; // RFE  CDFBR?   RPI-1125
		op_type_offset[54] = 1; // RRF  CFEBR?   RPI-1125
		op_type_offset[55] = 1; // SSF  LDP/LDPR RPI-1125
		op_type_offset[56] = 5; // RSY  LOC/LOCG RPI-1125
		op_type_offset[57] = 5; // RIE  AHIK RPI-1125
		final int max_op_type_offset = 57; // RPI-1125

		op_type_mask[ 1] = 0xff; // E PR oooo
		op_type_mask[ 7] = 0xff; // S SSM oooobddd
		op_type_mask[12] = 0x0f; // RI IIHH ooroiiii
		op_type_mask[13] = 0xf0; // BRE BRC oomoiiii
		op_type_mask[14] = 0xff; // RRE MSR oooo00rr
		op_type_mask[15] = 0xff; // RRF1 MAER oooo1032
		op_type_mask[16] = 0x0f; // RIL BRCL oomollllllll
		op_type_mask[18] = 0xff; // RXY MLG oorxbdddhhoo
		op_type_mask[19] = 0xff; // SSE LASP oooobdddbddd
		op_type_mask[20] = 0xff; // RSY LMG oorrbdddhhoo
		op_type_mask[21] = 0xff; // SIY TMY ooiibdddhhoo
		op_type_mask[22] = 0xff; // RSL TP oor0bddd00oo
		op_type_mask[23] = 0xff; // RIE BRXLG oorriiii00oo
		op_type_mask[24] = 0xff; // RXE ADB oorxbddd00oo
		op_type_mask[25] = 0xff; // RXF MAE oorxbdddr0oo
		op_type_mask[30] = 0xff; // RRF3 DIER oooo3012
		op_type_mask[32] = 0x0f; // SSF MVCOS oor0bdddbddd
		op_type_mask[34] = 0xff; // RRF2 DIEBR oooo3012
		op_type_mask[35] = 0xff; // RRF4 CSDTR oooo0m12 RPI-407
		op_type_mask[36] = 0xff; // RRR ADTR oooo3012 RPI-407
		op_type_mask[37] = 0xff; // RX   XDECI ASSIST RPI-812
		op_type_mask[38] = 0xff; // RXSS XREAD ASSIST RPI-812
		op_type_mask[39] = 0xff; // RRF5 CGRT  RPI-817
		op_type_mask[40] = 0xff; // RRF6 CGRTE RPI-817 (AZ ONLY)
		op_type_mask[41] = 0xff; // RIE2 CGIT  RPI-817
		op_type_mask[42] = 0xff; // RIE3 CGITE RPI-817 (AZ ONLY)
		op_type_mask[43] = 0xff; // RIE4 CGIJ  RPI-817
		op_type_mask[44] = 0xff; // RIE5 CGIJE RPI-813 (AZ ONLY)
		op_type_mask[45] = 0xff; // RRS1 CGRB  RPI-817
		op_type_mask[46] = 0xff; // RRS2 CGRBE RPI-817 (AZ ONLY)
		op_type_mask[47] = 0xff; // RRS3 CGIB  RPI-817
		op_type_mask[48] = 0xff; // RRS4 CGIBE RPI-817 (AZ ONLY)
		op_type_mask[49] = 0xff; // RIE6 CGRJ  RPI-817
		op_type_mask[50] = 0xff; // RIE7 CGRJE RPI-817
		op_type_mask[51] = 0xff; // SIL  MVHHI RPI-817
		op_type_mask[52] = 0xff; // RIE8 RNSBG RPI-817
		op_type_mask[53] = 0xff; // RRE  CEFBR? RPI-1125
		op_type_mask[54] = 0x0f; // RRF2 FIEBR? RPI-1125
		op_type_mask[55] = 0xff; // SSF2 LDP/LDPR RPI-1125
		op_type_mask[56] = 0xff; // RSY2 LOC/LOCG RPI-1125
		op_type_mask[57] = 0xff; // RIE9 AHIK RPI-1125
		final int max_op_type_mask = 57; // RPI-1125

		// Initialize op2 offset and mask arrays indexed by op1-
		final int max_op_type_setup = 57; // RPI-1125

		// Add setup case for each new op type - see case 55 etc.
		if (max_op_type_setup != OpTypes.max_op_type_offset) {
			tz390.abort_error(22, "Max op type setup cases out of sync "
					+ OpTypes.max_op_type_offset + " vs " + max_op_type_setup);
		}
		if (max_op_type_offset != OpTypes.max_op_type_offset) {
			tz390.abort_error(22, "Max op type offset tables out of sync "
				+ OpTypes.max_op_type_offset + " vs " + max_op_type_offset);
		}
		if (max_op_type_mask != OpTypes.max_op_type_offset) {
			tz390.abort_error(22, "Max op type offset and max op type mask tables out of sync "
				+ OpTypes.max_op_type_offset + " vs " + max_op_type_mask);
		}
		index = 1; // skip 0 comment code entry
		while (index < OpCodes.op_code.length) {
			final int op1 = Integer.valueOf(OpCodes.op_code[index].substring(0, 2), 16).intValue();
			if (OpCodes.op_code[index].length() > 2) {
				opcode2_offset[op1] = op_type_offset[OpTypes.op_type[index]]; // RPI-92 // RPI-135
				opcode2_mask[  op1] = op_type_mask[  OpTypes.op_type[index]]; // RPI-92 // RPI-135
			}
			index++;
		}
		tz390.tot_key_search = 0; // reset after adding opcodes
		tz390.tot_key_comp = 0;
		tz390.max_key_comp = 0;
	}

	/**
	 * Allocate memory and initialize memory.
	 */
	private void init_mem() {
		/*
		 * Allocate memory and initialize as follows:
		 * 1. Set cvt pointer at 16
		 * 2. Set zcvt_ipl_pgm to name of opt_ipl pgm name if any to run via link svc 6.
		 * 3. Set zcvt_user_pgm to name of user initial program to run via link svc.
		 * 4. Set mem_fqe_ptr to point to free queue with all of available memory
		 *    for use by svc 4 getmain and svc 5 freemain.
		 *    a. MEM(MB) defaults to 1 MB but can be set to any value up to available
		 *       memory on machine.
		 *       See TEST\TESTMEM1 for test of ABOVE/BELOW GETMAIN using MEM(32) to
		 *       allocate 16MB below and 16 MB above.
		 *    b. If less than 16 MB allocated 31 bit fqe is set to 0 and RMODE31 requests
		 *       use memory below the line.
		 * 5. Add 8 bytes to physical mem_byte array allocated to allow get_pd to fetch
		 *    8 bytes from last byte in memory for 1-8 byte packed decimal field.
		 *
		 * Notes:
		 * The default J2RE maximum memory available is limited by default to small
		 * fraction of total memory to prevent stalling OS or other J2RE applications
		 * running. To override default set -Xmx option at startup of J2RE.
		 * For example, add -Xmx500000000 to z390.bat to allow allocating up to 500 MB
		 * but don't allocate all of it or other J2RE application such as IE may stall
		 * or abort.
		 */
		tot_mem = tz390.max_mem << 20; // Convert MB to Bytes.
		try {
			mem_byte = new byte[tot_mem + 8];
			mem = ByteBuffer.wrap(mem_byte, 0, tot_mem + 6);
			Arrays.fill(mem_byte, mem24_start, tot_mem, fill_mem_char); // RPI-866
		} catch (final Exception e) {
			set_psw_check(Constants.psw_pic_memerr);
		}
		// Initialize 24 bit free memory queue element
		dsa24_start = mem24_start;
		mem.position(dsa24_start);
		mem.putInt(0); // set 24 bit fqe next to 0
		if (tot_mem > mem24_line) {
			dsa24_end = mem24_line;
			mem.putInt(dsa24_end - dsa24_start); // Set 24 but fqe length.
		} else {
			dsa24_end = tot_mem;
			mem.putInt(dsa24_end - dsa24_start);
		}
		// Initialize 31 bit free memory queue element.
		if (tot_mem > mem24_line) {
			dsa31_start = mem24_line;
			mem.position(dsa31_start);
			mem.putInt(0); // set 31 bit fqe next = 0
			dsa31_end = tot_mem;
			mem.putInt(dsa31_end - dsa31_start); // set 31 bit fqe len
		}
		// Initialize cvt pointer in low memory psacvt x'10' and x'4c'
		mem.putInt(psa_cvt, cvt_start);
		mem.putInt(psa_cvt2, cvt_start);
		// Initialize cvt pointers to dsa fqe's for use by getmain and freemain svc handlers
		mem.position(zcvt_fqe24); // 24 bit fqe
		mem.putInt(dsa24_start);
		mem.position(zcvt_fqe31); // 31 bit fqe
		mem.putInt(dsa31_start);
		// Initialize cvt initial program load pgm name field
		sz390.put_ascii_string(tz390.opt_ipl,zcvt_ipl_pgm,8,' ');
		sz390.put_ascii_string(tz390.pgm_name,zcvt_user_pgm,8,' ');

		// Initialize zcvt_exec_parm from PARM(..) option Notes: 1. ez390 sets R1 to zcvt_exec_parm at start
		mem.position(zcvt_exec_parm);
		mem.putShort((short) tz390.opt_parm.length());
		int index = 0;
		while (index < tz390.opt_parm.length()) {
			if (tz390.opt_ascii) {
				mem.put((byte) tz390.opt_parm.charAt(index));
			} else {
				mem.put(tz390.ascii_to_ebcdic[tz390.opt_parm.charAt(index)]);
			}
			index++;
		}
		// Initialize svc 3 for return register r14
		mem.putShort(zcvt_exit, (short) 0x0a03); // svc 3
		// Initialize MVS CVT compatibility fields
		mem.put(cvt_dcb, (byte) 0x9b); // os flags RPI-228
		// Initialize VSE COMRG fields RPI-558
		sz390.put_ascii_string(tz390.cur_date(),zcvt_comrg_jobdate,8,' ');
		sz390.put_ascii_string(tz390.pgm_name,  zcvt_comrg_comname,8,' ');
	}

	/**
	 * Trace instruction based on opcode_type.
	 */
	private void trace_ins()
	{
		if (tz390.opt_regs) {  // RPI-819 Move from main instr. loop
			sz390.dump_gpr(-1);
		}

		final String trace_name = get_ins_name(psw_loc);
		String trace_parms = "";
		int    trace_type = 0;
		int    maxlen = 0;
		if (   tz390.op_code_index > 0
			&& tz390.op_code_index < OpTraceTypes.op_trace_type.length) {
			trace_type = OpTraceTypes.op_trace_type[tz390.op_code_index];
		}

		try {
		switch (trace_type) {
		case 10: // "E" 8 PR oooo
			break;
		case 20: // "RR" 60 LR oorr
			if (mf2 == 0 // RPI-1149
				&& (    opcode1 == 0x0D // BASR,BALR,BCTR,BCR
					|| (opcode1 >= 0x05
					    && opcode1 <= 0x07))) { // RPI-1149
				trace_parms = " R" + tz390.get_hex(mf1, 1)
							+ "="  + tz390.get_hex(reg.getInt(rf1 + 4), 8);
			} else {
				trace_parms = " R" + tz390.get_hex(mf1, 1)
							+ "="  + tz390.get_hex(reg.getInt(rf1 + 4), 8)
							+ " R" + tz390.get_hex(mf2, 1)
							+ "="  + tz390.get_hex(reg.getInt(rf2 + 4), 8);
			}
			break;
		case 21: // x20-3f HFP RR
			trace_parms =" F" + tz390.get_hex(mf1, 1)
						+ "=" + get_fp_long_hex(rf1) + " F" + tz390.get_hex(mf2, 1)
						+ "=" + get_fp_long_hex(rf2);
			break;
		case 22: // x0e, x0f clcl, mvcl
			trace_parms = " R" + tz390.get_hex(mf1, 1)
						+ "="  + tz390.get_hex(reg.getInt(rf1 + 4), 8)
						+ " R" + tz390.get_hex(mf1 + 1, 1)
						+ "="  + tz390.get_hex(reg.getInt(rf1 + 12), 8)
						+ " R" + tz390.get_hex(mf2, 1)
						+ "="  + tz390.get_hex(reg.getInt(rf2 + 4), 8)
						+ " R" + tz390.get_hex(mf2 + 1, 1)
						+ "="  + tz390.get_hex(reg.getInt(rf2 + 12), 8);
			break;
		case 23: // 1c,1d mr,dr
			trace_parms = " R" + tz390.get_hex(mf1, 1)
						+ "="  + tz390.get_hex(reg.getInt(rf1 + 4), 8)
						+ " R" + tz390.get_hex(mf1 + 1, 1)
						+ "="  + tz390.get_hex(reg.getInt(rf1 + 12), 8)
						+ " R" + tz390.get_hex(mf2, 1)
						+ "="  + tz390.get_hex(reg.getInt(rf2 + 4), 8);
			break;
		case 30:// "BRX" 16 BER oomr
			rv2 = reg.getInt(rf2 + 4);
			trace_parms = " R" + tz390.get_hex(mf2, 1) + "("
						+ tz390.get_hex(rv2, 8) + ")="
						+ get_ins_target(rv2 & psw_amode);
			break;
		case 40:// "I" 1 SVC 00ii
			trace_parms = " I1=" + tz390.get_hex(if1, 2)
						+ " " + trace_svc();
			break;
		case 50:// "RX" 52 L oorxbddd
			trace_parms = " R"   + tz390.get_hex(mf1, 1)
						+ "="    + tz390.get_hex(reg.getInt(rf1 + 4), 8)
						+ " S2(" + tz390.get_hex(xbd2_loc, 8)
						+ ")="   + bytes_to_hex(mem, xbd2_loc, 4, 0);
		    break;
		case 51: // 45 BAL
			trace_parms = " R"   + tz390.get_hex(mf1, 1)
						+ "="    + tz390.get_hex(reg.getInt(rf1 + 4), 8)
						+ " S2(" + tz390.get_hex(xbd2_loc, 8)
						+ ")="   + get_ins_target(xbd2_loc);
			break;
		case 52: // 41 LA
			trace_parms = " R"   + tz390.get_hex(mf1, 1)
						+ "="    + tz390.get_hex(reg.getInt(rf1 + 4), 8)
						+ " S2(" + tz390.get_hex(xbd2_loc & psw_amode, 8) + ")";
			break;
		case 53: // 40, 48-4c rx half word
			trace_parms =  " R"  + tz390.get_hex(mf1, 1)
						+ "="    + tz390.get_hex(reg.getInt(rf1 + 4), 8)
						+ " S2(" + tz390.get_hex(xbd2_loc & psw_amode, 8)
						+ ")="   + bytes_to_hex(mem, xbd2_loc, 2, 0);
			break;
		case 54: // 60-7f RX HFP LD
			trace_parms = " F" + tz390.get_hex(mf1, 1) + "="
						+ get_fp_long_hex(rf1) + " S2("
						+ tz390.get_hex(xbd2_loc, 8) + ")="
						+ get_long_hex(get_long_xbd2()); // RPI-588
			break;
		case 55: // 5c,5d MD,DD
			trace_parms = " R" + tz390.get_hex(mf1, 1) + "="
						+ tz390.get_hex(reg.getInt(rf1 + 4), 8) + " R"
						+ tz390.get_hex(mf1 + 1, 1) + "="
						+ tz390.get_hex(reg.getInt(rf1 + 12), 8) + " S2("
						+ tz390.get_hex(xbd2_loc, 8) + ")="
						+ bytes_to_hex(mem, xbd2_loc, 4, 0);
			break;
		case 56: // 42,43 IC,STC RPI-395
			trace_parms = " R" + tz390.get_hex(mf1, 1) + "="
						+ tz390.get_hex(reg.getInt(rf1 + 4), 8) + " S2("
						+ tz390.get_hex(xbd2_loc & psw_amode, 8) + ")="
						+ bytes_to_hex(mem, xbd2_loc, 1, 0);
			break;
		case 57:// "RX" CVD, CVB RPI-588
			trace_parms = " R" + tz390.get_hex(mf1, 1) + "="
					+ tz390.get_hex(reg.getInt(rf1 + 4),8) + " S2("
					+ tz390.get_hex(xbd2_loc, 8) + ")="
					+ get_long_hex(get_long_xbd2()); // RPI-588
			break;
		case 58: // 60-7f RX HFP LE
			trace_parms = " F" + tz390.get_hex(mf1, 1) + "="
						+ bytes_to_hex(fp_reg, rf1, 4, 0) + " S2("
						+ tz390.get_hex(xbd2_loc, 8) + ")="
						+ bytes_to_hex(mem, xbd2_loc, 4, 0); // RPI-834
			break;
		case 59: // 44 RX EX r1,S2 (2,4,6 bytes) // RPI-1035
			rflen2 = mem.get(xbd2_loc) & 0xff;
			String hex_ins = "";
			if (rflen2 < 0x40) {
				hex_ins = bytes_to_hex(mem, xbd2_loc, 2, 0);
			} else if (rflen2 < 0xc0) {
				hex_ins = bytes_to_hex(mem, xbd2_loc, 4, 0);
			} else {
				hex_ins = bytes_to_hex(mem, xbd2_loc, 6, 0);
			}
			trace_parms = " R" + tz390.get_hex(mf1, 1) + "=" // RPI-1103
						+ tz390.get_hex(reg.getInt(rf1 + 4), 8) + " S2(" // RPI-1103
						+ tz390.get_hex(xbd2_loc, 8) + ")="
						+ hex_ins; // RPI-1035
			break;
		case 60:// "BCX" 16 BE oomxbddd
			trace_parms = " S2(" + tz390.get_hex(xbd2_loc, 8)
						+ ")="   + get_ins_target(xbd2_loc);
			break;
		case 70:// "S" 43 SPM oo00bddd
			trace_parms = " S2(" + tz390.get_hex(bd2_loc, 8) + ")="
					+ bytes_to_hex(mem, bd2_loc, 8, 0);
			break;
		case 71:// "S"  SRNM, SRNMT oo00bddd
			trace_parms = " S2(" + tz390.get_hex(bd2_loc, 8) + ")";
			break;
		case 72:// "S" LFPC, STFPC, LFAS
			trace_parms = " S2(" + tz390.get_hex(bd2_loc, 8) + ")="
					+ bytes_to_hex(mem, bd2_loc, 4, 0);
			break;
		case 80:// "DM" 1 DIAGNOSE 83000000
			trace_parms = " DIAGNOSE";
			break;
		case 90:// "RSI" 4 BRXH oorriiii
			trace_parms = " R" + tz390.get_hex(mf1, 1) + "="
						+ tz390.get_hex(reg.getInt(rf1 + 4), 8) + " R"
						+ tz390.get_hex(mf3, 1) + "="
						+ tz390.get_hex(reg.getInt(rf3 + 4), 8) + " I2="
						+ tz390.get_hex(if2, 8);
			break;
		case 91: // 84-87 BXH, BXLE
			rf2 = psw_loc + 2 * if2;
			trace_parms = " R" + tz390.get_hex(mf1, 1) + "="
						+ tz390.get_hex(reg.getInt(rf1 + 4), 8) + " R"
						+ tz390.get_hex(mf3, 1) + "="
						+ tz390.get_hex(reg.getInt(rf3 + 4), 8) + " S2("
						+ tz390.get_hex(rf2, 8) + ")=" + get_ins_target(rf2);
			break;
		case 100:// "RS" 25 oorrbddd
			trace_parms = " R" + tz390.get_hex(mf1, 1) + "="
					+ tz390.get_hex(reg.getInt(rf1 + 4), 8) + " R"
					+ tz390.get_hex(mf3, 1) + "="
					+ tz390.get_hex(reg.getInt(rf3 + 4), 8) + " S2("
					+ tz390.get_hex(bd2_loc, 8) + ")="
					+ bytes_to_hex(mem, bd2_loc, 4, 0);
			break;
		case 101: //bd,be,bf CLM, STCM, ICM
			trace_parms = " R" + tz390.get_hex(mf1, 1) + "="
						+ tz390.get_hex(reg.getInt(rf1 + 4), 8) + " M3="
						+ tz390.get_hex(mf3, 1) + " S2("
						+ tz390.get_hex(bd2_loc, 8) + ")="
						+ bytes_to_hex(mem, bd2_loc, mask_bits[mf3], 0);
			break;
		case 102: // 88-8f RX SHIFT
			trace_parms = " R" + tz390.get_hex(mf1, 1) + "="
						+ tz390.get_hex(reg.getInt(rf1 + 4), 8) + " S2("
						+ tz390.get_hex(bd2_loc, 8) + ")";
			break;
		case 103: // BXH, BXLE
			trace_parms = " R" + tz390.get_hex(mf1, 1) + "="
						+ tz390.get_hex(reg.getInt(rf1 + 4), 8) + " R"
						+ tz390.get_hex(mf3, 1) + "="
						+ tz390.get_hex(reg.getInt(rf3 + 4), 8) + " S2("
						+ tz390.get_hex(bd2_loc, 8) + ")="
						+ get_ins_target(bd2_loc);
			break;
		case 104: // MVCLE, CLCLE  RPI-1112
			trace_parms = " R" + tz390.get_hex(mf1, 1) + "="
						+ tz390.get_hex(reg.getInt(rf1 + 4), 8)
						+ " R" + tz390.get_hex(mf1+1, 1) + "="
						+ tz390.get_hex(reg.getInt(rf1 + 12), 8)
						+ " R" + tz390.get_hex(mf3, 1) + "="
						+ tz390.get_hex(reg.getInt(rf3 + 4), 8)
						+ " R" + tz390.get_hex(mf3+1, 1) + "="
						+ tz390.get_hex(reg.getInt(rf3 + 12), 8)
						+ " PAD=" + tz390.get_hex(bd2_loc, 2);
			break;
		case 110:// "SI" 9 CLI ooiibddd
			trace_parms = " S2(" + tz390.get_hex(bd1_loc, 8) + ")="
						+ bytes_to_hex(mem, bd1_loc, 1, 0) + " I2="
						+ tz390.get_hex(if2, 2)
						+ "='" + tz390.ascii_printable_char(if2) + "'"; // RPI-947
			break;
		case 120:// "RI" 37 IIHH ooroiiii
			trace_parms = " R" + tz390.get_hex(mf1, 1) + "="
					+ get_long_hex(reg.getLong(rf1)) + " I2="
					+ tz390.get_hex(if2, 4);
			break;
		case 121: // a75-a77 BRAS, BRCT
			rf2 = psw_loc + 2 * if2;
			trace_parms = " R" + tz390.get_hex(mf1, 1) + "="
					+ tz390.get_hex(reg.getInt(rf1 + 4), 8) + " S2("
					+ tz390.get_hex(rf2, 8) + ")="
					+ get_ins_target(rf2);
			break;
		case 122: // a78, a7a, a7e LHI, AHI< MHI, CHI
			trace_parms = " R" + tz390.get_hex(mf1, 1) + "="
					+ tz390.get_hex(reg.getInt(rf1 + 4), 8) + " I2="
					+ tz390.get_hex(if2, 4);
			break;
		case 123: // a7? AGHI TMHI ETC.
			trace_parms = " R" + tz390.get_hex(mf1, 1) + "="
					+ get_long_hex(reg.getLong(rf1)) + " I2="
					+ tz390.get_hex(if2, 4);
		    break;
		case 130:// "BRC" 31 BRE oomoiiii
			rf2 = psw_loc + 2 * if2;
			trace_parms = " S2(" + tz390.get_hex(rf2, 8) + ")="
						+ get_ins_target(rf2);
			break;
		case 140:// "RRE" 185 MSR oooo00rr  R32,R32
			trace_parms = " R" + tz390.get_hex(mf1, 1) + "="
					+ tz390.get_hex(reg.getInt(rf1 + 4), 8)
					+ " R" 	+ tz390.get_hex(mf2, 1) + "="
					+ tz390.get_hex(reg.getInt(rf2 + 4), 8);
			break;
		case 141: // b3c4-b3c6  CEGR etc.F64,R64
			if (alt_rnd_mode != 0 || alt_fpe_mode != 0) { // RPI-1125 CEGBRA
				trace_parms = " F" + tz390.get_hex(mf1, 1)
							+ "="  + get_fp_long_hex(rf1) + " M3=" + tz390.get_hex(mf3, 1)
							+ " F" + tz390.get_hex(mf2, 1)
							+ "="  + get_long_hex(reg.getLong(rf2)) + " M4=" + tz390.get_hex(mf4, 1);
			} else {
				trace_parms = " F" + tz390.get_hex(mf1, 1)
							+ "="  + get_fp_long_hex(rf1)
							+ " R" + tz390.get_hex(mf2, 1)
							+ "="  + get_long_hex(reg.getLong(rf2));
			}
			break;
		case 142: // b3??,b22d,b244,b245 DXR, SQDR F64,F64
			if (alt_rnd_mode != 0 || alt_fpe_mode != 0) { // RPI-1125
				trace_parms = " F" + tz390.get_hex(mf1, 1)
							+ "="  + get_fp_long_hex(rf1) + " M3=" + tz390.get_hex(mf3, 1)
							+ " F" + tz390.get_hex(mf2, 1)
							+ "="  + get_fp_long_hex(rf2) + " M4=" + tz390.get_hex(mf4, 1);
			} else {
				trace_parms = " F" + tz390.get_hex(mf1, 1)
							+ "="  + get_fp_long_hex(rf1)
							+ " F" + tz390.get_hex(mf2, 1)
							+ "="  + get_fp_long_hex(rf2);
			}
			break;
		case 143: // b990-b993  R1,R1+1,R2,M
			trace_parms = " R" + tz390.get_hex(mf1, 1)
						+ "="  + tz390.get_hex(reg.getInt(rf1 + 4), 8)
						+ " R" + tz390.get_hex(mf1 + 1, 1)
						+ "="  + tz390.get_hex(reg.getInt(rf1 + 12), 8)
						+ " R" + tz390.get_hex(mf2, 1)
						+ "="  + tz390.get_hex(reg.getInt(rf2 + 4), 8)
						+ " M="+ tz390.get_hex(mem.get(psw_loc + 2) >> 4, 1);
			break;
		case 144: // b9??  LPGR etc.  R64,r64
			trace_parms = " R" + tz390.get_hex(mf1, 1)
						+ "="  + get_long_hex(reg.getLong(rf1))
						+ " R" + tz390.get_hex(mf2, 1)
						+ "="  + get_long_hex(reg.getLong(rf2));
			break;
		case 145: // LGDR etc.  R64,F64
			trace_parms = " R" + tz390.get_hex(mf1, 1)
						+ "="  + get_long_hex(reg.getLong(rf1))
						+ " F" + tz390.get_hex(mf2, 1)
						+ "="  + get_fp_long_hex(rf2);
			break;
		case 146: // b3b4-b3b6,CEFR etc.F64,R64
			if (alt_rnd_mode != 0 || alt_fpe_mode != 0) { // RPI-1125
				trace_parms = " F" + tz390.get_hex(mf1, 1)
							+ "="  + get_fp_long_hex(rf1) + " M3=" + tz390.get_hex(mf3, 1)
							+ " F" + tz390.get_hex(mf2, 1)
							+ "="  + tz390.get_hex(reg.getInt(rf2+4),8) + " M4=" + tz390.get_hex(mf4, 1);
			} else {
				trace_parms = " F" + tz390.get_hex(mf1, 1)
							+ "="  + get_fp_long_hex(rf1)
							+ " R" + tz390.get_hex(mf2, 1)
							+ "="  + tz390.get_hex(reg.getInt(rf2+4),8);
			}
			break;
		case 147: // b9A2 ptf R64 RPI-817
			trace_parms = " R" + tz390.get_hex(mf1, 1)
						+ "="  + get_fp_long_hex(rf1);
			break;
		case 148: // b9??  LGFR etc.  R64,R32  RPI-822
			trace_parms = " R" + tz390.get_hex(mf1, 1)
						+ "="  + get_long_hex(reg.getLong(rf1))
						+ " R" + tz390.get_hex(mf2, 1)
						+ "="  + tz390.get_hex(reg.getInt(rf2+4),8);
			break;
		case 149: // b9??  CPYA,EAR,SAR
			if (opcode2 == 0x4d) { // CPYA RPI-1055
				trace_parms = " AR" + tz390.get_hex(mf1, 1)
							+ "="   + tz390.get_hex(ar_reg.getInt(rf1 >> 1),8)
							+ " AR" + tz390.get_hex(mf2, 1)
							+ "="   + tz390.get_hex(ar_reg.getInt(rf2 >> 1),8);
			} else if (opcode2 == 0x4e) { // SAR RPI-1055
				trace_parms = " AR" + tz390.get_hex(mf1, 1)
							+ "="   + tz390.get_hex(ar_reg.getInt(rf1 >> 1),8)
							+ " R"  + tz390.get_hex(mf2, 1)
							+ "="   + tz390.get_hex(reg.getInt(rf2+4),8);
			} else if (opcode2 == 0x4f) { // EAR RPI-1055
				trace_parms = " R"  + tz390.get_hex(mf1, 1)
							+ "="   + tz390.get_hex(reg.getInt(rf1 + 4),8)
							+ " AR" + tz390.get_hex(mf2, 1)
							+ "="   + tz390.get_hex(ar_reg.getInt(rf2 >> 1),8);
			}
			break;
		case 150:// "RRF1" 28 MAER oooor0rr
			trace_parms = " F" + tz390.get_hex(mf1, 1) + "="
						+ get_fp_long_hex(rf1) + " F" + tz390.get_hex(mf3, 1) + "="
						+ get_fp_long_hex(rf3) + " F" + tz390.get_hex(mf2, 1) + "="
						+ get_fp_long_hex(rf2);
			break;
		case 151:// "RRF2" CGRT oooom0rr RPI-817
			trace_parms = " F" + tz390.get_hex(mf1, 1) + "="
						+ get_long_hex(reg.getLong(rf1)) + " F" + tz390.get_hex(mf2, 1) + "="
						+ get_long_hex(reg.getLong(rf2)) + " M3=" + tz390.get_hex(mf3, 1);
			break;
		case 152:// "RRF2" CRT oooom0rr RPI-817
			trace_parms = " F" + tz390.get_hex(mf1, 1) + "="
						+ tz390.get_hex(reg.getInt(rf1+4),8) + " F" + tz390.get_hex(mf2, 1) + "="
						+ tz390.get_hex(reg.getInt(rf2+4),8) + " M3=" + tz390.get_hex(mf3, 1);
			break;
		case 153:// "RRF5" 39 NGRK R1,R2,R3 oooor0rr
			trace_parms = " F" + tz390.get_hex(mf1, 1) + "="
						+ get_long_hex(rf1) + " F" + tz390.get_hex(mf2, 1) + "="
						+ get_long_hex(rf2) + " F" + tz390.get_hex(mf3, 1) + "="
						+ get_long_hex(rf3);
			break;
		case 154:// "RRF5" 39 NRK R1,R2,R3 oooor0rr
			trace_parms = " F" + tz390.get_hex(mf1, 1) + "="
						+ tz390.get_hex(rf1+4,8) + " F" + tz390.get_hex(mf2, 1) + "="
						+ tz390.get_hex(rf2+4,8) + " F" + tz390.get_hex(mf3, 1) + "="
						+ tz390.get_hex(rf3+4,8);
			break;
		case 160: // c2?? AGFI etc., C01 LGFI, C06 LXHI  RPI-200
			trace_parms = " R" + tz390.get_hex(mf1, 1) + "="
						+ get_long_hex(reg.getLong(rf1))
						+ " I2=" + tz390.get_hex(if2, 8);
			break;
		case 161: // c2?? MSFI RPI-817
			trace_parms = " R" + tz390.get_hex(mf1, 1) + "="
						+ tz390.get_hex(reg.getInt(rf1+4),8)
						+ " I2=" + tz390.get_hex(if2, 8);
			break;
		case 162: // C00 LARL
			trace_parms = " R" + tz390.get_hex(mf1, 1) + "="
						+ tz390.get_hex(reg.getInt(rf1 + 4), 8) + " S2("
						+ tz390.get_hex(bd2_loc & psw_amode, 8) + ")";
			break;
		case 163: // C05 BRASL
			trace_parms =" R" + tz390.get_hex(mf1, 1) + "="
						+ tz390.get_hex(reg.getInt(rf1 + 4), 8) + " S2("
						+ tz390.get_hex(bd2_loc, 8) + ")="
						+ get_ins_target(bd2_loc);
			break;
		case 164: // C42 LLHRL
			trace_parms =" R" + tz390.get_hex(mf1, 1) + "="
						+ tz390.get_hex(reg.getInt(rf1 + 4), 8) + " S2("
						+ tz390.get_hex(bd2_loc, 8) + ")="
						+ bytes_to_hex(mem, bd2_loc, 2, 0);
			break;
		case 165: // C48 LGRL
			trace_parms =" R" + tz390.get_hex(mf1, 1) + "="
						+ tz390.get_long_hex(reg.getLong(rf1), 16)
						+ " S2(" + tz390.get_hex(bd2_loc, 8)
						+ ")="   + bytes_to_hex(mem, bd2_loc, 8, 0);
			break;
		case 166: // C4C LGFRL
			trace_parms =" R" + tz390.get_hex(mf1, 1) + "="
						+ tz390.get_long_hex(reg.getLong(rf1), 16)
						+ " S2(" + tz390.get_hex(bd2_loc, 8)
						+ ")="   + bytes_to_hex(mem, bd2_loc, 4, 0);
			break;
		case 167: // C4D LRL
			trace_parms =" R" + tz390.get_hex(mf1, 1) + "="
						+ tz390.get_hex(reg.getInt(rf1+4), 8)
						+ " S2(" + tz390.get_hex(bd2_loc, 8)
						+ ")="   + bytes_to_hex(mem, bd2_loc, 4, 0);
			break;
		case 168: // C44 LGHRL
			trace_parms =" R" + tz390.get_hex(mf1, 1) + "="
						+ tz390.get_long_hex(reg.getLong(rf1), 16)
						+ " S2(" + tz390.get_hex(bd2_loc, 8)
						+ ")="   + bytes_to_hex(mem, bd2_loc, 2, 0);
			break;
		case 169: // C62 PFDRL
			trace_parms = " M" + tz390.get_hex(mf1, 1)
						+ " S2(" + tz390.get_hex(bd2_loc & psw_amode, 8) + ")";
			break;
		case 170:// "SS" 32 MVC oollbdddbddd
			maxlen = rflen;
			if (maxlen > 16) {
				maxlen = 16; // RPI-395
			}
			int mem_loc = bd2_loc;  // RPI-975
			if (bd2_loc > tot_mem-16) {
				mem_loc = 0;
			}
			trace_parms = " S1(" + tz390.get_hex(bd1_loc, 8) + ")="
						+ bytes_to_hex(mem, bd1_loc, maxlen, 0) + " S2("
						+ tz390.get_hex(bd2_loc, 8) + ")="
						+ bytes_to_hex(mem, bd2_loc, maxlen, 0)
						+ "='" + tz390.get_ascii_printable_string(mem_byte,mem_loc,maxlen) + "'"; // RPI-947
			break;
		case 171: // ASSIST RXSS I/O Instructions RPI-812
			maxlen = bd2_loc;
			if (maxlen <= 0 || maxlen > 8) {
				maxlen = 8; // RPI-395
			}
			trace_parms = " S1(X1)(" + tz390.get_hex(xbd1_loc, 8)
						+ ")="   + bytes_to_hex(mem, xbd1_loc, maxlen, 0)
						+ " S2(" + tz390.get_hex(bd2_loc, 8) + ")";
			break;
		case 180:// "RXY" LTG oorxbdddhhoo
			trace_parms = " R" + tz390.get_hex(mf1, 1) + "="
						+ get_long_hex(reg.getLong(rf1)) + " S2("
						+ tz390.get_hex(xbd2_loc, 8) + ")="
						+ get_long_hex(get_long_xbd2()); // RPI-588
			break;
		case 182: // e391 LLGH
			trace_parms = " R" + tz390.get_hex(mf1, 1) + "="
						+ get_long_hex(reg.getLong(rf1)) + " S2("
						+ tz390.get_hex(xbd2_loc, 8) + ")="
						+ bytes_to_hex(mem, xbd2_loc, 2, 0);
			break;
		case 183:// "RXY" 76 MLG oorxbdddhhoo
			trace_parms = " R" + tz390.get_hex(mf1, 1) + "="
						+ get_long_hex(reg.getLong(rf1))
						+ " R" + tz390.get_hex(mf1+1, 1) + "="
						+ get_long_hex(reg.getLong(rf1+8)) // RPI-544
						+ " S2("
						+ tz390.get_hex(xbd2_loc, 8) + ")="
						+ get_long_hex(get_long_xbd2()); // RPI-588
			break;
		case 184: // LLGF
			trace_parms = " R" + tz390.get_hex(mf1, 1) + "="
						+ get_long_hex(reg.getLong(rf1)) + " S2("
						+ tz390.get_hex(xbd2_loc, 8) + ")="
						+ bytes_to_hex(mem, xbd2_loc, 4, 0);
			break;
		case 185: // LLGB
			trace_parms = " R" + tz390.get_hex(mf1, 1) + "="
						+ get_long_hex(reg.getLong(rf1)) + " S2("
						+ tz390.get_hex(xbd2_loc, 8) + ")="
						+ bytes_to_hex(mem, xbd2_loc, 1, 0);
			break;
		case 186: // LLC
			trace_parms = " R"   + tz390.get_hex(mf1, 1)
						+ "="    + tz390.get_hex(reg.getInt(rf1+4),8)
						+ " S2(" + tz390.get_hex(xbd2_loc, 8)
						+ ")="	 + bytes_to_hex(mem, xbd2_loc, 1, 0);
			break;
		case 187: // SLB
			trace_parms = " R" + tz390.get_hex(mf1, 1) + "="
						+ tz390.get_hex(reg.getInt(rf1 + 4), 8) + " S2("
						+ tz390.get_hex(xbd2_loc, 8) + ")="
						+ bytes_to_hex(mem, xbd2_loc, 4, 0);
			break;
		case 188: // CVBG, CVDG RPI-588
			trace_parms = " R" + tz390.get_hex(mf1, 1) + "="
						+ get_long_hex(reg.getLong(rf1)) + " S2("
						+ tz390.get_hex(xbd2_loc, 8) + ")="
						+ bytes_to_hex(mem, xbd2_loc, 16, 0);
			break;
		case 189:// "RXY" LAY oorxbdddhhoo
			trace_parms = " R" + tz390.get_hex(mf1, 1) + "="
						+ get_long_hex(reg.getLong(rf1)) + " S2("
						+ tz390.get_hex(xbd2_loc, 8) + ")"; // RPI-738
			break;
		case 190:// "SSE" 5 LASP oooobdddbddd
			trace_parms = " S1(" + tz390.get_hex(bd1_loc, 8) + ")="
						+ bytes_to_hex(mem, bd1_loc, 4, 0) + " S2("
						+ tz390.get_hex(bd2_loc, 8) + ")="
						+ bytes_to_hex(mem, bd2_loc, 4, 0);
			break;
		case 200:// "RSY" 31 CSY  oorrbdddhhoo
			trace_parms = " R" + tz390.get_hex(mf1, 1) + "="
						+ tz390.get_hex(reg.getInt(rf1 + 4), 8) + " R"
						+ tz390.get_hex(mf3, 1) + "="
						+ tz390.get_hex(reg.getInt(rf3 + 4), 8) + " S2("
						+ tz390.get_hex(bd2_loc, 8) + ")="
						+ bytes_to_hex(mem, bd2_loc, 4, 0);
			break;
		case 201: // eb20, eb2c, eb80 CLMH, STCM, ICMH
			trace_parms = " R"   + tz390.get_hex(mf1, 1)
						+ "="    + get_long_hex(reg.getLong(rf1))
						+ " M3=" + tz390.get_hex(mf3, 1)
						+ " S2(" + tz390.get_hex(bd2_loc, 8)
						+ ")="   + bytes_to_hex(mem, bd2_loc, mask_bits[mf3], 0);
			break;
		case 202: // eb21, eb2d, eb81 CLMY, STCY, ICMY
			trace_parms = " R" + tz390.get_hex(mf1, 1) + "="
						+ tz390.get_hex(reg.getInt(rf1 + 4), 8) + " M3="
						+ tz390.get_hex(mf3, 1) + " S2("
						+ tz390.get_hex(bd2_loc, 8) + ")="
						+ bytes_to_hex(mem, bd2_loc, mask_bits[mf3], 0);
			break;
		case 203: // eb1c RLLG
			trace_parms =  " R" + tz390.get_hex(mf1, 1) + "="
						+ get_long_hex(reg.getLong(rf1)) + " R"
						+ tz390.get_hex(mf3, 1) + "="
						+ get_long_hex(reg.getLong(rf3)) + " S2("
						+ tz390.get_hex(bd2_loc, 8) + ")";
			break;
		case 204: // eb1d RLL
			trace_parms =  " R" + tz390.get_hex(mf1, 1) + "="
						+ tz390.get_hex(reg.getInt(rf1+4),8) + " R"
						+ tz390.get_hex(mf3, 1) + "="
						+ tz390.get_hex(reg.getInt(rf3+4),8) + " S2("
						+ tz390.get_hex(bd2_loc, 4) + ")"; // RPI-1125 WAS 8 VS 4
			break;
		case 205:// BXHG, BXLEG
			trace_parms = " R" + tz390.get_hex(mf1, 1) + "="
						+ get_long_hex(reg.getLong(rf1)) + " R"
						+ tz390.get_hex(mf3, 1) + "="
						+ get_long_hex(reg.getLong(rf3)) + " S2("
						+ tz390.get_hex(bd2_loc, 8) + ")="
						+ get_ins_target(bd2_loc);
			break;
		case 206:// "RSY" 31 LMG oorrbdddhhoo
			trace_parms = " R" + tz390.get_hex(mf1, 1) + "="
						+ get_long_hex(reg.getLong(rf1))
						+ " R" + tz390.get_hex(mf3, 1)
						+ "="  + get_long_hex(reg.getLong(rf3))
						+ " S2(" + tz390.get_hex(bd2_loc, 8)
						+ ")=" + bytes_to_hex(mem, bd2_loc, 8, 0);
			break;
		case 207: // EBE2 LOCG R1,S2,M3
			trace_parms = " R"   + tz390.get_hex(mf1, 1)
						+ "="    + get_long_hex(reg.getLong(rf1))
						+ " S2(" + tz390.get_hex(bd2_loc, 8)
						+ ")="   + bytes_to_hex(mem, bd2_loc, 8, 0)
						+ " M3=" + tz390.get_hex(mf3, 1);
			break;
		case 208://  "EBE4","LANG","RSY  "  20 RPI-1125 Z196
			trace_parms = " R" + tz390.get_hex(mf1, 1) + "="
						+ get_long_hex(reg.getLong(rf1)) + " R"
						+ tz390.get_hex(mf3, 1) + "="
						+ get_long_hex(reg.getLong(rf3))
						+ " S2("
						+ tz390.get_hex(bd2_loc, 8) + ")="
						+ bytes_to_hex(mem, bd2_loc, 8, 0);
			break;
		case 209: //  "EBF2","LOC","RSY2 "   20 RPI-1125 Z196
			trace_parms = " R" + tz390.get_hex(mf1, 1) + "="
						+ tz390.get_hex(reg.getInt(rf1 + 4), 8)
						+ " S2("
						+ tz390.get_hex(bd2_loc, 8) + ")="
						+ bytes_to_hex(mem, bd2_loc, 4, 0)
						+ " M3=" + tz390.get_hex(mf3, 1);
		case 210:// "SIY" 6 TMY ooiibdddhhoo
			trace_parms = " S2(" + tz390.get_hex(bd1_loc, 8) + ")="
						+ bytes_to_hex(mem, bd1_loc, 1, 0) + " I2="
						+ tz390.get_hex(if2, 2);
			break;
		case 211:// "SIY" ASI ooiibdddhhoo
			trace_parms = " S2(" + tz390.get_hex(bd1_loc, 8) + ")="
						+ bytes_to_hex(mem, bd1_loc, 4, 0) + " I2="
						+ tz390.get_hex(if2, 2);
			break;
		case 212:// "SIY" AGSI ooiibdddhhoo
			trace_parms = " S2(" + tz390.get_hex(bd1_loc, 8) + ")="
						+ bytes_to_hex(mem, bd1_loc, 8, 0) + " I2="
						+ tz390.get_hex(if2, 2);
			break;
		case 220:// "RSL" 1 TP oor0bddd00oo
			trace_parms = " S1(" + tz390.get_hex(bd1_loc, 8) + ")="
						+ bytes_to_hex(mem, bd1_loc, rflen1, 0);
			break;
		case 230:// "RIE" 4 BRXLG oorriiii00oo
			trace_parms = " R" + tz390.get_hex(mf1, 1) + "="
						+ tz390.get_hex(reg.getInt(rf1 + 4), 8) + " R3"
						+ tz390.get_hex(mf3, 1) + "="
						+ tz390.get_hex(reg.getInt(rf3 + 4), 8) + " I2="
						+ tz390.get_hex(if2, 8);
			break;
		case 231:// "RIE2" CIT oor0iiiim0oo  RPI-817
			trace_parms = " R" + tz390.get_hex(mf1, 1) + "="
						+ tz390.get_hex(reg.getInt(rf1 + 4), 8) + " I2="
						+ tz390.get_hex(if2, 4)
						+ " M3=" + tz390.get_hex(mf3, 1);
			break;
		case 232:// "RIE2" CGIT oor0iiiim0oo  RPI-817
			trace_parms = " R" + tz390.get_hex(mf1, 1) + "="
						+ tz390.get_long_hex(reg.getLong(rf1), 16) + " I2="
						+ tz390.get_hex(if2, 4)
						+ " M3=" + tz390.get_hex(mf3, 1);
			break;
		case 233:// "RIE4" CGIJ oorm444422oo  RPI-817
			trace_parms = " R" + tz390.get_hex(mf1, 1) + "="
						+ tz390.get_long_hex(reg.getLong(rf1), 16) + " I2="
						+ tz390.get_hex(if2, 2)
						+ " M3=" + tz390.get_hex(mf3, 1)
						+ " S4(" + tz390.get_hex(bd4_loc, 8)
						+ ")="   + get_ins_target(bd4_loc);
			break;
		case 234:// "RIE6" CGRB oorriiiim0oo
			trace_parms = " R" + tz390.get_hex(mf1, 1)
						+ "=" + tz390.get_long_hex(reg.getLong(rf1), 16)
						+ " R" + tz390.get_hex(mf2, 1) + "="
						+ tz390.get_long_hex(reg.getLong(rf2), 16)
						+ " M=" + tz390.get_hex(mf3,1)
						+ " S4(" + tz390.get_hex(bd4_loc,8)
						+ "=" + get_ins_target(bd4_loc);
			break;
		case 235:// "RIE6" CRB oorriiiim0oo
			trace_parms = " R" + tz390.get_hex(mf1, 1)
						+ "=" + tz390.get_hex(reg.getInt(rf1+4), 8)
						+ " R" + tz390.get_hex(mf2, 1) + "="
						+ tz390.get_hex(reg.getInt(rf2+4), 8)
						+ " M=" + tz390.get_hex(mf3,1)
						+ " S4(" + tz390.get_hex(bd4_loc,8)
						+ "=" + get_ins_target(bd4_loc);
			break;
		case 236:// "RIE4" CIJ oorm444422oo  RPI-817
			trace_parms = " R" + tz390.get_hex(mf1, 1)
						+ "=" + tz390.get_hex(reg.getInt(rf1+4), 8)
						+ " I2=" + tz390.get_hex(if2, 2)
						+ " M3=" + tz390.get_hex(mf3, 1)
						+ " S4(" + tz390.get_hex(bd4_loc, 8)
						+ ")="   + get_ins_target(bd4_loc);
			break;
		case 240:// "RXE" 28 ADB oorxbddd00oo
			trace_parms = " F" + tz390.get_hex(mf1, 1) + "="
						+ get_fp_long_hex(rf1) + " S2("
						+ tz390.get_hex(xbd2_loc, 8) + ")="
						+ get_long_hex(get_long_xbd2()); // RPI-588
			break;
		case 241:// "RXE" TDCET etc.
			trace_parms = " F" + tz390.get_hex(mf1, 1) + "="
						+ get_fp_long_hex(rf1) + " S2("
						+ tz390.get_hex(xbd2_loc, 8) + ")";
			break;
		case 250:// "RXF" 8 MAE oorxbdddr0oo (note r3 before r1)
			trace_parms =  " F" + tz390.get_hex(mf1, 1) + "="
					+ get_fp_long_hex(rf1) + " F" + tz390.get_hex(mf3, 1) + "="
					+ get_fp_long_hex(rf3) + " S2(" + tz390.get_hex(bd2_loc, 8)
					+ ")=" + bytes_to_hex(mem, bd2_loc, 4, 0);
			break;
		case 251:// SLDT shifts
			trace_parms =  " F"   + tz390.get_hex(mf1, 1)
						+ "="	  + get_fp_long_hex(rf1)
						+ " F"   + tz390.get_hex(mf3, 1)
						+ "="    + get_fp_long_hex(rf3)
						+ " S2(" + tz390.get_hex(xbd2_loc, 8) // RPI-1180
						+ ")";
			break;
		case 260:// AP SS2 oollbdddbddd
			int maxlen1 = rflen1;
			int maxlen2 = rflen2;
			if (maxlen1 > 16)
				maxlen1 = 16; // RPI-395
			if (maxlen2 > 16)
				maxlen2 = 16;
			trace_parms = " S1(" + tz390.get_hex(bd1_loc, 8) + ")="
					+ bytes_to_hex(mem, bd1_loc, maxlen1, 0) + " S2("
					+ tz390.get_hex(bd2_loc, 8) + ")="
					+ bytes_to_hex(mem, bd2_loc, maxlen2, 0);
			break;
		case 270:// PLO SS3 oorrbdddbddd r1,s2,r3,s4
			maxlen = rflen;
			if (maxlen > 16) {
				maxlen = 16; // RPI-395
			}
			trace_parms = " S1(" + tz390.get_hex(bd1_loc, 8) + ")="
					+ bytes_to_hex(mem, bd1_loc, maxlen, 0) + " S2("
					+ tz390.get_hex(bd2_loc, 8) + ")="
					+ bytes_to_hex(mem, bd2_loc, maxlen, 0);
			break;
		case 280:// LMD SS5 oorrbdddbddd r1,r3,s2,s4
			maxlen = rflen;
			if (maxlen > 16) {
				maxlen = 16; // RPI-395
			}
			trace_parms = " S1(" + tz390.get_hex(bd1_loc, 8) + ")="
					+ bytes_to_hex(mem, bd1_loc, maxlen, 0) + " S2("
					+ tz390.get_hex(bd2_loc, 8) + ")="
					+ bytes_to_hex(mem, bd2_loc, maxlen, 0);
			break;
		case 290:// SRP SS2 oolibdddbddd s1(l1),s2,i3
			maxlen = rflen1;
			if (maxlen > 16) {
				maxlen = 16; // RPI-395
			}
			trace_parms = " S1(" + tz390.get_hex(bd1_loc, 8) + ")="
					+ bytes_to_hex(mem, bd1_loc, maxlen, 0) + " S2("
					+ tz390.get_hex(bd2_loc, 8) + ")"
					+ " I3=" + tz390.get_hex(rflen2-1,1);
			break;
		case 300:// RPI-206 "RRF3" 30 DIEBR/DIDBR oooormrr (r1,r3,r2,m4 maps to oooo3412)
			trace_parms = " F" + tz390.get_hex(mf1, 1)
						+ "="  + get_fp_long_hex(rf1)
						+ " F" + tz390.get_hex(mf3, 1)
						+ "="  + get_fp_long_hex(rf3)
						+ " F" + tz390.get_hex(mf2, 1)
						+ "="  + get_fp_long_hex(rf2)
						+ " M4=" + tz390.get_hex(mf4, 1);
			break;
		case 301:// FIDTR, DIXTR (r1,m3,r2,m4 - oooo3412)
			trace_parms = " F" + tz390.get_hex(mf1, 1)
						+ "="  + get_fp_long_hex(rf1)
						+ " M3=" + tz390.get_hex(mf3, 1)
						+ " F" + tz390.get_hex(mf2, 1)
						+ "="  + get_fp_long_hex(rf2)
						+ " M4=" + tz390.get_hex(mf4, 1);
			break;
		case 302:// RRF3" RRDTR/RRXTR oooormrr (r1,r3,r2,m4 maps to
			// oooo3412)  RPI-798
			trace_parms = " F" + tz390.get_hex(mf1, 1)
						+ "="  + get_fp_long_hex(rf1)
						+ " F" + tz390.get_hex(mf3, 1)
						+ "="  + get_fp_long_hex(rf3)
						+ " R" + tz390.get_hex(mf2, 1)
						+ "="  + get_long_hex(reg.getLong(rf2)) // RPI-798
						+ " M4=" + tz390.get_hex(mf4, 1);
			break;
		case 303:// CLFEBR (r1,m3,r2,m4 - oooo3412)
			trace_parms = " R" + tz390.get_hex(mf1, 1)
						+ "="  + tz390.get_hex(reg.getInt(rf1+4),8)
						+ " M3=" + tz390.get_hex(mf3, 1)
						+ " F" + tz390.get_hex(mf2, 1)
						+ "="  + get_fp_long_hex(rf2)
						+ " M4=" + tz390.get_hex(mf4, 1);
			break;
		case 304:// CELGBR (r1,m3,r2,m4 - oooo3412)
			trace_parms = " F" + tz390.get_hex(mf1, 1)
						+ "="  + get_fp_long_hex(rf1)
						+ " M3=" + tz390.get_hex(mf3, 1)
						+ " R" + tz390.get_hex(mf2, 1)
						+ "="  + get_long_hex(reg.getLong(rf2))
						+ " M4=" + tz390.get_hex(mf4, 1);
			 break;
		case 305:// CLGDTR (r1,m3,r2,m4 - oooo3412) RPI-1125
			trace_parms = " R" + tz390.get_hex(mf1, 1)
						+ "="  + get_long_hex(reg.getLong(rf1))
						+ " M3=" + tz390.get_hex(mf3, 1)
						+ " F" + tz390.get_hex(mf2, 1)
						+ "="  + get_fp_long_hex(rf2)
						+ " M4=" + tz390.get_hex(mf4, 1);
			break;
		case 306:// CDFTR (r1,m3,r2,m4 - oooo3412) RPI-1125
			trace_parms = " F" + tz390.get_hex(mf1, 1)
						+ "="  + get_fp_long_hex(rf1)
						+ " M3=" + tz390.get_hex(mf3, 1)
						+ " R" + tz390.get_hex(mf2, 1)
						+ "="  + tz390.get_hex(reg.getInt(rf2+4),8)
						+ " M4=" + tz390.get_hex(mf4, 1);
			break;
		case 310: // "SS" PKA oollbdddbddd ll from S2
		case 320: // "SSF" MVCOS oor0bdddbddd (s1,s2,r3) z9-41
			maxlen = rflen;
			if (maxlen > 16) {
				maxlen = 16; // RPI-395
			}
			trace_parms = " S1(" + tz390.get_hex(bd1_loc, 8) + ")="
					+ bytes_to_hex(mem, bd1_loc, maxlen, 0) + " S2("
					+ tz390.get_hex(bd2_loc, 8) + ")="
					+ bytes_to_hex(mem, bd2_loc, maxlen, 0)
					+ " R" + tz390.get_hex(mf3,1)  // RPI-606
					+ "=" + tz390.get_hex(reg.getInt(rf3 + 4),8);
			break;
		case 321: // "SSF" LDP/LDPG oor0bdddbddd (r3,s1,s2) RPI-1125
			maxlen = rflen;
			if (maxlen > 16) {
				maxlen = 16; // RPI-395
			}
			trace_parms = " R" + tz390.get_hex(mf3,1)
					+ "=" + tz390.get_hex(reg.getInt(rf3 + 4),8)
					+ " S1(" + tz390.get_hex(bd1_loc, 8) + ")="
					+ bytes_to_hex(mem, bd1_loc, maxlen, 0) + " S2("
					+ tz390.get_hex(bd2_loc, 8) + ")="
					+ bytes_to_hex(mem, bd2_loc, maxlen, 0); // RPI-1125
			break;
		case 330: // "BLX" BRCL extended mnemonics
			trace_parms = " S2(" + tz390.get_hex(bd2_loc, 8) + ")="
						+ get_ins_target(bd2_loc);
			break;
		case 340: // RPI-206 "RRF2" FIEBRA (r1,m3,r2 maps to oooo3012)
			if (alt_fpe_mode != 0) { // RPI-1125
				trace_parms = " F" + tz390.get_hex(mf1, 1) + "="
							+ get_fp_long_hex(rf1) + " M3=" + tz390.get_hex(mf3, 1)
							+ " F" + tz390.get_hex(mf2, 1) + "="
							+ get_fp_long_hex(rf2) + " M4=" + tz390.get_hex(mf4, 1);
			} else {
				trace_parms = " F" + tz390.get_hex(mf1, 1) + "="
					+ get_fp_long_hex(rf1) + " M3=" + tz390.get_hex(mf3, 1)
					+ " F" + tz390.get_hex(mf2, 1) + "="
					+ get_fp_long_hex(rf2);
			}
			break;
		case 341: // b398-b39a,b3b8-b3ba  32 bit reg
			if (alt_fpe_mode != 0) { // RPI-1125
				trace_parms = " R" + tz390.get_hex(mf1, 1) + "="
				+ tz390.get_hex(reg.getInt(rf1 + 4), 8)
				+ " M3=" + tz390.get_hex(mf3, 1)
				+ " F" + tz390.get_hex(mf2, 1)
				+ "=" + get_fp_long_hex(rf2) + " M4=" + tz390.get_hex(mf4, 1);
			} else {
				trace_parms = " R" + tz390.get_hex(mf1, 1) + "="
						+ tz390.get_hex(reg.getInt(rf1 + 4), 8)
						+ " M3=" + tz390.get_hex(mf3, 1)
						+ " F" + tz390.get_hex(mf2, 1)
						+ "=" + get_fp_long_hex(rf2);
			}
			break;
		case 342: // b3a8-aa, b3c8-b3ca  64 bit reg
			if (alt_fpe_mode != 0) { // RPI-1125 CGEBRA
				trace_parms = " R" + tz390.get_hex(mf1, 1) + "="
				+ get_long_hex(reg.getLong(rf1))
				+ " M3=" + tz390.get_hex(mf3, 1)
				+ " F" + tz390.get_hex(mf2, 1)
				+ "=" + get_fp_long_hex(rf2) + " M4=" + tz390.get_hex(mf4, 1);
			} else {
				trace_parms = " R" + tz390.get_hex(mf1, 1) + "="
						+ get_long_hex(reg.getLong(rf1))
						+ " M3=" + tz390.get_hex(mf3, 1)
						+ " F" + tz390.get_hex(mf2, 1)
						+ "=" + get_fp_long_hex(rf2);
			}
			break;
		case 343: // b3f1-beff
			trace_parms = " F" + tz390.get_hex(mf1, 1) + "="
						+ get_fp_long_hex(rf1)
						+ " F" + tz390.get_hex(mf3, 1) + "="
						+ get_fp_long_hex(rf3)
						+ " R" + tz390.get_hex(mf2,1) + "="
						+ get_long_hex(reg.getLong(rf2)
								);
			break;
		case 350: // b3d4, b3dc  LDETR, LXDTR
			trace_parms = " F" + tz390.get_hex(mf1, 1) + "="
								+ get_fp_long_hex(rf1)
						+ " F" + tz390.get_hex(mf2, 1) + "=" + get_fp_long_hex(rf2)
						+ " M4=" + tz390.get_hex(mf4, 1);
			break;
		case 351: // b3e3, b3ed  CSDTR, CSXTR  RPI-798
			trace_parms = " R" + tz390.get_hex(mf1, 1) + "="
							   + get_long_hex(reg.getLong(rf1))   // RPI-798
						+ " F" + tz390.get_hex(mf2, 1) + "=" + get_fp_long_hex(rf2)
						+ " M4=" + tz390.get_hex(mf4, 1);
			break;
		case 360: // "RRR" "MDTR"
			if (alt_fpe_mode != 0) { // RPI-1125 MDTRA
				trace_parms = " F" + tz390.get_hex(mf1, 1) + "="
				+ get_fp_long_hex(rf1) + " F" + tz390.get_hex(mf2, 1) + "="
				+ get_fp_long_hex(rf2) + " F" + tz390.get_hex(mf3, 1) + "="
				+ get_fp_long_hex(rf3) + " M4=" + tz390.get_hex(mf4, 1);
			} else {
				trace_parms = " F" + tz390.get_hex(mf1, 1) + "="
					+ get_fp_long_hex(rf1) + " F" + tz390.get_hex(mf2, 1) + "="
					+ get_fp_long_hex(rf2) + " F" + tz390.get_hex(mf3, 1) + "="
					+ get_fp_long_hex(rf3);
			}
			break;
		case 370: // "RRS1" "CGRB" r1,r2,m3,s4 oorrbdddm0oo RPI-817
			trace_parms = " R" + tz390.get_hex(mf1, 1)
			+ "=" + tz390.get_long_hex(reg.getLong(rf1), 16)
			+ " R" + tz390.get_hex(mf2,1)
			+ "=" + tz390.get_long_hex(reg.getLong(rf2), 16)
			+ " M3=" + tz390.get_hex(mf3, 1)
			+ " S4(" + tz390.get_hex(bd4_loc, 8)
			+ ")="   + get_ins_target(bd4_loc);
			break;
		case 371: // "RRS1" "CRB" r1,r2,m3,s4 oorrbdddm0oo RPI-817
			trace_parms = " R" + tz390.get_hex(mf1, 1)
			+ "=" + tz390.get_hex(reg.getInt(rf1+4), 8)
			+ " R" + tz390.get_hex(mf2,1)
			+ "=" + tz390.get_hex(reg.getInt(rf2+4), 8)
			+ " M3=" + tz390.get_hex(mf3, 1)
			+ " S4(" + tz390.get_hex(bd4_loc, 8)
			+ ")="   + get_ins_target(bd4_loc);
			break;
		case 380: // "RRS3" "CGIB" r1,i2,m3,i4 oorm444422oo RPI-817
			trace_parms = " R" + tz390.get_hex(mf1, 1)
			+ "=" + tz390.get_long_hex(reg.getLong(rf1), 16)
			+ " I2=" + tz390.get_hex(if2, 2)
			+ " M3=" + tz390.get_hex(mf3, 1)
			+ " S4(" + tz390.get_hex(bd4_loc, 8)
			+ ")="   + get_ins_target(bd4_loc);
			break;
		case 381: // "RRS3" "CIB" r1,i2,m3,i4 oorm444422oo RPI-817
			trace_parms = " R" + tz390.get_hex(mf1, 1)
			+ "=" + tz390.get_hex(reg.getInt(rf1+4), 8)
			+ " I2=" + tz390.get_hex(if2, 2)
			+ " M3=" + tz390.get_hex(mf3, 1)
			+ " S4(" + tz390.get_hex(bd4_loc, 8)
			+ ")="   + get_ins_target(bd4_loc);
			break;
		case 390: // "SIL" "MVHHI" d1(b1),i2
			trace_parms = " S2(" + tz390.get_hex(bd1_loc, 8) + ")="
			+ bytes_to_hex(mem, bd1_loc, 2, 0) + " I2="
			+ tz390.get_hex(if2, 4);
			break;
		case 391: // "SIL" "MVGHI" d1(b1),i2
			trace_parms = " S2(" + tz390.get_hex(bd1_loc, 8) + ")="
			+ bytes_to_hex(mem, bd1_loc, 8, 0) + " I2="
			+ tz390.get_hex(if2, 4);
			break;
		case 392: // "SIL" "MVHI" d1(b1),i2
			trace_parms = " S2(" + tz390.get_hex(bd1_loc, 8) + ")="
			+ bytes_to_hex(mem, bd1_loc, 4, 0) + " I2="
			+ tz390.get_hex(if2, 4);
			break;
		case 400: // "RIE8" "RNSBG" r1,r2,i3,i4,i5
			trace_parms = " R" + tz390.get_hex(mf1, 1)
			+ "=" + tz390.get_long_hex(reg.getLong(rf1),16)
			+ " R" + tz390.get_hex(mf2, 1)
			+ "=" + tz390.get_long_hex(reg.getLong(rf2),16)
			+ " I3=" + tz390.get_hex(if3,2)
			+ " I4=" + tz390.get_hex(if4,2)
			+ " I5=" + tz390.get_hex(if5,2);
			break;
		case 410: // "AHHHR" R1,R2,R3
			trace_parms = " R" + tz390.get_hex(mf1, 1)
			+ "="  + tz390.get_long_hex(reg.getLong(rf1),16)
			+ " R" + tz390.get_hex(mf2, 1)
			+ "="  + tz390.get_long_hex(reg.getLong(rf2),16)
			+ " R" + tz390.get_hex(mf3, 1)
			+ "="  + tz390.get_long_hex(reg.getLong(rf3),16);
		case 420: // "AHIK" R1,R3,I2
			trace_parms = " R" + tz390.get_hex(mf1, 1)
			+ "="  + tz390.get_hex(reg.getInt(rf1+4),8)
			+ " R" + tz390.get_hex(mf3, 1)
			+ "="  + tz390.get_hex(reg.getInt(rf3+4),8)
			+ " I2="  + tz390.get_hex(if2,4);
		case 430: // "AGHIK" R1,R3,I2
			trace_parms = " R" + tz390.get_hex(mf1, 1)
			+ "="  + tz390.get_long_hex(reg.getLong(rf1),16)
			+ " R" + tz390.get_hex(mf3, 1)
			+ "="  + tz390.get_long_hex(reg.getLong(rf3),16)
			+ " I2="  + tz390.get_hex(if2,4);
		}
	} catch (final Exception e) { // RPI-1054
		if (tz390.opt_trace) {
			tz390.put_trace(" " + tz390.get_hex(psw_loc | psw_amode_bit, 8) + " "
					+ psw_cc_code[psw_cc] + " TRACE EXCEPTION"); // RPI-1054
		}
		return;
	}
		ins_trace_line = " " + tz390.get_hex(psw_loc | psw_amode_bit, 8) + " "
					+ psw_cc_code[psw_cc] + " " + get_ins_hex(psw_loc) + " "
					+ trace_name
					+ trace_parms;
		tz390.put_trace(ins_trace_line);  // RPI-689
	}

	/**
	 * Return long from mem.getLong(xbd2_loc)<br>
	 * else return -1 and avoid trap for LA etc.
	 *
	 * @return
	 */
	private long get_long_xbd2() // RPI-808
	{
		if (xbd2_loc > tot_mem || xbd2_loc < 0) {
			return -1;
		} else {
			return mem.getLong(xbd2_loc);
		}
	}

	/**
	 * Set flags, masks, and rotate.
	 */
	private void rsbg_setup_and_rotate()
	{
		if (if3 < 0) {
			rsbg_test = true;
		} else {
			rsbg_test = false;
		}
		if3 = if3 & 0x3f;
		if (if4 < 0) {
			rsbg_zero = true;
		} else {
			rsbg_zero = false;
		}
		if4 = if4 & 0x3f;
		// 1. Set rsbg_mask_ones to all 0's  except the selected bits.
		// 2. Set rsbg_mask_zeros to all 1's except the selected bits.
		if (if3 <= if4) {
			if (if3 > 0) {
				rsbg_mask_ones = (long)(-1) >>> if3;
			} else {
				rsbg_mask_ones = -1;
			}
			rsbg_mask_ones = (rsbg_mask_ones >>> (63-if4)) << (63-if4);
			rsbg_mask_zeros = rsbg_mask_ones ^ -1;
		} else { // selected field wraps 63-0
			rsbg_mask_zeros = (((long)(-1) >>> (if4+1)) >>> (64-if3)) << (64-if3);
			rsbg_mask_ones = rsbg_mask_zeros ^ -1;
		}
		// Rotate rlv1 left or right
		if (if5 != 0) {
			if (if5 < 32) {
				rlv2 = long_rotate_left(rlv2,if5);
			} else {
				rlv2 = long_rotate_right(rlv2,64 - if5);
			}
		}
	}

	/**
	 * Rotate and insert in high or low 32 bits with optional zeros for non select bits.
	 *
	 * @param high
	 */
	private void risb_rotate_insert_high(final boolean high)
	{
		// Rotate rlv1 left or right.
		if (if5 != 0) {
			if (if5 < 32) {
				rlv2 = long_rotate_left(rlv2,if5);
			} else {
				rlv2 = long_rotate_right(rlv2,64 - if5);
			}
		}
		// Set rv1 and rv2 to high or low.
		if (high) {
			rv1 = (int)(rlv1 >>> 32);
			rv2 = (int)(rlv2 >>> 32);
		} else {
			rv1 = (int) rlv1;
			rv2 = (int) rlv2;
		}
		if4 = if4 & 0x3f;
		// 1.  Set rsbg_mask_ones  to all 0's except the selected bits.
		// 2.  Set rsbg_mask_zeros to all 1's except the selected bits.
		if (if3 <= if4) {
			if (if3 > 0) {
				risb_mask_ones = (int)(-1) >>> if3;
			} else {
				risb_mask_ones = -1;
			}
			risb_mask_ones  = (risb_mask_ones >>> (31-if4)) << (31-if4);
			risb_mask_zeros = risb_mask_ones ^ -1;
		} else { // selected field wraps 63-0
			risb_mask_zeros = (((int)(-1) >>> (if4+1)) >>> (32-if3)) << (32-if3);
			risb_mask_ones  = risb_mask_zeros ^ -1;
		}
		if (risb_zero) {
			rv1 = rv2 & risb_mask_ones; // RPI-1164  WAS RV1 IN ERROR
		} else {
			rv1 = (rv1 & risb_mask_zeros) | (rv2 & risb_mask_ones);
		}
		if (high) {
			reg.putInt(rf1,rv1);
		} else {
			reg.putInt(rf1+4,rv1);
		}
	}

	/**
	 * Rotate long n bits left (0-63).
	 *
	 * @param value
	 * @param n
	 * @return
	 */
	private long long_rotate_left(final long value, final int n)
	{
		return (value << n) | (value >>> (64 - n));
	}

	/**
	 * Rotate long right n bits 0-83.
	 *
	 * @param value
	 * @param n
	 * @return
	 */
	private long long_rotate_right(final long value, final int n)
	{
		return (value >>> n) | (value << (64- n));
	}

	/**
	 * Rotate int n bits left (0-31).
	 *
	 * @param value
	 * @param n
	 * @return
	 */
	private int int_rotate_left(final int value, final int n)
	{
		return (value << n) | (value >>> (32 - n));
	}

	/**
	 * Perform floating point operation.
	 */
	private void exec_pfpo()
	{
		/*
		 *  1.  If r0 bit 32 is on, check if function supported and set r1 rc = 0 else r1 = 3.
		 *  2.  if r0 bit 32 zero, perform floating point function:
		 *      a. bits 33-39 = operation
		 *         x'01' = convert radix (FP0+2 = FP4+6)
		 *      b. bits 40-47 = first  operand type
		 *      c. bits 48-55 = second operand type
		 *      d. bit  56    = inexact suppression control
		 *      e. bit  57    = alternate exception action control
		 *      f. bits 58-59 = target radix dependent controls
		 *      g. bits 60-63 = rounding method
		 */
		final int pfpo_op    = (int)reg.get(r0);
		final int pfpo_type1 = (int)reg.get(r0+1);
		final int pfpo_type2 = (int)reg.get(r0+2);
		final int pfpo_round = (int)reg.get(r0+3) & 0xf;

		if (pfpo_op != 1 && pfpo_round == 0) {
			// verify not test, radix,def rnd
			set_psw_check(Constants.psw_pic_oper);
			return;
		}

		rf1 = 0;
		rf2 = 8*4;
		reg.putInt(r0,0);
		psw_cc = psw_cc0;
		switch (pfpo_type1) {
		case 0: // 0 = HFP-SHORT
			switch (pfpo_type2) {
			case 0: // 0 = HFP-SHORT
				fp_load_reg(rf1, tz390.fp_eh_type, fp_reg, rf2, tz390.fp_eh_type);
				break;
			case 1:   // 1 = HFP-LONG
				fp_load_reg(rf1, tz390.fp_eh_type, fp_reg, rf2, tz390.fp_dh_type);
				break;
			case 2:   // 2 = HFP-EXTENDED
				fp_load_reg(rf1, tz390.fp_eh_type, fp_reg, rf2, tz390.fp_lh_type);
				break;
			case 5:   // 5 = BFP-SHORT
				fp_load_reg(rf1, tz390.fp_eh_type, fp_reg, rf2, tz390.fp_eb_type);
				break;
			case 6:   // 6 = BFP-LONG
				fp_load_reg(rf1, tz390.fp_eh_type, fp_reg, rf2, tz390.fp_db_type);
				break;
			case 7:   // 7 = BFP-EXTENDED
				fp_load_reg(rf1, tz390.fp_eh_type, fp_reg, rf2, tz390.fp_lb_type);
				break;
			case 8:   // 8 = DFP-SHORT
				fp_load_reg(rf1, tz390.fp_eh_type, fp_reg, rf2, tz390.fp_ed_type);
				break;
			case 9:   // 9 = DFP-LONG
				fp_load_reg(rf1, tz390.fp_eh_type, fp_reg, rf2, tz390.fp_dd_type);
				break;
			case 0xA: // A = DFP-EXTENDED
				fp_load_reg(rf1, tz390.fp_eh_type, fp_reg, rf2, tz390.fp_ld_type);
				break;
			default:
				set_psw_check(Constants.psw_pic_spec);
				return;
			}
			break;
		case 1:   // 1 = HFP-LONG
			switch (pfpo_type2) {
			case 0: // 0 = HFP-SHORT
				fp_load_reg(rf1, tz390.fp_dh_type, fp_reg, rf2, tz390.fp_eh_type);
				break;
			case 1:   // 1 = HFP-LONG
				fp_load_reg(rf1, tz390.fp_dh_type, fp_reg, rf2, tz390.fp_dh_type);
				break;
			case 2:   // 2 = HFP-EXTENDED
				fp_load_reg(rf1, tz390.fp_dh_type, fp_reg, rf2, tz390.fp_lh_type);
				break;
			case 5:   // 5 = BFP-SHORT
				fp_load_reg(rf1, tz390.fp_dh_type, fp_reg, rf2, tz390.fp_eb_type);
				break;
			case 6:   // 6 = BFP-LONG
				fp_load_reg(rf1, tz390.fp_dh_type, fp_reg, rf2, tz390.fp_db_type);
				break;
			case 7:   // 7 = BFP-EXTENDED
				fp_load_reg(rf1, tz390.fp_eh_type, fp_reg, rf2, tz390.fp_lb_type);
				break;
			case 8:   // 8 = DFP-SHORT
				fp_load_reg(rf1, tz390.fp_dh_type, fp_reg, rf2, tz390.fp_ed_type);
				break;
			case 9:   // 9 = DFP-LONG
				fp_load_reg(rf1, tz390.fp_dh_type, fp_reg, rf2, tz390.fp_dd_type);
				break;
			case 0xA: // A = DFP-EXTENDED
				fp_load_reg(rf1, tz390.fp_dh_type, fp_reg, rf2, tz390.fp_ld_type);
				break;
			default:
				set_psw_check(Constants.psw_pic_spec);
				return;
			}
			break;
		case 2:   // 2 = HFP-EXTENDED
			switch (pfpo_type2) {
			case 0: // 0 = HFP-SHORT
				fp_load_reg(rf1, tz390.fp_lh_type, fp_reg, rf2, tz390.fp_eh_type);
				break;
			case 1:   // 1 = HFP-LONG
				fp_load_reg(rf1, tz390.fp_lh_type, fp_reg, rf2, tz390.fp_dh_type);
				break;
			case 2:   // 2 = HFP-EXTENDED
				fp_load_reg(rf1, tz390.fp_lh_type, fp_reg, rf2, tz390.fp_lh_type);
				break;
			case 5:   // 5 = BFP-SHORT
				fp_load_reg(rf1, tz390.fp_lh_type, fp_reg, rf2, tz390.fp_eb_type);
				break;
			case 6:   // 6 = BFP-LONG
				fp_load_reg(rf1, tz390.fp_lh_type, fp_reg, rf2, tz390.fp_db_type);
				break;
			case 7:   // 7 = BFP-EXTENDED
				fp_load_reg(rf1, tz390.fp_lh_type, fp_reg, rf2, tz390.fp_lb_type);
				break;
			case 8:   // 8 = DFP-SHORT
				fp_load_reg(rf1, tz390.fp_lh_type, fp_reg, rf2, tz390.fp_ed_type);
				break;
			case 9:   // 9 = DFP-LONG
				fp_load_reg(rf1, tz390.fp_lh_type, fp_reg, rf2, tz390.fp_dd_type);
				break;
			case 0xA: // A = DFP-EXTENDED
				fp_load_reg(rf1, tz390.fp_lh_type, fp_reg, rf2, tz390.fp_ld_type);
				break;
			default:
				set_psw_check(Constants.psw_pic_spec);
				return;
			}
			break;
		case 5:   // 5 = BFP-SHORT
			switch (pfpo_type2) {
			case 0: // 0 = HFP-SHORT
				fp_load_reg(rf1, tz390.fp_eb_type, fp_reg, rf2, tz390.fp_eh_type);
				break;
			case 1:   // 1 = HFP-LONG
				fp_load_reg(rf1, tz390.fp_eb_type, fp_reg, rf2, tz390.fp_dh_type);
				break;
			case 2:   // 2 = HFP-EXTENDED
				fp_load_reg(rf1, tz390.fp_eb_type, fp_reg, rf2, tz390.fp_lh_type);
				break;
			case 5:   // 5 = BFP-SHORT
				fp_load_reg(rf1, tz390.fp_eb_type, fp_reg, rf2, tz390.fp_eb_type);
				break;
			case 6:   // 6 = BFP-LONG
				fp_load_reg(rf1, tz390.fp_eb_type, fp_reg, rf2, tz390.fp_db_type);
				break;
			case 7:   // 7 = BFP-EXTENDED
				fp_load_reg(rf1, tz390.fp_eb_type, fp_reg, rf2, tz390.fp_lb_type);
				break;
			case 8:   // 8 = DFP-SHORT
				fp_load_reg(rf1, tz390.fp_eb_type, fp_reg, rf2, tz390.fp_ed_type);
				break;
			case 9:   // 9 = DFP-LONG
				fp_load_reg(rf1, tz390.fp_eb_type, fp_reg, rf2, tz390.fp_dd_type);
				break;
			case 0xA: // A = DFP-EXTENDED
				fp_load_reg(rf1, tz390.fp_eb_type, fp_reg, rf2, tz390.fp_ld_type);
				break;
			default:
				set_psw_check(Constants.psw_pic_spec);
				return;
			}
			break;
		case 6:   // 6 = BFP-LONG
			switch (pfpo_type2) {
			case 0: // 0 = HFP-SHORT
				fp_load_reg(rf1, tz390.fp_db_type, fp_reg, rf2, tz390.fp_eh_type);
				break;
			case 1:   // 1 = HFP-LONG
				fp_load_reg(rf1, tz390.fp_db_type, fp_reg, rf2, tz390.fp_dh_type);
				break;
			case 2:   // 2 = HFP-EXTENDED
				fp_load_reg(rf1, tz390.fp_db_type, fp_reg, rf2, tz390.fp_lh_type);
				break;
			case 5:   // 5 = BFP-SHORT
				fp_load_reg(rf1, tz390.fp_db_type, fp_reg, rf2, tz390.fp_eb_type);
				break;
			case 6:   // 6 = BFP-LONG
				fp_load_reg(rf1, tz390.fp_db_type, fp_reg, rf2, tz390.fp_db_type);
				break;
			case 7:   // 7 = BFP-EXTENDED
				fp_load_reg(rf1, tz390.fp_db_type, fp_reg, rf2, tz390.fp_lb_type);
				break;
			case 8:   // 8 = DFP-SHORT
				fp_load_reg(rf1, tz390.fp_db_type, fp_reg, rf2, tz390.fp_ed_type);
				break;
			case 9:   // 9 = DFP-LONG
				fp_load_reg(rf1, tz390.fp_db_type, fp_reg, rf2, tz390.fp_dd_type);
				break;
			case 0xA: // A = DFP-EXTENDED
				fp_load_reg(rf1, tz390.fp_db_type, fp_reg, rf2, tz390.fp_ld_type);
				break;
			default:
				set_psw_check(Constants.psw_pic_spec);
				return;
			}
			break;
		case 7:   // 7 = BFP-EXTENDED
			switch (pfpo_type2) {
			case 0: // 0 = HFP-SHORT
				fp_load_reg(rf1, tz390.fp_lb_type, fp_reg, rf2, tz390.fp_eh_type);
				break;
			case 1:   // 1 = HFP-LONG
				fp_load_reg(rf1, tz390.fp_lb_type, fp_reg, rf2, tz390.fp_dh_type);
				break;
			case 2:   // 2 = HFP-EXTENDED
				fp_load_reg(rf1, tz390.fp_lb_type, fp_reg, rf2, tz390.fp_lh_type);
				break;
			case 5:   // 5 = BFP-SHORT
				fp_load_reg(rf1, tz390.fp_lb_type, fp_reg, rf2, tz390.fp_eb_type);
				break;
			case 6:   // 6 = BFP-LONG
				fp_load_reg(rf1, tz390.fp_lb_type, fp_reg, rf2, tz390.fp_db_type);
				break;
			case 7:   // 7 = BFP-EXTENDED
				fp_load_reg(rf1, tz390.fp_lb_type, fp_reg, rf2, tz390.fp_lb_type);
				break;
			case 8:   // 8 = DFP-SHORT
				fp_load_reg(rf1, tz390.fp_lb_type, fp_reg, rf2, tz390.fp_ed_type);
				break;
			case 9:   // 9 = DFP-LONG
				fp_load_reg(rf1, tz390.fp_lb_type, fp_reg, rf2, tz390.fp_dd_type);
				break;
			case 0xA: // A = DFP-EXTENDED
				fp_load_reg(rf1, tz390.fp_lb_type, fp_reg, rf2, tz390.fp_ld_type);
				break;
			default:
				set_psw_check(Constants.psw_pic_spec);
				return;
			}
			break;
		case 8:   // 8 = to DFP-SHORT
			switch (pfpo_type2) {
			case 0: // 0 = HFP-SHORT
				fp_load_reg(rf1, tz390.fp_ed_type, fp_reg, rf2, tz390.fp_eh_type);
				break;
			case 1:   // 1 = HFP-LONG
				fp_load_reg(rf1, tz390.fp_ed_type, fp_reg, rf2, tz390.fp_dh_type);
				break;
			case 2:   // 2 = HFP-EXTENDED
				fp_load_reg(rf1, tz390.fp_ed_type, fp_reg, rf2, tz390.fp_lh_type);
				break;
			case 5:   // 5 = BFP-SHORT
				fp_load_reg(rf1, tz390.fp_ed_type, fp_reg, rf2, tz390.fp_eb_type);
				break;
			case 6:   // 6 = BFP-LONG
				fp_load_reg(rf1, tz390.fp_ed_type, fp_reg, rf2, tz390.fp_db_type);
				break;
			case 7:   // 7 = BFP-EXTENDED
				fp_load_reg(rf1, tz390.fp_ed_type, fp_reg, rf2, tz390.fp_lb_type);
				break;
			case 8:   // 8 = DFP-SHORT
				fp_load_reg(rf1, tz390.fp_ed_type, fp_reg, rf2, tz390.fp_ed_type);
				break;
			case 9:   // 9 = DFP-LONG
				fp_load_reg(rf1, tz390.fp_ed_type, fp_reg, rf2, tz390.fp_dd_type);
				break;
			case 0xA: // A = DFP-EXTENDED
				fp_load_reg(rf1, tz390.fp_ed_type, fp_reg, rf2, tz390.fp_ld_type);
				break;
			default:
				set_psw_check(Constants.psw_pic_spec);
				return;
			}
			break;
		case 9:   // 9 = DFP-LONG
			switch (pfpo_type2) {
			case 0: // 0 = HFP-SHORT
				fp_load_reg(rf1, tz390.fp_dd_type, fp_reg, rf2, tz390.fp_eh_type);
				break;
			case 1:   // 1 = HFP-LONG
				fp_load_reg(rf1, tz390.fp_dd_type, fp_reg, rf2, tz390.fp_dh_type);
				break;
			case 2:   // 2 = HFP-EXTENDED
				fp_load_reg(rf1, tz390.fp_dd_type, fp_reg, rf2, tz390.fp_lh_type);
				break;
			case 5:   // 5 = BFP-SHORT
				fp_load_reg(rf1, tz390.fp_dd_type, fp_reg, rf2, tz390.fp_eb_type);
				break;
			case 6:   // 6 = BFP-LONG
				fp_load_reg(rf1, tz390.fp_dd_type, fp_reg, rf2, tz390.fp_db_type);
				break;
			case 7:   // 7 = BFP-EXTENDED
				fp_load_reg(rf1, tz390.fp_dd_type, fp_reg, rf2, tz390.fp_lb_type);
				break;
			case 8:   // 8 = DFP-SHORT
				fp_load_reg(rf1, tz390.fp_dd_type, fp_reg, rf2, tz390.fp_ed_type);
				break;
			case 9:   // 9 = DFP-LONG
				fp_load_reg(rf1, tz390.fp_dd_type, fp_reg, rf2, tz390.fp_dd_type);
				break;
			case 0xA: // A = DFP-EXTENDED
				fp_load_reg(rf1, tz390.fp_dd_type, fp_reg, rf2, tz390.fp_ld_type);
				break;
			default:
				set_psw_check(Constants.psw_pic_spec);
				return;
			}
			break;
		case 0xA: // A = DFP-EXTENDED
			switch (pfpo_type2) {
			case 0: // 0 = HFP-SHORT
				fp_load_reg(rf1, tz390.fp_ld_type, fp_reg, rf2, tz390.fp_eh_type);
				break;
			case 1:   // 1 = HFP-LONG
				fp_load_reg(rf1, tz390.fp_ld_type, fp_reg, rf2, tz390.fp_dh_type);
				break;
			case 2:   // 2 = HFP-EXTENDED
				fp_load_reg(rf1, tz390.fp_ld_type, fp_reg, rf2, tz390.fp_lh_type);
				break;
			case 5:   // 5 = BFP-SHORT
				fp_load_reg(rf1, tz390.fp_ld_type, fp_reg, rf2, tz390.fp_eb_type);
				break;
			case 6:   // 6 = BFP-LONG
				fp_load_reg(rf1, tz390.fp_ld_type, fp_reg, rf2, tz390.fp_db_type);
				break;
			case 7:   // 7 = BFP-EXTENDED
				fp_load_reg(rf1, tz390.fp_ld_type, fp_reg, rf2, tz390.fp_lb_type);
				break;
			case 8:   // 8 = DFP-SHORT
				fp_load_reg(rf1, tz390.fp_ld_type, fp_reg, rf2, tz390.fp_ed_type);
				break;
			case 9:   // 9 = DFP-LONG
				fp_load_reg(rf1, tz390.fp_ld_type, fp_reg, rf2, tz390.fp_dd_type);
				break;
			case 0xA: // A = DFP-EXTENDED
				fp_load_reg(rf1, tz390.fp_ld_type, fp_reg, rf2, tz390.fp_ld_type);
				break;
			default:
				set_psw_check(Constants.psw_pic_spec);
				return;
			}
			break;
		default:
			set_psw_check(Constants.psw_pic_spec);
			return;
		}
	}

	/**
	 * Set risb_zero true if r4 high bit on (bit 24).
	 */
	private void set_risb_zero() // RPI-1164
	{
		if ((mem_byte[(psw_loc & psw_amode)+3] & 0x80) != 0) {
			risb_zero = true;
		} else {
			risb_zero = false;
		}
	}

	/**
	 * Route for rre/rrf op type A instruction RPI-1125
	 * Set alt fp_bfp_rnd if not 0 and issue S0c4 if alt_fpe_mode for now.
	 */
	private void set_bfp_alt_mode_rr()
	{
		final int ins_loc = psw_loc & psw_amode;
		alt_rnd_mode = mem_byte[ins_loc+2] >>> 4;
		alt_fpe_mode = mem_byte[ins_loc+2] & 0xf;
		if (alt_rnd_mode != 0) { // RPI-1125
			fp_bfp_rnd = alt_rnd_mode;
		}
		if (alt_fpe_mode != 0) {
			set_psw_check(Constants.psw_pic_spec);
		}
	}

	/**
	 * rtn for rre/rrf op type A instruction RPI-1125
	 */
	private void reset_bfp_alt_mode()
	{
		fp_bfp_rnd = fp_bfp_rnd_default; // RPI-1125
	}

	/**
	 * Route for rre/rrf op type A instruction RPI-1125
	 * Set alt fp_dfp_rnd if not 0 and issue S0c4 if alt_fpe_mode for now.
	 */
	private void set_dfp_alt_mode_rr()
	{
		final int ins_loc = psw_loc & psw_amode;
		alt_rnd_mode = mem_byte[ins_loc+2] >>> 4;
		alt_fpe_mode = mem_byte[ins_loc+2] & 0xf;
		if (alt_rnd_mode != 0) { // RPI-1125
			fp_dfp_rnd = alt_rnd_mode;
		}
		if (alt_fpe_mode != 0) {
			set_psw_check(Constants.psw_pic_spec);
		}
	}

	/**
	 * Route for rrr op type A instr RPI-1125
	 * Set alt fp_dfp_rnd if not 0 and issue S0c4 if alt_fpe_mode for now.
	 */
	private void set_dfp_alt_mode_rrr()
	{
		final int ins_loc = psw_loc & psw_amode;
		mf4 = mem_byte[ins_loc+2] & 0xf;
		alt_rnd_mode = mf4;
		if (alt_rnd_mode != 0) {
			fp_dfp_rnd = alt_rnd_mode;
		}
	}

	/**
	 * rtn for rrr op type A instr. RPI-1125
	 */
	private void reset_dfp_alt_mode()
	{
		fp_dfp_rnd = fp_dfp_rnd_default;
	}
}
