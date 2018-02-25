import java.awt.Color;
import java.awt.Component;
import java.awt.Dimension;
import java.awt.FlowLayout;
import java.awt.Font;
import java.awt.Toolkit;
import java.awt.datatransfer.DataFlavor;
import java.awt.datatransfer.StringSelection;
import java.awt.datatransfer.Transferable;
import java.awt.datatransfer.UnsupportedFlavorException;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.event.AdjustmentEvent;
import java.awt.event.AdjustmentListener;
import java.awt.event.ComponentEvent;
import java.awt.event.ComponentListener;
import java.awt.event.FocusEvent;
import java.awt.event.FocusListener;
import java.awt.event.KeyEvent;
import java.awt.event.KeyListener;
import java.awt.event.MouseEvent;
import java.awt.event.MouseListener;
import java.awt.event.WindowAdapter;
import java.awt.event.WindowEvent;
import java.awt.font.TextLayout;
import java.nio.ByteBuffer;
import java.text.SimpleDateFormat;
import java.util.Arrays;
import java.util.Date;
import java.util.StringTokenizer;

import javax.swing.BorderFactory;
import javax.swing.ImageIcon;
import javax.swing.JCheckBoxMenuItem;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JMenu;
import javax.swing.JMenuBar;
import javax.swing.JMenuItem;
import javax.swing.JPanel;
import javax.swing.JPopupMenu;
import javax.swing.JScrollPane;
import javax.swing.JTextArea;
import javax.swing.JTextField;
import javax.swing.KeyStroke;
import javax.swing.Timer;

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
 * 
 */
public class gz390 implements MouseListener, KeyListener, ActionListener, ComponentListener, FocusListener {

	@SuppressWarnings("unused")
	private static final long serialVersionUID = 1L;

	/**
	 * Global variables
	 */

	// Global maximum/minimum limits.

	private final static int max_keys = 100;
	private              int max_rows = 24;
	private              int max_cols = 80;

	private final static Color   bg_color =	Color.BLACK;
	private       static Color   tx_color =	Color.YELLOW;
	private final static Color[] tn_color = {	Color.BLACK,   //0
												Color.BLUE,    //1 
												Color.RED,     //2
												Color.PINK,    //3 
												Color.GREEN,   //4 
												Color.MAGENTA, //5 ? TURQUOISE 
												Color.YELLOW,  //6
												Color.WHITE    //7
	};

//	// Maximum fud - JBA - Unused at the moment
// 	private int max_fud  =  500;

	/**
	 * Maximum buffer size
	 */
	private final static int max_buff = 3000;

	// Shared z390 library classes
	private tz390 tz390            = null; // shared tables
	private gz390_screen tn_scn    = null; // RPI 227 Graphics2D TN3270 screen
//	private gz390_screen graph_scn = null;  // JBA - Unused at the moment

	/**
	 * Helper class offering the command history.
	 */
	private final CmdHistory cmdHistory = new CmdHistory();

	/**
	 * Helper class offering permission information.
	 */
	private final Permissions perms = new Permissions();

	boolean console_log = false;
	int gz390_errors = 0;
	boolean cmd_error = false;

	/**
	 * Global variable containing the main title.<br>
	 * Will be enhanced by the version number.<br>
	 * Can be changes by public methods<br>
	 * {@link #start_guam(String, tz390)} and {@link #guam_window_title(String)}
	 */
	private String main_title = "GZ390";

//	// Global variable indicating the demo mode.
//	// Set if no permissions, for example when running as restricted applet.
//	private boolean main_demo = false;

//	// Global variable indicating the license.
//	// Set if permissions are OK.
//	private boolean main_lic  = false; 
//	private Date lic_end_date = null;

	/**
	 * Global variable containing mode message #1 (e.g. in demo mode).
	 */
	private String mode_msg1 = null;

	/**
	 * Global variable containing mode message #2 (e.g. in demo mode).
	 */
	private String mode_msg2 = null;

	private final static SimpleDateFormat mmddyy = new SimpleDateFormat("MM/dd/yy");
	private final static SimpleDateFormat hhmmss = new SimpleDateFormat("HH:mm:ss");

	// Monitor variables
	int     ins_count = 0;  
	int     io_count  = 0;
	int     start_cmd_io_count;
	long    start_cmd_time;
	Timer   monitor_timer = null;
	int     monitor_wait = 300; // RPI 224 
	int     monitor_timeout_limit = 0 * 1000;
	long    monitor_cmd_time_total = 0;
	long    monitor_last_time = 0;
	long    monitor_next_time = 0;
	long    monitor_cur_interval = 0;
	int     monitor_last_ins_count = 0;
	int     monitor_next_ins_count = 0;
	int     monitor_last_io_count = 0;
	int     monitor_next_io_count = 0;
	long    monitor_cur_ins  = 0;
	long    monitor_cur_int  = 0;
	long    monitor_cur_rate = 0;
	boolean monitor_last_cmd_mode = false;

	// GUAM GUI screen view variables.
	private GuamViewTypes guam_view = GuamViewTypes.MCS;

	int guam_tot_key  = 0;
	int guam_next_key = 0;
	int[] guam_key_code_char = new int[max_keys];
	int guam_cur_row = 1;
	int guam_cur_col = 1;

	// Status interval display variables
	int     status_interval =  0;
	long    status_last_time = 0;
	long    status_next_time = 0;
	int     status_last_ins_count = 0;
	int     status_next_ins_count = 0;
	int     status_next_io_count = 0;
	int     status_last_io_count = 0;
	long    status_cur_ins  = 0;
	long    status_cur_int  = 0;
	long    status_cur_rate = 0;

	// WTOR reply thread variables
	boolean wtor_running = false;
	Thread wtor_thread = null;
	String wtor_reply_string = null;
	int wtor_ecb_addr = -1;
	boolean shutdown_exit = false;

	// Global TGET/TPUT TN3290 objects
	int tpg_rc         = 0;    // return code
	int tpg_flags      = 0;    // from high byte R1
	int tpg_op_mask    = 0x80; // 1=TGET, 0=TPUT
	int tpg_op_tget    = 0x80;
	int tpg_op_tput    = 0x00;
	int tpg_wait_mask  = 0x10; // 1=NOWAIT, 0=WAIT
	int tpg_wait       = 0x00; // 0=WAIT
	int tpg_nowait     = 0x10;
	int tpg_type         = 0;
	int tpg_type_mask    = 0x03; // 00=EDIT 01=ASIS 10=CONTROL 11=FULLSCR
	int tpg_type_edit    = 0x00;
	int tpg_type_asis    = 0x01;
	int tpg_type_control = 0x02;
	int tpg_type_fullscr = 0x03;
	byte[] tget_byte = new byte[max_buff];
	ByteBuffer tget_buff = ByteBuffer.wrap(tget_byte);
	int tget_index = 0;
	int tget_len   = 0;
	byte[] tput_byte = new byte[max_buff];
	ByteBuffer tput_buff = ByteBuffer.wrap(tput_byte);
	int tput_index = 0;
	int tput_len = 0;
	int tput_buff_byte = 0;

	// Global tn3270 data
	byte tn_tab_code       = 0x09;
	byte tn_pa1_code       = 0x6c; // RPI 856
	byte tn_pa2_code       = 0x6e; // RPI 856
	byte tn_pa3_code       = 0x6b; // RPI 856
	byte tn_clear_code     = 0x6d; // RPI 856
	byte tn_enter_code     = 0x7d;
	byte tn_sba_cmd = 0x11; // set buffer addr (sba)
	byte tn_sf_cmd  = 0x1d; // set field (attr byte)
	byte tn_ic_cmd  = 0x13; // insert cursor
	byte tn_pt_cmd  = 0x05; // program tab 
	byte tn_ra_cmd  = 0x3c; // repeat to addr (sba,char)
	byte tn_eua_cmd = 0x12; // erase unprotected to addr (sba)
	byte tn_sa_cmd  = 0x28; // eds set attribute
	byte tn_sfe_cmd = 0x29; // eds start field
	boolean tn_delete_request = false;  // RPI 630
	boolean tn_cursor = false;
	boolean tn_cursor_alt = false;
	char tn_cursor_sym = '?';      // alternate cursor char ?
	char tn_cursor_sym_alt = ' ';  // alternate cursor space if ?
	char ff_char = '@'; // RPI 927
	int tn_cursor_scn_addr = 0;
	int tn_cursor_count = 1;
	char scn_null  = (byte)0x00; // rpi 856
	boolean tn_full_screen = false;
	byte tn_null  = 0;
	byte tn_field = 1;
	byte tn_char  = 2;
	int tn_protect_mask = 0x20; // mask for protected field attribute bit 
	int tn_numeric_mask = 0x10; // numeric field
	int tn_mdt_mask     = 0x01; // mask for modified data attribute bit  
	int tn_mdt_off      = 0xfe; // turn off mdt
	int tn_noaid = 0x60;       // no aid available
	int tn_aid = 0x60;         // set from PF key or enter if unlocked
	int tn_esc = 0x27;         // tput tso escape followed by write cmd and wcc
	int tn_write_cmd    = 0;   // vtam write command after escape
	int tn_write = 0xF1;       // tput tso write screen
	int tn_erase_write = 0xF5; // tput tso erase write
	int tn_write_alt = 0xF1;   // tput tso write screen
	int tn_write_eau = 0x6F;   // RPI 628
	byte tn_attr_prot_text = 0x30; // protected unmodified text 
	boolean tn_kb_lock = true;  // no TN3270 key input allowed
	boolean tn_scn_lock = true; // no TN3270 key mapping to screen
	boolean tn_attn = false;
	int cur_fld_addr  = 0;
	int cur_fld_attr  = 0;
	int fld_attr_hl   = 0x08; // hl high intensity field bit
	int fld_attr_nd   = 0x0c; // non-display RPI 850
	int cur_fld_hl    = 0;
	int cur_fld_color = 0;

	private int max_addr = max_rows * max_cols;

	// Array with address of all fields ascending
	private int    fld_tot;            // protected and unprotected
	private int[]  fld_addr = null;

	// Array of all input fields ascending
	private int   fld_mdt_tot  = 0; // fields with mdt bit on RPI 1061 include PA_MDT
	private int[] fld_mdt_addr = null;  // RPI 1061 all fields with mdt on

	// TN3270 screen
	private boolean[] scn_fld = null;
	private int[]  scn_attr   = null;
	private int[]  scn_hl     = null;
	private int[]  scn_color  = null;
	private char[] scn_char   = null; // set to display char else blank   
	private int    scn_addr   = 0;

	private final static int[] sba_to_ebc = {
		0x40,0xC1,0xC2,0xC3,0xC4,0xC5,0xC6,0xC7, //00
		0xC8,0xC9,0x4A,0x4B,0x4C,0x4D,0x4E,0x4F, //08
		0x50,0xD1,0xD2,0xD3,0xD4,0xD5,0xD6,0xD7, //10
		0xD8,0xD9,0x5A,0x5B,0x5C,0x5D,0x5E,0x5F, //18
		0x60,0x61,0xE2,0xE3,0xE4,0xE5,0xE6,0xE7, //20
		0xE8,0xE9,0x6A,0x6B,0x6C,0x6D,0x6E,0x6F, //28      
		0xF0,0xF1,0xF2,0xF3,0xF4,0xF5,0xF6,0xF7, //30
		0xF8,0xF9,0x7A,0x7B,0x7C,0x7D,0x7E,0x7F  //38
	};
	private final static int[] ebc_to_sba = {
		0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff, //00
		0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff, //08
		0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff, //10
		0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff, //18
		0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff, //20
		0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff, //28
		0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff, //30
		0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff, //38
		0x00,0xff,0xff,0xff,0xff,0xff,0xff,0xff, //40
		0xff,0xff,0x0a,0x0b,0x0c,0x0d,0x0e,0x0f, //48
		0x10,0xff,0xff,0xff,0xff,0xff,0xff,0xff, //50
		0xff,0xff,0x1a,0x1b,0x1c,0x1d,0x1e,0x1f, //58
		0x20,0x21,0xff,0xff,0xff,0xff,0xff,0xff, //60
		0xff,0xff,0x2a,0x2b,0x2c,0x2d,0x2e,0x2f, //68
		0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff, //70
		0xff,0xff,0x3a,0x3b,0x3c,0x3d,0x3e,0x3f, //78
		0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff, //80
		0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff, //88
		0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff, //90
		0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff, //98
		0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff, //A0
		0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff, //A8
		0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff, //B0
		0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff, //B8
		0xff,0x01,0x02,0x03,0x04,0x05,0x06,0x07, //C0
		0x08,0x09,0xff,0xff,0xff,0xff,0xff,0xff, //C8
		0xff,0x11,0x12,0x13,0x14,0x15,0x16,0x17, //D0
		0x18,0x19,0xff,0xff,0xff,0xff,0xff,0xff, //D8
		0xff,0xff,0x22,0x23,0x24,0x25,0x26,0x27, //E0
		0x28,0x29,0xff,0xff,0xff,0xff,0xff,0xff, //E8
		0x30,0x31,0x32,0x33,0x34,0x35,0x36,0x37, //F0
		0x38,0x39,0xff,0xff,0xff,0xff,0xff,0xff, //F8
	};

	private int  font_size = Constants.numDefaultFontSize; //see FONT command RPI 630 was 12
	private Font char_font = null;

	// Global GUAM GUI objects 
//	int ascii_lf = 10;
//	int ascii_cr = 13;
//	int ebcdic_space = 0x40;
	boolean refresh_wait    = false;
	boolean refresh_request = false;
	boolean main_status  = true;
	boolean main_view_changed = false;

	private int main_loc_x = Constants.posMainFrameX;
	private int main_loc_y = Constants.posMainFrameY;

	private JFrame main_frame = null; 
	private JPanel main_panel = null;
	private JTextArea log_text = null;
	private JScrollPane main_view = null;
	private JLabel cmd_label = null;
	private JTextField gz390_cmd_line = null;
	private JLabel status_label = null;
	private JTextField status_line = null;
	private String status_line_view = "MCS View";

	// Graphics 2d GUAM GUI objects
	private JTextArea graph_grid = null;

	// Menu items requiring state changes
//	private boolean opt_tn3270 = false; // display TN3270 panel
//	private boolean opt_graph  = false; // display graphic panel
//	private boolean opt_mcs    = true;  // display mcs panel
	private JMenuBar menuBar = null;  //RPI 81
	private JMenu file_menu = null;
	private JMenu edit_menu = null;
	private JMenu view_menu = null;
	private JMenu help_menu = null;
	private JMenuItem file_menu_exit       = null;
	private JMenuItem edit_menu_cut        = null;
	private JMenuItem edit_menu_copy       = null;
	private JMenuItem edit_menu_paste      = null;
	private JMenuItem edit_menu_select_all = null;
	private JMenuItem edit_menu_copy_log   = null;
	private JMenuItem edit_menu_notepad    = null;
	private JCheckBoxMenuItem view_menu_mcs    = null;
	private JCheckBoxMenuItem view_menu_tn3270 = null;
	private JCheckBoxMenuItem view_menu_graph  = null;
	private JMenuItem help_menu_help    = null;
	private JMenuItem help_menu_support = null;
	private JMenuItem help_menu_about   = null;

