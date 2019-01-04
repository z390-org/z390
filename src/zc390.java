import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.lang.reflect.Array;
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
 * zc390 is the component of z390 used to translate COBOL source
 * programs (.CBL) to z390 assembler source programs (.MLC).
 *
 * zcoboljava is a COBOL source translator which does the following
 * 1. Read source ASCII Cobol from parm1 with CBL default file type.
 * 2. Parse space delimited COBOL into comma delimited z390 macro assembler
 *    source statements using MLC default file type.
 *    a. New macro for each new COBOL verb.
 *    b. Labels with dashes converted to underscores.
 *    c. Continuation of words and literals handled.
 *    d. Periods and commas allowed within parameters which are then enclosed
 *       in single quotes to avoid conflict with macro assembler parameter parsing.
 *    e. Open/close () put in single quotes to avoid  conflict with macro assembler parm parsing.
 *    f. Literals with single or double quotes allowed with double single/double quotes inclosed.
 *    g. Single '" wrapped in opposite type quotes.
 *    h. Single () wrapped in single quotes.
 *    i. Single . generates PERIOD vero in Proc. Div.
 *    j. Generate DATA END, PROCEDURE END,and END
 *    k. Treat verbs as parameters within EXEC to END-EXEC.
 */
public class zc390
{
	// Global variables
	private int    zc390_rc = 0; // return code
	private tz390  tz390;        // shared z390 routines
	private int    tot_cbl = 0;  // total CBL lines read
	private int    tot_mlc  = 0; // total MLC lines written
	private int    tot_lab  = 0; // total LABEL lines for SN/PG labels
	private int    tot_err  = 0; // total errors

	// COBOL CBL input file variables
	private String  zc_line_id  = "";    // RPI-1086
	private String  zc_line_num = "";    // RPI-1086
	private String  zc_line = null;      // logical line with continuations added
	private String  zc_line_lookahead;   // lookahead rec for non split lit continuations
	private String  zc_file_name = null;
	private boolean zc_comment = true;
	private boolean zc_comment_copy = false; // RPI-1062 comment COPY except for ZC_LABELS.CPY
	private boolean zc_pg_comment_mode = false;
	private boolean zc_cics = false;
//	private boolean zc_extend = true; // JBA-unused
//	private boolean zc_trunc  = false; // JBA-unused
	private boolean linkage_sect = false;
	private boolean request_dfheiblk = false;
//	private boolean request_dfhcommarea = false; // JBA-unused
	private boolean request_proc = false;
//	private boolean request_data_end = false;  // RPI-1086  // JBA-unused
	private boolean dfheiblk = false;
	private boolean dfheiblk_loading = false;
	private boolean dfhcommarea = false;
	private boolean zc_eof = false;
	private boolean zc_comment_pending = false;
	private int zc_comment_cnt = 0;
	private int pic_token_cnt = 0; // tokens since pic mode turned on
	private boolean pic_mode = false;
	private boolean value_mode = false; // RPI-1126
	private boolean exec_mode = false;
	private String[] exec_parm = new String[256];
	private int exec_parm_index = 0;
	private boolean data_div  = false;
	private boolean allow_verb = false;
	private boolean skip_period = false;
	private String  zc_comment_line;

	// MLC meta macro assembler output file variables
	private BufferedWriter	mlc_file_buff	= null;
	private BufferedWriter	lab_file_buff	= null;
//	private File			lab_file		= null; // JBA-unused

	// Nested COPY file input variables
	private String zc_copy_file_name = null;
	private String zc_copy_member = null;
	private String zc_copy_ddname = null;
	private final static String cpz_type = ".CPZ";
	private int     tot_cpz_file_name = 0;
	private String[] cpz_file_name = null;
	private int cur_zc_file = 0; // 0 is primary CBL input
	private File[] zc_file                = null;
	private BufferedReader[] zc_file_buff = null;
	private boolean  zc_copy_trailer = false;
	private int      zc_copy_rep_ix  = 1;
	private int      cur_rep_ix      = 0;
	private String[] zc_copy_line         = null; // RPI-1062 has trailing line after COPY .
	private int[]    zc_copy_line_ix      = null; // RPI-1062 next token on  line index
	private int[]    zc_copy_rep_fst_ix   = null; // RPI-1062 next token on  line index
	private int[]    zc_copy_rep_lst_ix   = null; // RPI-1062 next token on  line index
	private String[] zc_copy_rep_lit1     = null; // RPI-1062 replacing lit1
	private String[] zc_copy_rep_lit2     = null; // RPI-1062 replacing lit2

	// zcob token variables
	private int     zc_token_count = 0;
	private int     zc_token_line_cnt = 0;
	private int     zc_prev_line_cnt = 0;
	private int     zc_next_line_cnt = 0;
	private boolean zc_flush_cont_token = false;
	private String  zc_prev_token = null;
	private String  zc_next_token = null;
	private int     zc_next_index = 0;
	private int     zc_prev_index = 0;
	private char    zc_prev_area  = 'A';
	private char    zc_next_area  = 'A';
	private boolean zc_prev_first = true;
	private boolean zc_next_first;
	private boolean zc_token_first = true;
	private String  zc_token   = null;   // next token or null at EOF
//	private int     zc_token_index = 0;
	private Pattern zc_name_pattern = null;    // RPI-1062 validate names
	private Pattern zc_data_token_pattern = null;   // parsing regular expression pattern
	private Pattern zc_proc_token_pattern = null; // RPI-1182
	private Matcher zc_name_match    = null;   // data name pattern matching
	private Matcher zc_token_match   = null;   // token pattern matching class
	private int     zc_match_offset  = 0;      // offset to start of matcher
	private char    zc_token_area = 'A'; // token area A  8-11 or B 12 or greater
	private boolean zc_split_lit = false; // literal split across lines
	private char    zc_split_char = '\'';  // literal sq or dq RPI-1062
	private boolean zc_proc_div = false; // PRODECUDE DIV started
	private String proc_using_parms = null;
	private String mlc_lab = null;
	private String mlc_op  = null;
	private String mlc_parms = "";
	private int mlc_parm_cnt = 0; // mlc parm count
	private int zc_level = 0; // parm (...) level used to allow verbs in DFHRESP/DFHVALUE etc.

	// working storage global data
//	private int		 ws_item_lvl	= 0;
	private int		 ws_lvl_index	= 0;
	private int[]	 ws_lvl			= new int[50];
	private String[] ws_indent		= new String[50];

	/**
	 * Start instance of zCobol class.
	 *
	 * @param argv
	 */
	public static void main(final String argv[])
	{
		zc390 pgm = new zc390();
		pgm.translate_cbl_to_mlc(argv,null);
	}

	/**
	 * Translate COBOL (CBL) to z390 macro assembler (.MLC).
	 *
	 * @param args
	 * @param log_text
	 */
	private void translate_cbl_to_mlc(final String[] args, final JTextArea log_text)
	{
		init_zc390(args);
		if (tz390.opt_trap) { // RPI-1058
			try {
				process_cbl();
			} catch (final Exception e) {
				abort_error("zc390 exception - " + e.toString());
			}
		} else {
			process_cbl();
		}
	}

	/**
	 * Process CBL to MLC with or without trap exception handler.
	 */
	private void process_cbl()
	{
		get_zc_token();
		while (zc_token != null) {
			process_zc_token();
			get_zc_token();
		}
		if (mlc_op != null) {
			put_zc_line(); // RPI-1086
			put_mlc_line(" ",mlc_op,mlc_parms);
		}
		term_zc();
	}

