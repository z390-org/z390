import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.DataInputStream;
import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.InputStreamReader;
import java.io.PrintStream;
import java.io.RandomAccessFile;
import java.lang.reflect.Array;
import java.math.BigDecimal;
import java.math.BigInteger;
import java.net.InetAddress;
import java.net.ServerSocket;
import java.net.Socket;
import java.nio.ByteBuffer;
import java.text.SimpleDateFormat;
import java.util.Arrays;
import java.util.Calendar;
import java.util.Date;
import java.util.GregorianCalendar;
import java.util.LinkedList;
import java.util.concurrent.locks.Condition;
import java.util.concurrent.locks.Lock;
import java.util.concurrent.locks.ReentrantLock;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import javax.swing.JTextArea;
import javax.swing.JTextField;

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
 * ez390 is the emulator component of z390<br>
 * which can be called from z390 GUI interface or from command line<br>
 * to execute 390 load module files.
 */
public class sz390 implements Runnable
{
	// Static limits
	private final static int max_tiot_files    =   100; // max open files
	private final static int max_cde_pgms      =   500; // max loaded 390 pgms
	private final static int max_link_stk      =    50; // max nested links
//	private final static int max_cmd_out       = 10000; // cmd output character buffer
	private final static int max_cmd_proc      =    10; // max cmd processes ID=0-9
	private final static int max_lsn_spec      =   265;
	private final static int max_dir_list      =   512;
	private final static int max_guam_buff     =  3000;
	private final static int max_ecb_count     =    16;
	private final static int max_env_name_len  =   256;
//	private final static int max_env_value_len =  4096; // RPI 413 could be move?

	// environment variables
	private int env_name_addr  = 0;
	private int env_value_addr = 0;
	private String env_name  = "";
	private String env_value = "";

	// Shared global variables
	public  tz390 tz390  = null;
	public  pz390 _pz390 = null;
	private vz390 _vz390  = null; // RPI 644
	private final String msg_id = "EZ390I ";
//	private boolean pz390_running = false;
	private boolean put_stats_running = false; // RPI 646
	public  String ez390_pgm = null; // saved by link for gz390 title
	private int ez390_rc = 0;
	private int ez390_errors = 0;
	private boolean ez390_recursive_abort = false; // RPI 935
	private String load_file_name = null;
	private RandomAccessFile z390_file = null;
	private File log_file = null;
	private BufferedWriter log_file_buff = null;
//	private String  opt_parms = " ";
//	private boolean opt_ok = false;
	private boolean exit_request = false;
	public  boolean system_abend = true;
	private boolean user_abend   = false;
	public  boolean svc_abend_type = system_abend;
	public  boolean svc_req_dump     = false; // request dump
	private boolean dump_taken = false;
//	private long long_psw_amode31_bit = ((long) (1) << 31); // RPI 819
	public  long stimer_exit_time = 0;  // set by STIMER for update+monitor to check
	public  int  stimer_exit_addr = 0;  // exit when STIMER tod reached
	public  boolean stimer_exit_request = false; // set when time expired
	public  boolean stimer_exit_running = false; // set while in stimer exit
	private int  stimer_save_r13 = 0; // save r13 during exit
	private int  stimer_save_r14 = 0; // save r14 during exit
	private int  stimer_save_r15 = 0; // save r15 during exit
	private int  stimer_save_psw = 0; // save psw at time of exit

	// gz390 graphical user access method variables
	public  gz390 gz390 = null;
	private int guam_major = 0;  // major function from r0+2
	private int guam_minor = 0;  // minor function from r0+3
	private int guam_args  = 0;  // arg list addr from r1
//	private final static int guam_view_mcs    = 1;
//	private final static int guam_view_tn3270 = 2;
//	private final static int guam_view_graph  = 3;
	private GuamViewTypes guam_view = GuamViewTypes.NONE; // 0=NONE, 1=MCS, 2=SCREEN/TN3270, 3=GRAPHIC
	private int guam_x     = 0;  // x pixels (rows for set screen view)
	private int guam_y     = 0;  // y pixels (cols for set screen view)
	private int guam_x2    = 0;
	private int guam_y2    = 0;
	private int guam_color = 0;
	private int guam_width = 0;
	private int guam_height= 0;
	private int guam_row   = 0;
	private int guam_col   = 0;
	private int guam_bg_rgb = 0;
	private int guam_text_rgb = 0;
	private int guam_lfield = 0;
	private int guam_cursor_type = 0;
	private int guam_font      = 0;
	private int guam_abuff     = 0; // addr buff
	private int guam_lbuff     = 0; // length buff
	private int guam_key_amod  = 0; // addr key mod
	private int guam_key_achar = 0; // addr key char
	private int guam_key       = 0; // mod and char from keyboard
	private int[] guam_mouse   = null; // guam_mouse_read returns x,y,left,right
	private int guam_left      = 0;    // GUAM mouse left button addr (1=pressed)
	private int guam_right     = 0;    // GUAM_mouse right button addr (1 = pressed)
	private boolean guam_wait  = true; // wait for input

	// global tget and tput data
	private int tpg_flags      = 0;    // TGET/TPUT options from high byte R1
	private int tpg_op_mask    = 0x80; // 1=TGET, 0=TPUT
//	private int tpg_op_tget    = 0x80;
	private int tpg_op_tput    = 0x00;
	private int tpg_wait_mask  = 0x10; // 1=NOWAIT, 0=WAIT
	private int tpg_wait       = 0x00;
//	private int tpg_nowait     = 0x10;
	private int tpg_type_mask  = 0x03; // 00=EDIT 01=ASIS 10=CONTROL 11=FULLSCR
//	private int tpg_type_edit  = 0x00;
//	private int tpg_type_asis  = 0x01;
//	private int tpg_type_control = 0x02;
//	private int tpg_type_fullscr = 0x03;
//	private byte[] tget_byte = null;
//	private ByteBuffer tget_buff = null;
	private byte[] tput_byte = new byte[max_guam_buff];
	private ByteBuffer tput_buff = ByteBuffer.wrap(tput_byte,0,max_guam_buff);
	private String guam_text = null;

	// Monitor variables
//	private int     ins_count = 0;
//	private int     io_count  = 0;
//	private Timer   monitor_timer = null;
//	private long    monitor_cmd_time_total = 0;
//	private long    monitor_last_time = 0;
//	private long    monitor_next_time = 0;
//	private long    monitor_cur_interval = 0;
//	private int     monitor_last_ins_count = 0;
//	private int     monitor_next_ins_count = 0;
//	private int     monitor_last_io_count = 0;
//	private int     monitor_next_io_count = 0;
//	private long    monitor_cur_ins  = 0;
//	private long    monitor_cur_int  = 0;
//	private long    monitor_cur_rate = 0;
	private int wto_fld = 0;
	private int wto_len = 0;

	// wtor console data
	public  BufferedReader wtor_reply_buff = null; // RPI 595, RPI 722
	public  boolean wtor_reply_pending = false;
	public  String  wtor_reply_string = null;
	public  int wtor_reply_addr = 0;
	public  int wtor_reply_len  = 0;
	public  int wtor_ecb_addr   = -1;
	public final static int ecb_waiting = 0x80000000;
	public final static int ecb_posted  = 0x40000000;

	// svc wait variables
	private int wait_count = 0;  // 0 for ECB= else ECBLIST wait count
	private int wait_addr  = 0;  // ECB= or ECBLIST= addr
	private boolean wait_retry = false; // do not refresh on retry after stimer exit

	// Command processor variables stored in an array
	public  CmdProcessor[] cmd_processors = null;
/*
 *	public  Process[]           cmd_proc          = (Process[])Array.newInstance(Process.class,max_cmd_proc);
	public  Thread[]            cmd_proc_thread   = (Thread[])Array.newInstance(Thread.class,max_cmd_proc);
	public  Thread[]            cmd_error_thread  = (Thread[])Array.newInstance(Thread.class,max_cmd_proc);
	public  Thread[]            cmd_output_thread = (Thread[])Array.newInstance(Thread.class,max_cmd_proc);
	private BufferedReader[]    cmd_error_reader  = new BufferedReader[max_cmd_proc]; // RPI 731
	private BufferedReader[]    cmd_output_reader = new BufferedReader[max_cmd_proc]; // RPI 731
	private PrintStream[]       cmd_input_writer  = new PrintStream[max_cmd_proc];    // RPI 731
	private LinkedList<String>[] cmd_output_queue = (LinkedList<String>[]) Array.newInstance(LinkedList.class, max_cmd_proc);
	public  boolean[]           cmd_proc_running  = (boolean[])Array.newInstance(boolean.class,max_cmd_proc);
	public  boolean[]           cmd_proc_cmdlog   = new boolean[max_cmd_proc];  // RPI 731
//	private int[]               cmd_proc_rc       = (int[])Array.newInstance(int.class,max_cmd_proc);
	public  int[]               cmd_proc_io       = (int[])Array.newInstance(int.class,max_cmd_proc);
	private long[]              cmd_proc_start_time = (long[])Array.newInstance(long.class,max_cmd_proc); // RPI 545
	private String[]            cmd_error_msg     = new String[max_cmd_proc];
	private String[]            cmd_output_msg    = new String[max_cmd_proc];
	private String[]            cmd_read_line     = new String[max_cmd_proc]; // RPI 731
//	private int cmd_io_total = 0;
 */
	public  int tot_cmd = 0; //max cmd processes started;
	private int tot_log_queue = 0;  // RPI 781

	// test option interactive debug variables
	private boolean test_first_cmd = true; // RPI 854
	private String  test_file_name = null;
	private boolean test_cmd_abort = false;
	private int     test_loop_count = 0;
	public  BufferedReader test_cmd_file = null;
	private String  test_cmd = null;
	private Pattern test_pattern = null;
	private Matcher test_match   = null;
	private String  test_token = null;
	private char    test_bias = ' ';
//	private int     test_token_len = 0;
	private char    test_opcode = 0;
	private int test_addr = 0;
	private int test_next_addr = 0;
	private String test_sdt = null;
	private byte test_addr_type = 0;
	private byte test_addr_mem = 0;
	private byte test_addr_reg = 1;
	private byte test_compare = 0;
	private int test_base_addr = -1;
	private int test_mem_loc = 0;
	private int test_mem_len = 0;
	private int test_reg_loc = 0;
	private long test_reg_sdt = 0;
	private byte[]  test_mem_sdt  = null;

	// test reg and mem break on change variables
	private boolean test_break_addr_mode = false;
	private boolean test_break_reg_mode  = false;
	private boolean test_break_mem_mode  = false;
	private boolean test_break_op_mode   = false;
	private int     tot_test_break_addr  = 0;
	private final static int max_break_addr = 100;
	private int[]   test_break_addr      = new int[max_break_addr];
	private long    test_break_op_ins    = 0; // RPI 825
	private String  test_break_addr_cmd  = null;
	private String  test_break_reg_cmd   = null;
	private String  test_break_mem_cmd   = null;
	private String  test_break_op_cmd    = null;
	private boolean test_break_reg       = false;
	private boolean test_break_mem       = false;
	private int     test_break_reg_loc   = 0;
	private int     test_break_reg_compare = 0;
	private long    test_break_reg_val   = 0;
	private long    test_break_reg_sdt   = 0;
	private int     test_break_mem_loc   = 0;
	private byte    test_break_mem_byte  = 0;
	private int     test_break_mem_compare = 0;
	private int     test_break_mem_equal = 0;
	private byte[]  test_break_mem_sdt   = null;
	private int     test_break_op1       = 0;
	private int     test_break_op2       = 0;
	private int     test_break_op2_index = 0;
	private int     test_break_op2_mask  = 0;

	// Time and date variables
//	private final static SimpleDateFormat cur_date_MMddyy   = new SimpleDateFormat("MM/dd/yy"); // JBA-unused
//	private final static SimpleDateFormat cur_tod_hhmmss    = new SimpleDateFormat("HH:mm:ss"); // JBA-unused
	private final static SimpleDateFormat cur_tod_hhmmss00  = new SimpleDateFormat("HHmmss00");
	private final static SimpleDateFormat cur_date_yyyy     = new SimpleDateFormat("yyyy");
	private final static SimpleDateFormat cur_date_MM       = new SimpleDateFormat("MM");
	private final static SimpleDateFormat cur_date_dd       = new SimpleDateFormat("dd");
	private final static SimpleDateFormat cur_date_ms       = new SimpleDateFormat("SSS");
	private final static SimpleDateFormat cur_date_yyddd    = new SimpleDateFormat("yyDDD");
	private final static SimpleDateFormat cur_date_yyyyddd  = new SimpleDateFormat("yyyyDDD");
	private final static SimpleDateFormat cur_date_MMddyyyy = new SimpleDateFormat("MMddyyyy");
	private final static SimpleDateFormat cur_date_ddMMyyyy = new SimpleDateFormat("ddMMyyyy");
	private final static SimpleDateFormat cur_date_yyyyMMdd = new SimpleDateFormat("yyyyMMdd");
	private int  cur_date_year  = 0;
	private int  cur_date_month = 0;
	private int  cur_date_day   = 0;
	private long time_mil   = 0;  // milli-seconds
	private long tod_start_day = 0;
	private long tod_start_pgm = 0;
	private long tod_end_pgm   = 0;
	public  long tod_time_limit = 0;
//	private int  next_time_ins   = 0x1000;
//	private int  next_time_check = next_time_ins;
//	private boolean log_tod = true;
	private JTextArea  z390_log_text = null;
	private JTextField z390_command_text = null;
	public  boolean ez390_startup = true;

	// 390 load module loader variables
	//	16 byte header with 4 fields as follows
	//	offset 0 - 4 character format version
	//	offset 4 - full word length of code
	//	offset 4 - full word entry offset
	//	offset 4 - full word count of rlds
	private char[] load_code_ver  = new char[4];
	private char[] z390_flags     = new char[4];
	private int z390_flags_amode31 = 0;
	private int z390_flags_rmode31 = 1;
	private String load_dsn       = null;
	private int    load_dsn_addr  = 0;
	public  String load_pgm_dir   = null;
	private String load_pgm_name  = null;
//	private byte[] alias_name_byte = new byte[8];
	private String load_pgm_type  = null;
	public  String load_vcdt_entry = null;
	public boolean load_vcdt_mode = false;
	private int    load_code_load = 0;
	private int    load_code_len  = 0;
	private int    load_code_ent  = 0;
	private int    load_code_rlds = 0;

	// CDE content directory entry variables used by LOAD, LINK, and DELETE to manage 390 load modules in memory
	private int tot_cde = 0;
	public  int cur_cde = 0;
	private String[] cde_name  = new String[max_cde_pgms];
	public  String[] cde_file  = new String[max_cde_pgms];
	private byte[]    cde_use   = (byte[])Array.newInstance(byte.class,max_cde_pgms);
	private int[]    cde_loc   = (int[])Array.newInstance(int.class,max_cde_pgms);
	private int[]    cde_len   = (int[])Array.newInstance(int.class,max_cde_pgms);
	private int[]    cde_ent   = (int[])Array.newInstance(int.class,max_cde_pgms);
	private int[]    cde_addr  = (int[])Array.newInstance(int.class,max_cde_pgms); // RPI 1063 addr CDE in mem
	private int      cded_len   = 40; // RPI 1063 see mac\CDED.MAC

	// nested link variables
	public  int   tot_link_stk = 0;
	private int[]     link_stk_cde = (int[])Array.newInstance(int.class,max_link_stk);
	private int[]     link_stk_ret = (int[])Array.newInstance(int.class,max_link_stk);

	// rld entries in following format
	//	offset 0 full workd rld field offset
	//	offset 4 signed byte rld field len
	//	(negative length means subtract the base address versus adding it to rld field.)
	private int  rld_loc = 0;
	private byte rld_len = 0;

	// Convert to display variables
	private int        ctd_display_len = 45; // CTD and CFD display field
	private float      ctd_e;
	private double     ctd_d;
	private byte[]     ctd_byte = new byte[16];
	private BigInteger ctd_bi;
	private BigDecimal ctd_bd;
	private String     ctd_text;
	private float      cfd_e;
	private double     cfd_d;
	private byte[]     cfd_byte;
	private BigInteger cfd_bi;
	private BigDecimal cfd_bd;

	/*
	 * tcpio server port global data
	 *
	 * Note thread for each open port:
	 *   1.  Waits for connection from client
	 *   2.  Start connection thread to process messages and send responses.
	 *   3.  Return to wait for next connection
	 */
	private final Lock      lock            = new ReentrantLock();
	private final Condition lock_condition  = lock.newCondition();
	private boolean tcpio_server_running = false;  // true if any tcpio server ports open (required for server threads to run)
	private int     tcpio_conn_ready_count   = 0;  // count of conn msgs ready
	private int max_tcp_server_port   = 10;  // max server ports open
	private int cur_tcp_server_index   = 0;  // current port
	private int[]          tcp_server_port       = new int[max_tcp_server_port];
	private boolean[]      tcp_server_open       = new boolean[max_tcp_server_port]; // RPI 622
	private Thread[]       tcp_server_thread     = new Thread[max_tcp_server_port];  // RPI 554
	private int[]          tcp_server_conn_index = new int[max_tcp_server_port]; // RPI 554 index to allocated conn for next connection
	private ServerSocket[] tcp_server_socket     = new ServerSocket[max_tcp_server_port];
	private String[]       tcp_server_host_text  = new String[max_tcp_server_port];
	private InetAddress[]  tcp_server_host_ip    = new InetAddress[max_tcp_server_port];

	// tcp server socket connection data
	// Note thread for each active connection started by server port thread processes receive messages and send messages to client.
	private final static int max_tcp_conn = 10; // max connections to server ports
//	private int               cur_tcp_conn = 0;  // current thread
	private Thread[]          tcp_conn_thread       = new Thread[max_tcp_conn];  // RPI 554
	private Socket[]          tcp_conn_socket       = new Socket[max_tcp_conn];
	private int[]             tcp_conn_server_port  = new int[max_tcp_conn];
	private int[]             tcp_conn_server_index = new int[max_tcp_conn];
	private boolean[]         tcp_conn_msg_ready    = new boolean[max_tcp_conn]; // 1 or more bytes ready for receiving
	private boolean[]         tcp_conn_read         = new boolean[max_tcp_conn];
	private byte[]            tcp_conn_byte         = new byte[max_tcp_conn];
	private DataInputStream[] tcp_conn_input        = new DataInputStream[max_tcp_conn];
	private PrintStream[]     tcp_conn_output       = new PrintStream[max_tcp_conn];

	// tcpio client global data
	private final static int max_tcp_client_port = 10; // max client ports open
	private int           cur_tcp_client_index  = 0;
	private int[]         tcp_client_port       = new int[max_tcp_client_port];
	private Socket[]      tcp_client_socket     = new Socket[max_tcp_client_port];
	private String[]      tcp_client_host_text  = new String[max_tcp_client_port];
	private InetAddress[] tcp_client_host_ip    = new InetAddress[max_tcp_client_port];
	private DataInputStream[] tcp_client_input  = new DataInputStream[max_tcp_client_port];
	private PrintStream[]     tcp_client_output = new PrintStream[max_tcp_client_port];
	private int    tcpio_op   = 0;       // r0 low = opcode 1-5
	private int    tcpio_flags= 0;       // r0 high= bit 15 = NOWAIT for receive
	private boolean tcpio_wait = false;
	private int    tcpio_conn = 0;       // r2 connection id for send/receive (-1 = any)
	private int    tcpio_amsg = 0;       // r14 msg start address
	private int    tcpio_lmsg = 0;       // r15 message length (max for receive)
	private int    tcpio_lmax = 1000000; // max lmsg set by send/recv
	private int    tcpio_lmin = 1;       // min lmsg
	private int    tcpio_host_ip_addr   = 0;
	private String tcpio_host_ip_text   = null;
	private String tcpio_host_name = null; // RPI 854
	private InetAddress tcpio_host_ip = null;
	private int    tcpio_port        = 0;
	private int    tot_tcpio_oper    = 0;
	private int    tot_tcpio_openc   = 0;
	private int    tot_tcpio_opens   = 0;
	private int    tot_tcpio_closec  = 0;
	private int    tot_tcpio_closes  = 0;
	private int    tot_tcpio_send    = 0;
	private int    tot_tcpio_recv    = 0;

	// DCB sequential and random file I/O tables
	private int    tot_tiot_files = 0;
	private int    cur_tiot_index = 0;
	public  int    tot_dcb_oper   = 0;
	private int    tot_dcb_open   = 0;
	private int    tot_dcb_close  = 0;
	private int    tot_dcb_get    = 0;
	private int    tot_dcb_put    = 0;
	public  int    tot_dcb_read   = 0;
	public  int    tot_dcb_write  = 0;
	private int    cur_decb_addr  = 0;
	private int    cur_ecb        = 0;
	private int    decb_ecb   = 0;
//	private int    decb_type  = 4;
	private int    decb_dcb   = 8;
	private int    decb_area  = 12;
	private long   cur_rba        = 0;
	public  int    cur_dcb_addr   = 0; // mem offset to dcb from r1
	public  int    cur_open_opt   = 0; // open options (GET=x'40, PUT=x'20')
	private int    cur_dcbe_addr  = 0; // dcb extension
	private String cur_dcb_ddnam  = null; // ascii ddname from dcb ebcdic
	private String cur_dcb_file_name = null;
	private int    cur_dcb_oflgs  = 0;
	private int    cur_dcb_synad  = 0;
	private int    cur_dcb_eodad  = 0;
	private int    cur_dcb_macrf  = 0;
	private int    cur_dcb_recfm  = 0;
	private int    cur_dcb_area   = 0;
	private int    cur_dcb_lrecl_f  = 0;
	private int    cur_dcb_blksi_f  = 0;
	private int    cur_vrec_lrecl  = 0;
	private String cur_rec_text  = null;
	private int    cur_rec_len   = 0;
//	private int dcb_dsorg  = 0x1a;
//	private int dcb_dsorg_ps = 0x40;    // physical sequential (GM or PM)
//	private int dcb_dsorg_da = 0x20;    // direct access(R/W)
	public  int dcb_iobad  = 0x1c;      // has tiot_index +1 while open else 0
	private int dcb_eodad  = 0x20;      // end of data exit
	private int dcb_recfm  = 0x24;      // record format
//	private int dcb_recfm_f = 0x80;     // fixed
//	private int dcb_recfm_v = 0x40;     // variable
//	private int dcb_recfm_fb = 0x90;    // fixed blocked
//	private int dcb_recfm_vb = 0x50;    // variable blocked
	private int dcb_recfm_ft = 0xa0;    // fixed to/from ascii text
	private int dcb_recfm_vt = 0x60;    // variable to/from ascii text
	public  int dcb_ddnam  = 0x28;      // ddname
	private int dcb_id     = 0x00;      // id = EBCDIC or ASCII C'DCB1' RPI88
	private int dcb_oflgs  = 0x30;      // open flags
	private int dcb_oflgs_open = 0x10;  // file open  RPI 906 was x'80'
	private int dcb_oflgs_r      = 0x40;  // read allowed
	public  int dcb_oflgs_w      = 0x20;  // write allowed
//	private int dcb_oflgs_rw     = 0x60;  // read and write allowed
	private int dcb_macrf  = 0x32;      // macro access type
//	private int dcb_macrf_gm = 0x5000;  // get move
	private int dcb_macrf_pm = 0x0050;  // put move
	private int dcb_macrf_gl = 0x4800;  // get locate RPI 764
	private int dcb_macrf_pl = 0x0048;  // put locate RPI 764
//	private int dcb_macrf_r  = 0x2000;  // read only  RPI 668
	private int dcb_macrf_w  = 0x0020;  // write only RPI 668
//	private int dcb_macrf_rw = 0x2020;  // read/write random
	private int dcb_synad = 0x38;       // synchronous error exit
	private int dcb_blksi_f = 0x3c;       // blocksize RPI 587 32 bits
	public  int dcb_lrecl_f = 0x50;       // record length RPI 587 32 bits
	private int dcb_rec   = 0x58;       // record area
	public  int dcb_dsnam = 0x5c;       // ascii file spec override ddname
	private int dcb_dcbe  = 0x60; // dcbe extention for eodad and synad
	private int dcb_io    = 0x64; // dcb total io req since open // RPI 764
	public  int dcb_len   = 0x68; // length of DCB
	private int dcbe_eodad = 0;
	private int dcbe_synad = 4;
	private boolean dcb_synad_recur = false; // RPI 377
	private boolean[]          tiot_dcb_open   = (boolean[])Array.newInstance(boolean.class,max_tiot_files);
	private String[]           tiot_ddnam      = new String[max_tiot_files];
	private String[]           tiot_dsn        = new String[max_tiot_files];
	private int[]              tiot_dcb_addr   = (int[])Array.newInstance(int.class,max_tiot_files);
	private int[]              tiot_vrec_blksi = (int[])Array.newInstance(int.class,max_tiot_files);
	private long[]             tiot_cur_rba    = (long[])Array.newInstance(long.class,max_tiot_files);
	public  long[]             tiot_eof_rba    = (long[])Array.newInstance(long.class,max_tiot_files);
	public  RandomAccessFile[] tiot_file       = (RandomAccessFile[])Array.newInstance(RandomAccessFile.class,max_tiot_files);

	// getmain and freemain work areas used by trace
	private int req_addr = 0;
	private int req_len  = 0;
	private int req_opt  = 0;
	private int cur_fqe  = 0;
	private int cur_fqe_len = 0;
	private int prev_fqe = 0;
	private int next_fqe = 0;
	private int next_fqe_len = 0;
	private int best_cur_fqe = 0;  // RPI 1153 smallest >= req_len
	private int best_prev_fqe = 0; // RPI 1153
	private int best_fqe_len = 0;  // RPI 1153
	private int max_mem_blk = 0; // largest contiguous memory blk for sort RPI 1092
	private int opt_getmain_amode31 = 0x02;
	private int opt_getmain_cond    = 0x01;

	// VSAM svc 97 interface variables
//	private int cur_vsam_op   =  0;
//	private int vsam_op_open  = 19;
//	private int vsam_op_clsoe = 20;

	// zsort global variables

	// zsort statistics
	private String zsort_pfx;
	private String zsort_start = "";;
	private String zsort_ended = "";
//	private String zsort_elapsed = "";
	private int    zsort_id = 0;

	// mode mode flags - ISORT/FSORT resets them all
//	private boolean zsort_abort = false; // JBA - unused
	private boolean zsort_put = false; // zsort put ok
	private boolean zsort_get = false; // zsort get ok

	// ISORT/FSORT input parameters
	private int zsort_parm_addr = 0; // zsort parm addr in r1 > lrecl,mem,key info
	private int zsort_lrecl = 0;     // +0 4 = fixed record length or max var record
	private int zsort_mem = 0;       // +4 4 = max memory used by sort or max avail from MEM option if 0
	private int zsort_min_blk_rec = 2; // min records in a sort block
	private int zsort_max_keys = 10; // max keys allowed
	private int zsort_tot_keys = 0;  // up to zsort_max_keys loaded from parm list with VL bit in last word
	private int[]  zsort_key_off   = new int[zsort_max_keys];  // +08 4 key offset in record
	private int[]  zsort_key_len   = new int[zsort_max_keys];  // +12 4 key length
	private byte[] zsort_key_type  = new byte[zsort_max_keys]; // +16 2 key type (also vl bit if last)
	private byte[] zsort_key_order = new byte[zsort_max_keys]; // +18 2 key ascending 1 or 0 for descending
//	private int zsort_psw_cc = 0; // JBA-unused!
	private int zsort_tot_sorts  = 0;
	private int zsort_tot_passes = 0;

	// zsort work file variables
	private RandomAccessFile zsort_sortwk01_file = null;
	private RandomAccessFile zsort_sortwk02_file = null;
	private long zsort_sortwk_len = 0;
	private int  zsort_tot_read  = 0; // block reads from work files
	private int  zsort_tot_write = 0; // block write to work files
	private int  zsort_tot_svc_put = 0; // total records to sort
	private int  zsort_tot_svc_get = 0; // total sorted records returned
	private int  zsort_tot_comp = 0;
	private int  zsort_tot_move = 0; // swaps, merges, isort get/put

	// zsort memory block variables
	private int zsort_fm_len   = 0; // mem alloc before rounding
	private int zsort_blk_len  = 0; // length of memory blk rounded down to even mult of lrecl
	private int zsort_blk_addr = 0; // addr of memory block in pz390.mem
	private int zsort_blk_end  = 0;
	private int zsort_blk_ptr = 0;
	private int zsort_blk1_addr = 0;  // merge input block 1
	private int zsort_blk1_ptr = 0;
	private int zsort_blk1_ptr_end = 0;
	private int zsort_blk2_addr = 0; // merge input block 2
	private int zsort_blk2_ptr = 0;
	private int zsort_blk2_ptr_end = 0;
	private int zsort_blk3_addr = 0; // merge output block 3
	private int zsort_blk3_ptr = 0;
	private int zsort_blk3_ptr_end = 0;
	private long zsort_blk1_xrba = 0;
	private long zsort_blk2_xrba = 0;
	private long zsort_blk1_xrba_end = 0;
	private long zsort_blk2_xrba_end = 0;
	private int  zsort_read_len;
	private int  zsort_write_len;

	// zsort merge variables used if records exceed memory
	private boolean zsort_merge_wk01 = true;     // Merge from wk01 to wk02 or wk02 to wk01 on alternating passes.
	private int     zsort_merge_mem_blk_len = 0; // Fixed block size for 2 input and 1 output blocks.
	private long    zsort_merge_wk_blk_len  = 0; // Double zsort_blk_len on each merge pass.
	private int     zsort_merge_pass        = 0; // Count merge passes for statistics.

	/**
	 * Execute supervisor call using mem and regs for data transfer.
	 * @param svc_id
	 */
	public void svc(final int svc_id) {
		switch (svc_id) {
		case 0x01:  // WAIT
			svc_wait();
			break;
		case 0x02:  // POST
			svc_post();
			break;
		case 0x03:  // EXIT
			svc_exit();
			break;
		case 0x04: // GETMAIN R0_BIT0=AMODE31, R0_BIT1=COND, R1=length
			svc_getmain();
			break;
		case 0x05: // FREEMAIN R0=LEN, R1=ADDR RPI 244
			svc_freemain();
			break;
		case 0x06:  // LINK  R15=PGMID, R1=PARMS
			svc_link();
			break;
		case 0x07:  // XCTL  R15=PGMID, R1=PARMS
			svc_xctl();
			break;
		case 0x08:  // LOAD  R15=PGMID
			svc_load();
			break;
		case 0x09: // DELETE R0=A(NAME)
			svc_delete();
			break;
		case 0x0b: // TIME R0_LH=DATETYPE, R0_LL=TIMETYPE, R1=ADDR
			svc_time();
			break;
		case 0x0d: // ABEND  R1=abend code
			_pz390.psw_pic = _pz390.reg.getInt(pz390.r1);
			if (_pz390.psw_pic < 0) {
				svc_req_dump = true; // req dump if abend issued
			} else {				 // rather than STAE or SPIE exit
				svc_req_dump = false;
			}
			svc_abend(_pz390.psw_pic & 0xfff,user_abend,svc_req_dump);
			break;
		case 0x12:  // BLDL FIND PGMS IN SYS390
			svc_bldl();
			break;
		case 0x13:  // OPEN DCB R0=(x'40' input,x'20' output) R1=DCB
			svc_open();
			break;
		case 0x14:  // CLOSE DCB R1=DCB
			svc_close();
			break;
		case 0x22:  // SVC 34 R1=COMMAND
			svc_cmd();
			break;
		case 0x23:  // WTO R1=ADDR
			// WTO FIELD
			//   0 2 length
			//   2 2 mcs flags
			//   4 (length-4) msg
			wto_fld = _pz390.reg.getInt(pz390.r1) & _pz390.psw_amode;
			wto_len = _pz390.mem.getShort(wto_fld);
			wto_msg("",wto_fld+4,wto_len-4);  // RPI190 remove "WTO  MSG"
			break;
		case 0x28:  //EXTRACT (GETENV) RPI 413
			svc_extract();
			break;
		case 0x2e:  //TTIMER r0=function, r1=mic addr
			svc_ttimer();
			break;
		case 0x2f:  //STIMER r0=flags, r1=rx storage arg.
			svc_stimer();
			break;
		case 0x33:  // SNAP r0hh=flags,r0ll=id,r14-15 storage
			svc_snap();
			break;
		case 0x3c:  // ESTAE R1=ADDR
			svc_estae(); // set abend exit R1=addr
			break;
		case 0x54:  // GUAM GUI application window I/O
			svc_guam();
			break;
		case 0x5d:  // TGET/TPUT TN3290 data stream for GUAM GUI
			svc_tget_tput();
			break;
		case 0x67:  // XLATE
			svc_xlate();  // translate ascii/EBCDIC
			break;
		case 0x6d:  // ESPIE
			svc_espie();  // set program check exit R0=types, R1=addr
			break;
		case 0x79: // VSAM access method
			_vz390.cur_vsam_op = _pz390.reg.get(pz390.r0 + 3);
			_vz390.svc_vsam();  // RPI 644
			break;
		case 0x7c: // TCPIO tcp/ip sockets I/O
			svc_tcpio();
			break;
		case 0x97: // dcb get move R0=REC,R1=DCB
			svc_get();
			break;
		case 0x98: // dcb put move/locate R0=REC, R1=DCB
			svc_put();
			break;
		case 0x99: // dcb read  R1=DECB
			svc_read();
			break;
		case 0x9a: // dcb write R1=DECB
			svc_write();
			break;
		case 0x9b: // decb check  R1=DECB
			svc_check();
			break;
		case 0x9c: // dcb point  R1=DCB
			svc_point();
			break;
		case 0xa0: // wtor
			svc_wtor();
			break;
		case 0xa1: //zsort
			svc_zsort();
			break;
		case 0xaa: // ctd - convert to display format r1=a(type,in,out)
			svc_ctd(); // RPI 360
			break;
		case 0xab: // cfd - convert from display format r1=a(type,in,out)
			svc_cfd(); // RPI 370
			break;
		case 0xac: // SYSTRACE reset trace options to string at R1 ending with space
			svc_systrace(); // RPI 1149
			break;
		default:
			abort_error(23, "Undefined svc - " + svc_id);
			break;
		}
	}

	/**
	 * Write message to z390_log_text and/or con if running stand-alone.
	 * @param msg
	 */
	public synchronized void put_log(final String msg) {
		put_log_line(msg);
		if (tz390.force_nocon) {
			return;
		}
		if (z390_log_text != null) {
			tz390.log_text_append(z390_log_text,msg);
		}
		if (   tz390.opt_trace
			|| tz390.opt_traceg
			|| tz390.opt_tracet
			|| tz390.opt_tracev
			|| tz390.opt_test) {
			tz390.put_trace(msg); // remove EZ390I
		} else if (tz390.opt_con) {
			put_con(msg);
		}
		if (!tz390.opt_con && (tz390.z390_abort || ez390_startup)) {
			put_con(msg);
		}
	}

	/**
	 * Put line to listing file.
	 * @param msg
	 */
	private void put_log_line(final String msg) {
		if (tz390.opt_list) {
			if (log_file.canWrite()) { // RPI 661
				try {
					tz390.systerm_io++;
					log_file_buff.write(msg + tz390.newline); // RPI 500
					if (log_file.length() > tz390.max_file_size) {
						abort_error(107, "Maximum log file size exceeded.");
					}
				} catch (final Exception e) {
					tz390.abort_error(6, "I/O error on log file write msg - " + msg); //   RPI 661
				}
			} else {
				put_con(msg);
			}
		}
	}

	/**
	 * Put message to console or command process output and yield to let parent process m.
	 * @param msg
	 */
	private void put_con(final String msg) {
		if (!tz390.force_nocon) { // RPI 1050 for future use
			System.out.println(msg);
			Thread.yield();
		}
	}

	/**
	 * Issue error message to log with prefix and increment error total.
	 * 1. Suppress if not gen_obj and not trace.
	 * @param error
	 * @param msg
	 */
	public void log_error(final int error, final String msg) {
		final String error_msg = "EZ390E error " + tz390.right_justify("" + error,3) + " " + msg;
		put_log(error_msg);
		tz390.put_systerm(error_msg);
		ez390_errors++;
		if (tz390.max_errors != 0 && ez390_errors > tz390.max_errors) {
			abort_error(5, "Maximum errors exceeded.");
		}
	}

	/**
	 * Issue error message to log with prefix and increment error total.
	 * @param error
	 * @param msg
	 */
	public synchronized void abort_error(final int error, String msg) { // RPI 646
		if (ez390_recursive_abort) { // RPI 935
			System.out.println("EZ390E abort recersive exit.");
			System.exit(16);
		}
		ez390_recursive_abort = true;
		_pz390.update_psa(); // RPI 1063
		if (tz390.z390_abort) {
			msg = "EZ390E abort for " + msg;
			tz390.put_systerm(msg);
			try { // rpi 560
				if (!put_stats_running) {  // RPI 646
					put_stats_running = true;
					put_stats();
				}
				close_files();
			} catch (final Exception e) {
				put_con("EZ390E close files failed");
			}
			System.exit(16);
		}
		tz390.z390_abort = true;
		ez390_errors++;
		if (ez390_rc == 0) {
			ez390_rc = 16;
		}
		stimer_exit_addr = 0; // RPI 471 cancel stimer exit
		final String error_msg = "EZ390E error " + tz390.right_justify("" + error,3) + " " + msg;
		put_log(error_msg);
		tz390.put_systerm(error_msg);
		if (!dump_taken && tz390.opt_dump) {
			dump_req(tz390.opt_dump);
		}
		exit_ez390();
	}

	/**
	 * Display total errors & close files and exit.
	 */
	public void exit_ez390() {
		final int r15_rc = _pz390.reg.getInt(pz390.r15); // RPI-39
		if (r15_rc > ez390_rc) {
			ez390_rc = r15_rc;
		}
		if  (ez390_errors > 0 || tz390.z390_abort) {
			ez390_rc = 16;
		}
		try {
			close_z390_guam();
		} catch (final Exception e) {
			put_con("EZ390E GUAM SHUTDOWN FAILED");
		}
		try {
			close_cmd(); // RPI-76
		} catch (final Exception e) {
			put_con("EZ390E CMDPROC SHUTDOWN FAILED");
		}
		try {
			tcpio_close_ports();
		} catch (final Exception e) {
			System.out.println("EZ390E TCPIO SHUTDOWN FAILED");
		}
		try {
			put_stats();
			close_files();
		} catch (final Exception e) {
			put_con("EZ390E CLOSE FILES FAILED");
		}
		System.exit(ez390_rc); //RPI39
	}

	/**
	 * If exit request, send shutdown request to z390 GUI via the sysout queue.
	 */
	private synchronized void close_z390_guam() { // RPI 397
		if (exit_request) {
			tz390.opt_trace  = false; // RPI 35
			tz390.z390_abort = true;  // RPI 208
			// send exit request to z390 GUI process
			put_con("exit_request");
		}
	}

	/**
	 * Display statistics as comments at end of BAL.
	 */
	private void put_stats() {
		if (tz390.opt_stats) {
			tz390.put_stat_final_options(); // rpi 755
			put_stat_line("TCPIO operations      = " + tot_tcpio_oper);
			if (tot_tcpio_oper > 0) { // RPI 566
				put_stat_line("TCPIO open client      = " + tot_tcpio_openc);
				put_stat_line("TCPIO open server     = " + tot_tcpio_opens);
				put_stat_line("TCPIO close_client    = " + tot_tcpio_closec);
				put_stat_line("TCPIO close server    = " + tot_tcpio_closes);
				put_stat_line("TCPIO send message    = " + tot_tcpio_send);
				put_stat_line("TCPIO receive message = " + tot_tcpio_recv);
			}
			put_stat_line("DCB operations        = " + tot_dcb_oper);
			if (tot_dcb_oper > 0) { // RPI 566
				put_stat_line("DCB open              = " + tot_dcb_open);
				put_stat_line("DCB close             = " + tot_dcb_close);
				put_stat_line("DCB get               = " + tot_dcb_get);
				put_stat_line("DCB put               = " + tot_dcb_put);
				put_stat_line("DCB read              = " + tot_dcb_read);
				put_stat_line("DCB write             = " + tot_dcb_write);
			}
			put_stat_line("VSAM operations       = " + _vz390.tot_vsam_oper);
			if (_vz390.tot_vsam_oper > 0) { // RPI 566
				put_stat_line("VSAM ACB open         = " + _vz390.tot_acb_open);
				put_stat_line("VSAM ACB close        = " + _vz390.tot_acb_close);
				put_stat_line("VSAM RPL get          = " + _vz390.tot_rpl_get);
				put_stat_line("VSAM RPL put          = " + _vz390.tot_rpl_put);
				put_stat_line("VSAM VXN find         = " + _vz390.tot_vxn_find);   // RPI 806
				put_stat_line("VSAM VXN max height   = " + _vz390.max_vxn_height); // RPI 806
				put_stat_line("VSAM AVL find         = " + _vz390.tot_avl_find);   // RPI 806
				put_stat_line("VSAM AVL max height   = " + _vz390.max_avl_height); // RPI 806
				put_stat_line("VSAM AVL insert tree  = " + _vz390.tot_avl_insert_ksit); // RPI 806
				put_stat_line("VSAM AVL insert record= " + _vz390.tot_avl_insert_ksir); // RPI 806
				if (_vz390.tot_avl_insert_ksir > 0) {
					put_stat_line("VSAM AVL rotate total = " + _vz390.tot_avl_rotate); // RPI 806
					put_stat_line("VSAM AVL rotate LL    = " + _vz390.tot_avl_rotate_ll); // RPI 806
					put_stat_line("VSAM AVL rotate LR    = " + _vz390.tot_avl_rotate_lr); // RPI 806
					put_stat_line("VSAM AVL rotate RR    = " + _vz390.tot_avl_rotate_rr); // RPI 806
					put_stat_line("VSAM AVL rotate RL    = " + _vz390.tot_avl_rotate_rl); // RPI 806
				}
				put_stat_line("VSAM ACB point        = " + _vz390.tot_rpl_point);
				put_stat_line("VSAM ACB erase        = " + _vz390.tot_rpl_erase);
				put_stat_line("VSAM VES read  cache  = " + _vz390.tot_ves_cache);
				put_stat_line("VSAM VES read  file   = " + _vz390.tot_ves_read);
				put_stat_line("VSAM VES write file   = " + _vz390.tot_ves_write);
				put_stat_line("VSAM VXN read  cache  = " + _vz390.tot_vxn_cache);
				put_stat_line("VSAM VXN read  file   = " + _vz390.tot_vxn_read);
				put_stat_line("VSAM VXN write file   = " + _vz390.tot_vxn_write);
			}
			put_stat_line("Keys                  = " + tz390.tot_key);
			put_stat_line("Key searches          = " + tz390.tot_key_search);
			if (tz390.tot_key_search > 0) {
				tz390.avg_key_comp = tz390.tot_key_comp/tz390.tot_key_search;
			}
			put_stat_line("Key avg comps         = " + tz390.avg_key_comp);
			put_stat_line("Key max comps         = " + tz390.max_key_comp);
			put_stat_line("total errors          = " + ez390_errors);
		}
		tz390.force_nocon = true; // RPI 755
		if (tz390.opt_timing) { // display instr rate
			_pz390.cur_date = new Date();
			tod_end_pgm = _pz390.cur_date.getTime();
			// final long tot_sec = (tod_end_pgm - tod_start_pgm)/1000; // JBA-unused
			final long ins_rate = ((long) tz390.systerm_ins)*1000/(tod_end_pgm - tod_start_pgm + 1);
			put_log("EZ390I instructions/sec     = " + ins_rate);
			if (tz390.opt_stats) {
				put_stat_line("instructions/sec      = " + ins_rate);
			}
		}
		put_log(msg_id + "total errors         = " + ez390_errors);
		tz390.force_nocon = false; // RPI 755
	}

	/**
	 * Routine statistics line to LOG or STATS(file).
	 * @param msg
	 */
	public void put_stat_line(final String msg) {
		if (tz390.stats_file != null) {
			tz390.put_stat_line(msg);
		} else {
			put_log(msg_id + msg);
		}
	}

	/**
	 * Close log, err, tre, xrd, xpr, xph, xgt, and xpt Assist files. RPI 812
	 */
	private synchronized void close_files() { // RPI 661
		tz390.force_nocon = true;
		tz390.set_ended_msg(ez390_rc); // RPI 837
		put_log(tz390.ended_msg);
		if (tz390.trace_file != null) {  // RPI 1050 move within force_nocon RPI 1149
			tz390.put_trace(tz390.ended_msg);
		}
		tz390.force_nocon = false;
		if (log_file != null && log_file.isFile()) {
			try {
				log_file_buff.close();
			} catch (final Exception e) {
				tz390.abort_error(3, "I/O error on log file close - " + e.toString()); // RPI 646
			}
		}
		ast_close_file(_pz390.ast_xread_tiot);
		ast_close_file(_pz390.ast_xprnt_tiot);
		ast_close_file(_pz390.ast_xpnch_tiot);
		ast_close_file(_pz390.ast_xget_tiot);
		ast_close_file(_pz390.ast_xput_tiot);
		tz390.close_trace_file();
		tz390.close_systerm(ez390_rc);
	}

	/**
	 * Cancel all active cmd processes.
	 */
	private void close_cmd() {
		int cmd_id = 0;
		while (cmd_id < max_cmd_proc) {
			if (cmd_processors[cmd_id].cmd_proc_running) { // RPI-592
				cmd_processors[cmd_id].cmd_cancel();
			}
			cmd_id++;
		}
	}

	/**
	 * Initialize pz390.cur_date and calendar with current time and date or force fixed time if NOTIMING option set.
	 * Notes:
	 *   1.  This NOTTIMING option is used in regression testing timing functions for repeatable results.
	 */
	public void init_time() {
		// int tod_hour  = 0;
		// int tod_min   = 0;
		// int tod_sec   = 0;
		// int tod_msec  = 0;  // 0-999 fraction of sec

//		final SimpleDateFormat cur_date_HH = new SimpleDateFormat("HH");
//		final SimpleDateFormat cur_date_mm = new SimpleDateFormat("mm");
//		final SimpleDateFormat cur_date_ss = new SimpleDateFormat("ss");

		
		Calendar cur_date_cal = null;

		cur_date_cal = new GregorianCalendar(1900,0,1);
		_pz390.ibm_mil = - cur_date_cal.getTime().getTime(); // milliseconds from 1900 to 1970

		if (tz390.opt_timing) { // measure and display timing
			_pz390.cur_date = new Date();
			cur_date_year  = Integer.valueOf(cur_date_yyyy.format(_pz390.cur_date));
			cur_date_month = Integer.valueOf(cur_date_MM.format(_pz390.cur_date));
			cur_date_day   = Integer.valueOf(cur_date_dd.format(_pz390.cur_date));
			// tod_hour    = Integer.valueOf(cur_date_HH.format(_pz390.cur_date));
			// tod_min     = Integer.valueOf(cur_date_mm.format(_pz390.cur_date));
			// tod_sec     = Integer.valueOf(cur_date_ss.format(_pz390.cur_date));
			// tod_msec    = Integer.valueOf(cur_date_ms.format(_pz390.cur_date));
			cur_date_cal   = new GregorianCalendar(cur_date_year,cur_date_month-1,cur_date_day);
			tod_start_day  = cur_date_cal.getTime().getTime();
			tod_start_pgm  = _pz390.cur_date.getTime();
			if (tz390.opt_time) {
				tod_time_limit = tz390.max_time_seconds *1000 + tod_start_pgm;
			}
		} else {
			cur_date_cal = new GregorianCalendar(2005,0,2,22,33,44);
			_pz390.cur_date = new Date(cur_date_cal.getTime().getTime()+567);
			cur_date_year  = Integer.valueOf(cur_date_yyyy.format(_pz390.cur_date));
			cur_date_month = Integer.valueOf(cur_date_MM.format(_pz390.cur_date));
			cur_date_day   = Integer.valueOf(cur_date_dd.format(_pz390.cur_date));
			// tod_hour    = Integer.valueOf(cur_date_HH.format(_pz390.cur_date));
			// tod_min     = Integer.valueOf(cur_date_mm.format(_pz390.cur_date));
			// tod_sec     = Integer.valueOf(cur_date_ss.format(_pz390.cur_date));
			// tod_msec    = Integer.valueOf(cur_date_ms.format(_pz390.cur_date));
			cur_date_cal   = new GregorianCalendar(cur_date_year,cur_date_month-1,cur_date_day);
			tod_start_day = cur_date_cal.getTime().getTime();
			tod_start_pgm = _pz390.cur_date.getTime();
		}
	}

	/**
	 * 1. Initialize test regular expression parser
	 * 2. Initialize optional test=ddname file for batch input else initialize test_cmd_file
	 *    which is also used for wtor replies when not in GUAM GUI mode
	 */
	public void init_test() {
		/*
		 * expression pattern
		 *   1. self defining terms
		 *         B'01'
		 *         C'ABC'
		 *         F'nnn'
		 *         H'nnn'
		 *         X'0F'
		 *   2. register
		 *         nr or nR
		 *   3. memory address
		 *         hex. for absolute memory address
		 *         dec  for decimal addr (for list len)
		 *         +hex or -hex for rel base address
		 *         *+hex or *-hex for rel instr. addr
		 *         nnr% for 24 bit indirect reg addr
		 *         nnR& for 31 bit indirect reg addr
		 *   3. break compare operators
		 *         =,<,>,!=,>=,<=
		 *   3. test commands (b,g,h,l,m,q,t)
		 *   4. test break opcode names
		 *   5. set operator =
		 */
		try {
			test_pattern = Pattern.compile(
					"([bB]['][0|1]+['])"				 // sdt
				+	"|([cC][']([^']|(['][']))*['])"		 // sdt ebcdic
				+	"|([cC][\"]([^\"]|([\"][\"]))*[\"])" // sdt ascii
				+	"|([fF]['][-]*[0-9]+['])"			 // sdt
				+	"|([hH]['][-]*[0-9]+['])"			 // sdt
				+	"|([xX]['][0-9a-fA-F]+['])"			 // sdt
				+ "|([0-9]+[rR][%?]*)"					 // reg addr
				+ "|([0-9a-fA-F]+[\\.])"				 // hex. addr
				+ "|([0-9]+)"							 // dec
				+ "|([a-zA-Z]+)"						 // cmd or opcode
				+ "|([!][=])|([>][=])|([<][=])"			 // set break compare operator RPI 650
				+ "|([=*+-?%<>])"						 // single operators RPI 650
				);
		} catch (final Exception e) {
			abort_error(56, "Test error in expression pattern - " + e.toString());
		}
		if (tz390.test_ddname != null && tz390.test_ddname.length() > 0) { // RPI 755
			test_file_name = get_ascii_env_var_string(tz390.test_ddname);
			tz390.fix_file_separators(test_file_name); // RPI 1080
			try {
				test_cmd_file = new BufferedReader(new FileReader(test_file_name));
			} catch (final Exception e) {
				abort_error(57, "Test input file for ddname " + tz390.test_ddname + " not found - " + test_file_name);
			}
		} else {
			test_cmd_file = new BufferedReader (new InputStreamReader(System.in));
		}
	}

	/**
	 * 1.  Set trace file for TRACE and TRACEALL<br>
	 * 2.  Open 390 and LST files
	 */
	public void open_files() {
		if (tz390.log_file_name.length() == 0) { // RPI 719  RPI 755
			tz390.log_file_name = tz390.get_file_name(tz390.dir_log,tz390.pgm_name,tz390.log_type); // RPI 866
		} else {
			tz390.log_file_name = tz390.dir_log + tz390.log_file_name + tz390.log_type;  // RPI 730
		}
		if (tz390.trace_file_name == null) { // RPI 719
			tz390.trace_file_name = tz390.dir_trc + tz390.pgm_name + tz390.tre_type;
		} else {
			tz390.trace_file_name = tz390.dir_trc + tz390.trace_file_name + tz390.tre_type;  // RPI 730
		}
		if (tz390.opt_list) {
			try {
				log_file = new File(tz390.log_file_name); // RPI 719 RPI 908
				log_file_buff = new BufferedWriter(new FileWriter(log_file));
			} catch (final Exception e) {
				abort_error(9, "I/O error on log file open - " + e.toString());
			}
		}
	}

	/**
	 * 1.  If stimer_exit_running then restore r13-r15 and exit to saved psw
	 * 2.  If stae exit running, restore psw and regs from zcvt_stae.
	 * 3.  If spie exit running, restore psw and regs from zcvt_epie
	 * 4.  exit to prev link return address or exit ez390 if none.
	 */
	private void svc_exit() {
		if (stimer_exit_running) {
			stimer_exit_running = false;
			_pz390.reg.putInt(pz390.r13,stimer_save_r13);
			_pz390.reg.putInt(pz390.r14,stimer_save_r14);
			_pz390.reg.putInt(pz390.r15,stimer_save_r15);
			_pz390.set_psw_loc(stimer_save_psw);
			if (tz390.opt_trace) {
				tz390.put_trace("TRACE STIMER EXIT ENDING");
			}
			return;
		} else if (_pz390.estae_exit_running) {
			final int estae_restart_psw = _pz390.reg.getInt(pz390.r0);
			final int estae_exit_rc = _pz390.reg.getInt(pz390.r15);
			_pz390.estae_last_ins_cnt = tz390.systerm_ins;
			_pz390.estae_exit_running = false;
			_pz390.psw_cc        = _pz390.estae_psw_cc;        // RPI 809
			_pz390.psw_amode     = _pz390.estae_psw_amode;     // RPI 809
			_pz390.psw_amode_bit = _pz390.estae_psw_amode_bit; // RPI 809
			_pz390.reg.position(0);
			_pz390.reg.put(_pz390.mem_byte, pz390.sdwa_g64,128); // RPI 845
			if (estae_exit_rc == 4) { // RPI 636 restart at ESTAPSW
				_pz390.set_psw_loc(estae_restart_psw);  // RPI 659
				if (tz390.opt_trace) {
					tz390.put_trace("ESTAE EXIT RESTART");
				}
			} else if (estae_exit_rc == 0) { // RPI 636 percolate to next higher ESTAE exit
				if (_pz390.tot_estae > 1) {  // RPI 636 percolate to next ESTAE exit
					_pz390.tot_estae--;      // RPI 636 purge ESTAE
					tot_link_stk = _pz390.estae_link[_pz390.tot_estae-1]; // RPI 636 reset link stack
					_pz390.setup_estae_exit();
				}
			} else { // abort due to invalid ESTAE exit RC
				abort_error(100, "ESTAE abort due to invalid return code = " + estae_exit_rc + ".");
			}
			return;
		} else if (_pz390.espie_exit_running) {
			_pz390.espie_last_ins_cnt = tz390.systerm_ins;
			_pz390.espie_exit_running = false;
			_pz390.psw_cc        = _pz390.espie_psw_cc;        // RPI 809
			_pz390.psw_amode     = _pz390.espie_psw_amode;     // RPI 809
			_pz390.psw_amode_bit = _pz390.espie_psw_amode_bit; // RPI 809
			_pz390.reg.position(0);
			_pz390.reg.put(_pz390.mem_byte, pz390.epie_gpr,128);
			_pz390.set_psw_loc(_pz390.mem.getInt(pz390.epie_psw+4));
			if (tz390.opt_trace) {
				tz390.put_trace("ESPIE EXIT ENDING");
			}
			return;
		}
		if (tot_link_stk == 1) {
			_pz390.set_psw_check(Constants.psw_pic_exit); // exit ez390
		} else {
			final int link_ret = link_stk_ret[tot_link_stk - 1];
			cur_cde      = link_stk_cde[tot_link_stk - 1];
			tot_link_stk--;
			delete_cur_cde();
			_pz390.set_psw_loc(link_ret);
			// exit to link caller in prior amode
			if ((link_ret & pz390.psw_amode31_bit) != 0) {
				_pz390.set_psw_amode(pz390.psw_amode31_bit);
			} else {
				_pz390.set_psw_amode(pz390.psw_amode24_bit);
			}
		}
	}

	/**
	 * Extract svc supports the following functions
	 *   r0 function
	 *    1 - GETENV get environment variable
	 *            input  r1=name with null terminator
	 *            output r2=getmain'd area value and null terminator
	 */
	private void svc_extract() { // RPI 413
		final int op = _pz390.reg.getInt(pz390.r0);
		switch (op) {
		case 1: // GETENV r1=name, r2 set to getmain'd value with null term
			env_name_addr = _pz390.reg.getInt(pz390.r1) & _pz390.psw_amode;
			env_name = get_ascii_string(env_name_addr,max_env_name_len,true);
			if (env_name.length() > 0) {
				env_value = get_ascii_env_var_string(env_name);
				if (env_value.length() > 0) {
					_pz390.reg.putInt(pz390.r0,0); // getmain below line
					_pz390.reg.putInt(pz390.r1,env_value.length()+1);
					svc_getmain();
					if (_pz390.reg.getInt(pz390.r15) == 0) {
						env_value_addr = _pz390.reg.getInt(pz390.r1);
						_pz390.reg.putInt(pz390.r2,env_value_addr);
						put_ascii_string(env_value,env_value_addr,env_value.length()+1,(char)0);
						if (tz390.opt_trace) {
							tz390.put_trace("GETENV NAME=" + env_name + " VALUE=" + env_value);
						}
					} else {
						return; // exit with rc = getmain error
					}
				} else {
					_pz390.reg.putInt(pz390.r15,4); // no value
				}
			} else {
				_pz390.reg.putInt(pz390.r15,8); // no name
			}
			break;
		default:
			_pz390.set_psw_check(Constants.psw_pic_spec);
		}
	}

	/**
	 * Load 390 load module into virtual memory.
	 */
	public void svc_load() {
		/*
		 * Input regs
		 *   1. r0  = 8 byte pgm name padded with spaces
		 *   2. r15 = 0 use SYS390 default path search
		 *   3. r15 = addr dsname if high bit off
		 *   4. r15 = addr ddname if high bit on
		 * Output regs:
		 *   1. r0  = address of 390 program entry
		 *            above or below line based on
		 *            lz390 rmode option and with
		 *            high bit indicating amode
		 *            based on lz390 amode option.
		 *            If not 390 file, r0 = load address
		 *   2. r1  = length of 390 file loaded in doubleword
		 *      count for OS compatiblity.
		 *      Length in bytes if not 390 file.
		 *   3. r15 = return code 0 ok or 4 if notfound
		 *   4. Add CDE to chian from CVTCDE else inc CVTUSE
		 *      for access by user pgms RPI 1063
		 *
		 * Notes:
		 *   1.  Add CDE entry for new entry else if already
		 *       loaded, increment cde_use and return
		 *       existing load address.
		 */
		load_dsn_addr = _pz390.reg.getInt(pz390.r15);
		load_pgm_dir =  tz390.dir_390; // RPI 244
		load_pgm_type = tz390.pgm_type;
		if (load_dsn_addr == 0) {
			load_pgm_name = get_ascii_string(_pz390.reg.getInt(pz390.r0),8,true);
		} else {
			if (!get_load_dsn(load_dsn_addr)) {
				_pz390.reg.putInt(pz390.r1,0);  // RPI102
				_pz390.reg.putInt(pz390.r15,4);
				return;
			}
		}
		cur_cde = tz390.find_key_index('P',load_pgm_name.toUpperCase() + load_pgm_type); // RPI 499
		if (cur_cde != -1 && cde_loc[cur_cde] != 0) {
			cde_use[cur_cde]++;
			if (cde_use[cur_cde] == 0) {
				cde_use[cur_cde] = (byte)0xff; // RPI 1063 no overflow
			}
			_pz390.mem_byte[cde_addr[cur_cde]+pz390.cde_cduse] = cde_use[cur_cde]; // RPI 1063 update count
			svc_load_set_regs();
			return;
		}
		load_file_name = tz390.find_file_name(load_pgm_dir,load_pgm_name,load_pgm_type,tz390.dir_cur);
		if (load_file_name == null) {
			_pz390.reg.putInt(pz390.r1,0); // RPI102
			_pz390.reg.putInt(pz390.r15,4);
			return;
		}
		if (load_pgm_type.equals(tz390.z390_type)) {
			svc_load_390();
		} else {
			svc_load_file();
		}
	}

	/**
	 * Set r0, r1, and r15 for load.
	 */
	private void svc_load_set_regs() {
		_pz390.reg.putInt(pz390.r0,cde_ent[cur_cde]);  // RPI 732
		if (cde_ent[cur_cde] != -1) {
			_pz390.reg.putInt(pz390.r1,cde_len[cur_cde] >>> 3); // RPI 102 390 double words
		} else {
			_pz390.reg.putInt(pz390.r1,cde_len[cur_cde]); // RPI 102 non 390 byte count
		}
		_pz390.reg.putInt(pz390.r15,0);
	}

	/**
	 * Load 390 file, relocate, and set r1 length in double words.
	 */
	private void svc_load_390() {
		try {
			z390_file = new RandomAccessFile(load_file_name,"r");
			if (z390_file.length() <= 10) {
				z390_file.seek(0);
				load_pgm_name = z390_file.readLine().toUpperCase();
				load_file_name = tz390.find_file_name(load_pgm_dir,load_pgm_name,load_pgm_type,tz390.dir_cur);
				if (load_file_name == null) {
					abort_error(118, "ALIAS LOAD FAILED FOR " + load_pgm_name);
				}
				z390_file = new RandomAccessFile(load_file_name,"r");
			}
			z390_file.seek(0);
			load_code_ver[0] = tz390.ascii_table.charAt(z390_file.read());
			load_code_ver[1] = tz390.ascii_table.charAt(z390_file.read());
			load_code_ver[2] = tz390.ascii_table.charAt(z390_file.read());
			load_code_ver[3] = tz390.ascii_table.charAt(z390_file.read());
			z390_flags[0]    = tz390.ascii_table.charAt(z390_file.read());
			z390_flags[1]    = tz390.ascii_table.charAt(z390_file.read());
			z390_flags[2]    = tz390.ascii_table.charAt(z390_file.read());
			z390_flags[3]    = tz390.ascii_table.charAt(z390_file.read());
			load_code_len    = z390_file.readInt();
			load_code_ent    = z390_file.readInt();
			load_code_rlds   = z390_file.readInt();
			tz390.systerm_io = tz390.systerm_io + 11;
			if (z390_flags[z390_flags_rmode31] == 'T') {
				_pz390.reg.putInt(pz390.r0,opt_getmain_amode31); // getmain above line
			} else {
				_pz390.reg.putInt(pz390.r0,0); // getmain below line
			}
			_pz390.reg.putInt(pz390.r1,load_code_len);
			svc_getmain();
			if (_pz390.reg.getInt(pz390.r15) == 0) {
				load_code_load = _pz390.reg.getInt(pz390.r1); // RPI 542
				tz390.systerm_io++;
				z390_file.read(_pz390.mem_byte,load_code_load,load_code_len);
				load_code_ent = load_code_ent + load_code_load;
			} else {
				abort_error(15, "Getmain for svc 8 load failed - PGM=" + tz390.pgm_name + "LEN=" + load_code_len);
			}
			svc_load_rlds();
			z390_file.close();
			if (z390_flags[z390_flags_amode31] == 'T') {
				load_code_ent  = load_code_ent  | pz390.psw_amode31_bit;
				load_code_load = load_code_load | pz390.psw_amode31_bit;
			}
			add_cde();
			svc_load_set_regs();
		} catch (final Exception e) {
			abort_error(18, "I/O error on 390 load module file - " + e.toString());
		}
	}

	/**
	 * Read and apply rld records at end of 390 file.
	 */
	private void svc_load_rlds() {
		int rld_field = 0;
		try {
			int cur_rld = 0;
			while (cur_rld < load_code_rlds) {
				tz390.systerm_io++;
				rld_loc = z390_file.readInt();
				tz390.systerm_io++;
				rld_len = z390_file.readByte();
				switch (rld_len) {
				case 2: // RPI 894
					_pz390.mem.position(load_code_load + rld_loc);
					rld_field = _pz390.mem.getInt();
					rld_field = (rld_field >>> 16) + load_code_load;
					if (rld_field > 0xffff) { // RPI 894
						abort_error(120, "Loader 2 byte RLD address too high in - " + tz390.pgm_name);
					}
					_pz390.mem.position(load_code_load + rld_loc);
					_pz390.mem.putShort((short)(rld_field));
					break;
				case 3: //RPI71
					_pz390.mem.position(load_code_load + rld_loc);
					rld_field = _pz390.mem.getInt();
					rld_field = (rld_field >>> 8) + load_code_load;
					if (rld_field > 0xffffff) { // RPI 894
						abort_error(121, "Loader 3 byte RLD address too high in - " + tz390.pgm_name);
					}
					_pz390.mem.position(load_code_load + rld_loc);
					_pz390.mem.putShort((short)(rld_field >>> 8));
					_pz390.mem.put((byte)(rld_field & 0xff));
					break;
				case 4:
					_pz390.mem.position(load_code_load + rld_loc);
					rld_field = _pz390.mem.getInt();
					rld_field = rld_field + load_code_load;
					_pz390.mem.position(load_code_load + rld_loc);
					_pz390.mem.putInt(rld_field);
					break;
				case 8: // RPI 270
					rld_loc = rld_loc + 4;
					_pz390.mem.position(load_code_load + rld_loc);
					rld_field = _pz390.mem.getInt();
					rld_field = rld_field + load_code_load;
					_pz390.mem.position(load_code_load + rld_loc);
					_pz390.mem.putInt(rld_field);
					break;
				default:
					abort_error(119, "Invalid RLD length in load module -" + tz390.pgm_name);
				}
				cur_rld++;
			}
		} catch (final Exception e) {
			abort_error(86, "Svc 8 I/O error reading RLD");
		}
	}

	/**
	 * Load non 390 file.
	 */
	private void svc_load_file() {
		/*
		 * 1. Load non 390 file
		 * 2. Set cde_pgm to file_name
		 * 3. Set cde_loc to load address
		 * 4. Set cde_len to length in bytes
		 * 5. Set cde_ent to -1
		 * 6. Set R0 to load address
		 * 7. Set r1 to length in bytes
		 */
		try {
			z390_file = new RandomAccessFile(load_file_name,"r");
			if (z390_file.length() > _pz390.tot_mem - _pz390.tot_mem_alloc) {
				abort_error(85, "File size exceeds available memory ");
			}
			load_code_len = (int) z390_file.length();
			z390_file.seek(0);
			if (_pz390.psw_amode == pz390.psw_amode31) {  // load file above line if amode31
				_pz390.reg.putInt(pz390.r0,opt_getmain_amode31);
			} else {
				_pz390.reg.putInt(pz390.r0,0);  // load below line
			}
			_pz390.reg.putInt(pz390.r1,load_code_len);
			svc_getmain();
			if (_pz390.reg.getInt(pz390.r15) == 0) {
				load_code_load = _pz390.reg.getInt(pz390.r1);  // RPI 542
				load_code_ent  = -1; // no entry for files;
				tz390.systerm_io++;
				z390_file.read(_pz390.mem_byte,load_code_load,load_code_len);
				if (_pz390.psw_amode == pz390.psw_amode31) {
					load_code_load = load_code_load | pz390.psw_amode31_bit;
				}
			} else {
				abort_error(15, "Getmain for svc 8 load failed - PGM=" + tz390.pgm_name + "LEN=" + load_code_len);
			}
			z390_file.close();
			add_cde();
			svc_load_set_regs();
		} catch (final Exception e) {
			abort_error(18, "I/O error on 390 load module file - " + e.toString());
		}
	}

	/**
	 * Delete current module and then load and then balr to 390 load module.
	 */
	private void svc_xctl() {
		/*
		 * Input:
		 *   1. r0  = addr pgm name
		 *   2. r1  = user parms
		 * 	 2. r15 = 0 use SYS390 default path search
		 *   3. r15 = addr dsname if high bit off
		 *   4. r15 = addr ddname if high bit on
		 * Output:
		 *   1. r15 = user pgm return code if call ok
		 *   2. abend s106
		 */
		final int user_parm = _pz390.reg.getInt(pz390.r1); // RPI 596 RPI 598
		svc_load();
		if (_pz390.reg.getInt(pz390.r15) != 0) {
			if (_pz390.tot_estae == 0) {
				log_error(102, "xctl program not found - " + load_pgm_name);
			}
			_pz390.set_psw_check(Constants.psw_pic_link_err); // link failed
			return;
		}
		final int link_addr = _pz390.reg.getInt(pz390.r0);
		if (_pz390.reg.getInt(pz390.r15) == 0) {
			final int save_new_cde = cur_cde;
			cur_cde = link_stk_cde[tot_link_stk-1]; // RPI 598
			delete_cur_cde();
			link_stk_cde[tot_link_stk-1] = save_new_cde; // RPI 610
			_pz390.reg.putInt(pz390.r14, pz390.zcvt_exit);
			_pz390.reg.putInt(pz390.r15, link_addr);
			_pz390.reg.putInt(pz390.r1, user_parm); // RPI 596
			_pz390.set_psw_loc(link_addr);
			if ((link_addr & pz390.psw_amode31_bit) != 0) {
				_pz390.set_psw_amode(pz390.psw_amode31_bit);
			} else {
				_pz390.set_psw_amode(pz390.psw_amode24_bit);
			}
		}
	}

	/**
	 * Set DSN from addr DDNAM with high bit or from addr DSNAM.
	 * @param dd_dsn_addr
	 * @return
	 */
	public boolean get_load_dsn(int dd_dsn_addr) {
		/*
		 * 1.  If vcdt_load then strip .xxx and set vcdt_entry = xxx else set to ACBNAME RPI 691
		 * 2.  Set following from ddname/dsname load_pgm_dir (overrides dir_390 default) RPI 244
		 *    load_pgm_name
		 *    load_pgm_type
		 * 3. Return true if ok else false.
		 * Notes:
		 *   1.  If dir_addr high bit on, get user list from 8 byte ddname env. var. at dir_addr
		 *       else get user list from dir_addr with null delimited or double quote delimiter.
		 */
		load_pgm_type = tz390.z390_type;
		if (dd_dsn_addr < 0) {
			final String ddname = get_ascii_string(dd_dsn_addr & 0x7fffffff,8,true);
			load_dsn = get_ascii_env_var_string(ddname);
			if (load_dsn == null || load_dsn.length() == 0) {
				log_error(82, "DDNAME=" + ddname + " not defined");
				return false;
			}
		} else {
			load_dsn = tz390.get_ascii_var_string(_pz390.mem_byte,dd_dsn_addr,max_dir_list);
			if (load_dsn == null || load_dsn.length() == 0) {
				log_error(83, "DSNAME invalid field at " + tz390.get_hex(dd_dsn_addr,8));
				return false;
			}
		}
		load_dsn = tz390.fix_file_separators(load_dsn); // RPI 1080
		int index = load_dsn.indexOf(";");
		if (index != -1) { // dsn is dir list vs file spec
			load_pgm_dir = load_dsn;
			if (!get_eploc_pgm_name()) {
				return false;
			}
		} else { // may be path with or without file name
			index = load_dsn.indexOf(".");
			if (load_vcdt_mode) {
				if (index > 0) {
					load_vcdt_entry = load_dsn.substring(index+1);
				} else {
					load_vcdt_entry = _vz390.cur_acb_vclrn;
				}
				load_dsn = load_dsn.substring(0,index).concat(tz390.z390_type);
			}
			if (!load_dsn.substring(0,1).equals(File.separator)
			  && load_dsn.charAt(1) != ':') {
				load_dsn = tz390.dir_cur + load_dsn; // RPI 713
			}
			if (tz390.opt_trace) {
				tz390.put_trace("LOAD DSN=" + load_dsn);
			}
			final File temp_file = new File(load_dsn);
			if (temp_file.isFile()) {
				load_pgm_name = temp_file.getName();
				index = load_pgm_name.indexOf(".");
				if (index > 0) {
					load_pgm_type  = load_pgm_name.substring(index);
					load_pgm_name = load_pgm_name.substring(0,index);
				} else {
					load_pgm_type = "";
				}
				load_pgm_dir = temp_file.getPath();
				index = load_pgm_dir.lastIndexOf(File.separator);
				if (index > 0) {
					load_pgm_dir = load_pgm_dir.substring(0,index);
				}
				return true;
			} else if (temp_file.isDirectory()) {
				load_pgm_dir  = temp_file.getPath();
				if (!get_eploc_pgm_name()) {
					return false;
				}
			} else {
				return false;
			}
		}
		return true;
	}

	/**
	 * Set load_pgm_name from r0 else error.
	 * @return
	 */
	private boolean get_eploc_pgm_name() {
		final int ep_loc = _pz390.reg.getInt(pz390.r0) & _pz390.psw_amode;
		if (ep_loc != 0) {
			load_pgm_name = get_ascii_string(ep_loc,8,true);
			return true;
		} else {
			log_error(87,"no program or file name found");
			return false;
		}
	}

	/**
	 * Delete loaded pgm/dsn from irtual memory if use count 0 after decrement.
	 */
	private void svc_delete() {
		/*
		 * Input regs
		 *   1. r0  = 8 byte pgm name padded with spaces
		 *   2. r15 = 0 use SYS390 default path search
		 *   3. r15 = addr dsname if high bit off
		 *   4. r15 = addr ddname if high bit on
		 * Output regs:
		 *   1.  r15 = 0 if successfully deleted
		 *   2.  r15 = 4 if not found in memory
		 */
		load_dsn_addr = _pz390.reg.getInt(pz390.r15);
		load_pgm_dir  = tz390.dir_390;
		load_pgm_type = tz390.z390_type;
		if (load_dsn_addr == 0) {
			load_pgm_name = get_ascii_string(_pz390.reg.getInt(pz390.r0),8,true);
		} else {
			if (!get_load_dsn(load_dsn_addr)) {
				_pz390.reg.putInt(pz390.r15,4);
				return;
			}
		}
		cur_cde = tz390.find_key_index('P',load_pgm_name.toUpperCase() + load_pgm_type); // RPI 499
		if (cur_cde != -1
		 && !find_link_cde()   // RPI 626
		 && delete_cur_cde()) {
			_pz390.reg.putInt(pz390.r15,0);
		} else {
			_pz390.reg.putInt(pz390.r15,4);
		}
	}

	/**
	 * Return true if cur_cde is on link stack else false.
	 * Used to prevent deleting link entries. RPI 626
	 * @return
	 */
	private boolean find_link_cde() {
		int index = 0;
		while (index < tot_link_stk) {
			if (cur_cde == link_stk_cde[index]) {
				return true;
			}
			index++;
		}
		return false;
	}

	/**
	 * decrement use count for cur_cde
	 * @return
	 */
	private boolean delete_cur_cde() {
		/*
		 * if use count 0
		 *    freemain memory
		 *    set cde_loc to 0 to release cde entry
		 *    return true
		 * else
		 *    return false
		 */
		if (cur_cde != -1 && cde_loc[cur_cde] != 0) {
			cde_use[cur_cde]--;
			_pz390.mem_byte[cde_addr[cur_cde]+pz390.cde_cduse] = cde_use[cur_cde]; // RPI 1063 update CDE use count in mem
			if  (cde_use[cur_cde] < 1) {
				_pz390.reg.putInt(pz390.r1,cde_loc[cur_cde]); // RPI 244
				_pz390.reg.putInt(pz390.r0,cde_len[cur_cde]); // RPI 244
				svc_freemain();
				cde_loc[cur_cde] = 0;
			}
			return true;
		} else {
			abort_error(88, "Delete cde system error");
			return false;
		}
	}

	/**
	 * Add new 390 load module to cde entry table and set usage to 1.
	 */
	private void add_cde() {
		cur_cde = tz390.find_key_index('P',load_pgm_name.toUpperCase() + load_pgm_type); // RPI 499
		if (cur_cde == -1) {
			if (tot_cde < max_cde_pgms) {
				cur_cde = tot_cde;
				tot_cde++;
				if (!tz390.add_key_index(cur_cde)) {
					abort_error(21, "Key search table exceeded");
				}
			} else {
				abort_error(55, "CDE maximum 390 load modules exceeded");
				return;
			}
		}
		cde_name[cur_cde] = load_pgm_name + load_pgm_type;
		cde_file[cur_cde] = load_file_name;  // RPI 668
		cde_use[cur_cde]  = 1;
		cde_len[cur_cde]  = load_code_len;
		cde_loc[cur_cde] = load_code_load;
		cde_ent[cur_cde] = load_code_ent;
		if (tz390.opt_trace) {
			tz390.put_trace(" CDE "
						  + "LOAD="  + tz390.get_hex(load_code_load,8)
						  + " LEN="  + tz390.get_hex(load_code_len,8)
						  + " NAME=" + load_file_name); // RPI 1051
		}
		if (cde_addr[cur_cde] == 0) {
			_pz390.reg.putInt(pz390.r1,cded_len); // RPI 1063
			svc_getmain();
			if (_pz390.reg.getInt(pz390.r15) == 0) {
				cde_addr[cur_cde] = _pz390.reg.getInt(pz390.r1);
			} else {
				abort_error(123, "Error allocating CDE for LOAD");
			}
			_pz390.mem.putInt(cde_addr[cur_cde]+pz390.cde_cdchain,_pz390.mem.getInt(pz390.cvt_cde));
			_pz390.mem.putInt(pz390.cvt_cde,cde_addr[cur_cde]);
			_pz390.mem.putInt(cde_addr[cur_cde]+pz390.cde_cdentpt,load_code_ent);
			put_ascii_string(cde_name[cur_cde],cde_addr[cur_cde]+pz390.cde_cdname,8,' ');
			_pz390.mem.put(cde_addr[cur_cde]+pz390.cde_cduse,cde_use[cur_cde]);
			_pz390.mem.putInt(cde_addr[cur_cde]+pz390.cde_cdloadpt,load_code_load);
			_pz390.mem.putInt(cde_addr[cur_cde]+pz390.cde_cdmodlen,load_code_len);
		}
	}

	/**
	 * load and then balr to 390 load module
	 */
	public void svc_link() {
		/*
		 * Input:
		 *   1. r0  = addr pgm name
		 *   2. r1  = user parms
		 * 	 2. r15 = 0 use SYS390 default path search
		 *   3. r15 = addr dsname if high bit off
		 *   4. r15 = addr ddname if high bit on
		 * Output:
		 *   1. r15 = user pgm return code if call ok
		 *   2. abend s106
		 *   3. On first load with option GUAM on,
		 *      the gz390 GUAM GUI window will be staretd
		 *      with default title using program name
		 */
		int save_r1 = _pz390.reg.getInt(pz390.r1);
		svc_load();
		_pz390.reg.putInt(pz390.r1,save_r1);
		if (_pz390.reg.getInt(pz390.r15) != 0) {
			if (_pz390.tot_estae == 0) {
				log_error(103,"LINK program not found - " + load_pgm_name);
			}
			_pz390.set_psw_check(Constants.psw_pic_link_err); // link failed
			return;
		}
		if (ez390_pgm == null) {
			ez390_pgm = load_pgm_name; // save first pgm
			if (tz390.opt_guam) {
				gz390 = new gz390();
				gz390.start_guam(ez390_pgm,tz390);
				if (tz390.z390_abort) {
					abort_error(58, "GUAM GUI startup abort");
				}
			}
		}
		final int link_addr = _pz390.reg.getInt(pz390.r0);
		if (_pz390.reg.getInt(pz390.r15) == 0) {
			if (tot_link_stk < max_link_stk) {
				link_stk_cde[tot_link_stk] = cur_cde; // set by load RPI-610
				link_stk_ret[tot_link_stk] = _pz390.psw_loc | _pz390.psw_amode_bit; // RPI-610
				tot_link_stk++; // RPI 610
			}
			_pz390.reg.putInt(pz390.r14, pz390.zcvt_exit);
			_pz390.reg.putInt(pz390.r15, link_addr);
			_pz390.set_psw_loc(link_addr);
			if ((link_addr & pz390.psw_amode31_bit) != 0) {
				_pz390.set_psw_amode(pz390.psw_amode31_bit);
			} else {
				_pz390.set_psw_amode(pz390.psw_amode24_bit);
			}
		}
	}

	/**
	 * 
	 */
	public void svc_getmain() {
		/*
		 * Input
		 *   1.  R1 = length to allocate
		 *   2.  R0 = options
		 *         bit 0 allocate memory above the line
		 *   3.  If tz390.opt_loadhigh alloc from top down else bottom up
		 *       RPI 819 for assist
		 * Output:
		 *   1.  Set r0 to length of allocated area rounded to *8 // RPI 542 (was address)
		 *   2.  set r1 to address of area                        // RPI 542 not set previously
		 *   3.  set r15 to 0 of ok, else nz
		 *   4.  set max_mem_blk to largest contig blk for use by sort etc. RPI 1092
		 * Notes:
		 *   1.  Use TRACEMEM option to trace FQE's
		 *   2.  If no 31 bit memory then allocate from 24 bit memory else abort if requested
		 *       memory type no available.
		 *   3.  Select best fit from available blocks RPI 1153
		 *       a.  Same size block to reduce fragmentation
		 *       b.  Smallest block > requested len to save largest
		 */
		max_mem_blk = 0; // RPI 1092
		req_len = _pz390.reg.getInt(pz390.r1);
		req_len = (req_len + 7)/8*8; // round to 8
		if (req_len <= 0) {
			_pz390.set_psw_check(Constants.psw_pic_gm_err);
			return;
		}
		req_opt = _pz390.reg.getInt(pz390.r0);
		if ((req_opt & opt_getmain_amode31) != 0
		 && _pz390.dsa31_start != 0) {
			cur_fqe = _pz390.mem.getInt(pz390.zcvt_fqe31);
			prev_fqe = pz390.zcvt_fqe31;
		} else {
			cur_fqe = _pz390.mem.getInt(pz390.zcvt_fqe24);
			prev_fqe = pz390.zcvt_fqe24;
		}
		best_cur_fqe  = 0;
		best_prev_fqe = 0;
		best_fqe_len  = 0;
		while (cur_fqe > 0) {
			cur_fqe_len = _pz390.mem.getInt(cur_fqe+4);
			if (!check_fqe_ok()) {
				return;
			}
			if (cur_fqe_len >= req_len) {
				if (cur_fqe_len == req_len) {
					alloc_from_fqe();
					_pz390.tot_mem_alloc = _pz390.tot_mem_alloc + req_len;
					_pz390.reg.putInt(pz390.r15,0);
					return;
				} else if (best_cur_fqe == 0 || cur_fqe_len < best_fqe_len) {
					best_cur_fqe = cur_fqe;
					best_prev_fqe = prev_fqe;
					best_fqe_len  = cur_fqe_len;
				}
			}
			if (cur_fqe_len > max_mem_blk) {
				max_mem_blk = cur_fqe_len; // RPI 1092
			}
			prev_fqe = cur_fqe;
			cur_fqe = _pz390.mem.getInt(cur_fqe);
		}
		if (best_cur_fqe > 0) {
			cur_fqe  = best_cur_fqe;
			prev_fqe = best_prev_fqe;
			cur_fqe_len = best_fqe_len;
			alloc_from_fqe();
			_pz390.tot_mem_alloc = _pz390.tot_mem_alloc + req_len;
			_pz390.reg.putInt(pz390.r15,0);
			return;
		}
		_pz390.reg.putInt(pz390.r15,4); //RPI191
		if ((req_opt & opt_getmain_cond) == 0) {
			_pz390.set_psw_check(Constants.psw_pic_no_mem);
		}
	}

	/**
	 * Allocate memory for GETMAIN from current FQE.
	 */
	private void alloc_from_fqe() {
		next_fqe = _pz390.mem.getInt(cur_fqe); // RPI 1153
		if (tz390.opt_loadhigh) {
			// allocate from high end of cur_fqe
			cur_fqe_len = cur_fqe_len - req_len;
			_pz390.reg.putInt(pz390.r0,req_len);               // RPI 542
			_pz390.reg.putInt(pz390.r1,cur_fqe + cur_fqe_len); // RPI 542
			if (tz390.opt_traceg) {
				trace_mem("GETMAIN ",cur_fqe+cur_fqe_len,req_len,0);
			}
			if (cur_fqe_len > 0) {
				_pz390.mem.putInt(cur_fqe+4,cur_fqe_len);
				if (tz390.opt_traceg) {
					trace_mem("FQE UPDT",cur_fqe,cur_fqe_len,next_fqe);
				}
			} else {
				if (tz390.opt_traceg) {
					trace_mem("FQE DEL ",cur_fqe,req_len,next_fqe);
				}
				_pz390.mem.putInt(prev_fqe,next_fqe);
			}
		} else {
			// allocate from bottom up  RPI819
			cur_fqe_len = cur_fqe_len - req_len;
			_pz390.reg.putInt(pz390.r0,req_len); // RPI-0542
			_pz390.reg.putInt(pz390.r1,cur_fqe);
			if (tz390.opt_traceg) {
				trace_mem("GETMAIN ",cur_fqe,req_len,0);
			}
			if (cur_fqe_len > 0) {
				_pz390.mem.putInt(prev_fqe,cur_fqe + req_len);
				_pz390.mem.putInt(cur_fqe + req_len,next_fqe);
				_pz390.mem.putInt(cur_fqe + req_len +4,cur_fqe_len);
				if (tz390.opt_traceg) {
					trace_mem("FQE UPDT",cur_fqe + req_len,cur_fqe_len,next_fqe);
				}
			} else {
				// alloc entire FQE
				if (tz390.opt_traceg) {
					trace_mem("FQE DEL ",cur_fqe,req_len,next_fqe);
				}
				_pz390.mem.putInt(prev_fqe,next_fqe);
			}
		}
	}

	/**
	 * 
	 */
	public void svc_freemain() {
		/*
		 * Input
		 *   1.  r0 = length  to return  RPI 244
		 *   2.  r1 = address to return  RPI 244
		 *
		 * Output:
		 *   1.  set r15 to 0 of OK, else abort
		 */
		req_addr = _pz390.reg.getInt(pz390.r1) & pz390.psw_amode31; // RPI-0244
		req_len  = _pz390.reg.getInt(pz390.r0); // RPI-0244
		req_len = (req_len + 7)/8*8; // round to 8
		if (req_addr < _pz390.dsa24_end) {
			if (   req_len <= 0
				|| (req_addr & 0x7) != 0
				|| req_addr < _pz390.dsa24_start
				|| req_addr + req_len  > _pz390.dsa24_end
				) {
				_pz390.set_psw_check(Constants.psw_pic_fm_err);
				return;
			}
			cur_fqe = _pz390.mem.getInt(pz390.zcvt_fqe24);
			prev_fqe = pz390.zcvt_fqe24;
		} else {
			if (req_len <= 0
				|| (req_addr & 0x7) != 0
				|| req_addr < _pz390.dsa31_start
				|| req_addr + req_len  > _pz390.dsa31_end
				) {
				_pz390.set_psw_check(Constants.psw_pic_fm_err);
				return;
			}
			cur_fqe = _pz390.mem.getInt(pz390.zcvt_fqe31);
			prev_fqe = pz390.zcvt_fqe31;
		}
		while (cur_fqe > 0) {
			next_fqe    = _pz390.mem.getInt(cur_fqe);
			cur_fqe_len = _pz390.mem.getInt(cur_fqe+4);
			if (!check_fqe_ok()) {
				return;
			}
			if (req_addr < cur_fqe) {
				// insert after prior fqe or cvt
				if (tz390.opt_traceg) {
					trace_mem("FREEMAIN",req_addr,req_len,0);
				}
				if (req_addr + req_len == cur_fqe) {
					// merge insert with cur_fqe
					_pz390.mem.putInt(req_addr,next_fqe);
					_pz390.mem.putInt(req_addr+4,req_len + cur_fqe_len); // RPI 491 (was + cur_fqe)
					if (tz390.opt_traceg) {
						trace_mem("FQE IMRG",req_addr,req_len+cur_fqe,next_fqe);
					}
				} else {
					_pz390.mem.putInt(req_addr,cur_fqe);
					_pz390.mem.putInt(req_addr+4,req_len);
					if (tz390.opt_traceg) {
						trace_mem("FQE INST",req_addr,req_len,cur_fqe);
					}
				}
				_pz390.mem.putInt(prev_fqe,req_addr);
				_pz390.tot_mem_alloc = _pz390.tot_mem_alloc - req_len;
				_pz390.reg.putInt(pz390.r15,0);
				return;
			} else if (req_addr == cur_fqe + cur_fqe_len) {
				// append to current fqe
				if (tz390.opt_traceg) {
					trace_mem("FREEMAIN",req_addr,req_len,0);
				}
				cur_fqe_len = cur_fqe_len + req_len;
				if (cur_fqe + cur_fqe_len == next_fqe) {
					// merge cur and next fqe's
					next_fqe_len = _pz390.mem.getInt(next_fqe+4);
					next_fqe = _pz390.mem.getInt(next_fqe);
					_pz390.mem.putInt(cur_fqe,next_fqe);
					_pz390.mem.putInt(cur_fqe+4,cur_fqe_len+next_fqe_len);
					if (tz390.opt_traceg) {
						trace_mem("FQE MRGE",cur_fqe,req_len,next_fqe);
					}
				} else if (next_fqe > 0
						&& cur_fqe + cur_fqe_len > next_fqe) {
					_pz390.set_psw_check(Constants.psw_pic_bad_mem);
					return;
				} else {
					_pz390.mem.putInt(cur_fqe+4,cur_fqe_len);
				}
				_pz390.tot_mem_alloc = _pz390.tot_mem_alloc - req_len;
				_pz390.reg.putInt(pz390.r15,0);
				return;
			} else if (req_addr > cur_fqe + cur_fqe_len) {
				prev_fqe = cur_fqe;
				cur_fqe = next_fqe;
			} else {
				// abort due to memory corruption
				_pz390.set_psw_check(Constants.psw_pic_bad_mem);
				return;
			}
		}
		// insert after last fqe or cvt
		if (tz390.opt_traceg) {
			trace_mem("FREEMAIN",req_addr,req_len,0);
		}
		_pz390.mem.putInt(req_addr,0);
		_pz390.mem.putInt(req_addr+4,req_len);
		_pz390.mem.putInt(prev_fqe,req_addr);
		if (tz390.opt_traceg) {
			trace_mem("FQE ADD ",prev_fqe,cur_fqe_len,req_addr); // RPI 1153
			trace_mem("FQE ADD ",req_addr,req_len,0);
		}
		_pz390.tot_mem_alloc = _pz390.tot_mem_alloc - req_len;
		_pz390.reg.putInt(pz390.r15,0);
	}

	/**
	 * Trace fqe if option tracemem on and verify address and length ok.
	 * @return
	 */
	private boolean check_fqe_ok() {
		if (tz390.opt_traceg) {
			trace_mem("FQE     ",cur_fqe,cur_fqe_len,next_fqe);
		}
		if (cur_fqe <= prev_fqe
		|| (cur_fqe & 0x7) != 0
		|| cur_fqe_len <= 0
		|| (cur_fqe_len & 0x7) != 0) {
			_pz390.set_psw_check(Constants.psw_pic_bad_mem);
		return false;
		}
	return true;
	}

	/**
	 * 
	 * @param mem_type
	 * @param mem_addr
	 * @param mem_len
	 * @param mem_nxt
	 */
	private void trace_mem(String mem_type,int mem_addr,int mem_len,int mem_nxt) {
		tz390.put_trace("TRACE MEMORY " + mem_type
					  + " LOC=" + tz390.get_hex(mem_addr,8)
					  + " LEN=" + tz390.get_hex(mem_len,8)
					  + " NXT=" + tz390.get_hex(mem_nxt,8)
					);
	}

	/**
	 * Return time and date in requested format.
	 * See TIME.MAC for additional information.
	 */
	private void svc_time() {
		/*
		 *   R0 LH = date type
		 *   R0 LL = time type
		 *   R1    = storage address for MIC,STCK,STCKE
		 *
		 * Notes:
		 *   1.  When option NOTIMING is specified,
		 *       the time and date are fixed at
		 *         TOD  = 22:33:44:567 milliseconds
		 *         DATE = 2005.002 (Jan 2, 2005)
		 *       This is used for regression testing date
		 *       and time functions by comparing expected
		 *       time and date output.
		 *   2.  See mac\TIME.MAC for documentation. RPI 825
		 */
		final int date_type = _pz390.reg.getShort(pz390.r0);
		final int time_type = _pz390.reg.getShort(pz390.r0+2);
		final int time_addr = _pz390.reg.getInt(pz390.r1) & _pz390.psw_amode;
		if (tz390.opt_timing) {
			_pz390.cur_date = new Date();
		}
		time_mil  = _pz390.cur_date.getTime();
		_pz390.reg.putInt(pz390.r15,0);  // RPI 717
		switch (time_type) {
		case 0: // dec
			_pz390.reg.putInt(pz390.r0,Integer.valueOf(cur_tod_hhmmss00.format(_pz390.cur_date),16)
									 +(Integer.valueOf(cur_date_ms.format(_pz390.cur_date),16) >> 4));
			_pz390.reg.putInt(pz390.r1,get_ccyydddf());
			return;
		case 1: // bin - 0.01 sec = (milliseconds/10)
			_pz390.reg.putInt(pz390.r0,(int)((time_mil-tod_start_day)/10));
			_pz390.reg.putInt(pz390.r1,get_ccyydddf());
			return;
		case 2: // tu - 26.04166 mic (milliseconds * 1000 / 26.04166)
			_pz390.reg.putInt(pz390.r0,(int)((time_mil-tod_start_day)*1000*100000/2604166));
			_pz390.reg.putInt(pz390.r1,get_ccyydddf());
			return;
		case 3: // mic - double word microseconds
			_pz390.mem.putLong(time_addr,(time_mil-tod_start_day)*1000);
			_pz390.reg.putInt(pz390.r1,get_ccyydddf());
			return;
		case 4: // stck - double word clock (bit 51 = microseconds)
			_pz390.mem.putLong(time_addr,((time_mil-tod_start_day))*1000 << (63-51));
			_pz390.reg.putInt(pz390.r1,get_ccyydddf());
			return;
		case  5: // clock stck  - 8 bytes (bit 51 ms from 1900)
			_pz390.ibm_ms = (time_mil+_pz390.ibm_mil)*1000;
			_pz390.mem.putLong(time_addr,_pz390.ibm_ms << (63-51));
			break;
		case  6: // clock stcke - 16 bytes(bit 59 ms from 1900)
			_pz390.mem.putLong(time_addr,(((time_mil+_pz390.ibm_mil)*1000) << (63-59)));
			_pz390.mem.putLong(time_addr+8,0);
			break;
		case  7: // clock java  - 8 bytes (bit 63 mil from 1970)
			_pz390.mem.putLong(time_addr,time_mil);
			break;
		case 8:  // nano - 8 byte (bit 63 nano-second counter)
			_pz390.mem.putLong(time_addr,System.nanoTime());
			break;
		case  9: // JDBC 29 char timestamp yyyy-mm-dd hh:mm:ss.nnnnnnnnn
			put_ascii_string(tz390.get_timestamp(),time_addr,29,' ');
			break;
		case 10: // dec
			_pz390.mem.putInt(time_addr,Integer.valueOf(cur_tod_hhmmss00.format(_pz390.cur_date),16)
									  +(Integer.valueOf(cur_date_ms.format(_pz390.cur_date),16) >> 4));
			break;
		case 11: // bin - 0.01 sec = (mic/10000)
			_pz390.mem.putInt(time_addr,(int)((time_mil-tod_start_day)/10));
			break;
		case 13: // mic - double word microseconds
			_pz390.mem.putLong(time_addr,(time_mil-tod_start_day)*1000);
			break;
		case 14: // stck - double word clock (bit 51 = microseconds)
			_pz390.mem.putLong(time_addr,((time_mil-tod_start_day)*1000) << (63-51));
			break;
		case 15: // estck - double word clock (bit 51 = microseconds)
			_pz390.mem.putLong(time_addr,((time_mil-tod_start_day)*1000) << (63-59));
			_pz390.mem.putLong(time_addr+8,0);
			return;
		case 16: // ins - return r1 = 64 bit instruction counter rpi 825
			_pz390.reg.putLong(8,_pz390.tz390.systerm_ins);
			return;
		case 0x80: // PTFF-QAF 0x00 - query ava8lable functions
			// 0-3 bits on for functions 0-3 problem state functions avail.
			// 4-127 bits off for supervisor state functions not avail
			_pz390.mem.putInt(time_addr,0xf0000000); // functions 0-3 avail
			Arrays.fill(_pz390.mem_byte,time_addr+1,time_addr+16,(byte)0x00);
			return;
		case 0x81: // PTFF-QTO 0x01 - time of day offset
			// 0-7   physical clock - double word clock (bit 51 = microseconds)
			// 8-15  tod offset from physical clock
			// 16-23 logical tod offset
			// 24-31 tod epoch difference
			_pz390.mem.putLong(time_addr,((time_mil-tod_start_day))*1000 << (63-51));
			Arrays.fill(_pz390.mem_byte,time_addr+8,time_addr+32,(byte)0x00);
			return;
		case 0x82: // PTFF-QSI steering information
			// 0-7 physical clock
			// 8-56 currently old and new epoch all zeros
			_pz390.mem.putLong(time_addr,((time_mil-tod_start_day))*1000 << (63-51));
			Arrays.fill(_pz390.mem_byte,time_addr+8,time_addr+56,(byte)0x00);
			return;
		case 0x83: // PTFF-QPT physical clock
			// 9-7 physical clock
			_pz390.mem.putLong(time_addr,((time_mil-tod_start_day))*1000 << (63-51));
			return;
		default:
			_pz390.reg.putInt(pz390.r15,4);
			return;
		}
		switch (date_type) {
		case 1: // 8(4,R1) = 0YYYYDDD
			_pz390.mem.putInt(time_addr+8,Integer.valueOf(cur_date_yyyyddd.format(_pz390.cur_date),16));
			break;
		case 2: // 8(4,R1) = MMDDYYYY
			_pz390.mem.putInt(time_addr+8,Integer.valueOf(cur_date_MMddyyyy.format(_pz390.cur_date),16));
			break;
		case 3: // 8(4,R1) = DDMMYYYY
			_pz390.mem.putInt(time_addr+8,Integer.valueOf(cur_date_ddMMyyyy.format(_pz390.cur_date),16));
			break;
		case 4: // 8(4,R1) = YYYYMMDD
			_pz390.mem.putInt(time_addr+8,Integer.valueOf(cur_date_yyyyMMdd.format(_pz390.cur_date),16));
			break;
		default:
			_pz390.reg.putInt(pz390.r15,4);
			return;
		}
	}

	/**
	 * Process TTIMER cancel, tu, or mic request
	 *   R0 BIT 0 = return MIC at R1 address else TU om R0
	 *   R0 BIT 1 = CANCEL else just return time
	 * Notes:
	 *   1.  RPI 452 return time with/without cancel opcode changed so recompile required.
	 */
	private void svc_ttimer() {
		final int opcode = _pz390.reg.getInt(pz390.r0);
		long mics_remaining = 1000 * (stimer_exit_time - System.currentTimeMillis()) ;
		if ((opcode & 0x1) == 0) {
			// return TU time in R0
			if (mics_remaining <= 0) {
				mics_remaining = 0;
				_pz390.reg.putInt(pz390.r0, 0);
				_pz390.reg.putInt(pz390.r15,0);
			} else {
				final long tu = (long)(mics_remaining/26.0144);
				if ((tu >> 32) == 0) {
					_pz390.reg.putInt(pz390.r0,(int)tu);
					_pz390.reg.putInt(pz390.r15,0);
				} else {
					_pz390.reg.putInt(pz390.r15,4);
				}
			}
		} else {
			// return MIC time at addr in R1
			if (mics_remaining < 0) {
				mics_remaining = 0;
			}
			final int addr = _pz390.reg.getInt(pz390.r1) & _pz390.psw_amode;
			_pz390.mem.putLong(addr,mics_remaining << 12);
			_pz390.reg.putInt(pz390.r15,0);
		}
		if ((opcode & 0x2) == 0x2) {
			stimer_exit_addr = 0; // Cancel stimer
		}
	}

	/**
	 * Process timer interval request
	 */
	private void svc_stimer() {
		final byte req_type   = _pz390.reg.get(0);
		final byte intvl_type = _pz390.reg.get(1);
		final int  intvl_addr = _pz390.reg.getInt(pz390.r1) & _pz390.psw_amode;
		long intvl_mics = 0;

		// Set intvl_mics interval in microseconds.
		switch (intvl_type) {
		case 1: // BINTVL=RX FWORD 0.01 SEC
			intvl_mics = (long)_pz390.mem.getInt(intvl_addr) * 10000;
			break;
		case 2: // DINTVL=RX DWORD PL8'HHMMSSTH'
			final long hhmmssth = _pz390.mem.getLong(intvl_addr) >>> 4;
			final int hh = (int)((hhmmssth >> 28)*10+((hhmmssth & 0x0f000000) >> 24));
			final int mm = (int)(((hhmmssth & 0x00f00000) >> 20)*10+((hhmmssth & 0x000f0000) >> 16));
			final int ss = (int)(((hhmmssth & 0x0000f000) >> 12)*10+((hhmmssth & 0x00000f00) >> 8));
			final int th = (int)(((hhmmssth & 0x000000f0) >> 4)*10+(hhmmssth & 0xf));
			intvl_mics = 10000 * (th + 100 * (ss + 60 * (mm + 60 * hh)));
			break;
		case 3: // MICVL=RX DWORD MICS
			intvl_mics = _pz390.mem.getLong(intvl_addr);
			break;
		case 4: // TUINTVL=RX DWORD 26.04166 MICS
			intvl_mics = Double.valueOf(_pz390.mem.getInt(intvl_addr) * 26.04166).longValue();
			break;
		default:
			_pz390.set_psw_check(Constants.psw_pic_spec);
			break;
		}

		// Process request by type
		switch (req_type) {
		case 1: // WAIT
			tz390.sleep_now(intvl_mics/1000);
			break;
		case 2: // REAL/TASK
			stimer_exit_addr  = _pz390.reg.getInt(pz390.r0) & _pz390.psw_amode;
			if (stimer_exit_addr == 0) {
				_pz390.set_psw_check(Constants.psw_pic_spec);
				return;
			}
			stimer_exit_time = System.currentTimeMillis() + intvl_mics/1000;
			break;
		default:
			_pz390.set_psw_check(Constants.psw_pic_spec);
			break;
		}
	}

	/**
	 * Start stimer exit when stimer_exit_request found true by instruction loop or wait loop.
	 */
	public void start_stimer_exit() {
		stimer_save_r13 = _pz390.reg.getInt(pz390.r13);
		stimer_save_r14 = _pz390.reg.getInt(pz390.r14);
		stimer_save_r15 = _pz390.reg.getInt(pz390.r15);
		stimer_save_psw = _pz390.psw_loc;
		_pz390.reg.putInt(pz390.r13, pz390.zcvt_stimer_save);
		_pz390.reg.putInt(pz390.r14, pz390.zcvt_exit);
		_pz390.reg.putInt(pz390.r15,stimer_exit_addr);
		stimer_exit_request = false; // request stimer exit
		stimer_exit_running = true;  // reset psw
		_pz390.psw_loc = stimer_exit_addr;
		stimer_exit_addr = 0;        // turn off stimer
		if (tz390.opt_trace) {
			tz390.put_trace("STIMER EXIT STARTING");
		}
	}

	/**
	 * Return ccyydddf for r1 linkage=svc calls.
	 * @return
	 */
	private int get_ccyydddf() {
		final int cc = Integer.valueOf(cur_date_yyyy.format(_pz390.cur_date))/100-19;
		return (cc << 24)
			| ((Integer.valueOf(cur_date_yyddd.format(_pz390.cur_date),16)) << 4)
			| 0xf;
	}

	/**
	 * Search for members specified in BLDL list passed in R1 using SYS390 directory list and set return code:
	 *   0 - all members found
	 *   4 - one or more not found
	 *       entry field R (offset  if all found else 4 if not.
	 *   8 - invalid entry count or entry length
	 * The R field in entries found is set to 1 and set to 0 if not found.
	 * If entry length >= 13 then set Z to 1 if found in memory else 0.
	 */
	private void svc_bldl() {
		final int bldl_list_addr = _pz390.reg.getInt(pz390.r1) & _pz390.psw_amode;
		int bldl_list_count = _pz390.mem.getShort(bldl_list_addr);
		if (bldl_list_count < 1) {
			_pz390.reg.putInt(pz390.r15,8);
			return;
		}

		String bldl_last_name = "";
		int bldl_entry_addr = bldl_list_addr+2;
		int bldl_rc = 0;
		while (bldl_list_count > 0) {
			final int bldl_entry_len = _pz390.mem.getShort(bldl_entry_addr);
			if (bldl_entry_len < 12) {  // RPI 311
				_pz390.reg.putInt(pz390.r15,8);
				return;
			}
			String bldl_member_name = get_ascii_string(bldl_entry_addr+2,8,true);
			if (bldl_member_name.compareTo(bldl_last_name) <= 0) {
				_pz390.reg.putInt(pz390.r15,8);
				return;
			}
			bldl_last_name = bldl_member_name;
			cur_cde = tz390.find_key_index('P',bldl_member_name.toUpperCase() + tz390.z390_type); // RPI 499
			if (cur_cde != -1 && cde_loc[cur_cde] != 0) {
				_pz390.mem.put(bldl_entry_addr+2+10,(byte)1); // R=1 entry found
				if (bldl_entry_len >= 13) {  // RPI 311
					_pz390.mem.put(bldl_entry_addr+2+12,(byte)1); // Z=1 entry found in memory
				}
			} else {
				String bldl_member_file_name = tz390.find_file_name(tz390.dir_390,bldl_member_name,tz390.z390_type,tz390.dir_cur);
				if (bldl_member_file_name != null) {
					_pz390.mem.put(bldl_entry_addr+2+10,(byte)1); // R=1 entry found
					if (bldl_entry_len >= 13) {  // RPI 311
						_pz390.mem.put(bldl_entry_addr+2+12,(byte)0); // Z=0 entry found in sys390 dir
					}
				} else {
					_pz390.mem.put(bldl_entry_addr+2+10,(byte)0); // R=1 entry not found
					bldl_rc = 4;
				}
			}
			bldl_entry_addr = bldl_entry_addr +2 + bldl_entry_len;  // RPI 311
			bldl_list_count--;
		}
		_pz390.reg.putInt(pz390.r15,bldl_rc);
	}


	/**
	 * 1.  Display trace table, abend code, psw, instr,and gpr's
	 * 2.  If dump_reguested
	 *        display gpr's
	 *        display fpr'ss
	 *        display tiot dcbs
	 *        dump all storage
	 * 3.  Abort if not in test mode
	 * @param pic
	 * @param type
	 * @param req_dump
	 */
	public void svc_abend(final int pic, final boolean type, final boolean req_dump) {
		if (_pz390.psw_abend) {
			return; // ignore mult on same cycle RPI 1054
		}
		_pz390.psw_abend = true; // RPI 1054
		if (!tz390.opt_trace) {
			list_trace_table(); // RPI 819 list last 10 instr
		}
		final int save_psw_loc = _pz390.psw_loc; // RPI 1054
		int dump_loc = _pz390.psw_loc - _pz390.psw_ins_len;
		if (   pic == 0x0c1 // invalid opcode
			|| pic == 0x422 // timeout // RPI 1054
			|| _pz390.psw_loc < 0) {
			dump_loc = _pz390.psw_loc;
			if (_pz390.opcode1 < 0xc0) {  // RPI 1063
				if (_pz390.opcode1 < 0x40) {
					_pz390.psw_ins_len = 2;
				} else {
					_pz390.psw_ins_len = 4;
				}
			} else {
				_pz390.psw_ins_len = 6;
			}
		} else {
			_pz390.psw_loc = dump_loc; // RPI 1036
		}
		_pz390.update_psa();  // RPI 1063
		String abend_code;
		if (type) {  // system or user requested abend
			abend_code = "S" + tz390.get_hex(pic,3);
		} else {
			abend_code = "000" + pic;
			abend_code = "U" + abend_code.substring(abend_code.length()-4);
		}
		log_error(11,
				  "ABEND PSW=" + dump_psw()  // rpi 1051
				 + " " + _pz390.get_ins_hex(dump_loc)
				 + " " + _pz390.get_ins_name(dump_loc)
				 + " ABEND " + abend_code);
		dump_req(req_dump || tz390.opt_dump);  // RPI 821 add dump option
		if (!tz390.opt_test) {
			ez390_errors--; // don't count abend twice
			abort_error(12, "Program aborting due to abend " + abend_code);
		} else {
			_pz390.test_trace_count = 1; // stop test G/Z/T
			_pz390.psw_check = false; // reset default
		}
		_pz390.psw_loc = save_psw_loc; // RPI 1054
		svc_abend_type = system_abend;
	}

	/**
	 * List last 10 instructions in trace table.
	 */
	private void list_trace_table() {
		final int cur_index = _pz390.trace_table_index;
		int index = _pz390.trace_table_next[cur_index];
		while (index != cur_index) {
			// list last 10 if any
			final int addr = _pz390.trace_table_addr[index];
			if (addr != 0) {
				put_dump("EZ390I Trace Table Entry      "
					 + tz390.get_hex(addr,8)
					 + " " + _pz390.get_ins_hex(addr) + " " + _pz390.get_ins_name(addr));
			}
			index = _pz390.trace_table_next[index];
		}
	}

	/**
	 * Return 16 character hex PSW with with the following bit settings:
	 *   1. bits 0-7 x'07' translation,
	 *      I/O interrupts, and external
	 *      interrupts enabled.
	 *   2. Bits 8-15 x'05' key zero, machine
	 *      checks enabled, and problem state enabled.
	 *   3. Bits 16-23 AS(2),CC(2),MASK(4)
	 *      AS   - translation mode zeros
	 *      CC   - condition code 0=CC8, 1=CC4, 2=CC2, 3=CC1
	 *      MASK - fixed, decimal, HFP exp, HFP sig.
	 *   4. Bits 24-31 zeros (64 bit addressing if 31 & 32 are one)
	 *   5. Bit  31    basic addressing mode 0=24, 1=31
	 *   6. Bits 32-63 - address of next instruction
	 * @return
	 */
	private String dump_psw() { // RPI 819
		final int cc   = pz390.psw_cc_code[_pz390.psw_cc];
		final int mask = _pz390.psw_pgm_mask;
		int amode_and_addr;
		if (_pz390.psw_amode == pz390.psw_amode31) {
			amode_and_addr = pz390.int_high_bit
						  | _pz390.psw_loc;
		} else {
			amode_and_addr = _pz390.psw_loc;
		}
		int psw1 = 0x07050000   // bits  0-15
				| cc   << 12 // bits 18-19
				| mask <<  8; // bits 20-23
		return tz390.get_hex(psw1,8) + " " + tz390.get_hex(amode_and_addr,8);
	}

	/**
	 * Dump registers and optional data, dump everything.
	 * @param req_dump
	 */
	private void dump_req(final boolean req_dump) {
		dump_taken = true;
		dump_gpr(-1);
		if (req_dump) {
			put_dump("");
			dump_fpr(-1);
			put_dump("");
			dump_tiot();
			put_dump("");
			dump_cde_pgms();
			dump_mem(_pz390.mem,0,_pz390.tot_mem);  // RPI 583
		}
	}

	/**
	 * Dump specified register or all if -1.
	 * @param reg_offset
	 */
	public void dump_gpr(final int reg_offset) {
		if (reg_offset < 0 || reg_offset > pz390.r15) { // RPI 490
			put_dump(" R0-R3 " + _pz390.bytes_to_hex(_pz390.reg,0,32,8));
			put_dump(" R4-R7 " + _pz390.bytes_to_hex(_pz390.reg,32,32,8));
			put_dump(" R8-RB " + _pz390.bytes_to_hex(_pz390.reg,64,32,8));
			put_dump(" RC-RF " + _pz390.bytes_to_hex(_pz390.reg,96,32,8));
		} else {
			final int reg_num = reg_offset/8;
			tz390.put_trace("R" + reg_num + "=" + _pz390.get_long_hex(_pz390.reg.getLong(reg_offset)));
		}
	}

	/**
	 * Dump specified fp register or all if -1.
	 * @param reg_offset
	 */
	public void dump_fpr(int reg_offset) {
		if (reg_offset < 0 || reg_offset > pz390.r15) {
			int reg_off = 0;
			while (reg_off < pz390.max_reg_off) {  // RPI 229
				_pz390.fp_store_reg(_pz390.trace_reg,reg_off);
				reg_off = reg_off + 8;
			}
			put_dump(" F0-F3 " + _pz390.bytes_to_hex(_pz390.trace_reg,0,32,8));
			put_dump(" F4-F7 " + _pz390.bytes_to_hex(_pz390.trace_reg,32,32,8));
			put_dump(" F8-FB " + _pz390.bytes_to_hex(_pz390.trace_reg,64,32,8));
			put_dump(" FC-FF " + _pz390.bytes_to_hex(_pz390.trace_reg,96,32,8));
		} else {
			final int reg_num = reg_offset/8;
			_pz390.fp_store_reg(_pz390.trace_reg,reg_offset);
			tz390.put_trace(" F" + reg_num + "=" + _pz390.get_long_hex(_pz390.trace_reg.getLong(reg_offset)));
		}
	}

	/**
	 * Dump specified area of memory.
	 * @param memory
	 * @param mem_addr
	 * @param mem_len
	 */
	public void dump_mem(ByteBuffer memory,int mem_addr,int mem_len) {
		int dump_len = 0;
		if (mem_addr < 0) {
			mem_addr = 0;
		}
		boolean last_saved    = false;
		boolean last_dup_line = false;
		String  dump_hex      = null;
		String  last_hex      = null;
		String  dump_text = ""; // RPI 1054
		int     last_addr     = 0;
		while (mem_len > 0 && mem_addr + mem_len <= _pz390.tot_mem) {
			if (mem_len > 16) {
				dump_len = 16;
			} else {
				dump_len = mem_len;
			}
			dump_text = tz390.get_ascii_printable_string(memory.array(),mem_addr,dump_len); // RPI 947

			dump_text = tz390.left_justify(dump_text,16); // RPI 411
			dump_hex = _pz390.bytes_to_hex(memory,mem_addr,dump_len,4);
			if (!last_saved) {
				last_saved = true;
				last_addr  = mem_addr;
				last_dup_line = false;
			} else {
				if (last_hex.equals(dump_hex)) {
					last_dup_line = true;
				} else {
					if (last_dup_line) {
						put_dump(" ........");
					}
					last_dup_line = false;
					last_addr = mem_addr;
				}
			}
			last_hex = dump_hex;
			if  (!last_dup_line) {
				dump_hex = tz390.left_justify(dump_hex,35); // RPI 411
				put_dump(" " +tz390.get_hex(mem_addr,8)
					   + " *"  + dump_hex
					   + "* *" + dump_text + "*");
			}
			mem_addr = mem_addr + 16;
			mem_len  = mem_len  - 16;
		}
		if (last_dup_line) {
			if (last_addr + 32 < mem_addr) {
				put_dump(" ........");
			}
			dump_hex = tz390.left_justify(dump_hex,35); // RPI 411
			put_dump(" " +tz390.get_hex(mem_addr-16,8) + " *"  + dump_hex + "* *" + dump_text + "*"); // RPI 1054
		}
	}

	/**
	 * Route dump lines to LOG file unless TRACE or TRACET is on in which case route to TRE file.
	 * @param text
	 */
	private void put_dump(String text) {
		if (tz390.trace_file != null || tz390.opt_test) {  // RPI 724
			tz390.put_trace(text); // RPI 689
		} else {
			put_log(text);
		}
	}

	/**
	 * Display total allocated and free memory totals on log.
	 */
	private void dump_mem_stat() {
		tz390.put_trace(" MEM TOTAL=" + (_pz390.tot_mem >> 20) + "MB"
					  + "  ALLOC=" + _pz390.tot_mem_alloc
					  + "  FREE=" + (_pz390.tot_mem - _pz390.tot_mem_alloc));
	}

	/**
	 * Check for DCB or ACB and route accordingly.
	 */
	private void svc_open() {
		cur_dcb_addr  = _pz390.reg.getInt(pz390.r1) & _pz390.psw_amode; // RPI 1021
		cur_open_opt  = _pz390.reg.getInt(pz390.r0);
		byte cur_acb_id = _pz390.mem.get(cur_dcb_addr);
		if (cur_acb_id == tz390.acb_id_ver) {
			_vz390.cur_vsam_op = vz390.vsam_op_open;
			_vz390.svc_vsam();  // RPI 644
		} else {
			svc_open_dcb("");
		}
	}

	/**
	 * Open DCB file for sequential or random I/O and use dsnam_path prefix for dcbdsnam option.
	 * @param dsnam_path
	 */
	public void svc_open_dcb(final String dsnam_path) {
	/*
	 * Notes:
	 *   1.  R1 = DCB
	 *   2.  R0 = OPEN OPTION
	 *          x'40' - input only  - dcb_oflgs_r
	 *          x'20' - output only - dcb_oflgs_w
	 *          x'60' - update      - dcb_oflgs_rw
	 *   3.  DDNAME points to environment variable with file path and name unless DCBDSNAM
	 *       field has pointer to DSN null or " delimited file spec in EBCDIC unless in ASCII mode.
	 *   4.  See DCBD macro for DCB fields and see DCB macro for generation of DCB
	 *   5.  TIOT table with unique entry for each DDNAME holds open files.
	 *   6.  Take synad exit if defined else issue error message and abort.
	 *
	 *  Output registers:
	 *    R0  - 64 bit file length RPI 587
	 */
		tot_dcb_open++;
		tot_dcb_oper++;
		check_dcb_addr();
		get_cur_tiot_index();
		if (cur_tiot_index != -1) {
			_pz390.mem.putInt(cur_dcb_addr + dcb_io,0); // reset RPI 764
			cur_dcb_recfm   = _pz390.mem_byte[cur_dcb_addr+dcb_recfm] & 0xff;
			cur_dcb_area    = _pz390.mem.getInt(cur_dcb_addr + dcb_rec);
			cur_dcb_lrecl_f = _pz390.mem.getInt(cur_dcb_addr + dcb_lrecl_f); // RPI 587
			cur_dcb_blksi_f = _pz390.mem.getInt(cur_dcb_addr + dcb_blksi_f); // RPI 587
			cur_dcb_oflgs = _pz390.mem_byte[cur_dcb_addr+dcb_oflgs] & 0xff;
			if ((cur_dcb_oflgs & dcb_oflgs_open) != 0) {
				dcb_synad_error(22,"file already open");
				return;
			}
			cur_dcb_file_name = get_dcb_file_name(dsnam_path);
			tiot_dsn[cur_tiot_index] = cur_dcb_file_name;
			cur_dcb_macrf = _pz390.mem.getShort(cur_dcb_addr + dcb_macrf) & 0xffff;
			if ((cur_dcb_macrf & dcb_macrf_pm) != 0 // RPI 668
			 || (cur_dcb_macrf & dcb_macrf_w ) != 0) {
				cur_dcb_oflgs = (dcb_oflgs_w | dcb_oflgs_r) & cur_open_opt;
			} else {
				cur_dcb_oflgs = dcb_oflgs_r & cur_open_opt;
			}
			tiot_cur_rba[cur_tiot_index] = 0; // RPI101
			tiot_vrec_blksi[cur_tiot_index] = 0;
			switch (cur_dcb_oflgs) {
			case 0x20: // write - dcb_oflgs_w (note NIO does not support write only)
				try {
					tiot_file[cur_tiot_index] = new RandomAccessFile(cur_dcb_file_name,"rw");
					if (cur_dcb_macrf == dcb_macrf_pm) {
						tiot_file[cur_tiot_index].setLength(0);
					}
					tiot_eof_rba[cur_tiot_index] = tiot_file[cur_tiot_index].length();
					if (cur_dcb_macrf == dcb_macrf_pl  // RPI 764
						&& _pz390.mem.getInt(cur_dcb_addr + dcb_rec) == 0) {
						get_dcb_locate_buffer();
					}
				} catch (final Exception e) {
					dcb_synad_error(23, "I/O error on open - " + e.toString());
					return;
				}
				break;
			case 0x40: // read only dcb_oflgs_r
				try {
					tiot_file[cur_tiot_index] = new RandomAccessFile(cur_dcb_file_name,"r");
					tiot_eof_rba[cur_tiot_index] = tiot_file[cur_tiot_index].length();
					if (cur_dcb_macrf == dcb_macrf_gl  // RPI 764
						&& _pz390.mem.getInt(cur_dcb_addr + dcb_rec) == 0) {
						get_dcb_locate_buffer();
					}
				} catch (final Exception e) {
					dcb_synad_error(23, "I/O error on open - " + e.toString());
					return;
				}
				break;
			case 0x60: // update - dcb_oflgs_rw
				try {
					tiot_file[cur_tiot_index] = new RandomAccessFile(cur_dcb_file_name,"rw");
					tiot_eof_rba[cur_tiot_index] = tiot_file[cur_tiot_index].length();
				} catch (final Exception e) {
					dcb_synad_error(23,"I/O error on open - " + e.toString());
					return;
				}
				break;
			default:
				dcb_synad_error(24,"invalid open type - " + tz390.get_hex(cur_dcb_oflgs,8));
				return;
			}
		}
		_pz390.mem_byte[cur_dcb_addr + dcb_oflgs] = (byte)(cur_dcb_oflgs | dcb_oflgs_open);
		tiot_dcb_open[cur_tiot_index] = true;  //RPI110
		_pz390.reg.putLong(0,tiot_eof_rba[cur_tiot_index]);  // RPI 587 return file length
		_pz390.reg.putInt(pz390.r15,0);
	}

	/**
	 * Set dcb_rec to address of get/put locate buffer else abort. RPI-0764
	 */
	private void get_dcb_locate_buffer() {
		if (cur_dcb_lrecl_f == 0) {
			_pz390.reg.putInt(pz390.r1,cur_dcb_blksi_f);
		} else {
			_pz390.reg.putInt(pz390.r1,cur_dcb_lrecl_f);
		}
		svc_getmain();
		if (_pz390.reg.getInt(pz390.r15) == 0) {
			_pz390.mem.putInt(cur_dcb_addr + dcb_rec,_pz390.reg.getInt(pz390.r1));
		} else {
			abort_error(122, "Getmain for svc 19 open failed - PGM=" + tz390.pgm_name + "LEN=" + load_code_len);
		}
	}

	/**
	 * Get file name from DCBDSNAM if not zero and append dsnam_path RPI 668
	 * else get file from DCBDDNAM environment variable.
	 * NOtes:
	 *   1.  DCBDSNAM is EBCDIC uless in ASCII mode.
	 *   2.  File spec up to 265 long spacey name with drive and path.
	 * @param dsnam_path
	 * @return
	 */
	private String get_dcb_file_name(final String dsnam_path) {
		String file_name = "";
		final int dcb_dsn = _pz390.mem.getInt(cur_dcb_addr + dcb_dsnam);
		if (dcb_dsn > 0) {
			file_name = dsnam_path + tz390.get_ascii_var_string(_pz390.mem_byte,dcb_dsn,max_lsn_spec).trim(); // RPI 668
			file_name = tz390.fix_file_separators(file_name); // RPI 1080
			if (!file_name.substring(0,1).equals(File.separator)
			 && (file_name.length() == 1
			   ||file_name.charAt(1) != ':')) {
				file_name = tz390.dir_cur + file_name; // RPI 713
			}
			return file_name;
		} else {
			file_name = get_tiot_file_name(cur_tiot_index);
			if (file_name == null) {
				dcb_synad_error(62,"ddname=" + tiot_ddnam[cur_tiot_index] + " not found");
			} else {
				return file_name;
			}
		}
		return "";
	}

	/**
	 * Return file name for tiot using ddname for tiot.
	 * @param tiot_index
	 * @return
	 */
	private String get_tiot_file_name(int tiot_index) {
		String file_name = get_ascii_env_var_string(tiot_ddnam[tiot_index]);
		if (file_name != null && file_name.length() > 0) {
			file_name = tz390.fix_file_separators(file_name); // RPI 1080
		}
		return file_name;
	}

	/**
	 * Check for DCB or ACB and route accordingly.
	 */
	private void svc_close() {
		cur_dcb_addr  = _pz390.reg.getInt(pz390.r1) & _pz390.psw_amode; // RPI 1021
		byte cur_acb_id = _pz390.mem.get(cur_dcb_addr);
		if (cur_acb_id == tz390.acb_id_ver) {
			_vz390.cur_vsam_op = vz390.vsam_op_close;
			_vz390.svc_vsam();  // RPI 644
		} else {
			svc_close_dcb();
		}
	}

	/**
	 * Close file if open else synad error.
	 */
	public void svc_close_dcb() {
		tot_dcb_close++;
		tot_dcb_oper++;
		check_dcb_addr();
		get_cur_tiot_index();
		if (cur_tiot_index != -1) {
			cur_dcb_oflgs = _pz390.mem_byte[cur_dcb_addr+dcb_oflgs] & 0xff;
			if ((cur_dcb_oflgs & dcb_oflgs_open) == 0) {
				dcb_synad_error(25,"file already closed");
				return;
			}
			try {
				if (tiot_vrec_blksi[cur_tiot_index] > 0) {
					tiot_file[cur_tiot_index].seek(tiot_cur_rba[cur_tiot_index]);
					tz390.systerm_io++;
					tiot_file[cur_tiot_index].writeInt((tiot_vrec_blksi[cur_tiot_index]+4) << 16);
				}
				tiot_file[cur_tiot_index].close();
				_pz390.mem_byte[cur_dcb_addr+dcb_oflgs] = (byte)(_pz390.mem_byte[cur_dcb_addr+dcb_oflgs] & (0xff ^ dcb_oflgs_open)); // RPI110
				_pz390.mem.putInt(cur_dcb_addr + dcb_iobad,0); //RPI110
				tiot_dcb_open[cur_tiot_index] = false;  //RPI110
			} catch (final Exception e) {
				dcb_synad_error(26,"i/o error on close - " + e.toString());
				return;
			}
		} else {
			dcb_synad_error(25,"file already closed");
			return;
		}
		_pz390.reg.putInt(pz390.r15,0);
	}

	/**
	 * Get next record into area from dcb gm/gl.
	 * Notes:
	 *   1.  Translate to EBCDIC unless ASCII mode
	 *   2.  If GL, move to dcb_area and return addr in R1.  RPI-0764
	 */
	private void svc_get() {
		tot_dcb_get++;
		tot_dcb_oper++;
		cur_dcb_addr  = _pz390.reg.getInt(pz390.r1) & _pz390.psw_amode;
		check_dcb_addr();
		get_cur_tiot_index();
		if (cur_tiot_index != -1) {
			cur_dcb_recfm   = _pz390.mem_byte[cur_dcb_addr+dcb_recfm] & 0xff;
			cur_dcb_lrecl_f = _pz390.mem.getInt(cur_dcb_addr + dcb_lrecl_f); // RPI 587
			cur_dcb_blksi_f = _pz390.mem.getInt(cur_dcb_addr + dcb_blksi_f); // RPI 587
			cur_dcb_macrf   = _pz390.mem.getShort(cur_dcb_addr + dcb_macrf) & 0xffff;
			if (cur_dcb_macrf == dcb_macrf_gl) {
				cur_dcb_area  = _pz390.mem.getInt(cur_dcb_addr + dcb_rec);
				// set R1 to dcb area for GL
				_pz390.reg.putInt(pz390.r1,cur_dcb_area);
			} else {
				cur_dcb_area  = _pz390.reg.getInt(pz390.r0) & _pz390.psw_amode;
			}
			if (tiot_cur_rba[cur_tiot_index] >= tiot_eof_rba[cur_tiot_index]) {
				dcb_eodad_exit();
				return;
			} else if ((cur_dcb_recfm == dcb_recfm_ft
					 || cur_dcb_recfm == dcb_recfm_vt)
					&& tiot_cur_rba[cur_tiot_index] == tiot_eof_rba[cur_tiot_index] -1) {
				try {  //RPI-0063
					tz390.systerm_io++;
					final byte eof_byte = tiot_file[cur_tiot_index].readByte();
					if (eof_byte == 0x1a) {
						dcb_eodad_exit();
						return;
					} else {
						tiot_file[cur_tiot_index].seek(tiot_cur_rba[cur_tiot_index]);
					}
				} catch (final Exception e) {
					dcb_synad_error(78,"i/o error on get move ascii eof byte - " + e.toString());
					return;
				}
			}
			switch (cur_dcb_recfm) {
			case 0x40: // get variable
				try {
					if (cur_dcb_lrecl_f == 0) {
						cur_dcb_lrecl_f = cur_dcb_blksi_f; // use blksi if no lrecl
					}
					tz390.systerm_io++;
					cur_vrec_lrecl = tiot_file[cur_tiot_index].readInt();
					check_mem_area(cur_dcb_area,cur_vrec_lrecl >> 16); // RPI 668
					_pz390.mem.putInt(cur_dcb_area,cur_vrec_lrecl);
					cur_vrec_lrecl = cur_vrec_lrecl >> 16;
					if (cur_vrec_lrecl < 5 || cur_vrec_lrecl > cur_dcb_lrecl_f) { // RPI 697
						dcb_synad_error(28,"invalid variable record length - " + cur_vrec_lrecl);
						return;
					}
					tz390.systerm_io++;
					tiot_file[cur_tiot_index].read(_pz390.mem_byte,cur_dcb_area + 4,cur_vrec_lrecl - 4);
					if (tz390.opt_traceq) {
						tz390.put_trace("QSAM EXCP READ  VREC  XRBA=" + tz390.get_long_hex(tiot_cur_rba[cur_tiot_index],16) + " LEN=" + tz390.get_hex(cur_vrec_lrecl,8));
						dump_mem(_pz390.mem,cur_dcb_area,cur_vrec_lrecl);
					}
					tiot_cur_rba[cur_tiot_index] = tiot_file[cur_tiot_index].getFilePointer();
				} catch (final Exception e) {
					dcb_synad_error(29,"i/o error on get move variable - " + e.toString());
					return;
				}
				break;
			case 0x50: // get variable blocked
				try {
					if (cur_dcb_lrecl_f == 0) {
						cur_dcb_lrecl_f = cur_dcb_blksi_f - 4; // use blksi if no lrecl
					}
					if (tiot_vrec_blksi[cur_tiot_index] == 0) {
						tz390.systerm_io++;
						tiot_vrec_blksi[cur_tiot_index] = (tiot_file[cur_tiot_index].readInt() >>> 16)-4;
						if (tiot_vrec_blksi[cur_tiot_index] < 5 || tiot_vrec_blksi[cur_tiot_index] > cur_dcb_blksi_f-4) {
							dcb_synad_error(30,"invalid variable block size - " + tiot_vrec_blksi[cur_tiot_index]);
							return;
						}
					}
					tz390.systerm_io++;
					cur_vrec_lrecl = tiot_file[cur_tiot_index].readInt();
					check_mem_area(cur_dcb_area,cur_vrec_lrecl >> 16); // RPI 668
					_pz390.mem.putInt(cur_dcb_area,cur_vrec_lrecl);
					cur_vrec_lrecl = cur_vrec_lrecl >> 16;
					if (cur_vrec_lrecl < 5 || cur_vrec_lrecl > cur_dcb_lrecl_f) { // RPI 697
						dcb_synad_error(28,"invalid variable record length - " + cur_vrec_lrecl);
						return;
					}
					tz390.systerm_io++;
					tiot_file[cur_tiot_index].read(_pz390.mem_byte,cur_dcb_area + 4,cur_vrec_lrecl - 4);
					if (tz390.opt_traceq) {
						tz390.put_trace("QSAM EXCP READ  VREC  XRBA=" + tz390.get_long_hex(tiot_cur_rba[cur_tiot_index],16) + " LEN=" + tz390.get_hex(cur_vrec_lrecl,8));
						dump_mem(_pz390.mem,cur_dcb_area,cur_vrec_lrecl);
					}
					tiot_cur_rba[cur_tiot_index] = tiot_file[cur_tiot_index].getFilePointer();
					tiot_vrec_blksi[cur_tiot_index] = tiot_vrec_blksi[cur_tiot_index] - cur_vrec_lrecl;
					if (tiot_vrec_blksi[cur_tiot_index] < 0) {
						dcb_synad_error(31,"invalid variable block at rba " + _pz390.get_long_hex(tiot_cur_rba[cur_tiot_index]));
						return;
					}
				} catch (final Exception e) {
					dcb_synad_error(29,"i/o error on get move variable - " + e.toString());
					return;
				}
				break;
			case 0x60: // variable from ascii text
				try {
					if (cur_dcb_lrecl_f == 0) {
						cur_dcb_lrecl_f = cur_dcb_blksi_f; // use blksi if no lrecl
					}
					tz390.systerm_io++;
					cur_rec_text = tiot_file[cur_tiot_index].readLine();
					cur_rec_len  = cur_rec_text.length();
					tiot_cur_rba[cur_tiot_index] = tiot_file[cur_tiot_index].getFilePointer();
					if (cur_rec_len > cur_dcb_lrecl_f - 4) { // rpi 697
						dcb_synad_error(46,"variable record too long");
						return;
					} else if (cur_rec_len == 0) {
						cur_rec_len = 1; // RPI 697
						cur_rec_text = " ";
					}
					check_mem_area(cur_dcb_area,cur_rec_len+4); // RPI 668
					_pz390.mem.putInt(cur_dcb_area,(cur_rec_len+4) << 16);
					int index = 0;
					while (index < cur_rec_len) {
						if (tz390.opt_ascii) {
							_pz390.mem_byte[cur_dcb_area + 4 + index] = (byte)cur_rec_text.charAt(index);
						} else {
							_pz390.mem_byte[cur_dcb_area + 4 + index] = tz390.ascii_to_ebcdic[cur_rec_text.charAt(index)];
						}
						index++;
					}
					if (tz390.opt_traceq) {
						tz390.put_trace("QSAM EXCP READ  VREC  XRBA=" + tz390.get_long_hex(tiot_cur_rba[cur_tiot_index]-cur_rec_len-4,16) + " LEN=" + tz390.get_hex(cur_rec_len+4,8));
						dump_mem(_pz390.mem,cur_dcb_area,cur_rec_len+4);
					}
				} catch (final Exception e) {
					dcb_synad_error(47,"i/o error on get move variable from ascii - " + e.toString());
					return;
				}
				break;
			case 0x80: // fixed - read lrecl bytes into area
			case 0x90: // fixed blocked
				try {
					if (cur_dcb_lrecl_f == 0) {
						cur_dcb_lrecl_f = cur_dcb_blksi_f; // use blksi if no lrecl
						if (cur_dcb_lrecl_f == 0) {
							dcb_synad_error(110,"invalid DCB lrecl = " + cur_dcb_lrecl_f); // RPI 668
						}
					}
					tz390.systerm_io++;
					check_mem_area(cur_dcb_area,cur_dcb_lrecl_f); // RPI 668
					tiot_file[cur_tiot_index].read(_pz390.mem_byte,cur_dcb_area,cur_dcb_lrecl_f);
					if (tz390.opt_traceq) {
						tz390.put_trace("QSAM EXCP READ  FREC  XRBA=" + tz390.get_long_hex(tiot_cur_rba[cur_tiot_index],16) + " LEN=" + tz390.get_hex(cur_dcb_lrecl_f,8));
						dump_mem(_pz390.mem,cur_dcb_area,cur_dcb_lrecl_f);
					}
					tiot_cur_rba[cur_tiot_index] = tiot_cur_rba[cur_tiot_index]+cur_dcb_lrecl_f;
				} catch (final Exception e) {
					dcb_synad_error(27,"i/o error on get move fixed - " + e.toString());
					return;
				}
				break;
			case 0xa0: // fixed from ascii text
				try {
					if (cur_dcb_lrecl_f == 0) {
						cur_dcb_lrecl_f = cur_dcb_blksi_f; // use blksi if no lrecl
						if (cur_dcb_lrecl_f == 0) {
							dcb_synad_error(111,"invalid DCB lrecl = " + cur_dcb_lrecl_f); // RPI 668
						}
					}
					tz390.systerm_io++;
					cur_rec_text = tiot_file[cur_tiot_index].readLine();
					cur_rec_len  = cur_rec_text.length();
					check_mem_area(cur_dcb_area,cur_dcb_lrecl_f); // RPI 668
					tiot_cur_rba[cur_tiot_index] = tiot_file[cur_tiot_index].getFilePointer();
					if (cur_rec_len <= cur_dcb_lrecl_f) {
						int index = 0;
						while (index < cur_rec_len) {
							if (tz390.opt_ascii) {
								_pz390.mem_byte[cur_dcb_area + index] = (byte)cur_rec_text.charAt(index);
							} else {
								_pz390.mem_byte[cur_dcb_area + index] = tz390.ascii_to_ebcdic[cur_rec_text.charAt(index)];
							}
							index++;
						}
						while (index < cur_dcb_lrecl_f) {
							if (tz390.opt_ascii) {
								_pz390.mem_byte[cur_dcb_area + index] = (byte)0x20; //RPI66
							} else {
								_pz390.mem_byte[cur_dcb_area + index] = (byte)0x40;
							}
							index++;
						}
						if (tz390.opt_traceq) {
							tz390.put_trace("QSAM EXCP READ  FREC  XRBA=" + tz390.get_long_hex(tiot_cur_rba[cur_tiot_index]-cur_dcb_lrecl_f,16) + " LEN=" + tz390.get_hex(cur_dcb_lrecl_f,8));
							dump_mem(_pz390.mem,cur_dcb_area,cur_dcb_lrecl_f);
						}
					} else {
						dcb_synad_error(44,"text too long for RECFM=FT - " + cur_rec_text); // RPI 865
					}
				} catch (final Exception e) {
					dcb_synad_error(44,"i/o error on get move fixed from ascii - " + e.toString());
					return;
				}
				break;
			default:
				dcb_synad_error(31,"invalid dcb record format for get move - " + tz390.get_hex(cur_dcb_recfm,2));
				return;
			}
		} else {
			dcb_synad_error(30,"file not found");
			return;
		}
		_pz390.reg.putInt(pz390.r15,0);
	}

	/**
	 * Put next record from area to dcb pm/pl file.
	 */
	private void svc_put() {
		tot_dcb_put++;
		tot_dcb_oper++;
		cur_dcb_addr  = _pz390.reg.getInt(pz390.r1) & _pz390.psw_amode;
		check_dcb_addr();
		get_cur_tiot_index();
		if (cur_tiot_index != -1) {
			cur_dcb_oflgs = _pz390.mem_byte[cur_dcb_addr + dcb_oflgs] & 0xff;
			if ((cur_dcb_oflgs & dcb_oflgs_w) == 0) {
				dcb_synad_error(33,"file not open for output");
				return;
			}
			cur_dcb_macrf = _pz390.mem.getShort(cur_dcb_addr + dcb_macrf) & 0xffff;
			if (cur_dcb_macrf == dcb_macrf_pl) {
				cur_dcb_area  = _pz390.mem.getInt(cur_dcb_addr + dcb_rec);
				// set R1 to dcb area for put rec
				_pz390.reg.putInt(pz390.r1,cur_dcb_area);
				if (_pz390.mem.getInt(cur_dcb_addr + dcb_io) == 1) {
					// exit now on first PL PUT with address of area
					_pz390.reg.putInt(pz390.r15,0);
					return;
				}
			} else {
				cur_dcb_area  = _pz390.reg.getInt(pz390.r0) & _pz390.psw_amode;
			}
			cur_dcb_recfm = _pz390.mem_byte[cur_dcb_addr+dcb_recfm] & 0xff;
			cur_dcb_lrecl_f = _pz390.mem.getInt(cur_dcb_addr + dcb_lrecl_f); // RPI 587
			cur_dcb_blksi_f = _pz390.mem.getInt(cur_dcb_addr + dcb_blksi_f); // RPI 587
			switch (cur_dcb_recfm) {
			case 0x80: // fixed - read lrecl bytes into area
			case 0x90: // put fixed blocked
				try {
					if (cur_dcb_lrecl_f == 0) {
						cur_dcb_lrecl_f = cur_dcb_blksi_f;
						if (cur_dcb_lrecl_f == 0) {
							dcb_synad_error(112,"invalid DCB lrecl = " + cur_dcb_lrecl_f); // RPI 668
						}
					}
					tz390.systerm_io++;
					check_mem_area(cur_dcb_area,cur_dcb_lrecl_f); // RPI 668
					tiot_file[cur_tiot_index].write(_pz390.mem_byte,cur_dcb_area,cur_dcb_lrecl_f);
					if (tz390.opt_traceq) {
						tz390.put_trace("QSAM EXCP WRITE FREC  XRBA=" + tz390.get_long_hex(tiot_cur_rba[cur_tiot_index],16) + " LEN=" + tz390.get_hex(cur_dcb_lrecl_f,8));
						dump_mem(_pz390.mem,cur_dcb_area,cur_dcb_lrecl_f);
					}
					tiot_cur_rba[cur_tiot_index] = tiot_cur_rba[cur_tiot_index]+cur_dcb_lrecl_f;
					if (tiot_file[cur_tiot_index].length() > tz390.max_file_size) {
						abort_error(101, "Maximum file size exceeded for " + tiot_dsn[cur_tiot_index]);
					}
				} catch (final Exception e) {
					dcb_synad_error(34, "I/O error on put move fixed - " + e.toString());
					return;
				}
				break;
			case 0x40: // put variable
				try {
					if (cur_dcb_lrecl_f == 0) {
						cur_dcb_lrecl_f = cur_dcb_blksi_f;
					}
					cur_vrec_lrecl = _pz390.mem.getInt(cur_dcb_area) >>> 16;
					if (cur_vrec_lrecl < 5 || cur_vrec_lrecl > cur_dcb_lrecl_f) {  // RPI 697
						dcb_synad_error(35,"invalid variable record length - " + cur_vrec_lrecl);
						return;
					}
					tz390.systerm_io++;
					check_mem_area(cur_dcb_area,cur_vrec_lrecl); // RPI 668
					tiot_file[cur_tiot_index].write(_pz390.mem_byte,cur_dcb_area,cur_vrec_lrecl);
					if (tz390.opt_traceq) {
						tz390.put_trace("QSAM EXCP WRITE VREC  XRBA=" + tz390.get_long_hex(tiot_cur_rba[cur_tiot_index],16) + " LEN=" + tz390.get_hex(cur_vrec_lrecl,8));
						dump_mem(_pz390.mem,cur_dcb_area,cur_vrec_lrecl);
					}
					tiot_cur_rba[cur_tiot_index] = tiot_cur_rba[cur_tiot_index]+cur_vrec_lrecl;
					if (tiot_file[cur_tiot_index].length() > tz390.max_file_size) {
						abort_error(102, "Maximum file size exceeded for " + tiot_dsn[cur_tiot_index]);
					}
				} catch (final Exception e) {
					dcb_synad_error(36, "I/O error on put move variable - " + e.toString());
					return;
				}
				break;
			case 0x50: // put variable blocked
				try {
					if (cur_dcb_lrecl_f == 0) {
						cur_dcb_lrecl_f = cur_dcb_blksi_f - 4;
					}
					if (tiot_vrec_blksi[cur_tiot_index] == 0) {
						tiot_cur_rba[cur_tiot_index] = tiot_file[cur_tiot_index].getFilePointer();
						tz390.systerm_io++;
						tiot_file[cur_tiot_index].writeInt(-1); // place holder for vb LLZZ
					}
					check_mem_area(cur_dcb_area,4); // RPI 668
					cur_vrec_lrecl = _pz390.mem.getShort(cur_dcb_area); // RPI 668
					if (cur_vrec_lrecl < 5 || cur_vrec_lrecl > cur_dcb_lrecl_f) {
						dcb_synad_error(37,"invalid variable record size - " + cur_vrec_lrecl);
						return;
					}
					tiot_vrec_blksi[cur_tiot_index] = tiot_vrec_blksi[cur_tiot_index] + cur_vrec_lrecl;
					if (tiot_vrec_blksi[cur_tiot_index] > cur_dcb_blksi_f - 4) {
						tiot_vrec_blksi[cur_tiot_index] = tiot_vrec_blksi[cur_tiot_index] - cur_vrec_lrecl;
						tiot_file[cur_tiot_index].seek(tiot_cur_rba[cur_tiot_index]);
						tz390.systerm_io++;
						tiot_file[cur_tiot_index].writeInt((tiot_vrec_blksi[cur_tiot_index]+4) << 16);
						tiot_file[cur_tiot_index].seek(tiot_cur_rba[cur_tiot_index] + tiot_vrec_blksi[cur_tiot_index]+4);
						tiot_cur_rba[cur_tiot_index] = tiot_file[cur_tiot_index].getFilePointer();
						tz390.systerm_io++;
						tiot_file[cur_tiot_index].writeInt(-1); // place holder for vb LLZZ
						tiot_vrec_blksi[cur_tiot_index] = cur_vrec_lrecl;
					}
					tz390.systerm_io++;
					check_mem_area(cur_dcb_area,cur_vrec_lrecl); // RPI 668
					tiot_file[cur_tiot_index].write(_pz390.mem_byte,cur_dcb_area,cur_vrec_lrecl);
					if (tz390.opt_traceq) {
						tz390.put_trace("QSAM EXCP WRITE VREC  XRBA=" + tz390.get_long_hex(tiot_cur_rba[cur_tiot_index],16) + " LEN=" + tz390.get_hex(cur_vrec_lrecl,8));
						dump_mem(_pz390.mem,cur_dcb_area,cur_vrec_lrecl);
					}
					if (tiot_file[cur_tiot_index].length() > tz390.max_file_size) {
						abort_error(103, "Maximum file size exceeded for " + tiot_dsn[cur_tiot_index]);
					}
				} catch (final Exception e) {
					dcb_synad_error(40, "I/O error on put move variable - " + e.toString());
					return;
				}
				break;
			case 0x60: // put variable to ASCII text
				try {
					if (cur_dcb_lrecl_f == 0) {
						cur_dcb_lrecl_f = cur_dcb_blksi_f;
					}
					check_mem_area(cur_dcb_area,4); // RPI 668  RPI 677
					cur_rec_len = (_pz390.mem.getInt(cur_dcb_area) >> 16)-4;
					check_mem_area(cur_dcb_area,cur_rec_len+4); // RPI 668 RPI 677
					if (cur_rec_len < 1 || cur_rec_len > (cur_dcb_lrecl_f - 4)) {
						dcb_synad_error(48, "Variable record too long - " + cur_rec_len);
						return;
					}
					cur_rec_text = get_ascii_string(cur_dcb_area+4,cur_rec_len,false);
					tz390.systerm_io++;
					tiot_file[cur_tiot_index].writeBytes(cur_rec_text + tz390.newline); // RPI 500
					if (tz390.opt_traceq) {
						tz390.put_trace("QSAM EXCP WRITE VTXT  XRBA=" + tz390.get_long_hex(tiot_cur_rba[cur_tiot_index],16) + " LEN=" + tz390.get_hex(cur_rec_len+4,8));
						dump_mem(_pz390.mem,cur_dcb_area,cur_rec_len+4);
					}
					tiot_cur_rba[cur_tiot_index] = tiot_file[cur_tiot_index].getFilePointer();
					if (tiot_file[cur_tiot_index].length() > tz390.max_file_size) {
						abort_error(104, "Maximum file size exceeded for " + tiot_dsn[cur_tiot_index]);
					}
				} catch (final Exception e) {
					dcb_synad_error(47, "I/O error on get move variable from ascii - " + e.toString());
					return;
				}
				break;
			case 0xa0: // put fixed to ASCII text
				try {
					if (cur_dcb_lrecl_f == 0) {
						cur_dcb_lrecl_f = cur_dcb_blksi_f;
						if (cur_dcb_lrecl_f == 0) {
							dcb_synad_error(113,"invalid DCB lrecl = " + cur_dcb_lrecl_f); // RPI 668
						}
					}
					check_mem_area(cur_dcb_area,cur_dcb_lrecl_f); // RPI 668
					cur_rec_text = get_ascii_string(cur_dcb_area,cur_dcb_lrecl_f,false);
					tz390.systerm_io++;
					tiot_file[cur_tiot_index].writeBytes(cur_rec_text + tz390.newline); // RPI 500
					if (tz390.opt_traceq) {
						tz390.put_trace("QSAM EXCP WRITE FTXT  XRBA=" + tz390.get_long_hex(tiot_cur_rba[cur_tiot_index],16) + " LEN=" + tz390.get_hex(cur_dcb_lrecl_f,8));
						dump_mem(_pz390.mem,cur_dcb_area,cur_dcb_lrecl_f);
					}
					if (tiot_file[cur_tiot_index].length() > tz390.max_file_size) {
						abort_error(105, "Maximum file size exceeded for " + tiot_dsn[cur_tiot_index]);
					}
				} catch (final Exception e) {
					dcb_synad_error(45, "I/O error on put move fixed to ascii - " + e.toString());
					return;
				}
				break;
			default:
				dcb_synad_error(41, "Invalid dcb record format for put move - " + tz390.get_hex(cur_dcb_recfm,2));
				return;
			}
		} else {
			dcb_synad_error(42, "File not found");
			return;
		}
		_pz390.reg.putInt(pz390.r15,0);
	}

	/**
	 * Read next record forward or backward into area from dcb macrf r/rw file.
	 */
	private void svc_read() {
		tot_dcb_read++;
		tot_dcb_oper++;
		cur_decb_addr  = _pz390.reg.getInt(pz390.r1) & _pz390.psw_amode;
		cur_dcb_addr  = _pz390.mem.getInt(cur_decb_addr + decb_dcb) & _pz390.psw_amode;
		check_dcb_addr();
		get_cur_tiot_index();
		if (cur_tiot_index != -1) {
			if (tiot_cur_rba[cur_tiot_index] >= tiot_eof_rba[cur_tiot_index]) {
				_pz390.mem_byte[cur_decb_addr + decb_ecb] = (byte) 0x42; // post ecb for check eof exit
				return;
			}
			cur_dcb_area  = _pz390.mem.getInt(cur_decb_addr + decb_area) & _pz390.psw_amode;
			cur_dcb_recfm = _pz390.mem_byte[cur_dcb_addr+dcb_recfm] & 0xff;
			cur_dcb_lrecl_f = _pz390.mem.getInt(cur_dcb_addr + dcb_lrecl_f);  // RPI 587
			cur_dcb_blksi_f = _pz390.mem.getInt(cur_dcb_addr + dcb_blksi_f);  // RPI 587
			try {
				_pz390.mem_byte[cur_decb_addr + decb_ecb] = (byte) 0x80; // post ecb waiting for post
				if (cur_dcb_lrecl_f == 0) {
					cur_dcb_lrecl_f = cur_dcb_blksi_f; // use blksi if no lrecl
				}
				tz390.systerm_io++;
				check_mem_area(cur_dcb_area,cur_dcb_lrecl_f); // RPI 668
				tiot_file[cur_tiot_index].read(_pz390.mem_byte,cur_dcb_area,cur_dcb_lrecl_f);
				tiot_cur_rba[cur_tiot_index] = tiot_cur_rba[cur_tiot_index]+cur_dcb_lrecl_f;
			} catch (final Exception e) {
				_pz390.mem_byte[cur_decb_addr + decb_ecb] = (byte) 0x41; // post ecb for check synad exit
				return;
			}
			_pz390.mem_byte[cur_decb_addr + decb_ecb] = (byte) 0x40; // post ecb normal exit
		} else {
			dcb_synad_error(50,"file not found");
			return;
		}
	}

	/**
	 * Write next record forward or backward into area from dcb macrf r/rw file.
	 */
	private void svc_write() {
		tot_dcb_write++;
		tot_dcb_oper++;
		cur_decb_addr = _pz390.reg.getInt(pz390.r1) & _pz390.psw_amode;
		cur_dcb_addr  = _pz390.mem.getInt(cur_decb_addr + decb_dcb) & _pz390.psw_amode;
		check_dcb_addr();
		get_cur_tiot_index();
		if (cur_tiot_index != -1) {
			cur_dcb_area  = _pz390.mem.getInt(cur_decb_addr + decb_area) & _pz390.psw_amode;
			cur_dcb_recfm = _pz390.mem_byte[cur_dcb_addr+dcb_recfm] & 0xff;
			cur_dcb_lrecl_f = _pz390.mem.getInt(cur_dcb_addr + dcb_lrecl_f);  // RPI 587
			cur_dcb_blksi_f = _pz390.mem.getInt(cur_dcb_addr + dcb_blksi_f);  // RPI 587
			_pz390.mem_byte[cur_decb_addr + decb_ecb] = (byte) 0x80; // post ecb waiting for post
			try {
				if (cur_dcb_lrecl_f == 0) {
					cur_dcb_lrecl_f = cur_dcb_blksi_f; // use blksi if no lrecl
				}
				tz390.systerm_io++;
				check_mem_area(cur_dcb_area,cur_dcb_lrecl_f); // RPI 668
				tiot_file[cur_tiot_index].write(_pz390.mem_byte,cur_dcb_area,cur_dcb_lrecl_f);
				tiot_cur_rba[cur_tiot_index] = tiot_cur_rba[cur_tiot_index]+cur_dcb_lrecl_f;
				if (tiot_file[cur_tiot_index].length() > tz390.max_file_size) {
					abort_error(106, "Maximum file size exceeded for " + tiot_dsn[cur_tiot_index]);
				}
			} catch (final Exception e) {
				_pz390.mem_byte[cur_decb_addr + decb_ecb] = (byte) 0x41; // post ecb for check synad exit
				return;
			}
			_pz390.mem_byte[cur_decb_addr + decb_ecb] = (byte) 0x40; // post ecb normal exit
		} else {
			dcb_synad_error(52, "File not found");
		}
	}

	/**
	 * Check decb ecb and process as follows:
	 *   ecb = x'40' exit normally
	 *   ecb = x'41' take synad error exit
	 *   ecb = x'42' take eodad exit
	 */
	private void svc_check() {
		cur_decb_addr = _pz390.reg.getInt(pz390.r1) & _pz390.psw_amode;
		cur_dcb_addr  = _pz390.mem.getInt(cur_decb_addr + decb_dcb) & _pz390.psw_amode;
		check_dcb_addr();
		cur_ecb = _pz390.mem_byte[cur_decb_addr + decb_ecb];
		if (cur_ecb == 0x40) {
			return;
		} else if (cur_ecb == 0x42) {
			dcb_eodad_exit();
			return;
		} else {
			dcb_synad_error(90, "I/O error on read/write ECB=" + tz390.get_hex(_pz390.mem.getInt(cur_decb_addr + decb_ecb),8)); //RPI112
		}
	}

	/**
	 * set dcb file pointer
	 *   r1 = address of dcb
	 *   r0 = 64 bit rba
	 */
	private void svc_point() {
		cur_dcb_addr  = _pz390.reg.getInt(pz390.r1) & _pz390.psw_amode;
		check_dcb_addr();
		get_cur_tiot_index();
		if (cur_tiot_index != -1) {
			try {
				cur_rba = _pz390.reg.getLong(0);
				tiot_file[cur_tiot_index].seek(cur_rba);
				tiot_cur_rba[cur_tiot_index] = cur_rba;
			} catch (final Exception e) {
				dcb_synad_error(53,"i/o error on point - " + e.toString());
				return;
			}
		} else {
			dcb_synad_error(54,"file not found");
			return;
		}
	}

	/**
	 * Take synad exit if defined else issue error message and issue pgm check.
	 * @param error_num
	 * @param error_msg
	 */
	private void dcb_synad_error(final int error_num, final String error_msg) {
		if (dcb_synad_recur) return; // RPI 377
		dcb_synad_recur = true;
		_pz390.mem.putInt(pz390.r15,error_num);  //RPI53
		cur_dcbe_addr = _pz390.mem.getInt(cur_dcb_addr + dcb_dcbe) & _pz390.psw_amode;
		if (cur_dcbe_addr != 0) {  // RPI 281
			cur_dcb_synad = _pz390.mem.getInt(cur_dcbe_addr + dcbe_synad) & _pz390.psw_amode;
		} else {
			cur_dcb_synad = _pz390.mem.getInt(cur_dcb_addr + dcb_synad) & _pz390.psw_amode;
		}
		if (cur_dcb_synad == 0) {
			final String cur_ddnam = get_ascii_string(cur_dcb_addr + dcb_ddnam,8,true);
			final String cur_file  = get_dcb_file_name("");
			log_error(43,"I/O error for DCB=" + tz390.get_hex(cur_dcb_addr,8)
				+ " DDNAME=" + cur_ddnam
				+ " FILE=" + cur_file);
			log_error(error_num,error_msg);
			_pz390.set_psw_check(Constants.psw_pic_io); //RPI64
		} else {
			_pz390.set_psw_loc(cur_dcb_synad);
		}
		dcb_synad_recur = false; // RPI 377
	}

	/**
	 * Take eodad exit if defined else issue error message and abort.
	 */
	private void dcb_eodad_exit() {
		cur_dcbe_addr = _pz390.mem.getInt(cur_dcb_addr + dcb_dcbe) & _pz390.psw_amode;
		if (cur_dcbe_addr != 0) {  // RPI 281
			cur_dcb_eodad = _pz390.mem.getInt(cur_dcbe_addr + dcbe_eodad) & _pz390.psw_amode;
		} else {
			cur_dcb_eodad = _pz390.mem.getInt(cur_dcb_addr + dcb_eodad) & _pz390.psw_amode;
		}
		if (cur_dcb_eodad == 0) {
			abort_error(31, "Read at end of file and no EODAD for " + tiot_ddnam[cur_tiot_index]);
		} else {
			_pz390.set_psw_loc(cur_dcb_eodad);
		}
	}

	/**
	 * Validate that cur_dcb_addr is on full word bound and that DCBID = EBCDIC or ASCII C'DCB1' else abort
	 * Notes:
	 *   1.  Also reset dcb_synad_recur
	 *   2.  Increment DCB I/O request counter
	 */
	private void check_dcb_addr() {
		dcb_synad_recur = false; // RPI 377
		if (cur_dcb_addr/4*4 != cur_dcb_addr  // RPI 152
		 || !get_ascii_string(cur_dcb_addr + dcb_id,8,true).equals(tz390.dcb_id_ver)) {
			abort_error(80, "Invalid DCB address or ID at DCB=("
					+ tz390.get_hex(cur_dcb_addr,8)
					+ ")=" + _pz390.bytes_to_hex(_pz390.mem,cur_dcb_addr + dcb_id,8,0));
		}
		_pz390.mem.putInt(cur_dcb_addr + dcb_io,_pz390.mem.getInt(cur_dcb_addr + dcb_io)+1);  // RPI 764
	}

	/**
	 * 1.  Using cur_dcb address from R1 or DECB get cur_tiot index from DCBIOBAD (x'1C').
	 * 2.  reduce index in DCBIOBAD by 1.
	 * 3.  If index not -1, verify tiot_dcb_addr and that dcb is open.
	 * 4.  If index = -1 or dcb's don't match add new entry for DCBDDNAM.
	 */
	private void get_cur_tiot_index() {
		cur_tiot_index = _pz390.mem.getInt(cur_dcb_addr + dcb_iobad) - 1;
		if (cur_tiot_index  != -1) {
			if (cur_tiot_index >= 0   // RPI 966
			 && cur_tiot_index < tot_tiot_files
			 && cur_dcb_addr == tiot_dcb_addr[cur_tiot_index]) {
				return;
			} else {
				abort_error(20, "DCB tiot index invalid DCB=" + tz390.get_hex(cur_dcb_addr,8));
			}
		} else {
			cur_dcb_ddnam = get_ascii_string(cur_dcb_addr + dcb_ddnam,8,true);
			_pz390.mem.putInt(cur_dcb_addr + dcb_iobad,get_new_tiot_index(cur_dcb_ddnam,cur_dcb_addr));
		}
	}

	/**
	 * Return new tiot index or abort (used by DCB I/O and ASSIST).
	 * @param ddname
	 * @param dcb_addr
	 * @return
	 */
	private int get_new_tiot_index(final String ddname, final int dcb_addr) {
		cur_tiot_index = 0;
		while (cur_tiot_index < tot_tiot_files) {
			if (!tiot_dcb_open[cur_tiot_index]) {
				tiot_ddnam[cur_tiot_index] = ddname;
				tiot_dcb_addr[cur_tiot_index] = dcb_addr;
				return cur_tiot_index + 1;
			}
			cur_tiot_index++;
		}
		if (tot_tiot_files < max_tiot_files) {
			tot_tiot_files++;
			tiot_ddnam[cur_tiot_index] = ddname;
			tiot_dcb_addr[cur_tiot_index] = dcb_addr;
			return cur_tiot_index + 1;
		} else {
			abort_error(21, "Maximum tiot files open exceeded");
			return -1;
		}
	}

	/**
	 * Return environment variable string with leading and trailing spaces removed
	 * or return "" if not found.
	 * @param env_var_name
	 * @return
	 */
	public String get_ascii_env_var_string(final String env_var_name) {
		final String text = System.getenv(env_var_name);
		if (text != null) {
			return text.trim(); // RPI-0111
		} else {
			return "";
		}
	}

	/**
	 * Get ASCII string with no trailing spaces from memory address and length
	 * Notes:
	 *   1.  Translates from EBCDIC to ASCII unless in ASCII mode.
	 *   2.  Terminate string at first 0 byte if requested or at end of field.  RPI-0642 RPI-0685
	 * @param mem_addr
	 * @param mem_len
	 * @param null_term
	 * @return
	 */
	public String get_ascii_string(int mem_addr,int mem_len,boolean null_term) {
		String text = "";
		int index = 0;
		while (index < mem_len
			&& (!null_term  // RPI-0685 allow nulls in ASCII text records
				|| _pz390.mem_byte[mem_addr + index] != 0)) {  // RPI-0642
			if (tz390.opt_ascii) {
				text = text + tz390.ascii_table.charAt( _pz390.mem_byte[mem_addr + index] & 0xff); // RPI 1069
			} else {
				text = text + tz390.ascii_table.charAt( tz390.ebcdic_to_ascii[_pz390.mem_byte[mem_addr + index] & 0xff] & 0xff); //RPI42 RPI 1069
			}
			index++;
		}
		return ("x"+text).trim().substring(1);
	}

	/**
	 * Put ASCII string with trailing spaces to memory address and length.
	 * Notes:
	 *   1.  Translates from ASCII to EBCDIC unless ASCII mode
	 * @param text
	 * @param mem_addr
	 * @param mem_len
	 * @param pad_char
	 */
	public void put_ascii_string(final String text, int mem_addr, final int mem_len, final char pad_char) {
		mem_addr = mem_addr & _pz390.psw_amode; // RPI-0712
		if (mem_addr + mem_len > _pz390.tot_mem) {
			log_error(114,"invalid put ascii text address for msg = " + text
				+ " LEN=" + mem_len + "ADDR=" + tz390.get_hex(mem_addr,8)); // RPI-1120
			return;
		}
		int index = 0;
		while (index < mem_len) {
			char text_char;
			if (index < text.length()) {
				text_char = text.charAt(index);
			} else {
				text_char = pad_char;
			}
			if (tz390.opt_ascii) {
				_pz390.mem_byte[mem_addr + index] = (byte)(text_char & 0xff); // RPI 551
			} else {
				_pz390.mem_byte[mem_addr + index] = tz390.ascii_to_ebcdic[text_char & 0xff];
			}
			index++;
		}
	}

	/**
	 * Execute OS command process
	 *   r0+1 = CMDLOG x'00', NOCMDLOG x'01'
	 *   r0+2 = cmd process id 0-9
	 *   r0+3 = cmd operation type
	 *   r1   = A(command)
	 *   r2   = command length
	 *   r3   = timeout wait limit in milli-sec
	 */
	private void svc_cmd() {
		String svc_cmd_text = "";
		final int cmd_id     = _pz390.reg.get(pz390.r0 + 2);
		final int cur_cmd_op = _pz390.reg.get(pz390.r0 + 3);
		switch (cur_cmd_op) {
		case 0: // start command process at R1
			if (cmd_processors[cmd_id].cmd_proc_running) {
				cmd_processors[cmd_id].cmd_cancel();
			}
			cmd_startup(cmd_id);
			if (tz390.opt_time) {
				_pz390.cur_date = new Date();
			}
			_pz390.reg.putInt(pz390.r15,0);
			break;
		case 1: // close windows command process
			if (cmd_processors[cmd_id].cmd_proc_running) {
				cmd_processors[cmd_id].cmd_cancel();
			}
			_pz390.reg.putInt(pz390.r15,0);
			break;
		case 2: // send command string at R1, null term
			if (cmd_processors[cmd_id].cmd_proc_running) {
				svc_cmd_text = tz390.get_ascii_var_string(_pz390.mem_byte,_pz390.reg.getInt(pz390.r1),max_lsn_spec);
				cmd_input(cmd_id,svc_cmd_text);
				_pz390.reg.putInt(pz390.r15,0);
			} else {
				_pz390.reg.putInt(pz390.r15,8);
			}
			break;
		case 3:
			// read next process output line into area at r1 padded to length in r2
			// wait for output up up to r3 milliseconds
			// r15 =  0 record returned OK
			// r15 =  4 no record in time allowed
			// r15 =  8 no record and process terminated
			// r15 = 16 i/o error during operation see log
			if (!cmd_processors[cmd_id].cmd_proc_running) {
				_pz390.reg.putInt(pz390.r15,8);
			}
			try {
				int cmd_read_wait = _pz390.reg.getInt(pz390.r3);
				try { // RPI 1113
					cmd_processors[cmd_id].cmd_read_line = cmd_get_queue(cmd_id);
				} catch (final Exception e) {
					cmd_processors[cmd_id].cmd_read_line = null;
				}
				cmd_processors[cmd_id].cmd_proc_start_time = System.currentTimeMillis(); // RPI-545
				while (cmd_processors[cmd_id].cmd_read_line == null
					&& cmd_processors[cmd_id].cmd_proc_running
					&& cmd_processors[cmd_id].cmd_proc_rc() == -1
					&& (cmd_read_wait == 4095  // RPI 1113 wait forever
						|| System.currentTimeMillis() - cmd_processors[cmd_id].cmd_proc_start_time < cmd_read_wait)) {
					tz390.sleep_now(tz390.monitor_wait);
					try { // trap and set null RPI-1113
						cmd_processors[cmd_id].cmd_read_line = cmd_get_queue(cmd_id);
					} catch (final Exception e) {
						cmd_processors[cmd_id].cmd_read_line = null;
					}
				}
				if (cmd_processors[cmd_id].cmd_read_line != null) {
					put_ascii_string(cmd_processors[cmd_id].cmd_read_line, _pz390.reg.getInt(pz390.r1), _pz390.reg.getInt(pz390.r2),' ');
					_pz390.reg.putInt(pz390.r15,0);
				} else if (cmd_processors[cmd_id].cmd_proc_running
						&& cmd_processors[cmd_id].cmd_proc_rc() == -1) {
					_pz390.reg.putInt(pz390.r15,4);
				} else {
					_pz390.reg.putInt(pz390.r15,12);
				}
			} catch (final Exception e) {
				log_error(76,"Cmd read I/O error - " + e.toString());
				_pz390.reg.putInt(pz390.r15,16);
			}
			break;
		}
	}

	/**
	 * Start Windows command processor with synchronized buffered output.
     * Notes:
     *   1.  Start process cmd_id
     *   2.  Send input commands via cmd_input(id,msg)
     *   3.  Retrieve output from cmd_output_queue
     *   4.  Cancel via cmd_cancel(cur_id);
	 * @param cmd_id
	 * @return
	 */
	private int cmd_startup(final int cmd_id) {
		if (_pz390.reg.get(pz390.r0+1) == 1) { // RPI-731 default is copy output to log
			cmd_processors[cmd_id].cmd_proc_cmdlog = true;
		} else {
			cmd_processors[cmd_id].cmd_proc_cmdlog = false;
		}
		int rc;
		String[] cmd_parms;
		final InfoOS infoOS = InfoOS.getInstance();
		try {
			if (infoOS.isLinux()) {
				cmd_parms = new String[2];
				cmd_parms[0] = infoOS.get_z390_command();
				cmd_parms[1] = tz390.jar_file_dir() + "/cmd.pl"; // RPI 500
			} else {
				cmd_parms = new String[1];
				cmd_parms[0] = infoOS.get_z390_command();
			}
			rc = cmd_proc_start(cmd_id,cmd_parms);
			if  (rc != 0) {
				log_error(67,"CMD task startup error rc = " + rc);
				cmd_processors[cmd_id].cmd_cancel();
			}
			return rc;
		} catch (final Exception e) {
			log_error(66,"execution startup error - " + e.toString());
			cmd_processors[cmd_id].cmd_cancel();
			return 16;
		}
	}

	/**
	 * 1. Terminate any prior command process with error if non zero completion.
	 * 2. Start new process running on separate thread.
	 *
	 * Note: Command monitor will issue exec_term if timeout limit is reached before next
	 *       start command does it.  Error will be issued by exec_term if non zero return code
	 *       or if process had to be cancelled.
	 *
	 * @param cmd_id
	 * @param exec_cmd
	 * @return
	 */
	public int cmd_proc_start(final int cmd_id, final String[] exec_cmd) {
		int rc;
		if (cmd_id + 1 > tot_cmd) {
			tot_cmd = cmd_id + 1;
		}
		if (cmd_processors[cmd_id].cmd_proc_running) {
			rc = cmd_processors[cmd_id].cmd_proc_rc();
			if (rc != 0) {
				if (rc == -1) {
					log_error(68, "Previous command execution cancelled.");
					cmd_processors[cmd_id].cmd_cancel();
				} else {
					log_error(69, "Previous command execution ended with rc =" + rc + ".");
				}
			}
		}
		try {
			cmd_processors[cmd_id].cmd_proc = Runtime.getRuntime().exec(exec_cmd);
			cmd_processors[cmd_id].cmd_error_reader  = new BufferedReader(new InputStreamReader(cmd_processors[cmd_id].cmd_proc.getErrorStream())); // RPI-731
			cmd_processors[cmd_id].cmd_output_reader = new BufferedReader(new InputStreamReader(cmd_processors[cmd_id].cmd_proc.getInputStream())); // RPI-731
			cmd_processors[cmd_id].cmd_input_writer  = new PrintStream(cmd_processors[cmd_id].cmd_proc.getOutputStream());
			cmd_processors[cmd_id].cmd_proc_thread   = new Thread(this);
			cmd_processors[cmd_id].cmd_error_thread  = new Thread(this);
			cmd_processors[cmd_id].cmd_output_thread = new Thread(this);
			cmd_processors[cmd_id].cmd_output_msg    = "";
			cmd_processors[cmd_id].cmd_error_msg     = "";
			cmd_processors[cmd_id].cmd_output_queue  = new LinkedList<String>();
			cmd_processors[cmd_id].cmd_error_msg     = "";
			cmd_processors[cmd_id].cmd_proc_io       = 0;
			cmd_processors[cmd_id].cmd_proc_running  = true;  // RPI-592
			cmd_processors[cmd_id].cmd_proc_thread.start();
			cmd_processors[cmd_id].cmd_error_thread.start();
			cmd_processors[cmd_id].cmd_output_thread.start();
			tz390.sleep_now(tz390.monitor_wait); // wait for first io
			int wait_count = 5;
			while (cmd_processors[cmd_id].cmd_proc_io == 0 && wait_count > 0) {
				tz390.sleep_now(tz390.monitor_wait);
				wait_count--;
			}
			return 0;
		} catch (final Exception e) {
			log_error(70,"execution startup error " + e.toString());
			cmd_processors[cmd_id].cmd_cancel();
			return -1;
		}
	}

	/**
	 * Send input to exec command in process.
	 * @param cmd_id
	 * @param cmd_line
	 */
	private synchronized void cmd_input(final int cmd_id, final String cmd_line) {
		try {
			tz390.systerm_io++;
			if (cmd_line == null) {  // RPI-731
				cmd_processors[cmd_id].cmd_input_writer.println("");
			} else {
				cmd_processors[cmd_id].cmd_input_writer.println(cmd_line);
			}
			// cmd_io_total++; // JBA-unused
			cmd_processors[cmd_id].cmd_proc_io++;
			cmd_processors[cmd_id].cmd_input_writer.flush();
		} catch (final Exception e) {
			log_error(71,"Execution input error" + e.toString());
		}
	}

	/**
	 * Wait for comproc threads to end normally or issue error if abnormal termination.
	 */
	public void run() {
		int cmd_id = 0;
		while (cmd_id < tot_cmd) {
			if (cmd_processors[cmd_id].cmd_proc_running // RPI-592
			 && cmd_processors[cmd_id].cmd_proc_thread == Thread.currentThread()) {
				// io_count++; // JBA-unused
				cmd_processors[cmd_id].cmd_proc_io++;
				try {
					cmd_processors[cmd_id].cmd_proc.waitFor();
				} catch (final Exception e) {
					abort_error(79, "Cmd proc wait error " + e.toString());
				}
				return;
			} else if (cmd_processors[cmd_id].cmd_proc_running // RPI-592
					&& cmd_processors[cmd_id].cmd_output_thread == Thread.currentThread()) {
				copy_cmd_output_to_queue(cmd_id);
				return;
			} else if (cmd_processors[cmd_id].cmd_proc_running // RPI-592
					&& cmd_processors[cmd_id].cmd_error_thread == Thread.currentThread()) {
				copy_cmd_error_to_queue(cmd_id);
				return;
			}
			cmd_id++;
		}

		// wait for next connection on each server
		// port thread, create connection and repeat
		int port_index = 0;
		while (tcpio_server_running && port_index < max_tcp_server_port) {
			if (tcp_server_port[port_index] > 0
			 && tcp_server_thread[port_index] != null
			 && tcp_server_thread[port_index] == Thread.currentThread()) {
				while (tcp_server_open[port_index] // RPI 622
					&& tcp_alloc_conn(port_index)) {
					int conn_index = tcp_server_conn_index[port_index]; // get allocated conn
					try {
						// this connection thread will wait here for next connection
						if (tz390.opt_tracet) {
							put_log("TCPIO waiting for connection on port=" + tcp_conn_server_port[conn_index]);
						}
						tcp_conn_socket[conn_index] = tcp_server_socket[port_index].accept();
						tcp_conn_input[ conn_index] = new DataInputStream(tcp_conn_socket[conn_index].getInputStream());
						tcp_conn_output[conn_index] = new PrintStream(tcp_conn_socket[conn_index].getOutputStream());
						tcp_conn_thread[conn_index] = new Thread(this);
						tcp_conn_thread[conn_index].start();
						if (tz390.opt_tracet) {
							put_log("TCPIO new connection on port=" + tcp_conn_server_port[conn_index] + " conn=" + tcp_server_conn_index[port_index]);
						}
					} catch (final Exception e) {
						if (tcp_server_open[port_index]) {
							put_log("TCPIO error starting connection for port=" + tcp_server_port[port_index]);
						}
						tcp_free_conn(conn_index);
					}
				}
			}
			port_index++;
		}

		int conn_index = 0;
		while (tcpio_server_running && conn_index < max_tcp_conn) {
			// find and run connection thread
			if (tcp_conn_server_port[conn_index] > 0
			 && tcp_conn_thread[conn_index] != null
			 && tcp_conn_thread[conn_index] == Thread.currentThread()) {
				while (tcpio_server_running) {
					// This is a live connection thread which runs following loop until server port closed
					//   1   While message ready on connection signal TCPIO main user thread and then yield.
					//   2   Read 1 byte from connection
					//   3   if disconnect, release connection and terminate thread else set conn msg avail
					//   4.  repeat
					try {
						while (tcpio_server_running
							&& tcp_conn_msg_ready[conn_index]) {
							lock.lock();
							try { // signal TCPIO main user thread to check for connection messages
								lock_condition.signalAll();
							} catch (final Exception e) {
								put_log("TCPIO disconnect during post for conn=" + conn_index + " port="  + tcp_conn_server_port[conn_index]);
								tcpio_close_conn(conn_index);
								return; // kill this thread
							} finally {
								lock.unlock();
							}
							// let tcpio main thread run until all current connection messages are read
							Thread.yield();
						}
					} catch(final Exception e) {
						put_log("TCPIO disconnect during yield for conn=" + conn_index + " port="  + tcp_conn_server_port[conn_index]);
						tcpio_close_conn(conn_index);
						return; // kill this thread
					}
					try {
						// thread waits here for 1 byte read or disconnect interrupt
						tcp_conn_byte[conn_index] = tcp_conn_input[conn_index].readByte();
						tcp_conn_read[conn_index] = true;
						if (tz390.opt_tracet) {
							put_log("TCPIO msg received on conn=" + conn_index + " LEN=" +(1+tcp_conn_input[conn_index].available()));
						}
						tcpio_set_conn_msg_ready(conn_index,true);
					} catch (final Exception e) {
						if (tcpio_server_running) {
							put_log("TCPIO disconnect during read for conn=" + conn_index + " port="  + tcp_conn_server_port[conn_index]);
							tcpio_close_conn(conn_index);
							return; // kill this task
						}
					}
				}
			}
			conn_index++;
		}
	}

	/**
	 * Copy cmd output lines to output queue.
	 * @param cmd_id
	 */
	public void copy_cmd_output_to_queue(int cmd_id) {
		try {
			tz390.systerm_io++;
			String msg = cmd_processors[cmd_id].cmd_output_reader.readLine();
			while (cmd_processors[cmd_id].cmd_proc_running // RPI-592
				&& msg != null) {
				cmd_processors[cmd_id].cmd_proc_io++;
				if (msg.equals("z390_abort_request")) {  // RPI 731
					System.out.println("EZ390E z390 abort request from CMD ID=" + cmd_id);
					tz390.z390_abort = true;
				} else {
					cmd_put_queue(cmd_id,msg);
					tz390.systerm_io++;
				}
				msg = cmd_processors[cmd_id].cmd_output_reader.readLine();
			}
		} catch (final Exception e) {
			if (cmd_processors[cmd_id].cmd_proc_running) {
				log_error(73,"Cmd process output error - " + e.toString());
				cmd_processors[cmd_id].cmd_cancel();
			}
		}
	}

	/**
	 * Copy cmd error lines to output queue.
	 * @param cmd_id
	 */
	public void copy_cmd_error_to_queue(final int cmd_id) {
		try {
			tz390.systerm_io++;
			String msg = cmd_processors[cmd_id].cmd_error_reader.readLine();
			while (cmd_processors[cmd_id].cmd_proc_running // RPI 592
				&& msg != null) {
				cmd_processors[cmd_id].cmd_proc_io++;
				if (msg.trim().length() > 0) {
					tz390.systerm_io++;
					cmd_put_queue(cmd_id,msg);
				}
				msg = cmd_processors[cmd_id].cmd_error_reader.readLine();
			}
		} catch (final Exception ex) {
			if (cmd_processors[cmd_id].cmd_proc_running) { // RPI-592
				log_error(74,"Cmd exec execution output error");
				cmd_processors[cmd_id].cmd_cancel();
			}
		}
	}

	/*
	 * Add output to linklist queue.
	 * Synchronized, so output and main thread retrieval via CMDPROC READ are safe.
	 * @param cmd_id
	 * @param msg
	 */
	private synchronized void cmd_put_queue(final int cmd_id, final String msg) {
		if (msg.length() == 0)
			return;
		tot_log_queue++;
		if (!tz390.max_cmd_queue_exceeded
		  && tot_log_queue > tz390.opt_maxque) {
			log_error(116, "CMD MSG MAXQUE EXCEEDED - COPYING ALL CMD OUTPUT TO LOG.");
			tz390.max_cmd_queue_exceeded = true;
		}
		if (msg.equals("z390_abort_request")) { // RPI-731
			log_error(117, "z390 abort request from CMD ID=" + cmd_id + ".");
			tz390.max_cmd_queue_exceeded = true;
		}
		if (cmd_processors[cmd_id].cmd_proc_running // RPI-592
		&& !cmd_processors[cmd_id].cmd_output_queue.offer(msg)) {
			log_error(77, "Cmd process output queue io error.");
		}
	}

	/**
	 * Retrieve next FIFO line from linklist queue.<br>
	 * Synchronized, so output and main thread retrieval via CMDPROC READ are safe.<br>
	 * If no string ready, return null.
	 * @param cmd_id
	 * @return
	 */
	public synchronized String cmd_get_queue(final int cmd_id) {
		if (!cmd_processors[cmd_id].cmd_proc_running) { // RPI-592
			return null;
		}
		try {
			final String cmd_output_line = cmd_processors[cmd_id].cmd_output_queue.remove();
			tot_log_queue--;
			return cmd_output_line;
		} catch (final Exception e) {
			return null;
		}
	}

	/**
	 * Read or write to TN3270 terminal.<br>
	 * Notes:<br>
	 *   1.  If GUAM GUI Access Method enabled, read or write to the GUAM GUI dialog.<br>
	 *   2.  If no GUAM interface and EDIT mode use WTO/WTOR to MCS console, else error.
	 */
	private synchronized void svc_tget_tput() { // RPI 318
		tpg_flags = _pz390.reg.get(pz390.r1) & 0xff;
		gz390.setTpgFlags(tpg_flags);
		gz390.setTpgType(tpg_flags & tpg_type_mask);
		final int buff_len  = _pz390.reg.getShort(pz390.r0+2);
		final int buff_addr = _pz390.reg.getInt(pz390.r1) & pz390.psw_amode24;
		String wto_msg = null;
		if (tz390.opt_guam) {
			if ((tpg_flags & tpg_op_mask) == tpg_op_tput) {
				// TPUT
				gz390.setTputLen(buff_len);
				if (gz390.getTputLen() > tput_buff.limit()) {
					abort_error(59, "GUAM GUI tput length too long.");
				}
				gz390.getTputBuff().position(0);
				gz390.getTputBuff().put(_pz390.mem_byte, buff_addr, buff_len);
				if (tz390.opt_tracet) { // RPI 671
					tz390.put_trace("");
					dump_mem(_pz390.mem,buff_addr,buff_len);
					tz390.put_trace("");
				}
				gz390.guam_tput();
				if (tz390.z390_abort) {
					abort_error(59, "GUAM GUI tput external abort.");
				}
			} else {
				// TGET
				gz390.setTgetLen(buff_len);
				gz390.guam_tget();
				if (tz390.z390_abort) {
					abort_error(60,"GUAM GUI tget abort");
				}
				if (gz390.getTpgRC() == 0) { // RPI 712
					_pz390.mem.position(buff_addr);
					// move tget_len actual and set R1= bytes returned
					_pz390.mem.put(gz390.getTgetByte(), 0, gz390.getTgetLen());
					if (tz390.opt_tracet) {  // RPI 671
						tz390.put_trace("");
						tz390.put_trace(" TGET bytes received = " + tz390.get_hex(gz390.getTgetLen(),4));
						dump_mem(_pz390.mem,buff_addr,gz390.getTgetLen());
						tz390.put_trace("");
					}
					_pz390.reg.putInt(pz390.r1,gz390.getTgetLen());
				}
			}
			_pz390.reg.putInt(pz390.r15,gz390.getTpgRC()); // RPI 221 set return code
		} else {
			switch (tpg_flags & tpg_type_mask) {
			case 0x00: // EDIT type
			case 0x01: // ASIS type
				if ((tpg_flags & tpg_op_mask) == tpg_op_tput) { // TPUT
					wto_msg = get_ascii_string(buff_addr,buff_len,false);
					put_log("TPUT MSG = " + wto_msg);
					_pz390.reg.putInt(pz390.r15,0); // RPI 221 set retrun code
				} else { // TGET
					if (!wtor_reply_pending) {
						wtor_reply_addr = buff_addr;
						wtor_reply_len  = buff_len;
						wtor_ecb_addr   = pz390.zcvt_tget_ecb & _pz390.psw_amode;
						wto_msg("TGET ENTER",0,0);
						_pz390.mem.putInt(wtor_ecb_addr,ecb_waiting); // ecb waiting for post by montior wtorit
						wtor_reply_string  = null;
						wtor_reply_pending = true;
					}
					while ((tpg_flags & tpg_wait_mask) == tpg_wait
						&& (_pz390.mem.getInt(wtor_ecb_addr) & ecb_waiting) == ecb_waiting) {
						tz390.sleep_now(tz390.monitor_wait);
					}
					if (wtor_reply_string != null) {
						_pz390.reg.putInt(pz390.r15,0);
					} else {
						_pz390.reg.putInt(pz390.r15,4);
					}
				}
				break;
			case 0x10: // CONTROL
				// ignore for now
				break;
			case 0x11: // FULLSCR
				abort_error(108, "tget/tput fullscr type requires GUAM option.");
				_pz390.reg.putInt(pz390.r15,8); // RPI 221 set retrun code
			}
		}
	}

	/**
	 * GUAM Graphical User Access Method for user I/O via GUAM GUI dialog window with 3 views:<br>
	 *   1.  MCS    - view for WTO and WTOR I/O<br>
	 *   2.  SCREEN - view for TPUT and TGET I/0<br>
	 *   3.  GRAPH  - view for graphics<br>
	 * r1 = major/minor opcode bytes
	 */
	private void svc_guam() {
		if (!tz390.opt_guam) {
			abort_error(104, "GUAM GUI option not specified - aborting.");
		}

		guam_major = _pz390.reg.get(   pz390.r0+2);
		guam_minor = _pz390.reg.get(   pz390.r0+3);
		guam_args  = _pz390.reg.getInt(pz390.r1  ) & _pz390.psw_amode;

		_pz390.reg.putInt(pz390.r15,0);

		switch (guam_major) {
		case 1: // WINDOW
			switch (guam_minor) {
			case 1: // TITLE,"text"
				guam_text = tz390.get_ascii_var_string(_pz390.mem_byte,_pz390.mem.getInt(guam_args),256);
				gz390.guam_window_title(guam_text);
				break;
			case 2: // LOC,x,y
				guam_x = _pz390.mem.getInt(guam_args  );
				guam_y = _pz390.mem.getInt(guam_args+4);
				gz390.guam_window_loc(guam_x,guam_y);
				break;
			case 3: // SIZE,width,height
				guam_width  = _pz390.mem.getInt(guam_args  );
				guam_height = _pz390.mem.getInt(guam_args+4);
				gz390.guam_window_size(guam_width,guam_height);
				break;
			case 4: // FONT,size
				guam_font = _pz390.mem.getInt(guam_args);
				gz390.guam_window_font(guam_font);
				break;
			case 5: // VIEW,mode,x,y,color
				guam_view = GuamViewTypes.fromInteger(_pz390.mem.getInt(guam_args));
				if (guam_view != GuamViewTypes.MCS) {
					guam_x     = _pz390.mem.getInt(_pz390.mem.getInt(guam_args+ 4) & _pz390.psw_amode);
					guam_y     = _pz390.mem.getInt(_pz390.mem.getInt(guam_args+ 8) & _pz390.psw_amode);
					guam_color = _pz390.mem.getInt(_pz390.mem.getInt(guam_args+12) & _pz390.psw_amode);
				}
				gz390.guam_window_view(guam_view,guam_x,guam_y,guam_color);
				break;
			case 6: // GETVIEW - return current view
				if (tz390.opt_guam) {
					guam_view = gz390.guam_window_getview();
				} else {
					guam_view = GuamViewTypes.MCS;
				}
				_pz390.reg.putInt(pz390.r0, guam_view.getViewTypeNumber());
				break;
			default:
				log_error(94, "Undefined GUAM GUI Window command - " + guam_minor + ".");
				_pz390.reg.putInt(pz390.r15,8);
			}
			break;
		case 2: // SCREEN
			switch (guam_minor) {
			case 1: // READ,buff,lbuff,WAIT/NOWAIT
				guam_abuff = _pz390.mem.getInt(guam_args  );
				guam_lbuff = _pz390.mem.getInt(guam_args+4);
				guam_wait  = _pz390.mem.getInt(guam_args+8) == 1;
				_pz390.mem.position(guam_abuff);
				_pz390.mem.put(gz390.guam_screen_read(guam_lbuff,guam_wait));
				break;
			case 2: // WRITE,row,col,buff,lbuff,color
				guam_row   = _pz390.mem.getInt(guam_args   );
				guam_col   = _pz390.mem.getInt(guam_args+ 4);
				guam_abuff = _pz390.mem.getInt(guam_args+ 8);
				guam_lbuff = _pz390.mem.getInt(guam_args+12);
				guam_color = _pz390.mem.getInt(guam_args+16);
				tput_buff.position(0);
				tput_buff.put(_pz390.mem_byte,guam_abuff,guam_abuff+guam_lbuff);
				gz390.guam_screen_write(guam_row,guam_col,tput_buff,guam_lbuff,guam_color);
				break;
			case 3: // FIELD,row,col,length
				guam_row   = _pz390.mem.getInt(guam_args);
				guam_col   = _pz390.mem.getInt(guam_args+4);
				guam_lfield  = _pz390.mem.getInt(guam_args+8);
				gz390.guam_screen_field(guam_row,guam_col,guam_lfield);
				break;
			case 4: // CURSOR,row,col,type
				guam_row   = _pz390.mem.getInt(guam_args);
				guam_col   = _pz390.mem.getInt(guam_args+4);
				guam_cursor_type  = _pz390.mem.getInt(guam_args+8);
				gz390.guam_screen_cursor(guam_row,guam_col,guam_cursor_type);
				break;
			case 5: // COLOR,background rgb, text rgb
				guam_bg_rgb   = _pz390.mem.getInt(_pz390.mem.getInt(guam_args) & _pz390.psw_amode);
				guam_text_rgb = _pz390.mem.getInt(_pz390.mem.getInt(guam_args+4) & _pz390.psw_amode);
				gz390.guam_screen_color(guam_bg_rgb,guam_text_rgb);
				break;
			default:
				log_error(95, "Undefined GUAM GUI Screen command - " + guam_minor + ".");
				_pz390.reg.putInt(pz390.r15,8);
			}
			break;
		case 3: // GRAPH
			switch (guam_minor) {
			case 1: // POINT,x,y,color
				guam_x     = _pz390.mem.getInt(guam_args);
				guam_y     = _pz390.mem.getInt(guam_args+4);
				guam_color = _pz390.mem.getInt(guam_args+8);
				gz390.guam_graph_point(guam_x,guam_y,guam_color);
				break;
			case 2: // LINE,x1,y1,x2,y2,color
				guam_x     = _pz390.mem.getInt(guam_args);
				guam_y     = _pz390.mem.getInt(guam_args+4);
				guam_x2     = _pz390.mem.getInt(guam_args+8);
				guam_y2     = _pz390.mem.getInt(guam_args+12);
				guam_color = _pz390.mem.getInt(guam_args+16);
				gz390.guam_graph_line(guam_x,guam_y,guam_x2,guam_x2,guam_color);
				break;
			case 3: // FILL,x1,y1,x2,y2,color
				guam_x     = _pz390.mem.getInt(guam_args);
				guam_y     = _pz390.mem.getInt(guam_args+4);
				guam_x2     = _pz390.mem.getInt(guam_args+8);
				guam_y2     = _pz390.mem.getInt(guam_args+12);
				guam_color = _pz390.mem.getInt(guam_args+16);
				gz390.guam_graph_fill(guam_x,guam_y,guam_x2,guam_y2,guam_color);
				break;
			case 4: // TEXT,x,y,buff,lbuff,color
				guam_row   = _pz390.mem.getInt(guam_args);
				guam_col   = _pz390.mem.getInt(guam_args+4);
				guam_abuff = _pz390.mem.getInt(guam_args+8);
				guam_lbuff = _pz390.mem.getInt(guam_args+12);
				guam_color = _pz390.mem.getInt(guam_args+16);
				tput_buff.position(0);
				tput_buff.put(_pz390.mem_byte,guam_abuff,guam_lbuff);
				gz390.guam_screen_write(guam_row,guam_col,tput_buff,guam_lbuff,guam_color);
				break;
			default:
				log_error(96, "Undefined GUAM GUI Graph command - " + guam_minor + ".");
				_pz390.reg.putInt(pz390.r15,8);
			}
			break;
		case 4: // KEYBOARD
		switch (guam_minor) {
			case 1: // READ,mod,char,WAIT/NOWAIT
				guam_key_amod = _pz390.mem.getInt(guam_args);
				guam_key_achar = _pz390.mem.getInt(guam_args+4);
				guam_wait = _pz390.mem.getInt(guam_args+8) == 1;
				guam_key = gz390.guam_keyboard_read(guam_wait);
				if (guam_key != -1) {
					_pz390.mem.putInt(guam_key_amod,guam_key >> 8);
					_pz390.mem.putInt(guam_key_achar,guam_key & 0xff);
				} else {
					_pz390.reg.putInt(pz390.r15,4);
				}
				break;
			default:
				log_error(97, "Undefined GUAM GUI Keyboard command - " + guam_minor + ".");
				_pz390.reg.putInt(pz390.r15,8);
			}
			break;
		case 5: // MOUSE
			switch (guam_minor) {
			case 1: // READ,x,y,left,right
				guam_x     = _pz390.mem.getInt(guam_args);
				guam_y     = _pz390.mem.getInt(guam_args+4);
				guam_left  = _pz390.mem.getInt(guam_args+8);
				guam_right = _pz390.mem.getInt(guam_args+12);
				guam_mouse = gz390.guam_mouse_read();
				_pz390.mem.putInt(guam_x,guam_mouse[0]);
				_pz390.mem.putInt(guam_x,guam_mouse[1]);
				_pz390.mem.putInt(guam_left,guam_mouse[2]);
				_pz390.mem.putInt(guam_right,guam_mouse[3]);
				break;
			default:
				log_error(98, "Undefined GUAM GUI Mouse command - " + guam_minor + ".");
				_pz390.reg.putInt(pz390.r15,8);
			}
		case 6: // SOUND
			switch (guam_minor) {
			case 1: // PLAY,"wav_file"
				guam_abuff = _pz390.mem.getInt(guam_args);
				guam_text = tz390.get_ascii_var_string(_pz390.mem_byte,guam_abuff,max_lsn_spec);
				gz390.guam_sound_play(guam_text);
				break;
			default:
				log_error(99, "Undefined GUAM GUI Sound command - " + guam_minor + ".");
				_pz390.reg.putInt(pz390.r15,8);
			}
			if (tz390.z390_abort) {
				abort_error(61, "GUAM GUI svc abort.");
			}
		}
	}

	/**
	 * Snap dump control blocks and/or memory.
	 */
	private void svc_snap() {
		/*
		 *   r0 - flags
		 *     x'8000' - dump storage range (r14,r15)
		 *     x'4000' - dump gpr r0-r15
		 *     x'2000' - dump fpr f0-f15
		 *     x'1000' - dump cde program info
		 *     x'0800' - dump dcb file info
		 *     x'0400' - dump all memory
		 */
		final int text_addr = _pz390.reg.getInt(pz390.r1);
		if (text_addr > 0) {
			put_log("SNAP DUMP ID=" + _pz390.reg.getShort(pz390.r0+2)
			  	  + " TEXT=" + get_ascii_string(text_addr,60,true)
			);
		} else {
			put_log("SNAP DUMP ID=" + _pz390.reg.getShort(pz390.r0+2));
		}
		final int flags = _pz390.reg.getShort(pz390.r0);
		if ((flags & 0x4000) != 0) {
			dump_gpr(-1);
		}
		if ((flags & 0x2000) != 0) {
			dump_fpr(-1);
		}
		if ((flags & 0x1000) != 0) {
			dump_cde();
		}
		if ((flags & 0x0800) != 0) {
			dump_tiot();
		}
		if ((flags & 0x8000) != 0) {
			final int dump_addr =  _pz390.reg.getInt(pz390.r14) & _pz390.psw_amode;
			final int dump_len  = (_pz390.reg.getInt(pz390.r15) & _pz390.psw_amode) - dump_addr;
			dump_mem(_pz390.mem,dump_addr,dump_len);
		} else if ((flags & 0x0400) != 0) { // RPI 583
			dump_mem(_pz390.mem,0,_pz390.tot_mem);
		}
	}

	/**
	 * Dump cde entries for all loaded pgms and files RPI 583
	 */
	private void dump_cde_pgms() {
		int index = 0;
		boolean first_line = true;
		while (index < tot_cde) {
			if (cde_loc[index] != 0) {
				if (first_line) {
					first_line = false;
				} else {
					put_dump("");
				}
				if (cde_ent[index] != -1) {
					put_dump( " CDE  PGM=" + cde_name[index]
							+ " ENT=" + tz390.get_hex(cde_ent[index],8)
							+ " LOC=" + tz390.get_hex(cde_loc[index],8)
							+ " LEN=" + tz390.get_hex(cde_len[index],8)
							+ " USE=" + tz390.get_hex(cde_use[index],2) // RPI 1063 1 byte use count
							+ tz390.newline); // RPI 500
				} else {
					put_dump( " CDE  DSN=" + cde_name[index]
							+ " LOC=" + tz390.get_hex(cde_loc[index],8)
							+ " LEN=" + tz390.get_hex(cde_len[index],8)
							+ " USE=" + tz390.get_hex(cde_use[index],2) // RPI 1063 1 byte use count
							+ tz390.newline); // RPI 500
				}
			}
			index++;
		}
	}

	/**
	 * Dump current program cde entries.
	 */
	private void dump_cde() {
		int index = 0;
		while (index < tot_cde) {
			if (cde_loc[index] != 0) {
				if (cde_ent[index] != -1) {
					put_dump( " CDE  PGM=" + cde_name[index]
							+ " ENT=" + tz390.get_hex(cde_ent[index],8)
							+ " LOC=" + tz390.get_hex(cde_loc[index],8)
							+ " LEN=" + tz390.get_hex(cde_len[index],8)
							+ " USE=" + tz390.get_hex(cde_use[index],2) // RPI 1063
					);
				} else {
					put_dump( " CDE  DSN=" + cde_name[index]
							+ " LOC=" + tz390.get_hex(cde_loc[index],8)
							+ " LEN=" + tz390.get_hex(cde_len[index],8)
							+ " USE=" + tz390.get_hex(cde_use[index],2)  // RPI 1063
					);
				}
			}
			index++;
		}
	}

	/**
	 * dump content of tiot entries
	 */
	public void dump_tiot() {
		boolean any_found = false;
		int index = 0;
		String dsn;
		while (index < tot_tiot_files) {
			if (tiot_dsn[index] != null) {
				dsn = tiot_dsn[index];
			} else {
				dsn = "";
			}
			any_found = true;
			put_dump( " TIOT  DDNAME=" + tz390.left_justify(tiot_ddnam[index],8)
		      		+ " DCB=" + tz390.get_hex(tiot_dcb_addr[index],8)
		      		+ " DCBOFLGS=" + tz390.get_hex(_pz390.mem_byte[tiot_dcb_addr[index] + dcb_oflgs] & 0xff,2)
		      		+ " DSN=" + dsn
			);
			index++;
		}
		if (!any_found) {
			put_dump(" TIOT NO DCB ENTRIES FOUND");
		}
	}

	/**
	 * 1. Log msg on z390 system log<br>
	 * 2. If QUAM GUI option on, display msg on gz390 mcs window view<br>
	 * @param wto_pfx
	 * @param msg_addr
	 * @param msg_len
	 */
	private void wto_msg(final String wto_pfx, final int msg_addr, final int msg_len) {
		String wto_msg = "";
		if (msg_len > 0) {
			wto_msg = get_ascii_string(msg_addr,msg_len,true);
		}
		put_log(wto_pfx + wto_msg);
		if (tz390.opt_guam) {
			gz390.guam_put_log(wto_msg);
			if (tz390.z390_abort) {
				abort_error(62, "GUAM GUI put_log abort.");
			}
		}
		_pz390.reg.putInt(pz390.r15,0);  //RPI31
	}

	/**
	 * Wait for ecb posting or stimer exit request.
	 * Retry the wait after stimer exit assuming r1 restored to wait ecb parm.
	 *
	 * Notes:
	 *   1.  WTOR ecb's are posted by gz390 wtor thread at which time reply is fetched and stored.
	 *   2.  Don't wait on a user defined ecb unless another process will post it or an stimer exit will post it.
	 */
	private void svc_wait() {
		if (!wait_retry) {
			wait_count = _pz390.reg.getInt(pz390.r0);
			wait_addr  = _pz390.reg.getInt(pz390.r1) & _pz390.psw_amode;
		}
		while (!check_wait_ecbs()  // RPI 280
			&& !stimer_exit_request) {
			tz390.sleep_now(tz390.monitor_wait);
		}
		if (stimer_exit_request) {
			wait_retry = true;
			// backup for stimer exit retry
			_pz390.psw_loc = _pz390.psw_loc - 2;
			tz390.systerm_ins--;
		} else {
			wait_retry = false;
			_pz390.reg.putInt(pz390.r15,0);
			if (wait_count > 0) {
				reset_wait_list();
			}
		}
	}

	/**
	 * Check wait ecbs and return true if required # of ecbs have been posted.
	 * @return
	 */
	private boolean check_wait_ecbs() {
		int ecb_code  = 0;
		if (wait_count == 0) {
			ecb_code = _pz390.mem.getInt(wait_addr);
			if ((ecb_code & ecb_posted) == 0) {
				// if not posted set waiting bit
				_pz390.mem.putInt(wait_addr,ecb_code | ecb_waiting);
				return false;
			} else {
				return true;
			}
		}

		int ecb_count     = wait_count;
		int ecb_list_addr = wait_addr;
		int ecb_addr = _pz390.mem.getInt(ecb_list_addr);
		int list_entry_count = 0;
		while (ecb_count > 0) {
			list_entry_count++;
			ecb_code = _pz390.mem.getInt(ecb_addr & 0x7fffffff);
			if ((ecb_code & ecb_posted) == 0) {
				// if not posted set waiting bit
				_pz390.mem.putInt(ecb_addr & 0x7fffffff,ecb_code | ecb_waiting);
			} else {
				ecb_count--;
				if (ecb_count == 0) {
					return true;
				}
			}
			if (ecb_addr < 0) {
				if (list_entry_count < wait_count) { // RPI 393
					_pz390.set_psw_check(Constants.psw_pic_waiterr);
				}
				return false;
			}
			ecb_list_addr = ecb_list_addr + 4;
			ecb_addr = _pz390.mem.getInt(ecb_list_addr);
		}
		return true;
	}

	/**
	 * Reset wait bit in ecblist.
	 */
	private void reset_wait_list() {
		int ecb_list_addr = wait_addr;
		int ecb_addr = _pz390.mem.getInt(ecb_list_addr);
		int ecb_list_count = max_ecb_count;
		while (ecb_addr != 0 && ecb_list_count > 0) {
			// turn off ecb waiting bit
			final int ecb_code = _pz390.mem.getInt( ecb_addr & 0x7fffffff);
			_pz390.mem.putInt(ecb_addr & 0x7fffffff,ecb_code & 0x7fffffff);
			if (ecb_addr < 0) {
				return;
			}
			ecb_list_addr = ecb_list_addr + 4;
			ecb_addr = _pz390.mem.getInt(ecb_list_addr);
			ecb_list_count--;
		}
		if (ecb_list_count == 0) {  // RPI 398
			_pz390.set_psw_check(Constants.psw_pic_waiterr);
		}
	}

	/**
	 * Post ecb complete.
	 */
	private void svc_post() {  // RPI 279
		final int ecb_addr = _pz390.reg.getInt(pz390.r1) & _pz390.psw_amode;
		final int ecb_code = _pz390.reg.getInt(pz390.r0) & pz390.max_pos_int;
		_pz390.mem.putInt(ecb_addr,(ecb_code | ecb_posted));
	}

	/**
	 * Request WTOR reply as follows:
	 * 1.  Save r0=reply, r14 length,r15=ecb
	 * 2.  Issue wtor message
	 * 2.  if QUAM GUI option, check for gz390 cmd reply else check for z390 cmd input reply
	 * 3.  if reply found, post ecb else repeat check at every monitor_update interval until reply found.
	 */
	private void svc_wtor() {
		wto_fld = _pz390.reg.getInt(pz390.r1) & _pz390.psw_amode;
		wto_len = _pz390.mem.getShort(wto_fld);
		wtor_reply_addr = _pz390.reg.getInt(pz390.r0) & _pz390.psw_amode;
		wtor_reply_len  = _pz390.reg.getInt(pz390.r14) & 0xff;
		wtor_ecb_addr = _pz390.reg.getInt(pz390.r15) & _pz390.psw_amode;
		wto_msg("",wto_fld+4,wto_len-4);  // RPI190 remove "WTOR MSG"
		_pz390.mem.putInt(wtor_ecb_addr,ecb_waiting); // ECB waiting for post by monitor wtorit
		if (tz390.opt_guam) {
			gz390.wtor_request_reply(wtor_ecb_addr);
		}
		if (tz390.z390_abort) {
			abort_error(63, "GUAM WTOR reply abort.");
		}
		if (wtor_reply_buff == null) {
			wtor_reply_buff = new BufferedReader(new InputStreamReader(System.in));
		}
		try {
			while (wtor_reply_buff.ready()) {
				wtor_reply_string = wtor_reply_buff.readLine();
			}
		} catch (final Exception e) {
			abort_error(115, "WTOR REPLY flush I/O error.");
		}
		wtor_reply_string  = null;
		wtor_reply_pending = true;
	}

	/**
	 * Set/reset program interruption exit
	 *  1.  if r0=0 cancel last espie added else add new espie exit  RPI 305
	 *  2.  if r0 negative replace exit else add RPI 305
	 *  3.  if r1 not zero, save parm address  RPI 305
	 */
	private void svc_espie() {
		final int espie_pie   = _pz390.reg.getInt(pz390.r0 ); // save pz390.psw_pic bit mask
		      int espie_addr  = _pz390.reg.getInt(pz390.r1 ) & _pz390.psw_amode; // save exit psw addr
		final int espie_param = _pz390.reg.getInt(pz390.r15) & _pz390.psw_amode; // save exit psw addr
		if (espie_addr == 0) {
			if (_pz390.tot_espie > 0) {
				_pz390.tot_espie--;
			}
			_pz390.reg.putInt(pz390.r15,0);
		} else if (_pz390.tot_espie < pz390.max_espie) {
			if (espie_addr < 0) {
				if (_pz390.tot_espie == 0) {
					_pz390.tot_espie++;
				}
				espie_addr = espie_addr & 0x7fffffff;
			} else {
				_pz390.tot_espie++;
			}
			_pz390.espie_pie[ _pz390.tot_espie-1] = espie_pie;
			_pz390.espie_exit[_pz390.tot_espie-1] = espie_addr;
			_pz390.espie_parm[_pz390.tot_espie-1] = espie_param;
			_pz390.reg.putInt(pz390.r15,0);
		} else {
			_pz390.set_psw_check(Constants.psw_pic_error);
		}
	}

	/**
	 * Set/reset task abend exit.
	 *  1.  if r0=0 cancel last estae added else add new estae exit  RPI 244
	 *  2.  if r0 negative replace exit else add RPI 244
	 *  3.  if r1 not zero, save parm address  RPI 244
	 */
	private void svc_estae() {
		      int estae_addr  = _pz390.reg.getInt(pz390.r0) & _pz390.psw_amode;
		final int estae_param = _pz390.reg.getInt(pz390.r1) & _pz390.psw_amode;
		if (estae_addr == 0) {
			if (_pz390.tot_estae > 0) {
				_pz390.tot_estae--;
			}
			_pz390.reg.putInt(pz390.r15,0);
		} else if (_pz390.tot_estae < pz390.max_estae) {
			if (estae_addr < 0) {
				if (_pz390.tot_estae == 0) {
					_pz390.tot_estae++;
				}
				estae_addr = estae_addr & 0x7fffffff;
			} else {
				_pz390.tot_estae++;
			}
			_pz390.estae_exit[_pz390.tot_estae-1] = estae_addr;
			_pz390.estae_parm[_pz390.tot_estae-1] = estae_param;
			_pz390.estae_link[_pz390.tot_estae-1] = tot_link_stk; // RPI 636
			_pz390.reg.putInt(pz390.r15,0);
		} else {
			_pz390.set_psw_check(Constants.psw_pic_error);
		}
	}

	/**
	 * Translate between ascii/ebcdic
	 *   r0 = area address
	 *        high bit on  for EBCDIC to ASCII
	 *        high bit off for ASCII to EBCDIC
	 *   r1 = length
	 */
	private void svc_xlate() {
		int index = _pz390.reg.getInt(pz390.r1);
		int addr  = _pz390.reg.getInt(pz390.r0);
		if (addr < 0) {
			addr = addr & 0x7fffffff;
			while (index > 0) {
				_pz390.mem_byte[addr] = tz390.ebcdic_to_ascii[_pz390.mem_byte[addr] & 0xff];
				addr++;
				index--;
			}
		} else {
			while (index > 0) {
				_pz390.mem_byte[addr] = tz390.ascii_to_ebcdic[_pz390.mem_byte[addr] & 0xff];
				addr++;
				index--;
			}
		}
	}

	/**
	 * convert to display - r1=a(type,in,out)
	 *   conversion type code:
	 *     1 128 bit integer to 45 byte decimal  display
     *     2 EH short    to 45 byte scientific notation
     *     3 EB short    to 45 byte scientific notation
     *     4 DH long     to 45 byte scientific notation
     *     5 DB long     to 45 byte scientific notation
     *     6 LH extended to 45 byte scientific notation
     *     7 LB extended to 45 byte scientific notation
	 *     8 DD long     to 45 byte scientific notation
	 *     9 ED short    to 45 byte scientific notation
	 *    10 LD extended to 45 byte scientific notation
	 */
	private void svc_ctd() {
		int addr = _pz390.reg.getInt(pz390.r1) & _pz390.psw_amode;
		byte type = _pz390.mem.get(addr+3);
		int addr_in  = _pz390.mem.getInt(addr+4) & _pz390.psw_amode; // RPI 526
		int addr_out = _pz390.mem.getInt(addr+8) & _pz390.psw_amode; // RPI 526

		switch (type) {
		case 1: // 128 bit int to display
			if (addr_in >= 16) { // RPI 507
				_pz390.mem.position(addr_in);
				_pz390.mem.get(ctd_byte,0,16);
			} else {
				if ((addr_in & 1) == 0) { // RPI 512, RPI 513
					_pz390.reg.position(addr_in * 8);
					_pz390.reg.get(ctd_byte,0,16);
				} else {
					_pz390.reg.putInt(pz390.r15,8);
					return;
				}
			}
			ctd_bi = new BigInteger(ctd_byte);
			ctd_text = ctd_bi.toString();
			break;
		case 2: // eh
			if (addr_in >= 16) { // RPI 507
				ctd_d = _pz390.fp_get_db_from_eh(_pz390.mem,addr_in);
			} else {
				if (_pz390.fp_reg_ctl[addr_in] != _pz390.fp_ctl_ld) {
					_pz390.fp_store_reg(_pz390.fp_reg,addr_in * 8);
				}
				ctd_d = _pz390.fp_get_db_from_eh(_pz390.fp_reg,addr_in * 8);
			}
			ctd_text = Double.toString(ctd_d);
			ctd_trunc(tz390.fp_eh_digits);
			break;
		case 3: // eb
			if (addr_in >= 16) { // RPI 507
				ctd_e = _pz390.fp_get_eb_from_eb(_pz390.mem,addr_in);
			} else {
				if (_pz390.fp_reg_ctl[addr_in] != _pz390.fp_ctl_ld) {
					_pz390.fp_store_reg(_pz390.fp_reg,addr_in * 8);
				}
				ctd_e = _pz390.fp_get_eb_from_eb(_pz390.fp_reg,addr_in * 8);
			}
			ctd_text = Float.toString(ctd_e);
			ctd_trunc(tz390.fp_eb_digits);
			break;
		case 4: // dh
			if (addr_in >= 16) { // RPI 507
				ctd_bd = _pz390.fp_get_bd_from_dh(_pz390.mem,addr_in);
			} else {
				if (_pz390.fp_reg_ctl[addr_in] != _pz390.fp_ctl_ld) {
					_pz390.fp_store_reg(_pz390.fp_reg,addr_in * 8);
				}
				ctd_bd = _pz390.fp_get_bd_from_dh(_pz390.fp_reg,addr_in * 8);  // RPI 821
			}
			ctd_text = ctd_bd.round(_pz390.fp_dh_context).toString(); // RPI 821
			ctd_trunc(tz390.fp_dh_digits);
			break;
		case 5: // db
			if (addr_in >= 16) { // RPI 507
				ctd_d = _pz390.fp_get_db_from_db(_pz390.mem,addr_in);
			} else {
				if (_pz390.fp_reg_ctl[addr_in] != _pz390.fp_ctl_ld) {
					_pz390.fp_store_reg(_pz390.fp_reg,addr_in * 8);
				}
				ctd_d = _pz390.fp_get_db_from_db(_pz390.fp_reg,addr_in * 8);
			}
			ctd_text = Double.toString(ctd_d);
			ctd_trunc(tz390.fp_db_digits);
			break;
		case 6: // lh
			if (addr_in >= 16) { // RPI 507
				ctd_bd = _pz390.fp_get_bd_from_lh(_pz390.mem,addr_in);
			} else {
				if (!pz390.fp_pair_valid[addr_in]) { // RPI 512
					_pz390.reg.putInt(pz390.r15,8);
					return;
				}
				if (_pz390.fp_reg_ctl[addr_in] != _pz390.fp_ctl_ld) {
					_pz390.fp_store_reg(_pz390.fp_reg,addr_in * 8);
				}
				ctd_bd = _pz390.fp_get_bd_from_lh(_pz390.fp_reg,addr_in * 8);
			}
			ctd_text = ctd_bd.round(_pz390.fp_lh_context).toString(); // RPI 821
			ctd_trunc(tz390.fp_lh_digits);
			break;
		case 7: // lb
			if (addr_in >= 16) { // RPI 507
				ctd_bd = _pz390.fp_get_bd_from_lb(_pz390.mem,addr_in);
			} else {
				if (!pz390.fp_pair_valid[addr_in]) { // RPI 512
					_pz390.reg.putInt(pz390.r15,8);
					return;
				}
				if (_pz390.fp_reg_ctl[addr_in] != _pz390.fp_ctl_ld) {
					_pz390.fp_store_reg(_pz390.fp_reg,addr_in * 8);
				}
				ctd_bd = _pz390.fp_get_bd_from_lb(_pz390.fp_reg,addr_in * 8);
			}
			ctd_text = ctd_bd.round(pz390.fp_lb_rnd_context[_pz390.fp_bfp_rnd]).toString(); // RPI 821
			ctd_trunc(tz390.fp_lb_digits);
			break;
		case 8: // dd
			if (addr_in >= 16) { // RPI 507
				if (!check_dfp_finite(_pz390.mem_byte,addr_in)) { // RPI 536
					_pz390.reg.putInt(pz390.r15,4);
					return;
				}
				ctd_bd = _pz390.fp_get_bd_from_dd(_pz390.mem,addr_in);
			} else {
				if (_pz390.fp_reg_ctl[addr_in] != _pz390.fp_ctl_ld) {
					_pz390.fp_store_reg(_pz390.fp_reg,addr_in * 8);
				}
				if (!check_dfp_finite(pz390.fp_reg_byte,addr_in * 8)) { // RPI 536
					_pz390.reg.putInt(pz390.r15,4);
					return;
				}
				ctd_bd = _pz390.fp_get_bd_from_dd(_pz390.fp_reg,addr_in * 8);
			}
			ctd_text = ctd_bd.toString();
			ctd_trunc(tz390.fp_dd_digits);
			break;
		case 9: // ed
			if (addr_in >= 16) { // RPI 507
				ctd_bd = _pz390.fp_get_bd_from_ed(_pz390.mem,addr_in);
			} else {
				if (_pz390.fp_reg_ctl[addr_in] != _pz390.fp_ctl_ld) {
					_pz390.fp_store_reg(_pz390.fp_reg,addr_in * 8);
				}
				ctd_bd = _pz390.fp_get_bd_from_ed(_pz390.fp_reg,addr_in * 8);
			}
			ctd_text = ctd_bd.toString();
			ctd_trunc(tz390.fp_ed_digits);
			break;
		case 10: // ld
			if (addr_in >= 16) { // RPI 507
				ctd_bd = _pz390.fp_get_bd_from_ld(_pz390.mem,addr_in);
			} else {
				if (!pz390.fp_pair_valid[addr_in]) { // RPI 512
					_pz390.reg.putInt(pz390.r15,8);
					return;
				}
				if (_pz390.fp_reg_ctl[addr_in] != _pz390.fp_ctl_ld) {
					_pz390.fp_store_reg(_pz390.fp_reg,addr_in * 8);
				}
				ctd_bd = _pz390.fp_get_bd_from_ld(_pz390.fp_reg,addr_in * 8);
			}
			ctd_text = ctd_bd.toString();
			ctd_trunc(tz390.fp_ld_digits);
			break;
		default:
			_pz390.reg.putInt(pz390.r15,8);
			return;
		}
		int index = 0;
		while (index < ctd_text.length()) {
			if (tz390.opt_ascii) {  // RPI 477
				_pz390.mem_byte[addr_out] = (byte)ctd_text.charAt(index);
			} else {
				_pz390.mem.put(addr_out,tz390.ascii_to_ebcdic[ctd_text.charAt(index)]);
			}
			index++;
			addr_out++;
		}
		while (index < ctd_display_len) {
			if (tz390.opt_ascii) { // RPI 477
				_pz390.mem_byte[addr_out] = Constants.ascii_space;
			} else {
				_pz390.mem.put( addr_out,   Constants.ebcdic_space);
			}
			index++;
			addr_out++;
		}
		_pz390.reg.putInt(pz390.r15,0);
	}

	/**
	 * Truncate to max digits plus exponent and strip trailing zeros on fraction.
	 * @param max_digits
	 */
	private void ctd_trunc(final byte max_digits) {
		int d_index = ctd_text.indexOf(".");
		final int e_index = ctd_text.indexOf("E");
		String e_text = "";
		if (d_index >= 0) {
			if (e_index > d_index) {
				if (ctd_text.charAt(e_index+1) == '+') {
					e_text = "E" + ctd_text.substring(e_index+2);
				} else {
					e_text = ctd_text.substring(e_index);
				}
				d_index = e_index;
				if (d_index > max_digits+1) {
					d_index = max_digits;  // last sig. digit offset
				} else {
					d_index = e_index-1;
				}
			} else {
				if (d_index > 0 && ctd_text.length() > max_digits+2) {
					ctd_text = ctd_text.substring(0,max_digits+2); // RPI 821
				}
				d_index = ctd_text.length()-1;
			}
			while (ctd_text.charAt(d_index) == '0') {
				d_index--;
			}
			if (ctd_text.charAt(d_index) == '.') {
				d_index--;
			}
			ctd_text = ctd_text.substring(0,d_index+1) + e_text;
		}
	}

	/**
	 * convert from display - r1=a(type,out,in)
	 *   conversion type code:
	 *     1 128 bit integer from 45 byte decimal  display
     *     2 EH short    from 45 byte scientific notation
     *     3 EB short    from 45 byte scientific notation
     *     4 DH long     from 45 byte scientific notation
     *     5 DB long     from 45 byte scientific notation
     *     6 LH extended from 45 byte scientific notation
     *     7 LB extended from 45 byte scientific notation
	 *     8 DD long     from 45 byte scientific notation
	 *     9 ED short    from 45 byte scientific notation
	 *    10 LD extended from 45 byte scientific notation
	 */
	private void svc_cfd() {
		final int  addr     = _pz390.reg.getInt(pz390.r1) & _pz390.psw_amode;
		final byte type     = _pz390.mem.get(   addr+3);
		final int  addr_out = _pz390.mem.getInt(addr+4) & _pz390.psw_amode; // RPI 526
		final int  addr_in  = _pz390.mem.getInt(addr+8) & _pz390.psw_amode;   // RPI 526
		final String cfd_text = tz390.get_ascii_var_string(_pz390.mem_byte,addr_in,ctd_display_len).trim();

		switch (type) {
		case 21: // 128 bit int from display
			try {
				cfd_bi = new BigDecimal(cfd_text).toBigInteger(); // RPI 512
			} catch (final Exception e) {
				_pz390.reg.putInt(pz390.r15,12);
				return;
			}
			if (addr_out >= 16) { // RPI 507
				_pz390.mem.position(addr_out);
			} else {
				if ((addr_out & 1) == 0) { // RPI 512
					_pz390.reg.position(addr_out * 8);
				} else {
					_pz390.reg.putInt(pz390.r15,8);
					return;
				}
			}
			cfd_byte = cfd_bi.toByteArray();
			int index = 16-cfd_byte.length;
			byte fill_byte = 0;
			if (cfd_byte[0] < 0) {
				fill_byte = -1;
			}
			while (index > 0) {
				if (addr_out >= 16) {  // RPI 507
					_pz390.mem.put(fill_byte);
				} else {
					_pz390.reg.put(fill_byte);
				}
				index--;
			}
			if (addr_out >= 16) {
				_pz390.mem.put(cfd_byte);
			} else {
				_pz390.reg.put(cfd_byte);
			}
			break;
		case 22: // eh
			try {
				cfd_d = Double.valueOf(cfd_text); // RPI 526
			} catch (final Exception e) {
				_pz390.reg.putInt(pz390.r15,12);
				return;
			}
			if (addr_out >= 16) {  // RPI 507
				_pz390.mem.putInt(addr_out,_pz390.fp_db_to_eh(cfd_d));
			} else {
				_pz390.fp_reg.putInt(addr_out * 8,_pz390.fp_db_to_eh(cfd_d));
				_pz390.fp_reg_ctl[addr_out] = _pz390.fp_ctl_ld;
			}
			break;
		case 23: // eb
			try {
				cfd_e = Float.valueOf(cfd_text);  // RPI 526
			} catch (final Exception e) {
				_pz390.reg.putInt(pz390.r15,12);
				return;
			}
			if (addr_out >= 16) {  // RPI 507
				_pz390.mem.putFloat(addr_out,cfd_e);
			} else {
				_pz390.fp_reg.putFloat(addr_out *8,cfd_e);
				_pz390.fp_reg_ctl[addr_out] = _pz390.fp_ctl_ld;
			}
			break;
		case 24: // dh
			try {
				cfd_bd = new BigDecimal(cfd_text,_pz390.fp_dh_context); // RPI-526 RPI-821  was dhg
			} catch (final Exception e) {
				_pz390.reg.putInt(pz390.r15,12);
				return;
			}
			_pz390.fp_bd_to_wreg(tz390.fp_dh_type, cfd_bd); // RPI 821
			if (addr_out >= 16) {  // RPI 507
				_pz390.mem.putLong(addr_out, tz390.fp_work_reg.getLong(0)); // RPI 821
			} else {
				_pz390.fp_reg.putLong(addr_out * 8,tz390.fp_work_reg.getLong(0)); // RPI 821
				_pz390.fp_reg_ctl[addr_out] = _pz390.fp_ctl_ld;
			}
			break;
		case 25: // db
			try {
				cfd_d = Double.valueOf(cfd_text);  // RPI 526
			} catch (final Exception e) {
				_pz390.reg.putInt(pz390.r15,12);
				return;
			}
			if (addr_out >= 16) {  // RPI 507
				_pz390.mem.putDouble(addr_out,cfd_d);
			} else {
				_pz390.fp_reg.putDouble(addr_out * 8,cfd_d);
				_pz390.fp_reg_ctl[addr_out] = _pz390.fp_ctl_ld;
			}
			break;
		case 26: // lh
			try {
				cfd_bd = new BigDecimal(cfd_text,_pz390.fp_lxg_context); // RPI-526 RPI-821
			} catch (final Exception e) {
				_pz390.reg.putInt(pz390.r15,12);
				return;
			}
			_pz390.fp_bd_to_wreg(tz390.fp_lh_type,cfd_bd);
			if (addr_out >= 16) {  // RPI 507
				_pz390.mem.position(addr_out);
				_pz390.mem.put(tz390.fp_work_reg_byte,0,16);
			} else {
				if (pz390.fp_pair_valid[addr_out]) { // RPI 512
					_pz390.fp_reg.position(addr_out * 8);
					_pz390.fp_reg.put(tz390.fp_work_reg_byte,0,8);
					_pz390.fp_reg_ctl[addr_out] = _pz390.fp_ctl_ld;
					_pz390.fp_reg.position(addr_out * 8 + 16);
					_pz390.fp_reg.put(tz390.fp_work_reg_byte,8,8);
					_pz390.fp_reg_ctl[addr_out + 2] = _pz390.fp_ctl_ld;
				} else {
					_pz390.reg.putInt(pz390.r15,8);
					return;
				}
			}
			break;
		case 27: // lb
			try {
				cfd_bd = new BigDecimal(cfd_text,_pz390.fp_lxg_context);   // RPI 526 RPI 821
			} catch (final Exception e) {
				_pz390.reg.putInt(pz390.r15,12);
				return;
			}
			_pz390.fp_bd_to_wreg(tz390.fp_lb_type,cfd_bd);
			if (addr_out >= 16) {  // RPI 507
				_pz390.mem.position(addr_out);
				_pz390.mem.put(tz390.fp_work_reg_byte,0,16);
			} else {
				if (pz390.fp_pair_valid[addr_out]) { // RPI 512
					_pz390.fp_reg.position(addr_out * 8);
					_pz390.fp_reg.put(tz390.fp_work_reg_byte,0,8);
					_pz390.fp_reg_ctl[addr_out] = _pz390.fp_ctl_ld;
					_pz390.fp_reg.position(addr_out * 8 + 16);
					_pz390.fp_reg.put(tz390.fp_work_reg_byte,8,8);
					_pz390.fp_reg_ctl[addr_out + 2] = _pz390.fp_ctl_ld;
				} else {
					_pz390.reg.putInt(pz390.r15,8);
					return;
				}
			}
			break;
		case 28: // dd   RPI 514
			try {
				cfd_bd = new BigDecimal(cfd_text,pz390.fp_dd_rnd_context[_pz390.fp_dfp_rnd]);   // RPI 526
			} catch (final Exception e) {
				_pz390.reg.putInt(pz390.r15,12);
				return;
			}
			_pz390.fp_bd_to_wreg(tz390.fp_dd_type,cfd_bd);
			if (addr_out >= 16) {  // RPI 507
				_pz390.mem.position(addr_out);
				_pz390.mem.put(tz390.fp_work_reg_byte,0,8);
			} else {
				_pz390.fp_reg.position(addr_out*8);
				_pz390.fp_reg.put(tz390.fp_work_reg_byte,0,8);
				_pz390.fp_reg_ctl[addr_out] = _pz390.fp_ctl_ld;
			}
			break;
		case 29: // ed  RPI 514
			try {
				cfd_bd = new BigDecimal(cfd_text,pz390.fp_ed_rnd_context[_pz390.fp_dfp_rnd]);   // RPI 526
			} catch (final Exception e) {
				_pz390.reg.putInt(pz390.r15,12);
				return;
			}
			_pz390.fp_bd_to_wreg(tz390.fp_ed_type,cfd_bd);
			if (addr_out >= 16) {  // RPI 507
				_pz390.mem.position(addr_out);
				_pz390.mem.put(tz390.fp_work_reg_byte,0,4);
			} else {
				_pz390.fp_reg.position(addr_out*8);
				_pz390.fp_reg.put(tz390.fp_work_reg_byte,0,4);
				_pz390.fp_reg_ctl[addr_out] = _pz390.fp_ctl_ld;
			}
			break;
		case 30: // ld   RPI 514
			try {
				cfd_bd = new BigDecimal(cfd_text, pz390.fp_ld_rnd_context[_pz390.fp_dfp_rnd]);   // RPI 526
			} catch (final Exception e) {
				_pz390.reg.putInt(pz390.r15,12);
				return;
			}
			_pz390.fp_bd_to_wreg(tz390.fp_ld_type,cfd_bd);
			if (addr_out >= 16) {  // RPI 507
				_pz390.mem.position(addr_out);
				_pz390.mem.put(tz390.fp_work_reg_byte,0,16);
			} else {
				if (pz390.fp_pair_valid[addr_out]) { // RPI 512
					_pz390.fp_reg.position(addr_out * 8);
					_pz390.fp_reg.put(tz390.fp_work_reg_byte,0,8);
					_pz390.fp_reg_ctl[addr_out] = _pz390.fp_ctl_ld;
					_pz390.fp_reg.position(addr_out * 8 + 16);
					_pz390.fp_reg.put(tz390.fp_work_reg_byte,8,8);
					_pz390.fp_reg_ctl[addr_out + 2] = _pz390.fp_ctl_ld;
				} else {
					_pz390.reg.putInt(pz390.r15,8);
					return;
				}
			}
			break;
		default:
			_pz390.reg.putInt(pz390.r15,8);
			return;
		}
		_pz390.reg.putInt(pz390.r15,0);
	}

	/**
	 * Process test option interactive debug commands.
	 */
	public void process_test_cmd() {
		/*
		 * 1.  Check for reg, memory, or opcode break and set count = 0 if hit.
		 * 2.  Decrement go count if positive.
		 * 3.  if go count = 0
		 *        read, parse, and execute test commands
		 *        until go or quit command executed.
		 *  Notes:
		 *   1.  Get next command from z390 GUI command line, system command_line, or
		 *       from ddname file specified in test option test(ddname)..
		 */
		if (test_break_addr_mode) {
			check_test_break_addr();
		}
		if (test_break_reg_mode) {
			check_test_break_reg();
		}
		if (test_break_mem_mode) {
			check_test_break_mem();
		}
		if (test_break_op_mode && test_break_op_ins < tz390.systerm_ins) {
			check_test_break_op();
		}
		if (_pz390.test_trace_count > 0) {
			_pz390.test_trace_count--;
			if (_pz390.test_trace_count == 0) {
				_pz390.trace_psw();
			}
		}
		while (!tz390.z390_abort && _pz390.test_trace_count == 0) {
			test_cmd_abort = false;
			get_test_cmd();
			if (!tz390.z390_abort
			 && test_cmd != null
			 && test_cmd.length() > 0) {  // RPI 98
				test_loop_count = 0;
				exec_test_cmd();
			} else {
				test_loop_count++;
				if (test_loop_count > 3) {
					abort_error(65, "Test loop detected - aborting.");
				}
			}
		}
	}

	/**
	 * Get next test command from Z390 GUI command line or system command line
	 * or file specified with the test(ddname) option.
	 */
	private void get_test_cmd() {
		if (!tz390.z390_abort && z390_command_text != null) {
			// z390 GUI test interface active
			try {
				z390_command_text.wait();
				test_cmd = z390_command_text.getText();
				z390_command_text.setText("");
			} catch (final Exception e) {
				test_error("i/o on z390 command line");
				test_cmd = "Q";  // quit now
			}
		} else {
			try {
				if (test_first_cmd  // RPI 854
				|| (tz390.test_ddname == null
					&& test_loop_count == 0) // RPI 89
				) {
					test_first_cmd = false;
					tz390.put_trace("test enter command or h for help");
				}
				tz390.systerm_io++;
				test_cmd = test_cmd_file.readLine();
				if (tz390.test_ddname != null && test_cmd == null) {
					test_cmd = "Q";
				}
			} catch (final Exception e) {
				test_error("i/o error on command line");
				test_cmd = "Q";  // quit now
			}
		}
	}

	/**
	 * Check for psw = break addr.
	 */
	private void check_test_break_addr() {
		int index = 0;
		while (index < tot_test_break_addr) {
			if (_pz390.psw_loc == test_break_addr[index]) {
				_pz390.test_trace_count = 0;
				tz390.put_trace("test break on " + test_break_addr_cmd);
				_pz390.trace_psw();
				return;
			}
			index++;
		}
	}

	/**
	 * Check for test mode break on register value.
	 */
	private void check_test_break_reg() {
		test_break_reg_val = _pz390.reg.getLong(test_break_reg_loc);
		test_break_reg = false;
		switch (test_break_reg_compare) {
		case 0: // =
			if (test_break_reg_val == test_break_reg_sdt) {
				test_break_reg = true;
			}
			break;
		case 1: // !=
			if (test_break_reg_val != test_break_reg_sdt) {
				test_break_reg = true;
			}
			break;
		case 2: // >
			if (test_break_reg_val > test_break_reg_sdt) {
				test_break_reg = true;
			}
			break;
		case 3: // >=
			if (test_break_reg_val >= test_break_reg_sdt) {
				test_break_reg = true;
			}
			break;
		case 4: // <
			if (test_break_reg_val < test_break_reg_sdt) {
				test_break_reg = true;
			}
			break;
		case 5: // <=
			if (test_break_reg_val <= test_break_reg_sdt) {
				test_break_reg = true;
			}
			break;
		default:
			test_error("invalid reg break compare - ignored");
		}
		if (test_break_reg) {
			_pz390.test_trace_count = 0;
			tz390.put_trace("test break on " + test_break_reg_cmd);
			dump_gpr(test_break_reg_loc);
			_pz390.trace_psw();
		}
	}

	/**
	 * Check for test break on memory value change.
	 */
	private void check_test_break_mem() {
		test_break_mem = false;
		int index = 0;
		test_break_mem_equal = 0; // count equal bytes
		while (test_break_mem_sdt != null && index < test_break_mem_sdt.length) {
			test_break_mem_byte = _pz390.mem_byte[test_break_mem_loc + index];
			switch (test_break_mem_compare) {
			case 0: // =
				if (test_break_mem_byte == test_break_mem_sdt[index]) {
					test_break_mem_equal++;
				}
				break;
			case 1: // !=
				if (test_break_mem_byte != test_break_mem_sdt[index]) {
					test_break_mem = true;
					index = test_break_mem_sdt.length;
				}
				break;
			case 2: // >
				if (test_break_mem_byte > test_break_mem_sdt[index]) {
					test_break_mem = true;
					index = test_break_mem_sdt.length;
				}
				break;
			case 3: // >=
				if (test_break_mem_byte >= test_break_mem_sdt[index]) {
					test_break_mem = true;
					index = test_break_mem_sdt.length;
				}
				break;
			case 4: // <
				if (test_break_mem_byte < test_break_mem_sdt[index]) {
					test_break_mem = true;
					index = test_break_mem_sdt.length;
				}
				break;
			case 5: // <=
				if (test_break_mem_byte <= test_break_mem_sdt[index]) {
					test_break_mem = true;
					index = test_break_mem_sdt.length;
				}
				break;
			default:
				test_error("invalid memory break compare - ignored");
			}
			index++;
		}
		if (test_break_mem_compare == 0  // =
		 && test_break_mem_equal   == test_break_mem_sdt.length) {
			test_break_mem = true;
		}
		if (test_break_mem) {
			_pz390.test_trace_count = 0;
			tz390.put_trace("test break on " + test_break_mem_cmd);
			dump_mem(_pz390.mem,test_break_mem_loc,test_break_mem_sdt.length);
			_pz390.trace_psw();
		}
	}

	/**
	 * Check for test mode break on opcode at current psw address.
	 */
	private void check_test_break_op() {
		if ((_pz390.mem_byte[_pz390.psw_loc] & 0xff) == test_break_op1) {
			if (test_break_op2_index == 0
			|| ((_pz390.mem_byte[_pz390.psw_loc+test_break_op2_index] & test_break_op2_mask)
				== test_break_op2)) {
				_pz390.test_trace_count = 0;
				test_break_op_mode = false;
				tz390.put_trace("test break on " + test_break_op_cmd);
				_pz390.trace_psw();
			}
		}
	}

	/**
	 * Parse and execute current test command.
	 */
	private void exec_test_cmd() {
		try { // RPI 1137
			if (test_cmd != null && test_cmd.length() > 0) {
				tz390.put_trace("test cmd: " + test_cmd);
				test_match = test_pattern.matcher(test_cmd);
			}
			test_token = get_next_test_token();
			if (test_token == null) {
				test_error("invalid command");
				return;
			}
			test_opcode = test_token.toUpperCase().charAt(0);
			switch (test_opcode) {
			case '+': // relative base replacement +nn=
				test_token = get_next_test_token();
				test_addr = test_base_addr + get_next_test_addr();
				test_opcode = '=';
				break;
			case '-': // relative base replacement -nn=
				test_token = get_next_test_token();
				test_addr = test_base_addr - get_next_test_addr();
				test_opcode = '=';
				break;
			case 'E': // no pre-processing for exit request
				break;
			default:
				test_addr = 0;
				if (test_token.length() > 1
				|| (test_token.charAt(0) >= '0' && test_token.charAt(0) <= '9')
				|| (test_token.charAt(0) == '*' && (test_cmd.length() > 1 && test_cmd.indexOf("=") > 0))) {
					test_addr = get_next_test_addr();
					if (test_token.equals("=")) {
						test_opcode = '=';
					} else {
						test_error("invalid command");
						return;
					}
				}
			}
			switch (test_opcode) {
			case '*': // * with no = following is comment
				break;
			case '=': // addr=sdt or nr=sdt change
				if (!test_cmd_abort) {
					test_sdt = get_next_test_token();
					if (test_addr_type == test_addr_mem) { // mem=sdt memory change
						test_mem_loc = test_addr;
						test_mem_sdt = get_test_mem_sdt(test_sdt);
						int index = 0;
						while (index < test_mem_sdt.length) {
							_pz390.mem_byte[test_mem_loc+index] = test_mem_sdt[index];
							index++;
						}
						dump_mem(_pz390.mem,test_mem_loc,test_mem_sdt.length);
					} else {  // nR=sdt gpr register change
						test_reg_loc = test_addr * 8;
						test_reg_sdt = get_test_reg_sdt(test_sdt);
						_pz390.reg.putLong(test_reg_loc,test_reg_sdt);
						dump_gpr(test_reg_loc);
					}
				}
				break;
			case 'A':  // set address stop
				test_token = get_next_test_token();
				set_test_break_addr(get_next_test_addr());
				break;
			case 'B':  // set base for rel addr of memory
				test_token = get_next_test_token();
				if (test_token != null && test_token.charAt(0) == '=') {
					test_token = get_next_test_token();
					if (test_token != null) {
						test_base_addr = get_next_test_addr();
						dump_mem(_pz390.mem,test_base_addr,16);
						break;
					}
				}
				test_error("invalide B=addr");
				break;
			case 'D': // dump tiot
				dump_tiot();
				break;
			case 'E':  // capture exit request from batch and exit when done
				if (test_token.length() > 1) { // RPI 586
					tz390.put_trace("test batch exit request");
					exit_request = true;
				} else {  // RPI 586
					if (tz390.opt_ascii) {
						tz390.opt_ascii = false;
						tz390.put_trace("test setting EBCDIC text mode");
					} else {
						tz390.opt_ascii = true;
						tz390.put_trace("test setting ASCII text mode");
					}
				}
				break;
			case 'F': // dump fp regs
				test_token = get_next_test_token();
				if (test_token == null) {
					dump_fpr(-1);
				} else {
					dump_fpr(get_test_int(test_token) * 8); // RPI 490
				}
				break;
			case 'G':  // go nn instrs, to hex addr, or until reg/mem/op/addr break
				tz390.opt_trace = false;
				go_test();
				break;
			case 'H':  // help
				tz390.put_trace("z390 test command help summary (Visit www.z390.org for more information)");
				tz390.put_trace("  addr=sdt    set memory value  (ie 1r?=x'80' changes mem at (r1) 31 bit");
				tz390.put_trace("  reg=sdt     set register value (ie 15r=8 changes reg 15 to 8)");
				tz390.put_trace("  A addr      add/remove address stop (ie A FF348. or A *+4 etc.)");  // RPI 395
				tz390.put_trace("  B=addr      set base for rel addr (ie B=15r% sets base to (r15) 24 bit");
				tz390.put_trace("  D           display DCB file status, DDNAME, and DSNAME information");
				tz390.put_trace("  E           toggle EBCDIC/ASCII mode for dumping storage etc.");
				tz390.put_trace("  F nn        display specified floating point registers else all F0-FF");
				tz390.put_trace("  G nn/adr/op exec n instr. or to hex addr or until next break without trace");
				tz390.put_trace("  J addr      jump to new addr and trace instruction");
				tz390.put_trace("  L reg       list contents of register (ie l 1r dumps register 1");
				tz390.put_trace("  L addr len  list contents of memory area (ie l 10. 4 dumps cvt addr");
				tz390.put_trace("  M           display memory total allocated and free");
				tz390.put_trace("  P           display program information from CDE");
				tz390.put_trace("  R nn        display specified general purpose register else all R0-RF");
				tz390.put_trace("  S           clear all breaks");
				tz390.put_trace("  S reg??sdt  set break on register change");
				tz390.put_trace("  S addr??sdt set break on memory change");
				tz390.put_trace("  T nn/adr/op exec n instr. or to hex addr or until next break with trace");
				tz390.put_trace("  Z or Q      Z to zoom to normal end or Q to quit now");
				tz390.put_trace("* addr = [hex.|*|dec|nnr%(24)|nnr?(31)][+-addr]");
				tz390.put_trace("* reg  = nnr where nn = 0-15");
				tz390.put_trace("* sdt  = self defining term (b'01',c'ab',f'1',h'2',x'ff')");
				tz390.put_trace("* ??   = break compare operator (=,!=,<,<=,>,>=)");
				break;
			case 'J': // jump to address
				test_token = get_next_test_token();
				if (test_token != null) {
					test_addr = get_next_test_addr();
					if (test_addr != -1) {
						_pz390.set_psw_loc(test_addr);
					} else {
						test_error("invalid jump address");
						return;
					}
					if (!test_cmd_abort) {
						_pz390.trace_psw();
					}
				} else {
					test_error("missing jump address");
				}
				break;
			case 'L':  // list reg or memory
				test_mem_len = 32;
				test_token = get_next_test_token();
				if (test_token == null) {
					dump_gpr(-1);
					_pz390.trace_psw();
				} else {
					test_bias = test_token.charAt(0);
					if (test_bias == '+' || test_bias == '-') {
						test_token = get_next_test_token();
						test_addr = get_next_test_addr();
						if (test_addr == -1 || test_base_addr == -1) {
							test_error("invalid base or offset");
							return;
						}
						if (test_bias == '+') {
							test_addr = test_base_addr + test_addr;
						} else {
							test_addr = test_base_addr - test_addr;
						}
						if (test_token != null) {
							test_mem_len = get_test_addr(test_token);
						}
					} else {
						test_addr = get_next_test_addr();
						if (test_token != null) {
							test_mem_len = get_test_addr(test_token);
						}
					}
					if (test_addr == -1) {
						test_error("invalid address");
						return;
					}
					if (test_addr_type == test_addr_reg) {
						test_reg_loc = test_addr * 8;
						dump_gpr(test_reg_loc);
					} else if (test_addr_type == test_addr_mem) {
						test_mem_loc = test_addr;
						if (!test_cmd_abort) {
							if (test_mem_len > 0
							 && test_mem_loc + test_mem_len <= _pz390.tot_mem) {
								dump_mem(_pz390.mem,test_mem_loc,test_mem_len);
							} else {
								test_error("invalid address or length");
								return;
							}
						}
					}
				}
				break;
			case 'M': // show getmain/freemain memory stats
				dump_mem_stat();
				break;
			case 'P': // show CDE program info.
				dump_cde();
				break;
			case 'Q': // quit test mode
				abort_error(109, "Quitting test mode"); //RPI121
				break;
			case 'R':  // dump gpr regs
				test_token = get_next_test_token();
				if (test_token == null) {
					dump_gpr(-1);
				} else {
					dump_gpr(get_test_int(test_token) * 8); // RPI 490
				}
				break;
			case 'S':  // set break on reg or memory change
				test_token = get_next_test_token();
				if (test_token == null) {
					tz390.put_trace("test breaks off");
					test_break_reg_mode = false;
					test_break_mem_mode = false;
					test_break_op_mode = false;
					test_break_addr_mode = false;
				} else {
					test_addr    = get_next_test_addr();
					test_compare = get_test_compare(test_token);
					if (!test_cmd_abort) {
						if (test_addr_type == test_addr_reg) {
							set_test_break_reg();
							check_test_break_reg();
						} else {
							set_test_break_mem();
							check_test_break_mem();
						}
					}
				}
				break;
			case 'T':  // trace nn ins or until reg/mem/op break
				tz390.opt_trace = true;
				go_test();
				break;
			case 'Z':  // zoom to normal end by turning off trace and test
				tz390.opt_trace = false;
				tz390.opt_test  = false;      // RPI-0186
				_pz390.test_trace_count = -1; // RPI-0186
				ez390_errors = 0;  // RPI 243
				ez390_rc = 0;
				break;
			default:
				test_error("undefined test command - " + test_opcode);
			}
		} catch(final Exception e) {
			test_error("invalid test command - " + test_opcode);
		}
	}

	/**
	 * Return integer value of token.
	 * Just issue ivalid int error if error and return -1.
	 * @param token
	 * @return
	 */
	private int get_test_int(final String token) { // RPI-0490
		try {
			return Integer.valueOf(token).intValue();
		} catch (final Exception e) {
			test_error("invalid integer - " + token);
			return -1;
		}
	}

	/**
	 * return next test command token or null
	 * @return
	 */
	private String get_next_test_token() {
		if (test_match.find()) {
			return test_match.group();
		} else {
			return null;
		}
	}

	/**
	 * Return memory address of [addr][+-addr]
	 * start with current test_token and continue
	 * until next test_token not +,-, ?, % or valid address RPI 650
	 * If invalid return -1
	 * Notes:
	 *   1.  EPA returns last program load address
	 * @return
	 */
	private int get_next_test_addr() {
		if (test_token == null) {
			return -1;
		}
		int total = 0;
		char test_sign = '+';
		while (test_sign == '+' || test_sign == '-') {
			test_next_addr = get_test_addr(test_token);
			if (test_next_addr == -1) {
				return -1;
			}
			if (test_sign == '+') {
				total = total + test_next_addr;
			} else {
				total = total - test_next_addr;
			}
			test_token = get_next_test_token();
			while (test_token != null
				&& test_token.length() == 1
				&& (test_token.charAt(0) == '?' // RPI 650
				 || test_token.charAt(0) == '%')) {
				if (test_token.charAt(0) == '?') {
					total = _pz390.mem.getInt(total & pz390.psw_amode31);
				} else {
					total = _pz390.mem.getInt(total & pz390.psw_amode24);
				}
				test_token = get_next_test_token();
			}
			if (test_token == null) {
				return total;
			}
			test_sign = test_token.charAt(0);
			if (test_sign == '+' || test_sign == '-') {
				test_token = get_next_test_token();
				if (test_token == null) {
					return -1;
				}
			}
		}
		return total;
	}

	/**
	 * Issue test error message and return to prompt.
	 * @param text
	 */
	private void test_error(final String text) {
		tz390.put_trace("test error " + text);
	}

	/**
	 * Set count and go execute instructions until count 0 or break found or exit.
	 */
	private void go_test() {
		test_token = get_next_test_token();
		if (test_token != null) {
			if (test_cmd.indexOf('*') >= 0
			 || test_cmd.indexOf('+') >= 0
			 || test_cmd.indexOf('-') >= 0
			 || (test_token.length() > 1
			  && test_token.charAt(test_token.length()-1) == '.')) {
				set_test_break_addr(get_next_test_addr());
				_pz390.test_trace_count = -1; // go until break
			} else {
				try {
					_pz390.test_trace_count = Integer.valueOf(test_token);
				} catch (final Exception e) {
					set_test_break_op();
					_pz390.test_trace_count = -1; // go until break
				}
			}
		} else {
			_pz390.test_trace_count = -1; // go until break or exit
		}
	}

	/**
	 * set break on specified instruction address
	 * @param addr
	 */
	private void set_test_break_addr(final int addr) {
		test_break_addr_mode = true;
		int index = 0;
		while (index < tot_test_break_addr) {
			if (test_break_addr[index] == addr) {
				tz390.put_trace("test break addr removed - " + tz390.get_hex(addr,8));
				tot_test_break_addr--;
				if (index < tot_test_break_addr) {
					test_break_addr[index] = test_break_addr[tot_test_break_addr];
				}
				return;
			}
			index++;
		}
		if (tot_test_break_addr == test_break_addr.length) {
			test_error("max addr breaks exceeded - remove one or clear");
		}
		test_break_addr_cmd  = test_cmd;
		test_break_addr[tot_test_break_addr] = addr & 0x7fffffff; // RPI 428
		tot_test_break_addr++;
		dump_mem(_pz390.mem,test_break_addr[tot_test_break_addr-1],16);
	}

	/**
	 * Set test break on register change.
	 */
	private void set_test_break_reg() {
		test_break_reg_mode = true;
		test_break_reg_cmd = test_cmd;
		test_break_reg_loc = test_addr * 8;
		test_break_reg_compare = test_compare;
		test_sdt = get_next_test_token();
		test_break_reg_sdt = get_test_reg_sdt(test_sdt);
		dump_gpr(test_break_reg_loc);
	}

	/**
	 * Set test break on memory change.
	 */
	private void set_test_break_mem() {
		test_break_mem_mode = true;
		test_break_mem_cmd = test_cmd;
		test_break_mem_loc = test_addr;
		test_break_mem_compare = test_compare;
		test_sdt = get_next_test_token();
		if (test_sdt != null) {
			test_break_mem_sdt = get_test_mem_sdt(test_sdt);
			if (test_break_mem_sdt != null) {
				dump_mem(_pz390.mem,test_break_mem_loc,test_break_mem_sdt.length);
			} else {
				test_error("missing sdt for break");
				test_cmd_abort = true;
			}
		} else {
			test_error("missing sdt for break");
			test_cmd_abort = true;
		}
	}

	/**
	 * Set break on opcode at current psw.
	 */
	private void set_test_break_op() {
		final int index = tz390.find_key_index('O',test_token.toUpperCase());
		if (index != -1) {
			test_break_op_mode = true;
			test_break_op_ins  = tz390.systerm_ins;
			test_break_op_cmd  = test_cmd;
			try { // RPI 490
				test_break_op1 = Integer.valueOf(OpCodes.op_code[index].substring(0,2),16).byteValue() & 0xff;
			} catch (final Exception e) {
				test_error("invalid hex opcode for " + test_token);
				test_break_op1 = 0;
			}
			test_break_op2_index = pz390.opcode2_offset[test_break_op1];
			if (OpCodes.op_code[index].length() == 4) {
				try {
					test_break_op2 = Integer.valueOf(OpCodes.op_code[index].substring(2,4),16).byteValue() & 0xff;
				} catch (final Exception e) {
					test_error("invalid hex opcode 2 for " + test_token);
					test_break_op2 = 0;
				}
				test_break_op2_mask = 0xff;
			} else if (OpCodes.op_code[index].length() == 3) {
				if (pz390.opcode2_mask[test_break_op1] == 0xf0) {
					try {
						test_break_op2 = (Integer.valueOf(OpCodes.op_code[index].substring(2,3),16).intValue() << 4) & 0xff;
					} catch (final Exception e) {
						test_error("invalid hex opcode2 for " + test_token);
						test_break_op2 = 0;
					}
					test_break_op2_mask = 0xf0;
				} else {
					try {
						test_break_op2 = Integer.valueOf(OpCodes.op_code[index].substring(2,3),16).intValue() & 0xff;
					} catch (final Exception e) {
						test_error("invald hex opcode2 for " + test_token);
						test_break_op2 = 0;
					}
					test_break_op2_mask = 0x0f;
				}
			} else {
				test_break_op2_index = 0; // no op2
			}
		} else {
			test_error("invalid opcode - " + test_token);
		}
	}

	/**
	 * get test address and set type
	 *
	 * memory type address forms
	 *   dec  = absolute decimal address
	 *   hex. = absolute hex address
	 *   +hex = base + hex offset
	 *   -hex = base - hex offset
	 *   *    = pz390.psw_loc
	 *   nr% indirect 24 bit
	 *   nr? indirect 31 bit
     *   ?   indirect address
	 *   EPA last load address  // RPI 395
	 * register type address forms
	 *    nnr or rnn
	 * @param text
	 * @return
	 */
	private int get_test_addr(final String text) {
		int addr = 0;
		test_addr_type = test_addr_mem;
		try {
			if (text.length() > 1) {
				if (text.toUpperCase().charAt(text.length()-1) == 'R') {
					test_addr_type = test_addr_reg;
					addr = Integer.valueOf(text.substring(0,text.length()-1)).intValue();
				} else if (text.charAt(text.length()-1) == '.') {
					addr = Long.valueOf(text.substring(0,text.length()-1),16).intValue() & 0xffffffff;
				} else if (text.charAt(0) == '+') {
					addr = test_base_addr + Long.valueOf(text.substring(1),16).intValue() & 0xffffffff;
				} else if (text.charAt(0) == '-') {
					addr = test_base_addr - Long.valueOf(text.substring(1),16).intValue() & 0xffffffff;
				} else if (text.length() > 2 && text.substring(0,2).equals("*+")) {
					addr = _pz390.psw_loc + Long.valueOf(text.substring(2),16).intValue() & 0xffffffff;
				} else if (text.substring(0,2).equals("*-")) {
					addr = _pz390.psw_loc - Long.valueOf(text.substring(2),16).intValue() & 0xffffffff;
				} else if (text.toUpperCase().charAt(text.length()-1) == '%') {
					final int index_r = text.toUpperCase().indexOf('R');
					int index_p = text.length()-2;
					addr = (_pz390.reg.getInt(get_test_int(text.substring(0,index_r))*8+4)) & pz390.psw_amode24;
					while (text.charAt(index_p) == '%') {
						addr = _pz390.mem.getInt(addr) & pz390.psw_amode24;
						index_p--;
					}
				} else if (text.toUpperCase().charAt(text.length()-1) == '?') {
					final int index_r = text.toUpperCase().indexOf('R');
					int index_q = text.length()-2;
					addr = (_pz390.reg.getInt(get_test_int(text.substring(0,index_r))*8+4)) & pz390.psw_amode31;
					while (text.charAt(index_q) == '?') {
						addr = _pz390.mem.getInt(addr) & pz390.psw_amode31;
						index_q--;
					}
				} else if (text.toUpperCase().equals("EPA")) {
					addr = load_code_load & _pz390.psw_amode;  // RPI 395
				} else {
					addr = get_test_int(text);
				}
			} else if (text.charAt(0) == '*') {
				addr = _pz390.psw_loc;
			} else { // assume single digit
				addr = get_test_int(text);
			}
		} catch (final Exception e) {
			test_error("invalid addr - " + text);
			test_cmd_abort = true;
		}
		if (addr >= 0 && addr < _pz390.tot_mem) {
			return addr; // RPI 540
		} else {
			return -1;
		}
	}

	/**
	 * set test compare code or issue error
	 *  0 - =
	 *  1 - !=
	 *  2 - >
	 *  3 - >=
	 *  4 - <
	 *  5 - <=
	 * @param compare
	 * @return
	 */
	private byte get_test_compare(final String compare) {
		if (compare != null) {
			if (compare.equals("=")) {
				return 0;
			} else if (compare.equals("!=")) {
				return 1;
			} else if (compare.equals("!=")) {
				return 1;
			} else if (compare.equals(">")) {
				return 2;
			} else if (compare.equals(">=")) {
				return 3;
			} else if (compare.equals("<")) {
				return 4;
			} else if (compare.equals("<=")) {
				return 5;
			}
		}
		test_error("invalid break compare operator - " + test_cmd);
		test_cmd_abort = true;
		return -1;
	}

	/**
	 * return long sdt value for register
	 *    b'...'
	 *    c'...'
	 *    c"..."
	 *    f'...'
	 *    h'...'
	 *    x'...'
	 *    or address hex., dec, nr%, nr?, +hex, -hex, *+hex, *-hex
	 * @param text
	 * @return
	 */
	private long get_test_reg_sdt(String text) {
		if (text == null || text.length() == 0) {
			test_cmd_abort = true;
			return -1;
		}
		if (text.length() <= 1
		|| (text.charAt(1) != '\''
			&& text.charAt(1) != '"')) {
			return get_test_addr(text) & 0xffffffff;
		} else {
			try {
				final char   type = text.toUpperCase().charAt(0);
				final String data = text.substring(2,text.length()-1);
				switch (type) {
				case 'B':
					return Long.valueOf(data,2);
				case 'C':
					int index = 0;
					long value = 0;
					int dcc_len = data.length();
					while (index < dcc_len) {
						if (tz390.opt_ascii || text.charAt(1)== '"') {
							value = value * 0x100 + data.charAt(index);
						} else {
							value = value * 0x100 + tz390.ascii_to_ebcdic[data.charAt(index)];
						}
						index++;
						if (index < dcc_len
						 && data.charAt(index) == text.charAt(1)) {
							index++; // skip 2nd quote
							dcc_len--;
						}
					}
					return value;
				case 'F':
				case 'H':
					return Long.valueOf(data);
				case 'X':
					return Long.valueOf(data,16);
				default:
					tz390.put_trace("test invalid reg sdt - " + text);
					test_cmd_abort = true;
				}
			} catch (final Exception e) {
				tz390.put_trace("test invalid reg sdt - " + text);
				test_cmd_abort = true;
			}
		}
		return -1;
	}

	/**
	 * Return memory sdt byte array
	 *    b'...'
	 *    c'...'
	 *    c"..."
	 *    f'...'
	 *    h'...'
	 *    x'...'
	 * @param text
	 * @return
	 */
	private byte[] get_test_mem_sdt(final String text) {
		byte[] data_byte = null;
		int  index         = 0;
		int  data_len      = 0;
		int  data_byte_len = 0;
		long data_val      = 0;
		try {
			final char type = text.toUpperCase().charAt(0);
			String data_text = text.substring(2,text.length()-1);
			data_len = data_text.length();
			switch (type) {
			case 'B':
				data_byte_len = (data_len + 7)/8;
				data_byte = new byte[data_byte_len];
				data_val = Long.valueOf(data_text,2);
				index = data_byte_len-1;
				while (index >= 0) {
					data_byte[index] = (byte)(data_val & 0xff);
					data_val = data_val >>> 8;
					index--;
				}
				return data_byte;
			case 'C':
				data_byte_len = data_len;
				int index1 = 0;
				int index2 = 0;
				while (index1 < data_len) {
					index1++;
					index2++;
					if (index1 < data_len
					 && data_text.charAt(index1) == text.charAt(1)) {
						index1++; // skip 2nd single quote
					}
				}
				data_byte_len = index2;
				data_byte = new byte[data_byte_len];
				index1 = 0;
				index2 = 0;
				while (index1 < data_len) {
					if (tz390.opt_ascii || text.charAt(1)=='"') {
						data_byte[index2] = (byte)data_text.charAt(index1);
					} else {
						data_byte[index2] = tz390.ascii_to_ebcdic[data_text.charAt(index1)];
					}
					index1++;
					index2++;
					if (index1 < data_len
					 && data_text.charAt(index1) == text.charAt(1)) {
						index1++; // skip 2nd single quote
					}
				}
				return data_byte;
			case 'F':
				data_byte_len = 4;
				data_byte = new byte[4];
				data_val = Long.valueOf(data_text);
				index = 3;
				while (index >= 0) {
					data_byte[index] = (byte)(data_val & 0xff);
					data_val = data_val >>> 8;
					index--;
				}
				return data_byte;
			case 'H':
				data_byte_len = 2;
				data_byte = new byte[2];
				data_val = Long.valueOf(data_text);
				index = 1;
				while (index >= 0) {
					data_byte[index] = (byte)(data_val & 0xff);
					data_val = data_val >>> 8;
					index--;
				}
				return data_byte;
			case 'X':
				data_byte_len = (data_len + 1)/2;
				data_byte = new byte[data_byte_len];
				if (data_text.length() < data_byte_len * 2) {
					data_text = "0" + data_text;
				}
				index = 0;
				while (index < data_byte_len) {
					try {
						data_byte[index] = Integer.valueOf(data_text.substring(index*2,index*2+2),16).byteValue();
					} catch (final Exception e) {
						test_error("invalid hex self defining term " + data_text);
						data_byte[index] = 0;
					}
					index++;
				}
				return data_byte;
			default:
				tz390.put_trace("test invalid mem sdt - " + text);
				test_cmd_abort = true;
			}
		} catch (final Exception e) {
			tz390.put_trace("test invalid mem sdt - " + text);
			test_cmd_abort = true;
		}
		return data_byte;
	}

	protected sz390() {
		cmd_processors = new CmdProcessor[max_cmd_proc];
		int cmd_id = 0;
		while (cmd_id < max_cmd_proc) {
			cmd_processors[cmd_id] = new CmdProcessor();
			cmd_id++;
		}
	}
	/**
	 * Initialize tz390 with additional shared objects.
	 *
	 * @param shared_tz390
	 * @param shared_pz390
	 * @param shared_vz390
	 */
	public void init_sz390(final tz390 shared_tz390, final pz390 shared_pz390, final vz390 shared_vz390) {
		tz390  = shared_tz390;
		_pz390 = shared_pz390;
		_vz390  = shared_vz390;
	}

	/**
	 * Return current OS feature bits for use by STFLE instruction.
	 * byte  bit
	 *   0   0 - Y z/OS and 390 instructions avail.
	 *       1 - Y z/OS mode installed
	 *       2 - Y z/OS mode active
	 *       7 - Y STFLE facility installed
	 *   2  16 - N extended translation 2
	 *      18 - N long displacement
	 *      19 - N long displacement performance
	 *      20 - Y HFP multiply and add/subtract
	 *      21 - Y extended immediate
	 *      22 - N extended translation 3
	 *      23 - Y HFP unnormalized
	 *   3  24 - Y extended timer 2
	 *      25 - Y store clock fast
	 *      28 - N extended TOD steering
	 *      30 - N extended timer 3
	 * @return
	 */
	public long get_feature_bits() {
		final int bits0_31 = 0xE1000DC0;
		return ((long)bits0_31) << 32;
	}

	/**
	 * tcp/ip sockets I/O
	 * Inputs:
	 *   r0 = operation
	 *      1 - open server port
	 *            r1=port
	 *      2 - open client port connection
	 *            r1=port
	 *            r14=host ip addr or 0 (HOST=*)
	 *      3 - close port connection
	 *            r1=port
	 *      4 - send message
	 *            r1=port
	 *            r2=connection id
	 *            r14=msg addr
	 *            r15=msg length
	 *      5 - receive message
	 *            r1=port
	 *            r2=connection id or -1
	 *            r14=buffer address
	 *            r15=max msg length
     * Output:
     *   r1 = message length for receive
     *   r2 = connection id for receive
     *   r15= return code
     *         0 - ok
     *         4 - no msg and nowait
     *         12- error on last operation
	 */
	private void svc_tcpio() {
		tcpio_op    = _pz390.reg.getShort(pz390.r0+2);
		tcpio_flags = _pz390.reg.getShort(pz390.r0);
		tcpio_wait =  (tcpio_flags & 0x0001) == 0; // set wait true if NOWAIT bit off
		tcpio_port  = _pz390.reg.getInt(pz390.r1);
		tcpio_conn  = _pz390.reg.getInt(pz390.r2);
		tcpio_amsg  = _pz390.reg.getInt(pz390.r14) & _pz390.psw_amode;
		tcpio_lmsg  = _pz390.reg.getInt(pz390.r15);
		_pz390.reg.putInt(pz390.r15,0);
		tot_tcpio_oper++;
		switch (tcpio_op) {
		case 1: // open server port
			tot_tcpio_opens++;
			tcpio_server_running = true; // enable tcpio server threads
			if (tz390.opt_tracet) {
				put_log("TCPIO open server port " + tcpio_port);
			}
			if (!tcpio_find_server_port()
					&& cur_tcp_server_index > -1) {
				tcp_server_port[cur_tcp_server_index] = tcpio_port;
				if (tcp_server_open[cur_tcp_server_index]) {
					put_log("TCPIO server port alrady open");
					break; // ignore if already open
				}
			} else {
				put_log("TCPIO open server failed - no ports available");
				_pz390.reg.putInt(pz390.r15,12);
				break;
			}
			try {
				tcpio_host_ip = InetAddress.getLocalHost();
				tcpio_host_ip_text = tcpio_host_ip.getHostAddress();
				tcpio_host_name = tcpio_host_ip.getHostName(); // RPI 854
			} catch (final Exception e) {
				put_log("TCPIO error on open get local host failed");
				_pz390.reg.putInt(pz390.r15,12);
				break;
			}
			tcp_server_host_text[cur_tcp_server_index] = tcpio_host_ip_text;
			tcp_server_host_ip[cur_tcp_server_index] = tcpio_host_ip;
			tcp_server_port[cur_tcp_server_index] = tcpio_port;
			if (tz390.opt_tracet) {
				put_log("TCPIO open server socket"
					+ " host=" + tcpio_host_ip_text + " " + tcpio_host_name // RPI 854
					+ " port=" + tcpio_port);
			}
			try {
				tcp_server_socket[cur_tcp_server_index] = new ServerSocket(tcpio_port);
				tcp_server_thread[cur_tcp_server_index] = new Thread(this);
				tcp_server_thread[cur_tcp_server_index].start();
			} catch (final Exception e) {
				put_log("TCPIO error open server socket " + e.toString());
				_pz390.reg.putInt(pz390.r15,12);
				break; // RPI  622
			}
			tcp_server_open[cur_tcp_server_index] = true; // RPI 622
			break;
		case 2: // open client connection to server port
			tot_tcpio_openc++;
			if (tz390.opt_tracet) {
				put_log("TCPIO open client port " + tcpio_port);
			}
			if (tcpio_find_client_port()) {
				if (tcp_client_socket[cur_tcp_client_index] != null
				&& !tcp_client_socket[cur_tcp_client_index].isClosed()) {
					put_log("TCPIO open client port already open");
					break; // ignore if already open
				}
			} else if (cur_tcp_client_index != -1) {
				tcp_client_port[cur_tcp_client_index] = tcpio_port;
				tcpio_host_ip_addr = _pz390.reg.getInt(pz390.r14) & _pz390.psw_amode;
				if (tcpio_host_ip_addr > 0) {
					tcpio_host_ip_text = tz390.get_ascii_var_string(_pz390.mem_byte,tcpio_host_ip_addr,265);
					try {
						tcpio_host_ip   = InetAddress.getByName(tcpio_host_ip_text);
						tcpio_host_name = tcpio_host_ip.getHostName();
					} catch(final Exception e) {
						put_log("TCPIO error open client host not found " + tcpio_host_ip_text);
						_pz390.reg.putInt(pz390.r15,12);
						break;
					}
				} else {
					try {
						tcpio_host_ip   = InetAddress.getLocalHost();
						tcpio_host_ip_text = tcpio_host_ip.getHostAddress();
						tcpio_host_name = tcpio_host_ip.getHostName();
					} catch(final Exception e) {
						put_log("TCPIO error open client get host failed");
						_pz390.reg.putInt(pz390.r15,12);
						break;
					}
				}
				tcp_client_host_text[cur_tcp_client_index] = tcpio_host_ip_text;
				tcp_client_host_ip[cur_tcp_client_index] = tcpio_host_ip;
				if (tz390.opt_tracet) {
					put_log("TCPIO open client"
						+ " HOST=" + tcpio_host_ip_text
						+ " PORT=" + tcpio_port);
				}
				try {
					tcp_client_socket[cur_tcp_client_index] = new Socket(tcpio_host_ip, tcpio_port);
					tcp_client_input[cur_tcp_client_index]  = new DataInputStream(tcp_client_socket[cur_tcp_client_index].getInputStream());
					tcp_client_output[cur_tcp_client_index] = new PrintStream(tcp_client_socket[cur_tcp_client_index].getOutputStream());
				} catch (final Exception e) {
					put_log("TCPIO error open client socket failed for port " + tcpio_port);
					_pz390.reg.putInt(pz390.r15,12);
				}
			} else {
				put_log("TCPIO error max client ports exceeded");
				_pz390.reg.putInt(pz390.r15,12);
			}
			break;
		case 3: // close port
			if (tz390.opt_tracet) {
				put_log("TCPIO close port" + tcpio_port);
			}
			if (tcpio_find_client_port()) {
				tot_tcpio_closec++;
				tcpio_close_client_port();
			} else if (tcpio_find_server_port()) {
				tot_tcpio_closes++;
				tcpio_close_server_port();
			}
			break;
		case 4: // send message
			tot_tcpio_send++;
			if (tcpio_lmsg < tcpio_lmin
			 || tcpio_lmsg > tcpio_lmax) {
				put_log("TCPIO send error msg length out of range " + tcpio_lmsg);
				_pz390.reg.putInt(pz390.r15,12);
				break;
			}
			if (tcpio_find_client_port()) {
				if (tcp_client_output[cur_tcp_client_index] != null) {
					tcp_client_output[cur_tcp_client_index].write(_pz390.mem_byte,tcpio_amsg,tcpio_lmsg);
					if (tz390.opt_tracet) {
						put_log("TCPIO send port=" + tcpio_port
							+ " length=" + tcpio_lmsg);
						dump_mem(_pz390.mem,tcpio_amsg,tcpio_lmsg);
					}
				} else {
					put_log("TCPIO errpr semd failed for port=" + tcpio_port);
					_pz390.reg.putInt(pz390.r15,12);
					break;
				}
			} else if (tcpio_find_server_port()) {
				final int conn_index = _pz390.reg.getInt(pz390.r2);
				if (conn_index >= 0
				 && conn_index < max_tcp_conn
				 && tcp_conn_server_port[conn_index] == tcpio_port) {
					if (tcp_conn_output[conn_index] != null) {
						tcp_conn_output[conn_index].write(_pz390.mem_byte,tcpio_amsg,tcpio_lmsg);
						if (tz390.opt_tracet) {
							put_log("TCPIO send port=" + tcpio_port
								+ " conn=" + conn_index
								+ " length=" + tcpio_lmsg);
							dump_mem(_pz390.mem,tcpio_amsg,tcpio_lmsg);
						}
					} else {
						put_log("TCPIO error send failed on port=" + tcpio_port);
						_pz390.reg.putInt(pz390.r15,12);
						break;
					}
				} else {
					put_log("TCPIO error send port not found " + tcpio_port);
					_pz390.reg.putInt(pz390.r15,12);
					break;
				}
			}
			break;
		case 5: // receive message
			tot_tcpio_recv++;
			if (tz390.opt_tracet) {
				put_log("TCPIO receive msg for port=" + tcpio_port);
			}
			if (tcpio_lmsg < tcpio_lmin
			 || tcpio_lmsg > tcpio_lmax) {
				put_log("TCPIO receive error msg length out of range " + tcpio_lmsg);
				_pz390.reg.putInt(pz390.r15,12);
				break;
			}
			if (tcpio_find_client_port()) {
				tcpio_receive_client_port();
			} else if (tcpio_find_server_port()) {
				tcpio_receive_server_port();
			} else {
				put_log("TCPIO error receive port not found " + tcpio_port);
				_pz390.reg.putInt(pz390.r15,12);
				break;
			}
			break;
		default:
			put_log("TCPIO error invalid operation " + tcpio_op);
			_pz390.set_psw_check(Constants.psw_pic_spec);
		}
	}

	/**
	 * set cur_tcp_server_index to allocated server port and return true else
	 * set cur_tcp_server_index to first free port       and return true else
	 * set cur_tcp_server_index to -1 and return false indicating no ports avail.
	 * @return
	 */
	private boolean tcpio_find_server_port() {
		cur_tcp_server_index = 0;
		int free = -1;
		while (cur_tcp_server_index < max_tcp_server_port) {
			if (tcp_server_port[cur_tcp_server_index] == tcpio_port) {
				return true;
			} else if (free == -1 && tcp_server_port[cur_tcp_server_index] == 0) {
				free = cur_tcp_server_index;
			}
			cur_tcp_server_index++;
		}
		cur_tcp_server_index = free;
		return false;
	}

	/**
	 * set cur_tcp_client_index to allocated  client port and return true else
	 * set cur_tcp_client_index to first free client port and return false else
	 * set cur_tcp_client index to -1 and return false
	 * @return
	 */
	private boolean tcpio_find_client_port() {
		int cur_tcp_client_index = 0;
		int free = -1;
		while (cur_tcp_client_index < max_tcp_client_port) {
			if (tcp_client_port[cur_tcp_client_index] == tcpio_port) {
				return true;
			} else if (free == -1 && tcp_client_port[cur_tcp_client_index] == 0) {
				free = cur_tcp_client_index;
			}
			cur_tcp_client_index++;
		}
		cur_tcp_client_index = free;
		return false;
	}

	/**
	 * Close all client and server ports.
	 */
	private void tcpio_close_ports() {
		tcpio_server_running = false; // shut down any server threads
		cur_tcp_client_index = 0;
		while (cur_tcp_client_index < max_tcp_client_port) {
			if (tcp_client_port[cur_tcp_client_index] > 0) {
				tcpio_close_client_port();
			}
			cur_tcp_client_index++;
		}
		cur_tcp_server_index = 0;
		while (cur_tcp_server_index < max_tcp_server_port) {
			if (tcp_server_port[cur_tcp_server_index] > 0) {
				tcpio_close_server_port();
			}
			cur_tcp_server_index++;
		}
	}

	/**
	 * Close all open TCP/IP ports.
	 */
	private void tcpio_close_client_port() {
		try {
			if (tz390.opt_tracet) {
				put_log("TCPIO closing client port" + tcp_client_port[cur_tcp_client_index]);
			}
			tcp_client_output[cur_tcp_client_index].flush();
			tcp_client_output[cur_tcp_client_index].close();
			tcp_client_input[ cur_tcp_client_index].close();
			tcp_client_socket[cur_tcp_client_index].close();
			tcp_client_socket[cur_tcp_client_index] = null;
			tcp_client_port[  cur_tcp_client_index] = 0;
		} catch (final Exception e) {
			put_log("TCPIO error closing client port " + tcpio_port);
		}
	}

	/**
	 * Close open TCP/IP server port.
	 */
	private synchronized void tcpio_close_server_port() {
		if (tcp_server_open[cur_tcp_server_index]) {
			tcp_server_open[cur_tcp_server_index] = false; // RPI 622
			try {
				if (tz390.opt_tracet) {
					put_log("TCPIO closing server port=" + tcpio_port);
				}
				int conn_index = 0;
				while (conn_index < max_tcp_conn) {
					if (tcp_conn_server_port[conn_index] == tcp_server_port[cur_tcp_server_index]) {
						tcpio_close_conn(conn_index);
					}
					conn_index++;
				}
				tcp_server_socket[cur_tcp_server_index].close();
				tcp_server_socket[cur_tcp_server_index] = null;
			} catch (final Exception e) {
			}
		}
	}

	/**
	 * Close connection by given index.
	 * @param conn_index
	 */
	private void tcpio_close_conn(final int conn_index) {
		tcp_conn_server_port[conn_index] = 0;  // RPI 731
		if (tcp_conn_socket[conn_index] == null) {
			return;
		}
		try {
			if (tz390.opt_tracet) {
				put_log("TCPIO closing connection " + conn_index);
			}
			tcp_conn_output[conn_index].close();
			tcp_conn_input[conn_index].close();
			tcp_conn_socket[conn_index].close();
			tcp_conn_socket[conn_index] = null;
		} catch (final Exception e) {
			put_log("TCPIO close connection failed " + e.toString());
		}
	}

	/**
	 * Receive message from client port.
	 * If nowait and message not ready RC=4 else wait for message.
	 */
	private void tcpio_receive_client_port() {
		try {
			int cur_msg_len = tcp_client_input[cur_tcp_client_index].available();
			if (cur_msg_len > 0 || tcpio_wait) {
				if (tz390.opt_tracet && cur_msg_len == 0) {
					put_log("TCPIO waiting for client msg on port=" + tcpio_port);
				}
				cur_msg_len = tcp_client_input[cur_tcp_client_index].read(_pz390.mem_byte,tcpio_amsg,tcpio_lmsg);
				if (cur_msg_len <= 0) {
					throw new RuntimeException("TCPIO error on client receive port=" + tcpio_port);
				}
				if (tz390.opt_tracet) {
					put_log("TCPIO receive client port=" + tcpio_port + " length=" + cur_msg_len);
					dump_mem(_pz390.mem,tcpio_amsg,cur_msg_len);
				}
				_pz390.reg.putInt(pz390.r1,cur_msg_len);
				return; // return with msg stored in mem
			} else {
				_pz390.reg.putInt(pz390.r15,4);
				_pz390.reg.putInt(pz390.r1,0);
				return; // return RC=4 for NOWAIT
			}
		} catch (final Exception e) {
			put_log("TCPIO receive error on client port=" + tcpio_port);
			_pz390.reg.putInt(pz390.r15,12);
		}
	}

	/**
	 * Receive message from server port connection.
	 * If no connection id is specified (-1), then next message from any connection.
	 * if nowait and message not ready RC=4 else wait for next message.
	 * Notes:
	 *   1. Connection # returned in R2
	 */
	private void tcpio_receive_server_port() {
		if (tz390.opt_traceall) {
			put_log("TCPIO receive msg from port=" + tcpio_port);
		}
		int conn_index = tcpio_conn;
		if (tcpio_conn == -1) {
			conn_index = 0; // start search at conn 0
		}
		tcpio_conn_ready_count = 0; // count ready connections during scan
		while (tcpio_server_running && (conn_index < max_tcp_conn || tcpio_wait)) {
			if (tz390.opt_traceall) {
				put_log("TCPIO check receive conn=" + conn_index);
			}
			try {
				if (tcp_conn_server_port[conn_index] > 0
				 && tcp_conn_msg_ready[conn_index]) {
					// this connection has msg ready so store it and exit
					tcpio_conn_store_msg(conn_index);
					return;
				}
				if (tcpio_conn == -1) {
					// find next message from any connection
					conn_index++;
					if (conn_index >= max_tcp_conn && tcpio_wait) {
						// After checking all connections for any pending messages,
						// wait here for message ready post from live connection thread
						// and then proceed to check again
						lock.lock();
						try {
							if (tcpio_conn_ready_count == 0) {
								lock_condition.await();
							}
						} catch(final Exception e) {
							if (tz390.opt_traceall) {
								put_log("TCPIO error waiting for server message on any conn");
							}
						} finally {
							lock.unlock();
						}
						tcpio_conn_ready_count = 0;
						conn_index = 0;
					}
				} else if (tcpio_wait) {
					// no msg ready from specific connection, so wait for post from connection and try again
					lock.lock(); // RPI 630 fix missing lock
					try {
						lock_condition.await();
					} catch(final Exception e) {
						if (tz390.opt_traceall) {
							put_log("TCPIO error waiting for server message on conn=" + tcpio_conn);
						}
					} finally {
						lock.unlock();
					}
				} else {
					// force nowait exit with conn=-1
					conn_index = max_tcp_conn;
				}
			} catch (final Exception e) {
				put_log("TCPIO error checking conn msg available on conn=" + conn_index + " - " + e.toString());
				tcpio_close_conn(conn_index);
			}
		}
		_pz390.reg.putInt(pz390.r1,  0); // return  0 msg length
		_pz390.reg.putInt(pz390.r2, -1); // return -1 conn index (none)
		_pz390.reg.putInt(pz390.r15, 4); // exit RC=4 NOWAIT and no msg ready
	}

	/**
	 * 1.  store msg from conn input buffer up to specified lmsg length and return actual length stored in R1.
	 *.2.  Turn off tcp_conn_msg_ready if 0 avail.
	 * Notes:
	 *   1.  First byte may be in conn_byte if conn_read = true
	 * @param conn_index
	 */
	private void tcpio_conn_store_msg(final int conn_index) {
		if (tz390.opt_traceall) {
			put_con("TCPIO storing msg from conn=" + conn_index);
			tz390.sleep_now(tz390.monitor_wait);
		}
		_pz390.reg.putInt(pz390.r2,conn_index); // return conn index
		int cur_msg_len = 0;
		int conn_amsg = tcpio_amsg;
		int conn_lmsg = tcpio_lmsg;
		if (tcp_conn_read[conn_index]) {
			cur_msg_len = 1;
			_pz390.mem.put(conn_amsg,tcp_conn_byte[conn_index]);
			tcp_conn_read[conn_index] = false;
			conn_amsg++;
			conn_lmsg--;
		}
		if  (conn_lmsg > 1) {
			try {
				int msg_avail = tcp_conn_input[conn_index].available();
				if (conn_lmsg > msg_avail) {
					conn_lmsg = msg_avail;
				}
				if (conn_lmsg > 0
					&& tcp_conn_input[conn_index].read(_pz390.mem_byte,conn_amsg,conn_lmsg) != conn_lmsg) {
					throw new RuntimeException("TCPIO error on store message from port=" + tcp_conn_server_port[conn_index]);
				}
				cur_msg_len = cur_msg_len + conn_lmsg;
			} catch (final Exception e) {
				put_log("TCPIO error storing message from conn=" + conn_index + " - " + e.toString());
				_pz390.reg.putInt(pz390.r15,12);
			}
		}
		_pz390.reg.putInt(pz390.r1,cur_msg_len);
		if (tz390.opt_tracet) {
			put_log("TCPIO receive server msg from port=" + tcpio_port
				+ " conn=" + conn_index + " length=" + cur_msg_len);
			dump_mem(_pz390.mem,tcpio_amsg,cur_msg_len);
		}
		tcpio_set_conn_msg_ready(conn_index,false);
	}

	/**
	 * if state true
	 *    set conn msg ready (byte has been read by conn thread)
	 * else if no msg data available
	 *    reset conn msg ready (will force read on conn thread)
	 * else
	 *    leave conn ready set to true (allows main user thread to read
	 *    mult msgs without switching back to conn thread for a read)
	 * @param conn_index
	 * @param state
	 * @return
	 */
	private synchronized boolean tcpio_set_conn_msg_ready(final int conn_index, final boolean state) {
		if (state) {
			tcp_conn_msg_ready[conn_index] = true;
			return true;
		}
		try {
			if (tcp_conn_input[conn_index].available() == 0) {
				tcp_conn_msg_ready[conn_index] = false;
				return false;
			} else {
				return true;
			}
		} catch (final Exception e) {
			put_log("TCPIO disconnect while switching state for conn=" + conn_index);
			tcpio_close_conn(conn_index);
		}
		return false;
	}

	/**
	 * Allocate next connection for server port use.
	 * @param port_index
	 * @return
	 */
	private synchronized boolean tcp_alloc_conn(final int port_index) {
		int conn_index = 0;
		while (conn_index < max_tcp_conn) {
			if (tcp_conn_server_port[conn_index] == 0) {
				tcp_conn_server_port[conn_index] = tcpio_port;
				tcp_server_conn_index[port_index] = conn_index;
				tcp_conn_server_index[conn_index] = port_index;
				tcp_conn_socket[conn_index] = null;
				return true;
			}
			conn_index++;
		}
		return false;
	}

	/**
	 * Release TCP connection for reuse.
	 * @param conn_index
	 */
	private synchronized void tcp_free_conn(final int conn_index) {
		final int port_index = tcp_conn_server_index[conn_index];
		if (!tcp_server_open[port_index]) { // RPI 622 free conn's at close
			tcp_conn_server_port[conn_index] = 0;
			return;
		}
		if (tcp_conn_server_index[conn_index] == tcp_server_conn_index[port_index]) {
			tcp_server_conn_index[port_index] = 0;
			tcp_conn_server_index[conn_index] = 0;
			tcp_conn_server_port[conn_index] = 0;
			tcp_conn_socket[conn_index] = null;
		} else {
			abort_error(23, "TCPIO free conn internal error - aborting.");
		}
	}

	/**
	 * Return true if DFP value finite based on CF5 field value common to all DFP types.
	 * @param dfp_bytes
	 * @param dfp_byte_index
	 * @return
	 */
	private boolean check_dfp_finite(final byte[] dfp_bytes, final int dfp_byte_index) {
		if (tz390.dfp_cf5_to_exp2[(dfp_bytes[dfp_byte_index] >>> 2) & 0x1f]<= 2) {
			return true;
		} else {
			return false;
		}
	}

	/**
	 * Check area start end and abort S0C5 if invalid. RPI-0668
	 * @param addr
	 * @param len
	 */
	private void check_mem_area(final int addr, final int len) {
		if (addr < 0
			|| len < 0
			|| addr + len > _pz390.tot_mem) {
			_pz390.set_psw_check(Constants.psw_pic_addr);
		}
	}

	/*
	 * ASSIST I/O file handling functions RPI-0812
	 */
	/**
	 * Open ASSIST file by ddname and return TIOT index if open successful else return -1
	 * 
	 * @param ddname
	 * @param input_type
	 * @param dcb_addr
	 * @return
	 */
	public int ast_open_file(final String ddname, final boolean input_type, final int dcb_addr) {
		tot_dcb_open++;
		tot_dcb_oper++;
		cur_tiot_index = get_new_tiot_index(ddname,dcb_addr)-1;
		if (cur_tiot_index != -1) {
			cur_dcb_file_name = get_tiot_file_name(cur_tiot_index);
			tiot_dsn[cur_tiot_index] = cur_dcb_file_name;
			cur_dcb_addr = dcb_addr;
			tiot_dcb_addr[cur_tiot_index] = dcb_addr;
			tiot_cur_rba[cur_tiot_index] = 0; // RPI101
			if (input_type) {
				try {
					tiot_file[cur_tiot_index] = new RandomAccessFile(cur_dcb_file_name,"r");
					tiot_eof_rba[cur_tiot_index] = tiot_file[cur_tiot_index].length();
				} catch (final Exception e) {
					dcb_synad_error(23, "I/O error on open - " + e.toString());
					_pz390.psw_cc = pz390.psw_cc3;
					return cur_tiot_index;
				}
			} else {
				try {
					tiot_file[cur_tiot_index] = new RandomAccessFile(cur_dcb_file_name,"rw");
					tiot_file[cur_tiot_index].setLength(0);
				} catch (final Exception e) {
					dcb_synad_error(23, "I/O error on open - " + e.toString());
					return -1;
				}
			}
		}
		tiot_dcb_open[cur_tiot_index] = true; // RPI-0110
		return cur_tiot_index;
	}

	/**
	 * Close assist file.
	 * @param tiot_index
	 */
	public void ast_close_file(final int tiot_index) {
		if (tiot_index < 0) {
			return;
		}
		tot_dcb_close++;
		tot_dcb_oper++;
		try {
			tiot_file[tiot_index].close();
			tiot_dcb_open[tiot_index] = false; // RPI-0110
		} catch (final Exception e) {
			dcb_synad_error(26,"i/o error on close - " + e.toString());
			_pz390.set_psw_check(Constants.psw_pic_io);
		}
	}

	/**
	 * z390 internal sort.
	 */
	private void svc_zsort() {
		/*
 		 * z390 internal sort
 		 *   r0  = operation type:
 		 *          1 - internal sort
 		 *          2 - file sort
 		 *          3 - put record to internal sort
 		 *          4 - get record from internal sort
 		 *   r1  = address parameter list for op 1 and 2 a(rec) for get/put
 		 *          0 4 - LRECL
 		 *          4 4 - max memory or 0 for max avail from MEM option
 		 *          8 4 - key field N offset from 0
 		 *         12 4 - key field N length
 		 *         16 2 - key type code and VL bit for last key
 		 *         18 2 - ascending = 0, descending 1 (also VL bit for last key)
 		 *   r15 = return code
 		 *          0 - OK
 		 *          4 - EOF for get
 		 *         16 - Abort due to error
 		 */
		zsort_parm_addr   = _pz390.reg.getInt(pz390.r1) & _pz390.psw_amode;
		switch (_pz390.reg.get(pz390.r0+3)) {
		case 1: // 	internal sort init
			zsort_id++;
			zsort_start = tz390.cur_time(true);
			if (tz390.opt_traceall) {
				tz390.put_trace("ZSORT ISORT INIT");
				dump_mem(_pz390.mem,zsort_parm_addr,8+10*12);
			}
			zsort_init_isort();
			break;
		case 2: // zsort put unsorted record
			zsort_put();
			break;
		case 3: // zsort get sorted record
			zsort_get();
			break;
		default:
			zsort_error("zsort undefined operation.");
			return;
		}
	}

	/**
	 * Move record of length zsort_lrecl in memory.
	 * @param from_ptr
	 * @param to_ptr
	 */
	private void zsort_move_rec(final int from_ptr, final int to_ptr) {
		System.arraycopy(_pz390.mem_byte, from_ptr, _pz390.mem_byte, to_ptr, zsort_lrecl);
		if (tz390.opt_traceall) {
			tz390.put_trace("ZSORT MOVE BLK FROM=" + tz390.get_hex(from_ptr,8) + " TO=" + tz390.get_hex(to_ptr,8));
			dump_mem(_pz390.mem,from_ptr,zsort_lrecl);
		}
		zsort_tot_move++;
	}

	/**
	 * Open sort work files and reset rbas to 0.
	 */
	private void zsort_open_sortwk() {
		String zsort_sortwk01_dsn = get_ascii_env_var_string("SORTWK01");
		if (zsort_sortwk01_dsn.length() == 0) {
			zsort_sortwk01_dsn = "SORTWK01.TMP";
		}
		String zsort_sortwk02_dsn = get_ascii_env_var_string("SORTWK02");
		if (zsort_sortwk02_dsn.length() == 0) {
			zsort_sortwk02_dsn = "SORTWK02.TMP";
		}
		if (zsort_sortwk01_file == null) {
			try {
				zsort_sortwk01_file = new RandomAccessFile(zsort_sortwk01_dsn,"rw");
				zsort_sortwk01_file.setLength(0);
			} catch(final Exception e) {
				zsort_error("zsort open sortwk01 failed - " + e);
			}
		} else {
			try {
				zsort_sortwk01_file.seek(0);
				zsort_sortwk01_file.setLength(0);
			} catch(final Exception e) {
				zsort_error("zsort sortwk01 seek failed " +e);
			}
		}
		if (zsort_sortwk02_file == null) {
			try {
				zsort_sortwk02_file = new RandomAccessFile(zsort_sortwk02_dsn,"rw");
				zsort_sortwk02_file.setLength(0);
			} catch(final Exception e) {
				zsort_error("zsort open sortwk02 failed - " + e);
			}
		} else {
			try {
				zsort_sortwk02_file.seek(0);
				zsort_sortwk02_file.setLength(0);
			} catch(final Exception e) {
				zsort_error("zsort sortwk02 seek failed " +e);
			}
		}
	}

	/**
	 * Write block from zsort_blk_addr to zsort_blk_ptr at current addr on file.
	 * @param file
	 * @param rec_ptr
	 * @param end_ptr
	 */
	private void zsort_write_blk(final RandomAccessFile file, final int rec_ptr, final int end_ptr) {
		zsort_write_len = end_ptr - rec_ptr;
		try {
			file.write(_pz390.mem_byte,rec_ptr,zsort_write_len);
		} catch(final Exception e) {
			zsort_error("zsort IO write blk error " + e);
			return;
		}
		if (tz390.opt_traceq || tz390.opt_traceall) {
			String zsort_wk_name;
			if (file == zsort_sortwk01_file) {
				zsort_wk_name = "SORTWK01";
			} else {
				zsort_wk_name = "SORTWK02";
			}
			try {
			tz390.put_trace("ZSORT IO WRITE BLK ON " + zsort_wk_name
					+ " XRBA=" + tz390.get_long_hex(file.getFilePointer()-zsort_write_len,8)
					+ " LEN="  + tz390.get_hex(zsort_write_len,8));
			} catch (final Exception e) {
				zsort_error("ZSORT IO WRITE BLK ERROR " + e);
			}
			dump_mem(_pz390.mem, rec_ptr,zsort_write_len);
		}
		zsort_tot_write++;
	}

	/**
	 * Write merged block to output merge file.
	 * @param rec_ptr
	 * @param end_ptr
	 */
	private void zsort_write_merge_blk(int rec_ptr,int end_ptr) {
		if (zsort_merge_wk01) {
			zsort_write_blk(zsort_sortwk02_file,rec_ptr,end_ptr);
		} else {
			zsort_write_blk(zsort_sortwk01_file,rec_ptr,end_ptr);
		}
	}

	/**
	 * Read block into blk_ptr to blk_end_ptr at current merge file_xrba.
	 * Return bytes read up to block size or end of file, or 0 if at end.
	 * 
	 * @param file_xrba
	 * @param file_xrba_end
	 * @param blk_ptr
	 * @param blk_end_ptr
	 */
	private void zsort_read_merge_blk(long file_xrba,long file_xrba_end,int blk_ptr,int blk_end_ptr) {
		zsort_read_len = blk_end_ptr - blk_ptr;
		if (file_xrba + zsort_read_len > file_xrba_end) {
			zsort_read_len = (int)(file_xrba_end - file_xrba);
		}
		if (zsort_read_len == 0) {
			return;
		}
		try {
			if (zsort_merge_wk01) {
				zsort_sortwk01_file.seek(file_xrba);
				zsort_sortwk01_file.read(_pz390.mem_byte,blk_ptr,zsort_read_len);
			} else {
				zsort_sortwk02_file.seek(file_xrba);
				zsort_sortwk02_file.read(_pz390.mem_byte,blk_ptr,zsort_read_len);
			}
		} catch(final Exception e) {
			zsort_error("zsort IO read blk error " + e);
			return;
		}
		if (tz390.opt_traceq || tz390.opt_traceall) {
			String zsort_wk_name;
			if (zsort_merge_wk01) {
				zsort_wk_name = "SORTWK01";
			} else {
				zsort_wk_name = "SORTWK02";
			}
			tz390.put_trace("ZSORT IO READ MERGE BLK FROM " +zsort_wk_name
					+ " XRBA=" + tz390.get_long_hex(file_xrba,8)
					+ " LEN="  + tz390.get_hex(zsort_read_len,8));
			dump_mem(_pz390.mem, blk_ptr, zsort_read_len);
		}
		zsort_tot_read++;
	}

	/**
	 * Initialize isort or fsort parameters.
	 */
	private void zsort_init_parms() {
		zsort_put = false;
		zsort_get = false;
		zsort_tot_svc_put = 0;
		zsort_tot_svc_get = 0;
		zsort_sortwk_len  = 0;
		zsort_lrecl = _pz390.mem.getInt(zsort_parm_addr    );
		zsort_mem   = _pz390.mem.getInt(zsort_parm_addr + 4);
		zsort_tot_keys   = 0;
		zsort_tot_sorts  = 0;
		zsort_tot_passes = 0;
		zsort_tot_move   = 0;
		zsort_tot_comp   = 0;
		zsort_tot_write  = 0;
		zsort_tot_read   = 0;
		int index = 0;
		zsort_parm_addr = zsort_parm_addr + 8;
		while (index < zsort_max_keys && zsort_tot_keys == 0) {
			zsort_key_off[  index] = _pz390.mem.getInt(zsort_parm_addr    );
			zsort_key_len[  index] = _pz390.mem.getInt(zsort_parm_addr + 4);
			zsort_key_type[ index] = _pz390.mem.get(   zsort_parm_addr + 9);
			zsort_key_order[index] = _pz390.mem.get(   zsort_parm_addr +11);
			// Check for VL bit on last key full word parameter
			if (_pz390.mem.get(zsort_parm_addr + 8) != 0) {
				zsort_tot_keys = index + 1;
			} else {
				zsort_parm_addr = zsort_parm_addr + 12;
			}
			index++;
		}
		if (zsort_tot_keys == 0) {
			zsort_error("zsort maximum keys exceeded");
		}
	}

	/**
	 * Initialize for internal sort.
	 */
	private void zsort_init_isort() {
		zsort_init_parms();
		zsort_put = true;
		zsort_alloc_blk();
		zsort_blk_ptr = zsort_blk_addr;
		zsort_blk_end = zsort_blk_addr + zsort_blk_len;
		zsort_tot_read    = 0;
		zsort_tot_write   = 0;
		zsort_tot_svc_put = 0;
		zsort_tot_svc_get = 0;
	}

	/**
	 * Pass unsorted record to zsort.
	 */
	private void zsort_put() {
		if (!zsort_put) {
			zsort_error("zsort not open for put");
			return;
		}
		if (zsort_blk_ptr >= zsort_blk_end) {
			zsort_sort_blk();
			if (zsort_sortwk01_file == null) {
				zsort_open_sortwk();
			}
			zsort_write_blk(zsort_sortwk01_file, zsort_blk_addr, zsort_blk_end);
			zsort_blk_ptr = zsort_blk_addr;
		}
		zsort_move_rec(_pz390.reg.getInt(pz390.r1), zsort_blk_ptr); // move rec to blk
		if (tz390.opt_traceall) {
			tz390.put_trace("ZSORT PUT REC");
			dump_mem(_pz390.mem, zsort_blk_ptr, zsort_lrecl);
		}
		zsort_blk_ptr = zsort_blk_ptr + zsort_lrecl;
		zsort_tot_svc_put++;
	}

	/**
	 * Get sorted record from zsort.
	 */
	private void zsort_get() {
		if (!zsort_get) {
			if (!zsort_put) {
				zsort_error("zsort not ready for get");
				return;
			}
			if (zsort_tot_svc_put == 0) {
				// return rc 4 end of file
				_pz390.reg.putInt(pz390.r15,4);
				zsort_get = false;
					zsort_put = false;
					return;
				}
				zsort_sort_blk(); // may be short block
				if (zsort_tot_write > 0) {
					zsort_write_blk(zsort_sortwk01_file,zsort_blk_addr,zsort_blk_ptr); // may be short block
					zsort_merge();
					zsort_merge_wk_blk_len = zsort_sortwk_len;
					zsort_blk1_xrba = 0;
					zsort_blk1_xrba_end = zsort_sortwk_len;
					zsort_blk1_ptr = zsort_blk1_addr;
					zsort_blk1_ptr_end = zsort_blk1_addr + zsort_blk_len;
					zsort_get_merge_blk1();
				} else {
					zsort_blk_end = zsort_blk_ptr;
					zsort_blk_ptr = zsort_blk_addr;
				}
				if (tz390.opt_stats) {
					zsort_put_stats();
				}
				zsort_put = false;
				zsort_get = true;
			}
			if (zsort_sortwk_len > 0) {
				if (zsort_blk1_ptr < zsort_blk1_ptr_end) {
					zsort_move_rec(zsort_blk1_ptr,_pz390.reg.getInt(pz390.r1)); // move from single block
					zsort_blk1_ptr = zsort_blk1_ptr + zsort_lrecl;
					if (zsort_blk1_ptr >= zsort_blk1_ptr_end) {
						zsort_get_merge_blk1();
					}
				} else {
					// return rc 4 end of file
					zsort_term();
					_pz390.reg.putInt(pz390.r15,4);
					zsort_get = false;
					return;
				}
			} else {
				if (zsort_blk_ptr < zsort_blk_end) {
					zsort_move_rec(zsort_blk_ptr,_pz390.reg.getInt(pz390.r1)); // move from single block
					zsort_blk_ptr = zsort_blk_ptr + zsort_lrecl;
				} else {
					// return rc 4 end of file
					zsort_term();
					_pz390.reg.putInt(pz390.r15,4);
					zsort_get = false;
					return;
				}
			}
			if (tz390.opt_traceall) {
				tz390.put_trace("ZSORT GET REC");
				dump_mem(_pz390.mem,_pz390.reg.getInt(pz390.r1),zsort_lrecl);
			}
			zsort_tot_svc_get++;
	}

	/**
	 * Allocate block using zsort_mem or max avail.
	 */
	private void zsort_alloc_blk() {
		if (zsort_mem == 0) {
			_pz390.reg.putInt(pz390.r0,0x80000001); // set RMODE31 and conditional
			_pz390.reg.putInt(pz390.r1,0x7ffffff0); // set max mem
			svc_getmain(); // force setting max_mem_blk
			zsort_mem = max_mem_blk;
		}
		zsort_blk_len = (zsort_mem / zsort_lrecl)*zsort_lrecl - zsort_lrecl;
		// round to multiple of lrecl and leave 1 rec at end for swap
		if (zsort_blk_len < zsort_min_blk_rec * zsort_lrecl) {
			zsort_error("zsort memory block too small"); // buffer too small
			return;
		}
		_pz390.reg.putInt(pz390.r0,0x80000000); // set RMODE31
		_pz390.reg.putInt(pz390.r1,zsort_blk_len+zsort_lrecl); // set mem blk req len RPI 1165
		req_opt = 0; // request unconditional to avoid S80A
		svc_getmain(); // force setting max_mem_blk
		zsort_blk_addr = _pz390.reg.getInt(pz390.r1);
		zsort_fm_len = zsort_blk_len; // save before rounding
	}

	/**
	 * Terminate zsort
	 *   1.  freemain allocated memory
	 *   2.  close/delete sortwk1 and sortwk2
	 */
	private void zsort_term() {
		if (zsort_fm_len > 0) {
			zsort_freemain();
		}
		if (zsort_sortwk01_file != null) {
			zsort_close_wk();
		}
	}

	/**
	 * Release storage if allocated.
	 */
	private void zsort_freemain() {
		if (zsort_fm_len == 0) {
			return;
		}
		_pz390.reg.putInt(pz390.r0,zsort_fm_len);
		_pz390.reg.putInt(pz390.r1,zsort_blk_addr);
		svc_freemain();
		zsort_fm_len = 0;
	}

	/**
	 * Close and delete files sortwk01 and sortwk02.
	 */
	private void zsort_close_wk() {
		try {
			zsort_sortwk01_file.setLength(0);
			zsort_sortwk01_file.close();
			zsort_sortwk02_file.setLength(0);
			zsort_sortwk02_file.close();
		} catch (final Exception e) {
			abort_error(125, "ZSORT CLOSE FAILED " + e);
		}
	}

	/**
	 * Write zsort statistics to sta file.
	 */
	private void zsort_put_stats() {
		zsort_ended = tz390.cur_time(true);
		zsort_pfx = "ZSORT ID=" + zsort_id + " ";
		tz390.put_stat_line(zsort_pfx
			+ "started=" + zsort_start
			+ " ended=" + zsort_ended);
		tz390.put_stat_line(zsort_pfx
			+ "lrecl=" +zsort_lrecl
			+ " keys=" + zsort_tot_keys);
		tz390.put_stat_line(zsort_pfx
				+ "records-got=" + zsort_tot_svc_get
				+ " memory= " + zsort_blk_len);
		tz390.put_stat_line(zsort_pfx
				+ "records-put=" + zsort_tot_svc_put
				+ " memory= " + zsort_blk_len);
		tz390.put_stat_line(zsort_pfx
			+ "record compares=" + zsort_tot_comp
			+ " moves=" + zsort_tot_move);
		tz390.put_stat_line(zsort_pfx
			+ "sorted blocks=" + zsort_tot_sorts
			+ " merge passes=" + zsort_tot_passes);
		tz390.put_stat_line(zsort_pfx
			+ "block writes=" + zsort_tot_write
			+ " reads=" + zsort_tot_read);
		tz390.put_stat_line(zsort_pfx
				+ "merge passes=" + zsort_merge_pass);
	}

	/**
	 * Issue error and set return code 16.
	 * @param msg
	 */
	private void zsort_error(final String msg) {
		_pz390.reg.putInt(pz390.r15,16);
		abort_error(124, msg);
		// zsort_abort = true; // JBA - unused
	}

	/**
	 * Sort fixed length records in zsort_blk up to zsort_blk_ptr.
	 */
	private void zsort_sort_blk() {
		zsort_tot_sorts++;
		int rec_diff = (zsort_blk_ptr - zsort_blk_addr + zsort_lrecl)/zsort_lrecl;
			rec_diff = rec_diff / 2 * zsort_lrecl;

		int rec_ptr1;
		int rec_ptr2;
		int last_move_ptr;
		while (rec_diff > 0) {
			rec_ptr1 = zsort_blk_addr + rec_diff;
			while (rec_ptr1 < zsort_blk_ptr) {
				zsort_move_rec(rec_ptr1,zsort_blk_end);
				rec_ptr2  = rec_ptr1 - rec_diff;
				last_move_ptr = 0;
				while (rec_ptr2 >= zsort_blk_addr
					&& zsort_comp(rec_ptr2,zsort_blk_end)) {
					zsort_move_rec(rec_ptr2,rec_ptr2 + rec_diff);
					last_move_ptr = rec_ptr2;
					rec_ptr2 = rec_ptr2 - rec_diff;
				}
				if (last_move_ptr != 0) {
					zsort_move_rec(zsort_blk_end,last_move_ptr);
				}
				rec_ptr1 = rec_ptr1 + zsort_lrecl;
			}
			rec_diff = rec_diff / zsort_lrecl / 2 * zsort_lrecl;
		}
	}

	/**
	 * Compare record key fields at mem(rec1) to mem(rec2) and return true if swap required
	 * @param rec1
	 * @param rec2
	 * @return
	 */
	private boolean zsort_comp(final int rec1, final int rec2) {
		zsort_tot_comp++;
		int key_index = 0;
		while (key_index < zsort_tot_keys) {
			int index1 = rec1 + zsort_key_off[key_index];
			int index2 = rec2 + zsort_key_off[key_index];
			int key_len = zsort_key_len[key_index];
			if (tz390.opt_traceall) {
				tz390.put_trace(
					"ZSORT COMPARE KEYS  OFF=" + zsort_key_off[key_index]
				  + " LEN=" + key_len
				  + " TYPE=" + zsort_key_type[key_index]
				  + " REC1=" + tz390.get_hex(index1,8)
				  + " REC2=" + tz390.get_hex(index2,8));
				dump_mem(_pz390.mem,index1,key_len);
				dump_mem(_pz390.mem,index2,key_len);
			}
			int int1;
			int int2;
			switch(zsort_key_type[key_index]) {
			case 1: // AC - ASCII characters
				while (key_len > 0) {
					int1 = tz390.ebcdic_to_ascii[_pz390.mem_byte[index1] & 0xff] & 0xff;
					int2 = tz390.ebcdic_to_ascii[_pz390.mem_byte[index2] & 0xff] & 0xff;
					if (zsort_key_order[key_index] > 0) {
						if (int1 > int2) return true;
						if (int1 < int2) return false;
					} else {
						if (int1 > int2) return false;
						if (int1 < int2) return true;
					}
					index1++;
					index2++;
					key_len--;
				}
				break;
			case 2: // BI - unsigned binary
			case 3: // CH - EBCDIC characters
				while (key_len > 0) {
					int1 = _pz390.mem_byte[index1] & 0xff;
					int2 = _pz390.mem_byte[index2] & 0xff;
					if (zsort_key_order[key_index] > 0) {
						if (int1 > int2) return true;
						if (int1 < int2) return false;
					} else {
						if (int1 > int2) return false;
						if (int1 < int2) return true;
					}
					index1++;
					index2++;
					key_len--;
				}
				break;
			case 4: // FI - signed binary
			case 5: // FL - floating point
				int1 = _pz390.mem_byte[index1];
				int2 = _pz390.mem_byte[index2];
				if (zsort_key_order[key_index] > 0) {
					if (int1 > int2) return true;
					if (int1 < int2) return false;
				} else {
					if (int1 > int2) return false;
					if (int1 < int2) return true;
				}
				index1++;
				index2++;
				key_len--;
				while (key_len > 0) {
					int1 = _pz390.mem_byte[index1] & 0xff;
					int2 = _pz390.mem_byte[index2] & 0xff;
					if (zsort_key_order[key_index] > 0) {
						if (int1 > int2) return true;
						if (int1 < int2) return false;
					} else {
						if (int1 > int2) return false;
						if (int1 < int2) return true;
					}
					index1++;
					index2++;
					key_len--;
				}
				break;
			case 6: // PD - packed decimal
				int1 = _pz390.mem_byte[index1 + key_len - 1] & 0xf; // sign key1
				if (int1 == 0xd) {
					int1 = -1;
				}
				int2 = _pz390.mem_byte[index2 + key_len - 1] & 0xf; // sign key2
				if (int2 == 0xd) {
					int2 = -1;
				}
				if (zsort_key_order[key_index] > 0) {
					if (int1 > int2) return true;
					if (int1 < int2) return false;
				} else {
					if (int1 > int2) return false;
					if (int1 < int2) return true;
				}
				while (key_len > 0) {
					int1 = _pz390.mem_byte[index1] & 0xff;
					int2 = _pz390.mem_byte[index2] & 0xff;
					if (zsort_key_order[key_index] > 0) {
						if (int1 > int2) return true;
						if (int1 < int2) return false;
					} else {
						if (int1 > int2) return false;
						if (int1 < int2) return true;
					}
					index1++;
					index2++;
					key_len--;
				}
				break;
			case 7: // ZD - zoned decimal
				int1 = _pz390.mem_byte[index1 + key_len - 1] & 0xf0; // sign key1
				if (int1 == 0xd0) {
					int1 = -1;
				}
				int2 = _pz390.mem_byte[index2 + key_len - 1] & 0xf0; // sign key2
				if (int2 == 0xd0) {
					int2 = -1;
				}
				if (zsort_key_order[key_index] > 0) {
					if (int1 > int2) return true;
					if (int1 < int2) return false;
				} else {
					if (int1 > int2) return false;
					if (int1 < int2) return true;
				}
				final byte save_sign1 = _pz390.mem_byte[index1 + key_len - 1];
				final byte save_sign2 = _pz390.mem_byte[index2 + key_len - 1];
				_pz390.mem_byte[index1 + key_len - 1] = (byte)(_pz390.mem_byte[index1 + key_len - 1] & 0x0f); // remove sign
				_pz390.mem_byte[index2 + key_len - 1] = (byte)(_pz390.mem_byte[index2 + key_len - 1] & 0x0f); // remove sign
				while (key_len > 0) {
					int1 = _pz390.mem_byte[index1] & 0xff;
					int2 = _pz390.mem_byte[index2] & 0xff;
					if (zsort_key_order[key_index] > 0) {
						if (int1 > int2) {
							_pz390.mem_byte[index1 + key_len - 1] = save_sign1;
							_pz390.mem_byte[index2 + key_len - 1] = save_sign2;
							return true;
						} else if (int1 < int2) {
							_pz390.mem_byte[index1 + key_len - 1] = save_sign1;
							_pz390.mem_byte[index2 + key_len - 1] = save_sign2;
							return false;
						}
					} else {
						if (int1 > int2) {
							_pz390.mem_byte[index1 + key_len - 1] = save_sign1;
							_pz390.mem_byte[index2 + key_len - 1] = save_sign2;
							return false;
						} else if (int1 < int2) {
							_pz390.mem_byte[index1 + key_len - 1] = save_sign1;
							_pz390.mem_byte[index2 + key_len - 1] = save_sign2;
							return true;
						}
					}
					index1++;
					index2++;
					key_len--;
				}
				_pz390.mem_byte[index1 + key_len - 1] = save_sign1;
				_pz390.mem_byte[index2 + key_len - 1] = save_sign2;
				break;
			default:
				zsort_error("zsort invalid key type " + zsort_key_type[key_index]);
				return false;
			}
			key_index++;
		}
		return false;
	}

	/**
	 * Merge sorted blocks from sortwk01 to sortwk02 and back again
	 * doubling sorted block size each time until there is 1 sorted block.
	 */
	private void zsort_merge() {
		zsort_merge_mem_blk_len = zsort_blk_len/zsort_lrecl/3*zsort_lrecl;
		// 3 memory blocks (2 in, 1 out)
		zsort_merge_wk_blk_len = zsort_blk_len;
		// start with sorted block size on wk01 for first merge pass
		zsort_merge_wk01 = true; // read wk01 first pass
		try {
			zsort_sortwk_len = zsort_sortwk01_file.length();
		} catch (final Exception e) {
			zsort_error("ZSORT SORTKW01 LENGTH ERROR - " + e);
			return;
		}
		while (zsort_merge_wk_blk_len < zsort_sortwk_len) {
			//perform merge pass until 1 merged block
			zsort_init_merge_pass();
			while (zsort_blk1_xrba < zsort_sortwk_len) {
				zsort_get_merge_blk1();
				zsort_get_merge_blk2();
				while (zsort_blk1_ptr < zsort_blk1_ptr_end
					|| zsort_blk2_ptr < zsort_blk2_ptr_end) {
					// merge blk1 and blk2 into blk3 until none
					zsort_merge_blk_rec();
				}
				zsort_next_merge_blks();
			}
			if (zsort_merge_wk01) {
				zsort_merge_wk01 = false;
				try {
					zsort_sortwk01_file.setLength(0);
				} catch (final Exception e) {
					zsort_error("ZSORT ERROR RESETING SORTWK01 " + e);
				}
			} else {
				zsort_merge_wk01 = true;
				try {
					zsort_sortwk02_file.setLength(0);
				} catch (final Exception e) {
					zsort_error("ZSORT ERROR RESETING SORTWK02 " + e);
				}
			}
			// double block size for next pass
			zsort_merge_wk_blk_len = zsort_merge_wk_blk_len * 2;
		}
	}

	/**
	 * Initialize for merge of wk01/wk02.
	 */
	private void zsort_init_merge_pass() {
		zsort_tot_passes++;
		zsort_blk1_addr = zsort_blk_addr;
		zsort_blk1_ptr_end = zsort_blk1_addr + zsort_merge_mem_blk_len;
		zsort_blk2_addr  = zsort_blk1_ptr_end;
		zsort_blk2_ptr_end = zsort_blk2_addr + zsort_merge_mem_blk_len;
		zsort_blk3_addr  = zsort_blk2_ptr_end;
		zsort_blk3_ptr   = zsort_blk3_addr;
		zsort_blk3_ptr_end = zsort_blk3_addr + zsort_merge_mem_blk_len;
		zsort_blk1_xrba = 0;
		zsort_blk1_xrba_end = zsort_blk1_xrba + zsort_merge_wk_blk_len;
		zsort_blk2_xrba = zsort_merge_wk_blk_len;
		zsort_blk2_xrba_end = zsort_blk2_xrba + zsort_merge_wk_blk_len;
		if (zsort_blk1_xrba_end > zsort_sortwk_len) {
			zsort_blk1_xrba_end = zsort_sortwk_len;
		}
		if (zsort_blk2_xrba > zsort_sortwk_len) {
			zsort_blk2_xrba_end = zsort_blk2_xrba;
		} else if (zsort_blk2_xrba_end > zsort_sortwk_len) {
			zsort_blk2_xrba_end = zsort_sortwk_len;
		}
	}

	/**
	 * Read next full or partial blk1 from current merge blk1_xrba to blk1_xrba_end.
	 */
	private void zsort_get_merge_blk1() {
		int mem_blk_len = zsort_blk1_ptr_end - zsort_blk1_addr;
		final int wk_blk_len = (int)(zsort_blk1_xrba_end - zsort_blk1_xrba);
		if (mem_blk_len > wk_blk_len) {
			mem_blk_len = wk_blk_len;
			if (mem_blk_len == 0) {
				zsort_blk1_ptr = zsort_blk1_addr;
				zsort_blk1_ptr_end = zsort_blk1_ptr;
				return;
			}
		}
		zsort_read_merge_blk(zsort_blk1_xrba,zsort_blk1_xrba_end,zsort_blk1_addr,zsort_blk1_addr + mem_blk_len);
		zsort_blk1_ptr_end = zsort_blk1_addr + mem_blk_len;
		zsort_blk1_ptr = zsort_blk1_addr;
		zsort_blk1_xrba = zsort_blk1_xrba + mem_blk_len;
	}

	/**
	 * Read next full or partial blk2 from current merge blk2_xrba to blk2_xrba_end.
	 */
	private void zsort_get_merge_blk2() {
		int mem_blk_len = zsort_blk2_ptr_end - zsort_blk2_addr;
		final int wk_blk_len = (int)(zsort_blk2_xrba_end - zsort_blk2_xrba);
		if (mem_blk_len > wk_blk_len) {
			mem_blk_len = wk_blk_len;
			if (mem_blk_len == 0) {
				zsort_blk2_ptr = zsort_blk2_addr;
				zsort_blk2_ptr_end = zsort_blk2_ptr;
				return;
			}
		}
		zsort_read_merge_blk(zsort_blk2_xrba,zsort_blk2_xrba_end,zsort_blk2_addr,zsort_blk2_addr + mem_blk_len);
		zsort_blk2_ptr_end = zsort_blk2_addr + mem_blk_len;
		zsort_blk2_ptr = zsort_blk2_addr;
		zsort_blk2_xrba = zsort_blk2_xrba + mem_blk_len;
	}

	/**
	 * Merge records from 2 blks into 1 output blk.
	 */
	private void zsort_merge_blk_rec() {
		if (zsort_blk1_ptr < zsort_blk1_ptr_end) {
			if (zsort_blk2_ptr < zsort_blk2_ptr_end) {
				if (zsort_comp(zsort_blk1_ptr, zsort_blk2_ptr)) {
					zsort_move_rec(zsort_blk2_ptr, zsort_blk3_ptr);
					zsort_blk2_ptr = zsort_blk2_ptr + zsort_lrecl;
					if (zsort_blk2_ptr >= zsort_blk2_ptr_end) {
						zsort_get_merge_blk2();
					}
				} else {
					zsort_move_rec(zsort_blk1_ptr, zsort_blk3_ptr);
					zsort_blk1_ptr = zsort_blk1_ptr + zsort_lrecl;
					if (zsort_blk1_ptr >= zsort_blk1_ptr_end) {
						zsort_get_merge_blk1();
					}
				}
				zsort_blk3_ptr = zsort_blk3_ptr + zsort_lrecl;
				if (zsort_blk3_ptr >= zsort_blk3_ptr_end) {
					zsort_write_merge_blk(zsort_blk3_addr, zsort_blk3_ptr_end);
					zsort_blk3_ptr = zsort_blk3_addr;
				}
			} else {
				// no more blk2 so flush blk3 and blk1
				if (zsort_blk3_ptr > zsort_blk3_addr) {
					zsort_write_merge_blk(zsort_blk3_addr, zsort_blk3_ptr);
					zsort_blk3_ptr = zsort_blk3_addr;
				}
				zsort_write_merge_blk(zsort_blk1_ptr, zsort_blk1_ptr_end);
				zsort_get_merge_blk1();
				while (zsort_read_len > 0) {
					zsort_write_merge_blk(zsort_blk1_addr, zsort_blk1_ptr_end);
					zsort_get_merge_blk1();
				}
			}
		} else {
			// no more blk1 so flush blk3 and blk2
			if (zsort_blk3_ptr > zsort_blk3_addr) {
				zsort_write_merge_blk(zsort_blk3_addr, zsort_blk3_ptr);
				zsort_blk3_ptr = zsort_blk3_addr;
			}
			zsort_write_merge_blk(zsort_blk2_ptr, zsort_blk2_ptr_end);
			zsort_get_merge_blk2();
			while (zsort_read_len > 0) {
				zsort_write_merge_blk(zsort_blk2_addr, zsort_blk2_ptr_end);
				zsort_get_merge_blk2();
			}
		}
	}

	/**
	 * Position to next merge blks in current pass.
	 */
	private void zsort_next_merge_blks() {
		if (zsort_blk1_xrba >= zsort_sortwk_len) {
			return;
		}
		zsort_blk1_ptr_end = zsort_blk1_addr + zsort_merge_mem_blk_len;
		zsort_blk2_ptr_end = zsort_blk2_addr + zsort_merge_mem_blk_len;
		zsort_blk1_xrba = zsort_blk1_xrba + zsort_merge_wk_blk_len;
		zsort_blk2_xrba = zsort_blk2_xrba + zsort_merge_wk_blk_len;
		zsort_blk1_xrba_end = zsort_blk1_xrba + zsort_merge_wk_blk_len;
		zsort_blk2_xrba_end = zsort_blk2_xrba + zsort_merge_wk_blk_len;
		if (zsort_blk1_xrba_end > zsort_sortwk_len) {
			zsort_blk1_xrba_end = zsort_sortwk_len;
		}
		if (zsort_blk2_xrba > zsort_sortwk_len) {
			zsort_blk2_xrba_end = zsort_blk2_xrba;
		} else if (zsort_blk2_xrba_end > zsort_sortwk_len) {
			zsort_blk2_xrba_end = zsort_sortwk_len;
		}
	}

	/**
	 * Reset ez390 trace options from string at R1 with trailing space.
	 */
	private void svc_systrace() {
		String systrace = "";
		byte option_byte = 0;
		char option_char = ' ';
		int string_addr = _pz390.reg.getInt(pz390.r1) & _pz390.psw_amode;
		while (string_addr < _pz390.tot_mem) {
			option_byte = _pz390.mem.get(string_addr);
			if (tz390.opt_ascii) {
				option_char = tz390.ascii_table.charAt(option_byte & 0xff);
			} else {
				option_char = tz390.ebcdic_table.charAt(option_byte & 0xff);
			}
			if (option_char == ' ') {
				tz390.set_trace_options(systrace);
				return;
			} else {
				systrace = systrace + option_char;
			}
			string_addr++;
		}
		log_error(126, "SYSTRACE space terminator not found.");
	}
}