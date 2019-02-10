/*
 * $Log: DiffPrint.java,v $
 * Revision 1.12  2013/04/01 16:27:31  stuart
 * Fix DiffPrint unified format with test cases.
 * Begin porting some diff-2.7 features.
 *
 * Revision 1.11  2013/02/26 21:07:08  stuart
 * Release 1.4
 *
 * Revision 1.10  2009/04/20 18:53:29  stuart
 * Make print_header public.
 *
 * Revision 1.9  2009/01/19 03:05:26  stuart
 * Fix StackOverflow bug with heuristic on reported by Jimmy Han.
 *
 * Revision 1.8  2007/12/20 05:04:21  stuart
 * Can no longer import from default package.
 *
 * Revision 1.7  2007/12/20 04:29:53  stuart
 * Fix setupOutput permission.  Thanks to Sargon Benjamin
 *
 * Revision 1.6  2005/04/27 02:13:40  stuart
 * Add Str.dup()
 *
 * Revision 1.5  2004/01/29 02:35:35  stuart
 * Test for out of bounds exception in UnifiedPrint.print_hunk.
 * Add setOutput() to DiffPrint.Base.
 *
 * Revision 1.4  2003/04/22  01:50:47  stuart
 * add Unified format diff
 *
 * Revision 1.3  2003/04/22  01:00:32  stuart
 * added context diff format
 *
 * Revision 1.2  2000/03/02  16:59:54  stuart
 * add GPL
 *
 */

import java.io.*;
import java.util.*;

interface UnaryPredicate {
	boolean execute(Object obj);
}

/**
 * A simple framework for printing change lists produced by <code>Diff</code>.
 *
 * @see Diff
 * @author Stuart D. Gathman
 * Copyright (C) 2000 Business Management Systems, Inc.
 * <p>
 * This program is free software; you can redistribute it and/or modify it under the terms of the
 * GNU General Public License as published by the Free Software Foundation; either version 1, or
 * (at your option) any later version.
 * <p>
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without
 * even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 * See the GNU General Public License for more details.
 * <p>
 * You should have received a copy of the GNU General Public License along with this program; if not,
 * write to the Free Software Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 */
public class DiffPrint {
	static boolean debug = false;

	/**
	 * A Base class for printing edit scripts produced by Diff.
	 * This class divides the change list into "hunks", and calls <code>print_hunk</code> for each hunk.
	 * Various utility methods are provided as well.
	 */
	public static abstract class Base {

		protected PrintWriter outfile;

		public void setOutput(final Writer wtr) {
			outfile = new PrintWriter(wtr);
		}
		protected void setupOutput() {
			if (outfile == null)
				outfile = new PrintWriter(new OutputStreamWriter(System.out));
		}
		protected Base(final Object[] a, final Object[] b) {
			file0 = a;
			file1 = b;
		}
		/**
		 * Set to ignore certain kinds of lines when printing an edit script.
		 * For example, ignoring blank lines or comments.
		 */
		protected UnaryPredicate ignore = null;

		/** Set to the lines of the files being compared.*/
		protected Object[] file0, file1;

		/**
		 * Divide SCRIPT into pieces by calling HUNKFUN and print each piece with PRINTFUN.
		 * Both functions take one argument, an edit script.
		 *
		 * PRINTFUN takes a subscript which belongs together (with a null link at the end)
		 * and prints it.
		 */
		public void print_script(final Diff.change script) {
			setupOutput();
			Diff.change next = script;

			while (next != null) {
				Diff.change t, end;

				// Find a set of changes that belong together.
				t = next;
				end = find_hunk(next);

				/* Disconnect them from the rest of the changes, making them a hunk, and
				 * remember the rest for next iteration. */
				next = end.link;
				end.link = null;

				// Print this hunk.
				print_hunk(t);

				// Reconnect the script so it will all be freed properly.
				end.link = next;
			}
			outfile.flush();
		}

		/**
		 * Called with the tail of the script and returns the last link that belongs together
		 * with the start of the tail.
		 */
		protected Diff.change find_hunk(final Diff.change hunk) {
			return hunk;
		}

		protected int first0, last0, first1, last1, deletes, inserts;

		protected List<String> function_regexp_list = new ArrayList<String>();