	// Pop-up edit menu variables (right click)
	private JPopupMenu popup_edit_menu = null; 
	private Component focus_comp = null;

	/**
	 * APL graphic characters for use via TN3270 data stream X'08' prefix defined as 16 bit Unicode chars
	 */
	private final static char[] apl_char = {
			0X0020,0X0020,0X0020,0X0020, //00
			0X0020,0X0020,0X0020,0X0020, //04 
			0X0020,0X0020,0X0020,0X0020, //08
			0X0020,0X0020,0X0020,0X0020, //0C
			0X0020,0X0020,0X0020,0X0020, //10
			0X0020,0X0020,0X0020,0X0020, //14 
			0X0020,0X0020,0X0020,0X0020, //18
			0X0020,0X0020,0X0020,0X0020, //1C
			0X0020,0X0020,0X0020,0X0020, //20
			0X0020,0X0020,0X0020,0X0020, //24 
			0X0020,0X0020,0X0020,0X0020, //28
			0X0020,0X0020,0X0020,0X0020, //2C
			0X0020,0X0020,0X0020,0X0020, //30
			0X0020,0X0020,0X0020,0X0020, //34 
			0X0020,0X0020,0X0020,0X0020, //38
			0X0020,0X0020,0X0020,0X0020, //3C        
			0X0020,0x0041,0x0042,0x0043, //40 41-49=A-I
			0x0044,0x0045,0x0046,0x0047, //44 
			0x0048,0x0049,0X0020,0X0020, //48
			0X0020,0X0020,0X0020,0X0020, //4C
			0X0020,0x004A,0x004B,0x004C, //50 4A-52=J-R
			0x004D,0x004E,0x004F,0x0050, //54 
			0x0051,0x0052,0X0020,0X0020, //58
			0X0020,0X0020,0X0020,0X0020, //5C
			0X0020,0X0020,0x0053,0x0054, //60 53-5A=S-Z
			0x0055,0x0056,0x0057,0x0058, //64 
			0x0059,0x005A,0X0020,0X0020, //68
			0X0020,0X0020,0X0020,0X0020, //6C
			0x25CA,0x005E,0x00A8,0x25D8, //70 DIAMOND,UP ARROW, DIAERESIS, INVERSE BULLET
			0X0020,0X20AC,0X251C,0X251D, //74 ?,EURO,VERT-RIGHT,VERT-LEFT
			0X0076,0X0020,0X0020,0X0020, //78 v
			0X0020,0X0020,0X0020,0X0020, //7C 
			0X007E,0X2551,0X2550,0X2502, //80 TILDE,VERT BARS,HORZ BARS,VERT LEFT BAR
			0X2502,0X2502,0X0020,0X0020, //84 VERT BAR RIGHT, VERT BAR CENTER
			0X0020,0X0020,0X2191,0X2193, //88 ,,UP ARROW,DOWN ARROW
			0X2264,0X250C,0X2514,0X2192, //8C LE, DOWN-RIGHT,UP-RIGHT,RIGHT ARROW
			0X25A1,0X258C,0X2590,0X2580, //90 WHITE BOX,LEFT BLK,RIGHT BLK, TOP BLK
			0X2584,0X2588,0X0020,0X0020, //94 BOTTOM BLK, FULL BLK
			0X0020,0X0020,0X003E,0X003C, //98 ,,GT,LT
			0X263C,0X25E6,0X00B1,0X2190, //9C SUN RAYS, WHITE BULLET,+/-, LEFT ARROW
			0X00AF,0X25CB,0X2015,0X25CA, //A0 TOP BAR,WHITE CIRCLE, HORZ BAR,DIAMOND
			0X006E,0X0020,0X0020,0X0020, //A4 LC N
			0X0020,0X0020,0X006E,0X0055, //A8 ,,LC N,UC U
			0X2534,0X005B,0X2265,0X25CB, //AC HORZ+UP,LEFT BRACE, GE, WHITE CIRCLE
			0X01A1,0X212E,0X006C,0X0070, //B0 O+HORN,e, L, P
			0X03C9,0X0020,0X0058,0X005C, //B4 OMEGA,,X,REV SLASH
			0X00F7,0X0020,0X25BC,0X25B2, //B8 DIVIDE,,ARROW DOWN, ARROW UP
			0X252C,0X005D,0X2260,0X2502, //BC HORZ+DOWN,RIGHT BRACE, NE, VERT BAR
			0X007B,0X0028,0X002B,0X25A0, //C0 LEFT BRACE,LEFT PAREN,PLUS, BLACK BLK
			0X2514,0X250C,0X251C,0X2534, //C4 UP RIGHT,DOWN RIGHT,VIRT+RIGHT,HORZ+UP
			0X00A7,0X0020,0X02C6,0X0076, //C8 SECT SIGN,TILDE+UP ARROW,TILDE+DOWN ARROW
			0X25A1,0X03A6,0X25A1,0X01FE, //CC WHITE BOX, CAP PHI, WHITE BOX+SLASH,O+SLASH
			0X007D,0X0029,0X002D,0X002B, //D0 RIGHT BRACE, RIGHT PAREN, MINUS, PLUS
			0X2518,0X2510,0X2524,0X252C, //D4 RIGHT+UP,RIGHT+DOWN,VERT+RIGHT, HORZ+DOWN
			0X00B6,0X0020,0X0049,0X0021, //D8 PILCROW,,I,!
			0X25BC,0X25B2,0X25A1,0X0041, //DC ARROW DOWN, ARROW UP, BLK, A
			0X2261,0X0031,0X0032,0X0033, //E0 IDENTICAL,1,2,3
			0X0020,0X0020,0X0020,0X0020, //E4 
			0X0020,0X0020,0X0078,0X0078, //E8 ,,X?,X?
			0X003A,0X03B8,0X25A1,0X03A6, //EC COLON?,THETA+TOP BAR, BOX, 
			0X0030,0X0031,0X0032,0X0033, //F0 0-3
			0X0034,0X0035,0X0036,0X0037, //F4 4-7
			0X0038,0X0039,0X25BC,0X25B2, //F8 8,9,TILDE+DOWN ARROW, UP ARROW+UNDERLINE
			0X0058,0X03B8,0X0020,0X0020, //FC X+BOX,THETA+UNDERLINE
	};


	/**
	 * Create instance of gz390 class.
	 * @param args - Command line arguments
	 */
	public static void main(final String[] args)
	{
		final gz390 pgm = new gz390();
		pgm.set_main_mode(args);
		pgm.init_gz390(args);
	}

	/**
	 * Set main program execution mode.
	 * Set security permissions.
	 * Notes:
	 *   1. Called from main() or init before gz390 instance started so only set class variables.
  	 * 
	 * @param args
	 * @return
	 */
	private int set_main_mode(final String[] args)
	{
		// Check and complain about wrong Java version...
		final InfoOS infoOS = InfoOS.getInstance();
		if (!infoOS.isCorrectJava()) {
			final MessageBox box = new MessageBox();
			box.messageBox("GZ390E error ", infoOS.getMessageIncorrectJavaVersion());
			exit_main(16);
		}

		// JBA - Added.
		// Do not create new tz390 if called via start_guam()
		if (tz390 == null) {
			tz390 = new tz390();
		}
		// main_demo = false;
		// main_lic  = false;

		// Check for security manager and set permissions
		perms.doChecks();

		// Switch to demo mode if no read permission
		if ( !perms.mayReadFiles() ) {
			mode_msg1 = "Permission to read files denied - continuing in demo mode.";
			mode_msg2 = "Note: Demo mode not implemented yet.";
			// main_demo = true;
			// main_lic  = false;
			return 0;
		}

		// main_lic = true;
		// main_demo = false;
		return 0;
	}

	private void log_error(final int error, final String msg)
	{
		final StringBuilder sb = new StringBuilder();
		sb.append("GZ390E error ").append(error).append(" ").append(msg);

		gz390_errors++;
		cmd_error = true;
		guam_put_log(sb.toString());

		if (tz390.max_errors != 0 && gz390_errors > tz390.max_errors) {
			abort_error(101, "Maximum errors exceeded (max is " + tz390.max_errors + ")");
		}
	}

	private void abort_error(final int error, final String msg)
	{
		gz390_errors++;
		tpg_rc = 8;
		status_line.setText(status_line_view + " " + msg);

		final StringBuilder sb = new StringBuilder();
		sb.append("GZ390E ").append(error).append(" ").append(msg);

		guam_put_log(sb.toString());
		System.out.println(sb.toString());

		if (tz390.z390_abort) {
			exit_main(16); // exit now to prevent loop
		} else {
			tz390.z390_abort = true; // abort all processes
		}
	}

	/**
	 * Cancel threads and exit with RC (turn off runtime shutdown exit).
	 * @param return_code
	 */
	private void shut_down(final int return_code)
	{
		if  (!tz390.z390_abort) {
			abort_error(58, "GUAM GUI window closed.");
			int count = 5;
			while (count > 0) {
				tz390.sleep_now(monitor_wait); // RPI 220 wait for ez390 to term
				count--;
			}
			return;
		}
		tz390.z390_abort = true; // force ez390/pz390 shutdown
		if (monitor_timer != null) {
			monitor_timer.stop();
		}
		if (main_frame != null) {
			main_frame.dispose();
		}
		if (!shutdown_exit) {
			shutdown_exit = true; //disable exit
			System.exit(return_code);
		}
	}

	/**
	 * 1. Parse parameters and execute gz390 command if found.
	 *    a. * in position 1 is a comment
	 *    e. space or null logged as blank line 
	 * 2. If not a known gz390 command, issue CMD Windows command.
	 * @param cmd_line
	 */
	private void process_command(final String cmd_line)
	{
		/* 
		 * Notes:
		 * 1.  gz390_cmd_line event handler routes input to CMD processor when in cmd_mode.
		 * 2.  Some commands will issue retry or cancel error message if command
		 *     running on separate thread to avoid file conflicts or deadlocks.  Other
		 *     non destructive commands will proceed in parallel which may cause log 
		 *     messages to be intermixed.
		 * 3.  Status bar shows progress of command processes on separate threads.
		 * 4.  Use EXIT or BREAK event to abort CMD process. CTRL-C works in command mode only.
		 */
		try {
			cmd_error = false;
			if  (cmd_line == null || cmd_line.length() == 0 || cmd_line.equals(" ")) {
				return;
			}
			String cmd_parm1 = null;
			String cmd_parm2 = null;
			final StringTokenizer st = new StringTokenizer(cmd_line," ,\'\"",true);
			final String cmd_opcode = get_next_parm(st,true).toUpperCase();
			if (st.hasMoreTokens()) {
				cmd_parm1 = get_next_parm(st,true);
				if (st.hasMoreTokens()) {
					cmd_parm2 = get_next_parm(st,true);
					while (st.hasMoreTokens()) {
						final String next_token = st.nextToken();
						if (next_token != null && !next_token.equals(" ")) {
							cmd_parm2 = cmd_parm2 + " " + next_token; 
						}
					}
				}
				if (cmd_parm1 != null && cmd_parm1.equals(",")) {
					cmd_parm1 = null;
					cmd_parm2 = null;
				}
			}
			boolean cmd_opcode_ok = false;
			final char first_char = cmd_opcode.charAt(0);
			switch (first_char) {
			case 'A': break;
			case 'B': break;
			case 'C': break;
			case 'D': break;
			case 'E': break;
			case 'F': break;
			case 'G': break;
			case 'H': break;
			case 'I': break;
			case 'J': break;
			case 'L': break;
			case 'M': break;
			case 'N': break;
			case 'O': break;
			case 'P': break;
			case 'R': break;
			case 'S': break;
			case 'T': break;
			case 'U': break;
			case 'V': break;
			case 'W': break;
			case 'X': break;
			case '*': cmd_opcode_ok = true; break;
			}

			// Add to history if OK.
			if  (cmd_opcode_ok) {
				cmdHistory.add_cmd_hist(cmd_line); // add_cmd_hist();
			}
		} catch (final Exception e) {
			log_error(7, "Command error on -" + cmd_line);
		}
	}

	/**
	 * Get string with or without single/double quotes.
	 * Ignore leading spaces or commas if ignore_spaces = true, else return null if space or comma found next.
	 * @param st
	 * @param ignore_spaces
	 * @return
	 */
	private String get_next_parm(final StringTokenizer st, final boolean ignore_spaces)
	{
		String parm_string = st.nextToken();
		while (ignore_spaces && parm_string.equals(" ") && st.hasMoreElements()) {
			parm_string = st.nextToken();
		}
		if  (parm_string.equals("\"") || parm_string.equals("\'")) {
			final String delimiter = parm_string;
			String next_token = "";
			while (st.hasMoreTokens() && !next_token.equals(delimiter)) {
				next_token = st.nextToken();
				parm_string = parm_string + next_token;
			}
		} else {
			if  (parm_string.equals(" ")) {
				parm_string = null;
			}
		}
		return parm_string;
	}

	private void about_command()
	{
		guam_put_log("\nz390 GUAM GUI gz390 Graphical User Access Method " + tz390.version);
		guam_put_log("Copyright 2011 Automated Software Tools Corporation");
		guam_put_log("z390 is licensed under GNU General Public License");
		guam_put_log("gz390 supports MCS, TN3270, and Graphic panel views");
		guam_put_log("gz390 J2SE Java source is distributed as part of z390");
		guam_put_log("Visit www.z390.org for additional information and support");

		if (mode_msg1 != null) { guam_put_log(mode_msg1); }
		if (mode_msg2 != null) { guam_put_log(mode_msg2); }
	}

	/**
	 * Reset font size.
	 * @param newFontSize
	 */
	private void font_command(final int newFontSize)
	{
		if (   newFontSize < Constants.minFontSize
			|| newFontSize > Constants.maxFontSize) {
			log_error(8, "Font size outside fixed width font limits ["
						+ Constants.minFontSize + ".." + Constants.maxFontSize + " pt].");
		} else {
			font_size = newFontSize;
			set_text_font();
			set_tooltips();
			refresh_request = true;
		}
	}

	/**
	 * Reset font size for menu, log, cmd and status line. 
	 */
	private void set_text_font()
	{
		set_char_font();
		menuBar.setFont(             char_font); // RPI 81
		file_menu.setFont(           char_font);
		edit_menu.setFont(           char_font);
		view_menu.setFont(           char_font);
		help_menu.setFont(           char_font); 
		file_menu_exit.setFont(      char_font);
		edit_menu_cut.setFont(       char_font); 
		edit_menu_copy.setFont(      char_font);
		edit_menu_paste.setFont(     char_font);
		edit_menu_select_all.setFont(char_font);
		edit_menu_copy_log.setFont(  char_font);
		edit_menu_notepad.setFont(   char_font);
		view_menu_mcs.setFont(       char_font);
		view_menu_tn3270.setFont(    char_font);
		view_menu_graph.setFont(     char_font);
		help_menu_help.setFont(      char_font);
		help_menu_support.setFont(   char_font);
		help_menu_about.setFont(     char_font);
		log_text.setFont(            char_font);
		cmd_label.setFont(           char_font);
		gz390_cmd_line.setFont(      char_font);
		status_label.setFont(        char_font);
		status_line.setFont(         char_font);
	}

