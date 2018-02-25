import java.awt.Button;
import java.awt.Dialog;
import java.awt.Frame;
import java.awt.Label;
import java.awt.Panel;
import java.awt.Toolkit;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.event.KeyEvent;
import java.awt.event.KeyListener;
import java.awt.event.WindowEvent;
import java.awt.event.WindowListener;

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
  * Pop-up message box with title and message and exit when OK button clicked.
 */
public class MessageBox implements ActionListener, WindowListener, KeyListener
{
	private Frame frame = null;

	public void messageBox(final String title, final String message) {
		frame  = new Frame();
		final Dialog dialog = new Dialog(frame, true); // Modal
		dialog.addWindowListener(this);
		dialog.addKeyListener(this);
		frame.setTitle(title);
		final Panel messagePanel = new Panel();
		final Label messageLabel = new Label(message);
		messagePanel.add(messageLabel);
		dialog.add("Center", messagePanel);
		final Button button = new Button("OK");
		button.addKeyListener(this);
		button.addActionListener(this);
		dialog.add("South", button);
		dialog.pack();
		Toolkit.getDefaultToolkit().beep();
		dialog.setLocation(100,100);
		dialog.toFront();
		dialog.setVisible(true);
	}

	private void cancel_message() {
		frame.dispose();
	}

	public void windowActivated(final WindowEvent e) {}
	public void windowDeactivated(final WindowEvent e) { cancel_message(); }
	public void windowOpened(final WindowEvent e) {}
	public void windowClosing(final WindowEvent e) { cancel_message(); }
	public void windowClosed(final WindowEvent e) { cancel_message(); }
	public void windowIconified(final WindowEvent e) {}
	public void windowDeiconified(final WindowEvent e) {}
	public void actionPerformed(final ActionEvent e) { cancel_message(); }
	public void keyPressed(final KeyEvent e) { cancel_message(); }
	public void keyTyped(final KeyEvent e) { cancel_message(); }
	public void keyReleased(final KeyEvent e) {}
}