	/**
	 * Initialize zCobol.
	 * 1.  Display zCobol version.
	 * 2.  Compile regular expression pattern.
	 * 3.  Open CBL and MLC files.
	 *
	 * @param args
	 */
	private void init_zc390(final String[] args)
	{
		tz390 = new tz390();
		tz390.init_tz390();   // RPI-1080
		tz390.init_tz390();   // RPI-1080
		tz390.init_options(args,tz390.mlc_type);
		tz390.open_systerm("ZC390");
		put_copyright();

		String zcobol_options = "";
		String comma = "";
		int index = 1;
		while (index < args.length) {
			zcobol_options = zcobol_options + comma + args[index];
			comma = ",";
			if (args[index].toUpperCase().equals("NOEXTEND")) {
				// zc_extend = false; // JBA-unused
			} else if (args[index].toUpperCase().equals("NOTIMING")) {
				tz390.opt_timing = false; // turn off timing for CDATE/CTIME
			} else if (args[index].toUpperCase().equals("NOCOMMENT")) {
				zc_comment = false;
			} else if (args[index].toUpperCase().equals("CICS")) {
				zc_cics = true;
			} else if (args[index].toUpperCase().equals("TRUNC")) {
				// zc_trunc = true; // JBA-unused
			}
			index++;
		}

		String zcobol_parms = "PGM='"    + args[0]   // RPI-1074
						  + "',VER="    + tz390.version
						  + ",CDATE=" + tz390.cur_date()
						  + ",CTIME=" + tz390.cur_time(false)
						  + ",OPTIONS=(" + zcobol_options + ")";
		String mlc_file_name;

		if (tz390.opt_traces) {
			System.out.println("ZCOBOL " + zcobol_parms);
		}
		index = args[0].indexOf('.'); // RPI-1080 allow any cbl suffix
		if (index == -1) {
			zc_file_name  = args[0] + ".CBL";
			mlc_file_name = args[0] + ".MLC";
		} else {
			zc_file_name  = args[0];
			mlc_file_name = args[0].substring(0,index) + ".MLC";
		}
		String lab_file_name = tz390.fix_file_separators(args[0]); // RPI-1086 RPI-1062 LABEL macros for section/paragraph
		String lab_file_dir; // RPI-1080 - Remove directory from COPY statement to support LSN

		index = args[0].lastIndexOf(File.separator); // RPI-1080
		if (index >= 0) {
			lab_file_dir = lab_file_name.substring(0,index+1);
		} else {
			lab_file_dir = "";
		}
		lab_file_name = lab_file_name.substring(index+1) + "_ZC_LABELS.CPY"; // RPI-1080
		// final File mlc_file = new File(mlc_file_name);
		zc_file              = (File[])Array.newInstance(File.class,tz390.opt_maxfile);
		zc_file_buff         = (BufferedReader[])Array.newInstance(BufferedReader.class,tz390.opt_maxfile);
		cpz_file_name        = new String[tz390.opt_maxfile];
		zc_copy_line         = (String[])Array.newInstance(String.class,tz390.opt_maxfile);
		zc_copy_line_ix      = (int[])Array.newInstance(int.class,tz390.opt_maxfile);
		zc_copy_rep_fst_ix   = (int[])Array.newInstance(int.class,tz390.opt_maxfile);
		zc_copy_rep_lst_ix   = (int[])Array.newInstance(int.class,tz390.opt_maxfile);
		zc_copy_rep_lit1     = (String[])Array.newInstance(String.class,tz390.opt_maxfile);
		zc_copy_rep_lit2     = (String[])Array.newInstance(String.class,tz390.opt_maxfile);
		try {
			mlc_file_buff  = new BufferedWriter(new FileWriter(mlc_file_name));
			lab_file_buff  = new BufferedWriter(new FileWriter(lab_file_dir + lab_file_name)); // RPI-1062
			zc_file[cur_zc_file] = new File(zc_file_name);
			zc_file_buff[cur_zc_file] = new BufferedReader(new FileReader(zc_file[cur_zc_file]));
		} catch (Exception e) {
			abort_error("zcobol file I/O error - " + e.toString());
		}
		put_mlc_line(" ","ZCOBOL",zcobol_parms);
		put_mlc_line(" ","COPY",lab_file_name); // RPI-1062 RPI-1074 RPI-1080
		zc_comment_copy = true;
		try {
			zc_data_token_pattern = Pattern.compile(
					// parm in single or double quotes
					"([']([^']|(['][']))*['])"        // parameter in single quotes // RPI-1062
				+	"|([xX]['][0-9a-fA-F]+['])"       // hex value x'??'
				+	"|([xX][\"][0-9a-fA-F]+[\"])"     // hex value x"??"
				+	"|([bB]['][01]+['])"              // binary value b'??'
				+	"|([bB][\"][01]+[\"])"            // binary value b"??"
				+	"|([\"]([^\"]|([\"][\"]))*[\"])"  // parameter in double quotes // RPI-1062
					// any parm such as PIC may have leading period and embedded .,- but not '"()=+/*
				+	"|([\\.]*[^\\s\\.\\,:;\\'\"()=<>\\+\\-\\*\\/]+(([^\\s\\.\\,:;\\'\"()=<>\\+\\*\\/]+)|([\\.\\,][^\\s\\.\\,:;\\'\"()=<>\\+\\-\\*\\/]+))*)"
					// COPY REPLACE lit ==???==
				+	"|([=][=][.]+[=][=])"
					// .,:'"() single special char requiring processing
				+	"|([=][=])|([\\.\\,:;\\'\"()=<>\\+\\-\\*\\/])"
			);
		} catch (final Exception e) {
			abort_error("zcobol cbl data token pattern errror - " + e.toString());
		}
		try {
			zc_proc_token_pattern = Pattern.compile(
					// parm in single or double quotes
					"([']([^']|(['][']))*['])"  // parm in single quotes // RPI-1062
				+	"|([xX]['][0-9a-fA-F]+['])"   // hex value x'??'
				+	"|([xX][\"][0-9a-fA-F]+[\"])" // hex value x"??"
				+	"|([bB]['][01]+['])"   // binary value b'??'
				+	"|([bB][\"][01]+[\"])" // binary value b"??"
				+	"|([\"]([^\"]|([\"][\"]))*[\"])"  // parm in double quotes // RPI-1062
					// any parm similar to data but without embedded commas
				+	"|([\\.]*[^\\s\\.\\,:;\\'\"()=<>\\+\\-\\*\\/]+(([^\\s\\.\\,:;\\'\"()=<>\\+\\*\\/]+)|([\\.][^\\s\\.\\,:;\\'\"()=<>\\+\\-\\*\\/]+))*)"
					// COPY REPLACE lit ==???==
				+ "|([=][=][.]+[=][=])"
					// .,:'"() single special char requiring processing
				+ "|([=][=])|([\\.\\,:;\\'\"()=<>\\+\\-\\*\\/])"
			);
		} catch (final Exception e) {
			abort_error("zcobol cbl proc token pattern errror - " + e.toString());
		}
		try {
			zc_name_pattern = Pattern.compile(
					// data name starting with 0-9 and
					// containing letters or dashes
					// but no dashes on end
					// note 1E1 etc. is allowed in PIC mode
					// any parm such as PIC may have leading period and embedded .,- but not '"()=+/*
					"[0-9]+(([a-zA-Z]+)|([\\-]+[a-zA-Z0-9]+))+"
			);
		} catch (Exception e) {
			abort_error("zcobol cbl data name pattern errror - " + e.toString());
		}
		ws_indent[0] = "  ";
		index = 1;
		while (index < 50) {
			ws_indent[index] = ws_indent[index-1] + "  ";
			index++;
		}
	}