		/**
		 * Look at a hunk of edit script and report the range of lines in each file that it applies to.
		 * HUNK is the start of the hunk, which is a chain of 'struct change'.
		 * The first and last line numbers of file 0 are stored in *FIRST0 and *LAST0, and likewise for
		 * file 1 in *FIRST1 and *LAST1.
		 * Note that these are internal line numbers that count from 0.
		 *
		 * If no lines from file 0 are deleted, then FIRST0 is LAST0+1.
		 *
		 * Also set *DELETES nonzero if any lines of file 0 are deleted and set *INSERTS nonzero if any
		 * lines of file 1 are inserted. If only ignorable lines are inserted or deleted, both are set to 0.
		 */
		protected void analyze_hunk (final Diff.change hunk) {
			int l0 = 0, l1 = 0, show_from, show_to;
			int i;
			boolean trivial = (ignore != null);
			Diff.change next;

			show_from = show_to = 0;

			first0 = hunk.line0;
			first1 = hunk.line1;

			for (next = hunk; next != null; next = next.link) {
				l0 = next.line0 + next.deleted - 1;
				l1 = next.line1 + next.inserted - 1;
				show_from += next.deleted;
				show_to += next.inserted;

				for (i = next.line0; i <= l0 && trivial; i++)
					if (!ignore.execute(file0[i]))
						trivial = false;
				for (i = next.line1; i <= l1 && trivial; i++)
					if (!ignore.execute(file1[i]))
						trivial = false;
			}

			last0 = l0;
			last1 = l1;

			// If all inserted or deleted lines are ignorable, tell the caller to ignore this hunk.
			if (trivial)
				show_from = show_to = 0;

			deletes = show_from;
			inserts = show_to;
		}

		/**
		 * Called to print the script header which identifies the files compared.
		 * The default does nothing (except set output to system.out if not otherwise set).
		 * Derived style classes can override to print the files compared in the format for that style.
		 */
		public void print_header(final String filea, final String fileb) {
			setupOutput();
		}

		protected abstract void print_hunk(final Diff.change hunk);

		protected void print_1_line(final String pre, final Object linbuf) {
			outfile.println(pre + linbuf.toString());
		}

		/**
		 * Print a pair of line numbers with SEPCHAR, translated for file FILE.
		 * If the two numbers are identical, print just one number.
		 *
		 * Arguments A and B are internal line numbers.
		 * We print the translated (real) line numbers.
		 * */
		protected void print_number_range (final char sepchar, int a, int b) {
			// Note: we can have B < A in the case of a range of no lines.
			// In this case, we should print the line number before the range, which is B.
			if (++b > ++a)
				outfile.print("" + a + sepchar + b);
			else
				outfile.print(b);
		}

		public static char change_letter(final int inserts, final int deletes) {
			if (inserts == 0)
				return 'd';
			else if (deletes == 0)
				return 'a';
			else
				return 'c';
		}
	}

	/** Print a change list in the standard diff format. */
	public static class NormalPrint extends Base {

		public NormalPrint(final Object[] a, final Object[] b) {
			super(a,b);
		}

