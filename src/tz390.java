import java.awt.GraphicsEnvironment;
import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.RandomAccessFile;
import java.lang.management.ManagementFactory;
import java.lang.management.MemoryPoolMXBean;
import java.lang.reflect.Array;
import java.math.BigDecimal;
import java.nio.ByteBuffer;
import java.nio.charset.Charset;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.Arrays;
import java.util.Date;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
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
 * tz390 is the shared table component of z390.<br>
 * Shared z390 tables.
 */
public class tz390
{
	// shared version id 

	// dsh - Change version for every release and ptf.
	// dsh - Change dcb_id_ver for dcb field changes.
	final String version    = "V1.5.07";  // dsh
	final String dcb_id_ver = "DCBV1001"; // dsh
	final byte   acb_id_ver = (byte)0xa0; // ACB vs DCB id RPI 644 

	final InfoOS infoOS = InfoOS.getInstance();
	
	// Global options 
	String  z390_font    = "Monospaced";  // RPI 509 was Courier
	boolean timeout = false; // RPI 1094
	boolean z390_abort   = false; // global abort request
	boolean tz390_recursive_abort = false; // RPI 935
	String  invalid_options = "";  // RPI 742
	boolean opt_align    = true;  // align data fields by type if not explicit RPI 1073
	boolean opt_allow    = false; // allow extensions such as no quotes for SETC var
	boolean opt_amode24  = false; // link to run amode24
	boolean opt_amode31  = true;  // link to run amode31
	boolean opt_ascii    = false; // use ASCII vs EBCDIC
	/**
	 * Run az390 assembler as mz390 subtask - RPI 415
	 */
	boolean opt_asm      = true;  
	boolean opt_assist   = false; // enable assembly and emulation of ASSIST instructions
	boolean opt_autolink = true;  // search SYSOBJ for missing externals
	/**
	 * Generate BAL source output from mz390 - RPI 415
	 */
	boolean opt_bal      = false;
	boolean opt_bs2000   = false; // Siemens BS2000 asm compatibility
	boolean opt_cics     = false; // exec cics program honoring prolog, epilog
	boolean opt_codepage = false; // use ascii and ebcdic codepages specified CODEPAG(ascii,ebcdic,LIST)
	boolean opt_comment  = true;  // generate source comments for zCobol RPI 986
	boolean opt_con      = true;  // log msgs to console
	boolean force_nocon  = false; // override option con RPI 755
	boolean opt_dump     = false; // only indicative dump on abend unless on
	boolean opt_edf      = true;  // option for zCICS RPI 1027 renamed EDF RPI 1123
	boolean opt_epilog   = true;  // if CICS, insert DFHEIRET
	boolean opt_errsum   = false; // just list critical errors and summary on ERR file and console 
	boolean opt_extend   = true;  // allow up to 31 digits for P and Z in zCobol RPI 986
	boolean opt_guam     = false; // use gz390 GUAM GUI access method interface
	boolean opt_init     = true;  // init regs to x'F4", mem to x'F5'
	String  codepage     = "CODEPAGE(ISO-8859-1+IBM1047)";  // default z/OS compatible
	String  opt_float    = "DECIMAL"; // zCobol FLOAT-? type D=DFP,B=BFP,H=HFP

	String  opt_ipl      = "";    // program to execute at startup
	String  opt_install_loc = ""; // optional install location for source debugging
	boolean opt_list     = true;  // generate LOG file
	boolean opt_listcall = true;  // list macro calls
	boolean opt_listuse  = true;  // list usage at USING and DROP
	boolean opt_loadhigh = true;  // load pgms and alloc storage from top down
	boolean opt_mcall    = false; // list MCALL and MEXIT on PRN // RPI 511
	boolean opt_mod      = false; // generate raw code output from lz390 with sfx .MOD
	boolean opt_obj      = true;  // generate binary MVS compatible OBJ file RPI 694
	boolean opt_objhex   = false; // generate ascii hex obj records (lz390 accepts bin or hex)
	String  opt_parm     = "";    // user parm string for ez390 (mapped to R1 > cvt_exec_parm)
	boolean opt_pc       = true;  // generate macro pseudo code
	boolean opt_pcopt    = true;  // optimize pc code for speed
	boolean opt_pdsmem8  = false; // check for copy/mac names > 8 // RPI 11
	boolean opt_printall = false; // force default PRINT GEN and ignore PRINT options RPI 1127
	String  opt_profile  = "";    // include PROFILE(COPYBOOK) as first MLC statement
	boolean opt_prolog   = true;  // if CICS, insert DFHEIBLK and DFHEIENT
	boolean opt_protect  = true;  // prevent PSA mods by user
	boolean opt_r64      = true;  // allow 64 bit register instructions RPI 986
	boolean opt_reformat = false; // reformat BAL statements 
	boolean opt_regs     = false; // show registers on trace
	boolean opt_rmode24  = true;  // link to load below line
	boolean opt_rmode31  = false; // link to load above line
	boolean opt_stats    = false; // show statistics on STA file
	String  opt_sysparm  = "";    // user parameter string for mz390  
	boolean opt_test     = false; // invoke interactive test cmds
	boolean opt_thread   = true;  // continuous PRN location counter RPI 1186
	boolean opt_time     = true;  // abend 422 if out of time TIME (sec)
	boolean opt_timing   = true;  // display current date, time, rate
	boolean opt_trace    = false; // trace pz390 instructions to LOG
	boolean opt_tracea   = false; // trace az390
	boolean opt_traceall = false; // trace all details
	boolean opt_tracec   = false; // trace copybooks for tracep // RPI 862
	boolean opt_traceg   = false; // trace memory FQE updates to LOG
	boolean opt_tracei   = false; // trace AINSERT RPI 1157
	boolean opt_tracel   = false; // trace lz390
	boolean opt_tracem   = false; // trace mz390
	boolean opt_tracep   = false; // trace pseudo code
	boolean opt_traceq   = false; // trace QSAM file I/O
	boolean opt_traces   = false; // trace MLC source and errors on console for mz390 // RPI 882    
	boolean opt_tracet   = false; // trace TCPIO and TGET/TPUT data I/O
	boolean opt_tracev   = false; // trace VSAM file I/O
	boolean opt_trap     = true;  // trap exceptions as 0C5
	boolean opt_trunc    = false; // zCobol TRUNC option default NOTRUNC RPI 986
	boolean opt_ts       = false; // time-stamp logs RPI 662
	boolean opt_vcb      = true;  // vsam cache operational
	boolean opt_warn     = true;  // issue zCobol warnings RPI 986
	boolean opt_xref     = true;  // cross reference symbols
	boolean opt_zstrmac  = true;  // allow ZSTRMAC extensions
	boolean max_cmd_queue_exceeded = false;  // RPI 731
	String  cmd_parms = ""; // all options from command
	int     cmd_parms_len = 34; // RPI 755
	int     max_cmd_parms_line = 78; // RPI 755
	String  test_ddname = "";
	char    z390_amode31 = 'T';
	char    z390_rmode31 = 'F';
	int opt_chkmac   = 0; // RPI 747 0-none,1-labels, 2-labels and src after MEND
	int opt_chksrc   = 1; // RPI 747 0-none,1-MLC only,2-all, 3-seq 73-80 and char past 80
	int opt_maxcall  = 50;
	int opt_maxdisplay = 80; // RPI 1118 max display line length for zCobol
	int opt_maxesd   = 1000;
	int opt_maxfile = 1000;     // RPI 707 max concurrent files open
	int opt_maxgbl  = 100000;   // RPI 284
	int opt_maxlcl  = 100000;   
	int opt_maxline = 200000;
	int opt_maxlog  = 1000000; // RPI 731
	int opt_maxparm = 10000;
	int opt_maxpass = 2;       // RPI 920 maximum az390 passes for nested symbol refs
	int opt_maxpc   = 50000;  // RPI 439 pseudo code working set
	int opt_maxque  = 1000;   // RPI 731 max CMD output queue
	int opt_maxrld  = 10000;
	int opt_maxsym  = 50000;
	int opt_mnote   = 0; // RPI 1142 (0 all, 1 az only, 2 mz only)

	// Global limits with option overrides
	int    max_mnote_warning = 4;   // mnote limit for warnings (rc=4 vs rc=16) RPI 415
	int    max_errors        = 100; // ERR(100) max errors before abort
	int    max_main_width  = 800;
	int    max_main_height = 600;
	int    min_main_width  = 150;
	int    min_main_height = 150;
	int    max_line_len = 80;           // RPI 264
	long   max_file_size = 50 << 20;    // max file output 
	int    max_rba_size = 0x7fffffff;   // max vsam RBA vs XRBA RPI 706
	long   max_time_seconds  = 15;      // TIME(15)max elapsed time - override time(sec)
	int    monitor_wait = 300;          // fix interval in milliseconds
	int    max_mem           = 1;       // MEM(1)  MB memory default (see mem(mb) override)
	String trace_options = "";

	// shared date and time formats
	SimpleDateFormat sdf_MMddyy = new SimpleDateFormat("MM/dd/yy");
	SimpleDateFormat sdf_HHmmss = new SimpleDateFormat("HH:mm:ss");

	// Shared pgm dir, name, type and associated dirs
	String pgm_name = null; // from first parm else abort
	String pgm_type = null; // from first parm override if mlc else def.
	String file_dir;        // dir for _name RPI 700
	String file_type;       // type for find_file_name
	String ada_type = ".ADA"; // ADATA type (not supported yet)
	String bal_type = ".BAL"; // basic assembler output from mz390, input to az390
	String cpy_type = ".CPY"; // copybook source for mz390
	String dat_type = ".DAT"; // AREAD default input for mz390
	String err_type = ".ERR"; // step error and rc log
	String log_type = ".LOG"; // log for z390, ez390, sz390, pz390
	String lkd_type = ".LKD"; // linker commands INCLUDE, ENTRY, ALIAS, NAME RPI 735
	String lst_type = ".LST"; // linker list file
	Boolean lkd_ignore = false; // RPI 735 ignore LKD if explicit .OBJ
	String mac_type = ".MAC"; // macro source
	String mlc_type = ".MLC"; // macro assembler source program
	String mod_type = ".MOD"; // load module file with no header, trailer,RLDs, and no rounding RPI 883
	String obj_type = ".OBJ"; // relocatable object code for az390 and lz390
	String opt_type = ".OPT"; // @file option file with one option per line plus comments 
	String pch_type = ".PCH"; // punch output from mz390
	String prn_type = ".PRN"; // assembly listing for az390
	String sta_type = ".STA"; // statistics mod file for option stats(filename) RPI 737
	String tra_type = ".TRA"; // az390 trace file
	String tre_type = ".TRE"; // ez390 trace file
	String trl_type = ".TRL"; // lz390 trace file
	String trm_type = ".TRM"; // mz390 trace file
	String z390_type = ".390"; // z390 executable load module for lz390 and ez390
	String dir_390 = null; // SYS390() load module
	String dir_bal = null; // SYSBAL() az390 source input
	String dir_cpy = null; // SYSCPY() mz390 copybook lib defaults to dir_mac RPI 742
	String dir_cur = null; // default current dir
	String dir_dat = null; // SYSDAT() mz390 AREAD extended option
	String dir_err = null; // SYSERR() ?z390 systerm error file directory
	String dir_log = null; // SYSLOG() ez390 log // RPI 243
	String dir_lst = null; // SYSLST() lz390 listing 
	String dir_mac = null; // SYSMAC() mz390 macro lib
	String dir_mlc = null; // SYSMLC() mz390 source input
	String dir_pch = null; // SYSPCH() mz390 punch output dir
	String dir_pgm = null; // from first parm else dir_cur
	String dir_prn = null; // SYSPRN() az390 listing
	String dir_obj = null; // SYSOBJ() lz390 object lib
	String dir_opt = null; // SYSOPT() OPT options @file path defaults to dir_mac RPI 742
	String dir_trc = null; // SYSTRC() trace file directory
	int max_opsyn = 1000; 
	int tot_opsyn = 0;
	int opsyn_index = -1;
	String[]  opsyn_new_name = new String[max_opsyn];
	String[]  opsyn_old_name = new String[max_opsyn];
	int cur_bal_line_num    = 0; // bal starting line number
	int prev_bal_cont_lines = 0; // bal continue lines for prev bal
	int bal_ictl_start =  1; // RPI 728 reformated to std by mz390
	int bal_ictl_end   = 71; // RPI 728
	int bal_ictl_cont  = 16; // RPI 728
	int bal_ictl_cont_tot = 56; // RPI 728

	// Shared SYSTERM error file
	long   systerm_start = 0; // start time
	String systerm_sec   = ""; // systerm elapsed seconds
	String systerm_file_name      = null;
	RandomAccessFile systerm_file = null;
	String systerm_prefix = "";   // pgm_name plus space
	int    systerm_io     = 0;    // total file io count
	long systerm_ins    = 0;    // ez390 instruction count
	String started_msg = "";
	String ended_msg   = "";
	String stats_file_name      = null;
	RandomAccessFile stats_file = null;

	// Log, trace file used by mz390, az390, lz390, ez390
	String         log_file_name = ""; // RPI 755
	String         trace_file_name = null;
	File           trace_file = null;
	BufferedWriter trace_file_buff = null;
	int tot_log_msg  = 0; // RPI 731
	int tot_log_text = 0; // RPI 731
	boolean log_text_added = false; // RPI 731

	/*
	 * timestamp data for TS optional trace time stamps
	 * The first 23 characters are standard ODBC SQL Timestamp to start of previous micro-second.
	 * The last 6 digits are the nanoseconds from last micro-second to current time.
	 */
	long   ts_nano_start = 0; // RPI 662 nanotime at startup
	long   ts_nano_now = 0;   // RPI 662 nanotime now
	long   ts_mic_start = 0;  // RPI 662 cur time in mics at startup
	long   ts_mic_dif   = 0;  // RPI 662 mics from startup to now
	long   ts_mic_now   = 0;  // RPI 662 cur time in mics   
	String ts_nano_digits;    // RPI 662 last 6 digit nanos within mic

	// Shared parameter parsing for comma delimited continue
	// statement parsing to find comma used by both mz390 and az390.
	Pattern find_non_space_pattern = null;
	Pattern find_bslash   = null; // RPI 1080
	Matcher match_bslash  = null; // RPI 1080
	Pattern find_slash    = null; // RPI 1080
	Matcher match_slash   = null; // RPI 1080
	Pattern find_dash     = null; // RPI 1080
	Matcher match_dash    = null; // RPI 1080
	Pattern find_squote   = null; // RPI 1080
	Matcher match_squote  = null; // RPI 1080
	Pattern find_dsquote  = null; // RPI 1080
	Matcher match_dsquote = null; // RPI 1080
	Pattern find_dquote   = null; // RPI 1080
	Matcher match_dquote  = null; // RPI 1080
	Pattern find_ddquote  = null; // RPI 1080
	Matcher match_ddquote = null; // RPI 1080
	Pattern find_amp      = null; // RPI 1080
	Matcher match_amp     = null; // RPI 1080
	Pattern find_damp     = null; // RPI 1080
	Matcher match_damp    = null; // RPI 1080
	Matcher find_parm_match = null; // RPI 1080
	Pattern parm_pattern = null;
	Matcher parm_match = null;
	boolean split_first = true; // first line of statement
	boolean split_cont  = false; // continuation line of statement
	boolean split_comment = false;
	boolean exec_line = false; // RPI 905
	String  split_label = null;
	String  split_op    = null;
	int     split_op_index = -1; // opcode index else -1
	int     split_op_type  = -1; // opcode type index else -1
	String  split_parms = null;
	int     split_parms_index = -1;  // line index to parms else -1
	int     split_level = 0;
	String  split_quote_text = null;
	boolean split_quote = false;
	boolean split_quote_last = false; // last char of prev continue is quote RPI 463

	// pad_spaces char table for padding starts at 4096 and expands as required
	int    pad_spaces_len = 0;
	char[] pad_spaces = null;

	// dup operator buffer
	int dup_char_len = 0;
	char[] dup_char = null; 

	// ASCII and EBCDIC printable character tables
	String ascii_min_char =		// RPI 1069
			  " 01234567890"	// blank and digits
			+ "ABCDEFGHIJKLMNOPQRSTUVWXYZ" // upper case
			+ "abcdefghijklmnopqrstuvwxyz" // lower case
			+ "@#$"				// additional leading symbol characters
			+ "&’()*+-./:=_";	// minimum ASCII special char

	String newline = System.getProperty("line.separator"); // RPI 500
	char   alarm_bell = 0x07; // ASCII bell char for system.out alarm
	int    sdt_char_int = 0; // RPI 192 shared character sdt
	String ascii_table = 
		"................" + //00
		"................" + //10
		" !" + '"' + "#$%&'()*+,-./" + //20 with "
		"0123456789:;<=>?" + //30
		"@ABCDEFGHIJKLMNO" + //40
		"PQRSTUVWXYZ[\\]^_" + //50
		"`abcdefghijklmno" + //60
		"pqrstuvwxyz{|}~." + //70
		"................" + //80
		"................" + //90
		"................" + //A0
		"................" + //B0
		"................" + //C0
		"................" + //D0
		"................" + //E0
		"................";  //F0
	String ebcdic_table =
		"................" + //00
		"................" + //10
		"................" + //20
		"................" + //30
		" ...........<(+|" + //40
		"&.........!$*);." + //50
		"-/.........,%_>?" + //60
		".........`:#@'=" + '"' + //70 with "
		".abcdefghi......" + //80
		".jklmnopqr......" + //90
		".~stuvwxyz......" + //A0
		"^.........[]...." + //B0
		"{ABCDEFGHI......" + //C0
		"}JKLMNOPQR......" + //D0
		"\\.STUVWXYZ......" + //E0 with \
		"0123456789......";   //F0
	byte[] ascii_to_ebcdic = new byte[256];
	String ascii_to_ebcdic_hex = 
		"00010203372D2E2F1605250B0C0D0E0F" + //00 ................
		"101112003C3D322618193F2722003500" + //10 ................
		"405A7F7B5B6C507D4D5D5C4E6B604B61" + //20  !"#$%&'()*+,-./
		"F0F1F2F3F4F5F6F7F8F97A5E4C7E6E6F" + //30 0123456789:;<=>?
		"7CC1C2C3C4C5C6C7C8C9D1D2D3D4D5D6" + //40 @ABCDEFGHIJKLMNO
		"D7D8D9E2E3E4E5E6E7E8E9ADE0BD5F6D" + //50 PQRSTUVWXYZ.\.._
		"79818283848586878889919293949596" + //60 `abcdefghijklmno
		"979899A2A3A4A5A6A7A8A98B4F9BA107" + //70 pqrstuvwxyz.|.~.
		"00010203372D2E2F1605250B0C0D0E0F" + //80 ................
		"101112003C3D322618193F2722003500" + //90 ................
		"405A7F7B5B6C507D4D5D5C4E6B604B61" + //A0  !"#$%&'()*+,-./
		"F0F1F2F3F4F5F6F7F8F97A5E4C7E6E6F" + //B0 0123456789:;<=>?
		"7CC1C2C3C4C5C6C7C8C9D1D2D3D4D5D6" + //C0 @ABCDEFGHIJKLMNO
		"D7D8D9E2E3E4E5E6E7E8E9ADE0BD5F6D" + //D0 PQRSTUVWXYZ.\.._
		"79818283848586878889919293949596" + //E0 `abcdefghijklmno
		"979899A2A3A4A5A6A7A8A98B4F9BA107";  //F0 pqrstuvwxyz.|.~.

	byte[] ebcdic_to_ascii = new byte[256];
	String ebcdic_to_ascii_hex = 
		"000102030009007F0000000B0C0D0E0F" + //00 ................
		"10111200000008001819000000000000" + //10 ................
		"00001C00000A171B0000000000050607" + //20 ................
		"00001600001E0004000000001415001A" + //30 ................
		"20000000000000000000002E3C282B7C" + //40  ...........<(+|
		"2600000000000000000021242A293B5E" + //50 &.........!$*);^
		"2D2F0000000000000000002C255F3E3F" + //60 -/.........,%_>?
		"000000000000000000603A2340273D22" + //70 .........`:#@'="
		"00616263646566676869007B00000000" + //80 .abcdefghi.{....
		"006A6B6C6D6E6F707172007D00000000" + //90 .jklmnopqr.}....
		"007E737475767778797A0000005B0000" + //A0 .~stuvwxyz...[..
		"000000000000000000000000005D0000" + //B0 .............]..
		"00414243444546474849000000000000" + //C0 .ABCDEFGHI......
		"004A4B4C4D4E4F505152000000000000" + //D0 .JKLMNOPQR......
		"5C00535455565758595A000000000000" + //E0 \.STUVWXYZ......
		"30313233343536373839000000000000";  //F0 0123456789......

	// CODEPAGE(ascii,ebcdic,LIST) option data 
	final String default_charset_name = Charset.defaultCharset().name();
	String ascii_charset_name = "";
	String ebcdic_charset_name = "";
	boolean list_charset_map = false;
	String test_ascii;
	String test_ebcdic;
	char   test_char;
	byte[] init_charset_bytes = new byte[256];

	// Floating Point shared types and attributes for use by az390 for constants and pz390 instructions.