	/**
	 * 1.  Add PROCEDURE END and END to mlc meta file.
	 * 2.  Display statistics.
	 * 3.  Exit
	 */
	private void term_zc()
	{
		put_mlc_line(" ","PROCEDURE","END");
		put_mlc_line(" ","END","");
		try {
			zc_file_buff[0].close();
			mlc_file_buff.close();
			lab_file_buff.close(); // RPI-1062
		} catch (final Exception e) {
			abort_error("zcobol file close error " + zc_file_name);
		}
		if (tz390.opt_stats) {
			int index = 0;
			while (index < tot_cpz_file_name) {
				final String xref_msg = "FID=" + tz390.right_justify(""+(index+1),3) + " " + cpz_file_name[index];
				tz390.put_stat_line(xref_msg);
				index++;
			}
			tz390.put_stat_line("total CBL lines in  =" + tot_cbl);
			tz390.put_stat_line("total MLC lines out =" + tot_mlc);
			tz390.put_stat_line("total labels        =" + tot_lab);
			tz390.put_stat_line("total errors        =" + tot_err);
		}
		tz390.close_systerm(zc390_rc);
		System.exit(zc390_rc);
	}

	/**
	 * Display zc390 version, time stamp, and copyright on statistics file.
	 */
	private void put_copyright()
	{
		if  (tz390.opt_stats) {
			tz390.put_stat_line(Constants.sCopyright2011);
			tz390.put_stat_line(Constants.sCopyright2013);
			tz390.put_stat_line(Constants.sCopyright2018);
			tz390.put_stat_line(Constants.sGnuLicence);
			tz390.put_stat_line("program = " + tz390.dir_mlc + tz390.pgm_name);
			tz390.put_stat_line("options = " + tz390.cmd_parms);
		}
	}

	/**
	 * 1.  write line to MLC file
	 * 2.  if LABEL macros for PROCEDURE DIVISION section and paragraph names,
	 *     write to CPY file concatenated in front of MLC to preload all
	 *     label definitions for compile.
	 * Note:
	 * If first char is " and not data_div assume comment-entry and make comment line.
	 *
	 * @param put_lab
	 * @param put_op
	 * @param put_parms
	 */
	private void put_mlc_line(final String put_lab, final String put_op, final String put_parms)
	{
		String put_line;

		if (put_lab.charAt(0) == '*') {
			put_line = put_lab;
		} else if (zc_comment_copy && put_op.equals("COPY")) {
			put_line = "*         " + put_op + " " + put_parms;
		} else if (put_lab.charAt(0) == ' ') {
			put_line = "         " + tz390.left_justify(put_op,5) + " " + put_parms;
			if (put_op.equals("LABEL")) {
				put_text_rec(lab_file_buff,put_line);
				tot_lab++;
			}
		} else {
			put_line = tz390.left_justify(put_lab,8) + " " + tz390.left_justify(put_op,5) + " " + put_parms;
		}
		if (tz390.opt_traces) {
			System.out.println("put mlc " + put_line);
		}
		put_text_rec(mlc_file_buff,put_line);
		tot_mlc++;
	}

	/**
	 * Write text record to MLC or CPY file.
	 *
	 * @param file_buff
	 * @param text
	 */
	private void put_text_rec(final BufferedWriter file_buff, final String text)
	{
		try {
			if (text.length() >=72) {
				file_buff.write(text.substring(0,71) + "X\r\n");
				int index = 71;
				while (text.length()-index > 56) {
					file_buff.write("               " + text.substring(index,index+56) + "X\r\n");
					index = index + 56;
				}
				file_buff.write("               " + text.substring(index) + "\r\n");
			} else {
				file_buff.write(text + "\r\n");
			}
			tot_mlc++;
		} catch (Exception e) {
			abort_error("Write MLC file error - " + e.toString());
		}
	}

	/**
	 * Display error and terminate.
	 *
	 * @param msg
	 */
	private void abort_error(String msg)
	{
		tot_err++;
		zc390_rc = 16;
		msg = "ZC390E abort " + msg + " on line " + tot_cbl;
		System.out.println(msg);
		tz390.put_systerm(msg);
		put_mlc_line("* " + msg,"",""); // RPI-1042
		tz390.close_systerm(zc390_rc);
		System.exit(zc390_rc);
	}

	/**
	 * Display error and terminate.
	 *
	 * @param msg
	 */
	private void log_error(String msg)
	{
		tot_err++;
		if (zc390_rc < 12) {
			zc390_rc = 12;
		}
		msg = "ZC390E " + msg + " on line " + tot_cbl;
		System.out.println(msg);
		tz390.put_systerm(msg);
		put_mlc_line("* " + msg,"","");
	}

	/**
	 * 1.  Set zc_token to next logical COBOL token including continued literal token
	 *     split across 1 or more lines and non-literal tokens continued at next non-blank char on continuation line.
	 * 3   Set to null at end of file.
	 * 4.  Set zc_token_area to A for token starting in col 8-11.
	 * 5.  Set zc_token_area to B for token starting in 12-72.
	 * 4.  If token not in quotes, make upper-case.
	 * 5.  If quotes
	 *     a.  Convert & to &&
	 *     b.  If orig ", convert "" to ", ' to ''
	 */
	private void get_zc_token()
	{
		int index;
		if (zc_next_token == null || zc_flush_cont_token) {
			zc_flush_cont_token = false;
			if (!zc_eof) {
				set_next_token();
				next_to_prev();
			}
			if (zc_eof) {
				// return null at eof
				zc_token = null;
				return;
			}
		} else if (zc_next_token.equals("''")
				   && zc_line.length() > 7
				   && zc_line.charAt(6) == '-') {
			// append ""..." or ''...' to prior token on mlc_line
			index = zc_line.lastIndexOf(zc_split_char);
			if (index > zc_next_index+1) {  // skip skip ''
				// append last lit to prev
				zc_prev_token = "'" + zc_split_char + zc_line.substring(zc_next_index,index) + '\'';
			} else {
				zc_prev_token = "'" + zc_split_char + "'";
			}
			rep_amp_sq_dq();
			mlc_parms = mlc_parms.substring(0,mlc_parms.length()-1) + zc_prev_token.substring(1);
			// restart matcher after ending "/'
			// and exit split mode
			if (zc_proc_div) {
				zc_token_match = zc_proc_token_pattern.matcher(zc_line.substring(index+1));
			} else {
				zc_token_match = zc_data_token_pattern.matcher(zc_line.substring(index+1));
			}
			zc_match_offset = index+1;
			zc_split_lit  = false;  // end split lit at quote
			zc_split_char = '\'';   // reset to default
			set_next_token();
			next_to_prev();
		} else {
			next_to_prev();
		}
		if (zc_prev_token != null
			&& zc_prev_token.equals("'")) {
			// start split literal with single " or '
			zc_split_lit  = true;
			zc_prev_token = "'" + zc_line.substring(zc_prev_index);
			zc_line = null;
			set_next_token();
			while (zc_split_lit
				&& zc_line != null
				&& zc_line.length() > 7
				&& zc_line.charAt(6) == '-'
				&& zc_next_token != null
				&& (zc_next_token.charAt(0) == '\''
				 || zc_next_token.charAt(0) == '=') ) {
				// we have continuation of literal '..' ".." or ==..==
				// in zc_next_token from next line
				if (zc_next_token.length() == 1) {
					// add rest of continued line
					index = zc_line.lastIndexOf(zc_split_char);
					zc_prev_token = zc_prev_token + zc_line.substring(index+1);
					zc_line = null;
					set_next_token();
				} else if (zc_next_token.length() == 2) { // RPI-1062 support - ""..." or ''...'
					// we have continuation ""... or ''... to insert " or ', or "". end
					zc_prev_token = zc_prev_token + zc_split_char;
					index = zc_line.lastIndexOf(zc_split_char);
					if (index > zc_next_index) {  // skip 6 to pos 8 and 2 to skip ''
						// append last lit to prev
						zc_prev_token = zc_prev_token + zc_line.substring(zc_next_index,index) + '\'';
					} else {
						zc_prev_token = zc_prev_token + "'";
					}
					// restart matcher after ending "/'
					// and exit split mode
					if (zc_proc_div) {
						zc_token_match = zc_proc_token_pattern.matcher(zc_line.substring(index+1));
					} else {
						zc_token_match = zc_data_token_pattern.matcher(zc_line.substring(index+1));
					}
					zc_match_offset = index+1;
					zc_split_lit  = false;  // end split lit at quote
					zc_split_char = '\'';   // reset to default
					zc_flush_cont_token = true; // flush continue token appended to prev.
				} else {
					// add to end of literal
					if (zc_prev_token.charAt(zc_prev_token.length()-1) == '\'') {
						zc_prev_token = zc_prev_token.substring(0,zc_prev_token.length()-1) + zc_next_token.substring(1,zc_next_token.length()-1) + '\''; // RPI-1062
					} else {
						zc_prev_token = zc_prev_token.substring(0,zc_prev_token.length()) + zc_next_token.substring(1,zc_next_token.length()-1) + '\''; // RPI-1062
					}
					zc_split_lit  = false;  // end split lit at quote
					zc_split_char = '\''; // RPI-1062 reset to default
					zc_flush_cont_token = true; // flush continue token appended to previous
				}
			}
			if (zc_split_lit) {
				log_error("zcob split literal format error");
				zc_split_lit = false;
			}
			zc_prev_area = 'B';
			// we have complete literal in zc_prev_token
		} else {
			// prev token not split literal
			if (!pic_mode) {
				if  (zc_prev_token != null
				     && (zc_prev_token.toUpperCase().equals("PIC")
					     || zc_prev_token.toUpperCase().equals("PICTURE"))) {
					pic_mode = true;
					pic_token_cnt = 0;
				}
			} else if (pic_token_cnt > 1) {
				pic_mode = false; // turn off after processing token after pic
			}
			if (!value_mode) {
				if  (zc_prev_token != null && (zc_prev_token.toUpperCase().equals("VALUE"))) {
					value_mode = true;
				}
			}
			set_next_token();
		}
		if (zc_prev_token.charAt(0) != '\'' ) {
			zc_prev_token = zc_prev_token.toUpperCase();
		} else if (zc_prev_token.length() > 2) {
			rep_amp_sq_dq();
		}
		// we now have a complete previous token
		zc_token       = zc_prev_token;
		// zc_token_index = zc_prev_index; // JBA-unused
		zc_token_area  = zc_prev_area;
		zc_token_first = zc_prev_first;
		zc_token_line_cnt = zc_prev_line_cnt;
		return;
	}