	/**
	 * Log summary list of commands and help reference.
	 */
	private void help_command()
	{
		guam_put_log("\nz390 GUAM GUI z390 Graphical User Access Method Help");
		guam_put_log("View menu MCS     - Display WTO and WTOR scrolling window (default)");
		guam_put_log("View menu TN3270  - Display TPUT and TGET TN3270 window");
		guam_put_log("View menu Graph   - Display graph drawn by gz390 GKS commands");
		guam_put_log("Help menu Support - Link to www.z390.org"); 
	}

	/**
	 * Start monitor to terminate cmd command if timeout limit reached.
	 */
	private void monitor_startup()
	{
		monitor_last_time = System.currentTimeMillis();
		monitor_last_ins_count = ins_count;
		status_last_time = monitor_last_time;
		status_last_ins_count = ins_count;
		try {
			ActionListener cmd_listener = new ActionListener() {
				public void actionPerformed(final ActionEvent evt) {
					monitor_update();
				}
			};
			monitor_timer = new Timer(monitor_wait,cmd_listener);
			monitor_timer.start();
		} catch (final Exception e) {
			log_error(12, "Execution startup error " + e.toString());
		}
	}

	/**
	 * 1.  At monitor_wait intervals, update the GUAM GUI title date+time and the status line information.
	 * 2.  Update TN3270 screen from key typed buffer.
	 * 2.  Reset focus to gz390_cmd_line after wto.
	 */
	private void monitor_update()
	{
		refresh_wait = false;  // reset main_view wait
		monitor_next_time = System.currentTimeMillis();
		monitor_next_ins_count = ins_count;
		monitor_next_io_count = io_count;
		monitor_cur_interval = monitor_next_time - monitor_last_time;
		monitor_cmd_time_total = (monitor_next_time - start_cmd_time)/1000;
		title_update();
		if (!tn_scn_lock) {
			process_typed_keys(); // RPI 861		
		}
		check_main_view(); 
		monitor_last_time = monitor_next_time;
		monitor_last_ins_count  = monitor_next_ins_count;
		monitor_last_io_count   = monitor_next_io_count;
	}

	/*
	 **************************************************
	 * Command support functions
	 **************************************************  
	 */

	/**
	 * Initialize first time or if rows specified. RPI 308
	 */
	private void init_tn3270_screen()
	{
		tn_scn = new gz390_screen(tz390);
		// tn_scn.tz390 = tz390; // RPI 671
		set_char_font();
		init_tn3270_arrays(max_rows, max_cols);
		tn_scn.setScreen(max_rows, max_cols, char_font, bg_color, tx_color);
		tn_clear_screen();
	}
	
	private void init_tn3270_arrays(final int rows, final int cols)
	{
		max_cols = cols;
		max_rows = rows;
		max_addr = rows * cols;

		// Array with address of all fields ascending
		fld_addr = new int[max_addr];

		fld_mdt_tot  = 0; // fields with mdt bit on RPI 1061 include PA_MDT
		fld_mdt_addr = new int[max_addr];  // RPI 1061 all fields with mdt on

		// TN3270 screen
		scn_fld   = new boolean[max_addr];
		scn_attr  = new int[    max_addr];
		scn_hl    = new int[    max_addr];
		scn_color = new int[    max_addr];
		scn_char  = new char[   max_addr]; // set to display char else blank   
		scn_addr  = 0;
	}

	/**
	 * Initialize GUI (graphical user interface).
	 * @param args
	 */
	private void init_gz390(final String[] args)
	{
		init_tn3270_screen();
		main_frame = new JFrame();
		title_update();
		main_frame.setSize(tn_scn.main_width, tn_scn.main_height);
		main_frame.setLocation(main_loc_x, main_loc_y);
		main_frame.addComponentListener(this);
		build_main_panel();
		set_char_font();
		update_main_view();
		monitor_startup();
		gz390_cmd_line.requestFocus();
	}

	/**
	 *  Build the main panel with:
	 *    a.  Scrolling log display
	 *    b.  command entry field
	 */
	private void build_main_panel()
	{
		main_panel = new JPanel();
		main_panel.setBorder(BorderFactory.createEmptyBorder(0, Constants.numBorderWidth, Constants.numBorderWidth, Constants.numBorderWidth));
		main_panel.setLayout(new FlowLayout(FlowLayout.LEFT)); 
		build_menu_items();
		set_tooltips();
		build_log_view();
		build_gz390_cmd_line();
		build_status_line();
		set_text_font();
		menuBar.add(file_menu);
		menuBar.add(edit_menu);
		menuBar.add(view_menu);
		menuBar.add(help_menu);
		main_frame.setJMenuBar(menuBar);
		main_panel.add(main_view);
		main_panel.add(cmd_label);
		main_panel.add(gz390_cmd_line);
		main_panel.add(status_label);
		main_panel.add(status_line);
		main_frame.getContentPane().add(main_panel);
		main_frame.addWindowListener(new WindowAdapter() {
			public void windowClosing(final WindowEvent e) {
				exit_main(0);
			}
		});
		refresh_request = true;
	}

	/**
	 * 
	 * @param rc
	 */
	private void exit_main(final int rc)
	{
		shut_down(rc);
	}

	/**
	 * Initialize tn3270 screen fonts using current font size
	 */
	private void set_char_font()
	{
		char_font = new Font(tz390.z390_font,Font.BOLD,font_size);
	}

	/**
	 * Build scrolling log view based on current screen and font size.
	 */
	private void build_log_view()
	{
		log_text = new JTextArea();
		log_text.addMouseListener(this);
		main_view = new JScrollPane(log_text);
		main_view.getVerticalScrollBar().addAdjustmentListener(new AdjustmentListener() {
			public void adjustmentValueChanged(final AdjustmentEvent e) {
				if (main_view_changed){
					main_view_changed = false;
					main_view.getVerticalScrollBar().setValue(main_view.getVerticalScrollBar().getMaximum());
				}
			}});
		main_view.setVerticalScrollBarPolicy(JScrollPane.VERTICAL_SCROLLBAR_ALWAYS);
	//	main_view.setPreferredSize(new Dimension(log_width, log_height));
	}

	/**
	 * Build the command entry field.
	 */
	private void build_gz390_cmd_line()
	{
		cmd_label = new JLabel("Command: ");
		gz390_cmd_line = new JTextField(Constants.numDefaultCommandColumns);
		gz390_cmd_line.addActionListener(this);
		gz390_cmd_line.addMouseListener(this);
		gz390_cmd_line.addKeyListener(this);
		gz390_cmd_line.addFocusListener(this);
	}

	/**
	 * Build the status line.
	 */
	private void build_status_line()
	{
		status_label = new JLabel(" Status: ");
		status_line = new JTextField(Constants.numDefaultCommandColumns);
		status_line.addActionListener(this);
		status_line.addMouseListener(this);
		status_line.addKeyListener(this);
		status_line.addFocusListener(this);
	}

	/**
	 * Build the menu bar.
	 */
	private void build_menu_items()
	{
		menuBar = new JMenuBar();
		file_menu = new JMenu("File");
		edit_menu = new JMenu("Edit");
		view_menu = new JMenu("View");
		help_menu = new JMenu("Help");
		file_menu_exit   = new JMenuItem("Exit");
		edit_menu_cut    = new JMenuItem("Cut");
		edit_menu_copy   = new JMenuItem("Copy");
		edit_menu_paste  = new JMenuItem("Paste");
		edit_menu_select_all = new JMenuItem("Select All");
		edit_menu_copy_log   = new JMenuItem("Copy Log");
		edit_menu_notepad = new JMenuItem("Notepad");
		view_menu_mcs    = new JCheckBoxMenuItem("MCS");
		view_menu_mcs.setState(true);
		view_menu_tn3270   = new JCheckBoxMenuItem("TN3270");
		view_menu_graph  = new JCheckBoxMenuItem("Graph");
		help_menu_help       = new JMenuItem("Help");
		help_menu_support    = new JMenuItem("Support");
		help_menu_about      = new JMenuItem("About");

		// Mnemonic menu bar keys
		file_menu.setMnemonic(           KeyEvent.VK_F);
		edit_menu.setMnemonic(           KeyEvent.VK_E);
		view_menu.setMnemonic(           KeyEvent.VK_V);
		help_menu.setMnemonic(           KeyEvent.VK_H);
		file_menu_exit.setMnemonic(      KeyEvent.VK_X);
		edit_menu_cut.setMnemonic(       KeyEvent.VK_T);
		edit_menu_copy.setMnemonic(      KeyEvent.VK_C);
		edit_menu_paste.setMnemonic(     KeyEvent.VK_P);
		edit_menu_select_all.setMnemonic(KeyEvent.VK_S);
		edit_menu_copy_log.setMnemonic(  KeyEvent.VK_L);
		edit_menu_notepad.setMnemonic(   KeyEvent.VK_N);
		view_menu_mcs.setMnemonic(       KeyEvent.VK_M);
		view_menu_tn3270.setMnemonic(    KeyEvent.VK_3);
		view_menu_graph.setMnemonic(     KeyEvent.VK_G);
		help_menu_help.setMnemonic(      KeyEvent.VK_H);
		help_menu_support.setMnemonic(   KeyEvent.VK_S);
		help_menu_about.setMnemonic(     KeyEvent.VK_A);

		// Set menu bar accelerator keys
		file_menu_exit.setAccelerator(   KeyStroke.getKeyStroke(KeyEvent.VK_Z,ActionEvent.CTRL_MASK));
		edit_menu_cut.setAccelerator(    KeyStroke.getKeyStroke(KeyEvent.VK_E,ActionEvent.CTRL_MASK));
		edit_menu_copy.setAccelerator(   KeyStroke.getKeyStroke(KeyEvent.VK_C,ActionEvent.CTRL_MASK));
		edit_menu_paste.setAccelerator(  KeyStroke.getKeyStroke(KeyEvent.VK_V,ActionEvent.CTRL_MASK));
		edit_menu_notepad.setAccelerator(KeyStroke.getKeyStroke(KeyEvent.VK_N,ActionEvent.CTRL_MASK));
		view_menu_mcs.setAccelerator(    KeyStroke.getKeyStroke(KeyEvent.VK_M,ActionEvent.CTRL_MASK+ActionEvent.SHIFT_MASK));
		view_menu_tn3270.setAccelerator( KeyStroke.getKeyStroke(KeyEvent.VK_3,ActionEvent.CTRL_MASK+ActionEvent.SHIFT_MASK));
		view_menu_graph.setAccelerator(  KeyStroke.getKeyStroke(KeyEvent.VK_G,ActionEvent.CTRL_MASK+ActionEvent.SHIFT_MASK));
		help_menu_help.setAccelerator(   KeyStroke.getKeyStroke(KeyEvent.VK_H,ActionEvent.CTRL_MASK+ActionEvent.ALT_MASK));
		help_menu_support.setAccelerator(KeyStroke.getKeyStroke(KeyEvent.VK_S,ActionEvent.CTRL_MASK+ActionEvent.ALT_MASK));
		help_menu_about.setAccelerator(  KeyStroke.getKeyStroke(KeyEvent.VK_A,ActionEvent.CTRL_MASK+ActionEvent.ALT_MASK));

		// Add menu action listeners
		file_menu_exit.addActionListener(this);
		edit_menu_cut.addActionListener(this);
		edit_menu_copy.addActionListener(this);
		edit_menu_paste.addActionListener(this);
		edit_menu_select_all.addActionListener(this);
		edit_menu_copy_log.addActionListener(this);
		edit_menu_notepad.addActionListener(this);
		view_menu_mcs.addActionListener(this);
		view_menu_tn3270.addActionListener(this);
		view_menu_graph.addActionListener(this);
		help_menu_help.addActionListener(this);
		help_menu_support.addActionListener(this);
		help_menu_about.addActionListener(this);

		file_menu.add(file_menu_exit); 
		edit_menu.add(edit_menu_cut);
		edit_menu.add(edit_menu_copy);
		edit_menu.add(edit_menu_paste);
		edit_menu.add(edit_menu_select_all);
		edit_menu.add(edit_menu_copy_log);
		edit_menu.add(edit_menu_notepad);
		view_menu.add(view_menu_mcs);
		view_menu.add(view_menu_tn3270);
		view_menu.add(view_menu_graph);
		help_menu.add(help_menu_help);
		help_menu.add(help_menu_support);
		help_menu.add(help_menu_about);
	}

	/**
	 * Set tool-tips after font changes.
	 */
	private void set_tooltips()
	{
		final String text_font_pfx = "<html><font size=" + font_size/3 + ">";
		final String text_font_sfx = "</html>";

		file_menu_exit.setToolTipText(      text_font_pfx + "Exit gz390 GUAM GUI" + text_font_sfx);
		edit_menu_cut.setToolTipText(       text_font_pfx + "Cut selected text" + text_font_sfx);
		edit_menu_copy.setToolTipText(      text_font_pfx + "Copy selected text to clipboard" + text_font_sfx);
		edit_menu_paste.setToolTipText(     text_font_pfx + "Paste clipboard text (append if log has focus" + text_font_sfx);
		edit_menu_select_all.setToolTipText(text_font_pfx + "Select all text" + text_font_sfx);
		edit_menu_copy_log.setToolTipText(  text_font_pfx + "Copy current log file to clipboard" + text_font_sfx);
		edit_menu_notepad.setToolTipText(   text_font_pfx + "Launch notepad to edit selected data on clipboard" + text_font_sfx);
		view_menu_mcs.setToolTipText(       text_font_pfx + "MCS WTO and WTOR console" + text_font_sfx);
		view_menu_tn3270.setToolTipText(    text_font_pfx + "TN3270 TPUT and TGET terminal screen" + text_font_sfx);
		view_menu_graph.setToolTipText(     text_font_pfx + "GKS graphic display" + text_font_sfx);
		help_menu_help.setToolTipText(      text_font_pfx + "Display summary of menu selections" + text_font_sfx);
		help_menu_support.setToolTipText(   text_font_pfx + "Link to www.z390.org web site for support information" + text_font_sfx);
		help_menu_about.setToolTipText(     text_font_pfx + "Display information about this version of gz390" + text_font_sfx);
	}

	/**
	 * Update main frame title with current date and time.
	 */
	private void title_update()
	{
		final Date cur_date = new Date();
		final StringBuilder sb = new StringBuilder();
		sb.append(main_title).append("   ")
		   .append(mmddyy.format(cur_date)).append(" ").append(hhmmss.format(cur_date));
		main_frame.setTitle(sb.toString());
	}

