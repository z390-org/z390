import java.io.FilePermission;
import java.util.PropertyPermission;

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
 * Helper class offering permission information
 * (mainly for using z390 as Java Applet).
 *
 * @author jba68/z390
 */
public class Permissions {

	/**
	 * Do permission checks?
	 * Reset with /NP command line parameter
	 */
	private boolean check_perms;

	/**
	 * Set if user.dir is OK.
	 */
	private boolean perm_file_user_dir;

	/**
	 *   Set if read  is OK.
	 */
	private boolean perm_file_read;

	/**
	 * Set if write is OK.
	 */
	private boolean perm_file_write;

	/**
	 * Set if exec is OK.
	 */
	private boolean perm_file_execute;

	/**
	 * Set if pop-up file chooser is OK.
	 */
	private boolean perm_runtime_thread;

	/**
	 * Set if write log is OK.
	 */
	private boolean perm_file_log;

	/**
	 * Set if select directory/file is OK.
	 */
	private boolean perm_select;

	/**
	 * True, if read  is OK.
	 * @return
	 */
	public boolean mayReadFiles() { return perm_file_read; }

	/**
	 * True, if write is OK.
	 * @return
	 */
	public boolean mayWriteFiles() { return perm_file_write; }

	/**
	 * True, if execute is OK.
	 * @return
	 */
	public boolean mayExecFiles() { return perm_file_execute; }

	/**
	 * True, if write log is OK.
	 * @return
	 */
	public boolean mayLog2File()	{ return perm_file_log; }

	/**
	 * True, if select directory/file is OK.
	 * @return
	 */
	public boolean maySelect() { return perm_select; }

	/**
	 * True, if user.dir OK.
	 * @return
	 */
	public boolean isUserDirOK() { return perm_file_user_dir; }

	/**
	 * True, if pop-up file chooser OK.
	 * @return
	 */
	public boolean isRuntimeThread() { return perm_runtime_thread; }

	
	/**
	 * Class constructor.<br>
	 * Initialize check allowance to true and all other permissions to false.
	 */
	public Permissions() {
		setAllowChecks(true);
		allowAll(false);
	}

	/**
	 * Are permission checks generally allowed?
	 * @return
	 */
	public boolean getAllowChecks() { return check_perms; }
	
	/**
	 * Allow permission checks generally.
	 * @param bAllowChecks
	 */
	public void setAllowChecks(final boolean bAllowChecks) {
		check_perms = bAllowChecks; 
	}

	/**
	 * Set all permissions (User directory, File read/write/execute, and Thread) to the same value.
	 * @param bAllow
	 */
	private void allowAll(final boolean bAllow) {
		perm_file_user_dir  = bAllow;
		perm_file_read      = bAllow;
		perm_file_write     = bAllow;
		perm_file_execute   = bAllow;
		perm_runtime_thread = bAllow;

		calculateSpecials();
	}

	/**
	 * Calculate special permissions dependent from the 5 other permissions.
	 */
	private void calculateSpecials() {
		perm_file_log = perm_file_write && perm_file_user_dir;
		perm_select   = perm_file_read  && perm_file_user_dir && perm_runtime_thread;
		
		if (!perm_file_log) {
			perm_file_write = false;
		}
	}
	
	/**
	 * Check for security manager and set permissions got from the security manager.
	 */
	public void doChecks() {
		if (!check_perms) {
			allowAll(false);
			return;
		}

		final SecurityManager sm = System.getSecurityManager();
		if (sm == null) {
			allowAll(true);
			return;
		}

		final FilePermission     perm_read     = new FilePermission("/*","read");
		final FilePermission     perm_write    = new FilePermission("/*","write");
		final FilePermission     perm_execute  = new FilePermission("/*","execute");
		final PropertyPermission perm_user_dir = new PropertyPermission("user.dir","read,write");
		final RuntimePermission  perm_thread   = new RuntimePermission("modifyThread");

		try {
			sm.checkPermission(perm_thread);
			perm_runtime_thread = true;
		} catch (final SecurityException e) {
			perm_runtime_thread = false;
		}
		try {
			sm.checkPermission(perm_execute);
			perm_file_execute = true;
		} catch (final SecurityException e) {
			perm_file_execute = false;
		}
		try {
			sm.checkPermission(perm_user_dir);
			perm_file_user_dir = true;
		} catch (final SecurityException e) {
			perm_file_user_dir = false;
		}
		try {
			sm.checkPermission(perm_read);
			perm_file_read = true;
		} catch (final SecurityException e) {
			perm_file_read = false;
		}
		try {
			sm.checkPermission(perm_write);
			perm_file_write = true;
		} catch (final SecurityException e) {
			perm_file_write = false;
		}
		calculateSpecials();
	}
}