	/**
	 * replace & with &&
	 * replace "" with "
	 * replace ' with '' if split_char = "
	 */
	private void rep_amp_sq_dq()
	{
		zc_prev_token = tz390.find_amp.matcher(zc_prev_token).replaceAll("&&"); // RPI-1080
		if (zc_split_char == '"') {
			zc_prev_token = tz390.find_squote.matcher(zc_prev_token.substring(1,zc_prev_token.length()-1)).replaceAll("''"); // RPI-1080
			zc_prev_token = "'" + zc_prev_token + "'";
			zc_prev_token = tz390.find_ddquote.matcher(zc_prev_token).replaceAll("\""); // RPI-1080
		}
	}

	/**
	 * Move next token to prev token.
	 */
	private void next_to_prev()
	{
		zc_prev_token = zc_next_token;
		zc_prev_index = zc_next_index;
		zc_prev_area  = zc_next_area;
		zc_prev_first = zc_next_first;
		zc_prev_line_cnt = zc_next_line_cnt;
	}

	/**
	 * Get next token from CBL file and set pending CBL comment line.
	 */
	private void set_next_token() {
		if (zc_line != null) {
			if (zc_next_token != null) {
				find_next_token();
			}
		}
		while (!zc_eof && zc_line == null) {
			get_zc_line();
			if (!zc_eof) {
				if (zc_line.length() < 8) {
					// ignore short lines
					zc_line = null;
				} else {
					if (zc_line.length() > 72) {
						zc_line = zc_line.substring(0,72);
					}
					if (   zc_line.charAt(6) == '*'
						|| zc_line.charAt(6) == '/'
						|| zc_line.charAt(6) == 'D') { // RPI-1062
						put_mlc_comment();
					} else if ((zc_line.length() >= 14
							    && zc_line.substring(7).toUpperCase().equals("AUTHOR."))
							 || (zc_line.length() >= 16
								&& zc_line.substring(7).toUpperCase().equals("SECURITY."))
							 || (zc_line.length() >= 20
								&& zc_line.substring(7).toUpperCase().equals("INSTALLATION."))
							 || (zc_line.length() >= 20
								&& zc_line.substring(7).toUpperCase().equals("DATE-WRITTEN."))
							 || (zc_line.length() >= 23
								&& zc_line.substring(7).toUpperCase().equals("SOURCE-COMPUTER.")) // RPI-1062
							 || (zc_line.length() >= 23
								&& zc_line.substring(7).toUpperCase().equals("OBJECT-COMPUTER.")) // RPI-1062
							) {
						put_mlc_comment();
						zc_pg_comment_mode = true;
					} else if (zc_pg_comment_mode) {
						if (zc_line.length() > 12
							&& zc_line.substring(7,11).equals("    ")) {
							put_mlc_comment();
						} else if (zc_line.length() > 13
								   && zc_line.substring(7,12).equals("DATA ")) {
							zc_pg_comment_mode = false;
						} else {
							int index = zc_line.substring(7).indexOf('.');
							if (index > 0) {
								zc_pg_comment_mode = false;
							}
						}
					}
				}
			}
			if  (zc_line != null) {
				if (zc_copy_trailer) {
					zc_copy_trailer = false;
				} else {
					if (zc_proc_div) {
					   zc_token_match = zc_proc_token_pattern
					   .matcher(zc_line.substring(7));
					} else {
						zc_token_match = zc_data_token_pattern
						.matcher(zc_line.substring(7));
					}
					zc_match_offset = 8;
				}
				find_next_token();
			}
		}
		if (zc_eof) {
			zc_next_token = null;
		} else {
			if (tz390.opt_traceall) {
				put_mlc_line("* trace get next token = " +zc_next_token,"","");
			}
		}
	}

	/**
	 * Put zc_line as comment on MLC.
	 */
	private void put_mlc_comment()
	{
		if (zc_comment_pending) {
			put_mlc_line(zc_comment_line,"","");
		}
		zc_comment_pending = true;
		zc_comment_line = "*" + zc_line;
		zc_line = null;
	}

	/**
	 * 1.  read next CBL file line
	 * 2.  set cbl_eof if end of file
	 * 3.  write each line as comment on MLC
	 * 4.  ignore lines < 8 or blank
	 * 5.  ignore comment lines with non-space in 7
	 */
	private void get_zc_line()
	{
		get_next_zc_line();
		boolean zc_line_blank = true;
		while (zc_line != null && zc_line_blank) {
			tot_cbl++;
			if (zc_line.length() >= 7) {
				zc_line_blank = false;
			} else {
				// ignore blank lines
				get_next_zc_line();
			}
		}
		if (zc_line != null) {
			zc_token_count = 0;
		} else {
			zc_eof = true;
			return;
		}
	}