	// fp conversion from big decimal to LH/LB variables copied from AZ390 routine 
	// developed earlier to convert string to floating point constants (moved for RPI 407
	byte fp_type    = 0;
	byte fp_db_type = 0; // BFP long - double
	byte fp_dd_type = 1; // DFP long - big dec
	byte fp_dh_type = 2; // HFP long - big dec
	byte fp_eb_type = 3; // BFP short - float
	byte fp_ed_type = 4; // DFP short - big dec
	byte fp_eh_type = 5; // HFP short - double
	byte fp_lb_type = 6; // BFP extended - big dec
	byte fp_ld_type = 7; // DFP extended - big dec
	byte fp_lh_type = 8; // HFP extended - big dec
	byte fp_lq_type = 9; // LQ quad word
	byte fp_db_digits = 15;
	byte fp_dd_digits = 16;
	byte fp_dh_digits = 15;
	byte fp_eb_digits =  7;
	byte fp_ed_digits =  7;
	byte fp_eh_digits =  7;   // RPI 821
	byte fp_lb_digits = 34;
	byte fp_ld_digits = 34;
	byte fp_lh_digits = 32; // RPI 821
	byte fp_guard_digits = 4; // RPI 1124

	// follow fp_work_reg used to format edl types to binary storage formats
	byte[]     fp_work_reg_byte = (byte[])Array.newInstance(byte.class,17); // 1 extra guard byte ignored
	ByteBuffer fp_work_reg = ByteBuffer.wrap(fp_work_reg_byte,0,17);
	/*
	 * Note:  The following big decimal precision array used in both az390 and ez390
	 *        should be maintained consistently as it is used for rounding 
	 *        during conversions between types.
	 */
	final int[]  fp_precision = {
			fp_db_digits+fp_guard_digits,
			fp_dd_digits,  // RPI 790 
			fp_dh_digits+fp_guard_digits,
			fp_eb_digits+fp_guard_digits,
			fp_ed_digits,  // RPI 790 
			fp_eh_digits+fp_guard_digits,
			fp_lb_digits+fp_guard_digits,
			fp_ld_digits,  // RPI 790 
			fp_lh_digits+fp_guard_digits,
			fp_lh_digits+fp_guard_digits  // rpi 1108 lq 
		};
	final int[]  fp_digits_max  = {0,16,0,0,7,0,0,34,0,0};
	final int[]  fp_sign_bit    = {0x800,0x20,0x80,0x100,0x20,0x80,0x8000,0x20,0x80,0X80}; // RPI 407
	final int[]  fp_one_bit_adj = {2,-1,2,2,-1,1,2,-1,1,1}; // RPI 407 RPI 821 from 1 to 2 
	final int[]  fp_exp_bias    = {0x3ff,398,0x40,0x7f,101,0x40,0x3fff,6176,0x40,0X40}; // RPI 407
	final int[]  fp_exp_max     = {0x7ff,0x3ff,0x7f,0xff,0xff,0x7f,0x7fff,0x3fff,0x7f,0X7F}; // RPI 407
	final int[]  fp_man_bits    = {52,-1,56,23,-1,24,112,-1,112,112}; 

	// DFP Decimal Floating Point shared tables
	int fp_sign = 0;
	int fp_exp   = 0; // scale * log10/log2
	String dfp_digits = null;
	int    dfp_dec_index = 0;  // RPI 786
	int    dfp_exp_index = 0;  // RPI 786
	int    dfp_exp = 0;        // RPI 786
	int    dfp_scf = 0;        // RPI 786
	int    dfp_preferred_exp = -2; // RPI 786
	byte[] dfp_work = new byte[16];
	// dfp_exp_bcd_to_cf5 returns CF5 5 bit combination field using index made up of 
	// high 2 bits of bias exponent plus 4 bit BCDnibble for first digit. 
	final byte[] dfp_exp_bcd_to_cf5 = { // RPI 407 indexed by high 2 bits of exp + first digit
			0x00,0x01,0x02,0x03,0x04,0x05,0x06,0x07,0x08,0x09,0,0,0,0,0,0, //0d
			0x08,0x09,0x0A,0x0B,0x0C,0x0D,0x0E,0x0F,0x1A,0x1B,0,0,0,0,0,0, //1d
			0x10,0x11,0x12,0x13,0x14,0x15,0x16,0x17,0x1C,0x1D,0,0,0,0,0,0, //2d
		};
	/*
	 * dfp_bcd_to_dpd returns 10 bit densely packed decimal indexed by 3 digit value 0-999
	 */
	final int[] dfp_bcd_to_dpd = {
			0x000,0x001,0x002,0x003,0x004,0x005,0x006,0x007,0x008,0x009,
			0x010,0x011,0x012,0x013,0x014,0x015,0x016,0x017,0x018,0x019,
			0x020,0x021,0x022,0x023,0x024,0x025,0x026,0x027,0x028,0x029,
			0x030,0x031,0x032,0x033,0x034,0x035,0x036,0x037,0x038,0x039,
			0x040,0x041,0x042,0x043,0x044,0x045,0x046,0x047,0x048,0x049,
			0x050,0x051,0x052,0x053,0x054,0x055,0x056,0x057,0x058,0x059,
			0x060,0x061,0x062,0x063,0x064,0x065,0x066,0x067,0x068,0x069,
			0x070,0x071,0x072,0x073,0x074,0x075,0x076,0x077,0x078,0x079,
			0x00A,0x00B,0x02A,0x02B,0x04A,0x04B,0x06A,0x06B,0x04E,0x04F,
			0x01A,0x01B,0x03A,0x03B,0x05A,0x05B,0x07A,0x07B,0x05E,0x05F,
			0x080,0x081,0x082,0x083,0x084,0x085,0x086,0x087,0x088,0x089,
			0x090,0x091,0x092,0x093,0x094,0x095,0x096,0x097,0x098,0x099,
			0x0A0,0x0A1,0x0A2,0x0A3,0x0A4,0x0A5,0x0A6,0x0A7,0x0A8,0x0A9,
			0x0B0,0x0B1,0x0B2,0x0B3,0x0B4,0x0B5,0x0B6,0x0B7,0x0B8,0x0B9,
			0x0C0,0x0C1,0x0C2,0x0C3,0x0C4,0x0C5,0x0C6,0x0C7,0x0C8,0x0C9,
			0x0D0,0x0D1,0x0D2,0x0D3,0x0D4,0x0D5,0x0D6,0x0D7,0x0D8,0x0D9,
			0x0E0,0x0E1,0x0E2,0x0E3,0x0E4,0x0E5,0x0E6,0x0E7,0x0E8,0x0E9,
			0x0F0,0x0F1,0x0F2,0x0F3,0x0F4,0x0F5,0x0F6,0x0F7,0x0F8,0x0F9,
			0x08A,0x08B,0x0AA,0x0AB,0x0CA,0x0CB,0x0EA,0x0EB,0x0CE,0x0CF,
			0x09A,0x09B,0x0BA,0x0BB,0x0DA,0x0DB,0x0FA,0x0FB,0x0DE,0x0DF,
			0x100,0x101,0x102,0x103,0x104,0x105,0x106,0x107,0x108,0x109,
			0x110,0x111,0x112,0x113,0x114,0x115,0x116,0x117,0x118,0x119,
			0x120,0x121,0x122,0x123,0x124,0x125,0x126,0x127,0x128,0x129,
			0x130,0x131,0x132,0x133,0x134,0x135,0x136,0x137,0x138,0x139,
			0x140,0x141,0x142,0x143,0x144,0x145,0x146,0x147,0x148,0x149,
			0x150,0x151,0x152,0x153,0x154,0x155,0x156,0x157,0x158,0x159,
			0x160,0x161,0x162,0x163,0x164,0x165,0x166,0x167,0x168,0x169,
			0x170,0x171,0x172,0x173,0x174,0x175,0x176,0x177,0x178,0x179,
			0x10A,0x10B,0x12A,0x12B,0x14A,0x14B,0x16A,0x16B,0x14E,0x14F,
			0x11A,0x11B,0x13A,0x13B,0x15A,0x15B,0x17A,0x17B,0x15E,0x15F,
			0x180,0x181,0x182,0x183,0x184,0x185,0x186,0x187,0x188,0x189,
			0x190,0x191,0x192,0x193,0x194,0x195,0x196,0x197,0x198,0x199,
			0x1A0,0x1A1,0x1A2,0x1A3,0x1A4,0x1A5,0x1A6,0x1A7,0x1A8,0x1A9,
			0x1B0,0x1B1,0x1B2,0x1B3,0x1B4,0x1B5,0x1B6,0x1B7,0x1B8,0x1B9,
			0x1C0,0x1C1,0x1C2,0x1C3,0x1C4,0x1C5,0x1C6,0x1C7,0x1C8,0x1C9,
			0x1D0,0x1D1,0x1D2,0x1D3,0x1D4,0x1D5,0x1D6,0x1D7,0x1D8,0x1D9,
			0x1E0,0x1E1,0x1E2,0x1E3,0x1E4,0x1E5,0x1E6,0x1E7,0x1E8,0x1E9,
			0x1F0,0x1F1,0x1F2,0x1F3,0x1F4,0x1F5,0x1F6,0x1F7,0x1F8,0x1F9,
			0x18A,0x18B,0x1AA,0x1AB,0x1CA,0x1CB,0x1EA,0x1EB,0x1CE,0x1CF,
			0x19A,0x19B,0x1BA,0x1BB,0x1DA,0x1DB,0x1FA,0x1FB,0x1DE,0x1DF,
			0x200,0x201,0x202,0x203,0x204,0x205,0x206,0x207,0x208,0x209,
			0x210,0x211,0x212,0x213,0x214,0x215,0x216,0x217,0x218,0x219,
			0x220,0x221,0x222,0x223,0x224,0x225,0x226,0x227,0x228,0x229,
			0x230,0x231,0x232,0x233,0x234,0x235,0x236,0x237,0x238,0x239,
			0x240,0x241,0x242,0x243,0x244,0x245,0x246,0x247,0x248,0x249,
			0x250,0x251,0x252,0x253,0x254,0x255,0x256,0x257,0x258,0x259,
			0x260,0x261,0x262,0x263,0x264,0x265,0x266,0x267,0x268,0x269,
			0x270,0x271,0x272,0x273,0x274,0x275,0x276,0x277,0x278,0x279,
			0x20A,0x20B,0x22A,0x22B,0x24A,0x24B,0x26A,0x26B,0x24E,0x24F,
			0x21A,0x21B,0x23A,0x23B,0x25A,0x25B,0x27A,0x27B,0x25E,0x25F,
			0x280,0x281,0x282,0x283,0x284,0x285,0x286,0x287,0x288,0x289,
			0x290,0x291,0x292,0x293,0x294,0x295,0x296,0x297,0x298,0x299,
			0x2A0,0x2A1,0x2A2,0x2A3,0x2A4,0x2A5,0x2A6,0x2A7,0x2A8,0x2A9,
			0x2B0,0x2B1,0x2B2,0x2B3,0x2B4,0x2B5,0x2B6,0x2B7,0x2B8,0x2B9,
			0x2C0,0x2C1,0x2C2,0x2C3,0x2C4,0x2C5,0x2C6,0x2C7,0x2C8,0x2C9,
			0x2D0,0x2D1,0x2D2,0x2D3,0x2D4,0x2D5,0x2D6,0x2D7,0x2D8,0x2D9,
			0x2E0,0x2E1,0x2E2,0x2E3,0x2E4,0x2E5,0x2E6,0x2E7,0x2E8,0x2E9,
			0x2F0,0x2F1,0x2F2,0x2F3,0x2F4,0x2F5,0x2F6,0x2F7,0x2F8,0x2F9,
			0x28A,0x28B,0x2AA,0x2AB,0x2CA,0x2CB,0x2EA,0x2EB,0x2CE,0x2CF,
			0x29A,0x29B,0x2BA,0x2BB,0x2DA,0x2DB,0x2FA,0x2FB,0x2DE,0x2DF,
			0x300,0x301,0x302,0x303,0x304,0x305,0x306,0x307,0x308,0x309,
			0x310,0x311,0x312,0x313,0x314,0x315,0x316,0x317,0x318,0x319,
			0x320,0x321,0x322,0x323,0x324,0x325,0x326,0x327,0x328,0x329,
			0x330,0x331,0x332,0x333,0x334,0x335,0x336,0x337,0x338,0x339,
			0x340,0x341,0x342,0x343,0x344,0x345,0x346,0x347,0x348,0x349,
			0x350,0x351,0x352,0x353,0x354,0x355,0x356,0x357,0x358,0x359,
			0x360,0x361,0x362,0x363,0x364,0x365,0x366,0x367,0x368,0x369,
			0x370,0x371,0x372,0x373,0x374,0x375,0x376,0x377,0x378,0x379,
			0x30A,0x30B,0x32A,0x32B,0x34A,0x34B,0x36A,0x36B,0x34E,0x34F,
			0x31A,0x31B,0x33A,0x33B,0x35A,0x35B,0x37A,0x37B,0x35E,0x35F,
			0x380,0x381,0x382,0x383,0x384,0x385,0x386,0x387,0x388,0x389,
			0x390,0x391,0x392,0x393,0x394,0x395,0x396,0x397,0x398,0x399,
			0x3A0,0x3A1,0x3A2,0x3A3,0x3A4,0x3A5,0x3A6,0x3A7,0x3A8,0x3A9,
			0x3B0,0x3B1,0x3B2,0x3B3,0x3B4,0x3B5,0x3B6,0x3B7,0x3B8,0x3B9,
			0x3C0,0x3C1,0x3C2,0x3C3,0x3C4,0x3C5,0x3C6,0x3C7,0x3C8,0x3C9,
			0x3D0,0x3D1,0x3D2,0x3D3,0x3D4,0x3D5,0x3D6,0x3D7,0x3D8,0x3D9,
			0x3E0,0x3E1,0x3E2,0x3E3,0x3E4,0x3E5,0x3E6,0x3E7,0x3E8,0x3E9,
			0x3F0,0x3F1,0x3F2,0x3F3,0x3F4,0x3F5,0x3F6,0x3F7,0x3F8,0x3F9,
			0x38A,0x38B,0x3AA,0x3AB,0x3CA,0x3CB,0x3EA,0x3EB,0x3CE,0x3CF,
			0x39A,0x39B,0x3BA,0x3BB,0x3DA,0x3DB,0x3FA,0x3FB,0x3DE,0x3DF,
			0x00C,0x00D,0x10C,0x10D,0x20C,0x20D,0x30C,0x30D,0x02E,0x02F,
			0x01C,0x01D,0x11C,0x11D,0x21C,0x21D,0x31C,0x31D,0x03E,0x03F,
			0x02C,0x02D,0x12C,0x12D,0x22C,0x22D,0x32C,0x32D,0x12E,0x12F,
			0x03C,0x03D,0x13C,0x13D,0x23C,0x23D,0x33C,0x33D,0x13E,0x13F,
			0x04C,0x04D,0x14C,0x14D,0x24C,0x24D,0x34C,0x34D,0x22E,0x22F,
			0x05C,0x05D,0x15C,0x15D,0x25C,0x25D,0x35C,0x35D,0x23E,0x23F,
			0x06C,0x06D,0x16C,0x16D,0x26C,0x26D,0x36C,0x36D,0x32E,0x32F,
			0x07C,0x07D,0x17C,0x17D,0x27C,0x27D,0x37C,0x37D,0x33E,0x33F,
			0x00E,0x00F,0x10E,0x10F,0x20E,0x20F,0x30E,0x30F,0x06E,0x06F,
			0x01E,0x01F,0x11E,0x11F,0x21E,0x21F,0x31E,0x31F,0x07E,0x07F,
			0x08C,0x08D,0x18C,0x18D,0x28C,0x28D,0x38C,0x38D,0x0AE,0x0AF,
			0x09C,0x09D,0x19C,0x19D,0x29C,0x29D,0x39C,0x39D,0x0BE,0x0BF,
			0x0AC,0x0AD,0x1AC,0x1AD,0x2AC,0x2AD,0x3AC,0x3AD,0x1AE,0x1AF,
			0x0BC,0x0BD,0x1BC,0x1BD,0x2BC,0x2BD,0x3BC,0x3BD,0x1BE,0x1BF,
			0x0CC,0x0CD,0x1CC,0x1CD,0x2CC,0x2CD,0x3CC,0x3CD,0x2AE,0x2AF,
			0x0DC,0x0DD,0x1DC,0x1DD,0x2DC,0x2DD,0x3DC,0x3DD,0x2BE,0x2BF,
			0x0EC,0x0ED,0x1EC,0x1ED,0x2EC,0x2ED,0x3EC,0x3ED,0x3AE,0x3AF,
			0x0FC,0x0FD,0x1FC,0x1FD,0x2FC,0x2FD,0x3FC,0x3FD,0x3BE,0x3BF,
			0x08E,0x08F,0x18E,0x18F,0x28E,0x28F,0x38E,0x38F,0x0EE,0x0EF,
			0x09E,0x09F,0x19E,0x19F,0x29E,0x29F,0x39E,0x39F,0x0FE,0x0FF,
	};

	// dfp_cf5_to_exp2 returns 2 high bits of biased exponent indexed by 5 bit combined field
	final int[] dfp_cf5_to_exp2 = {
			0,0,0,0,0,0,0,0,  //  0- 7 = 0
			1,1,1,1,1,1,1,1,  //  8-15 = 1
			2,2,2,2,2,2,2,2,  // 16-23 = 2
			0,0,              // 24-25 = 0
			1,1,              // 26-27 = 1
			2,2,              // 28-29 = 2
			3,                // 30 infinity RPI 536
			4};               // 31 NaN      RPI 536
	/*
	 * dfp_cf5_to_bcd returns decimal digit 0-9 indexed by 5 bit combination field value
	 */
	final long[] dfp_cf5_to_bcd = { //cf5 value
			0,1,2,3,4,5,6,7,  //00-07
			0,1,2,3,4,5,6,7,  //08-0F
			0,1,2,3,4,5,6,7,  //10-17
			8,9,              //18-19
			8,9,              //1A-1B
			8,9               //1C-1D
	};
	/*
	 * dfp_dpd_to_bcd returns 3 digit decimal value 0-999 using 10 bit densely packed decimal index value.
	 * Notes:
	 *   1. Redundant values in (...)
	 *   2. Java interprets leading 08 as octal number like 0x is hex so any leading 0's should be removed,
	 */
	final long[] dfp_dpd_to_bcd = {
			  0,  1,  2,  3,  4,  5,  6,  7,  8,  9, 80, 81,800,801,880,881,    // 00
			 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 90, 91,810,811,890,891,    // 01
			 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 82, 83,820,821,808,809,    // 02
			 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 92, 93,830,831,818,819,    // 03
			 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 84, 85,840,841, 88, 89,    // 04
			 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 94, 95,850,851, 98, 99,    // 05
			 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 86, 87,860,861,888,889,    // 06
			 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 96, 97,870,871,898,899,    // 07
			100,101,102,103,104,105,106,107,108,109,180,181,900,901,980,981,    // 08
			110,111,112,113,114,115,116,117,118,119,190,191,910,911,990,991,    // 09
			120,121,122,123,124,125,126,127,128,129,182,183,920,921,908,909,    // 0A
			130,131,132,133,134,135,136,137,138,139,192,193,930,931,918,919,    // 0B
			140,141,142,143,144,145,146,147,148,149,184,185,940,941,188,189,    // 0C
			150,151,152,153,154,155,156,157,158,159,194,195,950,951,198,199,    // 0D
			160,161,162,163,164,165,166,167,168,169,186,187,960,961,988,989,    // 0E
			170,171,172,173,174,175,176,177,178,179,196,197,970,971,998,999,    // 0F
			200,201,202,203,204,205,206,207,208,209,280,281,802,803,882,883,    // 10
			210,211,212,213,214,215,216,217,218,219,290,291,812,813,892,893,    // 11
			220,221,222,223,224,225,226,227,228,229,282,283,822,823,828,829,    // 12
			230,231,232,233,234,235,236,237,238,239,292,293,832,833,838,839,    // 13
			240,241,242,243,244,245,246,247,248,249,284,285,842,843,288,289,    // 14
			250,251,252,253,254,255,256,257,258,259,294,295,852,853,298,299,    // 15
			260,261,262,263,264,265,266,267,268,269,286,287,862,863,(888),(889),// 16
			270,271,272,273,274,275,276,277,278,279,296,297,872,873,(898),(899),// 17
			300,301,302,303,304,305,306,307,308,309,380,381,902,903,982,983,    // 18
			310,311,312,313,314,315,316,317,318,319,390,391,912,913,992,993,    // 19
			320,321,322,323,324,325,326,327,328,329,382,383,922,923,928,929,    // 1A
			330,331,332,333,334,335,336,337,338,339,392,393,932,933,938,939,    // 1B
			340,341,342,343,344,345,346,347,348,349,384,385,942,943,388,389,    // 1C
			350,351,352,353,354,355,356,357,358,359,394,395,952,953,398,399,    // 1D
			360,361,362,363,364,365,366,367,368,369,386,387,962,963,(988),(989),// 1E
			370,371,372,373,374,375,376,377,378,379,396,397,972,973,(998),(999),// 1F
			400,401,402,403,404,405,406,407,408,409,480,481,804,805,884,885,    // 20
			410,411,412,413,414,415,416,417,418,419,490,491,814,815,894,895,    // 21
			420,421,422,423,424,425,426,427,428,429,482,483,824,825,848,849,    // 22
			430,431,432,433,434,435,436,437,438,439,492,493,834,835,858,859,    // 23
			440,441,442,443,444,445,446,447,448,449,484,485,844,845,488,489,    // 24
			450,451,452,453,454,455,456,457,458,459,494,495,854,855,498,499,    // 25
			460,461,462,463,464,465,466,467,468,469,486,487,864,865,(888),(889),// 26
			470,471,472,473,474,475,476,477,478,479,496,497,874,875,(898),(899),// 27
			500,501,502,503,504,505,506,507,508,509,580,581,904,905,984,985,    // 28
			510,511,512,513,514,515,516,517,518,519,590,591,914,915,994,995,    // 29
			520,521,522,523,524,525,526,527,528,529,582,583,924,925,948,949,    // 2A
			530,531,532,533,534,535,536,537,538,539,592,593,934,935,958,959,    // 2B
			540,541,542,543,544,545,546,547,548,549,584,585,944,945,588,589,    // 2C
			550,551,552,553,554,555,556,557,558,559,594,595,954,955,598,599,    // 2D
			560,561,562,563,564,565,566,567,568,569,586,587,964,965,(988),(989),// 2E
			570,571,572,573,574,575,576,577,578,579,596,597,974,975,(998),(999),// 2F
			600,601,602,603,604,605,606,607,608,609,680,681,806,807,886,887,    // 30
			610,611,612,613,614,615,616,617,618,619,690,691,816,817,896,897,    // 31
			620,621,622,623,624,625,626,627,628,629,682,683,826,827,868,869,    // 32
			630,631,632,633,634,635,636,637,638,639,692,693,836,837,878,879,    // 33
			640,641,642,643,644,645,646,647,648,649,684,685,846,847,688,689,    // 34
			650,651,652,653,654,655,656,657,658,659,694,695,856,857,698,699,    // 35
			660,661,662,663,664,665,666,667,668,669,686,687,866,867,(888),(889),// 36
			670,671,672,673,674,675,676,677,678,679,696,697,876,877,(898),(899),// 37
			700,701,702,703,704,705,706,707,708,709,780,781,906,907,986,987,    // 38
			710,711,712,713,714,715,716,717,718,719,790,791,916,917,996,997,    // 39
			720,721,722,723,724,725,726,727,728,729,782,783,926,927,968,969,    // 3A
			730,731,732,733,734,735,736,737,738,739,792,793,936,937,978,979,    // 3B
			740,741,742,743,744,745,746,747,748,749,784,785,946,947,788,789,    // 3C
			750,751,752,753,754,755,756,757,758,759,794,795,956,957,798,799,    // 3D
			760,761,762,763,764,765,766,767,768,769,786,787,966,967,(988),(989),// 3E
			770,771,772,773,774,775,776,777,778,779,796,797,976,977,(998),(999),// 3F
	};