	/**
	 * Perform menu and command line requests.
	 */
	public void actionPerformed(final ActionEvent event)
	{
		final String event_name = event.getActionCommand().toUpperCase();
		if  (gz390_cmd_line.hasFocus()) {
			final String cmd_line = gz390_cmd_line.getText();
			reset_gz390_cmd();
			if  (wtor_running) {
				wtor_reply_string = cmd_line;
				wtor_running = false;
			} else {
				exec_guam_command();
			}
			return;
		}

		boolean event_ok = false;
		final char first_char = event_name.charAt(0);
		switch (first_char) {
		case 'A':
			if (event_name.equals("ABOUT")) {
				event_ok = true;
				about_command();
			}
			break;
		//case 'B':
		//	break;
		case 'C':	
			if (event_name.equals("COPY")) {
				event_ok = true;
				if  (log_text == focus_comp) {
					log_text.copy();
				}
				if  (gz390_cmd_line ==  focus_comp) {
					gz390_cmd_line.copy();
				}
			}
			if (event_name.equals("COPY LOG")) {
				event_ok = true;
				log_text.requestFocus();
				log_text.selectAll();
				log_text.copy();
			}
			if (event_name.equals("CUT")) {
				event_ok = true;
				if  (gz390_cmd_line ==  focus_comp){
					gz390_cmd_line.cut();
				}
			}
			break;
		//case 'D':
		//	break;
		case 'E':
			if (event_name.equals("EXIT")) {
				event_ok = true;
				exit_command();
			}
			break;
		case 'G':
			if (event_name.equals("GRAPH")) {
				if (guam_view != GuamViewTypes.GRAPH) {
					set_view_graph(0,0,0);
				}
			}
			break;
		case 'H':
			if (event_name.equals("HELP")) {
				event_ok = true;
				help_command();
			}
			break;
		//case 'J':
		//	break;
		//case 'L':
		//	break;
		case 'M':
			if (event_name.equals("MCS")) {
				event_ok = true;
				if (guam_view != GuamViewTypes.MCS) {
					set_view_mcs();
				}
			}
			break;
		case 'N':
			if (event_name.equals("NOTEPAD")) {
				event_ok = true;
				exec_cmd("NOTEPAD");
			}
			break;
		//case 'O':
		//	break;
		case 'P':
			if (event_name.equals("PASTE")) {
				event_ok = true;
				if  (log_text == focus_comp) {
					guam_put_log("PASTE from clipboard starting " + time_stamp());
					guam_put_log(getClipboard()); // append to log
					guam_put_log("PASTE from clipboard ending   " + time_stamp());
				}
				if  (gz390_cmd_line ==  focus_comp){
					gz390_cmd_line.paste();
				}
			}
			break;
		//case 'R':
		//	break;
		case 'S':
			if (event_name.equals("SELECT ALL")){
				event_ok = true;
				if  (log_text == focus_comp){
					log_text.selectAll();
				}
				if  (gz390_cmd_line ==  focus_comp){
					gz390_cmd_line.selectAll();
				}
			}
			if (event_name.equals("SUPPORT")){
				event_ok = true;
				final InfoOS infoOS = InfoOS.getInstance();
				exec_cmd(infoOS.get_z390_browser() + " http://www.z390.org");
			}
			break;
		case 'T':
			if (event_name.equals("TN3270")) {
				if (guam_view != GuamViewTypes.SCREEN) {
					set_view_screen(0,0,0);
					tn_kb_lock = false;
				}
			}
			break;
		//case 'V':
		//	break;
		}

		// If event_ok not set, execute command from JTextField.
		if (!event_ok) {
			exec_guam_command();
		}
	}

	/**
	 * Return date and time if opt_timing.
	 * @return
	 */
	private String time_stamp()
	{
		final Date temp_date = new Date(); 
		return mmddyy.format(temp_date) + " " + hhmmss.format(temp_date);
	}

	/**
	 * Execute command
	 */
	private void exec_guam_command()
	{
		String cmd_line = gz390_cmd_line.getText();
		if  (cmd_line == null || cmd_line.length() == 0) {
			cmd_line = " ";
		}
		reset_gz390_cmd();
		process_command(cmd_line); 
	}

	/**
	 * Reset gz390_cmd text and set focus.
	 */
	private void reset_gz390_cmd()
	{
		gz390_cmd_line.setText("");
		gz390_cmd_line.requestFocus();
	}

	/**
	 * Execute command as separate task.
	 * @param cmd
	 * @return
	 */
	private boolean exec_cmd(final String cmd)
	{
		if (perms.mayExecFiles()) { // if (perm_file_execute){
			try {
				Runtime.getRuntime().exec(cmd);
				return true;
			} catch(final Exception e) {
				return false;
			}
		} else {
			return false;
		}
	}

	/**
	 * Get string text from system clipboard.
	 * @return
	 */
	public static String getClipboard()
	{
		final Transferable t = Toolkit.getDefaultToolkit().getSystemClipboard().getContents(null);
		try {
			if (t != null && t.isDataFlavorSupported(DataFlavor.stringFlavor)) {
				final String text = (String)t.getTransferData(DataFlavor.stringFlavor);
				return text;
			}
		} catch (final UnsupportedFlavorException e) {
		} catch (final Exception e) {
		}
		return null;
	}

	/**
	 * Put string to system clipboard.
	 * @param str
	 */
	public static void setClipboard(String str)
	{
		final StringSelection ss = new StringSelection(str);
		Toolkit.getDefaultToolkit().getSystemClipboard().setContents(ss, null);
	}

	/**
	 * Handle key pressed events.
	 */
	public void keyPressed(KeyEvent e)
	{
		// displayInfo(e, "KEY PRESSED: "); //dsh 
		final int key_code = e.getKeyCode();
		final int key_mods = e.getModifiers();
		if  (e.isActionKey()){
			process_action_key_pressed(key_code,key_mods,e);
		} else {  // not action key
			process_non_action_key_pressed(key_code,key_mods,e);        	   
		}
		if (    key_code == KeyEvent.VK_CLEAR
			|| (key_code == KeyEvent.VK_C && key_mods == KeyEvent.CTRL_MASK)){
			if (!tn_kb_lock){
				tn_aid = tn_clear_code; // clear key
				tn_attn = true;
				tn_clear_screen(); 
			}
		}
	}

	/**
	 * Process action key after processing any pending typed keys.
	 * @param key_code
	 * @param key_mods
	 * @param e
	 */
	private void process_action_key_pressed(int key_code,int key_mods, KeyEvent e)
	{
		process_typed_keys();
		if (tn_kb_lock){
			// MCS mode action keys
			switch (key_code){
			case KeyEvent.VK_UP:
				gz390_cmd_line.setText(cmdHistory.get_prev_cmd()); // get_prev_cmd();
				return;
			case KeyEvent.VK_DOWN:
				gz390_cmd_line.setText(cmdHistory.get_next_cmd()); // get_next_cmd();
				return;
			}
		} else {
			switch (key_code) {
			case KeyEvent.VK_UP:
				scn_addr = scn_addr - max_cols;
				if (scn_addr < 0) {
					scn_addr = scn_addr + max_addr;
				}
				tn_update_cursor();
				return;
			case KeyEvent.VK_DOWN:
				scn_addr = scn_addr + max_cols;
				if (scn_addr >= max_addr) {
					scn_addr = scn_addr - max_addr;
				}
				tn_update_cursor();
				return;
			case KeyEvent.VK_LEFT:
				tn_scn_addr_dec();
				tn_update_cursor();
				return;
			case KeyEvent.VK_RIGHT:
				tn_scn_addr_inc();
				tn_update_cursor();
				return;
			}
		}
		if (key_mods == KeyEvent.CTRL_MASK){
			switch (key_code){
			case KeyEvent.VK_F1: 
				// CTRL-F1 = PA1
				if (!tn_kb_lock){
					tn_aid = tn_pa1_code;  // PA1
					tn_attn = true;
				}
				return;
			case KeyEvent.VK_F2:
				// CTRL-F2 = PA2
				if (!tn_kb_lock){
					tn_aid = tn_pa2_code;  //PA2
					tn_attn = true;
				}
				return;
			case KeyEvent.VK_F3:   
				// CTRL-F3 = PA3
				if (!tn_kb_lock){
					tn_aid = tn_pa3_code;  //PA3
					tn_attn = true;
				}
				return;
			case KeyEvent.VK_F6:   
				// CTRL-F6 = EEOF erase to end of current field
				if (!tn_kb_lock
						&& tn_input_field()){
					tn_erase_to_end(); // RPI 628
					tn_modify_field();  // RPI 861
				} else {
					sound_alarm_beep();
				}
				return;
			case KeyEvent.VK_F7:   
				// CTRL-F7 = EINF erase all unprotected fields
				if (!tn_kb_lock){
					tn_erase_all_unprotected(); // RPI 628
				}
				return;
			}
			return;
		}
		if (key_mods == (KeyEvent.ALT_MASK | KeyEvent.CTRL_MASK)){ 
			// RPI 216  CTRL-ALT-F1-12 = F13-24
			if (   key_code >= KeyEvent.VK_F1
				&& key_code <= KeyEvent.VK_F9){
				if (!tn_kb_lock){
					tn_aid = 0xc1 + key_code - KeyEvent.VK_F1;
					tn_attn = true;
				}
				return;
			}
			if (   key_code >= KeyEvent.VK_F10
				&& key_code <= KeyEvent.VK_F12){
				if (!tn_kb_lock){
					tn_aid = 0x4a + key_code - KeyEvent.VK_F10;
					tn_attn = true;
				}
				if (key_code == KeyEvent.VK_F10){
					e.consume(); // RPI 630 consume Windows annoying file menu popup for PF10
				}
				return;
			}
			return;
		}
		switch (key_code){
		case KeyEvent.VK_F1:   // F1 help
			if (!tn_kb_lock){
				tn_aid = 0xf1;
				tn_attn = true;
			} else {
				help_command();
			}
			return;
		case KeyEvent.VK_F2:   
			if (!tn_kb_lock){
				tn_aid = 0xf2;
				tn_attn = true;
			}
			return;
		case KeyEvent.VK_F3:   // F3 exit
			if (!tn_kb_lock){
				tn_aid = 0xf3;
				tn_attn = true;
				return;
			} else {
				process_cancel_key();
			}
			return;
		}
		if (   key_code >= KeyEvent.VK_F4
			&& key_code <= KeyEvent.VK_F9) {
			if (!tn_kb_lock){
				tn_aid = 0xf4 + key_code - KeyEvent.VK_F4;
				tn_attn = true;
			}
			return;
		}
		if (   key_code >= KeyEvent.VK_F10
			&& key_code <= KeyEvent.VK_F12) {
			if (!tn_kb_lock){
				tn_aid = 0x7a + key_code - KeyEvent.VK_F10;
				tn_attn = true;
			}
			if (key_code == KeyEvent.VK_F10) {
				e.consume(); // RPI 630 consume Windows annoying file menu popup for PF10
			}
			return;
		}
		if (   key_code >= KeyEvent.VK_F13
			&& key_code <= KeyEvent.VK_F21) {
			if (!tn_kb_lock){
				tn_aid = 0xc1 + key_code - KeyEvent.VK_F13;
				tn_attn = true;
			}
			return;
		}
		if (   key_code >= KeyEvent.VK_F22
			&& key_code <= KeyEvent.VK_F24) {
			if (!tn_kb_lock){
				tn_aid = 0x4a + key_code - KeyEvent.VK_F22;
				tn_attn = true;
			}
			return;
		}
	}

	/**
	 * Process enter, cancel, backspace, and delete (the rest are handled by key typed).
	 * @param key_code
	 * @param key_mods
	 * @param e
	 */
	private void process_non_action_key_pressed(final int key_code, final int key_mods, final KeyEvent e)
	{
		switch (key_code){
		case KeyEvent.VK_ENTER:
			if (!tn_kb_lock){
				process_typed_keys();
				tn_attn = true;
				tn_aid = tn_enter_code;
			}
			break;
		case KeyEvent.VK_BACK_SPACE:
			if (!tn_kb_lock){
				process_typed_keys();
				tn_scn_addr_dec();
				tn_update_cursor();
			}
			break;
		case KeyEvent.VK_DELETE: // RPI 630
			if (!tn_kb_lock){
				process_typed_keys();
			}
			tn_delete_request = true; 
			break;
		case KeyEvent.VK_CANCEL:
			process_typed_keys();
			process_cancel_key();
			break;
		}
	}

	/**
	 * Cancel cmd, or GUAM GUI cmd in response to F3 or CTRL-BREAK
	 */
	private void process_cancel_key()
	{
		abort_error(102,"GUAM GUI terminating due to external shutdown request");
		int count = 5;
		while (count > 0) {  // RPI 460
			tz390.sleep_now(monitor_wait); // RPI 220 wait for ez390 to term
			count--;
		}
	}

	/**
	 * Handle key typed events.
	 * collect any characters for accept which are placed in gz390_cmd_line
	 * by accept wait loop if not there already. First accept they are
	 * there, but following ones not? Hooky fix!
	 */
	public void keyTyped(final KeyEvent e)
	{
		// displayInfo(e, "KEY TYPED: "); //dsh
		if (guam_tot_key < max_keys){
			guam_key_code_char[guam_tot_key] = e.getKeyCode() << 16
					| (int) e.getKeyChar();
			guam_tot_key++;
		}
	}

	/**
	 * Process pending typed keys on monitor thread in ez390 and for all action keys.
	 */
	public synchronized void process_typed_keys() // RPI 861
	{
		char key_char = ' ';
		int index = 0;
		while (index < guam_tot_key) {
			key_char = (char) guam_key_code_char[index];
			switch (key_char){
			case KeyEvent.VK_TAB:
				if (!tn_kb_lock) {
					tn_tab();
				}
				break;
			case KeyEvent.VK_ENTER:
			case KeyEvent.VK_BACK_SPACE:
			case KeyEvent.VK_DELETE: // RPI 630 
			case KeyEvent.VK_CANCEL:
				// ignore keys handled in keypress
				break;
			default:
				if (!tn_kb_lock){
					if (tn_input_field()) {
						if ((scn_attr[cur_fld_addr] & tn_numeric_mask) == tn_numeric_mask
							&& (key_char < '0' || key_char > '9')) {
							sound_alarm_beep();
							status_line.setText(status_line_view + " Alarm - invalid key for numeric field");
							guam_tot_key = 0;
							return; 
						} else {
							tn_modify_field();
							scn_char[scn_addr] = key_char;
						}
						tn_update_scn(scn_addr);
						tn_next_input_addr();
						tn_update_cursor();
					} else {
						sound_alarm_beep();
						status_line.setText(status_line_view + " Alarm - invalid key for protected field");
						guam_tot_key = 0;
						return;
					}
				} else {
					sound_alarm_beep();
					status_line.setText(status_line_view + " Alarm - keyboard locked");
					guam_tot_key = 0;
					return;
				}
			}
			index++;
		}
		guam_tot_key = 0;
	}