		/**
		 * Print a hunk of a normal diff.
		 * This is a contiguous portion of a complete edit script, describing changes in consecutive lines.
		 */
		protected void print_hunk(final Diff.change hunk) {
			// Determine range of line numbers involved in each file.
			analyze_hunk(hunk);
			if (deletes == 0 && inserts == 0)
				return;

			// Print out the line number header for this hunk
			print_number_range (',', first0, last0);
			outfile.print(change_letter(inserts, deletes));
			print_number_range (',', first1, last1);
			outfile.println();

			// Print the lines that the first file has.
			if (deletes != 0)
				for (int i = first0; i <= last0; i++)
					print_1_line ("< ", file0[i]);

			if (inserts != 0 && deletes != 0)
				outfile.println("---");

			// Print the lines that the second file has.
			if (inserts != 0)
				for (int i = first1; i <= last1; i++)
					print_1_line ("> ", file1[i]);
		}
	}

//	/** Prints an edit script in a format suitable for input to <code>ed</code>.
//	 * The edit script must be generated with the reverse option to be useful as actual <code>ed</code> input.
//	 */
//	public static class EdPrint extends Base {
//
//		public EdPrint(final Object[] a, final Object[] b) {
//			super(a,b);
//		}
//
//		/** Print a hunk of an ed diff */
//		protected void print_hunk(final Diff.change hunk) {
//
//			// Determine range of line numbers involved in each file.
//			analyze_hunk (hunk);
//			if (deletes == 0 && inserts == 0)
//				return;
//
//			// Print out the line number header for this hunk
//			print_number_range (',', first0, last0);
//			outfile.println(change_letter(inserts, deletes));
//
//			// Print new/changed lines from second file, if needed
//			if (inserts != 0) {
//				boolean inserting = true;
//				for (int i = first1; i <= last1; i++) {
//					// Resume the insert, if we stopped.
//					if (! inserting)
//						outfile.println(i - first1 + first0 + "a");
//					inserting = true;
//
//					// If the file's line is just a dot, it would confuse `ed'.
//					// So output it with a double dot, and set the flag LEADING_DOT so that we will output
//					// another ed-command later to change the double dot into a single dot.
//					if (".".equals(file1[i])) {
//						outfile.println("..");
//						outfile.println(".");
//						// Now change that double dot to the desired single dot.
//						outfile.println(i - first1 + first0 + 1 + "s/^\\.\\././");
//						inserting = false;
//					} else {
//						// Line is not `.', so output it unmodified.
//						print_1_line ("", file1[i]);
//					}
//				}
//
//				// End insert mode, if we are still in it.
//				if (inserting)
//					outfile.println(".");
//			}
//		}
//	}

//	/**
//	 * Prints an edit script in context diff format.
//	 * This and its 'unified' variation is used for source code patches.
//	 */
//	public static class ContextPrint extends Base {
//
//		protected int context = 3;
//		/** Set to '\t' for tab align. */
//		protected char tab_align_flag = ' ';
//
//		public ContextPrint(final Object[] a, final Object[] b) {
//			super(a,b);
//		}
//
//		/**
//		 * Scan a (forward-ordered) edit script for the first place that more than 2*CONTEXT
//		 * unchanged lines appear, and return a pointer to the 'struct change' for the last
//		 * change before those lines.
//		 */
//		protected Diff.change find_hunk(Diff.change start) {
//			Diff.change prev;
//			int thresh,top0,top1;
//
//			do {
//				// Compute number of first line in each file beyond this changed.
//				top0 = start.line0 + start.deleted;
//				top1 = start.line1 + start.inserted;
//				prev = start;
//				start = start.link;
//				// Threshold distance is 2*CONTEXT between two non-ignorable changes,
//				// but only CONTEXT if one is ignorable.  */
//				thresh = ((prev.ignore || (start != null && start.ignore)) ? context : 2 * context + 1);
//				// It is not supposed to matter which file we check in the end-test.
//				// If it would matter, crash.
//				assert start == null || start.line0 - top0 == start.line1 - top1;
//			} while (start != null
//				// Keep going if less than THRESH lines elapse before the affected line.
//				&& start.line0 < top0 + thresh);
//
//			return prev;
//		}
//
//		protected void print_context_label(final String mark, final File inf, final String label) {
//			setupOutput();
//			if (label != null)
//				outfile.println(mark + ' ' + label);
//			else if (inf.lastModified() > 0)
//				// FIXME: use DateFormat to get precise format needed.
//				outfile.println(mark + ' ' + inf.getPath() + '\t' + new Date(inf.lastModified()));
//			else
//				// Don't pretend that standard input is ancient.
//				outfile.println(mark + ' ' + inf.getPath());
//		}
//
//		public void print_header(final String filea, final String fileb) {
//			print_context_label("***", new File(filea), filea);
//			print_context_label("---", new File(fileb), fileb);
//		}
//
//		/** If function_regexp defined, search for start of function. */
//		protected String find_function(final Object[] lines, final int start) {
//			return null;
//		}
//
//		protected void print_function(final Object[] file, final int start) {
//			final String function = find_function (file0, first0);
//			if (function != null) {
//				outfile.print(" ");
//				outfile.print((function.length() < 40) ? function : function.substring(0,40));
//			}
//		}
//
//		protected void print_hunk(final Diff.change hunk) {
//
//			// Determine range of line numbers involved in each file.
//			analyze_hunk(hunk);
//
//			if (deletes == 0 && inserts == 0)
//				return;
//
//			// Include a context's width before and after.
//			first0 = Math.max(first0 - context, 0);
//			first1 = Math.max(first1 - context, 0);
//			last0  = Math.min(last0 + context, file0.length - 1);
//			last1  = Math.min(last1 + context, file1.length - 1);
//
//			outfile.print("***************");
//
//			// If we looked for and found a function this is part of, include its name in the
//			// header of the diff section.
//			print_function(file0, first0);
//
//			outfile.println();
//			outfile.print("*** ");
//			print_number_range (',', first0, last0);
//			outfile.println(" ****");
//
//			if (deletes != 0) {
//				Diff.change next = hunk;
//
//				for (int i = first0; i <= last0; i++) {
//					// Skip past changes that apply (in file 0) only to lines before line I.
//					while (next != null && next.line0 + next.deleted <= i)
//						next = next.link;
//
//					// Compute the marking for line I.
//					String prefix = " ";
//					if (next != null && next.line0 <= i)
//						// The change NEXT covers this line.
//						// If lines were inserted here in file 1, this is "changed".
//						// Otherwise it is "deleted".
//						prefix = (next.inserted > 0) ? "!" : "-";
//					print_1_line (prefix, file0[i]);
//				}
//			}
//
//			outfile.print("--- ");
//			print_number_range (',', first1, last1);
//			outfile.println(" ----");
//
//			if (inserts != 0) {
//				Diff.change next = hunk;
//
//				for (int i = first1; i <= last1; i++) {
//					// Skip past changes that apply (in file 1) only to lines before line I.
//					while (next != null && next.line1 + next.inserted <= i)
//						next = next.link;
//
//					// Compute the marking for line I.
//					String prefix = " ";
//					if (next != null && next.line1 <= i)
//						// The change NEXT covers this line.
//						// If lines were deleted here in file 0, this is "changed".
//						// Otherwise it is "inserted".  */
//						prefix = (next.deleted > 0) ? "!" : "+";
//					print_1_line (prefix, file1[i]);
//				}
//			}
//		}
//	}

//	/**
//	 * Prints an edit script in context diff format.
//	 * This and its 'unified' variation is used for source code patches.
//	 */
//	public static class UnifiedPrint extends ContextPrint {
//
//		public UnifiedPrint(final Object[] a, final Object[] b) {
//			super(a,b);
//		}
//
//		public void print_header(final String filea, final String fileb) {
//			print_context_label("---", new File(filea), filea);
//			print_context_label("+++", new File(fileb), fileb);
//		}
//
//		private void print_number_range(final int a, final int b) {
//			//translate_range(file, a, b, &trans_a, &trans_b);
//
//			// Note: we can have B < A in the case of a range of no lines.
//			// In this case, we should print the line number before the range, which is B.
//			if (b < a)
//				outfile.print(b + ",0");
//			else
//				super.print_number_range(',',a,b);
//		}
//
//		/**
//		 * pr_unidiff_hunk from diff 2.7.
//		 * Adds prefix_lines (for removing common prefix and suffix before diffing)
//		 * and tab_align_flag, but otherwise unchanged.
//		 */
//		protected void print_hunk(final Diff.change hunk) {
//			Diff.change next;
//			int i, j;
//
//			// Determine range of line numbers involved in each file.
//			analyze_hunk(hunk);
//
//			if (deletes == 0 && inserts == 0)
//				return;
//
//			if (debug) {
//				System.err.printf("%d-%d %d-%d -%d +%d\n", first0,last0,first1,last1,deletes,inserts);
//				System.err.println(hunk);
//			}
//
//			// Include a context's width before and after.
//
//			//	i = - file0.prefix_lines;
//			i = 0;
//			first0 = Math.max (first0 - context, i);
//			first1 = Math.max (first1 - context, i);
//			last0  = Math.min (last0  + context, file0.length - 1);
//			last1  = Math.min (last1  + context, file1.length - 1);
//
//			outfile.print("@@ -");
//			print_number_range (first0, last0);
//			//print_unidiff_number_range (file0, first0, last0);
//			outfile.print(" +");
//			print_number_range (first1, last1);
//			//print_unidiff_number_range (file1, first1, last1);
//			outfile.print(" @@");
//
//			// If we looked for and found a function this is part of, include its name in the header
//			// of the diff section.
//			print_function(file0,first0);
//
//			outfile.println();
//
//			next = hunk;
//			i = first0;
//			j = first1;
//
//			while (i <= last0 || j <= last1) {
//
//				// If the line isn't a difference, output the context from file 0.
//				if (next == null || i < next.line0) {
//					if (i < file0.length) {
//						outfile.print(tab_align_flag);
//						print_1_line ("", file0[i++]);
//					}
//					j++;
//				} else {
//					// For each difference, first output the deleted part.
//					if (debug)
//						System.err.printf("%d-%d %d-%d\n",first0,last0,first1,last1);
//
//					int k = next.deleted;
//					while (k-- > 0) {
//						outfile.print('-');
//						if (tab_align_flag == '\t')
//							outfile.print('\t');
//						print_1_line ("", file0[i++]);
//					}
//
//					// Then output the inserted part.
//					k = next.inserted;
//					while (k-- > 0) {
//						outfile.print('+');
//						if (tab_align_flag == '\t')
//							outfile.print('\t');
//						print_1_line ("", file1[j++]);
//					}
//
//					// We're done with this hunk, so on to the next!
//					next = next.link;
//				}
//			}
//		}
//	}

//	/**
//	 * Read a text file into an array of String.  This provides basic diff functionality.
//	 * A more advanced diff utility will use specialized objects to represent the text lines,
//	 * with options to, for example, convert sequences of whitespace to a single space for
//	 * comparison purposes.
//	 */
//	static String[] slurp(final String file) throws IOException {
//		final BufferedReader rdr = new BufferedReader(new FileReader(file));
//		final List<String> s = new ArrayList<String>();
//		for (;;) {
//			final String line = rdr.readLine();
//			if (line == null) break;
//			s.add(line);
//		}
//		rdr.close();
//		return s.toArray(new String[s.size()]);
//	}