	final int max_ins_type = 100; // RPI 315 
	final int max_asm_type = 200;
	final int max_mac_type = 300;

	//  When adding new opcode case: // RPI 407 type 35 for CSDTR etc
	//  1.  Increase the above max.
	//  2.  Change above op_type_len table which must match
	//  3.  Change az390 instruction format cases and
	//  4.  Change pz390 op_type_offset and op_type_mask if new primary opcode
	//  5.  Change pz390 trace_psw to add new case formats

	int op_code_index = -1;


	// key search table data
	int last_key_op = 0;
	int key_not_found = 1;
	int key_found = 2;
	int max_key_root = 4000;
	int max_key_tab = 50000;
	int tot_key_tab = max_key_root+1;
	int tot_key = 0;
	char   key_type = '?';
	String key_text = null;
	int key_index = 0;
	int key_index_last = 0;
	int key_hash = 0;
	int tot_key_search = 0;
	int tot_key_comp  = 0;
	int avg_key_comp  = 0;
	int cur_key_comp = 0;
	int max_key_comp = 0;
	char[]    key_tab_type  = (char[])Array.newInstance(char.class,max_key_tab);
	String[]  key_tab_key   = new String[max_key_tab];
	int[]     key_tab_hash  = (int[])Array.newInstance(int.class,max_key_tab);
	int[]     key_tab_index = (int[])Array.newInstance(int.class,max_key_tab);
	int[]     key_tab_low   = (int[])Array.newInstance(int.class,max_key_tab);
	int[]     key_tab_high  = (int[])Array.newInstance(int.class,max_key_tab);

	/**
	 * Initialize shared data and tables.
	 */
	public void init_tz390()
	{
		dir_cur = System.getProperty("user.dir") + File.separator; // RPI 499 drop upper case
		ts_nano_start = System.nanoTime();          // RPI 662
		ts_mic_start  = System.currentTimeMillis(); // RPI 662
		init_pat();      // Initialize patterns for matcher
		init_opcodes();  // Verify opcode tables
	}

	/**
	 * Initialize opcodes.
	 */
	private void init_opcodes()
	{
		if (OpNames.op_name.length != OpTypes.op_type.length){
			abort_error(1, "opcode tables out of sync - aborting");
		}

		int index = 0;
		int max_type = 0;
		int ins_count = 0;
		while (index < OpTypes.op_type.length) {
			if (OpTypes.op_type[index] < 100) {
				if (OpTypes.op_type[index] > max_type) {
					max_type = OpTypes.op_type[index];
				}
				ins_count++;
			}
			index++;
		}
		if (max_type != OpTypes.max_op_type_offset) {
			abort_error(2, "opcode max type out of sync - " + max_type + " vs " + OpTypes.max_op_type_offset);
		}
		if (ins_count != OpCodes.op_code.length) {
			abort_error(3, "opcode total out of sync - aborting");
		}
	}

	/**
	 * Initialize patterns for use by opcode and options routines.
	 */
	private void init_pat()
	{
		// Find_non_space_pattern tokens:
		// Skip while space and return next non-white space token
		try {
			find_non_space_pattern = Pattern.compile(
					  "([\"][^\"]+[\"])"
					+ "|([^\\s]+)"  //RPI 313
			);
		} catch (final Exception e){
			abort_error(13, "find parm pattern errror - " + e.toString());
		}

		// Replace \ with / for Linux
		try {
			find_bslash = Pattern.compile(
					  "[\\\\]"  //RPI 1080
			);
		} catch (final Exception e) {
			abort_error(13, "replace \\ parm pattern errror - " + e.toString());
		}

		// Replace / with \ for Windows
		try {
			find_slash = Pattern.compile(
					  "[/]"  //RPI 1080
			);
		} catch (final Exception e) {
			abort_error(13,"replace / parm pattern errror - " + e.toString());
		}

		// Replace - with _ for Linux
		try {
			find_dash = Pattern.compile(
					  "[-]"  //RPI 1080
			);
		} catch (final Exception e){
			abort_error(13, "replace - parm pattern errror - " + e.toString());
		}

		// Replace ' with ''
		try {
			find_squote = Pattern.compile(
					  "[']"  //RPI 1080
			);
		} catch (Exception e){
			abort_error(13,"replace ' parm pattern errror - " + e.toString());
		}

		// Replace '' with '
		try {
			find_dsquote = Pattern.compile(
					  "['][']"  //RPI 1080
			);
		} catch (final Exception e) {
			abort_error(13, "replace '' parm pattern errror - " + e.toString());
		}

		// Replace " with '
		try {
			find_dquote = Pattern.compile(
					  "[\"]"  //RPI 1080
			);
		} catch (final Exception e) {
			abort_error(13,"replace \" parm pattern errror - " + e.toString());
		}

		// Replace "" with "
		try {
			find_ddquote = Pattern.compile(
					  "[\"][\"]"  //RPI 1080
			);
		} catch (Exception e){
			abort_error(13,"replace \"\" parm pattern errror - " + e.toString());
		}

		// Replace & with && for Linux
		try {
			find_amp = Pattern.compile(
					  "[\\&]"  //RPI 1080
			);
		} catch (Exception e){
			abort_error(13,"replace & parm pattern errror - " + e.toString());
		}

		// Replace && with & for Linux
		try {
			find_damp = Pattern.compile(
					  "[\\&][\\&]"  //RPI 1080
			);
		} catch (final Exception e){
			abort_error(13, "replace && parm pattern errror - " + e.toString());
		}

		/*
		 * parm_pattern tokens:
		 *   1.  ?'     operators such as L', T', etc.
		 *   2.  ppp=   parm followed by = for detecting key vs pos
		 *   3.  C'xxx' spaces, commas, and '' ok in xxx
		 *   4.  'xxx' spaces, commas, and '' ok in xxx
		 *   5.  xxx    no spaces or commas in xxx ('s ok)
		 *   6.  ,      return to parse sublist and null parms
		 *   7.  (      return to parse sublist parm
		 *   8.  )      return to parse sublist parm
		 *   8.  '      single quotes appended to parm text
		 *   9.  space - detect end of parms and comments
		 */
		try {
			parm_pattern = Pattern.compile(
					  "([a-zA-Z$@#_][a-zA-Z0-9$@#_]*[=])"    // RPI 253
					+ "|([cC][aAeE]*[']([^']|(['][']))*['])"  //RPI 270
					+ "|([cC][!]([^!]|([!][!]))*[!])" 
					+ "|([cC][\"]([^\"]|([\"][\"]))*[\"])"
					+ "|([']([^']|(['][']))*['])" 
					+ "|([diklnstDIKLNST]['])"  // RPI 313 single quote ?' operators
					+ "|([^\\s',()+*-/]+)"  //RPI181,342
					+ "|([\\s',()+*-/])"    //RPI181,342
			);
		} catch (final Exception e){
			abort_error(14, "parm pattern errror - " + e.toString());
		}
	}

	/**
	 * Parse and set options.
	 * @param args
	 * @param pgm_type
	 */
	public void init_options(final String[] args, final String pgm_type)
	{
		/*
		 * Notes:
		 *   1.  These use () vs = because bat removes =
		 *        syslog(ddname)
		 *        sys390(ddname)
		 *        systerm(filename)
		 *        test(ddname)
		 *        time(seconds)
		 *   2.  Add options check for consistency
		 *       a.  NOASM - requires chkmac(0)   - RPI 1053
		 */
		if (args.length >= 1) {
			if (!set_pgm_dir_name_type(args[0],pgm_type)) {
				abort_error(4, "Invalid input file option - " + args[0]);
			}
			dir_390 = dir_pgm + "+linklib"; // 2007-10-01 - RPI-0700 Set dir_390 to pgm_dir + linklib
			dir_bal = dir_pgm;
			dir_cpy = dir_pgm;
			dir_dat = dir_pgm;
			dir_err = dir_pgm;
			dir_log = dir_pgm;
			dir_lst = dir_pgm;
			dir_mac = dir_pgm;
			dir_mlc = dir_pgm;
			dir_obj = dir_pgm;
			dir_opt = dir_pgm; // 2007-11-25 - RPI-0742 Abort if option invalid
			dir_pch = dir_pgm;
			dir_prn = dir_pgm;
			dir_trc = dir_pgm;
		} else {
			abort_error(5, "Missing file option");
		}

		process_options_file(dir_cur + "z390.OPT", false); // RPI-1156 - Optional opt initialization.
		int index1 = 1;
		while (index1 < args.length) {
			final String token = args[index1];
			process_option("CMD-LINE", index1+1, token); // 2007-11-25 - RPI-0742 Abort if option invalid
			index1++;
		}

		if (   cmd_parms.length() > 0
			&& cmd_parms.charAt(cmd_parms.length()-1) == ' ') {
			cmd_parms = cmd_parms.substring(0,cmd_parms.length()-1);
		}

		if (log_file_name.length() > 0) { // RPI 719  RPI 755
			if (systerm_file_name == null) { // RPI 730
				systerm_file_name = log_file_name;
			}
			if (trace_file_name == null) {
				trace_file_name = log_file_name;
			}
		}
		if (systerm_file_name == null) {  // RPI 425 RPI 546
			systerm_file_name = pgm_name; // RPI 546
		}
		if (dir_cpy == null) {
			dir_cpy = dir_mac; // RPI 742
		}
		check_options();
	}

	/**
	 * Check options for consistency
	 */
	private void check_options()
	{
		if (!opt_asm) {
			if(opt_chkmac != 0){
				abort_error(26, "NOASM requires CHKMAC(0)"); // RPI 1053
			}
			if (opt_chksrc == 3){
				abort_error(27, "NOASM requires CHKSRC(0-2)"); // RPI 1053
			}
		}
	}

