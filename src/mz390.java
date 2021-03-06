import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.lang.reflect.Array;
import java.text.SimpleDateFormat;
import java.util.Arrays;
import java.util.Date;
import java.util.GregorianCalendar;
import java.util.LinkedList;
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
 * mz390 is the macro processor component of z390 which can be called from
 * z390 GUI interface or from command line to read MLC macro source and
 * any referenced macros and copybooks to generate expanded BAL source file.
 */
public class mz390
{
	// Static limits
	/**
	 * Maximum number of exp variable stack operations.
	 */
	private final int max_exp_stk = 500;
	/**
	 * Maximum substring length
	 */
	private final int max_substring_len = 100000;
	/**
	 * Maximum number of concurrent AREAD and PUNCH files.
	 */
	private final int max_ap_files = 10;
	/**
	 * Hash index for each macro instance.
	 */
	private final int max_lcl_key_root = 47;


	// Subordinate
	private tz390 tz390 = null;
	private az390 az390 = null; // RPI-415

	private final String msg_id = "MZ390I ";

	private String trace_id = msg_id; // "MZ390I "

	private boolean mac_branch = false; // RPI-899
	private boolean mac_abort = false;
	private int     mz390_rc = 0;
	private int     mz390_errors = 0;
//	private boolean mz390_recursive_abort	= false; // RPI-935 // JBA-unused
//	private boolean batch_asm_error			= false; // RPI-736 // JBA-unused
	private Date cur_date = null;
	private long tod_start = 0;
	private long tod_end   = 0;
	private long tot_msec = 0;
	private long ins_rate    = 0;
	private boolean log_to_bal = false;
	private int tot_bal_line = 0;
	private boolean bal_eof = false;
	private int tot_mnote_errors  = 0;
	private int tot_mnote_warning = 0;
	private int hwm_mnote_level   = 0;
	private String bal_text = null;     // curr bal_line text
	private int    bal_text_index0 = 0; // end of prev. parm
	private int    bal_text_index1 = 0; // start of cur parm
	private int    bal_text_index2 = 0; // end   of cur parm
	private int tot_mac_ins  = 0;
	private int tot_mac_load = 0;
	private int tot_mac_call = 0;
//	private int tot_mac_copy = 0; // JBA-unused
	private int mlc_line_end = 0;
	private File bal_file = null;
	private File temp_file = null;
	private BufferedWriter bal_file_buff = null;
	private boolean aread_op = false;
	private int tot_aread_io = 0;
	private int tot_punch_io = 0;
	private int ap_file_index = 0;
	private String ap_file_name = null;
	private boolean ap_format = false;  // format PCH extension
//	private boolean ap_noprint = false; // RPI-745 ignore AREAD option
//	private boolean ap_nostmt  = false; // RPI-745 ignore AREAD option
	private boolean ap_clockb  = false; // RPI-745 return 8 char TOD in 0.01 sec in AREAD string
	private boolean ap_clockd  = false; // RPI-745 return 8 char TOD as HHMMSSTH in AREAD string
	private boolean ap_file_io = false; // RPI-745 set if DDNAME, DSNAME, DSN, or ID on AREAD
	private int dat_file_index = 0;
	private int pch_file_index = 0;
	private File[] dat_file = new File[max_ap_files];
	private BufferedReader[] dat_file_buff = new BufferedReader[max_ap_files];
	private File[]   pch_file = new File[max_ap_files];
	private BufferedWriter[] pch_file_buff = new BufferedWriter[max_ap_files];
	private String bal_line = null;
	private String bal_label = null;
	private String bal_op = null;
	private String bal_comments = null; // RPI-1166
	private String   save_bal_op = null; // original bal_op
	private int      save_opsyn_index = -1; // opsyn index of orig. bal_op
	private int ago_index      = 0; // current ago index value 1-n
	private int ago_line_index = 0; // current ago branch line index;
	private int ago_lab_index  = 0; // current ago parms index to label
	private int ago_gbla_index = 0; // ago index array ptr
	private int ago_gblc_index = 0; // ago trace label array ptr
	private boolean aif_op = false;
	private boolean bal_op_ok = false;
	private String bal_parms = null;
	private boolean mlc_eof = false;
	private boolean end_found = false;
	private int     actr_limit = 4096;
	private int     actr_count = actr_limit;
	private final SimpleDateFormat sdf_sysclock       = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss.SSS000");
	private final SimpleDateFormat sdf_sysdatc        = new SimpleDateFormat("yyyyMMdd");
	private final SimpleDateFormat sdf_sysdate        = new SimpleDateFormat("MM/dd/yy");
	private final SimpleDateFormat sdf_sysdate_bs2000 = new SimpleDateFormat("MMddyyDDD");
	private final SimpleDateFormat sdf_systime        = new SimpleDateFormat("HH.mm");
	private final SimpleDateFormat sdf_systime_bs2000 = new SimpleDateFormat("HHmmss");
	private final SimpleDateFormat sdf_systime_clockd = new SimpleDateFormat("HHmmssSSS");
//	private boolean log_tod = true; // JBA-unused
	private JTextArea z390_log_text = null;

	// AINSERT linked list
	private int cur_ainsert  = 0;  // RPI-956 current AINSERT records in queue
	private int tot_ainsert  = 0;  // RPI-956 total AINSERT records
	private int last_ainsert = 0; // RPI-956 alloc AINSERT source records top down
	private LinkedList<String> ainsert_queue  = new LinkedList<String>(); // RPI-956
	private String last_seq = null; // RPI-957
	private String cur_seq  = null; // RPI-957

	// Macro execution global data
	private long    tod_time_limit = 0;
	private int     next_time_ins   = 0x1000;
	private int     next_time_check = next_time_ins;
	private String cur_mac_file_path = null;
	private int cur_mac_file = 0;
	private int dynamic_mac_file  = -1;    // RPI-1019
	private int dynamic_copy_file = -1;    // RPI-1019
	private boolean ainsert_copy = false;  // RPI-1019 RPI-1083 currently expanding AINSERT copy to front of queue
	private boolean ainsert_source = false; // RPI-1083 cur mac_line is from AINSERT queue
	private int     ainsert_copy_level = 0; // RPI-1135
	private int     ainsert_copy_index = 0; // RPI-1053
	private boolean ainsert_back = true;  // RPI-1019
	private File[]  mac_file               = null;
	private BufferedReader[] mac_file_buff = null;
	private int[]   mac_file_cur_file_num = null;
	private int[]   mac_file_cur_line_num = null;
	private int[]   mac_file_errors = null;
	private int[]   mac_ictl_start = null; // RPI-728
	private int[]   mac_ictl_end   = null; // RPI-728
	private int[]   mac_ictl_cont  = null; // RPI-728
	private int cur_mac_line_num = 0;
	private int cur_mac_file_num = 0;
	private boolean mac_mend_eof = false;  // RPI-740
	private String mac_line = null;
	private String mac_label = null;
	private String mac_op = null;
	private int    mac_opcode_index = 0;
	private String mac_parms = null;
//	private String parm_name = null; // JBA-unused
	private String parm_value = null;
	private boolean cics_first_dsa_dsect = false; // cics prolog change to DFHEISTG macro
	private boolean cics_first_csect     = false; // cics prolog change to DFHEIENT macro
	private boolean cics_first_end       = false; // cics epilog change to DFHEIEND macro

	// ZSTRMAC macro extension global data // RPI-902
	private int     zsm_line_index = 0;  // next genereated line to return
	private int     zsm_line_tot   = 0;  // tot generated lines
	private int     max_zsm_lines  = 256;
	private String  zsm_gen_line[] = new String[max_zsm_lines];
	private int     zsm_lvl        = 0;  // current nested structure level
	private int     max_zsm_lvl    = 50;
	private byte    zsm_lvl_type[] = new byte[max_zsm_lvl];
	private byte    zsm_type_aelse   = 1;
	private byte    zsm_type_aelseif = 2;
	private byte    zsm_type_aend    = 3;
	private byte    zsm_type_aentry  = 4;
	private byte    zsm_type_aexit   = 5;
	private byte    zsm_type_aif     = 6;
	private byte    zsm_type_acall   = 7;
	private byte    zsm_type_acase   = 8;
	private byte    zsm_type_awhen   = 9;
	private byte    zsm_type_auntil  = 10;
	private byte    zsm_type_awhile  = 11;
	private final String[] zsm_type_pfx = {	"???", // 0
											"AIF", // 1 AELSE
											"AIF", // 2 AELSEIF
											"???", // 3 AEND
											"ACL", // 4 AENTRY
											"???", // 5 AEXIT
											"AIF", // 6 AIF
											"ACL", // 7 ACALL
											"ACS", // 8 ACASE
											"ACS", // 9 AWHEN
											"AUN", //10 AUNTIL
											"AWH"};//11 AWHILE
	private int     zsm_lvl_tcnt[] = new int[max_zsm_lvl]; // type instance counter
	private boolean zsm_lvl_aelse[] = new boolean[max_zsm_lvl];
	private int     zsm_aif_tot    = 0;
	private int     zsm_acall_tot  = 0;
	private int     zsm_aentry_tot = 0;
	private int     zsm_acase_tot  = 0;
	private int     zsm_awhile_tot = 0;
	private int     zsm_auntil_tot = 0;
	private int     zsm_lvl_bcnt[] = new int[max_zsm_lvl]; // type block counter for AIF, ACASE
	private boolean zsm_lvl_tend[] = new boolean[max_zsm_lvl]; // req END label for type
	private String  zsm_lvl_ase_ago[] = new String[max_zsm_lvl]; // ACASE computed AGO with expression
	private int     zsm_lvl_ase_fst[] = new int[max_zsm_lvl]; // first index value assigend to awhen block
	private int     zsm_lvl_ase_lst[] = new int[max_zsm_lvl]; // last index value assigned to awhen block
	private short   zsm_lvl_ase_blk[] = new short[256*max_zsm_lvl];
	private String  zsm_aif_exp       = null;
	private int     zsm_acall_index     =    0;
	private int     zsm_aentry_name_tot =    1; // total acall blocks defined + 1
	private int     max_zsm_aentry_name = 1000; // maximum acall blocks
	private String  zsm_acall_name[]  = new String[max_zsm_aentry_name];
	private int     zsm_acall_cnt[]   = new int[max_zsm_aentry_name]; // unizue acall return counter
	private boolean zsm_aentry_def[]  = new boolean[max_zsm_aentry_name]; // aentry block defined  RPI-1078

	// Macro name table
	private String cur_mac_name = null;
	private int mac_name_index = 0; //current mlc or macro
//	private int mac_last_find_index = -1; // JBA-unused
	private int tot_ins = 0; // count instr/cntl for MFC option
	private int tot_mac_name = 0;      // next avail name
	private int load_macro_mend_level = 0;
	private boolean macro_op_found = false; // RPI-935
//	private boolean loading_mac = false; // JBA-unused
	private boolean load_proto_type = false;
	private int load_mac_inline_end = 0;
	private int find_mac_name_index = 0;
	private int load_mac_name_index = 0;
	private byte     load_type       = 0;
	private byte     load_mlc_file   = 0; // no MACRO, no prototype, stop on END
	private byte     load_mac_file   = 1; // MACRO, prototype, MEND, read file and verify name = prototype
	private byte     load_mac_inline = 2; // MACRO, prototype, MEND, read in memory source
	private byte     load_mac_exec   = 3; // executing mlc/mac code
	private int      load_proto_index = 0; // line index of proto_type statement
	private String   load_macro_name = null;
	private String   load_file_name = null;
	private String[] mac_name            = null;
	private int[]    mac_name_line_start = null;
	private int[]    mac_name_line_end   = null;
	private int[]    mac_name_lab_start  = null;
	private int[]    mac_name_lab_end    = null;

	// Macro BAL line tables
	private int new_mac_line_index = 0; //target  mac_line_index
	private int mac_line_index = 1;     //current mac line index
	private int bal_xref_index = 0;     // last mac line ref to pass to az390
	private int tot_mac_line = 1;       // next avail line RPI-899 was 0
	private String[] mac_file_line     = null;  // mlc, mac, and cpy source line including continued text
	private int[]    mac_file_line_num = null;  // starting line number in file
	private int[]    mac_file_num = null;  // mac file index
	private int[]    mac_file_next_line = null; // RPI-956
	private int[]    mac_file_prev_line = null; // RPI-956
	private int tot_mac_file_name = 0;
	private String[] mac_file_path = null;
	private char[]   mac_file_type = null; // ' ' - mlc, '+' - mac, '=' - copy RPI-549
	private boolean  skip_store = false;

	// Macro labels for loaded mlc and macros
	private int tot_mac_lab = 0;
	private String[] mac_lab_name  = null;
	private int[]    mac_lab_index = null;
	private int[]    mac_lab_num   = null; // RPI-266

	// Macro call stack variables
	private int tot_expand = 0;
	private int expand_inc = 100;         //macro array expansion RPI-401
	private int mac_call_level = 0;      //level of macro nesting during loading
	private int[]    mac_call_name_index = null;
	private int[]    mac_call_return     = null;
	private int[]    mac_call_sysm_sev   = null; // RPI-898
	private int[]    mac_call_actr       = null;
	private int[]    mac_call_sysndx     = null;
	private int[]    mac_call_pos_start  = null;
	private int[]    mac_call_pos_tot    = null;
	private int[]    mac_call_kwd_start  = null;
	private int[]    mac_call_lcl_name_start = null;
	private int[]    mac_call_lcl_seta_start = null;
	private int[]    mac_call_lcl_setb_start = null;
	private int[]    mac_call_lcl_setc_start = null;
	private int[]    mac_call_lcl_key_start  = null;
	private int[]    mac_call_lcl_key_root   = null;

	// Macro positional and key word global variables
	private Pattern var_pattern = null;
	private Matcher var_match   = null;
	private Pattern proto_pattern = null;
	private Matcher proto_match   = null;
	private Pattern exp_pattern = null;
	private Matcher exp_match   = null;
	private Pattern pch_pattern = null;
	private Matcher pch_match   = null;
	private Pattern label_pattern = null;
	private Matcher label_match   = null;
	private String  label_name;
	private Pattern symbol_pattern = null; // RPI-404
	private Matcher symbol_match = null;
	private Pattern exec_pattern = null;
	private Matcher exec_match   = null;
//	private int label_comma_index = 0; // parm into to comma after macro label else -1 // JBA-unused
	private int sublist_count = 0;
	private int tot_pos_parm = 0; // cur pos parms on stack
	private int cur_pos_parm = 0; // cur pos parm during init (may exceed prototype pos)
	private int tot_kwd_parm = 0; // cur kwd parms on stack
	private int hwm_pos_parm = 0;      // tot pos parms defined
	private int hwm_kwd_parm = 0;      // tot kwd parms defined
	private String[]  mac_call_pos_name = null;
	private String[]  mac_call_pos_parm = null;
	private String[]  mac_call_kwd_name = null;
	private String[]  mac_call_kwd_parm = null;
	private boolean[] mac_call_kwd_set  = null; // RPI-600

	// Global and local macro variables
	private byte val_seta_type      = 1;      // int    RPI-447
	private byte val_setb_type      = 2;      // byte   RPI-447
	private byte val_setc_type      = 3;      // String RPI-447
	private byte var_lcl_loc        = 11;     // lcl_seta, lcl_setb, lcl_setc
	private byte var_gbl_loc        = 12;     // gbl_seta, gbl_setb, gbl_setc
	private byte var_pos_loc        = 13;     // named positional parm
	private byte var_kw_loc         = 14;     // named keyword parm
	private byte var_syslist_loc    = 15; // syslist pos parm ref
	private byte var_seta_type      = 21; // lcla or gbla
	private byte var_setb_type      = 22; // lclb or gblb
	private byte var_setc_type      = 23; // lclc or gblc
	private byte var_parm_type      = 24; // setc parm (pos, kw, or syslist)
	private byte var_subscript_type = 25; // loc= lcl,gbl,pos,kw,sylist
	private byte var_sublist_type   = 26; // index=-1 for &syslist else use setc value
	private byte var_pc_seta_stack_type = 31; // pc opr1=stack-2, opr2=stack-1 (type unknown for comp??)
	private byte var_pc_seta_sdt_type   = 32; // pc opr1=stack-1, opr2=seta sdt =
//	private byte var_pc_setb_stack_type = 33; // pc opr1=stack-2, opr2=stack-1 // JBA-unused
//	private byte var_pc_setb_sdt_type   = 34; // pc opr1=stack-1, opr2=setb sdt (in pc_seta) // JBA-unused
	private byte var_pc_setc_stack_type = 35; // pc opr1=stack-2, opr2=stack-1
	private byte var_pc_setc_sdt_type   = 36; // pc opr1=stack-1, opr2=setc sdt
	private int tot_lcl_name = 0; // cur lcl sets on stack
	private int tot_lcl_seta = 0;
	private int tot_lcl_setb = 0;
	private int tot_lcl_setc = 0;
	private int hwm_lcl_name = 0; // high water mark lcl names
	private int hwm_lcl_seta = 0;
	private int hwm_lcl_setb = 0;
	private int hwm_lcl_setc = 0;
//	private boolean sysinit_done = false; // JBA-unused
	private int lcl_sysndx = -1;  // macro call counter
	private String lcl_sysect = ""; // RPI-1213
	private String lcl_sysloc = lcl_sysect;
	private String lcl_sysstyp = "";
	private int lcl_sysect_setc_index  = -1; // RPI-1213
	private int lcl_sysloc_setc_index  = -1; // RPI-1213
	private int lcl_sysstyp_setc_index = -1; // RPI-1213
	private String[] lcl_set_name  = null;
	private byte[]   lcl_set_type  = null;
	private int[]    lcl_set_start = null;
	private int[]    lcl_set_high  = null;
	private int[]    lcl_set_end   = null;
	private int[]    lcl_seta      = null;
	private byte[]   lcl_setb      = null;
	private String[] lcl_setc      = null;

	// Global set variables set by find_set and add_lcl_set, add_gbl_set
	private boolean var_subscript_calc = false;
	private boolean var_set_array; // RPI-836 set subscript required for set array
	private String var_name  = null;
	private int    var_name_index = 0;
	private byte   var_loc   = var_lcl_loc;
	private byte   var_type  = var_seta_type;
//	private int    set_size  = 0; // JBA-unused
	private int    seta_index = 0;
	private int    setb_index = 0;
	private int    setc_index = 0;
	private String store_name = null;
	private int    store_name_index = 0;
	private int    store_inc   = 0;  // RPI-839
	private byte   store_loc   = var_lcl_loc;
	private byte   store_type = val_seta_type;
	private int    store_seta_value = 0;
	private byte   store_setb_value = 0;
	private String store_setc_value = null;
	private byte   store_pc_op = 0;
	private boolean exec_pc_op      = false; // RPI-1139
	private boolean tracem_pc_op    = false; // RPI-930 include on tracem TRM listing
	private boolean store_subscript = false;
	private boolean store_created   = false;
	private int    store_sub        = 0;
	private int    store_seta_index = 0;
	private int    store_setb_index = 0;
	private int    store_setc_index = 0;
//	private int    store_pc_start = 0; // JBA-unused
//	private int    store_pc_last  = 0; // JBA-unused
	private String set_name = "";
	private int    set_sub  = 0;
	private boolean set_subscript = false; // RPI-1162
	private int    seta_value = 0;
	private byte   setb_value = 0;
	private String setc_value = "";
	private String save_setc_value = null;
	private String save_setc_value1 = null;
	private String save_setc_value2 = null;
	private byte   save_pc_parm_type = 0;
	private int    save_seta_value = 0;
	private int    setc_len   = 0;

	// Define global gbla, gblb, gblc, and system predefined globals
	private int    gbl_sysclock_index = 0; // YYYY-MM-DD HH:MM:SS.mmmmmm
	private int    gbl_sysmac_index = 0;   // macro name at specified level
	private String gbl_sysmac  = "";
	private int    gbl_syslib_index = 0;  // syslib current macro dsn, mem=+1, vol=+2
	private int    gbl_sysm_hsev_index = 0;  // highest mnote severity code
	private int    cur_sysm_hsev       = 0;  // RPI-898
	private int    gbl_sysm_sev_index = 0;   // highest mnote severity in last macro
	private int    gbl_sysstmt_index = 0;    // next BAL statement number as 8 digit SETC
	private int    gbl_systrace_index = 0;   // set trace options on/off RPI-930
	private File sys_file = null; // RPI-259
	private String sys_job = null; // set to MLC filename without suffix
	private String sys_dsn = null; // full path, file name, and suffix
	private String sys_mem = null; // file name and suffix
	private String sys_vol = null; // drive letter
	private int tot_gbl_name = 0;
	private int tot_gbl_seta = 0;
	private int tot_gbl_setb = 0;
	private int tot_gbl_setc = 0;
	private String[] gbl_set_name  = null;
	private byte[]   gbl_set_type  = null;
	private int[]    gbl_set_start = null;
	private int[]    gbl_set_high  = null; // RPI-342 highest subscript
	private int[]    gbl_set_end   = null;
	private int[]    gbl_seta      = null;
	private byte[]   gbl_setb      = null;
	private String[] gbl_setc      = null;

	// Macro operation global variables
	private int mac_op_type = 0;
	private int max_lcl_key_tab = 0;
	private int tot_lcl_key_tab  = max_lcl_key_root+1;
	private int cur_lcl_key_root = 1;
	private String lcl_key_text = null;
	private int lcl_key_index = 0;
	private int lcl_key_index_last = 0;
	private int lcl_key_hash = 0;
	private String[]  lcl_key_tab_key   = null;
	private int[]     lcl_key_tab_hash  = null;
	private int[]     lcl_key_tab_index = null;
	private int[]     lcl_key_tab_low   = null;
	private int[]     lcl_key_tab_high  = null;

	// Set expression global variables including polish notation var and op stacks
	private char    asc_space_char = ' '; // white space <= asc_space_char
	private String  exp_text  = null;
	private int     exp_text_len = 0;
	private int     exp_level = 0;
	private boolean[] exp_created_var = new boolean[max_exp_stk];
	private boolean exp_end = false;
	private boolean exp_ok  = false;
	private char    exp_term_op = '~';      // terminate exp
	private char    exp_start_op = '~';     // start exp
	private char    exp_string_op = '\'';   // start/end setc string
	private int     exp_string_var = 0; // RPI-1139
	private char    exp_create_set_op = '&'; // created set &(...) oper
	private boolean exp_var_replacement_mode = false; // for repace_vars()
	private boolean exp_var_replacement_change = false; // set if replacements made
	private boolean exp_alloc_set_mode = false;  // for lcl/gbl alloc
	private boolean exp_parse_set_mode = false;  // for set target and lcl/gbl alloc
//	private boolean exp_alloc_set_created  = false;  // set true if alloc_set finds created // JBA-unused
	private int     alloc_size     = 0;
	private int     min_alloc_size = 10; // RPI-435 minimum default alloc for array
	private byte    exp_parse_set_type = 0;
	private byte    exp_parse_set_loc  = 0;
	private String  exp_parse_set_name = null;
	private boolean exp_parse_set_subscript = false;
	private boolean exp_parse_set_created   = false;
	private int     exp_parse_set_sub  = 0;
	private int     exp_parse_set_name_index = 0;
	private byte    exp_sublst_op = 0;
	private char    exp_substring_op = ','; // calc substring '...'(e1,e2)
	private char    exp_subscript_op = ')'; // calc var subscript value &var(subscript)
	private int     exp_start_index = 0; // index to start of exp text
	private int     exp_next_index = 0; // index to next op
	private byte    exp_type = 0;       // requested type
	private int     exp_seta = 0;       // result of calc_seta_exp
	private byte    exp_setb = 0;       // result of calc_setb_exp
	private String  exp_setc = "";      // result of calc_setc_exp
	private byte    exp_set_compare = 0; // aif compare result
	private int    seta_value1 = 0;
	private int    seta_value2 = 0;
	private byte   setb_value1 = 0;
	private byte   setb_value2 = 0;
	private String setc_value1 = "";
	private String setc_value2 = "";
	private byte   val_type  = 0;
	private byte   val_type1 = 0;
	private byte   val_type2 = 0;
	private String  exp_token = null;
	private String  exp_prev_op = "" + exp_start_op;
	private boolean exp_prev_substring = false;
	private char    exp_prev_first = exp_start_op;
	private byte    exp_prev_class = 0;
	private char    exp_next_first = asc_space_char;
	private byte    exp_next_class = 0;
//	private int     exp_var_index = -1;  // lcl set index // JBA-unused
	private boolean exp_var_pushed = false;  // var pushed since last reset
	private boolean exp_var_last = false;
	private int tot_exp_stk_var = 0;
	private int tot_exp_stk_op  = 0;

	// Set or sdt variable stack
	private byte[]    exp_stk_val_type = (byte[])Array.newInstance(byte.class,max_exp_stk);
	private int[]     exp_stk_seta     = (int[])Array.newInstance(int.class,max_exp_stk);
	private byte[]    exp_stk_setb     = (byte[])Array.newInstance(byte.class,max_exp_stk);
	private String[]  exp_stk_setc     = new String[max_exp_stk];
	private byte[]    exp_stk_var_type = (byte[])Array.newInstance(byte.class,max_exp_stk);     // RPI-447
	private byte[]    exp_stk_var_loc  = (byte[])Array.newInstance(byte.class,max_exp_stk);     // RPI-447
	private int[]     exp_stk_var_name_index = (int[])Array.newInstance(int.class,max_exp_stk); // RPI-447

	// operator stack
	private String    exp_next_op       = null;
	private boolean   exp_check_prev_op = false;
	private String[]  exp_stk_op        = new String[max_exp_stk];
	private byte[]    exp_stk_op_class  = (byte[])Array.newInstance(byte.class,max_exp_stk);

	// operator classes
//	private enum exp_classes {  };
	private final static byte exp_class_add_sub =  1;
	private final static byte exp_class_mpy_div =  2;
	private final static byte exp_class_open    =  3;
	private final static byte exp_class_cls_sub =  4;
	private final static byte exp_class_str_op  =  5; // 2 operand string ops (".", FIND, INDEX etc.)
	private final static byte exp_class_term    =  6;
	private final static byte exp_class_comp    =  7;
	private final static byte exp_class_str_sub1=  8;
	private final static byte exp_class_str_sub2=  9;
	private final static byte exp_class_oper    = 10; // prefix operators (?',?2?, DOUBLE, LOWER, UPPER, etc.)
	private final static byte exp_class_not     = 11;
	private final static byte exp_class_and     = 12;
	private final static byte exp_class_or      = 13;
	private final static byte exp_class_xor     = 14;
	private final static byte exp_class_create_set = 15;
	/*
	 * Define exp actions based on last and next operator class
	 *     1   2  3  4  5  6  7  8  9 10 11 12 13 14 15
	 *     +-  *  /  (  )  .  ~ EQ  '  , ?'NOT AND OR XOR &( col = next_op                                                  row = prev_op
	 */
	private final static int tot_classes = 15;
	private final static int[] exp_action = {
		1, 3, 3, 1, 0, 1, 1, 8, 1, 3, 1, 1, 1, 1, 3, // 1 +-  prev add/sub
		2, 2, 3, 2, 0, 2, 2, 8, 2, 3, 2, 2, 2, 2, 3, // 2 * / prev mpy/div  RPI-214
		3, 3, 3, 4, 3, 0, 3, 3, 3, 3, 3, 3, 3, 3, 3, // 3 (   prev open (...) RPI-274, RPI-647
		3, 3, 3,11, 3, 3, 3, 8,11, 3, 3, 3, 3, 3, 3, // 4 )   prev var subscript RPI-559
		0, 0, 3, 5, 5, 5, 5, 8, 0, 3, 0, 0, 0, 0, 3, // 5 .   prev concat
		3, 3, 3, 6, 3, 6, 3, 8, 3, 3, 3, 3, 3, 3, 3, // 6 ~   prev terminator
		3, 3, 3, 7, 3, 7, 7, 8, 0, 3, 7, 7, 7, 7, 3, // 7 LL  logical compares // RPI-144 (was 1,2 now 3,3)
		3, 3, 3, 0, 0, 0, 0, 8, 0, 3, 0, 0, 0, 0, 3, // 8 '   string '....'
		3, 3, 3,10, 0, 0, 0, 0, 9, 3, 0, 0, 0, 0, 3, // 9 ,   substring '...'(e1,e2)
		12,12, 3,12,12,12,12,3,12,03,12,12,12,12, 3, //10 ?'  prefix operator  // RPI-145, RPI-196, RPI-353 RPI-938 O3 FOR DOUBLE ?' etc
		3, 3, 3,13, 3, 0, 3, 3, 0, 3,13,13,13,13, 3, //11 NOT logical
		3, 3, 3,14, 3, 0, 3, 3, 0, 3, 3,14,14,14, 3, //11 AND logical
		3, 3, 3,15, 3, 0, 3, 3, 0, 3, 3, 3,15,15, 3, //11 OR  logical
		3, 3, 3,16, 3, 0, 3, 3, 0, 3, 3, 3, 3,16, 3, //11 XOR logical
		0, 0, 0,17, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3  //10 ?'  prefix operator
	};

	/* Action code routines:
	 *   0 error
	 *   1 add/sub
	 *   2 mpy/div
	 *   3 push op
	 *   4 POP  op
	 *   5 string operation (concat,index,find)
	 *   6 exit with result of expression
	 *   7 compare operands (EQ,GE,GT,LE,LT,NE)
	 *   8 switch substring mode '&v(&s)..'(&s1,&s2) on/off
	 *   9 process 1st substring subscript
	 *  10 process 2nd substring subscript
	 *  11 process variable subscript or sublist
	 *  12 process prefix operator K', N' DOUBLE, etc
	 *  13 logical NOT
	 *  14 logical AND
	 *  15 logical OR
	 *  16 logical XOR
	 *  17 process created set symbol &(...)
	 */
	/*
	 * Pseudo Code for calc_exp
	 * Notes:
	 *   1.  init_pc() initializes arrays and lists
	 *   2.  get_pc()  alloc next pc_op entry
	 */
	/*
	 * Least recently used list of allocated pc_op entries
	 */
	private int       pcl_mru      = 0;     // ptr to most recently used mac line
	private int[]     pcl_mru_next = null;  // next   most recently used mac line
	private int[]     pcl_mru_prev = null;  // prev   most recently used mac_line
	private int       pcl_lru      = 0;     // ptr to last entry in mru list = least recently used
	/*
	 * allocated pc entry lists for mac lines
	 */
	private int[]     pcl_start    = null;  // first pc for bal line pc else 0
	private int[]     pcl_end      = null;  // last  pc for bal line

	// Pseudo code operation entries on free or allocated list with pointer from pcl_start[mac_line_index]
	// Note: pc_next = 0 indicates end of list
	private int       tot_pc_gen      = 0;    // total pc entries allocated
	private int       tot_pc_exec     = 0;    // total pc entries execute
	private int       tot_pc_gen_opt  = 0;    // total pc gen optimizations
	private int       tot_pc_exec_opt = 0;    // total pc exec optimizations
	private int       tot_pcl_exec    = 0;    // total pc lists executed
	private int       tot_pcl_gen     = 0;    // total pc lists allocated (1 per line)
	private int       tot_pcl_reuse   = 0;    // total pc lists reused due to cache overflow
	private int       pc_loc          = 0;     // current pc entry to execute
//	private int       pc_loc_prev     = 0;     // prev pc_loc in list else 0 set by get_pc, exec_pc // JBA-unused
//	private int       pc_loc_next     = 0;     // next pc_loc in list else 0 set by opt_lst // JBA-unused
	private int       pc_free         = 0;     // ptr to free pc enty and next list
	private byte      pc_parm_type    = 0;
	private byte[]    pc_op           = null;  // pseudo code operation
	private byte[]    pc_var_type     = null;  // pseudo code var type
	private byte[]    pc_var_loc      = null;  // pseudo code var loc
	private int[]     pc_sysndx       = null;  // pseudo code macro instance id
	private int[]     pc_seta         = null;  // pseudo code seta/setb sdt value or var name index
	private String[]  pc_setc         = null;  // pseudo code setc      sdt value
	private int[]     pc_next         = null;  // next pc entry in free or alloc list
	private boolean[] pc_req_opt      = null;  // pc optimization request
	private boolean pc_aborted = false;    // prevent abort_pc recursion in trace
	private boolean pc_gen_exp = false;    // calc_exp flag to generate pseudo code
	private boolean pc_pushc_pending = false;
	private boolean pc_concat_pending = false;
	private byte    pc_push_var_op = 0;
	private String  pc_push_var_setc_value = null;
	private String  pc_sublst_value1 = null;
	private String  pc_concat_setc_value1 = null;
	private String  pc_concat_setc_value = null;
	private String  pc_pushc_setc_value = null;
	private boolean pc_pusha_pending = false;
	private int     pc_pusha_seta_value = 0;
	private String  pc_pusha_setc_value = null;
	private final static byte pc_op_ago    =  1; // branch based on stack index value
	private final static byte pc_op_aif    =  2; // branch if stack value not 0
	private final static byte pc_op_pushv  =  3; // push var on stac
	private final static byte pc_op_pushvs =  4; // push var(sub) ons tack replacing subcript
	private final static byte pc_op_pusha  =  5; // push seta self defining term
	private final static byte pc_op_pushc  =  6; // push setc string constant
	private final static byte pc_op_concat =  7; // concatentate setc constant or 2 stack values
	private final static byte pc_op_storv  =  8; // store scalar set var
	private final static byte pc_op_storvs =  9; // store subscripted set var
	private final static byte pc_op_storvn = 10; // store next multiple value in var
	private final static byte pc_op_add    = 11; // add 2 entries on stack leaving 1
	private final static byte pc_op_sub    = 12; // sub 2 entries on stack leaving 1
	private final static byte pc_op_mpy    = 13; // mpy 2 entries on stack leaving 1
	private final static byte pc_op_div    = 14; // div 2 entries on stack leaving 1
	private final static byte pc_op_compeq = 15; // compare equal
	private final static byte pc_op_compge = 16; // compare greater than or equal
	private final static byte pc_op_compgt = 17; // compare greater than
	private final static byte pc_op_comple = 18; // compare greater less than or equal
	private final static byte pc_op_complt = 19; // compare equal
	private final static byte pc_op_compne = 20; // compare greater than or equal
	private final static byte pc_op_ucomp  = 21; // unary compliment value on stack
	private final static byte pc_op_dup    = 22; // duplicate string
	private final static byte pc_op_sublst = 23; // calculate setc sublist
	private final static byte pc_op_substr = 24; // calculate setc substring
	private final static byte pc_op_inc    = 25; // inc var/varsub
	private final static byte pc_op_dec    = 26; // dec var/varsub
	private final static byte pc_op_pushd  = 27; // push scalar dynamic var using name on stack
	private final static byte pc_op_pushds = 28; // push subscripted dynamic var using name and subscript on stack
	private final static byte pc_op_stord  = 29; // store scalar dynamic var using name on stack
	private final static byte pc_op_stords = 30; // store subscripted dynamic var using name and subscript on stack
	private final static byte pc_op_pfx_a  = 31; // A' lookahead defined symbol
	private final static byte pc_op_pfx_d  = 32; // D' ordinary defined symbol
	private final static byte pc_op_pfx_i  = 33; // I' integer count
	private final static byte pc_op_pfx_k  = 34; // K' character count
	private final static byte pc_op_pfx_l  = 35; // L' ordinary symbol length
	private final static byte pc_op_pfx_n  = 36; // N' number of sublist operands
	private final static byte pc_op_pfx_o  = 37; // O' operator
	private final static byte pc_op_pfx_s  = 38; // S' scale factor
	private final static byte pc_op_pfx_t  = 39; // T' symbol type
	private final static byte pc_op_pushs  = 40; // push symbol value abs value if found else 0
	private final static byte pc_op_stori  = 41; // inc store index by seta
	private final static byte pc_op_a2b    = 45; // convert value to binary string (3 = '11')
	private final static byte pc_op_a2c    = 46; // convert value to character string (240 = '1')
	private final static byte pc_op_a2d    = 47; //  convert value to decimal string (1 = '1')
	private final static byte pc_op_a2x    = 48; // convert value to hex string (240 = 'F0')
	private final static byte pc_op_and    = 49; // logical and (NC)
	private final static byte pc_op_b2a    = 50; // convert binary string to value (B2A('100') = 4)
	private final static byte pc_op_b2c    = 51; // convert binary string to character string ('11110000' = '1')
	private final static byte pc_op_b2d    = 52; //  convert binary string to decimal string ('100'  = '4')
	private final static byte pc_op_b2x    = 53; // convert binary string to hex string ('11110000' = 'F0')
	private final static byte pc_op_c2a    = 54; // convert characters to value (C2A('0') = 240)
	private final static byte pc_op_c2b    = 55; // convert character string to binary string ('1' = '11110000')
	private final static byte pc_op_c2d    = 56; //  convert character string to decimal string ('1'  = '240')
	private final static byte pc_op_c2x    = 57; // convert character string to hex string ('1' = 'F0')
	private final static byte pc_op_d2a    =  58; // convert decimal string to value (D2A('= 45; //2') = = 45; //2
	private final static byte pc_op_d2b    =  59; // convert decimal string to binary string ('4' = '100')
	private final static byte pc_op_d2c    = 60; //  convert decimal string to character string('240'  = '1')
	private final static byte pc_op_d2x    = 61; // convert decimal string to hex string ('240' = 'F0')
	private final static byte pc_op_dclen  = 62; // length of string after reducing double ' and &
	private final static byte pc_op_dcval  = 63; // return string with double ' and & reduced
	private final static byte pc_op_dequote = 64; // return string without first and last ' if any // RPI-886
	private final static byte pc_op_double = 65; // double quotes and & in string (NC)
	private final static byte pc_op_find   = 66; // return index of any char in string2 found in string1 (NC)
	private final static byte pc_op_index  = 67; // return index of string2 found in string1 else 0 (NC)
	private final static byte pc_op_isbin  = 68; // return 1 if valid binary string else 0
	private final static byte pc_op_isdec  = 69; // return 1 if valid decimal string else 0
	private final static byte pc_op_ishex  = 70; // return 1 if valid hex string else 0
	private final static byte pc_op_issym  = 71; // return 1 if valid character string for symbol else 0
	private final static byte pc_op_lower  = 72; // return lower case string (NC)
	private final static byte pc_op_not    = 73; // logical or arithmetic not (NC)
	private final static byte pc_op_or     = 74; // logical or (NC)
	private final static byte pc_op_upper  = 75; // return upper case string (NC)
	private final static byte pc_op_signed = 76; // return decimal string with minus sign if negative
	private final static byte pc_op_sla    = 77; // shift left arithmetic (2 SLA 1 = 4)
	private final static byte pc_op_sll    = 78; // shift left logical (2 SLL 1 = 4)
	private final static byte pc_op_sra    = 79; // shift right arithmetic (4 SRA 1 = 2)
	private final static byte pc_op_srl    = 80; // shift right logical (4 SRL 1 = 2)
	private final static byte pc_op_sattra = 81; // return assembler attribute for symbol (EQU 4th)
	private final static byte pc_op_sattrp = 82; // return program attribute for symbol (EQU 5th)
	private final static byte pc_op_x2a    = 83; // convert hex string to value (X2A('F0') = 240)
	private final static byte pc_op_x2b    = 84; // convert hex string to binary string ('F0' = '11110000')
	private final static byte pc_op_x2c    = 85; //  convert hex string to character string('F0'  = '1')
	private final static byte pc_op_x2d    = 86; // convert hex string to decimal string ('F0' = '240')
	private final static byte pc_op_xor    = 87; // logical exclusive or (NC)
//	private final static byte pc_op_gbl    = 88; // gbla,gblb,gblc declaration // JBA-unused
	private final static String[] pc_op_desc = {
			"?",       // 0 not used
			"AGO",     // 1 pc_op_ago
			"AIF",     // 2 pc_op_aif
			"PUSHV",   // 3 pc_op_pushv
			"PUSHVS",  // 4 pc_op_pushvs
			"PUSHA",   // 5 pc_op_pusha
			"PUSHC",   // 6 pc_op_pushc
			"CONCAT",  // 7 pc_op_concat
			"STORV",   // 8 pc_op_storv
			"STORVS",  // 9 pc_op_storvs
			"STORVN",  //10 pc_op_storvn
			"ADD",     //11 pc_op_add
			"SUB",     //12 pc_op_sub
			"MPY",     //13 pc_op_mpy
			"DIV",     //14 pc_op_div
			"COMPEQ",  //15 pc_op_compeq
			"COMPGE",  //16 pc_op_compge
			"COMPGT",  //17 pc_op_compgt
			"COMPLE",  //18 pc_op_comple
			"COMPLT",  //19 pc_op_complt
			"COMPNE",  //20 pc_op_compne
			"UCOMP",   //21 pc_op_ucomp
			"DUP",     //22 pc_op_dup
			"SUBLST",  //23 pc_op_sublst
			"SUBSTR",  //24 pc_op_substr
			"INC",     //25 pc_op_inc
			"DEC",     //26 pc_op_dec
			"PUSHD",   //27 pc_op_pushd
			"PUSHDS",  //28 pc_op_pushds
			"STORD",   //29 pc_op_stord
			"STORDS",  //30 pc_op_stords
			"A'",      //31 pc_op_pfx_a
			"D'",      //32 pc_op_pfx_d
			"I'",      //33 pc_op_pfx_i
			"K'",      //34 pc_op_pfx_k
			"L'",      //35 pc_op_pfx_l
			"N'",      //36 pc_op_pfx_n
			"O'",      //37 pc_op_pfx_o
			"S'",      //38 pc_op_pfx_s
			"T'",      //39 pc_op_pfx_t
			"PUSHS",   //40 pc_op_pushs
			"STORI",   //41 pc_op_stori
			"?",       //42
			"?",       //43
			"?",       //44
			"A2B",     //45 PC_OP_a2b
			"A2C",     //46 pc_op_a2c
			"A2D",     //47 pc_op_a2d
			"A2X",     //48 pc_op_a2x
			"AND",     //49 pc_op_and
			"B2A",     //50 pc_op_b2a
			"B2C",     //51 pc_op_b2c   +
			"B2D",     //52 pc_op_b2d
			"B2X",     //53 pc_op_b2x
			"C2A",     //54 pc_op_c2x
			"C2B",     //55 pc_op_c2b
			"C2D",     //56 pc_op_c2d
			"C2X",     //57 pc_op_c2x
			"D2A",     //58 pc_op_d2a
			"D2B",     //59 pc_op_d2b
			"D2C",     //60 pc_op_d2c
			"D2X",     //61 pc_op_d2x
			"DCLEN",   //62 pc_op_dclen
			"DCVAL",   //63 pc_op_dcval
			"DEQUOTE",  //64 pc_opDEQUOTEte // RPI-886
			"DOUBLE",  //65 pc_op_double
			"FIND",    //66 pc_op_find
			"INDEX",   //67 pc_op_index
			"ISBIN",   //68 pc_op_isbin
			"ISDEC",   //69 pc_op_isdec
			"ISHEX",   //70 pc_op_ishex
			"ISSYM",   //71 pc_op_issym
			"LOWER",   //72 pc_op_lower
			"NOT",     //73 pc_op_not
			"OR",      //74 pc_op_or
			"UPPER",   //75 pc_op_upper
			"SIGNED",  //76 pc_op_signed
			"SLA",     //77 pc_op_sla
			"SLL",     //78 pc_op_sll
			"SRA",     //79 pc_op_sra
			"SRL",     //80 pc_op_srl
			"SATTRA",  //81 pc_op_sattra
			"SATTRP",  //82 pc_op_sattrp
			"X2A",     //83 pc_op_x2a
			"X2B",     //84 pc_op_x2b
			"X2C",     //85 pc_op_x2c
			"X2D",     //86 pc_op_x2d
			"XOR",     //87 pc_op_xor
	};
	private int[]   pc_loc_list = new int[10];
	private byte[]  pcl_inc_list = { pc_op_pushv, pc_op_add, pc_op_storv};
	private byte[]  pcl_dec_list = { pc_op_pushv, pc_op_sub, pc_op_storv};
	private boolean pc_trace_gen = false;
//	private String  pc_trace_sub  = null;

	/**
	 * This main function is the entry point when executed from command line.
	 *
	 * @param args - Command line arguments
	 */
	public static void main(final String[] args)
	{
		// Create local instance of mz390 class.
		final mz390 pgm = new mz390();
		// Pass parameters to mz390 like z390 does.
		pgm.process_mz390(args,null);
	}

	/**
	 * Expand macro MLC source file to BAL source file.<br>
	 * This procedure may be called<br>
	 *  - directly from z390 GUI or<br>
	 *  - from main when mz370 run from windows command line.
	 *
	 * @param args - Command line arguments
	 * @param log_text - null, if called from main (to log to console)
	 */
	public void process_mz390(final String[] args, final JTextArea log_text)
	{
		// The local procedure put_log will route output to console if log_text is null.
		// Otherwise the output will be sent to the z390 log window (given JTextArea).
		z390_log_text = log_text;
		init_mz390(args, log_text);
		if (tz390.opt_trap) { // RPI-1058 move mlc loading under trap handler
			try {
				process_mac();
			} catch (final Exception e) {
				abort_error(84,"Internal system exception - " + e.toString());
			}
		} else {
			process_mac();
		}
		exit_mz390();
	}

	/**
	 * Initialize mz390...
	 * 1.  initialize log routing
	 * 2.  set options
	 * 3.  open MLC and BAL buffered I/O files
	 *
	 * @param args
	 * @param log_text
	 */
	private void init_mz390(final String[] args, final JTextArea log_text)
	{
		// Check and complain about wrong Java version...
		final InfoOS infoOS = InfoOS.getInstance();
		if (!infoOS.isCorrectJava()) {
			abort_error(205, infoOS.getMessageIncorrectJavaVersion());
		}

		tz390 = new tz390();
		tz390.init_tz390();  // RPI-1080
		tz390.init_options(args,tz390.mlc_type);
		tz390.open_systerm("MZ390");
		tz390.init_codepage(tz390.codepage); // RPI-1069
		if (tz390.opt_timing) {
			cur_date = new Date();
		} else {
			final GregorianCalendar cur_date_cal = new GregorianCalendar(2005,0,2,22,33,44);
			cur_date = new Date(cur_date_cal.getTime().getTime()+567);
		}
		tod_start = cur_date.getTime();
		open_files();
		if (!tz390.init_opcode_name_keys()) {
			abort_error(118, "Opcode key table error - aborting");
		}
		if (tz390.opt_asm) {
			az390 = new az390(); // RPI-415
			az390.mz390_started_msg = tz390.started_msg; // RPI-755
			az390.start_az390_thread(args, z390_log_text, tz390.systerm_file, tz390.stats_file); // RPI-737
		}
		compile_patterns();
		tod_time_limit = tz390.max_time_seconds * 1000 + tod_start;
		put_copyright();
		init_pc_arrays();
		init_arrays();
		mac_name[0] = "OPEN CODE"; // for trace
		init_gbl_sys();
		if (tz390.opt_zstrmac) {
			add_zstrmac_key("ACALL",  zsm_type_acall  );
			add_zstrmac_key("ACASE",  zsm_type_acase  );
			add_zstrmac_key("AELSE",  zsm_type_aelse  );
			add_zstrmac_key("AELSEIF",zsm_type_aelseif);
			add_zstrmac_key("AEND",   zsm_type_aend   );
			add_zstrmac_key("AENTRY", zsm_type_aentry );
			add_zstrmac_key("AEXIT",  zsm_type_aexit  );
			add_zstrmac_key("AIF",    zsm_type_aif    );
			add_zstrmac_key("AUNTIL", zsm_type_auntil );
			add_zstrmac_key("AWHEN",  zsm_type_awhen  );
			add_zstrmac_key("AWHILE", zsm_type_awhile );
		}
	}

	/**
	 * Add hash indexed keys for ZSTRMAC opcodes.
	 *
	 * @param opcode
	 * @param index
	 */
	private void add_zstrmac_key(final String opcode, final byte index)
	{
		if (tz390.find_key_index('Z',opcode) == -1) {
			if(!tz390.add_key_index(index)) {
				abort_error(239, "ZSTRMAC error adding opcode key " + opcode);
			}
		}
	}

	/**
	 * Initialize regular expression patterns and issue error if failure.
	 */
	private void compile_patterns()
	{
		// var_pattern used for finding and replacing scalar, subscripted, and created &variables
		try {
			var_pattern = Pattern.compile(
					  "([&][&])"							// RPI-192
					+ "|([']['])"							// RPI-192
					+ "|([&][\\(])"
					+ "|([&][a-zA-Z$@#_][a-zA-Z0-9$@#_]*)"	// RPI-253
					+ "|([&])"								// RPI-192
			);
		} catch (final Exception e) {
			abort_error(1, "Var pattern errror - " + e.toString());
		}
		/*
		 * proto_pattern is any one of 6 choices:
		 *   1.  &vvv=  var followed by = for detecting key vs pos
		 *   2.  C'xxx' spaces and '' ok in xxx
		 *   3.  'xxx' spaces and '' ok in xxx
		 *   4.  xxx    no spaces or commas in xxx ('s ok)
		 *   5.  ,      return commas for detecting null pos
		 *   6.  space  return space for detecting  comments
		 *   7.  return ( and ) to parse kw parm value (a,b)  RPI-223
		 * */
		try {
			proto_pattern = Pattern.compile(
					"([&][&])"
					+ "|([&][(])"
					+ "|([&][a-zA-Z$@#_][a-zA-Z0-9$@#_]*[=]*)" // &var or &var= for keyword  RPI-253
					+ "|([0-9]+)"                        // number
					+ "|([']([^']|(['][']))*['])"        // parm in quotes
					+ "|([\\s/()',\\.\\+\\-\\*=])"       // operators and white space RPI-181 (\\ for reg exp. opers)
					+ "|([dD]['])"                       // D' defined symbol test 0 or 1  RPI-336
					+ "|([iIkKlLnNoOsStT]['])"           // ?' prefix operators  RPI-481
					+ "|([bB]['][0|1]+['])"              // B'0110' binary self def. term
					+ "|([cC][aAeE]*[']([^']|(['][']))+['])"    // C'ABCD' EBCDIC or ASCII self def. term // RPI-270, RPI-274
					+ "|([cC][\"]([^\"]|([\"][\"]))+[\"])"    // C"ABCD" ASCII self def. term   RPI-73, RPI-274
					+ "|([cC][!]([^!]|([!][!]))+[!])"        // C"ABCD" EBCDIC self def. term  RPI-84, RPI-274
					+ "|([xX]['][0-9a-fA-F]+['])"        // X'0F'   hex self defining term
					+ "|([a-zA-Z$@#_][a-zA-Z0-9$@#_]*)"   // symbol or logical operator (AND, OR, XOR, NOT, GT, LT etc.) // RPI-253
			  		+ "|([^',()\\s]+)"   // RPI-223, RPI-250 // any other text
			);
		} catch (final Exception e) {
			abort_error(2, "Proto pattern error - " + e.toString());
		}
		/*
		 * exec_pattern same as proto_pattern plus ; for comments RPI-640
		 *   1.  &vvv=  var followed by = for detecting key vs pos
		 *   2.  C'xxx' spaces and '' ok in xxx
		 *   3.  'xxx' spaces and '' ok in xxx
		 *   4.  xxx    no spaces, commas, or periods in xxx ('s ok)
		 *   5.  ,      return commas for detecting null pos
		 *   6.  space  return space for detecting  comments
		 *   7.  return ( and ) to parse kw parm value (a,b)  RPI-223
		 * */
		try {
			exec_pattern = Pattern.compile(
					"([&][&])"
					+ "|([&][(])"
					+ "|([&][a-zA-Z$@#_][a-zA-Z0-9$@#_]*[=]*)" // &var or &var= for keyword  RPI-253
					+ "|([0-9]+)"                        // number
					+ "|([']([^']|(['][']))*['])"        // parm in quotes
					+ "|([\\s/()',\\.\\+\\-\\*=;])"       // operators and white space RPI-181 (\\ for reg exp. opers) add ";" RPI-640
					+ "|([dD]['])"                       // D' defined symbol test 0 or 1  RPI-336
					+ "|([iIkKlLnNoOsStT]['])"           // ?' prefix operators  RPI-481
					+ "|([bB]['][0|1]+['])"              // B'0110' binary self def. term
					+ "|([cC][aAeE]*[']([^']|(['][']))+['])"    // C'ABCD' EBCDIC or ASCII self def. term // RPI-270, 274
					+ "|([cC][\"]([^\"]|([\"][\"]))+[\"])"    // C"ABCD" ASCII self def. term   RPI-73, RPI-274
					+ "|([cC][!]([^!]|([!][!]))+[!])"        // C"ABCD" EBCDIC self def. term  RPI-84, RPI-274
					+ "|([xX]['][0-9a-fA-F]+['])"        // X'0F'   hex self defining term
					+ "|([a-zA-Z$@#_][a-zA-Z0-9$@#_]*)"   // symbol or logical operator (AND, OR, XOR, NOT, GT, LT etc.) // RPI-253
					+ "|([.]+)"   // RPI-223, RPI-250, RPI-805 // any other text
			);
		} catch (final Exception e) {
			abort_error(2, "Exec pattern error - " + e.toString());
		}
		// macro label_pattern  .lll
		try {
			label_pattern = Pattern.compile(
					"([.][a-zA-Z$@#_][a-zA-Z0-9$@#_]*)"  // RPI-253
			);
		} catch (final Exception e) {
			abort_error(3,"Label pattern error - " + e.toString());
		}
		// Assembler symbol_pattern A-Z09#$%_
		try {
			symbol_pattern = Pattern.compile(
					"([a-zA-Z$@#_][a-zA-Z0-9$@#_]*)"  // RPI-253
			);
		} catch (final Exception e) {
			abort_error(3,"Label pattern error - " + e.toString());
		}

		// pch_pattern for quoted string:
		//  1.  '...''...'
		try {
			pch_pattern = Pattern.compile(
					"([']['])"
					+ "|([&][&])" // RPI-195
					+ "|([^'&]+)"
					+ "|(['&])"
			);
		} catch (final Exception e) {
			abort_error(1,"Pch pattern error - " + e.toString());
		}
		/*
		 * macro set/aif expression pattern
		 *   1. &var   set variable
		 *   2. &(...) set created variable
		 *   3. ?'     prefix operators
		 *   4. b'...' c'...' or x'...' sdts
		 *   5. nnnn   integer
		 *   6. x      operator
		 *   7. symbols and char strings
		 */
		try {
			exp_pattern = Pattern.compile(
					  "([&][&(])"
					+ "|([&][a-zA-Z$@#_][a-zA-Z0-9$@#_]*)"    // &var  RPI-253
					+ "|([\\s&/()',\\.\\+\\-\\*=])"           // operators and white space RPI-181 (\\ for reg exp. opers)
					+ "|([0-9]+)"                             // number
					+ "|([dDiIkKlLnNoOsStT]['])"              // D' defined symbol test 0 or 1  RPI-336, RPI-434 RPI-481
					+ "|([bB]['][0|1]+['])"                   // B'0110' binary self def. term
					+ "|([cC][']([^']|(['][']))+['])"         // C'ABCD' EBCDIC or ASCII self def. term // RPI-270, RPI-274, RPI-1185
					+ "|([cC][aA][']([^']|(['][']))+['])"     // C'ABCD' EBCDIC or ASCII self def. term // RPI-270, RPI-274, RPI-1185
					+ "|([cC][eE][']([^']|(['][']))+['])"     // C'ABCD' EBCDIC or ASCII self def. term // RPI-270, RPI-274, RPI-1185
					+ "|([cC][\"]([^\"]|([\"][\"]))+[\"])"    // C"ABCD" ASCII self def. term   RPI-73, RPI-274
					+ "|([cC][!]([^!]|([!][!]))+[!])"         // C"ABCD" EBCDIC self def. term  RPI-84, RPI-274
					+ "|([xX]['][0-9a-fA-F]+['])"             // X'0F'   hex self defining term
					+ "|([a-zA-Z$@#_][a-zA-Z0-9$@#_]*)"       // symbol or logical operator (AND, OR, XOR, NOT, GT, LT etc.)
					+ "|([^'&]+)"  // RPI-268                 // string text
			);
		} catch (final Exception e) {
			abort_error(4, "Expression pattern error - " + e.toString());
		}
	}

	/**
	 * Set trace_file_name.<br>
	 * Open BAL file if option BAL.
	 */
	private void open_files()
	{
		if (tz390.trace_file_name == null) {  // RPI-719
			tz390.trace_file_name = tz390.dir_trc + tz390.pgm_name + tz390.trm_type;
		} else {
			tz390.trace_file_name = tz390.trace_file_name + tz390.trm_type;
		}
		if (!tz390.opt_bal) {
			return;
		}
		final String bal_file_name = tz390.get_file_name(tz390.dir_bal,tz390.pgm_name,tz390.bal_type); // RPI-866
		try {
			bal_file = new File(bal_file_name); // RPI-880 trap null error
			bal_file_buff = new BufferedWriter(new FileWriter(bal_file));
		} catch (final Exception e) {
			abort_error(8, "I/O error on BAL open - " + e.toString());
		}
	}

	/**
	 * Execute MLC as open code macro expanding any macros found and outputting all model
	 * statements to BAL file after substitution of any parameters and macro variables.
	 */
	private void process_mac()
	{
		load_type = load_mlc_file;
		load_file_name = tz390.dir_mlc + tz390.pgm_name + tz390.pgm_type;
		load_mac();
		mac_line_index = 0; // RPI-746
		mlc_line_end = tot_mac_line;
		init_lcl_sys();
		while (!mlc_eof && !tz390.z390_abort) {
			// Repeat executing nested macro code previously started by macro call.
			mac_abort = false;
			tot_mac_ins++;
			if  (mac_call_level == 0
				&& cur_ainsert > 0) {
				ainsert_source = true;
				insert_source_line();
			} else {
				ainsert_source = false;
			}
			if  (mac_line_index == mac_name_line_end[mac_call_name_index[mac_call_level]]) { // RPI-956
				if  (tz390.opt_listcall) {
					if (mac_call_level > 0) {
						String sysnest = "  " + mac_call_level;
						sysnest = sysnest.substring(sysnest.length() - 2);
						String mexit_line = "*MEXIT #=" + tz390.right_justify("" + mac_call_sysndx[mac_call_level],6)
										  + " LV=" + tz390.right_justify(sysnest,2) // RPI-891
										  + " " + mac_name[mac_call_name_index[mac_call_level]]; // RPI-772
						if (tz390.opt_traces && tz390.opt_mcall) { // RPI-890
							System.out.println(mexit_line); // RPI-890
						}
						put_bal_line(mexit_line);
					}
				}
				mac_call_level--;
				bal_line = null;
				if (mac_call_level >= 0) {
					mac_name_index = mac_call_name_index[mac_call_level];
					mac_line_index  = mac_call_return[mac_call_level];
					String sysm_sev = "00" + mac_call_sysm_sev[mac_call_level + 1]; // RPI-898
					gbl_setc[gbl_sysm_sev_index] = sysm_sev.substring(sysm_sev.length()-3); // RPI-898
					actr_count     = mac_call_actr[mac_call_level];
					tot_pos_parm = mac_call_pos_start[mac_call_level + 1];
					tot_kwd_parm = mac_call_kwd_start[mac_call_level + 1];
					tot_lcl_name  = mac_call_lcl_name_start[mac_call_level + 1];
					tot_lcl_seta  = mac_call_lcl_seta_start[mac_call_level + 1];
					tot_lcl_setb  = mac_call_lcl_setb_start[mac_call_level + 1];
					tot_lcl_setc  = mac_call_lcl_setc_start[mac_call_level + 1];
					tot_lcl_key_tab = mac_call_lcl_key_start[mac_call_level + 1];
					cur_lcl_key_root = mac_call_lcl_key_root[mac_call_level + 1];
				} else {
					set_mlc_eof(); // RPI-960
				}
			} else {
				if (tz390.opt_traces && mac_call_level == 0) {
					System.out.println("MZ390 OPEN CODE " + mac_file_line[mac_line_index]); // RPI-882
				}
				pc_loc = pcl_start[mac_line_index];
				if (pc_loc > 0) {
					exec_pc();
					bal_line = null;
				} else if (pc_loc < 0) {
					if (tz390.opt_tracem
						&& (tz390.opt_tracec // RPI-862 skip copy trace // RPI-862 Skip COPY trace
							|| mac_file_type[mac_file_num[mac_line_index]] != '=')) { // RPI-855
						trace_id = tz390.left_justify(mac_name[mac_call_name_index[mac_call_level]],9) + tz390.right_justify("" + mac_file_line_num[mac_line_index],6) + "        ";
						tz390.put_trace(trace_id + " " + mac_file_line[mac_line_index]);
					}
					// jump for ago, gbl?, etc.
					mac_line_index = - pc_loc;
					if (tz390.opt_tracem) { // RPI-899
						trace_break();
					}
					actr_count--; // RPI-754
					bal_line = null;
				} else {
					bal_line = mac_file_line[mac_line_index];
					bal_xref_index = mac_line_index;
					parse_bal_line();
					mac_op_type = find_opcode_type(bal_op);
					if (bal_label != null                // RPI-929
						&& bal_label.length() > 0        // RPI-929
						&& bal_label.charAt(0) == '*') {  // RPI-929
						find_mac_name_index = 0; // force comment for * in label field // RPI-929
					} else if (mac_op_type > tz390.max_asm_type) {  // RPI-274 -2 for OPSYN cancel
						exec_mac_op();      // execute macro operation
						bal_line = null;    // force macro execution cycle
					} else if (bal_op != null) {
						if (save_opsyn_index == -1
							|| tz390.opsyn_old_name[save_opsyn_index] == null
							|| !tz390.opt_asm
							|| tz390.find_key_index('O',bal_op) < 0
							) {
							find_mac_name_index = find_mac_entry(bal_op);
							if (find_mac_name_index == -2  // RPI-351
								&& save_opsyn_index >= 0
								&& tz390.opsyn_old_name[save_opsyn_index] == null) {
								find_mac_name_index = -1; // search again for opsyn cancel
							}
						} else {
							find_mac_name_index = -2; // RPI-331 don't search for opsyn rep.
						}
						if (find_mac_name_index == -1) { // RPI-891
							cur_mac_file_path = tz390.find_file_name(tz390.dir_mac,bal_op,tz390.mac_type,tz390.dir_cur);
							if (cur_mac_file_path != null) {
								put_listcall(); // RPI-746 RPI-891
							}
						} else if (find_mac_name_index >= 0) {
							put_listcall();
						}
						if (find_mac_name_index == -1) {
							load_mac_file();
						}
						if (find_mac_name_index >= 0) {
							call_mac();      // call a nested macro
							bal_line = null; // force macro execution cycle
						} else if (!tz390.opt_asm
								 	&&!tz390.opt_bal
								 	&& !bal_op.equals("END")) {
							log_error(225,"missing macro - " + bal_op);  // RPI-835
						}
					} else if (bal_line != null && bal_line.length() == 0) {
						bal_line = null; // RPI-498 ignore blank lines
					}
				}
				mac_line_index = mac_file_next_line[mac_line_index]; // RPI-956
			}
			if (bal_line != null) {
				if (bal_op != null && bal_op.equals("END")) {
					end_found = true;
				} else if (end_found
							&& bal_line.length() > 0
							&& bal_line.charAt(0) != '*') {
						abort_error(223,"Batch assemblies not supported"); // RPI-1062
				}
				put_bal_line(bal_line);
			}
			if (!mlc_eof && actr_count < 0) { // RPI-763
				log_error(82,"actr limit exceeded");  // RPI-754
				mac_line_index = mac_name_line_end[mac_call_name_index[mac_call_level]]; // RPI-754
			}
			if (tz390.opt_time
					&& (tot_mac_ins > next_time_check)) {
				next_time_check = tot_mac_ins + next_time_ins;
				cur_date = new Date();
				tod_end = cur_date.getTime();
				if (tod_end > tod_time_limit) {
					abort_error(86, "Time limit exceeded.");
				}
			}
		}
		if (tz390.opt_asm && !end_found) {
			create_mnote(4, "Missing END statement."); // RPI-1169
		}
	}

	/**
	 * Set mlc_eof and notify az390 to wrapup if running.
	 */
	private void set_mlc_eof()
	{
		mlc_eof = true;
		if (tz390.opt_asm) { // RPI-415
			az390.tz390.systerm_prefix = tz390.systerm_prefix;  // RPI-755
			az390.tz390.systerm_io = az390.tz390.systerm_io + tz390.systerm_io; // RPI-755
			if (az390.mz390_rc < mz390_rc) {
				az390.mz390_rc = mz390_rc;
			}
			call_az390_pass_bal_line(bal_line);
		}
	}

	/**
	 * 1. Load it if found
	 * 2. Add macro entry or dummy entry
	 */
	private void load_mac_file()
	{
		if (cur_mac_file_path != null) {
			load_type = load_mac_file;
			load_file_name = cur_mac_file_path;
			load_mac();
			find_mac_name_index = load_mac_name_index;
		} else { // add dummy mac to prevent search
			if (tz390.find_key_index('M',bal_op) == -1) {; // RPI-437
				if (!tz390.add_key_index(-2)) {
					abort_error(119, "Macro index table exceeded");
				}
			}
			find_mac_name_index = -2;
		}
	}

	/**
	 * Load macro from file or inline and set load_mac_name_index else abort with error.
	 */
	private void load_mac()
	{
		/*
		 * load type 0 = MLC file
		 *   no MACRO, no proto-type, end on END
		 *   parse EXEC statement with space delimited
		 *   parms and create exec macro parms
		 * load type 1 = MAC file
		 *   MACRO, MEND, and verify proto-type name = file name
		 * load type 2 = inline macro
		 *   MACRO, MEND, and proto-type defines macro name
		 *
		 * 1.  Return -2 if file not found
		 * 2.  Concatenate any continuations indicated by non-blank in position 72.  Each
		 *     continuation must start at position 16.
		 * 3.  Ignore .* macro comments
		 * 4.  Define any macro labels .xxx and check references.
		 * 5.  if continue char in 72, delimit at first ", " after 16.
		 * 6.  initial program MLC loads as 0 mac name entry
		 * 7.  Load inline macros without processing labels etc.
		 *     and includes are not expanded until inline load
		 * 8.  Insert MLC copy profile copybook if option PROFILE(copybook) specified.
		 * 9.  Expand the following structured macro code extensions if ZSTRMAC:
		 *     a.  AIF, AELSE, AELSEIF, AEND
		 *     b.  ACALL, AENTRY, AEXIT. AEND
		 *     c.  AWHILE, AUNTIL, AEXIT, AEND
		 *     d.  ACASE, AWHEN, AELSE, AEXIT, AEND
		 *
		 * Notes:
		 * At end of MLC load, turn off lookahead mode for ordinary symbols.
		 */
	//	loading_mac = true; // JBA-unused
		tot_mac_load++;
		zsm_lvl = 0;  // RPI-930 reset
		zsm_aentry_name_tot  = 1; // aentry names + 1
		cur_mac_file = 0;
		load_macro_mend_level = 0;
		load_proto_index = 0;
		load_macro_name = "";
		int save_mac_name_index = mac_name_index;
		int save_mac_line_index = mac_line_index;
		switch (load_type) {
		case 0: // MLC
			cur_mac_line_num = 0;
			load_open_macro_file();
			load_macro_mend_level = 1; // no macro statement
			mac_line_index = tot_mac_line;
			if (tz390.opt_profile.length() > 0) {
				mac_line = " COPY " + tz390.opt_profile;
				mac_file_line[mac_line_index] = mac_line;
				mac_line_index = mac_file_next_line[mac_line_index]; // RPI-956
				parse_mac_line();  // open copy
				if (tz390.opt_tracem) {
					tz390.put_trace("PROFILE " + mac_line);
				}
			}
			load_proto_type = true;
			break;
		case 1: // macro file
			cur_mac_line_num = 0;
			load_open_macro_file();
			load_macro_mend_level = 0; // read macro from file
			macro_op_found = false; // RPI-935 check for macro/mend in macro
			mac_line_index = tot_mac_line;
			load_proto_type = false;
			break;
		case 2: // macro inline
			put_bal_line(mac_file_line[mac_line_index]); // RPI-581
			mac_line_index = mac_file_next_line[mac_line_index]; // RPI-956
			cur_mac_line_num = mac_file_line_num[mac_line_index];
			if (tz390.opt_tracem) {
				tz390.put_trace("LOADING INLINE MACRO");
			}
			load_macro_mend_level = 1; // macro statement read inline
			load_mac_inline_end = mac_name_line_end[mac_name_index];
			load_proto_type = false;
			break;
		}
		mac_mend_eof = false; // RPI-740
		last_seq = null; // RPI-957
		load_get_mac_line();
		while (mac_line != null
				&& mac_line_index < tz390.opt_maxline) {
			if (tz390.opt_traceall) {
				tz390.put_trace("LOADING MAC LINE " + mac_line);
			}
			mac_abort = false;  // RPI-412
			parse_mac_line();
			if (load_type == load_mac_inline) {
				bal_xref_index = mac_line_index; // RPI-581
				put_bal_line(mac_line); // RPI-581
			} else if (mac_line.length() < 2 || !mac_line.substring(0,2).equals(".*")) {
				store_mac_line(); // RPI-273 update now for any cont. error
			}
			if (mac_op != null && mac_op.length() > 0) {
				if (mac_op.equals("MACRO")) {
					macro_op_found = true; // RPI-935
					load_macro_mend_level++;
				} else if (mac_op.equals("ICTL")) {
					set_ictl();  // RPI-728
				} else {
					if (load_macro_mend_level == 1) {
						if (!load_proto_type) {
							load_proto_type();
						} else {
							if (mac_op.equals("EXEC")) {
								load_macro_exec();
							}
							load_macro_ago_aif_refs();
							load_macro_label_sym();
						}
					} else if (load_macro_mend_level == 0) {
						log_error(148,"macro statement preceeding MACRO " + mac_line);
					}
					if (mac_op.equals("MEND")) {
						load_macro_mend_level--;
					}
					if (load_macro_mend_level == 0
						&& load_type != load_mlc_file) {
						if (tz390.opt_chkmac == 2
							&& tot_ainsert == 0 // RPI-1155
							&& load_type == load_mac_file) {  // RPI-747
							check_past_mend();  // RPI-740
						}
						mac_line = null; // eof at level 0 for macro
					}
				}
			}
			if (mac_line != null) {
				if (load_type == load_mac_inline
					|| !(mac_line.length() > 1 && (mac_line.substring(0,2).equals(".*")
							|| (mac_op != null
								&& mac_op.equals("ANOP")
								&& load_macro_mend_level == 1) ) ) ) {
					mac_line_index = mac_file_next_line[mac_line_index]; // RPI-956
				}
				load_get_mac_line();
			}
		}
		if (mac_line_index >= tz390.opt_maxline) {
			abort_error(87, "Maximum source lines exceeded. Maximum is " + tz390.opt_maxline + " lines.");
		}
		switch (load_type) {
		case 0: // MLC file
			if (tz390.opt_asm && az390.lookahead_mode) {
				az390.cur_esd = 0;
				az390.cur_esd_sid = -1;
				az390.lookahead_mode = false;
				az390.loc_ctr = 0; // RPI-632
				az390.loc_len = 0; // RPI-632
			}
			if (load_macro_mend_level != 1) {
				log_error(133,"Unbalanced macro mend in " + load_macro_name);
			}
			tot_mac_line = mac_line_index;
			mac_name_line_end[mac_name_index] = tot_mac_line;
			mac_line_index = save_mac_line_index;
			break;
		case 1: // macro file
			if (!macro_op_found   // RPI-935
				|| load_macro_mend_level != 0) {
				abort_error(134,"Unbalanced macro mend in " + load_macro_name);
			}
			tot_mac_line = mac_line_index;
			mac_name_line_end[mac_name_index] = tot_mac_line;
			mac_line_index = save_mac_line_index;
			break;
		case 2: // inline macro file
			if (load_macro_mend_level != 0) {
				log_error(135,"unbalanced macro mend in " + load_macro_name);
			}
			mac_name_line_end[mac_name_index] = mac_line_index;
		}
		mac_name_lab_end[mac_name_index] = tot_mac_lab;
		check_undefined_labs(mac_name_index);
		check_undefined_aentry(); // RPI-1078
		load_mac_name_index = mac_name_index;
		mac_name_index = save_mac_name_index;
	//	loading_mac = false; // JBA-unused
	}

	/**
	 * Issue error for any ACALL to undefined AENTRY routine.
	 */
	private void check_undefined_aentry()
	{
		int index = 1;
		while (index < zsm_aentry_name_tot) {
			if (!zsm_aentry_def[index]) {
				log_error(279, "Undefined AENTRY for ACALL - " + zsm_acall_name[index]);
			}
			index++;
		}
	}

	/**
	 * Scan for macro statement following final MEND ignoring comments.
	 */
	private void check_past_mend()
	{
		mac_line_index = mac_file_next_line[mac_line_index]; // RPI-956
		load_get_mac_line();
		while (mac_line != null && mac_line_index < tz390.opt_maxline) {
			if (mac_line.length() >= 2) {
				if (  !(mac_line.charAt(0) == '*')
					&& !mac_line.substring(0,2).equals(".*")) {
					create_mnote(4,"stmt after MEND in " + mac_name[mac_name_index] + " at line " + mac_file_line_num[mac_line_index] + " =\"" + mac_line + "\""); // RPI-907
					mac_line_index--; // backup to end
					if (load_type == load_mac_inline) {
						tot_mac_line = mac_line_index;
					}
					return; //skip rest after error
				}
			}
			load_get_mac_line();
		}
		mac_line_index--;  // backup to MEND/END
	}

	/**
	 * Set ICTL start, end, cont columns.
	 */
	private void set_ictl() // RPI-728
	{
		mac_ictl_start[cur_mac_file] = calc_seta_exp(mac_parms,0);
		if (!mac_abort
			&& mac_parms.length() > exp_next_index
			&& mac_parms.charAt(exp_next_index-1) == ',') {
			mac_ictl_end[cur_mac_file] = calc_seta_exp(mac_parms,exp_next_index);
			if (!mac_abort
				&& mac_parms.length() > exp_next_index
				&& mac_parms.charAt(exp_next_index-1) == ',') {
				mac_ictl_cont[cur_mac_file] = calc_seta_exp(mac_parms,exp_next_index);
			}
		}
		if (mac_ictl_start[cur_mac_file] < 1
			|| mac_ictl_start[cur_mac_file] > 40) {
			log_error(220, "Invalid ICTL start value - " + mac_ictl_start[cur_mac_file]);
			mac_ictl_start[cur_mac_file] = 1;
		}
		if (mac_ictl_end[cur_mac_file] < mac_ictl_start[cur_mac_file] + 5
			|| mac_ictl_start[cur_mac_file] > 80) {
			log_error(221, "Invalid ICTL end value - " + mac_ictl_end[cur_mac_file]);
			mac_ictl_end[cur_mac_file] = 71;
		}
		if (mac_ictl_cont[cur_mac_file] < 2
				|| mac_ictl_start[cur_mac_file] > 40) {
			log_error(222, "Invalid ICTL continue value - " + mac_ictl_cont[cur_mac_file]);
			mac_ictl_end[cur_mac_file] = 16;
		}
	}

	/**
	 * Open file for MLC or macro file else abort with error.
	 */
	private void load_open_macro_file()
	{
		mac_file[cur_mac_file] = new File(load_file_name);
		if (!mac_file[cur_mac_file].isFile()) {
			tz390.opt_asm = false; // RPI-720
			abort_error(39, "File not found - " + load_file_name); // RPI-169
		}
		load_macro_name = mac_file[cur_mac_file].getName(); // RPI-499 drop upper case
		if (tot_mac_name > 0) { // RPI-127 leave suffix on main pgm loaded as macro
			int index = load_macro_name.indexOf('.');
			if (index > 0) {
				load_macro_name = load_macro_name.substring(0,index);
			}
			if (tz390.opt_pdsmem8 // RPI-1160
				&& load_macro_name.length() > 8) {
				log_error(291, "MACRO MEMBER NAME > 8 - " + load_macro_name);
			}
		}
		add_mac(load_macro_name);
		try {
			cur_mac_file = 0;
			mac_file_buff[cur_mac_file] = new BufferedReader(new FileReader(mac_file[cur_mac_file]));
			set_mac_file_num();
		} catch (final Exception e) {
			abort_error(26, "I/O error opening file - " + e.toString());
		}
		if (tz390.opt_tracem) {
			tz390.put_trace("LOADING FILE " + load_file_name);
		}
		set_default_ictl();
	}

	/**
	 * Set default ICTL for macro/copy.
	 */
	private void set_default_ictl()
	{
		mac_ictl_start[cur_mac_file] =  1; // RPI-728
		mac_ictl_end[  cur_mac_file] = 71; // RPI-728
		mac_ictl_cont[ cur_mac_file] = 16; // RPI-728
	}

	/**
	 * Process proto-type during loading of MLC or macro.
	 */
	private void load_proto_type()
	{
		load_proto_type = true;
		load_proto_index = mac_line_index;
		mac_op = replace_vars(mac_op,false,false); // RPI-673
		if (load_type == load_mac_file) {
			mac_name_line_start[mac_name_index] = mac_line_index; // RPI-1
			if (!mac_op.equals(load_macro_name.toUpperCase())
				&& tz390.opt_chkmac > 0) { // RPI-519  RPI-747
				create_mnote(4, "MACRO PROTO-TYPE NAME DOES NOT MATCH FILE NAME " + load_macro_name); // RPI-740
			}
		} else {  // define inline macro
			load_macro_name = mac_op;
			load_proto_index = mac_line_index;
			mac_name_index = find_mac_entry(load_macro_name);
			if (mac_name_index < 0) {
				if (tot_mac_name < tz390.opt_maxsym) {
					mac_name_index = tot_mac_name;
					update_mac_key_index(mac_name_index,mac_op);
					tot_mac_name++;
				} else {
					abort_error(60, "Maximum macros exceeded for - " + mac_op);
					return;
				}
			}
			mac_name[           mac_name_index] = mac_op;
			mac_name_line_start[mac_name_index] = load_proto_index;
			mac_name_lab_start[ mac_name_index] = tot_mac_lab;
		}
	}

	/**
	 * Parse space delimited parameters for exec sql cics or dli and replace with comma
	 * delimited parameters for EXEC macro processing.
	 * Notes:
	 *   1.  Use the proto_pattern to handle all valid macro assembler parameter expressions
	 *       including quoted strings with spaces. RPI-640
	 */
	private void load_macro_exec()
	{
		exec_match = exec_pattern.matcher(mac_parms);
		String exec_parms = "";
		String exec_parm;
		char   exec_parm_char;
		boolean exec_eof = false;
		boolean exec_space = false;
		int     exec_parm_lvl = 0; // RPI-805
		while (!exec_eof
				&& exec_match.find()) {
			exec_parm = exec_match.group();
			exec_parm_char = exec_parm.charAt(0);
			if (exec_parm_char == '(') { // RPI-805
				exec_parm_lvl++;
			} else if (exec_parm_char == ')') {
				exec_parm_lvl--;
			}
			if (!exec_space) {
				if (exec_parm_char <= ' '
					|| exec_parm_char == ',') {  // RPI-860
					exec_space = true;
				} else {
					if (exec_parm_lvl > 0  // RPI-805
						|| (   exec_parm_char != ';'
						    && exec_parm_char != ','
						    && exec_parm_char != '.' )
						) {
						exec_parms = exec_parms.concat(exec_parm);
					} else {
						exec_eof = true;
					}
				}
			} else {
				if (exec_parm_char > ' ') {
					exec_space = false;
					if (exec_parm_lvl > 0    // RPI-805
						|| (   exec_parm_char != ';'
							&& exec_parm_char != ','
							&& exec_parm_char != '.' )
						) {
						if (exec_parm.charAt(0) == '(') { // RPI-905
							exec_parms = exec_parms.concat(exec_parm);
						} else {
							exec_parms = exec_parms.concat("," + exec_parm);
						}
					} else {
						exec_eof = true;
					}
				}
			}
		}
		mac_file_line[mac_line_index] = mac_label + " EXEC " + exec_parms; // RPI-905 add label if any
	}

	/**
	 * Check ago and aif references during loading.
	 */
	private void load_macro_ago_aif_refs()
	{
		int lab_index = 0;
		if (load_macro_mend_level == 1
			&& (   mac_op.equals("AGO")
				|| mac_op.equals("AGOB"))) {
			label_match = label_pattern.matcher(mac_parms);
			if (label_match.find()) {
				add_mac_label(mac_name_index
						,label_match.group().toUpperCase()
						,-mac_line_index);
				if (mac_parms.charAt(0) == '(') {
					boolean label_found = true;  // RPI-535
					while (label_found
							&& label_match.end() < mac_parms.length()
							&& mac_parms.charAt(label_match.end()) == ',') {
						lab_index = label_match.end()+1;
						if (label_match.find()) {
							add_mac_label(mac_name_index, label_match.group().toUpperCase(), -mac_line_index);
						} else {
							label_found = false; // RPI-535
							log_error(151," invalid AGO label - " + mac_parms.substring(lab_index));
						}
					}
				}
			} else {
				log_error(112,mac_name[mac_name_index] + " invalid AGO label - " + mac_parms);
			}
		} else if (load_macro_mend_level == 1
				&& (mac_op.equals("AIF") || mac_op.equals("AIFB"))) {
			int aif_test_index = 0;
			while (aif_test_index >= 0) {
				lab_index = mac_parms.substring(aif_test_index).indexOf(").");
				if (lab_index > 0) {
					label_match = label_pattern.matcher(mac_parms.substring(aif_test_index+lab_index+1));
					if (label_match.find()) {
						add_mac_label(mac_name_index, label_match.group().toUpperCase(), -mac_line_index);
						aif_test_index = aif_test_index + lab_index + label_match.end()+2;
						if (   mac_parms.length() <= aif_test_index
							|| mac_parms.charAt(aif_test_index-1) != ',') {
							aif_test_index = -1;
						}
					} else {
						log_error(113,mac_name[mac_name_index] + " invalid AIF label - " + mac_parms);
					}
				} else {
					if (aif_test_index == 0) {
						log_error(114,mac_name[mac_name_index] + " invalid AIF label - " + mac_parms);
					}
					aif_test_index = -1;
				}
			}
		}
	}

	/**
	 * During MLC or macro loading:
	 *   1.  Define macro labels .xxx
	 *   2.  If MLC lookahead, define ordinary symbol attribute and length if available using az390 DS, DC, and
	 *       EQU processing services.  Note call_az390 surpresses sending any BAL trace comments during lookahead.
	 *   3.  remove .* macro comments
	 */
	private void load_macro_label_sym()
	{
		if (mac_label.length() >= 1) {            // RPI-466
			if (mac_label.charAt(0) == '.'
				&& mac_label.length() > 1        // RPI-466
				&& mac_label.charAt(1) != '*') {
				label_match = label_pattern.matcher(mac_label);
				if (label_match.find()) {
					add_mac_label(mac_name_index, label_match.group().toUpperCase(), mac_line_index);
					mac_label = null;
				} else {
					log_error(40,"invalid macro label - " + mac_label);
				}
			} else if (tz390.opt_asm
					&& az390.lookahead_mode
					&& mac_label.charAt(0) != '*') {
				int index = mac_line.indexOf("&");
				if (index == -1) {
					set_lookahead_sym_attr_len();
				}
			}
		} else if (tz390.opt_asm
				   && az390.lookahead_mode
				   && (mac_op.equals("DS") || mac_op.equals("DC"))) {
			init_lookahead_az390();
			az390.process_dc(1);  // RPI-466
		}
	}

	/**
	 * If ASM, set symbol type and length during MLC macro loading in lookahead mode
	 */
	private void set_lookahead_sym_attr_len()
	{
		/*
		 * Notes:
		 *   1.  Called during macro load to define all ordinary symbols in open code allowing forward
		 *       reference to type and length if available during macro execution.  The sym_attr and
		 *       sym_len are stored in AZ390 symbol table with sym_def = -1 indicating lookahead mode definition.
		 *       Duplicates are ignored as there may be alternate macro paths.
		 *   2.  During macro execution, AZ390 recalculates all symbols for use during remained for macro expansion.
		 *
		 * Notes:
		 *   1.  sym_attr = 'U' and sym_len = 1 default at first create.
		 *   2.  sym_def = -1 for lookahead and 0 for forward ref during macro expansion.
		 *       AZ390 source line references start at 1 as of RPI-415.
		 *   3.  Note during macro execution, macro call label field symbol
		 *       will be changed to sym_attr 'M' if undefined or type 'U' and
		 *       will remain with sym_def = -1 to allow redefine as ordinary symbol via BAL expansion.
		 */
		if (!az390.az390_waiting) {
			abort_error(204, "az390 not in lookahead wait state");
		}
		final int index = tz390.find_key_index('R',mac_op.toUpperCase());
		if (index >= 0 && tz390.opsyn_old_name[index] != null) {
			mac_op = tz390.opsyn_old_name[index];
		}
		init_lookahead_az390();
		int op_index = tz390.find_key_index('O',mac_op);
		if (op_index != -1) {
			int op_type = OpTypes.op_type[op_index];
			if (op_type <= OpTypes.max_op_type_offset) {
				az390.update_label();
				az390.sym_attr[az390.cur_sid] = tz390.ascii_to_ebcdic['I'];
				az390.sym_len[az390.cur_sid] = OpTypes.op_type_len[op_type];
			} else if (mac_op.equals("CSECT")
					|| mac_op.equals("DSECT")
					|| mac_op.equals("LOCTR")
					|| mac_op.equals("RSECT")
					|| mac_op.equals("COM"  )) {
				az390.update_label();
				az390.sym_attr[az390.cur_sid] = tz390.ascii_to_ebcdic['J'];
				if (mac_op.equals("DSECT")) {
					az390.loc_ctr = 0;
					az390.sym_loc[az390.cur_sid] = az390.loc_ctr; // RPI-466
				}
				az390.sym_len[az390.cur_sid] = 1;
			} else if (mac_op.equals("DS")
					|| mac_op.equals("DC")) {
				az390.process_dc(1);
				az390.update_label();
			} else if (mac_op.equals("EQU")) {
				az390.process_equ();
			}
		}
	}

	/**
	 * Initialize for mz390 calls to EQU/DS/DC processing routines during lookahead.
	 */
	private void init_lookahead_az390()
	{
		az390.bal_abort = false;
		az390.bal_line  = mac_line;  // RPI-466
		az390.bal_label = mac_label;
		az390.bal_op    = mac_op;
		az390.bal_parms = mac_parms;
	}

	/**
	 * Add macro file entry and set mac_name_index else abort.
	 *
	 * @param macro_name
	 */
	private void add_mac(String macro_name)
	{
		if (tot_mac_name < tz390.opt_maxfile) { // RPI-284
			mac_name_index = tot_mac_name;
			if (tot_mac_name > 0) { // RPI-127 skip main pgm to allow macro later
				update_mac_key_index(mac_name_index,macro_name);
			} else {
				macro_name = "OPEN CODE";
			}
			tot_mac_name++;
			mac_name[mac_name_index] = macro_name.toUpperCase();
			mac_name_line_start[mac_name_index] = mac_line_index;
			mac_name_lab_start[mac_name_index]  = tot_mac_lab;
		} else {
			abort_error(27,"Max macros exceeded");
		}
	}

	/**
	 * Add or update macro key index.
	 *
	 * @param index
	 * @param name
	 */
	private void update_mac_key_index(final int index, final String name)
	{
		if (tz390.find_key_index('M',name) != -1) { // RPI-351
			tz390.update_key_index(index);
		} else {
			if (!tz390.add_key_index(index)) {
				abort_error(170, "Key search table exceeded adding " + name);
			}
		}
	}

	/**
	 * Find / Add file name and set cur_mac_file_num.
	 */
	private void set_mac_file_num()
	{
		final String mac_file_key = mac_file[cur_mac_file].getAbsolutePath();
		cur_mac_file_num = tz390.find_key_index('F',mac_file_key);
		if (cur_mac_file_num == -1) {
			if (tot_mac_file_name < tz390.opt_maxfile) {
				cur_mac_file_num = tot_mac_file_name;
				tot_mac_file_name++;
				if (!tz390.add_key_index(cur_mac_file_num)) {
					abort_error(172, "Key search table exceeded adding " + mac_file_key);
				}
				mac_file_path[cur_mac_file_num] = mac_file_key;
				final int index_sfx = mac_file_key.indexOf('.');
				if (   index_sfx > 0
					&& mac_file_key.substring(index_sfx).toUpperCase().equals(tz390.cpy_type)) {
					mac_file_type[cur_mac_file_num] = '='; // RPI-549
				} else {
					if (cur_mac_file_num > 0) {
						mac_file_type[cur_mac_file_num] = '+'; // RPI-549
					} else {
						mac_file_type[cur_mac_file_num] = ' '; // RPI-549
					}
				}
			}
		}
	}

	/**
	 * Add macro label and check for duplicates during macro loading.
	 * @param mac_index
	 * @param mac_label
	 * @param lab_line
	 */
	private void add_mac_label(final int mac_index, final String mac_label, final int lab_line)
	{
		int index = mac_name_lab_start[mac_index];
		while (index < tot_mac_lab) {
			if (mac_label.equals(mac_lab_name[index])) {
				if (mac_lab_index[index] <= 0) {
					// found forward ref - set lab line/num
					if (lab_line > 0) {
						mac_lab_index[index] = lab_line;
						mac_lab_num[index] = mac_file_line_num[lab_line];
					}
				} else if (lab_line > 0) {
					log_error(111,(mac_name[mac_index]) + " duplicate " + mac_label + " at " + mac_lab_num[index]);
				}
				return;
			}
			index++;
		}
		// add new unreferenced label
		if (tot_mac_lab < tz390.opt_maxsym) {
			label_name = label_match.group().toUpperCase();
			mac_lab_name[ tot_mac_lab] = label_name;
			mac_lab_index[tot_mac_lab] = lab_line;
			mac_lab_num[  tot_mac_lab] = mac_file_line_num[mac_line_index];
			tot_mac_lab++;
		} else {
			abort_error(110, mac_name[mac_index] + " maximum macro labels exceeded");
		}
	}

	/**
	 * Issue errors for any undefined macro labels.
	 *
	 * @param mac_index
	 */
	private void check_undefined_labs(final int mac_index)
	{
		int index = mac_name_lab_start[mac_index];
		while (index < mac_name_lab_end[mac_index]) {
			if (   mac_lab_index[index] <= 0
				&& tz390.opt_chkmac > 0) {  // RPI-747
				int old_mac_line_index = mac_line_index;
				mac_line_index = -mac_lab_index[index];
				create_mnote(4,"Macro " + mac_name[mac_index]
						+ " undefined " + mac_lab_name[index]
						+ " at "  + tz390.get_cur_bal_line_id(mac_file_num[mac_line_index],
															  mac_file_line_num[mac_line_index],
															  tz390.cur_bal_line_num,
															  mac_call_level > 0, // RPI-891 pass mac_gen vs open code flag
															  mac_file_type[mac_file_num[mac_line_index]])
				);
				mac_line_index = old_mac_line_index;
			}
			index++;
		}
	}

	/**
	 * Get next mac line from ainsert, file, or inline.
	 */
	private void load_get_mac_line()
	{
		// 1.  Concatenating continuation lines and parse mac line
		// 2.  Truncate continued lines at first ", "
		// 2.  Read nested copy files

		if (load_type == load_mac_inline) {
			if (   load_macro_mend_level > 0
				&& mac_line_index != load_mac_inline_end) { // RPI-956
				if (cur_ainsert > 0) {
					insert_source_line(); // RPI-956
				}
				mac_line = mac_file_line[mac_line_index];
			} else {
				mac_line = null;
			}
			return;
		}
		load_get_zstrmac_file_line();
	}

	/**
	 * Get next source line to load or insert from nested copy files.
	 */
	private void load_get_zstrmac_file_line()
	{
		if (tz390.opt_zstrmac) {
			if (zsm_line_index < zsm_line_tot) {
				mac_line = zsm_gen_line[zsm_line_index];
				zsm_line_index++;
				store_mac_line();
				return;
			}
			load_get_mac_file_line();
			if (    mac_line != null
				&&  mac_line.length() > 4
				&&  mac_line.charAt(0) != '*'
				&& !mac_line.substring(0,2).equals(".*")) {
				zsm_gen_lines();
			}
		} else {
			load_get_mac_file_line();
		}
	}

	/**
	 * Get next mac_line from file else set mac_line null.
	 */
	private void load_get_mac_file_line()
	{
		String temp_line = null;
		try {
			boolean retry = true;
			while (retry) {
				retry = false;
				tz390.systerm_io++;
				temp_line = mac_file_buff[cur_mac_file].readLine();
				if (temp_line != null && tz390.opt_chksrc >= 3) {
					temp_line = tz390.trim_trailing_spaces(temp_line,0); // RPI-1143
					if (temp_line.length() > 80) {
						log_error(274,"line exceeds 80 characters - " + temp_line); // R{O 957
					} else if (temp_line.length() > 72) {
						cur_seq = temp_line.substring(72);
						if (last_seq != null
							&& cur_seq.compareTo(last_seq) < 0) { // RPI-957
							log_error(275,"line sequence field not numeric - " + temp_line); // RPI-957
						}
						last_seq = cur_seq;
					}
				}
				if (!mac_mend_eof) {
					cur_mac_line_num++;
					store_mac_line(); // RPI-273 update now for any cont. error
				}
				if (temp_line == null) {
					mac_file_buff[cur_mac_file].close();
					cur_mac_file--;
					if (cur_mac_file >= 0) {
						if (tz390.opt_tracem
							&& (tz390.opt_tracec // RPI-862 skip copy trace // RPI-862 skip COPY trace
								|| mac_file_type[mac_file_num[mac_line_index]] != '=')
							) {
							tz390.put_trace("COPY ENDING FID=" + cur_mac_file_num + " LVL=" + (cur_mac_file+2) + " " + mac_file[cur_mac_file+1].getName());
						}
						if (dynamic_copy_file < cur_mac_file
							&& dynamic_mac_file < cur_mac_file) { // RPI-1019
							retry = true;  // exit ainsert mac/copy loops
						}
						cur_mac_file_num = mac_file_cur_file_num[cur_mac_file];
						cur_mac_line_num = mac_file_cur_line_num[cur_mac_file];
					}
				} else {
					temp_line = tz390.trim_trailing_spaces(temp_line,mac_ictl_end[cur_mac_file]+1);  // RPI-728 include cont col.
					if (tz390.opt_chksrc > 0) {  // RPI-747
						if 	((load_type == load_mlc_file
							 || tz390.opt_chksrc > 1) // RPI-957
						     && !tz390.verify_ascii_source(temp_line)) {
							log_error(138,"invalid ASCII source line " + cur_mac_line_num + " in " + mac_file[cur_mac_file].getAbsolutePath());
						}
					}
				}
			}
			if  (temp_line == null) {
				mac_line = null;
			} else if (temp_line.length() <= mac_ictl_end[cur_mac_file]   // RPI-437 RPI-728 no cont col
					|| temp_line.charAt(mac_ictl_end[cur_mac_file]) <= asc_space_char // RPI-728 test cont col
					) { // RPI-181
				mac_line = tz390.trim_trailing_spaces(temp_line,mac_ictl_end[cur_mac_file]);  // RPI-124  RPI-728 exclude cont col
			} else {
				mac_line = tz390.trim_continue(temp_line.substring(0,mac_ictl_end[cur_mac_file]),tz390.split_first,mac_ictl_end[cur_mac_file],mac_ictl_cont[cur_mac_file]); // first line RPI-728 remove cont char
				boolean mac_cont_line = true;
				while (mac_cont_line) { // RPI-181 // RPI-215
					tz390.systerm_io++;
					temp_line = mac_file_buff[cur_mac_file].readLine();
					if (temp_line != null && tz390.opt_chksrc >= 3) {
						temp_line = tz390.trim_trailing_spaces(temp_line,0); // RPI-1143
						if (temp_line.length() > 80) {
							log_error(272,"line exceeds 80 characters - " + temp_line); // R{O 957
						} else if (temp_line.length() > 72) {
							cur_seq = temp_line.substring(72);
							if (last_seq != null
								&& cur_seq.compareTo(last_seq) < 0) { // RPI-957
								log_error(273,"line sequence field not numeric - " + temp_line); // RPI-957
							}
							last_seq = cur_seq;
						}
					}
					cur_mac_line_num++;
					store_mac_line(); // RPI-273 update now for any cont. error
					if (temp_line == null) {
						log_error(139,"missing continuation line " + cur_mac_line_num + " in " + mac_file[cur_mac_file].getAbsolutePath());
						mac_cont_line = false;
						temp_line = "";
					}
					temp_line = tz390.trim_trailing_spaces(temp_line,72);
					if (tz390.opt_chksrc > 0) {  // RPI-747
						if 	((load_type == load_mlc_file
							 || tz390.opt_chksrc > 1) // RPI-957
							&& !tz390.verify_ascii_source(temp_line)) {
							log_error(140,"invalid ASCII source line " + cur_mac_line_num + " in " + mac_file[cur_mac_file].getAbsolutePath());
							mac_cont_line = false;
							temp_line = tz390.trim_trailing_spaces(temp_line,72);
						}
					}
					if (temp_line.length() < 72
						|| temp_line.charAt(71) <= asc_space_char) { // RPI-181
						mac_cont_line = false;
						temp_line = tz390.trim_trailing_spaces(temp_line,72); // RPI-124
					}
					if  (temp_line.length() >= mac_ictl_start[cur_mac_file] + mac_ictl_cont[cur_mac_file] - 1 // RPI-728
							&& temp_line.substring(mac_ictl_start[cur_mac_file]-1,mac_ictl_cont[cur_mac_file]-1).trim().equals("")  // RPI-728 check all spaces on preceeding cont
						) { // RPI-167
						mac_line = mac_line + tz390.trim_continue(temp_line,tz390.split_cont,mac_ictl_end[cur_mac_file],mac_ictl_cont[cur_mac_file]); // RPI-315, RPI-463 RPI-728
					} else if (temp_line.length() != 0               // RPI-492 blank line
							&& (mac_line.charAt(0) != '*'
							|| temp_line.charAt(0) != '*')) { // RPI-740 allow comment char for continued comm
						log_error(11,"continuation line < " + mac_ictl_cont[cur_mac_file] + " characters - " + temp_line);
						mac_cont_line = false;
						mac_line = mac_line + tz390.trim_trailing_spaces(temp_line,72); // RPI-1038
					}
				}
			}
			if (mac_line != null && mac_ictl_start[cur_mac_file] > 1) {  // RPI-728
				if (mac_line.length() > mac_ictl_start[cur_mac_file]) {
					mac_line = mac_line.substring(mac_ictl_start[cur_mac_file]-1);
				} else {
					mac_line = "";
				}
			}
		} catch (final Exception e) {
			abort_error(29,"I/O error on file read " + e.toString());
		}
	}

	/**
	 * Save mac_line during input for use by log_error.
	 * Update &SYSSTMT.
	 */
	private void store_mac_line() // RPI-274
	{
		if (skip_store || ainsert_copy) { // RPI-1019
			skip_store = false;
			return;
		}
		mac_file_line[mac_line_index] = mac_line;
		mac_file_num[mac_line_index] = cur_mac_file_num;
		mac_file_line_num[mac_line_index] = cur_mac_line_num;
		bal_xref_index = mac_line_index;
	}

	/**
	 * Generate ZSTRMAC structured macro code lines with same line
	 * number as original statement in zsm_lines and set zsm_line_tot
	 */
	private void zsm_gen_lines()
	{
		zsm_line_tot   = 0;
		zsm_line_index = 0;
		tz390.split_line(mac_line);
		if (tz390.split_op == null
			|| tz390.split_op.length() < 3) {
			return;
		}
		if (tz390.split_op.charAt(0) == ':'
			&& tz390.split_label == null) {
			// move :label to label field
			mac_line = tz390.split_op.substring(1) + " " + tz390.split_parms;
			store_mac_line();
			return;
		}
		int index = tz390.find_key_index('Z',tz390.split_op.toUpperCase());  // RPI-911
		if (index > 0 && index != zsm_type_aif) {  // aif may be explicit with label
			mac_line = ".*" + mac_line.substring(2);
		}
		switch (index) {
		case 1: // AELSE
			if  (zsm_lvl < 1
				|| (zsm_lvl_type[zsm_lvl] != zsm_type_aif
				    && zsm_lvl_type[zsm_lvl] != zsm_type_acase)
				) {
				log_error(238,"ZSM AELSE missing AIF or ACASE");
				return;
			}
			if  (zsm_lvl_aelse[zsm_lvl]) {
				log_error(241,"ZSM AELSE duplicate");
				return;
			}
			switch (zsm_lvl_type[zsm_lvl]) {
			case 6: // AELSE AIF
				zsm_lvl_aelse[zsm_lvl] = true;
				zsm_line_tot++;
				zsm_gen_line[zsm_line_tot-1] =
				  " AGO .AIF_" + zsm_lvl_tcnt[zsm_lvl] + "_E";
				zsm_line_tot++;
				zsm_gen_line[zsm_line_tot-1] =
				  ".AIF_" + zsm_lvl_tcnt[zsm_lvl]
				  + "_" + zsm_lvl_bcnt[zsm_lvl] + " ANOP";
				zsm_lvl_bcnt[zsm_lvl] = 0;
				break;
			case 8: // AELSE SELECT
				zsm_lvl_aelse[zsm_lvl] = true;
				if (zsm_lvl_bcnt[zsm_lvl] > 0) {
					zsm_line_tot++;
					zsm_gen_line[zsm_line_tot-1] =
				      " AGO .ACS_" + zsm_lvl_tcnt[zsm_lvl] + "_E";
				}
				zsm_line_tot++;
				zsm_gen_line[zsm_line_tot-1] =
				  ".ACS_" + zsm_lvl_tcnt[zsm_lvl]
				  + "_X ANOP";
				break;
			default:
				log_error(244,"ZSM AELSE missing AIF or ACASE");
			}
			break;
		case 2: // AELSEIF
			if  (zsm_lvl < 1
				|| zsm_lvl_type[zsm_lvl] != zsm_type_aif) {
				log_error(242,"ZSM AELSEIF missing AIF");
				return;
			}
			zsm_lvl_tend[zsm_lvl] = true;
			zsm_line_tot++;
			zsm_gen_line[zsm_line_tot-1] =
			  " AGO .AIF_" + zsm_lvl_tcnt[zsm_lvl] + "_E";
			zsm_line_tot++;
			zsm_gen_line[zsm_line_tot-1] =
			  ".AIF_" + zsm_lvl_tcnt[zsm_lvl]
			  + "_" + zsm_lvl_bcnt[zsm_lvl] + " ANOP";
			zsm_lvl_bcnt[zsm_lvl]++;
			if  (!zsm_find_aif_exp()) {
				log_error(243,"ZSM AELSEIF missing (...)");
				return;
			}
			zsm_line_tot++;
			zsm_gen_line[zsm_line_tot-1] =
			  " AIF (NOT" + zsm_aif_exp
			  + ").AIF_" + zsm_lvl_tcnt[zsm_lvl]
			  + "_" + zsm_lvl_bcnt[zsm_lvl];
			break;
		case 3: // AEND
			if (zsm_lvl < 1) {
				log_error(239,"ZSM AEND missing structure");
				return;
			}
			switch (zsm_lvl_type[zsm_lvl]) {
			case 4:  // AEND AENTRY
				if (zsm_acall_cnt[zsm_lvl] == 0) {
					log_error(248,"ZSM AENTRY not used - " + zsm_acall_name[zsm_acall_index]);
					return;
				}
				zsm_acall_index = zsm_lvl_tcnt[zsm_lvl];
				if  (zsm_lvl_tend[zsm_lvl]) {
					zsm_line_tot++;
					zsm_gen_line[zsm_line_tot-1] =
					  ".ACL_" + zsm_acall_index + "_E ANOP";
				}
				String ago = " AGO (&ACALL_" + zsm_acall_index
							+ "_" + zsm_acall_name[zsm_acall_index]
							+ ").ACL_" + zsm_acall_index + "_1";
				index = 1;
				while (index < zsm_acall_cnt[zsm_acall_index]) {
					index++;
					ago = ago + ",.ACL_" + zsm_acall_index + "_" + index;
				}
				zsm_line_tot++;
				zsm_gen_line[zsm_line_tot-1] = ago;
				zsm_line_tot++;
				zsm_gen_line[zsm_line_tot-1] =
				  ".ACL_" + zsm_acall_index + "_S ANOP";
				zsm_lvl--;
				break;
			case 6:  // AEND AIF
				if  (zsm_lvl_bcnt[zsm_lvl] > 0) {
					zsm_line_tot++;
					zsm_gen_line[zsm_line_tot-1] =
					  ".AIF_"
					  + zsm_lvl_tcnt[zsm_lvl]
					  + "_" + zsm_lvl_bcnt[zsm_lvl]
					  + " ANOP";
				}
				if (zsm_lvl_tend[zsm_lvl] || zsm_lvl_aelse[zsm_lvl]) {
					zsm_line_tot++;
					zsm_gen_line[zsm_line_tot-1] =
					  ".AIF_"
					  + zsm_lvl_tcnt[zsm_lvl]
					  + "_E ANOP";
				}
				zsm_lvl--;
				break;
			case 8:  // AEND ACASE
				if (zsm_lvl_bcnt[zsm_lvl] == 0) {
					log_error(255,"ZSM ACASE missing ASHEN");
					return;
				}
				zsm_line_tot++;
				zsm_gen_line[zsm_line_tot-1] =
				  " AGO .ACS_"
				  + zsm_lvl_tcnt[zsm_lvl]
				  + "_E";
				zsm_line_tot++;
				zsm_gen_line[zsm_line_tot-1] =
				  ".ACS_"
				  + zsm_lvl_tcnt[zsm_lvl]
				  + "_G ANOP";
				ago = zsm_lvl_ase_ago[zsm_lvl];
				if (zsm_lvl_ase_fst[zsm_lvl] != 1) {
					ago = ago.substring(0,ago.length()-1)
					+ "+1-" + zsm_lvl_ase_fst[zsm_lvl]
					+ ")";
				}
				int offset = 256*(zsm_lvl-1);
				String comma = "";
				String else_lab = ".ACS_" + zsm_lvl_tcnt[zsm_lvl]
								+ "_E";
				if (zsm_lvl_aelse[zsm_lvl]) {
					else_lab = ".ACS_" + zsm_lvl_tcnt[zsm_lvl]
							 + "_X";
				}
				index = zsm_lvl_ase_fst[zsm_lvl];
				while (index <= zsm_lvl_ase_lst[zsm_lvl]) {
					if (zsm_lvl_ase_blk[index+offset] > 0) {
						ago = ago + comma
							+ ".ACS_" + zsm_lvl_tcnt[zsm_lvl]
							+ "_" + zsm_lvl_ase_blk[index+offset];
					} else {
						ago = ago + comma + else_lab;
					}
					comma = ",";
					index++;
				}
				zsm_line_tot++;
				zsm_gen_line[zsm_line_tot-1] = ago;
				if (zsm_lvl_aelse[zsm_lvl]) {
					zsm_line_tot++;
					zsm_gen_line[zsm_line_tot-1] =
					  " AGO .ACS_"
					  + zsm_lvl_tcnt[zsm_lvl]
					  + "_X";
				}
				zsm_line_tot++;
				zsm_gen_line[zsm_line_tot-1] =
					  ".ACS_" + zsm_lvl_tcnt[zsm_lvl]
					+ "_E ANOP";
				zsm_lvl--;
				break;
			case 10: // AEND AUNTIL
				zsm_line_tot++;
				zsm_gen_line[zsm_line_tot-1] =
				  " AGO .AUN_"
				  + zsm_lvl_tcnt[zsm_lvl]
				  + "_T";
				zsm_line_tot++;
				zsm_gen_line[zsm_line_tot-1] =
				  ".AUN_"
				  + zsm_lvl_tcnt[zsm_lvl]
				  + "_E ANOP";
				zsm_lvl--;
				break;
			case 11: // AEND AWHILE
				zsm_line_tot++;
				zsm_gen_line[zsm_line_tot-1] =
				  " AGO .AWH_"
				  + zsm_lvl_tcnt[zsm_lvl]
				  + "_T";
				zsm_line_tot++;
				zsm_gen_line[zsm_line_tot-1] =
				  ".AWH_"
				  + zsm_lvl_tcnt[zsm_lvl]
				  + "_E ANOP";
				zsm_lvl--;
				break;
			default:
				tz390.abort_case();
			}
			break;
		case 4: // AENTRY
			zsm_aentry_tot++;   // RPI-1078
			if (zsm_lvl != 0) {
				log_error(245,"ZSM AENTRY cannot be nested within another structure");
				return;
			}
			zsm_lvl++;
			zsm_lvl_type[zsm_lvl] = zsm_type_aentry;
			if (!zsm_find_name()) {
				log_error(246,"ZSM AENTRY name error - " + tz390.split_parms);
				return;
			} else if (zsm_aentry_def[zsm_acall_index]) { // RPI-1078
				log_error(247,"ZSM AENTRY duplicate name error - " + zsm_acall_name[zsm_acall_index]);
				return;
			}
			zsm_aentry_def[zsm_acall_index] = true; // RPI-1078
			zsm_lvl_tcnt[zsm_lvl] = zsm_acall_index;
			zsm_line_tot++;
			zsm_gen_line[zsm_line_tot-1] =
			  " AGO .ACL_" + zsm_acall_index + "_S";
			zsm_line_tot++;
			zsm_gen_line[zsm_line_tot-1] =
				".ACL_" + zsm_acall_index
			  + "_" + zsm_acall_name[zsm_acall_index]
			  + " ANOP";
			break;
		case 5: // AEXIT
			if (zsm_lvl < 1
				|| tz390.split_parms == null) {
				log_error(256,"ZSM AEXIT missing structure");
				return;
			}
			String type = tz390.split_parms;
			index = type.indexOf(' ');
			if  (index > 0) {
				type = tz390.split_parms.substring(0,index);
			}
			byte type_index = (byte) tz390.find_key_index('Z',type);
			int zsm_exit_lvl = zsm_lvl;
			while (zsm_exit_lvl > 0
					&& zsm_lvl_type[zsm_exit_lvl] != type_index) {
				zsm_exit_lvl--;
			}
			if (zsm_exit_lvl == 0) {
				log_error(257,"ZSM AEXIT type not found");
				return;
			}
			zsm_line_tot++;
			if (type.equals("AENTRY")) {
				type = "ACALL";
			}
			zsm_gen_line[zsm_line_tot-1] =
				" AGO ." + zsm_type_pfx[type_index]
				+ "_" + zsm_lvl_tcnt[zsm_exit_lvl]
				+ "_E ANOP";
			zsm_lvl_tend[zsm_exit_lvl] = true;
			break;
		case 6: // AIF
			if (tz390.split_parms == null) {
				return;
			}
			index = tz390.split_parms.indexOf(").");
			if  (!zsm_find_aif_exp()) {
				return; // assume explicit AIF with label
			}
			mac_line = ".*" + mac_line.substring(2);
			zsm_lvl++;
			zsm_aif_tot++;
			zsm_lvl_type[zsm_lvl] = zsm_type_aif;
			zsm_lvl_tcnt[zsm_lvl] = zsm_aif_tot;
			zsm_lvl_tend[zsm_lvl] = false;
			zsm_lvl_aelse[zsm_lvl] = false;
			zsm_lvl_bcnt[zsm_lvl] = 1;
			zsm_line_tot++;
			zsm_gen_line[zsm_line_tot-1] = " AIF (NOT"
						+ zsm_aif_exp
						+ ").AIF_" + zsm_lvl_tcnt[zsm_lvl] + "_1";
			break;
		case 7: // ACALL
			zsm_acall_tot++;
			if (!zsm_find_name()) {
				log_error(249,"ZSM ACALL name error - " + tz390.split_parms);
				return;
			}
			if (zsm_aentry_def[zsm_acall_index]) {
				log_error(282,"ACALL issused after AENTRY for " + zsm_acall_name[zsm_acall_index]); // RPI-1078
			}
			zsm_acall_cnt[zsm_acall_index]++;
			zsm_line_tot++;
			zsm_gen_line[zsm_line_tot-1] =
				"&ACALL_" + zsm_acall_index
				+ "_" + zsm_acall_name[zsm_acall_index]
				+ " SETA " + zsm_acall_cnt[zsm_acall_index];
			zsm_line_tot++;
			zsm_gen_line[zsm_line_tot-1] =
				" AGO .ACL_" + zsm_acall_index
				+ "_" + zsm_acall_name[zsm_acall_index];
			zsm_line_tot++;
			zsm_gen_line[zsm_line_tot-1] =
				".ACL_" + zsm_acall_index
				+ "_" + zsm_acall_cnt[zsm_acall_index]
				+ " ANOP";
			break;
		case 8: // ACASE
			if  (!zsm_find_aif_exp()) {
				log_error(252,"ZSM ACASE missing (...)");
				return;
			}
			zsm_lvl++;
			zsm_lvl_type[zsm_lvl] = zsm_type_acase;
			zsm_acase_tot++;
			zsm_lvl_tcnt[zsm_lvl] = zsm_acase_tot;
			zsm_lvl_bcnt[zsm_lvl] = 0; // reset awhen block counter
			zsm_lvl_aelse[zsm_lvl] = false; // reset aelse block flag
			zsm_lvl_ase_ago[zsm_lvl] = " AGO " + zsm_aif_exp;
			zsm_lvl_ase_fst[zsm_lvl] = 256;
			zsm_lvl_ase_lst[zsm_lvl] = -1;
			int offset = 256*(zsm_lvl-1);
			index = 0;
			while (index < 256) {
				zsm_lvl_ase_blk[index+offset] = 0;
				index++;
			}
			zsm_line_tot++;
			zsm_gen_line[zsm_line_tot-1] =
				  " AGO .ACS_" + zsm_lvl_tcnt[zsm_lvl]
				+ "_G";
			break;
		case 9: // AWHEN
			if (zsm_lvl < 1
				|| zsm_lvl_type[zsm_lvl] != zsm_type_acase) {
				log_error(253,"ZSM AWHEN missing ACASE");
				return;
			}
			zsm_lvl_bcnt[zsm_lvl]++;
			if  (!zsm_acs_set_blk()) {
				log_error(254,"ZSM AWHEN invalid value -" + tz390.split_parms);
				return;
			}
			if  (zsm_lvl_bcnt[zsm_lvl] > 1
				|| zsm_lvl_aelse[zsm_lvl]) {
				zsm_line_tot++;
				zsm_gen_line[zsm_line_tot-1] =
					" AGO .ACS_" + zsm_lvl_tcnt[zsm_lvl]
					+ "_E";
			};
			zsm_line_tot++;
			zsm_gen_line[zsm_line_tot-1] =
			  ".ACS_" + zsm_lvl_tcnt[zsm_lvl]
			  + "_" + zsm_lvl_bcnt[zsm_lvl]
			  + " ANOP";
			break;
		case 10: // AUNTIL
			if  (!zsm_find_aif_exp()) {
				log_error(250,"ZSM AUNTIL missing (...)");
				return;
			}
			zsm_lvl++;
			zsm_lvl_type[zsm_lvl] = zsm_type_auntil;
			zsm_auntil_tot++;
			zsm_lvl_tcnt[zsm_lvl] = zsm_auntil_tot;
			zsm_line_tot++;
			zsm_gen_line[zsm_line_tot-1] =
				" AGO .AUN_" + zsm_lvl_tcnt[zsm_lvl];
			zsm_line_tot++;
			zsm_gen_line[zsm_line_tot-1] =
				".AUN_" + zsm_lvl_tcnt[zsm_lvl]
				+ "_T ANOP";
			zsm_line_tot++;
			zsm_gen_line[zsm_line_tot-1] =
				" AIF " + zsm_aif_exp
				+ ".AUN_" + zsm_lvl_tcnt[zsm_lvl]
				+ "_E";
			zsm_line_tot++;
			zsm_gen_line[zsm_line_tot-1] =
				".AUN_" + zsm_lvl_tcnt[zsm_lvl]
				+ " ANOP";
			break;
		case 11: // AWHILE
			if  (!zsm_find_aif_exp()) {
				log_error(251,"ZSM AWHILE missing (...)");
				return;
			}
			zsm_lvl++;
			zsm_lvl_type[zsm_lvl] = zsm_type_awhile;
			zsm_awhile_tot++;
			zsm_lvl_tcnt[zsm_lvl] = zsm_awhile_tot;
			zsm_line_tot++;
			zsm_gen_line[zsm_line_tot-1] =
				".AWH_" + zsm_lvl_tcnt[zsm_lvl]
				+ "_T ANOP";
			zsm_line_tot++;
			zsm_gen_line[zsm_line_tot-1] =
				" AIF (NOT" + zsm_aif_exp
				+ ").AWH_" + zsm_lvl_tcnt[zsm_lvl]
				+ "_E";
			break;
		}
	}

	/**
	 * Process AWHEN index value parms and set current block # in value block array.
	 * The valid values are 0-255, C'?', X'??', or range (v1,v2) separated by commas.
	 *
	 * @return
	 */
	private boolean zsm_acs_set_blk()
	{
		if  (tz390.split_parms == null) {
			return false;
		}
		int offset = 256*(zsm_lvl-1);
		int count = 0;
		int v     = 0;
		int v1    = 0;
		int v2    = 0;
		exp_next_index = 0;
		while (exp_next_index < tz390.split_parms.length()) {
			switch (tz390.split_parms.charAt(exp_next_index)) {
			case ' ':
				if (count > 0) {
					return true;
				} else {
					return false;
				}
			case '(': // next range (v1,v2)
				v1 = calc_seta_exp(tz390.split_parms,exp_next_index+1);
				if (!zsm_acs_chk_val(v1)) {
					return false;
				}
				if (exp_next_index < tz390.split_parms.length()
					&& tz390.split_parms.charAt(exp_next_index-1) == ',') {
					v2 = calc_seta_exp(tz390.split_parms,exp_next_index);
					if (!zsm_acs_chk_val(v2)
					 || v1 > v2) {
						return false;
					}
				}
				v = v1;
				while (v <= v2) {
					zsm_lvl_ase_blk[v+offset] = (short)zsm_lvl_bcnt[zsm_lvl];
					count++;
					v++;
				}
				if (exp_next_index >= tz390.split_parms.length()
					|| tz390.split_parms.charAt(exp_next_index-1) != ')') {
					return false;
				}
				break;
			case ',': // next v or (v1,v2)
				exp_next_index++;
				break;
			default:  // next value
				v = calc_seta_exp(tz390.split_parms,exp_next_index);
				if (!zsm_acs_chk_val(v)) {
					return false;
				}
				zsm_lvl_ase_blk[v+offset] = (short)zsm_lvl_bcnt[zsm_lvl];
				count++;
			}
		}
		return true;
	}

	/**
	 * Limit check AWHEN value and return false if not 0-255.
	 * Also set low and high value.
	 *
	 * @param val
	 * @return
	 */
	private boolean zsm_acs_chk_val(final int val)
	{
		if (val < 0 || val > 255) {
			return false;
		}
		if (val < zsm_lvl_ase_fst[zsm_lvl]) {
			zsm_lvl_ase_fst[zsm_lvl] = val;
		}
		if (val > zsm_lvl_ase_lst[zsm_lvl]) {
			zsm_lvl_ase_lst[zsm_lvl] = val;
		}
		return true;
	}

	/**
	 * Set zsm_aif_exp to (...) else return false.
	 *
	 * @return
	 */
	private boolean zsm_find_aif_exp()
	{
		if (tz390.split_parms == null) {
			return false;
		}
		int index1 = tz390.split_parms.indexOf("(");
		if (index1 >= 0) {
			// find (...) aif expression which may have trailing comments with (..)
			tz390.parm_match = tz390.parm_pattern.matcher(tz390.split_parms.substring(index1+1));
			int exp_lvl = 1;
			while (tz390.parm_match.find()) {  // RPI-930
				String token = tz390.parm_match.group();
				if (token.equals("(")) {
					exp_lvl++;
				} else if (token.equals(")")) {
					exp_lvl--;
					if (exp_lvl == 0) {
						int index2 = tz390.parm_match.end()+1;
						if (tz390.split_parms.length() > index2
							&& tz390.split_parms.charAt(index2) > ' ') { // RPI-1192 was == '.'
							return false; // assume std AIF with label
						} else {
							zsm_aif_exp = tz390.split_parms.substring(index1,index2);
							return true;
						}
					}
				}
			}
		}
		return false;
	}

	/**
	 * Find ACALL name or add new name and set zsm_acall_index else false.
	 *
	 * @return
	 */
	private boolean zsm_find_name()
	{
		zsm_acall_index = -1;
		if (tz390.split_parms == null) {
			return false;
		}
		String name = tz390.split_parms.toUpperCase();  // RPI-911
		int index = name.indexOf(' ');
		if (index > 0) {
			name = name.substring(0,index);
		}
		String zsm_hash_key = "N" + lcl_sysndx + name;
		zsm_acall_index = tz390.find_key_index('Z',zsm_hash_key);  // RPI-977
		if (zsm_acall_index >= 0) {
			if (zsm_acall_name[zsm_acall_index].equals(name)) {
				return true;
			}
			log_error(280,"zsm_find_name hash index duplicate for - '" + zsm_acall_name[zsm_acall_index] + "' and '" + name + "'");
			return false;
		}
		if (zsm_aentry_name_tot < max_zsm_aentry_name) {
			zsm_acall_index = zsm_aentry_name_tot;
			if (!tz390.add_key_index(zsm_acall_index)) {
				abort_error(281,"zsm_find_name hash table error");
				return false;
			}
			zsm_aentry_name_tot++;
			zsm_acall_name[zsm_acall_index] = name;
			zsm_acall_cnt[zsm_acall_index] = 0;
			zsm_aentry_def[zsm_acall_index] = false; // 1078
			return true;
		} else {
			return false;
		}
	}

	/**
	 * 1.  parse mac line into label, op, parms
	 * 2.  open copybook file if found
	 * 3.  if cics insert prolog and epilog
	 */
	private void parse_mac_line()
	{
		mac_label = null;
		mac_op    = null;
		mac_parms = null;
		if (   mac_line == null // RPI-139
			|| mac_line.length() == 0
			|| (mac_line.length() > 1 && mac_line.substring(0,2).equals(".*"))) {
			return;
		} else if (mac_line.charAt(0) == '*') {
			mac_label = "*";
			return;
		}
		tz390.split_line(mac_line);
		if (tz390.split_label != null) {
			mac_label = tz390.split_label;
			if (mac_label.charAt(0) == '.') {
				label_match = label_pattern.matcher(mac_label);
				if (label_match.find()
				 && label_match.group().length() != mac_label.length()) {
					log_error(284, "Invalid sequence label " + bal_label); // RPI-1139
				}
			}
		} else {
			mac_label = "";
		}
		if (tz390.split_op != null) {
			mac_op    = tz390.split_op.toUpperCase();
		} else {
			mac_op = "";
		}
		if (tz390.split_parms != null) {
			mac_parms = tz390.split_parms;
		} else {
			mac_parms = "";
		}
		if (mac_op.equals("COPY")) { // RPI-300  RPI-1083 RPI-1135 was && !ainsert_copy
			open_mac_copy_file();
			return;
		}
		if (tz390.opt_cics) {
			if (tz390.opt_prolog) {
				if (!cics_first_dsa_dsect
					&& mac_op.equals("DSECT")
					&& mac_label.equals("DFHEISTG")) {
					cics_first_dsa_dsect = true;
					mac_line  = " DFHEISTG";
					mac_label = "";
					mac_op    = "DFHEISTG";
					mac_parms = "";
				} else if (!cics_first_csect
						&& (mac_op.equals("CSECT")
						    || mac_op.equals("RSECT"))) {
					cics_first_csect = true;
					mac_line = mac_label + " " + "DFHEIENT";
					mac_op = "DFHEIENT";
				}
			}
			if (tz390.opt_epilog
					&& !cics_first_end
					&& mac_op.equals("END")) {
				cics_first_end = true;
				mac_line = " DFHEIEND";
				mac_op = "DFHEIEND";
			}
		}
	}

	/**
	 * Open copy file specified in mac_parms
	 * Notes:
	 *  1. Expand during MLC and macro loads
	 *  2. Insert using AINSERT during execution after var substitution on name.
	 *  3. Issue error on copy file not found if not loading MLC/MAC.
	 */
	private void open_mac_copy_file()
	{
		String new_mac_name = null;
		tz390.split_line(mac_parms); // RPI-84
		if (tz390.split_label == null) {
			tz390.split_label = "";
		} else if (tz390.opt_pdsmem8) { // RPI-1160
			int index = tz390.split_label.indexOf('.');
			if (index  == -1) {
				index = tz390.split_label.length();
			}
			if (index > 8) { // RPI-1160
				log_error(290,"COPY MEMBER NAME > 8 - " + tz390.split_label);
			}
		}
		if (load_type > load_mac_file
			&& !ainsert_source) { // RPI-970 check if previously loaded ok RPI-1019
			if (tz390.find_key_index('C',tz390.split_label) == -1) { // RPI-ignore copy if loaded during exec
				if (tz390.opt_asm
					&& !az390.tz390.opt_errsum) {
					tz390.init_errsum();
					az390.tz390.init_errsum();  // RPI-694 RPI-1051
				}
				log_error(266,"missing copy = " + mac_parms);
			}
			return; // ignore std copy during exec
		}
		cur_mac_file++;
		if (cur_mac_file >= tz390.opt_maxfile) {
			cur_mac_file--;
			abort_error(100,"Maximum nested copy files exceeded");
			return;
		}
		set_default_ictl(); // RPI-1019
		new_mac_name = tz390.find_file_name(tz390.dir_cpy,tz390.split_label,tz390.cpy_type,tz390.dir_cur);
		if (new_mac_name != null) { // RPI-970 add key if found
			if (tz390.find_key_index('C',tz390.split_label) == -1) {
				if (!tz390.add_key_index(1)) { // RPI-970 indicate copy found
					abort_error(267,"COPY caused hash table overflow");
				}
			}
		} else {
			cur_mac_file--;
			if (load_type != load_mlc_file) { // RPI-300
				if (tz390.opt_asm
					&& !az390.tz390.opt_errsum) {
					tz390.init_errsum();
					az390.tz390.init_errsum();  // RPI-694
				}
			}
			log_error(101,"missing copy  = " + mac_parms);
			return;
		}
		switch (load_type) { // RPI-300
		case 0: // load_mlc
		case 1: // load_mac_file
			store_mac_line();  // RPI-549
			skip_store = true; // RPI-549
			open_load_file(new_mac_name);
			break;
		case 2: // load_mac_inline  RPI-970 was 3 in error
			// already expanded during load so ignore and don't count twice
			cur_mac_file--;
			break;
		case 3: // load_mac_exec    RPI-970 was 4 in error
			if (!ainsert_copy && !ainsert_source) {
				// already expanded during load so ignore and don't count twice
				cur_mac_file--;
			} else {
				// expand dynamic COPY to ainsert queue now
				if (!ainsert_copy) { // RPI-1135
					ainsert_copy = true;
					ainsert_back = false;   // RPI-1135
					ainsert_copy_level = 1; // RPI-1135
					ainsert_copy_index = 0; // RPI-1053 RPI-1082
				} else {
					ainsert_copy_level++;
				}
				int save_dynamic_mac_file = dynamic_mac_file;
				dynamic_mac_file = cur_mac_file-1; // RPI-1083
				open_load_file(new_mac_name);
				load_get_zstrmac_file_line();
				while (cur_mac_file >= dynamic_mac_file && mac_line != null) {
					add_ainsert_queue_rec(mac_line);
					load_get_zstrmac_file_line();
				}
				dynamic_mac_file = save_dynamic_mac_file;
				ainsert_copy_level--; // RPI-1135
				if (ainsert_copy_level == 0) { // RPI-1135
					ainsert_copy   = false;
					ainsert_source = false;
				}
			}
			break;
		}
	}

	/**
	 * Open file for loading mac/copy file.
	 * @param new_mac_name
	 */
	private void open_load_file(final String new_mac_name)
	{
		mac_file[cur_mac_file] = new File(new_mac_name);
		try {
			mac_file_buff[cur_mac_file] = new BufferedReader(new FileReader(mac_file[cur_mac_file]));
			set_sys_dsn_mem_vol(mac_file[cur_mac_file].getCanonicalPath()); // RPI-259
			gbl_setc[gbl_syslib_index  ] = sys_dsn;
			gbl_setc[gbl_syslib_index+1] = sys_mem;
			gbl_setc[gbl_syslib_index+2] = sys_vol;
			if (cur_mac_file > 0 && !ainsert_copy) { // RPI-1053 only update prior if mac/cpy
				mac_file_cur_file_num[cur_mac_file - 1] = cur_mac_file_num;  // RPI-549
				mac_file_cur_line_num[cur_mac_file - 1] = cur_mac_line_num;
			}
			set_mac_file_num();
			cur_mac_line_num = 0;
			if (tz390.opt_tracem
				&& tz390.opt_tracec) { // RPI-862 skip copy trace // RPI-862 skip COPY trace
				tz390.put_trace("LOADING COPY LVL=" + (cur_mac_file+1) + " " + new_mac_name);
			}
		} catch (final Exception e) {
			cur_mac_file--;
			abort_error(26,"I/O error opening file - " + e.toString());
		}
	}

	/**
	 * 1.  strip .mac labels if ASM and not inline macro code
	 * 2.  set symbol attr if mfc
	 * 3.  optional reformatting
	 * 4.  optional pass to az390
	 * 5.  optional write to BAL
	 *
	 * @param text_line
	 */
	private void put_bal_line(String text_line)
	{
		if (text_line != null && !bal_eof) {
			tot_bal_line++;	// excludes stats after END
			String next_bal_line = "" + (tot_bal_line + 1); // RPI-892
			gbl_setc[gbl_sysstmt_index] = ("0000000" + next_bal_line).substring(next_bal_line.length()-1); // RPI-892
		}
		// move tracem before macro label removal RPI-855
		if (tz390.opt_tracem
			&& text_line != null
			&& mac_file_num != null
			&& (tz390.opt_tracec // RPI-862 skip copy trace // RPI-862 skip COPY trace
				|| mac_file_type[mac_file_num[mac_line_index]] != '=')
			) {
			tz390.put_trace(trace_id
				+ tz390.get_cur_bal_line_id(mac_file_num[bal_xref_index],      // RPI-746
											mac_file_line_num[bal_xref_index], // RPI-746
											tz390.cur_bal_line_num,
											mac_call_level > 0, // RPI-891 pass mac gen vs open code flag
											mac_file_type[mac_file_num[bal_xref_index]]) // RPI-746
										  + text_line); // RPI-549
		}
		if (tz390.opt_asm
			&& text_line.length() > 0
			&& text_line.charAt(0) != '*') {
			tz390.split_line(text_line);
			if (tz390.split_label == null) {
				tz390.split_label = "";
			}
			if (tz390.split_op == null) {
				tz390.split_op = "";
			}
			if (tz390.split_parms == null) {
				tz390.split_parms = "";
			}
			if (text_line.charAt(0) == '.' && load_type != load_mac_inline) { // RPI-926
				// remove .mac label if not inline and force reformat
				text_line = tz390.left_justify(" ",tz390.split_label.length())
						+ text_line.substring(tz390.split_label.length());
				tz390.split_label = "";
			}
			if (tz390.opt_reformat) {
				text_line = reformat_bal();
			}
		}
		if (tz390.opt_asm
			&& !bal_eof) {
			call_az390_pass_bal_line(text_line); // RPI-415
		}
		if (!tz390.opt_bal || bal_file_buff == null) {
			return;
		}
		try {
			put_continued_text(bal_file_buff,text_line);
			if (bal_file.length() > tz390.max_file_size) {
				abort_error(119,"Maximum BAL file size exceeded");
			}
		} catch (final Exception e) { // RPI-1
			log_to_bal = false;
			abort_error(13,"I/O error on BAL write - " + e.toString());
		}
	}

	/**
	 * Pass text_line to az390 and update the az390 copy of mz390_errors.
	 *
	 * @param text_line
	 */
	private void call_az390_pass_bal_line(final String text_line)
	{
		if (az390 != null) {
			if (az390.lookahead_mode) {
				if (text_line == null || text_line.length() == 0 || text_line.charAt(0) != '*') {
					abort_error(193, "Invalid pass request during lookahead");
				}
				// ignore trace comments during lookahead
				return;
			}
			az390.mz390_errors = mz390_errors; //update mz390 errors for PRN
			if (mac_call_level >=0) {
				if (mac_call_level == 0) {
					final String bal_file_name = tz390.get_file_name(tz390.dir_mlc,tz390.pgm_name,tz390.pgm_type); // RPI-866 RPI-880 was dir_bal
					try {
						temp_file = new File(bal_file_name);
						cur_mac_name = temp_file.getAbsolutePath(); // RPI-694
					} catch (final Exception e) {
						abort_error(231, "I/O error on MLC open " + e.toString()); // RPI-880
					}
				} else {
					cur_mac_name = mac_name[mac_call_name_index[mac_call_level]];
				}
			} else {
				cur_mac_name = null;
			}
			az390.pass_bal_line(text_line,cur_mac_name,mac_file_type[mac_file_num[bal_xref_index]],mac_file_num[bal_xref_index],mac_file_line_num[bal_xref_index]); // RPI-549
			check_sysops(); // RPI-1213 update after az390 process
			if (az390.pass_bal_eof) {
				bal_eof = true;
			}
		}
	}

	/**
	 * Format text_line from tz390.split at 10 and operands at 16 if possible
	 *
	 * @return
	 */
	private String reformat_bal()
	{
		String pad_label = "";
		String pad_op = "";
		if  (tz390.split_op.length() > 0
			 && tz390.split_label.length() < 8) {
			pad_label = tz390.left_justify(" ",8);
		}
		if  (tz390.split_op.length() > 0) {
			int pad_op_len = 14 - (tz390.split_label.length() + pad_label.length() + tz390.split_op.length());
			if (pad_op_len > 0) {
				pad_op = tz390.left_justify(" ",pad_op_len);
			} else {
				pad_op = "";
			}
		}
		return    tz390.split_label
				+ pad_label + " "
				+ tz390.split_op + pad_op + " "
				+ tz390.split_parms;
	}

	/**
	 * 1. Substitute any macro variables found.
	 * 2. Set bal_label, bal_op, bal_parms.
	 */
	private void parse_bal_line()
	{
		bal_label = null;
		bal_op    = null;
		bal_parms = null;
		trace_id = "" + tz390.left_justify(mac_name[mac_call_name_index[mac_call_level]],9) + tz390.right_justify("" + mac_file_line_num[mac_line_index],6) + " ";
		if  (bal_line == null
			|| bal_line.length() == 0
			|| (bal_line.length() > 1 && bal_line.substring(0,2).equals(".*"))) {
			return;
		} else if (bal_line.charAt(0) == '*') {
			bal_label = "*";
			return;
		}
		split_bal_line();
		int opcode_type = find_opcode_type(bal_op);
		if  (opcode_type <= tz390.max_asm_type) {  // RPI-274 OPSYN cancel -2
			// replace vars on model statements
			// but not conditional macro statements
			if (bal_label.length() > 0)bal_label = replace_vars(bal_label,false,tz390.opt_asm); // RPI-1166
			if (bal_op.length() > 0)bal_op = replace_vars(bal_op,false,false); 		 // RPI-1166
			bal_comments = ""; // RPI-1166
			if (bal_parms.length() > 0) {
				tz390.parm_match = tz390.parm_pattern.matcher(bal_parms);
				int index = 0;
				boolean split_parm_end = false;
				while (!split_parm_end && tz390.parm_match.find()) {
					if (tz390.parm_match.group().charAt(0) <= ' ') {
						split_parm_end = true;
						index = tz390.parm_match.start();
					} else {
						index = tz390.parm_match.end();
					}
				}
				if (split_parm_end) {
					bal_comments = bal_parms.substring(index); // RPI-1166
					bal_parms = replace_vars(bal_parms.substring(0,index),false,false); // RPI-1166
				} else {
					bal_parms = replace_vars(bal_parms,false,false);
				}
			}
			if (bal_label.length() < tz390.split_op_index) {
				bal_line = bal_label + tz390.pad_spaces(tz390.split_op_index - bal_label.length()) + bal_op;
			} else {
				bal_line = bal_label + " " + bal_op;
			}
			if (bal_line.length() < tz390.split_parms_index) {
				bal_line = bal_line + tz390.pad_spaces(tz390.split_parms_index - bal_line.length()) + bal_parms + bal_comments;
			} else {
				bal_line = bal_line + " " + bal_parms + bal_comments;
			}
		} else {
			exp_var_replacement_change = true; // set for mac stmts
		}
		if (tz390.opt_tracem
			&& exp_var_replacement_change
			&& (tz390.opt_tracec // RPI-862 skip copy trace // RPI-862 skip COPY trace
				|| mac_file_type[mac_file_num[mac_line_index]] != '=')
			) {
			pc_trace_gen = true;
			tz390.put_trace(trace_id
					+ "        "
					+ mac_file_line[mac_line_index]);
		}
		save_bal_op = bal_op;
		if (bal_op != null && bal_op.length() > 0) {
			String opsyn_key   = bal_op.toUpperCase();
			save_opsyn_index = tz390.find_key_index('R',opsyn_key);
			if (save_opsyn_index >= 0 && tz390.opsyn_old_name[save_opsyn_index] != null) {
				bal_op = tz390.opsyn_old_name[save_opsyn_index];  /// RPI-306
			}
		}
	}

	/**
	 * Split bal_line into bal_label, bal_op, and bal_parms.
	 */
	private void split_bal_line()
	{
		tz390.split_line(bal_line);
		if (tz390.split_label != null) {
			bal_label = tz390.split_label;
		} else {
			bal_label = "";
		}
		if (tz390.split_op != null) {
			bal_op = tz390.split_op;
		} else {
			bal_op = "";
		}
		if (tz390.split_parms != null) {
			bal_parms = tz390.split_parms;
		} else {
			bal_parms = "";
		}
	}

	/**
	 * 1. Replace all variables in text and set var_replacement if changed
	 * 2. If reduce then replace && with & and '' with '.
	 * 3. If check_lable then verify label field valid.
	 * Notes:
	 *   1.  Per RPI-241 ignore undefined &vars and let az390 report error if not in comment
	 *   2.  Per RPI-502 remove undefined var which may cause null parm error in az390.
	 *   3.  Replace null single parm with comma if comments follow RPI-695
	 *
	 * @param text
	 * @param reduce
	 * @param check_label
	 * @return
	 */
	private String replace_vars(String text,boolean reduce,boolean check_label)
	{
		exp_var_replacement_mode = false;
		exp_var_replacement_change = false;
		bal_text = text;
		var_match   = var_pattern.matcher(bal_text);
		bal_text_index0 = 0; // end of prev. parm
		String new_text = "";
		String var_save = null;
		while (var_match.find()) {
			bal_text_index1 = var_match.start();
			parm_value = var_match.group();
			var_save = parm_value;
			exp_var_replacement_mode = true;
			exp_var_replacement_change = true;
			if (parm_value.length() == 1) {
				bal_text_index2 = bal_text_index1 + 1;
			} else if (parm_value.equals("&&")
					|| parm_value.equals("''")) {
				if (reduce) { // RPI-192 leave ?? and '' for BAL compatibility in az390
					// reduce ?? and '' for mnote and punch output
					parm_value = parm_value.substring(1);
				}
				bal_text_index2 = bal_text_index1 + 2;
			} else {
				parm_value = calc_setc_exp(bal_text.substring(bal_text_index1),0);
				if (parm_value == null
					&& !bal_text.substring(bal_text_index1,bal_text_index1+8).equals("&SYSLIST")) { // RPI-1161
					mac_abort = false;
					log_error(288,"Undefined set variable = " + bal_text.substring(bal_text_index1));
				}
				mac_abort = false; // RPI-1139
				if (parm_value != null) {
					if (mac_call_level > 0
						&& parm_value.length() == 0
						&& bal_text_index1 + exp_next_index < bal_text.length()
						&& bal_text.charAt(bal_text_index1+exp_next_index) <= ' '
						&& bal_parms.equals(bal_text.substring(bal_text_index1))) {
						parm_value = ","; // RPI-695 replace with comma to delimit comments
					}
					bal_text_index2 = bal_text_index1 + exp_next_index;
				} else {
					parm_value = ""; // RPI-241 RPI-502 remove undefined var
					bal_text_index2 = bal_text_index1 + var_save.length();
				}
			}
			if (bal_text_index0 < bal_text_index1) {
				new_text = new_text + bal_text.substring(bal_text_index0,bal_text_index1);
			} else if (check_label  // RPI-659
						&& bal_text_index1 == 0
						&& parm_value != null
						&& parm_value.length() > 0
						&& parm_value.charAt(0) > ' '
						&& parm_value.charAt(0) != '*') { // RPI-835
					symbol_match = symbol_pattern.matcher(parm_value);
					if (!symbol_match.find()
						|| symbol_match.start() > 0) {
						log_error(218,"Invalid character in variable label - " + parm_value);
					}
			}
			new_text = new_text + parm_value;
			bal_text = bal_text.substring(bal_text_index2);
			var_match   = var_pattern.matcher(bal_text);
			bal_text_index0 = 0;
			check_label = false; // RPI-659
		}
		if (exp_var_replacement_mode) {
			if (bal_text_index0 < bal_text.length()) {
				new_text = new_text.concat(bal_text.substring(bal_text_index0));
			}
			text = new_text;
		}
		exp_var_replacement_mode = false;
		return text;
	}

	/**
	 * Find parameter or set variable and return true if found
	 *
	 * @param name
	 * @return
	 */
	private boolean find_var(final String name)
	{
		/*
		 * find parm or set variable and return true if found
		 * also set the following:
		 * 1.  var_type = seta|setb|setc|parm (1-4)
		 * 2.  var_loc  = lcl|gbl|pos|kw|syslist
		 * 3.  setc_value = parm value if not syslist
		 * 4.  var_name_index = index to name found else -1
		 * 5.  var_name = variable name or &SYSLIST
		 *
		 * Note caller must handle subscript or sublist in exp or bal parm processing
		 * Notes:
		 *   1.  First search parms and then set variables
		 *   2.  Convert to upper case
		 */
		var_set_array = false; // RPI-836
		var_name = name.toUpperCase();
		if  (var_name.equals("&SYSLIST")) {
			var_type = var_sublist_type;
			var_loc = var_syslist_loc;
			var_name_index = -1;
			return true;
		}
		// Search pos parameters
		var_name_index = find_lcl_key_index("P:" + var_name);
		if (var_name_index != -1) {
			var_type = var_parm_type;
			var_loc  = var_pos_loc;
			setc_value = mac_call_pos_parm[var_name_index];
			return true;
		}
		// Search keyword parameters
		var_name_index = find_lcl_key_index("K:" + var_name);
		if (var_name_index != -1) {
			var_type = var_parm_type;
			var_loc  = var_kw_loc;
			setc_value = mac_call_kwd_parm[var_name_index];
			return true;
		}
		if (find_set(var_name,1)) {
			return true;
		}
		return false;
	}

	/**
	 * Return number of parameters in sublist.
	 * @param list
	 * @return
	 */
	private int get_sublist_count(final String list)
	{
		if (list.length() == 0) {
			return 0;
		} else if (list.charAt(0) != '(') {
			return 1;
		} else {
			sublist_count = 1;
			get_sublist(list,0x7fffff); // get tot count
			return sublist_count;
		}
	}

	/**
	 * 1. parse list and return sublist requested or empty list
	 * 2. incr sublist_count for each , at level 1
	 *
	 * @param list
	 * @param sublist_index
	 * @return
	 */
	private String get_sublist(final String list, final int sublist_index)
	{
		if (sublist_index < 1) {
			log_error(85,"invalid sublist index - " + sublist_index);
		}
		if (list.length() < 3 || list.charAt(0) != '(') {
			if (sublist_index == 1) {
				return list;
			} else {
				return "";
			}
		}
		tz390.parm_match = tz390.parm_pattern.matcher(list.substring(1));
		int index = 1;
		int level = 1;
		String sublist = "";
		while (tz390.parm_match.find()) {
			String token = tz390.parm_match.group();
			switch (token.charAt(0)) {
			case ',':
				if (level == 1) {
					sublist_count++;
					if (index == sublist_index) {
						return sublist;
					} else {
						index++;
						sublist = "";
					}
				} else {
					sublist = sublist + ',';
				}
				break;
			case '(':
				level++;
				sublist = sublist + '(';
				break;
			case ')':
				level--;
				if (level == 0 && index == sublist_index) {
					return sublist;
				}
				sublist = sublist + ')';
				break;
			default:
				sublist = sublist.concat(token);
			break;
			}
		}
		if (index == sublist_index) {
			return sublist;
		} else {
			return "";
		}
	}

	/**
	 * Set mac_opcode_index and return opcode type
	 *
	 * @param opcode
	 * @return
	 */
	private int find_opcode_type(final String opcode)
	{
		/*
		 * Set mac_opcode_index and return opcode type:
		 *   -1 - not found in opcode table
		 *    0 - comment (no opcode)
		 *      1-100 - machine type
		 *    100-200 - assembler type
		 *    200+    - macro operation
		 *
		 * Notes:
		 *   1.  tz390 opcode table used to find opcode type.
		 *   2.  Return 0 for comment
		 */
		if (opcode == null || opcode.length() == 0) {
			return -1;
		}
		mac_opcode_index = tz390.find_key_index('O',opcode.toUpperCase());
		if (mac_opcode_index > 0) {
			return OpTypes.op_type[mac_opcode_index];
		} else {
			return -1;
		}
	}

	/**
	 * Branch to specified macro label or branch on index using list of labels
	 * Notes:
	 *   1.  For simple branch, pc_start is set to negative index of new line and no pc code required.
	 *   2.  For indexed branch, pc_op_ago opcode is generated with pc_seta pointing to
	 *       GBLA array with the following:
	 *       a.  First entry is start of GBLC macro label array if TRACEP on
	 *           else -1 if NOTRACEP.  Note value of zero indicates error during construction.
	 *       b.  Maximum index value from 1 to n
	 *       c.  mac_line_index for each label.
	 *   3.  Key index to AGO GBLA array is stored using "A:mac_line_index to retrieve array if AGO is reused.
	 */
	private void exp_ago()
	{
		// final int old_mac_line_index = mac_line_index; //previous mac_line_index // JBA-unused
		if (bal_parms != null && bal_parms.length() > 1) {
			if (bal_parms.charAt(0) != '(') {
				new_mac_line_index = exp_ago_branch(0);
				if (new_mac_line_index >= 0) {
					pcl_start[mac_line_index] = - new_mac_line_index;
					mac_line_index = new_mac_line_index; // RPI-899
					if (tz390.opt_tracem) { // RPI-899
						trace_break();
					}
				} else {
					abort_error(236,"Undefined ago label " + bal_parms);
				}
				return;
			} else {
				tot_pc_gen_opt++; // count all computed ago's
				if (tz390.opt_pc) {
					pc_gen_exp = true;
				}
				ago_index = calc_seta_exp(bal_parms,1);
				if (mac_abort) {
					return; // RPI-611 do not build ago  if error
				}
				ago_gbla_index = tz390.find_key_index('A',"" + mac_line_index);
				if (ago_gbla_index != -1
					&& gbl_seta[ago_gbla_index] != 0) {
					// regen and exec using previously
					// defined ago array after lru reuse
					gen_pc(pc_op_ago);
					if (!tz390.z390_abort) { // RPI-899
						exec_pc_ago();
						if (mac_branch && tz390.opt_tracem) { // RPI-899
							trace_break();
						}
					}
					return;
				} else {
					// set ago array pointer for first time gen
					ago_gbla_index = tot_gbl_seta;
					if (!tz390.add_key_index(ago_gbla_index)) {
						abort_error(202,"GBLA add failed for computed AGO");
					}
					if  (tz390.opt_tracem) {
						// set ago gblc array pointer
						ago_gblc_index = tot_gbl_setc;
					}
				}
				ago_line_index = -1; // RPI-899 was 0
				ago_lab_index = exp_next_index;
				// RPI-803 gen all labels first time
				int index = 0;
				while (ago_lab_index < bal_parms.length()) {
					index++; // index value for current label
					label_match = label_pattern.matcher(bal_parms.substring(ago_lab_index));
					if (label_match.find()) {
						new_mac_line_index = exp_ago_branch(ago_lab_index);
						if (index == ago_index) {
							if (new_mac_line_index >= 0) {
								ago_line_index = new_mac_line_index;
							} else {
								abort_error(234,"AGO computed label not found " + label_match.group()); // RPI-899
								return;
							}
						}
						// store mac line index in
						// ago gbla array
						gbl_seta[ago_gbla_index + 1 + index] = new_mac_line_index; // RPI-803
						if (tz390.opt_tracem) {
							// store ago label in
							// ago setc array if tracem or tracep
							label_name = label_match.group();
							gbl_setc[ago_gblc_index -1 + index] = label_name;
						}
						ago_lab_index = ago_lab_index + label_match.end()+1;
						if (ago_lab_index >= bal_parms.length()
							|| bal_parms.charAt(ago_lab_index-1) != ',') {
							// complete gbla and gblc array updates
							if (tz390.opt_tracem) {
								gbl_seta[ago_gbla_index] = ago_gblc_index;
								tot_gbl_setc = tot_gbl_setc + index;
							} else {
								gbl_seta[ago_gbla_index] = -1;
							}
							gbl_seta[ago_gbla_index+1] = index;
							tot_gbl_seta = tot_gbl_seta + 2 + index;
							// add key index to retrieve ago arrays
							// for reuse with or without pseudo code
							if  (tz390.find_key_index('A',"" + mac_line_index) == -1) {
								if (!tz390.add_key_index(ago_gbla_index)) {
									abort_error(203,"Key index table overflow for ago");
									return;
								}
							}
							gen_pc(pc_op_ago);
							// and force exit to
							// indexed branch label or next line
							if (ago_line_index >= 0) { // RPI-899 was > 0
								mac_line_index = ago_line_index;
								if (tz390.opt_tracem) { // RPI-899
									trace_break();
								}
							}
							ago_lab_index = bal_parms.length();
						}
					} else {
						log_error(150,"AGO invald macro label operand - " + bal_parms.substring(ago_lab_index));
					}
				}
			}
		} else {
			log_error(149,"AGO missing macro label operand");
		}
	}

	/**
	 * Skip line in trace if not in suppressed copy code.
	 */
	private void trace_break()
	{
		if (tz390.opt_tracec // RPI-862 skip COPY trace
		 || mac_file_type[mac_file_num[mac_line_index]] != '=') { // RPI-855
			tz390.put_trace(" ");
		}
	}

	/**
	 * Return new_mac_line_index and set label_name for next ago target label.
	 *
	 * @param lab_index
	 * @return
	 */
	private int exp_ago_branch(int lab_index)
	{
		actr_count--;
		int index = get_label_index(bal_parms.substring(lab_index));
		if (index < mac_name_line_start[mac_name_index]) { // RPI-956
			abort_error(16,mac_name[mac_name_index] + " undefined " + bal_parms.substring(lab_index)); // was log_error
		}
		return index;
	}

	/**
	 * Execute 1 or more AIF/AIFB tests and branch if true.
	 */
	private void exec_aif()
	{
		int aif_test_index   = 0; // start of next aif test (...).lab
		int aif_branch_index = -1; // true branch index else -1 RPI-899 was 0
		while (aif_test_index >= 0) {
			if (tz390.opt_pc) {
				pc_gen_exp = true;
			}
			setb_value = calc_setb_exp(bal_parms.substring(aif_test_index),0);
			if (mac_abort)return; // RPI-902 fix trap on TESTZSM4.ZSM
			new_mac_line_index = get_label_index(bal_parms.substring(aif_test_index+exp_next_index));
			gen_pc(pc_op_aif);
			if (setb_value != 0
				&& aif_branch_index == -1) { // RPI-899 was 0
				if (tz390.opt_tracem) { // RPI-899
					trace_break();
				}
				actr_count--;
				if (new_mac_line_index < 0) { // RPI-899 add +1 RPI-956 RPI-1059 remove +1
					log_error(142,mac_name[mac_name_index] + " AIF macro label not found - " + bal_parms.substring(aif_test_index+exp_next_index));
				} else {
					if (tz390.opt_pc) {
						aif_branch_index = new_mac_line_index;
					} else {
						mac_line_index = new_mac_line_index;
						return;
					}
				}
			}
			final int label_comma_index = get_label_comma_index(bal_parms.substring(aif_test_index + exp_next_index));
			if (label_comma_index != -1) {
				aif_test_index = aif_test_index+exp_next_index+label_comma_index+1;
			} else {
				aif_test_index = -1;
			}
		}
		if (aif_branch_index >= 0) { // branch after all gens RPI-899 was > 0
			mac_line_index = aif_branch_index;
		}
	}

	/**
	 * Execute macro operation (set, aif, ago, etc.).
	 * Note case index values must match mac_op_name array values.
	 */
	private void exec_mac_op()
	{
		bal_op_ok = false;
		switch (mac_op_type) {
		case 201:  // ACTR
			bal_op_ok = true;
			actr_count = calc_seta_exp(bal_parms,0);
			if (tz390.opt_tracem) { // RPI-1131
				tz390.put_trace("ACTR reset to " + actr_count);
			}
			break;
		case 202:  // AGO
		case 226:  // AGOB
			bal_op_ok = true;
			exp_ago();
			break;
		case 203:  // AIF
		case 227:  // AIFB
			bal_op_ok = true;
			aif_op = true;
			exec_aif();
			aif_op = false;
			break;
		case 204:  // AINSERT
			bal_op_ok = true;
			process_ainsert(); // RPI-956
			break;
		case 205:  // ANOP
			bal_op_ok = true;
			break;
		case 206:  // AREAD
			bal_op_ok = true;
			aread_op = true;
			get_set_target(var_setc_type);
			setc_value = get_aread_string();
			store_setc_value();
			aread_op = false;
			break;
		case 207:  // GBLA
			bal_op_ok = true;
			alloc_set(var_seta_type,var_gbl_loc);
			break;
		case 208:  // GBLB
			bal_op_ok = true;
			alloc_set(var_setb_type,var_gbl_loc);
			break;
		case 209:  // GBLC
			bal_op_ok = true;
			alloc_set(var_setc_type,var_gbl_loc);
			break;
		case 210:  // LCLA
			bal_op_ok = true;
			alloc_set(var_seta_type,var_lcl_loc);
			break;
		case 211:  // LCLB
			bal_op_ok = true;
			alloc_set(var_setb_type,var_lcl_loc);
			break;
		case 212:  // LCLC
			bal_op_ok = true;
			alloc_set(var_setc_type,var_lcl_loc);
			break;
		case 213:  // MHELP
			break;
		case 214:  // MNOTE  RPI-238
			bal_op_ok = true;
			int mnote_level = 0;  // RPI-444 RPI-938 assume '...'
			String mnote_text = bal_parms;
			if (bal_parms.length() > 1) {
				if (bal_parms.charAt(0) == '*') {
					mnote_level = -1; // RPI-938 remove from SYSTERM ERR file
					mnote_text = bal_parms.substring(2); // RPI-938
				} else if (bal_parms.charAt(0) == ',') {
					mnote_text = bal_parms.substring(1); // RPI-938
				} else if (bal_parms.charAt(0) != '\'') {
					mnote_level = calc_seta_exp(bal_parms,0);
					if (!mac_abort && mnote_level >= 0 && mnote_level <= 255) {
						mnote_text = bal_parms.substring(exp_next_index);
					} else {
						put_bal_line("         MNOTE " + bal_parms + " see MZ390 error");
						log_error(260,"MNOTE invalid level (0 - 255) - " + bal_parms); // RPI-938
					}
				}
				if (!mac_abort) {
					process_mnote(mnote_level,replace_quoted_text_vars(mnote_text,true)); // RPI-938 RPI-965
				}
			} else {
				put_bal_line("         MNOTE " + bal_parms + " see MZ390 error");
				log_error(263,"MNOTE missing level,'text'"); // RPI-938
			}
			break;
		case 215:  // SETA
			bal_op_ok = true;
			get_set_target(var_seta_type);
			exp_next_index = 0; // RPI-839
			while (!mac_abort
					&& bal_parms != null
					&& bal_parms.length() > exp_next_index
					&& bal_parms.charAt(exp_next_index) > ' ') {
				if (tz390.opt_pc) {
					pc_gen_exp = true;
				}
				exp_string_var = 0; // RPI-1139
				store_seta_value = calc_seta_exp(bal_parms,exp_next_index);
				if (exp_string_var > 0 && !tz390.opt_allow) {
					log_error(286,"strings not allowed in SETA"); // RPI-1139
				}
				seta_value = store_seta_value;
				gen_pc(store_pc_op);
				store_seta_value(store_pc_op);
				store_pc_op = pc_op_storvn;
				store_inc = -1;
				if (bal_parms.length() > exp_next_index
					&& bal_parms.charAt(exp_next_index-1) == ',') {
					exp_next_index--;
				} else {
					bal_parms = null;
				}
				while (!mac_abort
						&& bal_parms != null
						&& bal_parms.length() > exp_next_index
						&& bal_parms.charAt(exp_next_index) == ',') {
					exp_next_index++;
					store_inc++; // RPI-839
					store_sub++;
				}
				if (store_inc > 0) {
					if (tz390.opt_pc) {
						pc_gen_exp = true;
					}
					seta_value = store_inc;
					gen_pc(pc_op_stori); // RPI-839
				}
			}
			break;
		case 216:  // SETAF
			break;
		case 217:  // SETB
			bal_op_ok = true;
			get_set_target(var_setb_type);
			exp_next_index = 0; // RPI-839
			while (bal_parms != null
				   && bal_parms.length() > exp_next_index
				   && bal_parms.charAt(exp_next_index) > ' ') {
				if (tz390.opt_pc) {
					pc_gen_exp = true;
				}
				store_setb_value = calc_setb_exp(bal_parms,exp_next_index);
				setb_value = store_setb_value;
				gen_pc(store_pc_op);
				store_setb_value();
				store_pc_op = pc_op_storvn;
				store_inc = -1;
				if (bal_parms.length() > exp_next_index
					&& bal_parms.charAt(exp_next_index-1) == ','	) {
					exp_next_index--;
				} else {
					bal_parms = null;
				}
				while (!mac_abort
						&& bal_parms != null
						&& bal_parms.length() > exp_next_index
						&& bal_parms.charAt(exp_next_index) == ',') {
					exp_next_index++;
					store_inc++; // RPI-839
					store_sub++;
				}
				if (store_inc > 0) {
					if (tz390.opt_pc) {
						pc_gen_exp = true;
					}
					seta_value = store_inc;
					gen_pc(pc_op_stori); // RPI-839
				}
			}
			break;
		case 218:  // SETC
			bal_op_ok = true;
			get_set_target(var_setc_type);
			if (!tz390.opt_allow // HLASM compat required
				&& bal_parms.length() > 1
				&& bal_parms.charAt(0) == '&') {
				// For HLASM compatibility
				// don't allow SETC parm variable without quotes
				log_error(227,"missing quotes for SETC operand");
			}
			exp_next_index = 0; // RPI-839
			while (!mac_abort   // RPI-944
				   && bal_parms != null
				   && bal_parms.length() > exp_next_index
				   && bal_parms.charAt(exp_next_index) > ' ') {
				if (tz390.opt_pc) {
					pc_gen_exp = true;
				}
				store_setc_value = calc_setc_exp(bal_parms,exp_next_index);
				setc_value = store_setc_value;
				gen_pc(store_pc_op);
				store_setc_value();
				store_pc_op = pc_op_storvn;
				store_inc = -1;
				if (bal_parms.length() > exp_next_index
					&& bal_parms.charAt(exp_next_index-1) == ',') {
					exp_next_index--;
				} else {
					bal_parms = null;
				}
				while (!mac_abort
						&& bal_parms != null
						&& bal_parms.length() > exp_next_index
						&& bal_parms.charAt(exp_next_index) == ',') {
					exp_next_index++;
					store_inc++; // RPI-839
					store_sub++;
				}
				if (store_inc > 0) {
					if (tz390.opt_pc) {
						pc_gen_exp = true;
					}
					seta_value = store_inc;
					gen_pc(pc_op_stori); // RPI-839
				}
			}
			break;
		case 219:  // SETCF
			break;
		case 220:  // MACRO
			bal_op_ok = true;
			load_type = load_mac_inline;
			load_mac();
			load_type = load_mac_exec; // RPI-926 reset to remove following mac labels
			break;
		case 221:  // MEND
			break;
		case 222:  // MEXIT
			mac_line_index = mac_name_line_end[mac_call_name_index[mac_call_level]] - 1;
			bal_op_ok = true;
			if (tz390.opt_tracem) { // RPI-899
				trace_break();
			}
			break;
		case 223:  // PUNCH
			bal_op_ok = true;
			process_punch(); // RPI-968
			break;
		case 224:  // COPY (copy to bal and issue error if not found) RPI-300
			bal_op_ok = true;
			if (mac_call_level == 0) { // RPI-581
				put_bal_line(bal_line);
			}
			mac_parms = bal_parms;
			load_type = load_mac_exec;
			open_mac_copy_file();
			// 1.  issue error if not found
			// 2.  expand inline during MLC/MAC loading
			// 3.  expand to AINSERT queue during execution of ainsert COPY
			break;
		case 225:  // OPSYN
			bal_op_ok = true;
			bal_line = replace_vars(bal_line,true,true); // RPI-274 RPI-659
			parse_bal_line();  // RPI-306
			put_bal_line(bal_line);
			if (!tz390.update_opsyn(bal_label,bal_parms)) {
				abort_error(224,"OPSYN table exceeded"); // RPI-773
			}
			break;
		default:
			tz390.abort_case();
		}
		if (!bal_op_ok) {
			put_bal_line(bal_line);
			log_error(47,"macro operation not supported - " + bal_op);
		}
	}

	/**
	 * Allocate set scalar,array, or created set variables on first occurrence.
	 *
	 * @param alloc_set_type
	 * @param alloc_set_loc
	 */
	private void alloc_set(final byte alloc_set_type, final int alloc_set_loc)
	{
		/*
		 * Allocate set scalar,array, or created set variables on first occurrence.
		 *
		 * alloc_set_loc = lcl_set | gbl_set
		 * alloc_set_type = var_seta_type| var_setb_type | var_setc_type
		 *
		 * Set alloc_set_created if any created var found
		 *
		 * Notes:
		 * 1. Duplicates ignored and expand used to handle any subscript beyond first alloc.
		 * 2. Set created_va
		 */
	//	exp_alloc_set_created = false; // JBA-unused
		exp_alloc_set_mode = true; // RPI-126
		String text = bal_parms;
		int index = 0;
		while (!mac_abort
				&& index < text.length()
				&& text.charAt(index) > asc_space_char) {  // RPI-139
			if (text.charAt(index) == ',') {
				index++;
			}
			if (index < text.length() && text.charAt(index) != '&') {

				text = "&" + text.substring(index);
			} else {
				text = text.substring(index);
			}
			index = 0;
			if (!parse_set_var(text,index)
					|| (alloc_set_loc == var_lcl_loc
							&& exp_parse_set_loc == var_gbl_loc)) {  // RPI-178
				if (exp_parse_set_name != null) {
					if (alloc_set_loc == var_lcl_loc) {
						// add find before add for LCL?  // RPI-1129
						if (find_lcl_key_index("L:" + exp_parse_set_name) == -1) {
							add_lcl_set(exp_parse_set_name,alloc_set_type,exp_parse_set_sub,exp_parse_set_subscript); // RPI-1162
						}

					} else if (find_lcl_key_index("G:" + exp_parse_set_name) == -1) {
						add_lcl_key_index(0); // RPI-600 create gbl lcl declaration first time
						if (tz390.find_key_index('G',exp_parse_set_name) == -1) {
							add_gbl_set(exp_parse_set_name,alloc_set_type,exp_parse_set_sub,exp_parse_set_subscript); // RPI-1162
						}
					}
				} else {
					log_error(105,"syntax error at " + text.substring(index));
				}
			} else if (exp_parse_set_loc != var_loc) {
				log_error(106,"set local/global conflict for - " + text.substring(index));
			} else if (exp_parse_set_type != var_type) {  // RPI-178
				log_error(107,"set type conflict for - " + text.substring(index));
			} else if (!tz390.opt_allow  // RPI-1139
					   && (exp_parse_set_name.length() <= 4
					   || !exp_parse_set_name.substring(0,4)
					   .toUpperCase().equals("&SYS"))
					) { // RPI-1139
				log_error(289,"duplicate allocation - " + exp_parse_set_name);
			}
			if (exp_parse_set_created) {
				// exp_alloc_set_created = true; // JBA-unused
			}
			index = exp_next_index;
		}
		exp_alloc_set_mode = false; // RPI-126
	}

	/**
	 * Evaluate seta expression.
	 *
	 * @param text
	 * @param text_index
	 * @return
	 */
	private int calc_seta_exp(final String text, final int text_index)
	{
		exp_type = val_seta_type;
		calc_exp(text,text_index);
		switch (exp_type) {
		case 1:
			return exp_seta;
		case 2:
			if (exp_setb == 1) {
				return 1;
			} else {
				return 0;
			}
		case 3:
			return get_int_from_string(exp_setc,10);
		default:
			tz390.abort_case();
		}
		return -1;
	}

	/**
	 * Evaluate setb expression.
	 *
	 * @param text
	 * @param text_index
	 * @return
	 */
	private byte calc_setb_exp(final String text, final int text_index)
	{
		exp_type = val_setb_type;
		calc_exp(text,text_index);
		switch (exp_type) {
		case 1:
			if (exp_seta == 0) {  // RPI-1105 0/1 vs 0/val
				return 0;
			} else {
				return 1;
			}
		case 2:
			if (exp_setb == 0) { // RPI-1105 0/1 vs 0/val
				return 0;
			} else {
				return 1;
			}
		case 3:
			log_error(212, "Invalid string in SETB expression."); // RPI-609
		default:
			tz390.abort_case();
		}
		return 0;
	}

	/**
	 * Evaluate setc expression.
	 *
	 * @param text
	 * @param text_index
	 * @return
	 */
	private String calc_setc_exp(String text,int text_index)
	{
		exp_type = val_setc_type;
		if (!calc_exp(text,text_index)) { // RPI-1139
			exp_setc = null;
		}
		return exp_setc;
	}

	/**
	 * Set set store info form bal_label and return true if ok else false.
	 * Notes:
	 * 1. Sets store_pc_op to storv, storvs, stord, or stords.
	 *    Then seta, setb, setc changes it to storvn for multiple values.
	 *
	 * @param alloc_set_type
	 */
	private void get_set_target(byte alloc_set_type)
	{
		store_type = alloc_set_type;
		if (tz390.opt_pc && !aread_op) {
			pc_gen_exp = true;
		}
		boolean store_set_found = false;
		if (!parse_set_var(bal_label,0)) {
			if (exp_parse_set_name == null
				|| (exp_parse_set_subscript
					&& bal_label.charAt(bal_label.length()-1) != ')')) { // RPI-1139
				log_error(161,"invalid set variable name - " + bal_label);
				return;
			}
			store_name         = exp_parse_set_name;
			store_loc          = var_lcl_loc;
			exp_parse_set_type = store_type;
			exp_parse_set_loc  = store_loc;
			store_created      = exp_parse_set_created;
			store_subscript    = exp_parse_set_subscript;
			if (store_subscript) {
				alloc_size = min_alloc_size;
			} else {
				alloc_size = 1;
			}
			if (tz390.opt_pc && !aread_op) {
				pc_gen_exp = true;
			}
			if (find_lcl_key_index("L:" + store_name) == -1) {
				store_name_index = add_lcl_set(store_name,store_type,alloc_size,store_subscript); // RPI-1162
				exp_parse_set_name_index = store_name_index;
				store_set_found = true;
			} else {
				log_error(192,"dynamic alloc failed for - " + store_name + "(" + store_sub + ")");
			}
		} else {
			store_set_found = true;
		}
		if (store_set_found) {
			if (tz390.opt_pc && !aread_op) {
				pc_gen_exp = true;
			}
			if (exp_parse_set_type != store_type) {
				log_error(17,"invalid set variable type for - " + bal_label);
				return;
			}
			store_loc        = exp_parse_set_loc;
			store_name_index = exp_parse_set_name_index;
			store_sub        = exp_parse_set_sub;
			store_name       = exp_parse_set_name;
			store_subscript  = exp_parse_set_subscript;
			store_created    = exp_parse_set_created;
			if (store_subscript) {
				if (alloc_size < min_alloc_size) {
					alloc_size = min_alloc_size;
				}
				if (store_created) {
					store_pc_op = pc_op_stords;
				} else {
					store_pc_op = pc_op_storvs;
				}
			} else {
				if (store_created) {
					store_pc_op = pc_op_stord;
				} else {
					store_pc_op = pc_op_storv;
				}
			}
		}
	}

	/**
	 * Store seta_value or inc/dec at store loc (shared by exp and pc).
	 *
	 * @param op
	 */
	private void store_seta_value(final byte op)
	{
		if (store_loc == var_lcl_loc) {
			store_seta_index = lcl_set_start[store_name_index] + store_sub -1;
			if (store_seta_index < lcl_set_start[store_name_index]) {
				log_error(153,"lcla subscript < 1 = " + lcl_set_name[store_name_index] + "(" + (store_seta_index-lcl_set_start[store_name_index]+1) + ")" );
				store_seta_index = lcl_set_start[store_name_index];
			} else if (store_seta_index >= lcl_set_end[store_name_index]) {
				store_seta_index = expand_set(store_name_index,var_seta_type,var_lcl_loc,store_sub);
			}
			switch (op) {
			case 25: // pc_op_inc
				lcl_seta[store_seta_index]++;
				seta_value = lcl_seta[store_seta_index];
				break;
			case 26: // pc_op_dec
				lcl_seta[store_seta_index]--;
				seta_value = lcl_seta[store_seta_index];
				break;
			default:  // pc_op_stor?
				lcl_seta[store_seta_index] = seta_value;
			}
			if (lcl_set_high[store_name_index] != -1) { // RPI
				if (store_seta_index > lcl_set_high[store_name_index]) {
					lcl_set_high[store_name_index] = store_seta_index;
				}
			} else if (store_subscript) {
				log_error(297,"local seta subscripted scalar error - " + lcl_set_name[store_name_index]); // RPI-1162
			}
			if (tz390.opt_traceall) {
				tz390.put_trace("SETA LCLA " + lcl_set_name[store_name_index] + "(" + (store_seta_index - lcl_set_start[store_name_index] + 1) + ")= " + lcl_seta[store_seta_index]);
			}
		} else {
			store_seta_index = gbl_set_start[store_name_index] + store_sub -1;
			if (store_seta_index < gbl_set_start[store_name_index]) {
				log_error(154,"gbla subscript < 1 = " + gbl_set_name[store_name_index] + "(" + (store_seta_index-gbl_set_start[store_name_index]+1) + ")" );
				store_seta_index = gbl_set_start[store_name_index];
			} else if (store_seta_index >= gbl_set_end[store_name_index]) {
				store_seta_index = expand_set(store_name_index,var_seta_type,var_gbl_loc,store_sub);
			}
			switch (op) {
			case 25: // pc_op_inc
				gbl_seta[store_seta_index]++;
				seta_value = gbl_seta[store_seta_index];
				break;
			case 26: // pc_op_dec
				gbl_seta[store_seta_index]--;
				seta_value = gbl_seta[store_seta_index];
				break;
			default:  // pc_op_stor?
				gbl_seta[store_seta_index] = seta_value;
			}
			if (gbl_set_high[store_name_index] != -1) { // RPI-1162
				if (store_seta_index > gbl_set_high[store_name_index]) {
					gbl_set_high[store_name_index] = store_seta_index;
				}
			} else if (store_subscript) {
				log_error(292,"global seta subscripted scalar error - " + lcl_set_name[store_name_index]); // RPI-1162
			}
			if (tz390.opt_traceall) {
				tz390.put_trace("SETA GBLA " + gbl_set_name[store_name_index] + "(" + (store_seta_index - gbl_set_start[store_name_index] + 1) + ")= " + gbl_seta[store_seta_index]);
			}
		}
	}

	/**
	 * Store setb_value at store loc (shared by exp and pc).
	 */
	private void store_setb_value()
	{
		if (store_loc == var_lcl_loc) {
			store_setb_index = lcl_set_start[store_name_index] + store_sub -1;
			if (store_setb_index < lcl_set_start[store_name_index]) {
				log_error(155,"lclb subscript < 1 = " + lcl_set_name[store_name_index] + "(" + (store_setb_index-lcl_set_start[store_name_index]+1) + ")" );
				store_setb_index = lcl_set_start[store_name_index];
			} else if (store_setb_index >= lcl_set_end[store_name_index]) {
				store_setb_index = expand_set(store_name_index,var_setb_type,var_lcl_loc,store_sub);
			}
			lcl_setb[store_setb_index] = setb_value;
			if (lcl_set_high[store_name_index] != -1) { // RPI-1162
				if (store_setb_index > lcl_set_high[store_name_index]) {
					lcl_set_high[store_name_index] = store_setb_index;
				}
			} else if (store_subscript) {
				log_error(293,"local setb subscripted scalar error - " + lcl_set_name[store_name_index]); // RPI-1162
			}
			if (tz390.opt_traceall) {
				tz390.put_trace("SETB LCLB " + lcl_set_name[store_name_index] + "(" + (store_setb_index - lcl_set_start[store_name_index] + 1) + ")= " + lcl_setb[store_setb_index]);
			}
		} else {
			store_setb_index = gbl_set_start[store_name_index] + store_sub -1;
			if (store_setb_index < gbl_set_start[store_name_index]) {
				log_error(156,"gblb subscript < 1 = " + gbl_set_name[store_name_index] + "(" + (store_setb_index-gbl_set_start[store_name_index]+1) + ")" );
				store_setb_index = lcl_set_start[store_name_index];
			} else if (store_setb_index >= gbl_set_end[store_name_index]) {
				store_setb_index = expand_set(store_name_index,var_setb_type,var_gbl_loc,store_sub);
			}
			gbl_setb[store_setb_index] = setb_value;
			if (gbl_set_high[store_name_index] != -1) { // RPI-1162
				if (store_setb_index > gbl_set_high[store_name_index]) {
					gbl_set_high[store_name_index] = store_setb_index;
				}
			} else if (store_subscript) {
				log_error(294,"global setb subscripted scalar error - " + lcl_set_name[store_name_index]); // RPI-1162
			}
			if (tz390.opt_traceall) {
				tz390.put_trace("SETB GBLB " + gbl_set_name[store_name_index] + "(" + (store_setb_index - gbl_set_start[store_name_index] + 1) + ")= " + gbl_setb[store_setb_index]);
			}
		}
	}

	/**
	 * Store setc string at store loc (shared by exp and pc).
	 */
	private void store_setc_value()
	{
		if (setc_value == null) { // RPI-565
			setc_value = "";
			log_error(209, "Invalid SYSLIST substitution reference.");
			return;
		}
		if (store_loc == var_lcl_loc) {
			store_setc_index = lcl_set_start[store_name_index] + store_sub -1;
			if (store_setc_index < lcl_set_start[store_name_index]) {
				log_error(157,"lclc subscript < 1 = " + lcl_set_name[store_name_index] + "(" + (store_setc_index-lcl_set_start[store_name_index]+1) + ")" );
				store_setc_index = lcl_set_start[store_name_index];
			} else if (store_setc_index >= lcl_set_end[store_name_index]) {
				store_setc_index = expand_set(store_name_index,var_setc_type,var_lcl_loc,store_sub);
			}
			lcl_setc[store_setc_index] = setc_value;
			if (lcl_set_high[store_name_index] != -1) { // RPI-1162
				if (store_setc_index > lcl_set_high[store_name_index]) {
					lcl_set_high[store_name_index] = store_setc_index;
				}
			} else if (store_subscript) {
				log_error(295,"local setc subscripted scalar error - " + lcl_set_name[store_name_index]); // RPI-1162
			}
			if (tz390.opt_traceall) {
				tz390.put_trace("SETC LCLC " + lcl_set_name[store_name_index] + "(" + (store_setc_index - lcl_set_start[store_name_index] + 1) + ")= " + lcl_setc[store_setc_index]);
			}
		} else {
			store_setc_index = gbl_set_start[store_name_index] + store_sub -1;
			if (store_setc_index < gbl_set_start[store_name_index]) {
				log_error(158,"gblc subscript < 1 = " + gbl_set_name[store_name_index] + "(" + (store_setc_index-gbl_set_start[store_name_index]+1) + ")" );
				store_setc_index = gbl_set_start[store_name_index];
			} else if (store_setc_index >= gbl_set_end[store_name_index]) {
				store_setc_index = expand_set(store_name_index,var_setc_type,var_gbl_loc,store_sub);
			}
			gbl_setc[store_setc_index] = setc_value;
			if (gbl_set_high[store_name_index] != -1) { // RPI-1162
				if (store_setc_index > gbl_set_high[store_name_index]) {
					gbl_set_high[store_name_index] = store_setc_index;
				}
			} else if (store_subscript) {
				log_error(296,"global setc subscripted scalar error - " + lcl_set_name[store_name_index]); // RPI-1162
			}
			if (tz390.opt_traceall) {
				tz390.put_trace("SETC GBLC " + gbl_set_name[store_name_index] + "(" + (store_setc_index - gbl_set_start[store_name_index] + 1) + ")= " + gbl_setc[store_setc_index]);
			}
			if (store_setc_index == gbl_systrace_index) { // RPI-930
				tz390.set_trace_options(setc_value);
			}
		}
	}

	/**
	 * Read next MLC source line or next record from file specified in DDNAME=, DSNAME=, or pgmname.dat.
	 * 1.  DDNAME= is extention to HLL assembler where external variable defines file to read for AREAD.
	 * 2.  DSNAME= is extention to HLL assembler where macro variable defines file to read for AREAD.
	 * Notes:
	 *   1.  Only DDNAME or DSNAME can be coded
	 *   2.  empty lines (CR,LF) returned as single space " "
	 *   3.  end of file returns 0 length string "".
	 *   4.  Options NOPRINT and NOSTMT ignored
	 *
	 * @return
	 */
	private String get_aread_string()
	{
		String aread_text = ""; // RPI-1140
		dat_file_index = 0;
		set_aread_punch_options(bal_parms,tz390.dir_dat,tz390.dat_type);
		if (ap_file_io) {
			// read text from aread file 0-9
			dat_file_index = ap_file_index;
			if (ap_file_name == null) {
				ap_file_name = tz390.get_file_name(tz390.dir_dat,tz390.pgm_name,tz390.dat_type); // RPI-431
			}
			if (dat_file[dat_file_index] != null
				&& !ap_file_name.equals(dat_file[dat_file_index].getAbsolutePath()) ) {
				close_dat_file(dat_file_index); // RPI-432
			}
			if (dat_file[dat_file_index] == null) {
				int index = 0;
				while (index < max_ap_files) {
					if (pch_file[index] != null
						&& pch_file[index].getAbsolutePath().equals(ap_file_name)) {
						close_pch_file(index);
					}
					index++;
				}
				try {
					dat_file[dat_file_index] = new File(ap_file_name);
					dat_file_buff[dat_file_index] = new BufferedReader(new FileReader(dat_file[dat_file_index]));
				} catch (final Exception e) {
					dat_file[dat_file_index] = null;
					aread_text = ""; // RPI-443 return eof if no file
					if (tz390.opt_tracem) {
						tz390.put_trace(" AREAD TEXT ='" + aread_text + "'");
					}
					return aread_text;
				}
			}
			try {
				String text = dat_file_buff[dat_file_index].readLine();
				if (text == null) {
					close_dat_file(dat_file_index);
					aread_text = "";
					if (tz390.opt_tracem) { // RPI-1140
						tz390.put_trace(" AREAD TEXT ='" + aread_text + "'");
					}
					return aread_text;
				} else {
					tz390.systerm_io++;
					tot_aread_io++;
					text = tz390.trim_trailing_spaces(text,0);
					if (text.length() == 0) { // RPI-410
						text = " "; // return 1 space if all spaces or cr, lf
					}
					aread_text = text;
					if (tz390.opt_tracem) { // RPI-1140
						tz390.put_trace(" AREAD TEXT ='" + aread_text + "'");
					}
					return aread_text;
				}
			} catch (final Exception e) {
				abort_error(71,"I/O error on AREAD file read - " + e.toString());
				aread_text = "";
				if (tz390.opt_tracem) { // RPI-1140
					tz390.put_trace(" AREAD TEXT ='" + aread_text + "'");
				}
				return aread_text;
			}
		} else if (ap_clockb) { // RPI-745
			if (tz390.opt_timing) {
				cur_date = new Date();
			}
			final String hhmmssmmm = sdf_systime_clockd.format(cur_date);
			final int hh  = Integer.parseInt(hhmmssmmm.substring(0,2));
			final int mm  = Integer.parseInt(hhmmssmmm.substring(2,4));
			final int ss  = Integer.parseInt(hhmmssmmm.substring(4,6));
			final int th  = Integer.parseInt(hhmmssmmm.substring(6,9))/10;
			int tod = th + 100*(ss + 60*(mm + 60*hh));
			final String tod_str = "" + tod;
			aread_text = ("00000000" + tod_str).substring(tod_str.length());
			if (tz390.opt_tracem) { // RPI-1140
				tz390.put_trace(" AREAD TEXT ='" + aread_text + "'");
			}
			return aread_text;
		} else if (ap_clockd) { // RPI-745
			if (tz390.opt_timing) {
				cur_date = new Date();
			}
			aread_text = sdf_systime_clockd.format(cur_date).substring(0,8);
			if (tz390.opt_tracem) { // RPI-1140
				tz390.put_trace(" AREAD TEXT ='" + aread_text + "'");
			}
			return aread_text;
		} else {
			aread_text = get_next_source_line();
			if (tz390.opt_tracem) { // RPI-1140
				tz390.put_trace(" AREAD TEXT ='" + aread_text + "'");
			}
			return aread_text;
		}
	}

	/**
	 * Return next source line from mac_file or AINSERT queue for use by AREAD.
	 *
	 * @return
	 */
	private String get_next_source_line()
	{
		if (cur_ainsert > 0) {
			cur_ainsert--;
			ainsert_source = true;
			return ainsert_queue.pop();
		} else {
			ainsert_source = false;
		}
		if (mac_call_level > 0
			&& mac_call_return[mac_call_level-1] != mlc_line_end) {
			// return source line following macro call and update
			// return to skip the returned source line
			String text = mac_file_line[mac_call_return[mac_call_level-1]];
			mac_call_return[mac_call_level-1] = mac_file_next_line[mac_call_return[mac_call_level-1]];
			if (tz390.opt_asm && !tz390.opt_allow) {  // RPI-968
				text = set_length_80(text);
			}
			return text;
		} else {
			abort_error(72,"Aread past end of inline AREAD data");
			return "";
		}
	}

	/**
	 * Set AREAD and PUNCH text lengths to 80 for HLASM compatibility if ASM and NOALLOW.
	 *
	 * @param text
	 * @return
	 */
	private String set_length_80(final String text)
	{
		if (text.length() < 80) { // RPI-968
			return text + tz390.pad_spaces(80-text.length());
		} else {
			return text.substring(0,80);
		}
	}

	/**
	 * 1. set ap_file_index and ap_file_name from the following AREAD or PUNCH parss:
	 *    1.  DDNAME= environment variable to get file name
	 *    2.  DSNAME= explicit file name string
	 *    3.  DSN=    explicit file name string (alias)
	 *    4.  ID=n    file index 0-9 (0 is default)
	 *    and set ap_file_io if file I/O requested.
	 * 2. Set AREAD option flags for NOPRINT, NOSTMT, CLOCKB, CLOCKD.  RPI-745
	 * 3. Set PUNCH option FORMAT.
	 *
	 * @param parms
	 * @param file_dir
	 * @param file_type
	 */
	private void set_aread_punch_options(String parms, final String file_dir, final String file_type)
	{
	//	ap_noprint = false; // JBA-unused
	//	ap_nostmt  = false; // JBA-unused
		ap_clockb  = false;
		ap_clockd  = false;
		ap_format  = false;
		ap_file_io = false;
		if (bal_parms.length() == 0
			|| bal_parms.charAt(0) == ',') { // RPI-935
			return;
		}
		ap_file_index = 0;
		ap_file_name = null;
		parms = replace_vars(parms,true,false); // RPI-659
		String parm = null;
		while (parms.length() > 0) {
			int index = parms.indexOf(',');
			if  (index < 1) {
				index = parms.indexOf(' ');
				if (index > 0) {
					parms = parms.substring(0,index);
				}
				index = 0;
			}
			if (index > 1) {
				parm  = parms.substring(0,index);
				parms = parms.substring(index+1);
			} else {
				parm = parms;
				parms = "";
			}
			if (parm.length() > 7 && parm.substring(0,7).toUpperCase().equals("DDNAME=")) {
				ap_file_io = true;
				final String ddname = parm.substring(7);
				ap_file_name = get_ddname_file_name(ddname);
				ap_file_name = tz390.get_file_name(file_dir,ap_file_name,file_type);
			} else if (parm.length() > 7 && parm.substring(0,7).toUpperCase().equals("DSNAME=")) {
				ap_file_io = true;
				ap_file_name = parm.substring(7);
				ap_file_name = tz390.get_file_name(file_dir,ap_file_name,file_type);
			} else if (parm.length() > 4 && parm.substring(0,4).toUpperCase().equals("DSN=")) {
				ap_file_io = true;
				ap_file_name = parm.substring(4);
				ap_file_name = tz390.get_file_name(file_dir,ap_file_name,file_type);
			} else if (parm.length() > 3 && parm.substring(0,3).toUpperCase().equals("ID=")
					&& parm.substring(3).compareTo("0") >= 0
					&& parm.substring(3).compareTo("9") <= 0) {
				ap_file_io = true;
				ap_file_index = Integer.valueOf(parm.substring(3));
			} else if (parm.length() == 6 && parm.substring(0,6).toUpperCase().equals("FORMAT")) {
				ap_file_io = true;
				ap_format = true; // RPI-530
			} else if (parm.toUpperCase().equals("NOPRINT")) {
				// ap_noprint = true; // JBA-unused
			} else if (parm.toUpperCase().equals("NOSTMT")) {
				// ap_nostmt = true; // JBA-unused
			} else if (parm.toUpperCase().equals("CLOCKB")) {
				ap_clockb = true;
			} else if (parm.toUpperCase().equals("CLOCKD")) {
				ap_clockd = true;
			} else {
				log_error(185,"invalid parm " + parm);
			}
		}
	}

	/**
	 * Verify ddname is defined as environment variable pointing to valid file
	 * and return full path else abort.
	 *
	 * @param ddname
	 * @return
	 */
	private String get_ddname_file_name(final String ddname)
	{
		String temp_file_name = System.getenv(ddname);
		if (temp_file_name != null && temp_file_name.length() > 0) {
			temp_file = new File(temp_file_name);
			return temp_file.getAbsolutePath();
		} else {
			log_error(62,"ddname=" + ddname + " not found");
		}
		return "";
	}

	/**
	 * Write PUNCH 'text' to PCH file.
	 * 1. If ,DDNAME= follows 'text' write to specified file instead of default filename.pch
	 * 2. If ,DSNAME= follows 'text' write to specified file instead of default filename.pch
	 * 3. If FORMAT specified as extended option on PUNCH, the output will format continuations like MLC.
	 *
	 * @param pch_parms
	 */
	private void put_pch_line(String pch_parms)
	{
		String pch_text = "";
		String token = null;
		pch_match = pch_pattern.matcher(pch_parms.substring(1));
		boolean pch_eod = false;
		while (!pch_eod && pch_match.find()) {
			token = pch_match.group();
			if (token.charAt(0) != '\'' && token.charAt(0) != '&') { // RPI-195
				pch_text = pch_text + token;
			} else if (token.length() == 2) {
				pch_text = pch_text + token.charAt(0);
			} else if (token.charAt(0) == '\'') {
				pch_eod = true;
			} else {
				pch_text = pch_text + token.charAt(0);
			}
		}
		if (!pch_eod) {
			log_error(73,"invalid punch parm " + pch_parms);
		} else {
			pch_file_index = 0;
			if (pch_match.end()+2 < pch_parms.length()
				&& pch_parms.charAt(pch_match.end()+1) == ',') {  // RPI-743
				pch_parms = pch_parms.substring(pch_match.end()+2);
			} else {
				pch_parms = "";
			}
			set_aread_punch_options(pch_parms,tz390.dir_pch,tz390.pch_type);
			if (ap_file_io) {
				pch_file_index = ap_file_index;
				if (ap_file_name == null) {
					ap_file_name = tz390.get_file_name(tz390.dir_pch,tz390.pgm_name,tz390.pch_type);
				}
				if (pch_file[pch_file_index] != null
					 && !ap_file_name.equals(pch_file[pch_file_index].getAbsolutePath())) {
					close_pch_file(pch_file_index);
				}
			} else {
				ap_file_name = tz390.get_file_name(tz390.dir_pch,tz390.pgm_name,tz390.pch_type);
			}
			if (pch_file[pch_file_index] == null) {
				int index = 0;
				while (index < max_ap_files) {
					// close all matching DAT and PCH files
					// before opening new output PCH file
					if (dat_file[index] != null
						&& dat_file[index].getAbsolutePath().equals(ap_file_name)) {
						close_dat_file(index); // RPI-432
					}
					if (pch_file[index] != null
						&& pch_file[index].getAbsolutePath().equals(ap_file_name)) {
						close_pch_file(index);
					}
					index++;
				}
				try {
					pch_file[pch_file_index] = new File(ap_file_name);
					pch_file_buff[pch_file_index] = new BufferedWriter(new FileWriter(pch_file[pch_file_index]));
				} catch (final Exception e) {
					abort_error(75,"I/O error on PUNCH open - " + e.toString());
				}
			}
			try {
				pch_text = ("X" + pch_text).trim().substring(1); // RPI-195
				tz390.systerm_io++;
				tot_punch_io++;
				if (ap_format) {
					put_continued_text(pch_file_buff[pch_file_index],pch_text);
				} else {
					pch_file_buff[pch_file_index].write(pch_text + tz390.newline); // RPI-500
					if (pch_file[pch_file_index].length() > tz390.max_file_size) {
						abort_error(120,"Maximum pch file size exceeded");
					}
				}
			} catch (final Exception e) {
				abort_error(76,"I/O error on PUNCH file write - " + e.toString());
			}
		}
	}

	/**
	 * Parse set/aif/variable expression and return true if ok and set exp_var_index to result.
	 * Note:
	 *   1.  If parse_set_mode then exit without error true/false indicating if set variable exists or not.
	 *   2.  If var_replacement_mode, exit after retrieving first variable and before proceeding to next operator, and ignore var not found.
	 *   3.  Always turn off parse_set_mode at exit.
	 *   4.  Generate pseudo code for repeat executions.
	 *
	 * @param text
	 * @param text_index
	 * @return
	 */
	private boolean calc_exp(final String text, final int text_index)
	{
		setc_value = null;  // RPI-565
		exp_text = text;
		exp_start_index = text_index;
		if (exp_text == null || exp_start_index >= exp_text.length()) {
			log_error(128, "Invalid exp_calc text index - " + exp_text + "(" + exp_start_index + ")");
		}
		exp_text_len   = text.length();
		exp_match = exp_pattern.matcher(text.substring(exp_start_index));
		tot_exp_stk_var = 0;
		tot_exp_stk_op  = 0;
		exp_level = 0;
		exp_next_first = '?';  // not space or exp_term_op
		exp_end = false;
		exp_ok  = false;
		exp_var_pushed = false;     // reset var pushed for unary
		var_subscript_calc = false; // reset explicit subscript
		exp_prev_substring = false;
		exp_sublst_op = pc_op_pushvs;
		exp_set_prev_op();
		exp_set_next_op();
		while (!exp_end && !mac_abort) {
			exp_check_prev_op = false;
			exp_perform_op();
			if (!exp_end) {
				exp_set_prev_op();
				if (!exp_check_prev_op) {
					exp_set_next_op();
				}
			}
		}
		exp_parse_set_mode = false;
		pc_gen_exp = false; // RPI-467
		return exp_ok;
	}

	/**
	 * Set exp_prev_op from stack or set to exp_start_op (same as exp_term_op)
	 * also set exp_prev_class and exp_prev_first.
	 */
	private void exp_set_prev_op()
	{
		if (tot_exp_stk_op > 0) {
			exp_prev_op = exp_stk_op[tot_exp_stk_op - 1];
			exp_prev_class = exp_stk_op_class[tot_exp_stk_op - 1];
			if (!tz390.opt_allow // HLASM compat required
				&& exp_prev_class == exp_class_comp
				&& tot_exp_stk_var >= 2
				&& exp_stk_val_type[tot_exp_stk_var-1] == val_setc_type
				&& exp_stk_val_type[tot_exp_stk_var-2] == val_setc_type
				&& (exp_stk_var_name_index[tot_exp_stk_var-1] != -1
				 || exp_stk_var_name_index[tot_exp_stk_var-2] != -1
				)) {
				// for HLASM compatibility don't allow
				// compare of SETC variables without quotes
				log_error(226, "Missing SETC variable quotes");
			}
		} else {
			exp_prev_op = "" + exp_start_op;
			exp_prev_class = exp_class_term;
		}
		exp_prev_first = exp_prev_op.charAt(0);
	}

	/**
	 * Get next expression operator and push preceding variables on stack.
	 * Also set the following:
	 * 1.  exp_token
	 * 2.  exp_next_first
	 * 3.  exp_next_op (upper )
	 * 4.  exp_next_class
	 * Notes:
	 * 1.  push zero for unary +- based on previous setting of exp_var_last.
	 * 2.  push ordinary symbols starting with A-Z$@#_ as SDT string assuming there preceding T' type oper.
	 */
	private void exp_set_next_op()
	{
		exp_var_last  = true; // force first try
		while (!exp_end && exp_var_last) {
			exp_var_last = false; // assume no more
			if (exp_next_first == exp_term_op
				&& exp_next_class == exp_class_term) { // RPI-487
				flush_pc_pending();
				return;
			} else if ((exp_var_replacement_mode
						&& tot_exp_stk_op  == 0
						&& tot_exp_stk_var == 1)
					|| !exp_match.find()) {
				exp_set_term_op();
				return;
			}
			exp_token = exp_match.group();
			if (tz390.opt_traceall) {
				tz390.put_trace("EXP TOKEN=" + exp_token);
			}
			exp_next_index = exp_start_index + exp_match.end();
			exp_next_op = exp_token.toUpperCase();
			exp_next_first = exp_next_op.charAt(0);
			// Push &var in string and non-string mode
			if (exp_next_first == '&') {
				if  (exp_token.length() > 1
					&& exp_token.charAt(1) != '&') {
					if (exp_token.charAt(1) == '(') {
						if (exp_parse_set_mode && exp_level == 0) {
							exp_parse_set_created = true;
						} else {
							exp_created_var[exp_level] = true; // RPI-897
						}
						exp_next_class = exp_class_create_set;
						exp_level++;   // force level up 1
						exp_push_op(); // put created set op on stack
						exp_set_prev_op();
						exp_push_string("");
					} else {
						exp_push_var();
					}
				} else if (exp_token.equals("&&")
						&& (exp_prev_first == exp_string_op
								|| exp_prev_first == exp_create_set_op)) {
					// RPI-192 substitute & for && in setc strings
					setc_value = "&";
					opt_gen_pc_concat(pc_op_pushc);
					setc_value = exp_stk_setc[tot_exp_stk_var - 1].concat(setc_value);
					exp_stk_setc[tot_exp_stk_var - 1] = setc_value;
					if (exp_next_char() == '.') {
						skip_next_token(); // skip trailing . in string substitution
					}
				} else {
					log_error(37,"invalid expression variable - " + exp_token);
				}
				exp_var_last = true;
				// concat the rest if string mode
			} else if ((exp_next_first != exp_term_op
					 || exp_next_class != exp_class_term) // RPI-487
					&& (
						(exp_prev_first == exp_string_op
							&& exp_next_first != exp_string_op
						)
						||
						(exp_prev_first == exp_create_set_op
							&& exp_next_first != ')'
						)
						)
					) {
				//	if ?' then split into last char and end quote
				if (exp_token.length() >= 2 && exp_token.charAt(1) == '\'') {
					setc_value = exp_token.substring(0,1);
					opt_gen_pc_concat(pc_op_pushc);
					exp_stk_setc[tot_exp_stk_var - 1] = exp_stk_setc[tot_exp_stk_var - 1].concat(setc_value);
					exp_start_index = exp_next_index - exp_token.length() + 1;  // RPI-274
					exp_match = exp_pattern.matcher(exp_text.substring(exp_start_index));
					exp_var_last = true;
				} else { // concatenate token string chars
					setc_value = exp_token;
					opt_gen_pc_concat(pc_op_pushc);
					if (exp_prev_first == exp_create_set_op
							&& exp_next_first != ')') {
						flush_pc_pending();
					}
					setc_value = exp_stk_setc[tot_exp_stk_var - 1].concat(setc_value);
					exp_stk_setc[tot_exp_stk_var - 1] = setc_value;
					exp_var_last = true;
				}
			// else get var or op from next token
			} else {
				exp_set_next_token();
			}
		}
	}

	/**
	 * Set next token and op to exp_term_op.
	 */
	private void exp_set_term_op()
	{
		exp_token = "" + exp_term_op;
		exp_next_first = exp_term_op;
		exp_next_class = exp_class_term;
	}

	/**
	 * Set op from exp_next_op.
	 */
	private void exp_set_next_token()
	{
		exp_next_op = exp_next_op.toUpperCase();
		switch (exp_next_op.charAt(0)) {
		case '0':
		case '1':
		case '2':
		case '3':
		case '4':
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			setc_value = exp_token;
			exp_push_sdt();
			opt_gen_pc_pusha();
			break;
		case '+':
		case '-':
			if (exp_var_pushed == false  // RPI-171
					&& exp_prev_first != exp_string_op
					&& exp_prev_first != exp_create_set_op) {
				exp_token = "U" + exp_token;     // RPI-171 make unary oper
				exp_next_class = exp_class_oper; // RPI-171
				exp_next_first = 'U';
			} else {
				exp_next_class = exp_class_add_sub;
			}
			break;
		case '*':
			if (exp_var_pushed) {
				exp_next_class = exp_class_mpy_div;
			} else {
				setc_value = "0";
				exp_push_sdt();  // RPI-340
				opt_gen_pc_pusha();
			}
			break;
		case '/':
			exp_next_class = exp_class_mpy_div;
			break;
		case '(':
			exp_next_class = exp_class_open;
			break;
		case ')':
			if (exp_level == 0) {
				// not string, subscript, or create_set
				exp_set_term_op();
			} else {
				exp_next_class = exp_class_cls_sub;
			}
			break;
		case '.':
			exp_next_class = exp_class_str_op;
			break;
		case ' ':   //asc_space_char
		case '\t':  //tab
		case '\r':  //cr
		case '\n':  //lf
			exp_next_index--; // RPI-181 backup to space
		case '~':
			if (exp_level == 0) { // not string or subscript
				exp_set_term_op();
			} else {
				exp_var_last = true; // ignore (spaces)
			}
			break;
		case '\'':
			exp_next_class = exp_class_str_sub1;
			break;
		case ',':
			if (exp_level == 0) { // not string or subscript
				exp_set_term_op();
			} else {
				exp_next_class = exp_class_str_sub2;
			}
			break;
		case 'A':
			if (exp_next_op.equals("A'")) { // AI'sym = 1 if defined in lookahead
				exp_next_class = exp_class_oper;
			} else if (exp_next_op.equals("AND")) {
				exp_next_class = exp_class_and;
			} else if (exp_next_op.length() == 3
					&& exp_next_op.substring(0,2).equals("A2")) { // RPI-404
				exp_next_class = exp_class_oper;
			} else {
				push_sym();
				exp_var_last = true;
			}
			break;
		case 'B':
			if (exp_next_op.length() > 2
					&& exp_next_op.charAt(exp_next_op.length()-1) == '\'') {
				setc_value = exp_token;
				exp_push_sdt();
				opt_gen_pc_pusha();
			} else if (exp_next_op.length() == 3
					&& exp_next_op.substring(0,2).equals("B2")) { // RPI-404
				exp_next_class = exp_class_oper;
			} else {
				push_sym();
				exp_var_last = true;
			}
			break;
		case 'C':
			if (exp_next_op.length() > 2
					&& (exp_next_op.charAt(exp_next_op.length()-1) == '\''      // RPI-270 CA'..' or CE'..'
						|| exp_next_op.charAt(exp_next_op.length()-1) == '"'    // RPI-5
							|| exp_next_op.charAt(exp_next_op.length()-1) == '!')) { // RPI-84
				setc_value = exp_token;
				exp_push_sdt();
				opt_gen_pc_pusha();
			} else if (exp_next_op.length() == 3
					&& exp_next_op.substring(0,2).equals("C2")) { // RPI-404
				exp_next_class = exp_class_oper;
			} else {
				push_sym();
				exp_var_last = true;
			}
			break;
		case 'D':
			if (exp_next_op.equals("D'")) { // RPI-336
				exp_next_class = exp_class_oper;
			} else if (exp_next_op.equals("DOUBLE")) {
				exp_next_class = exp_class_oper;
			} else if (exp_next_op.equals("DCLEN")) {
				exp_next_class = exp_class_oper;
			} else if (exp_next_op.equals("DCVAL")) {
				exp_next_class = exp_class_oper;
			} else if (exp_next_op.equals("DEQUOTE")) { // RPI-886
				exp_next_class = exp_class_oper;
			} else if (exp_next_op.length() == 3
					&& exp_next_op.substring(0,2).equals("D2")) { // RPI-404
				exp_next_class = exp_class_oper;
			} else {
				push_sym();
				exp_var_last = true;
			}
			break;
		case 'E':
			if (exp_next_op.equals("EQ")) {
				exp_next_class = exp_class_comp;
			} else {
				push_sym();
				exp_var_last = true;
			}
			break;
		case 'F':
			if (exp_next_op.equals("FIND")) {
				exp_next_class = exp_class_str_op;
			} else {
				push_sym();
				exp_var_last = true;
			}
			break;
		case 'G':
			if (exp_next_op.equals("GE")) {
				exp_next_class = exp_class_comp;
			} else if (exp_next_op.equals("GT")) {
				exp_next_class = exp_class_comp;
			} else {
				push_sym();
				exp_var_last = true;
			}
			break;
		case 'I':
			if (exp_next_op.equals("I'")) { // I'sym = int value
				exp_next_class = exp_class_oper;
			} else if (exp_next_op.equals("INDEX")) {
				exp_next_class = exp_class_str_op;
			} else if (exp_next_op.length() == 5
					&& exp_next_op.substring(0,2).equals("IS")) { // RPI-404
				exp_next_class = exp_class_oper;
			} else {
				push_sym();
				exp_var_last = true;
			}
			break;
		case 'K':
			if (exp_next_op.equals("K'")) {
				exp_next_class = exp_class_oper;
			} else {
				push_sym();
				exp_var_last = true;
			}
			break;
		case 'L':
			if (exp_next_op.equals("LE")) {
				exp_next_class = exp_class_comp;
			} else if (exp_next_op.equals("LT")) {
				exp_next_class = exp_class_comp;
			} else if (exp_next_op.equals("L'")) {
				exp_next_class = exp_class_oper;
			} else if (exp_next_op.equals("LOWER")) { // RPI-196
				exp_next_class = exp_class_oper;
			} else {
				push_sym();
				exp_var_last = true;
			}
			break;
		case 'N':
			if (exp_next_op.equals("NE")) {
				exp_next_class = exp_class_comp;
			} else if (exp_next_op.equals("NOT")) {
				exp_next_class = exp_class_not;
			} else if (exp_next_op.equals("N'")) {
				exp_next_class = exp_class_oper;
			} else {
				push_sym();
				exp_var_last = true;
			}
			break;
		case 'O':
			if (exp_next_op.equals("OR")) {
				exp_next_class = exp_class_or;
			} else if (exp_next_op.equals("O'")) { // RPI-406
				exp_next_class = exp_class_oper;
			} else {
				push_sym();
				exp_var_last = true;
			}
			break;
		case 'S':
			if (exp_next_op.equals("S'")) { // S'sym = scale factor
				exp_next_class = exp_class_oper;
			} else if (exp_next_op.length() == 6
					&& exp_next_op.equals("SIGNED")) { // RPI-404
				exp_next_class = exp_class_oper;
			} else if (exp_next_op.length() == 3
					&& exp_next_op.equals("SLA")) { // RPI-404
				exp_next_class = exp_class_oper;
			} else if (exp_next_op.length() == 3
					&& exp_next_op.equals("SLL")) { // RPI-404
				exp_next_class = exp_class_oper;
			} else if (exp_next_op.length() == 3
					&& exp_next_op.equals("SRA")) { // RPI-404
				exp_next_class = exp_class_oper;
			} else if (exp_next_op.length() == 3
					&& exp_next_op.equals("SRL")) { // RPI-404
				exp_next_class = exp_class_oper;
			} else if (exp_next_op.length() == 8
						&& exp_next_op.equals("SYSATTRA")) { // RPI-404
				exp_next_class = exp_class_oper;
			} else if (exp_next_op.length() == 8
					&& exp_next_op.equals("SYSATTRP")) { // RPI-404
				exp_next_class = exp_class_oper;
			} else {
				push_sym();
				exp_var_last = true;
			}
			break;
		case 'T':
			if (exp_next_op.equals("T'")) {
				exp_next_class = exp_class_oper;
			} else {
				push_sym();
				exp_var_last = true;
			}
			break;
		case 'U':
			if (exp_next_op.equals("UPPER")) {
				exp_next_class = exp_class_oper;
			} else {
				push_sym();
				exp_var_last = true;
			}
			break;
		case 'X':
			if (exp_next_op.length() > 2 && exp_next_op.charAt(1) == '\'') {
				setc_value = exp_token;
				exp_push_sdt();
				opt_gen_pc_pusha();
			} else if (exp_next_op.equals("XOR")) {
				exp_next_class = exp_class_xor;
			} else if (exp_next_op.length() == 3
					&& exp_next_op.substring(0,2).equals("X2")) { // RPI-404
				exp_next_class = exp_class_oper;
			} else {
				push_sym();
				exp_var_last = true;
			}
			break;  // RPI-340
		default: // RPI-347
			push_sym();
			exp_var_last = true;
			break;
		}
	}

	/**
	 * Perform next exp action based on precedence of exp_next_op and exp_prev_op.
	 * Notes:
	 * If substring set prev_substring else reset after operation.
	 * Used by exp_substring. RPI-214
	 */
	private void exp_perform_op()
	{
		int action = 0;
		if (tz390.opt_traceall) {
			tz390.put_trace("EXP OPS=" + tot_exp_stk_op + " VARS=" + tot_exp_stk_var + " PREV OP = " + exp_prev_op +  " NEXT OP = " + exp_token);
		}
		if  (exp_prev_class == 0) {
			log_error(162,"invalid expression operator class for - " + exp_token);
		} else if (exp_next_class == 0) {
			log_error(163,"invalid expression operator class - " + exp_token);
		} else {
			action = exp_action[tot_classes*(exp_prev_class-1)+exp_next_class-1];
		}
		if (tz390.opt_traceall) {
			tz390.put_trace("EXP OPS=" + tot_exp_stk_op + " VARS=" + tot_exp_stk_var + " ACTION = " + action + " PREV CLASS = " + exp_prev_class + " NEXT CLASS = " + exp_next_class);
		}
		exec_pc_op = false; // RPI-1139
		switch (action) {
		case  1: // + or - add/sub
			exp_pop_op();
			if (exp_prev_first == '+') {
				pc_parm_type = var_pc_seta_stack_type;
				exec_pc_add();
				opt_gen_pc_seta(pc_op_add);
			} else {
				pc_parm_type = var_pc_seta_stack_type;
				exec_pc_sub();
				opt_gen_pc_seta(pc_op_sub);
			}
			break;
		case  2:  // * or / mpy/div
			exp_pop_op();
			if (exp_prev_first == '*') {
				pc_parm_type = var_pc_seta_stack_type;
				exec_pc_mpy();
				opt_gen_pc_seta(pc_op_mpy);
			} else {;
			    pc_parm_type = var_pc_seta_stack_type;
				exec_pc_div();
				opt_gen_pc_seta(pc_op_div);
			}
			break;
		case  3: // (..)
			if (exp_next_first != ',') {  // RPI-647 SKIP COMMAS
				exp_push_op();
			} else {
				break;
			}
			if (exp_next_first == '(') {
				exp_level++;
			} else if (exp_next_first == '\'') {  // RPI-99
				exp_level++;
				exp_push_string("");
			}
			break;
		case  4: // )
			exp_pop_op();
			exp_level--;
			if (exp_level == 0 && aif_op) {  // RPI-314
				exp_set_term_op();
				exp_term();
			} else {
				exp_check_prev_op = false;
				if (exp_next_index < exp_text_len
						&& exp_text.charAt(exp_next_index) == '\'') {;
						exp_token = "DUP"; // RPI-338
						exp_next_class = exp_class_oper;
						exp_push_op();
				}
			}
			break;
		case  5: // 2 operand string operators
			exp_pop_op();
			switch (exp_prev_op.charAt(0)) {
			case '.': // concatenate
				pc_parm_type = var_pc_setc_stack_type;
				exec_pc_concat();
				gen_exp_pc(pc_op_concat);
				break;
			case 'D': // duplicate string
				exec_pc_dup(); // RPI-421
				gen_exp_pc(pc_op_dup);
				break;
			case 'I': // find index in string for
				exec_pc_index();
				gen_exp_pc(pc_op_index);
				break;
			case 'F': // find index of substring in string
				exec_pc_find();
				gen_exp_pc(pc_op_find);
				break;
			default:
				log_error(94,"invalid string operator - " + exp_prev_op);
			}
			break;
		case  6: // ~ terminator
			exp_term();
			break;
		case  7: // logical operator
			exp_pop_op();
			exp_compare();
			break;
		case  8: // '...'(s1,s2) start/end substring text
			/*
			 * if prev op not ' then
			 *    put ' op
			 *    if not prev_substring then  RPI-214
			 *       put null string on stack
			 *    reset prev_substring
			 * else
			 *   if next op is not ( then
			 *       remove ' op leaving setc string
			 *   else
			 *       leave ' op and push , substring op
			 */
			exp_string_quote();
			break;
		case  9: // ,e1, substring e1
			/*
			 * leave e1 on stack and proceed to get e2
			 * and return to case 10 for substring calc
			 * substring setc and e1 now on stack
			 */
			if (exp_next_char() == '*') {  // RPI-257
				setc_value = "*";
				exp_push_sdt();
				opt_gen_pc_pusha();
				skip_next_token();
			} else if (exp_next_char() <= ' ') {
			 	log_error(258,"spaces not allowed in substring notation"); // RPI-944
			}
			break;
		case 10: // ,e2) substring e2
			/*
			 * replace string with substring
			 */
			exp_substring();
			break;
		case 11: // replace &var(sub) with value
			exp_calc_var_sub();
			exp_var_pushed = true; // prevent unary minus
			break;
		case 12: // prefix operator ?'
			exp_perform_prefix_op();
			break;
		case 13: // NOT
			exp_pop_op();
			exec_pc_not();
			gen_exp_pc(pc_op_not);
			break;
		case 14: // AND
			exp_pop_op();
			exec_pc_and();
			gen_exp_pc(pc_op_and);
			break;
		case 15: // OR
			exp_pop_op();
			exec_pc_or();
			gen_exp_pc(pc_op_or);
			break;
		case 16: // XOR
			exp_pop_op();
			exec_pc_xor();
			gen_exp_pc(pc_op_xor);
			break;
		case 17: // process created set &(...)
			exp_level--;  // reduce forced level by 1
			exp_pop_op(); // remove & create op
			exp_check_prev_op = false;
			exp_set_prev_op();
			if (tot_exp_stk_var > 0) {
				exp_token = '&' + get_setc_stack_value().toUpperCase(); // RPI-499 force upper
				exp_push_var();
			} else {
				log_error(103,"missing variable for created set variable");
			}
			break;
		default:
			log_error(38,"expression parsing error - prev op =" + exp_prev_first + " next op =" + exp_next_first); // RPI-260
		}
		if (action == 10) {
			exp_prev_substring = true;
		} else {
			exp_prev_substring = false;
		}
	}

	/**
	 * Perform prefix operator replacing value on stack with result value.
	 */
	private void exp_perform_prefix_op()
	{
		exp_pop_op();
		if (tz390.opt_traceall) {
			tz390.put_trace(" PREFIX OP=" + exp_prev_op + "VARS=" +tot_exp_stk_var);
		}
		if (tot_exp_stk_var < 1 && exp_stk_op[tot_exp_stk_op].charAt(0) != 'U') {
			log_error(175,"missing argument for prefix operator");
			return;
		}
		switch (exp_prev_first) {
		case 'A': // A2? convert from value  RPI-404
			if (exp_stk_op[tot_exp_stk_op].equals("A'")) { // RPI-469
				exec_pc_pfx_a();
				gen_exp_pc(pc_op_pfx_a);
			} else if (exp_stk_op[tot_exp_stk_op].equals("A2B")) {
				exec_pc_a2b();
				gen_exp_pc(pc_op_a2b);
			} else if (exp_stk_op[tot_exp_stk_op].equals("A2C")) {
				exec_pc_a2c();
				gen_exp_pc(pc_op_a2c);
			} else if (exp_stk_op[tot_exp_stk_op].equals("A2D")) {
				exec_pc_a2d();
				gen_exp_pc(pc_op_a2d);
			} else if (exp_stk_op[tot_exp_stk_op].equals("A2X")) {
				exec_pc_a2x();
				gen_exp_pc(pc_op_a2x);
			} else {
				log_error(176,"invalid prefix operator");
			}
			break;
		case 'B': // B2A - convert '010' to 2 etc.  RPI-404
			if (exp_stk_op[tot_exp_stk_op].equals("B2A")) {
				exec_pc_b2a();
				gen_exp_pc(pc_op_b2a);
			} else if (exp_stk_op[tot_exp_stk_op].equals("B2C")) {
				exec_pc_b2c();
				gen_exp_pc(pc_op_b2c);
			} else if (exp_stk_op[tot_exp_stk_op].equals("B2D")) {
				exec_pc_b2d();
				gen_exp_pc(pc_op_b2d);
			} else if (exp_stk_op[tot_exp_stk_op].equals("B2X")) {
				exec_pc_b2x();
				gen_exp_pc(pc_op_b2x);
			} else {
				log_error(177,"invalid prefix operator");
			}
			break;
		case 'C': // C2A - convert '1' to 241 etc.  RPI-404
			if (exp_stk_op[tot_exp_stk_op].equals("C2A")) {
				exec_pc_c2a();
				gen_exp_pc(pc_op_c2a);
			} else if (exp_stk_op[tot_exp_stk_op].equals("C2B")) {
				exec_pc_c2b();
				gen_exp_pc(pc_op_c2b);
			} else if (exp_stk_op[tot_exp_stk_op].equals("C2D")) {
				exec_pc_c2d();
				gen_exp_pc(pc_op_c2d);
			} else if (exp_stk_op[tot_exp_stk_op].equals("C2X")) {
				exec_pc_c2x();
				gen_exp_pc(pc_op_c2x);
			} else {
				log_error(181,"invalid prefix operator");
			}
			break;
		case 'D':
			if (exp_stk_op[tot_exp_stk_op].equals("D'")) {// RPI-336
				exec_pc_pfx_d();
				gen_exp_pc(pc_op_pfx_d);
			} else if (exp_stk_op[tot_exp_stk_op].equals("D2A")) {
				exec_pc_d2a();
				gen_exp_pc(pc_op_d2a);
			} else if (exp_stk_op[tot_exp_stk_op].equals("D2B")) {
				exec_pc_d2b();
				gen_exp_pc(pc_op_d2b);
			} else if (exp_stk_op[tot_exp_stk_op].equals("D2C")) {
				exec_pc_d2c();
				gen_exp_pc(pc_op_d2c);
			} else if (exp_stk_op[tot_exp_stk_op].equals("D2X")) {
				exec_pc_d2x();
				gen_exp_pc(pc_op_d2x);
			} else if (exp_stk_op[tot_exp_stk_op].equals("DUP")) {// RPI-338
				exec_pc_dup();	// RPI-421
				gen_exp_pc(pc_op_dup);
			} else if (exp_stk_op[tot_exp_stk_op].equals("DOUBLE")) {
				exec_pc_double();
				gen_exp_pc(pc_op_double);
			} else if (exp_stk_op[tot_exp_stk_op].equals("DCLEN")) {
				exec_pc_dclen();
				gen_exp_pc(pc_op_dclen);
			} else if (exp_stk_op[tot_exp_stk_op].equals("DCVAL")) {
				exec_pc_dcval();
				gen_exp_pc(pc_op_dcval);
			} else if (exp_stk_op[tot_exp_stk_op].equals("DEQUOTE")) {  // RPI-886
				exec_pc_dequote(); // RPI-886
				gen_exp_pc(pc_op_dequote);  // RPI-886
			} else {
				log_error(182,"undefined prefix operator");
			}
			break;
		case 'I': // i'. ISBIN, ISDEC, ISHEX
			if (exp_stk_op[tot_exp_stk_op].equals("I'")) {// I'sym returns integer value
				exec_pc_pfx_i();
				gen_exp_pc(pc_op_pfx_i);
			} else if (exp_stk_op[tot_exp_stk_op].equals("ISBIN")) {
				exec_pc_isbin();
				gen_exp_pc(pc_op_isbin);
			} else if (exp_stk_op[tot_exp_stk_op].equals("ISDEC")) {
				exec_pc_isdec();
				gen_exp_pc(pc_op_isdec);
			} else if (exp_stk_op[tot_exp_stk_op].equals("ISHEX")) {
				exec_pc_ishex();
				gen_exp_pc(pc_op_ishex);
			} else if (exp_stk_op[tot_exp_stk_op].equals("ISSYM")) {
				exec_pc_issym();
				gen_exp_pc(pc_op_issym);
			}
			break;
		case 'K': // K'var returns character count
			exec_pc_pfx_k();
			gen_exp_pc(pc_op_pfx_k);
			break;
		case 'L':
			if (exp_stk_op[tot_exp_stk_op].equals("L'")) {// L'sym returns length attribute
				exec_pc_pfx_l();
				gen_exp_pc(pc_op_pfx_l);
			} else { // LOWER  RPI-196
				exec_pc_lower();
				gen_exp_pc(pc_op_lower);
			}
			break;
		case 'N': // N'var returns sublist count or max array store subscript
			exec_pc_pfx_n();
			gen_exp_pc(pc_op_pfx_n);
			break;
		case 'O': // O'opcode returns opcode attribute  // RPI-405
			exec_pc_pfx_o();
			gen_exp_pc(pc_op_pfx_o);
			break;
		case 'S': // SIGNED value returns string with sign
			if (exp_stk_op[tot_exp_stk_op].equals("S'")) {// S'sym returns scale
				exec_pc_pfx_s();
				gen_exp_pc(pc_op_pfx_s);
			} else if (exp_stk_op[tot_exp_stk_op].equals("SIGNED")) {
				exec_pc_signed();
				gen_exp_pc(pc_op_signed);
			} else if (exp_stk_op[tot_exp_stk_op].equals("SLA")) {
				exec_pc_sla();
				gen_exp_pc(pc_op_sla);
			} else if (exp_stk_op[tot_exp_stk_op].equals("SLL")) {
				exec_pc_sll();
				gen_exp_pc(pc_op_sll);
			} else if (exp_stk_op[tot_exp_stk_op].equals("SRA")) {
				exec_pc_sra();
				gen_exp_pc(pc_op_sra);
			} else if (exp_stk_op[tot_exp_stk_op].equals("SRL")) {
				exec_pc_srl();
				gen_exp_pc(pc_op_srl);
			} else if (exp_stk_op[tot_exp_stk_op].equals("SYSATTRA")) {
				exec_pc_sattra();
				gen_exp_pc(pc_op_sattra);
			} else if (tz390.opt_asm && exp_stk_op[tot_exp_stk_op].equals("SYSATTRP")) {
				exec_pc_sattrp();
				gen_exp_pc(pc_op_sattrp);
			} else {
				log_error(183,"undefined prefix operator");
			}
			break;
		case 'T': // T'sym returns type attribute as setc
			exec_pc_pfx_t();
			gen_exp_pc(pc_op_pfx_t);
			break;
		case 'U':
			if (exp_stk_op[tot_exp_stk_op].equals("UPPER")) { // UPPER RPI-196
				exec_pc_upper();
				gen_exp_pc(pc_op_upper);
			} else {
				exp_unary_op();
			}
			break;
		case 'X':
			if (exp_stk_op[tot_exp_stk_op].equals("X2A")) {
				exec_pc_x2a();
				gen_exp_pc(pc_op_x2a);
			} else if (exp_stk_op[tot_exp_stk_op].equals("X2B")) {
				exec_pc_x2b();
				gen_exp_pc(pc_op_x2b);
			} else if (exp_stk_op[tot_exp_stk_op].equals("X2C")) {
				exec_pc_x2c();
				gen_exp_pc(pc_op_x2c);
			} else if (exp_stk_op[tot_exp_stk_op].equals("X2D")) {
				exec_pc_x2d();
				gen_exp_pc(pc_op_x2d);
			} else if (exp_stk_op[tot_exp_stk_op].equals("B2X")) {
				seta_value = Integer.valueOf(get_setc_stack_value(),2);
				setc_value = Integer.toString(seta_value,16).toUpperCase();
				setc_value = ("00000000" + setc_value).substring(setc_value.length());
				put_setc_stack_var();
			} else {
				log_error(177, "Invalid prefix operator.");
			}
			break;
		}
	}

	/**
	 * Execute unary operator U+ or U-
	 */
	private void exp_unary_op()
	{
		if (exp_stk_op[tot_exp_stk_op].charAt(1) == '-') {
			if (exp_var_pushed) {
				exec_pc_ucomp();
				if (pc_pusha_pending) {
					tot_pc_gen_opt++;
					seta_value = - pc_pusha_seta_value;
					pc_pusha_seta_value  = seta_value;
					pc_pusha_setc_value  = "-" + pc_pusha_setc_value;
				} else {
					gen_exp_pc(pc_op_ucomp);
				}
			} else if (exp_stk_op[tot_exp_stk_op].charAt(0) == 'U') {
				if (exp_token.charAt(1) == exp_stk_op[tot_exp_stk_op].charAt(1)) {
					exp_token = "U+";
				} else {
					exp_token = "U-";
				}
			} else {
				log_error(124,"missing unary operator value");
			}
		}
	}

	/**
	 * Add top of stack value to prev. value and pop the top stack value off.
	 */
	private void exec_pc_add()
	{
		get_pc_parms();
		seta_value = seta_value1 + seta_value2;
		if (tz390.opt_tracem) { // RPI-1212
			tz390.put_trace("ADD " + seta_value + " = " + seta_value1  + " + " + seta_value2);
		}
		put_seta_stack_var();
	}

	/**
	 * Sub top of stack value from previous value and pop the top stack value off.
	 */
	private void exec_pc_sub()
	{
		get_pc_parms();
		seta_value = seta_value1 - seta_value2;
		if (tz390.opt_tracem) { // RPI-1212
			tz390.put_trace("SUB " + seta_value + " = " + seta_value1  + " - " + seta_value2);
		}
		put_seta_stack_var();
	}

	/**
	 * Multiply top of stack value to previous value and pop the top stack value off.
	 */
	private void exec_pc_mpy()
	{
		get_pc_parms();
		seta_value = seta_value1 * seta_value2;
		if (tz390.opt_tracem) { // RPI-1212
			tz390.put_trace("MPY " + seta_value + " = " + seta_value1  + " * " + seta_value2);
		}
		put_seta_stack_var();
	}

	/**
	 * Divide top of stack value into previous value and pop the top stack value off.
	 */
	private void exec_pc_div()
	{
		get_pc_parms();
		if (seta_value2 != 0) {
			seta_value = seta_value1 / seta_value2;
		} else {
			seta_value = 0; // by definition for HLASM
		}
		if (tz390.opt_tracem) { // RPI-1212
			tz390.put_trace("DIV " + seta_value + " = " + seta_value1  + " / " + seta_value2);
		}
		put_seta_stack_var();
	}

	/**
	 * Concatenate two variables on stack.
	 */
	private void exec_pc_concat()
	{
		get_setc_stack_values();
		setc_value = setc_value1.concat(setc_value2);
		if (tz390.opt_tracem) { // RPI-1212
			tz390.put_trace("CONCAT " + setc_value + " = " + setc_value1  + " . " + setc_value2);
		}
		if (inc_tot_exp_stk_var()) {
			exp_stk_val_type[tot_exp_stk_var - 1] = val_setc_type;
			exp_stk_setc[    tot_exp_stk_var - 1] =     setc_value;
		}
	}

	/**
	 * Duplicate string on top of stack by value of top-1 count.
	 */
	private void exec_pc_dup() // RPI-421
	{
		if (tot_exp_stk_var > 1) {
			setc_value1 = get_setc_stack_value();
			seta_value1 = get_seta_stack_value(-1);
			tot_exp_stk_var--;
			setc_value = tz390.get_dup_string(setc_value1,seta_value1);
			if (tz390.opt_tracem) { // RPI-1212
				tz390.put_trace("DUP " + setc_value + " = (" + seta_value1  + ")'" + setc_value1 + "'");
			}
			put_setc_stack_var();
		} else {
			log_error(152, "Missing variable for D' operator.");
		}
	}

	/**
	 * Put index of first occurrence of second string within the first string on top of stack.
	 */
	private void exec_pc_index()
	{
		check_setc_quotes(2); // RPI-1139
		get_setc_stack_values();
		int str1_len = setc_value1.length();
		int str2_len = setc_value2.length();
		seta_value = 0;
		if (str1_len > 0
		 && str2_len > 0
		 && str1_len >= str2_len) {
			boolean str_found = false;
			int index1 = 0;
			while (!str_found
					&& index1 < str1_len - str2_len + 1) {
				if (setc_value1.substring(index1,index1+str2_len).equals(setc_value2)) {
					str_found = true;
					seta_value = index1 + 1;
				}
				index1++;
			}
		}
		if (tz390.opt_tracem) { // RPI-1212
			tz390.put_trace("INDEX " + seta_value + " = " + setc_value2  + " IN " + setc_value1);
		}
		put_seta_stack_var();
	}

	/**
	 * Return seta index of first character in str2 found in str1 on top of stack.
	 */
	private void exec_pc_find()
	{
		check_setc_quotes(2); // RPI-1139
		get_setc_stack_values();
		int str1_len = setc_value1.length();
		int str2_len = setc_value2.length();
		seta_value = 0;
		if (str1_len > 0 && str2_len > 0) {
			boolean str_found = false;
			int index1 = 0;
			while (!str_found && index1 < str1_len) {
				int index2 = 0;
				while (!str_found && index2 < str2_len) {
					if (setc_value1.charAt(index1) == setc_value2.charAt(index2)) {
						str_found = true;
						seta_value = index1 + 1;
					}
					index2++;
				}
				index1++;
			}
		}
		if (tz390.opt_tracem) { // RPI-1212
			tz390.put_trace("FIND " + seta_value + " = " + setc_value2  + " IN " + setc_value1);
		}
		put_seta_stack_var();
	}

	/**
	 * Perform compare EQ,GE,GT,LE,LT, or NE.
	 */
	private void exp_compare()
	{
		pc_parm_type = var_pc_seta_stack_type;
		if (exp_prev_op.equals("EQ")) {
			exec_pc_compeq();
			opt_gen_pc_comp(pc_op_compeq);
		} else if  (exp_prev_op.equals("GE")) {
			exec_pc_compge();
			opt_gen_pc_comp(pc_op_compge);
		} else if  (exp_prev_op.equals("GT")) {
			exec_pc_compgt();
			opt_gen_pc_comp(pc_op_compgt);
		} else if  (exp_prev_op.equals("LE")) {
			exec_pc_comple();
			opt_gen_pc_comp(pc_op_comple);
		} else if  (exp_prev_op.equals("LT")) {
			exec_pc_complt();
			opt_gen_pc_comp(pc_op_complt);
		} else if  (exp_prev_op.equals("NE")) {
			exec_pc_compne();
			opt_gen_pc_comp(pc_op_compne);
		}
	}

	/**
	 * Compare setc_value1 and setc_value2 in EBCDIC and return -1, 0, or 1 for low, equal, high.
	 * Notes:
	 * If length not equal, the shorter length operand is treated as lower. RPI-462
	 *
	 * @return
	 */
	private int setc_compare()
	{
		int len1 = setc_value1.length();
		int len2 = setc_value2.length();
		if (len1 < len2) { // RPI-462
			return -1;
		} else if (len1 > len2) {
			return 1;
		}
		int index = 0;
		while (index < len1
			&& setc_value1.charAt(index)
			== setc_value2.charAt(index)) {
			index++;
		}
		if (index < len1) {
			if (tz390.opt_ascii) {
				if (setc_value1.charAt(index) > setc_value2.charAt(index)) {
					return 1;
				} else {
					return -1;
				}
			} else {
				if (  (tz390.ascii_to_ebcdic[setc_value1.charAt(index) & 0xff] & 0xff)
					> (tz390.ascii_to_ebcdic[setc_value2.charAt(index) & 0xff] & 0xff)) { // RPI-422
					return 1;
				} else {
					return -1;
				}
			}
		} else {
			return 0; // RPI-462
		}
	}

	/**
	 * Perform logical not operation on stk var.
	 */
	private void exec_pc_not()
	{
		if (tot_exp_stk_var > 0) {
			seta_value1 =  get_seta_stack_value(-1);
			seta_value  = ~ seta_value1;
			switch (exp_stk_val_type[tot_exp_stk_var - 1]) {
			case 1: // not seta
				exp_stk_seta[tot_exp_stk_var - 1] = seta_value;
				break;
			case 2: // not setb
				if (seta_value1 != 1) { // RPI-147 ??
					setb_value = 1;
				} else {
					setb_value = 0;
				}
				exp_stk_setb[tot_exp_stk_var - 1] = setb_value;
				seta_value = setb_value;
				break;
			case 3: // not setc
				exp_stk_val_type[tot_exp_stk_var - 1] = val_setb_type;
				if (seta_value1 != 1) { // RPI-147
					setb_value = 1;
				} else {
					setb_value = 0;
				}
				exp_stk_seta[tot_exp_stk_var - 1] = seta_value;
				seta_value = setb_value;
				break;
			}
		} else {
			log_error(78,"missing NOT operand");
		}
		if (tz390.opt_tracem) { // RPI-1212
			tz390.put_trace("NOT " + seta_value + " = NOT " + seta_value1);
		}
	}

	/**
	 * Perform logical and operation on stk vars.
	 */
	private void exec_pc_and()
	{
		if (tot_exp_stk_var > 1) {
			seta_value1 = get_seta_stack_value(-2);
			seta_value2 = get_seta_stack_value(-1);
			seta_value = seta_value1 & seta_value2;
			switch (exp_stk_val_type[tot_exp_stk_var - 2]) {
			case 1: // and seta
				exp_stk_seta[tot_exp_stk_var - 2] = seta_value;
				break;
			case 2: // and setb
				setb_value = (byte) seta_value;
				exp_stk_setb[tot_exp_stk_var - 2] = setb_value;
				break;
			case 3: // and setc
				exp_stk_val_type[tot_exp_stk_var - 2] = val_setb_type;
				setb_value = (byte) seta_value;
				exp_stk_setb[tot_exp_stk_var - 2] = setb_value;
				break;
			}
			tot_exp_stk_var--;
		} else {
			log_error(79,"missing AND operand");
		}
		if (tz390.opt_tracem) { // RPI-1212
			tz390.put_trace("AND " + seta_value + " = " + seta_value1  + " AND " + seta_value2);
		}
	}

	/**
	 * Perform logical or operation on stk vars.
	 */
	private void exec_pc_or()
	{
		if (tot_exp_stk_var > 1) {
			seta_value1 = get_seta_stack_value(-2);
			seta_value2 = get_seta_stack_value(-1);
			seta_value = seta_value1 | seta_value2;
			switch (exp_stk_val_type[tot_exp_stk_var - 2]) {
			case 1: // or seta
				exp_stk_seta[tot_exp_stk_var - 2] = seta_value;
				break;
			case 2: // or setb
				setb_value = (byte) seta_value;
				exp_stk_setb[tot_exp_stk_var - 2] = setb_value;
				break;
			case 3: // or setc
				exp_stk_val_type[tot_exp_stk_var - 2] = val_setb_type;
				setb_value = (byte) seta_value;
				exp_stk_setb[tot_exp_stk_var - 2] = setb_value;
				break;
			}
			tot_exp_stk_var--;
		} else {
			log_error(80, "Missing OR operand.");
		}
		if (tz390.opt_tracem) { // RPI-1212
			tz390.put_trace("OR " + seta_value + " = " + seta_value1  + " OR " + seta_value2);
		}
	}

	/**
	 * Perform logical xor operation on stk vars.
	 */
	private void exec_pc_xor()
	{
		if (tot_exp_stk_var > 1) {
			seta_value1 = get_seta_stack_value(-2);
			seta_value2 = get_seta_stack_value(-1);
			seta_value = seta_value1 ^ seta_value2;
			switch (exp_stk_val_type[tot_exp_stk_var - 2]) {
			case 1: // xor seta
				exp_stk_seta[tot_exp_stk_var - 2] = seta_value;
				break;
			case 2: // xor setb
				setb_value = (byte) seta_value;
				exp_stk_setb[tot_exp_stk_var - 2] = setb_value;
				break;
			case 3: // xor setc
				exp_stk_val_type[tot_exp_stk_var - 2] = val_setb_type;
				setb_value = (byte) seta_value;
				exp_stk_setb[tot_exp_stk_var - 2] = setb_value;
				break;
			}
			tot_exp_stk_var--;
		} else {
			log_error(81,"missing XOR operand");
		}
		if (tz390.opt_tracem) { // RPI-1212
			tz390.put_trace("XOR " + seta_value + " = " + seta_value1  + " XOR " + seta_value2);
		}
	}

	/**
	 * Start or end string or substring defining setc value for exp_stack.
	 * Note:
	 * If exp_prev_substring_op set then don't put null string on stack.
	 */
	private void exp_string_quote()
	{
		if (exp_prev_first != exp_string_op) {
			exp_string_var++; // RPI-1139
			exp_level++;         // add substring extra level to handel spaces
			exp_push_op();       // push exp_string_op
			if (!exp_prev_substring) { // RPI-214
				exp_push_string(""); // push empty string val
			}
		} else {   // we are in string mode
			if (exp_next_char() == exp_string_op) {
				// Add quote for each 2 inside string
				skip_next_token();
				setc_value = "'";
				opt_gen_pc_concat(pc_op_pushc);
				setc_value = exp_stk_setc[tot_exp_stk_var - 1].concat("" + exp_string_op);
				exp_stk_setc[tot_exp_stk_var - 1] = setc_value;
			} else {
				if (exp_next_char() == '(') {
					flush_pc_pending();
					skip_next_token(); // skip substring (
					exp_stk_op[tot_exp_stk_op - 1] = "" + exp_substring_op;  // replace ' with , substring oper
					exp_stk_op_class[tot_exp_stk_op - 1] = exp_class_str_sub2;
					exp_set_prev_op();
					if (exp_next_char() <= ' '
						|| exp_next_char() == ',') {
						log_error(259,"invalid character in substring notation"); // RPI-944, RPI-1139
					}
				} else {
					exp_pop_op(); // remove ' string op
					exp_check_prev_op = false;
					exp_level--; // no more spaces in '...'
				}
			}
		}
	}

	/**
	 * Replace string, e1, e2 values with substring.
	 */
	private void exp_substring()
	{
		if (tot_exp_stk_var >= 3
			&& tot_exp_stk_op >= 1
			&& (tz390.opt_allow // RPI-1139
				|| exp_stk_val_type[tot_exp_stk_var - 3] == val_setc_type)) {
			exp_pop_op();  // remove , operator
			exp_check_prev_op = false;
			exp_level--;   // remove substring extra level
			exec_pc_substr();
			gen_exp_pc(pc_op_substr);
		} else {
			log_error(51,"invalid substring subscripts");
		}
	}

	/**
	 * Called with var ptr and subscript on stack.
	 *
	 * 1. If subscripted set var replace stack var set ptr with subscripted set value
	 * 2. If subscripted parm var update or replace stack var parm ptr with sublist parm value
	 * 3. Skip trailing . if any
	 */
	private void exp_calc_var_sub()
	{
		var_subscript_calc = true;
		if (tot_exp_stk_var >= 2) {
			setc_value = exp_stk_setc[tot_exp_stk_var - 2];
			if (exp_stk_var_type[tot_exp_stk_var - 2] == var_subscript_type) {
				set_sub = get_seta_stack_value(-1);
				tot_exp_stk_var--;
				var_name_index = exp_stk_var_name_index[tot_exp_stk_var - 1]; // RPI-447
				var_loc        = exp_stk_var_loc[tot_exp_stk_var - 1];        // RPI-447
				tot_exp_stk_var--;
				exec_pc_pushvs();
				switch (var_loc) {
				case 11: // lcl set var(sub)
				case 12: // gbl set var(sub)
					if (var_loc == var_lcl_loc) {
						var_type = lcl_set_type[var_name_index];
						var_name = lcl_set_name[var_name_index];
					} else {
						var_type = gbl_set_type[var_name_index];
						var_name = gbl_set_name[var_name_index];
					}
					exp_check_prev_op = false;
					if (exp_created_var[exp_level-1]) {
						pc_push_var_op = pc_op_pushds;
						exp_created_var[exp_level-1] = false; // RPI-897 missing -1
					} else {
						pc_push_var_op = pc_op_pushvs;
					}
					if (tz390.opt_tracep) {
						pc_push_var_setc_value = get_pc_trace_val(get_val_type(),3);
					}
					exp_level--;
					exp_pop_op();
					if (tot_exp_stk_op >= 1
							&& (exp_stk_op[tot_exp_stk_op - 1].charAt(0) == exp_string_op
									|| exp_stk_op[tot_exp_stk_op - 1].charAt(0) == exp_create_set_op)) {
						exp_append_string();
						opt_gen_pc_concat(pc_push_var_op);
					} else {
						gen_exp_pc(pc_push_var_op);
					}
					exp_check_prev_op = false;
					break;
				case 13: // pos parm var(sub) or var(sub,
				case 14: // kw  parm var(sub) or var(sub,
					var_type = var_parm_type;
					if (var_loc == var_pos_loc) {
						var_name = mac_call_pos_name[var_name_index];
					} else {
						var_name = mac_call_kwd_name[var_name_index];
					}
					if  (exp_next_first == ')') {
						exp_level--;
						exp_pop_op();
						exp_check_prev_op = false;
						exp_stk_val_type[tot_exp_stk_var - 1] = val_setc_type;
						exp_stk_setc[tot_exp_stk_var - 1] = setc_value;
						if (var_loc == var_pos_loc) {
							var_name = mac_call_pos_name[var_name_index];
						} else {
							var_name = mac_call_kwd_name[var_name_index];
						}
						if (tz390.opt_traceall) {
							if (var_loc == var_pos_loc) {
								tz390.put_trace("POS PARM " + var_name + "=" + setc_value);
							} else {
								tz390.put_trace("KEY PARM " + var_name + "=" + setc_value);
							}
						}
						if (tot_exp_stk_op >= 1
								&& (exp_stk_op[tot_exp_stk_op - 1].charAt(0) == exp_string_op
										|| exp_stk_op[tot_exp_stk_op - 1].charAt(0) == exp_create_set_op)) {
							exp_append_string();
							opt_gen_pc_concat(exp_sublst_op);
						} else {
							gen_exp_pc(exp_sublst_op);
						}
						exp_sublst_op = pc_op_pushvs;
					} else {
						exp_stk_setc[tot_exp_stk_var - 1] = setc_value; // update sublist string for next index
					}
					break;
				case 15: // syslist(sub) or syslist(sub,
					var_type = var_sublist_type;
					var_name = "&SYSLIST";
					if  (exp_next_first == ')') {
						exp_level--;
						exp_pop_op();
						exp_check_prev_op = false;
						exp_stk_val_type[tot_exp_stk_var - 1] = val_setc_type;
						exp_stk_setc[tot_exp_stk_var - 1] = setc_value;
						pc_push_var_setc_value = "'" + setc_value + "'";
						if (tot_exp_stk_op >= 1
								&& (exp_stk_op[tot_exp_stk_op - 1].charAt(0) == exp_string_op
										|| exp_stk_op[tot_exp_stk_op - 1].charAt(0) == exp_create_set_op)) {
							exp_append_string();
							opt_gen_pc_concat(exp_sublst_op);
						} else {
							gen_exp_pc(exp_sublst_op);
						}
						exp_sublst_op = pc_op_pushvs;
					} else {
						exp_stk_seta[tot_exp_stk_var - 1] = var_name_index;
						exp_stk_setc[tot_exp_stk_var - 1] = setc_value;
						gen_exp_pc(exp_sublst_op);
						exp_sublst_op = pc_op_sublst;
					}
					break;
				}
			} else if (exp_stk_var_type[tot_exp_stk_var - 2] == var_sublist_type) { // RPI-447
				var_type = var_sublist_type;
				exec_pc_sublst();
				if  (exp_next_first == ')') {
					exp_level--;
					exp_pop_op();
					exp_check_prev_op = false;  // RPI-60
					exp_stk_var_type[tot_exp_stk_var - 1] = var_parm_type;  // RPI-447
					exp_stk_var_loc[tot_exp_stk_var -1] = var_loc;
					exp_stk_var_name_index[tot_exp_stk_var -1] = var_name_index;
					if (tot_exp_stk_op >= 1
							&& (exp_stk_op[tot_exp_stk_op - 1].charAt(0) == exp_string_op
									|| exp_stk_op[tot_exp_stk_op - 1].charAt(0) == exp_create_set_op)) {
						exp_append_string();
						opt_gen_pc_concat(exp_sublst_op);
					} else {
						gen_exp_pc(exp_sublst_op);
					}
				} else {
					gen_exp_pc(exp_sublst_op);
				}
			}
			exp_stk_var_type[tot_exp_stk_var-1] = var_type;
		} else {
			log_error(54,"invalid subscripted variable");
		}
		if (exp_next_char() == '.') {  // RPI-528
			skip_next_token();  // skip trailing . in string substitution
		}
		var_subscript_calc = false;
	}

	/**
	 * Append var on top of stack to string var.
	 */
	private void exp_append_string()
	{
		setc_value1 = exp_stk_setc[tot_exp_stk_var - 2];
		switch (exp_stk_val_type[tot_exp_stk_var - 1]) {
		case 1:
			setc_value2 = "" + exp_stk_seta[tot_exp_stk_var - 1];
			break;
		case 2:
			setc_value2 = "" + exp_stk_setb[tot_exp_stk_var - 1];
			break;
		case 3:
			setc_value2 = exp_stk_setc[tot_exp_stk_var - 1];
			break;
		default:
			tz390.abort_case();
		}
		setc_value = setc_value1 + setc_value2;
		exp_stk_setc[tot_exp_stk_var - 2] = setc_value;
		tot_exp_stk_var--;
	}

	/**
	 * Return next char in expression else terminator.
	 * @return
	 */
	private char exp_next_char()
	{
		if (exp_next_index < exp_text_len) {
			return exp_text.charAt(exp_next_index);
		} else {
			return '~';
		}
	}

	/**
	 * Skip next token.
	 */
	private void skip_next_token()
	{
		if (exp_match.find()) {
			exp_token = exp_match.group();
			exp_next_index = exp_start_index + exp_match.end();
		}
	}

	/**
	 * Add true or false setb to stack.
	 * @param compare_result
	 */
	private void set_compare(boolean compare_result)
	{
		if (inc_tot_exp_stk_var()) {
			exp_stk_val_type[tot_exp_stk_var - 1] = val_setb_type;
			if (compare_result) {
				exp_set_compare = 1;
			} else {
				exp_set_compare = 0;
			}
			setb_value = exp_set_compare;
			exp_stk_setb[tot_exp_stk_var - 1] = setb_value;
			if (tz390.opt_traceall) {
				switch (val_type1) { // RPI-682
				case 1:
					tz390.put_trace("COMPARE " + seta_value1 + " "+ exp_prev_op  + " " + seta_value2 + " = " + exp_stk_setb[tot_exp_stk_var -1]);
					break;
				case  2:
					tz390.put_trace("COMPARE " + setb_value1 + " "+ exp_prev_op  + " " + setb_value2 + " = " + exp_stk_setb[tot_exp_stk_var -1]);
					break;
				case  3:
					tz390.put_trace("COMPARE '" + setc_value1 + "' "+ exp_prev_op  + " '" + setc_value2 + "' = " + exp_stk_setb[tot_exp_stk_var -1]);
					break;
				default:
					tz390.abort_case();
				}
			}
		}
	}

	/**
	 * if not over max
	 *    inc tot_exp_stk_var
	 *    and init stk name index -1
	 * else
	 *    abort and return false
	 *
	 * @return
	 */
	private boolean inc_tot_exp_stk_var()
	{
		if (tot_exp_stk_var < max_exp_stk) {
			exp_var_pushed = true;
			tot_exp_stk_var++;
			exp_stk_var_name_index[tot_exp_stk_var-1] = -1; // RPI-833
			return true;
		} else {
			abort_error(19, "Exp variable stack exceeded.");
			return false;
		}
	}

	/**
	 * Get set values from stack and pc_seta or pc_setc based on pc_parm_type.
	 * Set val_type1 as follows:
	 * 1.  If either is setb, make setb
	 * 2.  If either is seta, make seta
	 * 3.  else setc
	 */
	private void get_compare_values()
	{
		if  (tot_exp_stk_var >=1) {
			switch (pc_parm_type) {
			case 32: // var_pc_seta_sdt_type) {
				if (exp_stk_val_type[tot_exp_stk_var-1] == val_setb_type) {
					setb_value1 = get_setb_stack_value(-1);
					tot_exp_stk_var--;
					setb_value2 = (byte) pc_seta[pc_loc];
					val_type1 = val_setb_type;
				} else {
					seta_value1 = get_seta_stack_value(-1);
					tot_exp_stk_var--;
					seta_value2 = pc_seta[pc_loc];
					val_type1 = val_seta_type;
				}
				break;
			case 36: // var_pc_setc_sdt_type) {
				if (exp_stk_val_type[tot_exp_stk_var-1] == val_setb_type) {
					setb_value1 = get_setb_stack_value(-1);
					tot_exp_stk_var--;
					setb_value2 = (byte) get_seta_string_value(pc_setc[pc_loc]);
					val_type1 = val_setb_type;
				} else if (exp_stk_val_type[tot_exp_stk_var-1] == val_seta_type) {
					seta_value1 = get_seta_stack_value(-1);
					tot_exp_stk_var--;
					seta_value2 = get_seta_string_value(pc_setc[pc_loc]);
					val_type1 = val_seta_type;
				} else {
					setc_value1 = get_setc_stack_value();
					setc_value2 = pc_setc[pc_loc];
					val_type1 = val_setc_type;
				}
				break;
			case 31: // var_pc_seta_stack_type (set by flush opt_pc_pusha)
			case 35: // var_pc_setc_stack_type (set by flush opt_pc_pushc)
				if (tot_exp_stk_var >= 2) {
					val_type1 = exp_stk_val_type[tot_exp_stk_var - 2];
					val_type2 = exp_stk_val_type[tot_exp_stk_var - 1];
					switch (val_type1) {
					case 1: // seta
						if (val_type2 == val_setb_type) {
							get_setb_stack_values();
						} else {
							get_seta_stack_values();
						}
						break;
					case 2: // setb
						get_setb_stack_values();
						break;
					case 3: // setc
						if (val_type2 == val_setb_type) {
							get_setb_stack_values();
						} else if (val_type2 == val_seta_type) {
							get_seta_stack_values();
						} else {
							get_setc_stack_values();
						}
						break;
					default:
						tz390.abort_case();
					}
				} else {
					log_error(63,"expression compare error");
				}
				break;
			default:
				abort_pc("invalid compare parm type");
			}
		} else {
			log_error(63,"expression compare error");
		}
	}

	/**
	 * Get seta_value1 & 2 from top of stack and remove from stack.
	 */
	private void get_seta_stack_values()
	{
		val_type1 = val_seta_type;
		val_type2 = val_seta_type;
		if (tot_exp_stk_var >= 2) {
			seta_value1 = get_seta_stack_value(-2);
			seta_value2 = get_seta_stack_value(-1);
		} else {
			log_error(187, "Expression missing value error.");
			tot_exp_stk_var = 2;
		}
		tot_exp_stk_var = tot_exp_stk_var - 2;
	}

	/**
	 * Return seta value of stk + offset without removing.
	 *
	 * @param offset
	 * @return
	 */
	private int get_seta_stack_value(final int offset)
	{
		if (tot_exp_stk_var + offset < 0) { // RPI-952
			log_error(264,"stack missing seta value");
			return -1;
		}
		switch (exp_stk_val_type[tot_exp_stk_var + offset]) {
		case 1:
			return exp_stk_seta[tot_exp_stk_var + offset];
		case 2:
			return exp_stk_setb[tot_exp_stk_var + offset];
		case 3:
			return get_seta_string_value(exp_stk_setc[tot_exp_stk_var + offset]);
		default:
			log_error(53,"expression type error");
		}
		return 0;
	}

	/**
	 * Return int value of string using symbol table value if found else numeric value else 0.
	 *
	 * @param text
	 * @return
	 */
	private int get_seta_string_value(String text)
	{
		if (text.length() > 0
			&& ((text.charAt(0) >= '0' && text.charAt(0) <= '9')
				|| text.charAt(0) == '-'
				|| text.charAt(0) == '+')) {
			return get_int_from_string(text,10);
		} else {
			final int index = mz390_find_sym(text);
			if (index >= 0) { // RPI-449
				return az390.sym_loc[index];
			} else {
				return 0;
			}
		}
	}

	/**
	 * Return setb value of stk + offset without removing.
	 *
	 * @param offset
	 * @return
	 */
	private byte get_setb_stack_value(int offset)
	{
		if (tot_exp_stk_var + offset < 0) { // RPI-952
			log_error(265, "Stack missing setb value.");
			return 0;
		}
		switch (exp_stk_val_type[tot_exp_stk_var + offset]) {
		case 1:
			if (exp_stk_seta[tot_exp_stk_var + offset] != 0) {
				return 1;
			} else {
				return 0;
			}
		case 2:
			return exp_stk_setb[tot_exp_stk_var + offset];
		case 3:
			log_error(213, "Invalid string in SETB expression,"); // RPI-609
			break;
		default:
			log_error(53, "Expression type error.");
		}
		return 0;
	}

	/**
	 * Add seta_value to stack.
	 */
	private void put_seta_stack_var()
	{
		if (inc_tot_exp_stk_var()) {
			exp_stk_val_type[tot_exp_stk_var - 1] = val_seta_type;
			exp_stk_seta[tot_exp_stk_var - 1] = seta_value;
		}
	}

	/**
	 * Add setb_value to stack.
	 */
	private void put_setb_stack_var()
	{
		if (inc_tot_exp_stk_var()) {
			exp_stk_val_type[tot_exp_stk_var - 1] = val_setb_type;
			exp_stk_setb[tot_exp_stk_var - 1] = setb_value;
		}
	}

	/**
	 * Add setc_value to stack.
	 */
	private void put_setc_stack_var()
	{
		if (inc_tot_exp_stk_var()) {
			exp_stk_val_type[tot_exp_stk_var - 1] = val_setc_type;
			exp_stk_setc[tot_exp_stk_var - 1] = setc_value;
		}
	}

	/**
	 * Set setb_value1 & 2 from top of stack
	 */
	private void get_setb_stack_values()
	{
		val_type1 = val_setb_type;
		val_type2 = val_setb_type;
		if (tot_exp_stk_var >= 2) {
			switch (exp_stk_val_type[tot_exp_stk_var - 2]) {
			case 1:
				setb_value1 = (byte) exp_stk_seta[tot_exp_stk_var - 2];
				break;
			case 2:
				setb_value1 = exp_stk_setb[tot_exp_stk_var - 2];
				break;
			case 3:
				log_error(214,"invalid string in SETB expression"); // RPI-609
				break;
			default:
				tz390.abort_case();
			}
			switch (exp_stk_val_type[tot_exp_stk_var - 1]) {
			case 1:
				setb_value2 = (byte) exp_stk_seta[tot_exp_stk_var - 1];
				break;
			case 2:
				setb_value2 = exp_stk_setb[tot_exp_stk_var - 1];
				break;
			case 3:
				log_error(215,"invalid string in SETB expression"); // RPI-609
				break;
			default:
				tz390.abort_case();
			}
			setc_value1 = "" + setb_value1; // for RPI-274 trace
			setc_value2 = "" + setb_value2; // for RPI-274 trace
			tot_exp_stk_var = tot_exp_stk_var - 2;
		} else {
			log_error(18,"expression error");
		}
	}

	/**
	 * Set setc_value1 & 2 from top of stack without removing.
	 */
	private void get_setc_stack_values()
	{
		val_type2 = val_setc_type;
		setc_value2 = get_setc_stack_value();
		val_type1 = val_setc_type;
		setc_value1 = get_setc_stack_value();
	}

	/**
	 * Return setc string from top of stack and remove it.
	 * @return
	 */
	private String get_setc_stack_value()
	{
		if (tot_exp_stk_var >= 1) {
			tot_exp_stk_var--;
			switch (exp_stk_val_type[tot_exp_stk_var]) {
			case 1:
				return "" + exp_stk_seta[tot_exp_stk_var];
			case 2:
				return "" + exp_stk_setb[tot_exp_stk_var];
			case 3:
				return exp_stk_setc[tot_exp_stk_var];
			default:
				tz390.abort_case();
			}
		}
		log_error(20, "Stack missing setc value."); // RPI-952
		return "";
	}

	/**
	 * Put op on stack.
	 */
	private void exp_push_op()
	{
		exp_var_pushed = false;  // RPI-171
		if (tot_exp_stk_op >= max_exp_stk) {
			abort_error(44, "Maximum stack operations exceeded.");
			return;
		}
		if (tz390.opt_traceall) {
			tz390.put_trace("PUSHING OP - " + exp_token + " FROM=" + exp_text.substring(exp_next_index-1));
		}
		exp_stk_op[tot_exp_stk_op] = exp_token.toUpperCase();
		exp_stk_op_class[tot_exp_stk_op] = exp_next_class;
		tot_exp_stk_op++;
		exp_set_prev_op();
	}

	/**
	 * Pop current op on stack.
	 */
	private void exp_pop_op()
	{
		tot_exp_stk_op--;
		if (tz390.opt_traceall) {
			tz390.put_trace("POP OP=" + exp_stk_op[tot_exp_stk_op]);
		}
		if (tot_exp_stk_op < 0) {
			log_error(23, "Expression error.");
		} else {
			exp_check_prev_op = true;
		}
	}

	/**
	 * Terminate expression returning value on stack if no errors.
	 * Note:
	 *   1.  Don't return value if parse_mode.
	 *   2.  Turn off pc_gen_exp.
	 */
	private void exp_term()
	{
		flush_pc_pending();
		if (exp_parse_set_mode) {
			exp_parse_set_mode = false;
			exp_end = true;
			exp_ok  = true;
			return;
		}
		if (tot_exp_stk_var == 1
			&& tot_exp_stk_op == 0
			&& exp_level == 0) {  // RPI-1139
			switch (exp_type) {
			case 1:
				switch (exp_stk_val_type[0]) {
				case 1:
					exp_seta = exp_stk_seta[0];
					break;
				case 2:
					exp_seta = exp_stk_setb[0];
					break;
				case 3:
					exp_seta = get_int_from_string(exp_stk_setc[0],10);
					break;
				default:
					tz390.abort_case();
				}
				break;
			case 2:
				switch (exp_stk_val_type[0]) {
				case 1:
					exp_setb = (byte) exp_stk_seta[0];
					break;
				case 2:
					exp_setb = exp_stk_setb[0];
					break;
				case 3:
					log_error(216,"invalid string in SETB expression"); // RPI-609
					break;
				default:
					tz390.abort_case();
				}
				break;
			case 3:
				switch (exp_stk_val_type[0]) {
				case 1:
					exp_setc = "" + Math.abs(exp_stk_seta[0]); // RPI-943
					break;
				case 2:
					exp_setc = "" + exp_stk_setb[0];
					break;
				case 3:
					exp_setc = exp_stk_setc[0];
					break;
				default:
					tz390.abort_case();
				}
				break;
			}
			exp_end = true;
			exp_ok  = true;
		} else {
			log_error(35,"expression parsing error - total stack values=" + tot_exp_stk_var + "  total ops=" + tot_exp_stk_op); // RPI-260
		}
	}

	/**
	 * Return integer from string using specified base.
	 * Notes:
	 *   1.  return numeric value of string base 10 or 16
	 *   2.  If base 10, ignore trailing non digits
	 *
	 * @param setc_text
	 * @param base
	 * @return
	 */
	private int get_int_from_string(String setc_text,int base)
	{
		if (!tz390.opt_allow && base == 10
			&& setc_text != null && setc_text.length() > 0) { // RPI-1204
			char first = setc_text.trim().charAt(0);
			if (first < '0' || first > '9') {
				return 0;
			}
		}
		try {
			return (int)Long.valueOf(setc_text,base).longValue(); // RPI-1101. RPI-1105
		} catch (final Exception e) {
			if (setc_text == null) {  // RPI-565
				setc_value = "";
				log_error(210, "Invalid SYSLIST numeric reference.");
				return 0;
			}
			if (base == 10) {
				int index = 0;
				int value = 0;
				while (index < setc_text.length()) {
					if (setc_text.charAt(index) >= '0' && setc_text.charAt(index) <= '9') {
						value = value*10 + setc_text.charAt(index) - 0x30;
					} else {
						return value;
					}
					index++;
				}
				return value;
			} else {
				log_error(123, "Invalid hex string - " + setc_text);
				return 0;
			}
		}
	}

	/**
	 * Push var variable on stack.
	 *
	 * if &var followed by ( then put var pointer on value stack and put ) subscript op on op stack
	 * else
	 *    push unscripted var value on value stack and skip trailing . if any.
	 * Notes:
	 *  1. If exp_parse_set_mode, set exp_parse_set_name and exit.
	 *  2. If var value is setc, check for symbol value.
	 */
	private void exp_push_var()
	{
		int index = 0;
		if (tz390.opt_traceall) {
			index = exp_next_index-exp_token.length();
			if (index < 0)index = 0;
			tz390.put_trace("PUSHING VAR - " + exp_token+ " FROM=" + exp_text.substring(index));
		}
		if (find_var(exp_token)) {  // find set or parm var
			if (exp_parse_set_mode && exp_level == 0) {  // RPI-345
				exp_parse_set_mode = false;
				exp_end = true;
				exp_ok = true;
				return;
			}
			if (exp_next_char() == '('
				&& inc_tot_exp_stk_var()) {
				// subscripted var
				flush_pc_pending();
				if (var_type == var_parm_type) {
					exp_stk_var_type[tot_exp_stk_var - 1] = var_sublist_type; // RPI-447
					// put parm to be followd by
					// one or more subs for sublst op
					if (tz390.opt_tracep) {
						pc_push_var_setc_value = get_pc_trace_val(get_val_type(),3);
					}
					gen_exp_pc(pc_op_pushv);
					exp_sublst_op = pc_op_sublst;
				} else {
					exp_stk_var_type[tot_exp_stk_var - 1] = var_subscript_type; // RPI-447
				}
				skip_next_token();
				exp_token = "" + exp_subscript_op;
				exp_next_first = exp_subscript_op;
				exp_next_class = exp_class_cls_sub;
				exp_push_op();  // push ) subscript/sublist op
				exp_level++;
				exp_stk_var_loc[tot_exp_stk_var - 1] = var_loc;                // RPI-447 set/parm loc
				exp_stk_var_name_index[tot_exp_stk_var - 1] = var_name_index;  // RPI-447 set/sub subscript
				exp_stk_setc[tot_exp_stk_var - 1] = setc_value;                // sublist parm
				exp_stk_val_type[tot_exp_stk_var -1] = val_setc_type;          // RPI-447
			} else {
				// scalar var concat or push
				if (exp_prev_first == exp_string_op
					|| exp_prev_first == exp_create_set_op) {
					// concatentate var to string
					if (var_set_array) {  // RPI-836
						log_error(229,"subscript required for " + exp_token);
					}
					exp_concat_var();
					pc_push_var_setc_value = "'" + setc_value2 + "'";
					if (exp_created_var[exp_level]) {
						opt_gen_pc_concat(pc_op_pushd);
						exp_created_var[exp_level] = false;
					} else {
						opt_gen_pc_concat(pc_op_pushv);
					}
					if (tz390.opt_traceall) {
						index = exp_next_index-exp_token.length();
						if (index < 0)index = 0;
						tz390.put_trace("STRING CONCAT - " + exp_token + " = " + exp_stk_setc[tot_exp_stk_var-1]+ " FROM=" + exp_text.substring(index));
					}
				} else if (inc_tot_exp_stk_var()) {
					// push scalar var
					push_pc_var();
					if (exp_created_var[exp_level]) {
						gen_exp_pc(pc_op_pushd);
						exp_created_var[exp_level] = false;
					} else {
						if (var_set_array  // RPI-836
						 && exp_prev_class != exp_class_oper) {
							log_error(230,"subscript required for " + exp_token);
						}
						gen_exp_pc(pc_op_pushv);
					}
				}
				if (exp_next_char() == '.') {
					skip_next_token();  // skip trailing .
				}
			}
		} else {
			if (exp_parse_set_mode) {  // RPI-345
				exp_end = true;
				return;
			}
			log_error(24, "Undefined macro variable - " + exp_token);
		}
	}

	/**
	 * Convert sdt in setc_value to seta_value and push on stack.
	 *
	 * Note:
	 *   1.  Ordinary symbols are pushed as strings for use by prefix operators T', L'.
	 *   2.  "*" pushes max_substring_len
	 */
	private void exp_push_sdt()
	{
		if (tz390.opt_traceall) {
			tz390.put_trace("PUSHING SDT - " + setc_value);
		}
		if (inc_tot_exp_stk_var()
				&& ((setc_value.length() > 1
					&& (setc_value.charAt(setc_value.length()-1) == '\''  // RPI-270
					 || setc_value.charAt(setc_value.length()-1) == '"'   // RPI-5
					 || setc_value.charAt(setc_value.length()-1) == '!')) // RPI-84
				|| (setc_value.charAt(0) <= '9' && setc_value.charAt(0) >= '0')
				||  setc_value.charAt(0) == '*')) {
			exp_stk_val_type[tot_exp_stk_var - 1] = val_seta_type;
			switch (setc_value.substring(0,1).toUpperCase().charAt(0)) {
			case 'B': // B'11000001' binary
				seta_value = get_int_from_string(setc_value.substring(2,setc_value.length()-1),2);
				exp_stk_seta[tot_exp_stk_var-1] = seta_value;
				break;
			case 'C': // RPI-192 C'..'|C".."|C!..! char sdt
				if (!tz390.get_sdt_char_int(setc_value)) {
					log_error(129,"invalid character sdt " + setc_value);
				}
				seta_value = tz390.sdt_char_int;
				exp_stk_seta[tot_exp_stk_var-1] = seta_value;
				break;
			case 'X': // X'C1' hex
				seta_value = Long.valueOf(setc_value.substring(2,setc_value.length()-1),16).intValue();
				exp_stk_seta[tot_exp_stk_var-1] = seta_value;
				break;
			case '*': // return max substring length
				seta_value = max_substring_len;
				exp_stk_seta[tot_exp_stk_var-1] = seta_value;
				break;
			default:  // must be ASCII number
				seta_value = get_int_from_string(setc_value,10);
				exp_stk_seta[tot_exp_stk_var-1] = seta_value;
			}
		} else {
			log_error(195,"invalid self defining term - " + setc_value);
		}
		if (tz390.opt_allow && exp_next_char() == '\'') { // RPI-421 RPI-1139
			exp_token = "DUP";
			exp_next_class = exp_class_oper; // RPI-456
			exp_push_op();
		}
		exp_var_last = true;
	}

	/**
	 * Push current exp_token symbol on stack as setc for use by prefix operators T', L' else get sym_val else 0.
	 */
	private void push_sym()
	{
		flush_pc_pending();
		if (exp_prev_class == exp_class_oper
			|| (exp_prev_class == exp_class_open
				&& tot_exp_stk_op > 1
				&& exp_stk_op_class[tot_exp_stk_op-2] == exp_class_oper)) {
			// push string for class operator
			exp_push_string(exp_token);
		} else {
			if (tz390.opt_asm) {
				setc_value = exp_token;
				exec_pc_pushs();
				gen_exp_pc(pc_op_pushs);
			} else {
				exp_push_string(exp_token);
			}
		}
	}

	/**
	 * Find ordinary symbol and return index else -1
	 * Notes:
	 *  1. Return -1 if not opt_asm
	 *  2. Force az390 to finish last bal and lock az390 until next bal while mz390 accesses symbol table.
	 *
	 * @param symbol
	 * @return
	 */
	private int mz390_find_sym(String symbol)
	{
		if (symbol == null || symbol.length() == 0) {
			return -1;
		}
		int index = symbol.indexOf('.');
		if (index > 0) {
			// skip labeled using if found
			symbol = symbol.substring(index+1); // RPI-419
		}
		symbol_match = symbol_pattern.matcher(symbol);
		if (symbol_match.find()) {
			symbol = symbol_match.group();
		} else {
			return -1;
		}
		if (!tz390.opt_asm) { // RPI-427
			log_error(190, "Ordinary symbol reference requires ASM option - " + symbol);
			return -1;
		} else if (!az390.az390_running) {
			abort_error(189,msg_id + "aborting due to az390 abort");
		}
		if (tz390.opt_traceall) {
			tz390.put_trace(" MZ390 CALLING AZ390 SYM LOCK");
		}
		az390.set_sym_lock("mz390_find for " + symbol + "(" + (mac_file_num[mac_line_index]+1) + "/" + mac_file_line_num[mac_line_index] + ")");
		index = az390.find_sym(symbol);
		az390.reset_sym_lock();
		return index;
	}

	/**
	 * Set macro call label ordinary symbol type to 'M' if currently undefined.
	 *
	 * @param sym_lab
	 */
	private void set_sym_macro_attr(final String sym_lab)
	{
		if (!tz390.opt_asm) return;
		if (tz390.opt_traceall) {
			tz390.put_trace("define type M macro label for " + sym_lab);
		}
		int index = mz390_find_sym(sym_lab);
		if (index == -1) {
			index = az390.add_sym(sym_lab);
		}
		if (index >= 0) {
			if ( (az390.sym_def[index] == az390.sym_def_lookahead
				  ||
				  az390.sym_def[index] == az390.sym_def_ref
				 )
				&&
				 (az390.sym_attr[index] == tz390.ascii_to_ebcdic['U']
				  || az390.sym_attr[index] == tz390.ascii_to_ebcdic['M']
				 )
				) { // RPI-415 lookahead sym def
				az390.sym_attr[index] = tz390.ascii_to_ebcdic['M'];
				az390.sym_def[index] = az390.sym_def_lookahead;
			}
		} else {
			abort_error(188,"Symbol table overflow adding " + sym_lab);
		}
	}

	/**
	 * Return length for ordinary symbol if found else return 1.
	 *
	 * @param symbol
	 * @return
	 */
	private int get_sym_len(final String symbol)
	{
		if (!tz390.opt_asm) {
			return 1;
		}
		int cur_sym = mz390_find_sym(symbol);
		if (cur_sym != -1) {
			if (az390.sym_attr[cur_sym] == tz390.ascii_to_ebcdic['J']) {
				return 1; // RPI-415
			} else {
				return az390.sym_len[cur_sym];
			}
		} else {
			return 1;
		}
	}

	/**
	 * Push string on stack as setc.
	 *
	 * @param value
	 */
	private void exp_push_string(final String value)
	{
		if (inc_tot_exp_stk_var()) {
			exp_stk_val_type[tot_exp_stk_var-1] = val_setc_type;
			setc_value = value;
			exp_stk_setc[tot_exp_stk_var-1] = setc_value;
			opt_gen_pc_pushc();
		}
	}

	/**
	 * Add lcl set variable not found by find_set.
	 *
	 * @param new_name
	 * @param new_type
	 * @param new_size
	 * @param set_array
	 * @return
	 */
	private int add_lcl_set(String new_name,byte new_type,int new_size,boolean set_array) // RPI-1162
	{
		if (tot_lcl_name >= tz390.opt_maxlcl) { // RPI-434
			abort_error(43, "Maximum local variables exceeded. Maximum is " + tz390.opt_maxlcl + " local variables.");
			return -1;
		}
		var_name_index = tot_lcl_name;
		add_lcl_key_index(tot_lcl_name);
		tot_lcl_name++;
		if (tot_lcl_name > hwm_lcl_name) {
			hwm_lcl_name = tot_lcl_name;
		}
		var_loc   = var_lcl_loc;
		var_type  = new_type;
		val_type  = (byte)(var_type - 20);
		set_name  = new_name.toUpperCase();
		lcl_set_name[var_name_index] = set_name;
		lcl_set_type[var_name_index] = var_type;
		if (set_array) { // RPI-1162
			lcl_set_high[var_name_index] = 0; // RPI-343
		} else {
			lcl_set_high[var_name_index] = -1; // RPI-1162 scalar
		}
		switch (var_type) {
		case 21:  // lcl seta
			if (new_size < 1
					|| tot_lcl_seta + new_size >= tz390.opt_maxlcl) {
				abort_error(44,"Lcla size out of range " + set_name + "(" + new_size + ")");
				return -1;
			}
			lcl_set_start[var_name_index] = tot_lcl_seta;
			seta_index = tot_lcl_seta;
			tot_lcl_seta = tot_lcl_seta + new_size;
			if (tot_lcl_seta > hwm_lcl_seta) {
				hwm_lcl_seta = tot_lcl_seta;
			}
			lcl_set_end[var_name_index]   = tot_lcl_seta;
			seta_value = 0;
			if  (seta_index < tot_lcl_seta) {
				Arrays.fill(lcl_seta,seta_index,tot_lcl_seta,seta_value);
			}
			seta_index = lcl_set_start[var_name_index];
			if (tz390.opt_traceall) {
				tz390.put_trace("LCLA " + lcl_set_name[var_name_index] + "(" + new_size + ")");
			}
			break;
		case 22:  // lcl setb
			if (new_size < 1
					|| tot_lcl_setb + new_size >= tz390.opt_maxlcl) {
				abort_error(45,"Lclb size out of range " + set_name + "(" + new_size + ")");
				return -1;
			}
			lcl_set_start[var_name_index] = tot_lcl_setb;
			setb_index = tot_lcl_setb;
			tot_lcl_setb = tot_lcl_setb + new_size;
			if (tot_lcl_setb > hwm_lcl_setb) {
				hwm_lcl_setb = tot_lcl_setb;
			}
			lcl_set_end[var_name_index]   = tot_lcl_setb;
			setb_value = 0;
			if  (setb_index < tot_lcl_setb) {
				Arrays.fill(lcl_setb,setb_index,tot_lcl_setb,setb_value);
			}
			setb_index = lcl_set_start[var_name_index];
			if (tz390.opt_traceall) {
				tz390.put_trace("LCLB " + lcl_set_name[var_name_index] + "(" + new_size + ")");
			}
			break;
		case 23:  // lcl setc
			if (new_size < 1
					|| tot_lcl_setc + new_size >= tz390.opt_maxlcl) {
				abort_error(46,"Lclc size out of range " + set_name + "(" + new_size + ")");
				return -1;
			}
			lcl_set_start[var_name_index] = tot_lcl_setc;
			setc_index = tot_lcl_setc;
			tot_lcl_setc = tot_lcl_setc + new_size;
			if (tot_lcl_setc > hwm_lcl_setc) {
				hwm_lcl_setc = tot_lcl_setc;
			}
			lcl_set_end[var_name_index]   = tot_lcl_setc;
			setc_value = "";
			if  (setc_index < tot_lcl_setc) {
				Arrays.fill(lcl_setc,setc_index,tot_lcl_setc,setc_value);
			}
			setc_index = lcl_set_start[var_name_index];
			if (tz390.opt_traceall) {
				tz390.put_trace("LCLC " + lcl_set_name[var_name_index] + "(" + new_size + ")");
			}
			break;
		default:
			tz390.abort_case();
		return -1;
		}
		return var_name_index;
	}

	/**
	 * Add gbl set variable.
	 *
	 * @param new_name
	 * @param new_type
	 * @param new_size
	 * @param set_array
	 */
	private void add_gbl_set(final String new_name, final byte new_type, final int new_size, final boolean set_array)
	{
		if (tot_gbl_name >= tz390.opt_maxsym) {
			abort_error(55,"Maximum global variables exceeded");
			return;
		}
		var_name_index = tot_gbl_name;
		if (!tz390.add_key_index(var_name_index)) {
			abort_error(174,"Key search table exceeded adding " + new_name);
		}
		tot_gbl_name++;
		var_loc   = var_gbl_loc;
		var_type  = new_type;
		val_type  = (byte)(var_type - 20);
		set_name  = new_name.toUpperCase();
		gbl_set_name[var_name_index] = set_name;
		gbl_set_type[var_name_index] = var_type;
		if (set_array) { // RPI-1162
			gbl_set_high[var_name_index] = 0; // RPI-343
		} else {
			gbl_set_high[var_name_index] = -1; // RPI-1162 scalar
		}
		switch (var_type) {
		case 21:  // gbl seta
			if (new_size < 1
					|| tot_gbl_seta + new_size >= tz390.opt_maxgbl) {
				abort_error(56,"Gbla size out of range " + set_name + "(" + new_size + ")");
				return;
			}
			gbl_set_start[var_name_index] = tot_gbl_seta;
			seta_index = tot_gbl_seta;
			tot_gbl_seta = tot_gbl_seta + new_size;
			gbl_set_end[var_name_index]   = tot_gbl_seta;
			seta_value = 0;
			if  (seta_index < tot_gbl_seta) {
				Arrays.fill(gbl_seta,seta_index,tot_gbl_seta,seta_value);
			}
			seta_index = gbl_set_start[var_name_index];
			if (tz390.opt_traceall) {
				tz390.put_trace("GBLA " + gbl_set_name[var_name_index] + "(" + new_size + ")");
			}
			break;
		case 22:  // gbl setb
			if (new_size < 1
					|| tot_gbl_setb + new_size >= tz390.opt_maxgbl) {
				abort_error(57,"GBLB size out of range " + set_name + "(" + new_size + ")");
				return;
			}
			gbl_set_start[var_name_index] = tot_gbl_setb;
			setb_index = tot_gbl_setb;
			tot_gbl_setb = tot_gbl_setb + new_size;
			gbl_set_end[var_name_index]   = tot_gbl_setb;
			setb_value = 0;
			if  (setb_index < tot_gbl_setb) {
				Arrays.fill(gbl_setb,setb_index,tot_gbl_setb,setb_value);
			}
			setb_index = gbl_set_start[var_name_index];
			if (tz390.opt_traceall) {
				tz390.put_trace("GBLB " + gbl_set_name[var_name_index] + "(" + new_size + ")");
			}
			break;
		case 23:  // gbl setc
			if (new_size < 1
					|| tot_gbl_setc + new_size >= tz390.opt_maxgbl) {
				abort_error(58,"GBLC size out of range " + set_name + "(" + new_size + ")");
				return;
			}
			gbl_set_start[var_name_index] = tot_gbl_setc;
			setc_index = tot_gbl_setc;
			tot_gbl_setc = tot_gbl_setc + new_size;
			gbl_set_end[var_name_index]   = tot_gbl_setc;
			setc_value = "";
			if  (setc_index < tot_gbl_setc) {
				Arrays.fill(gbl_setc,setc_index,tot_gbl_setc,setc_value);
			}
			setc_index = gbl_set_start[var_name_index];
			if (tz390.opt_traceall) {
				tz390.put_trace("GBLC " + gbl_set_name[var_name_index] + "(" + new_size + ")");
			}
			break;
		default:
			tz390.abort_case();
		}
	}

	/**
	 * Parse scalar, subscripted, or created set variable with or without subscript using expression parser in parse_set_var_mode to set:
	 *  1.  exp_parse_set_name
	 *  2.  exp_parse_set_name_index
	 *  3.  exp_parse_set_type (seta/setb/setc)
	 *  4.  exp_parse_set_loc  (lcl/gbl)
	 *  5.  exp_parse_set_sub
	 *  6.  exp_parse_set_created - true/false &(
	 *  7.  exp_parse_set_subscript - true/false
	 * and return true if it exists or false if not.
	 *
	 * Notes:
	 *  1. If var found but exp_parse_set_name is null, then issue error for parms
	 *  2. Used by alloc set with alloc_set_mode to get name and sub for allocation.
	 *  3. Used by store to dynamically alloc undefined name as lcl.
	 *
	 * @param text
	 * @param text_index
	 * @return
	 */
	private boolean parse_set_var(final String text, final int text_index)
	{
		exp_parse_set_mode = true;
		exp_parse_set_name = null;
		exp_parse_set_name_index = -1;
		exp_parse_set_loc  = 0;
		exp_parse_set_type = 0;
		exp_parse_set_subscript = false;
		exp_parse_set_created = false;
		boolean save_pc_gen_exp = pc_gen_exp;
		calc_exp(text,text_index);
		boolean save_exp_ok = exp_ok;
		if (exp_parse_set_name != null
			&& exp_next_index < text.length()
			&& text.charAt(exp_next_index) == '(') {
			exp_parse_set_subscript = true;
			if (save_pc_gen_exp) {
			    pc_gen_exp = true; // gen pc code for subscript store
			}
			if (!tz390.opt_allow && exp_alloc_set_mode) {  // RPI-1139
				exp_parse_set_sub = calc_dimension(text,exp_next_index + 1);
			} else {
				exp_parse_set_sub = calc_seta_exp(text,exp_next_index + 1);
			}
			if (!exp_ok) {
				save_exp_ok = false;
			}
		} else {
			exp_parse_set_sub = 1;
		}
		if (save_exp_ok) {
			if (exp_parse_set_name == null) {
				log_error(104,"set/parm variable conflict - " + text.substring(text_index));
			}
			return true;
		}
		return false;
	}

	/**
	 * Find lcl or gbl set variable else false and set var_name_index = -1 if not found.
	 * Set following globals if found.
	 *
	 * 1.  var_loc   = var_lcl_loc or var_gbl_loc
	 * 2.  var_type  = var_seta_type|var_setb_type|var_setc_type
	 * 3.  var_name_index = for lcl/gbl seta, setb, setc array
	 * 4.  set_sub  = set variable subscript
	 * 5.  seta_value|setb_value|setc_value
	 * 6.  seta_index|setb_index|setc_index
	 * 7.  var_set_array set true if subscripted RPI-836
	 *
	 * Notes:
	 *  1.  Saves create set name for possible scalar allocation for set.
	 *  2.  Global set only found if declared locally or &SYS.
	 *  3.  Both lcl and gbl key index finds ready for add if not found returned.
	 *
	 * @param var_name
	 * @param var_sub
	 * @return
	 */
	private boolean find_set(final String var_name, final int var_sub)
	{
		var_set_array = false;
		if (exp_parse_set_mode
			&& exp_level == 0) {
			exp_parse_set_name = var_name;
		}
		if (find_lcl_set(var_name,var_sub)) {
			if (exp_parse_set_name_index == -1
				&& exp_level == 0) { // RPI-345
				exp_parse_set_name_index = var_name_index;
				exp_parse_set_loc = var_lcl_loc;
				exp_parse_set_type = lcl_set_type[var_name_index];
			}
			if (lcl_set_end[var_name_index]-lcl_set_start[var_name_index] > 1) {
				var_set_array = true; // RPI-836
			}
			return true;
		}
		if (find_gbl_set(var_name,var_sub)) {
			if (find_lcl_key_index("G:" + var_name) == -1
				&& (var_name.length() < 4
					|| !var_name.substring(1,4).equals("SYS"))) {
				find_lcl_key_index("L:" + var_name); // RPI-600 reset local key index for possible local set add
				var_name_index = -1;
				return false;
			}
			if (exp_parse_set_name_index == -1 && exp_level == 0) { // RPI-345
				exp_parse_set_name_index = var_name_index;
				exp_parse_set_loc = var_gbl_loc;
				exp_parse_set_type = gbl_set_type[var_name_index];
			}
			if (gbl_set_end[var_name_index]-gbl_set_start[var_name_index] > 1) {
				var_set_array = true; // RPI-836
			}
			return true;
		}
		var_name_index = -1;
		return false;
	}

	/**
	 * Find lcl variable or label else false also set var_name_index = -1 if not found
	 * set following globals if found
	 *
	 * 1.  var_loc   = var_lcl_loc or var_gbl_loc
	 * 2.  var_type  = var_seta_type|var_setb_type|var_setc_type
	 * 3.  var_name_index = for lcl/gbl seta, setb, setc array
	 * 4.  set_sub = subscript
	 * 5.  seta_value|setb_value|setc_value
	 * 6.  seta_index|setb_index|setc_index
	 *
	 * @param var_name
	 * @param var_sub
	 * @return
	 */
	private boolean find_lcl_set(final String var_name, final int var_sub)
	{
		set_sub = var_sub;
		var_name_index = find_lcl_key_index("L:" + var_name);
		if (var_name_index != -1) {
			var_loc = var_lcl_loc;
			var_type = lcl_set_type[var_name_index];
			get_lcl_set_value();
			return true;
		}
		var_name_index = -1;
		return false;
	}

	/**
	 * Find gbl set variable else false.
	 * Also set var_name_index = -1 if not found.
	 * Set following globals if found:
	 *
	 * 1.  var_loc   = var_lcl_loc or var_gbl_loc
	 * 2.  var_type  = var_seta_type|var_setb_type|var_setc_type
	 * 3.  var_name_index = for lcl/gbl seta, setb, setc array
	 * 4.  set_sub = subscript
	 * 5.  seta_value|setb_value|setc_value
	 * 6.  seta_index|setb_index|setc_index
	 *
	 * @param var_name
	 * @param var_sub
	 * @return
	 */
	private boolean find_gbl_set(final String var_name, final int var_sub)
	{
		var_name_index = tz390.find_key_index('G',var_name);
		if (var_name_index != -1) {
			var_loc = var_gbl_loc;
			var_type = gbl_set_type[var_name_index];
			get_gbl_set_value();
			return true;
		}
		var_name_index = -1;
		return false;
	}

	/**
	 * Set seta/setb/setc_value from lcl set value using:
	 *   var_type
	 *   var_name_index
	 *   set_sub
	 * and set val_type = val_seta/setb/setc_type
	 *
	 * 1.  Calculate seta_index|setb_index|setc_index
	 *     If subscript out of range and alloc mode use previous ending subscript (i.e. first allocation sets size per RPI-126).
	 * 2.  Calculate seta_value|setb_value|setc_value
	 *
	 * Notes:
	 * Requires var_name_index and set_sub
	 */
	private void get_lcl_set_value()
	{
		switch (var_type) {
		case 21:
			val_type = val_seta_type;
			seta_index = lcl_set_start[var_name_index] + set_sub - 1;
			if (seta_index >= lcl_set_end[var_name_index]) {
				seta_index = expand_set(var_name_index,var_seta_type,var_lcl_loc,set_sub);
			} else if (seta_index < lcl_set_start[var_name_index]) {
				log_error(164,"lcla subscript < 1 = " + lcl_set_name[var_name_index] // RPI-525
								+ "(" + (seta_index-lcl_set_start[var_name_index]+1) + ")" );
			}
			seta_value = lcl_seta[seta_index];
			break;
		case 22:
			val_type = val_setb_type;
			setb_index = lcl_set_start[var_name_index] + set_sub - 1;
			if (setb_index >= lcl_set_end[var_name_index]) {
				setb_index = expand_set(var_name_index,var_setb_type,var_lcl_loc,set_sub);
			} else if (setb_index < lcl_set_start[var_name_index]) { // RPI-525
				log_error(165,"lclb subscript < 1 = " + lcl_set_name[var_name_index]
								+ "(" + (setb_index-lcl_set_start[var_name_index]+1) + ")" );
			}
			setb_value = lcl_setb[setb_index];
			break;
		case 23:
			val_type = val_setc_type;
			setc_index = lcl_set_start[var_name_index] + set_sub - 1;
			if (setc_index >= lcl_set_end[var_name_index]) {
				setc_index = expand_set(var_name_index,var_setc_type,var_lcl_loc,set_sub);
			} else if (setc_index < lcl_set_start[var_name_index]) { // RPI-525
				log_error(166,"lclc subscript < 1 = " + lcl_set_name[var_name_index]
								+ "(" + (setc_index-lcl_set_start[var_name_index]+1) + ")" );
			}
			setc_value = lcl_setc[setc_index];
			break;
		default:
			tz390.abort_case();
		}
	}

	/**
	 * Expand set array.
	 *
	 * @param expand_name_index
	 * @param expand_type
	 * @param expand_loc
	 * @param expand_sub
	 * @return
	 */
	private int expand_set(final int expand_name_index, final byte expand_type, final byte expand_loc, final int expand_sub)
	{
		int index = 0;
		int len = 0;
		tot_expand++;
		if (expand_loc == var_lcl_loc) {
			if  (tz390.opt_tracem) {  // RPI-435
				tz390.put_trace("expand local set array - " + lcl_set_name[expand_name_index] + "(" + expand_sub +")");
			}
			switch (expand_type) {
			case 21:
				if (tot_lcl_seta + expand_sub + expand_inc > tz390.opt_maxlcl) {
					abort_error(48,"LCL seta sub out of range - " + lcl_set_name[expand_name_index] + "(" + expand_sub +")");
					return -1;
				}
				// move existing elements to end if not already there
				if (lcl_set_end[expand_name_index] != tot_lcl_seta) {
					index = lcl_set_start[expand_name_index];
					len = lcl_set_end[expand_name_index] - index;
					lcl_set_start[expand_name_index] = tot_lcl_seta;
					if (lcl_set_high[expand_name_index] > 0) {
						lcl_set_high[expand_name_index] =
							lcl_set_high[expand_name_index]
									+ tot_lcl_seta - index;
					}
					System.arraycopy(lcl_seta,index,lcl_seta,tot_lcl_seta,len);
					tot_lcl_seta = tot_lcl_seta + len; // RPI-415
					lcl_set_end[expand_name_index] = tot_lcl_seta;
				}
				// expand array to include set_sub + expand_inc
				tot_lcl_seta = lcl_set_start[expand_name_index] + expand_sub + expand_inc;
				adjust_expand_inc(var_lcl_loc); // grow to reduce repeats
				index = lcl_set_end[expand_name_index];
				Arrays.fill(lcl_seta,index,tot_lcl_seta,0);
				lcl_set_end[expand_name_index] = tot_lcl_seta;
				return lcl_set_start[expand_name_index]
						+ expand_sub - 1;
			case 22:
				if (tot_lcl_setb + expand_sub + expand_inc > tz390.opt_maxlcl) {
					abort_error(49,"LCL setb sub out of range - "
							+ lcl_set_name[expand_name_index]
							+ "(" + expand_sub +")");
					return -1;
				}
				// move existing elements to end if not already there
				if (lcl_set_end[expand_name_index] != tot_lcl_setb) {
					index = lcl_set_start[expand_name_index];
					len   = lcl_set_end[  expand_name_index] - index;
					lcl_set_start[expand_name_index] = tot_lcl_setb;
					if (lcl_set_high[expand_name_index] > 0) {
						lcl_set_high[expand_name_index] =
							lcl_set_high[expand_name_index]
									+ tot_lcl_setb - index;
					}
					System.arraycopy(lcl_setb,index,lcl_setb,tot_lcl_setb,len);
					tot_lcl_setb = tot_lcl_setb + len; // RPI-415
					lcl_set_end[expand_name_index] = tot_lcl_setb;
				}
				// expand array to include set_sub + expand_inc
				tot_lcl_setb = lcl_set_start[expand_name_index] + expand_sub + expand_inc;
				adjust_expand_inc(var_lcl_loc); // grow to reduce repeats
				index = lcl_set_end[expand_name_index];
				Arrays.fill(lcl_setb,index,tot_lcl_setb,(byte)0); // RPI-411
				lcl_set_end[expand_name_index] = tot_lcl_setb;
				return lcl_set_start[expand_name_index]
						+ expand_sub - 1;
			case 23:
				if (tot_lcl_setc + expand_sub + expand_inc > tz390.opt_maxlcl) {
					abort_error(50,"LCL setc sub out of range - "
							+ lcl_set_name[expand_name_index]
							+ "(" + expand_sub +")");
					return -1;
				}
				// move existing elements to end if not already there
				if (lcl_set_end[expand_name_index] != tot_lcl_setc) {
					index = lcl_set_start[expand_name_index];
					len   = lcl_set_end[expand_name_index] - index;
					lcl_set_start[expand_name_index] = tot_lcl_setc;
					if (lcl_set_high[expand_name_index] > 0) {
						lcl_set_high[expand_name_index] =
							lcl_set_high[expand_name_index]
									+ tot_lcl_setc - index;
					}
					System.arraycopy(lcl_setc,index,lcl_setc,tot_lcl_setc,len);
					tot_lcl_setc = tot_lcl_setc + len; // RPI-415
					lcl_set_end[expand_name_index] = tot_lcl_setc;
				}
				// expand array to include set_sub + expand_inc
				tot_lcl_setc = lcl_set_start[expand_name_index] + expand_sub + expand_inc;
				adjust_expand_inc(var_lcl_loc); // grow to reduce repeats
				index = lcl_set_end[expand_name_index];
				Arrays.fill(lcl_setc,index,tot_lcl_setc,"");
				lcl_set_end[expand_name_index] = tot_lcl_setc;
				return lcl_set_start[expand_name_index]
						+ expand_sub - 1;
			default:
				tz390.abort_case();
			return -1;
			}
		} else {
			if  (tz390.opt_tracem) {  // RPI-435
				tz390.put_trace("expand global set array - " + gbl_set_name[expand_name_index] + "(" + expand_sub +")");
			}
			switch (expand_type) {
			case 21:
				if (tot_gbl_seta + expand_sub + expand_inc > tz390.opt_maxgbl) {
					abort_error(59,"GBL seta sub out of range - " + gbl_set_name[expand_name_index] + "(" + expand_sub +")");
					return -1;
				}
				// move existing elements to end if not already there
				if (gbl_set_end[expand_name_index] != tot_gbl_seta) {
					index = gbl_set_start[expand_name_index];
					len   = gbl_set_end[expand_name_index] - index;
					gbl_set_start[expand_name_index] = tot_gbl_seta;
					if (gbl_set_high[expand_name_index] > 0) {
						gbl_set_high[expand_name_index] =
							gbl_set_high[expand_name_index]
									+ tot_gbl_seta - index;
					}
					System.arraycopy(gbl_seta,index,gbl_seta,tot_gbl_seta,len); // RPI-445
					gbl_set_end[expand_name_index] = tot_gbl_seta + len; // RPI-445
				}
				// expand array to include set_sub + expand_inc
				tot_gbl_seta = gbl_set_start[expand_name_index] + expand_sub + expand_inc;
				adjust_expand_inc(var_gbl_loc); // grow to reduce repeats
				index = gbl_set_end[expand_name_index];
				Arrays.fill(gbl_seta,index,tot_gbl_seta,0);
				gbl_set_end[expand_name_index] = tot_gbl_seta;
				return gbl_set_start[expand_name_index]
						+ expand_sub - 1;
			case 22:
				if (tot_gbl_setb + expand_sub + expand_inc > tz390.opt_maxgbl) {
					abort_error(61,"GBL setb sub out of range - "
							+ gbl_set_name[expand_name_index]
							+ "(" + expand_sub +")");
					return -1;
				}
				// move existing elements to end if not already there
				if (gbl_set_end[expand_name_index] != tot_gbl_setb) {
					index = gbl_set_start[expand_name_index];
					len   = gbl_set_end[expand_name_index] - index;
					gbl_set_start[expand_name_index] = tot_gbl_setb;
					if (gbl_set_high[expand_name_index] > 0) {
						gbl_set_high[expand_name_index] =
							gbl_set_high[expand_name_index]
									+ tot_gbl_setb - index;
					}
					System.arraycopy(gbl_setb,index,gbl_setb,tot_gbl_setb,len); // RPI-445
					gbl_set_end[expand_name_index] = tot_gbl_setb + len; // RPI-445
				}
				// expand array to include set_sub + expand_inc
				tot_gbl_setb = gbl_set_start[expand_name_index] + expand_sub + expand_inc;
				adjust_expand_inc(var_gbl_loc); // grow to reduce repeats
				index = gbl_set_end[expand_name_index];
				Arrays.fill(gbl_setb,index,tot_gbl_setb,(byte)0);
				gbl_set_end[expand_name_index] = tot_gbl_setb;
				return gbl_set_start[expand_name_index]
						+ expand_sub - 1;
			case 23:
				if (tot_gbl_setc + expand_sub + expand_inc > tz390.opt_maxgbl) {
					abort_error(65,"GBL setc sub out of range - "
							+ gbl_set_name[expand_name_index]
									+ "(" + expand_sub +")");
					return -1;
				}
				// move existing elements to end if not already there
				if (gbl_set_end[expand_name_index] != tot_gbl_setc) {
					index = gbl_set_start[expand_name_index];
					len   = gbl_set_end[expand_name_index] - index;
					gbl_set_start[expand_name_index] = tot_gbl_setc;
					if (gbl_set_high[expand_name_index] > 0) {
						gbl_set_high[expand_name_index] =
							gbl_set_high[expand_name_index]
									+ tot_gbl_setc - index; // RPI-445
					}
					System.arraycopy(gbl_setc,index,gbl_setc,tot_gbl_setc,len); // RPI-445
					gbl_set_end[expand_name_index] = tot_gbl_setc + len;  // RPI-445
				}
				// expand array to include set_sub + expand_inc
				tot_gbl_setc = gbl_set_start[expand_name_index] + expand_sub + expand_inc;
				adjust_expand_inc(var_gbl_loc); // grow to reduce repeats
				index = gbl_set_end[expand_name_index];
				Arrays.fill(gbl_setc,index,tot_gbl_setc,""); // RPI-411
				gbl_set_end[expand_name_index] = tot_gbl_setc;
				return gbl_set_start[expand_name_index]
						+ expand_sub - 1;
			default:
				tz390.abort_case();
			return -1;
			}
		}
	}

	/**
	 * Increase expansion increment to reduce overhead of repeated expansions.
	 * This is a trade-off with running out of memory.
	 *
	 * @param var_loc
	 */
	private void adjust_expand_inc(final int var_loc)
	{
		expand_inc = 100;  // RPI-435
		if (tz390.opt_traceall) {
			if (var_loc == var_lcl_loc) {
				tz390.put_trace("EXPANSION OF LCL " + lcl_set_name[var_name_index] + "(" + (lcl_set_end[var_name_index]-lcl_set_start[var_name_index]) + ") INC=" + expand_inc);
			} else {
				tz390.put_trace("EXPANSION OF GBL " + gbl_set_name[var_name_index] + "(" + (gbl_set_end[var_name_index]-gbl_set_start[var_name_index]) + ") INC=" + expand_inc);
			}
		}
	}

	/**
	 * 1.  Set seta/setb/setc_value from gbl set based on var_type, var_loc, var_name_index, and set_sub.
	 * 2.  Set val_type = var_seta/setb/setc_type
	 */
	private void get_gbl_set_value()
	{
		switch (var_type) {
		case 21:
			val_type = val_seta_type;
			seta_index = gbl_set_start[var_name_index] + set_sub - 1;
			if (seta_index >= gbl_set_end[var_name_index]) {
				seta_index = expand_set(var_name_index,var_seta_type,var_gbl_loc,set_sub);
			} else if (seta_index < gbl_set_start[var_name_index]) {
				log_error(167,"gbla subscript < 1 = " + gbl_set_name[var_name_index] // RPI-525
								+ "(" + (seta_index-gbl_set_start[var_name_index]+1) + ")" );
			}
			seta_value = gbl_seta[seta_index];
			break;
		case 22:
			val_type = val_setb_type;
			setb_index = gbl_set_start[var_name_index] + set_sub - 1;
			if (setb_index >= gbl_set_end[var_name_index]) {
				setb_index = expand_set(var_name_index,var_setb_type,var_gbl_loc,set_sub);
			} else if (setb_index < gbl_set_start[var_name_index]) {
				log_error(168,"gblb subscript < 1 = " + gbl_set_name[var_name_index]  // RPI-525
								+ "(" + (setb_index-gbl_set_start[var_name_index]+1) + ")" );
			}
			setb_value = gbl_setb[setb_index];
			break;
		case 23:
			val_type = val_setc_type;
			if (gbl_sysmac_index == gbl_set_start[var_name_index]) {
				if (!var_subscript_calc) {
					gbl_sysmac = mac_name[mac_call_name_index[mac_call_level]];
				} else if (set_sub >= 0 && set_sub <= mac_call_level) {
					gbl_sysmac = mac_name[mac_call_name_index[mac_call_level - set_sub]];
				} else {
					gbl_sysmac = "";
				}
				setc_index = gbl_set_start[var_name_index];
				gbl_setc[setc_index] = gbl_sysmac;
				setc_value = gbl_sysmac;
				break;
			}
			setc_index = gbl_set_start[var_name_index] + set_sub - 1;
			if (setc_index >= gbl_set_end[var_name_index]) {
				setc_index = expand_set(var_name_index,var_setc_type,var_gbl_loc,set_sub);
			} else if (setc_index < gbl_set_start[var_name_index]) {  // RPI-525
				log_error(169,"gblc subscript < 1 = " + gbl_set_name[var_name_index]
								+ "(" + (setc_index-gbl_set_start[var_name_index]+1) + ")" );
			}
			if (setc_index == gbl_sysclock_index) {
				if (tz390.opt_timing) {
					cur_date = new Date();
				}
				gbl_setc[setc_index] = sdf_sysclock.format(cur_date);
			}
			setc_value = gbl_setc[setc_index];
			break;
		default:
			tz390.abort_case();
		}
	}

	/**
	 * Find macro label and return line index-1 else abort.
	 *
	 * @param label_source
	 * @return
	 */
	private int get_label_index(String label_source)
	{
		label_match = label_pattern.matcher(label_source);
		label_name = label_source;
		if (label_source.charAt(0) == '.'  // RPI-1192
			&& label_match.find()) {
			label_name = label_match.group().toUpperCase();
			int    label_name_index = find_lcl_key_index("B:" + label_name);
			if (label_name_index != -1) {
				if (mac_lab_index[label_name_index] >= 0) {
					return mac_file_prev_line[mac_lab_index[label_name_index]]; // -1 req'd for following ++ cycle RPI-956
				} else {
					return -2; // RPI-1053
				}
			}
			label_name_index = mac_name_lab_start[mac_name_index];
			while (label_name_index < mac_name_lab_end[mac_name_index]) {
				if (mac_lab_name[label_name_index].equals(label_name)) {
					add_lcl_key_index(label_name_index);
					if (mac_lab_index[label_name_index] >= 0) {
						return mac_file_prev_line[mac_lab_index[label_name_index]]; // -1 req'd for following ++ cycle RPI-956
					} else {
						return -2; // RPI-956
					}
				} else {
					label_name_index++;
				}
			}
		}
		log_error(25, "Macro label not found - " + label_name);
		return -1;
	}

	/**
	 * Find and return index to comma after macro label else return -1.
	 *
	 * @param label_source
	 * @return
	 */
	private int get_label_comma_index(String label_source)
	{
		label_match = label_pattern.matcher(label_source);
		if (label_match.find()) {
			int index = label_match.end();
			if (index < label_source.length()
					&& label_source.charAt(index) == ',') {
				return index;
			}
		}
		return -1;
	}

	/**
	 * Return mac_name index if found else -1.
	 *
	 * 1. Note load_mac adds entry with -2 index to prevent mult search for macros not found.
	 * 2. If MFC option on, then instructions and assembler control statements will not be
	 *    expanded as macros.
	 * 3. Any non-conditional macro operator can be expanded via an inline macro that can be
	 *    defined via COPY statement.
	 *
	 * @param macro_name
	 * @return
	 */
	private int find_mac_entry(final String macro_name)
	{
		int index = tz390.find_key_index('M',macro_name.toUpperCase());
		if (index != -1) {
			if (index == -2) {
				// RPI-1213 move check_sysops();
			}
			return index;
		}
		if (tz390.opt_asm) {
			final String temp_name = macro_name.toUpperCase();
			if (save_opsyn_index == -1 || tz390.opsyn_old_name[save_opsyn_index] != null) {
				index = tz390.find_key_index('O',temp_name);
			} else {
				index = -1; // RPI-331
			}
			if (index != -1) {
				if (tz390.find_key_index('M',temp_name) == -1) {
					tz390.add_key_index(-2); // prevent repeat searches
					tot_ins++;
				}
				// RPI-1213 move check_sysops();
				return -2; // don't allow search for instructions
			}
		}
		return -1;
	}

	/**
	 * 1. Add macro to call stack.
	 * 2. If listcall option, add comment to BAL.
	 * 2. process prototype and set parameters.
	 * 3. Initialize mac_line_index to first macro statement.
	 * 4. Set macro label ordinary symbol type to 'M' if 'U'.
	 */
	private void call_mac()
	{
		tot_mac_call++;
		mac_name_index = find_mac_name_index;
		mac_call_return[mac_call_level] = mac_file_next_line[mac_line_index]; // RPI-956
		mac_call_actr[mac_call_level] = actr_count;
		actr_count = actr_limit;
		if  (mac_call_level < tz390.opt_maxcall-1) { // RPI-284
			mac_call_level++;
			mac_call_name_index[mac_call_level] = mac_name_index;
			mac_call_return[mac_call_level] = -1;
			mac_call_return[mac_call_level] = actr_limit;
			mac_call_sysm_sev[mac_call_level] = 0; // RPI-898
			mac_call_pos_start[mac_call_level] = tot_pos_parm;
			mac_call_kwd_start[mac_call_level] = tot_kwd_parm;
			mac_call_lcl_name_start[mac_call_level] = tot_lcl_name;
			mac_call_lcl_seta_start[mac_call_level] = tot_lcl_seta;
			mac_call_lcl_setb_start[mac_call_level] = tot_lcl_setb;
			mac_call_lcl_setc_start[mac_call_level] = tot_lcl_setc;
			mac_call_lcl_key_start[mac_call_level] = tot_lcl_key_tab;
			mac_call_lcl_key_root[mac_call_level] = cur_lcl_key_root;
			/*
			 * init lcl key index table variables
			 */
			cur_lcl_key_root = tot_lcl_key_tab + 1;
			tot_lcl_key_tab  = tot_lcl_key_tab + max_lcl_key_root + 1;
			lcl_key_index = cur_lcl_key_root;
			Arrays.fill(lcl_key_tab_key,lcl_key_index,tot_lcl_key_tab,null); // RPI-411
			/*
			 * add lcl system variables
			 */
			init_lcl_sys();
			/*
			 * 1.  parse proto-type and add initial key word parms with values
			 * 2.  parse macro call statement and set positional and key word parm values
			 */
			init_call_parms();
			set_call_parm_values();
			mac_line_index = mac_name_line_start[mac_name_index];
			if (tz390.opt_tracem) { // RPI-899
				trace_break();
			}
		} else {
			abort_error(30,"Maximum level of nested macros exceeded");
		}
	}

	/**
	 * If LISTCALL
	 *   gen listcall comment on BAL.
	 *   before load or call. RPI-746
	 * Notes:
	 * If LISTCALL and MCALL, all calls are listed on PRN.
	 */
	private void put_listcall()
	{
		if (!tz390.opt_listcall) return; // RPI-922
			String call_label = bal_label;
			String call_parms = bal_parms;
			if (call_label == null) {
				call_label = "        ";
			} else {
				if (call_label.length() > 1 && call_label.charAt(0) == '.') {
					call_label = tz390.left_justify(" ",call_label.length());
				}
				call_label = tz390.left_justify(call_label,8);
			}
			String call_op = save_bal_op;
			call_op = tz390.left_justify(call_op,5);
			String sysndx;
			if (lcl_sysndx < 10000) { // RPI-1163
				sysndx = tz390.right_justify("" + (lcl_sysndx+1),4);
			} else {
				sysndx = "" + (lcl_sysndx+1); // RPI-1163
			}
			String sysnest = tz390.right_justify("" + (mac_call_level+1),2);
			if (call_parms == null)call_parms = "";
			String call_line = null;
			if (tz390.opt_reformat) {
				call_line = call_label + " " + call_op + " " + call_parms;
			} else {
				if (bal_label != null && bal_label.length() > 1 && bal_label.charAt(0) == '.') {
					call_line = tz390.left_justify(" ",bal_label.length()) + bal_line.substring(bal_label.length());
				} else {
					call_line = bal_line;
				}
			}
			bal_xref_index = mac_line_index;
			String mcall_line = "*MCALL #=" + tz390.right_justify(sysndx,6) // RPI-891
								+ " LV=" +  tz390.right_justify(sysnest,2)
								+ " " + call_line;
			if (tz390.opt_traces && tz390.opt_mcall) {  // RPI-890
				System.out.println(mcall_line); // RPI-890
			}
			put_bal_line(mcall_line);
	}

	/**
	 * Allocate pseudo code arrays.
	 * Notes:
	 *  1. pc_start used to opt ago, gbl?, etc.
	 *  2. Others not alloc if nopc option.
	 */
	private void init_pc_arrays()
	{
		pcl_start    = (int[])Array.newInstance(int.class,tz390.opt_maxline);
		if (!tz390.opt_pc) {
			return;
		}
		pcl_end      = (int[])Array.newInstance(int.class,tz390.opt_maxline);
		pcl_mru_next = (int[])Array.newInstance(int.class,tz390.opt_maxline);
		pcl_mru_prev = (int[])Array.newInstance(int.class,tz390.opt_maxline);
		/*
		 * opt_maxpc = pseudo code cache size for
		 * optimizing execution of macro code expressions
		 */
		pc_op       = (byte[])Array.newInstance(byte.class,tz390.opt_maxpc);
		pc_var_type = (byte[])Array.newInstance(byte.class,tz390.opt_maxpc);
		pc_var_loc  = (byte[])Array.newInstance(byte.class,tz390.opt_maxpc);
		pc_sysndx   = (int[])Array.newInstance(int.class,tz390.opt_maxpc);
		pc_seta     = (int[])Array.newInstance(int.class,tz390.opt_maxpc);
		pc_setc     = new String[tz390.opt_maxpc];
		pc_next     = (int[])Array.newInstance(int.class,tz390.opt_maxpc);
		pc_req_opt  = (boolean[])Array.newInstance(boolean.class,tz390.opt_maxpc);
		/*
		 * put all pc entries on free list
		 */
		int index = 1;
		while (index < tz390.opt_maxpc-1) { // leave last entry 0
			pc_next[index] = index+1; // chain free list
			index++;
		}
		pc_free = 1; // next free pc entry in free list
	}

	/**
	 * Initialize large arrays with optional overrides for size.
	 */
	private void init_arrays()
	{
		/*
		 * opt_maxcall - maximum nested call stack
		 */
		mac_call_name_index = (int[])Array.newInstance(int.class,tz390.opt_maxcall);
		mac_call_return     = (int[])Array.newInstance(int.class,tz390.opt_maxcall);
		mac_call_sysm_sev   = (int[])Array.newInstance(int.class,tz390.opt_maxcall); // RPI-898
		mac_call_actr       = (int[])Array.newInstance(int.class,tz390.opt_maxcall);
		mac_call_sysndx     = (int[])Array.newInstance(int.class,tz390.opt_maxcall);
		mac_call_pos_start  = (int[])Array.newInstance(int.class,tz390.opt_maxcall);
		mac_call_pos_tot    = (int[])Array.newInstance(int.class,tz390.opt_maxcall);
		mac_call_kwd_start  = (int[])Array.newInstance(int.class,tz390.opt_maxcall);
		mac_call_lcl_name_start = (int[])Array.newInstance(int.class,tz390.opt_maxcall);
		mac_call_lcl_seta_start = (int[])Array.newInstance(int.class,tz390.opt_maxcall);
		mac_call_lcl_setb_start = (int[])Array.newInstance(int.class,tz390.opt_maxcall);
		mac_call_lcl_setc_start = (int[])Array.newInstance(int.class,tz390.opt_maxcall);
		mac_call_lcl_key_start  = (int[])Array.newInstance(int.class,tz390.opt_maxcall);
		mac_call_lcl_key_root   = (int[])Array.newInstance(int.class,tz390.opt_maxcall);
		/*
		 * opt_maxfile - nested copy file I/O plus
		 * reference File with file paths for cross reference
		 */
		mac_file              = (File[])Array.newInstance(File.class,tz390.opt_maxfile);
		mac_file_buff         = (BufferedReader[])Array.newInstance(BufferedReader.class,tz390.opt_maxfile);
		mac_file_cur_file_num = (int[])Array.newInstance(int.class,tz390.opt_maxfile);
		mac_file_cur_line_num = (int[])Array.newInstance(int.class,tz390.opt_maxfile);
		mac_file_errors       = (int[])Array.newInstance(int.class,tz390.opt_maxfile);
		mac_file_path         = new String[tz390.opt_maxfile];
		mac_file_type         = new char[tz390.opt_maxfile]; // RPI-549
		mac_ictl_start        = new int[tz390.opt_maxfile]; // RPI-549
		mac_ictl_end          = new int[tz390.opt_maxfile]; // RPI-549
		mac_ictl_cont         = new int[tz390.opt_maxfile]; // RPI-549
		mac_name              = new String[tz390.opt_maxfile];
		mac_name_line_start   = new int[tz390.opt_maxfile];
		mac_name_line_end     = new int[tz390.opt_maxfile];
		mac_name_lab_start    = new int[tz390.opt_maxfile];
		mac_name_lab_end      = new int[tz390.opt_maxfile];
		/*
		 * opt_maxline - total MLC and MAC/CPY file source loaded
		 */
		mac_file_line      = new String[tz390.opt_maxline];
		mac_file_line_num  = (int[])Array.newInstance(int.class,tz390.opt_maxline);
		mac_file_num  = (int[])Array.newInstance(int.class,tz390.opt_maxline);
		mac_file_next_line  = (int[])Array.newInstance(int.class,tz390.opt_maxline); // RPI-956
		mac_file_prev_line  = (int[])Array.newInstance(int.class,tz390.opt_maxline); // RPI-956
		int index = 0;
		while (index < tz390.opt_maxline - 1) {
			mac_file_next_line[index] = index+1;
			mac_file_prev_line[index+1] = index;
		    index++;
		}
		last_ainsert = tz390.opt_maxline;
		mac_file_line[0] = "";
		/*
		 * opt_maxgbl - global set variable names and cells
		 */
		gbl_set_name  = new String[tz390.opt_maxgbl];
		gbl_set_type  = (byte[])Array.newInstance(byte.class,tz390.opt_maxgbl);
		gbl_set_start = (int[])Array.newInstance(int.class,tz390.opt_maxgbl);
		gbl_set_high = (int[])Array.newInstance(int.class,tz390.opt_maxgbl);
		gbl_set_end   = (int[])Array.newInstance(int.class,tz390.opt_maxgbl);
		gbl_seta      = (int[])Array.newInstance(int.class,tz390.opt_maxgbl);
		gbl_setb      = (byte[])Array.newInstance(byte.class,tz390.opt_maxgbl);
		gbl_setc      = new String[tz390.opt_maxgbl];
		/*
		 * opt_maxkey - maximum indexed key table
		 */
		max_lcl_key_tab = tz390.opt_maxcall * max_lcl_key_root + tz390.opt_maxlcl + 2 * tz390.opt_maxparm;
		lcl_key_tab_key   = new String[max_lcl_key_tab];
		lcl_key_tab_hash  = (int[])Array.newInstance(int.class,max_lcl_key_tab);
		lcl_key_tab_index = (int[])Array.newInstance(int.class,max_lcl_key_tab);
		lcl_key_tab_low   = (int[])Array.newInstance(int.class,max_lcl_key_tab);
		lcl_key_tab_high  = (int[])Array.newInstance(int.class,max_lcl_key_tab);
		/*
		 * opt_maxlcl - local set variable names and cells
		 */
		lcl_set_name  = new String[tz390.opt_maxlcl];
		lcl_set_type  = (byte[])Array.newInstance(byte.class,tz390.opt_maxlcl);
		lcl_set_start = (int[])Array.newInstance(int.class,tz390.opt_maxlcl);
		lcl_set_high  = (int[])Array.newInstance(int.class,tz390.opt_maxlcl);
		lcl_set_end   = (int[])Array.newInstance(int.class,tz390.opt_maxlcl);
		lcl_seta      = (int[])Array.newInstance(int.class,tz390.opt_maxlcl);
		lcl_setb      = (byte[])Array.newInstance(byte.class,tz390.opt_maxlcl);
		lcl_setc      = new String[tz390.opt_maxlcl];
		/*
		 * opt_maxparm = positional and keyword parms
		 */
		mac_call_pos_name = new String[tz390.opt_maxparm];
		mac_call_pos_parm = new String[tz390.opt_maxparm];
		mac_call_kwd_name = new String[tz390.opt_maxparm];
		mac_call_kwd_parm = new String[tz390.opt_maxparm];
		mac_call_kwd_set  = new boolean[tz390.opt_maxparm]; // RPI-600
		/*
		 * opt_maxsym - symbols, macro labels,
		 */
		mac_lab_name  = new String[tz390.opt_maxsym];
		mac_lab_index = (int[])Array.newInstance(int.class,tz390.opt_maxsym);
		mac_lab_num   = (int[])Array.newInstance(int.class,tz390.opt_maxsym); // RPI-266
	}

	/**
	 * Add global system variables.
	 */
	private void init_gbl_sys()
	{
		add_gbl_sys("&SYSADATA_DSN",var_setc_type); // full path and file name if any RPI-259
		set_sys_dsn_mem_vol(tz390.dir_mlc + tz390.pgm_name + tz390.ada_type);
		gbl_setc[tot_gbl_setc-1] = sys_dsn;
		add_gbl_sys("&SYSADATA_MEMBER",var_setc_type); // current macro name if any
		gbl_setc[tot_gbl_setc-1] = sys_mem;
		add_gbl_sys("&SYSADATA_VOLUME",var_setc_type); // drive letter if any
		gbl_setc[tot_gbl_setc-1] = sys_vol;
		add_gbl_sys("&SYSASM",var_setc_type);
		gbl_setc[tot_gbl_setc-1] = "z390";
		add_gbl_sys("&SYSEDF",var_setb_type); // RPI-1027 RPI-1123
		if (tz390.opt_edf) { // RPI-1123
			gbl_setb[tot_gbl_setb-1] = 1;   // RPI-1027
		}
		add_gbl_sys("&SYSCICS",var_setb_type); // RPI-976
		if (tz390.opt_cics) {
			gbl_setb[tot_gbl_setb-1] = 1;   // RPI-976
		}
		add_gbl_sys("&SYSCICS_EPILOG",var_setb_type); // RPI-976
		if (tz390.opt_epilog) {
			gbl_setb[tot_gbl_setb-1] = 1;   // RPI-976
		}
		add_gbl_sys("&SYSCICS_PROLOG",var_setb_type); // RPI-976
		if (tz390.opt_prolog) {
			gbl_setb[tot_gbl_setb-1] = 1;   // RPI-976
		}
		add_gbl_sys("&SYSCLOCK",var_setc_type);
		gbl_sysclock_index = tot_gbl_setc-1;
		add_gbl_sys("&SYSDATC",var_setc_type);
		gbl_setc[tot_gbl_setc-1] = sdf_sysdatc.format(cur_date);
		add_gbl_sys("&SYSDATE",var_setc_type);
		if (tz390.opt_bs2000) {  // RPI-604
			gbl_setc[tot_gbl_setc-1] = sdf_sysdate_bs2000.format(cur_date);
		} else {
			gbl_setc[tot_gbl_setc-1] = sdf_sysdate.format(cur_date);
		}
		add_gbl_sys("&SYSIN_DSN",var_setc_type); // MLC full path and file name  RPI-259
		set_sys_dsn_mem_vol(tz390.dir_mlc + tz390.pgm_name + tz390.pgm_type);
		gbl_setc[tot_gbl_setc-1] = sys_dsn;
		add_gbl_sys("&SYSIN_MEMBER",var_setc_type); // MLC file name without suffix
		gbl_setc[tot_gbl_setc-1] = sys_mem;
		add_gbl_sys("&SYSIN_VOLUME",var_setc_type); // MLC drive letter
		gbl_setc[tot_gbl_setc-1] = sys_vol;
		add_gbl_sys("&SYSJOB",var_setc_type); // current job = MLC file name without suffix
		sys_job = sys_mem;
		final int index = sys_job.indexOf('.');
		if (index > 0) {
			sys_job = sys_mem.substring(0,index);
		}
		gbl_setc[tot_gbl_setc-1] = sys_job;
		add_gbl_sys("&SYSLIB_DSN",var_setc_type); // MAC full path and file name if any
		gbl_syslib_index = tot_gbl_setc-1;
		gbl_setc[tot_gbl_setc-1] = sys_dsn;
		add_gbl_sys("&SYSLIB_MEMBER",var_setc_type); // MAC file name without suffix
		gbl_setc[tot_gbl_setc-1] = sys_mem;
		add_gbl_sys("&SYSLIB_VOLUME",var_setc_type); // MAC drive letter if any
		gbl_setc[tot_gbl_setc-1] = sys_vol;
		add_gbl_sys("&SYSLIN_DSN",var_setc_type); // OBJ full path and file name
		set_sys_dsn_mem_vol(tz390.dir_mlc + tz390.pgm_name + tz390.obj_type);
		gbl_setc[tot_gbl_setc-1] = sys_dsn;
		add_gbl_sys("&SYSLIN_MEMBER",var_setc_type); // OBJ file name without suffix
		gbl_setc[tot_gbl_setc-1] = sys_mem;
		add_gbl_sys("&SYSLIN_VOLUME",var_setc_type); //OBJ drive letter
		gbl_setc[tot_gbl_setc-1] = sys_vol;
		add_gbl_sys("&SYSMAC",var_setc_type);
		gbl_sysmac_index = tot_gbl_setc-1;
		add_gbl_sys("&SYSM_HSEV",var_setc_type); // highest MNOTE error level
		gbl_sysm_hsev_index = tot_gbl_setc-1;    // RPI-898 was seta vs setc for HSEV and SEV
		gbl_setc[gbl_sysm_hsev_index] = "000"; // RPI-898
		add_gbl_sys("&SYSM_SEV",var_setc_type); // highest MNOTE level in last macro
		gbl_sysm_sev_index = tot_gbl_setc-1;  // RPI-898 was sysm_hsev_index in error
		gbl_setc[gbl_sysm_sev_index] = "000"; // RPI-898
		add_gbl_sys("&SYSOPT_DBCS",var_setb_type); // set false indicating no DBCS support
		add_gbl_sys("&SYSOPT_OPTABLE",var_setc_type); // "z390" opcode table name
		gbl_setc[tot_gbl_setc-1] = "z390";
		add_gbl_sys("&SYSOPT_RENT",var_setb_type); // set true if RENT option specified
		add_gbl_sys("&SYSOPT_XOBJECT",var_setb_type); //set true if GOFF or XOBJECT
		add_gbl_sys("&SYSPARM",var_setc_type);
		gbl_setc[tot_gbl_setc-1] = tz390.opt_sysparm;
		add_gbl_sys("&SYSPRINT_DSN",var_setc_type); // PRN full path and file name
		set_sys_dsn_mem_vol(tz390.dir_mlc + tz390.pgm_name + tz390.prn_type);
		gbl_setc[tot_gbl_setc-1] = sys_dsn;
		add_gbl_sys("&SYSPRINT_MEMBER",var_setc_type); // PRN file name without type
		gbl_setc[tot_gbl_setc-1] = sys_mem;
		add_gbl_sys("&SYSPRINT_VOLUME",var_setc_type); // PRN drive letter
		gbl_setc[tot_gbl_setc-1] = sys_vol;
		add_gbl_sys("&SYSPUNCH_DSN",var_setc_type); // PCH full path and file name
		set_sys_dsn_mem_vol(tz390.dir_mlc + tz390.pgm_name + tz390.pch_type);
		gbl_setc[tot_gbl_setc-1] = sys_dsn;
		add_gbl_sys("&SYSPUNCH_MEMBER",var_setc_type); //PCH file name without type
		gbl_setc[tot_gbl_setc-1] = sys_mem;
		add_gbl_sys("&SYSPUNCH_VOLUME",var_setc_type); //PCH drive letter
		gbl_setc[tot_gbl_setc-1] = sys_vol;
		add_gbl_sys("&SYSSEQF",var_setc_type); // source sequence field set to 0 length string
		add_gbl_sys("&SYSSTEP",var_setc_type); // current step = MLC file name
		gbl_setc[tot_gbl_setc-1] = sys_job;
		add_gbl_sys("&SYSSTMT",var_setc_type); // next BAL statement number as 8 digit string RPI-892
		gbl_sysstmt_index = tot_gbl_setc-1;    // RPI-892
		gbl_setc[tot_gbl_setc-1] = "00000001"; // RPI-892
		add_gbl_sys("&SYSTEM_ID",var_setc_type);
		gbl_setc[tot_gbl_setc-1] = System.getProperty("os.name") + " " + System.getProperty("os.version");
		add_gbl_sys("&SYSTERM_DSN",var_setc_type); // ERR full path and file name
		set_sys_dsn_mem_vol(tz390.dir_mlc + tz390.pgm_name + tz390.err_type);
		gbl_setc[tot_gbl_setc-1] = sys_dsn;
		add_gbl_sys("&SYSTERM_MEMBER",var_setc_type); // ERR file name without type
		gbl_setc[tot_gbl_setc-1] = sys_mem;
		add_gbl_sys("&SYSTERM_VOLUME",var_setc_type); // ERR file drive letter
		gbl_setc[tot_gbl_setc-1] = sys_vol;
		add_gbl_sys("&SYSTEM_JAVA",var_setc_type);
		gbl_setc[tot_gbl_setc-1] = System.getProperty("java.vendor") + " " + System.getProperty("java.version");
		add_gbl_sys("&SYSTIME",var_setc_type);
		if (tz390.opt_bs2000) {  // RPI-604
			gbl_setc[tot_gbl_setc-1] = sdf_systime_bs2000.format(cur_date);
		} else {
			gbl_setc[tot_gbl_setc-1] = sdf_systime.format(cur_date);
		}
		add_gbl_sys("&SYSTRACE",var_setc_type); // RPI-930
		gbl_systrace_index = tot_gbl_setc-1;    // RPI-930
		gbl_setc[tot_gbl_setc-1] = tz390.trace_options; // RPI-930
		add_gbl_sys("&SYSVER",var_setc_type);
		gbl_setc[tot_gbl_setc-1] = tz390.version;
		if (tz390.opt_bs2000) {  // RPI-604
			add_gbl_sys("&SYSTEM",var_setc_type);
			gbl_setc[tot_gbl_setc-1] = tz390.version.substring(1,2)
									 + tz390.version.substring(3,4)
									 + tz390.version.substring(5,7);
			add_gbl_sys("&SYSMOD",var_setc_type);
			if (tz390.opt_amode24) {
				gbl_setc[tot_gbl_setc-1] = "24";
			} else {
				gbl_setc[tot_gbl_setc-1] = "31";
			}
			add_gbl_sys("&SYSVERM",var_setc_type);
			gbl_setc[tot_gbl_setc-1] = "VER   ";
			add_gbl_sys("&SYSVERS",var_setc_type);
			gbl_setc[tot_gbl_setc-1] = "VER   ";
		}
	}

	/**
	 * Set sys_dsn, sys__mem, and sys_vol from file name.
	 *
	 * @param file_name
	 */
	private void set_sys_dsn_mem_vol(final String file_name)
	{
		sys_dsn = "";
		sys_mem = "";
		sys_vol = "";
		sys_file = new File(file_name); // RPI-499 drop upper case
		try {
			sys_dsn = sys_file.getCanonicalPath();
			sys_mem = sys_file.getName();
			final int index = sys_mem.indexOf(".");
			if (index > 0) { // RPI-329
				sys_mem = sys_mem.substring(0,index);
			}
			sys_vol = sys_dsn.substring(0,1);
		} catch (final Exception e) {}
	}

	/**
	 * Add global system variables.
	 *
	 * @param sys_name
	 * @param sys_type
	 */
	private void add_gbl_sys(final String sys_name, final byte sys_type)
	{
		if (tz390.find_key_index('G',sys_name) == -1) {
			add_gbl_set(sys_name,sys_type,1,false); // RPI-1162
		} else {
			abort_error(160,"Add global var failed - " + sys_name);
		}
	}

	/**
	 * Initialize local system macro variables.
	 */
	private void init_lcl_sys()
	{
		add_lcl_sys("&SYSNDX",var_setc_type); // RPI-593 was SETA
		lcl_sysndx++;
		String sysndx;
		if (lcl_sysndx < 10000) { // RPI-1163
			sysndx = "0000" + lcl_sysndx;
			sysndx = sysndx.substring(sysndx.length()-4);
		} else {
			sysndx = "" + lcl_sysndx; // RPI-1163
		}
		lcl_setc[tot_lcl_setc-1] = sysndx; // RPI-593
		mac_call_sysndx[mac_call_level] = lcl_sysndx; // RPI-593
		add_lcl_sys("&SYSNEST",var_seta_type);
		lcl_seta[tot_lcl_seta-1] = mac_call_level;
		add_lcl_sys("&SYSECT",var_setc_type);
		lcl_sysect_setc_index = tot_lcl_setc-1; // RPI-1213
		lcl_setc[lcl_sysect_setc_index] = lcl_sysect;
		add_lcl_sys("&SYSLOC",var_setc_type);
		lcl_sysloc_setc_index = tot_lcl_setc-1; // RPI-1213
		lcl_setc[lcl_sysloc_setc_index] = lcl_sysloc;
		add_lcl_sys("&SYSSTYP",var_setc_type);
		lcl_sysstyp_setc_index = tot_lcl_setc-1; // RPI-1213
		lcl_setc[lcl_sysstyp_setc_index] = lcl_sysstyp;
		if (tz390.opt_bs2000) {  // RPI-604
			add_lcl_sys("&SYSTSEC",var_setc_type);
			lcl_setc[tot_lcl_setc-1] = lcl_sysstyp;
		}
	}

	/**
	 * Add local set variable.
	 *
	 * @param sys_name
	 * @param sys_type
	 */
	private void add_lcl_sys(final String sys_name, final byte sys_type)
	{
		if (find_lcl_key_index("L:" + sys_name) == -1) {
			add_lcl_set(sys_name,sys_type,1,false); // RPI-1162
		} else {
			abort_error(122, "Duplicate lcl system variable - " + sys_name);
		}
	}

	/**
	 * Check for opcodes that update system variables.
	 */
	private void check_sysops()
	{
		if (bal_op == null || bal_op.length() == 0) {
			return;
		}
		if (az390.az390_private_sect) { // RPI-995 RPI-1213
			az390.az390_private_sect = false;
			lcl_sysect = az390.private_csect; // RPI-1213
			lcl_sysloc = az390.private_csect;
			lcl_sysstyp = "CSECT";
		}
		switch (bal_op.charAt(0)) {
		case 'C':
			if (bal_op.equals("CSECT")) {
				lcl_sysect = bal_label.toUpperCase();
				lcl_sysloc = lcl_sysect;
				lcl_sysstyp = "CSECT";
			}
			break;
		case 'D':
			if (bal_op.equals("DSECT")) {
				lcl_sysect = bal_label.toUpperCase();
				lcl_sysloc = lcl_sysect;
				lcl_sysstyp = "DSECT";
			}
			break;
		case 'L':
			if (bal_op.equals("LOCTR")) {
				lcl_sysloc = bal_label.toUpperCase();
				int cur_sym = mz390_find_sym(lcl_sysloc);
				if (cur_sym > 0) { // RPI-971 switch CSECT/DSECT
					while (az390.sym_sect_prev[cur_sym] > 0) {
						cur_sym = az390.sym_sect_prev[cur_sym];
					}
					if (az390.sym_type[cur_sym] == az390.sym_cst) {
						lcl_sysstyp = "CSECT";
					} else {
						lcl_sysstyp = "DSECT";
					}
				}
			}
		case 'R':
			if (bal_op.equals("RSECT")) {
				lcl_sysect = bal_label.toUpperCase();
				lcl_sysloc = lcl_sysect;
				lcl_sysstyp = "RSECT"; // RPI-479
			}
			break;
		case 'S':
			if (bal_op.equals("START")) {
				lcl_sysect = bal_label.toUpperCase();
				lcl_sysloc = lcl_sysect;
				lcl_sysstyp = "CSECT";
			}
			break;
		}
	}

	/**
	 * Parse prototype to set pos and key parameter initial values.
	 */
	private void init_call_parms()
	{
		cur_pos_parm = mac_call_pos_start[mac_call_level];  // RPI-313
		String proto_type_line = mac_file_line[mac_name_line_start[mac_name_index]];
		String proto_label	= null;
		//ring proto_op		= null; // JBA-unused
		String proto_parms	= null;
		tz390.split_line(proto_type_line);
		if (tz390.split_label != null) {
			proto_label = tz390.split_label;
		} else {
			proto_label = "";
		}
		//if (tz390.split_op != null) {
		//	proto_op = tz390.split_op;
		//} else {
		//	proto_op = "";
		//}
		if (tz390.split_parms != null) {
			proto_parms = tz390.split_parms;
		} else {
			proto_parms = "";
		}
		if  (proto_label.length() > 0) {
			init_pos_parm(proto_label);  // set syslist(0) label
		} else {
			init_pos_parm(""); // syslist(0) null
		}
		int first_pos_parm = tot_pos_parm;  // RPI-313
		if  (proto_parms.length() > 0) {
			String key_name = null;
			String key_value = null;
			int key_value_level = 0;
			proto_match = proto_pattern.matcher(proto_parms);
			byte state = 1;
			while (proto_match.find()) {
				parm_value = proto_match.group();
				switch (state) {
				case 1: // new parm
					if  (parm_value.equals(",")) {
						if (tot_pos_parm == first_pos_parm
							&& (proto_parms.length() == 1
								|| proto_parms.charAt(1) <= ' ')) {
							state = 4;  // RPI-313
						} else {
							set_pos_parm("");
						}
					} else if (parm_value.charAt(0) <= asc_space_char) { // RPI-239
						state = 4;
					} else {
						if  (parm_value.charAt(parm_value.length()-1) == '=') {
							key_name  = parm_value.substring(0,parm_value.length()-1).toUpperCase();  // RPI-359
							key_value = "";
							key_value_level = 0;
							state = 2; // possible key
						} else {
							init_pos_parm(parm_value);
							state = 3; // skip next commas
						}
					}
					break;
				case 2: // possible keyword parm initial value text
					if  (key_value_level == 0 // RPI-223
							&& (parm_value.equals(",")
									|| parm_value.charAt(0) <= asc_space_char)) { // RPI-239
						init_key_parm(key_name,key_value);
						if (parm_value.charAt(0) == ',') {
							state = 1;
						} else {
							state = 4;  // RPI-743
						}
					} else {
						if (parm_value.equals("(")) { // RPI-223
							key_value_level++;
						} else if (parm_value.equals(")")) {
							key_value_level--;
						}
						key_value = key_value.concat(parm_value);
					}
					break;
				case 3:  // ignore comma before next parm
					if (parm_value.equals(",")) {
						state = 1; // start next parm
					} else if (parm_value.charAt(0) <= asc_space_char) { // RPI-239
						state = 4; // switch to flush comments
					} else {
						log_error(31,"unexpected parm value after pos parm value");
					}
					break;
				case 4: // ignore spaces and comments
					break;
				default:
					tz390.abort_case();
				}
			}
			if (state == 2) {
				init_key_parm(key_name,key_value);
			}
		}
		// int proto_pos_parm_tot = tot_pos_parm - first_pos_parm;						// JBA-unused
		// int proto_kwd_parm_tot = tot_kwd_parm - mac_call_kwd_start[mac_call_level];	// JBA-unused
	}

	/**
	 * Set positional and key word parameter values from macro call statement.
	 * Note multiple commas force null pos parameters.
	 */
	private void set_call_parm_values()
	{
		cur_pos_parm = mac_call_pos_start[mac_call_level]; // RPI-313
		if  (bal_label.length() > 0 && bal_label.charAt(0) != '.') {
			symbol_match = symbol_pattern.matcher(bal_label);
			if (symbol_match.find() && symbol_match.group().equals(bal_label)) {  // RPI-633
				set_sym_macro_attr(bal_label);
			}
			set_pos_parm(bal_label);  // set syslist(0) label
		} else {
			set_pos_parm(""); // syslist(0) null
		}
		int first_pos_parm = tot_pos_parm;
		if  (bal_parms.length() > 0) {
			String key_name = null;
			tz390.parm_match = tz390.parm_pattern.matcher(bal_parms);
			byte state = 1;
			String token = null;
			char   token_first = '?';
			int    token_len   = 0;
			int level = 0;
			while (tz390.parm_match.find()) {
				token = tz390.parm_match.group();
				token_first = token.charAt(0);
				token_len   = token.length();
				switch (state) {
				case 1: // new parm
					parm_value = "";
					if  (token_first == ',') {
						if (tot_pos_parm == first_pos_parm
								&& (bal_parms.length() == 1
										|| bal_parms.charAt(1) <= ' ')) {
							state = 4;  // RPI-313
						} else {
							set_pos_parm("");
						}
					} else if (token_first <= asc_space_char) { // RPI-181
						state = 4;
					} else {
						state = 2;
						level = 0;
						if  (token_len >=2 && token.charAt(token_len-1) == '=') {
							key_name  = token.substring(0,token_len-1).toUpperCase();  // RPI-366
							parm_value = "";
						} else {
							key_name = null;
							parm_value = token;
							if (token_first == '(') {
								level = 1;
							}
						}
					}
					break;
				case 2: // build simple or sublist parm
					if (token_first <= asc_space_char // RPI-181
							|| (token_first == ','
								&& level == 0)) {
						if   (key_name == null) {
							set_pos_parm(parm_value);
						} else {
							if (!set_key_parm("&" + key_name,parm_value)) {
								set_pos_parm(key_name + "=" + parm_value);
							}
						}
						if (token_first > asc_space_char) {  // RPI-181
							state = 1;
						} else {
							state = 4;
						}
						break;
					} else if (token_first == '(') {
						level++;
					} else if (token_first == ')') {
						level--;
					}
					parm_value = parm_value + token;
					break;
				case 4:  // ignore spaces and comments
					break;
				default:
					tz390.abort_case();
				}
			}
			if (state == 2) {
				if (key_name != null) {
					if (!set_key_parm("&" + key_name,parm_value)) {
						set_pos_parm(key_name + "=" + parm_value);
					}
				} else {
					set_pos_parm(parm_value);
				}
			}
			if (cur_pos_parm > tot_pos_parm) {
				tot_pos_parm = cur_pos_parm;
			}
		}
		mac_call_pos_tot[mac_call_level] = cur_pos_parm - mac_call_pos_start[mac_call_level]-1;
		if (mac_call_pos_tot[mac_call_level] < 0) {
			mac_call_pos_tot[mac_call_level] = 0;
		}
	}

	/**
	 * Initialize positional parameter
	 *
	 * @param pos_parm_name
	 */
	private void init_pos_parm(String pos_parm_name)
	{
		pos_parm_name = pos_parm_name.toUpperCase(); // RPI-366
		if (tot_pos_parm +1 > tz390.opt_maxparm) {
			abort_error(144,"Maximum positional parms exceeded");
		}
		mac_call_pos_name[tot_pos_parm] = pos_parm_name;
		mac_call_pos_parm[tot_pos_parm] = "";
		if (pos_parm_name.length() > 0) {
			if (find_lcl_key_index("P:" + pos_parm_name) == -1) {
				add_lcl_key_index(tot_pos_parm);
			} else {
				log_error(90,"Duplicate positional parm - " + pos_parm_name);
			}
		}
		tot_pos_parm++;
		if (tot_pos_parm > hwm_pos_parm) {
			hwm_pos_parm = tot_pos_parm;
		}
	}

	/**
	 * Add key work parm name and default value.
	 *
	 * @param kwd_parm_name
	 * @param kwd_parm_value
	 */
	private void init_key_parm(final String kwd_parm_name, final String kwd_parm_value)
	{
		if (tot_kwd_parm +1 > tz390.opt_maxparm) {
			abort_error(145,"Maximum key word parms exceeded");
		}
		mac_call_kwd_name[tot_kwd_parm] = kwd_parm_name;
		mac_call_kwd_parm[tot_kwd_parm] = kwd_parm_value;
		mac_call_kwd_set[tot_kwd_parm]  = false;  // RPI-600
		if (kwd_parm_name.length() > 0) {
			if (find_lcl_key_index("K:" + kwd_parm_name) == -1) {
				add_lcl_key_index(tot_kwd_parm);
			} else {
				log_error(91, "Duplicate keyword parm definition - " + kwd_parm_name);
			}
		}
		tot_kwd_parm++;
		if (tot_kwd_parm > hwm_kwd_parm) {
			hwm_kwd_parm = tot_kwd_parm;
		}
	}

	/**
	 * Initialize positional parameter and increment cur_pos_parm set by.
	 *
	 * @param pos_parm
	 */
	private void set_pos_parm(final String pos_parm)
	{
		mac_call_pos_parm[cur_pos_parm] = pos_parm;
		if (cur_pos_parm >= tot_pos_parm) {
			mac_call_pos_name[cur_pos_parm] = "";
		}
		cur_pos_parm++;
	}

	/**
	 * Set keyword parameter.
	 *
	 * @param key
	 * @param key_parm
	 * @return
	 */
	private boolean set_key_parm(final String key, final String key_parm)
	{
		final int key_index = find_kwd_parm(key);
		if  (key_index != -1) {
			if (!mac_call_kwd_set[key_index]) {
				 mac_call_kwd_set[key_index] = true;
			} else {
				log_error(211, "Duplicate keyword parm on call " + key + "=" + key_parm);
			}
			mac_call_kwd_parm[key_index] = key_parm;
			return true;
		} else {
			return false;
		}
	}

	/**
	 * Find keyword parameter and return index else -1
	 *
	 * @param kwd_name
	 * @return
	 */
	private int find_kwd_parm(String kwd_name)
	{
		int kwd_index = mac_call_kwd_start[mac_call_level];
		while (kwd_index < tot_kwd_parm) {
			if (mac_call_kwd_name[kwd_index].equals(kwd_name)) {
				return kwd_index;
			}
			kwd_index++;
		}
		return -1;
	}

	/**
	 * Wait for az390 to end and display total errors
	 * for both close files and exit to system or caller
	 */
	private void exit_mz390()
	{
		if (tz390.opt_asm && az390 != null) {  // RPI-433 finish az390 even if mz390 abort
			if (az390.az390_running) {
				if (tz390.z390_abort) {
					az390.mz390_abort = true; // RPI-433
				}
				call_az390_pass_bal_line(null);
				bal_eof = true;
			}
			while (az390.az390_running) { // RPI-846 RPI-935 wait for az390 to write stats etc.
				tz390.sleep_now(tz390.monitor_wait);
			}
			tz390.systerm_io = tz390.systerm_io+az390.tz390.systerm_io;  // RPI-755 RPI-846
			if (az390.az390_rc > mz390_rc) {
				mz390_rc = az390.az390_rc;
			}
		}
		put_stats();
		if (tz390.opt_asm) { // RPI-935
			az390.put_stats();
			az390.close_files();
		}
		if (tz390.opt_asm && az390 != null
			&& az390.az390_rc > mz390_rc) {
			mz390_rc = az390.az390_rc;  // RPI-425
		} else if (mz390_rc == 0) {
			mz390_rc = hwm_mnote_level; // RPI-1089
		}
		close_files(); // RPI-1089 move after rc setting
		System.exit(mz390_rc);
	}

	/*
	 * 1. Display mz390 statistics on STA file if option STATS.
	 * 2. If ASM pass file names and merge file errors from mz390 and
	 *    lookahead phase of az390 for use in file xref at end of PRN.
	 * 3. Put_stats called from mz390 to sync with mz390 put_stats on STA
	 *    and to include total mz and az errors on TRM. RPI-846
	 * Notes:
	 * Use tz390.put_stat_line to route line to end of BAL or stat(file) option
	 */
	private void put_stats()
	{
		log_to_bal = false;
		if  (tz390.opt_stats) { // RPI-453
			tz390.put_stat_final_options(); // RPI-755
			put_stat_line("total MLC/MAC loaded  = " + tot_mac_line);
			put_stat_line("total BAL output lines= " + tot_bal_line);
			if (tot_aread_io + tot_punch_io > 0) {
				put_stat_line("total AREAD input     = " + tot_aread_io);
				put_stat_line("total PUNCH output    = " + tot_punch_io);
			}
			put_stat_line("total BAL instructions= " + tot_ins);
			put_stat_line("total macros          = " + tot_mac_name);
			put_stat_line("total macro loads     = " + tot_mac_load);
			put_stat_line("total macro calls     = " + tot_mac_call);
			put_stat_line("total AENTRY blocks   = " + zsm_aentry_tot); // RPI-1078
			put_stat_line("total ACALL  calls    = " + zsm_acall_tot); // RPI-1078
			put_stat_line("total AIF    blocks   = " + zsm_aif_tot); // RPI-1078
			put_stat_line("total ACASE  blocks   = " + zsm_acase_tot); // RPI-1078
			put_stat_line("total AWHILE calls    = " + zsm_awhile_tot); // RPI-1078
			put_stat_line("total AUNTIL blocks   = " + zsm_auntil_tot); // RPI-1078
			put_stat_line("total global set names= " + tot_gbl_name);
			put_stat_line("tot global seta cells = " + tot_gbl_seta);
			put_stat_line("tot global setb cells = " + tot_gbl_setb);
			put_stat_line("tot global setc cells = " + tot_gbl_setc);
			put_stat_line("max local pos parms   = " + hwm_pos_parm);
			put_stat_line("max local key parms   = " + hwm_kwd_parm);
			put_stat_line("max local set names   = " + hwm_lcl_name);
			put_stat_line("max local seta cells  = " + hwm_lcl_seta);
			put_stat_line("max local setb cells  = " + hwm_lcl_setb);
			put_stat_line("max local setc cells  = " + hwm_lcl_setc);
			put_stat_line("total array expansions= " + tot_expand);
			put_stat_line("total Keys            = " + tz390.tot_key);
			put_stat_line("Key searches          = " + tz390.tot_key_search);
			if (tz390.tot_key_search > 0) {
				tz390.avg_key_comp = tz390.tot_key_comp/tz390.tot_key_search;
			}
			put_stat_line("Key avg comps         = " + tz390.avg_key_comp);
			put_stat_line("Key max comps         = " + tz390.max_key_comp);
			put_stat_line("total macro line exec = " + tot_mac_ins);
			put_stat_line("total pcode line exec = " + tot_pcl_exec);
			put_stat_line("total pcode line gen. = " + tot_pcl_gen);
			put_stat_line("total pcode line reuse= " + tot_pcl_reuse);
			put_stat_line("total pcode op   gen. = " + tot_pc_gen);
			put_stat_line("total pcode op   exec = " + tot_pc_exec);
			put_stat_line("total pcode gen  opt  = " + tot_pc_gen_opt);
			put_stat_line("total pcode exec opt  = " + tot_pc_exec_opt);
			if  (tz390.opt_timing) {
				cur_date = new Date();
				tod_end = cur_date.getTime();
				tot_msec = tod_end-tod_start+1;
				put_stat_line("total milliseconds    = " + tot_msec);
				if (tot_msec > 0) {  // RPI-1131 prevent overflow
					ins_rate = (long)tot_mac_ins*1000/(long)tot_msec;
					put_stat_line("instructions/second   = " + ins_rate);
				}
			}
		}
		int index = 0;
		while (index < tot_mac_file_name) {
			String xref_msg = "FID=" + tz390.right_justify(""+(index+1),3)
							+ " ERR=" + tz390.right_justify(""+mac_file_errors[index],2)
							+ " " + mac_file_path[index];
			if (tz390.opt_stats) {
				put_stat_line(xref_msg);
			}
			if (!tz390.opt_asm && mac_file_errors[index] > 0) {  // RPI-425
				tz390.put_systerm(msg_id + xref_msg);
			}
			if (tz390.opt_asm) { // RPI-426
				// transfer xref file/line to az390 for
				// combined error xref at end of PRN
				az390.tot_xref_files = tot_mac_file_name;
				az390.xref_file_name[index] = mac_file_path[index];
				az390.xref_file_errors[index] = az390.xref_file_errors[index] + mac_file_errors[index];
			}
			index++;
		}
		if (tz390.opt_stats) {
			put_stat_line("total mnote warnings  = " + tot_mnote_warning); // RPI-402
			put_stat_line("total mnote errors    = " + tot_mnote_errors);
			put_stat_line("max   mnote level     = " + cur_sysm_hsev);  // RPI-898
			put_stat_line("total mz390 errors    = " + mz390_errors);
		}
		if (!tz390.opt_asm) {
			log_to_bal = true;
			put_log(msg_id + "total mnote warnings = " + tot_mnote_warning); // RPI-402
			put_log(msg_id + "total mnote errors   = " + tot_mnote_errors);
			put_log(msg_id + "max   mnote level    = " + cur_sysm_hsev);  // RPI-898
			put_log(msg_id + "total mz390 errors   = " + mz390_errors);
			if (tz390.opt_asm) { // RPI-846
				put_stat_line("total az390 errors    = " + az390.az390_errors);
			}
		} else if (tz390.opt_tracem) {
			tz390.put_trace(msg_id + "total mnote warnings  = " + tot_mnote_warning); // RPI-402
			tz390.put_trace(msg_id + "total mnote errors    = " + tot_mnote_errors);
			tz390.put_trace(msg_id + "max   mnote level     = " + cur_sysm_hsev);  // RPI-898
			tz390.put_trace(msg_id + "total mz390 errors    = " + mz390_errors);
			if (tz390.opt_asm) {  // RPI-935
				tz390.put_trace(msg_id + "total az390 errors    = " + az390.az390_errors); // RPI-846
			}
		}
		log_to_bal = false;
	}

	/**
	 * Routine statistics line to BAL or STATS(file).
	 *
	 * @param msg
	 */
	private void put_stat_line(final String msg)
	{
		if (tz390.stats_file != null) {
			tz390.put_stat_line(msg);
		} else {
			put_log(msg_id + msg);
		}
	}

	/**
	 * Close bal, pch, err, trm
	 */
	private void close_files()
	{
		if (tz390.opt_bal && bal_file_buff != null) {
			try {
				bal_file_buff.close();
			} catch (final Exception e) {
				abort_error(34, "I/O error on BAL close - " + e.toString());
			}
		}
		pch_file_index = 0;
		while (pch_file_index < max_ap_files) {
			if (pch_file[pch_file_index] != null && pch_file[pch_file_index].isFile()) {
				close_pch_file(pch_file_index);
			}
			pch_file_index++;
		}
		tz390.close_systerm(mz390_rc);
		if (tz390.opt_tracem) {
			tz390.force_nocon = true; // RPI-1050
			tz390.put_trace(tz390.ended_msg);
			tz390.force_nocon = false; // RPI-1050
		}
		tz390.close_trace_file();
	}

	/**
	 * Close specific DAT file.
	 *
	 * @param index
	 */
	private void close_dat_file(final int index)
	{
		try {
			dat_file_buff[index].close();
			dat_file[index] = null;
		} catch (final Exception e) {
			abort_error(69, "I/O error on AREAD file ID=" + index + " close - " + e.toString());
		}
	}

	/**
	 * Close specific PCH file.
	 *
	 * @param index
	 */
	private void close_pch_file(final int index)
	{
		try {
			pch_file_buff[index].close();
			pch_file[index] = null;
		} catch (final Exception e) {
			abort_error(77,"I/O error on PUNCH file ID=" + index + " close - " + e.toString());
		}
	}

	/**
	 * Create mnote on BAL and ERR.
	 *
	 * @param level
	 * @param text
	 */
	private void create_mnote(final int level, final String text)
	{
		process_mnote(level,"'" + text + "'");
	}

	/**
	 * Put mnote message on BAL and ERR files
	 *
	 * @param level
	 * @param msg
	 */
	private void process_mnote(final int level, String msg)
	{
		msg = tz390.ascii_printable_string(msg); // RPI-938
		if (level >= 0 // RPI-415 let az390 report mnote in seq on ERR
			&& (!tz390.opt_asm || tz390.opt_mnote == 2)
			|| mlc_eof) { // RPI-1142 put on ERR if no ASMm RPI-1169
			tz390.put_systerm("MNOTE " + level + "," + msg); // RPI-330, RPI-440, RPI-444
		}
		if (level > tz390.max_mnote_warning
			&& tz390.opt_mnote != 1) { // RPI-1142
			if (tz390.opt_traces || tz390.opt_con) {  // RPI-935
				System.out.println("MZ390E MNOTE " + level + "," + msg); // RPI-882
			}
			tot_mnote_errors++;
			int file_index = mac_file_num[mac_line_index]; // RPI-895
			mac_file_errors[file_index]++;                 // RPI-895
		} else if (level > 0) {
			tot_mnote_warning++;
		}
		if (level > hwm_mnote_level) {
			hwm_mnote_level = level;   // RPI-410
		}
		if (level > cur_sysm_hsev) {
			cur_sysm_hsev = level;
			String sysm_hsev = "00" + cur_sysm_hsev; // RPI-898
			gbl_setc[gbl_sysm_hsev_index] = sysm_hsev.substring(sysm_hsev.length()-3); // RPI-898
		}
		if (mac_call_level >= 0  // RPI-1169
			&& level > mac_call_sysm_sev[mac_call_level]) {  // RPI-898
			mac_call_sysm_sev[mac_call_level] = level;   // RPI-898
		}
		if (tz390.opt_mnote != 2) { // RPI-1132
			if (level > 0) {
				put_bal_line("         MNOTE " + level + "," + msg);
			} else if (level == 0) {
				put_bal_line("         MNOTE " + msg); // RPI-938
			} else {
				put_bal_line("         MNOTE *," + msg); // RPI-938
			}
		}
	}

	/**
	 * Punch record on PCH and list on PRN.
	 * If ASM and NOALLOW pad to 80 bytes.
	 */
	private void process_punch()
	{
		if (bal_parms.length() > 2
			&& bal_parms.charAt(0) == '\'') {
			String text = bal_parms;
			tz390.parm_match = tz390.parm_pattern.matcher(text);
			if (tz390.parm_match.find()
				&& tz390.parm_match.start(0) == 0) {
				int index = tz390.parm_match.end();
				String rec = replace_quoted_text_vars(tz390.parm_match.group(),false);
				if (rec.length() < 2) { // RPI-1131
					log_error(269,"PUNCH syntax error - " + bal_parms);
					return;
				}
				rec = rec.substring(1,rec.length()-1);
				if (rec.length() == 0 && !tz390.opt_allow) {
					log_error(287,"PUNCH record length = 0"); // RPI-1139
				}
				if ((index >= bal_parms.length()
					 || bal_parms.charAt(index) <= ' ')
					&& tz390.opt_asm
					&& !tz390.opt_allow) { // RPI-968
					rec = set_length_80(rec);
				}
				put_bal_line("         PUNCH " + "'" + rec + "'" + bal_parms.substring(index));  // RPI-410 RPI-965 RPI-1018
				put_pch_line("'" + rec + "'" + bal_parms.substring(index)); // RPI-965
				return;
			}
		}
		put_bal_line("         PUNCH " + bal_parms);  // RPI-410 RPI-965 RPI-1018
		log_error(269,"PUNCH syntax error - " + bal_parms);
	}

	/**
	 * Replace variables in MNOTE or PUNCH 'text' after verifying single quote text ok.
	 *
	 * @param text
	 * @param reduce
	 * @return
	 */
	private String replace_quoted_text_vars(String text, final boolean reduce) // RPI-965
	{
		if (text.length() >= 2 && text.charAt(0) == '\'') {
			if (text.charAt(1) == '\'' && (text.length() == 2 || text.charAt(2) == ',')) {
				return bal_parms; // RPI-965
			}
			tz390.parm_match = tz390.parm_pattern.matcher(text);
			String text_parm = "";
			if (tz390.parm_match.find()
				&& tz390.parm_match.start(0) == 0
				&& (tz390.parm_match.end() >= text.length()
					|| text.charAt(tz390.parm_match.end()) <= ' '
					|| text.charAt(tz390.parm_match.end()) == ',')) { // RPI-965 allow for DD??= extensions
				text_parm = tz390.parm_match.group();
				if (tz390.parm_match.end() < text.length()) {
					text_parm = text_parm + text.substring(tz390.parm_match.end()); // add comments after replacement
				}
				return replace_vars(text_parm,reduce,false);
			} else {
				put_bal_line("         MNOTE " + bal_parms + " see MZ390 error");
				log_error(261,"MNOTE/PUNCH text must be in single quotes" + bal_parms); // RPI-965
			}
		} else {
			put_bal_line("         MNOTE " + bal_parms + " see MZ390 error");
			log_error(262,"MNOTE/PUNCH invalid 'text' - " + bal_parms); // RPI-938
		}
		return text;
	}

	/**
	 * Issue error msg to log with prefix and inc error total.
	 *
	 * Notes:
	 * If exp_replacement mode error ignore and return setc_value = null
	 * except for 208 SYSLIST substitution error
	 *
	 * @param error
	 * @param msg
	 */
	private void log_error(final int error, final String msg)
	{
		if (mac_abort) return;

		mac_abort = true;
		exp_end = true;
		if (exp_var_replacement_mode  // RPI-241
			&& error != 208  // RPI-565 bad SYSLIST sub
			&& error != 218  // RPI-659 invalid symbol label substitution
			&& error != 288  // RPI-1139 undefined macro var ref
			&& tz390.opt_asm) { // RPI-529 issue error now if mac only
			exp_setc = null;
			return;
		}
		mz390_errors++;
		if (mz390_rc < 12) { // RPI-1062
			mz390_rc = 12;
		}
		log_to_bal = true;
		final int file_index = mac_file_num[mac_line_index];
		mac_file_errors[file_index]++;
		String error_msg = "MZ390E error " + tz390.right_justify("" + error,3)
							+ tz390.right_justify("(" + (file_index+1)
							+ "/" + mac_file_line_num[mac_line_index]
							+ ")" + mac_file_line_num[mac_line_index],15)
							+ " " + msg;
		if (tz390.opt_asm
		 && az390.tz390.opt_errsum) {  // RPI-694 (see az390 log_error also)
			if (error == 101 || error == 266) {  // RPI-694 RPI-1051
				if (!az390.add_missing_copy(mac_parms)) {
					abort_error(219,"Maximum missing copy exceeded");
				}
			}
		}
		if (tz390.opt_traces) {
			System.out.println("MZ390E " + msg); // RPI-882
		}
		put_log(error_msg);
		tz390.put_systerm(error_msg);
		if (tz390.max_errors != 0 && mz390_errors > tz390.max_errors) {
			abort_error(83,"Maximum errors exceeded");
		}
	}

	/**
	 * Issue error msg to log with prefix and inc error total.
	 *
	 * @param error
	 * @param msg
	 */
	private synchronized void abort_error(final int error, String msg)
	{
		mz390_errors++;
		mz390_rc = 16;  // RPI-1062
		if (tz390.z390_abort) {
			msg = msg_id + "aborting due to recursive abort for " + msg;
			System.out.println(msg);
			tz390.put_systerm(msg);
			if (tz390.opt_asm
				&& az390.tz390.opt_errsum) {
				az390.report_critical_errors();
			}
			tz390.close_systerm(mz390_rc);
			System.exit(mz390_rc);
		}
		tz390.z390_abort = true;
		tz390.opt_con = true; // RPI-453
		log_to_bal = true;
		String err_line_and_num = "";
		if (mac_file_num != null && mac_line_index >= 0) { // RPI-812 RPI-1052
			int file_index = mac_file_num[mac_line_index];
			mac_file_errors[file_index]++;  // RPI-432
			if (mac_line_index < tz390.opt_maxline) {
				err_line_and_num =
				   " file=" + (file_index+1)
				 + " line=" + mac_file_line_num[mac_line_index];
			}
		}
		msg = "MZ390E abort " + error + err_line_and_num + " " + msg;
		put_log(msg);
		tz390.put_systerm(msg);
		exit_mz390();
	}

	/**
	 * Display mz390 version, time stamp, and copyright if running standalone.
	 */
	private void put_copyright()
	{
		tz390.force_nocon = true; // RPI-755
		if  (tz390.opt_timing) {
			cur_date = new Date();
		}
		if (tz390.opt_stats) {
			put_stat_line(Constants.sCopyright2011);
			put_stat_line(Constants.sCopyright2013);
			put_stat_line(Constants.sCopyright2018);
			put_stat_line(Constants.sGnuLicence);
			put_stat_line("program = " + tz390.dir_mlc + tz390.pgm_name + tz390.pgm_type);
			put_stat_line("options = " + tz390.cmd_parms);
		}
		if (tz390.opt_tracem) {
			tz390.put_trace(msg_id + Constants.sCopyright2011);
			tz390.put_trace(msg_id + Constants.sCopyright2013);
			tz390.put_trace(msg_id + Constants.sCopyright2018);
			tz390.put_trace(msg_id + Constants.sGnuLicence);
			tz390.put_trace(msg_id + "program = " + tz390.dir_mlc + tz390.pgm_name + tz390.pgm_type);
			tz390.put_trace(msg_id + "options = " + tz390.cmd_parms);
		}
		tz390.force_nocon = false; // RPI-755 RPI-935
	}

	/**
	 * Write message to z390_log_text or console if running standalone.
	 * @param msg
	 */
	private synchronized void put_log(final String msg)
	{
		if  (log_to_bal) {
			put_bal_line("* " + msg);
		}
		if (tz390.opt_tracem) {
			tz390.put_trace(trace_id + msg);
		}
		if  (z390_log_text != null) {
			z390_log_text.append(msg + "\n");
		}
		if (tz390.opt_con) { // RPI-453
			System.out.println(msg);
		}
	}

	/**
	 * Return user_key_index for lcl user_key else -1
	 * and set following for possible add_key_index:
	 *    1.  lcl_key_text = user_key
	 *    2.  lcl_key_hash = hash code for key
	 *    3.  lcl_key_index_last = last search entry
	 *
	 *  lcl key types are:
	 *     K: - key word macro parm
	 *     B: - local macro label
	 *     P: - postional macro parm
	 *     L: = local set variable
	 *
	 * See tz390 with global find_key_index types FGMORSX.
	 *
	 * @param user_key
	 * @return
	 */
	private int find_lcl_key_index(final String user_key)
	{
		tz390.tot_key_search++;
		lcl_key_text = user_key;
		lcl_key_hash  = lcl_key_text.hashCode(); // RPI-434
		lcl_key_index = Math.abs(lcl_key_hash % max_lcl_key_root) + cur_lcl_key_root;
		if (lcl_key_tab_key[lcl_key_index] == null) {
			lcl_key_index_last = lcl_key_index;
			return -1;
		}
		int cur_key_comp = 0;
		while (lcl_key_index >= cur_lcl_key_root) {
			tz390.tot_key_comp++;
			cur_key_comp++;
			if (cur_key_comp > tz390.max_key_comp) {
				tz390.max_key_comp = cur_key_comp;
			}
			if (lcl_key_hash == lcl_key_tab_hash[lcl_key_index]
			 && user_key.equals(lcl_key_tab_key[lcl_key_index])) {
				lcl_key_index_last = -1;
				return lcl_key_tab_index[lcl_key_index];
			}
			lcl_key_index_last = lcl_key_index;
			if (lcl_key_hash < lcl_key_tab_hash[lcl_key_index]) {
				lcl_key_index = lcl_key_tab_low[lcl_key_index];
			} else {
				lcl_key_index = lcl_key_tab_high[lcl_key_index];
			}
		}
		return -1;
	}

	/**
	 * Add lcl user_index entry based on lcl_key_text, lcl_key_hash, and lcl_key_index_last
	 * set by prior find_lcl_key_index
	 *
	 * @param user_index
	 */
	private void add_lcl_key_index(int user_index)
	{
		if (lcl_key_index_last < 0 || lcl_key_index_last > lcl_key_tab_key.length) {
			abort_error(191,"Invalid key index add sequence");
		}
		if (lcl_key_tab_key[lcl_key_index_last] == null) {
			lcl_key_index = lcl_key_index_last;
		} else {
			if (tot_lcl_key_tab < max_lcl_key_tab) {
				lcl_key_index = tot_lcl_key_tab;
				tot_lcl_key_tab++;
			} else {
				abort_error(89,"LCL key search table exceeded");
			}
			if (lcl_key_hash < lcl_key_tab_hash[lcl_key_index_last]) {
				lcl_key_tab_low[lcl_key_index_last] = lcl_key_index;
			} else {
				lcl_key_tab_high[lcl_key_index_last] = lcl_key_index;
			}
		}
		tz390.tot_key++;
		lcl_key_tab_key[lcl_key_index]   = lcl_key_text;
		lcl_key_tab_hash[lcl_key_index]  = lcl_key_hash;
		lcl_key_tab_index[lcl_key_index] = user_index;
		lcl_key_tab_low[lcl_key_index] = 0;
		lcl_key_tab_high[lcl_key_index] = 0;
	}

	//****************************************
	//* Pseudo Code Support Routines
	//****************************************

	/**
	 * gen pc code for exp if pc_gen_exp.
	 *
	 * @param op
	 */
	private void gen_exp_pc(byte op)
	{
		if (pc_gen_exp) {
			if (op < pc_op_add || op > pc_op_div) {
				flush_pc_pending();
			}
			gen_pc(op);
		}
	}

	/**
	 * Generate pushv or pushvs.
	 *
	 * @param op
	 */
	private void gen_pc(final byte op)
	{
		if (!tz390.opt_pc) {
			return;
		}
		tracem_pc_op = false;
		switch (op) {
		case  1: // gen pc_op_ago computed branch
			get_pc(op);
			if (ago_gbla_index < 0) {  // RPI-899 was < 1
				abort_pc("undefined ago label " + pc_setc[pc_loc]);
			} else {
				pc_seta[pc_loc] = ago_gbla_index;
			}
			break;
		case  2: // gen pc_op_aif    branch if stack value not 0
			get_pc(op);
			pc_seta[pc_loc] = new_mac_line_index;
			pc_setc[pc_loc] = label_name;  // RPI-521
			break;
		case  3: // gen pc_op_pushv  push var on stack
			get_pc(op);
			pc_var_type[pc_loc] = var_type;
			pc_var_loc[pc_loc]  = var_loc;
			pc_seta[pc_loc]     = var_name_index;
			pc_setc[pc_loc]     = var_name;
			pc_req_opt[pc_loc]  = true; // request inc/dec opt
			break;
		case  4: // gen pc_op_pushvs       calculate var subscript
			get_pc(op);
			pc_var_type[pc_loc] = var_type;
			pc_var_loc[pc_loc]  = var_loc;
			if (var_name.equals("&SYSLIST")) {
				pc_seta[pc_loc] = -1;
			} else {
				pc_seta[pc_loc] = var_name_index;
			}
			pc_setc[pc_loc]     = var_name;
			break;
		case  5: // gen gen pc_op_pusha  push seta self defining term
			get_pc(op);
			pc_seta[pc_loc] = seta_value;
			pc_setc[pc_loc] = setc_value;
			break;
		case  6: // gen pc_op_pushc  push setc string constant
			get_pc(op);
			pc_setc[pc_loc] = pc_pushc_setc_value;
			break;
		case  7: // gen pc_op_concat concatentate setc constant or two values if null
			get_pc(op);
			pc_var_type[pc_loc] = pc_parm_type;
			if (pc_parm_type == var_pc_setc_sdt_type) {
				pc_setc[pc_loc]     = setc_value2;
			}
			break;
		case  8: // gen pc_op_storv store scalar var
			tracem_pc_op = true; // RPI-930
			get_pc(op);
			pc_var_type[pc_loc] = store_type;
			pc_var_loc[pc_loc]  = store_loc;
			pc_seta[pc_loc]     = store_name_index;
			pc_setc[pc_loc]     = store_name;
			var_type = store_type;
			break;
		case  9: // gen pc_op_storvs store subscripted set var
			tracem_pc_op = true; // RPI-930
			get_pc(op);
			pc_var_type[pc_loc] = store_type;
			pc_var_loc[pc_loc]  = store_loc;
			pc_seta[pc_loc] = store_name_index;
			pc_setc[pc_loc] = store_name;
			var_type = store_type;
			break;
		case 10: // gen pc_op_storvn store next value in var(sub+1)
			tracem_pc_op = true; // RPI-930
			get_pc(op);
			pc_var_type[pc_loc] = store_type;
			pc_var_loc[pc_loc]  = store_loc;
			pc_seta[pc_loc] = store_name_index;
			pc_setc[pc_loc] = store_name;
			var_type = store_type;
			break;
		case 11: // gen pc_op_add          add 2 entries on stack leaving 1
		case 12: // gen pc_op_sub          sub 2 entries on stack leaving 1
		case 13: // gen pc_op_mpy          mpy 2 entries on stack leaving 1
		case 14: // gen pc_op_div          div 2 entries on stack leaving 1
		case 15: // gen pc_op_compeq           compare equal
		case 16: // gen pc_op_compge           compare greater than or equal
		case 17: // gen pc_op_compgt           compare greater than
		case 18: // gen pc_op_comple           compare greater less than or equal
		case 19: // gen pc_op_complt           compare equal
		case 20: // gen pc_op_compne           compare greater than or equal
		case 21: // gen pc_op_ucomp        unary compliment value on stack
		case 22: // gen pc_op_dup          duplicate string
			tracem_pc_op = true; // RPI-930
			get_pc(op);
			pc_var_type[pc_loc] = pc_parm_type;
			if (pc_parm_type == var_pc_seta_sdt_type) {
				pc_seta[pc_loc] = seta_value2;
			} else if (pc_parm_type == var_pc_setc_sdt_type) {
				pc_setc[pc_loc] = setc_value2;
			}
			break;
		case 23: // gen pc_op_sublst calculate setc sublist
			get_pc(op);
			if (exp_next_first == ')') {
				exp_sublst_op = pc_op_pushvs;
			}
			break;
		case 24: // gen pc_op_substr calc setc substring
			get_pc(op);
			break;
		case 25: // gen pc_op_inc (see opt_pc)
		case 26: // gen pc_op_dec (see opt_pc)
			tracem_pc_op = true; // RPI-930
			get_pc(op);
			break;
		case 27: // gen pc_op_pushd push scalar dynamic var using name on stack
		case 28: // gen pc_op_pushds push suscripted dynamic var using name and subscript on stack
			get_pc(op);
			pc_setc[pc_loc] = var_name;
			break;
		case 29: // gen pc_op_stord  store scalar dynamic var using name on stack
		case 30: // gen pc_op_stords store subscripted dynamic var using name and subscript on stack
			tracem_pc_op = true; // RPI-930
			get_pc(op);
			pc_setc[pc_loc] = store_name;
			break;
		case 31: // gen pc_op_pfx_a A' lookahead defined symbol
		case 32: // gen pc_op_pfx_d D' ordinary defined symbol
		case 33: // gen pc_op_pfx_i I' integer count
		case 34: // gen pc_op_pfx_k K' character count
		case 35: // gen pc_op_pfx_l L' ordinary symbol length
		case 36: // gen pc_op_pfx_n N' number of sublist operands
		case 37: // gen pc_op_pfx_o O' operator
		case 38: // gen pc_op_pfx_s S' scale factor
		case 39: // gen pc_op_pfx_t T' symbol type
			get_pc(op);
			break;
		case 40: // gen pc_op_pushs push symbol abs value else 0
			get_pc(op);
			pc_setc[pc_loc] = setc_value;
			break;
		case 41: // gen gen pc_op_storei inc store index by seta
			tracem_pc_op = true; // RPI-930
			get_pc(op);
			pc_seta[pc_loc] = seta_value;
			pc_setc[pc_loc] = setc_value;
			break;
		case 45: // gen pc_op_a2b  convert value to binary string (3 = '11')
		case 46: // gen pc_op_a2c  convert value to character string (240 = '1')
		case 47: // gen pc_op_a2d   convert value to decimal string (1 = '1')
		case 48: // gen pc_op_a2x  convert value to hex string (240 = 'F0')
		case 49: // gen pc_op_and  logical and (NC)
		case 50: // gen pc_op_b2a  convert binary string to value (B2A('100') = 4)
		case 51: // gen pc_op_b2c  convert binary string to character string ('11110000' = '1')
		case 52: // gen pc_op_b2d   convert binary string to decimal string ('100' = '4')
		case 53: // gen pc_op_b2x  convert binary string to hex string ('11110000' = 'F0')
		case 54: // gen pc_op_c2a  convert 0= 45: // gen // gen 4 characters to value (C2A('0') = 240)
		case 55: // gen pc_op_c2b  convert character string to binary string ('1' = '11110000')
		case 56: // gen pc_op_c2d   convert character string to decimal string ('1' = '240')
		case 57: // gen pc_op_c2x  convert character string to hex string ('1' = 'F0')
		case 58: // gen pc_op_d2a  convert decimal string to value
		case 59: // gen pc_op_d2b  convert decimal string to binary string ('4' = '100')
		case 60: // gen pc_op_d2c   convert decimal string to character string('240'  = '1')
		case 61: // gen pc_op_d2x    convert decimal string to hex string ('240' = 'F0')
		case 62: // gen pc_op_dclen  length of string after reducing double ' and &
		case 63: // gen pc_op_dcval  return string with double ' and & reduced
		case 64: // gen pc_op_DEQUOTE return string without first and last ' if any
		case 65: // gen pc_op_double double quotes and & in string (NC)
		case 66: // gen pc_op_find   return index of any char in string2 found in string1 (NC)
		case 67: // gen pc_op_index  return index of string2 found in string1 else 0 (NC)
		case 68: // gen pc_op_isbin  return 1 if valid binary string else 0
		case 69: // gen pc_op_isdec  return 1 if valid decimal string else 0
		case 70: // gen pc_op_ishex  return 1 if valid hex string else 0
		case 71: // gen pc_op_issym  return 1 if valid character string for symbol else 0
		case 72: // gen pc_op_lower  return lower case string (NC)
		case 73: // gen pc_op_not    logical or arithmetic not (NC)
		case 74: // gen pc_op_or     logical or (NC)
		case 75: // gen pc_op_upper  return upper case string (NC)
		case 76: // gen pc_op_signed return decimal string with minus sign if negative
		case 77: // gen pc_op_sla    shift left arithmetic (2 SLA 1 = 4)
		case 78: // gen pc_op_sll    shift left logical (2 SLL 1 = 4)
		case 79: // gen pc_op_sra    shift right arithmetic (4 SRA 1 = 2)
		case 80: // gen pc_op_srl    shift right logical (4 SRL 1 = 2)
		case 81: // gen pc_op_sysattra return assembler attribute for symbol (EQU 4th)
		case 82: // gen pc_op_sysattrp  return program attribute for symbol (EQU 5th)
		case 83: // gen pc_op_x2a   convert hex string to value (X2A('F0') = 240)
		case 84: // gen pc_op_x2b   convert hex string to binary string ('F0' = '11110000')
		case 85: // gen pc_op_x2c    convert hex string to character string('F0'  = '1')
		case 86: // gen pc_op_x2d   convert hex string to decimal string ('F0' = '240')
		case 87: // gen pc_op_xOr   logical exclusive or (NC)
			get_pc(op);
			break;
		default:
			abort_pc("invalid pc op - " + pc_op[pc_loc]);
		}
		if (tz390.opt_tracep
			|| (tz390.opt_tracem && tracem_pc_op)) { // RPI-930
			trace_pc();
		}
	}

	/**
	 * Move this mac line to most recently used entry and then
	 * execute pseudo code starting at pc_loc until pc_end entry found.
	 */
	private void exec_pc()
	{
		update_mru();
		// exec pc code
		pc_trace_gen = false;
		if (tz390.opt_tracem
			&& !(mac_file_line[mac_line_index].length() > 0
			     && mac_file_line[mac_line_index].charAt(0) == '*')
			&& (tz390.opt_tracec // RPI-862 skip copy trace // RPI-862 skip COPY trace
				|| mac_file_type[mac_file_num[mac_line_index]] != '=')) {
			trace_id = tz390.left_justify(mac_name[mac_call_name_index[mac_call_level]],9)
					 + tz390.right_justify("" + mac_file_line_num[mac_line_index],6)
					 + "        ";
			tz390.put_trace(trace_id + " " + mac_file_line[mac_line_index]);
		}
		tot_exp_stk_var = 0;
		tot_pcl_exec++;
	//	pc_loc_prev = 0; // JBA-unused
		while (pc_loc > 0) {
			tot_pc_exec++;
			mac_branch = false;
			if (tz390.opt_pcopt
					&& pc_req_opt[pc_loc]) {
				opt_pcl();
			}
			tracem_pc_op = false; // RPI-930
			exec_pc_op = true; // RPI-1139
			switch (pc_op[pc_loc]) {
			case 1: // exec pc_op_ago - branch to new mac line
				ago_gbla_index = pc_seta[pc_loc];
				ago_index = get_seta_stack_value(-1);
				tot_exp_stk_var--;
				exec_pc_ago();
				break;
			case 2: // exec pc_op_aif - branch if stack value not 0
				if (tot_exp_stk_var == 1) {
					setb_value = get_setb_stack_value(-1);
					tot_exp_stk_var--;
					if (setb_value != 0) {
						actr_count--;
						if (pc_seta[pc_loc] < 0) { // RPI-521
							abort_pc("aif undefined branch label " + pc_setc[pc_loc]);
						} else {
							mac_line_index = pc_seta[pc_loc];
						}
						if (tz390.opt_tracep) {
							trace_pc();
						}
						if (tz390.opt_tracem) { // RPI-899
							trace_break();
						}
						return; // RPI-774 exit pc oode on first branch
					}
				} else {
					abort_pc("invalid aif stack");
				}
				break;
			case 3: // exec pc_op_pushv
				if (inc_tot_exp_stk_var()) {
					if (!get_pc_var()) {
						return;  // RPI-950
					}
					if (var_loc == var_lcl_loc) {
						var_type = lcl_set_type[var_name_index];
					    val_type = get_val_type();
					} else if (var_loc == var_gbl_loc) {
						var_type = gbl_set_type[var_name_index];
					    val_type = get_val_type();
					} else {
						var_type = var_parm_type;
						val_type = val_setc_type;
					}
					var_subscript_calc = false;
					get_pc_var_value();
					push_pc_var();
				}
				break;
			case  4: // exec pc_op_pushvs calc var subscript
				if (tot_exp_stk_var >= 1) {
					if (!get_pc_var()) {
						return;  // RPI-950
					}
					set_sub = get_seta_stack_value(-1);
					tot_exp_stk_var--;
					var_subscript_calc = true;
					exec_pc_pushvs();
				} else {
					abort_pc("missing var subscript");
				}
				break;
			case 5: // exec pc_op_pusha push seta type self defining term
				if (inc_tot_exp_stk_var()) {
					exp_stk_var_type[tot_exp_stk_var-1] = var_seta_type;
					exp_stk_val_type[tot_exp_stk_var-1] = val_seta_type;
					seta_value = pc_seta[pc_loc];
					exp_stk_seta[tot_exp_stk_var-1] = seta_value;
				}
				break;
			case 6:  // exec pc_op_pushc
				if (inc_tot_exp_stk_var()) {
					exp_stk_var_type[tot_exp_stk_var-1] = var_setc_type;
					exp_stk_val_type[tot_exp_stk_var-1] = val_setc_type;
					setc_value = pc_setc[pc_loc];
					exp_stk_setc[tot_exp_stk_var-1] = setc_value;
				}
				break;
			case 7: // exec pc_op_concat concatenate setc constant or two values on stack
				pc_parm_type = pc_var_type[pc_loc];
				get_pc_parms();
				setc_value = setc_value1 + setc_value2;
				put_setc_stack_var();
				break;
			case  8: // exec pc_op_storv - store scalar set
				tracem_pc_op = true; // RPI-930
				exec_pc_store(pc_op_storv);
				break;
			case  9:  // exec pc_op_storvs - store stack at set and incr set
				tracem_pc_op = true; // RPI-930
				exec_pc_store(pc_op_storvs);
				break;
			case 10: // exec pc_op_storvn store next var(sub+1)
				tracem_pc_op = true; // RPI-930
				exec_pc_store(pc_op_storvn);
				break;
			case 11: // exec pc_op_add
				tracem_pc_op = true; // RPI-930
				pc_parm_type = pc_var_type[pc_loc];
				exec_pc_add();
				break;
			case 12: // exec pc_op_sub
				tracem_pc_op = true; // RPI-930
				pc_parm_type = pc_var_type[pc_loc];
				exec_pc_sub();
				break;
			case 13: // exec pc_op_mpy
				tracem_pc_op = true; // RPI-930
				pc_parm_type = pc_var_type[pc_loc];
				exec_pc_mpy();
				break;
			case 14: // exec pc_op_div
				tracem_pc_op = true; // RPI-930
				pc_parm_type = pc_var_type[pc_loc];
				exec_pc_div();
				break;
			case 15: // exec pc_op_compeq
				tracem_pc_op = true; // RPI-930
				pc_parm_type = pc_var_type[pc_loc];
				exec_pc_compeq();
				break;
			case 16: // exec pc_op_compge
				tracem_pc_op = true; // RPI-930
				pc_parm_type = pc_var_type[pc_loc];
				exec_pc_compge();
				break;
			case 17: // exec pc_op_compgt
				tracem_pc_op = true; // RPI-930
				pc_parm_type = pc_var_type[pc_loc];
				exec_pc_compgt();
				break;
			case 18: // exec pc_op_comple
				tracem_pc_op = true; // RPI-930
				pc_parm_type = pc_var_type[pc_loc];
				exec_pc_comple();
				break;
			case 19: // exec pc_op_complt
				tracem_pc_op = true; // RPI-930
				pc_parm_type = pc_var_type[pc_loc];
				exec_pc_complt();
				break;
			case 20: // exec pc_op_compne
				tracem_pc_op = true; // RPI-930
				pc_parm_type = pc_var_type[pc_loc];
				exec_pc_compne();
				break;
			case 21: // exec pc_op_ucomp  compliment value on stack
				tracem_pc_op = true; // RPI-930
				exec_pc_ucomp();
				break;
			case 22: // exec pc_op_dup    duplicate string
				exec_pc_dup();
				break;
			case 23: // exec pc_op_sublst calc sublistvar subscript
				exec_pc_sublst();
				break;
			case 24: // exec pc_op_substr calc setc substring
				exec_pc_substr();
				break;
			case 25: // exec pc_op_inc
				tracem_pc_op = true; // RPI-930
				exec_pc_store(pc_op_inc);
				break;
			case 26: // exec pc_op_dec
				tracem_pc_op = true; // RPI-930
				exec_pc_store(pc_op_dec);
				break;
			case 27: // exec pc_op_pushd push scalar dynamic var using name on stack
				if (tot_exp_stk_var >= 1) {
					set_sub = 1;
					set_subscript = false; // RPI-1162
					get_pc_created_var(-1);
					tot_exp_stk_var--;
					exec_pc_pushvs();
				} else {
					abort_pc("missing dyn var name or subscript");
				}
				break;
			case 28: // exec pc_op_pushds push suscripted dynamic var using name and subscript on stack
				if (tot_exp_stk_var >= 2) {
					set_sub = get_seta_stack_value(-1);
					set_subscript = true; // RPI-1162
					tot_exp_stk_var--;
					get_pc_created_var(-1);
					tot_exp_stk_var--;
					exec_pc_pushvs();
				} else {
					abort_pc("missing dyn var name or subscript");
				}
				break;
			case 29: // exec pc_op_stord  store scalar dynamic var using name on stack
				tracem_pc_op = true; // RPI-930
				set_sub = 1;             // RPI-1162
				set_subscript = false;   // RPI-1162
				get_pc_created_var(-2);
				exec_pc_store(pc_op_stord);
				tot_exp_stk_var--; // remove created name
				break;
			case 30: // exec pc_op_stords store subscripted dynamic var using name and subscript on stack
				tracem_pc_op = true; // RPI-930
				set_subscript = true; // RPI-1162
				get_pc_created_var(-3);
				exec_pc_store(pc_op_stords);
				tot_exp_stk_var--; // remove created name
				break;
			case 31: // exec pc_op_pfx_a A' lookahead defined symbol
				exec_pc_pfx_a();
				break;
			case 32: // exec pc_op_pfx_d D' ordinary defined symbol
				exec_pc_pfx_d();
				break;
			case 33: // exec pc_op_pfx_i I' integer count
				exec_pc_pfx_i();
				break;
			case 34: // exec pc_op_pfx_k K' character count
				exec_pc_pfx_k();
				break;
			case 35: // exec pc_op_pfx_l L' ordinary symbol length
				exec_pc_pfx_l();
				break;
			case 36: // exec pc_op_pfx_n N' number of sublist operands
				exec_pc_pfx_n();
				break;
			case 37: // exec pc_op_pfx_o O' operator
				exec_pc_pfx_o();
				break;
			case 38: // exec pc_op_pfx_s S' scale factor
				exec_pc_pfx_s();
				break;
			case 39: // exec pc_op_pfx_t T' symbol type
				exec_pc_pfx_t();
				break;
			case 40: // exec pc_op_pushs push symbol abs value else 0
				setc_value = pc_setc[pc_loc];
				exec_pc_pushs();
				break;
			case 41: // exec pc_op_stori inc store index by seta
				store_sub = store_sub + pc_seta[pc_loc];
				break;
			case 45: // exec pc_op_a2b  convert value to binary string (3 = '11')
				exec_pc_a2b();
				break;
			case 46: // exec pc_op_a2c  convert value to character string (240 = '1')
				exec_pc_a2c();
				break;
			case 47: // exec pc_op_a2d   convert value to decimal string (1 = '1')
				exec_pc_a2d();
				break;
			case 48: // exec pc_op_a2x  convert value to hex string (240 = 'F0')
				exec_pc_a2x();
				break;
			case 49: // exec pc_op_and  logical and (NC)
				exec_pc_and();
				break;
			case 50: // exec pc_op_b2a  convert binary string to value (B2A('100') = 4)
				exec_pc_b2a();
				break;
			case 51: // exec pc_op_b2c  convert binary string to character string ('11110000' = '1')
				exec_pc_b2c();
				break;
			case 52: // exec pc_op_b2d   convert binary string to decimal string ('100' = '4')
				exec_pc_b2d();
				break;
			case 53: // exec pc_op_b2x  convert binary string to hex string ('11110000' = 'F0')
				exec_pc_b2x();
				break;
			case 54: // exec pc_op_c2a  convert 1-4 characters to value (C2A('0') = 240)
				exec_pc_c2a();
				break;
			case 55: // exec pc_op_c2b  convert character string to binary string ('1' = '11110000')
				exec_pc_c2b();
				break;
			case 56: // exec pc_op_c2d   convert character string to decimal string ('1' = '240')
				exec_pc_c2d();
				break;
			case 57: // exec pc_op_c2x  convert character string to hex string ('1' = 'F0')
				exec_pc_c2x();
				break;
			case 58: // exec pc_op_d2a  convert decimal string to value
				exec_pc_d2a();
				break;
			case 59: // exec pc_op_d2b  convert decimal string to binary string ('4' = '100')
				exec_pc_d2b();
				break;
			case 60: // exec pc_op_d2c   convert decimal string to character string('240'  = '1')
				exec_pc_d2c();
				break;
			case 61: // exec pc_op_d2x    convert decimal string to hex string ('240' = 'F0')
				exec_pc_d2x();
				break;
			case 62: // exec pc_op_dclen  length of string after reducing double ' and &
				exec_pc_dclen();
				break;
			case 63: // exec pc_op_dcval  return string with double ' and & reduced
				exec_pc_dcval();
				break;
			case 64: // exec pc_op_dequote return string without first and last ' if any // RPI-886
				exec_pc_dequote(); // RPI-886
				break;
			case 65: // exec pc_op_double double quotes and & in string (NC)
				exec_pc_double();
				break;
			case 66: // exec pc_op_find   return index of any char in string2 found in string1 (NC)
				exec_pc_find();
				break;
			case 67: // exec pc_op_index  return index of string2 found in string1 else 0 (NC)
				exec_pc_index();
				break;
			case 68: // exec pc_op_isbin  return 1 if valid binary string else 0
				exec_pc_isbin();
				break;
			case 69: // exec pc_op_isdec  return 1 if valid decimal string else 0
				exec_pc_isdec();
				break;
			case 70: // exec pc_op_ishex  return 1 if valid hex string else 0
				exec_pc_ishex();
				break;
			case 71: // exec pc_op_issym  return 1 if valid character string for symbol else 0
				exec_pc_issym();
				break;
			case 72: // exec pc_op_lower  return lower case string (NC)
				exec_pc_lower();
				break;
			case 73: // exec pc_op_not    logical or arithmetic not (NC)
				exec_pc_not();
				break;
			case 74: // exec pc_op_or     logical or (NC)
				exec_pc_or();
				break;
			case 75: // exec pc_op_upper  return upper case string (NC)
				exec_pc_upper();
				break;
			case 76: // exec pc_op_signed return decimal string with minus sign if negative
				exec_pc_signed();
				break;
			case 77: // exec pc_op_sla    shift left arithmetic (2 SLA 1 = 4)
				exec_pc_sla();
				break;
			case 78: // exec pc_op_sll    shift left logical (2 SLL 1 = 4)
				exec_pc_sll();
				break;
			case 79: // exec pc_op_sra    shift right arithmetic (4 SRA 1 = 2)
				exec_pc_sra();
				break;
			case 80: // exec pc_op_srl    shift right logical (4 SRL 1 = 2)
				exec_pc_srl();
				break;
			case 81: // exec pc_op_sattra return assembler attribute for symbol (EQU 5th)
				exec_pc_sattra();
				break;
			case 82: // exec pc_op_sattrp  return program attribute for symbol (EQU 4th)
				exec_pc_sattrp();
				break;
			case 83: // exec pc_op_x2a   convert hex string to value (X2A('F0') = 240)
				exec_pc_x2a();
				break;
			case 84: // exec pc_op_x2b   convert hex string to binary string ('F0' = '11110000')
				exec_pc_x2b();
				break;
			case 85: // exec pc_op_x2c    convert hex string to character string('F0'  = '1')
				exec_pc_x2c();
				break;
			case 86: // exec pc_op_x2d   convert hex string to decimal string ('F0' = '240')
				exec_pc_x2d();
				break;
			case 87: // exec pc_op_xOr   logical exclusive or (NC)
				exec_pc_xor();
				break;
			default:
				abort_pc("invalid pc op=" + pc_op[pc_loc]);
				return;
			}
			if (tz390.opt_tracep
				|| (tz390.opt_tracem && tracem_pc_op)) { // RPI-899 RPI-930
				trace_pc();
			}
			if (mac_branch && tz390.opt_tracem) { // RPI-899
				trace_break();
			}
		//	pc_loc_prev = pc_loc; // JBA-unused
			pc_loc = pc_next[pc_loc];
		}
		if (tot_exp_stk_var != 0) {
			abort_pc("invalid pc stack total = " + tot_exp_stk_var);
		}
	}

	/**
	 * Add new pc_op to list of pseudo codes for current mac_bal_line
	 *  1. Set pc_loc to new pc_op entry
	 *  2. Set pc_loc_prev to prev pc_loc else 0
	 *  3. Set pcl_start[mac_bal_line] to first
	 *  4. Set pc_end[mac_bal_line]  to last
	 *  5. Set pc_next[pc_loc-1] to chain start to end
	 *  6. First try to get next entry from pc_free list
	 *  7. If none on free list, remove least recently used entry from pc_lru and add to
	 *     pc_free list while and return first free entry.
	 *
	 * @param op
	 */
	private void get_pc(final byte op)
	{
		tot_pc_gen++;
	//	pc_loc_prev = pc_loc; // JBA-unused
		pc_loc = pc_free;
		if (pc_loc == 0) {
			// add least recently used pc list to free list and update pc_lru
			if (pcl_lru > 0 && pcl_lru != mac_line_index) {
				reuse_pc(pcl_lru);
				pc_loc = pc_free;
			} else {
				abort_pc("MAXPC limit exceeded for single statement");
			}
		}
		// allocate first free pc entry
		pc_free = pc_next[pc_loc];
		if (pcl_start[mac_line_index] == 0) {
			// add first pc for mac line
			tot_pcl_gen++;
		//	pc_loc_prev = 0; // JBA-unused
			pcl_start[mac_line_index] = pc_loc;
			pcl_end[mac_line_index]   = pc_loc;
			if (pcl_mru == 0) {
				pcl_mru = mac_line_index;
				pcl_lru = pcl_mru;
			} else {
				update_mru();
			}
		} else {
			// add pc to alloc list for mac line
			pc_next[pcl_end[mac_line_index]] = pc_loc;
			pcl_end[mac_line_index] = pc_loc;
		}
		pc_op[pc_loc] = op;
		pc_sysndx[pc_loc] = mac_call_sysndx[mac_call_level];
		pc_req_opt[pc_loc] = false; // default is no exec opt
		pc_next[pc_loc] = 0; // end of alloc list for mac line
	}

	/**
	 * Update mru with current mac_line_index.
	 */
	private void update_mru()
	{
		// remove current mac_line_index from mru list to allow moving it to top
		int prev = pcl_mru_prev[mac_line_index];
		int next = pcl_mru_next[mac_line_index];
		if (prev > 0) {
			pcl_mru_next[prev] = next;
		}
		if (next > 0) {
			pcl_mru_prev[next] = prev;
		}
		// update lru if moving lru to mru
		if (pcl_lru == mac_line_index) {
			pcl_lru = pcl_mru_prev[mac_line_index];
		}
		// move cur mac line to top fo mru list
		pcl_mru_prev[mac_line_index] = 0;
		pcl_mru_next[mac_line_index] = pcl_mru;
		if (pcl_mru > 0) {
			pcl_mru_prev[pcl_mru] = mac_line_index;
		}
		pcl_mru = mac_line_index;
	}

	/**
	 * Reuse pc list at mac line index.
	 *
	 * @param index
	 */
	private void reuse_pc(final int index)
	{
		tot_pcl_reuse++;
		pc_free = pcl_start[index];
		if (tz390.opt_traceall) {
			tz390.put_trace("PC LRU RELEASING " + pcl_start[pcl_lru] + " - " + pcl_end[pcl_lru]);
		}
		pcl_start[index] = 0;
		pcl_end[index]   = 0;
		if (index == pcl_mru) {
			pcl_mru = pcl_mru_next[pcl_mru];
		}
		if (index == pcl_lru) {
			pcl_lru = pcl_mru_prev[pcl_lru];
		}
	}

	/**
	 * Trace pc entry gen or exec.
	 */
	private void trace_pc()
	{
		if (!tz390.opt_pc || tz390.z390_abort) return; // RPI-899
		if (!tz390.opt_tracec
		 && mac_file_type[mac_file_num[mac_line_index]] == '=') {
			return; // RPI-862 skip COPY trace
		}
		String text = "";
		switch (pc_op[pc_loc]) {
		case  1: // trace pc_op_ago
			if (seta_value > 0 && seta_value <= gbl_seta[ago_gbla_index+1]) {
				ago_gblc_index = gbl_seta[ago_gbla_index];
				if (ago_gblc_index >= 0) {  // RPI-930 required due to SYSTRACE
					text = "(" + seta_value + ")=" + gbl_setc[ago_gblc_index + ago_index -1] + " BRANCH";
				} else {
					text = "(" + seta_value + ") BRANCH";
				}
			} else { // RPI-803
				text = "(" + seta_value + ")= NO BRANCH";
			}
			break;
		case  2: // trace pc_op_aif
			if (setb_value != 0) {
				text = "(" + setb_value + ")=" + pc_setc[pc_loc] + " BRANCH";
			} else {
				text = "(" + setb_value + ")=" + pc_setc[pc_loc] + " NO BRANCH";
			}
			break;
		case  3: // trace pc_op_pushv  push var on stack
			text = "(" + pc_setc[pc_loc] + ")=" + pc_push_var_setc_value;
			break;
		case  4: // trace pc_op_pushvs calculate var subscript
			text = "(" + pc_setc[pc_loc] + "," + set_sub + ")=" + pc_push_var_setc_value;
			break;
		case  5: // trace pc_op_pusha  push seta self defining term
			text = "()=" + pc_setc[pc_loc];
			break;
		case  6: // trace pc_op_pushc  push setc string constant
			text = "()='" + setc_value + "'";
			break;
		case  7: // trace pc_op_concat concatenate setc or 2 stack values
			text = "('" + setc_value1 + "','" + setc_value2 + "')='" + setc_value + "'";
			break;
		case  8: // trace pc_op_storv store scalar set var
			text = "(" + pc_setc[pc_loc] + ")=" + get_pc_trace_val(get_val_type(),3);
			break;
		case  9: // trace pc_op_storvs store subscripted set var
		case 10: // trace pc_op_storvn store next var(sub+1)
			text = "(" + pc_setc[pc_loc] + "," + store_sub + ")=" + get_pc_trace_val(get_val_type(),3);
			break;
		case 11: // trace pc_op_add    add 2 entries on stack leaving 1
		case 12: // trace pc_op_sub    sub 2 entries on stack leaving 1
		case 13: // trace pc_op_mpy    mpy 2 entries on stack leaving 1
		case 14: // trace pc_op_div    div 2 entries on stack leaving 1
			text = "(" + seta_value1 + "," + seta_value2 + ")=" + seta_value;
			break;
		case 15: // trace pc_op_compeq     compare equal
		case 16: // trace pc_op_compge     compare greater than or equal
		case 17: // trace pc_op_compgt     compare greater than
		case 18: // trace pc_op_comple     compare greater less than or equal
		case 19: // trace pc_op_complt     compare equal
		case 20: // trace pc_op_compne     compare greater than or equal
			text = "(" + get_pc_trace_val(val_type1,1) + "," + get_pc_trace_val(val_type1,2) + ")=" + setb_value;
			break;
		case 21: // trace pc_op_ucomp  compliement value on stack
			text = "(" + (-seta_value) + ")=" + seta_value;
			break;
		case 22: // trace pc_op_dup    duplicate string
			text = "(" + seta_value1 + ",'" + setc_value1 + "')='" + setc_value + "'";
			break;
		case 23: // trace pc_op_sublst calculate setc sublist
			text = "('" + pc_sublst_value1 + "'," + set_sub + ")=" + pc_push_var_setc_value;
			break;
		case 24: // trace pc_op_substr calculate setc substring
			text = "('" + setc_value1 + "'," + seta_value1 + "," + seta_value2 + ")='" + setc_value + "'";
			break;
		case 25: // trace pc_op_inc
		case 26: // trace pc_op_dec
			text = "(" + pc_setc[pc_loc] + ")=" + seta_value;
			break;
		case 27: // trace pc_op_pushd push scalar dynamic var using name on stack
			text = "(" + pc_setc[pc_loc] + ")=" + pc_push_var_setc_value;
			break;
		case 28: // trace pc_op_pushds push suscripted dynamic var using name and subscript on stack
			text = "(" + pc_setc[pc_loc] + "," + set_sub + ")=" + pc_push_var_setc_value;
			break;
		case 29: // trace pc_op_stord  store scalar dynamic var using name on stack
			text = "(" + pc_setc[pc_loc] + ")=" + get_pc_trace_val(get_val_type(),3);
			break;
		case 30: // trace pc_op_stords store subscripted dynamic var using name and subscript on stack
			text = "(" + pc_setc[pc_loc] + "," + store_sub + ")=" + get_pc_trace_val(get_val_type(),3);
			break;
		case 31: // trace pc_op_pfx_a A' lookahead defined symbol
			text = "('" + setc_value1 + "')=" + seta_value;
			break;
		case 32: // trace pc_op_pfx_d D' ordinary defined symbol
			text = "('" + setc_value1 + "')=" + setb_value;
			break;
		case 33: // trace pc_op_pfx_i I' integer count
			text = "('" + setc_value1 + "')=" + seta_value;
			break;
		case 34: // trace pc_op_pfx_k K' character count
			text = "('" + setc_value1 + "')=" + seta_value;
			break;
		case 35: // trace pc_op_pfx_l L' ordinary symbol length
			text = "('" + setc_value1 + "')=" + seta_value;
			break;
		case 36: // trace pc_op_pfx_n N' number of sublist operands
			switch (var_type) {
			case 21:
			case 22:
			case 23:
				if (var_name_index == -1) {
					setc_value1 = "?"; // RPI-901
				} else {
					if (var_loc == var_lcl_loc) {
						setc_value1 = lcl_set_name[var_name_index];
					} else {
						setc_value1 = gbl_set_name[var_name_index];
					}
				}
				break;
			case 24:
			case 25:
				break;
			case 26:
				setc_value1 = "&SYSLIST";
				break;
			default:
				abort_pc("invalid N' var type");
			}
			text = "('" + setc_value1 + "')=" + seta_value;
			break;
		case 37: // trace pc_op_pfx_o O' operator
			text = "('" + setc_value1 + "')='" + setc_value + "'";
			break;
		case 38: // trace pc_op_pfx_s S' scale factor
			text = "('" + setc_value1 + "')=" + seta_value;
			break;
		case 39: // trace pc_op_pfx_t T' symbol type
			text = "('" + setc_value1 + "')='" + setc_value + "'";
			break;
		case 40: // trace pc_op_pushs push symbol abs value else 0
			text = "(" + pc_setc[pc_loc] + ")=" + seta_value;
			break;
		case 41: // trace pc_op_stori inc store sub by seta
			text = "()=" + pc_setc[pc_loc];
			break;
		case 45: // trace pc_op_a2b  convert value to binary string (3 = '00000011')
		case 46: // trace pc_op_a2c  convert value to character string (240 = '1')
		case 47: // trace pc_op_a2d   convert value to decimal string (1 = '1')
		case 48: // trace pc_op_a2x  convert value to hex string (240 = 'F0')
			text = "(" + seta_value1 + ")='" + setc_value + "'";
			break;
		case 49: // trace pc_op_and  logical and (NC)
			text = "(" + seta_value1 + "," + seta_value2 + ")=" + seta_value;
			break;
		case 50: // trace pc_op_b2a  convert binary string to value (B2A('100') = 4)
			text = "(" + setc_value + ")=" + seta_value;
			break;
		case 51: // trace pc_op_b2c  convert binary string to character string ('11110000' = '1')
		case 52: // trace pc_op_b2d  convert binary string to decimal string ('100' = '4')
		case 53: // trace pc_op_b2x  convert binary string to hex string ('11110000' = 'F0')
			text = "('" + setc_value1 + "')='" + setc_value + "'";
			break;
		case 54: // trace pc_op_c2a  convert characters to value (C2A('0') = 240)
			text = "('" + setc_value + "')=" + seta_value;
			break;
		case 55: // trace pc_op_c2b  convert character string to binary string ('1' = '11110000')
		case 56: // trace pc_op_c2d   convert character string to decimal string ('1' = '240')
		case 57: // trace pc_op_c2x  convert character string to hex string ('1' = 'F0')
			text = "('" + setc_value1 + "')='" + setc_value + "'";
			break;
		case 58: // trace pc_op_d2a  convert decimal string to value
			text = "('" + setc_value1 + "')=" + seta_value;
			break;
		case 59: // trace pc_op_d2b  convert decimal string to binary string ('4' = '100')
		case 60: // trace pc_op_d2c   convert decimal string to character string('240'  = '1')
		case 61: // trace pc_op_d2x    convert decimal string to hex string ('240' = 'F0')
			text = "('" + setc_value1 + "')='" + setc_value + "'";
			break;
		case 62: // trace pc_op_dclen  length of string after reducing double ' and &
			text = "('" + setc_value1 + "')=" + seta_value;
			break;
		case 63: // trace pc_op_dcval  return string with double ' and & reduced
		case 64: // trace pc_op_dequote return string without first and last ' if any // RPI-886
		case 65: // trace pc_op_double double quotes and & in string (NC)
			text = "('" + setc_value1 + "')='" + setc_value + "'";
			break;
		case 66: // trace pc_op_find   return index of any char in string2 found in string1 (NC)
		case 67: // trace pc_op_index  return index of string2 found in string1 else 0 (NC)
			text = "('" + setc_value1 + "','" + setc_value2 + "')=" + seta_value;
			break;
		case 68: // trace pc_op_isbin  return 1 if valid binary string else 0
		case 69: // trace pc_op_isdec  return 1 if valid decimal string else 0
		case 70: // trace pc_op_ishex  return 1 if valid hex string else 0
		case 71: // trace pc_op_issym  return 1 if valid character string for symbol else 0
			text = "('" + setc_value1 + "')=" + setb_value;
			break;
		case 72: // trace pc_op_lower  return lower case string (NC)
			text = "('" + setc_value1 + "')='" + setc_value + "'";
			break;
		case 73: // trace pc_op_not    logical or arithmetic not (NC)
			text = "(" + seta_value1 + ")=" + seta_value;
			break;
		case 74: // trace pc_op_or     logical or (NC)
			text = "(" + seta_value1 + "," + seta_value2 + ")=" + seta_value;
			break;
		case 75: // trace pc_op_upper  return upper case string (NC)
			text = "('" + setc_value1 + "')='" + setc_value + "'";
			break;
		case 76: // trace pc_op_signed return decimal string with minus sign if negative
			text = "(" + seta_value1 + ")='" + setc_value + "'";
			break;
		case 77: // trace pc_op_sla    shift left arithmetic (2 SLA 1 = 4)
		case 78: // trace pc_op_sll    shift left logical (2 SLL 1 = 4)
		case 79: // trace pc_op_sra    shift right arithmetic (4 SRA 1 = 2)
		case 80: // trace pc_op_srl    shift right logical (4 SRL 1 = 2)
			text = "(" + seta_value1 + "," + seta_value2 + ")=" + seta_value;
			break;
		case 81: // trace pc_op_sattra return assembler attribute for symbol (EQU 4th)
		case 82: // trace pc_op_sattrp  return program attribute for symbol (EQU 5th)
			text = "('" + setc_value1 + "')='" + setc_value + "'";
			break;
		case 83: // trace pc_op_x2a   convert hex string to value (X2A('F0') = 240)
			text = "()=" + seta_value;
			break;
		case 84: // trace pc_op_x2b   convert hex string to binary string ('F0' = '11110000')
		case 85: // trace pc_op_x2c    convert hex string to character string('F0'  = '1')
		case 86: // trace pc_op_x2d   convert hex string to decimal string ('F0' = '240')
			text = "('" + setc_value1 + "')='" + setc_value + "'";
			break;
		case 87: // trace pc_op_xor   logical exclusive or (NC)
			text = "(" + seta_value1 + "," + seta_value2 + ")=" + seta_value;
			break;
		default:
			abort_pc("invalid pc op - " + pc_op[pc_loc]);
		}
		text = tz390.ascii_printable_string(text); // RPI-947
		if (pc_trace_gen) {
			tz390.put_trace("  GEN  PC LOC=" + tz390.right_justify("" + pc_loc,5) + " OP= " + pc_op_desc[pc_op[pc_loc]] + text);
		} else {
			tz390.put_trace("  EXEC PC LOC=" + tz390.right_justify("" + pc_loc,5) + " OP= " + pc_op_desc[pc_op[pc_loc]] + text);
		}
	}

	/**
	 * Issue log_error and abort pc mode due to pc error.
	 *
	 * @param msg
	 */
	private void abort_pc(String msg)
	{
		if (pc_aborted) return;
		pc_aborted = true;
		if (tz390.opt_tracep) {
			trace_pc();
		} else {
			log_error(205,msg);
		}
		tz390.opt_pc = false;
		tz390.opt_tracep = false;
		pcl_start[mac_line_index] = 0;
		log_error(194,"pc aborted due to " + msg);
	}

	/**
	 * Concatenate var to string on stack.
	 */
	private void exp_concat_var()
	{
		switch (var_type) {
		case 21: // seta
			setc_value1 = exp_stk_setc[tot_exp_stk_var - 1];
			setc_value2 = "" + seta_value;
			setc_value = setc_value1 + setc_value2;
			exp_stk_setc[tot_exp_stk_var - 1] = setc_value;
			break;
		case 22: // setb
			setc_value1 = exp_stk_setc[tot_exp_stk_var - 1];
			setc_value2 = "" + setb_value;
			setc_value = setc_value1 + setc_value2;
			exp_stk_setc[tot_exp_stk_var - 1] = setc_value;
			break;
		case 23: // setc
			setc_value1 = exp_stk_setc[tot_exp_stk_var - 1];
			setc_value2 = setc_value;
			setc_value = setc_value1 + setc_value2;
			exp_stk_setc[tot_exp_stk_var - 1] = setc_value;
			break;
		case 24: // positional or key word parm
			setc_value1 = exp_stk_setc[tot_exp_stk_var - 1];
			setc_value2 = setc_value;
			setc_value = setc_value1 + setc_value2;
			exp_stk_setc[tot_exp_stk_var - 1] = setc_value;
			break;
		default:
			tz390.abort_case();
		}
	}

	/**
	 * Push scalar var on stack (shared by exp and pc).
	 */
	private void push_pc_var()
	{
		switch (var_type) {
		case 21:
			exp_stk_val_type[tot_exp_stk_var -1] = val_seta_type; // RPI-447
			exp_stk_seta[tot_exp_stk_var - 1] = seta_value;
			pc_push_var_setc_value = "" + seta_value;
			break;
		case 22:
			exp_stk_val_type[tot_exp_stk_var -1] = val_setb_type; // RPI-447
			exp_stk_setb[tot_exp_stk_var - 1] = setb_value;
			pc_push_var_setc_value = "" + setb_value;
			break;
		case 23:  // push setc
		case 24:  // push parm as setc
			if (setc_value == null) {
				setc_value = "";  // RPI-565
			}
			exp_stk_val_type[tot_exp_stk_var - 1] = val_setc_type; // RPI-447
			exp_stk_setc[tot_exp_stk_var - 1] = setc_value;
			pc_push_var_setc_value = "'" + setc_value + "'";
			break;
		case 26:  // syslist
			if (setc_value == null) {
				setc_value = ""; // RPI-565
			}
			if (exp_prev_class != exp_class_oper) {  // RPI-565
				setc_value = "";
				log_error(208, "Invalid SYSLIST string reference");
			}
			exp_stk_val_type[tot_exp_stk_var -1] = val_setc_type;  // RPI-447
			pc_push_var_setc_value = "'" + setc_value + "'";
			break;
		default:
			tz390.abort_case();
		}
		exp_stk_var_type[tot_exp_stk_var - 1] = var_type; // RPI-447
		exp_stk_var_loc[tot_exp_stk_var -1]   = var_loc;  // RPI-447
		exp_stk_var_name_index[tot_exp_stk_var-1] = var_name_index; // RPI-447
	}

	/**
	 * 1.  Get var value in seta/setb/setc_value using var_type, var_loc, var_name_index and set_sub
	 * 2.  Set val_type = var_seta/setb/setc_type
	 */
	private void get_pc_var_value()
	{
		set_sub = 1;
		switch (var_loc) {
		case 11: // lcl set
			get_lcl_set_value();
			break;
		case 12: // gbl set
			get_gbl_set_value();
			break;
		case 13: // named positional parm
			val_type = val_setc_type;
			if (var_name_index > -1) {
				setc_value = mac_call_pos_parm[var_name_index];
			} else {
				setc_value = "";
			}
			break;
		case 14: // keyword parm
			val_type = val_setc_type;
			setc_value = mac_call_kwd_parm[var_name_index];
			break;
		case 15: // syslist
			val_type = val_setc_type;
			break;
		default:
			abort_pc("invalid get var loc - " + var_loc);
		}
	}

	/**
	 * Compare equal (shared exp and pc).
	 */
	private void exec_pc_compeq()
	{
		get_compare_values();
		switch (val_type1) {
		case 1:
			if (seta_value1 == seta_value2) {
				set_compare(true);
			} else {
				set_compare(false);
			}
			break;
		case 2:
			if (setb_value1 == setb_value2) {
				set_compare(true);
			} else {
				set_compare(false);
			}
			break;
		case 3:
			if (setc_compare() == 0) {
				set_compare(true);
			} else {
				set_compare(false);
			}
			break;
		default:
			tz390.abort_case();
		}
	}

	/**
	 * Compare greater than or equal (shared exp and pc).
	 */
	private void exec_pc_compge()
	{
		get_compare_values();
		switch (val_type1) {
		case 1:
			if (seta_value1 >= seta_value2) {
				set_compare(true);
			} else {
				set_compare(false);
			}
			break;
		case 2:
			if (setb_value1 >= setb_value2) {
				set_compare(true);
			} else {
				set_compare(false);
			}
			break;
		case 3:
			if (setc_compare() >= 0) {
				set_compare(true);
			} else {
				set_compare(false);
			}
			break;
		default:
			tz390.abort_case();
		}
	}

	/**
	 * Compare greater than (shared exp and pc).
	 */
	private void exec_pc_compgt()
	{
		get_compare_values();
		switch (val_type1) {
		case 1:
			if (seta_value1 > seta_value2) {
				set_compare(true);
			} else {
				set_compare(false);
			}
			break;
		case 2:
			if (setb_value1 > setb_value2) {
				set_compare(true);
			} else {
				set_compare(false);
			}
			break;
		case 3:
			if (setc_compare() > 0) {
				set_compare(true);
			} else {
				set_compare(false);
			}
			break;
		default:
			tz390.abort_case();
		}
	}

	/**
	 * Compare less than or equal (shared exp and pc).
	 */
	private void exec_pc_comple()
	{
		get_compare_values();
		switch (val_type1) {
		case 1:
			if (seta_value1 <= seta_value2) {
				set_compare(true);
			} else {
				set_compare(false);
			}
			break;
		case 2:
			if (setb_value1 <= setb_value2) {
				set_compare(true);
			} else {
				set_compare(false);
			}
			break;
		case 3:
			if (setc_compare() <= 0) {
				set_compare(true);
			} else {
				set_compare(false);
			}
			break;
		default:
			tz390.abort_case();
		}
	}

	/**
	 * Compare less than (shared exp and pc).
	 */
	private void exec_pc_complt()
	{
		get_compare_values();
		switch (val_type1) {
		case 1:
			if (seta_value1 < seta_value2) {
				set_compare(true);
			} else {
				set_compare(false);
			}
			break;
		case 2:
			if (setb_value1 < setb_value2) {
				set_compare(true);
			} else {
				set_compare(false);
			}
			break;
		case 3:
			if (setc_compare() < 0) {
				set_compare(true);
			} else {
				set_compare(false);
			}
			break;
		default:
			tz390.abort_case();
		}
	}

	/**
	 * Compare not equal (shared exp and pc).
	 */
	private void exec_pc_compne()
	{
		get_compare_values();
		switch (val_type1) {
		case 1:
			if (seta_value1 != seta_value2) {
				set_compare(true);
			} else {
				set_compare(false);
			}
			break;
		case 2:
			if (setb_value1 != setb_value2) {
				set_compare(true);
			} else {
				set_compare(false);
			}
			break;
		case 3:
			if (setc_compare() != 0) {
				set_compare(true);
			} else {
				set_compare(false);
			}
			break;
		default:
			tz390.abort_case();
		}
	}

	/**
	 * Push var(set_sub) value on stack.
	 * Notes:
	 *  1. Shared by exp and pc.
	 */
	private void exec_pc_pushvs()
	{
		if (inc_tot_exp_stk_var()) {
			exp_stk_var_type[tot_exp_stk_var - 1] = var_type;
			switch (var_loc) {
			case 11: // lcl set var(sub)
				var_name = lcl_set_name[var_name_index];
				var_type = lcl_set_type[var_name_index];
				get_lcl_set_value();
				switch (var_type) {
				case 21:
					val_type = val_seta_type;
					seta_value = lcl_seta[seta_index];
					exp_stk_seta[tot_exp_stk_var - 1] = seta_value;
					if (tz390.opt_traceall) {
						tz390.put_trace("STK LCLA " + lcl_set_name[var_name_index] + "(" + (seta_index-lcl_set_start[var_name_index]+1) + ")=" + lcl_seta[seta_index]);
					}
					break;
				case 22:
					val_type = val_setb_type;
					setb_value = lcl_setb[setb_index];
					exp_stk_setb[tot_exp_stk_var - 1] = setb_value;
					if (tz390.opt_traceall) {
						tz390.put_trace("STK SETB = " + lcl_set_name[var_name_index] + "(" + (setb_index-lcl_set_start[var_name_index]+1) + ")=" + lcl_setb[setb_index]);
					}
					break;
				case 23:
					val_type = val_setc_type;
					setc_value = lcl_setc[setc_index];
					exp_stk_setc[tot_exp_stk_var - 1] = setc_value;
					if (tz390.opt_traceall) {
						tz390.put_trace("STK SETC = " + lcl_set_name[var_name_index] + "(" + (setc_index-lcl_set_start[var_name_index]+1) + ")=" + lcl_setc[setc_index]);
					}
					break;
				default:
					tz390.abort_case();
				}
				break;
			case 12: // gbl set var(sub)
				var_name = lcl_set_name[var_name_index];
				var_type = gbl_set_type[var_name_index];
				get_gbl_set_value();
				switch (var_type) {
				case 21:
					val_type = val_seta_type;
					seta_value = gbl_seta[seta_index];
					exp_stk_seta[tot_exp_stk_var - 1] = seta_value;
					if (tz390.opt_traceall) {
						tz390.put_trace("STK SETA =  " + gbl_seta[seta_index]);
					}
					break;
				case 22:
					val_type = val_setb_type;
					setb_value = gbl_setb[setb_index];
					exp_stk_setb[tot_exp_stk_var - 1] = setb_value;
					if (tz390.opt_traceall) {
						tz390.put_trace("STK SETB = " + gbl_setb[setb_index]);
					}
					break;
				case 23:
					val_type = val_setc_type;
					setc_value = gbl_setc[setc_index];
					exp_stk_setc[tot_exp_stk_var - 1] = setc_value;
					if (tz390.opt_traceall) {
						tz390.put_trace("STK SETC = " + gbl_setc[setc_index]);
					}
					break;
					default:
						tz390.abort_case();
				}
				break;
			case 13: // pos parm var(sub) or var(sub,
			case 14: // kw  parm var(sub) or var(sub,
				var_type = var_parm_type;
				val_type = val_setc_type;
				setc_value = exp_stk_setc[tot_exp_stk_var - 1]; // get parm value set by find_var
				setc_value = get_sublist(setc_value,set_sub);
				break;
			case 15: // syslist(sub) or syslist(sub,
				var_type = var_parm_type;
				val_type = val_setc_type;
				if (var_name_index == -1) {
					if (mac_call_level > 0 && set_sub >= 0) {
						var_name_index = mac_call_pos_start[mac_call_level] + set_sub;
						exp_stk_var_name_index[tot_exp_stk_var - 1] = var_name_index; // RPI-447
						if (set_sub >= 0 && var_name_index < tot_pos_parm) {
							setc_value = mac_call_pos_parm[var_name_index];
						} else {
							setc_value = "";
						}
						exp_stk_setc[tot_exp_stk_var-1] = setc_value;
						if (tz390.opt_traceall) {
							tz390.put_trace("SYSLIST PARM(" + var_name_index + ")=" + setc_value);
						}
					} else if (set_sub < 0) {
						log_error(276,"syslist negative subscript - " + set_sub);
					} else {
						log_error(66,"syslist reference only allowed in macro");
					}
				} else {
					val_type = val_setc_type;
					setc_value = exp_stk_setc[tot_exp_stk_var - 1]; // get prev syslist(sub) value
					setc_value = get_sublist(setc_value,set_sub);
					exp_stk_setc[tot_exp_stk_var-1] = setc_value;
					if (tz390.opt_traceall) {
						tz390.put_trace("SUBLIST PARM=" + setc_value);
					}
				}
				break;
			default:
				tz390.abort_case();
			}
			exp_stk_val_type[tot_exp_stk_var-1] = val_type;
			if (tz390.opt_tracep) {
				pc_push_var_setc_value = get_pc_trace_val(val_type,3);
			}
		}
	}

	/**
	 * Replace setc value and sublist index on stack with caculated sublist.
	 *
	 * Notes:
	 * Shared by exp and pc
	 */
	private void exec_pc_sublst()
	{
		set_sub = get_seta_stack_value(-1);
		tot_exp_stk_var--;
		pc_sublst_value1 = exp_stk_setc[tot_exp_stk_var - 1]; // get parm value set by find_var
		setc_value = get_sublist(pc_sublst_value1,set_sub);
		pc_push_var_setc_value = "'" + setc_value + "'";
		exp_stk_val_type[tot_exp_stk_var - 1] = val_setc_type;  // RPI-447
		exp_stk_setc[tot_exp_stk_var - 1] = setc_value; // update sublist string
		if (tz390.opt_traceall) {
			tz390.put_trace("SUBLIST PARM=" + setc_value);
		}
	}

	/**
	 * Replace setc,arg1,arg2 on stack with subsubstring setc.
	 */
	private void exec_pc_substr()
	{
		if (tot_exp_stk_var >= 3) {
			switch (exp_stk_val_type[tot_exp_stk_var - 3]) {
			case 1: // val_seta_type
				exp_stk_setc[tot_exp_stk_var-3] = "" + exp_stk_seta[tot_exp_stk_var-3]; // RPI-993
				exp_stk_val_type[tot_exp_stk_var-3]= val_seta_type;
				break;
			case 2: // val_setb_type
				exp_stk_setc[tot_exp_stk_var-3] = "" + exp_stk_setb[tot_exp_stk_var-3]; // RPI-993
				exp_stk_val_type[tot_exp_stk_var-3]= val_setb_type;
			}
			get_seta_stack_values();
			if (tz390.opt_traceall) {
				tz390.put_trace("SUBSTRING " + exp_stk_setc[tot_exp_stk_var - 1] + "(" + seta_value1 + "," + seta_value2 + ")");
			}
			exp_stk_var_name_index[tot_exp_stk_var-1] = -1; // RPI-1139
			setc_value1 = exp_stk_setc[tot_exp_stk_var-1];
			setc_len = setc_value1.length();
			if (seta_value1 > 0
				&& seta_value2 >= 0
				&& (tz390.opt_allow     // RPI-1139
					|| seta_value1 == 1 // RPI-1139
					|| seta_value1 <= setc_len)) { // RPI-645
				if (seta_value1 <= setc_len && seta_value2 > 0) {
					int e1 = seta_value1 - 1;
					int e2 = e1 + seta_value2;
					if (e2 > setc_len) {
						e2 = setc_len;
					}
					setc_value = exp_stk_setc[tot_exp_stk_var - 1].substring(e1,e2);
					exp_stk_setc[tot_exp_stk_var - 1] = setc_value;
				} else {
					setc_value = "";
					exp_stk_setc[tot_exp_stk_var - 1] = setc_value;
				}
			} else {  // RPI-645
				log_error(217,"invalid substring - offset=" + seta_value1 + " len=" + seta_value2);
			}
		} else {
			log_error(52,"invalid substring expression");
		}
	}

	/**
	 * Return set&type_value&PARM ? = 1,2 or 3 for value
	 *
	 * @param type
	 * @param parm
	 * @return
	 */
	private String get_pc_trace_val(final byte type, final int parm)
	{
		switch (type) {
		case 1: // val_seta_type
			switch (parm) {
			case 1:
				return "" + seta_value1;
			case 2:
				return "" + seta_value2;
			case 3:
				return "" + seta_value;
			}
		case 2: // val_setb_type
			switch (parm) {
			case 1:
				return "" + setb_value1;
			case 2:
				return "" + setb_value2;
			case 3:
				return "" + setb_value;
			}
		case 3: // val_setc_type
			switch (parm) {
			case 1:
				return "'" + setc_value1 + "'";
			case 2:
				return "'" + setc_value2 + "'";
			case 3:
				return "'" + setc_value + "'";
			}
		default:
			tz390.abort_case();
			return "";
		}
	}

	/**
	 * Set var variables from pc entry and update if reguired for new macro instance
	 *   1.  var_type
	 *   2.  val_type
	 *   3.  var_loc
	 *   4.  var_name_index (update for new mac)
	 * Return true if ok else false if not found
	 *
	 * Notes:
	 *   1.  Update via find_set if new macro and local var
	 *
	 * @return
	 */
	private boolean get_pc_var()
	{
		var_type = pc_var_type[pc_loc];
		var_loc  = pc_var_loc[pc_loc];
		var_name_index = pc_seta[pc_loc];
		if (pc_sysndx[pc_loc] != mac_call_sysndx[mac_call_level]) {
			pc_sysndx[pc_loc] = mac_call_sysndx[mac_call_level];
			if (var_loc != var_gbl_loc
			 && var_loc != var_syslist_loc) {
				switch (var_loc) {
				case 11: // lcl set
					var_name_index = find_lcl_key_index("L:" + pc_setc[pc_loc]);
					// alloc new lcl var if not same instance of macro
					if (var_name_index == -1) {
						if (!find_var(pc_setc[pc_loc])
						 || var_loc != var_lcl_loc) {  // RPI-950 ignore GBL
							if (pc_op[pc_loc] == pc_op_storv     // RPI-950
							 || pc_op[pc_loc] == pc_op_storvs
							 || pc_op[pc_loc] == pc_op_inc    // RPI-950
							 || pc_op[pc_loc] == pc_op_dec    // RPI-950
							 || pc_op[pc_loc] == pc_op_stord  // RPI-950
							 || pc_op[pc_loc] == pc_op_stords) {
								// dynamically alloc local set for new macro instance
								alloc_size = 1;
								boolean alloc_subscript = false; // RPI-1162
								if ((pc_op[pc_loc] == pc_op_storvs
								  || pc_op[pc_loc] == pc_op_stords)
									&& alloc_size < min_alloc_size) {
									alloc_size = min_alloc_size;
									alloc_subscript = true; // RPI-1162
								}
								add_lcl_set(pc_setc[pc_loc],var_type,alloc_size,alloc_subscript); // RPI-1162
								if (var_name_index == -1) {
									abort_pc("local var dynamic alloc failed - " + pc_setc[pc_loc]);
									return false;
								}
							} else {
								abort_pc("local var not initialized - " + pc_setc[pc_loc]); // RPI-950
								return false;
							}
						}
					}
					break;
				case 13: // pos parm
					var_name_index = find_lcl_key_index("P:" + pc_setc[pc_loc]);
					break;
				case 14: // kwd parm
					var_name_index = find_lcl_key_index("K:" + pc_setc[pc_loc]);
					break;
				default:
					abort_pc("invalid var type for local instance update - " + pc_setc[pc_loc]);
					return false;
				}
				pc_seta[pc_loc] = var_name_index;
				if (var_name_index == -1) {
					abort_pc("local variable not found -" + pc_setc[pc_loc]); // RPI-950
					return false;
				}
			}
		}
		switch (var_loc) {
		case 11: // lcl set
			var_type = lcl_set_type[var_name_index];
			val_type = get_val_type();
			break;
		case 12: // gbl set
			var_type = gbl_set_type[var_name_index];
			val_type = get_val_type();
			break;
		case 13: // pos parm
		case 14: // kwd parm
		case 15: // syslist parm
			var_type = var_parm_type;
			val_type = val_setc_type;
			break;
		default:
			tz390.abort_case();
		}
		return true;
	}

	/**
	 * Convert pusha or pushc with sdt into op with sdt else flush and gen op with 2 stack values.
	 *
	 * @param op
	 */
	private void opt_gen_pc_comp(final byte op)
	{
		if (pc_pusha_pending) {
			opt_gen_pc_seta(op);
		} else {
			opt_gen_pc_setc(op);
		}
	}

	/**
	 * Convert pusha to op with seta sdt arg. else flush and gen op with 2 stack values.
	 *
	 * @param op
	 */
	private void opt_gen_pc_seta(final byte op)
	{
		if (!pc_gen_exp) {
			return;
		}
		if (pc_pusha_pending) {
			pc_pusha_pending = false;
			tot_pc_gen_opt++;
			pc_parm_type = var_pc_seta_sdt_type;
			seta_value2 = pc_pusha_seta_value;
			gen_exp_pc(op);
		} else {
			pc_parm_type = var_pc_seta_stack_type;
			gen_exp_pc(op);
		}
	}

	/**
	 * Convert pushc to op with setc sdt arg. else flush and gen op with 2 stack values.
	 *
	 * @param op
	 */
	private void opt_gen_pc_setc(final byte op)
	{
		if (!pc_gen_exp) {
			return;
		}
		if (pc_pushc_pending && !pc_concat_pending) {
			pc_pushc_pending = false;
			tot_pc_gen_opt++;
			pc_parm_type = var_pc_setc_sdt_type;
			setc_value2 = pc_pushc_setc_value;
			gen_exp_pc(op);
		} else {
			pc_parm_type = var_pc_setc_stack_type;
			gen_exp_pc(op);
		}
	}

	/**
	 * Set pending pushc after flushing any pending pc opcodes.
	 */
	private void opt_gen_pc_pushc()
	{
		if (!pc_gen_exp) {
			return;
		}
		flush_pc_pending();
		pc_pushc_pending = true;
		pc_pushc_setc_value = setc_value;
	}

	/**
	 * Set pending pusha after flushing any pending pc opcodes.
	 */
	private void opt_gen_pc_pusha()
	{
		if (!pc_gen_exp) {
			return;
		}
		flush_pc_pending();
		pc_pusha_pending = true;
		pc_pusha_seta_value = seta_value;
		pc_pusha_setc_value = setc_value;
	}

	/**
	 * Optimize concatenation of push? by checking if previous op was pushc
	 * and combining to single push? where possible.
	 *
	 * @param op
	 */
	private void opt_gen_pc_concat(final byte op)
	{
		if (pc_gen_exp) {
			if (pc_pushc_pending) {
				if (op == pc_op_pushc) {
					// combine 2 pushc and skip concat
					tot_pc_gen_opt++;
					pc_pushc_setc_value = pc_pushc_setc_value + setc_value;
					if (pc_concat_pending) {
						setc_value2 = exp_stk_setc[tot_exp_stk_var-1];
						pc_concat_setc_value = setc_value2 + setc_value;
					}
					return;
				} else if (pc_pushc_setc_value.length() == 0) {
					// if pushc null, push gen op and skip concat
					tot_pc_gen_opt++;
					pc_pushc_pending = false;
					gen_exp_pc(op);
					return;
				} else {
					// flush pushc and concat,
					// gen push?? op
					// then gen 2 stack value concat
					flush_pc_pending();
					gen_exp_pc(op);
					pc_parm_type = var_pc_setc_stack_type;
					gen_exp_pc(pc_op_concat);
				}
			} else {
				// no pushc pending so flush any pusha
				flush_pc_pending();
				if (op != pc_op_pushc) {
					// gen substr/push?? and concat if not pushc
					gen_exp_pc(op);
					pc_parm_type = var_pc_setc_stack_type;
					gen_exp_pc(pc_op_concat);
				} else {
					// start new pushc pending and
					// set pc_concat_pending for use in flush
					// to generate concat after final pushc
					pc_pushc_pending = true;
					pc_pushc_setc_value = setc_value;
					pc_concat_pending = true;
					pc_concat_setc_value1 = exp_stk_setc[tot_exp_stk_var-1];
					pc_concat_setc_value = pc_concat_setc_value1 + setc_value;
				}
			}
		}
	}

	/**
	 * Generate pushc or pusha if pending.
	 * Generate concat after pushc if pending.
	 *
	 * Notes:
	 * Push emply setc if pending
	 */
	private void flush_pc_pending()
	{
		if (pc_pushc_pending) {
			save_setc_value1 = setc_value1;
			save_setc_value2 = setc_value2;
			save_setc_value  = setc_value;
			save_pc_parm_type = pc_parm_type;
			pc_pushc_pending = false;
			if (pc_concat_pending) {
				pc_concat_pending = false;
				pc_parm_type = var_pc_setc_sdt_type;
				setc_value1 = pc_concat_setc_value1;
				setc_value2 = pc_pushc_setc_value;
				setc_value  = pc_concat_setc_value;
				gen_exp_pc(pc_op_concat);
			} else {
				setc_value = pc_pushc_setc_value;
				gen_exp_pc(pc_op_pushc);
			}
			setc_value1  = save_setc_value1;
			setc_value2  = save_setc_value2;
			setc_value   = save_setc_value;
			pc_parm_type = save_pc_parm_type;
		} else if (pc_pusha_pending) {
			pc_pusha_pending = false;
			save_seta_value = seta_value;
			save_setc_value = setc_value;
			seta_value = pc_pusha_seta_value;
			setc_value = pc_pusha_setc_value;
			if (pc_gen_exp) {
				gen_pc(pc_op_pusha);
			}
			seta_value = save_seta_value;
			setc_value = save_setc_value;
		}
	}

	/**
	 * Optimize pc code list prior to first execution and reset pc_req_opt:
	 *   1.  PUSHV,ADD 1,STORV = INC
	 *   2.  PUSHV,SUB 1,STORV = DEC
	 */
	private void opt_pcl()
	{
		pc_req_opt[pc_loc] = false;
		switch (pc_op[pc_loc]) {
		case  3: // opt pc_op_pushv                //  0    1     2    3
			if (get_pc_loc_list(pcl_inc_list) // pushv,add 1,storv
			 && pc_setc[pc_loc_list[0]].equals(pc_setc[pc_loc_list[2]])
			 && pc_seta[pc_loc_list[1]] == 1) {
				pc_op[pc_loc] = pc_op_inc;
				tot_pc_exec_opt++;
				pc_next[pc_loc] = 0;
				free_pc_list(pc_loc_list[1],pc_loc_list[2]);
			} else if (get_pc_loc_list(pcl_dec_list) // set,pushv,sub 1,store
					&& pc_setc[pc_loc_list[0]].equals(pc_setc[pc_loc_list[2]])
					&& pc_seta[pc_loc_list[1]] == 1) {
				pc_op[pc_loc] = pc_op_dec;
				tot_pc_exec_opt++;
				pc_next[pc_loc] = 0;
				free_pc_list(pc_loc_list[1],pc_loc_list[2]);
			}
			break;
		}
	}

	/**
	 * Exec store for storv, storvs, storvn, inc, and dec.
	 *
	 * @param op
	 */
	private void exec_pc_store(final byte op)
	{
		if (!get_pc_var()) {
			return;  // RPI-950
		}
		store_type = var_type;
		store_loc = var_loc;
		store_name_index = var_name_index;
		store_name = pc_setc[pc_loc];
		switch (store_type) {
		case 21: // exec seta
			if (op != pc_op_inc && op != pc_op_dec) {
				seta_value = get_seta_stack_value(-1);
				tot_exp_stk_var--;
			}
			get_pc_store_sub(op);
			store_seta_value(op);
			break;
		case 22: // exec setb
			setb_value = get_setb_stack_value(-1);
			tot_exp_stk_var--;
			get_pc_store_sub(op);
			store_setb_value();
			break;
		case 23: // exec setc
			setc_value = get_setc_stack_value();
			get_pc_store_sub(op);
			store_setc_value();
			break;
		default:
			abort_pc("invalid pc store var type=" + store_type);
		}
	}

	/**
	 * Set store_sub and store_subscript based on op.
	 *
	 * Note:
	 * If pc_op_storvs, then get store_sub from top of stack after store value has been removed.
	 *
	 * @param op
	 */
	private void get_pc_store_sub(final byte op)
	{
		if (op == pc_op_storvs || op == pc_op_stords) {
			store_subscript = true;
			store_sub = get_seta_stack_value(-1);
			tot_exp_stk_var--;
		} else if (op == pc_op_storvn) {
			store_subscript = true;
			store_sub++;
		} else {
			store_subscript = false;
			store_sub = 1;
		}
	}

	/**
	 * Load pc_loc_list.
	 *
	 * @param pc_op_list
	 * @return
	 */
	private boolean get_pc_loc_list(byte[] pc_op_list)
	{
		final int list_len = pc_op_list.length;
		pc_loc_list[0] = pc_loc;
		int index = 1;
		int next  = pc_next[pc_loc];
		while (index < list_len) {
			if (next == 0
			 || pc_op[next] != pc_op_list[index]) {
				return false;
			}
			pc_loc_list[index] = next;
			next = pc_next[next];
			index++;
		}
		return true;
	}

	/**
	 * Free pc list starting at head and ending at tail.
	 *
	 * Notes:
	 * User must reset any other pointers to this list from pc_next or pc_start.
	 *
	 * @param head
	 * @param tail
	 */
	private void free_pc_list(int head, int tail)
	{
		pc_next[tail] = pc_free;
		pc_free = head;
	}

	/**
	 * Replace top of stack with A'stack indicating if symbol defined in lookahead (shared by exp and pc).
	 */
	private void exec_pc_pfx_a()
	{
		if (tot_exp_stk_var > 0) {
			setc_value1 = get_setc_stack_value();
			if (mz390_find_sym(setc_value1) != -1) {
				seta_value = 1;
			} else {
				seta_value = 0;
			}
			put_seta_stack_var();
			exp_var_pushed = true; // prevent unary minus
		} else {
			log_error(67,"A' missing variable");
		}
		if (tz390.opt_tracem) { // RPI-1212
			tz390.put_trace("A' " + seta_value + " = A'" + setc_value1);
		}
	}

	/**
	 * Replace top of stack with D'sym = 1/0 indicating if defined as ordinary symbol yet.
	 */
	private void exec_pc_pfx_d()
	{
		if (tot_exp_stk_var > 0) {
			setc_value1 = get_setc_stack_value();
			if (!tz390.opt_asm) {
				setb_value = 0;
			} else {
				int cur_sym = mz390_find_sym(setc_value1);
				if (cur_sym != -1 && az390.sym_def[cur_sym] > az390.sym_def_ref) {
					setb_value = 1;
				} else {
					setb_value = 0;
				}
			}
			put_setb_stack_var();
		} else {
			log_error(152, "Missing variable for D' operator.");
		}
		if (tz390.opt_tracem) { // RPI-1212
			tz390.put_trace("D' " + setb_value + " = D'" + setc_value1);
		}
	}

	/**
	 * Return I'sym integer value.
	 */
	private void exec_pc_pfx_i()
	{
		if (tot_exp_stk_var > 0) {
			setc_value1 = get_setc_stack_value();
			if (!tz390.opt_asm) {
				seta_value = 0;
			} else {
				int cur_sym = mz390_find_sym(setc_value1);
				if (cur_sym != -1 && az390.sym_def[cur_sym] > az390.sym_def_ref) {
					seta_value = az390.get_int_pfx(az390.sym_type[cur_sym],az390.sym_dc_type_sfx[cur_sym],az390.sym_len[cur_sym],az390.sym_scale[cur_sym]);
				} else {
					seta_value = 0;
				}
			}
			put_seta_stack_var();
		} else {
			log_error(152,"missing variable for I' operator");
		}
		if (tz390.opt_tracem) { // RPI-1212
			tz390.put_trace("I' " + seta_value + " = I'" + setc_value1);
		}
	}

	/**
	 * K'sym returns string length.
	 */
	private void exec_pc_pfx_k()
	{
		if (tot_exp_stk_var > 0) {
			setc_value1 = get_setc_stack_value();
			seta_value = setc_value1.length();
			put_seta_stack_var();
		} else {
			log_error(197, "K' missing variable");
		}
		if (tz390.opt_tracem) { // RPI-1212
			tz390.put_trace("K' " + seta_value + " = K'" + setc_value1);
		}
	}

	/**
	 * L'sym returns symbol length.
	 */
	private void exec_pc_pfx_l()
	{
		if (tot_exp_stk_var > 0) {
			setc_value1 = get_setc_stack_value();
			seta_value = get_sym_len(setc_value1);
			put_seta_stack_var();
		} else {
			log_error(198, "L' missing variable");
		}
		if (tz390.opt_tracem) { // RPI-1212
			tz390.put_trace("L' " + seta_value + " = L'" + setc_value1);
		}
	}

	/**
	 * Replace top of stack with N'stack (shared by exp and pc).
	 */
	private void exec_pc_pfx_n()
	{
		if (tot_exp_stk_var > 0) {
			var_type = exp_stk_var_type[tot_exp_stk_var -1];
			val_type = get_val_type();
			var_loc  = exp_stk_var_loc[tot_exp_stk_var -1];
			var_name_index = exp_stk_var_name_index[tot_exp_stk_var -1];
			switch (var_type) { // RPI-447 was exp_stk_type
			case 21: // seta
			case 22: // setb
			case 23: // setc
				if (var_loc == var_lcl_loc) { // RPI-447 was var_loc
					if (var_name_index >= 0) { // RPI-901
						if (lcl_set_high[var_name_index] != -1) {   // RPI-1162
							if (lcl_set_high[var_name_index] > 0) { // RPI-1162 was end-start > 1 in error
								seta_value = lcl_set_high[var_name_index] - lcl_set_start[var_name_index]+1;
							} else {
								seta_value = 0;
							}
						} else {
							seta_value = 0; // RPI-1162 scalar
						}
					} else {
						seta_value = 0; // RPI-901
						log_error(237,"undefined N'operand"); // RPI-901
					}
					tot_exp_stk_var--;
				} else if (var_loc == var_gbl_loc) {
					if (var_name_index >= 0) { // RPI-901
						if (gbl_set_high[var_name_index] != -1) {   // RPI-1162
							if (gbl_set_high[var_name_index] > 0) { // RPI-1162 was end-start > 1 in error
								seta_value = gbl_set_high[var_name_index] - gbl_set_start[var_name_index]+1;
							} else {
								seta_value = 0;
							}
						} else {
							seta_value = 0; // RPI-1162 scalar
						}
					}
					tot_exp_stk_var--;
				} else {
					// parm sublist count
					setc_value = get_setc_stack_value();
					seta_value = get_sublist_count(setc_value);
				}
				put_seta_stack_var();
				break;
			case 24: // parm var_parm_type
			case 25: // subscript var_subscript type
			case 26: // sublist var_sublist_type
				if (var_loc == var_syslist_loc      // RPI-447 was setb
					&& var_name_index == -1     // RPI-447 was seta
					&& mac_call_level > 0) {
					// syslist parm count
					seta_value = mac_call_pos_tot[mac_call_level];
					tot_exp_stk_var--; // remove syslist var
					put_seta_stack_var();
				} else {
					// syslist parm sublist count
					setc_value1 = get_setc_stack_value();
					seta_value = get_sublist_count(setc_value1);
					put_seta_stack_var(); // RPI-447
				}
				break;
			default:
				log_error(159, "Invalid argument for N'");
			}
			exp_var_pushed = true; // prevent unary minus
		} else {
			log_error(199, "N' missing variable");
		}
	}

	/**
	 * Return type of operator for O'sum
	 *   A = assembler control operator (CSECT, EQU ETC)
	 *   E = extended mnemonic (BH, BL, BER, ETC.)
	 *   O = machine opcode
	 *   M = macro defined
	 *   S = macro found in sysmac dir
	 *   U = unknown
	 */
	private void exec_pc_pfx_o()
	{
		if (tot_exp_stk_var > 0) {
			setc_value1 = get_setc_stack_value().toUpperCase();
			int opcode_type = find_opcode_type(setc_value1);
			if (opcode_type >= 0) {
				if (opcode_type <= tz390.max_ins_type) {
					if (opcode_type ==  3
					 || opcode_type ==  6
					 || opcode_type == 13) {
						setc_value = "E"; // BRX, BCX, BRCX extended mnemonic
					} else {
						setc_value = "O"; // machine opcode
					}
				} else {
					setc_value = "A"; // assembler opcode
				}
			} else if (opcode_type == -1) {
				int macro_index = find_mac_entry(setc_value1);
				if (macro_index > 0) {
					setc_value = "M";
				} else if (macro_index == -1
						&& tz390.find_file_name(tz390.dir_mac,setc_value,tz390.mac_type,tz390.dir_cur) != null) {
					setc_value = "S";
				} else {
					setc_value = "U";
				}
			} else {
				setc_value = "U"; // deleted or not found
			}
			put_setc_stack_var();
		} else {
			log_error(200,"O' missing variable");
		}
		if (tz390.opt_tracem) { // RPI-1212
			tz390.put_trace("O' " + setc_value + " = O'" + setc_value1);
		}
	}

	/**
	 * Return exponent attrivute of ordinary symbol.
	 */
	private void exec_pc_pfx_s()
	{
		if (tot_exp_stk_var > 0) {
			setc_value1 = get_setc_stack_value();
			if (!tz390.opt_asm) {
				seta_value = 0;
			}
			int cur_sym = mz390_find_sym(setc_value1);
			if (cur_sym != -1 && az390.sym_def[cur_sym] > az390.sym_def_ref) {
				seta_value = az390.sym_scale[cur_sym];
			} else {
				seta_value = 0;
			}
			put_seta_stack_var();
		} else {
			log_error(152, "Missing variable for D' operator.");
		}
		if (tz390.opt_tracem) { // RPI-1212
			tz390.put_trace("S' " + seta_value + " = S'" + setc_value1);
		}
	}

	/**
	 * T'var/sym returns symbol type
	 */
	private void exec_pc_pfx_t()
	{
		if (tot_exp_stk_var > 0) { // RPI-835
			setc_value1 = get_setc_stack_value();
			if (!tz390.opt_asm) {
				setc_value = "U";
			} else {
				int cur_sym = mz390_find_sym(setc_value1);
				if (cur_sym >= 0) {
					if (az390.sym_attr_elt[cur_sym] == az390.sym_attr_elt_def) {
						setc_value = "" + (char)tz390.ebcdic_to_ascii[az390.sym_attr[cur_sym] & 0xff];
					} else {
						setc_value = "" + (char)tz390.ebcdic_to_ascii[az390.sym_attr_elt[cur_sym] & 0xff];
					}
				} else {
					if (setc_value1.length() > 0) {
						if (string_numeric(setc_value1)) { // RPI-180, RPI-468
							setc_value  = "N";
						} else {
							setc_value = "U";
						}
					} else {
						setc_value = "O";;
					}
				}
			}
			put_setc_stack_var();
		} else {
			log_error(201, "T' missing variable.");
		}
		if (tz390.opt_tracem) { // RPI-1212
			tz390.put_trace("T' " + setc_value + " = T'" + setc_value1);
		}
	}

	/**
	 * Return true if string or (string) numeric  RPI-468
	 *
	 * @param text
	 * @return
	 */
	private boolean string_numeric(String text)
	{
		if (text.length() > 0) {
			if (text.length() >= 3 && text.charAt(0) == '(' && text.charAt(text.length()-1) == ')') {
				text = text.substring(1,text.length()-2);
			}
			int index = 0;
			while (index < text.length()) {
				if (text.charAt(index) < '0' || text.charAt(index) > '9') {
					return false;
				}
				index++;
			}
			return true;
		}
		return false;
	}

	/**
	 * Replace string on stack with upper case
	 */
	private void exec_pc_upper()
	{
		check_setc_quotes(1); // RPI-1139
		setc_value1 = get_setc_stack_value();
		setc_value = setc_value1.toUpperCase();
		if (tz390.opt_tracem) { // RPI-1212
			tz390.put_trace("UPPER " + setc_value + " = UPPER " + setc_value1);
		}
		put_setc_stack_var();
	}

	/**
	 * Replace string on stack with lower case.
	 */
	private void exec_pc_lower()
	{
		check_setc_quotes(1); // RPI-1139
		setc_value1 = get_setc_stack_value();
		setc_value = setc_value1.toLowerCase();
		if (tz390.opt_tracem) { // RPI-1212
			tz390.put_trace("LOWER " + setc_value + " = LOWER " + setc_value1);
		}
		put_setc_stack_var();
	}

	/**
	 * Execute computed ago branch using
	 *   1. ago_seta_index ptr to gbla ago array:
	 *      +0 = ptr to gblc label array if TRACEP else 0
	 *      +1 = maximum limit of ago index
	 *      +2 = ago line index array for macro labels
	 *   2. ago_index = current index
	 */
	private void exec_pc_ago()
	{
		if (ago_index >= 1
			&& ago_index <= gbl_seta[ago_gbla_index + 1]) {
			actr_count--;  // RPI-754
			new_mac_line_index = gbl_seta[ago_gbla_index + 1 + ago_index];
			if (new_mac_line_index >= 0) { // RPI-899
				mac_line_index = new_mac_line_index;
			} else {
				String ago_err = " index = " + ago_index;
				if (tz390.opt_tracep) {
					ago_err = ago_err + " label=" + gbl_setc[gbl_seta[ago_gbla_index] + ago_index - 1];
				}
				abort_error(235,"Exec ago computed label undefined " + ago_err);
			}
			mac_branch = true; // RPI-900
		}
	}

	/**
	 * Perform unary compliment on stack value.
	 */
	private void exec_pc_ucomp()
	{
		switch (exp_stk_val_type[tot_exp_stk_var-1]) {
		case 1:
			seta_value = - exp_stk_seta[tot_exp_stk_var -1];
			exp_stk_seta[tot_exp_stk_var-1] = seta_value;
			break;
		case 2:
			seta_value = - exp_stk_setb[tot_exp_stk_var -1];
			exp_stk_seta[tot_exp_stk_var-1] = seta_value;
			exp_stk_val_type[tot_exp_stk_var-1] = val_seta_type;
			break;
		case 3:
			seta_value = - get_seta_stack_value(-1);
			exp_stk_seta[tot_exp_stk_var-1] = seta_value;
			exp_stk_val_type[tot_exp_stk_var-1] = val_seta_type;
			break;
		}
	}

	/**
	 * Convert int to binary string with leading zeros to make length mult. 8
	 */
	private void exec_pc_a2b()
	{
		seta_value1 = get_seta_stack_value(-1);
		tot_exp_stk_var--;
		setc_value = Long.toString(((long)(seta_value1) << 32) >>> 32,2);  // RPI-1105
		setc_value = "00000000000000000000000000000000".substring(setc_value.length()) + setc_value;
		put_setc_stack_var();
	}

	/**
	 * Convert int to character string.
	 */
	private void exec_pc_a2c()
	{
		seta_value1 = get_seta_stack_value(-1);
		tot_exp_stk_var--;
		setc_value  = ""
					+ (char)tz390.ebcdic_to_ascii[seta_value1 >>> 24       ]
					+ (char)tz390.ebcdic_to_ascii[seta_value1 >>> 16 & 0xff]
					+ (char)tz390.ebcdic_to_ascii[seta_value1 >>> 8  & 0xff]
					+ (char)tz390.ebcdic_to_ascii[seta_value1        & 0xff];
		put_setc_stack_var();
	}

	/**
	 * Convert int to decimal string.
	 */
	private void exec_pc_a2d()
	{
		seta_value1 = get_seta_stack_value(-1);
		tot_exp_stk_var--;
		if (seta_value1 >= 0) {
			setc_value = "+" + seta_value1; // PRI 943
		} else {
			setc_value = ""  + seta_value1; // RPI-943
		}
		put_setc_stack_var();
	}

	/**
	 * Convert int to hex string.
	 */
	private void exec_pc_a2x()
	{
		seta_value1 = get_seta_stack_value(-1);
		tot_exp_stk_var--;
		setc_value = Integer.toHexString(seta_value1).toUpperCase(); // RPI-1101
		setc_value = ("00000000" + setc_value).substring(setc_value.length());
		put_setc_stack_var();
	}

	/**
	 * Convert binary string to int.
	 */
	private void exec_pc_b2a()
	{
		check_setc_quotes(1); // RPI-1139
		setc_value1 = get_setc_stack_value();
		setc_value = "B'" + setc_value1 + "'";
		exp_push_sdt();
	}

	/**
	 * Convert binary string to char string.
	 */
	private void exec_pc_b2c()
	{
		check_setc_quotes(1); // RPI-1139
		seta_value  = Integer.valueOf(get_setc_stack_value(),2);
		setc_value  = ""
					+ (char)tz390.ebcdic_to_ascii[seta_value >>> 24       ]
					+ (char)tz390.ebcdic_to_ascii[seta_value >>> 16 & 0xff]
					+ (char)tz390.ebcdic_to_ascii[seta_value >>> 8  & 0xff]
					+ (char)tz390.ebcdic_to_ascii[seta_value        & 0xff];
		put_setc_stack_var();
	}

	/**
	 * Convert binary string to decimal string.
	 */
	private void exec_pc_b2d()
	{
		check_setc_quotes(1); // RPI-1139
		setc_value1 = get_setc_stack_value();
		seta_value = Integer.valueOf(setc_value1,2);
		if (seta_value < 0) {
			seta_value = - seta_value;
		}
		setc_value = Integer.toString(seta_value);
		put_setc_stack_var();
	}

	/**
	 * Convert binary string to hex string.
	 */
	private void exec_pc_b2x()
	{
		check_setc_quotes(1); // RPI-1139
		setc_value1 = get_setc_stack_value();
		seta_value = Integer.valueOf(setc_value1,2);
		setc_value = Integer.toHexString(seta_value).toUpperCase(); // RPI-1101
		setc_value = ("00000000" + setc_value).substring(setc_value.length());
		put_setc_stack_var();
	}

	/**
	 * convert 1-4 character string to int
	 */
	private void exec_pc_c2a()
	{
		check_setc_quotes(1); // RPI-1139
		setc_value = "C'" + get_setc_stack_value() + "'";
		exp_push_sdt();
	}

	/**
	 * Convert char string to binary string.
	 */
	private void exec_pc_c2b()
	{
		check_setc_quotes(1); // RPI-1139
		setc_value = "C'" + get_setc_stack_value() + "'";
		setc_value1 = setc_value;
		if (!tz390.get_sdt_char_int(setc_value)) {
			log_error(178, "Invalid character sdt " + setc_value);
		}
		seta_value = tz390.sdt_char_int;
		setc_value = Integer.toString(seta_value,2);
		seta_value = setc_value.length();
		seta_value = seta_value - seta_value/8*8;
		if (seta_value != 0) {
			setc_value = "00000000".substring(seta_value) + setc_value;
		}
		put_setc_stack_var();
	}

	/**
	 * Convert char string to decimal string.
	 */
	private void exec_pc_c2d()
	{
		check_setc_quotes(1); // RPI-1139
		setc_value = "C'" + get_setc_stack_value() + "'";
		setc_value1 = setc_value;
		if (!tz390.get_sdt_char_int(setc_value)) {
			log_error(179,"invalid character sdt " + setc_value);
		}
		seta_value = tz390.sdt_char_int;
		if (seta_value < 0) {
			seta_value = - seta_value;
		}
		setc_value = Integer.toString(seta_value);
		put_setc_stack_var();
	}

	/**
	 * Convert char string to hex string.
	 */
	private void exec_pc_c2x()
	{
		check_setc_quotes(1); // RPI-1139
		String hex = ""; // RPI-1101
		final String text = get_setc_stack_value();
		int index = 0;
		while (index < text.length()) {
			if (index + 4 >= text.length()) {
				get_text_hex(text.substring(index));
			} else {
				get_text_hex(text.substring(index,index+4));
			}
			hex = hex + setc_value;
			index = index + 4;
		}
		setc_value = hex;
		put_setc_stack_var();
	}

	/**
	 * Return up to 2-8 hex chars for 1-4 chars.
	 *
	 * @param text
	 */
	private void get_text_hex(final String text)
	{
		setc_value = "C'" + text + "'";
		setc_value1 = setc_value;
		if (!tz390.get_sdt_char_int(setc_value)) {
			log_error(180,"invalid character sdt " + setc_value);
		}
		seta_value = tz390.sdt_char_int;
		setc_value = tz390.get_hex(seta_value,2*text.length()); // RPI-1101
	}

	/**
	 * Convert decimal string to int.
	 */
	private void exec_pc_d2a()
	{
		check_setc_quotes(1); // RPI-1139
		boolean save_opt_allow = tz390.opt_allow; // RPI-1204
		tz390.opt_allow = true;           // RPI-1204
		seta_value = get_seta_stack_value(-1);
		tz390.opt_allow = save_opt_allow; // RPI-1204
		setc_value1 = get_setc_stack_value();
		put_seta_stack_var();
	}

	/**
	 * Convert decimal string to binary string.
	 */
	private void exec_pc_d2b()
	{
		check_setc_quotes(1); // RPI-1139
		boolean save_opt_allow = tz390.opt_allow; // RPI-1204
		tz390.opt_allow = true;           // RPI-1204
		seta_value = get_seta_stack_value(-1);
		tz390.opt_allow = save_opt_allow; // RPI-1204
		setc_value1 = get_setc_stack_value();
		setc_value = Integer.toString(seta_value,2);
		seta_value = setc_value.length();
		seta_value = seta_value - seta_value/8*8;
		if (seta_value != 0) {
			setc_value = "00000000".substring(seta_value) + setc_value;
		}
		put_setc_stack_var();
	}

	/**
	 * Convert decimal string to char string.
	 */
	private void exec_pc_d2c()
	{
		check_setc_quotes(1); // RPI-1139
		boolean save_opt_allow = tz390.opt_allow; // RPI-1204
		tz390.opt_allow = true;           // RPI-1204
		seta_value = get_seta_stack_value(-1);
		tz390.opt_allow = save_opt_allow; // RPI-1204
		setc_value1 = get_setc_stack_value();
		setc_value = ""
					+ (char)tz390.ebcdic_to_ascii[seta_value >>> 24       ]
					+ (char)tz390.ebcdic_to_ascii[seta_value >>> 16 & 0xff]
					+ (char)tz390.ebcdic_to_ascii[seta_value >>> 8  & 0xff]
					+ (char)tz390.ebcdic_to_ascii[seta_value        & 0xff];
		put_setc_stack_var();
	}

	/**
	 * Convert decimal string to hex string.
	 */
	private void exec_pc_d2x()
	{
		check_setc_quotes(1); // RPI-1139
		final boolean save_opt_allow = tz390.opt_allow; // RPI-1204
		tz390.opt_allow = true;           // RPI-1204
		seta_value = get_seta_stack_value(-1);
		tz390.opt_allow = save_opt_allow; // RPI-1204
		setc_value1 = get_setc_stack_value();;
		setc_value = Integer.toHexString(seta_value).toUpperCase(); // RPI-1101
		setc_value = ("00000000" + setc_value).substring(setc_value.length());
		put_setc_stack_var();
	}

	/**
	 * Return dc length of string after reducing double quotes and ampersands.
	 */
	private void exec_pc_dclen()
	{
		check_setc_quotes(1); // RPI-1139
		setc_value1 = get_setc_stack_value();
		setc_value = tz390.find_dsquote.matcher(setc_value1).replaceAll("'"); // RPI-1080
		setc_value = tz390.find_damp.matcher(   setc_value ).replaceAll("&"); // RPI-1080
		seta_value = setc_value.length();
		val_type = val_seta_type;
		put_seta_stack_var();
	}

	/**
	 * Return string with reduced quotes and ampersands.
	 */
	private void exec_pc_dcval()
	{
		check_setc_quotes(1); // RPI-1139
		setc_value1 = get_setc_stack_value();
		setc_value = tz390.find_dsquote.matcher(setc_value1).replaceAll("'"); // RPI-1080
		setc_value = tz390.find_damp.matcher(   setc_value ).replaceAll("&"); // RPI-1080
		put_setc_stack_var();
	}

	/**
	 * Remove start and ending quote if any.
	 */
	private void exec_pc_dequote() // RPI-886
	{
		check_setc_quotes(1); // RPI-1139
		setc_value1 = get_setc_stack_value();
		if (   setc_value1.length() > 1
			&& setc_value1.charAt(0) == '\''
			&& setc_value1.charAt(setc_value1.length()-1) == '\'') {
			setc_value = setc_value1.substring(1,setc_value1.length()-1);
		} else if (setc_value1.length() > 0) { // RPI-1107
			if (setc_value1.charAt(0) == '\'') {
				setc_value = setc_value1.substring(1); // RPI-1107
			} else if (setc_value1.charAt(setc_value1.length()-1) == '\'') {
				setc_value = setc_value1.substring(0,setc_value1.length()-1); // RPI-1107
			} else {
				setc_value = setc_value1;
			}
		} else { // return value if no first/last quotes
			setc_value = setc_value1;
		}
		put_setc_stack_var();
	}

	/**
	 * Double quotes within string.
	 */
	private void exec_pc_double()
	{
		check_setc_quotes(1); // RPI-1139
		setc_value1 = get_setc_stack_value();
		setc_value = tz390.find_squote.matcher(setc_value1).replaceAll("''"); // RPI-1080
		setc_value = tz390.find_amp.matcher(   setc_value ).replaceAll("&&"); // RPI-1080
		put_setc_stack_var();
	}

	/**
	 * Return 1 if binary string else 0.
	 */
	private void exec_pc_isbin()
	{
		check_setc_quotes(1); // RPI-1139
		setc_value1 = get_setc_stack_value();
		try {
			seta_value = Integer.valueOf(setc_value1,2);
			setb_value = 1;
		} catch (final Exception e) {
			setb_value = 0;
		}
		put_setb_stack_var();
	}

	/**
	 * If string decimal return 1 else 0.
	 */
	private void exec_pc_isdec()
	{
		check_setc_quotes(1); // RPI-1139
		setc_value1 = get_setc_stack_value();
		try {
			seta_value = Integer.valueOf(setc_value1);
			setb_value = 1;
		} catch (final Exception e) {
			setb_value = 0;
		}
		put_setb_stack_var();
	}

	/**
	 * Return 1 if string hex else 0.
	 */
	private void exec_pc_ishex()
	{
		check_setc_quotes(1); // RPI-1139
		setc_value1 = get_setc_stack_value();
		try {
			seta_value = Integer.valueOf(setc_value1,16);
			setb_value = 1;
		} catch (final Exception e) {
			setb_value = 0;
		}
		put_setb_stack_var();
	}

	/**
	 * Return 1 if symbol defined else 0.
	 */
	private void exec_pc_issym()
	{
		check_setc_quotes(1); // RPI-1139
		setc_value1 = get_setc_stack_value();
		if (setc_value1.length() > 0 && setc_value1.length() <= 63) {
			symbol_match = symbol_pattern.matcher(setc_value1);
			if (symbol_match.find()
				&& symbol_match.group().equals(setc_value1)) {  // RPI-633
				setb_value = 1;
			} else {
				setb_value = 0;
			}
		} else {
			setb_value = 0;
		}
		put_setb_stack_var();
	}

	/**
	 * Convert int to signed decimal string.
	 */
	private void exec_pc_signed()
	{
		seta_value = get_seta_stack_value(-1);
		tot_exp_stk_var--;
		setc_value = Integer.toString(seta_value);
		put_setc_stack_var();
	}

	/**
	 * shift left arithmetic
	 */
	private void exec_pc_sla()
	{
		seta_value1 = get_seta_stack_value(-2);
		seta_value2 = get_seta_stack_value(-1);
		tot_exp_stk_var = tot_exp_stk_var - 2;
		seta_value = seta_value1 << seta_value2;
		if (seta_value1 >= 0) {
			seta_value = seta_value & 0x7fffffff;
		} else {
			seta_value = seta_value | 0x80000000;
		}
		if (tz390.opt_tracem) { // RPI-1212
			tz390.put_trace("SLA " + seta_value + " = " + seta_value1  + " SLA " + seta_value2);
		}
		put_seta_stack_var();
	}

	/**
	 * Shift left logical.
	 */
	private void exec_pc_sll()
	{
		seta_value1 = get_seta_stack_value(-2);
		seta_value2 = get_seta_stack_value(-1);
		tot_exp_stk_var = tot_exp_stk_var - 2;
		seta_value = seta_value1 << seta_value2;
		if (tz390.opt_tracem) { // RPI-1212
			tz390.put_trace("SLL " + seta_value + " = " + seta_value1  + " SLL " + seta_value2);
		}
		put_seta_stack_var();
	}

	/**
	 * Shift right arithmetic.
	 */
	private void exec_pc_sra()
	{
		seta_value1 = get_seta_stack_value(-2);
		seta_value2 = get_seta_stack_value(-1);
		tot_exp_stk_var = tot_exp_stk_var - 2;
		seta_value = seta_value1 >> seta_value2;
		if (tz390.opt_tracem) { // RPI-1212
			tz390.put_trace("SRA " + seta_value + " = " + seta_value1  + " SRA " + seta_value2);
		}
		put_seta_stack_var();
	}

	/**
	 * Shift right logical
	 */
	private void exec_pc_srl()
	{
		seta_value1 = get_seta_stack_value(-2);
		seta_value2 = get_seta_stack_value(-1);
		tot_exp_stk_var = tot_exp_stk_var - 2;
		seta_value = seta_value1 >>> seta_value2;
		if (tz390.opt_tracem) { // RPI-1212
			tz390.put_trace("SRL " + seta_value + " = " + seta_value1  + " SRL " + seta_value2);
		}
		put_seta_stack_var();
	}

	/**
	 * Return int value of assembler attribute for symbol defined via EQU 4th parm.
	 */
	private void exec_pc_sattra()
	{
		check_setc_quotes(1); // RPI-1139
		setc_value1 = get_setc_stack_value();
		int cur_sym = mz390_find_sym(setc_value1);
		if (cur_sym >= 0) {
			setc_value = az390.sym_attra[cur_sym];
		} else {
			setc_value = "";
		}
		if (tz390.opt_tracem) { // RPI-1212
			tz390.put_trace("SATTRA " + setc_value + " = SATTRA " + setc_value1);
		}
		put_setc_stack_var();
	}

	/**
	 * Return int value of symbol program attribute defined via EQU 5th parm.
	 */
	private void exec_pc_sattrp()
	{
		check_setc_quotes(1); // RPI-1139
		setc_value1 = get_setc_stack_value();
		int cur_sym = mz390_find_sym(setc_value1);
		if (cur_sym >= 0) {
			seta_value = az390.sym_attrp[cur_sym];
			setc_value = (""
						+ (char)tz390.ebcdic_to_ascii[seta_value >>> 24       ]
						+ (char)tz390.ebcdic_to_ascii[seta_value >>> 16 & 0xff]
						+ (char)tz390.ebcdic_to_ascii[seta_value >>> 8  & 0xff]
						+ (char)tz390.ebcdic_to_ascii[seta_value        & 0xff]
						 ).trim();
		} else {
			setc_value = "";
		}
		if (tz390.opt_tracem) { // RPI-1212
			tz390.put_trace("SATTRP " + setc_value + " = SATTRP " + setc_value1);
		}
		put_setc_stack_var();
	}

	/**
	 * Convert hex string to int.
	 */
	private void exec_pc_x2a()
	{
		check_setc_quotes(1); // RPI-1139
		setc_value1 = get_setc_stack_value();
		try {
			seta_value = Integer.valueOf(setc_value1,16);
		} catch (final Exception e) {
			seta_value = 0;  // RPI-1085
		}
		put_seta_stack_var();
	}

	/**
	 * Convert hex string to binary string.
	 */
	private void exec_pc_x2b()
	{
		check_setc_quotes(1); // RPI-1139
		setc_value1 = get_setc_stack_value();
		seta_value1 = Integer.valueOf(setc_value1,16);
		setc_value = Integer.toString(seta_value1,2);
		seta_value = setc_value.length();
		seta_value = seta_value - seta_value/8*8;
		if (seta_value != 0) {
			setc_value = "00000000".substring(seta_value) + setc_value;
		}
		put_setc_stack_var();
	}

	/**
	 * Convert hex string to char string.
	 */
	private void exec_pc_x2c()
	{
		check_setc_quotes(1); // RPI-1139
		setc_value1 = get_setc_stack_value();
		seta_value = Integer.valueOf(setc_value1,16);
		setc_value = ""
					+ (char)tz390.ebcdic_to_ascii[seta_value >>> 24       ]
					+ (char)tz390.ebcdic_to_ascii[seta_value >>> 16 & 0xff]
					+ (char)tz390.ebcdic_to_ascii[seta_value >>> 8  & 0xff]
					+ (char)tz390.ebcdic_to_ascii[seta_value        & 0xff];
		put_setc_stack_var();
	}

	/**
	 * Convert hex string to decimal string.
	 */
	private void exec_pc_x2d()
	{
		check_setc_quotes(1); // RPI-1139
		setc_value1 = get_setc_stack_value();
		seta_value = Integer.valueOf(setc_value1,16);
		if (seta_value < 0) {
			seta_value = - seta_value;
		}
		setc_value = Integer.toString(seta_value);
		put_setc_stack_var();
	}

	/**
	 * Get created var name from stack and update var fields in pc.
	 *
	 * @param offset
	 */
	private void get_pc_created_var(int offset)
	{
		pc_sysndx[pc_loc] = mac_call_sysndx[mac_call_level];
		var_name = "&" + exp_stk_setc[tot_exp_stk_var + offset].toUpperCase(); // RPI-499 fix careted vars
		symbol_match = symbol_pattern.matcher(var_name);
		if (  !symbol_match.find() // RPI-897
			|| symbol_match.start() != 1) {
			log_error(233,"invalid created set symbol name - " + var_name);
		}
		pc_setc[pc_loc] = var_name;
		if (!find_set(var_name,set_sub)) {
			var_loc  = var_lcl_loc;
			var_type = store_type;
			add_lcl_set(var_name,store_type,set_sub,set_subscript); // RPI-1162
		}
		pc_var_type[pc_loc] = var_type;
		pc_var_loc[ pc_loc] = var_loc;
		pc_seta[    pc_loc] = var_name_index;
	}

	/**
	 * Set pc seta or setc parms based on pc_var_type() and abort if error.
	 */
	private void get_pc_parms()
	{
		switch (pc_parm_type) {
		case 31: // var_pc_seta_stack_values
			val_type = val_seta_type;
			if (tot_exp_stk_var >= 2) {
				get_seta_stack_values();
			} else {
				abort_pc("stack count < 2 = " + tot_exp_stk_var);
			}
			break;
		case 32: // var_pc_seta_sdt_type
			val_type = val_seta_type;
			if (tot_exp_stk_var >= 1) {
				seta_value1 = get_seta_stack_value(-1);
				tot_exp_stk_var--;
				seta_value2 = pc_seta[pc_loc];
			} else {
				abort_pc("stack count < 1 = " + tot_exp_stk_var);
			}
			break;
		case 35: // var_pc_setc_stack_values
			val_type = val_setc_type;
			if (tot_exp_stk_var >= 2) {
				get_setc_stack_values();
			} else {
				abort_pc("stack count < 2 = " + tot_exp_stk_var);
			}
			break;
		case 36: // var_pc_setc_sdt_type
			val_type = val_setc_type;
			if (tot_exp_stk_var >= 1) {
				setc_value1 = get_setc_stack_value();
				setc_value2 = pc_setc[pc_loc];
			} else {
				abort_pc("stack count < 1 = " + tot_exp_stk_var);
			}
			break;
		default:
			abort_pc("invalid get_pc_parms type = " + var_type);
		}
	}

	/**
	 * Push ordinary symbol abs value on stack else issue error.
	 */
	private void exec_pc_pushs()
	{
		final int index = mz390_find_sym(setc_value);
		if (index >= 0) {
			seta_value = az390.sym_loc[index];
			put_seta_stack_var();
		} else if (exp_prev_class == exp_class_oper) {
			put_setc_stack_var(); // push the setc name
		 } else {  // RPI-836
			log_error(228,"undefined symbol - " + setc_value);
		}
	}

	/**
	 * Return val_type based on var_type.
	 *
	 * @return
	 */
	private byte get_val_type()
	{
		switch (var_type) {
		case 21: // var_seta_type
			return val_seta_type;
		case 22: // var_setb_type
			return val_setb_type;
		case 23: // var_setc_type
			return val_setc_type;
		case 24: // var_parm_type
		case 25: // var_parm_type
		case 26: // var_parm_type
			return val_setc_type;
		default:
			abort_pc("invalid var type");
			return -1;
		}
	}

	/**
	 * Write text to buffered file with continuations if > 71 characters.
	 * Notes:
	 *   1. Used by put_bal_line and
	 *   2. Used by put_pch_line if extended FORMAT option specified.
	 *
	 * @param file_buff
	 * @param text
	 */
	private void put_continued_text(final BufferedWriter file_buff, final String text)
	{
		try {
			if  (text.length() < tz390.bal_ictl_end + 1) { // RPI-264, RPI-437 RPI-728
				tz390.systerm_io++;
				file_buff.write(text + tz390.newline); // RPI-500
			} else {
				tz390.systerm_io++;
				file_buff.write(text.substring(0,tz390.bal_ictl_end) + "X" + tz390.newline); // RPI-500 RPI-728
				String text_left = text.substring(tz390.bal_ictl_end);  // RPI-728
				while (text_left.length() > 0) {
					if  (text_left.length() > tz390.bal_ictl_cont_tot) {  // RPI-728
						String cont_line = "               "   // RPI-728 - 16 blanks
								+ text_left.substring(0,tz390.bal_ictl_cont_tot) // RPI-728
								+ "X" + tz390.newline ; // RPI-500
						tz390.systerm_io++;
						file_buff.write(cont_line);
						text_left = text_left.substring(tz390.bal_ictl_cont_tot);
					} else {
						tz390.systerm_io++;
						file_buff.write("               "
								+ text_left + tz390.newline); // RPI-500
						text_left = "";
					}
				}
			}
		} catch (final Exception e) {
			abort_error(206,"File I/O error " + e.toString());
		}
	}

	/**
	 * Insert record in in queue.
	 */
	private void process_ainsert()
	{
		if (   bal_parms.length() > 2
			&& bal_parms.charAt(0) == '\'') {
			final String text = bal_parms;
			tz390.parm_match = tz390.parm_pattern.matcher(text);
			if (   tz390.parm_match.find()
				&& tz390.parm_match.start(0) == 0) {
				int index = tz390.parm_match.end();
				String rec = replace_quoted_text_vars(tz390.parm_match.group(),true);
				rec = rec.substring(1,rec.length()-1);
				if (tz390.opt_asm && !tz390.opt_allow) { // RPI-968
					rec = set_length_80(rec);
				}
				if (index >= text.length()
					|| text.charAt(index) <= ' ') {
					log_error(277,"AINSERT missing FRONT/BACK" + bal_parms); // RPI-1053
				} else {
					if (text.substring(index,index+5).toUpperCase().equals(",BACK")) {
						ainsert_back = true;
						add_ainsert_queue_rec(rec);
					} else if (text.substring(index,index+6).toUpperCase().equals(",FRONT")) {
						ainsert_back = false;
						add_ainsert_queue_rec(rec);
					} else {
						log_error(278, "AINSERT missing FRONT/BACK" + bal_parms); // RPI-1053
					}
				}
				return;
			}
		}
		log_error(268,"AINSERT syntax error - " + bal_parms);
	}

	/**
	 * Add record to front or back of ainsert queue for copy insert at front in seq.
	 *
	 * @param rec
	 */
	private void add_ainsert_queue_rec(final String rec)
	{
		if (   tz390.opt_tracem    // RPI-1135
			|| tz390.opt_tracei) { // RPI-1159
			if (!tz390.opt_tracem) {
				trace_id = tz390.left_justify(mac_name[mac_call_name_index[mac_call_level]],9) + tz390.right_justify("" + mac_file_line_num[mac_line_index],6) + "        ";
			} else {
				trace_id = "";
			}
			tz390.put_trace(trace_id + "AINSERT PUSH=" + rec);
		}
		if (ainsert_back) {
			ainsert_queue.add(rec);
		} else {
			if (ainsert_copy) { // RPI-1053
				ainsert_queue.add(ainsert_copy_index,rec);
				ainsert_copy_index++;
			} else {
				ainsert_queue.addFirst(rec);
			}
		}
		cur_ainsert++;
	}

	/**
	 * Insert AINSERT logical record in front of current source line at mac_line index.
	 */
	private void insert_source_line()
	{
		get_ainsert_source_line(); // RPI-1136
		if (tz390.opt_tracem) { // RPI-1053
			tz390.put_trace("AINSERT POP =" + mac_line); // RPI-1135
		}
		while (cur_ainsert > 0
				&& mac_line.length() > 1
				&& mac_line.substring(0,2).equals(".*")) {
			get_ainsert_source_line(); // RPI-1136
			if (tz390.opt_tracem) { // RPI-1053
				tz390.put_trace("AINSERT POP =" + mac_line); // RPI-1135
			}
		}
		if (   mac_line.length() > 1
			&& mac_line.substring(0,2).equals(".*")) {
			return;
		}
		set_insert_mac_line_index();  // RPI-1019
		mac_file_line[mac_line_index] = mac_line;
	}

	/**
	 * Return mac_line with source line from AINSERT queue which may have continuations.
	 */
	private void get_ainsert_source_line()
	{
		String temp_line = ainsert_queue.pop();
		cur_ainsert--;
		tot_ainsert++;
		if (cur_mac_file < 0) {
			cur_mac_file = 0; // RPI-1053
		}
		if (   temp_line.length() <= mac_ictl_end[cur_mac_file]   // RPI-437 RPI-728 no cont col
			|| temp_line.charAt(mac_ictl_end[cur_mac_file]) <= asc_space_char // RPI-728 test cont col
			) { // RPI-181
			mac_line = tz390.trim_trailing_spaces(temp_line,mac_ictl_end[cur_mac_file]);  // RPI-124  RPI-728 exclude cont col
		} else {
			mac_line = tz390.trim_continue(temp_line.substring(0,mac_ictl_end[cur_mac_file]),tz390.split_first,mac_ictl_end[cur_mac_file],mac_ictl_cont[cur_mac_file]); // first line RPI-728 remove cont char
			boolean mac_cont_line = true;
			while (mac_cont_line && cur_ainsert > 0) { // RPI-181 // RPI-215
				temp_line = ainsert_queue.pop();
				cur_ainsert--;
				temp_line = tz390.trim_trailing_spaces(temp_line,72);
				if (   temp_line.length() < 72
					|| temp_line.charAt(71) <= asc_space_char) { // RPI-181
					mac_cont_line = false;
					mac_line = mac_line + tz390.trim_trailing_spaces(temp_line.substring(15),72); // RPI-124
					return;
				}
				if (   temp_line.length() >= mac_ictl_start[cur_mac_file] + mac_ictl_cont[cur_mac_file] - 1 // RPI-728
					&& temp_line.substring(mac_ictl_start[cur_mac_file]-1,mac_ictl_cont[cur_mac_file]-1).trim().equals("")  // RPI-728 check all spaces on preceeding cont
					) { // RPI-167
					mac_line = mac_line + tz390.trim_continue(temp_line,tz390.split_cont,mac_ictl_end[cur_mac_file],mac_ictl_cont[cur_mac_file]); // RPI-315, RPI-463 RPI-728
				} else if (temp_line.length() != 0               // RPI-492 blank line
						   && (mac_line.charAt(0) != '*'
						   || temp_line.charAt(0) != '*')) { // RPI-740 allow comment char for continued comm
					log_error(271,"AINSERT continuation line < " + mac_ictl_cont[cur_mac_file] + " characters - " + temp_line);
					mac_cont_line = false;
				}
			}
		}
	}

	/**
	 * Set mac_line_index to next insert for AINSERT or dynamic COPY else abort.
	 */
	private void set_insert_mac_line_index()
	{
		last_ainsert--;
		if (tot_mac_line >= last_ainsert) {
			abort_error(270, "Maximum source lines MAXLINE exceeded");
			return;
		}
		mac_file_prev_line[last_ainsert] = mac_file_prev_line[mac_line_index];
		mac_file_next_line[mac_file_prev_line[mac_line_index]] = last_ainsert;
		mac_file_prev_line[mac_line_index] = last_ainsert;
		mac_file_next_line[last_ainsert] = mac_line_index;
		mac_line_index = last_ainsert;
	}

	/**
	 * If NOALLOW verify function has quoted string as first argument.
	 *
	 * @param tot_setc_args
	 */
	private void check_setc_quotes(int tot_setc_args)
	{
		if (exec_pc_op || tz390.opt_allow) { // RPI-1139
			return;
		}
		while (tot_setc_args > 0) {
			if (   tot_exp_stk_var >= tot_setc_args
				&& exp_stk_var_name_index[tot_exp_stk_var - tot_setc_args] != -1) {
				log_error(283, "Function character argument missing quotes"); // RPI-1139
			}
			exp_string_var--; // RPI-1139
			tot_setc_args--;
		}
	}

	/**
	 * Return numberic array dimension > 0 else issue error and return 1.
	 *
	 * @param text
	 * @param start
	 * @return
	 */
	private int calc_dimension(final String text, final int start)
	{
		int dim = 0;
		int index = start;
		while (    text.charAt(index) >= '0'
				&& text.charAt(index) <= '9') {
			dim = dim * 10 + (text.charAt(index) & 0xf);
			index++;
		}
		if (dim <= 0 || text.charAt(index) != ')') {
			log_error(285, "Invalid dimension " + text.substring(start));
			dim = 1;
		}
		exp_next_index = index+1; // RPI-1139 skip )
		return dim;
	}
}