	/**
	 * Read a text file into an array of String.  This provides basic diff functionality.
	 * A more advanced diff utility will use specialized objects to represent the text lines,
	 * with options to, for example, convert sequences of whitespace to a single space for
	 * comparison purposes.
	 */
	static String[] slurp(final File file) throws IOException {
		final BufferedReader rdr = new BufferedReader(new FileReader(file));
		final List<String> s = new ArrayList<String>();
		for (;;) {
			final String line = rdr.readLine();
			if (line == null) break;
			s.add(line);
		}
		rdr.close();
		return s.toArray(new String[s.size()]);
	}

//	/**
//	 *
//	 * @param argv
//	 * @throws IOException
//	 */
//	public static void main(final String[] argv) throws IOException {
//		final String filea = argv[argv.length - 2];
//		final String fileb = argv[argv.length - 1];
//		final String[] a = slurp(filea);
//		final String[] b = slurp(fileb);
//
//		final Diff d = new Diff(a,b);
//		char style = 'n'; // Normal print
//		d.heuristic = false;
//
//		for (int i = 0; i < argv.length - 2; ++i) {
//			final String f = argv[i];
//			if (f.startsWith("-")) {
//				for (int j = 1; j < f.length(); ++j) {
//					switch (f.charAt(j)) {
//					case 'H': // heuristic on
//						d.heuristic = true;
//						break;
//					case 'e': // Ed style
//						style = 'e';
//						break;
//					case 'c': // Context diff
//						style = 'c';
//						break;
//					case 'u': // Unified diff
//						style = 'u';
//						break;
//					}
//				}
//			}
//		}
//
//		final boolean reverse = style == 'e';
//		Diff.change script = d.diff_2(reverse);
//		if (script == null)
//			System.err.println("No differences");
//		else {
//			Base p;
//			switch (style) {
//			case 'e':
//				p = new EdPrint(a,b); break;
//			case 'c':
//				p = new ContextPrint(a,b); break;
//			case 'u':
//				p = new UnifiedPrint(a,b); break;
//			default:
//				p = new NormalPrint(a,b); break;
//			}
//			p.print_header(filea,fileb);
//			p.print_script(script);
//		}
//	}
}