	/**
	 * Process option from command line or from @file optionsfile line.
	 * @param opt_file_name
	 * @param opt_file_line
	 * @param token
	 */
	private void process_option(final String opt_file_name, final int opt_file_line, String token)
	{
		try {
			if (cmd_parms_len + token.length() + 1 > max_cmd_parms_line){
				String temp_token = token;
				while (temp_token.length() > max_cmd_parms_line - 2){
					cmd_parms = cmd_parms + "\r\n  " + temp_token.substring(0,max_cmd_parms_line - 2);
					temp_token = temp_token.substring(max_cmd_parms_line - 2);
				}
				if (temp_token.length() > 0){
					cmd_parms = cmd_parms + "\r\n  " + temp_token + " ";
					cmd_parms_len = temp_token.length() + 3;
				} else {
					cmd_parms_len = max_cmd_parms_line;
				}
			} else {
				cmd_parms = cmd_parms + token + " ";
				cmd_parms_len = cmd_parms_len + token.length() + 1;
			}
			if (   token.length() > 2 //RPI201 RPI 756
				&& token.charAt(0) == '"'
				&& token.charAt(token.length()-1) == '"') {
				token = token.substring(1,token.length()-1);
			}

			if (token.charAt(0) == '@'){
				process_options_file(token.substring(1),true);  // RPI 742 RPI 1156

			} else if (token.toUpperCase().equals("ALIGN")){
				opt_align = true; // RPI 1073

	} else if (token.toUpperCase().equals("NOALIGN")){
		opt_align = false;  // RPI 1073

	} else if (token.toUpperCase().equals("ALLOW")){
		opt_allow = true; // RPI 833

	} else if (token.toUpperCase().equals("NOALLOW")){
		opt_allow = false;  // RPI 833

	} else if (token.toUpperCase().equals("AMODE24")){
		opt_amode24 = true;
		opt_amode31 = false;
		z390_amode31 = 'F';
		z390_rmode31 = 'F';
	} else if (token.toUpperCase().equals("NOAMODE24")){
		opt_amode24 = false;
		opt_amode31 = true;
		z390_amode31 = 'T';
	} else if (token.toUpperCase().equals("AMODE31")){
		opt_amode24 = false;
		opt_amode31 = true;
		z390_amode31 = 'T';
	} else if (token.toUpperCase().equals("NOAMODE31")){
		opt_amode24 = true;
		opt_amode31 = false;
		z390_amode31 = 'F';
		z390_rmode31 = 'F';
	} else if (token.toUpperCase().equals("ASCII")){
		opt_ascii = true; 
	} else if (token.toUpperCase().equals("NOASCII")){
		opt_ascii = false; 
	} else if (token.toUpperCase().equals("ASM")){
		opt_asm = true; 
	} else if (token.toUpperCase().equals("NOASM")){
		opt_asm = false; 
	} else if (token.toUpperCase().equals("ASSIST")){
		opt_assist   = true; 
		opt_loadhigh = false; // RPI 819
	} else if (token.toUpperCase().equals("NOASSIST")){
		opt_assist   = false; 
		opt_loadhigh = true; // RPI 819
	} else if (token.toUpperCase().equals("AUTOLINK")){
		opt_autolink = true; // RPI 874
	} else if (token.toUpperCase().equals("NOAUTOLINK")){
		opt_autolink = false;
	} else if (token.toUpperCase().equals("BAL")){
		opt_bal = true; 
	} else if (token.toUpperCase().equals("NOBAL")){
		opt_bal = false; 
	} else if (token.toUpperCase().equals("BS2000")){
		opt_bs2000 = true;  // RPI 604
		opt_amode24 = true;
		opt_amode31 = false;
		z390_amode31 = 'F';
		z390_rmode31 = 'F';
	} else if (token.toUpperCase().equals("NOBS2000")){
		opt_bs2000 = false;  // RPI 604
		opt_amode24 = false;
		opt_amode31 = true;
		z390_amode31 = 'T';
		z390_rmode31 = 'F';
	} else if (token.length() == 9
			&& token.substring(0,7).toUpperCase().equals("CHKMAC(")){
		opt_chkmac = token.charAt(7) - '0';
		if (opt_chkmac < 0 || opt_chkmac > 2){
			add_invalid_option(opt_file_name,opt_file_line,token);
		}
	} else if (token.length() == 9
			&& token.substring(0,7).toUpperCase().equals("CHKSRC(")){
		opt_chksrc = token.charAt(7) - '0';
		if (opt_chksrc < 0 || opt_chksrc > 3){ // RPI 957
			add_invalid_option(opt_file_name,opt_file_line,token);
		}
	} else if (token.toUpperCase().equals("EDF")){ // RPI 1131
		opt_edf = true;
	} else if (token.toUpperCase().equals("NOEDF")){
		opt_edf = false;
	} else if (token.toUpperCase().equals("CICS")){
		opt_cics = true;
	} else if (token.toUpperCase().equals("NOCICS")){
		opt_cics = false;
	} else if (token.length() > 9 
			   && token.substring(0,9).toUpperCase().equals("CODEPAGE(")){
       	codepage = token;
	} else if (token.toUpperCase().equals("NOCODEPAGE")){
       	codepage = "";
	} else if (token.toUpperCase().equals("COMMENT")){
       	opt_comment = true;
	} else if (token.toUpperCase().equals("NOCOMMENT")){
       	opt_comment = false;
	} else if (token.toUpperCase().equals("CON")){
       	opt_con = true;
	} else if (token.toUpperCase().equals("NOCON")){
       	opt_con = false;
    } else if (token.toUpperCase().equals("DUMP")){
       	opt_dump = true;
    } else if (token.toUpperCase().equals("NODUMP")){
       	opt_dump = false;
    } else if (token.toUpperCase().equals("EPILOG")){
       	opt_epilog = true;
    } else if (token.toUpperCase().equals("NOEPILOG")){
       	opt_epilog = false;
    } else if (token.length() > 4
    	&& token.substring(0,4).toUpperCase().equals("ERR(")){
       	try {
       		max_errors = Integer.valueOf(token.substring(4,token.length()-1)).intValue();
      	} catch (Exception e){
      		add_invalid_option(opt_file_name,opt_file_line,token);
      	}
    } else if (token.toUpperCase().equals("ERRSUM")){
       	init_errsum();
    } else if (token.toUpperCase().equals("NOERRSUM")){
       	opt_errsum = false;
		max_errors = 100;
    } else if (token.toUpperCase().equals("EXTEND")){
       	opt_extend = true;
    } else if (token.toUpperCase().equals("NOEXTEND")){
       	opt_extend = false;
    } else if (token.length() > 6
        	&& token.substring(0,6).toUpperCase().equals("FLOAT(")){
       		opt_float = token.substring(6,token.length()-1).toUpperCase();
            if (!opt_float.equals("DECIMAL") 
            	&& !opt_float.equals("BINARY")
            	&& !opt_float.equals("HEX")){
            	abort_error(25,"option FLOAT must be DECIMAL, BINARY, or HEX");
            }
    } else if (token.toUpperCase().equals("GUAM")){
       	opt_guam = true;
    } else if (token.toUpperCase().equals("NOGUAM")){
       	opt_guam = false;
    } else if (token.toUpperCase().equals("INIT")){
       	opt_init = true;
    } else if (token.toUpperCase().equals("NOINIT")){
       	opt_init = false;
    } else if (token.length() > 4
     		&& token.substring(0,4).toUpperCase().equals("IPL(")){
    	opt_ipl = token.substring(4,token.length()-1); 
    } else if (token.length() > 8
     		&& token.substring(0,8).toUpperCase().equals("INSTALL(")){
    	opt_install_loc = token.substring(8,token.length()-1); 
   		System.setProperty("user.dir",opt_install_loc); // RPI 532 RPI 1080
   		dir_cur = System.getProperty("user.dir") + File.separator; // RPI 499 drop upper case RPI 865 
    } else if (token.toUpperCase().equals("LIST")){
       	opt_list = true;
    } else if (token.toUpperCase().equals("NOLIST")){
       	opt_list = false;
    } else if (token.toUpperCase().equals("LISTCALL")){
       	opt_listcall = true;
    } else if (token.toUpperCase().equals("NOLISTCALL")){
       	opt_listcall = false;
    } else if (token.toUpperCase().equals("LISTUSE")){
       	opt_listuse = true;
    } else if (token.toUpperCase().equals("NOLISTUSE")){
       	opt_listuse = false;
    } else if (token.toUpperCase().equals("LOADHIGH")){
       	opt_loadhigh = true; // RPI 819
    } else if (token.toUpperCase().equals("NOLOADHIGH")){
       	opt_loadhigh = false;
    } else if (token.length() > 4
      		&& token.substring(0,4).toUpperCase().equals("LOG(")){
     	log_file_name = token.substring(4,token.length()-1); // RPI 719
    } else if (token.length() > 8
      		&& token.substring(0,8).toUpperCase().equals("MAXCALL(")){
       	opt_maxcall = Integer.valueOf(token.substring(8,token.length()-1)).intValue(); 
    } else if (token.length() > 11  // RPI 1118 max zcobol display line
      		&& token.substring(0,11).toUpperCase().equals("MAXDISPLAY(")){
       	opt_maxdisplay = Integer.valueOf(token.substring(11,token.length()-1)).intValue(); 
    } else if (token.length() > 7
      		&& token.substring(0,7).toUpperCase().equals("MAXESD(")){
       	opt_maxesd = Integer.valueOf(token.substring(7,token.length()-1)).intValue();   	
    } else if (token.length() > 8
    	&& token.substring(0,8).toUpperCase().equals("MAXFILE(")){
       	try {
       		opt_maxfile = Integer.valueOf(token.substring(8,token.length()-1)).intValue();
       	} catch (Exception e){
       		add_invalid_option(opt_file_name,opt_file_line,token);
       	}   
    } else if (token.length() > 7
      		&& token.substring(0,7).toUpperCase().equals("MAXGBL(")){
       	opt_maxgbl = Integer.valueOf(token.substring(7,token.length()-1)).intValue();
    } else if (token.length() > 10
      		&& token.substring(0,10).toUpperCase().equals("MAXHEIGHT(")){
       	max_main_height = Integer.valueOf(token.substring(10,token.length()-1)).intValue();
    } else if (token.length() > 7
      		&& token.substring(0,7).toUpperCase().equals("MAXLCL(")){
       	opt_maxlcl = Integer.valueOf(token.substring(7,token.length()-1)).intValue(); 
    } else if (token.length() > 8
      		&& token.substring(0,8).toUpperCase().equals("MAXLINE(")){
       	opt_maxline = Integer.valueOf(token.substring(8,token.length()-1)).intValue(); 
    } else if (token.length() > 8
      		&& token.substring(0,7).toUpperCase().equals("MAXLOG(")){
       	opt_maxlog = Integer.valueOf(token.substring(7,token.length()-1)).intValue() << 20; 
    } else if (token.length() > 8
      		&& token.substring(0,8).toUpperCase().equals("MAXPARM(")){
       	opt_maxparm = Integer.valueOf(token.substring(8,token.length()-1)).intValue(); 
    } else if (token.length() > 8
      		&& token.substring(0,8).toUpperCase().equals("MAXPASS(")){ // RPI 920
       	opt_maxpass = Integer.valueOf(token.substring(8,token.length()-1)).intValue(); 
    } else if (token.length() > 6
      		&& token.substring(0,6).toUpperCase().equals("MAXPC(")){ // RPI 439
       	opt_maxpc = Integer.valueOf(token.substring(6,token.length()-1)).intValue();
    } else if (token.length() > 7
      		&& token.substring(0,7).toUpperCase().equals("MAXQUE(")){
       	opt_maxque = Integer.valueOf(token.substring(7,token.length()-1)).intValue(); 
    } else if (token.length() > 7
      		&& token.substring(0,7).toUpperCase().equals("MAXRLD(")){
       	opt_maxrld = Integer.valueOf(token.substring(7,token.length()-1)).intValue();  
    } else if (token.length() > 8
        	&& token.substring(0,8).toUpperCase().equals("MAXSIZE(")){
           	try {
           		max_file_size = Long.valueOf(token.substring(8,token.length()-1)).longValue() << 20; 
           	} catch (Exception e){
           		add_invalid_option(opt_file_name,opt_file_line,token);
           	}
    } else if (token.length() > 7
      		&& token.substring(0,7).toUpperCase().equals("MAXSYM(")){
       	opt_maxsym = Integer.valueOf(token.substring(7,token.length()-1)).intValue(); 
    } else if (token.length() > 7
      		&& token.substring(0,8).toUpperCase().equals("MAXWARN(")){
       	max_mnote_warning = Integer.valueOf(token.substring(8,token.length()-1)).intValue();
    	
    } else if (token.length() > 9
    		   && token.substring(0,9).toUpperCase().equals("MAXWIDTH(")){  // RPI 935
    	max_main_width = Integer.valueOf(token.substring(9,token.length()-1)).intValue();
    } else if (token.toUpperCase().equals("MCALL")){
       	opt_mcall = true; // RPI 511
       	opt_listcall = true;
    } else if (token.toUpperCase().equals("NOMCALL")){
       	opt_mcall = false; 
       	opt_listcall = false;
    } else if (token.length() > 5
    	&& token.substring(0,4).toUpperCase().equals("MEM(")){
       	try {
       	    max_mem = Integer.valueOf(token.substring(4,token.length()-1)).intValue();
       	} catch (Exception e){
       		add_invalid_option(opt_file_name,opt_file_line,token);
       	}
    } else if (token.length() > 10
      		&& token.substring(0,10).toUpperCase().equals("MINHEIGHT(")){
       	min_main_height = Integer.valueOf(token.substring(10,token.length()-1)).intValue();
    } else if (token.length() > 9
      		&& token.substring(0,9).toUpperCase().equals("MINWIDTH(")){
       	min_main_width = Integer.valueOf(token.substring(9,token.length()-1)).intValue();
    } else if (token.length() > 6  // RPI 1142
      		&& token.substring(0,6).toUpperCase().equals("MNOTE(")){
       	opt_mnote = Integer.valueOf(token.substring(6,token.length()-1)).intValue();
    } else if (token.toUpperCase().equals("MOD")){
       	opt_mod = true;
    } else if (token.toUpperCase().equals("NOMOD")){
       	opt_mod = false;
    } else if (token.toUpperCase().equals("OBJ")){
       	opt_obj = true;
    } else if (token.toUpperCase().equals("NOOBJ")){
       	opt_obj = false;
    } else if (token.toUpperCase().equals("OBJHEX")){
       	opt_objhex = true;
    } else if (token.toUpperCase().equals("NOOBJHEX")){
       	opt_objhex = false;
    } else if (token.length() > 5
       		&& token.substring(0,5).toUpperCase().equals("PARM(")){
        	opt_parm = token.substring(5,token.length()-1);
        	if (opt_parm.length() > 2 
        		&& opt_parm.charAt(0) == '\''
        		&& opt_parm.charAt(opt_parm.length()-1) == '\''){
        		opt_parm = opt_parm.substring(1,opt_parm.length()-1); 		
        	}
    } else if (token.toUpperCase().equals("PC")){
        opt_pc = true;
    } else if (token.toUpperCase().equals("NOPC")){
        opt_pc = false;
    } else if (token.toUpperCase().equals("PCOPT")){
        opt_pcopt = true;
    } else if (token.toUpperCase().equals("NOPCOPT")){
        opt_pcopt = false;
    } else if (token.toUpperCase().equals("PDSMEM8")){
        opt_pdsmem8 = true;
    } else if (token.toUpperCase().equals("NOPDSMEM8")){
        opt_pdsmem8 = false;
    } else if (token.toUpperCase().equals("PRINTALL")){ // RPI 1127
        opt_printall = true;
    } else if (token.toUpperCase().equals("NOPRINTALL")){
        opt_printall = false;
    } else if (token.length() > 8
      		&& token.substring(0,8).toUpperCase().equals("PROFILE(")){
     	opt_profile = token.substring(8,token.length()-1);
    } else if (token.toUpperCase().equals("PROLOG")){
        opt_prolog = true;
    } else if (token.toUpperCase().equals("NOPROLOG")){
        opt_prolog = false;
    } else if (token.toUpperCase().equals("PROTECT")){
        opt_protect = true;
    } else if (token.toUpperCase().equals("NOPROTECT")){
        opt_protect = false;
    } else if (token.toUpperCase().equals("R64")){ // RPI 986
        opt_r64 = true;
    } else if (token.toUpperCase().equals("NOR64")){
        opt_r64 = false;
    } else if (token.toUpperCase().equals("REFORMAT")){
        opt_reformat = true; 
    } else if (token.toUpperCase().equals("NOREFORMAT")){
        opt_reformat = false; 
    } else if (token.toUpperCase().equals("REGS")){
       	opt_regs = true;
       	opt_list  = true;
    } else if (token.toUpperCase().equals("NOREGS")){
       	opt_regs = false;
    } else if (token.toUpperCase().equals("RMODE24")){
       	opt_rmode24 = true;
       	opt_rmode31 = false;
       	z390_rmode31 = 'F';
    } else if (token.toUpperCase().equals("NORMODE24")){
       	opt_rmode24 = false;
       	opt_rmode31 = true;
       	z390_rmode31 = 'T';
       	z390_amode31 = 'T';
    } else if (token.toUpperCase().equals("RMODE31")){
       	opt_rmode24 = false;
      	opt_rmode31 = true;
       	z390_rmode31 = 'T';
    } else if (token.toUpperCase().equals("NORMODE31")){
       	opt_rmode24 = true;
      	opt_rmode31 = false;
       	z390_rmode31 = 'F';
    } else if (token.toUpperCase().equals("STATS")){
       	opt_stats = true;  // RPI 755
       	stats_file_name = pgm_name;
    } else if (token.toUpperCase().equals("NOSTATS")){
       	opt_stats = false;  // RPI 755
       	stats_file_name = null;
    } else if (token.length() > 6
      		&& token.substring(0,6).toUpperCase().equals("STATS(")){
     	stats_file_name = token.substring(6,token.length()-1); // RPI 736
     	opt_stats = true; // RPI 755
    } else if (token.length() > 7
       		&& token.substring(0,7).toUpperCase().equals("SYS390(")){
       	dir_390 = set_path_option(dir_390,token.substring(7,token.length()-1));	
    } else if (token.length() > 7 
       		&& token.substring(0,7).toUpperCase().equals("SYSBAL(")){
      	dir_bal = set_path_option(dir_bal,token.substring(7,token.length()-1)); 
    } else if (token.length() > 7 
      		&& token.substring(0,7).toUpperCase().equals("SYSCPY(")){
       	if (dir_cpy == null){ // RPI 979
       		dir_cpy = set_path_option(dir_pgm,token.substring(7,token.length()-1)); 
       	} else {
       		dir_cpy = set_path_option(dir_cpy,token.substring(7,token.length()-1)); 
       	}
    } else if (token.length() > 7 
      		&& token.substring(0,7).toUpperCase().equals("SYSDAT(")){
       	dir_dat = set_path_option(dir_dat,token.substring(7,token.length()-1)); 
    } else if (token.length() > 7
       		&& token.substring(0,7).toUpperCase().equals("SYSERR(")){
        dir_err = set_path_option(dir_err,token.substring(7,token.length()-1)); // RPI 243 
    } else if (token.length() > 7
      		&& token.substring(0,7).toUpperCase().equals("SYSLOG(")){
       	dir_log = set_path_option(dir_log,token.substring(7,token.length()-1));
    } else if (token.length() > 7 
      		&& token.substring(0,7).toUpperCase().equals("SYSLST(")){  // RPI 866
      	dir_lst = set_path_option(dir_lst,token.substring(7,token.length()-1)); 
    } else if (token.length() > 7 
       		&& token.substring(0,7).toUpperCase().equals("SYSMAC(")){
       	dir_mac = set_path_option(dir_mac,token.substring(7,token.length()-1));  
    } else if (token.length() > 7 
       		&& token.substring(0,7).toUpperCase().equals("SYSMLC(")){
      	dir_mlc = set_path_option(dir_mlc,get_short_file_name(token.substring(7,token.length()-1))); 
    } else if (token.length() > 7 
       		&& token.substring(0,7).toUpperCase().equals("SYSOBJ(")){
       	dir_obj = set_path_option(dir_obj,token.substring(7,token.length()-1)); 
    } else if (token.length() > 7 
       		&& token.substring(0,7).toUpperCase().equals("SYSOPT(")){
       	dir_opt = set_path_option(dir_opt,token.substring(7,token.length()-1)); // RPI 742
    } else if (token.length() > 8
     		&& token.substring(0,8).toUpperCase().equals("SYSPARM(")){
    	opt_sysparm = token.substring(8,token.length()-1); 
    } else if (token.length() > 7 
       		&& token.substring(0,7).toUpperCase().equals("SYSPCH(")){
      	dir_pch = set_path_option(dir_pch,get_short_file_name(token.substring(7,token.length()-1))); 
    } else if (token.length() > 7 
      		&& token.substring(0,7).toUpperCase().equals("SYSPRN(")){
      	dir_prn = set_path_option(dir_prn,token.substring(7,token.length()-1)); 	
    } else if (token.length() > 8
      		&& token.substring(0,8).toUpperCase().equals("SYSTERM(")){
     	systerm_file_name = token.substring(8,token.length()-1); // RPI 730
    } else if (token.length() > 7 
       		&& token.substring(0,7).toUpperCase().equals("SYSTRC(")){
      	dir_trc = set_path_option(dir_trc,token.substring(7,token.length()-1)); 
    } else if (token.length() > 5
      		&& token.substring(0,5).toUpperCase().equals("TIME(")) {
       	max_time_seconds = Long.valueOf(token.substring(5,token.length()-1)).longValue();
       	if (max_time_seconds > 0) {
       		opt_time = true;
       	} else {
       		opt_time = false;
       		opt_timing = false;
       	}
    } else if (token.toUpperCase().equals("TIME")){
       	opt_time = true;  
       	max_time_seconds = 15;
    } else if (token.toUpperCase().equals("NOTIME")){
       	opt_time = false;  
    } else if (token.toUpperCase().equals("TIMING")){
       	opt_timing = true;  
    } else if (token.toUpperCase().equals("NOTIMING")){
       	opt_timing = false;
       	opt_time   = false;
    } else if (token.toUpperCase().equals("TEST")){
       	opt_test = true;
       	opt_time = false;
       	opt_con  = true;
    } else if (token.toUpperCase().equals("NOTEST")){
       	opt_test = false;
    } else if (token.toUpperCase().equals("THREAD")){
       	opt_thread = true;  // RPI 1186
    } else if (token.toUpperCase().equals("NOTHREAD")){
       	opt_thread = false; // RPI 1186
    } else if (token.length() > 5
      		&& token.substring(0,5).toUpperCase().equals("TEST(")){
       	test_ddname = token.substring(5,token.length()-1);	
       	opt_test = true;
    } else if (token.toUpperCase().equals("TRACE")){
       	opt_trace = true;
       	opt_list   = true;
       	if (!opt_test){
       		opt_con   = false; // RPI 569 leave on if TEST
       	}
    } else if (token.toUpperCase().equals("NOTRACE")){
       	opt_trace = false;
    } else if (token.length() > 6
      		&& token.substring(0,6).toUpperCase().equals("TRACE(")){
       	trace_options = token.substring(6,token.length()-1).toUpperCase();
       	opt_con = false;
       	set_trace_options(trace_options); // RPI 930       	
    } else if (token.toUpperCase().equals("TRACEA")){
       	opt_tracea = true;
       	opt_list = true;
       	opt_con   = false;
    } else if (token.toUpperCase().equals("NOTRACEA")){
       	opt_tracea = false;
    } else if (token.toUpperCase().equals("TRACEC")){
       	opt_tracec = true;
    } else if (token.toUpperCase().equals("NOTRACEC")){
       	opt_tracec = false;
    } else if (token.toUpperCase().equals("TRACEALL")){
       	opt_trace    = true;
    	opt_traceall = true;
      	opt_tracea   = true;
      	opt_tracec   = true; // RPI 862
       	opt_traceg   = true;
       	opt_tracei   = true; // RPI 1157
       	opt_tracel   = true;
       	opt_tracem   = true;
       	opt_tracep   = true;
       	opt_traceq   = true;
       	opt_traces   = true; // RPI 882
       	opt_tracet   = true;
       	opt_tracev   = true;
       	opt_list     = true;
       	opt_listcall = true; // RPI 862
       	opt_con   = false;
    } else if (token.toUpperCase().equals("NOTRACEALL")){
       	opt_traceall = false;
       	opt_trace    = false;
      	opt_tracea   = false;
      	opt_tracec   = false;
       	opt_traceg   = false;
       	opt_tracei   = false;  // RPI 1157
       	opt_tracel   = false;
      	opt_tracem   = false;
       	opt_tracep   = false;
       	opt_traceq   = false;
       	opt_traces   = false; // RPI 882
       	opt_tracet   = false;
       	opt_tracev   = false;
    } else if (token.toUpperCase().equals("TRACEG")){
       	opt_traceg = true;
       	opt_con   = false;
    } else if (token.toUpperCase().equals("NOTRACEG")){
       	opt_traceg = false;
    } else if (token.toUpperCase().equals("TRACEI")){
       	opt_tracei = true;
       	opt_con   = false;
    } else if (token.toUpperCase().equals("NOTRACEI")){
       	opt_tracei = false;
    } else if (token.toUpperCase().equals("TRACEL")){
       	opt_tracel = true;
       	opt_list = true;
       	opt_con   = false;
    } else if (token.toUpperCase().equals("NOTRACEL")){
       	opt_tracel = false;
    } else if (token.toUpperCase().equals("TRACEM")){
        	opt_tracem = true;
        	opt_list = true;
        	opt_listcall = true; // RPI 862
        	opt_con   = false;
    } else if (token.toUpperCase().equals("NOTRACEM")){
    	opt_tracem = false;
    } else if (token.toUpperCase().equals("TRACEMEM")){
       	opt_traceg = true;
       	opt_con   = false;
    } else if (token.toUpperCase().equals("NOTRACEMEM")){
       	opt_traceg = false;
    } else if (token.toUpperCase().equals("TRACEP")){
    	opt_tracep = true;
    	opt_tracem = true;
    	opt_list = true;
    	opt_listcall = true; // RPI 862
    	opt_con   = false;
    } else if (token.toUpperCase().equals("NOTRACEP")){
    	opt_tracep = false;
    } else if (token.toUpperCase().equals("TRACEQ")){
    	opt_traceq = true;
    	opt_con   = false;
    } else if (token.toUpperCase().equals("NOTRACEQ")){
    	opt_traceq = false;
    } else if (token.toUpperCase().equals("TRACES")){
    	opt_traces = true; // RPI 882
    	opt_con   = false;
    } else if (token.toUpperCase().equals("NOTRACES")){
    	opt_traces = false; // RPI 882
    } else if (token.toUpperCase().equals("TRACET")){
    	opt_tracet = true;
    	opt_con   = false;
    } else if (token.toUpperCase().equals("NOTRACET")){
    	opt_tracet = false;
    } else if (token.toUpperCase().equals("TRACEV")){
    	opt_tracev = true;
    	opt_con   = false;
    } else if (token.toUpperCase().equals("NOTRACEV")){
    	opt_tracev = false;
    } else if (token.toUpperCase().equals("TRAP")){
       	opt_trap = true;
    } else if (token.toUpperCase().equals("NOTRAP")){
       	opt_trap = false;
    } else if (token.toUpperCase().equals("TRUNC")){
       	opt_trunc = true;
    } else if (token.toUpperCase().equals("NOTRUNC")){
       	opt_trunc = false;
    } else if (token.toUpperCase().equals("TS")){
    	opt_ts = true; // timestamp traces
    } else if (token.toUpperCase().equals("NOTS")){
    	opt_ts = false; 
    } else if (token.toUpperCase().equals("VCB")){
    	opt_vcb = true; // VSAM Cache Buffering to reduce I/O
    } else if (token.toUpperCase().equals("NOVCB")){
    	opt_vcb = false;
    } else if (token.toUpperCase().equals("WARN")){
    	opt_warn = true; // VSAM Cache Buffering to reduce I/O
    } else if (token.toUpperCase().equals("NOWARN")){
    	opt_warn = false;
    } else if (token.toUpperCase().equals("XREF")){
       	opt_xref = true;
       	opt_list = true;
    } else if (token.toUpperCase().equals("NOXREF")){
       	opt_xref = false;
    } else if (token.toUpperCase().equals("ZSTRMAC")){
       	opt_zstrmac = true;
    } else if (token.toUpperCase().equals("NOZSTRMAC")){
       	opt_zstrmac = false;
    } else {
        add_invalid_option(opt_file_name,opt_file_line,token);
    }
  } catch (Exception e) {
	  add_invalid_option(opt_file_name,opt_file_line,token);
  }
}

	/**
	 * Set trace options (called by init and by mz390 when SYSTRACE is updated.
	 * @param trace_options
	 */
	public void set_trace_options(final String trace_options)
	{
		opt_traceall = false;
		opt_trace    = false;
		opt_tracea   = false;
		opt_tracec   = false; 
		opt_traceg   = false;
		opt_tracei   = false; // RPI 1157
		opt_tracel   = false;
		opt_tracem   = false;
		opt_tracep   = false;
		opt_traceq   = false;
		opt_traces   = false; 
		opt_tracet   = false;
		opt_tracev   = false;

		int index = 0;
		while (index < trace_options.length())
		{
		//	final char c = trace_options.toUpperCase().charAt(index);
			final char c = trace_options.charAt(index);
			switch (c) {
			case '*':
				opt_traceall = true;
				opt_trace    = true;
				opt_tracea   = true;
				opt_tracec   = true; 
				opt_traceg   = true;
				opt_tracei   = true; // RPI 1157
				opt_tracel   = true;
				opt_tracem   = true;
				opt_tracep   = true;
				opt_traceq   = true;
				opt_traces   = true; 
				opt_tracet   = true;
				opt_tracev   = true;
				break;
			case 'A':
				opt_tracea = true;
				break;
			case 'C':
				opt_tracec = true; // RPI 862
				break;
			case 'E':
				opt_trace  = true;
				break;
			case 'G':
				opt_traceg = true;
				break;
			case 'I':
				opt_tracei = true;  // RPI 1157
				break;
			case 'L':
				opt_tracel = true;
				break;
			case 'M':
				opt_tracem = true;
				opt_listcall = true; // RPI 862
				break;
			case 'P':
				opt_tracep = true;
				opt_tracem = true;
				opt_listcall = true; // RPI 862
				break;
			case 'Q':
				opt_traceq = true;
				break;
			case 'S':
				opt_traces = true; // RPI 882
				break;
			case 'T':
				opt_tracet = true;
				break;
			case 'V':
				opt_tracev = true;
				break;
			}
			index++;
		}
	}

	/**
	 * Collect invalid options for single error.
	 * @param opt_file_name
	 * @param opt_file_line
	 * @param option
	 */
	private void add_invalid_option(String opt_file_name,int opt_file_line,String option)
	{
		invalid_options = invalid_options + " " + option; // RPI 880
		System.out.println("TZ390E invalid option=" + option + "  (" + opt_file_name + "/" + opt_file_line + ")");
	}