	/**
	 * Display CBL as comments if ZC_COMMENT.
	 *
	 * @param text
	 */
	private void zc_cbl_comment(final String text)
	{
		if (text != null
			&& zc_comment // request to gen CBL comments
			&& (text.length() < 7 || text.charAt(6) != '*')) {
			if (zc_comment_pending) {
				put_mlc_line(zc_comment_line,"","");
			}
			zc_comment_pending = true;
			zc_comment_line = "* " + text;
			zc_comment_cnt = tot_cbl;
		}
	}

	/**
	 * Get next zc_line from nested copy files.
	 */
	private void get_next_zc_line()
	{
		if (request_dfheiblk) {
			request_dfheiblk = false;
			zc_line = "         COPY DFHEIBLK."; // RPI-1062
			return;
		}
		if (zc_copy_trailer) {
			zc_copy_trailer = false;
		} else {
			get_zc_read_cont();
			if (zc_line != null) {
				cur_rep_ix = zc_copy_rep_fst_ix[cur_zc_file];
				if (cur_rep_ix > 0) {
					while (cur_rep_ix <= zc_copy_rep_lst_ix[cur_zc_file]) {
						zc_line = zc_line.replaceAll(zc_copy_rep_lit1[cur_rep_ix],zc_copy_rep_lit2[cur_rep_ix]); // RPI-1080
						cur_rep_ix++;
					}
				}
			} else if (zc_copy_line[cur_zc_file] != null) {
				zc_copy_trailer = true;
				zc_line = zc_copy_line[cur_zc_file]; // RPI-1062 add +1 for all 3
				zc_copy_line[cur_zc_file] =null;
				if (zc_proc_div) {
					zc_token_match = zc_proc_token_pattern.matcher(zc_line.substring(zc_copy_line_ix[cur_zc_file]));
				} else {
					zc_token_match = zc_data_token_pattern.matcher(zc_line.substring(zc_copy_line_ix[cur_zc_file]));
				}
				zc_match_offset = zc_copy_line_ix[cur_zc_file]+1;
			}
		}
		while (zc_line == null && cur_zc_file > 0) {
			try {
				zc_file_buff[cur_zc_file].close();
			} catch (Exception e) {
				abort_error("zcobol read error on CBL/CPY close file - " + e.toString());
			}
			if (zc_copy_rep_fst_ix[cur_zc_file] >= 0) {
				// restore current rep index for use in next copy
				zc_copy_rep_ix = zc_copy_rep_fst_ix[cur_zc_file];
			}
			cur_zc_file--;
			if (dfheiblk_loading) {
				dfheiblk_loading = false;
				flush_last_mlc_line();
				dfheiblk = true;
			}
			if (request_proc) {
				gen_data_end();  // RPI-1086
			}
			get_zc_read_cont();
		}
		if (zc_line != null && zc_line.length() > 72) {
			zc_line = zc_line.substring(0,72);
		}
	}

	/**
	 * Read next zc_line with concatenated non split lit continuations.
	 */
	private void get_zc_read_cont()
	{
		try {
			zc_line = zc_file_buff[cur_zc_file].readLine();
			zc_cbl_comment(zc_line);
			if (zc_line != null && !zc_split_lit) {
				zc_file_buff[cur_zc_file].mark(100);
				zc_line_lookahead = zc_file_buff[cur_zc_file].readLine();
				boolean cont_split_lit = false;
				while (zc_line_lookahead != null
						&& !cont_split_lit
						&& zc_line_lookahead.length() > 7
						&& zc_line_lookahead.charAt(6) == '-') {
					zc_cbl_comment(zc_line_lookahead);
					if (zc_line_lookahead.length() > 72) {
						zc_line_lookahead = zc_line_lookahead.substring(0,72);
					}
					int index = 7;
					while (index < zc_line_lookahead.length()
							&& zc_line_lookahead.charAt(index) == ' ') {
						index++;
					}
					if (index < zc_line_lookahead.length()
							 && zc_line_lookahead.charAt(index) != '\''
							 && zc_line_lookahead.charAt(index) != '"') {
						zc_cbl_comment(zc_line_lookahead);
						zc_line = zc_line.concat(zc_line_lookahead.substring(index));
						tot_cbl++;
						zc_file_buff[cur_zc_file].mark(100);
						zc_line_lookahead = zc_file_buff[cur_zc_file].readLine();
					} else {
						cont_split_lit = true;
					}
				}
				if (zc_line_lookahead != null && zc_line_lookahead.length() > 0) {
					zc_file_buff[cur_zc_file].reset();
				}
			}
		} catch (Exception e) {
			abort_error("zcobol read error on CBL/CPY file - " + e.toString());
			zc_line = null;
		}
	}

	/**
	 * Write pending CBL line comment if pending
	 */
	private void flush_comment_line()
	{
		if (zc_comment_pending && zc_comment_cnt <= zc_token_line_cnt) {
			put_mlc_line(zc_comment_line,"","");
			zc_comment_pending = false;
		}
	}

	/**
	 * Find next token in zc_line else set zc_line = null.
	 */
	private void find_next_token()
	{
		if (!zc_token_match.find()) {
			zc_line = null;
		} else {
			zc_token_count++;
			if (zc_token_count == 1) {
				zc_next_first = true;
				value_mode = false; // RPI-1126
			} else {
				zc_next_first = false;
			}
			pic_token_cnt++;
			zc_next_token = zc_token_match.group();
			zc_next_index = zc_token_match.start() + zc_match_offset;
			zc_next_line_cnt = tot_cbl;
			if (zc_token_match.start() + zc_match_offset < 12 && zc_next_first) {
				zc_next_area = 'A';
			} else {
				zc_next_area = 'B';
			}
			if (zc_next_token.length() >= 2
				&& zc_next_token.charAt(0) == '"') {
				zc_split_char = '"'; // RPI-1062
				zc_next_token = "'" + zc_next_token.substring(1,zc_next_token.length()-1)+"'"; // cvt ".." to '..'
			} else if (zc_next_token.equals("\"")) {
				zc_split_char = '"'; // RPI-1062
				zc_next_token = "'";
			} else if (zc_next_token.toUpperCase().equals("COPY")) {
				process_copy();
			}
			if (pic_mode) {
				int index2 = zc_next_index + zc_token_match.group().length()-1;
				while (zc_line.length() > index2
					&& zc_line.charAt(index2) > ' '
					&& (zc_line.charAt(index2) != '.'
					|| (zc_line.length() > index2+1
					&& zc_line.charAt(index2+1) > ' ' ) )
					&& zc_token_match.find()) {
					zc_next_token = zc_next_token + zc_token_match.group();
					zc_next_index = zc_token_match.start() + zc_match_offset;
					index2 = zc_next_index + zc_token_match.group().length()-1;
				}
			} else if (zc_next_token.charAt(0) <= '9'
					&& zc_next_token.charAt(0) >= '0') {
				// convert data names starting with digit to #name
				zc_name_match = zc_name_pattern.matcher(zc_next_token);
				if (zc_name_match.find()) {
					zc_next_token = "#" + zc_next_token; // RPI-1062
				}
			}
		}
	}

