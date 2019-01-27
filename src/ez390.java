import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.text.SimpleDateFormat;
import java.util.Date;

import javax.swing.JTextArea;
import javax.swing.JTextField;
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
 * ez390 is the emulator component of z390<br>
 * which can be called from z390 GUI interface or from command line<br>
 * to execute 390 load module files.
 */
public class ez390 implements Runnable
{
	private final static String msg_id_i = "EZ390I ";
	private final static String msg_id_e = "EZ390E ";

	// Shared global variables
	private tz390  _tz390 = null;
	private pz390  _pz390 = null;
	private sz390  _sz390 = null;
	private vz390  _vz390 = null; // RPI 644
	private Thread  pz390_thread = null;
	private boolean pz390_running = false;
//	private String load_file_name = null;
//	private boolean exit_request = false;

	// Monitor variables
//	private int    ins_count = 0;
	private int    io_count  = 0;
	private Timer  monitor_timer = null;
	private long   monitor_cmd_time_total = 0;
//	private long   monitor_last_time = 0;
	private long   monitor_next_time = 0;
//	private long   monitor_cur_interval = 0;
//	private int    monitor_last_ins_count = 0;
//	private int    monitor_next_ins_count = 0;
//	private int    monitor_last_io_count = 0;
//	private int    monitor_next_io_count = 0;
//	private long   monitor_cur_ins  = 0;
//	private long   monitor_cur_int  = 0;
//	private long   monitor_cur_rate = 0;
	private String cmd_read_line = null;

	// Time and date variables
	private final static SimpleDateFormat cur_date_MMddyy   = new SimpleDateFormat("MM/dd/yy");
	private final static SimpleDateFormat cur_tod_hhmmss    = new SimpleDateFormat("HH:mm:ss");
//	private final static SimpleDateFormat cur_tod_hhmmss00  = new SimpleDateFormat("HHmmss00");
//	private final static SimpleDateFormat cur_date_yyyy     = new SimpleDateFormat("yyyy");
//	private final static SimpleDateFormat cur_date_MM       = new SimpleDateFormat("MM");
//	private final static SimpleDateFormat cur_date_dd       = new SimpleDateFormat("dd");
//	private final static SimpleDateFormat cur_date_HH       = new SimpleDateFormat("HH");
//	private final static SimpleDateFormat cur_date_mm       = new SimpleDateFormat("mm");
//	private final static SimpleDateFormat cur_date_ss       = new SimpleDateFormat("ss");
//	private final static SimpleDateFormat cur_date_ms       = new SimpleDateFormat("SSS");
//	private final static SimpleDateFormat cur_date_yyddd    = new SimpleDateFormat("yyDDD");
//	private final static SimpleDateFormat cur_date_yyyyddd  = new SimpleDateFormat("yyyyDDD");
//	private final static SimpleDateFormat cur_date_MMddyyyy = new SimpleDateFormat("MMddyyyy");
//	private final static SimpleDateFormat cur_date_ddMMyyyy = new SimpleDateFormat("ddMMyyyy");
//	private final static SimpleDateFormat cur_date_yyyyMMdd = new SimpleDateFormat("yyyyMMdd");

//	private int  cur_date_year  = 0;
//	private int  cur_date_month = 0;
//	private int  cur_date_day   = 0;
//	private int  tod_hour  = 0;
//	private int  tod_min   = 0;
//	private int  tod_sec   = 0;
//	private int  tod_msec  = 0;  // 0-999 fraction of sec
//	private long time_mil   = 0;  // milli-seconds
//	private Calendar cur_date_cal = null;
//	private long tod_start_day = 0;
//	private long tod_start_pgm = 0;
//	private long tod_end_pgm   = 0;
//	private long tot_sec = 0;
//	private long tod_time_limit = 0;
//	private int  next_time_ins   = 0x1000;
//	private int  next_time_check = next_time_ins;
//	private boolean log_tod = true;
	private JTextArea z390_log_text = null;
//	private JTextField  z390_command_text = null;

	/**
	 * main is the entry point when executed from command line<br>
	 * Create instance of ez390 class and pass parameters to ez390 like z390 does.
	 *
	 * @param args
	 */
	public static void main(final String[] args)
	{
		final ez390 pgm = new ez390();
		pgm.process_ez390(args,null,null);
	}