	/**
	 * Process option file as follows:
	 * 1.  Default suffix .OPT
	 * 2.  Uses SYSOPT path which defaults to program path
	 * 3.  Comments starting with * to end of line
	 * 4.  @file option can be nested.
	 * 
	 * @param file_name
	 * @param required
	 */
	private void process_options_file(String file_name,boolean required) // RPI 1156
	{
		final String opt_file_name = find_file_name(dir_opt,file_name,opt_type,dir_cur); // RPI 880
		int opt_file_line = 0; // rpi 880
		if (opt_file_name != null) {
			try {
				final File opt_file = new File(opt_file_name);
				final BufferedReader opt_file_buff = new BufferedReader(new FileReader(opt_file));

				if (!required) {
					cmd_parms = cmd_parms.trim() + opt_file_name;
				}
				cmd_parms = cmd_parms.trim() + "=(";

				String option_line = opt_file_buff.readLine();
				while (option_line != null){
					opt_file_line++; // rpi 880
					final Matcher find_option_match = find_non_space_pattern.matcher(option_line);
					final boolean comment_found = false;  // RPI 880
					while (    find_option_match.find() 
							&& find_option_match.group().charAt(0) != '*'
							&& !comment_found){  // RPI 880
							final String option = find_option_match.group();
							process_option(opt_file_name,opt_file_line,option);
					}
					option_line = opt_file_buff.readLine();
				}
				opt_file_buff.close();
				cmd_parms = cmd_parms.trim() + ") ";
			} catch (final Exception e) {
				add_invalid_option(opt_file_name,opt_file_line,"@" + file_name); // RPI 880
			}
		} else if (required) {
			add_invalid_option(opt_file_name,opt_file_line,"@" + file_name); // RPI 880
		}
	}

	/**
	 * Open systerm file and sta statistics file positions to add to end of existing files.
	 * @param z390_pgm
	 */
	public void open_systerm(final String z390_pgm)
	{
		String z390_j2se_versions = "";  // RPI 797
		if (opt_timing) {
			// Initialize systerm_start as soon as possible.
			// Otherwise abort_error logs a rubbish running time
			systerm_start = System.currentTimeMillis();
			z390_j2se_versions = 
				  " USING z390 " + version
				+ " ON J2SE " + System.getProperty("java.version")
				+ " " + cur_date(); // RPI 797
	}

		systerm_prefix = left_justify(pgm_name,9) + " " + z390_pgm + " ";
		if (   stats_file      == null 
			&& stats_file_name != null) {
			stats_file_name = get_file_name(dir_err, stats_file_name, sta_type);
			try {
				stats_file = new RandomAccessFile(stats_file_name,"rw"); 
				stats_file.seek(stats_file.length());
			} catch (final Exception e) {
				stats_file = null; 
				abort_error(20,"stats file open error " + e.toString());
			}
		}
		if (systerm_file != null) { return; } // RPI 415
		if (   systerm_file_name == null
			|| systerm_file_name.length() == 0) {
			systerm_file_name = pgm_name; // RPI 880
		}
		systerm_file_name = get_file_name(dir_err,systerm_file_name,err_type);
		try {
			systerm_file = new RandomAccessFile(systerm_file_name,"rw"); 
			systerm_file.seek(systerm_file.length());
			if (invalid_options.length() > 0) {
				abort_error(21, "invalid option(s) - " + invalid_options);
			}
		} catch (final Exception e) {
			systerm_file = null; 
			abort_error(10, "systerm file open error " + e.toString());
		}
		try {
			systerm_io++;
			started_msg = cur_time(true) 
						+ systerm_prefix 
						+ "START" + z390_j2se_versions; // RPI 797
			System.out.println(started_msg);
			systerm_file.writeBytes(started_msg + newline); // RPI 500
			if (stats_file != null) {
				try { // RPI 935
					stats_file.writeBytes(started_msg + newline); // RPI 755
				} catch (final Exception e) {
					stats_file = null; 
					abort_error(23, "I/O error on stats file " + e.toString());
				}
			}
		} catch (final Exception e) {
			systerm_file = null; 
			abort_error(11, "I/O error on systerm file " + e.toString());
		}
	}

	/**
	 * Log error to systerm file.
	 * @param msg
	 */
	public synchronized void put_systerm(String msg) // RPI 397
	{
		if (systerm_file != null) { // RPI 935
			try {
				systerm_io++;
				systerm_file.writeBytes(cur_time(true) + systerm_prefix + msg + newline); // RPI 500
			} catch (final Exception e){
				abort_error(12, "I/O error on systerm file " + e.toString());
			}
		} else {
			System.out.println(systerm_prefix + msg); //RPI 1069 codepage prior to setting systerm
		}
	}

	/**
	 * Mod stat record on stats.sta file.
	 * @param msg
	 */
	public synchronized void put_stat_line(final String msg) // RPI 397
	{
		if (stats_file != null) { // RPI 935
			try {
				systerm_io++;
				stats_file.writeBytes(cur_time(true) + systerm_prefix + msg + newline); // RPI 500
			} catch (final Exception e){
				stats_file = null;
				abort_error(19, "I/O error on stats file " + e.toString());
			}
		}
	}

	/**
	 * Close systerm error file if open.
	 * @param rc
	 */
	public synchronized void close_systerm(final int rc) // RPI 397
	{
		if (systerm_file != null){
			systerm_io++;
			set_ended_msg(rc);
			try {
				System.out.println(ended_msg);
				systerm_file.writeBytes(ended_msg + newline); // RPI 500
				if (stats_file != null){
					try {
						stats_file.writeBytes(ended_msg + newline); // RPI 755
					} catch (Exception e){
						stats_file = null;
						abort_error(24, "I/O error on stats file close " + e.toString());
					}
				}
			} catch (Exception e){
				systerm_file = null; // RPI 935
			}
			try {
				systerm_file.close();
			} catch (Exception e){
				System.out.println("TZ390E systerm file close error - " + e.toString());
			}
			systerm_file = null;
		}
		if (stats_file != null){
			try {
				stats_file.close();
			} catch (final Exception e){
				System.out.println("TZ390E stats file close error - " + e.toString());
			}
			stats_file = null;
		}
	}

	/**
	 * Set ended_msg for use by mz390, az390, lz390, and ez390.
	 * @param rc
	 */
	public void set_ended_msg(final int rc)
	{
		// 2008-09-06 - RPI-0797 Suppress versions and memory consumption for NOTIMING.
		String systerm_mem = "";

		// 2008-04-23 - RPI-0837 Update EZ390 ENDING message only once and add in to log.
		if (ended_msg.length() > 0) {
			return;
		}
		if (opt_timing) {
			systerm_sec = " SEC="     + right_justify("" + ((System.currentTimeMillis()-systerm_start)/1000),2);
			systerm_mem = " MEM(MB)=" + right_justify("" + get_mem_usage(),3);
		}
		String systerm_ins_text = "";
		if (systerm_ins > 0) {
			systerm_ins_text = " INS=" + systerm_ins;
		}
		ended_msg = cur_time(true) + systerm_prefix
					+ "ENDED RC=" + right_justify("" + rc,2)
					+ systerm_sec
					+ systerm_mem
					+ " IO=" + systerm_io
					+ systerm_ins_text;
	}

	/**
	 * Close trace file if open RPI 484.
	 */
	public void close_trace_file()
	{
		if (trace_file_buff != null) {
			try {
				trace_file_buff.close();
			} catch (final Exception e) {
				abort_error(15, "Trace file close failed " + e.toString());
			}
		}
	}

	/**
	 * Return max memory usage by J2SE in MB.
	 * @return
	 */
	public int get_mem_usage()
	{
		long mem_tot = 0;
		final List<MemoryPoolMXBean> pools = ManagementFactory.getMemoryPoolMXBeans();
		for (final MemoryPoolMXBean p: pools) {
			mem_tot = mem_tot + p.getPeakUsage().getUsed();
		}
		return (int)(mem_tot >> 20);
	}

	/**
	 * Return shortest file name possible with quotes if LSN.
	 * @param file_name
	 * @return
	 */
	private String get_short_file_name(String file_name)
	{
		if (   file_name.length() > dir_cur.length()
			&& file_name.substring(0,dir_cur.length()).equals(dir_cur)) {
			if (file_name.substring(dir_cur.length(),dir_cur.length()+1).equals(File.separator)) {
				file_name = file_name.substring(dir_cur.length()+1); // skip dir + sep
			} else {
				file_name = file_name.substring(dir_cur.length()); // skip dir
			}
		}
		final int index = file_name.indexOf(" ");
		if (file_name.charAt(0) != '"' // RPI 756
			&& index >=0) {
			return "\"" + file_name + "\""; // LSN
		}
		return file_name;
	}

	/**
	 * Display options error on system out and exit with RC 16.
	 * @param error
	 * @param msg
	 */
	public synchronized void abort_error(final int error, String msg) // RPI 397
	{
		if (tz390_recursive_abort) { // RPI 935
			System.out.println("TZ390E recurive abort exit");
			System.exit(16);
		}
		tz390_recursive_abort = true;
		msg = "TZ390E abort error " + error + " - " + msg;
		System.out.println(msg);
		System.out.println("z390_abort_request"); // RPI 731 request parent shutdown
		System.out.flush();
		put_systerm(msg);
		z390_abort = true;
		sleep_now(1000);
		close_systerm(16);
		System.exit(16);
	}

	/**
	 * Initialize ASCII/EBCDIC conversion tables.
	 */
	private void init_ascii_ebcdic()
	{
		int index = 0;
		while (index < 256) {
			ascii_to_ebcdic[index] = (byte) Integer.valueOf(ascii_to_ebcdic_hex.substring(index*2,index*2+2),16).intValue();
			ebcdic_to_ascii[index] = (byte) Integer.valueOf(ebcdic_to_ascii_hex.substring(index*2,index*2+2),16).intValue();
			index++;
		}
	}

	/**
	 * Return user_key_index for user_key else -1 and set following for possible add_key_index:
	 *    1.  key_text = user_key
	 *    2.  key_hash = hash code for key
	 *    3.  key_index_last = last search entry
	 * @param user_key_type
	 * @param user_key
	 * @return
	 */
	public int find_key_index(final char user_key_type, final String user_key)
	{
		/*
		 * Notes:
		 *   1.  Usage my mz390
		 *       a.  "A:" - ago gbla table pointer
		 *       b.  "C:" - copy file found  RPI 970
		 *       c.  "F:" - macro and copybook files
		 *       d.  "G:" - global set variables
		 *       e.  "M:" - loaded macros
		 *       f.  "O:" - opcode table (init_opcode_name_keys)
		 *       g.  "R:" - opcode and macro opsyn
		 *       h.  "S:" - ordinary symbols
		 *       i.  "X:" - executable macro command
		 *       j.  "Z:" - ZSTRMAC opcodes and apm names RPI 902
		 *   2.  Usage by az390
		 *       a.  "L:" - literals
		 *       b.  "O:" - opcode table (init_opcode_name_keys)
		 *       c.  "R:" - opcode opsyn
		 *       d.  "S:" - ordinary symbols
		 *       e.  "U:" - USING labels
		 *       f.  "V:" - extrn symbol
		 *   3.  Usage by lz390
		 *       a.  "G:" - global ESD's
		 *   4.  Usage by ez390
		 *       a.  "H:" - opcodes by hex key
		 *       b.  "H:BR:" - branch opocodes by hex key
		 *       c.  "O:" - opcodes by name (init_opcode_name_keys)
		 *       d.  "P:" - CDE program name lookup
		 *       e.  "R:" - OPSYN opcode/macro substitution
		 *   5.  See find_lcl_key_index in mz390 with local key types KBPL
		 *   6.  Optimize by using separate user_key_type char to avoid extra string concat and
		 *       avoid string compare if not desired type.  RPI 409 (all calls changed)
		 */
		tot_key_search++;
		key_type = user_key_type;
		key_text = user_key;
		key_hash  = key_text.hashCode(); // RPI 434 
		key_index = Math.abs(key_hash % max_key_root)+1;
		if (key_tab_key[key_index] == null) {
			key_index_last = key_index;
			last_key_op = key_not_found;
			return -1;
		}
		cur_key_comp = 0;
		while (key_index > 0) {
			tot_key_comp++;
			cur_key_comp++;
			if (   key_hash == key_tab_hash[key_index]
				&& user_key_type == key_tab_type[key_index]
				&& user_key.equals(key_tab_key[key_index])) {
				if (cur_key_comp > max_key_comp) {
					max_key_comp = cur_key_comp;
				}
				last_key_op = key_found;
				return key_tab_index[key_index];
			}
			key_index_last = key_index;
			if (key_hash < key_tab_hash[key_index]) {
				key_index = key_tab_low[key_index];
			} else {
				key_index = key_tab_high[key_index];
			}
		}
		if (cur_key_comp > max_key_comp) {
			max_key_comp = cur_key_comp;
		}
		last_key_op = key_not_found;
		return -1;
	}

	/**
	 * Add user_index entry based on key_text, key_hash, and key_index_last set by prior find_key_index
	 * @param user_index
	 * @return
	 */
	public boolean add_key_index(final int user_index)
	{
		if (last_key_op != key_not_found) {
			return false;
		}
		if (key_tab_key[key_index_last] == null) {
			key_index = key_index_last;
		} else {
			if (tot_key_tab < max_key_tab) {
				key_index = tot_key_tab;
				tot_key_tab++;
			} else {
				return false;  // table size exceeded
			}
			if (key_hash < key_tab_hash[key_index_last]) {
				key_tab_low[key_index_last] = key_index;
			} else {
				key_tab_high[key_index_last] = key_index;
			}
		}
		tot_key++;
		key_tab_type[ key_index] = key_type;
		key_tab_key[  key_index] = key_text;
		key_tab_hash[ key_index] = key_hash;
		key_tab_index[key_index] = user_index;
		return true;
	}

	/**
	 * Update previously found key index.
	 * @param user_key
	 * @return
	 */
	public boolean update_key_index(int user_key)
	{
		if (last_key_op != key_found) {
			return false;
		}
		key_tab_index[key_index] = user_key;
		return true;
	}

	/**
	 * 1.  Strip long spacey name quotes if found from path and file.
	 * 2.  Replace . and ..\ with current directory  RPI 866
	 * 3.  Check for overriding path in filename and ignore default path RPI 866
	 * 4.  Check for overriding filename in path and ignore default filename RPI 866
	 * 2.  Add directory, name, and/or type if not specified  
	 * 3.  Replace \ with / if Linux
	 * @param file_dir
	 * @param file_name
	 * @param file_type
	 * @return
	 */
	public String get_file_name(String file_dir,String file_name,final String file_type)
	{
		if (   file_dir  == null
			|| file_name == null
			|| file_type == null
			|| file_dir.length()  == 0
			|| file_name.length() == 0) { // RPI 903 allow 0 length type
			return null; // RPI 880
		}

		final int last_path_sep = file_dir.lastIndexOf(File.separatorChar); // RPI 1191
		file_dir  = fix_file_separators(file_dir);  // RPI 1080
		file_name = fix_file_separators(file_name); // RPI 1080
		if (   file_name.charAt(0) == '\"' 
			|| file_name.charAt(0) == '\''){
			file_name = file_name.substring(1,file_name.length() - 1);
		}
		File temp_file;
		int index = file_name.indexOf(File.separator); // RPI 866
		if (index >= 0
				|| (file_name.length() > 2 && file_name.charAt(1) == ':')){
			// path found in file_name so ignore file_dir
			temp_file = new File(file_name);
			file_name = temp_file.getAbsolutePath(); 
		} else {
			if (   file_dir == null 
				|| file_dir.length() == 0
				|| file_dir.equals(".")){
				temp_file = new File(dir_cur);
				if (temp_file.isDirectory()){
					file_name = temp_file.getAbsolutePath() + File.separator + file_name;
				} else {
					return null; // rpi 880
				}
			} else {
				temp_file = new File(file_dir + File.separator); // RPI 1210 
				index = file_dir.lastIndexOf("."); // RPI 1191 
				if (index > last_path_sep){        // RPI 1191 
					// file_dir has filename.sfx so ignore file_name
					if (file_dir.charAt(index-1) == '*'){  // RPI 908
						if (index > 1){
							// path\*.sfx
							temp_file = new File(file_dir.substring(0,index-1) + file_name + file_dir.substring(index));
						} else {
							// *.sfx - replace sfx
							temp_file = new File(dir_pgm + File.separator + file_name + file_dir.substring(index));
						}
					}
					file_name = temp_file.getAbsolutePath(); // RPI 908 remove file exist chk 
				} else {
					// concatenate file_dir with file_name
					if (temp_file.isDirectory()){
						file_name = temp_file.getAbsolutePath() + File.separator + file_name;
					} else {
						return null; // rpi 880
					}
				}
			}
		}
		index = file_name.lastIndexOf(".");
		int index1 = file_name.lastIndexOf(File.separatorChar); // RPI 1210 
		if (index <= index1) { // RPI 1210 
			// concat default type if none
			file_name = file_name.trim() + file_type;
		}
		return file_name;
	}

	/**
	 * 1.  Replace \ with / if Linux else / with |
	 * 2.  Replace ..\ or ../ with parent path
	 * 3.  Remove embedded ./ or .\
	 * @param name
	 * @return
	 */
	public String fix_file_separators(String name)
	{
		if (infoOS.isLinux()) { // RPI 532 file separator fix
			name = find_bslash.matcher(name).replaceAll("/");  // RPI 1080
		} else {
			name = find_slash.matcher(name).replaceAll("\\\\");  // RPI 1080
		}
		// proces any ..\..\ relative paths RPI 1097
		File temp_file = new File(System.getProperty("user.dir"));
		boolean parent_path = false;
		while (name.length() >= 3 && name.substring(0,3).equals(".." + File.separator)) {
			parent_path = true;
			temp_file = new File(temp_file.getParent());
			name = name.substring(3);
		}
		// Remove leading .\ for rel file RPI 1097
		if (name.length() >= 2 && name.substring(0,2).equals("." + File.separator)) {
			name = name.substring(2);
		}
		// Replace embedded .\ with \  RPI 1097
		int index = 0;
		while (index < name.length() - 1) {
			if (name.charAt(index) == '.') {
				if (name.charAt(index+1) == File.separatorChar) {
					name = name.substring(0,index) + name.substring(index+2);
					index--;
				}
			}
			index++;
		}
		// Remove trailing \ RPI 1097
		index = name.length()-1;
		while (index >= 0 && name.charAt(index) == File.separatorChar){
			name = name.substring(0,index);
			index--;
		}
		// Prefix parent path if any  RPI 1097
		if (parent_path) {
			name = temp_file.getPath() + File.separator + name;
		}
		return name;
	}

	/**
	 * Search for existing file in one or more directories and return file name or null if not found.<br>
	 * <br>
	 * Notes:
	 * <ol><li>The separator for multiple files may be ; or + (plus sign)<br>versus semicolon is used in BAT parameters to avoid conflict with Windows BAT parsing.<br>
	 *     <li>If file_name has type use it.<br>
	 *       else if directory path has *.type use the type instead of default file_type.</ol>
	 * @param parm_dir_list
	 * @param file_name
	 * @param file_type_def
	 * @param dir_cur
	 * @return
	 */
	public String find_file_name(String parm_dir_list, String file_name, String file_type_def, final String dir_cur)
	{
		boolean explicit_type = false;
		File    temp_file;
		if (file_name == null)return null; // RPI 459
		if (file_name.charAt(0) == '"'){
			file_name = file_name.substring(1,file_name.length()-1); // RPI 1074 
		}
		file_name  = fix_file_separators(file_name);
		int index  = file_name.lastIndexOf(File.separator); // rpi 1210 
		int index1 = file_name.lastIndexOf('.');
		if (index1 > index){ // rpi 1210
			file_type_def = file_name.substring(index1); // RPI 756 rpi 1210 
			explicit_type = true;
			file_name = file_name.substring(0,index1);   // RPI 756 rpi 1210 
		}

		if (index == -1
			&& (file_name.length() > 2 &&  file_name.charAt(1) == ':')) {
				index = 2;
		}	
		if (index >= 0) {
			// file_name has explicit path so use it
			temp_file = new File(file_name + file_type_def);
			if (temp_file.isFile()){
				return temp_file.getPath(); // RPI 756
			}
		} else {
			// search directory list for file
			parm_dir_list = fix_file_separators(parm_dir_list); // RPI 1080
			index = 0;
			int path_len = 0;  
			while (index <= parm_dir_list.length()) {
				file_type = file_type_def;
				index1 = parm_dir_list.substring(index).indexOf(";");
				if (index1 == -1)
					index1 = parm_dir_list.substring(index).indexOf("+");
				if (index1 > 0){
					path_len = path_len + index1;
					file_dir = parm_dir_list.substring(index,path_len); // RPI123
					index = index + index1 + 1;
					path_len = path_len + 1;
				} else {
					file_dir = parm_dir_list.substring(index);
					index = parm_dir_list.length()+1;
				}
				if (file_dir.equals(".")) {
					file_dir = dir_cur;
				}
				int index2 = file_dir.indexOf("*.");
				if (index2 >= 0) {  // RPI 756
					if (!explicit_type) {
						file_type = file_dir.substring(index2+1);
					}
					file_dir = file_dir.substring(0,index2);
				}
				if (file_dir.length() > 0) {
					if (!file_dir.substring(file_dir.length()-1,file_dir.length()).equals(File.separator)){
						if (file_dir.length() != 2 || file_dir.charAt(1) != ':'){
							file_dir = file_dir + File.separator;
						}
					}
					temp_file = new File(file_dir + file_name + file_type);
				} else {
					temp_file = new File(file_name + file_type);
				}
				if (temp_file.isFile()){
					return temp_file.getPath(); // RPI 499 drop upper case
				}
			}
		}
		return null;
	}