	/**
	 * Handle key released events
	 */
	public void keyReleased(KeyEvent e)
	{
		// displayInfo(e, "KEY RELEASED: "); //dsh
	}

	/**
	 * Display information...
	 * @param e
	 * @param s
	 */
	protected void displayInfo(KeyEvent e, String s)
	{
		String keyString, modString, tmpString, actionString, locationString;

		// You should only rely on the key char if the event
		// is a key typed event.
		int id = e.getID();
		if (id == KeyEvent.KEY_TYPED) {
			char c = e.getKeyChar();
			keyString = "key character = '" + c + "'";
		} else {
			final int key_code = e.getKeyCode();
			keyString = "key code = " + key_code + " (" + KeyEvent.getKeyText(key_code) + ")";
		}

		final int modifiers = e.getModifiersEx();
		modString = "modifiers = " + modifiers;
		tmpString = KeyEvent.getModifiersExText(modifiers);
		if (tmpString.length() > 0) {
			modString += " (" + tmpString + ")";
		} else {
			modString += " (no modifiers)";
		}

		actionString = "action key? ";
		if (e.isActionKey()) {
			actionString += "YES";
		} else {
			actionString += "NO";
		}

		locationString = "key location: ";
		final int location = e.getKeyLocation();
		switch (location) {
		case KeyEvent.KEY_LOCATION_STANDARD:
			locationString += "standard";
			break;
		case KeyEvent.KEY_LOCATION_LEFT:
			locationString += "left";
			break;
		case KeyEvent.KEY_LOCATION_RIGHT:
			locationString += "right";
			break;
		case KeyEvent.KEY_LOCATION_NUMPAD:
			locationString += "numpad";
			break;
		default: // KeyEvent.KEY_LOCATION_UNKNOWN)
			locationString += "unknown";
			break;
		}

		final String newline = "\n";
		System.out.println(s + newline + "    " + keyString + newline + "    "
				+ modString + newline + "    " + actionString + newline
				+ "    " + locationString + newline);
	}

	/**
	 * Pop-up edit menu on right mouse click.
	 */
	public void mousePressed(final MouseEvent e)
	{
		check_main_view();
		if (e.getButton() == MouseEvent.BUTTON3) {
			if (popup_edit_menu == null) {
				popup_edit_menu = new JPopupMenu();
				JMenuItem popup_edit_menu_cut      = new JMenuItem("Cut");
				JMenuItem popup_edit_menu_copy     = new JMenuItem("Copy");
				JMenuItem popup_edit_menu_paste  = new JMenuItem("Paste");
				JMenuItem popup_edit_menu_select_all = new JMenuItem("Select All");
				JMenuItem popup_edit_menu_copy_log = new JMenuItem("Copy Log");
				JMenuItem popup_edit_menu_notepad = new JMenuItem("Notepad");
				popup_edit_menu.add(popup_edit_menu_cut);
				popup_edit_menu.add(popup_edit_menu_copy);
				popup_edit_menu.add(popup_edit_menu_paste);
				popup_edit_menu.add(popup_edit_menu_select_all);
				popup_edit_menu.add(popup_edit_menu_copy_log);
				popup_edit_menu.add(popup_edit_menu_notepad);
				popup_edit_menu_cut.addActionListener(this);
				popup_edit_menu_copy.addActionListener(this);
				popup_edit_menu_paste.addActionListener(this);
				popup_edit_menu_select_all.addActionListener(this);
				popup_edit_menu_copy_log.addActionListener(this);
				popup_edit_menu_notepad.addActionListener(this);
			}
			Component mouse_comp = e.getComponent();
			if  (mouse_comp == log_text) {
				focus_comp = log_text; //force log focus for edit
			}
			popup_edit_menu.show(mouse_comp,e.getX(),e.getY());
		}
	}

	public void mouseReleased(final MouseEvent e) {}

	public void mouseEntered(final MouseEvent e) {}

	public void mouseExited(final MouseEvent e) {}

	public void mouseClicked(final MouseEvent e) {}

	public void focusLost(final FocusEvent e)
	{
		// Last component to lose focus (ignored for now).
	}

	public void focusGained(final FocusEvent e)
	{
		// Save last component to get focus.

		final Component temp_comp = e.getComponent();

		if (temp_comp == log_text || focus_comp == main_view){
			focus_comp = log_text;
		}
		if (temp_comp == gz390_cmd_line){
			focus_comp = temp_comp;
		}
	}

	/**
	 * Abort command if running and turn off cmd_mode.
	 * If no command is running and not in cmd_mode, then exit gz390.
	 */
	private void exit_command()
	{
		exit_main(0);
	}

	/**
	 * 
	 * @param path
	 * @param description
	 * @return
	 */
	protected static ImageIcon createImageIcon(final String path, final String description)
	{
		final java.net.URL imgURL = gz390.class.getResource(path);
		if (imgURL != null) {
			return new ImageIcon(imgURL, description);
		} else {
			System.err.println("Couldn't find file: " + path);
			return null;
		}
	}

	/**
	 * 1. If screen not ready, exit.
	 * 2. If delete key pending, do it now.
	 * 3. If cursor active, update it now.
	 * 4. If main window size has changed due to user stretching without
	 *    window event handler triggering update, do it now.
	 */
	private void check_main_view()
	{
		if (!tn_scn.isScreenReady()) {
			return;
		}
		if (tn_delete_request) {
			process_delete_key(); // RPI 845
		}
		if (tn_scn.isScreenReady() && tn_cursor)
		{
			tn_cursor_count--;
			if (tn_cursor_count <= 0) {
				tn_cursor_count = Constants.tn_cursor_wait_int;
				if (tn_cursor_scn_addr >= max_addr) {
					tn_cursor_scn_addr = 0;
				}
				final char save_cursor_char = scn_char[tn_cursor_scn_addr];
				if (!tn_cursor_alt) {
					tn_cursor_alt = true;
					if (save_cursor_char == tn_cursor_sym) {
						scn_char[tn_cursor_scn_addr] = tn_cursor_sym_alt;
					} else {
						scn_char[tn_cursor_scn_addr] = tn_cursor_sym;
					}
				} else {
					tn_cursor_alt = false;
				}
				tn_update_scn(tn_cursor_scn_addr);
				scn_char[tn_cursor_scn_addr] = save_cursor_char;
			}
		}
/*		if (   refresh_request
			|| tn_scn.main_width  != main_frame.getSize().getWidth()
			|| tn_scn.main_height != main_frame.getSize().getHeight())
		{
			tn_scn.main_width  = (int) main_frame.getSize().getWidth();
			tn_scn.main_height = (int) main_frame.getSize().getHeight();
		//	update_main_view();
			gz390_cmd_line.requestFocus();
			refresh_request = false;
		}
*/	}

	/**
	 * Shift input field left 1 char to end if not at null char.
	 */
	private synchronized void process_delete_key()
	{
		tn_delete_request = false;

		if (tn_cursor
			&&	tn_input_field()
			&&  scn_char[scn_addr] != tn_null) { // RPI 845
			tn_modify_field(); // RPI 861
			int save_scn_addr = scn_addr;
			tn_scn_addr_inc();
			while (scn_addr < max_addr
				&& tn_input_field()) { // RPI 845	&& scn_addr != save_scn_addr) {
				scn_char[scn_addr - 1] = scn_char[scn_addr];
				tn_update_scn(scn_addr - 1);
				tn_scn_addr_inc();
			}
			scn_char[scn_addr - 1] = scn_null; // RPI 856
			tn_update_scn(scn_addr - 1);
			scn_addr = save_scn_addr;
			tn_update_scn(scn_addr);
			tn_update_cursor();
			refresh_request = true;
		} else {
			sound_alarm_beep();
			status_line.setText(status_line_view + " Alarm - null or protected field");
		}
	}

	/**
	 * Update main_view and command line size following change in window size
	 */
	private void update_main_view()
	{
	//	if (refresh_wait) {
	//		refresh_request = true;
	//		return; // wait for next monitor interval
	//	}
	//
	//	refresh_wait = true;
		switch (guam_view) {
		case MCS:
			set_main_view_mcs();
			break;
		case SCREEN:
			set_main_view_screen();
			break;
		default:
			set_main_view_graph();
			break;
		}
		main_frame.setVisible(true);
	}

	/**
	 * Display MCS scrolling wto/wtor panel.
	 */
	private void set_view_mcs()
	{
		set_main_view(GuamViewTypes.MCS);
		tn_kb_lock = true; // RPI 308 text entry
		guam_tot_key = 0;  // RPI 308 clear queue
		status_line_view = "MCS View";
		status_line.setText(status_line_view);
		update_main_view();
		refresh_request = true;
	}

	/**
	 * Build screen view based on current screen and font size.
	 * Notes:
	 *   1.  Purge and redefine main_panel with new main_view
	 *   2.  Turn off focus subsystem to see tab key
	 *   3.  Display "Screen View on status line.
	 * @param rows
	 * @param cols
	 * @param color
	 */
	private void set_view_screen(final int rows, final int cols, final int color)
	{
		if (rows > 0) { // user request for new screen size
			init_tn3270_arrays(rows, cols);
		}
		if (tn_scn == null || rows != 0) { 
			init_tn3270_screen();
			tn_clear_screen();  // RPI 671
		}
		set_main_view(GuamViewTypes.SCREEN);
		guam_cur_row = 1; // RPI 308 reset for text output
		guam_tot_key = 0; // RPI 308 clear queue

		status_line_view = "Screen View";
		status_line.setText(status_line_view);

		update_main_view();
		refresh_request = true;
	}

	/**
	 * Display graph for QUAM GKS commands
	 * @param x
	 * @param y
	 * @param color
	 */
	private void set_view_graph(final int x, final int y, final int color)
	{
		if (graph_grid == null) { // init first time
			graph_grid = new JTextArea(
					  "\n  GUAM GUI grahics support not done yet."
					+ "\n  Click on View to see MCS and TN3270 views."
					+ "\n  Run DEMOGUI1 for simple WTO, WTOR, WAIT interface."
					+ "\n  Run DEMOGUI2 for WTO, WTOR,ECB MIP rate calculation."
					+ "\n  Run DEMOGUI3 for TPUT, TGET TN3270 EDIT mode interface."
					+ "\n  Run DEMOGUI4 for TPUT, TGET TN3270 data stream demo (using edit mode until done).");
			graph_grid.addMouseListener(this);
		}

		set_main_view(GuamViewTypes.GRAPH);

		status_line_view = "Graph View";
		status_line.setText(status_line_view);
		update_main_view();
		refresh_request = true;
	}

	/**
	 * Redefine main_view scrolling pane.
	 * @param view_type
	 */
	private void set_main_view(final GuamViewTypes view_type)
	{
		main_panel.removeAll();

		guam_view = view_type;
		view_menu_mcs.setSelected(   view_type == GuamViewTypes.MCS   );
		view_menu_tn3270.setSelected(view_type == GuamViewTypes.SCREEN);
		view_menu_graph.setSelected( view_type == GuamViewTypes.GRAPH );

		switch (view_type) {
		case MCS:
			main_view = new JScrollPane(log_text);
			main_view.setVerticalScrollBarPolicy(JScrollPane.VERTICAL_SCROLLBAR_ALWAYS);
			main_view.getVerticalScrollBar().addAdjustmentListener(new AdjustmentListener() {
				public void adjustmentValueChanged(final AdjustmentEvent e){
					if (main_view_changed) {
						main_view_changed = false;
						main_view.getVerticalScrollBar().setValue(main_view.getVerticalScrollBar().getMaximum());
					}
				}});
			break;
		case SCREEN:
			set_main_view_screen();
			break;
		case GRAPH:
		default:
			main_view = new JScrollPane(graph_grid);
			set_main_view_graph();
			break;
		}
		rebuild_main_panel();
	}

	/**
	 * Set GUAM dialog window to show MCS log
	 */
	private void set_main_view_mcs()
	{
		final int cxPanel = (int) main_frame.getSize().getWidth()  - 4 * Constants.numBorderWidth;
		final int cyPanel = (int) main_frame.getSize().getHeight() - 4 * Constants.numBorderWidth - menuBar.getHeight();

		main_panel.setSize(cxPanel,cyPanel);

		final int cxLogVw = cxPanel - main_view.getVerticalScrollBar().getWidth() - 3 * Constants.numBorderWidth;
		final int cyLogVw = cyPanel - 50 - gz390_cmd_line.getHeight() - status_line.getHeight();;
		main_view.setPreferredSize(new Dimension(cxLogVw,cyLogVw));

		set_main_view_textfields(cxLogVw);
	}

	/**
	 * Adjust font to show full TN3270 screen in current window space.
	 */
	private void set_main_view_screen()
	{
		final int cxPanel = (int) main_frame.getSize().getWidth()  - 4 * Constants.numBorderWidth;
		final int cyPanel = (int) main_frame.getSize().getHeight() - 4 * Constants.numBorderWidth - menuBar.getHeight();

		final int cxLogVw = cxPanel - 8 * Constants.numBorderWidth;
		final int cyLogVw = cyPanel - 50 - gz390_cmd_line.getHeight() - status_line.getHeight();

//		main_panel.setSize(cxPanel, cyPanel);
//		main_panel.setPreferredSize(new Dimension(cxPanel, cyPanel));
		
		tn_scn.resizeScreen(cxLogVw,cyLogVw);
		
		main_view = tn_scn.getScreenPanel();
		main_view.setSize(tn_scn.scn_width, tn_scn.scn_height);
		main_view.setPreferredSize(new Dimension(tn_scn.scn_width, tn_scn.scn_height));

		tn_repaint_screen();

		set_main_view_textfields(cxPanel-16);
	}

	/**
	 * Adjust command line and status line text field according to new width. 
	 * @param cxView
	 */
	private void set_main_view_textfields(final int cxView)
	{
		//final StringBuilder sb = new StringBuilder();
		//sb.append("set_main_view_textfields(").append(cxView).append(")");

		final int nOldCols  = gz390_cmd_line.getColumns();
		final int pxPerChar = gz390_cmd_line.getWidth() / nOldCols;
		// sb.append(" colsOld=").append(nOldCols).append(", pxPerChar=").append(pxPerChar);

		if (pxPerChar != 0) {
			final int cxLabel = cmd_label.getWidth();
			boolean lbl_visible;
			int nNewCols = ((cxView-cxLabel) / pxPerChar)-2;
			if (nNewCols < 60) {
				nNewCols = (cxView / pxPerChar)-2;
				if (nNewCols < 1) { nNewCols = 1; }
				lbl_visible = false;
			} else {
				lbl_visible = true;
			}
			if (cmd_label.isVisible() != lbl_visible) {
				cmd_label.setVisible(   lbl_visible);
				status_label.setVisible(lbl_visible);
			}
			if (nOldCols != nNewCols) {
				//sb.append(" colsNew=").append(nNewCols);
				gz390_cmd_line.setColumns(nNewCols);
				status_line.setColumns(  nNewCols);
			}
		}
		// System.out.println(sb.toString());
	}

