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
 * Helper class offering the command history functionality.
 *
 * @author jba68/z390
 */
public class CmdHistory {

	private final static int max_cmd  = 100;

	/**
	 * Index of most recent command entered.
	 */
	private int cur_cmd;
	
	/**
	 * Index of highest command entered.
	 */
	private int end_cmd;

	/**
	 * Index of current command in view
	 */
	private int view_cmd;
	
	/**
	 * RPI 603
	 */
	private boolean view_restore;

	/**
	 * 
	 */
	private String[] cmd_history;

	/**
	 * 
	 */
	private String last_cmd_line; // RPI 506

	/**
	 * 
	 */
	CmdHistory()
	{
		cur_cmd = 0;
		end_cmd = 0;
		view_cmd = 0;
		view_restore = false; 
		cmd_history = new String[max_cmd];
		last_cmd_line = "x"; // RPI 506
		
		reset();
	}

	/**
	 * 
	 */
	public void reset()
	{
		cmd_history[0] = "";
	}

	/**
	 * Add command cmd_line to rolling history.
	 */
	public void add_cmd_hist(final String cmd_line)
	{
		if (last_cmd_line.equals(cmd_line)) {
			return;
		}

		last_cmd_line = cmd_line;
		cur_cmd++;
		if (cur_cmd < max_cmd && cur_cmd > end_cmd) {
			end_cmd = cur_cmd;
		}
		if (cur_cmd >= max_cmd) {
			cur_cmd = 0;
		}
		cmd_history[cur_cmd] = cmd_line;
		view_restore = true; // force cmd restore on next up/down
		view_cmd = cur_cmd;
	}

	/**
	 * Restore previous command to z390_cmd_line.
	 * @return
	 */
	public String get_prev_cmd()
	{
		if (view_restore) {
			view_restore = false;
		} else {
			view_cmd--; // RPI 603
			if  (view_cmd < 0) {
				view_cmd = end_cmd;
			}
		}
		// z390_cmd_line.setText(cmd_history[view_cmd]);
		return cmd_history[view_cmd];
	}

	/**
	 * Display next command.
	 * @return
	 */
	public String get_next_cmd()
	{
		view_restore = false;
		view_cmd++;  // RPI 603
		if  (view_cmd > end_cmd) {
			view_cmd = 0;
		}
		// z390_cmd_line.setText(cmd_history[view_cmd]);
		return cmd_history[view_cmd];
	}
}