	/**
	 * Process zc_token
	 *   1.  If token length > 1 and not literal replace - with _ and if ., included wrap in single quotes.
	 *   2.  Single char processing
	 *       a.  Flush line at . and gen PERIOD if Proc. div.
	 *           else ignore period.
	 *       b.  Ignore commas.
	 *       c.  If '" wrap in opposite quotes
	 *       d.  If () wrap in single quotes.
	 *       e.  comma or semicolon ignored
	 */
	private void process_zc_token()
	{
		if (zc_token.length() > 1) {
			if (   zc_token.charAt(0) != '\''
				&& zc_token.charAt(0) != '"') {
				if (zc_token.indexOf(',') >= 0) {// ALLOW . IN OPEN PARMS zc_token.indexOf('.') >= 0
					// Wrap strings with ., in quotes to make single parameter.
					zc_token = "'" + zc_token + "'";
				} else if (!pic_mode && !value_mode && zc_token.indexOf('-') >= 0) { // RPI-1126 allow nE-n value
					// Replace token "-" with "_" for z390 meta macro assembler compatibility.
					zc_token = tz390.find_dash.matcher(zc_token).replaceAll("_");  // RPI-1080
				}
			}
		} else if (zc_token.length() == 1) {
			// single char token . or ,
			if (zc_token.charAt(0) == '.') {
				if (mlc_op != null
					&& mlc_parm_cnt >= 1) {
					if (exec_mode) {
						log_error("EXEC statement missing END-EXEC");
						exec_mode = false;
						exec_parm_index = 0;
					}
					// Flush line at period after parameters and generate PERIOD in proc div
					if (zc_proc_div && !skip_period) {
						new_mlc_line(" ","PERIOD","");
					}
					flush_last_mlc_line();
					zc_level = 0;
				}
				skip_period = false;
				// ignore period
				return;
			} else if (zc_token.charAt(0) == ','
					|| zc_token.charAt(0) == ';') {
				// ignore commas and semicolons
				return;
			} else if (zc_token.charAt(0) == '\'') {
				zc_token = "'" + zc_token + "'";
			} else if (zc_token.charAt(0) == '"') {
				zc_token = "\"" + zc_token + "\"";
			} else if (zc_token.charAt(0) == '(') {
				zc_level++;
				zc_token = "'('";
			} else if (zc_token.charAt(0) == ')') {
				zc_level--;
				zc_token = "')'";
			}
			// may be single char label
		} else {
			abort_error("zero length token parsing error");
		}
		if (zc_token_area == 'A') {
			// Non procedure division section operation or procedure division label.
			if (zc_proc_div
				&& zc_next_token != null // RPI-1062
				&& (zc_next_token.equals(".") // RPI-1012
					|| zc_next_token.toUpperCase().equals("SECTION"))) { // RPI-1012 RPI-1063
				// Generate procedure div label
				new_mlc_line(" ","LABEL",zc_token); // RPI-1086
				mlc_parm_cnt = 1;  // RPI-1062 Append SECTION if present to first parameter name
				skip_period = true;
			} else {
				if  (zc_token.charAt(0) >= '0'
					 && zc_token.charAt(0) <= '9') {
					new_ws_line();
				} else {
					if (zc_token.equals("DATA")) {
						data_div = true;
					} else if (zc_token.equals("LINKAGE")) {
						linkage_sect = true;
					} else if (zc_token.equals("PROCEDURE")) {
						if (!data_div) {
							zc_comment_pending = false; // Cancel proc div comment
							data_div = true;
							put_mlc_line(" ","DATA","DIVISION");
						}
						if (zc_cics) {
							// check if PROCEDURE statement needs to be preceded by generated
							// DFHEIBLK and DFHCOMMAREA linkage sections
							if (!linkage_sect) {
								zc_comment_pending = false;
								linkage_sect = true;
								put_mlc_line(" ","LINKAGE","SECTION");
							}
							if (!dfheiblk) {
								request_dfheiblk = true;
							}
							if (!dfhcommarea) {
								dfhcommarea = true;
								put_mlc_line(" ","WS","01,DFHCOMMAREA");
							}
							if (!dfheiblk) {
								set_proc_using_parms();
								zc_comment_pending = false;
								request_proc = true;
								return;
							}
						}
						gen_data_end(); // RPI-1086
					} else if (zc_token.equals("SD")) {
						zc_token = "ZCSD"; // RPI-1062
					} else if (zc_token.equals("END")) { // RPI-1062
						zc_token = "ZCEND";
					}
					new_mlc_line(" ",zc_token,"");
				}
			}
		} else if (find_verb()) {
			if (zc_token_first) {
				flush_last_mlc_line();
				flush_comment_line();
			}
			set_zc_line_id_num(); // RPI-1086
			new_mlc_line(" ",zc_token,"");
			if (zc_next_token.equals(".")) {
				new_mlc_line(" ","PERIOD","");
			}
		} else {
			// Assume parameter for prior verb
			if (mlc_op == null) {
				// Assume unknown verb starting new line
				flush_comment_line();
				if (!zc_proc_div
					&& zc_token.charAt(0) >= '0'
					&& zc_token.charAt(0) <= '9') {
					new_ws_line();
				} else {
					set_zc_line_id_num(); // RPI-1086
					new_mlc_line(" ",zc_token,"");
				}
			} else {
				add_mlc_parm(zc_token);
			}
		}
	}

	/**
	 * Generate DATA END after any CICS generated COPY for DFHEIBLK or DFHCOMMAREA.
	 */
	private void gen_data_end()
	{
		put_mlc_line(" ","DATA","END");
		if (request_proc) {
			request_proc = false;
			if (proc_using_parms.length() > 0) {
				put_mlc_line(" ","PROCEDURE","DIVISION,USING,DFHEIBLK,DFHCOMMAREA," + proc_using_parms);
			} else {
				put_mlc_line(" ","PROCEDURE","DIVISION,USING,DFHEIBLK,DFHCOMMAREA");
			}
		}
		zc_proc_div = true;
		skip_period = true;
	}

	/**
	 * Set zc_line_id and zc_line_num.
	 */
	private void set_zc_line_id_num()
	{
		zc_line_id = zc_line.substring(0,7); // RPI-1086
		zc_line_num = tz390.right_justify("" + tot_cbl,6); // RPI-1086
	}

	/**
	 * 1.  Insert DFHEIBLK and DFHCOMMAREA parameters.
	 * 2.  Add any user parameters after above.
	 * 3.  Flush through period.
	 */
	private void set_proc_using_parms() {
		proc_using_parms = "";
		get_zc_token();
		while (!zc_token.equals(".")) {
			if (   !zc_token.equals("DIVISION")
				&& !zc_token.equals("USING")
				&& !zc_token.equals("DFHEIBLK")
				&& !zc_token.equals("DFHCOMMAREA")
				&& !zc_token.equals(",")) {
				proc_using_parms = proc_using_parms + " " + zc_token;
			}
			get_zc_token();
		}
	}

	/**
	 * If new level # less than current level #, decrement group level #.
	 * Generate new WS verb with level # as first parameter indented to current group level.
	 */
	private void new_ws_line()
	{
		int ws_item_lvl = 0;
		try {
			ws_item_lvl = Integer.valueOf(zc_token);
		} catch (final Exception e) {
			log_error("Invalid WS level number");
			ws_item_lvl = 1;
		}
		switch (ws_item_lvl) {
		case 1:
			if (zc_token_area != 'A') {
				log_error("zcobol level 01 must be in A field");
			}
			ws_lvl_index = 0;
			ws_lvl[0] = ws_item_lvl;
			break;
		case 66:  // redefine
			ws_lvl_index = 0;
			ws_lvl[0] = ws_item_lvl;
			break;
		case 77:  // item
			ws_lvl_index = 0;
			ws_lvl[0] = ws_item_lvl;
			break;
		case 88:  // value
			// use current level / indent
			break;
		default: // 02-49
			if (ws_item_lvl < 1 || ws_item_lvl > 49) {
				log_error("zcobol invalid ws level " + ws_item_lvl);
			}
			if (ws_item_lvl > ws_lvl[ws_lvl_index]) {
				ws_lvl_index++;
			} else {
				while (ws_lvl_index > 0 && ws_item_lvl < ws_lvl[ws_lvl_index]) {
					ws_lvl_index--;
				}
			}
			ws_lvl[ws_lvl_index] = ws_item_lvl;
		}
		new_mlc_line(" ","WS","" + ws_indent[ws_lvl_index] + zc_token);
		mlc_parm_cnt = 1;
		if (zc_token.equals("01") && zc_next_token.equals("DFHCOMMAREA")) {
			dfhcommarea = true;
		}
	}