	/**
	 * Set GUAM dialog window to show TN3270 screen using current
	 * main window size (max require scrolling to see entry screen)
	 */
	private void set_main_view_graph()
	{
		final int cxPanel = (int) main_frame.getSize().getWidth()  - 4 * Constants.numBorderWidth;
		final int cyPanel = (int) main_frame.getSize().getHeight() - 4 * Constants.numBorderWidth - menuBar.getHeight();

		main_panel.setSize(cxPanel,cyPanel);

		final int cxLogVw = cxPanel - 16 - 3 * Constants.numBorderWidth;
		final int cyLogVw = cyPanel - 50 - gz390_cmd_line.getHeight() - status_line.getHeight();;
		main_view.setPreferredSize(new Dimension(cxLogVw,cyLogVw));

		set_main_view_textfields(cxLogVw);
	}

	/**
	 * Rebuild main_panel with current main_view, gz390_cmd and status lines
	 * with or without labels to fix current main_panel size.
	 */
	private void rebuild_main_panel()
	{
		main_panel.removeAll();
		main_panel.add(main_view);

		// Add the optional labels and lines
		main_panel.add(cmd_label);
		// gz390_cmd_line.setFont(tn_scn.getScreenFont()); // RPI 686 
		// status_line.setFont(   tn_scn.getScreenFont()); // RPI 686
		// command_columns = tn_scn.scn_cols - 10;  // RPI 686
		gz390_cmd_line.setColumns(Constants.numDefaultCommandColumns);

		// disable focus subsystem to process tab key
		gz390_cmd_line.setFocusTraversalKeysEnabled(false); 
		main_panel.add(gz390_cmd_line);
		main_panel.add(status_label);
		main_panel.add(status_line);

		final int cxMain = main_frame.getWidth();
		final int cyMain = main_frame.getHeight();
		main_frame.setSize(cxMain, cyMain-1); // Ugly work-around to force system...
		main_frame.setSize(cxMain, cyMain+1); // ... to send a componentResized event

	}

	public void componentHidden(final ComponentEvent e)
	{/*
		final Component c = e.getComponent();
		final StringBuilder sb = new StringBuilder();
		sb.append("componentHidden event from ").append(c.getClass().getName());
		System.out.println(sb.toString());
	*/}

	public void componentMoved(final ComponentEvent e)
	{/*
		final Component c = e.getComponent();
		final StringBuilder sb = new StringBuilder();
		sb.append("componentMoved event from ")
		  .append(c.getClass().getName())
		  .append("; new location: ").append(c.getLocation().x).append(", ").append(c.getLocation().y);
		System.out.println(sb.toString());
	*/}

	public void componentResized(final ComponentEvent e)
	{/*
		final Component c = e.getComponent();
		final StringBuilder sb = new StringBuilder();
		sb.append("componentResized event from ")
		  .append(c.getClass().getName())
		  .append("; new size: ").append(c.getSize().width).append(", ").append(c.getSize().height);
		System.out.println(sb.toString());

	*/	check_main_view(); 
		update_main_view();
	}

	public void componentShown(final ComponentEvent e)
	{/*
		final Component c = e.getComponent();
		final StringBuilder sb = new StringBuilder();
		sb.append("componentShown event from ").append(c.getClass().getName());
		System.out.println(sb.toString());
	*/}

	/***********************************************
	 * Private screen, graph, keyboard, mouse, sound functions
	 ***********************************************
	 */

	/**
	 * Update screen from tput EBCDIC buffer using line at at time edit mode.
	 * @param buff
	 * @param lbuff
	 */
	private void tput_edit_buffer(byte[] buff, int lbuff)
	{
		final String text = get_ascii_string(buff,lbuff);
		int text_start = 0;
		int text_end   = 0;
		guam_cur_col = 1;
		while (text_start < text.length()){
			if (guam_cur_row == 1){
				scn_addr = 0;
			} else {
				scn_addr = (guam_cur_row-1)*max_cols;
			}
			text_end = text_start + max_cols;
			if (text_end > text.length()){
				text_end = text.length();
			}
			int index = text_start;
			int addr  = scn_addr;
			while (index < text_end){
				scn_char[addr] = text.charAt(index);
				tn_update_scn(addr);
				index++;
				addr++;
				if (addr >= max_addr){
					addr = 0;
				}
			}
			text_start = text_end;
			scn_next_line();
		}
		update_main_view();
	}

	/**
	 * Update screen from tn3270 data stream buffer.
	 */
	private void tn_tput_buffer()
	{
		tn_scn.stopScreenUpdates();

		tput_index = 0;
		switch (tpg_type) {
		case 0x01: // asis and noedit  RPI 219
			tn_get_tput_byte(); // first byte always write
			if (tput_buff_byte == tn_erase_write){
				tn_clear_screen();
			}
			tn_get_tput_byte(); // second byte always wcc
			tn_write_control_char();
			break;
		case 0x03: // fullscr
			tn_get_tput_byte(); // first byte esc or wcc
			if (tput_buff_byte == tn_esc){
				tn_get_tput_byte(); // wrt,wcc follows esc
				if (tput_buff_byte == tn_erase_write){
					tn_clear_screen();
				} else if (tput_buff_byte == tn_write_eau){ 
					tn_erase_all_unprotected(); // RPI 628
				}
				tn_get_tput_byte(); // wcc following esc,wrt
			}
			tn_write_control_char();
			break;
		}
		while (tput_index < tput_len) {
			tn_get_tput_byte();
			switch (tput_buff_byte) {
			case 0x05: // PT  program tab
				tn_tab();
				break;
			case 0x08: // GE  graphic escape
				tn_get_tput_byte();
				scn_char[scn_addr] = apl_char[tput_buff_byte]; 		  
				tn_update_scn(scn_addr);
				tn_next_field_addr();
				break;
			case 0x11: // SBA set buffer address
				scn_addr = tn_get_buff_addr();
				break;
			case 0x12: // EUA erase unprotected to address
				tn_eua();
				break;
			case 0x13: // IC insert cursor
				tn_cursor = true;
				tn_update_cursor();
				break;
			case 0x1d: // SF start new field
				tn_start_field();
				break;
			case 0x28: // SA  set extended attribute within field
				tn_eds_set_field_attribute();
				break;
			case 0x29: //SFE extended data stream field start
				tn_eds_start_field();
				break;
			case 0x3C: // RA repeat to address
				tn_ra();
				break;
			default: // write data in next input field postion
				if (scn_addr >= max_addr){
					scn_addr = scn_addr - max_addr; // RPI 927
				}
				if (scn_fld[scn_addr]){ // RPI 861
					tn_drop_field(scn_addr);
				}
				scn_attr[scn_addr]  = cur_fld_attr;
				scn_hl[scn_addr]    = cur_fld_hl;
				scn_color[scn_addr] = cur_fld_color;
				scn_char[scn_addr] = (char)tz390.ebcdic_to_ascii[tput_buff_byte];
				if ((tput_buff_byte & 0xff) == 255){
					scn_char[scn_addr] = ff_char;  // RPi 927
				}
				tn_update_scn(scn_addr);
				tn_next_field_addr();
			}
		}
		scn_addr = tn_cursor_scn_addr; // RPI 630 reset to last insert cursor
		tn_scn.startScreenUpdates(); 
	}

	/**
	 * Execute tn_write_eau as follows:
	 *   1.  erase all unprotected fields
	 *   2.  Reset modified data flags
	 *   2.  position cursor to first field
	 *   3.  unlock keyboard
	 */
	private void tn_erase_all_unprotected()
	{
		int first_input_sba = -1;
		int index = 0;
		while (index < fld_mdt_tot){
			if ((scn_char[fld_mdt_addr[index]] & tn_protect_mask) == 0) {
				scn_addr = fld_mdt_addr[index]+1;
				if (first_input_sba == -1) {
					first_input_sba = scn_addr;
				}
				tn_erase_to_end();
			}
			index++;
		}
		tn_reset_mdt();
		if (first_input_sba == -1) {
			first_input_sba = 0; 
		}
		scn_addr = first_input_sba;
		tn_update_cursor();
		tn_kb_lock = false; // allows kb input
		status_line.setText(status_line_view + " Ready for input");
		refresh_request = true;
	}

	/**
	 * Erase to end of current input field
	 */
	private void tn_erase_to_end() // RPI 628
	{
		int index = scn_addr;
		while (!scn_fld[index]){  // RPI 861
			scn_char[index] = scn_null;
			tn_update_scn(index);
			index++;
			if (index > max_addr){
				index = 0;
			}
			if (index == scn_addr){
				return;
			}
		}
	}

	/**
	 * Get next tput buffer byte in tput_buff_byte else abort.
	 */
	private void tn_get_tput_byte()
	{
		if (tput_index < tput_len) {
			tput_buff_byte = tput_byte[tput_index] & 0xff;
			tput_index++;
		} else {
			abort_error(105, "tput read past end of buffer.");
		}
	}

	/**
	 * Increase scn_addr and wrap if at end of screen.
	 */
	private void tn_next_field_addr()
	{
		tn_scn_addr_inc();
	}

	/**
	 * Incr scn_addr to next input field addr.
	 */
	private void tn_next_input_addr()
	{
		tn_scn_addr_inc();
		if (scn_fld[scn_addr]) {
			tn_scn_addr_dec(); // RPI 861
			tn_next_input_field();
		}
	}

	/**
	 * Next screen position with wrap.
	 */
	private void tn_scn_addr_inc()
	{
		scn_addr++;
		if (scn_addr > max_addr) {
			scn_addr = 0;
		}
	}

	/**
	 * Previous screen position with wrap.
	 */
	private void tn_scn_addr_dec()
	{
		scn_addr--;
		if (scn_addr < 0) {
			scn_addr = max_addr-1;
		}
	}

	/**
	 * Store nulls in unprotected fields to ending address.
	 */
	private void tn_eua()
	{
		final int sba_end = tn_get_buff_addr();
		while (scn_addr != sba_end) {
			if (tn_input_field()) {  // RPI 861 
				// erase and reset mdt in unprotected fields
				scn_char[scn_addr] = scn_null;
				tn_update_scn(scn_addr);
			}
			tn_scn_addr_inc();
		}	
	}

	/**
	 * Repeat character to sba address.
	 */
	private void tn_ra()
	{
		final int sba_end = tn_get_buff_addr();
		if (sba_end >= max_addr) {
			abort_error(103, "tn3270 ra addr error.");
			return;
		}
		final byte ra_byte = tput_byte[tput_index];
		tput_index++;
		int sba = scn_addr;
		boolean ra_done = false;
		while (!ra_done) {
			if (scn_fld[sba]) { // RPI 861
				tn_drop_field(sba);
			}
			scn_attr[sba]  = cur_fld_attr;  // RPI 1091
			scn_hl[sba]    = cur_fld_hl;    // RPI 1091
			scn_color[sba] = cur_fld_color; // RPI 1091
			scn_char[sba] = (char)tz390.ebcdic_to_ascii[ra_byte & 0xff]; // RPI 628
			if ((ra_byte & 0xff) == 255){
				scn_char[sba] = ff_char;  // RPi 927
			}
			tn_update_scn(sba);
			sba++;
			if (sba >= max_addr) {
				sba = 0;
			}
			if (sba == sba_end) ra_done = true;
			scn_addr = sba; // RPI 1091
		}
	}

	/**
	 * Tab to next input field from current field.
	 */
	private void tn_tab()
	{
		tn_next_input_field();
		tn_update_cursor();
	}

	/*
	 * Find next input field starting at scn_addr with wrap and set scn_addr and cursor if on.
	 */
	private void tn_next_input_field()
	{
		int sba_first = scn_addr;
		int sba_next = max_addr;
		int index = 0;
		int save_cur_fld_addr = cur_fld_addr;;
		while (index < fld_mdt_tot){
			cur_fld_addr = fld_mdt_addr[index]; 
			if (   cur_fld_addr > scn_addr
				&& cur_fld_addr < sba_next
				&& (scn_attr[cur_fld_addr] & tn_protect_mask) == 0  // RPI 1094 skip prot fields
				) {
				sba_next = cur_fld_addr; 
			} else if (cur_fld_addr < sba_first
				&& (scn_attr[cur_fld_addr] & tn_protect_mask) == 0  // RPI 1094 skip prot fields
				) {
				sba_first = cur_fld_addr;
			}
			index++;
		}
		if (sba_next != max_addr) {
			scn_addr = sba_next+1;
			if (scn_addr == max_addr) {
				scn_addr = 0;
			}
			tn_update_cursor();
		} else if (sba_first != scn_addr) {
			scn_addr = sba_first + 1;
			if (scn_addr == max_addr) {
				scn_addr = 0;
			}
			tn_update_cursor();
		} else {
			cur_fld_addr = save_cur_fld_addr; // RPI 1094 store if no input found
		}
	}

	/**
	 * Return true if scn_addr is in unprotected input field and set cur_fld_addr
	 * Note:
	 *  1. True also returned if no fields and fld_addr set to -1 indicating none
	 * @return
	 */
	private boolean tn_input_field()
	{
		cur_fld_addr = 0; 
		if (fld_tot == 0) {
			return true;
		}
		if (fld_mdt_tot == 0 || scn_fld[scn_addr]) {
			return false;
		}
		cur_fld_addr = fld_addr[0]; // RPI 861
		int index = 1;
		while (index < fld_tot && fld_addr[index] < scn_addr) {
			cur_fld_addr = fld_addr[index];
			index++;
		}
		if ((scn_attr[cur_fld_addr] & tn_protect_mask) == 0) {
			return true;
		} else {
			return false;
		}
	}

	/**
	 * Update modified field attribute bit at fld_addr if any input fields.
	 * Note:
	 *   1.  fld_addr must be set by tn_input
	 */
	private void tn_modify_field()
	{
		if (fld_mdt_tot > 0) {
			scn_attr[cur_fld_addr] = scn_attr[cur_fld_addr] | tn_mdt_mask;
		} else {
			scn_attr[scn_addr] = scn_attr[scn_addr] | tn_mdt_mask; // RPI 671
		}
	}

	/**
	 * Update cursor for IC command or change in focus due to screen input or tab.
	 * 1.  Update scn_addr to next input field position or turn off cursor if none found.
	 * 2.  Turn on blinking cursor at position found
	 */
	private void tn_update_cursor()
	{
		if (tz390.timeout) {
			abort_error(144, "GUAM abort due to timeout.");
			return;
		}
		if (!tn_cursor) {
			return;
		}
		if (scn_addr != tn_cursor_scn_addr) { // put char back at prev cursor position
			tn_cursor_alt = false; // RPI 630
			tn_update_scn(tn_cursor_scn_addr);
		}
		if (scn_addr >= max_addr){
			tn_cursor_scn_addr = 0; // RPI 861
		}
		tn_cursor_scn_addr = scn_addr;
		refresh_request = true;
	}

