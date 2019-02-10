/**
 * Copyright 2019 Joachim Bartz, Germany
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

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.io.PrintWriter;

/**
 * This class will help us to get GNU diff files of the regression test directories.
 * <p>
 * To get standard GNU diff output we use slightly modified Diff.java and DiffPrint.java.
 * The logic is taken roughly from the linklib MLC files RTGENDIR, RTGENCMP, and RTGENDIF.
 * <p>
 * All actual/working files from directory A are compared to files saved in directory B.
 * The diff files can later be found in directory C. If there is no appropriate file in
 * directory B, a "missing" files is written to directory C.
 * <p>
 * For statistical reasons three values are counted:
 * <li>number of missing files
 * <li>number of files w/  diffs
 * <li>number of files w/o diffs
 *
 * @author jba68/z390
 */
public class DiffRegrTests {

	private static int nMissing = 0;
	private static int nHasDiff = 0;
	private static int nNoDiff  = 0;
	
	/**
	 * Create a "missing" file in diff directory with the given file name.
	 *
	 * @param fileC
	 * @return true, if missing file written - false otherwise
	 */
	private static boolean createMissingFile(final File fileC) {
		try {
			final FileWriter fr = new FileWriter(fileC, false);
			fr.write("MISSING MATCH FOR THIS FILE");
			fr.close();
			nMissing++;
		} catch (final IOException e) {
			System.err.println("Error writing missing diff file " + fileC.getName() + " - "+ e.toString());
			return false;
		}
		return true;
	}

	/**
	 * Create diff between fileA and file B and write diff to diff directory as fileC.
	 *
	 * @param fileA actual regression test file to be compared to fileB
	 * @param fileB saved regression test file to be compared to fileA
	 * @param fileC diff of fileA and fileB in "normal" diff format; none if no diffs found
	 * @return true, if diff file written - false otherwise
	 */
	private static boolean doDiff(final File fileA, final File fileB, final File fileC) {
		try {
			final String[] a = DiffPrint.slurp(fileA);
			final String[] b = DiffPrint.slurp(fileB);

			final Diff d = new Diff(a,b);
		//	d.heuristic = false;
			d.heuristic = true;

			final Diff.change script = d.diff_2(false);
			if (script != null) {
				nHasDiff++;
				final FileWriter     fr = new FileWriter(fileC, false);
				final BufferedWriter br = new BufferedWriter(fr);
				final PrintWriter    pr = new PrintWriter(br);

				final DiffPrint.Base p = new DiffPrint.NormalPrint(a,b);
				p.setOutput(pr);
				p.print_header(fileA.getAbsolutePath() ,fileB.getAbsolutePath());
				p.print_script(script);

				pr.close();
				br.close();
				fr.close();
			} else {
				nNoDiff++;
			}
		} catch (final IOException e) {
			System.err.println("Error writing missing diff file " + fileC.getName() + " - "+ e.toString());
			return false;
		}
		return true;
	}

	/**
	 * Compare all items of two given directories (file by file)
	 * and create diff output files in the third directory.
	 *
	 * @param args
	 */
	public static void main(final String[] args) {

		final StringBuilder sb1 = new StringBuilder();
		final StringBuilder sb2 = new StringBuilder();

		if (args.length < 3) {
			sb1.append("Not enough parameters to diff rt results.\n")
			   .append("  arg1 = directory with actual rt files\n")
			   .append("  arg2 = directory with saved  rt files\n")
			   .append("  arg3 = directory to store diff results\n");
		}

		final String sDirActual = args.length >= 1 ? args[0] : null;
		final String sDirSaved  = args.length >= 2 ? args[1] : null;
		final String sDirDiffs  = args.length >= 3 ? args[2] : null;

		// Check if sDirNew   exists
		if (sDirActual != null) {
			final File dActual = new File(sDirActual);
			if (!dActual.exists()) {
				dActual.mkdirs();
			}
			if (!dActual.exists()) {
				sb2.append("  arg1 = directory with actual rt results not found\n");
			}
			if (!dActual.isDirectory()) {
				sb2.append("  arg1 = directory with actual rt results is no directory\n");
			}
		}

		// Check if sDirSaved exists
		if (sDirSaved != null) {
			final File dSaved = new File(sDirSaved);
			if (!dSaved.exists()) {
				dSaved.mkdirs();
			}
			if (!dSaved.exists()) {
				sb2.append("  arg2 = directory with saved rt results not found\n");
			}
			if (!dSaved.isDirectory()) {
				sb2.append("  arg2 = directory with saved rt results is no directory\n");
			}
		}

		// Check if sDirDiffs exists
		if (sDirDiffs != null) {
			final File dDiffs = new File(sDirDiffs);
			if (!dDiffs.exists()) {
				dDiffs.mkdirs();
			}
			if (!dDiffs.exists()) {
				sb2.append("  arg3 = directory to store diff results not found\n");
			}
			if (!dDiffs.isDirectory()) {
				sb2.append("  arg3 = directory to store diff results is no directory\n");
			}
		}

		if (sb1.length() > 0 || sb2.length() > 0 ) {
			System.err.println(sb1.toString());
	
			if (sb2.length() > 0) {
				sb2.insert(0, "Error in parameter(s) to diff rt results:\n");
				System.err.println(sb2.toString());
			}
			return;
		}

		// Read in all files from the "new" directory
		final File[] filesActualArray = new File(sDirActual).listFiles();

		for (File fActual : filesActualArray) {
			boolean bOK = true;
			final String sActual = fActual.getName();

			// Target diff file
			final File fDiff  = new File(sDirDiffs + "/" + sActual);
			final File fSaved = new File(sDirSaved + "/" + sActual);

			// Check if there is a corresponding file in dirSaved
			if (fSaved.exists()) {
				// "Saved" file exists. Do diff compare now
				System.out.println("diff - act/" + sActual + " - saved/" + sActual);
				bOK = doDiff(fActual, fSaved, fDiff);
			} else {
				// No "saved" file. Write "Missing" file to dirDiffs...
				System.out.println("diff - act/" + sActual + " - (missing)");
				bOK = createMissingFile(fDiff);
			}
			if (!bOK) {
				break;
			}
		}

		// Create statistical files in diff directory:
		createStatisticFile(sDirDiffs, "RTDIF_TOTALS__%d.TXT", filesActualArray.length);
		createStatisticFile(sDirDiffs, "RTDIF_MATCHES_%d.TXT", nNoDiff);
		createStatisticFile(sDirDiffs, "RTDIF_DIFFS___%d.TXT", nHasDiff);
		createStatisticFile(sDirDiffs, "RTDIF_MISSING_%d.TXT", nMissing);
	}

	/**
	 * 
	 * @param sDirDiffs
	 * @param fileName
	 * @param n
	 */
	private static void createStatisticFile(final String sDirDiffs, final String fileName, final int n) {
		final String sFile = sDirDiffs + "/" + fileName.replace("%d", "" + n);
		try {
			final FileWriter fr = new FileWriter(sFile, false);
			fr.close();
		} catch (final IOException e) {
			System.err.println("Error writing statistic file " + sFile + " - "+ e.toString());
		}
	}
}