	/**
	 * Execute command as separate task.
	 * @param cmd
	 * @return
	 */
	public boolean exec_cmd(final String cmd)
	{
		try {
			Runtime.getRuntime().exec(cmd);
			return true;
		} catch(final Exception e) {
			return false;
		}
	}

	/**
	 * Add all opcodes to key index table.
	 * @return
	 */
	public boolean init_opcode_name_keys()
	{
		int index = 0;
		while (index < OpNames.op_name.length) {
			if (   OpNames.op_name[index].length() > 4
				&& OpNames.op_name[index].substring(OpNames.op_name[index].length()-1).equals("?")) {
				// add alternate opcodes for ? = blank and A  RPI 1125
				if (find_key_index('O',OpNames.op_name[index].substring(0,OpNames.op_name[index].length()-1)) == -1) {
					if(!add_key_index(index)) {
						return false;
					}
				} else {
					return false;
				}
				if (find_key_index('O',OpNames.op_name[index].substring(0,OpNames.op_name[index].length()-1).concat("A")) == -1) {
					if(!add_key_index(index)) {
						return false;
					}
				} else {
					return false;
				}
			} else {
				if (find_key_index('O',OpNames.op_name[index]) == -1) {
					if(!add_key_index(index)) {
						return false;
					}
				} else {
					return false;
				}
			}
			index++;
		}
		return true;
	}

	/**
	 * Set pgm_dir, pgm_name, pgm_type from parameter. 
	 * Notes:
	 *   1.  Only allow file type override for MLC.
	 *   2.  Set lkd_ignore true if explicit .OBJ found RPI 735
	 * @param file_name
	 * @param file_type
	 * @return
	 */
	public boolean set_pgm_dir_name_type(String file_name,final String file_type)
	{
		lkd_ignore = false;
		if (file_name.charAt(0) == '\"'   // strip lsn quotes
				|| file_name.charAt(0) == '\'') {
			file_name = file_name.substring(1,file_name.length() - 1);
		}
		file_name = fix_file_separators(file_name); // RPI 1080
		int index = file_name.lastIndexOf(File.separator);
		if (index != -1) {  // get dir path if any
			dir_pgm = file_name.substring(0,index+1);
			file_name = file_name.substring(index + 1); // RPI 499 drop upper case
		} else if (file_name.length() > 1 && file_name.charAt(1) == ':') {
			File temp_file = new File(file_name.substring(0,2));
			try {
				dir_pgm = temp_file.getCanonicalPath() + File.separator;
			} catch (final Exception e) {
				return false;
			}
			file_name = file_name.substring(2); //RPI113
		} else {
			dir_pgm = dir_cur;
			// RPI 499 drop upper case file_name = file_name.toUpperCase();
		}
		index  = file_name.lastIndexOf(File.separator); // rpi 1210 
		int index1 = file_name.lastIndexOf('.');
		if (index1 > index){  // strip extension if any rpi 1210 
			pgm_name = file_name.substring(0,index1);
			if (file_name.substring(index1).toUpperCase().equals(".OBJ")){
				lkd_ignore = true;  // RPI 735 ignore LKD for link with explicit OBJ file
			}
			if (!file_type.equals(mlc_type)){ //RPI169
				pgm_type = file_type;
			} else {
				pgm_type = file_name.substring(index1); // RPI 1210
			}
		} else {
			pgm_name = file_name;
			pgm_type = file_type;
		}
		return true;
	}

	/**
	 * Reset op_code key table indexes changed by opsyn during previous pass if any.
	 */
	public void reset_opsyn()
	{
		int index = 0;
		while (index < tot_opsyn){
			opsyn_old_name[index] = opsyn_new_name[index]; // RPI 403
			index++;
		}
	}

	/**
	 * Update opsyn table as follows:
	 *   1.  Add new alias name for opcode
	 *   2.  Add null entry to cancel opcode  // RPI 306
	 *   3.  Restore opcode to previous alias and remove any cancel entry.  // RPI 404
	 * Notes:
	 *   1.  Indexes pointing to new name entries in opsyn table are only added once.
	 *   2,  az390 uses reset_opsyn() to reset old = new for multiple passes so opcodes prior to first
	 *       OPSYN statement will map to std. opcode. mz390 only makes one pass so its not an issue.
	 * @param new_name
	 * @param old_name
	 * @return
	 */
	public boolean update_opsyn(String new_name,String old_name)
	{
		int index = -1;
		if (old_name != null) {
			index = old_name.indexOf(" ");
			if (index > 0){  // RPI 306 remove comments
				old_name = old_name.substring(0,index).toUpperCase();
			}
			if (old_name.length() == 0 || old_name.charAt(0) == ',') {
				old_name = null;
			}
		}
		if (new_name == null || new_name.length() == 0) {
			return false;
		}
		new_name = new_name.toUpperCase();
		opsyn_index = find_key_index('R',new_name);
		if (opsyn_index == -1) {
			// defining new alias
			if (tot_opsyn < max_opsyn) {
				opsyn_index = tot_opsyn;
				tot_opsyn++;
				add_key_index(opsyn_index);
				opsyn_new_name[opsyn_index] = new_name;
			} else {
				return false;  // RPI 773
			}
		}
		if (old_name != null) {
			index = find_key_index('R', old_name);
			if (index != -1) {
				// replace old name with any previously saved opcode
				old_name = opsyn_old_name[index];
			}
			// save new and old opcodes
			opsyn_old_name[opsyn_index] = old_name;
		} else {
			opsyn_old_name[opsyn_index] = null; // RPI 331
		}
		return true;
	}

	/**
	 * Format int into 1-16 hex digit string.
	 * @param work_int
	 * @param req_hex_digits
	 * @return
	 */
	public String get_hex(final int work_int, final int req_hex_digits)
	{
		final String work_hex = Integer.toHexString(work_int);
		if (req_hex_digits <= 8 || (work_int >= 0 && req_hex_digits <= 16)){
			return ("0000000000000000" + work_hex).substring(work_hex.length() + 16 - req_hex_digits).toUpperCase();
		} else if (req_hex_digits >= 16 && work_int < 0){
			return ("FFFFFFFFFFFFFFFF" + work_hex).substring(work_hex.length() + 16 - req_hex_digits).toUpperCase();
		} else {
			return null; // force error
		}
	}

	/**
	 * Format long into 1-16 hex digit string.
	 * @param work_long
	 * @param req_hex_digits
	 * @return
	 */
	public String get_long_hex(final long work_long, final int req_hex_digits)
	{
		final String work_hex = Long.toHexString(work_long);
		if (req_hex_digits <= 16) {
			return ("0000000000000000" + work_hex).substring(work_hex.length() + 16 - req_hex_digits).toUpperCase();
		} else {
			return null; // force error
		}
	}

	/**
	 *  set sdt_char_int to value of character string else false
	 *  
	 *  C'....' EBCDIC/ASCII (rep ''|&& with'|&)
	 *  C"...." ASCII        (rep ""|''|&& with "|'|&)
	 *  C!....! EBCDIC       (rep !!|''|&& with !|'|&) 
	 *  CA'...' ASCII
	 *  CE'...' EBCDIC
	 * @param sdt
	 * @return
	 */
	public boolean get_sdt_char_int(final String sdt)
	{
		boolean ebcdic = true;
		int index = 2;
		int bytes = 0; // RPI 1205
		sdt_char_int = 0;
		char sdt_quote = '\'';
		char char_type = sdt.substring(1,2).toUpperCase().charAt(0); 
		switch (char_type){
		case 'A': // ASCII
			index = 3;
			ebcdic = false;
			break;
		case 'E': // EBCDIC
			index = 3;
			break;
		case '\'': // ASCII or EBCDIC based on opt_ASCII
			if (opt_ascii) {
				ebcdic = false;
			}
			break;
		case '"': // ASCII
			sdt_quote = '"';
			ebcdic = false;
			break;
		case '!': // EBCDIC
			sdt_quote = '!';
			break;
		}
		while (index < sdt.length()-1) {
			if (   sdt.charAt(index) == sdt_quote
				|| sdt.charAt(index) == '\''
				|| sdt.charAt(index) == '&'){  // RPI 274
				if (index + 1 < sdt.length()-1
					&& sdt.charAt(index+1) == sdt.charAt(index)) {
					index++;
				}
			}
			bytes++;
			if (bytes > 4) return false; // RPI 1205
			if (!ebcdic) { //RPI5  RPI 270
				sdt_char_int = (sdt_char_int << 8) + (sdt.charAt(index) & 0xff);
			} else {
				sdt_char_int = (sdt_char_int << 8) + (ascii_to_ebcdic[sdt.charAt(index)] & 0xff);
			}
			if (   index+1 == sdt.length()
				&& sdt.charAt(index) != sdt_quote){
				return false;
			}
			index++;
		}
		return true;
	}

	/**
	 * 1.  Verify ascii source code and length <= 80 if not * in col 1.
	 * @param temp_line
	 * @return
	 */
	public boolean verify_ascii_source(final String temp_line)
	{
		if (temp_line.length() > max_line_len) { // RPI 437
			return false;
		}
		int index = 0;
		while (index < temp_line.length()) {
			final int next_char = temp_line.charAt(index) & 0xff; // RPI 744
			if (   next_char != 9  // RPI 302
				&& next_char != '.' 
				&& ascii_table.charAt(next_char) == '.') {
				return false;
			}
			index++;
		}
		return true;
	}

	/**
	 * Return text left justified in field if field larger than text.
	 * @param text
	 * @param padded_len
	 * @return
	 */
	public String left_justify(final String text, final int padded_len)
	{
		if (text == null) {
			return "";
		}
		int pad_len = padded_len - text.length();
		if (pad_len > 0) {
			return text + pad_spaces(pad_len); // RPI 902
		} else {
			return text;
		}
	}

	/**
	 * Return n space characters.
	 * @param n
	 * @return
	 */
	public String pad_spaces(final int n) // RPI 902
	{
		if (n > pad_spaces_len) {
			init_pad_spaces(n);
		}
		return String.valueOf(pad_spaces,0,n);
	}

	/**
	 * Return text right justified in field if field larger than text.
	 * @param text
	 * @param padded_len
	 * @return
	 */
	public String right_justify(final String text, final int padded_len)
	{
		int pad_len = padded_len - text.length();
		if (pad_len > 0) {
			return pad_spaces(pad_len) + text; // RPI 902
		} else {
			return text;
		}
	}

	/**
	 * Initialize new pad_spaces byte array used by left and right justify.
	 * @param new_pad_len
	 */
	private void init_pad_spaces(final int new_pad_len)
	{
		pad_spaces_len = new_pad_len;
		if (pad_spaces_len < 4096) {
			pad_spaces_len = 4096;
		}
		pad_spaces = new char[pad_spaces_len];
		Arrays.fill(pad_spaces,0,pad_spaces_len,' ');
	}

	/**
	 * Return string with text duplicated dup_count times.
	 * @param text
	 * @param dup_count
	 * @return
	 */
	public String get_dup_string(final String text, final int dup_count)
	{
		if (dup_count <= 0) {
			return ""; // RPI 774
		}
		if (dup_char_len < dup_count) {
			dup_char_len = dup_count;
			if (dup_char_len < 4096) {
				dup_char_len = 4096;
			}
			dup_char = new char[dup_char_len];
		}
		final int tot_char = text.length() * dup_count;
		if (text.length() == 1) {
			Arrays.fill(dup_char,0,dup_count,text.charAt(0));
		} else {
			int rep = 0;
			while (rep < dup_count) {  // RPI 620
				System.arraycopy(text.toCharArray(), 0, dup_char, rep * text.length(), text.length());
				rep++;
			}
		}
		return String.valueOf(dup_char,0,tot_char);
	}

	/**
	 * Remove trailing spaces from non-continued source line.
	 * @param line
	 * @param max_text
	 * @return
	 */
	public String trim_trailing_spaces(final String line, final int max_text) // RPI 437
	{
		if (max_text > 0 && line.length() > max_text) {
			return ("X" + line.substring(0,max_text)).trim().substring(1);  //RPI124
		} else {
			return ("X" + line).trim().substring(1);
		}
	}

	/**
     * Trim line to comma delimiter or end of line recognizing whether line is continuation of 
     * quoted string or not..
	 * Notes:
	 *   1.  Allows ", " to appear in quotes which may be split across lines.
	 *   2.  Allow spaces within (...) on macro statements but not opcodes
	 *   3.  Handle quoted string continued on one or more continuation lines. RPI 463.
	 *   4.  Remove leading spaces from continuations.
	 * @param line
	 * @param first_line
	 * @param ictl_end
	 * @param ictl_cont
	 * @return
	 */
	public String trim_continue(final String line, final boolean first_line, final int ictl_end, final int ictl_cont)
	{
		int index;
		int eol_index = line.length();
		if (eol_index >= ictl_end+1){  // RPI 728
			eol_index = ictl_end; // RPI 315 // RPI 728
		}
		if (first_line){
			split_level = 0;
			split_quote = false;      // RPI115
			split_quote_text = "";
			split_quote_last = false; // RPI 463
			if (line.charAt(0) == '*'){
				split_comment = true;
				return line.substring(0,eol_index); // RPI 313 don't look in comments
			} else {
				split_comment = false;
			}
			split_line(line);
			if (split_op != null){
				split_op_index = find_key_index('O',split_op.toUpperCase());
				if (split_op_index >= 0){
					split_op_type = OpTypes.op_type[split_op_index];
				} else {
					split_op_type = -1;
				}
				if (split_parms_index != -1){
					split_quote_text = line.substring(0,split_parms_index);
				}
				if (split_op.equals("EXEC")){ // RPI 905
					exec_line = true;
				} else {
					exec_line = false;
				}
			} else {
				split_op_index = -1;
				split_op_type  = -1;
			}
		} else {
			// continued line
			if (split_comment){
				if (line.length() > 16){
					return line.substring(15,eol_index); // RPI 463
				} else {
					return line.substring(0,eol_index);
				}
			}
			if (line.length() >= ictl_cont){     // RPI 728
				split_parms_index = ictl_cont-1; // RPI 728
				split_quote_text = "";
				if (split_quote){  // RPI 463
					index = line.substring(split_parms_index,eol_index).indexOf('\'');
					while (index != -1 && split_quote){
						if (index == -1){
							return split_quote_text + line.substring(split_parms_index,eol_index);
						} else {
							if (index < eol_index - 1){
								if (line.charAt(index+1) != '\''){
									split_quote = false;
									split_quote_text = split_quote_text + line.substring(split_parms_index,split_parms_index + index+1);
									split_parms_index = split_parms_index + index+1;
								} else {
									split_quote_text = split_quote_text + line.substring(split_parms_index,split_parms_index + index+2);
									split_parms_index = split_parms_index + index+2; // skip double quotes in quoted string
								}
							} else {
								split_quote_last = true;
								split_quote = false;
								return split_quote_text + line.substring(split_parms_index,eol_index);
							}
						}
					}
				}
			} else {
				split_parms_index = -1;		
			}
		}
		if (split_parms_index == -1){
			return line.substring(0,eol_index); // return line if no parms
		}
		parm_match = parm_pattern.matcher(line.substring(split_parms_index));
		index = 0;
		boolean split_parm_end = false;
		while (!split_parm_end && parm_match.find()){
			String parm = parm_match.group();
			index = parm_match.start();
			switch (parm.charAt(0)){
			case ',':
				if ((split_op_type < max_asm_type 
						|| split_level == 0) // RPI 315 allow ,space within (...) for mac ops 
						&& !split_quote 
						&& line.length() > split_parms_index + index+1
						&& line.charAt(split_parms_index + index+1) <= ' '){  //RPI181
					// truncate line to , delimter found
					eol_index = split_parms_index + index +1;
					return split_quote_text + line.substring(split_parms_index,eol_index); // RPI 313
				}
				break;
			case '\'': // single quote found 
				if (parm.length() == 1){  // rpi 463
					if (!split_quote){
						split_quote = true;
						split_parm_end = true;
					} else {
						split_quote = false;
					}
				}
				break;
			case '(': // RPI 315
				if (!split_quote)split_level++;
				break;
			case ')': // RPI 315
				if (!split_quote)split_level--;
				break;
			default: // check for ending white space
				if (parm.charAt(0) <= ' '
				&& !split_quote
				&& (split_op_type < max_asm_type 
						|| split_level == 0) // RPI 315 allow ,space within (...) for mac ops 	
				&& !exec_line // rpi 905   
						){
					split_parm_end = true; // force end
				}
			}
		}
		return split_quote_text + line.substring(split_parms_index,eol_index); // return line with no comma,space
	}

	/**
	 * Split line into 4 strings:
	 *   split_label
	 *   split_op
	 *   split_parms 
	 * using precompiled pattern  RPI 313
	 * 
	 * 4 fields are null if none
	 * @param line
	 */
	public void split_line(final String line)  // RPI 313
	{
		split_label = null;
		split_op    = null;
		split_parms = null;
		if (line == null || line.length() == 0) {
			return;
		}
		find_parm_match = find_non_space_pattern.matcher(line);
		if (line.charAt(0) > ' ') {
			find_parm_match.find();
			split_label = find_parm_match.group();
		}
		if (find_parm_match.find()) {
			split_op = find_parm_match.group().toUpperCase(); // RPI 532
			split_op_index = find_parm_match.start();
			if (find_parm_match.find()) {
				split_parms_index = find_parm_match.start();
				split_parms = line.substring(split_parms_index);
			} else {
				split_parms_index = -1;
			}
		}
	}

	/**
	 * Return first directory in list.
	 * @param dirs
	 * @return
	 */
	public String get_first_dir(final String dirs)
	{
		String first_dir;
		int index_first = dirs.indexOf("+");
		if (index_first == -1) {
			index_first = dirs.indexOf(";");
		}
		if (index_first != -1) { // RPI 378
			first_dir = dirs.substring(0,index_first);
		} else {
			first_dir = dirs;
		}
		if (first_dir.charAt(first_dir.length()-1) != File.separator.charAt(0)) {
			first_dir = first_dir + File.separator;
		}
		return first_dir;
	}

	/**
	 * Open trace file if trace options on for M, A, L, E.
	 * @param text
	 */
	public void put_trace(String text)
	{
		if (   text != null 
			&& text.length() > 13
			&& text.substring(0,6).equals(text.substring(7,13))) { // RPI 659
			text = text.substring(7); // RPI 515 RPI 659
		}
		if (!force_nocon &&(opt_con || opt_test)) {  // RPI 689 RPI 935
			System.out.println(text);
		}
		if (trace_file == null) {
			try {
				trace_file = new File(trace_file_name);
				trace_file_buff = new BufferedWriter(new FileWriter(trace_file));
				put_trace(started_msg); // RPI 755 RPI 1149 
			} catch (final Exception e) {
				abort_error(16, "trace file open failed - " + e.toString());
			}
		}
		try {
			if (opt_ts) {
				text = get_timestamp() +  text; // RPI 662
			}
			trace_file_buff.write(text + newline); // RPI 500
		} catch (final Exception e) {
			abort_error(17, "trace file write error " + e.toString());
		}
		if (trace_file.length() > max_file_size) {
			abort_error(18, "maximum trace file size exceeded"); // RPI 731
		}
	}

	/**
	 * 1.  inc cur_bal_line_num by 1 plus previous continuations.
	 * 2.  Set number of continuation lines for next call.
	 * @param text_line
	 */
	public void inc_cur_bal_line_num(final String text_line)
	{
		if (text_line == null) return;

		cur_bal_line_num = cur_bal_line_num + 1 + prev_bal_cont_lines;
		if (text_line != null && text_line.length() > 71){ // RPI 415 adj for continuations for xref
			prev_bal_cont_lines = 1 + (text_line.length()-72)/56;	
		} else {
			prev_bal_cont_lines = 0; // RPI 550
		}
	}

	/**
	 * return unique BAL line id consisting of:  // RPI 549
	 *   1.  FID file id number (See list of files in stats at end of BAL)
	 *   2.  FLN file Line number within file
	 *   3.  GSN Generated statement number for BAL line
	 *   4.  Type code
	 *       ' ' main source code
	 *       '+' generated macro code
	 *       '=' included copybook code
	 * Notes:
	 *   1.  If FLN is 0 only GSN is returned for az standalone mode.
	 *   2.  If GSN is 0 only (FID/FLN) is returned for mz trace..
	 * @param file_num
	 * @param file_line_num
	 * @param bal_line_num
	 * @param mac_gen
	 * @param line_type
	 * @return
	 */
	public String get_cur_bal_line_id(int file_num, int file_line_num, int bal_line_num, boolean mac_gen, char line_type)
	{
		if (file_line_num == 0) {
			return right_justify("" + bal_line_num + line_type,10);
		}
		if (bal_line_num == 0) {
			return right_justify("(" + (file_num+1)
					+ "/" + file_line_num
					+ ")"
					+ line_type,10); // RPI 549
		}
		if (line_type == ' ' && mac_gen){ // RPI 891 
			line_type = '+'; // RPI 581 inline macro generated code
		}
		return right_justify("(" + (file_num+1)
				+ "/" + file_line_num
				+ ")" + bal_line_num 
				+ line_type,15); // RPI 549
	}