	/**
	 * Update screen character at position sba with field attributes and extended attributes.
	 * @param sba
	 */
	private synchronized void tn_update_scn(final int sba)
	{
		if (sba >= max_addr) {
			return;
		}

		final char save_char = scn_char[sba]; // RPI 638
		if (save_char == (char)0x00 || (scn_attr[sba] & fld_attr_nd) == fld_attr_nd) { // RPI 850
			scn_char[sba] = ' '; // RPI 638
		}
		tn_scn.setScreenLayout( new TextLayout("" + scn_char[sba],tn_scn.getScreenFont(), tn_scn.scn_context) ); // RPI 630 scn_addr > sba
		final int row = sba / max_cols;
		final int col = sba - row * max_cols;
		final int x   = col * tn_scn.scn_char_width;
		final int y   = row * tn_scn.scn_char_height + tn_scn.scn_char_base;
		if (scn_color[sba] != 0) {						// RPI 630 scn_addr > sba
			int tn_color_index = scn_color[sba] & 0xf;	// RPI 630 scn_addr > sba
			if (tn_color_index > tn_color.length) {
				tn_color_index = 0;
			}
			tx_color = tn_color[tn_color_index];
		} else {
			tx_color = tn_scn.scn_text_color;
		}
		if (scn_hl[sba] != 0 || (scn_attr[sba] & fld_attr_hl) != 0) {  // RPI 630 scn_addr > sba
			tn_scn.scn_grid.setColor(tx_color.brighter());
		} else {
			tn_scn.scn_grid.setColor(tx_color);
		}

		tn_scn.scn_grid.clearRect(x-1, y-tn_scn.scn_char_base, tn_scn.scn_char_width+1, tn_scn.scn_char_height);
		tn_scn.scn_grid.drawChars(scn_char,sba,1, x, y);  // RPI 630
		
		scn_char[sba] = save_char; // RPI 628
		tn_scn.allowRepaint(true);
	}

	/**
	 * fill tget_byte buffer with the following:
	 *   1, action key  = enter, PF, PA, or clear key)
	 *   2, sba of cursor (if enter or PF only) RPI 856
	 *   3. sba code x'11', sba addr, modified data bytes for each mdt field else
	 *   4. Modified data bytes for unformatted screen with no mdt fields 
	 */
	private void tn_get_screen_input()
	{
		tget_byte[0] = (byte) tn_aid;
		if ( tget_len == 1 
			|| tn_aid == tn_clear_code // RPI 856
			|| tn_aid == tn_pa1_code   // RPI 856
			|| tn_aid == tn_pa2_code   // RPI 856
			|| tn_aid == tn_pa3_code   // RPI 856
			) {
			tget_len = 1; // RPI 856
			return;       // RPI 592
		}
		tget_byte[1] = (byte)sba_to_ebc[scn_addr >> 6];
		tget_byte[2] = (byte)sba_to_ebc[scn_addr & 0x3f];
		if (fld_mdt_tot == 0){
			tn_unformatted_input();
		} else {
			tn_formatted_input();
		}
	}

	/**
	 * Return all modified bytes on screen when no field formatting.  RPI 671
	 */
	private void tn_unformatted_input()
	{
		tget_index = 3;
		int sba = 0;
		while (sba < max_addr) {
			if ((scn_attr[sba] & tn_mdt_mask) == tn_mdt_mask) {
				if (tget_index < tget_len) {
					if (tz390.opt_ascii) {
						tget_byte[tget_index] = (byte)scn_char[sba];
					} else {
						tget_byte[tget_index] = tz390.ascii_to_ebcdic[scn_char[sba] & 0xff];
					}
					tget_index++;
				} else {
					abort_error(113,"tget input buffer overrun");
					return;
				}
			}
			sba++;
		}
		if (tget_index < tget_len){
			tget_len = tget_index; // set actual length
		}
	}

	/**
	 * Return modified input fields preceeded with sba code x'11' and sba addr
	 */
	private void tn_formatted_input()
	{
		tget_index = 3;
		int index = 0;
		while (index < fld_mdt_tot){
			cur_fld_addr = fld_mdt_addr[index];
			if ((scn_attr[cur_fld_addr] & tn_mdt_mask) == tn_mdt_mask) {
				int input_sba = cur_fld_addr+1; // RPI 940
				if  (input_sba >= max_addr) {
					input_sba = 0;
				}
				if (tget_index + 3 <= tget_len) {
					tget_byte[tget_index] = tn_sba_cmd;
					tget_byte[tget_index+1] = (byte)sba_to_ebc[input_sba >> 6];    // RPI 940
					tget_byte[tget_index+2] = (byte)sba_to_ebc[input_sba & 0x3f]; // RPI 940
					tget_index = tget_index +3;
				} else {
					abort_error(104,"tget input buffer overrun");
					return;
				}
				int sba = input_sba;
				if (sba == max_addr) {
					sba = 0;
				}
				while (!scn_fld[sba]) {   // RPI 861
					if (scn_char[sba] != tn_null) {  // RPI 861
						if (tget_index < tget_len ) {
							if (tz390.opt_ascii) {
								tget_byte[tget_index] = (byte)scn_char[sba];
							} else {
								tget_byte[tget_index] = tz390.ascii_to_ebcdic[scn_char[sba] & 0xff];
							}
							tget_index++;
						} else {
							abort_error(113, "tget input buffer overrun");
							return;
						}
					}
					sba++;
					if (sba == max_addr) {
						sba = 0;
					}
				}
			}
			index++;
		}
		if (tget_index < tget_len) {
			tget_len = tget_index; // set actual length
		}
	}

	/**
	 * Execute wcc from next byte in buffer.
	 */
	private void tn_write_control_char()
	{
	/*
	 * WCC 0xC3 = clear screen, reset KB and MDT's
	 * bit 0   - even bit count 
	 * bit 1   - reset screen
	 * bit 2-3 - printout format
	 * bit 4   - start print
	 * bit 5   - sound alarm
	 * bit 6   - keyboard restore
	 * bit 7   - reset modify data tags (MDT)
	 */
		if ((tput_buff_byte & 0x40) != 0) { // reset screen
			// RPI 222 removed tn_clear_screen()
		}
		if ((tput_buff_byte & 0x04) != 0) { // sound alarm	
			sound_alarm_beep();
			status_line.setText(status_line_view + " Alarm message");
		}
		if ((tput_buff_byte & 0x02) != 0) { // reset keyboard
			tn_kb_lock = false; // allows kb input
		} else {
			tn_kb_lock = true;
			status_line.setText(status_line_view + " Display only with keyboard locked");
		}
		if ((tput_buff_byte & tn_mdt_mask) == tn_mdt_mask){  // reset mult data tags
			tn_reset_mdt();
		}
	}

	/**
	 * Sound alarm by sending ASCII bell x'07' to System.out.
	 */
	private void sound_alarm_beep()
	{
		/*
		 * Notes:
		 *   1.  Tried Toolkit.getToolkitDefault().beep(); and it didn't work
		 *   2.  To get bell to work, I had to go to  Windows XP Control Panel, select Sounds,
		 *       and assign the Windows default for "Alert" sound to "Windows XP error" sound (it was none)
		 *   3.  Note alarm only sounds if running ez390 from command line, and not when running from z390.
		 */
		System.out.println(tz390.alarm_bell); // RPI 220 use ASCII bell x'07'
	}

	/**
	 * Clear screen and reset fields.
	 */
	private synchronized void tn_clear_screen()
	{
		Arrays.fill(scn_char,0,max_addr,scn_null); // RPI 856
		Arrays.fill(scn_fld, 0,max_addr,false);    // RPI 861
		Arrays.fill(scn_attr,0,max_addr,0);
		// JBA - Why not the other arrays???
		// fld_addr + scn_hl + scn_color
		fld_tot = 0;
		fld_mdt_tot = 0;
		scn_addr = 0;
		tn_cursor_scn_addr = 0; 
		tn_cursor = true;
		tn_cursor_alt = false;
		tn_scn.scn_grid.clearRect(0,0,tn_scn.scn_width,tn_scn.scn_height);
	}

	/**
	 * Reset all mdt bits so only changes will be input.
	 */
	private void tn_reset_mdt()
	{
		if (fld_mdt_tot > 0) {
			int index = 0;
			while (index < fld_mdt_tot) {
				scn_attr[fld_mdt_addr[index]] = scn_attr[fld_mdt_addr[index]] & tn_mdt_off;
				index++;
			}
		} else {
			Arrays.fill(scn_attr,0,max_addr,0);
		}
	}

	/**
	 * Return buffer address from next 2 bytes.
	 * Notes:
	 *   1.  Wrap screen if sba > max_addr
	 * @return
	 */
	private int tn_get_buff_addr()
	{
		int sba = -1;
		if (tput_index < tput_len -2) {
			final int high_bits = ebc_to_sba[tput_byte[tput_index  ] & 0xff];
			final int low_bits  = ebc_to_sba[tput_byte[tput_index+1] & 0xff];
			tput_index = tput_index+2;
			sba = (high_bits << 6) | low_bits;
			if (sba >= max_addr) {
				return sba - (sba/max_addr)*max_addr;
			}
		} else {
			abort_error(106, "tn3270 command buffer overrun.");
			return -1;
		}
		return sba;
	}

	/**
	 * Start field in tn3270 buffer at current sba.
	 */
	private void tn_start_field()
	{
		/* 
		 *   1.  Set current tn_field_attr.
		 *   2.  Set 1 protected blank at start of field.
		 *   3.  Save unique unprotected fields in ascending order until next wcc
		 *       clears them all.
		 * 
		 * field attribute byte
		 * bit  0-1 - set to form EBCDIC/ASCII graphic symbol rpi 572
		 * bit  2   - protected output
		 * bit  3   - numeric (protected & numeric = skip)
		 * bit  4-5 - display format
		 *              00 - normal intensity, no light pen
		 *              01 - normal intensity, light pen
		 *              10 - high intensity, no light pen
		 *              11 - field not displayed
		 * bit  6   - reserved
		 * bit  7   - modified data tag
		 */
		cur_fld_attr  = tput_byte[tput_index] & 0x3f; // RPI 572
		cur_fld_hl    = 0;
		cur_fld_color = 0;
		scn_attr[scn_addr] = cur_fld_attr;
		tput_index++;
		tn_add_field_addr(); 
		if (   (cur_fld_attr & tn_protect_mask) == 0
			|| (cur_fld_attr & tn_mdt_mask) == 1) { // RPI 1061 add PA-MDT fields
			tn_add_input_field_addr();
		}
		scn_char[scn_addr] = scn_null; // RPI 628
		tn_update_scn(scn_addr);
		tn_next_field_addr();
	}

	/**
	 * 1. add scn_addr to fld_addr if new
	 * 2. sort after new add.
	 * 3. set scn_fld_addr up to next
	 */
	private void tn_add_field_addr()
	{
		scn_fld[scn_addr] = true; // RPI 861
		int index = 0;
		while (index < fld_tot) {
			if (scn_addr == fld_addr[index]) {
				return;
			}
			index++;
		}
		fld_addr[fld_tot] = scn_addr;
		fld_tot++;
		if (fld_tot > 1) {
			// sort all field addresses for use in search
			Arrays.sort(fld_addr,0,fld_tot);
		}
	}

	/**
	 * Add scn_addr to fld_mdt_addr array if new and sort after new add.
	 */
	private void tn_add_input_field_addr()
	{
		int index = 0;
		while (index < fld_mdt_tot) {
			if (scn_addr == fld_mdt_addr[index]) {
				return;
			}
			index++;
		}
		fld_mdt_addr[fld_mdt_tot] = scn_addr;
		fld_mdt_tot++;
		if (fld_mdt_tot > 1) {
			// sort input field addresses for use in search
			Arrays.sort(fld_mdt_addr,0,fld_mdt_tot);
		}
	}

	/**
	 * Remove field definition at sba.
	 * @param sba
	 */
	private void tn_drop_field(final int sba)
	{
		int index = 0;
		while (index < fld_tot) {
			if (fld_addr[index] == sba) {
				index++;
				while (index < fld_tot) {
					fld_addr[index-1] = fld_addr[index];
					index++;
				}
				fld_tot--;
				if ((scn_attr[sba] & tn_protect_mask) == 0) {
					tn_drop_input_field(sba);
				}
				scn_fld[sba] = false; // 861
				return;
			}
			index++;
		}
	}

	/**
	 * Remove input field.
	 * @param sba
	 */
	private void tn_drop_input_field(final int sba)
	{
		int index = 0;
		while (index < fld_mdt_tot){
			if (fld_mdt_addr[index] == sba) {
				index++;
				while (index < fld_mdt_tot) {
					fld_mdt_addr[index-1] = fld_mdt_addr[index];
					index++;
				}
				fld_mdt_tot--;
				return;
			}
			index++;
		}
	}

	/**
	 * Extended data stream start field first byte is count of attribute pairs type attribute.
	 */
	private void tn_eds_start_field()
	{
		/* 
		 * Extended data stream start field first byte is count of attribute pairs type attribute
		 *   C0   basic field attribute
		 *   41   extended highlighting
		 *   42   color
		 *   
		 *   1.  Set current tn_field_attr
		 *                   tn_field_highlight
		 *                   tn_color.
		 *   2.  Set 1 protected blank at start of field.
		 *   3.  Save unique unprotected fields in ascending order until next wcc clears them all.
		 * 
		 * basic field attribute byte following x'C0'
		 * bit  0-1 - set based on remaining bits
		 * bit  2   - protected output
		 * bit  3   - numeric (protected & numeric = skip)
		 * bit  4-5 - display format
		 *              00 - normal intensity, no light pen
		 *              01 - normal intensity, light pen
		 *              10 - high intensity, no light pen
		 *              11 - field not displayed
		 * bit  6   - reserved
		 * bit  7   - modified data tag
		 * 
		 * highlight attribute byte following x'41'
		 * 00 - normal
		 * F1 - blink
		 * F2 - reverse video
		 * F4 - underscore
		 * 
		 * color attribute byte following x'42' color attr byte
		 * 00 Default		F4 Green
	     * F1 Blue			F5 Turquoise
	     * F2 Red			F6 Yellow
	     * F3 Pink			F7 White
		 */
		cur_fld_hl    = 0;
		cur_fld_color = 0;
		int count = tput_byte[tput_index] & 0xff;
		if (count < 1 || count > 3 || tput_index + 2 * count > max_buff) {
			abort_error(111, "Invalid tn3270 sfe count " + count + ".");
			return;
		}
		tput_index++;
		while (count > 0) {
			tn_eds_set_field_attribute();
			count--;
		}
		tn_update_scn(scn_addr);
	}