	/**
	 * Execute 390 load module file passed as first argument(s).<br>
	 *
	 * Note this may be called directly from z390 GUI or from main when lz370 run from windows command line.
	 * If called from main, the JTextAreas log_text will be null and local put_log function will route to
	 * console instead of the z390 log window.
	 * @param args
	 * @param log_text
	 * @param command_text
	 */
	public void process_ez390(final String[] args, final JTextArea log_text, final JTextField cmd_text)
	{
		init_ez390(args, log_text, cmd_text);
		if (_tz390.opt_ipl.length() > 0) {
			run_pgm(pz390.zcvt_ipl_pgm);
			_sz390.ez390_pgm = null;
			_sz390.tot_link_stk = 0;
		}
		run_pgm(pz390.zcvt_user_pgm);
		monitor_timer.stop(); // RPI 782
		_sz390.exit_ez390();
	}

	/**
	 * Execute IPL pgm and/or application pgm.
	 *
	 * @param zcvt_pgm_addr
	 */
	private void run_pgm(final int zcvt_pgm_addr)
	{
		_pz390.reg.putInt(pz390.r13, pz390.zcvt_save);
		_pz390.reg.putInt(pz390.r14, pz390.zcvt_exit);
		_pz390.reg.putInt(pz390.r15, 0); // RPI 819
		_pz390.reg.putInt(pz390.r0,  zcvt_pgm_addr);
		_pz390.reg.putInt(pz390.r1,  pz390.zcvt_exec_parma);			// RPI-582
		_pz390.mem.putInt(pz390.zcvt_exec_parma, pz390.zcvt_exec_parm);	// RPI-582
		_sz390.svc_link();
		if (_tz390.opt_trap) {
			_pz390.psw_check = false;
			while (    !_tz390.z390_abort
					&& !_pz390.psw_check ) {
				try {
					exec_pz390();
				} catch (final Exception e) {
					_pz390.set_psw_check(Constants.psw_pic_addr);
					_pz390.psw_check = false; // retry if no abandon
				}
			}
		} else {
			exec_pz390(); // no trap - no exception handling
		}
		if (_pz390.psw_check && _pz390.psw_pic != Constants.psw_pic_exit) {
			_sz390.svc_abend(_pz390.psw_pic,_sz390.svc_abend_type,_sz390.svc_req_dump);
		}
	}

	/**
	 * <ol><li>Check for trace msg and log if found
	 *     <li>Execute test commands if test mode
	 *     <li>Dump registers if reqister trace option
	 *     <li>Run pz390 to next interrupt
	 *     <li>Check for trace msg and log if found
	 *     <li>If svc interrupt, exec svc
	 *     <li>else if psw_check<br>
	 *         if svc_exit exit normally<br>
	 *         else psw_handler for abend<br>
	 *         or espie/estae restart
	 */
	private void exec_pz390()
	{
		pz390_thread = new Thread(this);
		pz390_running = true;
		pz390_thread.start();
		try {
			if (_tz390.opt_guam) {
				while (!_tz390.z390_abort && pz390_running) {
					_tz390.sleep_now(_tz390.monitor_wait);  // RPI 218
				}
			} else {
				pz390_thread.join(); // faster with no spurious interrupts
			}
		} catch (final Exception e) {
			_sz390.abort_error(202,"pz390 processor error " + e.toString());
		}
	}

	/**
	 * Initialize ez390 module.
	 * <ol><li>Initialize log routing.
	 *     <li>Initialize ASCII to EBCDIC table.
	 *     <li>Initialize regular expression parser for test.
	 *     <li>Set options.
	 *     <li>Initialize memory.
	 *     <li>Set runtime hooks for cancellation.
	 *     <li>Start monitor for command processor and timeout, and CPU rate statistics.</ol>
	 *
	 * @param args
	 * @param log_text
	 * @param cmd_text
	 */
	private void init_ez390(final String[] args, final JTextArea log_text, final JTextField cmd_text)
	{
		if (log_text != null) {
			z390_log_text = log_text;
		}
		_tz390 = new tz390();
		_pz390 = new pz390();
		_sz390 = new sz390();
		_vz390 = new vz390();
		_tz390.init_tz390();

		final InfoOS infoOS = InfoOS.getInstance();
		if (!infoOS.isCorrectJava()) {
			_sz390.abort_error(204, infoOS.getMessageIncorrectJavaVersion());
		}
		_tz390.init_options(args, _tz390.z390_type);
		_tz390.open_systerm("EZ390");
		_tz390.init_codepage(_tz390.codepage); // RPI-1069
		_vz390.init_vz390(_tz390, _pz390, _sz390);
		_sz390.init_sz390(_tz390, _pz390, _vz390);
		_sz390.open_files(); // RPI-357 RPI-812 Moved before init_pz390.
		_pz390.init_pz390(_tz390, _sz390);
		_tz390.force_nocon = true;
		_sz390.put_log(_tz390.started_msg); // RPI-755
		_tz390.force_nocon = false; // RPI-1050 moved after trace
		_sz390.init_time();
		_sz390.init_test();
		put_copyright();
		monitor_startup();
		_sz390.ez390_startup = false;
	}

