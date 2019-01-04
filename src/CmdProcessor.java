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

import java.io.BufferedReader;
import java.io.PrintStream;
import java.util.LinkedList;

/**
 * Helper class containing command processor informations.
 *
 * @author jba68/z390
 */
public class CmdProcessor
{
	// Command processor variables.
	Process				cmd_proc			= null;
	Thread				cmd_proc_thread		= null;
	Thread				cmd_error_thread	= null;
	Thread				cmd_output_thread	= null;
	BufferedReader		cmd_error_reader	= null;	 // RPI-731
	BufferedReader		cmd_output_reader	= null;	 // RPI-731
	PrintStream			cmd_input_writer	= null;	 // RPI-731
	LinkedList<String>	cmd_output_queue	= null;
	boolean				cmd_proc_running	= false;
	boolean				cmd_proc_cmdlog		= false; // RPI-731
	int					cmd_proc_io			= 0;
	long				cmd_proc_start_time	= 0;	 // RPI-545
	String				cmd_error_msg		= "";
	String				cmd_output_msg		= "";
	String				cmd_read_line		= "";	 // RPI-731

	/**
	 * Standard constructor (empty at the moment).
	 */
	CmdProcessor()
	{
	}

	/**
	 * Return ending rc else -1.
	 * Return 0 if no process defined.
	 *
	 * @return
	 */
	public int cmd_proc_rc()
	{
		int rc = -1;
		if (cmd_proc_running) {
			try {
				rc = cmd_proc.exitValue();
			} catch (final Exception e) {
			}
		} else {
			rc = 0;
		}
		return rc;
	}

	/**
	 * Cancel an executing process.
	 */
	public void cmd_cancel()
	{
		cmd_proc_running = false;
	}
}
