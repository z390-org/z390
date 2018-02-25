import java.awt.Color;
import java.awt.Dimension;
import java.awt.FlowLayout;
import java.awt.Font;
import java.awt.event.WindowAdapter;
import java.awt.event.WindowEvent;
import java.awt.font.TextLayout;

import javax.swing.BorderFactory;
import javax.swing.JFrame;
import javax.swing.JPanel;
import javax.swing.JScrollPane;

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
public class TestScreen {
	/**
	 * Start a test window for gz390_screen.
	 * @param argv
	 */
	public static void main(final String argv[]) {
		final int   numRows  = 24;
		final int   numCols  = 80;
		final int   fontSize = 14;
		final Color colorBG  = Color.BLACK;
		final Color colorTX  = Color.YELLOW;
		final Font  fontASCII = new Font(Font.MONOSPACED,Font.BOLD, fontSize);

		final gz390_screen tn_scn = new gz390_screen(null);
		tn_scn.setScreen(numRows, numCols, fontASCII, colorBG, colorTX);

		final JFrame mainFrame = new JFrame("Test z390 gz390_screen graphic2d panel class");
		mainFrame.addWindowListener(new WindowAdapter() {
			public void windowClosing(final WindowEvent e) {
				System.exit(0);
			}
		});

		final JPanel mainPanel = new JPanel();
		mainPanel.setBorder(BorderFactory.createEmptyBorder(0,2,2,2));
		mainPanel.setLayout(new FlowLayout(FlowLayout.LEFT)); 

		final JScrollPane mainView = tn_scn.getScreenPanel();
		mainView.setPreferredSize(new Dimension(tn_scn.scn_width, tn_scn.scn_height));
		mainView.createVerticalScrollBar();
		mainView.createHorizontalScrollBar();

		mainPanel.add(mainView);

		mainFrame.getContentPane().add(mainPanel);
		mainFrame.pack();
		mainFrame.setVisible(true);

		int y = tn_scn.scn_char_base;
		int x = 1;
		for ( int i=1 ; i <= numRows+1 ; ++i ) {
			tn_scn.scn_grid.setColor(colorTX);
			tn_scn.setScreenLayout( new TextLayout("Line " + i + " - The quick brown fox jumps over the lazy dog. The quick brown fox jumps!",
									fontASCII, tn_scn.scn_context) );
			tn_scn.getScreenLayout().draw(tn_scn.scn_grid, x, y);
			y += tn_scn.scn_char_height;
		}
		tn_scn.allowRepaint(true);
	}
}
