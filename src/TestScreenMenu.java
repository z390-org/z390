import java.awt.Color;
import java.awt.Dimension;
import java.awt.FlowLayout;
import java.awt.Font;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.event.WindowAdapter;
import java.awt.event.WindowEvent;
import java.awt.font.TextLayout;

import javax.swing.BorderFactory;
import javax.swing.JCheckBoxMenuItem;
import javax.swing.JFrame;
import javax.swing.JMenu;
import javax.swing.JMenuBar;
import javax.swing.JMenuItem;
import javax.swing.JPanel;

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
 * Test screen with graphical menu items.
 *
 * @author jba68/z390
 */
public class TestScreenMenu implements ActionListener
{
	private JFrame mainFrame = null;
	private JPanel mainPanel = null;

	private JMenuItem menuFileExit = null;

	private JCheckBoxMenuItem itemRows01 = null;
	private JCheckBoxMenuItem itemRows02 = null;
	private JCheckBoxMenuItem itemRows05 = null;
	private JCheckBoxMenuItem itemRows10 = null;
	private JCheckBoxMenuItem itemRows20 = null;
	private JCheckBoxMenuItem itemRows24 = null;

	private JCheckBoxMenuItem itemSize08 = null;
	private JCheckBoxMenuItem itemSize10 = null;
	private JCheckBoxMenuItem itemSize12 = null;
	private JCheckBoxMenuItem itemSize14 = null;
	private JCheckBoxMenuItem itemSize16 = null;
	private JCheckBoxMenuItem itemSize20 = null;
	private JCheckBoxMenuItem itemSize24 = null;
	private JCheckBoxMenuItem itemSize32 = null;
	private JCheckBoxMenuItem itemSize48 = null;
	private JCheckBoxMenuItem itemSize64 = null;
	private JCheckBoxMenuItem itemSize72 = null;

	private int   numRows  = 24;
	private int   numCols  = 80;
	private int   fontSize = 14;
	private final static Color   colorBG = Color.BLACK;
	private final static Color   colorTX = Color.YELLOW;
	private final static Color[] colorsTN = {	Color.BLACK,   //0
												Color.BLUE,    //1
												Color.RED,     //2
												Color.PINK,    //3
												Color.GREEN,   //4
												Color.MAGENTA, //5 ? TURQUOISE
												Color.YELLOW,  //6
												Color.WHITE    //7
	};

	private Font fontASCII = null;

	private final gz390_screen tnScreen = new gz390_screen();

	/**
	 * Start a test window for gz390_screen.
	 *
	 * @param argv
	 */
	public static void main(final String argv[]) {
		final TestScreenMenu tms = new TestScreenMenu();
		tms.prepareMainFrame();
		tms.createScreen();
		tms.addScreenToFrame();
		tms.updateScreen();
	}

	/**
	 * Prepare the main JFrame, the JMenu, JMenuItems, and a JPanel for the TN screen.
	 */
	private void prepareMainFrame() {
		mainFrame = new JFrame("Test z390 gz390_screen graphic2d menu panel class");
		mainFrame.addWindowListener(new WindowAdapter() {
			public void windowClosing(final WindowEvent e) {
				System.exit(0);
			}
		});

		final JMenuBar menuBar = new JMenuBar();

		final JMenu menuFile = new JMenu("File");
		menuFileExit = new JMenuItem("Exit"); menuFile.add(menuFileExit); menuFileExit.addActionListener(this);
		menuBar.add(menuFile);

		final JMenu menuRows = new JMenu("Rows");
		itemRows01 = new JCheckBoxMenuItem(" 1 row" ); menuRows.add(itemRows01); itemRows01.addActionListener(this);
		itemRows02 = new JCheckBoxMenuItem(" 2 rows"); menuRows.add(itemRows02); itemRows02.addActionListener(this);
		itemRows05 = new JCheckBoxMenuItem(" 5 rows"); menuRows.add(itemRows05); itemRows05.addActionListener(this);
		itemRows10 = new JCheckBoxMenuItem("10 rows"); menuRows.add(itemRows10); itemRows10.addActionListener(this);
		itemRows20 = new JCheckBoxMenuItem("20 rows"); menuRows.add(itemRows20); itemRows20.addActionListener(this);
		itemRows24 = new JCheckBoxMenuItem("24 rows"); menuRows.add(itemRows24); itemRows24.addActionListener(this);
		menuBar.add(menuRows);
		updateSizeMenuOptions(numRows);

		final JMenu menuSize = new JMenu("Font Size");
		itemSize08 = new JCheckBoxMenuItem(" 8 pt"); menuSize.add(itemSize08); itemSize08.addActionListener(this);
		itemSize10 = new JCheckBoxMenuItem("10 pt"); menuSize.add(itemSize10); itemSize10.addActionListener(this);
		itemSize12 = new JCheckBoxMenuItem("12 pt"); menuSize.add(itemSize12); itemSize12.addActionListener(this);
		itemSize14 = new JCheckBoxMenuItem("14 pt"); menuSize.add(itemSize14); itemSize14.addActionListener(this);
		itemSize16 = new JCheckBoxMenuItem("16 pt"); menuSize.add(itemSize16); itemSize16.addActionListener(this);
		itemSize20 = new JCheckBoxMenuItem("20 pt"); menuSize.add(itemSize20); itemSize20.addActionListener(this);
		itemSize24 = new JCheckBoxMenuItem("24 pt"); menuSize.add(itemSize24); itemSize24.addActionListener(this);
		itemSize32 = new JCheckBoxMenuItem("32 pt"); menuSize.add(itemSize32); itemSize32.addActionListener(this);
		itemSize48 = new JCheckBoxMenuItem("48 pt"); menuSize.add(itemSize48); itemSize48.addActionListener(this);
		itemSize64 = new JCheckBoxMenuItem("64 pt"); menuSize.add(itemSize64); itemSize64.addActionListener(this);
		itemSize72 = new JCheckBoxMenuItem("72 pt"); menuSize.add(itemSize72); itemSize72.addActionListener(this);
		menuBar.add(menuSize);
		updateFontMenuOptions(fontSize);

		mainFrame.setJMenuBar(menuBar);

		mainPanel = new JPanel();
		mainPanel.setBorder(BorderFactory.createEmptyBorder(0,2,2,2));
		mainPanel.setLayout(new FlowLayout(FlowLayout.LEFT));
	}

