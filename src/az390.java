import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.RandomAccessFile;
import java.lang.reflect.Array;
import java.math.BigDecimal;
import java.math.BigInteger;
import java.math.MathContext;
import java.math.RoundingMode;
import java.nio.ByteBuffer;
import java.util.Arrays;
import java.util.Date;
import java.util.Iterator;
import java.util.TreeSet;
import java.util.concurrent.locks.Condition;
import java.util.concurrent.locks.Lock;
import java.util.concurrent.locks.ReentrantLock;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import javax.swing.JTextArea;

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
 * az390 is the assembler component of z390<br>
 * which can be called from z390 GUI interface or from command line<br>
 * to read BAL source and generate OBJ relocatable object code file.
 */
public class az390 implements Runnable
{
	// Global variables
			tz390 tz390 = null;
	private final static String msg_id_i = "AZ390I ";
	private final static String msg_id_e = "AZ390E ";

			int		az390_rc = 0;
			int		az390_errors = 0;
			boolean	az390_recursive_abort = false; // RPI-935
			int		mz390_rc     = 0; // RPI-415 passed from mz390 if option asm
			int		mz390_errors = 0; // RPI-415 passed from mz390 if option asm
			String	mz390_started_msg = ""; // RPI-755
			boolean	mz390_abort = false;
	private int		cur_pass = 1;
//	private Date	cur_date = new Date();
	private long	tod_start = new Date().getTime();
//	private long	tot_sec = 0;
//	private boolean	stats_to_obj = false;
	private int		tot_obj_bytes = 0;
	private File	bal_file = null;
	private BufferedReader bal_file_buff = null;
	private RandomAccessFile obj_file = null;
	private File	prn_file = null;
	private BufferedWriter prn_file_buff = null;
			String	bal_line = null;
	private String	mnote_warning_msg = ""; // RPI-1056
	private int		mcall_bal_index = 22;
	private int		mcall_lv_index  = 16;
	private String	bal_xref_file_name = null;
	private char	bal_xref_file_type = ' ';
	private char	cur_line_type  = ' '; // RPI-581
	private int		cur_line_file_num = 0;
//	private String	bal_xref_file_path = null;
	private int		bal_xref_file_num  = 0;
	private int		bal_xref_file_line = 0;
			int		tot_xref_files = 0;
			String[] xref_file_name = null;
//	private String[] xref_file_path = null; // RPI-425
			int[]    xref_file_errors = null;
	private char[]   xref_file_type   = null; // RPI-540 '+' macro '=' copy
//	private int    mz390_xref_file = 0;
//	private int    mz390_xref_line = 0;
			String bal_label   = null;
	private String opsyn_label = null;
			String bal_op = null;
	private boolean bal_op_ok = false;
	private boolean bal_label_ok = false; // RPI-451
			String bal_parms = null;
	private boolean list_use      = false;
	private int      mac_inline_level = 0;      // RPI-581
	private int      mac_inline_op_macro = 220; // RPI-581
	private int      mac_inline_op_mend  = 221; // RPI-581
	private int      mac_inline_op_other = 226; // RPI-581

			boolean bal_abort = false;
	private int bal_op_index = 0;
	private int end_loc = 0; // RPI-605
	private boolean report_label_changes = true;
	private boolean report_equ_changes = true;
	private boolean bal_eof = false;
	private boolean end_found = false;
	private String end_entry = "";
	private int    end_entry_sid = 0;
	private boolean end_entry_found = false;
//	private SimpleDateFormat mmddyy = new SimpleDateFormat("MM/dd/yy");
//	private SimpleDateFormat hhmmss = new SimpleDateFormat("HH:mm:ss");
//	private boolean log_tod = true;
	private JTextArea z390_log_text = null;

	// Semaphores used to synchronize mz390 and az390
	private Thread  az390_thread = null;     // RPI-415
			boolean az390_running = false;   // RPI-415
	private boolean mz390_call = false;      // RPI-415
			boolean lookahead_mode  = false; // RPI-415
	private boolean sym_lock = false;
	private String  sym_lock_desc = null;
	private final Lock      lock            = new ReentrantLock();
	private final Condition lock_condition  = lock.newCondition();
	boolean bal_line_full = false;
	private String pass_bal_line = null;
	private String pass_xref_file_name = null;
	private char   pass_xref_file_type = ' ';
	private int    pass_xref_file_num = 0;
	private int    pass_xref_file_line = 0;
	private String xref_file_line = null;
	private	int    xref_bal_index = 0;
			boolean pass_bal_eof = false;
			boolean az390_waiting = false;
			boolean az390_private_sect = false; // RPI-995

	// Static limits
	private	int sort_index_bias = 100000; // must be > tz390.opt_maxsym and tz390.opt_maxsym
	private	int sort_index_len  = 6;      // digits in key_index_bias
	private	int max_exp_stk = 500;
	private	int max_exp_rld = 500;
	private	int max_hh = 0x7ffff; // RPI-387
	private	int min_hh = 0xfff80000; // RPI-387
	private	int max_text_buff_len = 16;
//	private	long[] max_fh = {((long)(-1) >>> 57),
//							 ((long)(-1) >>> 49),
//							 ((long)(-1) >>> 41),
//							 ((long)(-1) >>> 33),
//							 ((long)(-1) >>> 25),
//							 ((long)(-1) >>> 17),
//							 ((long)(-1) >>>  9),
//							 ((long)(-1) >>>  1),
//							};
//	private long[] min_fh = {((long)(-1) << 7),
//							 ((long)(-1) << 15),
//							 ((long)(-1) << 23),
//							 ((long)(-1) << 31),
//							 ((long)(-1) << 39),
//							 ((long)(-1) << 47),
//							 ((long)(-1) << 55),
//							 ((long)(-1) << 63),
//							};

	// BAL file global variables
	private long    tod_time_limit = 0;
	private int tot_bal_line = 1;
//	private int tot_mac_copy = 0;
	private int tot_mnote_warning = 0;
	private int tot_mnote_errors  = 0;
	private int max_mnote_level   = 0;
	private String[]  bal_line_text = null; //logical bal line from 1 or more physical lines
	private int[]     bal_line_num  = null; //starting generated BAL physical line #
	private int[]     bal_line_xref_file_num  = null;
	private int[]     bal_line_xref_file_line = null;
//	private boolean bal_line_gen = true;
	private String trace_pfx = null;
//	private String parm_name = null;
//	private String parm_value = null;
	private int bal_line_index = 1; //current mac line index
	private Pattern exp_pattern = null;
	private Matcher exp_match   = null;
	private Pattern label_pattern = null;
	private Matcher label_match   = null;
	private Pattern extrn_pattern = null;
	private Matcher extrn_match   = null;
	private Pattern dcc_sq_pattern = null;  // EBCDIC or ASCII
	private Pattern dcc_dq_pattern = null;  //RPI5  C".." ASCII
	private Pattern dcc_eq_pattern = null;  //RPI73 C!..! EBCDIC
	private Matcher dcc_match   = null;

	// Location counter and ESD tables
			int loc_ctr = 0;
	private int loc_start = 0;
			int loc_len = 0;
			int cur_esd_sid = 0;
	private int tot_esd = 0;
			int cur_esd = 0;
	private int cur_esd_base = 0;   // first section
	private int first_cst_esd = 0;
	private int esd_sdt = 0;
	private int esd_cpx_rld = -1;
	private int[]     esd_sid  = null;
	private int[]     esd_base = null;
	private int[]     esd_loc  = null; // current loc within section
	private int tot_loc_stmt   = 0;

	// Using global data
	private int cur_use_start = 0;
	private int cur_use_end   = 0;
	private boolean explicit_drop_reg = false;
	private int[] push_cur_use_start = null;
	private int[] push_cur_use_end   = null;
	private int cur_use = 0;
	private boolean cur_use_depend = false;
	private boolean use_eof = false;
	private int cur_use_base_esd = 0;
	private int cur_use_base_loc = 0;
	private int cur_use_base_len = 0;
	private int cur_use_reg = -1;
	private int cur_use_neg_reg = -1;
	private int cur_use_off = 0x80000; // RPI-387 max 20 bit+1
	private int cur_use_neg_off = 0xfff00000; // RPI-387 min 20 bit-1
	private String cur_use_lab = "";
	private String[] use_lab      = null;
	private int[]    use_base_esd = null;
	private int[]    use_base_loc = null;
	private int[]    use_base_len = null;
	private int[]    use_reg      = null;
	private int[]    use_reg_loc  = null;
	private int      use_domain_tot = 0;

	// push, pop, and, print data
	private int using_level = 0;
	private int print_level = 0;
	private int[]     using_start = null;
	private int[]     using_end   = null;
	private boolean[] print_on    = null;
	private boolean[] print_gen   = null;
	private boolean[] print_data  = null;
	private boolean  force_list_bal = false; // RPI-285 RPI-891 force msg on PRN
	private boolean  list_bal_line  = true;	 // RPI-891 assume all BAL on PRN

	/*
	 * set mac_call_gen on after printing *MCALL LV= 1 and set off after print *MEXIT LV= 1
	 */
	private boolean  mac_call_gen   = false;
	private boolean  mac_call_first = false;
	private boolean  mac_call_last  = false;

	/*
	 * symbol table global variables
	 */
	private final static byte sym_sdt   = 0;  // dec, b'', c'', h''
			final        byte sym_cst   = 1;  // CSECT )alias REL)
	private final static byte sym_dst   = 2;  // DSECT (alias REL)
	private final static byte sym_ent   = 3;  // ENTRY (alias REL)
	private final static byte sym_ext   = 4;  // EXTRN external link
	private final static byte sym_rel   = 5;  // RX (CST.DST,ENT)_
	private final static byte sym_rld   = 6;  // complex rld exp
	private final static byte sym_lct   = 7;  // loctr (changed to cst/dst).
	private final static byte sym_wxt   = 8;  // WXTRN weak external link RPI182
	private final static byte sym_und   = 9;  // undefined symbol RPI-694
	private int tot_sym = 0;
//	private int tot_sym_find = 0;
//	private int tot_sym_comp = 0;
			int cur_sid = 0;
	private int prev_sect_sid = 0;
	private int prev_sect_esd = 0;
	private boolean cur_sym_sect = false; // RPI-553 indicate if sym is sect or not
	private boolean sect_change = false;
	private byte prev_sect_type = sym_cst;
			String private_csect = "$PRIVATE"; // RPI-995
	private String[] sym_type_desc = {"ABS","CST","DST","ENT","EXT","REL","RLD","LCT","WXT","UND"}; //RPI-182 RPI-694
	private String[]  sym_name         = null;
			int[]     sym_def          = null;
			byte[]    sym_type         = null;
			byte[]    sym_dc_type      = null; // RPI-790
			byte[]    sym_dc_type_sfx  = null; // RPI-790
			byte[]    sym_attr         = null; // RPI-340
			byte[]	  sym_attr_elt     = null; // RPI-415 explicit length type attribute
			byte      sym_attr_elt_def = 0; // null char
			int[]     sym_scale        = null; // scale factor for int or fp exp
			int[]     sym_attrp        = null; // equ 4th program attribute 4 EBCDIC char stored as int
			String[]  sym_attra        = null; // equ 5th assembler attribute int RPI-415
	private int[]     sym_esd          = null;
			int[]     sym_loc          = null;
	private int[]     sym_max_loc      = null;
			int[]     sym_len          = null;
//	private int[]     sym_sect_type    = null;
			int[]     sym_sect_prev    = null;
	private int[]     sym_sect_next    = null;
	private TreeSet<Integer>[] sym_xref = null;
	private int last_xref_index = 0;
	private int last_xref_line  = 0;
			int sym_def_ref       =  0; // symbol referenced but not defined
			int sym_def_lookahead = -1; // symbol defined during lookahead

	/*
	 * ERRSUM critical error data
	 */
	private final static int max_missing = 100;
	private int tot_missing_copy  = 0;
	private int tot_missing_macro = 0;
	private int tot_missing_sym   = 0;
	private String missing_copy[]  = new String[max_missing];
	private String missing_macro[] = new String[max_missing];

	/*
	 * DS/DC type and attribute tables
	 */
	private final static String dc_type_table    = "ABCDEFHLPSVXYZ";
	private final static String dc_type_explicit = "RBCKKGGKPRVXRZ";
	private final static int[] dc_type_len = {
				4,  // A
				1,  // B
				1,  // C
				8,  // D
				4,  // E
				4,  // F
				2,  // H
				16, // L
				1,  // P
				2,  // S
				4,  // V
				1,  // X
				2,  // Y
				1   // Z
				};
//	private final static int[] dc_type_align = {
//				4,  // A
//				0,  // B
//				0,  // C
//				8,  // D
//				4,  // E
//				4,  // F
//				2,  // H
//				8,  // L
//				0,  // P
//				2,  // S
//				4,  // V
//				0,  // X
//				2,  // Y
//				0   // Z
//				};
	private final static char[] dc_type_delimiter = {
				'(',  // A
				'\'', // B
				'\'', // C
				'\'', // D
				'\'', // E
				'\'', // F
				'\'', // H
				'\'', // L
				'\'', // P
				'(',  // S
				'(',  // V
				'\'', // X
				'(',  // Y
				'\''  // Z
				};
	private final static String[] sym_attra_type = {
				"AR",   // Register - Access
				"CR",   // CR Register - Control
				"CR32", // Register - Control 32-bit
				"CR64", // Register - Control 64-bit
				"FPR",  // Register - Floating-Point
				"GR",   // Register - General
				"GR32", // Register - General 32-bit
				"GR64"  // Register - General 64-bit
				};
	private	byte    bal_lab_attr = 0;
	private	byte    bal_lab_attr_elt = sym_attr_elt_def; // RPI-415 explicit length attr

	/*
	 * Literal table for next pool at LTORG or END.
	 */
	private	int tot_lit = 0;
	private	int cur_lit = 0;
	private	boolean lit_loc_ref = false;
	private	int cur_lit_pool = 1;
	private	String[]  lit_name         = null;
	private	int[]     lit_pool         = null;
	private	int[]     lit_line         = null;
	private	int[]     lit_line_loc     = null;
	private	int[]     lit_esd          = null;
	private	int[]     lit_loc          = null;
	private	int[]     lit_len          = null;
	private	int[]     lit_dup          = null;  // RPI-1200 use dup*len for alignment sizing
	private	int[]     lit_scale        = null;  // RPI-790
	private	byte[]    lit_dc_type      = null;  // RPI-790
	private	byte[]    lit_dc_type_sfx  = null;  // RPI-790
	private	byte[]    lit_gen          = null;
//	private	int[]     lit_def          = null;
	private	TreeSet<Integer>[] lit_xref = null;

	/*
	 * BAL operation code data and tables
	 */
//	private final static String hex_tab   = "0123456789ABCDEF";
	private	String hex_op    = null;
	private	String hex_ll    = null;
	private	String hex_len1  = null;
	private	String hex_len2  = null;
	private	String hex_bddd  = null;
	private	String hex_bddd1 = null;
	private	boolean get_bdddhh = false; // RPI-387
	private	String hex_bddd2 = null; // returns bdddhh if get_bdddhh true
	private	String hex_bddd_loc  = null;
	private	String hex_bddd1_loc = null;
	private	String hex_bddd2_loc = null;

	/*
	 * Expression global variables including polish notation var and op stacks
	 */
	private	String  exp_text  = ""; // expression text
	private	int     exp_index = 0;  // current starting index
	private	boolean check_prev_op = true;
	private	int     exp_val   = 0;
	private	int     exp_esd   = 0;
	private	byte    exp_type  = 0;
	private	byte    exp_attr  = 0;
//	private	int     exp_state = 0;
	private	int     exp_level = 0;
	private	String  exp_use_lab = null;
	private	boolean exp_term = false;
	private	boolean exp_eot  = false;  // end of text terminator
	private	String  exp_term_op = "~";
	private	String  exp_start_op = exp_term_op;
	private	String  exp_token = null;
	private	String  exp_op    = " ";
	private	int     sym_esd1  = 0;
	private	int     sym_esd2  = 0;
//	private	byte    sym_type1 = 0;
//	private	byte    sym_type2 = 0;
	private	int     sym_val1  = 0;
	private	int     sym_val2  = 0;
	private	String  exp_prev_op = exp_start_op;
//	private	int     exp_sym_index = -1;  // symbol index
	private	boolean exp_sym_pushed = false;
	private	boolean exp_sym_last = false;
	private	boolean exp_first_sym_len = true; // is this first exp sym len
	private	boolean exp_equ     = false; // RPI-749
	private	boolean exp_lit_mod = false; // RPI-749
	private	int exp_len = 1;
	private	int tot_exp_stk_sym = 0;
	private	int tot_exp_stk_op  = 0;
	private	int[]     exp_stk_sym_esd  = (int[])Array.newInstance(int.class,max_exp_stk);
	private	int[]     exp_stk_sym_val  = (int[])Array.newInstance(int.class,max_exp_stk);
	private	String[]  exp_stk_op   = new String[max_exp_stk];
	private	int[]     exp_op_class = (int[])Array.newInstance(int.class,256);

	/*
	 * define exp actions based on last and next operator class
	 *    1 2 3 4 5 6
	 *   +-* /( ) ?'~             col = next_op
	 *                            row = prev_op
	 */
	private final static int tot_classes = 6;
	private final static int[] exp_action = {
			1,3,3,1,3,1,   // 1 +-  prev add/sub
			2,2,3,2,3,2,   // 2 * / prev mpy/div
			3,3,3,4,3,0,   // 3 (   prev open
			0,0,0,0,3,0,   // 4 )   prev close
			5,5,3,5,3,5,   // 5 ?'  prev pfx oper L' U+/= RPI-313 RPI-991 pfx/pfx=3
			3,3,7,6,3,6,   // 6 ~   prev terminator
		};

	/* action code routines:
	 *   0 error
	 *   1 add/sub
	 *   2 mpy/div
	 *   3 push op
	 *   4 POP  op
	 *   5 length attribute of symbol or * instr.
	 *   6 exit with result of expression
	 *   7 check ( for terminator if last_val
	 */

	/*
	 * Expression relocation definitions RLDS
	 */
	private	int		exp_rld_mod_val = 0;     // RPI-632
	private	boolean	exp_rld_mod_set = false; // RPI-632
	private	byte	exp_rld_len = 0;  // gen rlds if 3 or 4
	private	int		tot_exp_rld_add = 0;
	private	int		tot_exp_rld_sub = 0;
	private	int[]	exp_rld_add_esd = (int[])Array.newInstance(int.class,max_exp_rld);
	private	int[]	exp_rld_sub_esd = (int[])Array.newInstance(int.class,max_exp_rld);

	/*
	 * global relocation definitions RLDS
	 */
	private	int tot_rld = 0;
	private	final static char rld_add = '+';
	private	final static char rld_sub = '-';
	private	int[]     rld_fld_esd = null;
	private	int[]     rld_fld_loc = null;
	private	byte[]    rld_fld_len = null;
	private	char[]    rld_fld_sgn = null;
	private	int[]     rld_xrf_esd = null;

	/*
	 * object code text buffer variables
	 */
	private	boolean gen_obj_code = false;
	private	String obj_code = "";
	private	int    list_obj_loc  = 0;
	private	String list_obj_code = "";
	private	String cur_text_buff = null;
	private	int cur_text_loc = 0;
	private	int cur_text_len = 0;
	private	int cur_text_esd = 0;

	/*
	 * binary obj file buffer and layouts
	 */
	private	byte[] bin_byte = new byte[80];
//	private	final static byte obj_bin_id = 0x02; // first bin obj byte
//	private	final static byte[] bin_esd_type = {'E','S','D'};
//	private	final static byte[] bin_txt_type = {'T','X','T'};
//	private	final static byte[] bin_rld_type = {'R','L','D'};
//	private	final static byte[] bin_end_type = {'E','N','D'};

	/*
	 * DS/DC global variables
	 */
	private	boolean dc_op   = false;  // ds vs dc bal op
	private	boolean dc_eod  = false;  // ds/dc end of fields
	private	boolean dc_len_explicit = false;
	private	boolean dc_scale_explicit = false; // RPI-777
//	private	boolean dc_exp_explicit = false;   // RPI-777
	private	boolean dc_bit_len  = false;  // RPI-417
//	private	boolean dc_unsigned = false;  // RPI-893
	private	BigInteger dc_bit_buff  = null;
	private	byte[]     dc_bit_bytes = null;
	private	long       dc_bit_value = 0;
	private	String     dc_bit_hex   = null;
	private	int     dc_bit_tot      = 0;
	private	int     dc_bit_byte_len = 0;
	private	int     dc_bit_fill     = 0;
	private	int     dcb_len = 0;
	private	int     dcb_pad = 0;
	private	String  dcb_bin = null;
	private	String  dcc_text = null;
	private	char    dcc_quote = ' ';
	private	int     dcc_len  = 0;
	private	int     dcp_len  = 0;
	private	char    dcp_sign;
	private	int     dcx_len  = 0;
	private	boolean dc_first_field = true;  // is this first dc field
	private	boolean dc_lit_ref = false;
	private	boolean dc_lit_gen = false;
	private	int     dc_lit_index_start = 0;
	private	String  dc_field = null;
	private	char    dc_type  = ' '; // ds/ds field type char
	private	byte    dc_attr_elt = sym_attr_elt_def; // ds/dc explicit length field type char
	private	boolean dcv_type = false;
	private	boolean dca_ignore_refs = false;
	private	char    dc_type_sfx = ' ';
	private	String  fp_text  = null; // RPI-790 fp text for use by DFP
	private	double  fp_log2  = Math.log(2);
	private	double  fp_log10 = Math.log(10);
	private	MathContext fp_context = null;
	private	BigDecimal fp_big_dec1 = BigDecimal.ZERO;
	private	BigDecimal fp_big_dec2 = BigDecimal.ZERO;
//	private	BigDecimal fp_big_dec3 = BigDecimal.ZERO;
	private	BigDecimal fp_bd_two  = BigDecimal.valueOf(2);
	private	byte[] fp_big_byte = null;
	private	byte[] fp_data_byte = new byte[16];
	private	ByteBuffer fp_data_buff = ByteBuffer.wrap(fp_data_byte,0,16);
	private				 BigInteger fp_big_int1 = BigInteger.ZERO;
//	private	final static BigInteger fp_big_int2 = BigInteger.ZERO;
	private	final static BigInteger fp_big_int_one_bits = BigInteger.ONE.shiftLeft(113).subtract(BigInteger.ONE);
	private	final static BigInteger fp_big_int_lx_man_bits = BigInteger.ONE.shiftLeft(112).subtract(BigInteger.ONE); // RPI-821
//	private	final static BigInteger fp_big_int_dh_man_bits = BigInteger.ONE.shiftLeft(56).subtract(BigInteger.ONE);  // RPI-821
	private	int    fp_int1 = 0;
	private	int    fp_round_bit = 0;
	private	final static int  fp_int_eb_one_bits  = 0xffffff;
	private	final static int  fp_int_eb_man_bits  = 0x7fffff;
	private	final static int  fp_int_eh_man_bits  = 0xffffff;
	private				 long fp_long1 = 0;
	private	final static long fp_long_db_one_bits = ((long)(1) << 53) - 1;
	private	final static long fp_long_db_man_bits = ((long)(1) << 52) - 1;
	private	final static long fp_long_dh_man_bits = ((long)(1) << 56) - 1;
	private	int    dc_index = 0;
	private	int    dc_data_start = 0;
	private	int    dc_dup   = 0;
	private	int    dc_dup_loc = 0; // rel offset for dup of a/v/s data with loc_ctr
	private	int    dc_len   = 0;
	private	int    dc_scale = 0;
	private	String  dc_digits = "";       // RPI-777 digits in P or Z value
	private	boolean dc_dec_point = false; // RPI-777 decimal point found in P/Z
	private	int     dc_dec_scale = 0;     // RPI-777 decimals to right of poind
	private	int    dc_exp   = 0;
	private	int    dc_first_len = 0;
	private	int    dc_first_dup = 9; // RPI-1200
//	private	int    dc_first_loc = 0;
	private	char   dc_first_type = ' ';  // dc first field type char
	private	char   dc_first_type_sfx = ' '; // dc first type suffix  RPI-790
	private	int    dc_first_scale = 0;   // RPI-481
//	private	byte   dc_first_attr_elt = ' '; // dc first explicit length field type char
	private	String dc_hex = null;
//	private	byte[]     dc_data_byte = (byte[])Array.newInstance(byte.class,256);
//	private	ByteBuffer dc_data = ByteBuffer.wrap(dc_data_byte,0,256);
	private	int dc_type_index = 0;
	private	BigDecimal  dc_bd_val = null;
	private	BigInteger  dc_bi_val = null;
	private	byte[]      dc_byte_val = null;
	private	boolean     dcc_ascii_req = false;

	/*
	 * EXEC CICS DFHRESP(type) literal data substitution per RPI-626
	 */
	private final static String[] dfhresp_type = {
			"NORMAL)",          // 1 - =F'0'
			"ERROR)",           // 2 - =F'1'
			"TERMIDERR)",       // 3 - =F'11' RPI-928
			"FILENOTFOUND)",    // 4 - =F'12' RPI-687
			"DSIDERR)",         // 5 - =F'12' RPI-905
			"NOTFND)",          // 6 - =F'13' RPI-687, RPI-690
			"DUPREC)",          // 7 - =F'14' RPI-687
			"DUPKEY)",          // 8 - =F'15' RPI-687
			"INVREQ)",          // 9 - =F'16'
			"IOERR)",           //10 - =F'17' RPI-928
			"NOSPACE)",         //11 - =F'18' RPI-687
			"NOTOPEN)",         //12 - =F'19' RPI-687
			"ENDFILE)",         //13 - =F'20' RPI-687
			"ILLOGIC)",         //14 - =F'21' RPI-729
			"LENGERR)",         //15 - =F'22'
			"ITEMERR)",         //16 - =F'26' RPI-662
			"PGMIDERR)",        //17 - =F'27'
			"TRANSIDERR)",      //18 - =F'28' RPI-928
			"ENDDATA)",         //19 - =F'29' RPI-928
			"EXPIRED)",         //20 - =F'31' RPI-751
			"MAPFAIL)",         //21 - =F'36' RPI-841
			"INVMPSZ)",         //22 - =F'38' RPI-841
			"OVERFLOW)",        //23 - =F'40' RPI-841
			"QIDERR)",          //24 - =F'44' RPI-662
			"ENQBUSY)",         //25 - =F'55' RPI-951
			"ENVDEFERR)",       //26 - =F'56' RPI-928
			"NOTALLOC)",        //27 - =F'61' RPI-1079
			"SUPPRESSED)",      //28 - =F'72' RPI-1057
			"END)",             //29 - =F'83' RPI-1057
			"DISABLED)",        //30 - =F'84' RPI-687
			"ACTIVITYERR)",     //31 - =F'109' RPI-1168
			"CONTAINERERR)",    //32 - =F'110' RPI-1168
			"TOKENERR)",        //33 - =F'112' RPI-1168
			"CHANNELERR)",      //34 - =F'122' RPI-1168
	};
	private final static String[] dfhresp_lit = {
			"=F'0'",           // 1 "NORMAL)"
			"=F'1'",           // 2 "ERROR)"
			"=F'11'",          // 3 "TERMIDERR"     RPI-928
			"=F'12'",          // 4 "FILENOTFOUND)" RPI-687
			"=F'12'",          // 5 "DSIDERR"       RPI-905
			"=F'13'",          // 6 "NOTFND)" RPI-687, RPI-690
			"=F'14'",          // 7 "DUPREC)" RPI-687
			"=F'15'",          // 8 "DUPKEY)" RPI-687
			"=F'16'",          // 9 "INVREQ)"
			"=F'17'",          //10 "IOERR"    RPI-928
			"=F'18'",          //11 "NOSPACE)" RPI-687
			"=F'19'",          //12 "NOTOPEN)" RPI-687
			"=F'20'",          //13 "ENDFILE)" RPI-687
			"=F'21'",          //14 "ILLOGIC)" RPI-729
			"=F'22'",          //15 "LENGERR)"
			"=F'26'",          //16 "ITEMERR)" RPI-662
			"=F'27'",          //17 "PGMIDERR)"
			"=F'28'",          //18 "TRANSIDERR"  RPI-928
			"=F'29'",          //19 "ENDDATA"     RPI-928
			"=F'31'",          //20 "EXPIRED)"  RPI-751
			"=F'36'",          //21 "MAPFAIL)"  RPI-841
			"=F'38'",          //22 "INVMPSZ)"  RPI-841
			"=F'40'",          //23 "OVERFLOW)" RPI-841
			"=F'44'",          //24 "QIDERR)"   RPI-662
			"=F'55'",          //25 "ENQBUSY)"  RPI-951
			"=F'56'",          //26 "ENVDEFERR)" RPI-928
			"=F'61'",          //27 "NOTALLOC)"  RPI-1079
			"=F'72'",          //28 "SUPPRESSED)" RPI-1057
			"=F'83'",          //29 "END)"      RPI-1057
			"=F'84'",          //30 "DISABLED)" RPI-687
			"=F'109'",         //31 "ACTIVITYERR)"  RPI-1168
			"=F'110'",         //32 "CONTAINERERR)" RPI-1168
			"=F'112'",         //33 "TOKENERR)"     RPI-1168
			"=F'122'",         //33 "CHANNELERR)",  RPI-1168
	};
	/*
	 * EXEC CICS DFHVALUE(type) literal substitution
	 */
	private final static String[] dfhvalue_type = {
			"NOTAPPLIC)",       // 1 - =F'1'
			"VSAM)",            // 2 - =F'3'
			"ESDS)",            // 3 - =F'5'
			"KSDS)",            // 4 - =F'6'
			"RRDS)",            // 5 - =F'7'
			"BASE)",            // 6 - =F'10'
			"PATH)",            // 7 - =F'11'
			"FIXED)",           // 8 - =F'12'
			"VARIABLE)",        // 9 - =F'13'
			"OPEN)",            //10 - =F'18'
			"CLOSED)",          //11 - =F'19'
			"ENABLED)",         //12 - =F'23'
			"DISABLED)",        //13 - =F'24'
			"UNENABLED)",       //14 - =F'33'
			"READABLE)",        //15 - =F'35'
			"NOTREADABLE)",     //16 - =F'36'
			"UPDATABLE)",       //17 - =F'37'
			"NOTUPDATABLE)",    //18 - =F'38'
			"BROWSABLE)",       //19 - =F'39'
			"NOTBROWSABLE)",    //20 - =F'40'
			"ADDABLE)",         //21 - =F'41'
			"NOTADDABLE)",      //22 - =F'42'
			"DELETABLE)",       //23 - =F'43'
			"NOTDELETABLE)",    //24 - =F'44'
			"VRRDS)",           //25 - =F'732'
	};
	private final static String[] dfhvalue_lit = {
			"=F'1'",            // 1 "NOTAPPLIC)"
			"=F'3'",            // 2 "VSAM)"
			"=F'5'",            // 3 "ESDS)"
			"=F'6'",            // 4 "KSDS)"
			"=F'7'",            // 5 "RRDS)"
			"=F'10'",           // 6 "BASE)"
			"=F'11'",           // 7 "PATH)"
			"=F'12'",           // 8 "FIXED)"
			"=F'13'",           // 9 "VARIABLE)"
			"=F'18'",           //10 "OPEN)"
			"=F'19'",           //11 "CLOSED)"
			"=F'23'",           //12 "ENABLED)"
			"=F'24'",           //13 "DISABLED)"
			"=F'33'",           //14 "UNENABLED)"
			"=F'35'",           //15 "READABLE)"
			"=F'36'",           //16 "NOTREADABLE)"
			"=F'37'",           //17 "UPDATABLE)"
			"=F'38'",           //18 "NOTUPDATABLE)"
			"=F'39'",           //19 "BROWSABLE)"
			"=F'40'",           //20 "NOTBROWSABLE)"
			"=F'41'",           //21 "ADDABLE)"
			"=F'42'",           //22 "NOTADDABLE)"
			"=F'43'",           //23 "DELETABLE)"
			"=F'44'",           //24 "NOTDELETABLE)"
			"=F'732'",          //25 "VRRDS)"
	};

	/**
	 * main is entry when executed from command line.<br>
	 * Create instance of az390 class and pass parameters to az390 like z390 does.
	 *
	 * @param args
	 */
	public static void main(final String[] args)
	{
		final az390 pgm = new az390();
		pgm.init_az390(args,null);
		pgm.process_az390();
	}

	/**
	 * Initialize z390 when called from mz390 to receive BAL directly and share the symbol table with mz390.
	 *
	 * @param args
	 * @param z390_log
	 * @param mz390_systerm_file
	 * @param mz390_stats_file
	 */
	public void start_az390_thread(final String[] args, final JTextArea z390_log, final RandomAccessFile mz390_systerm_file, final RandomAccessFile mz390_stats_file)
	{
		mz390_call = true;
		init_az390(args,null);
		tz390.systerm_file = mz390_systerm_file; // share the ERR file
		tz390.systerm_prefix = tz390.left_justify(tz390.pgm_name,9) + " AZ390 ";
		tz390.stats_file = mz390_stats_file;
		tz390.init_codepage(tz390.codepage);
		az390_thread = new Thread(this);
		az390_running = true;
		az390_thread.start();
		set_sym_lock("az390 startup");    // proceed to waiting for bal and lock sym table
		lookahead_mode  = true; // lookahead done during mz390 load_mac
		reset_sym_lock();  // allow use of DS/DC/EQU during lookahead RPI-448
		cur_esd = tz390.opt_maxesd - 1; // lookahead dummy section # for all ds/dc/equ
		cur_esd_sid = tz390.opt_maxsym-1;
		sym_type[tz390.opt_maxsym-1] = sym_cst;
	}

	/**
	 * Save xref file names and error counts for cross reference at end of PRN.
	 *
	 * @param mac_file_path
	 * @param mac_file_errors
	 */
	public void finish_az390(String[] mac_file_path,int[] mac_file_errors) {
		// xref_file_path   = mac_file_path;
		// xref_file_errors = mac_file_errors;
	}

	/**
	 *
	 */
	public void run()
	{
		if (az390_thread == Thread.currentThread()) {
			if (tz390.opt_trap) { // RPI-423
				try {
					process_az390();
				} catch (final Exception e) {
					abort_error(158, "Internal system exception - " + e.toString());
				}
			} else {
				process_az390();
			}
			lock.lock(); // RPI-415
			try {
				az390_running = false;
				lock_condition.signalAll();
			} catch (final Exception e) {
				abort_error(159, "Thread ending interruption");
			} finally {
				lock.unlock();
			}
		}
	}

	/**
	 * Assemble BAL source file into relocateable OBJ file and generate optional PRN file.
	 */
	private void process_az390()
	{
		// Notes:
		// 1. az390 may be called from:
		//    a. z390 GUI Windows command via main();
		//    b. Windows command prompt via main();
		//    c. mz390 call via process_az390_call();
		// 2. If called from z390 GUI Windows command, the console output will be redirected to to the z390 GUI log.
		// 3. If called from mz390 via process_az390_call, az390 process will run on separate thread and the
		//    get_bal_line and receive_bal_line methods will synchronize passing BAL record from mz390 to az390 process.

		if (tz390.opt_trap) {
			try {
				load_bal();
				process_bal();
			} catch (final Exception e) {
				abort_error(79,"internal system exception - " + e.toString());
			}
		} else {
			load_bal();
			process_bal();
		}
		exit_az390();
	}

	/**
	 * Initialize az390<br>
	 * <ol><li>Initialize log routing.
	 *     <li>Set options.
	 *     <li>Compile regular expression parsers.
	 *     <li>Open BAL and OBJ buffered I/O files.
	 *     <li>Initialize ASCII/EBCDIC translation table.</ol>
	 *
	 * @param args
	 * @param log_text
	 */
	private void init_az390(final String[] args, final JTextArea log_text)
	{
		if (log_text != null) {
			z390_log_text = log_text;
		}

		final InfoOS infoOS = InfoOS.getInstance();
		if (!infoOS.isCorrectJava()) {
			abort_error(88, infoOS.getMessageIncorrectJavaVersion());
		}

		tz390 = new tz390();
		tz390.init_tz390();
		tz390.init_options(args,tz390.bal_type);

		if (!mz390_call) {
			tz390.open_systerm("AZ390");
			tz390.init_codepage(tz390.codepage);
		} else {
			tz390.systerm_start = System.currentTimeMillis();
			tz390.started_msg = mz390_started_msg;
		}
		if (!tz390.init_opcode_name_keys()) {
			abort_error(87, "Opcode key search table exceeded");
		}
		init_arrays();
		init_push_pop();
		open_files();
		tz390.force_nocon = true;
		put_log(tz390.started_msg);
		tz390.force_nocon = false;
		put_copyright();
		compile_patterns();
		tod_time_limit = tz390.max_time_seconds * 1000 + tod_start;
	}

	/**
	 * Initialize push/pop using and print.
	 */
	private void init_push_pop()
	{
		using_start[0] = 0;
		using_end[  0] = 0;
		print_on[   0] = true;
		print_gen[  0] = true;
		print_data[ 0] = false;
	}

	/**
	 * Initialize arrays using tz390.opt_max???
	 */
	@SuppressWarnings("unchecked") // for sym_xref + lit_xref
	private void init_arrays()
	{
		// opt_maxcall - maximum call/push/using
		push_cur_use_start	= (int[])Array.newInstance(int.class,tz390.opt_maxcall);
		push_cur_use_end	= (int[])Array.newInstance(int.class,tz390.opt_maxcall);
		use_lab				= new String[tz390.opt_maxcall];
		use_base_esd		= (int[])Array.newInstance(int.class,tz390.opt_maxcall);
		use_base_loc		= (int[])Array.newInstance(int.class,tz390.opt_maxcall);
		use_base_len		= (int[])Array.newInstance(int.class,tz390.opt_maxcall);
		use_reg				= (int[])Array.newInstance(int.class,tz390.opt_maxcall);
		use_reg_loc			= (int[])Array.newInstance(int.class,tz390.opt_maxcall);
		using_start			= (int[])Array.newInstance(int.class,tz390.opt_maxcall);
		using_end			= (int[])Array.newInstance(int.class,tz390.opt_maxcall);
		print_on			= (boolean[])Array.newInstance(boolean.class,tz390.opt_maxcall);
		print_gen			= (boolean[])Array.newInstance(boolean.class,tz390.opt_maxcall);
		print_data			= (boolean[])Array.newInstance(boolean.class,tz390.opt_maxcall);
		xref_file_name		= new String[tz390.opt_maxfile];
		xref_file_type		= new char[tz390.opt_maxfile]; // RPI-549 + or =
	//	xref_file_path		= new String[tz390.opt_maxfile];  // RPI-425
		xref_file_errors	= (int[])Array.newInstance(int.class,tz390.opt_maxfile);

		// opt_maxesd - maximum sections
		esd_sid		= (int[])Array.newInstance(int.class,tz390.opt_maxesd);
		esd_base	= (int[])Array.newInstance(int.class,tz390.opt_maxesd); // RPI-301
		esd_loc		= (int[])Array.newInstance(int.class,tz390.opt_maxesd); // RPI-778 cur loc within section for continue

		// opt_maxline - maximum BAL loaded in memory
		bal_line_text			= new String[tz390.opt_maxline]; //logical bal line from 1 or more physical lines
		bal_line_num			= (int[])Array.newInstance(int.class,tz390.opt_maxline); //starting physical line #
		bal_line_xref_file_num	= (int[])Array.newInstance(int.class,tz390.opt_maxline); //starting physical line #
		bal_line_xref_file_line	= (int[])Array.newInstance(int.class,tz390.opt_maxline); //starting physical line #

		// opt_maxrld - relocation definitions
		rld_fld_esd	= (int[])Array.newInstance(int.class,tz390.opt_maxrld);
		rld_fld_loc	= (int[])Array.newInstance(int.class,tz390.opt_maxrld);
		rld_fld_len	= (byte[])Array.newInstance(byte.class,tz390.opt_maxrld);
		rld_fld_sgn	= (char[])Array.newInstance(char.class,tz390.opt_maxrld);
		rld_xrf_esd	= (int[])Array.newInstance(int.class,tz390.opt_maxrld);

		// opt_maxsym - symbols and literals
		sym_name		= new String[tz390.opt_maxsym];
		sym_def			= (int[])Array.newInstance(int.class,tz390.opt_maxsym);
		sym_type		= (byte[])Array.newInstance(byte.class,tz390.opt_maxsym);
		sym_dc_type		= (byte[])Array.newInstance(byte.class,tz390.opt_maxsym); // RPI-790
		sym_dc_type_sfx	= (byte[])Array.newInstance(byte.class,tz390.opt_maxsym); // RPI-790
		sym_attr		= (byte[])Array.newInstance(byte.class,tz390.opt_maxsym);
		sym_attr_elt	= (byte[])Array.newInstance(byte.class,tz390.opt_maxsym);
		sym_attrp		= (int[])Array.newInstance(int.class,tz390.opt_maxsym);
		sym_scale		= (int[])Array.newInstance(int.class,tz390.opt_maxsym);
		sym_attra		= new String[tz390.opt_maxsym];
		sym_esd			= (int[])Array.newInstance(int.class,tz390.opt_maxsym);
		sym_loc			= (int[])Array.newInstance(int.class,tz390.opt_maxsym);
		sym_max_loc		= (int[])Array.newInstance(int.class,tz390.opt_maxsym);
		sym_len			= (int[])Array.newInstance(int.class,tz390.opt_maxsym);
	//	sym_sect_type	= (int[])Array.newInstance(int.class,tz390.opt_maxsym);
		sym_sect_prev	= (int[])Array.newInstance(int.class,tz390.opt_maxsym);
		sym_sect_next	= (int[])Array.newInstance(int.class,tz390.opt_maxsym);
		sym_xref		= (TreeSet<Integer>[])Array.newInstance(TreeSet.class,tz390.opt_maxsym);
		lit_name		= new String[tz390.opt_maxsym];
		lit_pool		= (int[])Array.newInstance(int.class,tz390.opt_maxsym);
		lit_line		= (int[])Array.newInstance(int.class,tz390.opt_maxsym);
		lit_line_loc	= (int[])Array.newInstance(int.class,tz390.opt_maxsym);
		lit_esd			= (int[])Array.newInstance(int.class,tz390.opt_maxsym);
		lit_loc			= (int[])Array.newInstance(int.class,tz390.opt_maxsym);
		lit_len			= (int[])Array.newInstance(int.class,tz390.opt_maxsym);
		lit_dup			= (int[])Array.newInstance(int.class,tz390.opt_maxsym); // RPI-1200
		lit_scale		= (int[])Array.newInstance(int.class,tz390.opt_maxsym); // RPI-790
		lit_dc_type		= (byte[])Array.newInstance(byte.class,tz390.opt_maxsym); // RPI-790
		lit_dc_type_sfx	= (byte[])Array.newInstance(byte.class,tz390.opt_maxsym); // RPI-790
		lit_gen			= (byte[])Array.newInstance(byte.class,tz390.opt_maxsym);
	//	lit_def			= (int[])Array.newInstance(int.class,tz390.opt_maxsym);
		lit_xref		= (TreeSet<Integer>[])Array.newInstance(TreeSet.class,tz390.opt_maxsym);
	}

	/**
	 * Compile regular expression parsers.
	 */
	private void compile_patterns()
	{
		// label_pattern  .lll
		try {
			label_pattern = Pattern.compile(
				"([a-zA-Z$@#_][a-zA-Z0-9$@#_]*)"   // RPI-253
				);
		} catch (Exception e) {
			abort_error(1,"label pattern errror - " + e.toString());
		}

		// extrn and entry pattern
		try {
			extrn_pattern = Pattern.compile(
				"([a-zA-Z$@#_][a-zA-Z0-9$@#_]*)" // RPI-253
				+"|([,\\s])" //RPI181
				);
		} catch (Exception e) {
			abort_error(1,"extrn pattern errror - " + e.toString());
		}

		// expression pattern
		//	1. B'01', C'ABC', X'0F' sdts
		//	2. USING label.
		//	3. symbolst
		//	3. + - * / ( ) L'
		//
		try {
			exp_pattern = Pattern.compile(
				"([0-9]+([.][0-9]*)*([eE]([\\+]|[\\-])*[0-9]+)*)" // RPI-232 fp/int
				+ "|([\\s,'\\+\\-\\*\\/\\(\\)=])"        // RPI-159, RPI-181
				+ "|([bB]['][0|1]+['])"                  // sdt B'01'
				+	"|([cC][aAeE]*[']([^']|(['][']))*['])" // ebcdic/ascii mode //RPI-270
				+	"|([cC][!]([^!]|([!][!]))*[!])"        // ebcdic always
				+	"|([cC][\"]([^\"]|([\"][\"]))*[\"])"   // ascii  always
				+	"|([xX]['][0-9a-fA-F]+['])"            // sdt X'1F'
				+ "|([iIlLsS]['])"                       // length op  RPI-9 RPI-790 add I',S' ops
				+	"|([a-zA-Z$@#_][a-zA-Z0-9$@#_]*[\\.]?)" // labeled using or symbol  RPI-253
				);
		} catch (Exception e) {
			abort_error(2,"expression pattern errror - " + e.toString());
		}

		// define exp_class with operator precedence classes indexed by expression operator
		exp_op_class['+'] = 1;
		exp_op_class['-'] = 1;
		exp_op_class['*'] = 2;
		exp_op_class['/'] = 2;
		exp_op_class['('] = 3;
		exp_op_class[')'] = 4;
		exp_op_class['I'] = 5; // Integer pfx // RPI-790
		exp_op_class['L'] = 5; // length  pfx
		exp_op_class['S'] = 5; // Scale   pfx // RPI-790
		exp_op_class['U'] = 5; // unary   pfx
		exp_op_class[' '] = 6;
		exp_op_class[','] = 6;
		exp_op_class['~'] = 6;

		// dcc_sq_pattern for quoted string:
		//	1.  '...''...'
		try {
			dcc_sq_pattern = Pattern.compile(
				"([']['])"
				+ "|([&][&])" //RPI-192
				+ "|(['&])"   //RPI-192
				+ "|([^'&]+)"
				);
		} catch (final Exception e) {
			abort_error(1,"dcc pattern errror - " + e.toString());
		}

		// dcc_dq_pattern for quoted string:
		//	1.  "...""..."
		try {
			dcc_dq_pattern = Pattern.compile(
				"([\"][\"])"
				+ "|([']['])" // RPI-192
				+ "|([&][&])" // RPI-192
				+ "|([\"'&])" // RPI-192
				+ "|([^\"]+)"
				);
		} catch (final Exception e) {
			abort_error(1,"dcc pattern errror - " + e.toString());
		}

		// dcc_eq_pattern for quoted string:
		//	1.  !...!!...!
		try {
			dcc_eq_pattern = Pattern.compile(
				"([!][!])"
				+ "|([']['])" // RPI-192
				+ "|([&][&])" // RPI-192
				+ "|([!'&])"  // RPI-192
				+ "|([^!]+)"
				);
		} catch (Exception e) {
			abort_error(1,"dcc pattern errror - " + e.toString());
		}
	}

	/**
	 * Set trace file name.<br>
	 * Open OBJ and PRN files.
	 */
	private void open_files()
	{
		if (tz390.trace_file_name == null) {  // RPI-719
			tz390.trace_file_name = tz390.dir_trc + tz390.pgm_name + tz390.tra_type;
		} else {
			tz390.trace_file_name = tz390.trace_file_name + tz390.tra_type;
		}
		if (tz390.opt_obj) {  // RPI-694
			try {
				obj_file = new RandomAccessFile(tz390.get_first_dir(tz390.dir_obj) + tz390.pgm_name + tz390.obj_type,"rw");
			} catch (final Exception e) {
				abort_error(4, "I/O error on obj open - " + e.toString());
			}
		}
		if (tz390.opt_list) {
			final String prn_file_name = tz390.get_file_name(tz390.dir_prn,tz390.pgm_name,tz390.prn_type); // RPI-866
			try {
				prn_file = new File(prn_file_name); // RPI-908 catch null error
				prn_file_buff = new BufferedWriter(new FileWriter(prn_file));
			} catch (final Exception e) {
				abort_error(4, "I/O error on prn open - " + e.toString());
			}
		}
	}

	/**
	 * Assemble BAL source into OBJ relocatable object code file.
	 */
	private void process_bal()
	{
		resolve_symbols();
		list_bal_line = true; // RPI-891
		gen_obj_esds();
		gen_obj_text();
		gen_obj_rlds();
		gen_obj_end(); // RPI-1197
		if (tz390.opt_list) {
			list_bal_line = true; // RPI-891
			gen_sym_list();
			gen_lit_xref_list(); // RPI-198
		}
	}

	/**
	 * If errors occurred during loading of BAL repeat symbol update passes until there
	 * are no errors or minimum error or max passes are reached.
	 */
	private void resolve_symbols()
	{
		reset_lits();
		tz390.reset_opsyn();
		if (az390_errors > 0 || sect_change) { // RPI-605
			int prev_az390_errors = az390_errors + 1;
			while (cur_pass <= tz390.opt_maxpass + tot_loc_stmt // RPI-920
					&& (sect_change
						|| (az390_errors > 0 && az390_errors < prev_az390_errors) // RPI-632 repeat until 0 or no change
						|| cur_pass <= 1  // RPI-264, RPI-632 was <=2
						)
					) {
				report_label_changes = true; // RPI-632
				report_equ_changes   = true; // RPI-632
				prev_az390_errors = az390_errors;
				az390_errors = 0;
				az390_rc = 0; // RPI-1062
				cur_pass++;
				update_symbols();
				if (tz390.opt_tracea) {
					String pass_msg = "PASS " + cur_pass + "  TOTAL ERRORS " + az390_errors;
					tz390.put_trace(pass_msg);
					tz390.put_systerm(pass_msg); // RPI-605
				}
				reset_lits();
				tz390.reset_opsyn();
			}
		}
		az390_errors = 0;  // RPI-920 restore from prev.
		az390_rc = 0; // RPI-1062
		bal_abort = false; // RPI-920 prevent obj ESD error
		cur_pass++; // increment to last pass
	}

	/**
	 * Scan BAL source and update symbols.
	 */
	private void update_symbols()
	{
		loc_ctr = 0;
		cur_lit_pool = 1;
		cur_esd = 0;
		bal_eof = false;
		end_found = false;
		bal_line_index = 1;
		while (!bal_eof) {
			check_timeout();
			if  (bal_line_index == tot_bal_line) {
				bal_eof = true;
			} else {
				bal_line = bal_line_text[bal_line_index];
				xref_bal_index = bal_line_index;
				parse_bal_line();
				bal_op_index = find_bal_op();
				if (bal_op_index > -1) {  // RPI-274
					process_bal_op();
				}
				bal_line_index++;
			}
		}
		if (!end_found) {
			process_end();
		}
	}

	/**
	 * Check if timeout expired.
	 */
	private void check_timeout()
	{
		if (tz390.opt_time) {
			final long tod_end = new Date().getTime();
			if (tod_end > tod_time_limit) {
				abort_error(80, "Time limit exceeded");
			}
		}
	}

	/**
	 * Update each section starting address and max length, and reset current length and current esd_loc.<br>
	 * <br>
	 * Notes:
	 * <ol><li>If any section start address or max length changes issue error to force additional passes.
	 *     <li>sym_cst CSECT's start at 0 and are contiguous within LOCTR's
	 *     <li>Each new CSECT is aligned to *8
	 *     <li>sym_dst DSECT's always start at 0
	 *     <li>Set esd_base to root section for cst, dst, and loctors</ol>
	 */
	private void update_sects()
	{
		if (tot_loc_stmt > 0 && cur_pass == 1) { // RPI-632
			sect_change_error();  // RPI-632 force first 2 passes if LOCTR found
		} else {
			sect_change = false;
		}
		int cst_ctr = 0;
		int index = 1;
		while (index <= tot_esd) {
			cur_sid = esd_sid[index];
			if (sym_type[     cur_sid] == sym_cst
			 && sym_sect_prev[cur_sid] == 0) {
				// new CSECT/RSECT aligned to double word
				if (!tz390.opt_thread) {
					cst_ctr = 0; // RPI-1186 NOTHREAD starts all CSECTS at 0
				}
				loc_ctr = (cst_ctr+7)/8*8;  // RPI-632
				esd_loc[index] = loc_ctr; // RPI-778
				if (sym_loc[cur_sid] != loc_ctr) {
					sect_change_error();;
					bal_abort = false; // force all change errors
					log_error(91, "csect start change error - "
							+ sym_name[cur_sid]
							+ " old start=" + tz390.get_hex(sym_loc[cur_sid],6)
							+ " new start=" + tz390.get_hex(loc_ctr,6));
				}
				sym_loc[cur_sid] = loc_ctr;
				if (sym_sect_next[cur_sid] == 0) {
					loc_ctr = (loc_ctr + sym_len[cur_sid]+7)/8*8;
				} else {
					loc_ctr = loc_ctr + sym_len[cur_sid];
				}
				if (sym_max_loc[cur_sid] != loc_ctr && tot_esd > 1) {
					sect_change_error();
					bal_abort = false; // force all change errors
					log_error(92, "csect end   change error - "
							+ sym_name[cur_sid]
							+ " old end =" + tz390.get_hex(sym_max_loc[cur_sid],6)
							+ " new end =" + tz390.get_hex(loc_ctr,6));
				}
				sym_max_loc[cur_sid] = loc_ctr;
				sym_len[cur_sid] = loc_ctr - sym_loc[cur_sid];
				update_loctrs();
				sym_len[cur_sid] = 0;
				cst_ctr = loc_ctr; // save end of CSECT
			} else if (sym_type[     cur_sid] == sym_dst
					&& sym_sect_prev[cur_sid] == 0) {
				loc_ctr = 0;
				sym_loc[esd_sid[index]] = loc_ctr;
				esd_loc[sym_esd[cur_sid]] = loc_ctr; // RPI-778
				loc_ctr = loc_ctr + sym_len[cur_sid];
				if (sym_max_loc[cur_sid] != loc_ctr) {
					sect_change_error();
					bal_abort = false; // force all change errors
					log_error(93, "dsect end   change error - "
							+ sym_name[cur_sid]
							+ " old end  =" + tz390.get_hex(sym_max_loc[cur_sid],6)
							+ " new end  =" + tz390.get_hex(loc_ctr,6));
				}
				sym_max_loc[cur_sid] = loc_ctr;
				sym_len[cur_sid] = loc_ctr - sym_loc[cur_sid];
				update_loctrs();
				sym_len[cur_sid] = 0;
			}
			index++;
		}
		loc_ctr = 0;
	}

	/**
	 * Set sect_change.
	 */
	private void sect_change_error()
	{
		sect_change = true;  // RPI-632
	}

	/**
	 * Update loctr sections with contiguous starting addresses from CSECT/DSECT and
	 * issue errors if any start address or length changes and reset length for next pass.
	 */
	private void update_loctrs()
	{
		int index = cur_sid;
		while (sym_sect_next[index] > 0) {
			index = sym_sect_next[index];
			if (sym_loc[index] != loc_ctr) {
				sect_change_error();
				bal_abort = false; // force all change errors
				log_error(94, "loctr section start change error - "
						+ sym_name[index]
						+ " old start=" + tz390.get_hex(sym_loc[cur_sid],6)
						+ " new start=" + tz390.get_hex(loc_ctr,6)
						);
			}
			sym_loc[index] = loc_ctr;
			esd_loc[sym_esd[index]] = loc_ctr; // RPI-778
			loc_ctr = loc_ctr + sym_len[index];
			if (loc_ctr != sym_max_loc[index]) {
				sect_change_error();
				bal_abort = false; // force all change errors
				log_error(95, "loctr section end   change error - "
						+ sym_name[index]
						+ " old end  =" + tz390.get_hex(sym_max_loc[cur_sid],6)
						+ " new end  =" + tz390.get_hex(loc_ctr,6)
						);
			}
			sym_max_loc[index] = loc_ctr;
			sym_len[index] = 0;
		}
	}

	/**
	 * Reset lit_gen flags to force reallocation on each pass.
	 */
	private void reset_lits()
	{
		if (tot_lit > 0) {
			Arrays.fill(lit_gen,0,tot_lit,(byte)0); // RPI-411
		}
	}

	/**
	 * Write ESDs for CSECTS, EXTRNS, and ENTRIES to the OBJ file in ASCII hex and list on PRN if option LIST.
	 */
	private void gen_obj_esds()
	{
		xref_bal_index = -1;
		if (tot_esd > 0 && tz390.opt_list) {
			put_prn_line("External Symbol Definitions");
		}
		cur_esd = 1;
		while (cur_esd <= tot_esd) {
			if (sym_type[esd_sid[cur_esd]] == sym_cst // RPI-459
			 && sym_sect_prev[esd_sid[cur_esd]] == 0) {
				String esd_code = " ESD=" + tz390.get_hex(sym_esd[esd_sid[cur_esd]],4)
								+ " LOC=" + tz390.get_hex(sym_loc[esd_sid[cur_esd]],8)
								+ " LEN=" + tz390.get_hex(get_sym_len(esd_sid[cur_esd]),8)
								+ " TYPE=" + get_esd_type()
								+ " NAME=" + sym_name[esd_sid[cur_esd]];
				if (tz390.opt_list) {
					put_prn_line(esd_code);
				}
				put_obj_line(".ESD" + esd_code);
			}
			cur_esd++;
		}
		cur_esd = 1;
		while (cur_esd <= tot_esd) {
			if (sym_type[esd_sid[cur_esd]] != sym_cst
			 && sym_type[esd_sid[cur_esd]] != sym_dst
			 && sym_sect_prev[esd_sid[cur_esd]] == 0) {
				String esd_code = " ESD=" + tz390.get_hex(sym_esd[esd_sid[cur_esd]],4)
								+ " LOC=" + tz390.get_hex(sym_loc[esd_sid[cur_esd]],8)
								+ " LEN=" + tz390.get_hex(get_sym_len(esd_sid[cur_esd]),8)
								+ " TYPE=" + get_esd_type()
								+ " NAME=" + sym_name[esd_sid[cur_esd]];
				if (tz390.opt_list) {
					put_prn_line(esd_code);
				}
				put_obj_line(".ESD" + esd_code);
			}
			cur_esd++;
		}
	}

	/**
	 * Return ESD type.
	 *
	 * @return
	 */
	private String get_esd_type()
	{
		String esd_type = sym_type_desc[sym_type[esd_sid[cur_esd]]];
		if (esd_type.equals("REL")) {
			esd_type = "ENT";
		}
		return esd_type;
	}

	/**
	 * Generate object code for BAL instructions in CSECTs on final pass.
	 */
	private void gen_obj_text()
	{
		gen_obj_code = true;
		tz390.systerm_prefix = tz390.left_justify(tz390.pgm_name,9) + " " + "AZ390 "; // RPI-755 RPI-938 switch from mz390
		put_prn_line("Assembler Listing");
		loc_ctr = 0;
		cur_lit_pool = 1;
		cur_esd = 0;
		bal_eof = false;
		end_found = false;
		bal_line_index = 1;
		while (!bal_eof) {
			if  (bal_line_index == tot_bal_line) {
				bal_eof = true;
			} else {
				bal_line = bal_line_text[bal_line_index];
				xref_bal_index = bal_line_index;
				parse_bal_line();
				bal_op_index = find_bal_op();
				if (bal_op_index > -1) {  // RPI-274 OPYSN cancel -2
					process_bal_op();
				}
				bal_line_index++;
			}
		}
		if (!end_found) {
			if (tz390.opt_profile.length() == 0) {
				bal_line_index = tot_bal_line-1;
				if (mz390_abort) {  // RPI-433
					log_error(165, "Input truncated due to mz390 abort."); // RPI-935
				} else {
					list_bal_line = false; // RPI-1169
					process_end();         // RPI-1169
				}
			} else {
				list_bal_line = false; // RPI-891 no end stmt 3
				process_end();
			}
		}
		list_bal_line = true; // RPI-891 restore
	}

	/**
	 * Allocate or generate object code for BAL op.
	 */
	private void process_bal_op()
	{
		/*
		 * 1.  Note op_type index values must match op_name array values.
		 * 2.  Indexes < 100 and CNOP are machine instruction types RPI-743
		 * 3.  Indexes > 100 are assembler instructions
		 */
		loc_len = 0;
		exp_text  = bal_parms;
		exp_index = 0;
		obj_code = "";
		list_obj_code = "";
		hex_bddd1_loc = "      ";
		hex_bddd2_loc = "      ";
		if (gen_obj_code && tz390.opt_list) { // RPI-484
			list_bal_line = true;
		} else {
			list_bal_line = false;
		}
		loc_start = loc_ctr;
		list_obj_loc = loc_start; // RPI-265
		dc_lit_ref = false;  // RPI12
		dc_lit_gen = false;
		bal_op_ok = false;   // assume opcode undefined
		bal_label_ok = true;    // assume label updates ok RPI-451
		cur_sym_sect = false;   // assume RX/ABS label RPI-553
		int index = OpTypes.op_type[bal_op_index];
		if (index < tz390.max_ins_type || bal_op.equals("CNOP")) { // RPI-340 RPI-743
			if (index > 0 && mac_inline_level == 0) {
				check_private_csect(); // RPI-747
			}
			bal_lab_attr = tz390.ascii_to_ebcdic['I'];
		} else {
			bal_lab_attr = tz390.ascii_to_ebcdic['U'];
		}
		bal_lab_attr_elt = sym_attr_elt_def;
		if (mac_inline_level > 0
		 && index != mac_inline_op_macro  // MACRO
		 && index != mac_inline_op_mend) { // MEND
			index     = mac_inline_op_other; // RPI-581 print inline source
		}
		switch (index) {
		case 0:  // * comments
			bal_op_ok = true;
			if (bal_line.length() > 0 && bal_line.charAt(0) != '*') {
				log_error(190, "Comment must start with * in position 1.");  // RPI-609
			}
			if (gen_obj_code
			 && bal_line.length() > mcall_bal_index) {
				if (bal_line.substring(0,9).equals("*MCALL #=")) {
					if (bal_line.substring(mcall_lv_index,mcall_lv_index+5).equals("LV= 1")) { // RPI-891
						mac_call_first = true; // RPI-891 switching to GEN code
						list_bal_line = true;  // RPI-891
					} else if (!tz390.opt_mcall) {
						// suppress nested macro call listing
						list_bal_line = false; // RPI-891
					}
					if (!tz390.opt_mcall) { // RPI-511
						bal_line = bal_line.substring(mcall_bal_index); //strip * call prefix and level RPI-233 RPI-581
					}
				} else if (bal_line.substring(0,9).equals("*MEXIT #=")) {
					if (bal_line.substring(mcall_lv_index,mcall_lv_index+5).equals("LV= 1")) {
						mac_call_last = true; // RPI-891 switching to open code
					}
					if (!tz390.opt_mcall) {
						// suppress all macro exit listings
						list_bal_line = false; // RPI-891
					} else {
						list_bal_line = true;  // RPI-891
					}
				} else if (bal_line.substring(0,8).equals("* MZ390E")) {
					force_list_bal = true;
				}
			}
			break;
		case 1:  // "E" 8 PR oooo
			bal_op_ok = true;
			loc_ctr = (loc_ctr+1)/2*2;
			loc_start = loc_ctr;
			loc_len = 2;
			get_hex_op(1,4); // RPI-743 remove op check
			put_obj_text();
			break;
		case 2:  // "RR" 60  LR  oorr
			bal_op_ok = true;
			loc_ctr = (loc_ctr+1)/2*2;
			loc_start = loc_ctr;
			loc_len = 2;
			get_hex_op(1,2);
			get_hex_reg();
			if (obj_code.substring(0,2).equals("04")) { // SPM
				obj_code = obj_code.concat("0");
			} else {
				skip_comma();
				get_hex_reg();
			}
			check_end_parms();
			put_obj_text();
			break;
		case 3:  // "BRX" 16  BER oomr
			bal_op_ok = true;
			loc_ctr = (loc_ctr+1)/2*2;
			loc_start = loc_ctr;
			loc_len = 2;
			get_hex_op(1,3);  // BCR OP includes mask
			get_hex_reg();
			check_end_parms();
			put_obj_text();
			break;
		case 4:  // "I" 1 SVC 00ii
			bal_op_ok = true;
			loc_ctr = (loc_ctr+1)/2*2;
			loc_start = loc_ctr;
			loc_len = 2;
			get_hex_op(1,2);
			get_hex_byte();
			check_end_parms();
			put_obj_text();
			break;
		case 5:  // "RX" 52  L  oorxbddd
			bal_op_ok = true;
			loc_ctr = (loc_ctr+1)/2*2;
			loc_start = loc_ctr;
			loc_len = 4;
			get_hex_op(1,2);
			get_hex_reg();
			skip_comma();
			get_hex_xbddd();
			check_end_parms();
			put_obj_text();
			break;
		case 6:  // "BCX" 16 BE  oomxbddd
			bal_op_ok = true;
			loc_ctr = (loc_ctr+1)/2*2;
			loc_start = loc_ctr;
			loc_len = 4;
			get_hex_op(1,3); // BCX op includes mask
			get_hex_xbddd();
			check_end_parms();
			put_obj_text();
			break;
		case 7:  // "S" 43 SPM oo00bddd
			bal_op_ok = true;
			loc_ctr = (loc_ctr+1)/2*2;
			loc_start = loc_ctr;
			loc_len = 4;
			get_hex_op(1,4);
			if (bal_op.equals("CSCH")    // RPI-296
			 || bal_op.equals("IPK")
			 || bal_op.equals("PTLB")
			 || bal_op.equals("RSCH")
			 || bal_op.equals("SAL")
			 || bal_op.equals("SCHM")
			 || bal_op.equals("XSCH")) {  // RPI-277
				obj_code = obj_code + "0000";
			} else {
				get_hex_bddd2(true);
				check_end_parms();  // RPI-493 only if operands
			}
			put_obj_text();
			break;
		case 8:  // "DM" 1  DIAGNOSE 83000000
			bal_op_ok = true;
			loc_ctr = (loc_ctr+1)/2*2;
			loc_start = loc_ctr;
			loc_len = 4;
			get_hex_op(1,2);
			get_hex_zero(6); // RPI-946
			put_obj_text();
			break;
		case 9:  // "RSI" 4 BRXH  oorriiii
			bal_op_ok = true;
			loc_ctr = (loc_ctr+1)/2*2;
			loc_start = loc_ctr;
			loc_len = 4;
			get_hex_op(1,2);
			get_hex_reg();
			skip_comma();
			get_hex_reg();
			skip_comma();
			get_hex_rel();
			check_end_parms();
			put_obj_text();
			break;
		case 10:  // "RS" 25  oorrbddd
			bal_op_ok = true;
			loc_ctr = (loc_ctr+1)/2*2;
			loc_start = loc_ctr;
			loc_len = 4;
			get_hex_op(1,2);
			get_hex_reg();
			skip_comma();
			if (hex_op.compareTo("88") >=0
			 && hex_op.compareTo("8F") <= 0) {
				obj_code = obj_code + "0"; // r3=0 for shift
			} else {
				get_hex_reg();
				skip_comma();
			}
			get_hex_bddd2(true);
			check_end_parms();
			put_obj_text();
			break;
		case 11:  // "SI" 9 CLI  ooiibddd
			bal_op_ok = true;
			loc_ctr = (loc_ctr+1)/2*2;
			loc_start = loc_ctr;
			loc_len = 4;
			get_hex_op(1,2);
			get_hex_bddd2(true);
			skip_comma();
			get_hex_byte();
			check_end_parms();
			obj_code = obj_code.substring(0,2) + obj_code.substring(6,8) + obj_code.substring(2,6);
			put_obj_text();
			break;
		case 12:  // "RI" 37 IIHH  ooroiiii
			bal_op_ok = true;
			loc_ctr = (loc_ctr+1)/2*2;
			loc_start = loc_ctr;
			loc_len = 4;
			get_hex_op(1,2);
			get_hex_reg();
			get_hex_op(3,1);
			skip_comma();
			get_hex_rel();
			check_end_parms();
			put_obj_text();
			break;
		case 13:  // "BRCX" 31 BRE  oomoiiii
			bal_op_ok = true;
			loc_ctr = (loc_ctr+1)/2*2;
			loc_start = loc_ctr;
			loc_len = 4;
			get_hex_op(1,2);
			get_hex_op(4,1);
			get_hex_op(3,1);
			get_hex_rel();
			check_end_parms();
			put_obj_text();
			break;
		case 14:  // "RRE" 185  MSR oooo00rr
			bal_op_ok = true;
			loc_ctr = (loc_ctr+1)/2*2;
			loc_start = loc_ctr;
			loc_len = 4;
			get_hex_op(1,4);
			get_hex_zero(2);
			if (bal_op.equals("PALB")   // RPI-277
			 || bal_op.equals("PCKMO")  // RPI-1125
			 || bal_op.equals("PCC")) { // RPI-1125
				get_hex_zero(2);
			} else {
				get_hex_reg();
				if (exp_index >= exp_text.length()
				 || exp_text.charAt(exp_index) != ',') {
					obj_code = obj_code.concat("0"); // IPM,EFPC,SFPC,PTF RPI-817
				} else {
					skip_comma();
					get_hex_reg();
				}
				if (bal_op.charAt(0) == 'T'
				 && bal_op.length() == 4
				 && (bal_op.equals("TROO")
					|| bal_op.equals("TROT")
					|| bal_op.equals("TRTO")
					|| bal_op.equals("TRTT"))) {
					if (!bal_abort && exp_next_char(',')) { //RPI-577
						skip_comma();
						get_hex_reg(); // RPI-454
						obj_code = obj_code.substring(0,4) + obj_code.substring(8,9) + obj_code.substring(5,8);
					}
				}
				check_end_parms();
			}
			put_obj_text();
			break;
		case 15:  // RPI-206 "RRF1" MA?R, MS?R, MY?R (r1,r3,r2 maps to oooo1032)
			bal_op_ok = true;
			loc_ctr = (loc_ctr+1)/2*2;
			loc_start = loc_ctr;
			loc_len = 4;
			get_hex_op(1,4);
			get_hex_reg();
			get_hex_zero(1);
			skip_comma();
			get_hex_reg();
			skip_comma();
			get_hex_reg();
			check_end_parms();
			put_obj_text();
			break;
		case 16:  // "RIL" 6  BRCL  oomollllllll
			bal_op_ok = true;
			loc_ctr = (loc_ctr+1)/2*2;
			loc_start = loc_ctr;
			loc_len = 6;
			get_hex_op(1,2);
			get_hex_reg();
			get_hex_op(3,1);
			skip_comma();
			get_hex_long();
			check_end_parms();
			put_obj_text();
			break;
		case 17:  // "SS" 32  MVC oollbdddbddd
			bal_op_ok = true;
			loc_ctr = (loc_ctr+1)/2*2;
			loc_start = loc_ctr;
			loc_len = 6;
			get_hex_op(1,2);
			get_hex_llbddd();
			hex_bddd1     = hex_bddd;
			hex_bddd1_loc = hex_bddd_loc;
			obj_code = obj_code + hex_ll + hex_bddd1;
			skip_comma();
			get_hex_bddd2(true);
			check_end_parms();
			put_obj_text();
			break;
		case 18:  // "RXY" 76 MLG oorxbdddhhoo
			bal_op_ok = true;
			loc_ctr = (loc_ctr+1)/2*2;
			loc_start = loc_ctr;
			loc_len = 6;
			get_hex_op(1,2);
			get_hex_reg();
			skip_comma();
			get_hex_xbdddhh2();
			get_hex_op(3,2);
			check_end_parms();
			put_obj_text();
			break;
		case 19:  // "SSE" 5  LASP  oooobdddbddd
			bal_op_ok = true;
			loc_ctr = (loc_ctr+1)/2*2;
			loc_start = loc_ctr;
			loc_len = 6;
			get_hex_op(1,4);
			get_hex_bddd2(true);
			skip_comma();
			get_hex_bddd2(true);
			check_end_parms();
			put_obj_text();
			break;
		case 20:  // "RSY" 31  LMG r1,r3,s2 oorrbdddhhoo
			bal_op_ok = true;
			loc_ctr = (loc_ctr+1)/2*2;
			loc_start = loc_ctr;
			loc_len = 6;
			get_hex_op(1,2);
			get_hex_reg();
			skip_comma();
			get_hex_reg();
			skip_comma();
			get_hex_bdddhh2();
			get_hex_op(3,2);
			check_end_parms();
			put_obj_text();
			break;
		case 21:  // "SIY" 6  TMY  ooiibdddhhoo
			bal_op_ok = true;
			loc_ctr = (loc_ctr+1)/2*2;
			loc_start = loc_ctr;
			loc_len = 6;
			get_hex_op(1,2);
			get_hex_bdddhh2();
			skip_comma();
			get_hex_byte();
			obj_code = obj_code.substring(0,2) + obj_code.substring(8,10) + obj_code.substring(2,8);
			get_hex_op(3,2);
			check_end_parms();
			put_obj_text();
			break;
		case 22:  // "RSL" 1  TP  oor0bddd00oo
			bal_op_ok = true;
			loc_ctr = (loc_ctr+1)/2*2;
			loc_start = loc_ctr;
			loc_len = 6;
			get_hex_op(1,2);
			get_hex_llbddd();
			if (hex_ll.charAt(0) == '0') {
				hex_len1 = hex_ll.substring(1);
				hex_bddd1     = hex_bddd;
				hex_bddd1_loc = hex_bddd_loc;
			} else {
				log_error(69,"field 1 hex length > 16 = " + hex_ll);
			}
			obj_code = obj_code + hex_len1 + "0" + hex_bddd1 + "00";
			get_hex_op(3,2);
			check_end_parms();
			put_obj_text();
			break;
		case 23:  // "RIE" 4  BRXLG  oorriiii00oo
			bal_op_ok = true;
			loc_ctr = (loc_ctr+1)/2*2;
			loc_start = loc_ctr;
			loc_len = 6;
			get_hex_op(1,2);
			get_hex_reg();
			skip_comma();
			get_hex_reg();
			skip_comma();
			get_hex_rel();
			get_hex_zero(2);
			get_hex_op(3,2);
			check_end_parms();
			put_obj_text();
			break;
		case 24:  // "RXE" 28  ADB oorxbddd00oo
			bal_op_ok = true;
			loc_ctr = (loc_ctr+1)/2*2;
			loc_start = loc_ctr;
			loc_len = 6;
			get_hex_op(1,2);
			get_hex_reg();
			skip_comma();
			get_hex_xbddd();
			get_hex_zero(2);
			get_hex_op(3,2);
			check_end_parms();
			put_obj_text();
			break;
		case 25:  // "RXF" 8   MAE  oorxbdddr0oo (note r3 before r1)
			bal_op_ok = true;
			loc_ctr = (loc_ctr+1)/2*2;
			loc_start = loc_ctr;
			loc_len = 6;
			get_hex_op(1,2);
			get_hex_reg();
			skip_comma();
			get_hex_reg();
			skip_comma();
			get_hex_xbddd();
			get_hex_zero(1);
			get_hex_op(3,2);
			obj_code = obj_code.substring(0,2)  // oo
					 + obj_code.substring(3,4)  // r3
					 + obj_code.substring(4,9)  // xbddd
					 + obj_code.substring(2,3)  // r1
					 + obj_code.substring(9);   // 0oo
			check_end_parms();
			put_obj_text();
			break;
		case 26:   // AP SS2  oollbdddbddd
			bal_op_ok = true;
			loc_ctr = (loc_ctr+1)/2*2;
			loc_start = loc_ctr;
			loc_len = 6;
			get_hex_op(1,2);
			get_hex_llbddd();
			if (hex_ll.charAt(0) == '0') {
				hex_len1 = hex_ll.substring(1);
				hex_bddd1     = hex_bddd;
				hex_bddd1_loc = hex_bddd_loc;
			} else {
				log_error(69, "Field 1 hex length > 16 = " + hex_ll);
			}
			skip_comma();
			get_hex_llbddd();
			if (hex_ll.charAt(0) == '0') {
				hex_len2 = hex_ll.substring(1);
				hex_bddd2     = hex_bddd;
				hex_bddd2_loc = hex_bddd_loc;
			} else {
				log_error(70, "Field 2 hex length > 16 = " + hex_ll);
			}
			obj_code = obj_code + hex_len1 + hex_len2 + hex_bddd1 + hex_bddd2;
			check_end_parms();
			put_obj_text();
			break;
		case 27:   // PLO SS3  oorrbdddbddd  r1,s2,r3,s4
			bal_op_ok = true;
			loc_ctr = (loc_ctr+1)/2*2;
			loc_start = loc_ctr;
			loc_len = 6;
			get_hex_op(1,2);
			hex_len1 = get_hex_nib();
			skip_comma();
			get_hex_bddd2(false);          // RPI-613
			hex_bddd1     = hex_bddd2;     // RPI-613
			hex_bddd1_loc = hex_bddd2_loc; // RPI-613
			skip_comma();
			hex_len2 = get_hex_nib();
			skip_comma();
			get_hex_bddd2(false);  // RPI-613
			obj_code = obj_code + hex_len1 + hex_len2 + hex_bddd1 + hex_bddd2;
			check_end_parms();
			put_obj_text();
			break;
		case 28:   // LMD SS4  oorrbdddbddd  r1,r3,s2,s4
			bal_op_ok = true;
			loc_ctr = (loc_ctr+1)/2*2;
			loc_start = loc_ctr;
			loc_len = 6;
			get_hex_op(1,2);
			get_hex_reg();
			skip_comma();
			get_hex_reg();
			skip_comma();
			get_hex_bddd2(true);
			skip_comma();
			get_hex_bddd2(true);
			check_end_parms();
			put_obj_text();
			break;
		case 29:   // SRP SS5  oolibdddbddd s1(l1),s2,i3
			bal_op_ok = true;
			loc_ctr = (loc_ctr+1)/2*2;
			loc_start = loc_ctr;
			loc_len = 6;
			get_hex_op(1,2);
			get_hex_llbddd();
			if (hex_ll.charAt(0) == '0') {
				hex_len1 = hex_ll.substring(1);
				hex_bddd1     = hex_bddd;
				hex_bddd1_loc = hex_bddd_loc;
			} else {
				log_error(69, "Field 1 hex length > 16 = " + hex_ll);
			}
			skip_comma();
			get_hex_bddd2(false); //RPI120 get bddd2 to add later
			skip_comma();
			hex_len2 = get_hex_nib();
			obj_code = obj_code + hex_len1 + hex_len2 + hex_bddd1 + hex_bddd2;  //RPI120
			check_end_parms();
			put_obj_text();
			break;
		case 30:  // RPI-206 "RRF3" 30 DIEBR/DIDBR oooormrr (r1,r3,r2,m4 maps to oooo3412)
			bal_op_ok = true;
			loc_ctr = (loc_ctr+1)/2*2;
			loc_start = loc_ctr;
			loc_len = 4;
			get_hex_op(1,4);
			get_hex_reg();
			skip_comma();
			get_hex_reg();
			skip_comma();
			get_hex_reg();
			skip_comma();
			get_hex_reg();
			obj_code = obj_code.substring(0,4)  // oooo
					 + obj_code.substring(5,6)  // r3
					 + obj_code.substring(7,8)  // m4
					 + obj_code.substring(4,5)  // r1
					 + obj_code.substring(6,7); // r2
			check_end_parms();
			put_obj_text();
			break;
		case 31:  // "SS" PKA oollbdddbddd  ll from S2
			bal_op_ok = true;
			loc_ctr = (loc_ctr+1)/2*2;
			loc_start = loc_ctr;
			loc_len = 6;
			get_hex_op(1,2);
			get_hex_bddd2(false);          // RPI-613
			hex_bddd1     = hex_bddd2;     // RPI-613
			hex_bddd1_loc = hex_bddd2_loc; // RPI-613
			skip_comma();
			get_hex_llbddd();
			hex_bddd2 = hex_bddd;
			hex_bddd2_loc = hex_bddd_loc;
			obj_code = obj_code + hex_ll + hex_bddd1 + hex_bddd2;
			check_end_parms();
			put_obj_text();
			break;
		case 32:   //  MVCOS oor0bdddbddd (s1,s2,r3) "C80" 32 Z9-41
			bal_op_ok = true;
			loc_ctr = (loc_ctr+1)/2*2;
			loc_start = loc_ctr;
			loc_len = 6;
			get_hex_op(1,2);
			get_hex_bddd2(false);          // RPI-606
			hex_bddd1     = hex_bddd2;     // RPI-606
			hex_bddd1_loc = hex_bddd2_loc; // RPI-606
			skip_comma();
			get_hex_bddd2(false);
			skip_comma();
			get_hex_reg(); // RPI-1152
			get_hex_op(3,1);
			obj_code = obj_code + hex_bddd1 + hex_bddd2;
			check_end_parms();
			put_obj_text();
			break;
		case 33:   // "BLX" branch relative on condition long RPI199
			bal_op_ok = true;
			loc_ctr = (loc_ctr+1)/2*2;
			loc_start = loc_ctr;
			loc_len = 6;
			get_hex_op(1,2); //BRCL C0 OP
			get_hex_op(4,1); //BRCL MASK
			get_hex_op(3,1); //BRCL 4  OP
			get_hex_long();
			check_end_parms();
			put_obj_text();
			break;
		case 34:   // RPI-206 "RRF2" CG?R, CF?R, FI?R, IDTE, TB?R RRF2 34 (r1,m3,r2 maps to oooo3012)
			bal_op_ok = true;
			loc_ctr = (loc_ctr+1)/2*2;
			loc_start = loc_ctr;
			loc_len = 4;
			get_hex_op(1,4);
			get_hex_reg();
			get_hex_zero(1);
			skip_comma();
			get_hex_reg();
			skip_comma();
			get_hex_reg();
			obj_code = obj_code.substring(0,4)  // oooo
					 + obj_code.substring(6,7)  // m3
					 + "0"
					 + obj_code.substring(4,5)  // r1
					 + obj_code.substring(7,8); // r2
			check_end_parms();
			put_obj_text();
			break;
		case 35:  // RPI-407 "CSDTR" "RRF4" 35 oooo0mrr (r1,r2,m4 maps to oooo0412)
			bal_op_ok = true;
			loc_ctr = (loc_ctr+1)/2*2;
			loc_start = loc_ctr;
			loc_len = 4;
			get_hex_op(1,4);
			get_hex_zero(1);
			get_hex_reg();
			skip_comma();
			get_hex_reg();
			skip_comma();
			get_hex_reg();
			obj_code = obj_code.substring(0,5)  // oooo
					 + obj_code.substring(7,8)  // m4
					 + obj_code.substring(5,7); // r1,r2
			check_end_parms();
			put_obj_text();
			break;
		case 36:  // RPI-407 "ADTR" "RRR" oooo3012
			bal_op_ok = true;
			loc_ctr = (loc_ctr+1)/2*2;
			loc_start = loc_ctr;
			loc_len = 4;
			get_hex_op(1,4);
			if (bal_op.charAt(bal_op.length()-1) == 'A') { // RPI-1125
				get_hex_reg();
				skip_comma();
				get_hex_reg();
				skip_comma();
				get_hex_reg();
				skip_comma();
				get_hex_reg();
				obj_code = obj_code.substring(0,4)  // oooo
						 + obj_code.substring(6,7)  // r3
						 + obj_code.substring(7,8)  // m4
						 + obj_code.substring(4,5)  // r1
						 + obj_code.substring(5,6); // r2
			} else {
				get_hex_reg();
				get_hex_zero(1);
				skip_comma();
				get_hex_reg();
				skip_comma();
				get_hex_reg();
				obj_code = obj_code.substring(0,4)  // oooo
						 + obj_code.substring(7,8)  // r3
						 + "0"
						 + obj_code.substring(4,5)  // r1
						 + obj_code.substring(6,7); // r2
			}
			check_end_parms();
			put_obj_text();
			break;
		case 37:  // "RXAS" XDECI for ASSIST RPI-812
			if (tz390.opt_assist) {
				bal_op_ok = true;
				loc_ctr = (loc_ctr+1)/2*2;
				loc_start = loc_ctr;
				loc_len = 4;
				get_hex_op(1,2);
				get_hex_reg();
				skip_comma();
				get_hex_xbddd();
				check_end_parms();
				put_obj_text();
			}
			break;
		case 38:  // "RXSS" XREAD for ASSIST RPI-812
			if (tz390.opt_assist) {
				bal_op_ok = true;
				loc_ctr = (loc_ctr+1)/2*2;
				loc_start = loc_ctr;
				loc_len = 6;
				get_hex_op(1,3);
				if ((bal_parms == null
				 || bal_parms.length() == 0
				 || bal_parms.charAt(0) == ',')
				 && bal_op.equals("XDUMP")) {
					exp_text = "0,0"; // force zeros for default XDUMP
				}
				get_hex_xbddd();
				if (exp_index < exp_text.length()
				 && exp_text.charAt(exp_index) == ',') {
					skip_comma();
					if (exp_index < exp_text.length()
					 && exp_text.charAt(exp_index) == '(') {
						exp_text = "0" + exp_text.substring(exp_index);
						exp_index = 0; // allow (reg) vs 0(reg)
					}
					get_hex_bddd2(true);
				} else {
					get_hex_zero(4);
				}
				check_end_parms();
				put_obj_text();
			} else if (OpNames.op_name[bal_op_index].equals("PKU")) {
				bal_op_ok = true;
				loc_ctr = (loc_ctr+1)/2*2;
				loc_start = loc_ctr;
				loc_len = 6;
				get_hex_op(1,2);
				get_hex_llbddd();
				hex_bddd1     = hex_bddd;
				hex_bddd1_loc = hex_bddd_loc;
				obj_code = obj_code + hex_ll + hex_bddd1;
				skip_comma();
				get_hex_bddd2(true);
				check_end_parms();
				put_obj_text();
			}
			break;
		case 39:   // RPI-817 "RRF5" CRT (r1,r2,m3 maps to oooo3012)
			bal_op_ok = true;
			loc_ctr = (loc_ctr+1)/2*2;
			loc_start = loc_ctr;
			loc_len = 4;
			get_hex_op(1,4);
			get_hex_reg();
			get_hex_zero(1);
			skip_comma();
			get_hex_reg();
			if (!bal_abort && exp_next_char(',')) {
				skip_comma();
				get_hex_reg();
			} else {
				get_hex_zero(1); // RPI-817 optional m3 PFMF
			}
			obj_code = obj_code.substring(0,4)  // oooo
					 + obj_code.substring(7,8)   // m3
					 + "0"
					 + obj_code.substring(4,5)  // r1
					 + obj_code.substring(6,7); // r2
			check_end_parms();
			put_obj_text();
			break;
		case 40:   // RPI-817 "RRF6" CRTE (r1,r2 maps to oooo0012)
			bal_op_ok = true;
			loc_ctr = (loc_ctr+1)/2*2;
			loc_start = loc_ctr;
			loc_len = 4;
			get_hex_op(1,5);
			get_hex_zero(1);
			get_hex_reg();
			skip_comma();
			get_hex_reg();
			check_end_parms();
			put_obj_text();
			break;
		case 41:  // "RIE2" CIT oor0iiiim0oo
			// r1,i2,m3
			bal_op_ok = true;
			loc_ctr = (loc_ctr+1)/2*2;
			loc_start = loc_ctr;
			loc_len = 6;
			get_hex_op(1,2);  // OP1
			get_hex_reg();    // R1
			get_hex_zero(1);
			skip_comma();
			get_hex_rel();    // I2
			skip_comma();
			get_hex_reg();    // M3
			get_hex_zero(1);
			get_hex_op(3,2);  // OP2
			check_end_parms();
			put_obj_text();
			break;
		case 42:  // "RIE3" CITE oorriiiim0oo
			// r1,i2
			bal_op_ok = true;
			loc_ctr = (loc_ctr+1)/2*2;
			loc_start = loc_ctr;
			loc_len = 6;
			get_hex_op(1,2);  // op1
			get_hex_reg();    // r1f
			get_hex_zero(1);
			skip_comma();
			get_hex_rel();    // i2
			get_hex_op(5,1);  // m3 from opcode
			get_hex_zero(1);  // 0
			get_hex_op(3,2);  // op2
			check_end_parms();
			put_obj_text();
			break;
		case 43:  // "RIE4" CIJ/CGIJ/CLIJ/CLGIJ oo13444422oo
			// r1,i2,m3,i4
			bal_op_ok = true;
			loc_ctr = (loc_ctr+1)/2*2;
			loc_start = loc_ctr;
			loc_len = 6;
			get_hex_op(1,2);  // op1
			get_hex_reg();    // r1
			skip_comma();
			if (OpNames.op_name[bal_op_index].charAt(1) == 'L') { // RPI-1146
				get_hex_byte();   // i2
			} else {
				get_hex_byte_signed(); // i2
			}
			skip_comma();
			get_hex_reg();    // m3
			skip_comma();
			get_hex_rel();    //i4 rel
			get_hex_op(3,2);
			check_end_parms();
			obj_code = obj_code.substring(0,3)    // op1+r1
					 + obj_code.substring(5,6)    // m3
					 + obj_code.substring(6,10)   // i4 4444 rel
					 + obj_code.substring(3,5)    // i2 22 byte
					 + obj_code.substring(10,12); // op2
			put_obj_text();
			break;
		case 44:  // "RIE5" CGIJ oorm444422oo r1,i2,m3,i4
			// r1,i2,i4
			bal_op_ok = true;
			loc_ctr = (loc_ctr+1)/2*2;
			loc_start = loc_ctr;
			loc_len = 6;
			get_hex_op(1,2); // op1
			get_hex_reg();   // r1
			get_hex_op(5,1); // m3
			skip_comma();
			if (OpNames.op_name[bal_op_index].charAt(1) == 'L') { // RPI-1146
				get_hex_byte();   // i2
			} else {
				get_hex_byte_signed(); // i2
			}
			skip_comma();
			get_hex_rel(); // i4 rel
			get_hex_op(3,2);
			check_end_parms();
			obj_code = obj_code.substring(0,4)    // op1+r1+m3
					 + obj_code.substring(6,10)   // i4 4444 rel
					 + obj_code.substring(4,6)    // i2 22 byte
					 + obj_code.substring(10,12); // op2
			put_obj_text();
			break;
		case 45:  // "RRS1" CGIB oorrbdddm0oo
			// r1,r2,m3,s4
			bal_op_ok = true;
			loc_ctr = (loc_ctr+1)/2*2;
			loc_start = loc_ctr;
			loc_len = 6;
			get_hex_op(1,2);
			get_hex_reg(); // r1
			skip_comma();
			get_hex_reg(); // r2
			skip_comma();
			get_hex_reg(); // m3
			get_hex_zero(1);
			skip_comma();
			get_hex_bddd2(true); // bddd4
			get_hex_op(3,2);
			check_end_parms();
			obj_code = obj_code.substring(0,4)    // op1+r1+r2
					 + obj_code.substring(6,10)   // s4 bddd
					 + obj_code.substring(4,6)    // m3 + 0
					 + obj_code.substring(10,12); // op2
			put_obj_text();
			break;
		case 46:  // "RRS2" CGRBE oorriiiim0oo
			// r1,r2,s4
			bal_op_ok = true;
			loc_ctr = (loc_ctr+1)/2*2;
			loc_start = loc_ctr;
			loc_len = 6;
			get_hex_op(1,2); // op1
			get_hex_reg();   // r1
			skip_comma();
			get_hex_reg();   // r2
			skip_comma();
			get_hex_bddd2(true);  // s4 bddd
			get_hex_op(5,1); // m3 from op
			get_hex_zero(1); // 0
			get_hex_op(3,2); // op2
			check_end_parms();
			put_obj_text();
			break;
		case 47:  // "RRS3" CGIB oo13bddd22oo
			// r1,i2,m3,i4
			bal_op_ok = true;
			loc_ctr = (loc_ctr+1)/2*2;
			loc_start = loc_ctr;
			loc_len = 6;
			get_hex_op(1,2); // op1
			get_hex_reg();   // r1
			skip_comma();
			get_hex_byte();  // i2
			skip_comma();
			get_hex_reg();   // m3
			skip_comma();
			get_hex_bddd2(true);  // s4 bddd
			get_hex_op(3,2); // op2
			check_end_parms();
			obj_code = obj_code.substring(0,3)    // op1+r1
					 + obj_code.substring(5,6)    // m3
					 + obj_code.substring(6,10)   // s4 bddd
					 + obj_code.substring(3,5)    // i2 22 byte
					 + obj_code.substring(10,12); // op2
			put_obj_text();
			break;
		case 48:  // "RRS4" CGIBE oormbddd22oo r1,i2,m3,i4
			// r1,i2,s4
			bal_op_ok = true;
			loc_ctr = (loc_ctr+1)/2*2;
			loc_start = loc_ctr;
			loc_len = 6;
			get_hex_op(1,2);  // op1
			get_hex_reg();    // r1
			get_hex_op(5,1);  // m3 from opcode
			skip_comma();
			get_hex_byte();   // i2
			skip_comma();
			get_hex_bddd2(true); // s4 bddd
			get_hex_op(3,2);  // op2
			check_end_parms();
			obj_code = obj_code.substring(0,4)    // op1+r1+m3
					 + obj_code.substring(6,10)   // i4 4444 rel
					 + obj_code.substring(4,6)    // i2 22 byte
					 + obj_code.substring(10,12); // op2
			put_obj_text();
			break;
		case 49:  // "RIE6" CGRJ oorriiiim0oo
			// r1,r2,m3,s4
			bal_op_ok = true;
			loc_ctr = (loc_ctr+1)/2*2;
			loc_start = loc_ctr;
			loc_len = 6;
			get_hex_op(1,2);  // OP1
			get_hex_reg();    // R1
			skip_comma();
			get_hex_reg();    // r2
			skip_comma();
			get_hex_reg();    // m3
			skip_comma();
			get_hex_rel();    // I2
			get_hex_zero(1);
			get_hex_op(3,2);  // OP2
			check_end_parms();
			obj_code = obj_code.substring(0,4)   // op1+r1+r2
					 + obj_code.substring(5,9)   // s4 bddd
					 + obj_code.substring(4,5)   // m3 + 0
					 + obj_code.substring(9,12); // op2
			put_obj_text();
			break;
		case 50:  // "RIE7" CGRJE oorriiiim0oo
			// r1,r2,s4
			bal_op_ok = true;
			loc_ctr = (loc_ctr+1)/2*2;
			loc_start = loc_ctr;
			loc_len = 6;
			get_hex_op(1,2);  // OP1
			get_hex_reg();    // R1
			skip_comma();
			get_hex_reg();    // R2
			skip_comma();
			get_hex_rel();    // I2
			get_hex_op(5,1);  // M3
			get_hex_zero(1);  // 0
			get_hex_op(3,2);  // OP2
			check_end_parms();
			put_obj_text();
			break;
		case 51: // "SIL" "MVHHI" d1(b1),i2 oooobdddiiii
			bal_op_ok = true;
			loc_ctr = (loc_ctr+1)/2*2;
			loc_start = loc_ctr;
			loc_len = 6;
			get_hex_op(1,4);
			get_hex_bddd2(true);
			skip_comma();
			get_hex_rel();
			check_end_parms();
			put_obj_text();
			break;
		case 52: // "RIE8" "RNSBG" oo12334455oo RPI-817
			// r1,r2,i3,i4[,i5] or extended op r1,r2 RPI-1164
			// i3 high bit for test RNSBGT
			// i4 high bit for zero RISBGZ
			bal_op_ok = true;
			loc_ctr = (loc_ctr+1)/2*2;
			loc_start = loc_ctr;
			loc_len = 6;
			get_hex_op(1,2);  // OP1
			get_hex_reg();    // R1
			skip_comma();
			get_hex_reg();    // R2
			if (OpCodes.op_code[bal_op_index].length() == 11) {
				// extended op (get i3,i4,i5 from op_code "oooo$i3i4i5" RPI-1164
				final int i3 = Integer.valueOf(OpCodes.op_code[bal_op_index].substring(5,7));
				final int i4 = Integer.valueOf(OpCodes.op_code[bal_op_index].substring(7,9));
				final int i5 = Integer.valueOf(OpCodes.op_code[bal_op_index].substring(9,11));
				obj_code = obj_code + tz390.get_hex(i3,2);
				if (OpNames.op_name[bal_op_index].charAt(0) == 'L') {
					obj_code = obj_code + tz390.get_hex(i4 + 0x80,2);
				} else {
					obj_code = obj_code + tz390.get_hex(i4,2);
				}
				obj_code = obj_code + tz390.get_hex(i5,2);
			} else {
				skip_comma();
				get_hex_byte();   // I3
				if (!bal_abort
				 && bal_op.length() == 6
				 && bal_op.charAt(5) == 'T') { // turn on test bit if OP=?????T
					obj_code = obj_code.substring(0,obj_code.length()-2) + tz390.get_hex(exp_val + 0x80,2);
				}
				skip_comma();
				get_hex_byte();   // I4
				if (!bal_abort                                          // RPI-1164 WAS 6
				 && bal_op.charAt(bal_op.length()-1) == 'Z') { // turn on XZERO bit if OP=??????Z  // RPI-1164 RISBG/RISBHG
					obj_code = obj_code.substring(0,obj_code.length()-2) + tz390.get_hex(exp_val + 0x80,2);
				}
				if (exp_text.length() > exp_index
				 && exp_text.charAt(exp_index) == ',') {
					skip_comma();
					get_hex_byte();   // I5
				} else {
					get_hex_zero(2);  // I5 default 0 rotate RPI-1164 was 1
				}
			}
			get_hex_op(3,2);  // OP2
			check_end_parms();
			put_obj_text();
			break;
		case 53:   // LEDBR?, LDXBR?, LEXBR? RPI-1125 oo0012/oo3412 r1,r2/r1,m3,r2,m4
			bal_op_ok = true;
			loc_ctr = (loc_ctr+1)/2*2;
			loc_start = loc_ctr;
			loc_len = 4;
			get_hex_op(1,4);
			if (bal_op.charAt(bal_op.length()-1) == 'A') { // RPI-277
				get_hex_reg();  // r1
				skip_comma();
				get_hex_reg();  // m3
				skip_comma();
				get_hex_reg();  // r2
				skip_comma();
				get_hex_reg();  // m4
				obj_code = obj_code.substring(0,4)  // op1
						 + obj_code.substring(5,6)  // m3
						 + obj_code.substring(7,8)  // m4
						 + obj_code.substring(4,5)  // r1
						 + obj_code.substring(6,7); // r2
				check_end_parms();
			} else {
				get_hex_zero(2);
				get_hex_reg();
				skip_comma();
				get_hex_reg();
				check_end_parms();
			}
			put_obj_text();
			break;
		case 54:   // FIEBR?, FIDBR?, FIXBR? RPI-1125 	r1,m3,r2 or r1,m3,r2,m4
			bal_op_ok = true;
			loc_ctr = (loc_ctr+1)/2*2;
			loc_start = loc_ctr;
			loc_len = 4;
			get_hex_op(1,4);
			if (bal_op.charAt(bal_op.length()-1) == 'A') { // RPI-1125
				get_hex_reg();  // r1
				skip_comma();
				get_hex_reg();  // m3
				skip_comma();
				get_hex_reg();  // r2
				skip_comma();
				get_hex_reg();  // m4
				obj_code = obj_code.substring(0,4)  // op1
						 + obj_code.substring(5,6)  // m3
						 + obj_code.substring(7,8)  // m4
						 + obj_code.substring(4,5)  // r1
						 + obj_code.substring(6,7); // r2
				check_end_parms();
			} else {
				get_hex_reg();
				get_hex_zero(1);
				skip_comma();
				get_hex_reg();
				skip_comma();
				get_hex_reg();
				obj_code = obj_code.substring(0,4)  // oooo
						 + obj_code.substring(6,7)   // m3
						 + "0"
						 + obj_code.substring(4,5)  // r1
						 + obj_code.substring(7,8); // r2
				check_end_parms();
			}
			put_obj_text();
			break;
		case 55:   // SSF LPD/LPDG oor0bdddbddd (r3,s1,s2) RPI-1125
			bal_op_ok = true;
			loc_ctr = (loc_ctr+1)/2*2;
			loc_start = loc_ctr;
			loc_len = 6;
			get_hex_op(1,2);
			get_hex_reg();
			get_hex_op(3,1);
			skip_comma();
			get_hex_bddd2(false);          // RPI-606
			hex_bddd1     = hex_bddd2;     // RPI-606
			hex_bddd1_loc = hex_bddd2_loc; // RPI-606
			skip_comma();
			get_hex_bddd2(false);
			obj_code = obj_code + hex_bddd1 + hex_bddd2;
			check_end_parms();
			put_obj_text();
			break;
		case 56:  // "RSY" 207/209 LOCG r1,s2,m3 oormbdddhhoo RPI-1125
			bal_op_ok = true;
			loc_ctr = (loc_ctr+1)/2*2;
			loc_start = loc_ctr;
			loc_len = 6;
			get_hex_op(1,2);
			get_hex_reg();
			skip_comma();
			get_hex_bdddhh2();
			get_hex_op(3,2);
			skip_comma();
			get_hex_reg();
			obj_code = obj_code.substring(0,2)   // oooo
					 + obj_code.substring(2,3)   // r1
					 + obj_code.substring(11,12) // m3
					 + obj_code.substring(3,11); // r2
			check_end_parms();
			put_obj_text();
			break;
		case 57: // "RIE9" "AHIK" oo13IIII00Oo RPI-1125
			// r1,r3,i2
			bal_op_ok = true;
			loc_len = 6;
			get_hex_op(1,2); // OP1
			get_hex_reg();   // R1
			skip_comma();
			get_hex_reg();   // R3
			skip_comma();
			get_hex_rel();   // I2
			get_hex_zero(2);
			get_hex_op(3,2); // OP2
			check_end_parms();
			put_obj_text();
			break;
		case 101:  // CCW  0
		case 102:  // CCW0 0
			bal_op_ok = true;
			bal_lab_attr = tz390.ascii_to_ebcdic['W']; // RPI-340
			gen_ccw0(); // op8,addr24,flags8,zero8,len16 // RPI-567
			break;
		case 103:  // CCW1 0
			bal_op_ok = true;
			bal_lab_attr = tz390.ascii_to_ebcdic['W']; // RPI-340
			gen_ccw1();  // op8,flags8,len16,bit0,addr31  // RPI-567
			break;
		case 104:  // DC 0
			bal_op_ok = true;
			process_dc(1);
			break;
		case 105:  // DS 0
			bal_op_ok = true;
			process_dc(1);
			break;
		case 106:  // ALIAS 0
			bal_op_ok = true;  // RPI-368 ignore
			bal_label_ok = false; // RPI-553
			break;
		case 107:  // AMODE 0
			bal_op_ok = true; //RPI122 IGNORE
			bal_label_ok = false; // RPI-553
		case 108:  // CATTR 0
			break;
		case 109:  // COM 0
			bal_lab_attr = tz390.ascii_to_ebcdic['J']; // RPI-340
			bal_op_ok = true;
			process_sect(sym_cst,bal_label);  // RPI-230
			if (first_cst_esd == 0) first_cst_esd = cur_esd;
			bal_label_ok = false;
			break;
		case 110:  // CSECT 0
			bal_lab_attr = tz390.ascii_to_ebcdic['J']; // RPI-340
			bal_op_ok = true;
			process_sect(sym_cst,bal_label);
			if (first_cst_esd == 0) first_cst_esd = cur_esd;
			bal_label_ok = false;
			break;
		case 111:  // CXD 0
			break;
		case 112:  // DSECT 0
			bal_lab_attr = tz390.ascii_to_ebcdic['J']; // RPI-340
			bal_op_ok = true;
			process_sect(sym_dst,bal_label);
			bal_label_ok = false;
			break;
		case 113:  // DXD 0
			break;
		case 114:  // ENTRY 0
			bal_op_ok = true;
			process_esd(sym_ent);
			break;
		case 115:  // EXTRN 0
			bal_lab_attr = tz390.ascii_to_ebcdic['T']; // RPI-340
			bal_op_ok = true;
			process_esd(sym_ext);
			break;
		case 116:  // LOCTR 0
			bal_lab_attr = tz390.ascii_to_ebcdic['J']; // RPI-340
			bal_op_ok = true;
			if (cur_pass == 1) { // RPI-960
				tot_loc_stmt++;  // RPI-920
			}
			process_sect(sym_lct,bal_label);
			bal_label_ok = false;
			break;
		case 117:  // RMODE 0
			bal_op_ok = true; //RPI122 IGNORE
			bal_label_ok = false; // RPI-553
			break;
		case 118:  // RSECT 0
			bal_lab_attr = tz390.ascii_to_ebcdic['J']; // RPI-340
			bal_op_ok = true;
			process_sect(sym_cst,bal_label);  // RPI-230
			if (first_cst_esd == 0)first_cst_esd = cur_esd;
			bal_label_ok = false;
			break;
		case 119:  // START 0
			bal_lab_attr = tz390.ascii_to_ebcdic['J']; // RPI-340
			bal_op_ok = true;
			process_sect(sym_cst,bal_label);  // RPI-230
			if (first_cst_esd == 0) {
				first_cst_esd = cur_esd;
			} else if (cur_esd != first_cst_esd) {
				log_error(204,"START must be first CSECT"); // RPI-917
			}
			bal_label_ok = false;
			break;
		case 120:  // WXTRN 0
			bal_lab_attr = tz390.ascii_to_ebcdic['S']; // RPI-340
			bal_op_ok = true;
			process_esd(sym_wxt); //RPI182
			break;
		case 121:  // XATTR 0
			break;
		case 123:  // DROP 0
			bal_op_ok = true;
			if (gen_obj_code) {
				drop_using();
			}
			break;
		case 124:  // USING 0
			bal_op_ok = true;
			bal_label_ok = false;
			check_private_csect();
			if (gen_obj_code) {
				add_using();
			}
			break;
		case 125:  // AEJECT 0
			bal_op_ok = true; //RPI122 IGNORE
			break;
		case 126:  // ASPACE 0
			bal_op_ok = true; //RPI122 IGNORE
			list_bal_line = false; // RPI-289
			break;
		case 127:  // CEJECT 0
			bal_op_ok = true; //RPI122 IGNORE
			list_bal_line = false; // RPI-289
			break;
		case 128:  // EJECT 0
			bal_op_ok = true; //RPI122 IGNORE
			list_bal_line = false; // RPI-289
			break;
		case 129:  // PRINT 0
			bal_op_ok = true;
			if (gen_obj_code) {
				process_print();
			}
			break;
		case 130:  // SPACE 0
			bal_op_ok = true; //RPI122 IGNORE
			list_bal_line = false; // RPI-289
			break;
		case 131:  // TITLE 0
			bal_op_ok = true;
			bal_label_ok = false; // RPI-131
			break;
		case 132:  // ADATA 0
			break;
		case 133:  // CNOP 0
			bal_op_ok = true;
			process_cnop();
			break;
		case 135:  // END 0
			bal_op_ok = true;
			end_found = true;
			if (gen_obj_code && bal_parms != null) {
				label_match = label_pattern.matcher(bal_parms);
				if (!bal_abort && label_match.find()) {
					end_entry = label_match.group();
					end_entry_sid = find_sym(end_entry); // RPI-1197
					if (end_entry_sid > 0) {
						end_entry_found = true;
					} else {
						log_error(210,"END entry label not found - " + end_entry);
					}
				}
			}
			process_end();
			break;
		case 136:  // EQU 0
			bal_op_ok = true;
			bal_label_ok = false;
			process_equ();
			break;
		case 137:  // EXITCTL 0
			break;
		case 138:  // ICTL 0
			bal_op_ok = true; // RPI-728
			break;
		case 139:  // ISEQ 0
			bal_op_ok = true; // RPI-728 ignore
			break;
		case 140:  // LTORG 0
			bal_op_ok = true;
			list_bal_line();
			if ( // RPI-1159 was tot_lit > 0
				cur_esd > 0
			 && sym_type[esd_sid[esd_base[cur_esd]]] == sym_cst) { // RPI-564
				gen_ltorg();
			}
			cur_lit_pool++;
			list_bal_line = false; // RPI-891 suppress LTORG at end
			break;
		case 141:  // OPSYN 0
			break;
		case 142:  // ORG 0
			bal_op_ok = true;
			process_org();
			break;
		case 143:  // POP 0
			bal_op_ok = true;
			if (gen_obj_code) {
				process_pop();
			}
			break;
		case 145:  // PUSH 0
			bal_op_ok = true;
			if (gen_obj_code) {
				process_push();
			}
			break;
		case 146:  // REPRO 0
			break;
		case 147:  // ACONTROL
			bal_op_ok = true;  // RPI-368 ignore
			break;
		case 201:  // ACTR 0
			break;
		case 202:  // AGO 0
			break;
		case 203:  // AIF 0
			break;
		case 204:  // AINSERT 0
			break;
		case 205:  // ANOP 0
			break;
		case 206:  // AREAD 0
			break;
		case 207:  // GBLA 0
			break;
		case 208:  // GBLB 0
			break;
		case 209:  // GBLC 0
			break;
		case 210:  // LCLA 0
			break;
		case 211:  // LCLB 0
			break;
		case 212:  // LCLC 0
			break;
		case 213:  // MHELP 0
			break;
		case 214:  // MNOTE 0
			bal_op_ok = true;  // pass through from mz390
			if (gen_obj_code
			 && mac_inline_level == 0) { // RPI-581
				force_list_bal = true;  // RPI-581
				if (bal_parms != null   // RPI-503
				 && bal_parms.length() > 0
				 && bal_parms.charAt(0) != '*') { // RPI-444
					tz390.put_systerm("MNOTE " + bal_parms); // RPI-440
				}
				if (bal_parms.length() > 0
				 && bal_parms.charAt(0) != '\''
				 && bal_parms.charAt(0) != ','
				 && bal_parms.charAt(0) != '*') {
					exp_text = bal_parms;
					exp_index = 0;
					exp_val = 0;
					if (calc_abs_exp()) {
						if (exp_val > az390_rc) {  // RPI-313
							az390_rc = exp_val;
						}
						if (exp_val > 0) {
							if (exp_val > tz390.max_mnote_warning) {
								tot_mnote_errors++;
							} else {
								tot_mnote_warning++;
							}
						}
						if (exp_val > max_mnote_level) {
							max_mnote_level = exp_val;
						}
					}
				}
			}
			break;
		case 215:  // SETA 0
			break;
		case 216:  // SETAF 0
			break;
		case 217:  // SETB 0
			break;
		case 218:  // SETC 0
			break;
		case 219:  // SETCF 0
			break;
		case 220:  // MACRO 0
			bal_op_ok = true;  // pass true from mz390
			mac_inline_level++; // RPI-581
			break;
		case 221:  // MEND 0
			bal_op_ok = true;  // pass true from mz390
			mac_inline_level--;  // RPI-581
			break;
		case 222:  // MEXIT 0
			break;
		case 223:  // PUNCH 0
			bal_op_ok = true; // pass thru after gen by mz390
			break;
		case 224:  // COPY 0
			bal_op_ok = true;  // already expanded in mz390
			break;
		case 225:  // OPSYN
			bal_op_ok = true;
			bal_label_ok = false;         // reset to avoid dup. label
			tz390.update_opsyn(bal_label,bal_parms);
			if (tz390.opt_traceall) { // RPI-403
				tz390.put_trace("OPSYN(" + tz390.opsyn_index + ") NEW=" + opsyn_label + " OLD=" + bal_parms);
			}
			break;
		case 226:  // inline macro code and not MACRO or MEND
			bal_op_ok = true;
			break;
		default:
			// should not occur - see tz390 opcode_type table
			abort_error(139,"invalid opcode type index");
		}
		if (mac_inline_level == 0) {
			if (!bal_op_ok) {
				log_error(62, "Unsupported operation code " + bal_op); // RPI-563
			}
			if (bal_label != null
			 && index < tz390.max_asm_type  // RPI-926
			 && bal_label_ok) { // RPI-451
				update_label();
			}
		}
		if (!bal_abort && bal_line != null) { // RPI-891
			list_bal_line();
		}
		loc_ctr = loc_ctr + loc_len;
	}

	/**
	 * List BAL line with first 8 bytes of object code if any and turn off list_bal_line request.
	 */
	private void list_bal_line()
	{
		// Notes:
		// See comments processing case 0 for update of mac_call_gen,
		// call reformatting, and delay flags mac_call_first and mac_call_last.

		if (!check_list_bal_line()) { // RPI-484 RPI-891
			update_list_bal_line();
			return;
		}
		if (list_obj_code.length() < 16) {
			list_obj_code = list_obj_code.concat("                ").substring(0,16);
		}
		list_obj_loc = loc_start;
		if (gen_obj_code) { // RPI-581
			cur_line_type     = xref_file_type[bal_line_xref_file_num[bal_line_index]];
			cur_line_file_num = bal_line_xref_file_num[bal_line_index];
			put_prn_line(tz390.get_hex(list_obj_loc,6)
					+ " " + list_obj_code.substring(0,16)
					+ " " + hex_bddd1_loc
					+ " " + hex_bddd2_loc
					+ " " + tz390.get_cur_bal_line_id(cur_line_file_num,
								bal_line_xref_file_line[bal_line_index],
								bal_line_num[bal_line_index],
								mac_call_gen, // RPI-891
								cur_line_type)
					+ bal_line);
		}
		force_list_bal = false; // RPI-285
		update_list_bal_line();
		if (list_use) {
			list_use();
			list_use = false;
		}
	}

	/**
	 * Set true if ok to list BAL line on PRN file.
	 *
	 * @return
	 */
	private boolean check_list_bal_line()
	{
		if (!tz390.opt_list) {
			// no PRN file generated  // RPI-895 no ERRSUM check
			return false;
		}
		if (force_list_bal) {
			// force listing error msgs etc.
			return true;
		}
		if (list_bal_line && print_on[print_level]) {
			if (mac_call_gen && !print_gen[print_level]) {
				// Suppress generated BAL for PRINT NOGEN.
				return false;
			}
			return true;
		} else {
			// Suppress BAL for PRINT OFF.
			return false;
		}
	}

	/**
	 * Update mac_call_gen after prn.
	 */
	private void update_list_bal_line()
	{
		if (mac_call_first) {
			mac_call_first = false;
			mac_call_gen   = true; // RPI-891
			list_bal_line = false; // RPI-891
		}
		if (mac_call_last) {
			mac_call_last = false;
			mac_call_gen  = false;  // RPI-891
			list_bal_line = true;   // RPI-891
		}
	}

	/**
	 * Add plus RLD.
	 *
	 * @param exp_esd
	 */
	private void add_rld(final int exp_esd)
	{
		if (cur_esd == 0 || sym_type[esd_sid[esd_base[cur_esd]]] != sym_cst) {
			return; // RPI-1208
		}
		if (tot_exp_rld_add < max_exp_rld) {
			exp_rld_add_esd[tot_exp_rld_add] = exp_esd;
			tot_exp_rld_add++;
		}
	}

	/**
	 * sub rld
	 *
	 * @param exp_esd
	 */
	private void sub_rld(final int exp_esd)
	{
		if (cur_esd == 0 || sym_type[esd_sid[esd_base[cur_esd]]] != sym_cst) {
			return; // RPI-1208
		}
		if (tot_exp_rld_sub < max_exp_rld) {
			exp_rld_sub_esd[tot_exp_rld_sub] = exp_esd;
			tot_exp_rld_sub++;
		}
	}

	/**
	 * Reduce RLD on stack.
	 */
	private void reduce_exp_rld()
	{
		int index1 = 0;
		int index2 = 0;
		while (index1 < tot_exp_rld_add) {
			index2 = 0;
			while (index2 < tot_exp_rld_sub) {
				if (exp_rld_add_esd[index1] == exp_rld_sub_esd[index2]) {
					tot_exp_rld_add--;
					if (index1 < tot_exp_rld_add) { // RPI-673
						exp_rld_add_esd[index1] = exp_rld_add_esd[tot_exp_rld_add];
						index1--; // backup to restart on replacement
					}
					tot_exp_rld_sub--;
					if (index2 < tot_exp_rld_sub) {  // RPI-673
						exp_rld_sub_esd[index2] = exp_rld_sub_esd[tot_exp_rld_sub];
					}
					index2 = tot_exp_rld_sub;  // RPI-673 force restart
				}
				index2++;
			}
			index1++;
		}
		if ((tot_exp_rld_add + tot_exp_rld_sub) == 0) {
			exp_type = sym_sdt;
			exp_esd  = 0; // RPI-673
			return;
		} else if (tot_exp_rld_add == 1 && tot_exp_rld_sub == 0) {
			exp_type = sym_rel;
			exp_esd = exp_rld_add_esd[0];
		} else {
			exp_type = sym_rld;
		}
	}

	/**
	 * Generate RLDs for expression.<br>
	 * <br>
	 * Notes:
	 * <ol><li>Convert to rel CSECT vs rel module offsets for linker use.
	 *     <li>Original exp_val saved in rld_exp_val for use in PRN display<br>
	 *         (i.e. show addresses relative to module versus CSECT).</ol>
	 */
	private void gen_exp_rld()
	{
		if (cur_esd == 0 || sym_type[esd_sid[esd_base[cur_esd]]] != sym_cst) { // RPI-1208
			return;
		}
		exp_rld_mod_val = exp_val;  // RPI-632 rel module vs CSECT
		exp_rld_mod_set = true;     // RPI-632
		int index = 0;
		while (index < tot_exp_rld_add) {
			if (tot_rld < tz390.opt_maxrld) {
				rld_fld_esd[tot_rld] = esd_base[cur_esd]; // RPI-301
				rld_fld_loc[tot_rld] = loc_ctr - sym_loc[esd_sid[esd_base[cur_esd]]]; // RPI-564 use base
				rld_fld_len[tot_rld] = exp_rld_len;
				rld_fld_sgn[tot_rld] = rld_add;
				rld_xrf_esd[tot_rld] = exp_rld_add_esd[index];
				exp_val = exp_val - sym_loc[esd_sid[exp_rld_add_esd[index]]];
				if (tz390.opt_traceall) {
					tz390.put_trace("EXP RLD" // RPI-564 additional traceall info
								 + " ESD=" + tz390.get_hex(rld_fld_esd[tot_rld],4)
								 + " LOC=" + tz390.get_hex(rld_fld_loc[tot_rld],8)
								 + " LEN=" + tz390.get_hex(rld_fld_len[tot_rld],1)
								 + " SIGN=" + rld_fld_sgn[tot_rld]
								 + " XESD=" + tz390.get_hex(rld_xrf_esd[tot_rld],4));
				}
				tot_rld++;
			} else {
				abort_error(103, "rld table exceeded.");
			}
			index++;
		}
		index = 0;
		while (index < tot_exp_rld_sub) {
			if (tot_rld < tz390.opt_maxrld) {
				rld_fld_esd[tot_rld] = cur_esd;
				rld_fld_loc[tot_rld] = loc_ctr - sym_loc[esd_sid[cur_esd]];
				rld_fld_len[tot_rld] = exp_rld_len;
				rld_fld_sgn[tot_rld] = rld_sub;
				rld_xrf_esd[tot_rld] = exp_rld_sub_esd[index];
				exp_val = exp_val + sym_loc[esd_sid[exp_rld_sub_esd[index]]];
				if (tz390.opt_traceall) {
					tz390.put_trace("EXP RLD" // RPI-564 additional traceall info
								 + " ESD=" + tz390.get_hex(rld_fld_esd[tot_rld],4)
								 + " LOC=" + tz390.get_hex(rld_fld_loc[tot_rld],8)
								 + " LEN=" + tz390.get_hex(rld_fld_len[tot_rld],1)
								 + " SIGN=" + rld_fld_sgn[tot_rld]
								 + " XESD=" + tz390.get_hex(rld_xrf_esd[tot_rld],4));
				}
				tot_rld++;
			} else {
				abort_error(103, "rld table exceeded.");
			}
			index++;
		}
	}

	/**
	 * Write RLDs to the OBJ file in ASCII hex.
	 */
	private void gen_obj_rlds()
	{
		xref_bal_index = -1;
		if (tot_rld > 0) {
			put_prn_line("Relocation Definitions");
		}
		int index = 0;
		while (index < tot_rld) {
			String rld_code =
					  " ESD=" + tz390.get_hex(rld_fld_esd[index],4)
					+ " LOC=" + tz390.get_hex(rld_fld_loc[index],8)
					+ " LEN=" + tz390.get_hex(rld_fld_len[index],1)
					+ " SIGN=" + rld_fld_sgn[index]
					+ " XESD=" + tz390.get_hex(rld_xrf_esd[index],4);
			put_prn_line(rld_code);
			put_obj_line(".RLD" + rld_code);
			index++;
		}
	}

	/**
	 * Write END object record with entry if specified  RPI-1197
	 */
	private void gen_obj_end()
	{
		if (end_entry_found) {
			put_obj_line( ".END" + " ESD=" + tz390.get_hex(sym_esd[end_entry_sid],4)
						+ " LOC=" + tz390.get_hex(sym_loc[end_entry_sid]-sym_loc[esd_sid[sym_esd[end_entry_sid]]],8));
		} else {
			put_obj_line( ".END" + " ESD=0000"
						+ " LOC=00000000");
		}
	}

	/**
	 * List symbols in alphabetical order with optional cross reference.
	 */
	private void gen_sym_list()
	{
		put_prn_line(tz390.newline +  // RPI-500
				"Symbol Table Listing" + tz390.newline);
		final TreeSet<String> sort_sym = new TreeSet<String>();
		int index = 1;
		while (index <= tot_sym) { // RPI-415
			if (sym_def[index] != sym_def_lookahead) { // RPI-450
				sort_sym.add(sym_name[index] + (sort_index_bias + index));
			}
			index++;
		}
		final Iterator<String> sym_key_it = sort_sym.iterator();
		while (sym_key_it.hasNext()) {
			final String key = sym_key_it.next();
			// get sym index from end of sort key string
			index = Integer.valueOf(key.substring(key.length()-sort_index_len)) - sort_index_bias;
			String name = sym_name[index];
			if (name.length() < 8) {
				name = name.concat("       ").substring(0,8);
			}
			String sym_line = " SYM=" + name
							+ " LOC=" + tz390.get_hex(sym_loc[index],8)
							+ " LEN=" + tz390.get_hex(get_sym_len(index),8)
							+ " ESD=" + tz390.get_hex(esd_base[sym_esd[index]],4) // RPI-301
							+ " TYPE=" + sym_type_desc[sym_type[index]];
			if (tz390.opt_xref) {
				sym_line = sym_line + "  XREF=";
				if (sym_def[index] > sym_def_ref) {
					sym_line = sym_line + bal_line_num[sym_def[index]] + " ";
				}
				if (sym_xref[index] != null) {
					Iterator<Integer> sym_xref_it = sym_xref[index].iterator();
					while (sym_xref_it.hasNext()) {
						int sym_xref_num = sym_xref_it.next();
						if (sym_xref_num != bal_line_num[sym_def[index]]) {
							sym_line = sym_line + sym_xref_num + " ";
							if (sym_line.length() > tz390.max_line_len) {
								put_prn_line(sym_line);
								sym_line = "  ";
							}
						}
					}
				}
				if (sym_line.length() > 2) {
					put_prn_line(sym_line);
				}
			} else {
				put_prn_line(sym_line);
			}
		}
	}

	/**
	 * List literals in alpha order with optional cross reference.
	 */
	private void gen_lit_xref_list()
	{
		put_prn_line(tz390.newline + "Literal Table Listing" + tz390.newline); // RPI-500
		final TreeSet<String> sort_lit = new TreeSet<String>();
		int index = 0;
		while (index < tot_lit) {
			sort_lit.add(lit_name[index] + (sort_index_bias + index));
			index++;
		}
		final Iterator<String> lit_key_it = sort_lit.iterator();
		while (lit_key_it.hasNext()) {
			final String key = lit_key_it.next();
			// get lit table index from end of sort key string
			cur_lit = Integer.valueOf(key.substring(key.length()-sort_index_len)) - sort_index_bias;
			String lit = lit_name[cur_lit];
			if (lit.length() < 8) {
				lit = lit.concat("       ").substring(0,8);
			}
			String lit_line = " LIT=" + lit
							+ " LOC=" + tz390.get_hex(lit_loc[cur_lit],8)
							+ " LEN=" + tz390.get_hex(lit_len[cur_lit],8)
							+ " ESD=" + tz390.get_hex(lit_esd[cur_lit],4)
							+ " POOL=" + tz390.get_hex(lit_pool[cur_lit],4);
			if (tz390.opt_xref  && lit_xref[cur_lit] != null) {
				lit_line = lit_line + " XREF=";
				final Iterator<Integer> lit_xref_it = lit_xref[cur_lit].iterator();
				while (lit_xref_it.hasNext()) {
					final int lit_xref_num = lit_xref_it.next();
					lit_line = lit_line + lit_xref_num + " ";
					if (lit_line.length() > tz390.max_line_len) {
						put_prn_line(lit_line);
						lit_line = "  ";
					}
				}
			}
			if (lit_line.length() > 2) {
				put_prn_line(lit_line);
			}
		}
		put_prn_line(" ");
	}

	/**
	 * Load BAL source.<br>
	 * <ol><li>Concatenate any continuations indicated by non-blank in position 72.<br>
	 *     Each continuation must start at position 16.</ol>
	 */
	private void load_bal()
	{
		if (!mz390_call) { // RPI-415
			String bal_file_name = tz390.get_file_name(tz390.dir_bal,tz390.pgm_name,tz390.pgm_type); // RPI-866
			bal_file = new File(bal_file_name);
			try {
				bal_file_buff = new BufferedReader(new FileReader(bal_file));
			} catch (final Exception e) {
				abort_error(6, "I/O error on BAL open - " + e.toString());
			}
		}
		get_bal_line();
		while (!bal_eof && bal_line != null
				&& tot_bal_line < tz390.opt_maxline) {
			save_bal_line();
			parse_bal_line();
			bal_op_index = find_bal_op();
			if (bal_op_index > -1) { // RPI-274 OPSYN cancel
				process_bal_op();
			}
			if (bal_line != null) {
				tot_bal_line++;
				get_bal_line();
			}
		}
		if (!end_found) {
			process_end();
		}
		if (tot_bal_line >= tz390.opt_maxline) {
			abort_error(83, "Maximum source lines exceeded.");
		}
		if (tz390.opt_tracea) {
			tz390.put_trace("PASS " + cur_pass + " TOTAL ERRORS = " + az390_errors);
		}
		if (!mz390_call) { // RPI-415
			try {
				bal_file_buff.close();
			} catch (final Exception e) {
				abort_error(7, "I/O error on BAL file close " + e.toString());
			}
		}
	}

	/**
	 * Pass mz390 bal_line to az390 bal_line with synchronization of threads<br>
	 * Ignore BAL after END.
	 *
	 * @param new_bal_line
	 * @param new_xref_file_name
	 * @param new_xref_file_type
	 * @param new_xref_file_num
	 * @param new_xref_line_num
	 */
	public void pass_bal_line(final String new_bal_line, final String new_xref_file_name, final char new_xref_file_type, final int new_xref_file_num, final int new_xref_line_num)
	{
		if (sym_lock) {
			abort_error(168, "BAL pass sym lock error on line - " + new_bal_line);
		}
		lock.lock(); // RPI-415
		try {
			if (pass_bal_eof) {
				return;
			}
			while (az390_running && bal_line_full) {
				lock_condition.await();
			}
			pass_bal_line = new_bal_line;
			pass_xref_file_name = new_xref_file_name;
			pass_xref_file_type = new_xref_file_type;
			pass_xref_file_num  = new_xref_file_num;
			pass_xref_file_line = new_xref_line_num;
			if (pass_bal_line == null || bal_eof) {
				pass_bal_eof = true;
			}
			bal_line_full = true;
			lock_condition.signalAll();
		} catch (final Exception e) {
			abort_error(152, "Waiting for az390 to release BAL line.");
		} finally {
			lock.unlock();
		}
	}

	/**
	 * Block mz390 until az390 is waiting for next BAL.<br>
	 * Set sym_lock.<br>
	 * <br>
	 * Notes:
	 * <ol><li>See az390 pass_bal for lock check.
	 *     <li>See mz390 put_bal_line for lock reset.</ol>
	 *
	 * @param desc
	 */
	public void set_sym_lock(final String desc)
	{
		sym_lock_desc = desc;
		// Wait for az390 to processing pending BAL
		while (az390_running
			&& (bal_line_full // RPI-485
				|| !az390_waiting)) {
			Thread.yield();
		}
		if (!lookahead_mode
			&& az390_thread != Thread.currentThread()) {
			sym_lock = true;
		} else {
			abort_error(167, "Invalid set sym lock request - " + sym_lock_desc);
		}
}

	/**
	 * Reset sym lock at next mz390 BAL line and at start of lookahead mode.
	 */
	public  void reset_sym_lock()
	{
		sym_lock = false;
	}

	/**
	 * Get next BAL line from BAL file or from mz390 parallel thread pass
	 */
	private void get_bal_line()
	{
		check_timeout();
		if (mz390_call) {
			lock.lock();
			try {
				az390_waiting = true;
				while (!bal_line_full) {
					lock_condition.await();
				}
				az390_waiting = false;
				bal_line = pass_bal_line;
				bal_xref_file_name = pass_xref_file_name;
				bal_xref_file_type = pass_xref_file_type;
				bal_xref_file_num  = pass_xref_file_num;
				bal_xref_file_line = pass_xref_file_line;
				if (bal_xref_file_name != null) {
					xref_file_name[bal_xref_file_num] = bal_xref_file_name;
					xref_file_type[bal_xref_file_num] = bal_xref_file_type;
				}
				bal_line_full = false;
				lock_condition.signalAll();
			} catch(final Exception e) {
				abort_error(151, "Waiting for mz390 to pass BAL line " + e.toString());
			} finally {
				lock.unlock();
			}
			if (lookahead_mode) {
				abort_error(157,"invalid pass bal record during lookahead - " + bal_line);
			}
			tz390.inc_cur_bal_line_num(bal_line);
			return;
		}

		String temp_line;
		try {
			tz390.systerm_io++;
			temp_line = bal_file_buff.readLine();
			tz390.cur_bal_line_num++;
			tz390.prev_bal_cont_lines = 0;
			save_bal_line(); // RPI-274
			if (temp_line == null) {
				bal_line = null;
			} else if (temp_line.length() < tz390.bal_ictl_end + 1		// RPI-437 RPI-728
					|| temp_line.charAt(tz390.bal_ictl_end) <= ' ') {	// RPI-181 RPI-728
				bal_line = tz390.trim_trailing_spaces(temp_line,tz390.bal_ictl_end + 1);  //RPI124 RPI-728
				if (!tz390.verify_ascii_source(bal_line)) {
					log_error(116, "Invalid ASCII source line " + tz390.cur_bal_line_num + " in " + bal_file.getAbsolutePath());  // RPI-694 RPI-769
				}
			} else {
				bal_line = temp_line.substring(0,tz390.bal_ictl_end);  // RPI-728
				bal_line = tz390.trim_continue(bal_line,tz390.split_first,tz390.bal_ictl_end,tz390.bal_ictl_cont); // RPI-728
				boolean bal_cont = true;
				while (bal_cont) { // RPI-181 RPI-315
					tz390.systerm_io++;
					temp_line = bal_file_buff.readLine();
					if (temp_line == null) {
						abort_error(117, "Missing continue source line " + tz390.cur_bal_line_num + " in " + bal_file.getAbsolutePath());
					}
					temp_line = tz390.trim_trailing_spaces(temp_line,tz390.bal_ictl_end + 1);  // RPI-728
					if (!tz390.verify_ascii_source(temp_line)) {
						abort_error(118, "Invalid ASCII source line " + tz390.cur_bal_line_num + " in " + bal_file.getAbsolutePath()); // RPI-694 RPI-769
					}
					if (temp_line.length() < tz390.bal_ictl_end + 1 || temp_line.charAt(tz390.bal_ictl_end) <= ' ') { //RPI181 RPI-278
						bal_cont = false; // RPI-315
						temp_line = tz390.trim_trailing_spaces(temp_line,tz390.bal_ictl_end + 1); //RPI124 RPI-728
					}
					tz390.prev_bal_cont_lines++;
					save_bal_line(); // RPI-274
					if (temp_line.length() >= tz390.bal_ictl_cont  // RPI-728
					 && temp_line.substring(tz390.bal_ictl_start - 1,tz390.bal_ictl_cont - 1).trim().equals("")) { // RPI167  RPI-728 no char preceding cont
						bal_line = bal_line + tz390.trim_continue(temp_line,tz390.split_cont,tz390.bal_ictl_end,tz390.bal_ictl_cont); // RPI-315, RPI-463 RPI-728
					} else {
						log_error(8, "Continuation line < " + tz390.bal_ictl_cont + " characters - " + temp_line);
					}
				}
			}
		} catch (Exception e) {
			abort_error(9, "I/O error on file read " + e.toString());
		}
	}

	/**
	 * Save BAL line during loading for log_error use.
	 */
	private void save_bal_line()
	{
		bal_line_index = tot_bal_line;
		bal_line_text[tot_bal_line] = bal_line;
		bal_line_num[tot_bal_line] = tz390.cur_bal_line_num;
		bal_line_xref_file_num[tot_bal_line] = bal_xref_file_num;
		bal_line_xref_file_line[tot_bal_line] = bal_xref_file_line;
		xref_bal_index = tot_bal_line; // for error xref during lookahead
	}

	/**
	 * Set bal_label and bal_op.
	 */
	private void parse_bal_line()
	{
		if (tz390.opt_tracea) {
			if (bal_line_xref_file_num[bal_line_index] == 0) {
				trace_pfx = "OPEN CODE" + tz390.right_justify("" + bal_line_xref_file_line[bal_line_index],6) + tz390.right_justify("" + bal_line_num[bal_line_index],7) + " ";
			} else {
				trace_pfx = tz390.left_justify(get_base_name(xref_file_name[bal_line_xref_file_num[bal_line_index]]),9) + tz390.right_justify("" + bal_line_xref_file_line[bal_line_index],6) + tz390.right_justify("" + bal_line_num[bal_line_index],7) + " ";
			}
			tz390.put_trace(trace_pfx + tz390.get_hex(loc_ctr,6) + " " + bal_line); // RPI-605
		}
		bal_abort = false;
		bal_label = null;
		bal_op    = null;
		bal_parms = null;
		if  (bal_line == null || bal_line.length() == 0 || bal_line.charAt(0) == '*') {
			return;
		}
		tz390.split_line(bal_line);
		bal_label = tz390.split_label;
		if (tz390.split_op != null) {
			bal_op = tz390.split_op.toUpperCase();
		} else {
			bal_op = null;
		}
		bal_parms = tz390.split_parms;
	}

	/**
	 * Return base file name from path\file.sfx.
	 *
	 * @param file_name
	 * @return
	 */
	private String get_base_name(final String file_name)
	{
		final int index1 = file_name.lastIndexOf(File.separator);
		int index2 = file_name.lastIndexOf('.');
		if (index2 <= index1) { // RPI-1210
			index2 = file_name.length();
		}
		return file_name.substring(index1+1,index2);
	}

	/**
	 * Return index of BAL operation<br>
	 * or return -1 if undefined operation<br>
	 * or return -2 if cancelled OPSYN<br>
	 * return 0 for comments
	 *
	 * @return
	 */
	private int find_bal_op()
	{
		int index = 0;
		if (bal_op != null && bal_op.length() > 0) {
			String key = bal_op;
			index = tz390.find_key_index('R',key);
			if (index >= 0 && tz390.opsyn_old_name[index] != null) {
				key = tz390.opsyn_old_name[index];  /// RPI-306
				bal_op = tz390.opsyn_old_name[index]; // RPI-493
			}
			index = tz390.find_key_index('O',key);
			if (index > -1) { // RPI-274 OPYSN cancel
				return index;
			} else if (mac_inline_level > 0) {
				return mac_inline_op_other; // RPI-581
			}
			label_match = label_pattern.matcher(bal_op);  // RPI-253
			if (!label_match.find()) {
				log_error(196, "Invalid character in opcode - " + bal_op);  // RPI-659
			} else {
				if (!tz390.opt_errsum) {
					tz390.init_errsum(); // RPI-694
				}
				log_error(29, "ERRSUM missing macro = " + bal_op); // RPI-694 RPI-1051
			}
			return -1;
		}
		if (bal_line.length() == 0 || bal_line.charAt(0) == '*') {
			return 0;
		} else {
			log_error(71, "Missing opcode - " + bal_line); // RPI-1034
			return - 1;
		}
	}

	/**
	 * Process EXTRN, ENTRY, or WXTRN statement.
	 *
	 * @param esd_type
	 */
	private void process_esd(final byte esd_type)
	{
		String token = null;
		boolean extrn_eod = false;
		extrn_match = extrn_pattern.matcher(bal_parms);
		while (!bal_abort && !extrn_eod && extrn_match.find()) {
			token = extrn_match.group();
			switch (token.charAt(0)) {
			case ',':
				break;
			case '\t':  //tab  RPI181
			case '\r':  //cr
			case '\n':  //lf
			case ' ':   //space
				extrn_eod = true;
				break;
			default:
				switch (esd_type) {
				case 3: // sym_ent
					cur_sid = find_sym(token);
					if (cur_sid != -1 // RPI-489
					 && sym_def[cur_sid] > sym_def_ref) {
						add_entry(token);
					} else {
						log_error(156, "ENTRY not found - " + token);
					}
					break;
				case 4: // sym_ext
					cur_sid = find_sym(token);
					if (!lookahead_mode
						&& (cur_sid == -1
						|| sym_def[cur_sid] == sym_def_lookahead) // RPI-415
						|| sym_def[cur_sid] != sym_cst) { // RPI-1044
						cur_sid = add_extrn(token);
					}
					break;
				case 8: // sym_wxt
					cur_sid = find_sym(token);
					if (!lookahead_mode
						&& (cur_sid == -1
						|| sym_def[cur_sid] == sym_def_lookahead) // RPI-415
						|| sym_def[cur_sid] != sym_cst) { // RPI-1044
						cur_sid = add_wxtrn(token);
					}
					break;
				}
			}
		}
	}

	/**
	 * Add EXTRN using V vs S key index.
	 *
	 * @param token
	 * @return
	 */
	private int add_extrn(final String token)
	{
		int index  = tz390.find_key_index('V',token.toUpperCase());
		if (index == -1) {
			index = add_sym(token);
		}
		if (index >= 1) {
			if (sym_def[index] == sym_def_ref
				&& sym_attr[index] == tz390.ascii_to_ebcdic['U']) {
				sym_type[index] = sym_ext;
				sym_attr[index] = tz390.ascii_to_ebcdic['T']; // RPI-415
				sym_esd[ index] = add_esd(index,sym_ext);
			}
		} else {
			abort_error(153, "Symbol table error on add extrn " + token);
		}
		return index; // RPI-1044
	}

	/**
	 * Add WXTRN using V vs S key index.
	 *
	 * @param token
	 * @return
	 */
	private int add_wxtrn(final String token)
	{
		int index = tz390.find_key_index('V',token.toUpperCase());
		if (index == -1) {
			index = add_sym(token);
		}
		if (index >= 1) {
			if (sym_def[index] == sym_def_ref
				&& sym_attr[index] == tz390.ascii_to_ebcdic['U']) {
				sym_type[index] = sym_wxt;
				sym_attr[index] = tz390.ascii_to_ebcdic['S']; // RPI-415
				sym_esd[index] = add_esd(index,sym_wxt);
			}
		} else {
			abort_error(154, "Symbol table error on add wxtrn " + token);
		}
		return index; // RPI-1044
	}

	/**
	 * Add ENTRY.
	 *
	 * @param token
	 */
	private void add_entry(final String token)
	{
		if (sym_type[cur_sid] == sym_rel || sym_type[cur_sid] == sym_cst) { // RPI-288
			int index = 1;
			while (index <= tot_esd) {
				if (esd_sid[index] == cur_sid) {
					return; // ESD already defined
				}
				index++;
			}
			add_esd(cur_sid,sym_ent);
		} else {
			log_error(97, "Invalid entry type symbol - " + sym_name[cur_sid]);
			cur_sid = -1;
		}
	}

	/**
	 * Add or update CSECT, DSECT, or loctr indicated by sym_cst, sym_dst, or sym_lct type parameter.<br>
	 *<br>
	 * Steps:
	 * <ol><li>Update previous section if any with max length and any loctr pointers.
	 *     <li>If name omitted used private cst/dst. RPI-254
	 *     <li>Add new section if not found or external reference found as local label.
	 *     <li>Reset location counter to end of current section.
	 *     <li>Update previous section type and sid for use in processing sym_lct sections.</ol>
	 *
	 * @param sect_type
	 * @param sect_name
	 */
	private void process_sect(final byte sect_type, String sect_name)
	{
		cur_sym_sect = true; // RPI-553
		if (cur_esd_sid > 0) {
			update_sect();
		}
		if (sect_name == null || sect_name.length() == 0) {
			sect_name = private_csect;  // private code
			if (mz390_call && cur_pass == 1) {
				az390_private_sect = true; // RPI-995
			}
		}
		cur_esd_sid = find_sym(sect_name);
		if (cur_esd_sid < 1 || sym_def[cur_esd_sid] == sym_def_ref) {
			// new section RPI-415
			if (cur_esd_sid == -1) {
				// add for first time
				cur_sid = add_sym(sect_name);
			} else {
				// replacing existing symbol
				cur_sid = cur_esd_sid;
				cur_esd_sid = -1;
			}
			if (cur_sid >= 1 && sym_def[cur_sid] <= sym_def_ref) {
				if (sym_type[cur_sid] != sym_ext && sym_type[cur_sid] != sym_wxt) {
					cur_esd = add_esd(cur_sid,sect_type);
					if (sect_type == sym_dst) {  // RPI-44
						loc_ctr = 0;  // reset for first time dsect
					}
				} else {
					cur_esd = sym_esd[cur_sid];
				}
			}
		} else if (sym_def[cur_esd_sid] <= sym_def_ref) {
			cur_sid = cur_esd_sid;
			cur_esd_sid = -1;
			if (sect_type == sym_dst) {  // RPI-44
				loc_ctr = 0;  // reset for first time dsect
			}
			init_sym_entry();
			if (!lookahead_mode) {
				cur_esd = add_esd(cur_sid,sect_type);
			}
		}
		if (!lookahead_mode) {
			if (cur_esd_sid < 1    // new section or extern redefine
			 || sym_def[cur_esd_sid] == sym_def_ref) { // RPI-182
				if (sect_type != sym_lct) {
					loc_ctr = (loc_ctr + 7)/8*8;
				}
				if (cur_esd_sid < 1) {
					cur_esd_sid = cur_sid; // new sect sid
				} else {
					cur_sid = cur_esd_sid; // cvt ext to csect
					cur_esd = sym_esd[cur_esd_sid];
					sym_def[cur_sid] = bal_line_index;
				}
				esd_sid[cur_esd]  = cur_sid;
				sym_esd[cur_sid]  = cur_esd;
				sym_def[cur_sid]  = bal_line_index;
				sym_attr[cur_sid] = bal_lab_attr;
				sym_type[cur_sid] = sect_type;
				sym_loc[cur_sid]  = loc_ctr;
				sym_len[cur_sid]  = 0;
				add_sym_xref(cur_sid);
				if (sect_type == sym_lct) {
					if (prev_sect_type != 0) {
						while (sym_sect_next[prev_sect_sid] > 0) {
							// RPI-372 chain new loctr to end of loctrs
							prev_sect_sid = sym_sect_next[prev_sect_sid];
						}
						sym_sect_prev[cur_esd_sid] = prev_sect_sid;
						sym_sect_next[prev_sect_sid] = cur_esd_sid;
						sym_type[cur_esd_sid] = prev_sect_type;
						esd_base[cur_esd] = esd_base[prev_sect_esd]; // RPI-301
					} else {
						log_error(90, "LOCTR must follow CSECT or DSECT.");
						sym_type[cur_esd_sid]  = sym_cst;
					}
				}
			} else if (sect_type == sym_type[cur_esd_sid]
					|| sect_type == sym_lct
					|| sym_type[cur_esd_sid] == sym_lct) { // RPI-553
				// Update previous section
				cur_esd = sym_esd[cur_esd_sid];
				loc_ctr = esd_loc[cur_esd]; // RPI-778
			} else {
				log_error(182, "Duplicate section name of different type.");
			}
			prev_sect_type = sym_type[cur_esd_sid];
			prev_sect_esd  = sym_esd[cur_esd_sid];
			prev_sect_sid = cur_esd_sid;
			loc_start = loc_ctr;
		}
	}

	/**
	 * Find symbol by name.
	 * <ol><li>Return defined symbol index else -1.
	 *     <li>If not lookahead mode<br>
	 *         If found, add xref else if vcon mode, add extrn</ol>
	 *
	 * @param name
	 * @return
	 */
	public int find_sym(String name) // RPI-415 public
	{
		int index = 0;
		if (dcv_type) {
			index  = tz390.find_key_index('V',name.toUpperCase());
			if (index == -1) {
				index = add_extrn(name);
			}
			add_sym_xref(index);
			return index;
		}
		index = tz390.find_key_index('S',name.toUpperCase());
		if (!lookahead_mode) {
			if (index != -1 && sym_def[index] != sym_def_lookahead) { // RPI-415
				add_sym_xref(index);
				if (sym_type[index] == sym_und) {  // RPI-694
					log_error(198, "Symbol not defined " + sym_name[index]);
				} else if (exp_equ && bal_line_index == sym_def[index]) {
					log_error(200, "Circular EQU expression error for " + sym_name[index]); // RPI-749
				} else if (exp_lit_mod && bal_line_index < sym_def[index]) {
					log_error(201, "Literal modifier forward reference for " + sym_name[index]); // RPI-749
				}
			} else if (exp_rld_len > 0) {
				index  = tz390.find_key_index('V',name.toUpperCase());
			}
		}
		return index;
	}

	/**
	 * Add or update relative labels and exclude CST, DST, EQU, USING symbols.
	 */
	public void update_label() // RPI-415
	{
		label_match = label_pattern.matcher(bal_label);  // RPI-253
		if (!label_match.find()
		 || !label_match.group().equals(bal_label)) {
			log_error(141, "Invalid symbol - " + bal_label);
			return;
		}
		cur_sid = find_sym(bal_label);
		if (cur_sid < 1) {
			if (bal_op.equals("USING")) {
				return;
			}
			cur_sid = add_sym(bal_label);
			init_sym_entry();
		} else if (sym_def[cur_sid] <= sym_def_ref) {
			init_sym_entry();
		} else if (sym_def[cur_sid] == bal_line_index) {
			if (sym_type[cur_sid] == sym_rel && !bal_op.equals("EQU")) {
				if (sym_loc[cur_sid] != loc_start) { // RPI-605
					sect_change_error();
					if (tz390.opt_trace // RPI-726
					 && gen_obj_code
					 && report_label_changes) {
						report_label_changes = false;
						log_error(187, "First label address change for " + bal_label + " from " + tz390.get_hex(sym_loc[cur_sid],6) + " to " + tz390.get_hex(loc_start,6));
					}
				}
				sym_loc[cur_sid] = loc_start;
				if (loc_len == 0) {
					sym_len[cur_sid] = dc_first_len;
					sym_scale[cur_sid] = dc_first_scale; // RPI-481
					sym_dc_type[cur_sid]     = (byte) dc_first_type; // RPI-790
					sym_dc_type_sfx[cur_sid] = (byte) dc_first_type_sfx; // RIP 790
				} else {
					sym_len[cur_sid] = loc_len;
				}
			}
		} else if (sym_def[cur_sid] > sym_def_ref
			   &&  sym_attr[cur_sid] != tz390.ascii_to_ebcdic['M']	// allow redefine macro label
			   && (sym_attr[cur_sid] != tz390.ascii_to_ebcdic['J']	// RPI-182
				   || (!cur_sym_sect								// RPI-553 don't allow sect + RX
					 && sym_loc[cur_sid] != loc_ctr					// unless RX address = section start
				))) {
			duplicate_symbol_error();
		}
	}

	/**
	 * Initialize sym variables for new or existing lookahead symbol table entry
	 */
	private void init_sym_entry()
	{
		if (lookahead_mode) {
			sym_def[cur_sid] = sym_def_lookahead;
		} else {
			sym_def[cur_sid] = bal_line_index;
		}
		sym_type[	 cur_sid] = sym_rel;
		sym_attr[	 cur_sid] = bal_lab_attr;
		sym_attr_elt[cur_sid] = bal_lab_attr_elt;
		sym_esd[	 cur_sid] = cur_esd;
		sym_loc[	 cur_sid] = loc_start;
		if (loc_len == 0) {
			sym_len[cur_sid]   = dc_first_len;
			sym_scale[cur_sid] = dc_first_scale; // RPI-481
			sym_dc_type[cur_sid]     = (byte)dc_first_type; // RPI-790
			sym_dc_type_sfx[cur_sid] = (byte)dc_first_type_sfx;
		} else {
			sym_len[cur_sid] = loc_len;
		}
	}

	/**
	 * Return total length of CSECT or DSECT.
	 *
	 * @param index
	 * @return
	 */
	private int get_sym_len(int index) {
		switch (sym_type[index]) {
		case 1: // CSECT or CSECT LOCTR
		case 2: // DSECT or DSECT LOCTR
			int tot_len = sym_max_loc[index] - sym_loc[index];
			if (sym_sect_prev[index] == 0) {
				while (sym_sect_next[index] > 0) {
					index = sym_sect_next[index];
					tot_len = tot_len + sym_max_loc[index] - sym_loc[index];
				}
				tot_len = (tot_len + 7)/8*8;
			}
			return tot_len;
		default: // other types (abs, rel, etc.)
			return sym_len[index];
		}
	}

	/**
	 * Update length of current section and save current loc_ctr for continue.
	 */
	private void update_sect()
	{
		if (loc_ctr - sym_loc[cur_esd_sid] > sym_len[cur_esd_sid]) {
			sym_len[cur_esd_sid] = loc_ctr - sym_loc[cur_esd_sid];
		}
		esd_loc[cur_esd] = loc_ctr; // RPI-778
	}

	/**
	 * Processing by request type:
	 * 1.  parse ds/dc bal statement and allocate or gen data items including alignment bytes where required.
	 * 2.  find or add literal table entry using ds/dc type single parm following = parm
	 * 3.  generate literal pool dc using loc_ctr set to referenced instruction.
	 * if LTORG, gen lits
	 * if not DC/DS/LTORG set dc_lit and process first field as literal and update exp_index
	 *
	 * @param request_type
	 */
	public void process_dc(final int request_type) // RPI-415
	{
		switch (request_type) {
		case 1: // process ds/dc statements
			check_private_csect();
			dc_field = bal_parms;
			if (dc_field == null) { // RPI-978
				log_error(205, "DS/DC missing operand.");
			}
			dc_index = 0;
			dc_lit_ref = false;
			dc_lit_gen = false;
			if (bal_op.equals("DC")
				&& gen_obj_code
				&& sym_type[esd_sid[esd_base[cur_esd]]] == sym_cst) { // RPI-564
				dc_op = true;
			} else {
				dc_op = false;
			}
			break;
		case 2:  // find or add literal table entry
			lit_loc_ref = false;
			dc_field = exp_text;
			dc_index = exp_index + 1;
			dc_lit_ref = true;
			dc_lit_gen = false;
			dc_op = false;
			dc_lit_index_start = dc_index;
			break;
		case 3:  // generate literal table entry
			check_private_csect();
			dc_field = lit_name[cur_lit];
			dc_index = 0;
			obj_code = "";
			list_obj_code = "";
			dc_lit_ref = false;
			dc_lit_gen = true;
			if (gen_obj_code
				&& sym_type[esd_sid[esd_base[cur_esd]]] == sym_cst) { // RPI-564
				dc_op = true;
			} else {
				dc_op = false;
			}
			break;
		}
		dc_first_field  = true;
		dc_bit_len      = false; // RPI-417
		dc_bit_tot      = 0;
		dc_len_explicit = false;
		while (!bal_abort && dc_index < dc_field.length()) {
			if (dc_field.charAt(dc_index) == ',' && !dc_lit_ref) {
				dc_index++;
			} else if (dc_field.charAt(dc_index) <= ' ') { //RPI181
				dc_index = dc_field.length();  // flush trailing comments
			}
			if (dc_lit_ref) {
				exp_lit_mod = true; // RPI-749
			}
			get_dc_field_dup();
			get_dc_field_type();
			get_dc_field_modifiers(); // RPI-368
			exp_lit_mod = false; // RPI-749
			if  (dc_index < dc_field.length()
			  && dc_field.charAt(dc_index) != ','
			  && dc_field.charAt(dc_index) > ' ') { //RPI181
				// process field data
				if (bal_abort || dc_field.charAt(dc_index) != dc_type_delimiter[dc_type_index]) {
					if (dc_type != 'C' ||
					   (dc_field.charAt(dc_index) != '"'      //RPI5
					   && dc_field.charAt(dc_index) != '!')) { //RPI73
						log_error(45, "Invalid dc delimiter for type - " + dc_field.substring(0,dc_index+1));
						return;
					}
				}
				dc_eod = false;
				switch (dc_type) {
				case 'A': // (exp1,,expn)
					process_dca_data();
					break;
				case 'B': // '0|1,0|1'
					process_dcb_data();
					break;
				case 'C': // 'text'
					process_dcc_data();
					break;
				case 'D': // 'fp,fp'
					process_dc_fp_data();
					break;
				case 'E': // 'fp,fp'
					process_dc_fp_data();
					break;
				case 'F': // 'int,int'
					process_dcf_data();
					break;
				case 'H': // 'int,int'
					process_dch_data();
					break;
				case 'L': // 'fp,fp'
					process_dc_fp_data();
					break;
				case 'P': // 'int,int'
					process_dcp_data();
					break;
				case 'S': // (exp1,expn)
					if (dc_bit_len) {
						log_error(172, "DC S invalid length.");
						return;
					}
					process_dcs_data();
					break;
				case 'V': // (exp1,expn)
					if (dc_bit_len) {
						log_error(173, "DC V invalid length.");
						return;
					}
					if (cur_esd > 0 && sym_type[esd_sid[esd_base[cur_esd]]] == sym_cst) { // RPI-564
						dcv_type = true;
						process_dca_data();
						dcv_type = false;
					} else {
						dc_op = false;
						process_dca_data();
					}
					break;
				case 'X': // 'int,int'
					process_dcx_data();
					break;
				case 'Y': // (exp1,,expn) length 2
					process_dca_data();
					break;
				case 'Z': // 'zoned decimals'
					process_dcz_data();
					break;
				default:
					log_error(44,"invalid dc type delimiter");
					break;
				}
			} else {
				// no field data so fill with zeros
				if (dc_op && dc_dup > 0) {
					log_error(189, "DC field with no data."); // RPI-609
				}
				dc_fill(dc_dup * dc_len); // RPI-265 align within ds/dc
				dc_len = 0;
			}
			dc_first_field = false;
			if (dc_lit_ref || dc_lit_gen) {
				if (dc_lit_gen && !gen_obj_code) {
					lit_loc[cur_lit] = loc_start;
				}
				exp_index = dc_index;
				dc_lit_ref = false;
				dc_lit_gen = false;
				return;
			}
			if (!(dc_index < dc_field.length())
				|| dc_field.charAt(dc_index) <= ' ' //RPI-181
				|| dc_field.charAt(dc_index) == dc_type_delimiter[dc_type_index]) {
				if (dc_bit_len) {
					flush_dc_bits(); // RPI-417
				}
				return;
			}
		}
		if (dc_bit_len) {
			flush_dc_bits(); // RPI-417
		}
		if (gen_obj_code && loc_ctr != cur_text_loc) {
			log_error(174, "Location counter / hex object code error");
		}
	}

	/**
	 * Calculate absolute value else abort.
	 *
	 * @return
	 */
	private boolean calc_abs_exp()
	{
		if (calc_exp() && exp_esd == 0) {
			return true;
		} else {
			log_error(32, "Invalid absolute value.");
		}
		return false;
	}

	/**
	 * Calculate relative value else abort.
	 *
	 * @return
	 */
	private boolean calc_rel_exp()
	{
		if (calc_exp() && exp_esd > 0) {
			return true;
		} else {
			log_error(33, "Invalid relative value.");
		}
		return false;
	}

	/**
	 * Set dca_ignore_refs for A and V type symbol refs if DS or DSECT
	 *
	 * @return
	 */
	private boolean calc_dca_exp()
	{
		if (!dc_op || dcv_type) {
			dca_ignore_refs = true;
			boolean temp_rc = calc_exp();
			dca_ignore_refs = false;
			return temp_rc;
		} else {
			return calc_exp();
		}
	}

	/**
	 * Parse abs/rel expression starting at exp_text.charAt(exp_index)
	 * return true if ok and set
	 * <ol><li>exp_val = abs or rel offset
	 *     <li>exp_esd = abs 0 or cst/dst esd
	 *     <li>exp_index = index to terminator which can be end of string, or (),</ol>
	 *
	 * @return true if ok (plus esp_val, esp_esd, esp_index)<br>else false
	 */
	private boolean calc_exp()
	{
		if (exp_text == null || exp_index > exp_text.length()) {
			exp_text = ""; // RPI-356
			return false;
		}
		exp_match = exp_pattern.matcher(exp_text.substring(exp_index));
		// exp_state = 1;
		exp_term = false;
		exp_eot  = false;
		exp_first_sym_len = true; // is this first exp symbol length
		exp_use_lab = null; // RPI-375
		exp_len = 1;
		tot_exp_stk_sym = 0;
		tot_exp_stk_op  = 0;
		tot_exp_rld_add = 0;
		tot_exp_rld_sub = 0;
		exp_sym_pushed = false;
		exp_sym_last = false;
		exp_level = 0;
		exp_op = " ";
		exp_type = sym_sdt;
		exp_attr = tz390.ascii_to_ebcdic['U'];
		while (!exp_term && !bal_abort) {
			if (!exp_op.equals(exp_term_op) && exp_match.find()) {
				exp_token = exp_match.group();
				exp_index = exp_index + exp_token.length();
			} else {
				exp_token = "" + exp_term_op;
				exp_eot = true;
			}
			proc_exp_token();
		}
		if (!bal_abort) {
			if (!exp_eot) {
				exp_index--;  // backup to terminator
			}
			return true;
		} else {
			return false;
		}
	}

	/**
	 * Parse general expression tokens
	 * <ol><li>Push sym or sdt.
	 *     <li>Exec or push operations + - * /
	 *     <li>Terminate on end of string or (),</ol>
	 */
	private void proc_exp_token()
	{
		check_prev_op = true;
		while (check_prev_op && !bal_abort) {
			exp_op = exp_token.toUpperCase();
			switch (exp_op.charAt(0)) {
			case '+':
				if (!exp_sym_pushed) {
					exp_token = "U+";
					exp_op = exp_token;
				}
				proc_exp_op();
				break;
			case '-':
				if (!exp_sym_pushed) {
					exp_token = "U-";
					exp_op = exp_token;
				}
				proc_exp_op();
				break;
			case '*':
				if (exp_sym_last) {
					proc_exp_op();
				} else {
					proc_loc_ctr();
				}
				break;
			case '/':
				proc_exp_op();
				break;
			case '(':
				if (exp_level == 0
				 && exp_sym_last
				 && tot_exp_stk_sym > 0) {
					exp_op = exp_term_op;
				}
				proc_exp_op();
				break;
			case ')':
				proc_exp_op();
				break;
			case '\t': //tab  RPI181
			case '\r': //cr
			case '\n': //lf
			case ' ':  //space
				exp_op = exp_term_op;
				proc_exp_op();
				break;
			case ',':
			case '\'': // terminator for DCF, DCH, expressions
				exp_op = exp_term_op;
				proc_exp_op();
				break;
			case '~':  // terminator
				proc_exp_op();
				break;
			case 'B':
				if (exp_token.length() > 2 && exp_token.charAt(exp_token.length()-1) == '\'') { // RPI-270
					proc_exp_sdt();
				} else {
					proc_exp_sym();
				}
				break;
			case 'C':
				if (exp_token.length() > 1
					&& (exp_token.charAt(exp_token.length()-1) == '\''   // RPI-270
					 || exp_token.charAt(exp_token.length()-1) == '"'    // RPI-5
					 || exp_token.charAt(exp_token.length()-1) == '!')) { // RPI-73, RPI-90
					proc_exp_sdt();
				} else {
					proc_exp_sym();
				}
				break;
			case 'I':  // RPI-790 I' operator
				if (exp_token.length() > 1 && exp_token.charAt(1) == '\'') {
					proc_exp_op();
				} else {
					proc_exp_sym();
				}
				break;
			case 'L':
				if (exp_token.length() > 1 && exp_token.charAt(1) == '\'') {
					proc_exp_op();
				} else {
					proc_exp_sym();
				}
				break;
			case 'S':  // RPI-790 S' operator
				if (exp_token.length() > 1 && exp_token.charAt(1) == '\'') {
					proc_exp_op();
				} else {
					proc_exp_sym();
				}
				break;
			case 'U':
				if (exp_token.length() == 2
				&& (exp_token.charAt(1) == '-'
				 || exp_token.charAt(1) == '+')) {
					proc_exp_op();
				} else {
					proc_exp_sym();
				}
				break;
			case 'X':
				if (exp_token.length() > 1 && exp_token.charAt(exp_token.length()-1) == '\'') { //RPI-270
					proc_exp_sdt();
				} else {
					proc_exp_sym();
				}
				break;
			case '=':
				push_exp_lit(); // RPI-365
				break;
			default:
				if (exp_op.charAt(0) <= '9' && exp_op.charAt(0) >= '0') {
					proc_exp_sdt();
				} else {
					proc_exp_sym();
				}
				break;
			}
		}
	}

	/**
	 * Push current location counter on stack.
	 */
	private void proc_loc_ctr()
	{
		exp_sym_last = true;
		check_prev_op = false;
		if (inc_tot_exp_stk_sym()) {
			if (cur_esd > 0) {
				exp_stk_sym_esd[tot_exp_stk_sym-1]= esd_base[cur_esd];  // RPI-301
				if (dc_lit_ref || dc_lit_gen) {
					lit_loc_ref = true;
					exp_stk_sym_val[tot_exp_stk_sym-1] = lit_line_loc[cur_lit] + dc_dup_loc;
				} else {
					exp_stk_sym_val[tot_exp_stk_sym-1] = loc_ctr;
				}
			} else {
				log_error(27, "Location counter undefined.");
			}
		}
	}

	/**
	 *
	 */
	private void proc_exp_sym()
	{
		if (exp_token.length() > 1 && exp_token.charAt(exp_token.length()-1) == '.') {
			if (gen_obj_code) {
				exp_use_lab = exp_token.substring(0,exp_token.length()-1).toUpperCase(); //RPI-987 add uc
			}
		} else {
			exp_sym_last = true;
			push_exp_sym();
		}
		check_prev_op = false;
	}

	/**
	 *
	 */
	private void proc_exp_sdt()
	{
		exp_sym_last = true;
		push_exp_sdt(exp_token);  // RPI-415 (was exp_op in caps)
		check_prev_op = false;
	}

	/**
	 *
	 */
	private void proc_exp_op()
	{
		if (tot_exp_stk_op > 0) {
			exp_prev_op = exp_stk_op[tot_exp_stk_op -1];
		} else {
			exp_prev_op = exp_start_op;
		}
		if (tz390.opt_traceall) {
			tz390.put_trace("EXP OPS=" + tot_exp_stk_op + " VARS=" + tot_exp_stk_sym + " PREV OP = " + exp_prev_op +  " NEXT OP = " + exp_token);
		}
		final int prev_op_class = exp_op_class[exp_prev_op.charAt(0)];
		if (prev_op_class == 0) {
			log_error(11,"invalid operator class for - " + exp_prev_op);
			return;
		}
		final int next_op_class = exp_op_class[exp_op.charAt(0)];
		if (next_op_class == 0) {
			log_error(12, "Invalid operator class - " + exp_op);
			return;
		}
		final int action = exp_action[tot_classes*(prev_op_class-1)+next_op_class-1];
		if (tz390.opt_traceall) {
			tz390.put_trace("EXP OPS=" + tot_exp_stk_op + " VARS=" + tot_exp_stk_sym + " ACTION = " + action + " PREV CLASS = " + prev_op_class + " NEXT CLASS = " + next_op_class);
		}
		switch (action) {
		case 1: // add/sub
			if (exp_prev_op.equals("+")) {
				exp_add();
			} else {
				exp_sub();
			}
			break;
		case 2:  // mpy/div
			if (exp_prev_op.equals("*")) {
				exp_mpy();
			} else {
				exp_div();
			}
			break;
		case 3: // (
			exp_push_op();
			if (exp_op.charAt(0) == '(') {
				exp_level++;
			}
			check_prev_op = false;
			break;
		case 4: // )
			exp_pop_op();
			exp_level--;
			if (exp_level == 0 && bal_op.equals("AIF")) {
				exp_op = exp_term_op;
				exp_term();
			}
			check_prev_op = false;
			break;
		case 5: //  PFX operators (I', L', S', or U+ or U-) RPI-790
			exp_pop_op(); // RPI-9
			switch (exp_stk_op[tot_exp_stk_op].charAt(0)) {
			case 'I': // Integer operator
				exp_integer_op();
				break;
			case 'L': // length operator
				exp_len_op();
				break;
			case 'S': // Scale operator
				exp_scale_op();
				break;
			case 'U': // unary operator
				if (exp_sym_pushed) {
					if (exp_stk_op[tot_exp_stk_op].charAt(1) == '-') {
						exp_stk_sym_val[tot_exp_stk_sym-1] = - exp_stk_sym_val[tot_exp_stk_sym -1];
					}
				} else if (exp_token.charAt(0) == 'U') {
					if (exp_token.charAt(1) == exp_stk_op[tot_exp_stk_op].charAt(1)) {
						exp_token = "U+";
					} else {
						exp_token = "U-";
					}
					exp_op = exp_token;
				} else {
					log_error(123, "Missing unary operand value.");
				}
				break;
			default:
				log_error(124, "Invalid prefix operator type.");
			}
			break;
		case 6: // terminator space, comma, unmatched )
			exp_term();
			check_prev_op = false;
			break;
		case 7: // check if ( is terminator after value
			if (exp_sym_last) {
				exp_term();
			} else {
				exp_push_op();
				exp_level++;
			}
			check_prev_op = false;
			break;
		default:
			log_error(13, "Expression parsing error."); // RPI-260
		}
	}

	/**
	 * Add top of stack value to previous value and pop the top stack value off.
	 */
	private void exp_add()
	{
		get_stk_sym();
		if (sym_esd1 != 0 || sym_esd2 != 0) {
			if ((sym_esd1 > 0) && (sym_esd2 > 0)) {
				add_rld(sym_esd1);
				add_rld(sym_esd2);
				// sym_type1 = sym_rld;
				sym_esd1  = esd_cpx_rld;
			} else if ((sym_esd1 == esd_cpx_rld) || (sym_esd2 == esd_cpx_rld)) {
				if (sym_esd1 > 0) {
					add_rld(sym_esd1);
				} else if (sym_esd2 > 0) {
					add_rld(sym_esd2);
				}
				// sym_type1 = sym_rld;
				sym_esd1 = esd_cpx_rld;
			} else {
				if (sym_esd2 > 0) {
					sym_esd1 = sym_esd2;
				}
			}
		}
		sym_val1 = sym_val1 + sym_val2;
		put_stk_sym();
	}

	/**
	 * Sub top of stack value from previous value and pop the top stack value off.
	 */
	private void exp_sub()
	{
		get_stk_sym();
		if (sym_esd1 > 0 || sym_esd2 > 0) {
			if  (sym_esd1 > 0 && sym_esd2 > 0) {
				if (sym_esd1 == sym_esd2) {
					sym_esd1 = 0;
					sym_esd2 = 0;
					// sym_type1 = sym_sdt;
					// sym_type2 = sym_sdt;
				} else {
					add_rld(sym_esd1);
					sub_rld(sym_esd2);
					// sym_type1 = sym_rld;
					sym_esd1  = esd_cpx_rld;
				}
			} else if (sym_esd1 == esd_cpx_rld
					|| sym_esd2 == esd_cpx_rld
					|| sym_esd2 > 0) {
				if (sym_esd1 > 0) {
					add_rld(sym_esd1);
				} else if (sym_esd2 > 0) {
					sub_rld(sym_esd2);
				}
				// sym_type1 = sym_rld;
				sym_esd1  = esd_cpx_rld;
			}
		}
		sym_val1 = sym_val1 - sym_val2;
		put_stk_sym();
	}

	/**
	 * mpy top of stack value to previous value and pop the top stack value off.
	 */
	private void exp_mpy()
	{
		get_stk_sym();
		if (sym_esd1 != 0 || sym_esd2 != 0) {
			log_error(58,"invalid rld multiplication - " + exp_text.substring(0,exp_index));
			return;
		}
		sym_val1 = sym_val1 * sym_val2;
		put_stk_sym();
	}

	/**
	 * div top of stack value into previous value and pop the top stack value off.
	 */
	private void exp_div()
	{
		get_stk_sym();
		if (sym_esd1 != 0 || sym_esd2 != 0) {
			log_error(59,"invalid rld division - " + exp_text.substring(0,exp_index));
			return;
		}
		if (sym_val2 == 0 && tz390.opt_allow) {
			log_error(60,"invalid rld division - " + exp_text.substring(0,exp_index));
			return;
		}
		if (sym_val2 != 0) {
			sym_val1 = sym_val1 / sym_val2;
		} else {
			sym_val1 = 0;  // by definition for HLASM
		}
		put_stk_sym();
	}

	/**
	 * Replace sym or lit on stack with integer I' attribute value.
	 */
	private void exp_integer_op() // RPI-790
	{
		if (tot_exp_stk_sym >= 1) {
			int temp_int = -1;
			if (cur_sid >  0) {
				temp_int = get_int_pfx(sym_dc_type[cur_sid],sym_dc_type_sfx[cur_sid],sym_len[cur_sid],sym_scale[cur_sid]);
			} else if (cur_lit >= 0) {
				temp_int = get_int_pfx(lit_dc_type[cur_lit],lit_dc_type_sfx[cur_lit],lit_len[cur_lit],lit_scale[cur_lit]);
			}
			if (temp_int >= 0) {
				exp_stk_sym_val[tot_exp_stk_sym - 1] = temp_int;
				exp_stk_sym_esd[tot_exp_stk_sym - 1] = sym_sdt;
			} else {
				log_error(25, "Invalid symbol for length attribute operator.");
			}
		} else {
			log_error(26, "Missing symbol for integer attribute.");
		}
	}

	/**
	 * Replace sym or lit on stack with length value.
	 */
	private void exp_len_op()
	{
		if (tot_exp_stk_sym >= 1) {
			int temp_len = -1;
			if (cur_sid >  0) {
				temp_len = sym_len[cur_sid];
			} else if (cur_lit >= 0) {
				temp_len = lit_len[cur_lit];
			}
			if (temp_len >= 0) {
				exp_stk_sym_val[tot_exp_stk_sym - 1] = temp_len;
				exp_stk_sym_esd[tot_exp_stk_sym - 1] = sym_sdt;
			} else {
				log_error(25, "Invalid symbol for length attribute operator.");
			}
		} else {
			log_error(26, "Missing symbol for length attribute.");
		}
	}

	/**
	 * Replace sym or lit on stack with scale value.
	 */
	private void exp_scale_op() // RPI-790
	{
		if (tot_exp_stk_sym >= 1) {
			int temp_scale = -1;
			if (cur_sid >  0) {
				temp_scale = sym_scale[cur_sid];
			} else if (cur_lit >= 0) {
				temp_scale = lit_scale[cur_lit];
			}
			if (temp_scale >= 0) {
				exp_stk_sym_val[tot_exp_stk_sym - 1] = temp_scale;
				exp_stk_sym_esd[tot_exp_stk_sym - 1] = sym_sdt;
			} else {
				log_error(25, "Invalid symbol for scale attribute operator.");
			}
		} else {
			log_error(26, "Missing symbol for length attribute.");
		}
	}

	/**
	 * Set stk_value1 & 2 from top of stack.
	 */
	private void get_stk_sym()
	{
		if (tot_exp_stk_sym >= 2) {
			sym_esd1 = exp_stk_sym_esd[tot_exp_stk_sym - 2];
			sym_val1 = exp_stk_sym_val[tot_exp_stk_sym - 2];
			if (sym_esd1 > 0) { // RPI-1198
				// sym_type1 = sym_rel;
			} else {
				// sym_type1 = sym_sdt;
			}
			sym_esd2 = exp_stk_sym_esd[tot_exp_stk_sym - 1];
			sym_val2 = exp_stk_sym_val[tot_exp_stk_sym - 1];
			if (sym_esd2 > 0) {
				// sym_type2 = sym_rel;
			} else {
				// sym_type2 = sym_sdt;
			}
		} else {
			log_error(17, "Expression parsing error."); // RPI-260
		}
	}

	/**
	 * Pop operator from op stack.<br>
	 * Pop sym_val2 off var stack.<br>
	 * Replace original sym_val1 on top of stack with result.
	 */
	private void put_stk_sym()
	{
		if ((tot_exp_stk_sym >= 2) && (tot_exp_stk_op > 0)) {
			tot_exp_stk_op--;
			tot_exp_stk_sym--;
			exp_stk_sym_esd[tot_exp_stk_sym - 1] = sym_esd1;
			exp_stk_sym_val[tot_exp_stk_sym - 1] = sym_val1;
		} else {
			log_error(18, "Expression parsing error.");
		}
		exp_sym_last = true;
	}

	/**
	 * Put current op on stack.<br>
	 * If unary minus push 0 var first.<br>
	 * If unary plus skip the push.
	 */
	private void exp_push_op()
	{
		if (tot_exp_stk_op > max_exp_stk) {
			abort_error(20,"Stack operation size exceeded.");
		}
		exp_stk_op[tot_exp_stk_op] = exp_op; // RPI-270 was exp_token with lc l'
		tot_exp_stk_op++;
		exp_sym_pushed = false;
		exp_sym_last = false;
	}

	/**
	 * Pop current op from stack.
	 */
	private void exp_pop_op()
	{
		tot_exp_stk_op--;
		if (tot_exp_stk_op < 0) {
			log_error(21, "Expression parsing error."); // RPI-260
		}
	}

	/**
	 * Terminate expression returning value on stack if no errors.
	 */
	private void exp_term()
	{
		if (tot_exp_stk_sym == 1 && tot_exp_stk_op == 0) {
			exp_term = true;
			exp_val = exp_stk_sym_val[0];
			exp_esd = exp_stk_sym_esd[0];
			if (exp_esd == esd_cpx_rld) {
				reduce_exp_rld();
			}
			if (exp_esd == esd_sdt) {
				exp_type = sym_sdt;
			} else if (exp_esd == esd_cpx_rld) {
				if (exp_rld_len > 0) { // RPI-893
					if (gen_obj_code) {
						gen_exp_rld();
					}
				} else {
					log_error(61, "Invalid complex rld expression: " + exp_text.substring(0,exp_index)); // RPI-1034
				}
			} else {
				if (gen_obj_code) {
					if (exp_rld_len > 0) { // RPI-894
						exp_rld_add_esd[0] = exp_esd;
						tot_exp_rld_add = 1;
						gen_exp_rld();
					}
				}
				exp_type = sym_rel;
			}
		} else {
			log_error(35, "Expression parsing error."); // RPI-260
		}
	}

	/**
	 * Push symbol on stack else abort set cur_sid > 0 used by L'
	 */
	private void push_exp_sym()
	{
		if (inc_tot_exp_stk_sym()) {
			cur_sid = find_sym(exp_token);
			if (cur_sid > 0
			&& (sym_def[cur_sid] >= sym_def_ref || lookahead_mode)) {  // RPI-488
				if (exp_first_sym_len) {
					exp_first_sym_len = false;
					exp_len = sym_len[cur_sid];
				}
				exp_stk_sym_esd[tot_exp_stk_sym-1]  = esd_base[sym_esd[cur_sid]]; // RPI-301
				exp_stk_sym_val[tot_exp_stk_sym-1]  = sym_loc[cur_sid];
			} else {
				if (dca_ignore_refs) {
					exp_stk_sym_esd[tot_exp_stk_sym-1]  = sym_sdt;
					exp_stk_sym_val[tot_exp_stk_sym-1]  = 0;
				} else {
					log_error(98,"symbol not found - " + exp_token);
					if (cur_sid < 0 && cur_pass > 1) {
						tot_missing_sym++;
						cur_sid = add_sym(exp_token); // RPI-694
						sym_type[cur_sid] = sym_und;  // RPI-694
						sym_loc[cur_sid]  = -1;       // RPI-694
						sym_len[cur_sid]  = -1;       // RPI-694
					}
				}
			}
		}
	}

	/**
	 * Push literal on stack else abort and set cur_lit >= 0 and cur_sit = -1
	 * for L' to determine that literal is on the stack.<br>
	 *<br>
	 * Note:
	 * <ul><li>Literal must be first term in exp since it may use calc_exp during
	 *     DC processing and then resets exp stack with lit address</ul>
	 */
	private void push_exp_lit() // RPI-365
	{
		cur_sid = -1; // RPI-365
		if (inc_tot_exp_stk_sym()) {
			exp_index--;
			get_lit_addr();
			if (!exp_match.find()) { // Skip lit exp term
				log_error(111, "Invalid literal token.");
			}
			if (cur_lit >= 0) {
				exp_len = lit_len[cur_lit];
				exp_stk_sym_esd[tot_exp_stk_sym-1]  = esd_base[lit_esd[cur_lit]]; // RPI-301
				exp_stk_sym_val[tot_exp_stk_sym-1]  = lit_loc[cur_lit];
			} else {
				if (dca_ignore_refs) {
					exp_stk_sym_esd[tot_exp_stk_sym-1]  = sym_sdt;
					exp_stk_sym_val[tot_exp_stk_sym-1]  = 0;
				} else {
					log_error(110,"literal not found - " + exp_token);
				}
			}
		}
		exp_sym_last = true;
		check_prev_op = false;
	}

	/**
	 * Check if room to add to exp_stack and return true else abort.
	 *
	 * @return
	 */
	private boolean inc_tot_exp_stk_sym() {
		if (tot_exp_stk_sym < max_exp_stk) {
			tot_exp_stk_sym++;
			exp_sym_pushed = true;
			return true;
		} else {
			abort_error(22, "Maximum stack variables exceeded. Maximum is " + max_exp_stk + " items.");
			return false;
		}
	}

	/**
	 * Push self defining abs term on stack.
	 *
	 * @param sdt
	 */
	private void push_exp_sdt(final String sdt)
	{
		if (inc_tot_exp_stk_sym()) {
			exp_stk_sym_esd[tot_exp_stk_sym-1] = sym_sdt;
			try {
				switch (sdt.toUpperCase().charAt(0)) {
				case 'B': // B'11000001' binary
					exp_stk_sym_val[tot_exp_stk_sym-1] = Long.valueOf(sdt.substring(2,sdt.length()-1),2).intValue(); // RPI-1099
					break;
				case 'C': //RPI192
					if (!tz390.get_sdt_char_int(sdt)) {
						log_error(138, "Invalid character sdt " + sdt);
					}
					exp_stk_sym_val[tot_exp_stk_sym-1] = tz390.sdt_char_int;
					break;
				case 'X': // X'C1' hex
					exp_stk_sym_val[tot_exp_stk_sym-1] = Long.valueOf(sdt.substring(2,sdt.length()-1),16).intValue();
					break;
				default:
					exp_stk_sym_val[tot_exp_stk_sym-1] = (int) Double.valueOf(sdt).longValue();  // RPI-232 RPI-1101
					break;
				}
			} catch (Exception e) {
				log_error(163,"invalid sdt constant - " + sdt);
				exp_stk_sym_val[tot_exp_stk_sym-1] = 0;
			}
		}
	}

	/**
	 * Put statistics and display total errors after mz390 is done and close files.
	 * Note:
	 *  1. Return az390 return code for use by mz390 when called from mz390 when mfc option on.
	 */
	public void exit_az390()
	{
		if (!mz390_call) { // RPI-935 let mz390 do it if running
			put_stats(); // RPI-846
		}
		if (tz390.opt_errsum) {
			report_critical_errors();
		}
		if (!mz390_call) { // RPI-935
			close_files(); // RPI-935 - Let mz390 close after putting statistics.
		}
		if (mz390_call) { // RPI-415
			return;
		}
		System.exit(az390_rc);
	}

	/**
	 * Display statistics on STA and totals on STA and TRM including MZ and AZ totals.
	 */
	public void put_stats()
	{
		force_list_bal = true; // RPI-285
		tz390.force_nocon = true; // RPI-755
		if (tz390.opt_stats) {  // RPI-453
			put_stat_line("BAL lines             = " + (tot_bal_line-1));
			put_stat_line("symbols               = " + tot_sym);
			put_stat_line("Literals              = " + tot_lit);
			put_stat_line("alloc passes          = " + (cur_pass-1));
			put_stat_line("Keys                  = " + tz390.tot_key);
			put_stat_line("Key searches          = " + tz390.tot_key_search);
			if (tz390.tot_key_search > 0) {
				tz390.avg_key_comp = tz390.tot_key_comp/tz390.tot_key_search;
			}
			put_stat_line("Key avg comps         = " + tz390.avg_key_comp);
			put_stat_line("Key max comps         = " + tz390.max_key_comp);
			put_stat_line("ESD symbols           = " + tot_esd);
			put_stat_line("object bytes          = " + tot_obj_bytes);
			put_stat_line("object rlds           = " + tot_rld);
			if (tz390.opt_timing) {
				final long tod_end = new Date().getTime();
				final long tot_sec = (tod_end - tod_start)/1000;
				put_stat_line("total seconds         = " + tot_sec);
			}
		}
		int index = 0;
		while (index < tot_xref_files) {
			if (mz390_call && xref_file_errors[index] > 0) {  // RPI-935
				String xref_msg  = "FID=" + tz390.right_justify(""+(index+1),3)
								+ " ERR=" + tz390.right_justify(""+xref_file_errors[index],4)
								+ " " + xref_file_name[index];
				put_log(msg_id_i + xref_msg);
				tz390.put_systerm(msg_id_i + xref_msg);
			}
			index++;
		}
		if (tz390.opt_stats) {
			put_stat_line("total mnote warnings  = " + tot_mnote_warning); // RPI-402
			put_stat_line("total mnote errors    = " + tot_mnote_errors);
			put_stat_line("max   mnote level     = " + max_mnote_level);
			if (mz390_call) {
				put_stat_line("total mz390 errors    = " + mz390_errors); // RPI-659
			}
			put_stat_line("total az390 errors    = " + az390_errors); // RPI-659
		}
		put_log(msg_id_i + "total mnote warnings = " + tot_mnote_warning); // RPI-402
		put_log(msg_id_i + "total mnote errors   = " + tot_mnote_errors);
		put_log(msg_id_i + "max   mnote level    = " + max_mnote_level);
		if (mz390_call) {
			put_log(msg_id_i + "total mz390 errors   = " + mz390_errors); // RPI-659
		}
		put_log(msg_id_i + "total az390 errors   = " + az390_errors); // RPI-659
		if (mz390_call) {
			tz390.systerm_prefix = tz390.left_justify(tz390.pgm_name,9) + " " + "MZ390 "; // RPI-755 RPI-1047
		}
		tz390.force_nocon = false; // RPI-755
	}

	/**
	 * Routine statistics line to PRN or STATS(file).
	 * @param msg
	 */
	private void put_stat_line(final String msg)
	{
		if (tz390.stats_file != null) {
			tz390.put_stat_line(msg);
		} else {
			put_log(msg_id_i + msg);
		}
	}

	/**
	 * Close output files OBJ, PRN, ERR, and TRA.
	 */
	public void close_files()
	{
		if (obj_file != null) {
			try {
				obj_file.close();
			} catch (final Exception e) {
				tz390.abort_error(24, "I/O error on obj close - " + e.toString());
			}
		}
		if (!mz390_call) { // RPI-415 let mz390 close it
			tz390.close_systerm(az390_rc);
		} else {
			if (mz390_rc > az390_rc) {
				az390_rc = mz390_rc;
			}
			tz390.set_ended_msg(az390_rc);
		}
		tz390.force_nocon = true;
		put_log(tz390.ended_msg);
		if (!mz390_call && tz390.opt_tracea) { // RPI-935 RPI-1050 moved within NOCON
			tz390.put_trace(tz390.ended_msg);
		}
		tz390.force_nocon = false;
		if (tz390.opt_list) {
			if (prn_file != null && prn_file.isFile()) {
				try {
					prn_file_buff.close();
				} catch (final Exception e) {
					tz390.abort_error(24, "I/O error on prn close - " + e.toString());
				}
			}
		}
		tz390.close_trace_file();
	}

	/**
	 * Issue error message to log with prefix and increase error total.<br>
	 * <br>
	 * Notes:
	 * <ol><li>Set bal_abort if not set else exit.
	 *     <li>Suppress if not gen_obj and not trace.
	 *     <li>Print BAL line first if list on.</ol>
	 *
	 * @param error
	 * @param msg
	 */
	private void log_error(final int error,final String msg)
	{
		if (bal_abort) return; // only 1 error per line
		bal_abort = true;
		az390_errors++;
		if (gen_obj_code && az390_rc < 12) { // RPI-1062
			az390_rc = 12;
		}
		if (gen_obj_code) { // RPI-484
			if (!mz390_abort) { // RPI-433 don't duplicate mz error line
				force_list_bal = true;  // RPI-285
				list_bal_line();
			}
			force_list_bal = true;  // RPI-285
			set_file_line_xref();
			if (tz390.opt_errsum) {  // RPI-694 (see mz390 log_error also
				if (error == 29) {   // undefined opcode
					if (!add_missing_macro(bal_op)) {
						abort_error(199,"max missing copy exceeded");
					}
				}
			} // RPI-895
			String error_msg = msg_id_e + "error " + tz390.right_justify("" + error,3); // RPI-1031
			if (dc_lit_gen) { // RPI-1031
				xref_file_line = " (" + (bal_line_xref_file_num[lit_line[cur_lit]]+1) + "/" + bal_line_xref_file_line[lit_line[cur_lit]] + ")";
				error_msg = error_msg + tz390.right_justify(xref_file_line + bal_line_num[lit_line[cur_lit]],15) + "   " + bal_line_text[lit_line[cur_lit]];
			} else {
				error_msg = error_msg + tz390.right_justify(xref_file_line + bal_line_num[bal_line_index],15) + "   " + bal_line_text[bal_line_index];
			}
			put_log(error_msg);
			tz390.put_systerm(error_msg);
			error_msg = msg_id_i + msg;
			tz390.force_nocon = true; // RPI-935
			put_log(error_msg);
			tz390.force_nocon = false; // RPI-935
			tz390.put_systerm(error_msg);
			force_list_bal = false;  // RPI-285
			list_bal_line = false; // RPI-891 suppress defail bal line
		}
		if (gen_obj_code && tz390.max_errors != 0 && az390_errors > tz390.max_errors) {
			abort_error(49,"max errors exceeded");
		}
	}

	/**
	 * Set xref_file_line passed from mz390 if available for use in error messages.
	 */
	private void set_file_line_xref()
	{
		if (mz390_call && xref_bal_index > -1) { // RPI-425 RPI-935
			if (gen_obj_code) {  // RPI-935
				xref_file_errors[bal_line_xref_file_num[xref_bal_index]]++;
			}
			xref_file_line = " (" + (bal_line_xref_file_num[xref_bal_index]+1) + "/" + bal_line_xref_file_line[xref_bal_index] + ")";
		} else {
			xref_file_line = "";
		}
	}

	/**
	 * Issue error message to log with prefix and increase error total.
	 *
	 * @param error
	 * @param msg
	 */
	private synchronized void abort_error(final int error,String msg) // RPI-646
	{
		az390_errors++;
		az390_rc = 16; // RPI-1062
		if (az390_recursive_abort || tz390.z390_abort) {
			msg = msg_id_i + "aborting due to recursive abort error " + error + " - " + msg;
			System.out.println(msg);
			tz390.put_systerm(msg);
			if (tz390.opt_errsum) {
				report_critical_errors();
			}
			if (mz390_call) {  // RPI-1062
				tz390.systerm_prefix = tz390.left_justify(tz390.pgm_name,9) + " MZ390 ";
			}
			tz390.close_systerm(az390_rc);
			bal_line_full = false;
			System.exit(az390_rc);
		}
		az390_recursive_abort = true;	// RPI-1062
		bal_abort = true;				// RPI-415
		tz390.z390_abort = true;
		tz390.opt_con = true;			// RPI-453
		force_list_bal = true;			// RPI-285
		list_bal_line();
		force_list_bal = true;			// RPI-285
		String error_msg = msg_id_e + "abort " + error + " on line " + bal_line_num[bal_line_index] + " " + bal_line_text[bal_line_index];
		put_log(error_msg);
		tz390.put_systerm(error_msg);
		error_msg = msg_id_i + msg;
		put_log(error_msg);
		tz390.put_systerm(error_msg);
		exit_az390();
	}

	/**
	 * Display az390 version, time stamp, and copyright if running stand-alone.
	 */
	private void put_copyright()
	{
		tz390.force_nocon = true; // RPI-755
		if (z390_log_text == null) {
			put_log(msg_id_i + Constants.sCopyright2011);
			put_log(msg_id_i + Constants.sCopyright2013);
			put_log(msg_id_i + Constants.sCopyright2018);
			put_log(msg_id_i + Constants.sGnuLicence);
		}
		put_log(msg_id_i + "program = " + tz390.dir_mlc + tz390.pgm_name);
		put_log(msg_id_i + "options = " + tz390.cmd_parms);
		tz390.force_nocon = false; // RPI-755
	}

	/**
	 * Write message to z390_log_text or console if running stand-alone.
	 *
	 * @param msg
	 */
	private synchronized void put_log(final String msg)
	{
		put_prn_line(msg);
		if (tz390.force_nocon) {
			return; // RPI-755
		}
		if  (z390_log_text != null) {
			z390_log_text.append(msg + "\n");
		} else {
			if (tz390.opt_con) { // RPI-453
				System.out.println(msg);
			}
		}
	}

	/**
	 * Put line to prt listing file
	 * If print_on and not suppressed by nogen.
	 * If print data, print all data.
	 *
	 * @param msg
	 */
	private void put_prn_line(final String msg)
	{
		String temp_hex;
		if (tz390.opt_tracea) {
			tz390.put_trace(msg); // RPI-564 additional tracea info
		}
		if (check_list_bal_line()) { // RPI-484  RPI-694 RPI-891
			try {
				tz390.systerm_io++;
				prn_file_buff.write(msg + tz390.newline); // RPI-500
				if (prn_file.length() > tz390.max_file_size) {
					abort_error(118,"maximum prn file size exceeded");
				}
				int index = 16;
				while (print_data[print_level]
					&& index < list_obj_code.length()) {
					list_obj_loc = list_obj_loc + 8;
					if (index + 16 > list_obj_code.length()) {
						temp_hex = list_obj_code.substring(index);
					} else {
						temp_hex = list_obj_code.substring(index,index+16);
					}
					String data_line = tz390.get_hex(list_obj_loc,6) + " " + temp_hex;
					if (tz390.opt_tracea) {
						tz390.put_trace(data_line); // RPI-564 additional tracea info
					}
					tz390.systerm_io++;
					prn_file_buff.write(data_line + tz390.newline); // RPI-500
					if (prn_file.length() > tz390.max_file_size) {
						abort_error(118,"maximum prn file size exceeded");
					}
					index = index + 16;
				}
				if (mnote_warning_msg.length() > 0) { // RPI-1056
					mnote_warning_msg = msg_id_e + mnote_warning_msg;
					prn_file_buff.write(mnote_warning_msg + tz390.newline);
					tot_mnote_warning++;
					if (az390_rc < 4) {
						az390_rc = 4;
					}
					if (max_mnote_level < 4) {
						max_mnote_level = 4;
					}
					tz390.put_systerm(mnote_warning_msg); // RPI-1056
					mnote_warning_msg = "";
				}
			} catch (final Exception e) {
				az390_errors++;
			}
		}
	}

	/**
	 * Check for extra parameters beyond end of last instruction parameter and issue error.
	 */
	private void check_end_parms()
	{
		if (!exp_eot
			&& exp_index < exp_text.length()
			&& exp_text.charAt(exp_index) > ' ') { // RPI-181
			log_error(122,"extra parameter found - " + exp_text.substring(exp_index));
		}
	}

	/**
	 * Put object code to OBJ file in hex or binary format.
	 *
	 * @param msg
	 */
	private void put_obj_line(final String msg)
	{
		if (obj_file == null || tz390.z390_abort) {
			return;
		}
		if (tz390.opt_traceall) {
			tz390.put_trace(msg); // RPI-564 additional traceall info
		}
		try {
			if (tz390.opt_objhex) {
				tz390.systerm_io++;
				obj_file.writeBytes(msg + tz390.newline); // RPI-500
			} else {
				cvt_obj_hex_to_bin(msg);
				if (!bal_abort) {
					tz390.systerm_io++;
					obj_file.write(bin_byte);
				}
			}
			if (obj_file.length() > tz390.max_file_size) {
				abort_error(119, "Maximum obj file size exceeded.");
			}
		} catch (final Exception e) {
			abort_error(28, "I/O error on OBJ file write - " + e.toString());
		}
	}

	/**
	 * Convert ASCII hex object string to binary 80 byte EBCDIC format for mainframe compatibility.<br>
	 * See DFSMS Program Management Manual reference.
	 *
	 * @param hex_rcd
	 */
	private void cvt_obj_hex_to_bin(final String hex_rcd)
	{
		try {
			int index = 0;
			int index1 = 0;
			bin_byte[0] = 0x02;        // 1    binary OBJ ID code
			String type = hex_rcd.substring(1,4);
			if (type.equals("ESD")) {   // 2-4 .ESD
				bin_byte[1] = tz390.ascii_to_ebcdic['E'];
				bin_byte[2] = tz390.ascii_to_ebcdic['S'];
				bin_byte[3] = tz390.ascii_to_ebcdic['D'];
				Arrays.fill(bin_byte, 4, 14, Constants.ebcdic_space);
									 // 15-16 ESD ID
				bin_byte[14] = (byte)Integer.valueOf(hex_rcd.substring(9,11),16).intValue();
				bin_byte[15] = (byte)Integer.valueOf(hex_rcd.substring(11,13),16).intValue();
				index = 16;			 // 17-72 up to 3 ESD entries
				index1 = 54;
				while (index < 24) {  // name at entry 1 - 8
					if (index1 < hex_rcd.length()) {
						bin_byte[index] = tz390.ascii_to_ebcdic[hex_rcd.charAt(index1)];
						index1++;
					} else {
						bin_byte[index] = Constants.ebcdic_space;
					}
					index++;
				}
				if (hex_rcd.substring(45,48).equals("CST")) {
					bin_byte[10] = 0;		// 11-12 SD entry bytes
					bin_byte[11] = 16;
					bin_byte[24] = 0x00;	// SD type at entry 9
											// 24 bit address at entry 10-12
					if (!hex_rcd.substring(18,20).equals("00")) {
						abort_error(132,"SD invalid 24 bit address - " + hex_rcd);
					}
					bin_byte[25] = (byte)Integer.valueOf(hex_rcd.substring(20,22),16).intValue();
					bin_byte[26] = (byte)Integer.valueOf(hex_rcd.substring(22,24),16).intValue();
					bin_byte[27] = (byte)Integer.valueOf(hex_rcd.substring(24,26),16).intValue();
					bin_byte[28] = 0x07;  // double word align at entry 13
					if (!hex_rcd.substring(31,33).equals("00")) {
						log_error(133,"SD invalid 24 bit length - " + hex_rcd); // RPI-851
						return;
					}
					bin_byte[29] = (byte)Integer.valueOf(hex_rcd.substring(33,35),16).intValue();
					bin_byte[30] = (byte)Integer.valueOf(hex_rcd.substring(35,37),16).intValue();
					bin_byte[31] = (byte)Integer.valueOf(hex_rcd.substring(37,39),16).intValue();
					Arrays.fill(bin_byte, 32, 80, Constants.ebcdic_space);
				} else if (hex_rcd.substring(45,48).equals("EXT")) {
					bin_byte[10] = 0;    // 11-12 ER entry bytes
					bin_byte[11] = 13;
					bin_byte[24] = 0x02; // ER type at entry 9
					Arrays.fill(bin_byte, 25, 28, Constants.ebcdic_space); // blank address at entry 10
					bin_byte[28] = 0x00; // byte alignment at entry 13
					Arrays.fill(bin_byte, 29, 80, Constants.ebcdic_space);
				} else if (hex_rcd.substring(45,48).equals("WXT")) {
					bin_byte[10] = 0;    // 11-12 WX entry bytes
					bin_byte[11] = 13;
					bin_byte[24] = 0x0A; // WX type at entry 9
					Arrays.fill(bin_byte, 25, 28, Constants.ebcdic_space); // blank address at entry 10
					bin_byte[28] = 0x00; // byte alignment at entry 13
					Arrays.fill(bin_byte, 29, 80, Constants.ebcdic_space);
				} else if (hex_rcd.substring(45,48).equals("ENT")) {
					bin_byte[10] = 0;    // 11-12 :D entry bytes
					bin_byte[11] = 16;
					bin_byte[24] = 0x01; // LD type at entry 9
					Arrays.fill(bin_byte, 25, 28, Constants.ebcdic_space); // blank ESD type 12-14 for LD
					if (!hex_rcd.substring(18,20).equals("00")) {
						log_error(134, "LD invalid 24 bit address - " + hex_rcd); // RPI-851
						return;
					}
					bin_byte[25] = (byte)Integer.valueOf(hex_rcd.substring(20,22),16).intValue();
					bin_byte[26] = (byte)Integer.valueOf(hex_rcd.substring(22,24),16).intValue();
					bin_byte[27] = (byte)Integer.valueOf(hex_rcd.substring(24,26),16).intValue();
					bin_byte[28] = 0x00; // byte align at entry 13}
					bin_byte[29] = 0x00; // SD identifier for entry
					bin_byte[30] = (byte)Integer.valueOf(hex_rcd.substring(9,11),16).intValue();
					bin_byte[31] = (byte)Integer.valueOf(hex_rcd.substring(11,13),16).intValue();
					Arrays.fill(bin_byte, 32, 80, Constants.ebcdic_space);
				} else {
					log_error(131,"invalid ESD type " + hex_rcd); // RPI-851
					return;
				}
			} else if (type.equals("TXT")) {
				bin_byte[1] = tz390.ascii_to_ebcdic['T'];
				bin_byte[2] = tz390.ascii_to_ebcdic['X'];
				bin_byte[3] = tz390.ascii_to_ebcdic['T'];
				bin_byte[4] = Constants.ebcdic_space;
										// 6-8 address at
				if (!hex_rcd.substring(18,20).equals("00")) {
					log_error(134,"TXT invalid 24 bit address - " + hex_rcd);
					return;
				}
				bin_byte[5] = (byte)Integer.valueOf(hex_rcd.substring(20,22),16).intValue();
				bin_byte[6] = (byte)Integer.valueOf(hex_rcd.substring(22,24),16).intValue();
				bin_byte[7] = (byte)Integer.valueOf(hex_rcd.substring(24,26),16).intValue();
				bin_byte[8] = Constants.ebcdic_space;
				bin_byte[9] = Constants.ebcdic_space;
				bin_byte[10] = 00;		// 11-12 number of text bytes
				bin_byte[11] = (byte)Integer.valueOf(hex_rcd.substring(31,33),16).intValue();
				bin_byte[12] = Constants.ebcdic_space;
				bin_byte[13] = Constants.ebcdic_space;
										// 15-16 SD type
				bin_byte[14] = (byte)Integer.valueOf(hex_rcd.substring(9,11),16).intValue();
				bin_byte[15] = (byte)Integer.valueOf(hex_rcd.substring(11,13),16).intValue();
				index  = 16;
				index1 = 34;
				int count = bin_byte[11];
				while (count > 0) {
					bin_byte[index] = (byte)Integer.valueOf(hex_rcd.substring(index1,index1+2),16).intValue();
					index++;
					index1 = index1+2;
					count--;
				}
				Arrays.fill(bin_byte, index, 80, Constants.ebcdic_space);
			} else if (type.equals("RLD")) {
				bin_byte[1] = tz390.ascii_to_ebcdic['R'];
				bin_byte[2] = tz390.ascii_to_ebcdic['L'];
				bin_byte[3] = tz390.ascii_to_ebcdic['D'];
				Arrays.fill(bin_byte, 4, 10, Constants.ebcdic_space);
				bin_byte[10] = 0;		// 11-12 number of bytes for RLD entries
				bin_byte[11] = 8;
				Arrays.fill(bin_byte, 12, 16, Constants.ebcdic_space);
										// 17-18 ESD ID of referenced ESD
				bin_byte[16] = (byte)Integer.valueOf(hex_rcd.substring(45,47),16).intValue();
				bin_byte[17] = (byte)Integer.valueOf(hex_rcd.substring(47,49),16).intValue();
										// 19-20 ESD ID of SD containing RLD field
				bin_byte[18] = (byte)Integer.valueOf(hex_rcd.substring(9,11),16).intValue();
				bin_byte[19] = (byte)Integer.valueOf(hex_rcd.substring(11,13),16).intValue();
										// 20 flags TTTTLLSN
				int  rld_len =  Integer.valueOf(hex_rcd.substring(31,32),16).intValue()
								- 1;	// rld field len -1  4=3, 3=2, 2=1, 8=0 RPI-270 RPI-894
				if (rld_len == 7) {
					rld_len = 0;  // RPI-270 RPI-894
				}
				char rld_sign = hex_rcd.charAt(38);
				if (rld_sign == '+') {
					bin_byte[20] = (byte)(rld_len << 2); // pos rld
				} else {
					bin_byte[20] = (byte)(rld_len << 2 + 2); // neg rld
				}
										// 22-24 address at
				if (!hex_rcd.substring(18,20).equals("00")) {
					log_error(135, "RLD invalid 24 bit address - " + hex_rcd); // RPI-851
					return;
				}
				bin_byte[21] = (byte)Integer.valueOf(hex_rcd.substring(20,22),16).intValue();
				bin_byte[22] = (byte)Integer.valueOf(hex_rcd.substring(22,24),16).intValue();
				bin_byte[23] = (byte)Integer.valueOf(hex_rcd.substring(24,26),16).intValue();
				Arrays.fill(bin_byte, 24, 80, Constants.ebcdic_space);
			} else if (type.equals("END")) {
				bin_byte[1] = tz390.ascii_to_ebcdic['E'];
				bin_byte[2] = tz390.ascii_to_ebcdic['N'];
				bin_byte[3] = tz390.ascii_to_ebcdic['D'];
				Arrays.fill(bin_byte, 4, 80, Constants.ebcdic_space);
				// 15-16 ESD ID of referenced ESD  RPI-1197
				bin_byte[14] = (byte)Integer.valueOf(hex_rcd.substring(9,11),16).intValue();
				bin_byte[15] = (byte)Integer.valueOf(hex_rcd.substring(11,13),16).intValue();
				// 6-8 relative entry address in ESD  RPI-1197
				if (!hex_rcd.substring(18,20).equals("00")) {
					log_error(211,"END invalid 24 bit entry address - " + hex_rcd); // RPI-851
					return;
				}
				bin_byte[5] = (byte)Integer.valueOf(hex_rcd.substring(20,22),16).intValue();
				bin_byte[6] = (byte)Integer.valueOf(hex_rcd.substring(22,24),16).intValue();
				bin_byte[7] = (byte)Integer.valueOf(hex_rcd.substring(24,26),16).intValue();
			} else {
				log_error(130,"invalid object record - " + hex_rcd); // RPI-851
				return;
			}
		} catch (final Exception e) {
			if (az390_errors == 0) { // ignore if prior errors
				log_error(136,"Invalid ascii hex object code - " + hex_rcd);
			}
		}
	}

	/**
	 * Format long into 16 byte hex string.
	 *
	 * @param work_long
	 * @return
	 */
	private String get_long_hex(final long work_long)
	{
		final String work_hex = Long.toHexString(work_long);
		return ("0000000000000000" + work_hex).substring(work_hex.length()).toUpperCase();
	}

	/**
	 * Format text string into hex string.
	 * If ascii_req true, generate ASCII else EBCDIC hex.
	 *
	 * @param text
	 * @param ascii
	 * @return
	 */
	private String string_to_hex(final String text, final boolean ascii)
	{
		int work_int = 0;
		StringBuffer hex = new StringBuffer(2 * text.length());
		int index = 0;
		while (index < text.length()) {
			if (ascii) {
				work_int = text.charAt(index) & 0xff;
			} else {
				work_int = tz390.ascii_to_ebcdic[text.charAt(index) & 0xff] & 0xff; // RPI-737
			}
			String temp_string = Integer.toHexString(work_int);
			if  (temp_string.length() == 1) {
				hex.append("0" + temp_string);
			} else {
				hex.append(temp_string);
			}
			index++;
		}
		return hex.toString().toUpperCase();
	}

	/**
	 * Format bytes into hex string.
	 * If chunk > 0 insert space after each chunk.
	 *
	 * @param bytes
	 * @param byte_start
	 * @param byte_length
	 * @param chunk
	 * @return
	 */
	private String bytes_to_hex(final byte[] bytes, final int byte_start, final int byte_length, final int chunk)
	{
		final StringBuffer hex = new StringBuffer(72);
		int index1 = 0;
		int hex_bytes = 0;
		while (index1 < byte_length) {
			int work_int = bytes[byte_start + index1] & 0xff;
			String temp_string = Integer.toHexString(work_int);
			if (temp_string.length() == 1) {
				hex.append("0" + temp_string);
			} else {
				hex.append(temp_string);
			}
			if (chunk > 0) {
				hex_bytes++;
				if (hex_bytes >= chunk) {
					hex.append(" ");
					hex_bytes = 0;
				}
			}
			index1++;
		}
		return hex.toString().toUpperCase();
	}

	/**
	 * <ol><li>Append obj_code to list_obj_code for print line (required by multiple DC calls).
	 *     <li>Exit if gen_obj_code not on or not CSECT.
	 *     <li>Buffer output of object text code for contiguous data in same ESD.
	 *     <li>Called from END processing with BAL_EOF to flush buffer.
	 *     <li>Reset obj_code for use by DC routines.</ol>
	 */
	private void put_obj_text()
	{
		if (tz390.z390_abort || mz390_abort) {
			return;
		}
		if (!bal_eof) { // flush buffer if bal_eof
			if (!gen_obj_code) {
				return;
			}
			if (cur_esd == 0 || sym_type[esd_sid[esd_base[cur_esd]]] != sym_cst) {  // RPI-564, RPI-301
				return;
			}
		}
		String temp_obj_line;
		if (exp_rld_mod_set) {
			list_obj_code = list_obj_code.concat(tz390.get_hex(exp_rld_mod_val,2*exp_rld_len)); // RPI-632
			exp_rld_mod_set = false;
		} else {
			list_obj_code = list_obj_code.concat(obj_code);
		}
		int obj_code_len = obj_code.length()/2;
		tot_obj_bytes = tot_obj_bytes + obj_code_len;
		if (cur_text_len > 0
			&& (bal_eof
				|| cur_text_esd != esd_base[cur_esd] // RPI-301
				|| cur_text_loc != loc_ctr)) {
			cur_text_loc = cur_text_loc - cur_text_len;
			temp_obj_line = ".TXT ESD=" + tz390.get_hex(cur_text_esd,4) + " LOC=" + tz390.get_hex(cur_text_loc - sym_loc[esd_sid[cur_text_esd]],8) + " LEN=" + tz390.get_hex(cur_text_len,2) + " " + cur_text_buff;
			put_obj_line(temp_obj_line);
			cur_text_len = 0;
		}
		if (bal_eof || bal_abort) return; // RPI-851
		if (cur_text_len == 0) {
			cur_text_esd = esd_base[sym_esd[esd_sid[cur_esd]]]; // RPI-301
			cur_text_loc = loc_ctr;
			cur_text_buff = "";
		}
		cur_text_buff = cur_text_buff.concat(obj_code);
		cur_text_len = cur_text_len + obj_code_len;
		cur_text_loc = cur_text_loc + obj_code_len;
		while (cur_text_len >= max_text_buff_len) {
			cur_text_loc = cur_text_loc - cur_text_len;
			temp_obj_line = ".TXT ESD=" + tz390.get_hex(cur_text_esd,4)
						  + " LOC=" + tz390.get_hex(cur_text_loc - sym_loc[esd_sid[cur_text_esd]],8)
						  + " LEN=" + tz390.get_hex(max_text_buff_len,2)
						  + " " + cur_text_buff.substring(0,2*max_text_buff_len);
			put_obj_line(temp_obj_line);
			cur_text_loc = cur_text_loc + cur_text_len;
			cur_text_buff = cur_text_buff.substring(2*max_text_buff_len);
			cur_text_len = cur_text_buff.length()/2;
		}
		obj_code = "";
	}

	/**
	 * Start private CSECT if no CSECT or DSECT.
	 */
	private void check_private_csect()
	{
		if (cur_esd == 0) {
			process_sect(sym_cst,"");
			first_cst_esd = cur_esd;
		}
	}

	/**
	 * Add or replace USING for code generation.
	 */
	private void add_using()
	{
		if (bal_parms == null) { // RPI-651
			log_error(195, "Missing USING parameters.");
			return;
		}
		get_use_range();
		if (bal_label != null) {
			cur_use_lab = bal_label.toUpperCase();
			drop_cur_use_label();
		} else {
			cur_use_lab = "";
		}
		use_eof = false;
		use_domain_tot = 0; // RPI-776
		get_use_domain();
		while (!use_eof) {
			use_domain_tot++;
			if (cur_use_lab.length() == 0 && !cur_use_depend) {
				drop_cur_use_reg(); // RPI-629
			}
			add_use_entry();
			get_use_domain();
			cur_use_base_loc = cur_use_base_loc + 4096;
		}
		if (use_domain_tot == 0) { // RPI-776
			log_error(202, "USING missing domain operand.");
		}
		if (tz390.opt_listuse) {
			list_use = true;
		}
	}

	/**
	 * Set cur_use_base esd, loc, and len.
	 */
	private void get_use_range()
	{
		cur_use_base_esd = 0;
		cur_use_base_loc = 0;
		cur_use_base_len = 0;
		exp_text = bal_parms.toUpperCase();  // RPI-776
		exp_index = 0;
		if (exp_text.length() > 1) { // RPI-776
			if (exp_text.charAt(0) == '(') {
				exp_index = 1;
				if (calc_exp()) { // RPI-1148 allow abs base
					cur_use_base_esd = exp_esd;
					cur_use_base_loc = exp_val;
				}
				if (exp_text.charAt(exp_index) == ',') {
					exp_index++;
				} else {
					log_error(104, "Missing domain for using.");
					return;
				}
				if (calc_rel_exp() && cur_use_base_esd == exp_esd) {
					cur_use_base_len = exp_val - cur_use_base_loc;
				} else {
					log_error(103, "Missing end of range value.");
					return;
				}
				if (exp_text.length() > exp_index && exp_text.charAt(exp_index) == ')') {
					exp_index++;
				} else {
					log_error(103, "Missing end of range value.");
					return;
				}
			} else {
				if (calc_exp()) { // RPI-1148 allow abs base
					cur_use_base_esd = exp_esd;
					cur_use_base_loc = exp_val;
				}
				cur_use_base_len = 4096;
			}
		}
	}

	/**
	 * Set cur_use_reg and cur_use_off from exp_text at exp_index set by get_use_range.<br>
	 * <br>
	 * Notes:
	 * <ul><li>get_rel_exp_bddd() is called for dependent using expressions to find reg and loc.</ul>
	 */
	private void get_use_domain()
	{
		cur_use_depend = false;
		cur_use_reg = 0;
		cur_use_off = 0;
		if (exp_text.length() > exp_index
		 && exp_text.charAt(exp_index) == ',') {
			exp_index++;  // RPI-776
			if (calc_exp()) {
				if (exp_type == sym_sdt) {
					cur_use_reg = exp_val;
				} else if (exp_type == sym_rel
						|| exp_type == sym_cst
						|| exp_type == sym_dst) { // RPI-274
					cur_use_depend =true;
					if (cur_use_lab == "") {
						drop_dependent_using(); // RPI-1056
					}
					hex_bddd = get_exp_bddd();
				}
			}
		} else {
			use_eof =true;
		}
	}

	/**
	 * Drop duplicate unlabeled dependent USING for same section and offset.
	 */
	private void drop_dependent_using() // RPI-1056
	{
		int index = cur_use_start;
		while (index < cur_use_end) {
			if (use_lab[index] == ""
			 && cur_use_base_esd == use_base_esd[index]
			 && cur_use_base_loc == use_base_loc[index]) {
				cur_use_end--;
				if (index < cur_use_end) { // RPI-431 was <
					move_use_entry(cur_use_end,index);
				}
			}
			index++;
		}
	}

	/**
	 * Drop one or more using registers or labeled using.
	 */
	private void drop_using()
	{
		if (tz390.opt_listuse) {
			list_use = true;
		}
		if (bal_parms == null
		 || bal_parms.length() == 0
		 || bal_parms.charAt(0) == ',') {
			cur_use_end = cur_use_start;
			return;
		}
		tz390.parm_match = tz390.parm_pattern.matcher(bal_parms);
		while (tz390.parm_match.find()) {
			cur_use_lab = tz390.parm_match.group().toUpperCase();  // RPI-431, RPI-987
			if (cur_use_lab.charAt(0) != ',') {
				if (cur_use_lab.charAt(0) > ' ') {
					if (tz390.find_key_index('U',cur_use_lab) != -1) {
						drop_cur_use_label();
					} else {
						exp_text = bal_parms.substring(tz390.parm_match.start()); // RPI-673
						exp_index = 0;
						if (calc_abs_exp()) {
							cur_use_reg = exp_val;
							explicit_drop_reg = true; // RPI-1052
							drop_cur_use_reg();
							explicit_drop_reg = false; // RPI-1052
							if (tz390.parm_match.start() + exp_index < bal_parms.length()) { // RPI-1052
								bal_parms = bal_parms.substring(tz390.parm_match.start() + exp_index);
								tz390.parm_match = tz390.parm_pattern.matcher(bal_parms);
							} else {
								return;
							}
						} else {
							log_error(101, "Invalid register expression - " + exp_text);
						}
					}
				} else {
					return; // end of parameters at white space
				}
			}
		}
	}

	/**
	 * Remove labeled using if found.
	 */
	private void drop_cur_use_label()
	{
		int index = cur_use_start;
		while (index < cur_use_end) {
			if (use_lab[index] != null && use_lab[index].equals(cur_use_lab)) {
				cur_use_end--;
				if (index < cur_use_end) { // RPI-431 was <
					move_use_entry(cur_use_end,index);
				}
			}
			index++;
		}
	}

	/**
	 * Remove cur_use_reg entries if found but not labeled usings.
	 */
	private void drop_cur_use_reg()
	{
		int index = cur_use_start;
		int dropped = 0; // RPI-1206
		while (index < cur_use_end) {
			if (use_lab[index] == ""  // RPI-431, RPI-451
			 && use_reg[index] == cur_use_reg) {
				cur_use_end--;
				dropped++; // RPI-1206
				if (index < cur_use_end) {
					move_use_entry(cur_use_end,index);
					index--; // RPI-1206 backup to check moved entry
				}
				// RPI-1205 return; // RPI-1052 exit after removing one
			}
			index++;
		}
		if (explicit_drop_reg == true && dropped == 0) { // RPI-1206
			log_error(207, "Active USING not found for DROP register - " + cur_use_reg); // RPI-1052
		}
	}

	/**
	 * Move use entry from index1 to index2.
	 *
	 * @param index1
	 * @param index2
	 */
	private void move_use_entry(final int index1, final int index2)
	{
		use_lab[	 index2] = use_lab[		index1];
		use_base_esd[index2] = use_base_esd[index1];
		use_base_loc[index2] = use_base_loc[index1];
		use_base_len[index2] = use_base_len[index1];
		use_reg[	 index2] = use_reg[		index1];
		use_reg_loc[ index2] = use_reg_loc[	index1];
	}

	/**
	 * Add use entry.
	 */
	private void add_use_entry()
	{
		if (cur_use_end < tz390.opt_maxcall) {
			cur_use = cur_use_end;
			cur_use_end++;
			use_lab[cur_use] = cur_use_lab;
			if (cur_use_lab.length() > 0
			 && tz390.find_key_index('U',cur_use_lab) == -1) {
				// create key to indicate using label
				if (!tz390.add_key_index(0)) {
					abort_error(87, "Key search table exceeded.");
				}
			}
			use_base_esd[cur_use] = cur_use_base_esd;
			use_base_loc[cur_use] = cur_use_base_loc;
			use_base_len[cur_use] = cur_use_base_len;
			use_reg[     cur_use] = cur_use_reg;
			use_reg_loc[ cur_use] = cur_use_off;
		} else {
			log_error(100, "Maximum active using table exceeded. Maximum is " + tz390.opt_maxcall + " items.");
		}
	}

	/**
	 * List current use table if LISTUSE.
	 */
	private void list_use()
	{
		int index = cur_use_start;
		boolean none = true;
		while (index < cur_use_end) {
			none = false;
			list_bal_line = true; // RPI-891
			put_prn_line("LISTUSE " + tz390.left_justify(sym_name[esd_sid[use_base_esd[index]]],8)
					  + " ESD=" + tz390.get_hex(use_base_esd[index],4)
					  + " LOC=" + tz390.get_hex(use_base_loc[index],8)
					  + " LEN=" + tz390.get_hex(use_base_len[index],5)
					  + " REG=" + tz390.get_hex(use_reg[index],1)
					  + " OFF=" + tz390.get_hex(use_reg_loc[index],5)
					  + " LAB=" + use_lab[index] );
			index++;
		}
		if (none) {
			list_bal_line = true; // RPI-891
			put_prn_line("LISTUSE NONE");
		}
	}

	/**
	 * Initialize object code with op code and initialize exp parser with parameters if op_offset = 1.
	 *
	 * @param op_offset
	 * @param op_len
	 */
	private void get_hex_op(final int op_offset, final int op_len)
	{
		hex_op = OpCodes.op_code[bal_op_index].substring(op_offset-1,op_offset - 1 + op_len);
		obj_code = obj_code + hex_op;
		if (op_offset == 1) {
			exp_text = bal_parms;
			exp_index = 0;
		}
	}

	/**
	 * Return single hex nibble char 0-f.
	 *
	 * @return
	 */
	private String get_hex_nib()
	{
		if (calc_abs_exp()) {
			if (exp_val >= 0 && exp_val <= 15) {
				return tz390.get_hex(exp_val,1);
			} else {
				log_error(81, "Invalid field value 0-15 " + exp_val);
			}
		} else {
			log_error(82, "Invalid field.");
		}
		return "h";
	}

	/**
	 * Append hex register from next parameter.
	 */
	private void get_hex_reg()
	{
		if (calc_abs_exp()) {
			if (exp_val >= 0 && exp_val <= 15) {
				obj_code = obj_code + tz390.get_hex(exp_val,1);
			} else {
				log_error(55, "Invalid register expression - " + exp_val);
				obj_code = obj_code + "r";
			}
		} else {
			log_error(41, "Invalid register value.");
			obj_code = obj_code + "r";
		}
	}

	/**
	 * Append zero nibbles.
	 *
	 * @param hex_ll
	 */
	private void get_hex_zero(final int hex_ll)
	{
		final String zeros = "00000000";
		obj_code = obj_code.concat(zeros.substring(0,hex_ll));
	}

	/**
	 * Verify and skip comma.
	 */
	private void skip_comma()
	{
		if (!bal_abort && exp_next_char(',')) {
			exp_index++;
		} else {
			log_error(50, "Missing operand comma - " + exp_text.substring(0,exp_index));
		}
	}

	/**
	 * Append hex byte from next parameter.
	 */
	private void get_hex_byte()
	{
		if (calc_abs_exp() && exp_val < 256) {
			obj_code = obj_code + tz390.get_hex(exp_val,2);
		} else {
			log_error(42, "Invalid byte value.");
			obj_code = obj_code + "ii";
		}
	}

	/**
	 * Append signed byte from next parameter. RPI-1146
	 */
	private void get_hex_byte_signed()
	{
		if (calc_exp() && exp_val < 128 && exp_val >= -128) {
			obj_code = obj_code + tz390.get_hex(exp_val,2);
		} else {
			log_error(209, "Invalid signed byte value.");
			obj_code = obj_code + "ii";
		}
	}

	/**
	 * Set hex_len, hex_bddd, and hex_bddd_loc from next parameter.
	 */
	private void get_hex_llbddd()
	{
		int ll = 1;
		int b  = 0;
		int ddd = 0;
		hex_ll = "ll";
		hex_bddd = "bddd";
		hex_bddd_loc = "      ";
		calc_lit_or_exp();
		if (!bal_abort) {
			if (exp_type == sym_rel) {
				hex_bddd_loc = tz390.get_hex(exp_val,6);
				hex_bddd = get_exp_bddd();
				ll  = get_exp_ll();
			} else {
				ddd = exp_val;
				if (exp_next_char('(')) {
					exp_index++;
					if (exp_next_char(',')) {
						ll = exp_len;
						exp_index++;
						if (calc_abs_exp()) {
							b = exp_val;
						}
					} else if (calc_abs_exp()) {
						if (exp_next_char(',')) {
							ll = exp_val;
							exp_index++;
							if (calc_abs_exp()) {
								b = exp_val;
							}
						} else {
							ll = exp_val;  // RPI-538 (was ll), RPI-613 (was b = exp_len in err)
						}
					}
					if (exp_next_char(')')) {
						exp_index++;
					} else {
						log_error(192, "Missing close )"); // RPI-637
					}
				}
				hex_bddd = get_exp_abs_bddd(b,ddd);
			}
			if (ll >= 0 && ll <= 256) {
				if (ll > 0) {
					ll--;
				}
				hex_ll = tz390.get_hex(ll,2);
			} else {
				log_error(206, "Invalid length - " + ll); // RPI-1033
			}
		}
	}

	/**
	 * Return explicit or implied length from exp_len.
	 *
	 * @return
	 */
	private int get_exp_ll()
	{
		int ll = exp_len;
		if (exp_next_char('(')) {
			if (calc_abs_exp()) {
				ll = exp_val;
			} else {
				return 1;
			}
		}
		if (ll >= 0 && ll <= 256) {
			return ll;
		} else {
			log_error(149, "Length exceeds 256 limit = " + ll); // RPI-955
			return 1;
		}
	}

	/**
	 * Append xbddd or xbdddhh hex object code from next parameter.
	 */
	private void get_hex_xbddd()
	{
		String hex_xbddd = "llbddd";
		calc_lit_or_exp();
		if (!bal_abort) {
			if (exp_type == sym_rel) {
				hex_bddd2_loc = tz390.get_hex(exp_val,6);
				hex_bddd2 = get_exp_bddd(); // RPI-1148
				hex_xbddd = get_exp_x() + hex_bddd2;
			} else {
				hex_xbddd = get_exp_abs_xbddd();
			}
		}
		obj_code = obj_code + hex_xbddd;
	}

	/**
	 * Get hex x from next (x) else 0.
	 *
	 * @return
	 */
	private String get_exp_x()
	{
		if (exp_next_char('(')) {
			exp_index++;
			if (calc_abs_exp() && exp_val >= 0 && exp_val <= 15) {
				exp_index++;
				return tz390.get_hex(exp_val,1);
			} else {
				log_error(40, "Invalid index register.");
				return "x";
			}
		} else {
			return "0";
		}
	}

	/**
	 * Append xbddd hex object code from next parameter.
	 */
	private void get_hex_xbdddhh2() {
		get_bdddhh = true; // RPI-387
		get_hex_xbddd();   // RPI-161,RPI-166
		get_bdddhh = false;
	}

	/**
	 * If add_code<br>
	 *		append bddd or bdddhh hex object code from next parm<br>
	 * else<br>
	 *		just set hex_bddd2<br>
	 *
	 * @param add_code
	 */
	private void get_hex_bddd2(final boolean add_code)
	{
		hex_bddd2 = null;
		calc_lit_or_exp();
		if (!bal_abort) {
			if (exp_type == sym_rel) {
				hex_bddd2_loc = tz390.get_hex(exp_val,6);
				hex_bddd2 = get_exp_bddd(); // RPI-1148
			} else {
				hex_bddd2 = get_exp_abs_bddd();
			}
		} else {
			hex_bddd2 = get_default_bddd();
		}
		if (add_code) {  //RPI120
			obj_code = obj_code + hex_bddd2;
		}
	}

	/**
	 * Return true if next exp_text char at exp_index is next_char.
	 *
	 * @param next_char
	 * @return
	 */
	private boolean exp_next_char(final char next_char)
	{
		if (exp_text != null && exp_index < exp_text.length() // RPI-822
		 && exp_text.charAt(exp_index) == next_char) {
			return true;
		} else {
			return false;
		}
	}

	/**
	 * Generate bdddhh where hhddd is 20 bit signed offset to b. RPI-387
	 */
	private void get_hex_bdddhh2()
	{
		get_bdddhh = true; // RPI-387
		get_hex_bddd2(true);
		get_bdddhh = false;
	}

	/**
	 * Append iiii signed offset (calc for label).
	 */
	private void get_hex_rel()
	{
		String hex_iiii = "iiii";
		if (calc_exp()) {
			if (exp_type == sym_rel) {
				hex_iiii = get_rel_exp_iiii();
			} else {
				if (exp_val > 0xffff0000 && exp_val <= 0xffff) {
					hex_iiii = tz390.get_hex(exp_val,4);
				} else {
					log_error(63, "Relative offset too large - " + exp_val);
				}
			}
		}
		obj_code = obj_code + hex_iiii;
	}

	/**
	 * Append llllllll signed offset (calc for label).
	 */
	private void get_hex_long()
	{
		String hex_llllllll = "llllllll";
		calc_lit_or_exp();  // RPI-954
		if (!bal_abort) { // RPI-954
			if  (exp_type == sym_rel) {
				hex_bddd2_loc = tz390.get_hex(exp_val,6); // RPI-949
				hex_llllllll = get_rel_exp_llllllll();
			} else {
				hex_llllllll  = tz390.get_hex(exp_val,8);
				hex_bddd2_loc = tz390.get_hex(exp_val,6); // RPI-949
			}
		}
		obj_code = obj_code + hex_llllllll;
	}

	/**
	 * Return relative signed half word offset from psw_loc to symbol in same csect at even address.<br>
	 * <br>
	 * Notes:
	 * <ul><li>Error if not same CSECT or too large or odd address.</ul>
	 *
	 * @return
	 */
	private String get_rel_exp_iiii()
	{
		String hex_iiii = "iiii";
		if (exp_esd == esd_base[cur_esd] || tz390.opt_allow) { // RPI-301 RPI-988
			int hw_off = (exp_val - loc_start)/2;
			if (hw_off >= -0x8000 && hw_off <= 0x7fff) {
				if ((exp_val & 0x1) == 0) {
					hex_iiii = tz390.get_hex(hw_off,4);
					hex_bddd2_loc = tz390.get_hex(exp_val,6);  // RPI-585
				} else {
					log_error(111, "Relative target address is odd - " + tz390.get_hex(exp_val,8));
				}
			} else {
				log_error(74, "Relative offset too large - " + tz390.get_hex(hw_off,8));
			}
		} else {
			log_error(75, "Relative offset not in same esd.");
		}
		return hex_iiii;
	}

	/**
	 * Return relative signed word offset from psw_loc to symbol in same csect at even address.<br>
	 * <br>
	 * Notes:
	 * <ul><li>Error if not same CSECT or odd address.</ul>
	 * @return
	 */
	private String get_rel_exp_llllllll()
	{
		String hex_llllllll= "llllllll";
		if (exp_esd == esd_base[cur_esd] || tz390.opt_allow) { // RPI-301 RPI-988
			if ((exp_val & 0x1) == 0) {
				exp_val = (exp_val - loc_start)/2;
				hex_llllllll = tz390.get_hex(exp_val,8);
			} else {
				log_error(112, "Relate target address odd - " + tz390.get_hex(exp_val,8));
			}
		} else {
			log_error(76, "Relative offset not in same esd.");
		}
		return hex_llllllll;
	}

	/**
	 * 1.  Return hex bddd based on exp_esd and exp_val set by calc_exp or calc_lit.
	 * 2.  If get_bdddhh is set, then 20 bit signed offset will be returned as bdddhh. RPI-387
	 * 2.  Set cur_reg and cur_reg_loc for use when called from dependent using with domain expression.
	 * 3.  If exp_use_lab is not null restrict using entries to labeled using.
	 *
	 * @return
	 */
	private String get_exp_bddd() // RPI-1148 supp 31 bit abs
	{
		if (!gen_obj_code) {
			return get_default_bddd();
		}
		if (exp_esd == 0 && exp_val >= 0) { // RPI-1196
			cur_use_reg = 0;
			cur_use_off = 0;
			if (get_bdddhh && exp_val <= 0xfffff) { // RPI-1148 RPI-1196
				return "0" + tz390.get_hex(exp_val,3) + tz390.get_hex(exp_val >>> 12,2);
			} else if (exp_val <= 0xfff) { // RPI-1196
				return "0" + tz390.get_hex(exp_val,3);
			}
		}
		cur_use_reg = -1;  // assume not found
		cur_use_off = 0x80000;
		cur_use_neg_reg = -1;
		cur_use_neg_off = 0xfff00000;
		int test_offset = 0;
		int test_len = 0;
		int index = cur_use_start;
		cur_esd_base = exp_esd; // RPI-301
		while (index < cur_use_end) {
			if (use_base_esd[index] == cur_esd_base // RPI-301
				&& ((exp_use_lab != null
				&& use_lab[index].equals(exp_use_lab))  // RPI-274
					|| (exp_use_lab == null  // RPI-609
					&& use_lab[index] == ""))) {
				test_offset = exp_val - use_base_loc[index];
				if (get_bdddhh) {
					test_len = max_hh;
				} else {
					test_len = use_base_len[index];
				}
				if (test_offset <= cur_use_off  // RPI-982
				 && test_offset + use_reg_loc[index] >= 0  // RPI-994
				 && test_offset < test_len) {
					if (cur_use_lab == ""
					 && test_offset == cur_use_off) {
						mnote_warning_msg = "MNOTE 4,'Duplicate USING ranges found for - "
								+ use_reg[index] + " and " + cur_use_reg
								+ " using highest'"; // RPI-1056
					}
					if (test_offset < cur_use_off
					 || use_reg[index] > cur_use_reg) { // RPI-982
						cur_use_reg = use_reg[index];
						cur_use_off = test_offset + use_reg_loc[index];
					}
				} else if (get_bdddhh
						&& test_offset >= cur_use_neg_off  // RPI-982
						&& test_offset < 0) {
							if (test_offset > cur_use_off
							 || use_reg[index] > cur_use_reg) { // RPI-982
								cur_use_neg_reg = use_reg[index];
								cur_use_neg_off = test_offset + use_reg_loc[index];
							}
				}
			}
			index++;
		}
		exp_use_lab = null;
		if (cur_use_reg >= 0) {  // RPI-465
			return get_exp_abs_bddd(cur_use_reg,cur_use_off);
		} else if (cur_use_neg_reg > 0) {
			cur_use_reg = cur_use_neg_reg;
			cur_use_off = cur_use_neg_off;
			return get_exp_abs_bddd(cur_use_reg,cur_use_off);
		} else {
			log_error(144, "No base register found.");
			exp_use_lab = null;
			return get_default_bddd();
		}
	}

	/**
	 * Return bddd or bdddhh from explicit ddd(b) with ddd in exp_val.
	 *
	 * @return
	 */
	private String get_exp_abs_bddd()
	{
		int b   = 0;
		int ddd = exp_val;
		if (exp_next_char('(')) {
			exp_index++;
			if (exp_next_char(',')) {
				exp_index++; // ignore , in (,b)
				log_error(183, "No index or length comma allowed."); // RPI-588
			}
			if (calc_abs_exp()) {
				b = exp_val;
			}
			if (exp_next_char(')')) {
				exp_index++;
			} else {
				log_error(193, "Unexpected character before close )");  // RPI-637 RPI-1034
			}
		} else {
			return get_exp_bddd(); // RPI-1148
		}
		return get_exp_abs_bddd(b,ddd);
	}

	/**
	 * Return xbddd or xbdddhh from explicit ddd(x,b) with ddd in exp_val.
	 *
	 * @return
	 */
	private String get_exp_abs_xbddd()
	{
		int x  = 0;
		int b   = 0;
		int ddd = exp_val;
		if (exp_next_char('(')) {
			exp_index++;
			if (exp_next_char(',')) {
				exp_index++;
				if (calc_abs_exp()) {
					b = exp_val;
				}
			} else if (calc_abs_exp()) {
				if (exp_next_char(',')) {
					x = exp_val;
					exp_index++;
					if (calc_abs_exp()) {
						b = exp_val;
					}
				} else {
					x = exp_val;  // RPI-612
				}
			}
			if (exp_next_char(')')) {
				exp_index++;
			} else {
				log_error(194, "Missing close ) ");  // RPI-637
			}
		} else {
			return "0" + get_exp_bddd(); // RPI-1148
		}
		return tz390.get_hex(x,1) + get_exp_abs_bddd(b,ddd);
	}

	/**
	 * Return bddd or bdddhh using exp_val displacement.
	 * @param b
	 * @param dddhh
	 * @return
	 */
	private String get_exp_abs_bddd(final int b, final int dddhh)
	{
		if (b < 0 || b > 15) {
			log_error(146, "Base out of range = " + b);
			return get_default_bddd();
		}
		if (get_bdddhh) {
			if (dddhh >= min_hh && dddhh < max_hh) {
				return (tz390.get_hex(b,1)
					  + tz390.get_hex(dddhh & 0xfff,3)
					  + tz390.get_hex((dddhh >> 12) & 0xff,2)).toUpperCase();
			} else {
				log_error(147, "Displacement dddhh out of range = " + dddhh);
				return get_default_bddd();
			}
		} else {
			if (dddhh >= 0 && dddhh < 4096) {
				return (tz390.get_hex(b,1)
					  + tz390.get_hex(dddhh,3)).toUpperCase();
			} else {
				log_error(148, "Displacement ddd out of range = " + dddhh);
				return get_default_bddd();
			}
		}
	}

	/**
	 * Return dup factor for dc_field else 1.
	 */
	private void get_dc_field_dup()
	{
		dc_dup_loc = 0;
		dc_dup = 1;
		if (dc_index >= dc_field.length()) {
			return;
		}
		if (dc_field.charAt(dc_index) == '(') {
			exp_text = dc_field;
			exp_index = dc_index + 1;
			if (calc_abs_exp()) {
				dc_index = exp_index + 1;
				dc_dup = exp_val;
			} else {
				dc_dup = -1;
			}
		} else {
			dc_dup = get_dc_int(dc_index);
		}
		if (dc_dup < 0) { // RPI-327
			log_error(43, "Invalid dc duplication factor.");
		}
	}

	/**
	 * Set dc_type and dc_type_index and verify valid type else abort.
	 */
	private void get_dc_field_type()
	{
		if (bal_abort || dc_index >= dc_field.length()) {
			dc_type_index = -1;
			log_error(145, "Missing DC field type.");
			return;
		}
		dc_type = dc_field.substring(dc_index,dc_index+1).toUpperCase().charAt(0);
		dc_index++;
		dc_type_index = dc_type_table.indexOf(dc_type);
		if (dc_type_index == -1) {
			log_error(51, "Invalid dc type - " + dc_field.substring(0,dc_index));
		}
	}

	/**
	 * 1.  Set L, S, E defaults
	 * 2.  Check modifiers based on type
	 *     a.  if DEL check for B/D/H and set tz390.fp_type
	 *     b.  if C check for A/E and set dc_type_sfx  // RPI-270
	 *     c.  if AFV check for D and set dc_type_sfx  // RPI-270
	 *     d.  if LQ ignore the Q for 16 byte default
	 *     e.  If S check for Y and set length 3
	 * 3.  Process explicit L length, S scale, and E exponent modifiers in any order
	 * 4.  Align and save first length if required
	 */
	private void get_dc_field_modifiers()
	{
		if (dc_type_index != -1) {
			dc_attr_elt = sym_attr_elt_def; // default for not explicit length
			dc_len = dc_type_len[dc_type_index];
		} else {
			dc_len = 1;
		}
		dc_len_explicit = false;
		dc_scale_explicit = false;  // RPI-777
		// dc_exp_explicit = false; // RPI-777
		dc_scale = 0; // 2**N  mantissa multiplier
		dc_exp   = 0; // 10**N exponent offset

		// set type suffix if any
		if (dc_index < dc_field.length()) {
			dc_type_sfx = dc_field.substring(dc_index,dc_index+1).toUpperCase().charAt(0);
			switch (dc_type) {
			case 'A': // RPI-270
				if (dc_type_sfx == 'D') {
					dc_index++;
					dc_len = 8; // RPI-270
				}
				break;
			case 'C': // RPI-270
				if (dc_type_sfx == 'A') {
					dc_index++;
				} else {
					if (dc_type_sfx == 'E') {
						dc_index++;
					}
				}
				break;
			case 'D':
				if (dc_type_sfx == 'B') {
					tz390.fp_type = tz390.fp_db_type;
					dc_index++;
				} else if (dc_type_sfx == 'D') {
					tz390.fp_type = tz390.fp_dd_type; // RPI-407
					dc_index++;
				} else {
					tz390.fp_type = tz390.fp_dh_type;
					if (dc_type_sfx == 'H') {
						dc_index++;
					}
				}
				break;
			case 'E':
				if (dc_type_sfx == 'B') {
					tz390.fp_type = tz390.fp_eb_type;
					dc_index++;
				} else if (dc_type_sfx == 'D') {
					tz390.fp_type = tz390.fp_ed_type; // RPI-407
					dc_index++;
				} else {
					tz390.fp_type = tz390.fp_eh_type;
					if (dc_type_sfx == 'H') {
						dc_index++;
					}
				}
				break;
			case 'F': // RPI-270
				if (dc_type_sfx == 'D') {
					dc_index++;
					dc_len = 8; // RPI-270
				}
				break;
			case 'L':
				if (dc_type_sfx == 'B') {
					tz390.fp_type = tz390.fp_lb_type;
					dc_index++;
				} else if (dc_type_sfx == 'D') {
					tz390.fp_type = tz390.fp_ld_type; // RPI-407
					dc_index++;
				} else if (dc_type_sfx == 'Q') { // RPI-555
					tz390.fp_type =tz390.fp_lq_type; // RPI-1108 LQ
					dc_index++;
				} else {
					tz390.fp_type = tz390.fp_lh_type;
					if (dc_type_sfx == 'H') {
						dc_index++;
					}
				}
				break;
			case 'S': // RPI-893
				if (dc_type_sfx == 'Y') {
					dc_index++;
					dc_len_explicit = true; // no SY alignment
					dc_len = 3;
				}
				break;
			case 'V': // RPI-270
				if (dc_type_sfx == 'D') {
					dc_index++;
					dc_len = 8; // RPI-270
				}
				break;
			}
		} else {
			dc_type_sfx = ' '; // RPI-388
		}

		// set explicit length, scale, exponent if any
		boolean check_mod = true;
		while (!bal_abort && check_mod) {
			if (dc_index < dc_field.length()
			 && dc_field.substring(dc_index,dc_index+1).toUpperCase().charAt(0) == 'L') {
				// explicit length
				dc_len_explicit = true;
				if (!bal_abort) {
					dc_attr_elt = tz390.ascii_to_ebcdic[dc_type_explicit.charAt(dc_type_index) & 0xff];  // RPI-737
				}
				if (dc_index+1 < dc_field.length() && dc_field.charAt(dc_index+1) == '.') {
					dc_index++;  // RPI-438 limited bit length support
					if (!dc_bit_len) {
						dc_bit_len = true; // RPI-417
						dc_bit_buff = BigInteger.valueOf(0);
						dc_bit_tot = 0;
					}
				} else if (dc_bit_len) {
					flush_dc_bits(); // RPI-417
				}
				dc_len = get_dc_mod_int();
				if (dc_len < 0) {
					log_error(185, "DS/DC negative length -" + dc_len);
				}
			} else if (dc_index < dc_field.length()
				 && dc_field.substring(dc_index,dc_index+1).toUpperCase().charAt(0) == 'S') {
					// explicit scale
					dc_scale_explicit = true; // RPI-777
					dc_scale = get_dc_mod_int();
			} else if (dc_index < dc_field.length()
				 && dc_field.substring(dc_index,dc_index+1).toUpperCase().charAt(0) == 'E') {
					// explicit exponent
					// dc_exp_explicit = true;
					dc_exp = get_dc_mod_int();
			} else {
				check_mod = false;
			}
		}

		// align and save first field attr.
		if (!dc_lit_ref
		 && !dc_len_explicit) { // RPI-265 align within DS/DC
			if (tz390.opt_align || dc_dup == 0) { // RPI-1073
				if (dc_len == 16) {
					if (tz390.fp_type == tz390.fp_lq_type) { // RPI-1108
						dc_align(16);
					} else {
						dc_align(8);
					}
				} else {
					dc_align(dc_len);
				}
			}
		}
		if (dc_first_field) {
			dc_first_type  = dc_type;
			dc_first_type_sfx = dc_type_sfx; // RPI-790
			bal_lab_attr   = tz390.ascii_to_ebcdic[dc_type];
			// dc_first_attr_elt = dc_attr_elt;
			bal_lab_attr_elt  = dc_attr_elt;
			if (dc_bit_len) { // RPI-417
				dc_first_len = (dc_len + 7)/8;
			} else {
				dc_first_len = dc_len;
			}
			dc_first_scale = dc_scale;
			dc_first_dup   = dc_dup; // RPI-1200
			loc_start = loc_ctr;
		}
	}

	/**
	 * Align to multiple of align_len from loc_ctr.
	 * If align_len > 8 use 8. RPI-373 removed by RPI-1108
	 * 
	 * @param align_len
	 */
	private void dc_align(final int align_len)
	{
		dc_fill((loc_ctr + align_len -1)/align_len*align_len - loc_ctr);
	}

	/**
	 * Flush any bits in dc_bit_buff to align to byte boundary for next field or end of DS.DC.
	 */
	private void flush_dc_bits()
	{
		if (dc_bit_tot > 0) {
			dc_bit_byte_len = (dc_bit_tot + 7)/8;
			if (dc_op) {
				dc_bit_fill = dc_bit_tot - (dc_bit_tot/8)*8;
				if (dc_bit_fill > 0) {
					dc_bit_buff = dc_bit_buff.shiftLeft(8 - dc_bit_fill);
				}
				dc_bit_bytes = dc_bit_buff.toByteArray();
				dc_bit_hex = "";
				int index = 0;
				if (dc_bit_byte_len > dc_bit_bytes.length) {
					while (index < dc_bit_byte_len - dc_bit_bytes.length) {
						dc_bit_hex = dc_bit_hex + "00";
						index++;
					}
					index = 0;
				} else if (dc_bit_byte_len < dc_bit_bytes.length) {
					index = 1;
				}
				while (index < dc_bit_bytes.length) {
					final String dc_hex_byte = Integer.toHexString(dc_bit_bytes[index] & 0xff).toUpperCase();
					if (dc_hex_byte.length() < 2) {
						dc_bit_hex = dc_bit_hex + "0" + dc_hex_byte;
					} else {
						dc_bit_hex = dc_bit_hex + dc_hex_byte;
					}
					index++;
				}
				obj_code = obj_code + dc_bit_hex;
				put_obj_text();
			}
			loc_ctr = loc_ctr + dc_bit_byte_len;
		}
		dc_bit_len = false;
	}

	/**
	 * DC filling.<br>
	 * <br>
	 * Increment loc_ctr by bytes if not bit mode else shift bits by bit length.<br>
	 * If DC and not first field fill with zeros.
	 *
	 * @param fill_len
	 */
	private void dc_fill(final int fill_len)
	{
		if (dc_bit_len) {
			dc_bit_buff = dc_bit_buff.shiftLeft(fill_len);
			dc_bit_tot  = dc_bit_tot + fill_len;
			return;
		}
		final int prev_loc_ctr = loc_ctr;
		loc_ctr = loc_ctr + fill_len;
		if (!dc_first_field && dc_op) {
			if (prev_loc_ctr < loc_ctr) {
				list_obj_code = list_obj_code + tz390.get_dup_string("0",2*(loc_ctr-prev_loc_ctr)); // RPI-411
			}
		}
	}

	/**
	 * Alloc or gen DS/DC A/V/Y type parms using prev. settings for dc_dup and dc_len.
	 * Also save first field dc_type, dc_len.
	 */
	private void process_dca_data()
	{
		exp_text = dc_field;
		dc_index++; // start inside (,,,)
		dc_data_start = dc_index;
		if (dc_op
		&& !dc_bit_len   // RPI-417
		&& ((dc_len >= 2 // RPI-893 Add AL2(RLD) > BDDD support
			&& dc_len <= 4)
			|| dc_len == 8)) { // RPI-182 RPI-270
			exp_rld_len = (byte) dc_len;
		} else {
			exp_rld_len = 0;
		}
		exp_index = dc_index;
		while (!dc_eod && !bal_abort) {
			while (!dc_eod && !bal_abort) {
				if  (calc_dca_exp()) {
					dc_index = exp_index;
					if (dc_bit_len) {
						gen_dca_bits();
					} else {
						gen_dca_bytes();
					}
					if (dc_field.length() > dc_index) {
						if (dc_field.charAt(dc_index) == ',') {
							exp_index++;
						} else if (dc_field.charAt(dc_index) == ')') {
							if (dc_dup > 1) { // RPI-2 start
								dc_index = dc_data_start;
								exp_index = dc_index;
								dc_dup--;
							} else {
								dc_eod = true;
							} // RPI-2
						} else {
							log_error(105, "Invalid dc data terminator - " + dc_field.substring(dc_index));
						}
					} else { // prevent trap on missing ) etc. RPI-817
						log_error(203, "Missing dc data terminator.");
					}
				}
			}
			dc_index++; // skip dca terminator
			dc_len = 0; // don't double count
		}
		exp_rld_len = 0;
	}

	/**
	 * Generate DCA exp_val in dc_bit_buff.<br><br>
	 * Notes:<br>
	 * <li>Shared by gen_dcb_bits()
	 */
	private void gen_dca_bits()
	{
		dc_bit_tot = dc_bit_tot + dc_len;
		if (dc_op && dc_dup > 0) {
			dc_bit_buff = dc_bit_buff.shiftLeft(dc_len);
			if (exp_val >= 0) {
				dc_bit_buff = dc_bit_buff.add(BigInteger.valueOf(exp_val));
			} else {
				dc_bit_value = ((long)(-1) >>> (64-dc_len)) & (long)(exp_val);
				dc_bit_buff = dc_bit_buff.add(BigInteger.valueOf(dc_bit_value));
			}
		}
	}

	/**
	 * Generate DCA byte field.
	 */
	private void gen_dca_bytes()
	{
		if (dc_op && dc_dup > 0) {
			if (exp_val >= 0 || dc_len <= 4) {
				obj_code = obj_code + tz390.get_hex(exp_val,2*dc_len);
			} else {
				obj_code = obj_code + ("FFFFFFFF").substring(0,2*dc_len-8) + tz390.get_hex(exp_val,8);
			}
			put_obj_text();
		}
		if (!dc_lit_ref && dc_dup > 0) {
			loc_ctr = loc_ctr + dc_len;
			dc_dup_loc = dc_dup_loc + dc_len;
		}
	}

	/**
	 * Allocate or generate DS/DC B type parameters using previous settings for dc_dup and dc_len.<br>
	 * Also save first field dc_len.<br><br>
	 * Notes:
	 * <li>Binary values are right aligned in explicit length fields.
	 */
	private void process_dcb_data()
	{
		dc_index++;   // start inside 'bin1,bin2,,'
		dc_data_start = dc_index;
		while (!dc_eod && !bal_abort) {
			int dcb_start = dc_index;
			while (!dc_eod && !bal_abort
				&& dc_index < dc_field.length()
				&& dc_field.charAt(dc_index) != '\''
				&& dc_field.charAt(dc_index) != ',') {
				dc_index++;
			}
			if (dc_index >= dc_field.length()) {
				log_error(65, "Invalid binary dc data " + dc_field.substring(dc_data_start));
				return;
			}
			dcb_len = dc_index - dcb_start;
			dcb_pad = 8 - (dcb_len - dcb_len/8*8);
			dcb_bin = "";
			if (dcb_pad != 8) {
				dcb_bin = "00000000".substring(0,dcb_pad) + dc_field.substring(dcb_start,dc_index);
			} else {
				dcb_bin = dc_field.substring(dcb_start,dc_index);
			}
			if (dc_bit_len) {
				gen_dcb_bits();
			} else {
				gen_dcb_bytes();
			}
			if (dc_field.charAt(dc_index) == ',') {
				dc_index++;
			} else if (dc_field.charAt(dc_index) == '\'') {
				dc_index++; // skip dch terminator
				dc_len = 0; // don't double count
				if (!bal_abort) {
					if (dc_dup > 1) {  //rpi2
						dc_index = dc_data_start;
						dcb_start = dc_index;
						exp_index = dc_index;
						dc_dup--;
					} else {
						dc_eod = true;
					} //rpi-2
				}
			} else {
				log_error(106, "Invalid dc data terminator - " + dc_field.substring(dc_index));
			}
		}
		exp_rld_len = 0;
	}

	/**
	 * Generate DCB type bit field in dc_bit_buff.
	 */
	private void gen_dcb_bits()
	{
		try {
			exp_val = Integer.valueOf(dcb_bin,2);
		} catch (final Exception e) {
			log_error(171, "Invalid binary constant");
			return;
		}
		gen_dca_bits();
	}

	/**
	 * Generate DCB byte length field.
	 */
	private void gen_dcb_bytes()
	{
		int index = 0;
		dc_hex = "";
		try {
			while (index < dcb_bin.length()) {
				final String dcb_hex = Integer.toHexString(Integer.valueOf(dcb_bin.substring(index,index+8),2).intValue()).toUpperCase();
				if (dcb_hex.length() < 2) {
					dc_hex = dc_hex + "0" + dcb_hex;
				} else {
					dc_hex = dc_hex + dcb_hex;
				}
				index = index + 8;
			}
		} catch (final Exception e) {
			log_error(197, "Invalid binary value string - " + dcb_bin);  // RPI-667
		}
		dcb_len = dc_hex.length()/2;
		if (dc_len_explicit) {
			if (dcb_len < dc_len) {
				dc_hex = tz390.get_dup_string("0",2*(dc_len-dcb_len)) + dc_hex; // RPI-411
			}
			if (dcb_len > dc_len) {
				dc_hex = dc_hex.substring(2*(dcb_len-dc_len));
				dcb_len = dc_len;
			}
		} else {
			dc_len = dcb_len;
		}
		if (!dc_len_explicit && dc_first_field) {
			dc_first_len = dc_len;
			dc_first_field = false;
		}
		if (dc_op && dc_dup > 0) {
			obj_code = obj_code + dc_hex;
			put_obj_text();
		}
		if (!dc_lit_ref && dc_dup > 0) {
			loc_ctr = loc_ctr + dc_len;
		}
	}

	/**
	 * Allocate or generate dc Cln'...' data using dc_dup and explicit dc_len if any.<br>
	 * Notes:
	 * <ol><li>C'..' default EBCDIC unless ASCII option
	 *     <li>C".." always ASCII regardless of option
	 *     <li>C!..! always EBCDIC regardless of option
	 *     <li>''|""|!! or && replaced with single '|"|! or &
	 *     <li>CA'...' always ASCII   RPI-270
	 *     <li>CE'...' always EBCDIC  RPI-270</ol>
	 */
	private void process_dcc_data()
	{
		dcc_text = "";
		dcc_len  = 0;
		String token = null;
		int dcc_next = 0;
		dcc_quote = dc_field.charAt(dc_index); // ',", or ! delimiter
		if (dcc_quote == '\'') {
			dcc_match = dcc_sq_pattern.matcher(dc_field.substring(dc_index + 1));
		} else if (dcc_quote == '"') {
			dcc_match = dcc_dq_pattern.matcher(dc_field.substring(dc_index + 1));
		} else {
			dcc_match = dcc_eq_pattern.matcher(dc_field.substring(dc_index + 1));
		}
		while (!dc_eod && !bal_abort && dcc_match.find()) {
			token = dcc_match.group();
			dcc_next = dcc_match.end();
			if (token.charAt(0) != dcc_quote
			 && token.charAt(0) != '\''  //RPI192
			 && token.charAt(0) != '&') { //RPI192
				dcc_text = dcc_text + token;
			} else if (token.length() == 2) {
				dcc_text = dcc_text + token.charAt(0); //RPI192
			} else if (token.charAt(0) == dcc_quote) {
				dc_eod = true;
			} else {
				log_error(137, "Invalid single " + token.charAt(0));
			}
		}
		if (!dc_eod) {
			log_error(52, "Invalid dc character literal - " + dc_field.substring(dc_index));
		}
		dc_index = dc_index + dcc_next + 1;
		dcc_len = dcc_text.length();
		dcc_ascii_req = (dcc_quote == '\'' && ((tz390.opt_ascii && dc_type_sfx != 'E') || dc_type_sfx == 'A')) | dcc_quote == '"';  //RPI5 and RPI73
		if (dc_bit_len) {
			gen_dcc_bits();
		} else {
			gen_dcc_bytes();
		}
		dc_len = 0;
	}

	/**
	 * Generate DCC bit field.
	 */
	private void gen_dcc_bits()
	{
		dc_bit_tot = dc_bit_tot + dc_len;
		if (dc_op && dc_dup > 0) {
			int index = 0;
			while (dc_len > 0) {
				dc_bit_buff = dc_bit_buff.shiftLeft(8);
				if (index < dcc_text.length()) {
					if (dcc_ascii_req) {
						dc_bit_buff = dc_bit_buff.add(BigInteger.valueOf((int)dcc_text.charAt(index) & 0xff));
					} else {
						dc_bit_buff = dc_bit_buff.add(BigInteger.valueOf((int)tz390.ascii_to_ebcdic[dcc_text.charAt(index) & 0xff] & 0xff));
					}
				} else {
					if (dcc_ascii_req) {
						dc_bit_buff = dc_bit_buff.add(BigInteger.valueOf((int)(Constants.ascii_space)  & 0xff));
					} else {
						dc_bit_buff = dc_bit_buff.add(BigInteger.valueOf((int)(Constants.ebcdic_space) & 0xff));
					}
				}
				dc_len = dc_len -8;
				index++;
			}
			if (dc_len < 0) {
				dc_bit_buff = dc_bit_buff.shiftRight(-dc_len);
			}
		}
	}

	/**
	 * Generate DCC bytes
	 */
	private void gen_dcc_bytes()
	{
		if (dc_len_explicit) {
			if (dc_len > dcc_len) {
				dcc_text = tz390.left_justify(dcc_text,dc_len); // RPI-411
			} else {
				dcc_text = dcc_text.substring(0,dc_len);
			}
		} else {
			dc_len = dcc_len;
		}
		if (dc_first_field && !dc_len_explicit) {
			dc_first_len = dc_len;
			dc_first_field = false;
		}
		while (!bal_abort && dc_dup > 0) {
			if (dc_op) {
				obj_code = obj_code + string_to_hex(dcc_text,dcc_ascii_req);
				put_obj_text();
			}
			if (!dc_lit_ref) {
				loc_ctr = loc_ctr + dc_len;
			}
			dc_dup--;
		}
	}

	/**
	 * Allocate or generate DS/DC D, E, or F type data using previous settings for dc_type, dc_type_sfx, dc_dup and dc_len.<br>
	 * Also save first field dc_type, dc_len.
	 */
	private void process_dc_fp_data()
	{
		exp_text = dc_field;
		dc_index++;   // start inside (,,,)
		exp_index = dc_index;
		dc_data_start = dc_index;
		exp_rld_len = 0;
		while (!dc_eod && !bal_abort) {
			while (!dc_eod && !bal_abort && dc_field.charAt(dc_index) != '\'') {
				get_dc_fp_hex(dc_field,dc_index);
				if (dc_bit_len) {
					gen_dc_fp_bits();
				} else {
					gen_dc_fp_bytes();
				}
				if (dc_field.charAt(dc_index) == ',') {
					exp_index++;
				} else if (dc_field.charAt(dc_index) == '\'') {
					if (dc_dup > 1) { // RPI-388 start
						dc_index = dc_data_start;
						dc_dup--;
					} else {
						dc_eod = true;
					}
				} else {
					log_error(150, "Invalid data field terminator - " + dc_field);
				}
				dc_first_field = false; // RPI-790
			}
			dc_index++; // skip dca ) terminator
			dc_len = 0; // don't double count
		}
		exp_rld_len = 0;
	}

	/**
	 * Generate del bit length field.
	 */
	private void gen_dc_fp_bits()
	{
		dc_bit_tot = dc_bit_tot + dc_len;
		if (dc_op && dc_dup > 0) {
			int index = 0;
			while (dc_len > 0) {
				dc_bit_buff = dc_bit_buff.shiftLeft(8);
				dc_bit_buff = dc_bit_buff.add(BigInteger.valueOf(Integer.valueOf(dc_hex.substring(index,index+2),16) & 0xff));
				dc_len = dc_len -8;
				index = index + 2;
			}
			if (dc_len < 0) {
				dc_bit_buff = dc_bit_buff.shiftRight(-dc_len);
			}
		}
	}

	/**
	 * Generate del byte length field.
	 */
	private void gen_dc_fp_bytes()
	{
		if (dc_len_explicit) {
			if (dc_len * 2 <= dc_hex.length()) {
				dc_hex = dc_hex.substring(0,dc_len*2);
			} else {
				while (dc_hex.length() < dc_len *2) {
					dc_hex = dc_hex + "00";
				}
			}
		}
		if (dc_op && dc_dup > 0) {
			obj_code = obj_code + dc_hex;
			put_obj_text();
		}
		if (!dc_lit_ref && dc_dup > 0) {
			loc_ctr = loc_ctr + dc_len;
		}
	}

	/**
	 * Set dc_bd_val from next floating point sdt in dc_field at dc_index.<br>
	 * Note:
	 * <ol><li>Apply any scale factor or exponent to dc_bd_value.
	 *     <li>Set dc_unsigned true/false.</ol>
	 *
	 * @return
	 */
	private boolean get_dc_bd_val()
	{
		// dc_unsigned = false;
		if (dc_field.charAt(dc_index) == '\'') {
			dc_eod = true;
			return false;
		}
		if (dc_field.charAt(dc_index) == 'U' || dc_field.charAt(dc_index) == 'u') {
			// dc_unsigned = true;
			dc_index++;
		}
		int fp_bd_start = dc_index;
		while (dc_index < dc_field.length()) {
			if (dc_field.charAt(dc_index) == '\''
			 || dc_field.charAt(dc_index) == ',') {
				try {
					dc_bd_val = new BigDecimal(dc_field.substring(fp_bd_start,dc_index));
				} catch (final Exception e) {
					log_error(161, "Invalid decimal constant - " + dc_field.substring(fp_bd_start,dc_index));
					dc_bd_val = BigDecimal.ZERO;
				}
				if (dc_scale != 0) { // RPI-368
					dc_bd_val = dc_bd_val
							.multiply(fp_bd_two.pow(dc_scale))
							.divideToIntegralValue(BigDecimal.ONE);
				}
				if (dc_exp > 0) { // RPI-737
					dc_bd_val = dc_bd_val.movePointRight(dc_exp);
				} else if (dc_exp < 0) {
					dc_bd_val = dc_bd_val.movePointLeft(-dc_exp);
				}
				return true;
			} else {
				dc_index++;
			}
		}
		return false;
	}

	/**
	 * Get 1-16 byte hex value for F or H constant from dc_bd_val.
	 *
	 * @return
	 */
	private String get_dc_fh_hex_val()
	{
		try {
			if (dc_len <= 8) {  // RPI-893
				return tz390.get_long_hex(dc_bd_val.longValueExact(),2*dc_len);
			} else if (dc_len <= 16
					&& dc_bd_val.scale() <= 0
					&& dc_bd_val.scale() > -40) {
				dc_bi_val = dc_bd_val.toBigIntegerExact();
				dc_byte_val = dc_bi_val.toByteArray();
				if (dc_byte_val.length > dc_len) {
					log_error(129, "DC value out of range " + dc_len);
					dc_len = 0;
					return "";
				}
				byte pad = 0;
				if (dc_bi_val.signum() < 0) {
					pad = -1;
				}
				int index = 0;
				if (index < 16-dc_byte_val.length) {
					Arrays.fill(fp_data_byte,index,16-dc_byte_val.length,pad); // RPI-411
					index = 16-dc_byte_val.length;
				}
				if (index < 16) {
					System.arraycopy(dc_byte_val,0,fp_data_byte,index,16-index);
				}
				return tz390.get_long_hex(fp_data_buff.getLong(0),2*dc_len-16)
					 + tz390.get_long_hex(fp_data_buff.getLong(8),16);
			} else {
				log_error(122, "DC field length out of range " + dc_len);
				dc_len = 0;
				return "";
			}
		} catch (final Exception e) {
			log_error(128, "DC value out of range " + dc_len);
			dc_len = 0;
			return "";
		}
	}

	/**
	 * Set dc_hex for D, E, or F floating point sdt starting at text index.
	 * @param text
	 * @param index
	 */
	private void get_dc_fp_hex(final String text, int index) {
		if (text.charAt(index) == ',') {
			index++;
		}
		int text_end   = text.substring(index).indexOf('\''); // RPI-411
		final int text_comma = text.substring(index).indexOf(','); // RPI-463
		if (text_comma == -1 || text_comma > text_end) {
			if (text_end == -1) {
				log_error(66, "Invalid floating point data field.");
				dc_hex = "00";
			}
		} else {
			text_end = text_comma; // RPI-463
		}
		dc_index = index + text_end;
		fp_text = text.substring(index,index+text_end); // RPI-790
		fp_get_hex();
	}

	/**
	 * Allocate or generate DS/DC F type parameters using previous settings for dc_dup and dc_len.<br>
	 * Also save first field dc_type, dc_len.
	 */
	private void process_dcf_data()
	{
		dc_index++; // start inside ',,,'
		dc_data_start = dc_index;
		while (!dc_eod && !bal_abort) {
			while (!dc_eod && !bal_abort) {
				if  (get_dc_bd_val()) {
					if (dc_bit_len) {
						gen_dc_fh_bits();
					} else {
						gen_dc_fh_bytes();
					}
					if (dc_field.charAt(dc_index) == ',') {
						dc_index++;
					} else if (dc_field.charAt(dc_index) == '\'') {
						if (dc_dup > 1) { // RPI-2 start
							dc_index = dc_data_start;
							dc_dup--;
						} else {
							dc_eod = true;
						} // RPI-2 end
					} else {
						log_error(107, "Invalid data field terminator - " + dc_field);
					}
				} else {
					log_error(88, "Invalid data field expression - " + dc_field);
				}
			}
			dc_index++; // skip dcf terminator
			dc_len = 0; // don't double count
		}
		exp_rld_len = 0;
	}

	/**
	 * Generate F or H bit field.
	 */
	private void gen_dc_fh_bits()
	{
		dc_bit_tot = dc_bit_tot + dc_len;
		if (dc_op && dc_dup > 0) {
			dc_bit_buff = dc_bit_buff.shiftLeft(dc_len);
			dc_bi_val = dc_bd_val.toBigIntegerExact();
			if (dc_bi_val.signum() >= 0) {
				dc_bit_buff = dc_bit_buff.add(dc_bi_val);
			} else {
				dc_bi_val = BigInteger.ONE.shiftLeft(dc_len).subtract(BigInteger.ONE).and(dc_bi_val);
				dc_bit_buff = dc_bit_buff.add(dc_bi_val);
			}
		}
	}

	/**
	 * Generate F or H byte field.
	 */
	private void gen_dc_fh_bytes()
	{
		if (dc_op && dc_dup > 0) {
			obj_code = obj_code + get_dc_fh_hex_val();
			put_obj_text();
		}
		if (!dc_lit_ref && dc_dup > 0) {
			loc_ctr = loc_ctr + dc_len;
		}
	}

	/**
	 * Allocate or generate DS/DC H type parameters using previous settings for dc_dup and dc_len.
	 * Also save first field dc_type, dc_len
	 */
	private void process_dch_data()
	{
		dc_index++; // start inside (,,,)
		dc_data_start = dc_index;
		while (!dc_eod && !bal_abort) {
			while (!dc_eod && !bal_abort) {
				if  (get_dc_bd_val()) {
					if (dc_bit_len) {
						gen_dc_fh_bits();
					} else {
						gen_dc_fh_bytes();
					}
					if (dc_field.charAt(dc_index) == ',') {
						dc_index++;
					} else if (dc_field.charAt(dc_index) == '\'') {
						if (dc_dup > 1) { // RPI-2 start
							dc_index = dc_data_start;
							dc_dup--;
						} else {
							dc_eod = true;
						} // RPI-2 end
					} else {
						log_error(108, "Invalid data field terminator - " + dc_field);
					}
				} else {
					log_error(88, "Invalid data field expression - " + dc_field);
				}
			}
			dc_index++; // skip dch terminator
			dc_len = 0; // don't double count
		}
		exp_rld_len = 0;
	}

	/**
	 * Allocate or generate DS/DC P type parameters using previous settings for dc_dup and dc_len.<br>
	 * Also save first field dc_type, dc_len.
	 */
	private void process_dcp_data()
	{
		dc_index++; // start inside delimiter 'n,n'
		dc_data_start = dc_index;
		while (!dc_eod && !bal_abort) {
			while (!dc_eod && !bal_abort
				&& dc_index < dc_field.length()
				&& dc_field.charAt(dc_index) != '\'') {
				dcp_sign = 'C';
				dc_dec_point = false; // RPI-777
				dc_dec_scale = 0;     // RPI-777
				dc_digits = "";
				while (!bal_abort  // RPI-617
					&& dc_index < dc_field.length()
					&& dc_field.charAt(dc_index) != ','
					&& dc_field.charAt(dc_index) != '\'') {
						if (dc_field.charAt(dc_index) >= '0'
						 && dc_field.charAt(dc_index) <= '9') {
							dc_digits = dc_digits + dc_field.charAt(dc_index); // RPI-777
							if (dc_dec_point) {
								dc_dec_scale++; // RPI-777
							}
							dc_index++;
						} else if (dc_field.charAt(dc_index) == '.') {
							dc_dec_point = true;
							dc_index++;
						} else if (dc_field.charAt(dc_index) == '+') {
							dc_index++;
						} else if (dc_field.charAt(dc_index) == '-') {
							dcp_sign = 'D';
							dc_index++;
						} else if (dc_field.charAt(dc_index) == ' ') {
							dc_index++; // RPI-840
						} else {
							log_error(67, "Invalid character in P type data field - " + dc_field);
						}
				}
				if (!dc_scale_explicit && dc_first_field) {
					dc_first_scale = dc_dec_scale;
				}
				if (dc_digits.length() - dc_digits.length()/2*2 == 0) {
					dc_hex = '0' + dc_digits + dcp_sign;
				} else {
					dc_hex = dc_digits + dcp_sign;
				}
				dcp_len = dc_hex.length()/2;
				if (dc_bit_len) {
					gen_dcp_bits();
				} else {
					gen_dcp_bytes();
				}
				if (dc_field.charAt(dc_index) == ',') {
					dc_index++;
				}
				dc_first_field = false; // RPI-790
			}
			dc_index++; // skip dcp terminator
			if (!bal_abort) {
				if  (dc_dup > 1) {
					dc_index = dc_data_start;
					dc_dup--;
				} else {
					dc_eod = true;
				}
			}
		}
		dc_len = 0; // don't double count RPI-538
	}

	/**
	 * Generate P bit field.
	 */
	private void gen_dcp_bits() {
		dc_bit_tot = dc_bit_tot + dc_len;
		if (dc_op && dc_dup > 0) {
			dc_bit_buff = dc_bit_buff.shiftLeft(dc_len);
			dc_bi_val = BigInteger.ZERO;
			int index = 0;
			while (index < dc_hex.length()) {
				dc_bi_val = dc_bi_val.shiftLeft(8).add(BigInteger.valueOf(Integer.valueOf(dc_hex.substring(index,index+2),16)));
				index = index + 2;
			}
			dc_bit_buff = dc_bit_buff.add(dc_bi_val);
		}
	}

	/**
	 * Generate P byte field.
	 */
	private void gen_dcp_bytes()
	{
		if (dc_len_explicit) {
			if (dcp_len < dc_len) {
				dc_hex = tz390.get_dup_string("0",2*(dc_len-dcp_len)) + dc_hex;
				dcp_len = dc_len;
			}
			if (dcp_len > dc_len) {
				dc_hex = dc_hex.substring(2*(dcp_len - dc_len));
			}
		} else {
			dc_len = dcp_len;
		}
		if (!dc_len_explicit && dc_first_field) {
			dc_first_len = dcp_len;
			dc_first_field = false;
		}
		if (dc_len > 16 && dc_type == 'P') { // allow Z > 16
			log_error(68, "P type field too long - " + dc_field);
		} else if (dc_op && dc_dup > 0) {
			obj_code = dc_hex;
			put_obj_text();
		}
		if (!dc_lit_ref && dc_dup > 0) {
			loc_ctr = loc_ctr + dc_len;
		}
	}

	/**
	 * Allocate or generate DS/DC Z type parameters using previous settings for dc_dup and dc_len.<br>
	 * Also save first field dc_type, dc_len.
	 */
	private void process_dcz_data()
	{
		dc_index++;   // start inside delimiter 'n,n'
		dc_data_start = dc_index;
		while (!dc_eod && !bal_abort) {
			while (!dc_eod && !bal_abort
				&& dc_index < dc_field.length()
				&& dc_field.charAt(dc_index) != '\'') {
				dcp_sign = 'C';
				dc_dec_point = false; // RPI-777
				dc_dec_scale = 0;     // RPI-777
				dc_digits = "";
				while (!bal_abort  // RPI-617
					&& dc_index < dc_field.length()
					&& dc_field.charAt(dc_index) != ','
					&& dc_field.charAt(dc_index) != '\'') {
						if (dc_field.charAt(dc_index) >= '0'
						 && dc_field.charAt(dc_index) <= '9') {
							if (tz390.opt_ascii) { // RPI-777
								dc_digits = dc_digits + "3" + dc_field.charAt(dc_index); // RPI-777
							} else {
								dc_digits = dc_digits + "F" + dc_field.charAt(dc_index);
							}
							if (dc_dec_point) {
								dc_dec_scale++; // RPI-777
							}
							dc_index++;
						} else if (dc_field.charAt(dc_index) == '.') {
							dc_dec_point = true;
							dc_index++;
						} else if (dc_field.charAt(dc_index) == '+') {
							dc_index++;
						} else if (dc_field.charAt(dc_index) == '-') {
							dcp_sign = 'D';
							dc_index++;
						} else if (dc_field.charAt(dc_index) == ' ') {
							dc_index++; // RPI-840
						} else {
							log_error(67,"invalid character in Z type data field - " + dc_field); // RPI-930
						}
				}
				if (!dc_scale_explicit && dc_first_field) {
					dc_first_scale = dc_dec_scale;
				}
				if (dc_digits.length() > 2) {
					dc_hex = dc_digits.substring(0,dc_digits.length()-2) + dcp_sign + dc_digits.charAt(dc_digits.length()-1);
				} else if (dc_digits.length() == 2) {  // RPI-930
					dc_hex = "" + dcp_sign + dc_digits.charAt(dc_digits.length()-1);
				} else { // RPI-930
					dc_hex = "0";
				}
				dcp_len = dc_hex.length()/2;
				while (dcp_len < dc_len) {
					dc_hex = "F0" + dc_hex; // RPI-939
					dcp_len++;  // RPI-930
				}
				if (dc_bit_len) {
					gen_dcp_bits();
				} else {
					gen_dcp_bytes();
				}
				if (dc_field.charAt(dc_index) == ',') {
					dc_index++;
				}
				dc_first_field = false; // RPI-790
			}
			dc_index++; // skip dcp terminator
			if (!bal_abort) {
				if (dc_dup > 1) {
					dc_index = dc_data_start;
					dc_dup--;
				} else {
					dc_eod = true;
				}
			}
		}
		dc_len = 0; // don't double count RPI-538
	}

	/**
	 * Allocate or generate DS/DC S type parameters using previous settings for dc_dup and dc_len.<br>
	 * Also save first field dc_type, dc_len.
	 */
	private void process_dcs_data()
	{
		exp_text = dc_field;
		dc_index++;   // start inside (,,,)
		exp_index = dc_index;
		dc_data_start = dc_index;
		exp_rld_len = 0;
		while (!dc_eod && !bal_abort) {
			while (!dc_eod && !bal_abort) {
				if  (calc_exp()) {
					dc_index = exp_index;
					if  (dc_len == 2) {
						if  (exp_type == sym_rel) { // RPI-458
							if (dc_op && dc_dup > 0) { //RPI-578
								obj_code = obj_code + get_exp_bddd();
							}
						} else {
							dc_hex = get_exp_abs_bddd();
							if (dc_op && dc_dup > 0) { // RPI-578
								obj_code = obj_code + dc_hex;
							}
						}
						dc_index = exp_index;
					} else if (dc_len == 3) {
						// RPI-893 SY long displacement
						get_bdddhh = true;
						if  (exp_type == sym_rel) { // RPI-458
							if (dc_op && dc_dup > 0) { //RPI-578
								obj_code = obj_code + get_exp_bddd();
							}
						} else {
							dc_hex = get_exp_abs_bddd();
							if (dc_op && dc_dup > 0) { // RPI-578
								obj_code = obj_code + dc_hex;
							}
						}
						get_bdddhh = false;
						dc_index = exp_index;
					} else {
						log_error(99, "Invalid length for S type.");
					}
					if (dc_op && dc_dup > 0) { //RPI-578
						put_obj_text();
					}
					if (!dc_lit_ref && dc_dup > 0) {
						loc_ctr = loc_ctr + dc_len;
						dc_dup_loc = dc_dup_loc + dc_len;
					}
					if (dc_field.charAt(dc_index) == ',') {
						exp_index++;
					} else if (dc_field.charAt(dc_index) == ')') {
						if (dc_dup > 1) {         //RPI2 start
							dc_index = dc_data_start;
							exp_index = dc_index;
							dc_dup--;
						} else {
							dc_eod = true;
						} // RPI-2 end
					} else {
						log_error(109, "Invalid data field terminator - " + dc_field);
					}
				} else {
					dc_index = exp_index;
					log_error(88, "Invalid data field expression - " + dc_field);
				}
			}
			dc_index++; // skip dca terminator
			dc_len = 0; // don't double count
		}
		exp_rld_len = 0;
	}

	/**
	 * Allocate or generate DS/DC X type parameters using previous settings for dc_dup and dc_len.<br>
	 * Also save first field dc_len.<br><br>
	 * Notes:
	 * <ol><li>Hex values are right aligned in explicit length fields.
	 *     <li>Spaces are ignored in data RPI-371</ol>
	 */
	private void process_dcx_data()
	{
		dc_index++; // start inside 'hex1,hex2,,'
		dc_data_start = dc_index;
		while (!dc_eod && !bal_abort) {
			dcx_len = 0;
			dc_hex = "";
			while (!dc_eod && !bal_abort
				&& dc_index < dc_field.length()
				&& dc_field.charAt(dc_index) != '\''
				&& dc_field.charAt(dc_index) != ',') {
				final char hex_code = dc_field.substring(dc_index,dc_index + 1).toUpperCase().charAt(0);
				if ((hex_code >= '0' && hex_code <= '9')
					||
					(hex_code >= 'A' && hex_code <= 'F')) {
					dcx_len++;
					dc_hex = dc_hex + hex_code;
				} else if (hex_code != ' ') {
					log_error(77, "Invalid hex code " + hex_code);
				}
				dc_index++;
			}
			if (dc_index >= dc_field.length()) {
				log_error(78, "Invalid hex dc data " + dc_field.substring(dc_data_start));
				return;
			}
			if (dcx_len != dcx_len/2*2) {
				dc_hex = "0" + dc_hex;
			}
			dcx_len = dc_hex.length()/2;
			if (dc_bit_len) {
				gen_dcx_bits();
			} else {
				gen_dcx_bytes();
			}
			if (dc_field.charAt(dc_index) == ',') {
				dc_index++;
			} else if (dc_field.charAt(dc_index) == '\'') {
				if  (dc_dup > 1) {    //rpi2
					dc_index = dc_data_start;
					exp_index = dc_index;
					dc_dup--;
				} else {
					dc_eod = true;
				} // RPI-2
			} else {
				log_error(109, "Invalid dc data terminator - " + dc_field.substring(dc_index));
			}
		}
		dc_index++; // skip terminator
		dc_len = 0; // don't double count
	}

	/**
	 * Generate X bit field.
	 */
	private void gen_dcx_bits()
	{
		dc_bit_tot = dc_bit_tot + dc_len;
		if (dc_op && dc_dup > 0) {
			dc_bit_buff = dc_bit_buff.shiftLeft(dc_len);
			dc_bi_val = BigInteger.ZERO;
			int index = 0;
			while (index < dc_hex.length()) {
				dc_bi_val = dc_bi_val.shiftLeft(8).add(BigInteger.valueOf(Integer.valueOf(dc_hex.substring(index,index+2),16)));
				index = index + 2;
			}
			dc_bit_buff = dc_bit_buff.add(dc_bi_val);
		}
	}

	/**
	 * Generate X byte field.
	 */
	private void gen_dcx_bytes()
	{
		if (dc_len_explicit) {
			if (dcx_len < dc_len) { // RPI-411
				dc_hex = tz390.get_dup_string("0",2*(dc_len-dcx_len)) + dc_hex;
				dcx_len = dc_len;
			}
			if (dcx_len > dc_len) {
				dc_hex = dc_hex.substring(2*(dcx_len-dc_len));
				dcx_len = dc_len;
			}
		} else {
			dc_len = dcx_len;
		}
		if (!dc_len_explicit && dc_first_field) {
			dc_first_len = dc_len;
			dc_first_field = false;
		}
		if (dc_op && dc_dup > 0) {
			obj_code = obj_code + dc_hex;
			put_obj_text();
		}
		if (!dc_lit_ref && dc_dup > 0) {
			loc_ctr = loc_ctr + dc_len;
		}
	}

	/**
	 * Return integer expression in (...) or decimal number for modifier.
	 *
	 * @return
	 */
	private int get_dc_mod_int()
	{
		if (dc_field.length() <= dc_index+1) { // RPI-1077
			log_error(208, "DS/DC missing modifier - " + dc_field);
			return 1;
		} else if (dc_field.charAt(dc_index+1) == '(') {
			exp_text = dc_field;
			exp_index = dc_index+2;
			if (!bal_abort && calc_abs_exp() // RPI-416
				&& dc_field.charAt(exp_index) == ')') {
				dc_index = exp_index+1;
				return exp_val;
			} else {
				log_error(43, "Invalid dc duplication factor.");
				return -1;
			}
		} else {
			return get_dc_int(dc_index+1);
		}
	}

	/**
	 * Return next number from dc_field at index else return 1 and update dc_index.
	 *
	 * @param index
	 * @return
	 */
	private int get_dc_int(final int index)
	{
		dc_index = index;
		while (dc_index < dc_field.length()
 			&& dc_field.charAt(dc_index) <= '9'
 			&& dc_field.charAt(dc_index) >= '0') {
			dc_index++;
		}
		if (dc_index > index) {
			return Integer.valueOf(dc_field.substring(index,dc_index)).intValue();
		} else {
			return 1;
		}
	}

	/**
	 * Generate one or more 0700 instructions to align to specified boundary.
	 */
	private void process_cnop()
	{
		loc_ctr = (loc_ctr+1)/2*2; // Skip odd byte preceding CNOP. RPI-941
		loc_start = loc_ctr;
		exp_text = bal_parms;
		exp_index = 0;
		int req_off = 0;
		int cur_off = 0;
		if (calc_abs_exp() && exp_val >= 0 && exp_val < 8) {
			req_off = exp_val;
			if (exp_text.charAt(exp_index) == ',') {
				exp_index++;
				if (calc_abs_exp()  // RPI-620
						&& (exp_val == 4 || exp_val == 8)) {
					cur_off = loc_ctr - loc_ctr/exp_val*exp_val;
					int gap_bytes = req_off - cur_off;
					if (gap_bytes < 0) {
						gap_bytes = exp_val - cur_off + req_off;
					}
					if ((gap_bytes & 0x1) > 0) {
						loc_len = 1;
						gap_bytes--;
						cur_off++;
						obj_code = "00";
					}
					if ((gap_bytes & (4-1)) > 0) { // 2 byte alignment
						obj_code = obj_code + "0700";
						cur_off += 2;
						gap_bytes -= 2;
						loc_len += 2;
					}
					while (gap_bytes > 0) {
						obj_code = obj_code + "47000700";
						cur_off += 4;
						gap_bytes -= 4;
						loc_len += 4;
					}
					put_obj_text();
				}
			}
		}
	}

	/**
	 * Perform END processing at END statement or end of MLC source at end of each pass.
	 */
	private void process_end()
	{
		if (cur_esd > 0) {
			update_sect();
		}
		list_bal_line();
		if (tot_lit > 0) {
			cur_esd = 1;
			while (cur_esd <= tot_esd
				&& sym_type[esd_sid[esd_base[cur_esd]]] != sym_cst) { // RPI-564
				cur_esd++;
			}
			if (cur_esd <= tot_esd) {
				cur_esd_sid = esd_sid[cur_esd];
				while (sym_sect_next[cur_esd_sid] > 0) {
					cur_esd_sid = sym_sect_next[cur_esd_sid];
				}
				loc_ctr = (sym_loc[cur_esd_sid] + sym_len[cur_esd_sid] + 7)/8*8;
				gen_ltorg();
				update_sect();
			} else {
				cur_esd = 0;
			}
		}
		bal_eof = true;
		loc_ctr = 0;
		cur_esd = 0;
		put_obj_text(); // flush buffer
		if (end_loc != loc_ctr) { // RPI-605
			sect_change_error();
			log_error(186, "End location changed from "
				+ tz390.get_hex(end_loc,6)
				+ " to " + tz390.get_hex(loc_ctr,6));
		}
		end_loc = loc_ctr;
		update_sects();
		list_bal_line = false; // RPI-891 suppress END after auto LTORG
	}

	/**
	 * Define or update symbol definition.
	 */
	public void process_equ() // RPI-415
	{
		/*
		 *   1. Set sym_loc to first pos value
		 *   2. Set sym_len to optional 2nd pos value else
		 *      set sym_len to 1.
		 *   3. Set sym_attr to optional 3rd pos value.
		 *   4. Set sym_attrp 4th program type
		 *   5. Set sym_attra 5th assembler type
		 */
		int index = 0;
		check_private_csect();
		loc_start = loc_ctr;
		if (bal_label != null) {
			cur_sid = find_sym(bal_label);
			if (cur_sid < 1) {
				cur_sid = add_sym(bal_label);
			}
			int store_sid = cur_sid;
			sym_name[store_sid] = bal_label;
			if (!lookahead_mode && sym_def[store_sid] <= sym_def_ref) {
				sym_def[store_sid] = bal_line_index;
			} else if (!lookahead_mode && sym_def[store_sid] != bal_line_index) {
				duplicate_symbol_error();
			}
			exp_text = bal_parms;
			exp_index = 0;
			exp_equ = true; // RPI-749
			if (calc_exp()) {
				// equ value and defaults
				sym_type[store_sid] = exp_type;
				sym_attr[store_sid] = exp_attr;
				sym_esd[store_sid] = exp_esd;
				if (sym_loc[store_sid] != exp_val) { // RPI-605
					sect_change_error();
					if (gen_obj_code && report_equ_changes) {
						report_equ_changes = false;
						log_error(188, "First equ change for " + sym_name[store_sid] + " from " + tz390.get_hex(sym_loc[store_sid],8) + " to " + tz390.get_hex(exp_val,8));
					}
				}
				sym_loc[store_sid] = exp_val;
				sym_len[store_sid] = 1;
				hex_bddd1_loc = tz390.get_hex(exp_val,8);	// RPI-1099 was 6 vs 8
				hex_bddd2_loc = "    ";						// RPI-1099
				if (exp_next_char(',')) {
					// equ explicit length
					exp_text = exp_text.substring(exp_index+1);
					exp_index = 0;
					if (exp_index < exp_text.length()) {
						if (exp_text.charAt(exp_index) != ',') {
							if (calc_abs_exp()) { // RPI-340
								sym_len[store_sid] = exp_val;
							}
						}
					}
					if (exp_next_char(',')) {
						// equ explicit attr
						exp_text = exp_text.substring(exp_index+1);
						exp_index = 0;
						if (exp_text.charAt(exp_index) != ',') {
							if (exp_text.length() > 2
							 && exp_text.substring(exp_index,exp_index+2).equals("T'")) {
								index = find_sym(exp_text.substring(exp_index+2));
								if (index > 0) {
									sym_attr[store_sid] = sym_attr[index];
								} else {
									sym_attr[store_sid] = tz390.ascii_to_ebcdic['U'];
								}
							} else if (calc_abs_exp()) { // RPI-340
								sym_attr[store_sid] = (byte) exp_val;
							}
						}
					}
					if (exp_next_char(',')) {
						// equ 4th explicit attrp pgm attr
						exp_text = exp_text.substring(exp_index+1);
						exp_index = 0;
						if (exp_text.charAt(exp_index) != ',') {
							if (calc_abs_exp()) { // RPI-340
								sym_attrp[store_sid] = exp_val;
							}
						}
					}
					if (exp_next_char(',')) {
						// equ 5th explicit attra asm attr
						String setc_value = exp_text.substring(exp_index+1).toUpperCase();
						index = 0;  // RPI-624
						while (index < setc_value.length()
							&& setc_value.charAt(index) > ' ') {
							index++;
						}
						if (index > 0) {
							setc_value = setc_value.substring(0,index);
						}
						sym_attra[store_sid] = setc_value; // RPI-615 remove bad code setting string length
						index = 0;
						boolean attra_found = false;
						while (!attra_found && index < sym_attra_type.length) {
							if (sym_attra[store_sid].equals(sym_attra_type[index])) {
								attra_found = true;
							}
							index++;
						}
						if (!attra_found) {
							log_error(155, "Invalid symbol assembler attribute " + sym_attra[store_sid]);
						}
					}
				}
			} else {
				log_error(53, "Invalid EQU expression.");
			}
		} else {
			log_error(184," Missing EQU label.");  // RPI-597
		}
		exp_equ = false; // RPI-749
	}

	/**
	 * Reset current location in same CSECT.
	 */
	private void process_org()
	{
		update_sect(); // RPI-340
		loc_start = loc_ctr;
		if (bal_parms == null
		 || bal_parms.length() == 0
		 || bal_parms.charAt(0) == ',') { // RPI-258
			if (cur_esd > 0) {  //RPI-10, RPI-87
				// org to end of current CSECT
				loc_ctr = sym_loc[esd_sid[cur_esd]] + sym_len[esd_sid[cur_esd]];
				hex_bddd1_loc = tz390.get_hex(loc_ctr,6); // RPI-632
			} else {
				log_error(102, "Org expression must be in same section.");
			}
			return;
		}
		exp_text = bal_parms;
		exp_index = 0;
		if (cur_esd > 0
		 && calc_rel_exp()
		 && exp_esd == esd_base[cur_esd]) { // RPI-301
			loc_ctr = exp_val;
			hex_bddd1_loc = tz390.get_hex(loc_ctr,6); // RPI-632
			update_sect();  // RPI-10, RPI-778
		} else {
			loc_ctr = loc_start; // RPI-851
			log_error(102, "Org expression must be in same section.");
		}
	}

	/**
	 * Push print or using level if any.
	 */
	private void process_push()
	{
		init_get_next_parm(bal_parms);
		String parm = get_next_parm();
		while (parm != null) {
			if (parm.equals("NOPRINT")) {
				list_bal_line = false;
			} else if (parm.equals("PRINT")) {
				if (print_level < tz390.opt_maxcall-1) {
					print_on[  print_level+1] = print_on[  print_level];
					print_gen[ print_level+1] = print_gen[ print_level];
					print_data[print_level+1] = print_data[print_level];
					print_level++;
				} else {
					log_error(126, "Maximum push print exceeded. Maximum is " + tz390.opt_maxcall + " items.");
				}
			} else if (parm.equals("USING")) {
				final int cur_entries = cur_use_end - cur_use_start;
				if (using_level < tz390.opt_maxcall-1
					&& cur_use_end + cur_entries <= tz390.opt_maxcall) {
					push_cur_use_start[using_level] = cur_use_start;
					push_cur_use_end[  using_level] = cur_use_end;
					int index = cur_use_start;
					while (index < cur_use_end) {
						move_use_entry(index,index+cur_entries);
						index++;
					}
					using_level++;
					cur_use_start = cur_use_start + cur_entries;
					cur_use_end   = cur_use_end   + cur_entries;
				} else {
					log_error(127, "Maximum push using exceeded. Maximum is " + tz390.opt_maxcall + " items.");
				}
			} else {
				log_error(129, "Invalid push parm - " + parm);
			}
			parm = get_next_parm();
		}
	}

	/**
	 * Pop print or using level if any.
	 */
	private void process_pop()
	{
		init_get_next_parm(bal_parms);
		String parm = get_next_parm();
		while (parm != null) {
			if (parm.equals("NOPRINT")) {
				list_bal_line = false;
			} else if (parm.equals("PRINT")) {
				if (print_level > 0) {
					print_level--;
				}
			} else if (parm.equals("USING")) {
				if (using_level > 0) {
					using_level--;
					cur_use_start = push_cur_use_start[using_level];
					cur_use_end   = push_cur_use_end[  using_level];
				}
			} else {
				log_error(125, "Invalid pop parm - " + parm);
			}
			parm = get_next_parm();
		}
	}

	/**
	 * Process print options (unsupported options ignored).
	 */
	private void process_print()
	{
		init_get_next_parm(bal_parms);
		String parm = get_next_parm();
		while (parm != null) {
			if (parm.equals("NOPRINT")) { // RPI-304
				list_bal_line = false;
			} else if (parm.equals("ON")) {
				print_on[print_level] = true;
			} else if (parm.equals("OFF") && !tz390.opt_printall) { // RPI-1127
				print_on[print_level] = false;
			} else if (parm.equals("GEN")) {
				print_gen[print_level] = true;
			} else if (parm.equals("NOGEN") && !tz390.opt_printall) { // RPI-1127
				print_gen[print_level] = false;
			} else if (parm.equals("DATA")) { // RPI-588
				print_data[print_level] = true;
			} else if (parm.equals("NODATA")) {
				print_data[print_level] = false;
			}
			parm = get_next_parm();
		}
	}

	/**
	 * Use tz390.parm_match to find and return next parameter separated by commas else return null.
	 *
	 * @param parms
	 */
	private void init_get_next_parm(final String parms)
	{
		if (parms != null && parms.length() > 0) {
			tz390.parm_match = tz390.parm_pattern.matcher(parms);
		} else {
			tz390.parm_match = null;
		}
	}

	/**
	 * Use tz390.parm_match to find and return next parameter in upper case else return null.
	 *
	 * @return
	 */
	private String get_next_parm()
	{
		if (tz390.parm_match != null) {
			while (tz390.parm_match.find()) {
				final String parm = tz390.parm_match.group().toUpperCase();
				if (parm.charAt(0) <= ' ') {
					return null;
				}
				if (parm.charAt(0) != ',') {
					return parm;
				}
			}
		}
		return null;
	}

	/**
	 * Issue error for duplicate symbol definition.
	 */
	private void duplicate_symbol_error()
	{
		log_error(72, "Duplicate symbol " + sym_name[cur_sid] + " on line " + bal_line_num[bal_line_index] + " and " + bal_line_num[sym_def[cur_sid]]);
	}

	/**
	 * Calculate rel exp for lit or explicit offset for following offset(index,base).
	 */
	private void calc_lit_or_exp()
	{
		if (exp_next_char('=')) {
			calc_lit();
		} else
		if ( exp_text != null
		  && exp_text.substring(exp_index).length() > 8  // RPI-626 RPI-822
		  && exp_text.substring(exp_index,exp_index+8).toUpperCase().equals("DFHRESP(")) {
			final String dfhresp_type_key = exp_text.substring(exp_index + 8).toUpperCase() + "         ";
			int index = 0;
			while (index < dfhresp_type.length && !dfhresp_type_key.substring(0,dfhresp_type[index].length()).equals(dfhresp_type[index])) {
				index++;
			}
			if (index < dfhresp_type.length) {
				exp_text = exp_text.substring(0,exp_index) + dfhresp_lit[index] + exp_text.substring(exp_index + 8 + dfhresp_type[index].length()); // RPI-635
				calc_lit();
			} else {
				calc_exp();
			}
		} else
		if ( exp_text != null
		  && exp_text.substring(exp_index).length() > 9  // RPI-1057
		  && exp_text.substring(exp_index,exp_index+9).toUpperCase().equals("DFHVALUE(")) {
			final String dfhvalue_type_key = exp_text.substring(exp_index + 9).toUpperCase() + "         ";
			int index = 0;
			while (index < dfhvalue_type.length && !dfhvalue_type_key.substring(0,dfhvalue_type[index].length()).equals(dfhvalue_type[index])) {
				index++;
			}
			if (index < dfhvalue_type.length) {
				exp_text = exp_text.substring(0,exp_index) + dfhvalue_lit[index] + exp_text.substring(exp_index + 9 + dfhvalue_type[index].length()); // RPI-635
				calc_lit();
			} else {
				calc_exp();
			}
		} else {
			calc_exp();
		}
	}

	/**
	 * Find or add literal and set exp_type, exp_val, and exp_esd.<br>
	 * If literal followed by '-' or '+' calculate expression add to lit address
	 *
	 * @return return abs val else error.
	 */
	private boolean calc_lit()
	{
		get_lit_addr();
		if (cur_lit != -1) {
			if (exp_next_char('-')) {
				if (calc_exp()) {
					exp_val = exp_val + lit_loc[cur_lit];
					if (exp_esd == lit_esd[cur_lit]) {
						exp_esd = esd_sdt;
						exp_type = sym_sdt;
					} else if (exp_esd == 0) { // RPI-501
						exp_esd = lit_esd[cur_lit];
						exp_type = sym_rel;
					} else {
						log_error(175, "Invalid literal complex expression.");
					}
				} else { // RPI-457
					log_error(169, "Invalid literal expression.");
				}
			} else if (exp_next_char('+')) {
				if (calc_exp() && exp_esd == esd_sdt) { // RPI-457
					exp_val = exp_val + lit_loc[cur_lit];
					exp_esd = esd_base[lit_esd[cur_lit]];  // RPI-457
					exp_type = sym_rel;
				} else {
					log_error(170, "Invalid literal + offset expression.");
				}
			} else {
				exp_val = lit_loc[cur_lit];
				exp_esd = esd_base[lit_esd[cur_lit]];
				exp_type = sym_rel;
			}
			exp_len = lit_len[cur_lit];
			if (!bal_abort) {
				return true;
			}
		}
		return false;
	}

	/**
	 * Return bddd or bdddhh.
	 */
	private String get_default_bddd()
	{
		if (get_bdddhh) {
			return "bdddhh";
		} else {
			return "bddd";
		}
	}

	/**
	 * Find or add literal and set:<br>
	 *   1. cur_lit = lit table index<br>
	 *   2. exp_val = lit address<br>
	 *   3. exp_esd = lit esd
	 */
	private void get_lit_addr()
	{
		String lit_key = "";
		process_dc(2);
		if (!bal_abort) {
			if (lit_loc_ref) {
				lit_key = cur_lit_pool + ":" +bal_line_index + dc_field.substring(dc_lit_index_start,dc_index);
			} else {
				lit_key = cur_lit_pool + dc_field.substring(dc_lit_index_start,dc_index);
			}
			cur_lit = tz390.find_key_index('L',lit_key);
			if (cur_lit != -1) {
				add_lit_xref(cur_lit);
				if (lit_loc_ref) {
					lit_line_loc[cur_lit] = loc_ctr;
				}
				exp_esd = esd_base[lit_esd[cur_lit]]; // RPI-301
				exp_val = lit_loc[cur_lit];
				return;
			}
			if (!gen_obj_code && tot_lit < tz390.opt_maxsym) {
				cur_lit = tot_lit;
				if (!tz390.add_key_index(cur_lit)) {
					abort_error(87, "Key search table exceeded.");
				}
				add_lit_xref(cur_lit);
				tot_lit++;
				lit_name[cur_lit] = dc_field.substring(dc_lit_index_start,dc_index);
				lit_pool[cur_lit] = cur_lit_pool;
				lit_line[cur_lit] = bal_line_index;
				lit_line_loc[cur_lit] = loc_ctr;
				lit_esd[cur_lit] = cur_esd;
				lit_loc[cur_lit] = -1; // set by gen_lit
				lit_len[cur_lit] = dc_first_len;
				lit_dup[cur_lit] = dc_first_dup; // RPI-1200 save for lit pool alignment sizing
				lit_scale[cur_lit] = dc_first_scale; // RPI-790
				lit_dc_type[cur_lit]  = (byte) dc_first_type;  // RPI-790
				lit_dc_type_sfx[cur_lit] = (byte) dc_first_type_sfx; // RPI-790
				lit_gen[cur_lit] = 0;  // set by gen_lit;
				exp_val = -1;
			} else {
				log_error(57, "Literal table size exceeded.");
			}
		}
		exp_val = 0;
		exp_esd = 0;
	}

	/**
	 * Generate ltorg at current location in CSECT.
	 */
	private void gen_ltorg()
	{
		loc_ctr = (loc_ctr + 7)/8*8;
		gen_lit_size(8);
		gen_lit_size(4);
		gen_lit_size(2);
		gen_lit_size(1);
	}

	/**
	 * Generate literal dc's of specified size.
	 *
	 * @param size
	 */
	private void gen_lit_size(final int size)
	{
		cur_lit = 0;
		while (cur_lit < tot_lit) {
			if (lit_len[cur_lit]*lit_dup[cur_lit] == lit_len[cur_lit]*lit_dup[cur_lit]/size*size // RPI-1200 use dup for aligning
				&& lit_gen[cur_lit] == 0
				&& lit_pool[cur_lit] == cur_lit_pool) {
				lit_gen[cur_lit] = 1;
				lit_esd[cur_lit] = esd_base[cur_esd]; // RPI-457
				process_dc(3);
				if (gen_obj_code && tz390.opt_list) { // RPI-484
					if (list_obj_code.length() < 16) {
						list_obj_code = list_obj_code.concat("                ").substring(0,16);
					}
					list_obj_loc = lit_loc[cur_lit];
					final String lit_line = tz390.get_hex(list_obj_loc,6) + " " + list_obj_code.substring(0,16) + " =" + lit_name[cur_lit];
					if (bal_abort) {
						force_list_bal = true; // RPI-1031
						loc_ctr = loc_ctr + lit_len[cur_lit]; // RPI-1031
					}
					put_prn_line(lit_line);
					bal_abort = false; // RPI-1031
				}
			}
			cur_lit++;
		}
	}

	/**
	 * Add literal xref.
	 *
	 * @param index
	 */
	private void add_lit_xref(final int index)
	{
		if (!tz390.opt_xref || !gen_obj_code) { // RPI165
			return;
		}
		if (lit_xref[index] == null) {
			lit_xref[index] = new TreeSet<Integer>();
		}
		lit_xref[index].add(bal_line_num[bal_line_index]);
	}

	/**
	 * Add new ESD chained to SID and return index else abort.
	 *
	 * @param sid
	 * @param sect_type
	 * @return
	 */
	private int add_esd(final int sid, final byte sect_type)
	{
		if (tot_esd < tz390.opt_maxesd-1) { // RPI-284
			tot_esd++;
			esd_sid[tot_esd] = sid;
			esd_base[tot_esd] = tot_esd; // RPI-301
			if (sect_type != sym_ent) {  // May already be set to rel or cst
				sym_esd[sid] = tot_esd;
				sym_type[sid] = sect_type;
			}
		} else {
			abort_error(96, "Maximum ESDs exceeded. Maximum is " + tz390.opt_maxesd + " items");
			return -1;
		}
		return tot_esd;
	}

	/**
	 * Add symbol table entry name and return index for use in setting remaining fields.<br>
	 * Note:<br>
	 * If in lookahead mode, set sym_def = -1<br>
	 *
	 * @param name
	 * @return
	 */
	public int add_sym(final String name) // RPI-415 public
	{
		if (tot_sym < tz390.opt_maxsym - 1) {
			tot_sym++;
			sym_name[tot_sym] = name.toUpperCase(); // RPI-415
			sym_attr[tot_sym] = tz390.ascii_to_ebcdic['U'];
			if (!tz390.add_key_index(tot_sym)) {
				return -1;
			}
			if (lookahead_mode) {
				sym_def[tot_sym] = sym_def_lookahead;
			} else {
				add_sym_xref(tot_sym);
			}
			return tot_sym;
		} else {
			abort_error(10, "Maximum symbol table size exceeded. Maximum is " + tz390.opt_maxsym + " items.");
			return -1;
		}
	}

	/**
	 * Add symbol xref.
	 *
	 * @param index
	 */
	private void add_sym_xref(final int index)
	{
		if (!tz390.opt_xref
		 || !gen_obj_code  //RPI165
		 || (last_xref_index == index && last_xref_line == bal_line_index)) {
			return;
		}
		last_xref_index = index;
		last_xref_line  = bal_line_index;
		if (sym_xref[index] == null) {
			sym_xref[index] = new TreeSet<Integer>();
		}
		sym_xref[index].add(bal_line_num[bal_line_index]);
	}

	/**
	 * Generate 8 byte aligned CCW0
	 * op8,addr24,flags8,zero8,len16
	 */
	private void gen_ccw0() // RPI-567
	{
		dc_align(8);
		loc_start = loc_ctr;
		exp_text = bal_parms;
		exp_index = 0;
		if (calc_abs_exp() && exp_val >= 0 && exp_val <  256) {
			obj_code = obj_code + tz390.get_hex(exp_val,2);
			loc_len  = 1;
			put_obj_text();
			loc_ctr++;
			if (exp_text.charAt(exp_index) == ',') {
				exp_index++;
				exp_rld_len = 3;
				if (calc_exp()) {  // RPI-771
					obj_code = obj_code + tz390.get_hex(exp_val,6);
					put_obj_text();        // RPI-632
					loc_ctr = loc_ctr + 3; // RPI-632
					if (exp_text.charAt(exp_index) == ',') {
						exp_index++;
						exp_rld_len = 0;
						if (calc_abs_exp() && exp_val < 256) {
							obj_code = obj_code + tz390.get_hex(exp_val,2);
							obj_code = obj_code + tz390.get_hex(0,2);
							put_obj_text();        // RPI-632
							loc_ctr = loc_ctr + 2; // RPI-632
							if (exp_text.charAt(exp_index) == ',') {
								exp_index++;
								if (calc_abs_exp() && exp_val <= 0xffff) {
									obj_code = obj_code + tz390.get_hex(exp_val,4);
									put_obj_text();        // RPI-632
									loc_ctr = loc_ctr + 2; // RPI-632
								}
							}
						}
					}
				}
			}
		}
		loc_len = 0;
		exp_rld_len = 0;
	}

	/**
	 * Generate 8 byte aligned CCW1
	 * op8,flags8,len16,addr32
	 */
	private void gen_ccw1() // RPI-567
	{
		String ccw_op    = null;
		String ccw_flags = null;
		String ccw_len   = null;

		dc_align(8);
		loc_start = loc_ctr;
		exp_text = bal_parms;
		exp_index = 0;
		if (calc_abs_exp()
		  && exp_val >= 0
		  && exp_val <  256) {
			ccw_op = tz390.get_hex(exp_val,2);
			loc_ctr = loc_ctr + 4;
			if (exp_text.charAt(exp_index) == ',') {
				exp_index++;
				exp_rld_len = 4;
				if (calc_exp()) {  // RPI-771
					obj_code = obj_code + tz390.get_hex(exp_val,8);
					put_obj_text();
					exp_rld_len = 0;
					loc_ctr = loc_ctr - 4;
					if (exp_text.charAt(exp_index) == ',') {
						exp_index++;
						put_obj_text();
						if (calc_abs_exp()
						  && exp_val < 256) {
							ccw_flags = tz390.get_hex(exp_val,2);
							if (exp_text.charAt(exp_index) == ',') {
								exp_index++;
								if (calc_abs_exp()
								  && exp_val <= 0xffff) {
									ccw_len = tz390.get_hex(exp_val,4);
								}
							}
						}
					}
				}
			}
		}
		obj_code = obj_code + ccw_op + ccw_flags + ccw_len;
		put_obj_text();
		loc_ctr = loc_ctr + 8;
		loc_len = 0;
		exp_rld_len = 0;
		if (list_obj_code.length() == 16) {
			list_obj_code = list_obj_code.substring(8)+list_obj_code.substring(0,8);
		}
	}

	/**
	 * Set dc_hex for floating point string fp_text in scientific notation 0.314159E1 etc.
	 * Format is based on fp type 0-8 (db,dd,dh,eb,ed,eh,lb,ld,lh)
	 */
	private void fp_get_hex()
	{
		/*
		 * Notes:
		 *	1.	This is very tricky code!
		 *	2.	Use BigDecimal for all types to insure DH and EH exponents beyond
		 *		range of DB and EB will be correctly handled without error.
		 *	3.	The fp_context is set to significant decimal digits plus fp_guard_digts
		 *		to insure sufficient significant bits for proper rounding occurs.
		 *	4.	The preferred DFP exponent  (BigDecimal scale factor) is
		 *		set based on explicit decimal point with significant trailing decimal places
		 *		including zeros else use 0. RPI-790
		 *
		 * First convert string constant to positive big_dec1 value with sufficient sig. bits.
		 * Exit with arbitrary format if zero.
		 */
		char fp_sign = '+';
		if (fp_text.charAt(0) =='-') { // RPI-834
			fp_sign = '-';
			fp_text = fp_text.substring(1);
		}
		if (fp_text.charAt(0) == '(') { // RPI-367 support (MIN) and (MAX)
			if (fp_text.toUpperCase().equals("(MAX)")) {
				switch (tz390.fp_type) {  // gen (max) hex for tz390.fp_type
				case 0: // tz390.fp_db_type s1,e11,m52 with assumed 1
					dc_hex = "7FEFFFFFFFFFFFFF";
					break;
				case 1: // tz390.fp_dd_type s1,cf5,bxcf6,ccf20
					dc_hex = "77FCFF3FCFF3FCFF"; // RPI-407
					break;
				case 2: // tz390.fp_dh_type s1,e7,m56 with hex exp
					dc_hex = "7FFFFFFFFFFFFFFF";
					break;
				case 3: // tz390.fp_eb_type s1,e8,m23 with assumed 1
					dc_hex = "7F7FFFFF";
					break;
				case 4: // tz390.fp_ed_type s1,cf5,bxcf8,ccf50
					dc_hex = "77F3FCFF"; // RPI-407
					break;
				case 5: // tz390.fp_eh_type s1,e7,m24 with hex exp
					dc_hex = "7FFFFFFF";
					break;
				case 6: // tz390.fp_lb_type s1,e15,m112 with assumed 1
					dc_hex = "7FFEFFFFFFFFFFFFFFFFFFFFFFFFFFFF";
					break;
				case 7: // tz390.fp_ld_type s1,cf5,bxcf12,ccf110
					dc_hex = "77FFCFF3FCFF3FCFF3FCFF3FCFF3FCFF"; // RPI-407
					break;
				case 8: // tz390.fp_lh_type s1,e7,m112 with split hex
					dc_hex = "7FFFFFFFFFFFFFFF71FFFFFFFFFFFFFF";
					break;
				case 9: // tz390.fp_lq_type quad word RPI-1108
					dc_hex = "00000000000000000000000000000000";
					break;
				}
				if (fp_sign == '-') {
					dc_hex = "F" + dc_hex.substring(1);
				}
				return;
			} else if (fp_text.toUpperCase().equals("(MIN)")) {
				switch (tz390.fp_type) {  // gen (min) hex for tz390.fp_type
				case 0: // tz390.fp_db_type s1,e11,m52 with assumed 1
					dc_hex = "0010000000000000";
					break;
				case 1: // tz390.fp_dd_type s1,cf5,bxcf8,ccf50
					dc_hex = "0000000000000001"; // RPI-407
					break;
				case 2: // tz390.fp_dh_type s1,e7,m56 with hex exp
					dc_hex = "0110000000000000";
					break;
				case 3: // tz390.fp_eb_type s1,e7,m24 with assumed 1
					dc_hex = "00800000";
					break;
				case 4: // tz390.fp_dd_type s1,cf5,bxcf6,ccf20
					dc_hex = "00000001"; // RPI-407
					break;
				case 5: // tz390.fp_eh_type s1,e7,m24 with hex exp
					dc_hex = "01100000";
					break;
				case 6: // tz390.fp_lb_type s1,e15,m112 with assumed 1
					dc_hex = "00010000000000000000000000000000";
					break;
				case 7: // tz390.fp_ld_type s1,cf5,bxcf12,ccf110
					dc_hex = "00000000000000000000000000000001"; // RPI-407
					break;
				case 8: // tz390.fp_lh_type s1,e7,m112 with split hex
					dc_hex = "01100000000000007200000000000000";
					break;
				case 9: // tz390.fp_lq_type quad word RPI-1108
					dc_hex = "00000000000000000000000000000000";
					break;
				}
				if (fp_sign == '-') {
					dc_hex = "8" + dc_hex.substring(1);
				}
				return;
			} else {
				log_error(112,"unrecognized floating point constant " + fp_text);
			}
		}
		fp_context = new MathContext(tz390.fp_precision[tz390.fp_type],RoundingMode.HALF_EVEN); // RPI-843
		try { // RPI-424
			fp_big_dec1 = new BigDecimal(fp_text,fp_context);
		} catch (Exception e) {
			log_error(162,"invalid decimal floating point constant");
			fp_big_dec1 = BigDecimal.ZERO;
		}
		if (dc_exp > 0) { // RPI-368 adj by DC E modifier
			fp_big_dec1 = fp_big_dec1.movePointLeft(dc_exp);
		} else if (dc_exp < 0) {
			fp_big_dec1 = fp_big_dec1.movePointRight(-dc_exp);
		}
		if (fp_big_dec1.signum() > 0) {
			if (fp_sign == '+') { // RPI-834
				tz390.fp_sign = 0;
			} else {
				tz390.fp_sign = tz390.fp_sign_bit[tz390.fp_type];
			}
		} else if (fp_sign == '+') { // RPI-834
			switch (tz390.fp_type) { // gen zero hex for tz390.fp_type
			case 0: // tz390.fp_db_type s1,e11,m52 with assumed 1
				dc_hex = "0000000000000000"; // RPI-384
				return;
			case 1: // tz390.fp_dd_type s1,cf5,bxcf8,ccf50 // RPI-407
				dc_hex = "2238000000000000"; // RPI-384 RPI-790
				return;
			case 2: // tz390.fp_dh_type s1,e7,m56 with hex exp
				dc_hex = "0000000000000000"; // RPI-384
				return;
			case 3: // tz390.fp_eb_type s1,e7,m24 with assumed 1
				dc_hex = "00000000"; // RPI-384
				return;
			case 4: // tz390.fp_ed_type s1,cf5,bxdf6,ccf20 // RPI-407
				dc_hex = "22500000"; // RPI-384 RPI-790
				return;
			case 5: // tz390.fp_eh_type s1,e7,m24 with hex exp
				dc_hex = "00000000"; // RPI-384
				return;
			case 6: // tz390.fp_lb_type s1,e15,m112 with assumed 1
				dc_hex = "00000000000000000000000000000000";  // RPI-384
				return;
			case 7: // tz390.fp_ld_type s1,cf5,bxdf12,ccf110 // RPI-407
				dc_hex = "22080000000000000000000000000000";  // RPI-384 RPI-790
				return;
			case 8: // tz390.fp_lh_type s1,e7,m112 with split hex
				dc_hex = "00000000000000000000000000000000";  // RPI-384
				return;
			case 9: // tz390.fp_lq_type quad word RPI-1108
				dc_hex = "00000000000000000000000000000000";
				break;
			}
		} else { // RPI-834 negative zero values
			switch (tz390.fp_type) {  // gen zero hex for tz390.fp_type
			case 0: // tz390.fp_db_type s1,e11,m52 with assumed 1
				dc_hex = "8000000000000000"; // RPI-384
				return;
			case 1: // tz390.fp_dd_type s1,cf5,bxcf8,ccf50 // RPI-407
				dc_hex = "A238000000000000"; // RPI-384 RPI-790
				return;
			case 2: // tz390.fp_dh_type s1,e7,m56 with hex exp
				dc_hex = "8000000000000000"; // RPI-384
				return;
			case 3: // tz390.fp_eb_type s1,e7,m24 with assumed 1
				dc_hex = "80000000"; // RPI-384
				return;
			case 4: // tz390.fp_ed_type s1,cf5,bxdf6,ccf20 // RPI-407
				dc_hex = "A2500000"; // RPI-384 RPI-790
				return;
			case 5: // tz390.fp_eh_type s1,e7,m24 with hex exp
				dc_hex = "80000000"; // RPI-384
				return;
			case 6: // tz390.fp_lb_type s1,e15,m112 with assumed 1
				dc_hex = "80000000000000000000000000000000";  // RPI-384
				return;
			case 7: // tz390.fp_ld_type s1,cf5,bxdf12,ccf110 // RPI-407
				dc_hex = "A2080000000000000000000000000000";  // RPI-384 RPI-790
				return;
			case 8: // tz390.fp_lh_type s1,e7,m112 with split hex
				dc_hex = "80000000000000000000000000000000";  // RPI-384
				return;
			case 9: // tz390.fp_lq_type quad word RPI-1108
				dc_hex = "00000000000000000000000000000000";
				break;
			}
		}
		/*
		 * 1.  Convert BFP and HFP to base 2 exp and mantissa from base 10.
		 * 2.  For DFP adjust base 10 exponent based on explicit decimal point
		 *     and significant trailing digits including zeros.
		 */
		switch (tz390.fp_type) {
		case 0: // tz390.fp_db_type s1,e11,m52 with assumed 1
			cvt_fp_exp_to_base_2();
			fp_cvt_bd_to_hex();
			break;
		case 1: // tz390.fp_dd_type s1,cf5,bxcf8,ccf50 // RPI-407
			fp_cvt_bd_to_hex();
			break;
		case 2: // tz390.fp_dh_type s1,e7,m56 with hex exp
			cvt_fp_exp_to_base_2();
			fp_cvt_bd_to_hex();
			break;
		case 3: // tz390.fp_eb_type s1,e7,m24 with assumed 1
			cvt_fp_exp_to_base_2();
			fp_cvt_bd_to_hex();
			break;
		case 4: // tz390.fp_ed_type s1,cf5,bxdf6,ccf20 // RPI-407
			fp_cvt_bd_to_hex();
			break;
		case 5: // tz390.fp_eh_type s1,e7,m24 with hex exp
			cvt_fp_exp_to_base_2();
			fp_cvt_bd_to_hex();
			break;
		case 6: // tz390.fp_lb_type s1,e15,m112 with assumed 1
			cvt_fp_exp_to_base_2();
			fp_cvt_bd_to_hex();
			break;
		case 7: // tz390.fp_ld_type s1,cf5,bxdf12,ccf110 // RPI-407
			fp_cvt_bd_to_hex();
			break;
		case 8: // tz390.fp_lh_type s1,e7,m112 with split hex
			cvt_fp_exp_to_base_2();
			fp_cvt_bd_to_hex();
			break;
		case 9: // tz390.fp_lq_type quad word RPI-1108
			break;
		}
	}

	/**
	 * Calculate tz390.fp_exp and big_dec2 such that:
	 * big_dec1 = big_dec2 * 2  ** tz390.fp_exp
	 */
	private void cvt_fp_exp_to_base_2()
	{
		/*******************************************
		 * Calc tz390.fp_exp and big_dec2 such that:
		 * big_dec1 = big_dec2 * 2  ** tz390.fp_exp
		 ***************************************
		 *
		 * tz390.fp_exp = log(big_dec1) / log(2)
		 *
		 * Since the exponent range of LB exceeds native double, the log of big_dec1 is
		 * calculated using equivalent:
		 *   log(X*10**N) = log(X) + N*log(10)
		 * The exponent must then be offset by the number of bits in the required binary mantissa in
		 * order to retain significant bits when big_dec2 is converted to big_int format.  The exponent
		 * is also reduced by 1 for assumed bit in binary formats plus 1 additional to insure rounding for
		 * irrational values is done by shifting right.
		 */
		fp_big_dec1 = fp_big_dec1.stripTrailingZeros(); // RPI-821
		final int    work_scale = -fp_big_dec1.scale();
		final double work_man   =  fp_big_dec1.multiply(
			BigDecimal.TEN.pow(-work_scale,fp_context),fp_context).doubleValue();
		tz390.fp_exp = (int)((Math.log(work_man)
					 + ((double)work_scale * fp_log10)) / fp_log2)
					 - tz390.fp_man_bits[tz390.fp_type]
					 - tz390.fp_one_bit_adj[tz390.fp_type];
		/*
		 * Now calc big_dec2 mantissa truncated integer tz390.fp_exp calculated above.  This calculation
		 * may produce an irrational number with the precision specified due to base 10 to base 2
		 * exponent conversion.
		 *
		 * big_dec2 = big_dec1 / 2 ** tz390.fp_exp/
		 */
		try {
			fp_big_dec2 = fp_big_dec1.multiply(BigDecimal.valueOf(2).pow(-tz390.fp_exp,fp_context),fp_context);
		} catch (final Exception e) {
			log_error(89, "Floating point value out of range");
			dc_hex = "FFFF000000000000";
			return;
		}
		/*
		 * retrieve fp_big_dec2 mantissa bits as big_int and
		 * adjust tz390.fp_exp by mantissa bits
		 */
		fp_big_int1 = fp_big_dec2.toBigInteger();
		tz390.fp_exp = tz390.fp_exp + tz390.fp_man_bits[tz390.fp_type];
	}

	/**
	 *	1.	BFP - Adjust mantissa and base 2 exponent to align for assumed 1 bit.<br>
	 *	2.	HFP - Adjust mantissa and base 2 exponent to base 16 exponent.<br>
	 *	3.	DFP - Set base 10 exponent based on explicit decimal point and trailing
	 *		significant digits including zeros else use preferred exponent of 0.  RPI-790
	 */
	private void fp_cvt_bd_to_hex() {
		switch (tz390.fp_type) {  // gen hex for fp type
		case 0: // tz390.fp_db_type s1,e11,m52 with assumed 1
			fp_long1 = fp_big_int1.longValue();
			fp_round_bit = 0;
			while (fp_long1 > fp_long_db_one_bits) {
				fp_round_bit = (int)(fp_long1 & 1);
				fp_long1 = fp_long1 >>> 1;
					 tz390.fp_exp++;
					 if (fp_long1 <= fp_long_db_one_bits) {
						 fp_long1 = fp_long1 + fp_round_bit;
					 }
			}
			tz390.fp_exp = tz390.fp_exp + tz390.fp_exp_bias[tz390.fp_type];
			if (tz390.fp_exp >= 0 && tz390.fp_exp <= tz390.fp_exp_max[tz390.fp_type]) {
				dc_hex = get_long_hex(
						((long)(tz390.fp_sign | tz390.fp_exp)
								<< tz390.fp_man_bits[tz390.fp_type])
							| (fp_long1 & fp_long_db_man_bits));
			} else {
				log_error(89, "Floating point value out of range");
				dc_hex = "FFFF000000000000";
			}
			break;
		case 1: // tz390.fp_dd_type s1,cf5,bxcf8,ccf50 // RPI-50
			set_dfp_preferred_exp();
			if (!tz390.fp_get_dfp_bin(tz390.fp_dd_type, fp_big_dec1)) {
				log_error(179,"DD dfp constant out of range");
				dc_hex = "0000000000000000";
			} else {
				dc_hex = tz390.get_long_hex(tz390.fp_work_reg.getLong(0),16);
			}
			break;
		case 2: // tz390.fp_dh_type s1,e7,m56 with hex exp
			fp_long1 = fp_big_int1.longValue();
			fp_round_bit = 0;
			while ((tz390.fp_exp & 0x3) != 0
				  || fp_long1 > fp_long_dh_man_bits) {
				fp_round_bit = (int)(fp_long1 & 1);
				fp_long1 = fp_long1 >>> 1;
				tz390.fp_exp++;
				if (fp_round_bit == 1
					&& (tz390.fp_exp & 0x3) == 0  // RPI-821
					&& fp_long1 <= fp_long_dh_man_bits) {
					fp_long1++;
				}
			}
			tz390.fp_exp = (tz390.fp_exp >> 2) + tz390.fp_exp_bias[tz390.fp_type] + dc_scale; // RPI-368
			if (tz390.fp_exp >= 0 && tz390.fp_exp <= tz390.fp_exp_max[tz390.fp_type]) {
				dc_hex = get_long_hex(
					 ((long)(tz390.fp_sign | tz390.fp_exp)
							 << tz390.fp_man_bits[tz390.fp_type])
					  | fp_long1);
			} else {
				log_error(89, "Floating point value out of range");
				dc_hex = "FFFF000000000000";
			}
			break;
		case 3: // tz390.fp_eb_type s1,e7,m24 with assumed 1
			fp_int1 = fp_big_int1.intValue();
			fp_round_bit = 0;
			while (fp_int1 >= fp_int_eb_one_bits) {
				fp_round_bit = fp_int1 & 1;
				fp_int1 = fp_int1 >>> 1;
				tz390.fp_exp++;
				if (fp_int1 <= fp_int_eb_one_bits) {
					fp_int1 = fp_int1 + fp_round_bit;
				}
			}
			tz390.fp_exp = tz390.fp_exp + tz390.fp_exp_bias[tz390.fp_type];
			if (tz390.fp_exp >= 0 && tz390.fp_exp <= tz390.fp_exp_max[tz390.fp_type]) {
				dc_hex = tz390.get_hex(
						((tz390.fp_sign | tz390.fp_exp)
							<< tz390.fp_man_bits[tz390.fp_type])
						| (fp_int1 & fp_int_eb_man_bits),8);
			} else {
				log_error(89, "Floating point value out of range.");
				dc_hex = "FF000000";
			}
			break;
		case 4: // tz390.fp_ed_type s1,cf5,bxcf6,ccf20 // RPI-407
			set_dfp_preferred_exp();
			if (!tz390.fp_get_dfp_bin(tz390.fp_ed_type, fp_big_dec1)) { // RPI-790
				log_error(180,"ED dfp constant out of range");
				dc_hex = "00000000";
			} else {
				dc_hex = tz390.get_hex(tz390.fp_work_reg.getInt(0),8);
			}
			break;
		case 5: // tz390.fp_eh_type s1,e7,m24 with hex exp
			fp_int1 = fp_big_int1.intValue();
			fp_round_bit = 0;
			while ((tz390.fp_exp & 0x3) != 0  // RPI-821
				  || fp_int1 > fp_int_eh_man_bits) {
				fp_round_bit = fp_int1 & 1;
				fp_int1 = fp_int1 >>> 1;
				tz390.fp_exp++;
				if (fp_round_bit == 1   // RPI-821
				  && (tz390.fp_exp & 0x3) != 0
				  &&	fp_int1 <= fp_int_eh_man_bits) {
					fp_int1++;	// RPI-821
				}
			}
			tz390.fp_exp = (tz390.fp_exp >> 2) + tz390.fp_exp_bias[tz390.fp_type] + dc_scale;  // RPI-368
			if (tz390.fp_exp >= 0 && tz390.fp_exp <= 0x7f) {
				dc_hex = tz390.get_hex(
						((tz390.fp_sign | tz390.fp_exp) << 24)
						| fp_int1,8);
			} else {
				log_error(89, "Floating point value out of range.");
				dc_hex = "00000000";
			}
			break;
		case 6: // tz390.fp_lb_type s1,e15,m112 with assumed 1
			fp_round_bit = 0;
			while (fp_big_int1.compareTo(fp_big_int_one_bits) > 0) {
				if (fp_big_int1.testBit(0)) {
					fp_round_bit = 1;
				} else {
					fp_round_bit = 0;
				}
				fp_big_int1 = fp_big_int1.shiftRight(1);
				tz390.fp_exp++;
				if (fp_round_bit == 1
				  && fp_big_int1.compareTo(fp_big_int_one_bits) <= 0) {
					fp_big_int1 = fp_big_int1.add(BigInteger.ONE);
				}
			}
			tz390.fp_exp = tz390.fp_exp + tz390.fp_exp_bias[tz390.fp_type];
			if (tz390.fp_exp >= 0 && tz390.fp_exp <= tz390.fp_exp_max[tz390.fp_type]) {
				fp_big_byte = fp_big_int1.toByteArray();
				int index1 = fp_big_byte.length - 1;
				int index2 = 15;
				while (index2 > 0) {
					if (index1 >= 0) {
						fp_data_byte[index2] = fp_big_byte[index1];
						index1--;
					} else {
						fp_data_byte[index2] = 0;
					}
					index2--;
				}
				fp_data_buff.putShort(0,(short)(tz390.fp_sign | tz390.fp_exp));
				dc_hex = bytes_to_hex(fp_data_byte,0,16,0);
			} else {
				log_error(89,"floating point value out of range");
				dc_hex = "FF00000000000000FF00000000000000";
			}
			break;
		case 7: // tz390.fp_ld_type s1,cf5,bxcf12,ccf110 // RPI-407
			set_dfp_preferred_exp();
			if (!tz390.fp_get_dfp_bin(tz390.fp_ld_type, fp_big_dec1)) { // RPI-790
				log_error(181,"LD dfp constant out of range");
				dc_hex = "00000000000000000000000000000000";
			} else {
				dc_hex  = tz390.get_long_hex(tz390.fp_work_reg.getLong(0),16)
						+ tz390.get_long_hex(tz390.fp_work_reg.getLong(8),16)	;
			}
			break;
		case 8: // tz390.fp_lh_type s1,e7,m112 with split hex
			fp_round_bit = 0;
			while ((tz390.fp_exp & 0x3) != 0  // RPI-821
				  || fp_big_int1.compareTo(fp_big_int_lx_man_bits) > 0) {
				if (fp_big_int1.testBit(0)) {
					fp_round_bit = 1;
				} else {
					fp_round_bit = 0;
				}
				fp_big_int1 = fp_big_int1.shiftRight(1);
				tz390.fp_exp++;
				if (fp_round_bit == 1
				  && (tz390.fp_exp & 0x3) == 0  // RPI-821
				  && fp_big_int1.compareTo(fp_big_int_lx_man_bits) <= 0) {
					fp_big_int1 = fp_big_int1.add(BigInteger.ONE);
				}
			}
			tz390.fp_exp = (tz390.fp_exp >> 2) + tz390.fp_exp_bias[tz390.fp_type] + dc_scale; // RPI-368
			if (tz390.fp_exp >= 0 && tz390.fp_exp <= tz390.fp_exp_max[tz390.fp_type]) {
				fp_big_byte = fp_big_int1.toByteArray();
				int index1 = fp_big_byte.length - 1;
				int index2 = 15;
				while (index2 > 0) {
					if (index2 == 8) {
						index2--;  // skip dup exp byte
					}
					if (index1 >= 0) {
						fp_data_byte[index2] = fp_big_byte[index1];
						index1--;
					} else {
						fp_data_byte[index2] = 0;
					}
					index2--;
				}
				fp_data_buff.put(0,(byte)(tz390.fp_sign | tz390.fp_exp));
				if (fp_data_buff.getLong(0) == 0) {
					fp_data_buff.put(8,(byte)0x00); // RPI-384
				} else {
					fp_data_buff.put(8,(byte)(tz390.fp_sign | ((tz390.fp_exp - 14) & 0x7f))); // RPI-384
				}
				dc_hex = bytes_to_hex(fp_data_byte,0,16,0);
			} else {
				log_error(89,"floating point value out of range");
				dc_hex = "FF00000000000000FF00000000000000";
			}
			break;
		case 9: // tz390.fp_lq_type quad word RPI-1108
			break;
		}
	}

	/**
	 * Set DFP preferred base 10 exponent for fp_big_dec1 value
	 * if explicit decimal found in fp_text.
	 */
	private void set_dfp_preferred_exp()
	{
		int tot   = 0;
		int index = fp_text.indexOf('.');
		if (index != -1) {
			index++;
			while (index < fp_text.length() && fp_text.charAt(index) >= '0' && fp_text.charAt(index) <= '9') {
				tot++;
				index++;
			}
			if (tot > tz390.fp_digits_max[tz390.fp_type]) {
				tot = tz390.fp_digits_max[tz390.fp_type];
			}
			fp_big_dec1.setScale(tot);
		}
		if (!dc_scale_explicit && dc_first_field) {
			dc_first_scale = tot; // RPI-790
		}
		dc_scale = fp_big_dec1.scale();
	}

	/**
	 * Add missing copy file for ERRSUM.
	 *
	 * @param name
	 * @return
	 */
	public boolean add_missing_copy(final String name)
	{
		int index = 0;
		while (index < tot_missing_copy) {
			if (name.equals(missing_copy[index])) {
				return true;
			}
			index++;
		}
		if (index < max_missing) {
			tot_missing_copy++;
			missing_copy[index] = name;
			return true;
		}

		return false;
}

	/**
	 * Add nussubg ciot file for ERRSUM.
	 *
	 * @param name
	 * @return
	 */
	private boolean add_missing_macro(final String name)
	{
		int index = 0;
		while (index < tot_missing_macro) {
			if (name.equals(missing_macro[index])) {
				return true;
			}
			index++;
		}
		if (index < max_missing) {
			tot_missing_macro++;
			missing_macro[index] = name;
			return true;
		}
		return false;
	}

	/**
	 * Report critical errors on ERR file and console for ERRSUM option.
	 */
	public void report_critical_errors()
	{
		if (tot_missing_macro + tot_missing_copy + tot_missing_sym == 0) {
			return; // RPI-959
		}
		tz390.opt_errsum = false; // allow printing on PRN again
		tz390.opt_list   = true;
		put_errsum("ERRSUM Critical Error Summary Option");
		put_errsum("ERRSUM Fix and repeat until all nested errors resolved");
		int index = 0;
		while (index < tot_missing_copy) {
			put_errsum("ERRSUM missing copy  =" + missing_copy[index]); // RPI-1051
			index++;
		}
		index = 0;
		while (index < tot_missing_macro) {
			put_errsum("ERRSUM missing macro =" + missing_macro[index]);
			index++;
		}
		if (tot_missing_macro + tot_missing_copy == 0) {
			index = 1;
			while (index <= tot_sym) {
				if (sym_type[index] == sym_und) {
					put_errsum("ERRSUM undefined symbol = " + sym_name[index]);
				}
				index++;
			}
		}
		put_errsum("ERRSUM total missing   copy   files =" + tot_missing_copy );
		put_errsum("ERRSUM total missing   macro  files =" + tot_missing_macro);
		put_errsum("ERRSUM total undefined symbols      =" + tot_missing_sym  );
		if (mz390_call) {
			put_errsum("ERRSUM total mz390 errors    = " + mz390_errors); // RPI-659 RPI-945
		}
		put_errsum("ERRSUM total az390 errors    = " + az390_errors); // RPI-659 RPI-945
	}

	/**
	 * Put ERRSUM messages on ERR file and console.
	 * @param msg
	 */
	private void put_errsum(String msg)
	{
		msg = msg_id_e + msg;
		System.out.println(msg);
		if (prn_file != null) {
			// If ERRSUM turned on after open put messages to PRN.
			put_prn_line(msg);
		}
		tz390.put_systerm(msg);
	}

	/**
	 * Return I' integer pfx value for symbol based on length and scale per ref.
	 *
	 * @param type
	 * @param type_sfx
	 * @param len
	 * @param scale
	 * @return
	 */
	public int get_int_pfx(final byte type, final byte type_sfx, final int len, final int scale)
	{
		switch (type) {
		case 'F':
		case 'H':
			return 8 * len - scale - 1;
		case 'D':
		case 'E':
		case 'L':
			if (type_sfx == 'D') { // DFP
				if (len == 4) {
					return 7 - scale;
				} else if (len == 8) {
					return 16 - scale;
				} else {
					return 34 - scale;
				}
			} else { // HFP and BFP
				if (len <= 8) {
					return 2 * (len - 1) - scale;
				} else {
					return 2 * (len - 1) - scale - 2;
				}
			}
		case 'P':
			return 2 * len - scale - 1;
		case 'Z':
			return len - scale;
		default:
			return 0;
		}
	}
}