	/**
	 *  Return the directory containing the jar file 
	 *  (Contributed by Martin Ward)
	 * @return
	 */
	public String jar_file_dir()
	{
		/*
		 */
		final StringBuffer path = new StringBuffer(System.getProperty("java.class.path"));
		// Delete everything from the last directory separator onwards:
		path.delete(path.lastIndexOf(File.separator), path.length());
		return path.toString();
	}

	/**
	 * Store binary DD,ED, or LD format in fp_work_reg.  Return true if value within range.
	 * Notes:
	 *   1.  Set DFP exponent to explicit decimal point else preferred exponent is 0.
	 * @param dfp_type
	 * @param dfp_bd
	 * @return
	 */
	public boolean fp_get_dfp_bin(int dfp_type,BigDecimal dfp_bd)
	{
		// round to specified precision using default

		// get digits and power of 10 exponent
		if (dfp_bd.signum() == 0) {
			fp_work_reg.putLong(0,0);
			fp_work_reg.putLong(8,0);
			return true; 
		}
		dfp_digits = dfp_bd.toString().toUpperCase();
		dfp_dec_index = dfp_digits.indexOf('.');
		dfp_exp_index = dfp_digits.indexOf('E');
		dfp_exp = 0;
		dfp_scf = 0;
		if (dfp_exp_index != -1) {
			dfp_exp = Integer.valueOf(dfp_digits.substring(dfp_exp_index+2));
			if (dfp_digits.charAt(dfp_exp_index+1) == '-') {
				dfp_exp = - dfp_exp;
			}
			if (dfp_dec_index != -1) {
				dfp_exp = dfp_exp - (dfp_exp_index - dfp_dec_index - 1); // adjust exp 
				dfp_digits = dfp_digits.substring(0,dfp_dec_index) + dfp_digits.substring(dfp_dec_index+1,dfp_exp_index);
			} else {
				dfp_digits = dfp_digits.substring(0,dfp_exp_index);
			}
		} else {
			if (dfp_dec_index != -1) {
				dfp_exp = dfp_exp - (dfp_digits.length() - dfp_dec_index - 1); // adjust exp
				dfp_digits  = dfp_digits.substring(0,dfp_dec_index) 
							+ dfp_digits.substring(dfp_dec_index+1);
			}
		}
		// strip leading zeros
		int index = 0;
		int limit = dfp_digits.length() - 1;
		while (index < limit 
				&& dfp_digits.charAt(index) == '0'){
			index++;
		}
		if (index > 0){
			dfp_digits = dfp_digits.substring(index);
		}
		dfp_exp = dfp_exp + fp_exp_bias[dfp_type];
		if (dfp_exp < 0
				|| dfp_exp > fp_exp_max[dfp_type]){
			return false;
		}
		// calc cf, bxcf, and ccf and return hex
		switch (dfp_type) {
		case 1: // fp_dd_type s1,cf5,bxcf6,ccf20
			dfp_digits = ("0000000000000000" + dfp_digits).substring(dfp_digits.length());
			int cf5_index =   (dfp_exp & 0x300) >>> 4 
							| (dfp_digits.charAt(0) & 0xf); // RPI 820
			if (cf5_index > dfp_exp_bcd_to_cf5.length){
				cf5_index = dfp_exp_bcd_to_cf5.length-1; // RPI 820
			}
			dfp_scf = fp_sign | dfp_exp_bcd_to_cf5[cf5_index]; // RPI 820
			fp_work_reg.putLong(0,
								(long)dfp_scf << 58 
								| (long)(dfp_exp & 0xff) << 50
								| get_dfp_ccf_digits(16,1,15));
			return true;
		case 4: // fp_ed_type s1,cf5,bxcf8,ccf50
			dfp_digits = ("0000000" + dfp_digits).substring(dfp_digits.length());
			cf5_index =   (dfp_exp & 0xc0) >>> 2 
						| (dfp_digits.charAt(0) & 0xf); // RPI 1211 
			if (cf5_index >= dfp_exp_bcd_to_cf5.length){
				cf5_index = dfp_exp_bcd_to_cf5.length-1; // RPI 820
			}
			dfp_scf = fp_sign | dfp_exp_bcd_to_cf5[cf5_index];
			fp_work_reg.putInt(0,
							(int)(dfp_scf << 26
							| ((dfp_exp & 0x3f) << 20
							| (int)get_dfp_ccf_digits(7,1,6)
				)));
			return true;
		case 7: // fp_ld_type s1,cf5,bxdf12,ccf110
			dfp_digits = ("0000000000000000000000000000000000" + dfp_digits).substring(dfp_digits.length());
			cf5_index = (dfp_exp & 0x3000) >>> 8 | (dfp_digits.charAt(0) & 0xf); // RPI 820
			if (cf5_index >= dfp_exp_bcd_to_cf5.length){
				cf5_index = dfp_exp_bcd_to_cf5.length-1; // RPI 820
			}
			dfp_scf = fp_sign | dfp_exp_bcd_to_cf5[cf5_index]; // RPI 820
			long dfp_ccf1 = get_dfp_ccf_digits(34,1,15);
			fp_work_reg.putLong(0,
							(long)dfp_scf << 58 
							| (long)(dfp_exp & 0xfff) << 46
							| dfp_ccf1 >>> 4);
			fp_work_reg.putLong(8,
							(long)(dfp_ccf1 & 0xf) << 60
							| get_dfp_ccf_digits(34,16,18));
			return true;
		}
		return false;
	}

	/**
	 * Return long with 1 to 6 DPD densly packed decimal truples of 10 bits representing 3 digits.
	 * @param tot_digits
	 * @param digit_offset
	 * @param digit_count
	 * @return
	 */
	private long get_dfp_ccf_digits(int tot_digits,int digit_offset, int digit_count)
	{
		long dfp_bits = 0;
		int index = digit_offset;
		while (index < digit_offset + digit_count){
			dfp_bits = (dfp_bits << 10) | dfp_bcd_to_dpd[Integer.valueOf(dfp_digits.substring(index,index+3))];
			index = index + 3;
		}
		return dfp_bits;
	}

	/**
	 * Return current JDBC time stamp string with 9 digit fractional nanosecond forrmat:
	 * yyyy-mm-dd hh:mm:ss.nnnnnnnnn (29 characters)
	 * 
	 * Note only the first 3 millisecond digits are returned by current JDBC TimeStamp
	 * constructor so System.nanotime() method is used to add remaining 6 digits of nanosecond fraction.
	 * @return
	 */
	public String get_timestamp()  // RPI 662
	{
		ts_nano_now    = System.nanoTime();
		ts_mic_dif     = (ts_nano_now - ts_nano_start)/1000000;
		ts_mic_now     = ts_mic_start + ts_mic_dif;
		ts_nano_digits = "" + (ts_nano_now - (ts_nano_start + ts_mic_dif * 1000000));
		return (new Timestamp(ts_mic_now).toString() + "000").substring(0,23)
				+ ("000000" + ts_nano_digits).substring(ts_nano_digits.length())
				+ " ";
	}

	/**
	 * Set max_main_height and max_main_width.
	 */
	public void get_window_size()
	{
		int start_bar_height = 36; //windows start bar
		try {
			max_main_height = GraphicsEnvironment.getLocalGraphicsEnvironment().getScreenDevices()[0].getDisplayMode().getHeight()
					- start_bar_height;
			max_main_width = GraphicsEnvironment.getLocalGraphicsEnvironment().getScreenDevices()[0].getDisplayMode().getWidth();
		} catch (final Exception e) {
		}
	}

	/**
	 * Turn on ERRSUM option either by user request or
	 * if missing COPY or MACRO error detected during pass 1 of az390.
	 * Note:
	 *   1.  ASM required
	 *   2.  Any error limit can prevent finding all the missing copybooks and macros
	 *       due to pre-mature abort on error limit.
	 *       There may still be additional nesting missing macros and copybooks requiring multiple
	 *       passes after including missing files listed.
	 */
	public void init_errsum()
	{
		if (opt_asm) {
			opt_errsum = true;
			max_errors = 0;
		} else {
			abort_error(30,"ERRSUM requires option ASM");
		}
	}

	/**
	 * Return printable ASCII char from byte. RPI 947
	 * @param mem_byte
	 * @return
	 */
	public char ascii_printable_char(final int mem_byte)
	{
		if (opt_ascii) {
			return ascii_table.charAt(mem_byte & 0xff);
		} else {
			return ebcdic_table.charAt(mem_byte & 0xff);
		}
	}

	/**
	 * Return printable ascii string from string that may have non-printable ascii codes. RPI 938
	 * @param text
	 * @return
	 */
	public String ascii_printable_string(final String text)
	{
		int index = 0;
		String ascii_text = "";
		while (index < text.length()){
			ascii_text = ascii_text + ascii_table.charAt((byte)text.charAt(index) & 0xff);
			index++;
		}
		return ascii_text;
	}

	/**
	 * Return printable ASCII string from byte array. RPI 947
	 * @param byte_array
	 * @param addr
	 * @param len
	 * @return
	 */
	public String get_ascii_printable_string(byte[] byte_array, int addr, int len)
	{
		int index = 0;
		String text = "";
		while (index < len) {
			if (opt_ascii){
				text = text + ascii_table.charAt(byte_array[addr+index] & 0xff);
			} else {
				text = text + ebcdic_table.charAt(byte_array[addr+index] & 0xff);
			}
			index++;
		}
		return text;
	}

	/**
	 * Return ASCII variable length string delimited by null or double quotes which
	 * are stripped off along with leading or trailing spaces.
	 * @param byte_array
	 * @param mem_addr
	 * @param max_len
	 * @return
	 */
	public String get_ascii_var_string(byte[] byte_array,int mem_addr,int max_len)
	{
		String text = "";
		int index = 0;
		while (index < max_len){
			byte data_byte = byte_array[mem_addr+index];
			char data_char;
			if (opt_ascii){
				data_char = ascii_table.charAt(data_byte & 0xff); // RPI 1069
			} else {
				data_char = ascii_table.charAt(ebcdic_to_ascii[data_byte & 0xff] & 0xff); //RPI42 RPI 1069
			}
			if (data_byte == 0){
				break;
			}
			if (data_char == '"'){
				if (index != 0){
					break;
				}
			} else {
				text = text + data_char;
			}
			index++;
		}
		return text.trim();  //RPI111
	}

	/**
	 * Append msg to visible log textarea and reduce size by 50% when it exceeds opt_maxlog byte limit.
	 * @param log_text
	 * @param msg
	 */
	public void log_text_append(JTextArea log_text, String msg)
	{
		tot_log_msg++;
		if (tot_log_text > opt_maxlog){
			log_text.replaceRange(" Z390 visible log truncated at msg #" + tot_log_msg + "\n",0,opt_maxlog/2);
			tot_log_text = tot_log_text - opt_maxlog/2;
		}
		tot_log_text = tot_log_text + msg.length() + 1;
		log_text.append(msg + "\n");
		log_text_added = true;
	}

	/**
	 * Sleep for 1 monitor wait interval.
	 * @param mills
	 */
	public void sleep_now(final long mills)
	{
		try {
			Thread.sleep(mills);
		} catch (final Exception e) {
			z390_abort = true;
			System.out.println("TZ390E thread sleep error - " + e.toString());
			Thread.yield();
		}
	}

	/**
	 * 1.  if new path starts with +, concat with existing path else replace existing path option.
	 * @param old_path
	 * @param new_path
	 * @return
	 */
	private String set_path_option(String old_path,String new_path)
	{
		if (new_path.charAt(0) == '+') {
			return old_path + new_path;
		} else {
			return new_path; 
		}
	}

	/**
	 * List final value of all changed options on stats file.
	 */
	public void put_stat_final_options()
	{
		// Option flags
		cmd_parms_len = 21 + systerm_prefix.length();
		if (opt_align){ // rpi 1073
			add_final_opt("ALIGN");
		} else {
			add_final_opt("NOALIGN");
		}
		if (opt_allow){ // rpi 833 allow HLASM extensions
			add_final_opt("ALLOW");
		} else {
			add_final_opt("NOALLOW");
		}
		if (opt_amode24 ){ // link to run amode24
			add_final_opt("AMODE24");
		} else {
			add_final_opt("NOAMODE24");
		}
		if (opt_amode31 ){ // link to run amode31
			add_final_opt("AMODE31");
		} else {
			add_final_opt("NOAMODE31");
		}
		if (opt_ascii   ){ // use ascii vs ebcdic
			add_final_opt("ASCII");
		} else {
			add_final_opt("NOASCII");
		}
		if (opt_asm     ){ // run az390 assembler as mz390 subtask  RPI 415
			add_final_opt("ASM");
		} else {
			add_final_opt("NOASM");
		}
		if (opt_assist     ){ // assemble and emulate ASSIST instr. RPI 812
			add_final_opt("ASSIST");
		} else {
			add_final_opt("NOASSIST");
		}
		if (opt_autolink){ // search for external ref. in linklib RPI 822
			add_final_opt("AUTOLINK");
		} else {
			add_final_opt("NOAUTOLINK");
		}
		if (opt_bal     ){ // generate bal source output from mz390 RPI 415
			add_final_opt("BAL");
		} else {
			add_final_opt("NOBAL");
		}
		if (opt_bs2000  ){ // Seimens BS2000 asm compatibility
			add_final_opt("BS2000");
		} else {
			add_final_opt("NOBS2000");
		}
		if (opt_edf){ // exec cics program honoring prolog,epilog
			add_final_opt("EDF");
		} else {
			add_final_opt("NOEDF");
		}
		if (opt_cics    ){ // exec cics program honoring prolog,epilog
			add_final_opt("CICS");
		} else {
			add_final_opt("NOCICS");
		}
		if (codepage.length() > 0){ // codepage(ascii,ebcdic,list)
			add_final_opt(codepage);
		} else {
			add_final_opt("NOCODEPAGE");
		}
		if (opt_comment){ // zcobol source comments in MLC
			add_final_opt("COMMENT");
		} else {
			add_final_opt("NOCOMMENT");
		}
		if (opt_con     ){ // log msgs to console
			add_final_opt("CON");
		} else {
			add_final_opt("NOCON");
		}
		if (opt_dump    ){ // only indicative dump on abend unless on
			add_final_opt("DUMP");
		} else {
			add_final_opt("NODUMP");
		}
		if (opt_epilog  ){ // if cics, insert DFHEIRET
			add_final_opt("EPILOG");
		} else {
			add_final_opt("NOEPILOG");
		}
		if (opt_errsum  ){ // just list critical errors and summary on ERR file and console 
			add_final_opt("ERRSUM");
		} else {
			add_final_opt("NOERRSUM");
		}
		if (opt_extend){ // allow 31 digit P and Z in zcobol 
			add_final_opt("EXTEND");
		} else {
			add_final_opt("NOEXTEND");
		}
		add_final_opt("FLOAT(" + opt_float + ")");
		if (opt_guam    ){ // use gz390 GUAM GUI access method interface
			add_final_opt("GUAM");
		} else {
			add_final_opt("NOGUAM");
		}
		if (opt_init    ){ // init regs x'F4' and mem x'F5' vs 0's
			add_final_opt("INIT");  // RPI 828
		} else {
			add_final_opt("NOINIT");
		}
		if (opt_list    ){ // generate LOG file
			add_final_opt("LIST");
		} else {
			add_final_opt("NOLIST");
		}
		if (opt_listcall){ // list macro calls
			add_final_opt("LISTCALL");
		} else {
			add_final_opt("NOLISTCALL");
		}
		if (opt_listuse ){ // list usage at USING and DROP
			add_final_opt("LISTUSE");
		} else {
			add_final_opt("NOLISTUSE");
		}
		if (opt_loadhigh){ // load pgms and alloc storage from top down
			add_final_opt("LOADHIGH");
		} else {
			add_final_opt("NOLOADHIGH");
		}
		if (opt_mcall   ){ // list MCALL and MEXIT on PRN // RPI 511
			add_final_opt("MCALL");
		} else {
			add_final_opt("NOMCALL");
		}
		if (opt_mod){ // generate code file from lz390 with no header/trailer, no rounding, no RLD's RPI 883
			add_final_opt("MOD");
		} else {
			add_final_opt("NOMOD");
		}
		if (opt_obj     ){ // generate binary MVS compatible OBJ file RPI 694
			add_final_opt("OBJ");
		} else {
			add_final_opt("NOOBJ");
		}
		if (opt_objhex  ){ // generate ascii hex obj records (lz390 accepts bin or hex)
			add_final_opt("OBJHEX");
		} else {
			add_final_opt("NOOBJHEX");
		}
		if (opt_pc      ){ // generate macro pseudo code
			add_final_opt("PC");
		} else {
			add_final_opt("NOPC");
		}
		if (opt_pcopt   ){ // optimize pc code for speed
			add_final_opt("PCOPT");
		} else {
			add_final_opt("NOPCOPT");
		}
		if (opt_pdsmem8){ // optimize pc code for speed
			add_final_opt("PDSMEM8");
		} else {
			add_final_opt("NOPDSMEM8");
		}
		if (opt_printall){ // force printing all source on PRN RPI 1127
			add_final_opt("PRINTALL");
		} else {
			add_final_opt("NOPRINTALL");
		}
		if (opt_prolog  ){ // if cics, insert DFHEIBLK and DFHEIENT
			add_final_opt("PROLOG");
		} else {
			add_final_opt("NOPROLOG");
		}
		if (opt_protect ){ // prevent PSA mods by user
			add_final_opt("PROTECT");
		} else {
			add_final_opt("NOPROTECT");
		}
		if (opt_r64){ // RPI 986 allow 64 bit register usage
			add_final_opt("R64");
		} else {
			add_final_opt("NOR64");
		}
		if (opt_reformat){ // reformat BAL statements
			add_final_opt("REFORMAT");
		} else {
			add_final_opt("NOREFORMAT");
		}
		if (opt_regs    ){ // show registers on trace
			add_final_opt("REGS");
		} else {
			add_final_opt("NOREGS");
		}
		if (opt_rmode24 ){ // link to load below line
			add_final_opt("RMODE24");
		} else {
			add_final_opt("NORMODE24");
		}
		if (opt_rmode31 ){ // link to load above line
			add_final_opt("RMODE31");
		} else {
			add_final_opt("NORMODE31");
		}
		if (opt_stats   ){ // show statistics on STA file
			add_final_opt("STATS");
		} else {
			add_final_opt("NOSTATS");
		}
		if (opt_test    ){ // invoke interactive test cmds
			add_final_opt("TEST");
		} else {
			add_final_opt("NOTEST");
		}
		if (opt_thread  ){ // continuous loc ctr RPI 1186
			add_final_opt("THREAD");
		} else {
			add_final_opt("NOTHREAD");
		}
		if (opt_time    ){ // abend 422 if out of time TIME (sec)
			add_final_opt("TIME");
		} else {
			add_final_opt("NOTIME");
		}
		if (opt_timing  ){ // display current date, time, rate
			add_final_opt("TIMING");
		} else {
			add_final_opt("NOTIMING");
		}
		if (opt_trace   ){ // trace(e) trace ez390 to TRE
			add_final_opt("TRACE");
		} else {
			add_final_opt("NOTRACE");
		}
		if (opt_tracea  ){ // trace(a) az390 assembler to TRA
			add_final_opt("TRACEA");
		} else {
			add_final_opt("NOTRACEA");
		}
		if (opt_traceall){ // trace(aeglmpqtv) trace all TRM,TRA,TRL,TRE
			add_final_opt("TRACEALL");
		} else {
			add_final_opt("NOTRACEALL");
		}
		if (opt_tracec){ // trace(aceglmpqtv) trace all TRM,TRA,TRL,TRE
			add_final_opt("TRACEC"); // RPI 862
		} else {
			add_final_opt("NOTRACEC");
		}
		if (opt_traceg  ){ // trace(g) memory FQE updates to TRE
			add_final_opt("TRACEG");
		} else {
			add_final_opt("NOTRACEG");
		}
		if (opt_tracei  ){ // RPI 1157
			add_final_opt("TRACEI");
		} else {
			add_final_opt("NOTRACEI");
		}
		if (opt_tracel  ){ // trace(L) lz390 to TRL
			add_final_opt("TRACEL");
		} else {
			add_final_opt("NOTRACEL");
		}
		if (opt_tracem  ){ // trace mz390 to TRM
			add_final_opt("TRACEM");
		} else {
			add_final_opt("NOTRACEM");
		}
		if (opt_tracep  ){ // trace mz390 pseudo code to TRM
			add_final_opt("TRACEP");
		} else {
			add_final_opt("NOTRACEP");
		}
		if (opt_traceq  ){ // trace(q) QSAM file I/O to TRE
			add_final_opt("TRACEQ");
		} else {
			add_final_opt("NOTRACEQ");
		}
		if (opt_traces  ){ // trace(s) show MLC source and errors on console
			add_final_opt("TRACES");
		} else {
			add_final_opt("NOTRACES");
		}
		if (opt_tracet  ){ // trace(t) TCPIO and TGET/TPUT I/O to TRE
			add_final_opt("TRACET");
		} else {
			add_final_opt("NOTRACET");
		}
		if (opt_tracev  ){ // trace(v) VSAM file I/O to TRE
			add_final_opt("TRACEV");
		} else {
			add_final_opt("NOTRACEV");
		}
		if (opt_trap    ){ // trap exceptions as 0C5
			add_final_opt("TRAP");
		} else {
			add_final_opt("NOTRAP");
		}
		if (opt_trunc    ){ // truncate COMP to PIC digits
			add_final_opt("TRUNC");
		} else {
			add_final_opt("NOTRUNC");
		}
		if (opt_ts      ){ // time-stamp logs RPI 662
			add_final_opt("TS");
		} else {
			add_final_opt("NOTS");
		}
		if (opt_vcb     ){ // vsam cache operational
			add_final_opt("VCB");
		} else {
			add_final_opt("NOVCB");
		}
		if (opt_warn     ){ // zcobol mnote level 4 warnings
			add_final_opt("WARN");
		} else {
			add_final_opt("NOWARN");
		}
		if (opt_xref    ){ // cross reference symbols
			add_final_opt("XREF");
		} else {
			add_final_opt("NOXREF");
		}
		if (opt_zstrmac){ // allow ZSTRMAC structured macro extensions
			add_final_opt("ZSTRMAC");
		} else {
			add_final_opt("NOZSTRMAC");
		}
		// option limits
		add_final_opt("CHKMAC=" + opt_chkmac); // RPI 747 0-none,1-labels, 2-labels and src after MEND
		add_final_opt("CHKSRC=" + opt_chksrc); // RPI 747 0-none,1-MLC only,2-all
		add_final_opt("ERR=" + max_errors);
		add_final_opt("MAXCALL=" + opt_maxcall);
		add_final_opt("MAXDISPLAY=" + opt_maxdisplay); // RPI 1131
		add_final_opt("MAXESD=" + opt_maxesd);
		add_final_opt("MAXFILE=" + opt_maxfile);
		add_final_opt("MAXGBL=" + opt_maxgbl);
		add_final_opt("MAXHEIGHT=" + max_main_height);
		add_final_opt("MAXLCL=" + opt_maxlcl);
		add_final_opt("MAXLEN=" + max_line_len);
		add_final_opt("MAXLINE=" + opt_maxline);
		add_final_opt("MAXLOG=" + opt_maxlog); // max gui log before trunc
		add_final_opt("MAXPARM=" + opt_maxparm);
		add_final_opt("MAXPASS=" + opt_maxpass); // RPI 920
		add_final_opt("MAXPC=" + opt_maxpc); // pseudo code cache size
		add_final_opt("MAXQUE=" + opt_maxque); // max cmd out before trunc
		add_final_opt("MAXRLD=" + opt_maxrld);
		add_final_opt("MAXSIZE=" + max_file_size);
		add_final_opt("MAXSYM=" + opt_maxsym);
		add_final_opt("MAXWARN=" + max_mnote_warning);
		add_final_opt("MAXWIDTH=" + max_main_width);
		add_final_opt("MEM=" + max_mem);
		add_final_opt("MINHEIGHT=" + min_main_height);
		add_final_opt("MINWIDTH=" + min_main_width);
		add_final_opt("MNOTE=" + opt_mnote); // RPI 1142
		add_final_opt("PARM=" + opt_parm);
		add_final_opt("PROFILE=" + opt_profile);
		add_final_opt("STATS=" + stats_file_name);
		add_final_opt("SYSPARM=" + opt_sysparm);
		add_final_opt("SYSTERM=" + systerm_file_name);
		add_final_opt("TESTDD=" + test_ddname);
		add_final_opt("TIME=" + max_time_seconds);
		add_final_opt("TRACE=" + trace_options);
		add_final_opt("Z390ACROBAT=" + infoOS.get_z390_acrobat());
		add_final_opt("Z390BROWSER=" + infoOS.get_z390_browser());
		add_final_opt("Z390COMMAND=" + infoOS.get_z390_command());
		add_final_opt("Z390EDITOR="  + infoOS.get_z390_editor() );
		// option directories and files
		add_final_opt("INSTALL=" + opt_install_loc);
		add_final_opt("IPL=" + opt_ipl);
		add_final_opt("LOG=" + log_file_name);
		add_final_opt("SYS390=" + dir_390); // SYS390() load module
		add_final_opt("SYSBAL=" + dir_bal); // SYSBAL() az390 source input
		add_final_opt("SYSCPY=" + dir_cpy); // SYSCPY() mz390 copybook lib defaults to dir_mac RPI 742
		add_final_opt("SYSDAT=" + dir_dat); // SYSDAT() mz390 AREAD extended option
		add_final_opt("SYSERR=" + dir_err); // SYSERR() ?z390 systerm error file directory
		add_final_opt("SYSLOG=" + dir_log); // SYSLOG() ez390 log // RPI 243
		add_final_opt("SYSLST=" + dir_lst); // SYSLST() lz390 listing 
		add_final_opt("SYSMAC=" + dir_mac); // SYSMAC() mz390 macro lib
		add_final_opt("SYSMLC=" + dir_mlc); // SYSMLC() mz390 source input
		add_final_opt("SYSPCH=" + dir_pch); // SYSPCH() mz390 punch output dir
		add_final_opt("SYSPRN=" + dir_prn); // SYSPRN() az390 listing
		add_final_opt("SYSOBJ=" + dir_obj); // SYSOBJ() lz390 object lib
		add_final_opt("SYSOPT=" + dir_opt); // SYSOPT() OPT options @file path defaults to dir_mac RPI 742
		add_final_opt("SYSTRC=" + dir_trc); // SYSTRC() trace file directory
	}