	/**
	 * Create the TN screen with current font size and given number of rows/columns.
	 */
	private void createScreen() {
		fontASCII = new Font(Font.MONOSPACED, Font.BOLD, fontSize);
		tnScreen.setScreen(numRows, numCols, fontASCII, colorBG, colorTX);
	}

	/**
	 * Set TN screen to the preferred size.<br>
	 * Add TN screen panel to mainPanel and pack the main frame.
	 */
	private void addScreenToFrame() {
		tnScreen.getScreenPanel().setPreferredSize(new Dimension(tnScreen.getScnWidth(), tnScreen.getScnHeight()));
		//main_view.createVerticalScrollBar();
		//main_view.createHorizontalScrollBar();

		mainPanel.add(tnScreen.getScreenPanel());

		mainFrame.setContentPane(mainPanel);
		mainFrame.pack();
		mainFrame.setVisible(true);
	}

	/**
	 * Write samples string to TN screen.<br>
	 * The screen is filled up to current number of numRows.
	 */
	private void updateScreen() {
		final String sDE = " - Zwölf Boxkämpfer jagen Eva und Erwin quer über den großen Sylter Deich.";
		final String sEN = " - The quick brown fox jumps over the lazy dog. The quick brown fox jumps!";

		int y = tnScreen.getCharBase();
		int x = 1;
		for ( int i=1 ; i <= numRows+1 ; ++i ) {
			String s;
			tnScreen.getGrid().setColor(colorsTN[(i%7) + 1]);
			if ( i % 2 == 0 ) {
				s = "Line " + i + sDE;
			} else {
				s = "Line " + i + sEN;
			}
			tnScreen.setScreenLayout( new TextLayout(s, fontASCII, tnScreen.getContext()) );
			tnScreen.getScreenLayout().draw(tnScreen.getGrid(), x, y);
			y += tnScreen.getCharHeight();
		}
		tnScreen.allowRepaint(true);
	}

	/**
	 * Update Rows menu items.<br>
	 * Only one menu item may be checked.
	 *
	 * @param currentSize
	 */
	private void updateSizeMenuOptions(final int currentSize) {
		itemRows01.setSelected(currentSize ==  1);
		itemRows02.setSelected(currentSize ==  2);
		itemRows05.setSelected(currentSize ==  5);
		itemRows10.setSelected(currentSize == 10);
		itemRows20.setSelected(currentSize == 20);
		itemRows24.setSelected(currentSize == 24);
	}

	/**
	 * Update Font Size menu items.<br>
	 * Only one menu item may be checked.
	 *
	 * @param currentFontSize
	 */
	private void updateFontMenuOptions(final int currentFontSize) {
		itemSize08.setSelected(currentFontSize ==  8);
		itemSize10.setSelected(currentFontSize == 10);
		itemSize12.setSelected(currentFontSize == 12);
		itemSize14.setSelected(currentFontSize == 14);
		itemSize16.setSelected(currentFontSize == 16);
		itemSize20.setSelected(currentFontSize == 20);
		itemSize24.setSelected(currentFontSize == 24);
		itemSize32.setSelected(currentFontSize == 32);
		itemSize48.setSelected(currentFontSize == 48);
		itemSize64.setSelected(currentFontSize == 64);
		itemSize72.setSelected(currentFontSize == 72);
	}

	/**
	 * Perform menu action setting new number of rows or font size.<br>
	 * -- Update menu options to new situation.<br>
	 * -- Remove old mainView from mainPanel.<br>
	 * -- Create new screen (and so a new mainView) using the new setting.<br>
	 */
	public void actionPerformed(final ActionEvent e) {
		final String state = (String)e.getActionCommand();
		switch (state) {
		case " 1 row":	numRows  =  1; break;
		case " 2 rows":	numRows  =  2; break;
		case " 5 rows":	numRows  =  5; break;
		case "10 rows":	numRows  = 10; break;
		case "20 rows":	numRows  = 20; break;
		case "24 rows":	numRows  = 24; break;
		case " 8 pt":	fontSize =  8; break;
		case "10 pt":	fontSize = 10; break;
		case "12 pt":	fontSize = 12; break;
		case "14 pt":	fontSize = 14; break;
		case "16 pt":	fontSize = 16; break;
		case "20 pt":	fontSize = 20; break;
		case "24 pt":	fontSize = 24; break;
		case "32 pt":	fontSize = 32; break;
		case "48 pt":	fontSize = 48; break;
		case "64 pt":	fontSize = 64; break;
		case "72 pt":	fontSize = 72; break;
		case "Exit":
			System.exit(0);
		default:
			return;
		}

		// Update menu options to new situation
		updateSizeMenuOptions(numRows);
		updateFontMenuOptions(fontSize);

		// Remove old mainView from mainPanel
		mainPanel.removeAll();

		// Create new screen (and so a new mainView) using the new setting
		createScreen();
		// add new screen to mainPanel and pack the frame
		addScreenToFrame();

		updateScreen();
	}
}