	/**
	 * Set single field attribute from next 2 bytes see sa and sfe commands.
	 */
	private void tn_eds_set_field_attribute()
	{
		int iType = tput_byte[tput_index] & 0xff;
		tput_index++;
		switch (iType) {
		case 0xc0: // basic type attribute
			tn_start_field();
			break;
		case 0x41: // highlighting
			cur_fld_hl = tput_byte[tput_index] & 0xff;
			scn_hl[scn_addr] = cur_fld_hl; // RPI 1151 
			tput_index++;
			break;
		case 0x42:  // color
			cur_fld_color = tput_byte[tput_index] & 0xff;
			scn_color[scn_addr] = cur_fld_color; // RPI 1151 
			tput_index++;
			break;
		default:
			abort_error(112, "Invalid tn3270 sfe type code " + tz390.get_hex(iType,2));
			return;
		}
	}

	/**
	 * 1. Read keyboard text into tget_buff until return or field full and translate to EBCDIC.
	 * 2. Echo characters to screen at row,col.
	 */
	private void keyboard_readline()
	{
		int index = 0;
		while (index < tget_len) {
			final int key     = guam_keyboard_read((tpg_flags & tpg_wait_mask) == tpg_wait);
			final int keychar = key & 0xffff;
			if (keychar == KeyEvent.VK_ENTER) {
				tget_len = index;
				return;
			} else
			if (keychar == KeyEvent.VK_BACK_SPACE) {
				if (index > 0) {
					index--;
					if (guam_cur_col > 1) {
						guam_cur_col--;
						scn_write_char(scn_null); // RPI 856
						guam_cur_col--;
					}
				}
			} else
			if (index < tget_len) {
				scn_write_char((char)keychar);
				if (tz390.opt_ascii) {
					tget_byte[index] = (byte)keychar;
				} else {
					tget_byte[index] = tz390.ascii_to_ebcdic[keychar];
				}
				index++;
			} else {
				return;
			}
		}
	}

	/**
	 * Write 1 character at current screen location.
	 * @param key
	 */
	private void scn_write_char(final char key)
	{
		scn_addr = (guam_cur_row-1)*max_cols + (guam_cur_col-1);
		scn_char[scn_addr] = key;
		tn_update_scn(scn_addr);
		guam_cur_col++;
		if (guam_cur_col > max_cols) {
			scn_next_line();
		}
	}

	/**
	 * Position to next screen line with status line prompt before wrapping screen to position back to line 1
	 */
	private void scn_next_line()
	{
		guam_cur_col = 1;
		guam_cur_row++;
		if (guam_cur_row > max_rows){
			status_line.setText(status_line_view + " Press enter for next screen.");
			update_main_view();
			guam_keyboard_read((tpg_flags & tpg_wait_mask) == tpg_wait);
			tn_clear_screen();
			status_line.setText(status_line_view);
			guam_cur_row = 1;
		}
	}

	/**
	 * Return string of ASCII characters from tget_buff up to lbuff long.
	 * @param text_byte
	 * @param lbuff
	 * @return
	 */
	private String get_ascii_string(final byte[] text_byte, final int lbuff)
	{
		final StringBuilder sb = new StringBuilder();
		int index = 0;
		while (index < lbuff) {
			final byte data_byte = text_byte[index];
			char data_char;
			if (tz390.opt_ascii) {
				data_char = (char) data_byte;
			} else {
				data_char = (char) tz390.ebcdic_to_ascii[data_byte & 0xff]; //RPI42
			}
			if ((data_byte & 0xff) == 255) {
				data_char = ff_char;  // RPi 927
			}
			sb.append(data_char);
			index++;
		}
		return sb.toString();
	}

	/***********************************************
	 * Public GUAM GUI application interfaces for
	 *   WTO/WTOR   - MCS view
	 *   TPUT/TGET  - Screen view
	 *   GUAM MACRO - graphic view and window commands
	 ***********************************************/

	/**
	 * Return quam_cmd_line and reset.
	 * @param ecb_addr
	 * @return
	 */
	public boolean wtor_request_reply(final int ecb_addr)
	{
		if (!wtor_running) {
			abort_error(108, "wtor already running.");
			return false;
		}

		gz390_cmd_line.requestFocus();
		wtor_ecb_addr = ecb_addr;
		wtor_reply_string = null;
		wtor_running = true; // turn on monitor update of wtor_reply_string
		return true;
	}

	/**
	 * Return wtor reply string if ready else null.
	 * @param ecb_addr
	 * @return
	 */
	public String get_wtor_reply_string(final int ecb_addr)
	{
		if (!wtor_running) {
			if (   wtor_ecb_addr != -1
				&& wtor_ecb_addr == ecb_addr
				&& wtor_reply_string != null) {
				wtor_ecb_addr = -1;
				return wtor_reply_string;
			} else {
				log_error(23, "wtor reply error");
			}
		}
		return null;
	}

	/**
	 * Startup gz390 GUAM GUI window with title in default MCS mode for wto/wtor.
	 * @param title
	 * @param shared_tz390
	 */
	public void start_guam(final String title, final tz390 shared_tz390)
	{
		tz390 = shared_tz390;
		main_title = "GZ390 " + tz390.version;
		final String[] dummy_args = new String[0];
		set_main_mode(dummy_args);
		init_gz390(dummy_args);
		guam_window_title(title);
		refresh_request = true;
	}

	/**
	 * Set gz390 GUAM GUI window title.
	 * Notes:
	 *   1.  Called from ez390 with ez390_pgm at initialization time if option GUAM.
	 * @param title
	 */
	public void guam_window_title(final String title)
	{
		main_title = title;
	}

	/**
	 * Write message to log file and to console if console mode or console option on.
	 * Append any output from CMD still in buffers to front of message with \n.
	 * @param msg
	 */
	public synchronized void guam_put_log(final String msg)
	{
		io_count++;
		log_text.append(msg + "\n");
		main_view_changed = true;
	}

	/**
	 * Set location of main window x, y.
	 * @param x
	 * @param y
	 */
	public void guam_window_loc(int x,int y)
	{
		if (x < 0) {
			x = 0;
		} else
		if (x + tn_scn.main_width > tz390.max_main_width) {
			if  (x + tz390.min_main_width > tz390.max_main_width) {
				x = tz390.max_main_width - tz390.min_main_width;
				tn_scn.main_width = tz390.min_main_width;
			} else {
				tn_scn.main_width = tz390.max_main_width - x;
			}
		}
		if  (y < 0) {
			y = 0;
		} else
		if (y + tn_scn.main_height > tz390.max_main_height) {
			if  (y + tz390.min_main_height > tz390.max_main_height) {
				y = tz390.max_main_height - tz390.min_main_height;
				tn_scn.main_height = tz390.min_main_height;
			} else {
				tn_scn.main_height = tz390.max_main_height - y;
			}
		}
		main_loc_x = x;
		main_loc_y = y;
		main_frame.setLocation(main_loc_x, main_loc_y);
		main_frame.setSize(tn_scn.main_width, tn_scn.main_height);
		refresh_request = true;
	}

	/**
	 * Resize main window.
	 * @param x
	 * @param y
	 */
	public void guam_window_size(int x,int y)
	{
		main_loc_x = (int) main_frame.getLocation().getX();
		main_loc_y = (int) main_frame.getLocation().getY();
		if  (x < tz390.min_main_width){
			x = tz390.min_main_width;
		} else {
			if (x > tz390.max_main_width - main_loc_x) {
				x = tz390.max_main_width - main_loc_x;
			}
		}
		if  (y < tz390.min_main_height){
			y = tz390.min_main_height;
		} else {
			if (y > tz390.max_main_height - main_loc_y){
				y = tz390.max_main_height - main_loc_y;
			}
		}
		tn_scn.main_width  = x;
		tn_scn.main_height = y;
		main_frame.setSize(tn_scn.main_width,tn_scn.main_height);
		refresh_request = true;
	}

	/**
	 * Set font size.
	 * @param font
	 */
	public void guam_window_font(final int font)
	{
		font_command(font);
	}

	/**
	 * set window view  
	 *   1 = MCS console view
	 *   2 = TN3270 screen view
	 *   3 = graphics view
	 * @param view
	 * @param x
	 * @param y
	 * @param color
	 */
	public void guam_window_view(final GuamViewTypes view, final int x, final int y, final int color)
	{
		switch (view) {
		case MCS: // MCS console view
			set_view_mcs();
			break;
		case SCREEN: // TN3270 screen view
			set_view_screen(x,y,color);
			break;
		case GRAPH: // graphics view
		default:
			set_view_graph(x,y,color);
			break;
		}
	}

	/**
	 * Return current window view
	 *   1 = MCS console view
	 *   2 = TN3270 screen view
	 *   3 = graphics view
	 * @return
	 */
	public GuamViewTypes guam_window_getview()
	{
		return guam_view;
	}

	/**
	 * Write text at row,col from buff for lbuff using color.
	 * @param row
	 * @param col
	 * @param buff
	 * @param lbuff
	 * @param color
	 */
	public void guam_screen_write(final int row, final int col, final ByteBuffer buff, final int lbuff, final int color)
	{
		// TODO
	}

	/**
	 * Return ByteBuffer of length lbuff from TN3270 screen.
	 * If wait = 1 wait for input else return r15=4 if none ready.
	 * @param lbuff
	 * @param wait
	 * @return
	 */
	public ByteBuffer guam_screen_read(final int lbuff, final boolean wait)
	{
		final byte[] temp_byte = new byte[lbuff];
		final ByteBuffer temp_buff = ByteBuffer.wrap(temp_byte,0,lbuff);
		while (guam_tot_key == 0 && wait) {
			tz390.sleep_now(monitor_wait);
		}
		return temp_buff;
	}

	/**
	 * Define field for input from screen.
	 * @param row
	 * @param col
	 * @param lfield
	 */
	public void guam_screen_field(int row, int col, int lfield)
	{
		// TODO
	}

	/**
	 * Set cursor type at row, col.
	 * @param row
	 * @param col
	 * @param type
	 */
	public void guam_screen_cursor(final int row, final int col, final int type)
	{
		// TODO
	}

	/**
	 * Set screen background and text colors.
	 * @param bg_color
	 * @param text_color
	 */
	public void guam_screen_color(final int bg_color, final int tx_color)
	{
		tn_scn.scn_back_color = new Color(bg_color);
		tn_scn.scn_grid.setBackground(tn_scn.scn_back_color);

		tn_scn.scn_text_color = new Color(tx_color);
		tn_scn.scn_grid.setColor(     tn_scn.scn_text_color);
	}

	/**
	 * Draw point at x,y.
	 * @param x
	 * @param y
	 * @param color
	 */
	public void guam_graph_point(final int x, final int y, final int color)
	{
		// TODO
	}

	/**
	 * Draw line from (x1,y1) to (x2,y2).
	 * @param x1
	 * @param y1
	 * @param x2
	 * @param y2
	 * @param color
	 */
	public void guam_graph_line(final int x1, final int y1, final int x2, final int y2, final int color)
	{
		// TODO
	}

	/**
	 * Fill area at x1,y1 to x2,y2.
	 * @param x1
	 * @param y1
	 * @param x2
	 * @param y2
	 * @param color
	 */
	public void guam_graph_fill(final int x1, final int y1, final int x2, final int y2, final int color)
	{
		// TODO
	}

	/**
	 * Draw characters at x,y.
	 * @param x1
	 * @param y1
	 * @param text
	 * @param color
	 */
	public void guam_graph_text(final int x1, final int y1, final String text, final int color)
	{
		// TODO
	}

	/**
	 * Read next keyboard keycode and keychar and return as int (code high 16, char low 16).
	 * If none ready and no wait return -1 else wait for next input key
	 * @param wait
	 * @return
	 */
	public int guam_keyboard_read(final boolean wait)
	{
		while (guam_tot_key == 0 && wait) {
			try {
				Thread.sleep(monitor_wait);
			} catch (final Exception e) {
				abort_error(110, "GUAM GUI Keyboard read wait exception -" + e.toString());
				return -1;
			}
		}
		if (guam_tot_key > 0) {
			final int key = guam_key_code_char[guam_next_key];
			guam_next_key++;
			if (guam_next_key >= guam_tot_key) {
				guam_tot_key = 0;
				guam_next_key = 0;
			}
			return key;
		} else {
			return -1;
		}
	}

	/**
	 * Return int[4] with x,y,left,right.
	 * @return
	 */
	public int[] guam_mouse_read()
	{
		final int[] mouse = new int[4];
		return mouse;
	}

	/**
	 * Play wav_file.
	 * @param wav_file
	 */
	public void guam_sound_play(final String wav_file)
	{}

	/**
	 * 1.  Return last tn3270 data stream input if available following keyboard enter
	 *     or PF key.  If option edit, remove control characters and translate to
	 *     EBCDIC unless ASCII mode.
	 * 2.  If none, and option wait then wait else return R15=4 indicating not avail.
	 * 3.  Set tget_len to actual bytes returns if less than requested length.
	 * 4.  Set R1=length of data buffer returned and R15=0 or 4 if none and NOWAIT
	 */
	public void guam_tget()
	{
		tpg_rc = 0; // assume RC = 0
		if (guam_view != GuamViewTypes.SCREEN) {
			set_view_screen(0,0,0);
		}
		if ((tpg_flags & tpg_type_mask) == tpg_type_asis) {
			if (!tn_attn) {
				tn_kb_lock = false;
				tn_scn_lock = false;
				status_line.setText(status_line_view + " Ready for input");
			}
			if ((tpg_flags & tpg_wait_mask) == tpg_wait) {
				while (!tz390.z390_abort && !tn_attn) {
					tz390.sleep_now(monitor_wait);
				}
			} else if (!tn_attn) {
				tpg_rc = 4; // RPI 221 return 4 if NOWAIT and no data 
				return;
			}
			if (tn_attn) {
				status_line.setText(status_line_view + " Processing keyboard input");
				tn_get_screen_input();
				tn_attn = false;
				tn_aid = tn_noaid;
				tn_kb_lock = true;
			}
		} else {
			keyboard_readline();
		}
	}

	/**
	 * Display TN3290 data stream buffer on GUAM GUI 3270 screen and return true if OK.
	 */
	public void guam_tput()
	{
		tpg_rc = 0; // RPI 221 assume OK
		if (guam_view != GuamViewTypes.SCREEN) {
			set_view_screen(0,0,0);
		}
		if (   (tpg_flags & tpg_type_mask) == tpg_type_fullscr
			|| (tpg_flags & tpg_type_mask) == tpg_type_asis) {
			tn_full_screen = true;
			tn_tput_buffer();
		} else {
			tn_full_screen = false;
			tput_edit_buffer(tput_byte,tput_len);
		}
		gz390_cmd_line.requestFocus();
	}

	/**
	 * Repaint scn_char for new font size screen.
	 */
	private void tn_repaint_screen()
	{
		tn_scn.stopScreenUpdates();

		int sba = 0;
		while (sba < max_addr) {
			tn_update_scn(sba);
			sba++;
		}

		tn_scn.startScreenUpdates();
	}
}
