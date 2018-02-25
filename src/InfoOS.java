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
 * Helper class to determine correct OS information.
 *
 * @author jba68/z390
 */
public class InfoOS {

	private static final InfoOS infoOS = new InfoOS();
	
	private final String java_vendor  = System.getProperty("java.vendor");
	private final String java_version = System.getProperty("java.version");
	private final String os_name      = System.getProperty("os.name");

	private enum z390_os_types { OS_UNKNOWN, OS_WINDOWS, OS_LINUX };

	private z390_os_types z390_os_type = z390_os_types.OS_UNKNOWN;
	private boolean bCorrectJava = false;

	// Windows and Linux variables
	private String z390_acrobat = System.getenv("Z390ACROBAT");
	private String z390_browser = System.getenv("Z390BROWSER");
	private String z390_command = System.getenv("Z390COMMAND");
	private String z390_editor  = System.getenv("Z390EDIT"); // RPI 510

	private InfoOS() {
		z390_os_type = init_os_type();
		bCorrectJava = init_java_version();
		init_os_util();
	}
	
	public static InfoOS getInstance() {
		return infoOS;
	}
	
	public boolean isWindows() {
		return (z390_os_type == z390_os_types.OS_WINDOWS);
	};

	public boolean isLinux() {
		return (z390_os_type == z390_os_types.OS_LINUX);
	};
	
	public boolean isCorrectJava() {
		return bCorrectJava;
	};

	public String get_z390_acrobat() {
		return z390_acrobat;
	}
	public String get_z390_browser() {
		return z390_browser;
	}
	public String get_z390_command() {
		return z390_command;
	}
	public String get_z390_editor() {
		return z390_editor;
	}

	public String getMessageIncorrectJavaVersion() {
		final String msg = "Unknown/incorrect Java version " + java_vendor + " " + java_version;
		return msg;
	}

	/**
	 * Initialize OS type out of the global os_name variable.
	 * @return
	 */
	private z390_os_types init_os_type() {
		if (os_name.substring(0,3).equals("Win")) {
			return z390_os_types.OS_WINDOWS;
		} else {
			return z390_os_types.OS_LINUX; 
		}
	}

	/**
	 * Verify Java version is from a known vendor and version is 1.6+.
	 * @return
	 */
	private boolean init_java_version() {
		if (   !java_vendor.equals("Oracle Corporation"   )
			&& !java_vendor.equals("Sun Microsystems Inc.")
			&& !java_vendor.equals("Apple Inc."           ) ) {
			return false;
		}	

		if (java_version.compareTo("1.6") < 0) {
			return false;
		}

		return true;
	}

	/**
	 * Initialize OS dependent utilities.<br>
	 * Note: We only know Windows and Linux!
	 */
	private void init_os_util() {
		if (isWindows()) {
			if (z390_browser == null || z390_browser.length() == 0) {
				z390_browser = "cmd.exe /c Start";
			}
			if (z390_acrobat == null || z390_acrobat.length() == 0) {
					z390_acrobat = z390_browser;
			}
			if (z390_command == null || z390_command.length() == 0) {
				if (os_name.equals("Windows 95") || os_name.equals("Windows 98")){
					z390_command = "command.com";
				} else {
					z390_command = "cmd.exe";
				}
			}
			if (z390_editor == null || z390_editor.length() == 0){
			    z390_editor  = "notepad.exe";
			}
			return;
		}
		
		if (isLinux()) {
			if (z390_browser == null || z390_browser.length() == 0){
				z390_browser = "firefox";
			}
			if (z390_acrobat == null || z390_acrobat.length() == 0){
				z390_acrobat = "acroread";
			}
			if  (z390_command == null || z390_command.length() == 0){
				z390_command = "perl";
			}
			if (z390_editor == null || z390_editor.length() == 0){
				z390_editor  = "gedit";
			}
			return;
		}
		
		// cannot happen :-)
	}
}