	/**
	 * Write pending MLC line, start new line, and reset parameter count.
	 *
	 * @param new_lab
	 * @param new_op
	 * @param new_parms
	 */
	private void new_mlc_line(final String new_lab, final String new_op, final String new_parms)
	{
		flush_last_mlc_line();
		mlc_lab   = new_lab;
		mlc_op    = new_op;
		mlc_parms = new_parms;
		mlc_parm_cnt = 0;
	}

	/**
	 * Write pending mlc_line if any.
	 */
	private void flush_last_mlc_line()
	{
		if (mlc_op != null) {
			put_zc_line(); // RPI-1086
			put_mlc_line(mlc_lab,mlc_op,mlc_parms);
		}
		mlc_op = null;
	}

	/**
	 * Put zCobol call source comment.
	 */
	private void put_zc_line()
	{
		if (zc_proc_div) {
			if (zc_comment
				&& !mlc_op.equals("PERIOD")
				&& !mlc_op.equals("LABEL"))
			{
				put_mlc_line("*ZC " + zc_line_num + " " + zc_line_id + " " + tz390.left_justify(mlc_op,5) + " " + mlc_parms,"",""); // RPI-1086
			}
		}
	}

	/**
	 * Add token parameter to mlc_line.
	 * Notes:
	 * If exec_mode and parameter.
	 *
	 * @param token
	 */
	private void add_mlc_parm(final String token)
	{
		if (mlc_parm_cnt == 0) {
			mlc_parms = zc_token;
		} else if (!exec_mode) {
			mlc_parms = mlc_parms + "," + zc_token;
		} else {
			if (zc_token.compareTo("END_EXEC") == 0) {
				gen_exec_stmt();
				zc_token_first = true;
			} else {
				exec_parm[exec_parm_index] = zc_token;
				exec_parm_index++;
			}
		}
		mlc_parm_cnt++;
	}

	/**
	 * Generate EXEC call with parm(value) parameters combined.
	 */
	private void gen_exec_stmt()
	{
		int index = 0;
		while (index < exec_parm_index) {
			if (exec_parm[index].equals("'('")) {
				mlc_parms = mlc_parms + "(" + exec_parm[index+1];
				index = index + 2;
				while (index < exec_parm_index && exec_parm[index] != "')'") {
					mlc_parms = mlc_parms + "," + exec_parm[index];
					index++;
				}
				mlc_parms = mlc_parms + ")";
				index = index + 1;
			} else {
				mlc_parms = mlc_parms + "," + exec_parm[index];
				index++;
			}
		}
		put_mlc_line("*ZC " + zc_line_num + " " + zc_line_id + " " + tz390.left_justify(mlc_op,5) + " " + mlc_parms,"",""); // RPI-1086
		put_mlc_line(mlc_lab,mlc_op,mlc_parms);
		if (zc_next_token.equals(".")) {
			put_mlc_line(" ","PERIOD","");
		}
		if (!zc_cics
			&& mlc_op.equals("EXEC")
			&& mlc_parms.length() > 4
			&& mlc_parms.substring(0,4).equals("CICS")) {
			abort_error("EXEC CICS statements require CICS option");
		}
		mlc_op = null;
		exec_mode = false;
		exec_parm_index = 0;
	}

	/**
	 * Return true if zc_token is a known COBOL verb.
	 *
	 * @return
	 */
	private boolean find_verb()
	{
		if (allow_verb) {
			allow_verb = false;
			return false;
		}
		if (exec_mode || zc_level > 0) {
			// Ignore verbs within exec statements and (...) parameters
			return false;
		}
		String key = zc_token.toUpperCase();
		switch (key.charAt(0)) {
		case 'A':
			if (   key.equals("ACCEPT")
				|| key.equals("ADD")
				|| key.equals("ALPHABET") // RPI-1062 spec. name
				|| key.equals("ALTER")
				) {
				return true;
			}
			return false;
		case 'C':
			if (   key.equals("CALL")
				|| key.equals("CANCEL")
				|| key.equals("CLOSE")
				|| key.equals("COMPUTE")
				|| key.equals("CONTINUE")
				|| key.equals("CLASS") // RPI-1062 spec names
				|| key.equals("CURRENCY") // RPI-1062 spec names
				|| key.equals("CURSOR") // RPI-1062 spec names
				|| key.equals("CRT") // RPI-1062 spec names
				) {
					return true;
				}
				return false;
		case 'D':
			if (   key.equals("DIVIDE")  // most frequent
				|| key.equals("DELETE")
				|| key.equals("DISABLE")
				|| key.equals("DISPLAY")
				|| key.equals("DECIMAL_POINT") // RPI-1062 spec name
				) {
				if (!zc_proc_div && key.equals("DISPLAY")) {
					return false; // RPI-1062
				}
					return true;
				}
				return false;
		case 'E':
			if (key.equals("EXEC")
				) {
				exec_mode = true;
				return true;
			}
			if (key.equals("END_EXEC")) {
				log_error("zcob END_EXEC not preceeded by EXEC statement");
				return true;
			}
			if (   key.equals("EJECT")
				|| key.equals("ELSE")
				|| key.equals("ENABLE")
				|| key.equals("END_ADD")
				|| key.equals("END_DIVIDE")
				|| key.equals("END_EVALUATE")
				|| key.equals("END_IF")
				|| key.equals("END_MULTIPLY")
				|| key.equals("END_PERFORM")
				|| key.equals("END_READ")
				|| key.equals("END_SUBTRACT")
				|| key.equals("ENTRY")
				|| key.equals("EVALUATE")
				|| key.equals("EXAMINE")  // OS/VS replaced by INSPECT
				|| key.equals("EXHIBIT")  // OS/VS replaced by DISPLAY
				|| key.equals("EXIT")
				) {
				return true;
			}
			return false;
		case 'G':
			if (   key.equals("GENERATE")
				|| key.equals("GO")
				|| key.equals("GOBACK")
				) {
					return true;
				}
				return false;
		case 'I':
			if (   key.equals("IF")
				|| key.equals("INITIALIZE")
				|| key.equals("INITIATE")
				|| key.equals("INSPECT")
					) {
					return true;
				}
				return false;
		case 'L':
			if (   key.equals("LOCALE")
				) {
					return true;
				}
				return false;
		case 'M':
			if (   key.equals("MERGE")
				|| key.equals("MOVE")
				|| key.equals("MULTIPLY")
				) {
					return true;
				}
				return false;
		case 'N':
			if (key.equals("NEXT")
				|| key.equals("NOTE")
				|| key.equals("NOT")
				) {
				if (key.equals("NOT")) { // RPI-1062
					if (zc_next_token.equals("ON")) {
						return true;
					} else {
						return false;
					}
				}
				return true;
			}
			return false;
		case 'O':
			if (   key.equals("OPEN")
				|| key.equals("ORDER") // RPI-1062 spec names
				) {
					return true;
				}
				return false;
		case 'P':
			if (key.equals("PERFORM")) {
				return true;
			}
			return false;
		case 'R':
			if (   key.equals("READ")
				|| key.equals("READY")   // OS/VS READY TRACE
				|| key.equals("RECEIVE")
				|| key.equals("RELEASE")
				|| key.equals("REMARKS") // OS/VS replaced with comments
				|| key.equals("RESET")   // OS/VS RESET TRACE
				|| key.equals("RETURN")
				|| key.equals("REWRITE")
				) {
					return true;
				}
				return false;
		case 'S':
			if (   key.equals("SUBTRACT") // MFU first for speed
				|| key.equals("SEARCH")
				|| key.equals("SELECT")
				|| key.equals("SEND")
				|| key.equals("SET")
				|| key.equals("SORT")
				|| key.equals("START")
				|| key.equals("STOP")
				|| key.equals("STRING")
				|| key.equals("SYMBOLIC") // RPI-1062 spec names
				) {
				if (key.equals("START")) {
					zc_token = "ZCSTART"; // avoid assembler START conflicts
				}
					return true;
				}
				return false;
		case 'T':
			if (key.equals("TERMINATE")
				|| key.equals("TRANSFORM") // OS/VS REPLACED BY INSPECT
				) {
				return true;
			}
			return false;
		case 'U':
			if (key.equals("UNSTRING")) {
				return true;
			}
			return false;
		case 'W':
			if (   key.equals("WHEN")
				|| key.equals("WRITE")
				) {
				if (!zc_proc_div && key.equals("WHEN")) {
					return false; // RPI-1062
				}
				return true;
			}
			return false;
		}
		return false;  // UNDEFINED WORD
	}

