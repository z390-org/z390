import java.awt.BorderLayout;
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
import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.InputStreamReader;
import java.io.PrintStream;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.StringTokenizer;

import javax.swing.BorderFactory;
import javax.swing.ImageIcon;
import javax.swing.JApplet;
import javax.swing.JButton;
import javax.swing.JCheckBoxMenuItem;
import javax.swing.JFileChooser;
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
import javax.swing.filechooser.FileFilter;

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
public class z390 extends JApplet 
	implements MouseListener, KeyListener,
				ActionListener, 
				ComponentListener,
				Runnable,
				FocusListener {
	/**
	 */
	private static final long serialVersionUID = 1L;

	// Global command mode variables

	/**
	 * Helper class to get info about the OS and Java.
	 */
	private final InfoOS infoOS = InfoOS.getInstance();

	/**
	 * Helper class offering the command history.
	 */
	private final CmdHistory cmdHistory = new CmdHistory();

	/**
	 * Helper class offering permission information.
	 */
	private final Permissions perms = new Permissions();

	/**
	 * Shared table class.
	 */
	private tz390 tz390 = null;

	/**
	 * Global variable containing the startup command file.
	 * Will be set by using the command line parameter /SC.
	 */
	private String startup_cmd_file = null;

//	// Global variable storing ECHO ON|OFF.
//	private boolean echo_cmd = true;

	/**
	 * Global variable storing CONSOLE ON|OFF.
	 */
	private boolean console_log = false;

	/**
	 * Maximum number of errors.<br>
	 * Use command "ERR n" to set new limit.<br>
	 * Set n=0 to allow unlimited errors.
	 */
	private int max_errors = 100;

	/**
	 * Global z390 error counter.
	 */
	private int z390_errors = 0;

//	// Global variable containing command error flag. 
//	private boolean cmd_error = false;

	/**
	 * Global variable indicating program is running as browser applet.
	 */
	private boolean main_applet  = false;

	/**
	 * Global variable indicating program is running using the GUI.<br>
	 * Can be forced by using the command line parameter /G.
	 */
	boolean main_gui = false;

//	// Global variable indication program is using the console
//	// Can be forced by using the command line parameter /C.
//	boolean main_console = false;

//	// parameter = file name
//	boolean main_batch = false;

	/**
	 * Global variable containing the main title.<br>
	 * Will be enhanced by the version number.<br>
	 * Can be set using the command TITLE "....".
	 */
	private String main_title = "z390";

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

	/**
	 * Global variable containing the last fetched Date+Time.
	 */
	private Date cur_date = null;

	/**
	 * Helper object to get Date in mm/dd/yy format.
	 */
	private final SimpleDateFormat mmddyy = new SimpleDateFormat("MM/dd/yy");
	/**
	 * Helper object to get Time in hh:mm:ss format.
	 */
	private final SimpleDateFormat hhmmss = new SimpleDateFormat("HH:mm:ss");

	/**
	 *  Current working directory file
	 */
	private File dir_cur_file = null;

	// Global log output file variables
	private String log_file_name = null;

	/**
	 * BufferedWriter handle to log file.
	 */
	private BufferedWriter log_file = null;

	/**
	 * True: Write unique log file time-stamps [ = default].<br>
	 * False: Omit unique log file time-stamps.<br>
	 * Can be set to false by using the command line parameter /NT.
	 */
	private boolean log_tod = true;

	/**
	 * Maximum line length while logging.
	 */
	private final int max_line_length = 80;

	// Monitor variables
	private int     ins_count = 0;
	private int     io_count  = 0;
	private int     start_cmd_io_count;
	private long    start_cmd_time;
	private Timer   monitor_timer = null;
	private final int monitor_wait = 300;
	private int     monitor_timeout_limit = 0 * 1000;
	private long    monitor_cmd_time_total = 0;
	private long    monitor_last_time = 0;
	private long    monitor_next_time = 0;
//	private long    monitor_cur_interval = 0;
	private int     monitor_last_ins_count = 0;
	private int     monitor_next_ins_count = 0;
	private int     monitor_last_io_count = 0;
	private int     monitor_next_io_count = 0;
//	private long    monitor_cur_ins  = 0;
//	private long    monitor_cur_int  = 0;
//	private long    monitor_cur_rate = 0;
	private boolean monitor_last_cmd_mode = false;

	// Status interval display variables
	private int     status_interval =  0;
	private long    status_last_time = 0;
	private long    status_next_time = 0;
//	private int     status_last_ins_count = 0;
//	private int     status_next_ins_count = 0;
//	private int     status_next_io_count  = 0;
//	private int     status_last_io_count  = 0;
//	private long    status_cur_ins  = 0;
//	private long    status_cur_int  = 0;
//	private long    status_cur_rate = 0;

	// CMD Command execution variables
	private boolean cmd_mode = false;
	private boolean cmd_running = false;
//	private int cmd_io_total = 0;
	private Process cmd_exec_process = null;
	private BufferedReader cmd_exec_error_reader  = null; // RPI 731
	private BufferedReader cmd_exec_output_reader = null; // RPI 731
	private PrintStream    cmd_exec_input_writer  = null; // RPI 731
	private String cmd_exec_error_msg = "";
	private String cmd_exec_output_msg = "";
	private Thread cmd_exec_process_thread = null;
	private Thread cmd_exec_error_reader_thread = null;
	private Thread cmd_exec_output_reader_thread = null;
//	private String cmd_line = ""; // RPI 508 prevent last becoming null
	private boolean shutdown_exit = false;

	// Global Z390 GUI objects

	/**
	 * Show status label + line in GUI?
	 */
	private boolean main_status  = true;

	private JFrame main_frame = null;
	private int main_width  = 625;
	private int main_height = 400;
	private int main_border =   2;
	private int main_loc_x  =  50;
	private int main_loc_y  =  50;
	private int font_size = 12; //see FONT command
	private final int command_columns = 75; // RPI 685

	/**
	 * Display labels (Command + Status) at the bottom of the main window?
	 */
	private boolean labels_visible = true;

	private JPanel      main_panel    = null;
	private JTextArea   log_text      = null;
	private JScrollPane log_view      = null;
	private JLabel      cmd_label     = null;
	private JTextField  z390_cmd_line = null;
	private JLabel      status_label  = null;
	private JTextField  status_line   = null;

	// Menu items requiring state changes
	private JMenuBar menuBar = null; // RPI 81
	private JMenu file_menu   = null;
	private JMenu edit_menu   = null;
	private JMenu option_menu = null;
	private JMenu view_menu   = null;
	private JMenu help_menu   = null;
	private JMenuItem file_menu_cd = null;
	private JMenuItem file_menu_edit = null;
	private JMenuItem file_menu_mac = null;
	private JMenuItem file_menu_asm = null;
	private JMenuItem file_menu_asml = null;
	private JMenuItem file_menu_asmlg = null;
	private JMenuItem file_menu_job = null;
	private JMenuItem file_menu_link = null;
	private JMenuItem file_menu_exec = null;
	private JMenuItem file_menu_exit = null;
	private JMenuItem edit_menu_cut = null;
	private JMenuItem edit_menu_copy = null;
	private JMenuItem edit_menu_paste = null;
	private JMenuItem edit_menu_select_log = null; // RPI 1041
	private JMenuItem edit_menu_select_cmd = null; // RPI 1041
	private JMenuItem edit_menu_copy_log   = null;
	private JMenuItem edit_menu_editor     = null;
	private JCheckBoxMenuItem option_menu_ascii = null;
	private JCheckBoxMenuItem option_menu_con = null;
	private JCheckBoxMenuItem option_menu_dump = null;
	private JCheckBoxMenuItem option_menu_guam  = null;
	private JCheckBoxMenuItem option_menu_list = null;
	private JCheckBoxMenuItem option_menu_listcall = null;
	private JCheckBoxMenuItem option_menu_stats = null;
	private JCheckBoxMenuItem option_menu_amode31 = null;
	private JCheckBoxMenuItem option_menu_rmode31 = null;
	private JCheckBoxMenuItem option_menu_test = null;
	private JCheckBoxMenuItem option_menu_trace = null;
	private JCheckBoxMenuItem view_menu_status = null;
	private JCheckBoxMenuItem view_menu_cmd = null;
	private JMenuItem help_menu_help = null;
	private JMenuItem help_menu_commands = null;
	private JMenuItem help_menu_guide = null;
	private JMenuItem help_menu_perm = null;
	private JMenuItem help_menu_releases = null;
	private JMenuItem help_menu_support = null;
	private JMenuItem help_menu_about = null;

	// Pop-up edit menu variables (right click)
	private JPopupMenu popup_edit_menu = null; 
	private Component focus_comp = null;

	// Dialog frames
	private JFrame select_dir_frame = null;
	private JFrame select_file_frame = null;
//	private File   selected_file = null;
//	private String selected_file_name = null;
//	private String selected_dir_name = null;
	private String select_cmd = null;
	private String select_file_type = null;
	private String select_opt  = "";

	// batch command global variables
	String bat_file_name = null;

	/**
	 * Global variable containing MAC options.<br>
	 * Will be set using global options.<br>
	 * MAC.bat file.MLC [ASCII] [NOCON] [NOLISTCALL] [NOSTATS] [TRACE] [CON] 
	 */
	private String mac_opt = "";

	/**
	 * Global variable containing ASM options.<br>
	 * Will be set using global options.<br>
	 * ASM.bat file.MLC [ASCII] [NOCON] [NOLIST] [NOLISTCALL] [NOSTATS] [TRACE] [CON]
	 */
	private String asm_opt = "";

	/**
	 * Global variable containing ASML options.<br>
	 * Will be set using global options.<br>
	 * ASML.bat file.MLC [ASCII] [NOCON] [NOAMODE31] [NOLIST] [NOLISTCALL] [RMODE31] [NOSTATS] [TRACE] [CON]
	 */
	private String asml_opt = "";

	/**
	 * Global variable containing ASMLG options.<br>
	 * Will be set using global options.<br>
	 * ASMLG.bat file.MLC [ASCII] [NOCON] [DUMP] [GUAM] [NOAMODE31] [NOLIST] [NOLISTCALL] [RMODE31] [NOSTATS] [TEST] [TRACE] [CON]
	 */
	private String asmlg_opt = "";

	/**
	 * Global variable containing JOB options.<br>
	 * Will be set using global options.<br>
	 * JOB.bat file.BAT [ASCII] [NOCON] [DUMP] [GUAM] [NOAMODE31] [NOLIST] [NOLISTCALL] [RMODE31] [NOSTATS] [TEST] [TRACE] [CON]
	 */
	private String job_opt = "";

	/**
	 * Global variable containing LINK options.<br>
	 * Will be set using global options.<br>
	 * LINK.bat file.OBJ [ASCII] [NOCON] [NOAMODE31] [NOLIST] [RMODE31] [NOSTATS] [TRACE] [CON]
	 */
	private String link_opt = "";

	/**
	 * Global variable containing EXEC options.<br>
	 * Will be set using global options.<br>
	 * EXEC.bat file.390 [ASCII] [NOCON] [DUMP] [GUAM] [NOLIST] [NOSTATS] [TEST] [TRACE] [CON]
	 */
	private String exec_opt = "";

	// web site and install location
	private final String web_site = "http://www.z390.org";
	String install_loc = null;
	String install_webdoc = null; // RPI 872

	// macro assembler command global variables
//	private String sysin_file_name = null;
//	private String syslib_dir_name = null;
//	private String sysout_dir_name = null;
//	private boolean print_option = true;
//	private boolean anim_option  = true;

	/**
	 * JApplet execution launched from web browser.
	 */
	public void init()
	{
		final ImageIcon start_icon = createImageIcon("z390.png","Run z390");
		final int cxIcon = start_icon.getIconWidth();
		final int cyIcon = start_icon.getIconHeight();
		
		final JButton start_button = new JButton(start_icon);
		start_button.setSize(cxIcon, cyIcon);
		start_button.setToolTipText("Click on z390 icon to start Z390 GUI.");
		start_button.addActionListener(new ActionListener() {
			public void actionPerformed(final ActionEvent e) {
				final String[] args = new String[1];
				args[0] = "/G";
				main_applet = true;
				if (set_main_mode(args) == 0) {
					init_z390(args);
				}
			}
		});
		getContentPane().add(start_button);
		setSize(cxIcon, cyIcon); 
	}

	/**
	 * Create instance of z390 class.
	 * @param args
	 */
	public static void main(final String[] args)
	{
		final z390 pgm = new z390();
		pgm.main_applet = false;
		pgm.set_main_mode(args);
		if (pgm.main_gui) {
			pgm.init_z390(args);
		}
	}

	/**
	 * Set main program execution mode and security permissions.
	 * @param args
	 * @return
	 */
	private int set_main_mode(final String[] args)
	{
		// Check and complain about wrong Java version...
		if (!infoOS.isCorrectJava()) {
			final MessageBox box = new MessageBox();
			box.messageBox("SZ390E error ", infoOS.getMessageIncorrectJavaVersion());
			if (!main_applet) {
				exit_main(16);
			}
			return 16;
		}

		// Notes:
		//  1. Called from main or init before z390 instance started so only set class variables.
		tz390 = new tz390();
		// main_demo = false;
		// main_lic  = false;

		// Set startup parameter options
		set_startup_parm_options(args);

		// Check for security manager and set permissions
		perms.doChecks();

		//	if ( !perms.mayLog2File() ) {
		//		if (main_batch) {
		//			System.out.println("SZ390E error 15 batch log permission denied - aborting.");
		//			shut_down(16);
		//		}
		//	}

		// Switch to demo mode if no read permission
		if ( !perms.mayReadFiles() ) {
			mode_msg1 = "Permission to read files denied - continuing in demo mode.";
			mode_msg2 = "Note: Demo mode not implemented yet.";
			// main_demo = true;
			// main_lic  = false;
			return 0;
		}
		// main_demo = false;
		// main_lic  = true;
		return 0;
	}

	/**
	 * Process startup parameters<br>
	 *    /G   - graphical interface (default)<br>
	 *    /NP  - no permissions (suppress checking permissions)<br>
	 *    /NT  - no unique log file time-stamps <br>
	 *    /RT  - regress test mode (suppress time stamps)<br> 
	 *    /SC file - startup command mode file (.bat)
	 * @param args
	 */
	private void set_startup_parm_options(final String args[])
	{
		main_gui     = false;
		// main_console = false;
		// main_batch   = false;

		if (args.length > 0) {
			int index1 = 0;
			while (index1 < args.length) {
				boolean parm_ok = false;
				final String arg = args[index1].toUpperCase();
				if (arg.equals("/G")) {
					parm_ok = true;
					// Use GUI
					main_gui     = true;
					//main_console = false;
					//main_batch   = false;
				} else
				if (arg.equals("/NP")) {
					parm_ok = true;
					// Do not check permissions (all false)
					perms.setAllowChecks(false);
				} else
				if (arg.equals("/NT")) {
					parm_ok = true;
					// No unique log file time-stamps
					log_tod = false;
				} else
				if (arg.equals("/RT")) {
					parm_ok = true;
					// Suppress time stamps (in regress test mode)
					tz390.opt_timing = false;
				} else
				if (arg.equals("/SC")) {
					// Startup command mode file (.bat)
					index1++;
					if (index1 < args.length) {
						parm_ok = true;
						startup_cmd_file = args[index1];
						if (   startup_cmd_file.charAt(0)    != '\"'
							&& startup_cmd_file.indexOf(' ') != -1) {
							startup_cmd_file = '\"' + startup_cmd_file + '\"';
						}
					}
				}
				if (!parm_ok) {
					System.out.println("S075 z390 parameter error - " + args[index1]);
				}
				index1++;
			}
		}
		if  (!main_gui /* && !main_batch *//* && !main_console */ ) {
			main_gui = true;
		}
	}

	/**
	 * If OFF specified, turn log off.<br>
	 * If file specified, open as new log file.<br>
	 * Else error.
	 * @param cmd_parm1
	 * @param cmd_parm2
	 */
	private void log_command(final String cmd_parm1, final String cmd_parm2)
	{
		if (   cmd_parm1 != null
			&& cmd_parm1.toUpperCase().equals("OFF")) {
			close_log_file();
		} else
		if (cmd_parm1 != null) {
			close_log_file();
			try {
				log_file_name = cmd_parm1;
				log_file = new BufferedWriter(new FileWriter(log_file_name));
				put_copyright();
				put_log("Log file = " + log_file_name);
			} catch (final Exception e) {
				abort_error(1, "Log file open - " + e.toString());
			}
		} else {
			log_error(74, "Missing log command file or OFF parameter.");
		}
	}

	/**
	 * Open log file
	 */
	private void open_log_file()
	{
		if ( perms.mayLog2File() ) {
			install_loc = System.getProperty("user.dir");
			File temp_file = new File(install_loc);
			if (temp_file.isDirectory()) {
				install_loc = temp_file.getPath();
			} else {
				abort_error(52, "Invalid install directory - " + install_loc);
			}
			// 2008-09-08 - RPI-0872 - Help menu "Guide" link to www.z390.org or webdoc/index.html
			temp_file = new File(install_loc + File.separator + "webdoc" + File.separator + "index.html"); 
			if (temp_file.exists()) {
				try {
					install_webdoc = temp_file.toURI().toURL().toExternalForm();
				} catch (final Exception e) {
					// 2008-09-10 - RPI-0904 - Correct help menu "Guide" to support LSN path.
					install_webdoc = null;
				}
			} else {
				// 2008-09-08 - RPI-0872 - Help menu "Guide" link to www.z390.org or webdoc/index.html
				install_webdoc = null;
			}
			log_file_name = tz390.get_file_name(tz390.dir_cur,"z390",tz390.log_type);
			try {
				if (log_tod) {
					boolean new_log = false;
					String temp_log_name = "temp";
					while (!new_log){
						final Date tod = new Date();
						final SimpleDateFormat tod_format = new SimpleDateFormat("_yyyy_MMdd_HHmmss");
						final String log_file_tod = tod_format.format(tod);
						final int index = log_file_name.indexOf('.');
						if (index == -1) {
							temp_log_name = log_file_name                    + log_file_tod + tz390.log_type;
						} else {
							temp_log_name = log_file_name.substring(0,index) + log_file_tod + tz390.log_type; // RPI 508
						}
						final File temp_log_file = new File(temp_log_name);
						if (temp_log_file.exists()) {
							sleep_now();
						} else {
							new_log = true;
						}
					}
					log_file_name = temp_log_name;
				} else {
					log_file_name = log_file_name.concat(tz390.log_type);
				}
				log_file = new BufferedWriter(new FileWriter(log_file_name));
				put_copyright();
				put_log("Log file = " + log_file_name);
			} catch (Exception e) {
				// 2006-03-19 - RPI-0236 - If install directory is read-only, turn off log,
				// 						   and send message to console saying "use log command".
				log_file = null;  // RPI 236
				System.out.println("z390 log file I/O error - use LOG command to open new log " + e.toString());
			}
		} else {
			put_copyright();
			log_error(15,"Permission to write log in current directory denied");
		}
		put_log("Enter command or help");
	}

	/**
	 * Close log file.
	 */
	private void close_log_file()
	{
		if (log_file != null) {
			try {
				log_file.close();
				log_file = null;
			} catch (final Exception e) {
				System.out.println("S003 z390 log file close error - " + e.toString());
				shut_down(16);
			}
		}
	}

	/**
	 * Display error total on log and close data and log files.
	 */
	private void close_all_files()
	{
		put_log("Z390I total errors = " + z390_errors);
		close_log_file();
	}

	/**
	 * Write error to log file.
	 * @param error
	 * @param msg
	 */
	private void log_error(final int error, final String msg)
	{
		z390_errors++;
		// cmd_error = true;

		// msg = "SZ390E error " + error + " " + msg;
		final StringBuilder sb = new StringBuilder();
		sb.append("SZ390E error ").append(error).append(" ").append(msg);

		if (sb.length() > max_line_length) {
			put_log(sb.substring(0,max_line_length));
			int index1 = max_line_length;
			while (index1 < sb.length()) {
				int text_length = sb.length() - index1;
				if (text_length > max_line_length) {
					text_length = max_line_length - 5;
				}
				put_log("     " + sb.substring(index1,index1 + text_length));
				index1 = index1 + text_length;
			}
		} else {
			put_log(sb.toString());
		}
		if (   max_errors != 0
			&& z390_errors > max_errors) {
			abort_error(10, "Maximum errors exceeded (max is " + max_errors + ").");
		}
	}

	/**
	 * Write error to log file and abort completely with RC 16.
	 * @param error
	 * @param msg
	 */
	private synchronized void abort_error(final int error, final String msg)
	{
		z390_errors++;

	//	msg = "SZ390E " + error + " " + msg;
		final StringBuilder sb = new StringBuilder();
		sb.append("SZ390E ").append(error).append(" ") .append(msg);
		final String sMessage = sb.toString();

		put_log(sMessage);
		System.out.println(sMessage);

		exit_main(16);
	}

	/**
	 * Cancel threads and exit with RC (turn off runtime shutdown exit).
	 * @param return_code
	 */
	private void shut_down(final int return_code)
	{
		if (monitor_timer != null) {
			monitor_timer.stop();
		}
		if  (cmd_exec_process != null) {
			cmd_exec_cancel();
		}
		if  (main_frame != null) {
			main_frame.dispose();
		}
		if (main_applet) {
			showStatus("Z390I total errors = " + z390_errors);
		} else if (!shutdown_exit) {
			shutdown_exit = true; //disable exit
			System.exit(return_code);
		}
	}

	/**
	 * Install hook for shutdown when -Xrs VM set
	 */
	private void set_runtime_hooks()
	{
		if ( /*  main_console && */ !shutdown_exit) {
			Runtime.getRuntime().addShutdownHook(new Thread() {
				public void run() {
					if (!shutdown_exit) {
						shutdown_exit = true;
						if (tz390.opt_trap) {
							try {
								abort_error(78, "Aborting due to external shutdown request.");
							} catch (final Exception e) {
								System.out.println("z390 internal system exception abort " + e.toString());
							}
						} else {
							abort_error(78, "Aborting due to external shutdown request.");
						}
					}
				}
			});
		}
	}

	/**
	 * Display z390 version and copyright.
	 */
	private void put_copyright()
	{
		put_log("Z390I " + tz390.version);
		put_log("Copyright 2011 Automated Software Tools Corporation");
		put_log("z390 is licensed under GNU General Public License");
		if (mode_msg1 != null) { put_log(mode_msg1); }
		if (mode_msg2 != null) { put_log(mode_msg2); }
	}

	/**
	 * Write message to log file and to console if console mode or console option on.
	 * @param msg
	 */
	private synchronized void put_log(final String msg)
	{
		if (msg.trim().length() == 0) {
			return;
		}
		io_count++;
		if (main_gui) {
			tz390.log_text_append(log_text, msg);
		} else
		if ( /* main_console || */ console_log) {
			System.out.println(msg);
		}
		if (log_file != null) {
			try {
				log_file.write(msg + tz390.newline);
			} catch (final Exception e) {
				abort_error(2, "Write to log error - " + e.toString());
			}
		}
	}

	/**
	 * Parse parameters and execute z390 command if found.
	 * @param cmd_text
	 */
	private void process_command(final String cmd_text)
	{
		/* 
		 * 1. Parse parameters and execute z390 command if found.
		 *    a) * in position 1 is a comment
		 *    e) space or null logged as blank line 
		 *
		 * 2. If not a known z390 command, issue CMD Windows command.
		 * 
		 * Notes:
		 * 1. z390_cmd_line event handler routes input to CMD processor when in cmd_mode.
		 *
		 * 2. Some commands will issue retry or cancel error message if command
		 *    running on separate thread to avoid file conflicts or deadlocks.  Other
		 *    non destructive commands will proceed in parallel which may cause log 
		 *    messages to be intermixed.
		 *
		 * 3. Status bar shows progress of command processes on separate threads.
		 *
		 * 4. Use EXIT or BREAK event to abort CMD process. CTRL-C works in command mode only.
		 */
		String cmd_line = cmd_text.trim();
		// cmd_error = false;
		if (   cmd_line          == null
			|| cmd_line.length() == 0) {
			return;
		}

		try {
			String cmd_opcode = null;
			String cmd_parm1  = null;
			String cmd_parm2  = null;
			boolean cmd_opcode_ok = false;

			// 2006-04-03 - RPI-0235 correct CD path display and support cd.. etc.
			if (   cmd_line.length() > 2
				&& cmd_line.substring(0,2).toUpperCase().equals("CD")) {
				cmd_line = "CD " + cmd_line.substring(2);
			}

			final StringTokenizer st = new StringTokenizer(cmd_line," ,\'\"",true);
			cmd_opcode = get_next_parm(st,true).toUpperCase();
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
				if (   cmd_parm1 != null
					&& cmd_parm1.equals(",")) {
					cmd_parm1 = null;
					cmd_parm2 = null;
				}
			}

			final char first_char = cmd_opcode.charAt(0);
			switch (first_char) {
			case 'A':
				if (cmd_opcode.equals("ABOUT")) {
					cmd_opcode_ok = true; 
					about_command();
				} else
				if (cmd_opcode.equals("AMODE31")){
					cmd_opcode_ok = true;
					tz390.opt_amode31 = options_command(option_menu_amode31, cmd_parm1,cmd_parm2);
				} else
				if (cmd_opcode.equals("ASCII")) {
					cmd_opcode_ok = true;
					tz390.opt_ascii = options_command(option_menu_ascii, cmd_parm1,cmd_parm2);
				} else
				if (cmd_opcode.equals("ASM")) {
					cmd_opcode_ok = true;
					batch_cmd("ASM",cmd_parm1,"MLC",cmd_parm2);
				} else
				if (cmd_opcode.equals("ASML")) {
					cmd_opcode_ok = true;
					batch_cmd("ASML",cmd_parm1,"MLC",cmd_parm2);
				} else
				if (cmd_opcode.equals("ASMLG")) {
					cmd_opcode_ok = true;
					batch_cmd("ASMLG",cmd_parm1,"MLC",cmd_parm2);
				}
				break;
			//case 'B':
			//	break;
			case 'C': 
				if (cmd_opcode.equals("CD")) {
					cmd_opcode_ok = true; 
					cd_command(cmd_parm1); 
				} else
				if (cmd_opcode.equals("COMMANDS")) {
					cmd_opcode_ok = true; 
					commands_command(); 
				} else
				if (cmd_opcode.equals("CON")) {
					cmd_opcode_ok = true;
					tz390.opt_con = options_command(option_menu_con, cmd_parm1,cmd_parm2);
				} else
				if (cmd_opcode.equals("COPYLOG")) {
					cmd_opcode_ok = true;
					if  (main_gui) {
						log_text.requestFocus();
						log_text.selectAll();
						log_text.copy();
					} else {
						log_error(24, "COPYLOG not available in command mode");
					}
				} else
				if (cmd_opcode.equals("CMD")) {
					cmd_opcode_ok = true;
					if (cmd_parm1 == null) {
						if (cmd_mode) {  // RPI-15
							cmd_exec_cancel();
						} else {
							if (cmd_exec_rc() != -1) {
								cmd_startup(null); // start cmd processor
							}
							cmd_mode = true;
						}
					} else {
						final int index1 = cmd_line.toUpperCase().indexOf("CMD ") + 4; // RPI-62
						cmd_command(cmd_line.substring(index1));
					}
				} else
				if (cmd_opcode.equals("CONSOLE")) {
					cmd_opcode_ok = true; 
					if (cmd_parm1 != null) {
						if (cmd_parm1.toUpperCase().equals("OFF")) {
							console_log = false;
						} else {
							console_log = true;
						}
					} else {
						log_error(50, "Missing immediate data parameter.");
					}
				}
				break;
			case 'D':
				if (cmd_opcode.equals("DD")) {
					cmd_opcode_ok = true;
					batch_cmd("DD",cmd_parm1,"",cmd_parm2);
				} else
				if (cmd_opcode.equals("DUMP")){
					cmd_opcode_ok = true;
					tz390.opt_dump = options_command(option_menu_dump, cmd_parm1,cmd_parm2);
				}
				break;
			case 'E':
				//if (cmd_opcode.equals("ECHO")) {
				//	cmd_opcode_ok = true; 
				//	if  (cmd_parm1 != null) {
				//		if (cmd_parm1.toUpperCase().equals("OFF")){
				//			echo_cmd = false;
				//		} else {
				//			echo_cmd = true;
				//		}
				//	} else {
				//		log_error(50, "Missing immediate data parameter.");
				//	}
				//} else
				if (cmd_opcode.equals("EDIT")) {
					cmd_opcode_ok = true;
					batch_cmd("EDIT",cmd_parm1,"","");
				} else
				if (cmd_opcode.equals("ERR")) {
					cmd_opcode_ok = true;
					max_errors = Integer.valueOf(cmd_parm1).intValue();
					put_log("max errors set to - " + max_errors);
				} else
				if (cmd_opcode.equals("EXEC")) {
					cmd_opcode_ok = true;
					batch_cmd("EXEC",cmd_parm1,"390",cmd_parm2);
					break;
				} else
				if (cmd_opcode.equals("EXIT")) {
					cmd_opcode_ok = true;
					exit_command();
				}
				break;
			case 'F':
				if (cmd_opcode.equals("FONT")) {
					cmd_opcode_ok = true;
					font_command(cmd_parm1,cmd_parm2);
				}
				break;
			case 'G': 
				if (cmd_opcode.equals("GUAM")){
					cmd_opcode_ok = true;
					tz390.opt_guam = options_command(option_menu_guam, cmd_parm1,cmd_parm2);
				} else
				if (cmd_opcode.equals("GUIDE")) {
					cmd_opcode_ok = true; 
					//if (!main_batch){
					guide_command();
					//} else {
					//	log_error(54, "Interactive command not supported in batch.");
					//}
				}
				break;
			case 'H': 
				if  (cmd_opcode.equals("HELP")) {
					cmd_opcode_ok = true; 
					help_command();
				}
				break;
			//case 'I':
			//	break;
			case 'J':
				if (cmd_opcode.equals("JOB")) {
					cmd_opcode_ok = true;
					batch_cmd("JOB",cmd_parm1,"BAT",cmd_parm2);
				}
				break;
			case 'L':
				if  (cmd_opcode.equals("LINK")) {
					cmd_opcode_ok = true;
					batch_cmd("LINK",cmd_parm1,"OBJ",cmd_parm2);
				} else
				if (cmd_opcode.equals("LIST")) {
					cmd_opcode_ok = true;
					tz390.opt_list = options_command(option_menu_list, cmd_parm1,cmd_parm2);
				} else
				if  (cmd_opcode.equals("LISTCALL")) {
					cmd_opcode_ok = true;
					tz390.opt_listcall = options_command(option_menu_listcall, cmd_parm1,cmd_parm2);
				} else
				if (cmd_opcode.equals("LOG")) {
					cmd_opcode_ok = true;
					log_command(cmd_parm1,cmd_parm2);
				} else
				if (cmd_opcode.equals("LOC")) {
					cmd_opcode_ok = true; 
					loc_command(cmd_parm1,cmd_parm2);
				}
				break;
			case 'M': 
				if (cmd_opcode.equals("MAC")) {
					cmd_opcode_ok = true;
					batch_cmd("MAC",cmd_parm1,"MLC",cmd_parm2);
				}
				break;
			//case 'O':
			//	break;
			case 'P':
				if (cmd_opcode.equals("PERM")) {
					cmd_opcode_ok = true; 
					perm_command();
				} else
				if (cmd_opcode.equals("PASTE")) {
					cmd_opcode_ok = true;
					//if  (!main_batch) {
					put_log("PASTE from clipboard starting " + time_stamp());
					put_log(getClipboard()); // append to log
					put_log("PASTE from clipboard ending   " + time_stamp());
					//} else {
					//	log_error(54, "Interactive command not supported in batch.");
					//}
				}
				break;
			case 'R':
				if  (cmd_opcode.equals("REL")) {
					cmd_opcode_ok = true; 
					rel_command();
				} else
				if (cmd_opcode.equals("RMODE31")) {
					cmd_opcode_ok = true;
					tz390.opt_rmode31 = options_command(option_menu_rmode31, cmd_parm1,cmd_parm2);
				}
				break;
			case 'S':
				if (cmd_opcode.equals("STATS")) {
					cmd_opcode_ok = true;
					tz390.opt_stats = options_command(option_menu_stats,cmd_parm1,cmd_parm2);
					break;
				} else
				if (cmd_opcode.equals("STATUS")) {
					cmd_opcode_ok = true;
					status_command(cmd_parm1,cmd_parm2);
				} else
				if (cmd_opcode.equals("SUPPORT")) {
					cmd_opcode_ok = true; 
					//if (!main_batch) {
					support_command();
					//} else {
					//	log_error(54, "Interactive command not supported in batch");
					//}
				} else
				if (cmd_opcode.equals("SIZE")) {
					cmd_opcode_ok = true;
					size_command(cmd_parm1,cmd_parm2);
				}
				break;
			case 'T':
				if (cmd_opcode.equals("TEST")) {
					cmd_opcode_ok = true;
					tz390.opt_test = options_command(option_menu_test, cmd_parm1,cmd_parm2);
				} else
				if  (cmd_opcode.equals("TIMEOUT")) {
					cmd_opcode_ok = true;
					timeout_command(cmd_parm1,cmd_parm2);
				} else
				if  (cmd_opcode.equals("TITLE")) {
					cmd_opcode_ok = true;
					title_command(cmd_parm1,cmd_parm2);
				} else
				if (cmd_opcode.equals("TRACE")) {
					cmd_opcode_ok = true;
					tz390.opt_trace = options_command(option_menu_trace, cmd_parm1,cmd_parm2);
				}
				break;
			//case 'U':
			//	break;
			//case 'V':
			//	break;
			//case 'W':
			//	break;
			//case 'X':
			//	break;
			case '*':
				cmd_opcode_ok = true;
				break;
			}

			// If built in command not found, try Windows cmd.
			if (!cmd_opcode_ok) {
				process_command("CMD " + cmd_line);
			} else {
				cmdHistory.add_cmd_hist(cmd_line); // add_cmd_hist();
			}
		} catch (final Exception e) {
			log_error(51, "Command error on -" + cmd_line);
		}
	}

	/**
	 * Return date and time if tz390.opt_timing.
	 * @return
	 */
	private String time_stamp()
	{
		String temp_date_text = "";
		if (tz390.opt_timing) {
			Date temp_date = new Date(); 
			temp_date_text = mmddyy.format(temp_date)
					 + " " + hhmmss.format(temp_date);
		}
		return temp_date_text;
	}

	/**
	 * Get string with or without single/double quotes.
	 * Ignore leading spaces or commas if ignore_spaces = true,
	 * else return null if space or comma found next.
	 * @param st
	 * @param ignore_spaces
	 * @return
	 */
	private String get_next_parm(final StringTokenizer st, final boolean ignore_spaces)
	{
		String parm_string = st.nextToken();
		while (    ignore_spaces
				&& parm_string.equals(" ")
				&& st.hasMoreElements()) {
			parm_string = st.nextToken();
		}
		if (   parm_string.equals("\"")
			|| parm_string.equals("\'")) {
			final String delimiter = parm_string;
			String next_token = "";
			while (st.hasMoreTokens() && !next_token.equals(delimiter)) {
				next_token = st.nextToken();
				parm_string = parm_string + next_token;
			}
		} else
		if (parm_string.equals(" ")) {
			parm_string = null;
		}
		return parm_string;
	}

	/**
	 * Write command list.
	 */
	private void about_command()
	{
		put_copyright();
		put_log("z390 Portable mainframe macro assembler, linker, and emulator tool");
		put_log("  * edit, assemble, link, and execute mainframe assembler code");
		put_log("  * use interactive z390 GUI, command line, or batch interface");
		put_log("  * macro assembler compatible with HLASM");
		put_log("  * linker supports AMODE/RMODE relocatable load modules");
		put_log("  * emulator supports 32/64 bit plus HFP/BFP floating point instructions");
		put_log("  * emulator supports OS basic svcs such as READ/WRITE at macro level");
		put_log("  * emulator includes powerful trace and test debug tools");
		put_log("  * z390 distributed as InstallShield exe for Windows and as zip");
		put_log("  * z390 includes example demos and regression tests");
		put_log("  * z390 written entirely in J2SE 1.5.0 compatible Java");
		put_log("  * z390 distributed with source under GNU open source license");
		put_log("  * z390 open source project for support and extensions");
		put_log("Visit www.z390.org for additional information");
	}

	/**
	 * Reset font size for log, and command line and menu pop-ups.
	 * @param cmd_parm1
	 * @param cmd_parm2
	 */
	private void font_command(final String cmd_parm1, final String cmd_parm2)
	{
		if (cmd_parm1 != null) {
			final int new_font_size = getDecimalInteger(cmd_parm1);
			if (new_font_size < 8 || new_font_size > 72) {
				log_error(63, "Font outside fixed width font limits [8..72 pt].");
			} else
			if (main_gui) {
				font_size = new_font_size;
				set_text_font();
				set_tooltips();
				main_frame.setSize(main_width, main_height-1); // Ugly work-around to force system...
				main_frame.setSize(main_width, main_height+1); // ... to send a componentResized event
				update_main_view();
			}
		} else {
			log_error(63, "Font outside fixed width font limits.");
		}
	}

	/**
	 * Reset font size for menu, log, command, and status line.
	 */
	private void set_text_font()
	{
		final Font newFont = new Font(tz390.z390_font,Font.BOLD,font_size);
		menuBar.setFont(newFont);

		file_menu.setFont(newFont);
			file_menu_cd.setFont(newFont);
			file_menu_edit.setFont(newFont);
			file_menu_mac.setFont(newFont);
			file_menu_asm.setFont(newFont);
			file_menu_asml.setFont(newFont);
			file_menu_asmlg.setFont(newFont);
			file_menu_job.setFont(newFont);
			file_menu_link.setFont(newFont);
			file_menu_exec.setFont(newFont);
			file_menu_exit.setFont(newFont);

		edit_menu.setFont(newFont);
			edit_menu_cut.setFont(newFont);
			edit_menu_copy.setFont(newFont);
			edit_menu_paste.setFont(newFont);
			edit_menu_select_log.setFont(newFont);
			edit_menu_select_cmd.setFont(newFont);
			edit_menu_copy_log.setFont(newFont);
			edit_menu_editor.setFont(newFont);

		option_menu.setFont(newFont);
			option_menu_ascii.setFont(newFont);
			option_menu_con.setFont(newFont);
			option_menu_dump.setFont(newFont);
			option_menu_guam.setFont(newFont);
			option_menu_list.setFont(newFont);
			option_menu_listcall.setFont(newFont);
			option_menu_stats.setFont(newFont);
			option_menu_amode31.setFont(newFont);
			option_menu_rmode31.setFont(newFont);
			option_menu_test.setFont(newFont);
			option_menu_trace.setFont(newFont);

		view_menu.setFont(newFont);
			view_menu_status.setFont(newFont);
			view_menu_cmd.setFont(newFont);

		help_menu.setFont(newFont);
			help_menu_help.setFont(newFont);
			help_menu_commands.setFont(newFont);
			help_menu_guide.setFont(newFont);
			help_menu_perm.setFont(newFont);
			help_menu_releases.setFont(newFont);
			help_menu_support.setFont(newFont);
			help_menu_about.setFont(newFont);

		log_text.setFont(newFont);

		cmd_label.setFont(newFont);
		z390_cmd_line.setFont(newFont);

		status_label.setFont(newFont);
		status_line.setFont(newFont);
	}

	/**
	 * Return integer from immediate decimal parameter.
	 * @param cmd_parm
	 * @return
	 */
	private int getDecimalInteger(final String cmd_parm)
	{
		// final int save_hex_base = hex_base;
		// hex_base = 10;
		final int work_int = getInteger(10, cmd_parm);
		// hex_base = save_hex_base;
		return work_int;
	}

	/**
	 * Return integer from immediate hex parameter:or reg.
	 * @param hex_base
	 * @param cmd_parm
	 * @return
	 */
	private int getInteger(final int hex_base, final String cmd_parm)
	{
		int work_int = 0;
		int index1 = 1;
		try {
			if (   cmd_parm.charAt(0) == '\''
				&& cmd_parm.length() <= 6) {
				while (index1 < cmd_parm.length() - 1) {
					work_int = work_int * 256 + get_text_char((int)cmd_parm.charAt(index1));
					index1++;
				}
			} else if (cmd_parm.length() < 8) {
				work_int = Integer.valueOf(cmd_parm,hex_base).intValue();
			} else if (cmd_parm.length() == 8) {
				work_int = Integer.valueOf(cmd_parm.substring(0,4),hex_base).intValue() * 256 * 256
						 + Integer.valueOf(cmd_parm.substring(4  ),hex_base).intValue();
			} else {
				log_error(36, "Invalid hex value - " + cmd_parm);
			}
			return work_int;
		} catch (final Exception e) {
			log_error(36, "Invalid hex value - " + cmd_parm);
			return 0;
		}
	}

	/**
	 * Return int value of char or 0 if not printable.
	 * @param work_int
	 * @return
	 */
	private int get_text_char(int work_int)
	{
		if (work_int < 0) {
			work_int = work_int + 256;
		}
		return work_int;
	}

	/**
	 * Log summary list of commands and help reference.
	 */
	private void help_command()
	{
		put_log("\nz390 help command summary");
		put_log("File menu selections");
		put_log("  EDIT  - open source file to edit");
		put_log("  MAC   - expand MLC macro source to BAL assembler source");
		put_log("  ASM   - assemble MLC to relocatable OBJ file");
		put_log("  ASML  - assemble and link MLC to 390 load module file");
		put_log("  ASMLG - assemble, link, and execule 390 load module file");
		put_log("  JOB   - execute selected batch job");
		put_log("  LINK  - link OBJ files into 390 load module file");
		put_log("  EXEC  - execute 390 load module file");
		put_log("Option menu - toggle default options for above cmds");
		put_log("View menu - toggle status line and cmd input mode");
		put_log("Type COMMANDS for alphabetical list of all commands");
		put_log("Type GUIDE to view online or local help (if installed)");
		put_log("Type SUPPORT to visit support web site");
	}

	/**
	 * Start monitor to terminate cmd command if timeout limit reached.
	 */
	private void monitor_startup()
	{
		monitor_last_time = System.currentTimeMillis();
		monitor_last_ins_count = ins_count;
		status_last_time = monitor_last_time;
		//status_last_ins_count = ins_count;
		try {
			final ActionListener cmd_listener = new ActionListener() {
				public void actionPerformed(final ActionEvent evt) {
					monitor_update();
				}
			};
			monitor_timer = new Timer(monitor_wait,cmd_listener);
			monitor_timer.start();
		} catch (final Exception e) {
			log_error(66, "Execution startup error " + e.toString());
		}
	}

	/**
	 * Start Windows command processor with synchronized buffered output to log.<br>
	 * If cmd_line is null, set cmd_mode and start command processor without command.
	 * Future commands in cmd_mode will be passed to processor via cmd_exec_input_writer.
	 * @param cmd_line
	 * @return
	 */
	private int cmd_startup(final String cmd_line)
	{
		String[] cmd_parms;
		try {
			if (infoOS.isLinux()) {
				if  (cmd_line != null) {
					cmd_parms = new String[3];
					cmd_parms[0] = infoOS.get_z390_command();
					// 2007-01-30 - RPI-0532 Correct Doc path and cmd.pl path and separator
					cmd_parms[1] = install_loc + "/cmd.pl";
					cmd_parms[2] = cmd_line;
				} else {
					cmd_parms = new String[2];
					cmd_parms[0] = infoOS.get_z390_command();
					// 2007-01-30 - RPI-0532 Correct Doc path and cmd.pl path and separator
					cmd_parms[1] = install_loc + "/cmd.pl";
				}
			} else {
				if  (cmd_line != null) {
					cmd_parms = new String[3];
					cmd_parms[0] = infoOS.get_z390_command();
					cmd_parms[1] = "/C";
					cmd_parms[2] = cmd_line;
				} else {
					cmd_parms = new String[1];
					cmd_parms[0] = infoOS.get_z390_command();
				}
			}
			final int rc = cmd_exec_start(cmd_parms);
			if  (rc == 0) {
				monitor_cmd_time_total = 0;
				start_cmd_io_count = io_count;
				start_cmd_time = cur_date.getTime();
				if (!main_gui) {
					while (cmd_exec_rc() == -1) {
						sleep_now();
					}
				}
				if (tz390.opt_timing) {
					cur_date = new Date();
				}
				sync_cmd_dir();
				final StringBuilder sb = new StringBuilder();
				sb.append("*** ")
				  .append(mmddyy.format(cur_date)).append(" ").append(hhmmss.format(cur_date))
				  .append(" CMD task started");
				put_log(sb.toString());
			} else {
				log_error(66, "CMD task startup error rc = " + rc + ".");
				cmd_exec_cancel();
			}
			return rc;
		} catch (final Exception e) {
			log_error(66, "Execution startup error - " + e.toString());
			cmd_exec_cancel();
			return 16;
		}
	}

	/**
	 * Sleep for monitor interval if not abort
	 */
	private void sleep_now()
	{
		if (tz390.z390_abort) {
			exit_command();
		}
		try {  // wait until done if not GUI
			Thread.sleep(monitor_wait);
		} catch (final Exception e) {
			abort_error(77, "Wait interrupted " + e.toString() );
		}
	}

	/**
	 * Sync the command task directory with current directory.
	 */
	private void sync_cmd_dir()
	{
		if (!tz390.dir_cur.equals(install_loc)) {
			if (infoOS.isLinux()) {
				cmd_exec_input("CD " + tz390.dir_cur); // Change Linux directory and/or drive
			} else {
				if (!tz390.dir_cur.substring(0,2).equals(install_loc.substring(0,2))) {
					cmd_exec_input(tz390.dir_cur.substring(0,2)); // Change windows drive
				}
				cmd_exec_input("CD " + tz390.dir_cur.substring(2)); // Change windows directory
			}
		}
	}

	/**
	 * 
	 */
	private void monitor_update()
	{
		/*
		 * 1.  At monitor_wait intervals, update the z390 GUI title date and time and the status line information.
		 * 2.  If CMD mode and monitor_wait_total > timeout_interval then abort CMD.
		 * 3.  If monitor_wait_total > status_interval then update and log status line in batch or command mode.
		 * 4.  If current time beyond main_demo timeout terminate.
		 * 5.  Reset focus to z390_cmd_line after update
		 */
		if (tz390.z390_abort) {
			exit_command();
		}
		monitor_next_time      = System.currentTimeMillis();
		monitor_next_ins_count = ins_count;
		monitor_next_io_count  = io_count;
	//	monitor_cur_interval   =  monitor_next_time - monitor_last_time;
		monitor_cmd_time_total = (monitor_next_time - start_cmd_time)/1000;
		if (tz390.opt_timing) {
			cur_date = new Date();
		}
		if  ((cmd_mode || cmd_running) && cmd_exec_rc() != -1) {
			final StringBuilder sb = new StringBuilder();
			sb.append("*** ")
			  .append(mmddyy.format(cur_date)).append(" ").append(hhmmss.format(cur_date))
			  .append(" CMD task ended TOT SEC=").append(monitor_cmd_time_total)
			  .append(" TOT LOG IO="            ).append(io_count-start_cmd_io_count);
			put_log(sb.toString());
			cmd_mode    = false;
			cmd_running = false;
			if (main_gui) {
				view_menu_cmd.setSelected(false);
			}
		}
		if (main_gui) {
			title_update();
			if (   ins_count > monitor_last_ins_count
				|| io_count  > monitor_last_io_count
				|| monitor_last_cmd_mode != cmd_mode) {
				//monitor_cur_ins  = monitor_next_ins_count - monitor_last_ins_count;
				//monitor_cur_int  = monitor_next_time - monitor_last_time;
				//monitor_cur_rate = monitor_cur_ins *1000 / monitor_cur_int;
				status_line.setText(get_status_line());
			}
//			check_main_view();
		}
		if (status_interval > 0) {
			status_next_time = monitor_next_time;
			//status_cur_int = status_next_time - status_last_time;
			if (   (status_next_time - status_last_time) >= status_interval
				&& (!cmd_mode && cmd_exec_rc() == -1)) {
				status_log_update();
			}
		}
		if (monitor_timeout_limit > 0) {
			if (!cmd_mode && cmd_exec_rc() == -1) {
				if (monitor_cmd_time_total > monitor_timeout_limit) {
					cmd_timeout_error(); 
				}
			}
		}
		monitor_last_cmd_mode = cmd_mode;
		monitor_last_time = monitor_next_time;
		monitor_last_ins_count  = monitor_next_ins_count;
		monitor_last_io_count   = monitor_next_io_count;
	}

	/**
	 * Command timeout error.
	 */
	private void cmd_timeout_error()
	{
		cmd_exec_cancel();
		status_log_update();
		log_error(69, "CMD command timeout error - command aborted.");
		reset_z390_cmd();
	}

	/**
	 * Execute Windows command as follows:<br>
	 * 1.  If cmd_mode set via prior cmd with no command, then all commands are routed
	 *     to command processor via cmd_exec_input.  Use  BREAK key or EXIT command
	 *     passed to command processor to end cmd_mode.<br>
	 * 2.  If prior Windows command is still running, display current status and request 
	 *     user hit break or retry later.<br>
	 * 3.  If cmd_mode not set then start command processor via call to cmd_exec_start.<br>
	 * 4.  See STATUS command to set interval for display of status of long running commands.
	 */
	private void cmd_command(final String cmd)
	{
		if (cmd_exec_rc() == -1) {
			cmd_exec_input(cmd); // Route command to existing CMD task running.
		} else
		if (cmd == null) {
			cmd_startup(null);
		} else {
			cmd_startup(null);
			cmd_exec_input(cmd);
			cmd_running = true;
			cmd_exec_input(" exit"); // Note: Leading space may be eaten by pause!
		}
	}

	/*
	 **************************************************
	 * Command support functions
	 **************************************************  
	 */

	/**
	 * Format fixed field status line for both z390 GUI status line and status log requests.
	 *   1. Time of date
	 *   2. INS total -- dropped?!?
	 *   3. I/O total
	 *   4. CMD mode
	 * @return
	 */
	private String get_status_line()
	{
		final StringBuilder sb = new StringBuilder();
		sb.append(time_stamp()).append(" LOG IO=").append(get_pad(io_count,6));
		if (cmd_exec_rc() == -1) {
			sb.append(" CMD");
		}
		return sb.toString();
	}

	/**
	 * Format and pad status line number to specified length.<br>
	 * If number <= 0, return all spaces.<br>
	 * If number > 1000000, return M.<br>
	 * If number > 1000, return K.
	 * @param num
	 * @param pad
	 * @return
	 */
	private String get_pad(final long num, final int pad)
	{
		final String padding = "           "; // 11 spaces
		final StringBuilder sb = new StringBuilder();

		if (num > 0) {
			if  (num > 1000000) {
				sb.append(num/1000000).append("M");
			} else
			if  (num > 1000) {
				sb.append(num/1000).append("K");
			} else {
				sb.append(num);
			}
		}
		sb.append(padding);
		return sb.substring(0,pad);
	}

	/**
	 * Update status interval and write status line to log.
	 */
	private void status_log_update()
	{
		status_next_time = System.currentTimeMillis();
		//status_next_ins_count = ins_count;
		//status_next_io_count = io_count;
		//status_cur_int = status_next_time - status_last_time;
		//status_cur_ins = status_next_ins_count - status_last_ins_count;
		//if  (status_cur_int > 0) {
		//	status_cur_rate = status_cur_ins * 1000/status_cur_int;
		//} else {
		//	status_cur_rate = 0;
		//}
		put_log(get_status_line());
		status_last_time = status_next_time;
		//status_last_ins_count = status_next_ins_count;
		//status_last_io_count = status_next_io_count;
	}

	/**
	 * Load shared tables and file routines.
	 * @param args
	 */
	private void init_z390(String[] args)
	{
		// 2009-09-26 - RPI-1080 Replace init_tables with init_tz390.
		tz390.init_tz390();

		// 2006-05-05 - RPI-0309 Retain last directory on file select.
		dir_cur_file = new File(tz390.dir_cur);
		main_title = "z390 " + tz390.version;

		// Set runtime cancel hooks
		set_runtime_hooks();

		// Invoke graphical user interface
		main_frame = new JFrame();
		title_update();
		set_main_frame_icon();

		tz390.get_window_size(); // RPI 630
		main_frame.setSize(main_width,main_height);
		main_frame.setLocation(main_loc_x,main_loc_y);
		main_frame.addComponentListener(this);
		build_main_panel();
		open_log_file();
		monitor_startup();
		if (startup_cmd_file != null) {
			try {
				final BufferedReader temp_file = new BufferedReader(new FileReader(startup_cmd_file));
				String temp_line = temp_file.readLine();
				while (!tz390.z390_abort && temp_line != null) {
					process_command(temp_line);
					temp_line = temp_file.readLine();
				}
				temp_file.close();
			} catch (final Exception e) {
				log_error(72, "Startup file I/O error - " + e.toString());
			}
		}
		cmdHistory.reset(); // cmd_history[0] = "";
		main_frame.setVisible(true);
		z390_cmd_line.requestFocus();
	}
	
	/**
	 * Set main frame icon using PNG resource.
	 * If not possible, use the standard image (no change).
	 */
	private void set_main_frame_icon()
	{
		final java.net.URL imgURL = z390.class.getResource("z390.32x32-ico.png");
		if (imgURL != null) {
			final ImageIcon icon = new ImageIcon(imgURL);
			main_frame.setIconImage(icon.getImage());
		}
	}

	/**
	 *  Build the main panel with:<br>
	 *    a) Scrolling log display<br>
	 *    b) Command entry field
	 */
	private void build_main_panel()
	{
		main_panel = new JPanel();
		main_panel.setBorder(BorderFactory.createEmptyBorder(0,main_border,main_border,main_border));
		main_panel.setLayout(new FlowLayout(FlowLayout.LEFT)); 
		build_menu_items();
		set_tooltips();
		build_log_view();
		build_z390_cmd_line();
		build_status_line();
		set_text_font();
		menuBar.add(file_menu);
		menuBar.add(edit_menu);
		menuBar.add(option_menu);
		menuBar.add(view_menu);
		menuBar.add(help_menu);
		main_frame.setJMenuBar(menuBar);
		main_panel.add(log_view);
		main_panel.add(cmd_label);
		main_panel.add(z390_cmd_line);
		main_panel.add(status_label);
		main_panel.add(status_line);
		main_frame.getContentPane().add(main_panel);
		main_frame.addWindowListener(new WindowAdapter() {
			public void windowClosing(final WindowEvent e) {
				exit_main(0);
			}
		});
		update_main_view();
	}

	/**
	 * 
	 * @param rc
	 */
	private void exit_main(final int rc)
	{
		close_all_files();
		shut_down(rc);
	}

	/**
	 * Build scrolling log view based on current screen and font size.
	 */
	private void build_log_view()
	{
		log_text = new JTextArea();
		log_text.addMouseListener(this);
		log_view = new JScrollPane(log_text);
		log_view.getVerticalScrollBar().addAdjustmentListener(new AdjustmentListener() {
			public void adjustmentValueChanged(final AdjustmentEvent e) {
				if (tz390.log_text_added) {
					tz390.log_text_added = false;
					log_view.getVerticalScrollBar().setValue(log_view.getVerticalScrollBar().getMaximum());
				}
			}});
		log_view.setVerticalScrollBarPolicy(JScrollPane.VERTICAL_SCROLLBAR_ALWAYS);
	}

	/**
	 * Build the command entry field.
	 */
	private void build_z390_cmd_line()
	{
		cmd_label = new JLabel("Command: ");
		z390_cmd_line = new JTextField(command_columns);
		z390_cmd_line.addActionListener(this);
		z390_cmd_line.addMouseListener(this);
		z390_cmd_line.addKeyListener(this);
		z390_cmd_line.addFocusListener(this);
	}

	/**
	 * Build the status line.
	 */
	private void build_status_line()
	{
		status_label = new JLabel(" Status: ");
		status_line  = new JTextField(command_columns);
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
			file_menu_cd         = new JMenuItem("CD..");
			file_menu_edit       = new JMenuItem("EDIT..");
			file_menu_mac        = new JMenuItem("MAC..");
			file_menu_asm        = new JMenuItem("ASM..");
			file_menu_asml       = new JMenuItem("ASML..");
			file_menu_asmlg      = new JMenuItem("ASMLG..");
			file_menu_job        = new JMenuItem("JOB..");
			file_menu_link       = new JMenuItem("LINK..");
			file_menu_exec       = new JMenuItem("EXEC..");
			file_menu_exit       = new JMenuItem("Exit");
		edit_menu                = new JMenu("Edit");
			edit_menu_cut        = new JMenuItem("Cut");
			edit_menu_copy       = new JMenuItem("Copy");
			edit_menu_paste      = new JMenuItem("Paste");
			edit_menu_select_log = new JMenuItem("Select Log"); // RPI 1041
			edit_menu_select_cmd = new JMenuItem("Select Cmd"); // RPI 1041
			edit_menu_copy_log   = new JMenuItem("Copy Log");
			edit_menu_editor     = new JMenuItem("Editor");
		option_menu              = new JMenu("Options");
			option_menu_ascii    = new JCheckBoxMenuItem("ASCII");
			option_menu_con      = new JCheckBoxMenuItem("CON");
			option_menu_con.setSelected(true);
			option_menu_dump     = new JCheckBoxMenuItem("DUMP");
			option_menu_guam     = new JCheckBoxMenuItem("GUAM");
			option_menu_list     = new JCheckBoxMenuItem("LIST");
			option_menu_list.setSelected(true);
			option_menu_listcall = new JCheckBoxMenuItem("LISTCALL");
			option_menu_listcall.setSelected(true);
			option_menu_stats    = new JCheckBoxMenuItem("STATS");
			option_menu_stats.setSelected(true);
			option_menu_amode31  = new JCheckBoxMenuItem("AMODE31");
			option_menu_amode31.setSelected(true);
			option_menu_rmode31  = new JCheckBoxMenuItem("RMODE31");
			option_menu_test     = new JCheckBoxMenuItem("TEST");
			option_menu_trace    = new JCheckBoxMenuItem("TRACE");
		view_menu                = new JMenu("View");
			view_menu_status     = new JCheckBoxMenuItem("Status");
			view_menu_status.setSelected(true);
			view_menu_cmd        = new JCheckBoxMenuItem("CMD Mode");
		help_menu                = new JMenu("Help");
			help_menu_help       = new JMenuItem("Help");
			help_menu_commands   = new JMenuItem("Commands");
			help_menu_guide      = new JMenuItem("Guide");
			help_menu_perm       = new JMenuItem("Permissions");
			help_menu_releases   = new JMenuItem("Releases");
			help_menu_support    = new JMenuItem("Support");
			help_menu_about      = new JMenuItem("About");

		// Mnemonic menu bar keys
		file_menu.setMnemonic(               KeyEvent.VK_F);
			file_menu_cd.setMnemonic(        KeyEvent.VK_C);
			file_menu_edit.setMnemonic(      KeyEvent.VK_D);
			file_menu_mac.setMnemonic(       KeyEvent.VK_M);
			file_menu_asm.setMnemonic(       KeyEvent.VK_A);
			file_menu_asml.setMnemonic(      KeyEvent.VK_S);
			file_menu_asmlg.setMnemonic(     KeyEvent.VK_G);
			file_menu_job.setMnemonic(       KeyEvent.VK_J);
			file_menu_link.setMnemonic(      KeyEvent.VK_L);
			file_menu_exec.setMnemonic(      KeyEvent.VK_E);
			file_menu_exit.setMnemonic(      KeyEvent.VK_X);
		edit_menu.setMnemonic(               KeyEvent.VK_E);
			edit_menu_cut.setMnemonic(       KeyEvent.VK_T);
			edit_menu_copy.setMnemonic(      KeyEvent.VK_C);
			edit_menu_paste.setMnemonic(     KeyEvent.VK_P);
			edit_menu_select_log.setMnemonic(KeyEvent.VK_S);
			edit_menu_select_cmd.setMnemonic(KeyEvent.VK_M);
			edit_menu_copy_log.setMnemonic(  KeyEvent.VK_L);
			edit_menu_editor.setMnemonic(    KeyEvent.VK_N);
		//tion_menu.setMnemonic(             KeyEvent.VK_ );
			option_menu_ascii.setMnemonic(   KeyEvent.VK_I);
			option_menu_con.setMnemonic(     KeyEvent.VK_C);
			option_menu_dump.setMnemonic(    KeyEvent.VK_D);
			option_menu_guam.setMnemonic(    KeyEvent.VK_G);
			option_menu_list.setMnemonic(    KeyEvent.VK_L);
			option_menu_listcall.setMnemonic(KeyEvent.VK_I);
			option_menu_stats.setMnemonic(   KeyEvent.VK_S);
			option_menu_amode31.setMnemonic( KeyEvent.VK_A);
			option_menu_rmode31.setMnemonic( KeyEvent.VK_R);
			option_menu_trace.setMnemonic(   KeyEvent.VK_E);
			option_menu_test.setMnemonic(    KeyEvent.VK_T);
		view_menu.setMnemonic(               KeyEvent.VK_V);
			view_menu_status.setMnemonic(    KeyEvent.VK_S);
			view_menu_cmd.setMnemonic(       KeyEvent.VK_C);
		help_menu.setMnemonic(               KeyEvent.VK_H);
			help_menu_help.setMnemonic(      KeyEvent.VK_H);
			help_menu_commands.setMnemonic(  KeyEvent.VK_C);
			help_menu_guide.setMnemonic(     KeyEvent.VK_G);
			help_menu_perm.setMnemonic(      KeyEvent.VK_P);
			help_menu_releases.setMnemonic(  KeyEvent.VK_R);
			help_menu_support.setMnemonic(   KeyEvent.VK_S);
			help_menu_about.setMnemonic(     KeyEvent.VK_A);

		// Set menu bar accelerator keys
		file_menu_cd.setAccelerator(      KeyStroke.getKeyStroke(KeyEvent.VK_D,ActionEvent.CTRL_MASK));
		file_menu_edit.setAccelerator(    KeyStroke.getKeyStroke(KeyEvent.VK_I,ActionEvent.CTRL_MASK));
		file_menu_mac.setAccelerator(     KeyStroke.getKeyStroke(KeyEvent.VK_M,ActionEvent.CTRL_MASK));
		file_menu_asm.setAccelerator(     KeyStroke.getKeyStroke(KeyEvent.VK_A,ActionEvent.CTRL_MASK));
		file_menu_asml.setAccelerator(    KeyStroke.getKeyStroke(KeyEvent.VK_S,ActionEvent.CTRL_MASK));
		file_menu_asmlg.setAccelerator(   KeyStroke.getKeyStroke(KeyEvent.VK_G,ActionEvent.CTRL_MASK));
		file_menu_job.setAccelerator(     KeyStroke.getKeyStroke(KeyEvent.VK_J,ActionEvent.CTRL_MASK));
		file_menu_link.setAccelerator(    KeyStroke.getKeyStroke(KeyEvent.VK_L,ActionEvent.CTRL_MASK));
		file_menu_exec.setAccelerator(    KeyStroke.getKeyStroke(KeyEvent.VK_X,ActionEvent.CTRL_MASK));
		file_menu_exit.setAccelerator(    KeyStroke.getKeyStroke(KeyEvent.VK_Z,ActionEvent.CTRL_MASK));
		edit_menu_cut.setAccelerator(     KeyStroke.getKeyStroke(KeyEvent.VK_E,ActionEvent.CTRL_MASK));
		edit_menu_copy.setAccelerator(    KeyStroke.getKeyStroke(KeyEvent.VK_C,ActionEvent.CTRL_MASK));
		edit_menu_paste.setAccelerator(   KeyStroke.getKeyStroke(KeyEvent.VK_V,ActionEvent.CTRL_MASK));
		edit_menu_editor.setAccelerator(  KeyStroke.getKeyStroke(KeyEvent.VK_N,ActionEvent.CTRL_MASK));
		view_menu_status.setAccelerator(  KeyStroke.getKeyStroke(KeyEvent.VK_S,ActionEvent.CTRL_MASK+ActionEvent.SHIFT_MASK));
		view_menu_cmd.setAccelerator(     KeyStroke.getKeyStroke(KeyEvent.VK_C,ActionEvent.CTRL_MASK+ActionEvent.SHIFT_MASK));
		help_menu_help.setAccelerator(    KeyStroke.getKeyStroke(KeyEvent.VK_H,ActionEvent.CTRL_MASK+ActionEvent.ALT_MASK));
		help_menu_commands.setAccelerator(KeyStroke.getKeyStroke(KeyEvent.VK_C,ActionEvent.CTRL_MASK+ActionEvent.ALT_MASK));
		help_menu_guide.setAccelerator(   KeyStroke.getKeyStroke(KeyEvent.VK_G,ActionEvent.CTRL_MASK+ActionEvent.ALT_MASK));
		help_menu_perm.setAccelerator(    KeyStroke.getKeyStroke(KeyEvent.VK_P,ActionEvent.CTRL_MASK+ActionEvent.ALT_MASK));
		help_menu_releases.setAccelerator(KeyStroke.getKeyStroke(KeyEvent.VK_R,ActionEvent.CTRL_MASK+ActionEvent.ALT_MASK));
		help_menu_support.setAccelerator( KeyStroke.getKeyStroke(KeyEvent.VK_O,ActionEvent.CTRL_MASK+ActionEvent.ALT_MASK));    
		help_menu_about.setAccelerator(   KeyStroke.getKeyStroke(KeyEvent.VK_A,ActionEvent.CTRL_MASK+ActionEvent.ALT_MASK));

		// Add menu action listeners
		file_menu_cd.addActionListener(this);
		file_menu_edit.addActionListener(this);
		file_menu_mac.addActionListener(this);
		file_menu_asm.addActionListener(this);
		file_menu_asml.addActionListener(this);
		file_menu_asmlg.addActionListener(this);
		file_menu_job.addActionListener(this);
		file_menu_link.addActionListener(this);
		file_menu_exec.addActionListener(this);
		file_menu_exit.addActionListener(this);
		edit_menu_cut.addActionListener(this);
		edit_menu_copy.addActionListener(this);
		edit_menu_paste.addActionListener(this);
		edit_menu_select_log.addActionListener(this);
		edit_menu_select_cmd.addActionListener(this);
		edit_menu_copy_log.addActionListener(this);
		edit_menu_editor.addActionListener(this);
		option_menu_ascii.addActionListener(this);
		option_menu_con.addActionListener(this);
		option_menu_dump.addActionListener(this);
		option_menu_guam.addActionListener(this);
		option_menu_list.addActionListener(this);
		option_menu_listcall.addActionListener(this);
		option_menu_stats.addActionListener(this);
		option_menu_amode31.addActionListener(this);
		option_menu_rmode31.addActionListener(this);
		option_menu_trace.addActionListener(this);
		option_menu_test.addActionListener(this);
		view_menu_status.addActionListener(this);
		view_menu_cmd.addActionListener(this);
		help_menu_help.addActionListener(this);
		help_menu_commands.addActionListener(this);
		help_menu_guide.addActionListener(this);
		help_menu_perm.addActionListener(this);
		help_menu_releases.addActionListener(this);
		help_menu_support.addActionListener(this);
		help_menu_about.addActionListener(this);

		file_menu.add(file_menu_cd);
		file_menu.add(file_menu_edit);
		file_menu.add(file_menu_mac);
		file_menu.add(file_menu_asm); 
		file_menu.add(file_menu_asml);
		file_menu.add(file_menu_asmlg);
		file_menu.add(file_menu_job);
		file_menu.add(file_menu_link); 
		file_menu.add(file_menu_exec);
		file_menu.add(file_menu_exit); 
		edit_menu.add(edit_menu_cut);
		edit_menu.add(edit_menu_copy);
		edit_menu.add(edit_menu_paste);
		edit_menu.add(edit_menu_select_log);
		edit_menu.add(edit_menu_select_cmd);
		edit_menu.add(edit_menu_copy_log);
		edit_menu.add(edit_menu_editor);
		option_menu.add(option_menu_ascii);
		option_menu.add(option_menu_con);
		option_menu.add(option_menu_dump);
		option_menu.add(option_menu_guam);
		option_menu.add(option_menu_list);
		option_menu.add(option_menu_listcall);
		option_menu.add(option_menu_stats);
		option_menu.add(option_menu_amode31);
		option_menu.add(option_menu_rmode31);
		option_menu.add(option_menu_trace);
		option_menu.add(option_menu_test);
		view_menu.add(view_menu_status);
		view_menu.add(view_menu_cmd);
		help_menu.add(help_menu_help);
		help_menu.add(help_menu_commands);
		help_menu.add(help_menu_guide);
		help_menu.add(help_menu_perm);
		help_menu.add(help_menu_releases);
		help_menu.add(help_menu_support);
		help_menu.add(help_menu_about);
	}

	/**
	 * Set tool tips after font changes.
	 */
	private void set_tooltips()
	{
		final String text_font_pfx = "<html><font size=" + font_size/3 + ">";
		final String text_font_sfx = "</html>";

		file_menu_cd.setToolTipText(text_font_pfx + "CD change directory" + text_font_sfx);
		file_menu_edit.setToolTipText(text_font_pfx + "Edit source file" + text_font_sfx);
		file_menu_mac.setToolTipText(text_font_pfx + "MAC macro expand (MLC > BAL)" + text_font_sfx);
		file_menu_asm.setToolTipText(text_font_pfx + "ASM macro assemble (MLC > BAL > OBJ)" + text_font_sfx);
		file_menu_asml.setToolTipText(text_font_pfx + "ASML macro assemble and link (MLC > BAL > OBJ > 390" + text_font_sfx);
		file_menu_asmlg.setToolTipText(text_font_pfx + "ASMLG macro assemble, link, and exec 390" + text_font_sfx);
		file_menu_job.setToolTipText(text_font_pfx + "JOB execute selected batch job file BAT" + text_font_sfx);
		file_menu_link.setToolTipText(text_font_pfx + "LINK link object files into load module (OBJ > 390)" + text_font_sfx);
		file_menu_exec.setToolTipText(text_font_pfx + "EXEC execute 390 load module" + text_font_sfx);
		file_menu_exit.setToolTipText(text_font_pfx + "Exit z390 GUI" + text_font_sfx);
		edit_menu_cut.setToolTipText(text_font_pfx + "Cut selected text" + text_font_sfx);
		edit_menu_copy.setToolTipText(text_font_pfx + "Copy selected text to clipboard" + text_font_sfx);
		edit_menu_paste.setToolTipText(text_font_pfx + "Paste clipboard text (append if log has focus" + text_font_sfx);
		edit_menu_select_log.setToolTipText(text_font_pfx + "Select all log text" + text_font_sfx);
		edit_menu_select_cmd.setToolTipText(text_font_pfx + "Select all cmd text" + text_font_sfx);
		edit_menu_copy_log.setToolTipText(text_font_pfx + "Copy current log file to clipboard" + text_font_sfx);
		edit_menu_editor.setToolTipText(text_font_pfx + "Launch editor to edit selected data on clipboard" + text_font_sfx);
		option_menu_ascii.setToolTipText(text_font_pfx + "ASCII use ASCII versus EBCDIC for character set" + text_font_sfx);
		option_menu_con.setToolTipText(text_font_pfx + "CON List statistics and log output on console" + text_font_sfx);
		option_menu_dump.setToolTipText(text_font_pfx + "DUMP generate full dump on abnormal termination" + text_font_sfx);
		option_menu_guam.setToolTipText(text_font_pfx + "Open GUAM Graphical User Access Method dialog for MCS, TN3270, and GKS graphics");
		option_menu_list.setToolTipText(text_font_pfx + "LIST generate PRN, LST, and/or LOG output files" + text_font_sfx);
		option_menu_listcall.setToolTipText(text_font_pfx + "LISTCALL trace each macro call and exit on BAL" + text_font_sfx);
		option_menu_stats.setToolTipText(text_font_pfx + "STATS generate statistics comments" + text_font_sfx);
		option_menu_amode31.setToolTipText(text_font_pfx + "AMODE31 link 390 with 31 bit addressing" + text_font_sfx);
		option_menu_rmode31.setToolTipText(text_font_pfx + "RMODE31 link 390 to load above 24 bit limit" + text_font_sfx);
		option_menu_trace.setToolTipText(text_font_pfx + "TRACE generate trace on BAL, PRN, LST, or LOG file" + text_font_sfx);
		option_menu_test.setToolTipText(text_font_pfx + "TEST prompt for interactive debug commands" + text_font_sfx);
		view_menu_status.setToolTipText(text_font_pfx + "Status line view or hide to save space" + text_font_sfx);
		view_menu_cmd.setToolTipText(text_font_pfx + "Windows batch command input Mode" + text_font_sfx);
		help_menu_help.setToolTipText(text_font_pfx + "Display summary of basic commands" + text_font_sfx);
		help_menu_commands.setToolTipText(text_font_pfx + "Display alphabetical list of all commands" + text_font_sfx);
		help_menu_guide.setToolTipText(text_font_pfx + "Link to online or local docs (if installed)" + text_font_sfx);
		help_menu_perm.setToolTipText(text_font_pfx + "Display Java security manager permissions" + text_font_sfx);
		help_menu_releases.setToolTipText(text_font_pfx + "Display OS, Java, and z390 verions" + text_font_sfx);
		help_menu_support.setToolTipText(text_font_pfx + "Link to www.z390.org online support" + text_font_sfx);
		help_menu_about.setToolTipText(text_font_pfx + "Display information about this version of z390" + text_font_sfx);
	}
	
	/**
	 * Update main frame title with current date and time.
	 */
	private void title_update()
	{
		final Date curDate = new Date();
		final StringBuilder sb = new StringBuilder();
		sb.append(main_title).append("   ").append(mmddyy.format(curDate)).append(" ").append(hhmmss.format(curDate));
		main_frame.setTitle(sb.toString());
	}

	/**
	 * Perform menu and command line requests.
	 */
	public void actionPerformed(final ActionEvent event)
	{
		final String event_name = event.getActionCommand().toUpperCase();
		if (z390_cmd_line.hasFocus()) {
			if (cmd_mode) {
				if (cmd_exec_rc() == -1) {
					final String cmd_line = z390_cmd_line.getText();
					cmdHistory.add_cmd_hist(cmd_line);
					put_log("CMD input:" + cmd_line);
					reset_z390_cmd();
					cmd_exec_input(cmd_line);
				} else {
					put_log("CMD mode has ended.");
					cmd_mode = false;
					if (main_gui) {
						view_menu_cmd.setSelected(false);
					}
				}
				reset_z390_cmd();
			} else {
				final String cmd_line = z390_cmd_line.getText();
				if  (  cmd_line != null
					&& cmd_line.length() > 0) {
					exec_gui_command();
					reset_z390_cmd();
				}
			}
			return;
		}

		boolean event_ok = false;
		final char first_char = event_name.charAt(0);
		switch (first_char) {
		case 'A':
			if (event_name.equals("ABOUT")) {
				z390_cmd_line.setText("ABOUT");
			} else
			if (event_name.equals("AMODE31")) {
				z390_cmd_line.setText(tz390.opt_amode31 ? "AMODE31 OFF" : "AMODE31 ON");
			} else
			if (event_name.equals("ASCII")) {
				z390_cmd_line.setText(tz390.opt_ascii ? "ASCII OFF" : "ASCII ON");
			} else
			if (event_name.equals("ASM..")) {
				batch_cmd("ASM","","MLC",asm_opt);
			} else
			if (event_name.equals("ASML..")) {
				batch_cmd("ASML","","MLC",asml_opt);
			} else
			if (event_name.equals("ASMLG..")) {
				batch_cmd("ASMLG","","MLC",asmlg_opt);
			}
			break;
		//case 'B':
		//	break;
		case 'C':	
			if (event_name.equals("CD..")) {
				put_log("CD change current directory");
				z390_cmd_line.setText("CD");
			} else
			if (event_name.equals("CMD MODE")) {
				if (cmd_mode) {
					event_ok = true;
					put_log("CMD mode off");
					cmd_exec_cancel();
				} else {
					z390_cmd_line.setText("CMD");
				}
			} else
			if (event_name.equals("COMMANDS")) {
				z390_cmd_line.setText("COMMANDS");
			} else
			if (event_name.equals("CON")) {
				z390_cmd_line.setText(tz390.opt_con ? "CON OFF" : "CON ON");
			} else
			if (event_name.equals("COPY")) {
				event_ok = true;
				if (log_text == focus_comp) {
					log_text.copy();
				}
				if (z390_cmd_line ==  focus_comp) {
					z390_cmd_line.copy();
				}
			} else
			if (event_name.equals("COPY LOG")) {
				event_ok = true;
				z390_cmd_line.setText("COPYLOG");
			} else
			if (event_name.equals("CUT")) {
				event_ok = true;
				if  (z390_cmd_line ==  focus_comp) {
					z390_cmd_line.cut();
				}
			}
			break;
		case 'D':
			if (event_name.equals("DUMP")) {
				z390_cmd_line.setText(tz390.opt_dump ? "DUMP OFF" : "DUMP ON");
			}
			break;
		case 'E':
			if (event_name.toUpperCase().equals("EDIT..")) {
				batch_cmd("EDIT","","","");
			} else
			if (event_name.toUpperCase().equals("EDITOR")) {
				if ( perms.mayExecFiles() ) {
					//if (!main_batch) {
					if (!tz390.exec_cmd(infoOS.get_z390_editor())) {
						log_error(16, "Editor not found - " + infoOS.get_z390_editor());
					}
					//} else {
					//	log_error(54, "Interactive editor not supported in batch.");
					//}
				} else {
					log_error(17, "Permission for file execute denied.");
				}
			} else
			if (event_name.equals("EXEC..")) {
				batch_cmd("EXEC","","390",exec_opt);
				break;
			} else
			if (event_name.equals("EXIT")) {
				event_ok = true;
				exit_command();
			}
			break;
		case 'G':
			if (event_name.equals("GUAM")) {
				z390_cmd_line.setText(tz390.opt_guam ? "GUAM OFF" : "GUAM ON");
			} else
			if (event_name.equals("GUIDE")) {
				z390_cmd_line.setText("GUIDE");
			}
			break;
		case 'H':
			if (event_name.equals("HELP")) {
				z390_cmd_line.setText("HELP");
			}
			break;
		case 'J':
			if (event_name.equals("JOB..")) {
				batch_cmd("JOB","","BAT",job_opt);
			}
			break;
		case 'L':
			if (event_name.equals("LINK..")) {
				batch_cmd("LINK","","OBJ",link_opt);
			} else
			if (event_name.equals("LIST")) {
				z390_cmd_line.setText(tz390.opt_list ? "LIST OFF" : "LIST ON");
			} else
			if (event_name.equals("LISTCALL")) {
				z390_cmd_line.setText(tz390.opt_listcall ? "LISTCALL OFF" : "LISTCALL ON");
			}
			break;
		case 'M':
			if (event_name.equals("MAC..")) {
				batch_cmd("MAC","","MLC",mac_opt);
			}
			break;
		//case 'O':
		//	break;
		case 'P':
			if (event_name.equals("PASTE")) {
				event_ok = true;
				if (log_text == focus_comp) {
					z390_cmd_line.setText("PASTE");
				}
				if (z390_cmd_line ==  focus_comp) {
					z390_cmd_line.paste();
				}
			} else
			if (event_name.equals("PERMISSIONS")) {
				z390_cmd_line.setText("PERM");
			}
			break;
		case 'R':
			if (event_name.equals("RELEASES")) {
				z390_cmd_line.setText("REL");
			} else
			if (event_name.equals("RMODE31")) {
				z390_cmd_line.setText(tz390.opt_rmode31  ? "RMODE31 OFF" : "RMODE31 ON");
			}
			break;
		case 'S':
			if (event_name.equals("SELECT LOG")) {
				event_ok = true;
				log_text.requestFocus();
				log_text.selectAll(); 
			} else
			if (event_name.equals("SELECT CMD")) {
				event_ok = true; 
				z390_cmd_line.requestFocus();
				z390_cmd_line.selectAll();
			} else
			if (event_name.equals("STATS")) {
				z390_cmd_line.setText(tz390.opt_stats ? "STATS OFF" : "STATS ON");
			} else
			if (event_name.equals("STATUS")) {
				z390_cmd_line.setText(main_status ? "STATUS OFF" : "STATUS ON");
			} else
			if (event_name.equals("SUPPORT")) {
				z390_cmd_line.setText("SUPPORT");
			}
			break;
		case 'T':
			if (event_name.equals("TEST")) {
				z390_cmd_line.setText(tz390.opt_test ? "TEST OFF" : "TEST ON");
			} else
			if (event_name.equals("TRACE")) {
				z390_cmd_line.setText(tz390.opt_trace ? "TRACE OFF" : "TRACE ON");
			}
			break;
		//case 'V': 
		//	break;
		}

		//  If event_ok not set, execute command from JTextField
		if (!event_ok) {
			exec_gui_command();
		}
	}

	/**
	 * Execute GUI command
	 */
	private void exec_gui_command()
	{
		String cmd_line = z390_cmd_line.getText();

		if (cmd_line == null || cmd_line.length() == 0) {
			cmd_line = " ";
		}

		reset_z390_cmd();

		if (cmd_running) {
			process_command("CMD " + cmd_line);
		} else {
			process_command(cmd_line);
		}
	}

	/**
	 * Display Java security access permissions.
	 */
	private void perm_command()
	{
		if ( perms.getAllowChecks() ) {
			put_log("Java Security Manager Permissions - see Java PropertyTool Settings");
		} else {
			log_error(40, "Java Permissions denied due to z390 /NP command option");
		}
		if ( perms.isUserDirOK() ) {
			put_log("  Property Permissions - user directory access - ok");
		} else {
			put_log("  Property Permissions - user directory access - denied");
		}
		if ( perms.isRuntimeThread() ) {
			put_log("  Runtime Permissions - thread modify for popups - ok");
		} else {
			put_log("  Runtime Permissions - thread modify for popups - denied");
		}
		if ( perms.mayExecFiles() ) {
			put_log("  File Permissions - execute for browser/edit - ok");
		} else {
			put_log("  File Permissions - execute for browser/edit - denied");
		}
		if ( perms.mayReadFiles() ) {
			put_log("  File Permissions - read - ok");
		} else {
			put_log("  File Permissions - read - denied");
		}
		if (perms.mayWriteFiles() ) {
			put_log("  File Permissions - write - ok");
		} else {
			put_log("  File Permissions - write - denied");
		}
	}

	/**
	 * Display Windows, Java Runtime, and z390 software releases led.
	 */
	private void rel_command()
	{
		String temp_version;
		try {
			temp_version = System.getProperty("os.name") + " " + System.getProperty("os.version");
			put_log("System version = " + temp_version);
		} catch (final Exception e) {
			put_log("System Version Permission denied.");
		}
		try {
			temp_version = System.getProperty("java.vendor") + " " + System.getProperty("java.version");
			put_log("Java Version = " + temp_version);
		} catch (final Exception e) {
			put_log("Java Version Permission denied.");
		}
		put_log("Z390I Version = " + tz390.version);
	}

	/**
	 * Link to z390\webdoc\index.html or www.z390.org
	 * Note: Start parameters are /d"path" file.
	 */
	private void guide_command()
	{
		if (install_webdoc == null) {
			start_doc(web_site); // RPI 872
		} else {
			start_doc(install_webdoc); // RPI 872
		}
	}

	/*
	 * Reset z390_cmd text and set focus.
	 */
	private void reset_z390_cmd()
	{
		if (main_gui) {
			z390_cmd_line.setText("");
			z390_cmd_line.requestFocus();
		}
	}

	/**
	 * Link to online support www.z390.org
	 */
	private void support_command()
	{
		start_doc(web_site);
	}

	/**
	 * 
	 * @param url
	 * @return
	 */
	public boolean start_doc(final String url)
	{
		if  (tz390.exec_cmd(infoOS.get_z390_browser() + " " + url)) {
			put_log("Start issued for " + url);
			return true;
		} else {
			log_error(41, "Start error for " + url);
			return false;
		}
	}

	/**
	 * Get string text from system clip-board.
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
	 * Put string to system clip-board.
	 * @param str
	 */
	public static void setClipboard(final String str)
	{
		final StringSelection ss = new StringSelection(str);
		Toolkit.getDefaultToolkit().getSystemClipboard().setContents(ss, null);
	}

	/**
	 * Handle key pressed events.
	 */
	public void keyPressed(final KeyEvent e)
	{
		// displayInfo(e, "KEY PRESSED: "); //dsh
		final int keyCode = e.getKeyCode();
		if (e.isActionKey()) {
			switch (keyCode) {
			case KeyEvent.VK_UP:
				z390_cmd_line.setText(cmdHistory.get_prev_cmd()); // get_prev_cmd();
				break;
			case KeyEvent.VK_DOWN:
				z390_cmd_line.setText(cmdHistory.get_next_cmd()); // get_next_cmd();
				break;
			case KeyEvent.VK_F1: // F1 help
				process_command("HELP");
				break;
			case KeyEvent.VK_F3: // F3 exit
				process_cancel_key();
				break;
			case KeyEvent.VK_F10: // Consume to prevent Windows pop-up of file menu
				e.consume();
				break;
			}
		} else {  // not an action key
			if (keyCode == KeyEvent.VK_CANCEL) {
				process_cancel_key();
			}
		}
	}

	/**
	 * Cancel command, or GUI command in response to F3 or CTRL-BREAK.
	 */
	private void process_cancel_key()
	{
		if  (cmd_exec_rc() == -1) {
			if (!cmd_mode) {
				log_error(70, "Previous command execution cancelled.");
				cmd_exec_cancel();
			} else {
				put_log("CMD mode cancelled.");
				cmd_exec_cancel();
			}
		} else {
			abort_error(78,"Aborting due to external shutdown request.");
			exit_main(16);
		}
	}

	/**
	 * Handle key typed events...
	 * 
	 * Collect any characters for accept which are placed in z390_cmd_line
	 * by accept wait loop if not there already.
	 * First accept they are there, but following ones not?  Hooky fix!
	 */
	public void keyTyped(final KeyEvent e)
	{
		// displayInfo(e, "KEY TYPED: "); //dsh 
	}

	/**
	 * Handle key released events.
	 */
	public void keyReleased(final KeyEvent e)
	{
		// displayInfo(e, "KEY RELEASED: "); //dsh 
	}

	/**
	 * 
	 * @param e
	 * @param s
	 */
	protected void displayInfo(final KeyEvent e, final String s)
	{
		String keyString;

		// You should only rely on the key char if the event is a key typed event.
		final int id = e.getID();
		if (id == KeyEvent.KEY_TYPED) {
			final char c = e.getKeyChar();
			keyString = "key character = '" + c + "'";
		} else {
			final int keyCode = e.getKeyCode();
			keyString = "key code = " + keyCode + " (" + KeyEvent.getKeyText(keyCode) + ")";
		}

		final int modifiers = e.getModifiersEx();
		final String tmpString = KeyEvent.getModifiersExText(modifiers);
		String modString = "modifiers = " + modifiers;
		if (tmpString.length() > 0) {
			modString += " (" + tmpString + ")";
		} else {
			modString += " (no modifiers)";
		}

		String actionString = "action key? ";
		actionString += e.isActionKey() ? "YES" : "NO";

		String locationString = "key location: ";
		final int location = e.getKeyLocation();
		switch(location) {
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
		default: // (location == KeyEvent.KEY_LOCATION_UNKNOWN)
			locationString += "unknown";
			break;
		}
		final String newline = "\n";
		System.out.println(s + newline
					+ "    " + keyString + newline
					+ "    " + modString + newline
					+ "    " + actionString + newline
					+ "    " + locationString + newline);
	}

	/**
	 * Pop-up edit menu on right mouse click.
	 */
	public void mousePressed(final MouseEvent e)
	{
//		check_main_view();
		if (e.getButton() == MouseEvent.BUTTON3) {
			if (popup_edit_menu == null) {
				popup_edit_menu = new JPopupMenu();
				final JMenuItem popup_edit_menu_cut        = new JMenuItem("Cut");
				final JMenuItem popup_edit_menu_copy       = new JMenuItem("Copy");
				final JMenuItem popup_edit_menu_paste      = new JMenuItem("Paste");
				final JMenuItem popup_edit_menu_select_all = new JMenuItem("Select All");
				final JMenuItem popup_edit_menu_copy_log   = new JMenuItem("Copy Log");
				final JMenuItem popup_edit_menu_editor     = new JMenuItem("Edit..");
				popup_edit_menu.add(popup_edit_menu_cut);
				popup_edit_menu.add(popup_edit_menu_copy);
				popup_edit_menu.add(popup_edit_menu_paste);
				popup_edit_menu.add(popup_edit_menu_select_all);
				popup_edit_menu.add(popup_edit_menu_copy_log);
				popup_edit_menu.add(popup_edit_menu_editor);
				popup_edit_menu_cut.addActionListener(this);
				popup_edit_menu_copy.addActionListener(this);
				popup_edit_menu_paste.addActionListener(this);
				popup_edit_menu_select_all.addActionListener(this);
				popup_edit_menu_copy_log.addActionListener(this);
				popup_edit_menu_editor.addActionListener(this);
			}
			final Component mouse_comp = e.getComponent();
			if  (mouse_comp == log_text) {
				focus_comp = log_text; //force log focus for edit
			}
			popup_edit_menu.show(mouse_comp,e.getX(),e.getY());
		}
	}

	public void mouseReleased(final MouseEvent e) {}

	public void mouseEntered( final MouseEvent e) {}

	public void mouseExited(  final MouseEvent e) {}

	public void mouseClicked( final MouseEvent e) {}

	/**
	 * Last component to lose focus (ignored for now).
	 */
	public void focusLost(final FocusEvent e) {}

	/**
	 * Save last component to get focus.
	 */
	public void focusGained(final FocusEvent e)
	{
		final Component temp_comp = e.getComponent();
		if (temp_comp == z390_cmd_line) {
			focus_comp = temp_comp;
		} else {
			focus_comp = log_text;
		}
	}

	/**
	 * Abort command if running and turn off cmd_mode.<br>
	 * If no command running and not cmd_mode, then exit z390.
	 */
	private void exit_command()
	{
		if (!cmd_mode && cmd_exec_rc() != -1) {
			exit_main(0);
		} else {
			cmd_exec_cancel();
		}
	}

	/**
	 * Set location of main window x, y.
	 * @param cmd_parm1
	 * @param cmd_parm2
	 */
	private void loc_command(final String cmd_parm1, final String cmd_parm2)
	{
		if (main_gui && cmd_parm1 != null && cmd_parm2 != null) {
			int x = getDecimalInteger(cmd_parm1);
			int y = getDecimalInteger(cmd_parm2);
			if  (x < 0) {
				x = 0;
			} else {
				if (x + main_width > tz390.max_main_width) {
					if (x + tz390.min_main_width > tz390.max_main_width) {
						x = tz390.max_main_width - tz390.min_main_width;
						main_width = tz390.min_main_width;
					} else {
						main_width = tz390.max_main_width - x;
					}
				}
			}
			if  (y < 0) {
				y = 0;
			} else {
				if (y + main_height > tz390.max_main_height) {
					if  (y + tz390.min_main_height > tz390.max_main_height) {
						y = tz390.max_main_height - tz390.min_main_height;
						main_height = tz390.min_main_height;
					} else {
						main_height = tz390.max_main_height - y;
					}
				}
			}
			main_loc_x = x;
			main_loc_y = y;
			main_frame.setLocation(main_loc_x, main_loc_y);
			main_frame.setSize(main_width, main_height);
		} else {
			log_error(64, "Invalid window location.");
		}
	}

	/**
	 * Resize main window.
	 * @param cmd_parm1
	 * @param cmd_parm2
	 */
	private void size_command(final String cmd_parm1, final String cmd_parm2)
	{
		if (main_gui && cmd_parm1 != null && cmd_parm2 != null) {
			main_loc_x = (int) main_frame.getLocation().getX();
			main_loc_y = (int) main_frame.getLocation().getY();
			int x = getDecimalInteger(cmd_parm1);
			int y = getDecimalInteger(cmd_parm2);
			if (x < tz390.min_main_width) {
				x = tz390.min_main_width;
			} else
			if (x > tz390.max_main_width - main_loc_x) {
				x = tz390.max_main_width - main_loc_x;
			}
			if (y < tz390.min_main_height){
				y = tz390.min_main_height;
			} else
			if (y > tz390.max_main_height - main_loc_y) {
				y = tz390.max_main_height - main_loc_y;
			}
			main_width  = x;
			main_height = y;
			main_frame.setSize(main_width,main_height);
		} else {
			log_error(65, "Invalid window size request.");
		}
	}

	/**
	 * Set status line display on or off, or set interval for logging status.
	 * If seconds specified as 0 or null, logging status is turned off.
	 * @param cmd_parm1
	 * @param cmd_parm2
	 */
	private void status_command(final String cmd_parm1, final String cmd_parm2)
	{
		if (cmd_parm1 != null) {
			if (cmd_parm1.toUpperCase().equals("ON")) {
				if (!main_status) {
					main_status = true;
					view_menu_status.setSelected(true);
					if (labels_visible) {
						main_panel.add(status_label);
					}
					main_panel.add(status_line);
				}
			} else
			if (cmd_parm1.toUpperCase().equals("OFF")) {
				if  (main_status) {
					main_status = false;
					view_menu_status.setSelected(false);
					if (labels_visible) {
						main_panel.remove(status_label);
					}
					main_panel.remove(status_line);
				}
			} else {
				final int sec = getDecimalInteger(cmd_parm1);
				if ( sec >= 1) {
					put_log("Status logging interval set to " + sec + " seconds.");
					status_interval = sec * 1000;
				} else {
					put_log("Status logging turned off.");
					status_interval = 0;
				}
			}
			update_main_view();
		} else {
			log_error(50, "Missing immediate data parameter.");
		}
	}

	/**
	 * Set GUI window title.
	 * @param cmd_parm1
	 * @param cmd_parm2
	 */
	private void title_command(final String cmd_parm1, final String cmd_parm2)
	{
		if (main_gui && cmd_parm1 != null && cmd_parm1.length() >= 3) {
			main_title = cmd_parm1.substring(1,cmd_parm1.length()-1);
			title_update();
		}
	}

	/**
	 * Set timeout interval in seconds used to timeout commands when not in command mode.
	 * Default is 3 seconds.  Issue command with no argument to turn off timeout.
	 * Commands can be cancelled via BREAK.
	 * @param cmd_parm1
	 * @param cmd_parm2
	 */
	private void timeout_command(final String cmd_parm1, final String cmd_parm2)
	{
		int sec = 0;
		if  (cmd_parm1 != null) {
			sec = getDecimalInteger(cmd_parm1);
			monitor_timeout_limit = sec * 1000;
		}
		if  (monitor_timeout_limit <= 0) {
			monitor_timeout_limit = 0;
			put_log("Timeout monitor for CMD turned off.");
		} else {
			put_log("Timeout limit for CMD set to " + sec + " seconds.");
		}
	}

	/**
	 * Check or un-check option menu item and update option parameter lists for commands.
	 * @param option_men
	 * @param cmd_parm1
	 * @param cmd_parm2
	 * @return
	 */
	private boolean options_command(final JCheckBoxMenuItem option_men, final String cmd_parm1, final String cmd_parm2)
	{
		boolean option_flag = false;
		if (cmd_parm1.toUpperCase().equals("ON")) {
			option_flag = true;
			option_men.setSelected(true);
		} else {
			option_flag = false;
			option_men.setSelected(false);
		}
		mac_opt   = "";
		asm_opt   = "";
		asml_opt  = "";
		asmlg_opt = "";
		job_opt   = "";
		link_opt  = "";
		exec_opt  = "";
		if (option_menu_ascii.isSelected()) {  // do last to override trace setting NOCON
			mac_opt   += " ASCII";
			asm_opt   += " ASCII";
			asml_opt  += " ASCII";
			asmlg_opt += " ASCII";
			job_opt   += " ASCII";
			link_opt  += " ASCII";
			exec_opt  += " ASCII";
		}
		if (!option_menu_con.isSelected()) {  // do last to override trace setting NOCON
			mac_opt   += " NOCON";
			asm_opt   += " NOCON";
			asml_opt  += " NOCON";
			asmlg_opt += " NOCON";
			job_opt   += " NOCON";
			link_opt  += " NOCON";
			exec_opt  += " NOCON";
		}
		if (option_menu_dump.isSelected()) {  // do last to override trace setting NOCON
			asmlg_opt += " DUMP";
			job_opt   += " DUMP";
			exec_opt  += " DUMP";
		}
		if (option_menu_guam.isSelected()) {  // do last to override trace setting NOCON
			asmlg_opt += " GUAM";
			job_opt   += " GUAM";
			exec_opt  += " GUAM";
		}
		if (!option_menu_amode31.isSelected()) {
			asml_opt  += " NOAMODE31";
			asmlg_opt += " NOAMODE31";
			job_opt   += " NOAMODE31";
			link_opt  += " NOAMODE31";
		}
		if (!option_menu_list.isSelected()) {
			asm_opt   += " NOLIST";
			asml_opt  += " NOLIST";
			asmlg_opt += " NOLIST";
			job_opt   += " NOLIST";
			link_opt  += " NOLIST";
			exec_opt  += " NOLIST";
		}
		if (!option_menu_listcall.isSelected()) {
			mac_opt   += " NOLISTCALL";
			asm_opt   += " NOLISTCALL";
			asml_opt  += " NOLISTCALL";
			asmlg_opt += " NOLISTCALL";
			job_opt   += " NOLISTCALL";
		}
		if (option_menu_rmode31.isSelected()) {
			asml_opt  += " RMODE31";
			asmlg_opt += " RMODE31";
			job_opt   += " RMODE31";
			link_opt  += " RMODE31";
		}
		if (!option_menu_stats.isSelected()) {
			mac_opt   += " NOSTATS";
			asm_opt   += " NOSTATS";
			asml_opt  += " NOSTATS";
			asmlg_opt += " NOSTATS";
			job_opt   += " NOSTATS";
			link_opt  += " NOSTATS";
			exec_opt  += " NOSTATS";
		}
		if (option_menu_test.isSelected()) {
			asmlg_opt += " TEST";
			exec_opt  += " TEST";
			job_opt   += " TEST";
		}
		if (option_menu_trace.isSelected()) {
			mac_opt   += " TRACE";
			asm_opt   += " TRACE";
			asml_opt  += " TRACE";
			link_opt  += " TRACE";
			job_opt   += " TRACE";
			asmlg_opt += " TRACE";
			exec_opt  += " TRACE";

			if (option_menu_con.isSelected()) { // override trace setting NOCON
				mac_opt   += " CON";
				asm_opt   += " CON";
				asml_opt  += " CON";
				asmlg_opt += " CON";
				job_opt   += " CON";
				link_opt  += " CON";
				exec_opt  += " CON";
			}
		}
		return option_flag;
	}

	/**
	 * Set current directory using file chooser dialog if parm1 null else use path.
	 */
	private void cd_command(final String cmd_parm1)
	{
		if ( perms.isUserDirOK() ) {
			if (cmd_parm1 == null) {
				//if (!main_batch) {
				select_dir();
				//} else {
				//	log_error(22, "CD missing directory");
				//}
			} else {
				String new_dir = tz390.get_file_name(tz390.dir_cur, cmd_parm1, "");
				final File   new_dir_file = new File(new_dir);
				if (new_dir_file.isDirectory()) {
					try {
						// 2006-04-03 - RPI-0235 Correct CD path display and support cd.. etc.
						// 2006-11-29 - RPI-0508 Correct error 51 on /SC startup commands
						new_dir = new_dir_file.getCanonicalPath() + File.separator;
					} catch (final Exception e) {}
					tz390.dir_cur = new_dir; 
					dir_cur_file = new File(new_dir);
					System.setProperty("user.dir",tz390.dir_cur);
					if (cmd_mode) {
						sync_cmd_dir();
					}
					put_log("CD new current directory - " + System.getProperty("user.dir"));
				} else {
					log_error(37, "Directory not found - " + new_dir);
				}
			}
		} else {
			log_error(23,"Permission for CD change directory denied.");
		}
	}

	/**
	 * Invoke file chooser dialog to set dir_cur.
	 * (Note: Dialog is kept for non GUI mode to avoid dispose causing GUI shutdown on last window).
	 */
	private void select_dir()
	{
		if ( perms.maySelect() ) {
			final JFileChooser select_dir_chooser = new JFileChooser();
			// 2007-01-20 - RPI-0541 Correct Z390 GUI file selection dialog cancel action
			// Rebuild every time
			create_select_dir(select_dir_chooser);
		} else {
			log_error(38, "Permission for directory selection denied.");
		}
	}

	/**
	 * Create dialog with file chooser to select current directory.
	 * @param select_dir_chooser
	 */
	private void create_select_dir(final JFileChooser select_dir_chooser)
	{
		select_dir_frame = new JFrame(main_title + " Select Current Directory");
		select_dir_frame.addWindowListener(new WindowAdapter() {
			public void windowClosing(WindowEvent e) {
				select_dir_frame.setVisible(false);
				if (main_gui) {
					main_frame.setVisible(true);
				}
			}
		});
		final JPanel select_dir_panel = new JPanel();
		select_dir_panel.setLayout(new BorderLayout());
		if  (dir_cur_file != null) {
			select_dir_chooser.setCurrentDirectory(dir_cur_file);
		}
		select_dir_chooser.setFileSelectionMode(JFileChooser.DIRECTORIES_ONLY);
		select_dir_chooser.addActionListener(new ActionListener() {
			public void actionPerformed(final ActionEvent e) {
				File selected_file = null;
				String selected_dir_name = null;
				final String state = (String)e.getActionCommand();
				if (state.equals(JFileChooser.APPROVE_SELECTION)) {
					// 2007-01-20 - RPI-0541 Correct Z390 GUI file selection dialog cancel action
					selected_file = select_dir_chooser.getSelectedFile();
				} else {
					select_dir_frame.setVisible(false);
					if (main_gui) {
						main_frame.setVisible(true);
					}
				}
				if (selected_file != null) {
					selected_dir_name = selected_file.getPath();
					if  (main_gui) {
						z390_cmd_line.setText("CD " + "\"" + selected_dir_name + "\"");
						z390_cmd_line.postActionEvent();
					} else {
						cd_command("CD " + "\"" + selected_dir_name + "\"");
					}
				} else {
					log_error(37, "Directory not selected");
				}
				select_dir_frame.setVisible(false);
				if (main_gui) {
					main_frame.setVisible(true);
				}
			}});
		select_dir_panel.add(select_dir_chooser);
		select_dir_frame.getContentPane().add("North", select_dir_panel);
		select_dir_frame.pack();
		select_dir_frame.setLocation(100,100);
		if (main_gui) {
			main_frame.setVisible(false);
		}
		select_dir_frame.setVisible(true);
	}

	/**
	 * Invoke file chooser dialog to set selected_file_name within select_file_type if any.<br>
	 * Notes:<br>
	 *   1.  Note dialog is kept for non GUI mode to avoid dispose causing GUI shutdown on last window)
	 * @param file_cmd
	 * @param file_type
	 * @param file_opt
	 */
	private void select_file(final String file_cmd, final String file_type, final String file_opt)
	{
		select_cmd       = file_cmd;
		select_file_type = file_type;
		select_opt       = file_opt;
		
		if ( perms.maySelect() ) {
			final JFileChooser select_file_chooser = new JFileChooser();
			// 2007-01-20 - RPI-0541 Correct Z390 GUI file selection dialog cancel action
			// Rebuild every time
			select_file_chooser.resetChoosableFileFilters();
			select_file_chooser.setAcceptAllFileFilterUsed(true);
			if (select_file_type.length() > 0) {
				select_file_chooser.addChoosableFileFilter(new SelectFileType());
				select_file_chooser.setAcceptAllFileFilterUsed(false);
			} else {
				select_file_type = "ALL";
			}
			create_select_file(select_file_chooser);
			if (main_gui) {
				main_frame.setVisible(false);
			}
			select_file_frame.setLocation(100,100);
			select_file_frame.setVisible(true);
		} else {
			log_error(39, "Permission for file selection denied.");
		}
	}

	/**
	 * Create select file frame with chooser on first call.  It is updated after that.
	 * @param select_file_chooser
	 */
	private void create_select_file(final JFileChooser select_file_chooser)
	{
		select_file_frame = new JFrame(main_title + " Select " + select_file_type + " file for " + select_cmd);
		select_file_frame.addWindowListener(new WindowAdapter() {
			public void windowClosing(WindowEvent e) {
				select_file_frame.setVisible(false);
				if (main_gui){
					main_frame.setVisible(true);
				}
			}
		});
		final JPanel select_file_panel = new JPanel();
		select_file_panel.setLayout(new BorderLayout());
		if (dir_cur_file != null) {
			select_file_chooser.setCurrentDirectory(dir_cur_file);
		}
		select_file_chooser.setFileSelectionMode(JFileChooser.FILES_ONLY);
		select_file_chooser.addActionListener(new ActionListener() {
			public void actionPerformed(final ActionEvent e) {
				File selected_file = null;
				String selected_file_name = null;
				final String state = (String)e.getActionCommand();
				// 2007-01-20 - RPI-0541 Correct Z390 GUI file selection dialog cancel action
				if (state.equals(JFileChooser.APPROVE_SELECTION)){
					selected_file = select_file_chooser.getSelectedFile();
				} else {
					select_file_frame.setVisible(false);
					if (main_gui) {
						main_frame.setVisible(true);
					}
				}
				if (selected_file != null) {
					selected_file_name = selected_file.getPath();
					if (select_file_type.length() > 0 && !select_cmd.equals("EDIT")) {
						final int i = selected_file_name.lastIndexOf(".");
						if (i > 0) {
							selected_file_name = selected_file_name.substring(0,i);
						}
					}
					if (main_gui) {
						if (select_cmd.equals("EDIT")) {
							if (!tz390.exec_cmd(infoOS.get_z390_editor() + " " + selected_file_name)) {
								log_error(19, "start editor failed - " + infoOS.get_z390_editor());
							}
						} else if (select_cmd.equals("JOB")) {
							selected_file_name = get_short_file_name(selected_file_name);
							z390_cmd_line.setText(selected_file_name + select_opt);
							z390_cmd_line.postActionEvent();
						} else {
							select_cmd = get_short_file_name(install_loc + File.separator + select_cmd);
							selected_file_name = get_short_file_name(selected_file_name);
							z390_cmd_line.setText(select_cmd + " " + selected_file_name + " " + select_opt);
							z390_cmd_line.postActionEvent();
						}
					} else {
						process_command(select_cmd + " " + get_short_file_name(selected_file_name));
					}
				} else {
					log_error(37,"file not selected");
				}
				select_file_frame.setVisible(false);
				if (main_gui){
					main_frame.setVisible(true);
				}
			}});
		select_file_panel.add(select_file_chooser);
		select_file_frame.getContentPane().add("North", select_file_panel);
		select_file_frame.pack();
	}

	/**
	 * Return shortest file name possible with quotes if LSN.
	 * @param file_name
	 * @return
	 */
	private String get_short_file_name(String file_name)
	{
		if (   file_name.length() >  tz390.dir_cur.length()
			&& file_name.substring(0,tz390.dir_cur.length()).equals(tz390.dir_cur))
		{
			// 2006-11-16 - RPI-0499 Use z390_os_type to support Windows and Linux
			// skip dir + sep (remove +1 (already skipping sep))
			file_name = file_name.substring(tz390.dir_cur.length());
		}
		if (   file_name.length() > 0
			&& file_name.charAt(0) != '"') {
			// 2011-07-26 - RPI-1173 Correct LSN path logic to avoid double "" 
			final int index = file_name.indexOf(" ");
			if (index >=0) {
				return "\"" + file_name + "\""; // LSN
			}
		}
		return file_name;
	}

	/**
	 * Display alphabetical list of basic and extended commands.
	 */
	private void commands_command()
	{
		put_log("\nz390 alphabetical command list");
		put_log(" ");
		put_log("ABOUT                    display summary information about z390 tool");
		put_log("AMODE31  ON/OFF          set amode 24/31 for link cmd");
		put_log("ASCII    ON/OFF          set EBCDIC or ASCII mode mode");
		put_log("ASM      MLC file        submit assembly of MLC source to OBJ object code file");
		put_log("ASML     MLC file        submit assembly and link MLC source to 390 load module file");
		put_log("ASMLG    MLC file        submit assembly, link, and execute 390 load module file");
		put_log("CD       directory path  change directory");
		put_log("CMD      command         set cmd mode and submit batch cmd");
		put_log("Copy                     copy selected text to clipboard (GUI right click)");
		put_log("COMMANDS                 alphabetical list of all commands");
		put_log("CON      ON/OFF          set console output for file cmds");
		put_log("COPYLOG                  copy the entire log text to clipboard (GUI only)");
		put_log("Cut                      cut selected text (GUI right click)");
		put_log("Dump     ON/OFF          set option for indicative or full dump on abort");
		put_log("Edit     any file        edit source file in seprarate window");
		put_log("ERR      nnn             change error msg limit from 100 to nnn (0 is off)");
		put_log("EXIT                     exit z390 after closing all files (also CTRL-BREAK");
		put_log("EXEC     390 file        submit execution of 390 load module");
		put_log("FONT     points          change font size");
		put_log("GUAM     ON/OFF          Open Graphical User Interface for MCS, 3270, and graphics");
		put_log("GUIDE                    view PDF user guide in web browser");
		put_log("HELP                     display help information summary");
		put_log("JOB      BAT file        submit batch job");
		put_log("LINK     obj file        submit link obj file into 390 load module");
		put_log("LIST     ON/OFF          set PRN, LST, and/or LOG output for file cmds");
		put_log("LISTCALL ON/OFF          set trace calls for MAC file cmd");
		put_log("LOC      x y pixels      set upper left location of window");
		put_log("MAC      mlc file        expand mlc macro file to bal source file");
		put_log("PASTE                    paste clipboard text (GUI right click)");
		put_log("PERM                     display current Java security manager permissions");
		put_log("REL                      display current release level for OS, Java, and z390");
		put_log("RMODE31  ON/OFF          set rmode 24/31 for link cmd");
		put_log("SIZE     x y pixels      set width and height of window");
		put_log("STATS    ON/OFF          set statistics for BAL, PRN, LST, and/or LOG file cmds");
		put_log("STATUS   ON/OFF/sec      set status line on or off or set log interval sec");
		put_log("SUPPORT                  open browser to online support web site");
		put_log("TEST     ON/OFF          set prompt for interactive test cmds for EXEC cmd");
		put_log("TITLE    'text'          set GUI title, use quotes ' or \"");
		put_log("TIMEOUT  seconds         set command timeout seconds or 0 for no limit (default");
		put_log("TRACE    ON/OFF          set trace for BAL, PRN, LST, and/or LOG file cmds");
	}

	/**
	 * Returns an ImageIcon, or null if the path was invalid.
	 * @param path
	 * @param description
	 * @return
	 */
	protected static ImageIcon createImageIcon(final String path, final String description)
	{
		final java.net.URL imgURL = z390.class.getResource(path);
		if (imgURL != null) {
			return new ImageIcon(imgURL, description);
		} else {
			System.err.println("Could not find file: " + path);
			return null;
		}
	}

	/**
	 * Update log and command line size following any of the following changes:<br>
	 *  1. Change in window size<br>
	 *  2. Change in font size
	 */
	private void update_main_view()
	{
		if (main_gui) {
			main_width  = (int) main_frame.getSize().getWidth();
			main_height = (int) main_frame.getSize().getHeight();
	
			final int cxPanel = main_width  - 4 * main_border;
			final int cyPanel = main_height - 4 * main_border - menuBar.getHeight();
			main_panel.setSize(cxPanel,cyPanel);

			final int cxLogVw = cxPanel - log_view.getVerticalScrollBar().getWidth() - 3 * main_border;
			int cyLogVw = cyPanel - 50 - z390_cmd_line.getHeight();
			if (main_status) { cyLogVw -= status_line.getHeight(); } else { cyLogVw += main_border; }
			log_view.setPreferredSize(new Dimension(cxLogVw,cyLogVw));

			final int nOldCols  = z390_cmd_line.getColumns();
			final int pxPerChar = z390_cmd_line.getWidth() / nOldCols;

			if (pxPerChar != 0) {
				final int cxLabel   = cmd_label.getWidth();
				boolean lbl_visible;
				int nNewCols = ((cxLogVw-cxLabel) / pxPerChar)-3;
				if (nNewCols < 60) {
					nNewCols = (cxLogVw / pxPerChar)-3;
					if (nNewCols < 1 ) { nNewCols = 1; }
					lbl_visible = false;
				} else {
					lbl_visible = true;
				}
				if (labels_visible != lbl_visible) {
					labels_visible = lbl_visible;
					cmd_label.setVisible(   labels_visible);
					status_label.setVisible(labels_visible);
				}
				if (nOldCols != nNewCols) {
					z390_cmd_line.setColumns(nNewCols);
					status_line.setColumns(  nNewCols);
				}
			}
			main_frame.setVisible(true);
		}
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
	*/
		update_main_view();
	}

	public void componentShown(final ComponentEvent e)
	{/*
		final Component c = e.getComponent();
		final StringBuilder sb = new StringBuilder();
		sb.append("componentShown event from ").append(c.getClass().getName());
		System.out.println(sb.toString());
	*/}

	/**
	 * 1. Terminate any prior executed process with error if non zero completion.
     * 2. Start new process running on separate thread.  
     *
     * Note: Cmd monitor will issue exec_term if timeout limit is reached before
     *       next start command does it. Error will be issued by exec_term if
     *       non zero return code or if process had to be cancelled.
     * @param exec_cmd
     * @return
     */
	public int cmd_exec_start(final String[] exec_cmd)
	{
		if  (cmd_exec_process != null) {
			int rc = cmd_exec_rc();
			if (rc != 0) {
				if (rc == -1) {
					log_error(75, "Previous command execution cancelled."); // RPI 792
					cmd_exec_cancel();
				} else {
					log_error(71, "Previous command execution ended with rc =" + rc + ".");
				}
			}
		}
		try {
			cmd_exec_process = Runtime.getRuntime().exec(exec_cmd);
			cmd_exec_error_reader  = new BufferedReader(new InputStreamReader(cmd_exec_process.getErrorStream()));
			cmd_exec_output_reader = new BufferedReader(new InputStreamReader(cmd_exec_process.getInputStream()));
			cmd_exec_input_writer  = new PrintStream(cmd_exec_process.getOutputStream(),true);  // add true for autoflush
			cmd_exec_process_thread = new Thread(this);
			cmd_exec_error_reader_thread   = new Thread(this);
			cmd_exec_output_reader_thread  = new Thread(this);
			cmd_exec_output_msg = "";
			cmd_exec_error_msg = "";
			int last_io_count = io_count;
			cmd_exec_process_thread.start();
			cmd_exec_error_reader_thread.start();
			cmd_exec_output_reader_thread.start();
			sleep_now();
			int wait_count = 5;
			while (io_count == last_io_count && wait_count > 0) {
				sleep_now();
				wait_count--;
			}
			return 0;
		} catch (final Exception e) {
			log_error(66, "Execution startup error " + e.toString());
			cmd_exec_cancel();
			return -1;
		}
	}

	/**
	 * Send input to executing command in process.
	 * @param cmd_line
	 */
	private void cmd_exec_input(final String cmd_line)
	{
		try {
			if (cmd_line == null) {
				cmd_exec_input_writer.println("");
			} else {
				cmd_exec_input_writer.println(cmd_line);
			}
			//cmd_io_total++;
			monitor_cmd_time_total = 0;
			//cmd_io_total = 0;
		} catch (final Exception e) {
			log_error(68, "Execution input error" + e.toString());
		}
	}

	/**
	 * Return ending RC else -1<br>
	 * Return 0 if no process defined.
	 * @return
	 */
	private int cmd_exec_rc()
	{
		int rc = -1;
		if  (cmd_exec_process != null) {
			try {
				rc = cmd_exec_process.exitValue(); 
			} catch (final Exception e) {
			}
		} else {
			rc = 0;
		}
		return rc;
	}

	/**
	 * Cancel executing process.
	 */
	private void cmd_exec_cancel()
	{
		ins_count++;
		if  (cmd_exec_process != null) {
			try {
				cmd_exec_process.destroy();
			} catch (final Exception e) {
				cmd_exec_process = null; 
			}
		}
		cmd_mode = false;
		if (main_gui) {
			view_menu_cmd.setSelected(false);
		}
	}

	public void run()
	{
		if (cmd_exec_process_thread == Thread.currentThread()) {
			try {
				cmd_exec_process.waitFor();
			} catch (Exception e) {
				log_error(66, "Exec execution interruption error" + e.toString());
				cmd_exec_cancel();
			}
			io_count++;
		} else if (cmd_exec_output_reader_thread == Thread.currentThread()) {
			copy_cmd_output_to_log();
		} else if (cmd_exec_error_reader_thread == Thread.currentThread()) {
			copy_cmd_error_to_log();
		}
	}

	/**
	 * Copy command output to log a byte at a time to handle command output with CR/LF (ie TIME).
	 */
	private void copy_cmd_output_to_log()
	{
		try {
			cmd_exec_output_msg = cmd_exec_output_reader.readLine();
			while (cmd_exec_output_msg != null) {
				if (cmd_exec_output_msg.equals("exit_request")) {
					// If ez390 issues an exit request, close down GUI.
					// This is triggered when ez390 exits if z390 sent
					// "exit_request to input queue.
					cmd_exec_input(" exit");  // RPI 98, RPI 500 RPI 731 RPI 765 RPI 888 leading space may be eaten by PAUSE
				} else {
					put_log(cmd_exec_output_msg);
				}
				cmd_exec_output_msg = cmd_exec_output_reader.readLine();
			}
		} catch (final Exception ex) {
			if (cmd_exec_rc() == -1) {  // RPI 731
				log_error(67,"exec execution output error");
				cmd_exec_cancel();
			}
		}
	}

	/**
	 * Copy command error to log a line at a time.
	 */
	private void copy_cmd_error_to_log()
	{
		try {
			cmd_exec_error_msg = cmd_exec_error_reader.readLine();
			while (cmd_exec_error_msg != null) {
				put_log(cmd_exec_error_msg);
				cmd_exec_error_msg = cmd_exec_error_reader.readLine();
			}
		} catch (final Exception ex) {
			if (cmd_exec_rc() == -1) {  // RPI 731
				// 2008-01-30 RPI-0792 Remove put error message before checking for null
				log_error(73, "Exec execution output error");
				cmd_exec_cancel();
			}
		}
	}

	/**
	 * Invoke batch command with specified file and options.  If file is null, invoke file
	 * selection dialog with specified file type and then launch batch command when selection
	 * dialog closes.
	 *
	 * Note:
	 *   1.  select_file_type is set to filter files to type for command.
	 *   2.  select_opt is set to any override options for command.  The override
	 *       options are updated on any change to the options menu.
	 *   3.  CMD mode is started if not already running and mult batch commands just
	 *       queue up for single process.
	 *   4.  EDIT command is launched separately in parallel to allow multiple edits to run.
	 *       Editor is defined by EDIT environment variable else it uses hard coded default.
	 *   5.  JOB launches selected BAT file with options
	 *
	 * @param bat_cmd
	 * @param bat_file_name
	 * @param bat_file_type
	 * @param bat_opt
	 */
	private void batch_cmd(final String bat_cmd, final String bat_file_name, final String bat_file_type, final String bat_opt)
	{
		select_cmd = bat_cmd;
		select_opt = bat_opt;
		if (select_opt == null) {
			select_opt = "";
		}

		if ( perms.mayExecFiles() ) {
			if (   bat_file_name == null
				|| bat_file_name.length() == 0) {
				select_file(bat_cmd, bat_file_type, bat_opt);
			} else {
				if (bat_cmd.equals("EDIT")) {
					if (!tz390.exec_cmd("\"" + infoOS.get_z390_editor() + "\" \"" + bat_file_name + "\"")) {
						log_error(19, "Start editor failed - " + infoOS.get_z390_editor());
					}
				} else
				if (select_cmd.equals("JOB")) {
					cmd_command(get_short_file_name(bat_file_name) + select_opt);
				} else {
					cmd_command(get_short_file_name(install_loc + File.separator + bat_cmd)
						+ " " + get_short_file_name(bat_file_name) 
						+ " " + select_opt);
				}
			}
		} else {
			log_error(17, "Permission for file execute denied.");
		}
	}

	/**
	 * Define accept and getDescription method for file chooser to filter files to just select_file_type if any.
	 */
	private class SelectFileType extends FileFilter
	{
		public boolean accept(final File f)
		{
			if (f.isDirectory()) {
				return true;
			}
			final String extension = getExtension(f);
			if (extension != null) {
				if (extension.toUpperCase().equals(select_file_type) ) {
					return true;
				} else {
					return false;
				}
			}
			return false;
		}

		public String getDescription()
		{
			return "Select files of type " + select_file_type;
		}

		private String getExtension(final File f)
		{
			String ext = null;
			final String s = f.getName();
			int i = s.lastIndexOf('.');

			if (i > 0 &&  i < s.length() - 1) {
				ext = s.substring(i+1).toLowerCase();
			}
			return ext;
		}
	}
}