	/**
	 * Start monitor to terminate cmd command if timeout limit reached.
	 */
	private void monitor_startup()
	{
		try {
			ActionListener cmd_listener = new ActionListener() {
				public void actionPerformed(final ActionEvent evt) {
					monitor_update();
				}
			};
			monitor_timer = new Timer(_tz390.monitor_wait,cmd_listener);
			monitor_timer.start();
		} catch (final Exception e) {
			_sz390.log_error(66, "Execution startup error " + e.toString());
		}
	}

	/**
	 * Update monitor details.
	 */
	private void monitor_update()
	{
		/*
		 * 1. At monitor_wait intervals, update the the CPU instruction rate and monitor cmd processes if running with timeout
		 * 2. If CMD running and monitor_wait_total > timeout_interval then abort cmd process with timeout
		 * 3. Terminate, if current time beyond timeout.
		 * 4. If WTOR pending, check for reply and post ecb.
		 * 5. If stimer_exit_addr set, check for stimer_Exit_tod passed and take exit if tod passed:
		 *     a. Save r13-r15 and PSW for restore at end of exit
		 *     b. Set r13 to save, r14 to svc 3 instr, and r15 to exit
		 *     c. Set stimer_exit_pending for svc 3
		 *     d. change PSW to r15 exit addr
		 * 6. If GUAM TN3270 screen active, process pending typed keys
		 */

		monitor_next_time = System.currentTimeMillis();

		if (_tz390.opt_timing) {
			_pz390.cur_date = new Date();
			if (_tz390.opt_time
					&& !_pz390.psw_check
					&& monitor_next_time > _sz390.tod_time_limit) { // RPI-837
				while (pz390_running) {
					_tz390.timeout   = true; // RPI-1054 Request pz390 to abandon, RPI-1094 moved
					_pz390.psw_check = true; // RPI-1054
					if (_tz390.opt_guam) {   // RPI-1094
						System.out.println("GUAM GUI window closed due to timeout");
						System.exit(16);
					}
					Thread.yield(); // RPI-1040 Wait to end execution before dump.
				}
			}
		}

		int cmd_id = 0;
		while (cmd_id < _sz390.tot_cmd) {
			if ((_sz390.cmd_processors[cmd_id].cmd_proc_running)
			  && _sz390.cmd_processors[cmd_id].cmd_proc_rc() != -1) {
				_sz390.put_log( "*** " + cur_date_MMddyy.format(_pz390.cur_date)
								+ " "  + cur_tod_hhmmss.format( _pz390.cur_date)
								+ " CMD task ended TOT SEC=" + monitor_cmd_time_total
								+ " TOT LOG IO=" + io_count);
				_sz390.cmd_processors[cmd_id].cmd_proc_running = false;
			} else if (_tz390.opt_time && _tz390.max_time_seconds > 0) {
				if (_sz390.cmd_processors[cmd_id].cmd_proc_running
				 && _sz390.cmd_processors[cmd_id].cmd_proc_rc() == -1) {
					if  (monitor_cmd_time_total > _tz390.max_time_seconds) {
						_sz390.cmd_processors[cmd_id].cmd_cancel();
						_sz390.log_error(75, "CMD command timeout error " + monitor_cmd_time_total + " > " + _tz390.max_time_seconds);
					}
				}
			} else {
				if ((  _sz390.cmd_processors[cmd_id].cmd_proc_cmdlog // RPI-731
					|| _tz390.max_cmd_queue_exceeded) // RPI-731
					&& _sz390.cmd_processors[cmd_id].cmd_proc_running
					&& _sz390.cmd_processors[cmd_id].cmd_proc_rc() == -1) {
					cmd_read_line = _sz390.cmd_get_queue(cmd_id);
					while (cmd_read_line != null) {
						_sz390.put_log("CMDLOG ID=" + cmd_id + " MSG=" + cmd_read_line);
						cmd_read_line = _sz390.cmd_get_queue(cmd_id);
					}
				}
			}
			cmd_id++;
		}
		if (_sz390.wtor_reply_pending) {
			if (_tz390.opt_guam) {
				_sz390.wtor_reply_string = _sz390.gz390.get_wtor_reply_string(_sz390.wtor_ecb_addr);
			} else
			if (_tz390.opt_test && _sz390.test_cmd_file != null) {
				try {
					_sz390.wtor_reply_string = _sz390.test_cmd_file.readLine();
				} catch (final Exception e) {
					_sz390.log_error(93, "wtor reply I/O error - " + e.toString());
				}
			} else {  // RPI 595
				try {
					if (_sz390.wtor_reply_buff == null) {
						_sz390.wtor_reply_buff = new BufferedReader(new InputStreamReader(System.in));
					}
					if (_pz390.mem.getInt(_sz390.wtor_ecb_addr) == sz390.ecb_waiting
						|| _sz390.wtor_reply_buff.ready()) {
						_sz390.wtor_reply_string = _sz390.wtor_reply_buff.readLine();
					}
				} catch (final Exception e) {
					_sz390.log_error(93, "wtor reply I/O error - " + e.toString());
				}
			}
			if (_sz390.wtor_reply_string != null) {
				_sz390.put_log("" + _sz390.wtor_reply_string);  // RPI-190 Remove "WTOR REPLY MSG".
				_sz390.put_ascii_string(_sz390.wtor_reply_string,_sz390.wtor_reply_addr,_sz390.wtor_reply_len,' ');
				_sz390._pz390.mem.putInt(_sz390.wtor_ecb_addr,sz390.ecb_posted); // Post ECB for any wait.
				_sz390.wtor_reply_pending = false;
			}
		}
		if (!_sz390.stimer_exit_running
			&& _sz390.stimer_exit_addr != 0
			&& _sz390.stimer_exit_time <= monitor_next_time) {
			_sz390.stimer_exit_request = true; // request exit
		}
		if (_tz390.z390_abort) { // RPI-220 Shut down due to external request.
			_sz390.abort_error(203, msg_id_e + "monitor external shutdown request");
		}
	}

