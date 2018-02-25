import java.nio.charset.Charset;
import java.util.Iterator;
import java.util.Map;

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
public class test_unicode {
	/**
	 * Start instance of zCobol class.
	 * @param argv
	 */
	public static void main(final String argv[])
	{
		test_unicode pgm = new test_unicode();
		pgm.main();
	}

	public void main() {
		// System 390 EBCDIC
		final String encoding = "Cp1047";

		// Microsoft proprietary USA : encoding = "Cp037";
		// IBM PC OEM DOS		     : encoding = "Cp437";
		try {
			final String unicode = "1234567890abcdefghijklmnopqrstuvwxyz";
			final byte[] ebcdic = unicode.getBytes(encoding);
			final String reconsituted = new String(ebcdic, encoding);
			System.out.println( unicode );
			System.out.println( reconsituted );
			list_default_charset();
			list_available_charsets();
		} catch (final Exception e){
			System.out.println("test_unicode trap - " + e);
		}
	}

	/**
	 * Print default character set.
	 */
	private void list_default_charset()
	{
		String name = Charset.defaultCharset().name();
		System.out.println("default charset = " + name);
	}

	/**
	 * List all available character sets.
	 */
//	@SuppressWarnings("unchecked")
	private void list_available_charsets()
	{
		Map<String, Charset> map = Charset.availableCharsets();
		Iterator<String> it = map.keySet().iterator();
		while (it.hasNext()) {
			// Get character set name
			final String charsetName = (String)it.next();

			// Get character set
			final Charset charset = Charset.forName(charsetName);
			System.out.println(charset);
		}
	}
}