	/**
	 * Add final option value to final_option formatted string.
	 * @param token
	 */
	private void add_final_opt(String token)
	{
		while (token.length() > max_cmd_parms_line - 2){
			put_stat_line("final options=" + token.substring(0,max_cmd_parms_line - 2));
			token = token.substring(max_cmd_parms_line - 2);
		}
		if (token.length() > 0){
			put_stat_line("final_options=" + token);
		}
	}

	/**
	 * Abort case with invalid index RPI 849 used by pz390, mz390.
	 */
	public synchronized void abort_case() // RPI 646
	{
		abort_error(22,"internal error - invalid case index");
	}

	/**
	 * Return MM/DD/YY or constant if notiming
	 * @return
	 */
	public String cur_date()
	{
		if (opt_timing) {
			return sdf_MMddyy.format(new Date());
		} else {
			return "MM/DD/YY";
		}
	}

	/**
	 * Return HH:MM:SS with or without space or 0 length string if notiming.
	 * @param space_pad
	 * @return
	 */
	public String cur_time(final boolean space_pad)
	{
		if (opt_timing) {
			if (space_pad) {
				return sdf_HHmmss.format(new Date()) + " ";
			} else {
				return sdf_HHmmss.format(new Date());
			}
		} else {
			return "";
		}
	}

	/**
	 * initialize ascii and ebcdic translate tables 
	 * using specified Unicode codepages.  If list is on display
	 * mapping between ascii Unicode table and the corresponding
	 * ascii and ebcdic byte values in hex and list available  ascii
	 * and ebcdic charset codepages.  If either of the names are
	 * not valid, a list of the current ascii default and all 
	 * available Charset codepages will be listed.  The two
	 * codepages will be verified to have the required minimum
	 * ebcdic code mapping for z390 assembler A-Z,a-z,0-9,@#$,
	 * blank, and &’()*+-./:=_.  Any characters that have mapping
	 * will attempt to print otherwise they will appear as periods.
	 * @param codepage_parm
	 */
	public void init_codepage(String codepage_parm)
	{
		// Initialie hard-coded ascii/ebcdic tables if no codepage.
		if (codepage_parm.length() == 0) {   // RPI 1069
			init_ascii_ebcdic();
			if (opt_traceall){
				put_systerm("TRACEALL default ascii ebcdic codepage");
				list_hex_ascii_ebcdic();
			}
			opt_codepage = false;
			return;
		}

		// initialize 256 byte values
		int index = 0;
		while (index < 256){
			init_charset_bytes[index]=(byte)index;
			index++;
		}

		// Extract 3 operands from codepage(ascii+ebcdic+list).
		index = codepage_parm.indexOf('+');
		if (index > 0) {
			ascii_charset_name = codepage_parm.substring(9,index);
			codepage_parm = codepage_parm.substring(index+1);
			index = codepage_parm.indexOf('+');
			if (index > 0) {
				ebcdic_charset_name = codepage_parm.substring(0,index);
				if (codepage_parm.substring(index+1,codepage_parm.length()-1).toUpperCase().equals("LIST")) {
					list_charset_map = true;
				}
			} else {
				ebcdic_charset_name = codepage_parm.substring(0,codepage_parm.length()-1);
			}
		} else {
			report_codepage_error("invalid CODEPAGE(ascii+ebcdic+list) = " + codepage);
			return;
		}
		try {
			test_ascii = new String(init_charset_bytes,ascii_charset_name);
			if (!check_test_ascii()) {
				report_codepage_error("ascii codepage validation error");
				return;
			}
		} catch (Exception e){
			report_codepage_error("codepage charset load error on " + ascii_charset_name);
			return;
		}
		try {
			test_ebcdic = new String(init_charset_bytes,ebcdic_charset_name);
			if (!check_test_ebcdic()){
				report_codepage_error("ebcdic codepage validation error on " + ebcdic_charset_name);
				return;
			}
		} catch (Exception e){
			if (!load_ebcdic_charset_hex_file()){
				report_codepage_error("codepage charset load error on " + ebcdic_charset_name);
				return;
			}
		}
		try {
			if (list_charset_map) {
				put_systerm("CODEPAGE listing for " + codepage);
				put_systerm("Default  ascii  Charset codepage is - " + default_charset_name.trim());
				put_systerm("Selected ascii  Charset codepage is - " + ascii_charset_name);
				put_systerm("Selected ebcdic Charset codepage is - " + ebcdic_charset_name);
			}
			init_charset_tables();
			if (list_charset_map) {
				list_ebcdic_ascii_unicode();
				list_available_charsets();
			}
			opt_codepage = true;
		} catch (final Exception e) {
			report_codepage_error("codepage charset table initialization error");
			return;
		}
	}

	/**
	 * 1.  copy test tables to live tables
	 * 2.  initialize translate tables
	 * 3.  initialize printable character table
	 */
	private void init_charset_tables()
	{
		// copy charsets
		ascii_table = test_ascii;
		ebcdic_table = test_ebcdic;

		// init translate tables from Charsets
		int i = 0;
		while (i < 256) {
			ascii_to_ebcdic[i]=0;
			ebcdic_to_ascii[i]=0;
			i++;
		}
		i = 0;
		int j;
		while (i < 256) {
			j = ebcdic_table.charAt(i) & 0xff;
			if (ascii_to_ebcdic[j] == 0 && ebcdic_to_ascii[i] == 0) {
				ascii_to_ebcdic[j]=(byte)i;
				ebcdic_to_ascii[i]=(byte)j;
			}
			i++;
		}

		// Abort if any duplicates in minimum ascii to ebcdic.
		i = 0;
		int k;
		int l;
		while (i < 256) {
			j = ebcdic_table.charAt(i) & 0xff;
			if (   (ascii_to_ebcdic[j] & 0xff) != i
				|| (ebcdic_to_ascii[i] & 0xff) != j) {
				k = ascii_min_char.indexOf(ebcdic_table.charAt(i));
				l = ascii_min_char.indexOf((char)i);
				if (k >= 0 && l >= 0){
					final String msg = "duplicate ascii/ebcdic conversion at - " + Integer.toHexString(i) + "/" + Integer.toHexString(j);
					report_codepage_error(msg);
					abort_error(31,msg);
				}
			}
			i++;
		}
		if (list_charset_map) {
			list_hex_ascii_ebcdic();
		}

		// replace control characters with period for printing
		int index = 0;
		while (index < 256) {
			if ((ascii_table.charAt(index) & 0xff) < 0x20) {
				if (index == 0) {
					ascii_table = "." + ascii_table.substring(index+1);
				} else if (index == 255) {
					ascii_table = ascii_table.substring(0,255)+".";
				} else {
					ascii_table = ascii_table.substring(0,index)+"."+ascii_table.substring(index+1);
				}
			}
			if ((ebcdic_table.charAt(index) & 0xff) < 0x20){
				if (index == 0) {
					ebcdic_table = "." + ebcdic_table.substring(index+1);
				} else if (index == 255) {
					ebcdic_table = ebcdic_table.substring(0,255)+".";
				} else {
					ebcdic_table = ebcdic_table.substring(0,index)+"."+ebcdic_table.substring(index+1);
				}
			}
			index++;
		}
	}

	/**
	 * Report codepage parameter error.
	 * @param msg
	 */
	private void report_codepage_error(final String msg)
	{
		put_systerm("CODEPAGE option error - " + msg);
		put_systerm("z390 default ascii/ebcdic tables used");
		put_systerm("Default ascii Charset codepage is - " + default_charset_name);
		list_available_charsets();
		opt_codepage = false;
		init_ascii_ebcdic();
	}

	/**
	 * List unicode, char, ascii hex, ebcdic hex.
	 */
	private void list_ebcdic_ascii_unicode()
	{
		put_systerm("hex-ebcdic/hex-ascii/print-char/unicode listing");
		int index = 0;
		while (index < 64) {
			put_systerm(map_text(index    )
					  + map_text(index+ 64)
					  + map_text(index+128)
					  + map_text(index+192));
			index++;
		}
	}

	/**
	 * Return text index,hex-ebcdic,hex-ascii,char,U+hex
	 * @param index
	 * @return
	 */
	private String map_text(final int index)
	{
		String	codepoint = "000"+Integer.toHexString(test_ascii.codePointAt(index));
				codepoint = codepoint.substring(codepoint.length()-4);
		char test_char;
		if (index >= 32){
			test_char = test_ascii.charAt(index);
		} else {
			test_char = '.';
		}

		String	test_ascii_hex = "0" + Integer.toHexString((byte)test_ascii.charAt(index));
				test_ascii_hex = test_ascii_hex.substring(test_ascii_hex.length()-2);

		String	test_ebcdic_hex = "0" + Integer.toHexString((byte)test_ebcdic.charAt(index));
				test_ebcdic_hex = test_ebcdic_hex.substring(test_ebcdic_hex.length()-2);

		final String text =   test_ebcdic_hex
					 + "/"  + test_ascii_hex
					 + "/"  + test_char
					 + "/U" + codepoint + "  ";
		return text;
	}

	/**
	 * List available ASCII and EBCDIC charset codepages.
	 */
	private void list_available_charsets()
	{
		put_systerm("available ascii and ebcdic charset codepages");
		int tot_charset = 0;
		int tot_ebcdic  = 0;
		int tot_ascii   = 0;
		final Map<String,Charset> map = Charset.availableCharsets();
		Iterator<String> it = map.keySet().iterator();
		while (it.hasNext()) {
			tot_charset++;
			// Get character set name
			final String charset_name = (String)it.next();
			try {
				test_ascii = new String(init_charset_bytes,charset_name);
				if (check_test_ascii()) {
					tot_ascii++;
					put_systerm("valid ascii  charset - " + charset_name);
				} else {
					test_ebcdic = new String(init_charset_bytes,charset_name);
					if (check_test_ebcdic()) {
						tot_ebcdic++;
						put_systerm("valid ebcdic charset - " + charset_name);
					}
				}
			} catch (final Exception e) {
			}
		}
		put_systerm("total charsets=" + tot_charset + "  total ebcdic=" + tot_ebcdic + "  total ascii=" + tot_ascii);
	}

	/**
	 * return true if test_ascii charset meets the following tests:
	 *   1.  Length 256
	 *   2.  hex char
	 *       20  space
	 *       30  zero
	 *       39  nine
	 *       41  A
	 *       5A  Z
	 *       61  a
	 *       7A  z
	 * @return
	 */
	private boolean check_test_ascii()
	{
		if (   test_ascii.length() != 256
			|| test_ascii.charAt(0x30) != '0'
			|| test_ascii.charAt(0x39) != '9'
			|| test_ascii.charAt(0x41) != 'A'
			|| test_ascii.charAt(0x5A) != 'Z'
			|| test_ascii.charAt(0x61) != 'a'
			|| test_ascii.charAt(0x7A) != 'z'
			|| test_ascii.charAt(0x24) != '$'
			|| test_ascii.charAt(0x23) != '#'
			|| test_ascii.charAt(0x40) != '@'
			|| test_ascii.charAt(0x20) != ' '
			|| test_ascii.charAt(0x26) != '&'
			|| test_ascii.charAt(0x27) != '\''
			|| test_ascii.charAt(0x28) != '('
			|| test_ascii.charAt(0x29) != ')'
			|| test_ascii.charAt(0x2A) != '*'
			|| test_ascii.charAt(0x2B) != '+'
			|| test_ascii.charAt(0x2C) != ','
			|| test_ascii.charAt(0x2D) != '-'
			|| test_ascii.charAt(0x2E) != '.'
			|| test_ascii.charAt(0x2F) != '/'
			|| test_ascii.charAt(0x3A) != ':'
			|| test_ascii.charAt(0x3D) != '='
			|| test_ascii.charAt(0x5F) != '_' ) {
			return false;
		}
		return true;
	}

	/**
	 * Return true if test_ebcdic charset meets minimum character requirements
	 * @return
	 */
	private boolean check_test_ebcdic()
	{
		if (   test_ebcdic.length() != 256
			|| test_ebcdic.charAt(0xF0) != '0'
			|| test_ebcdic.charAt(0xF9) != '9'
			|| test_ebcdic.charAt(0xC1) != 'A'
			|| test_ebcdic.charAt(0xE9) != 'Z'
			|| test_ebcdic.charAt(0x81) != 'a'
			|| test_ebcdic.charAt(0xA9) != 'z'
			|| test_ebcdic.charAt(0x5B) != '$'	
			|| test_ebcdic.charAt(0x7B) != '#'
			|| test_ebcdic.charAt(0x7C) != '@'
			|| test_ebcdic.charAt(0x40) != ' '
			|| test_ebcdic.charAt(0x50) != '&'
			|| test_ebcdic.charAt(0x7D) != '\''
			|| test_ebcdic.charAt(0x4D) != '('
			|| test_ebcdic.charAt(0x5D) != ')'
			|| test_ebcdic.charAt(0x5C) != '*'
			|| test_ebcdic.charAt(0x4E) != '+'
			|| test_ebcdic.charAt(0x6B) != ','
			|| test_ebcdic.charAt(0x60) != '-'
			|| test_ebcdic.charAt(0x4B) != '.'
			|| test_ebcdic.charAt(0x61) != '/'
			|| test_ebcdic.charAt(0x7A) != ':'
			|| test_ebcdic.charAt(0x7E) != '='
			|| test_ebcdic.charAt(0x6D) != '_' ) {
			return false;
		}
		return true;
	}

	/**
	 * List ASCII to EBCDIC and EBCDIC to ASCII conversion tables in hex for debugging.
	 */
	public void list_hex_ascii_ebcdic()
	{
		put_systerm("hex ascii Charset - " + ascii_charset_name);

		String hexline = "";

		int i = 0;
		while (i < 256) {
			final String hex = "0" + Integer.toHexString(ascii_table.charAt(i) & 0xff);
			hexline = hexline + hex.substring(hex.length()-2);
			if (hexline.length() >= 32) {
				put_systerm(Integer.toHexString(i/16)+"0 " + hexline);
				hexline = "";
			}
			i++;
		}
		put_systerm("hex ebcdic charset - " + ebcdic_charset_name);
		i = 0;
		hexline = "";
		while (i < 256){
			final String hex = "0" + Integer.toHexString(ebcdic_table.charAt(i) & 0xff);
			hexline = hexline + hex.substring(hex.length()-2);
			if (hexline.length() >= 32) {
				put_systerm(Integer.toHexString(i/16)+"0 " + hexline);
				hexline = "";
			}
			i++;
		}	
		put_systerm("hex ebcdic_to_ascii table");
		i = 0;
		while (i < 256){
			final String hex = "0" + Integer.toHexString(ebcdic_to_ascii[i] & 0xff);
			hexline = hexline + hex.substring(hex.length()-2);
			if (hexline.length() >= 32) {
				put_systerm(Integer.toHexString(i/16)+"0 " + hexline);
				hexline = "";
			}
			i++;
		}
		put_systerm("hex ascii_to_ebcdic table");
		i = 0;
		while (i < 256){
			final String hex = "0" + Integer.toHexString(ascii_to_ebcdic[i] & 0xff);
			hexline = hexline + hex.substring(hex.length()-2);
			if (hexline.length() >= 32) {
				put_systerm(Integer.toHexString(i/16)+"0 " + hexline);
				hexline = "";
			}
			i++;
		}
	}

	/**
	 * Load ebcdic_charset_name as alternate source for system defined ebcdic_charset_name.
	 * @return
	 */
	private boolean load_ebcdic_charset_hex_file()
	{
		try {
			final BufferedReader ebcdic_hex_buff =
					new BufferedReader(new FileReader(new File(ebcdic_charset_name)));

			String hex_rec = ebcdic_hex_buff.readLine();
			int hex_offset = 0;
			char[]  ebcdic_charset = new char[256];
			while (hex_rec != null && hex_offset < 256) {
				if (hex_rec.charAt(0) != '*'){
					int ver_offset = Integer.valueOf(hex_rec.substring(0,2),16);
					if (hex_offset != ver_offset) {
						ebcdic_hex_buff.close();
						return false;
					}
					if (hex_offset < 256) {
						int index = 0;
						while (index < 32) {
							int hex_byte = Integer.valueOf(hex_rec.substring(3+index,5+index),16);
							ebcdic_charset[hex_offset] =(char)hex_byte;
							hex_offset++;
							index = index+2;
						}
					}
				}
				hex_rec = ebcdic_hex_buff.readLine();
			}
			ebcdic_hex_buff.close();
			if (hex_offset == 256){
				test_ebcdic = String.valueOf(ebcdic_charset);
			} else {
				return false;
			}
		} catch (final Exception e){
			return false;
		}
		return true;
	}
}