	/**
	 *
	 */
	public void run()
	{
		if (pz390_thread == Thread.currentThread()) {
			if (_tz390.opt_trap) { // RPI-423
				try {
					_pz390.exec_pz390();
				} catch (final Exception e) {
					_sz390.svc_abend(Constants.psw_pic_addr,_sz390.system_abend,_tz390.opt_dump); // RPI-536 // RPI-1054
				}
			} else {
				_pz390.exec_pz390();
			}
			pz390_running = false;
			return;
		}

		int cmd_id = 0;
		while (cmd_id < _sz390.tot_cmd) {
			if (_sz390.cmd_processors[cmd_id].cmd_proc_thread == Thread.currentThread()) {
				io_count++;
				_sz390.cmd_processors[cmd_id].cmd_proc_io++;
				try {
					_sz390.cmd_processors[cmd_id].cmd_proc.waitFor();
				} catch (final Exception e) {
					_sz390.abort_error(201,"cmd proc wait error " + e.toString());
				}
				return;
			} else
			if (_sz390.cmd_processors[cmd_id].cmd_output_thread == Thread.currentThread()) {
				_sz390.copy_cmd_output_to_queue(cmd_id);
				return;
			} else
			if (_sz390.cmd_processors[cmd_id].cmd_error_thread == Thread.currentThread()) {
				_sz390.copy_cmd_error_to_queue(cmd_id);
				return;
			}
			cmd_id++;
		}
	}

	/**
	 * Display ez390 version, time-stamp, and copyright if running stand-alone.
	 */
	private void put_copyright()
	{
		_tz390.force_nocon = true;  // RPI-755

		if  (z390_log_text == null) {
			_sz390.put_log(msg_id_i + Constants.sCopyright2011);
			_sz390.put_log(msg_id_i + Constants.sCopyright2013);
			_sz390.put_log(msg_id_i + Constants.sCopyright2018);
			_sz390.put_log(msg_id_i + Constants.sGnuLicence);
		}
		_sz390.put_log(msg_id_i + "program = " + _tz390.dir_mlc + _tz390.pgm_name + _tz390.pgm_type);
		_sz390.put_log(msg_id_i + "options = " + _tz390.cmd_parms);

		if (_tz390.opt_stats) {
			_tz390.put_stat_line(Constants.sCopyright2011);
			_tz390.put_stat_line(Constants.sCopyright2013);
			_tz390.put_stat_line(Constants.sCopyright2018);
			_tz390.put_stat_line(Constants.sGnuLicence);
			_tz390.put_stat_line("program = " + _tz390.dir_mlc + _tz390.pgm_name + _tz390.pgm_type);
			_tz390.put_stat_line("options = " + _tz390.cmd_parms);
		}
		_tz390.force_nocon = false; // RPI 755
	}
}