	/**
	 * Expand copy which may appear in the middle of sentence with the following options:
	 * 1.  COPY member (uses SYSCPY paths for dir search)
	 * 2.  COPY member OF/IN library (ddname of dir)
	 * 3.  COPY ... REPLACING lit1 BY lit2
	 */
	private void process_copy()
	{
		int parm = 0; // Count and check parameters to period
		zc_copy_member = null;
		zc_copy_ddname = null;
		if (cur_zc_file + 1 >= tz390.opt_maxfile) {
			log_error("maximum nested copy files exceeded");
			set_next_token();
			return;
		}
		zc_copy_line[cur_zc_file]       = null; // assume  no trailing tokens
		zc_copy_rep_fst_ix[cur_zc_file] = 0; // assume  no REPLACING
		zc_copy_rep_lst_ix[cur_zc_file] = 0; // force exit from while loop when index high
		set_next_token();
		while (!zc_eof && !zc_next_token.equals(".")) {
			switch (parm) {
			case 0: // member name
				zc_copy_member = zc_next_token;
				parm = 1;
				break;
			case 1: // OF/IN ddname or REPLACING else error
				if (   zc_next_token.toUpperCase().equals("OF")
					|| zc_next_token.toUpperCase().equals("IN")) {
					parm = 2;
				} else if (zc_next_token.toUpperCase().equals("REPLACING")) {
					parm = 4;
				} else {
					copy_error("unknown COPY parm - " + zc_next_token);
					return;
				}
				break;
			case 2: // ddname following OF/IN
				zc_copy_ddname = zc_next_token;
				parm = 3;
				break;
			case 3: // REPLACING
				if (zc_next_token.toUpperCase().equals("REPLACING")) {
					parm = 4;
				} else {
					copy_error("unknown COPY parm - " + zc_next_token);
					return;
				}
				break;
			case 4: // lit1 or OF/IN lit2 (split pseudo ==...== not supported)
				if (   zc_next_token.toUpperCase().equals("OF")
					|| zc_next_token.toUpperCase().equals("IN")) {
					parm = 7;
					return;
				}
				if (   zc_next_token.length() > 2
					&& zc_next_token.charAt(0) == '=') {
					zc_next_token = zc_next_token.substring(2,zc_next_token.length()-2);
				} else if (zc_next_token.equals("==")) {
					copy_error("Split pseudo COPY replacement not supported.");
				}
				if (zc_copy_rep_fst_ix[cur_zc_file+1] == 0) {
					zc_copy_rep_fst_ix[cur_zc_file+1] = zc_copy_rep_ix;
				}
				zc_copy_rep_lst_ix[cur_zc_file+1] = zc_copy_rep_ix;
				zc_copy_rep_lit1[zc_copy_rep_lst_ix[cur_zc_file+1]] = zc_next_token;
				zc_copy_rep_ix++;
				if (zc_copy_rep_ix >= tz390.opt_maxfile) {
					copy_error("Maximum nested copy reps exceeded.");
					return;
				}
				parm = 5;
				break;
			case 5:
				if (zc_next_token.toUpperCase().equals("BY")) {
					parm = 6;
				} else {
					copy_error("Unknown COPY parm - " + zc_next_token);
					return;
				}
				break;
			case 6: // store first lit2 token
				zc_copy_rep_lit2[zc_copy_rep_lst_ix[cur_zc_file+1]] = zc_next_token;
				parm = 4;
				break;
			case 7: // append OF/IN field to lit2
				zc_copy_rep_lit2[zc_copy_rep_lst_ix[cur_zc_file+1]] = zc_copy_rep_lit2[zc_copy_rep_lst_ix[cur_zc_file+1]] + " " + zc_next_token;
				parm = 4;
				break;
			default:
				copy_error("unknown COPY parm - " + zc_next_token);
				return;
			}
			set_next_token();
		}
		if (zc_copy_member == null) {
			copy_error("missing COPY member");
			return;
		} else if (zc_copy_ddname != null) {
			zc_copy_file_name = System.getenv(zc_copy_ddname);
			if (zc_copy_file_name == null) {
				copy_error("copy ddname not found - " + zc_copy_ddname);
				return;
			}
			zc_copy_file_name = zc_copy_file_name + File.separator + zc_copy_member + cpz_type;
		} else {
			zc_copy_file_name = tz390.find_file_name(tz390.dir_cpy,zc_copy_member,cpz_type,tz390.dir_cur);
			if (zc_copy_file_name == null) { // RPI-970 add key if found
				copy_error("COPY file not found - " + zc_copy_file_name);
				return;
			} else if (zc_cics) {
				if (zc_copy_member.equals("DFHEIBLK")) {
					if (!dfheiblk) {
						dfheiblk_loading = true;
					} else {
						put_mlc_line("* ZC390I DUPLICATE COPY DFHEIBLK IGNORED","","");
						set_next_token();
						return;
					}
				}
			}
		}
		cur_zc_file++;
		add_cpz_file();
		try {
			zc_file[cur_zc_file] = new File(zc_copy_file_name);
			zc_file_buff[cur_zc_file] = new BufferedReader(new FileReader(zc_file[cur_zc_file]));
		} catch (final Exception e) {
			cur_zc_file--;
			copy_error("I/O error opening copy file - " + e.toString());
			return;
		}
		if (zc_line != null && zc_token_match.find()) {
			zc_copy_line[   cur_zc_file] = zc_line;
			zc_copy_line_ix[cur_zc_file] = zc_token_match.start()+ zc_match_offset - 1; // RPI-1062
			zc_line = null; // RPI-1062
		}
		set_next_token(); // RPI-1062 - Get next token from copy file.
	}

	/**
	 * Terminate COPY with error and dec cur_zc_file and flush line.
	 *
	 * @param msg
	 */
	private void copy_error(final String msg)
	{
		log_error(msg + "\r" + zc_line);
		zc_line = null;
		zc_copy_trailer = false;
	}

	/**
	 * Add CPZ file for statistics list  RPI-1042
	 */
	private void add_cpz_file()
	{
		if (!tz390.opt_stats) {
			return;
		}
		final int index = tz390.find_key_index('F',zc_copy_file_name);
		if (index == -1) {
			if (tot_cpz_file_name < tz390.opt_maxfile) {
				if (!tz390.add_key_index(tot_cpz_file_name)) {
					abort_error("key search table exceeded adding " + tot_cpz_file_name);
				}
				cpz_file_name[tot_cpz_file_name] = zc_copy_file_name;
				tot_cpz_file_name++;
			}
		}
	}
}
