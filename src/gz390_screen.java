import java.awt.Color;
import java.awt.Font;
import java.awt.FontMetrics;
import java.awt.Graphics;
import java.awt.Graphics2D;
import java.awt.RenderingHints;
import java.awt.font.FontRenderContext;
import java.awt.font.TextLayout;
import java.awt.image.BufferedImage;

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
 * Define public Graphics2D scn_panel.<br>
 *<br>
 * The gz390_screen class defines public Graphics2D panel for use by gz390 to define GUAM views:
 * <ol><li>tn_screen
 *     <li>graphic_screen</ol>
 * The method set_screen(rows,cols,font,background_color,text_color) is used to initialize
 * screen size based on the height and width of the font assuming it has been set to desired
 * font size and is a Monospace font.<br>
 * gz390 character and graphics commands draw directly on gz390_screen buffered image object
 * which is repainted at fixed intervals whenever scn_repaint is set true.
 */
public class gz390_screen extends JPanel implements Runnable
{
	// Global data for gz3270_screen
	private static final long serialVersionUID = 1L;

	// Input variable from set_screen
	private int scn_rows = 0;
	private int scn_cols = 0;

	private Font scn_font  = null;
	public  Font getScreenFont() { return scn_font; }

	private Color scn_back_color;
	public void setBackColor(final Color c) { scn_back_color = c; }

	private Color scn_text_color;
	public void setTextColor(final Color c) { scn_text_color = c; }
	public Color getTextColor() { return scn_text_color; }

	// Create screen image based on pixel size of character rendering
	// using specified font_size assuming font is Monospace.
	private BufferedImage scn_image;
	private Graphics2D    scn_grid;
	public  Graphics2D getGrid() { return scn_grid; }

	private FontRenderContext scn_context;
	public FontRenderContext getContext() { return scn_context; }

	private JScrollPane scn_panel;
	public  JScrollPane getScreenPanel() { return scn_panel; }

	private TextLayout scn_layout;
	public  TextLayout getScreenLayout() { return scn_layout; }
	public  void       setScreenLayout(final TextLayout txtLayout) { scn_layout = txtLayout; }

	/**
	 * Minimum font size.
	 */
	private final int min_font_size = 10;

	/**
	 * Maximum font size.
	 */
	private final int max_font_size = 30;

	/**
	 * Current font size.
	 */
	private int scn_font_size   =  0;

	/**
	 * Current font height in pixel.
	 */
	private int scn_char_height =  0;
	/**
	 * Get current font height in pixel.
	 */
	public  int getCharHeight() { return scn_char_height; }
	/**
	 * Get current font base in pixel.
	 */
	private int scn_char_base   =  0; // RPI 630 offset to char baseline
	/**
	 * Get current font base in pixel.
	 */
	public  int getCharBase()   { return scn_char_base;  }
	/**
	 * Current font width in pixel.
	 */
	private int scn_char_width  =  0;
	/**
	 * Get current font width in pixel.
	 */
	public  int getCharWidth()  { return scn_char_width; }

	private int scn_height = 0;
	public  int getScnHeight() { return scn_height; }
	private int scn_width  = 0;
	public  int getScnWidth() { return scn_width; }

	// Screen updated at wait intervals whenever screen_update is set
	int main_width  = 680; // RPI 630 for better font default
	int main_height = 550;

	private boolean scn_ready = false;
	public  boolean isScreenReady() { return scn_ready; }
	private void    setScreenReady(final boolean isReady) { scn_ready = isReady; }

	private final long scn_update_wait = 300; // milli-seconds

	private Thread scn_update_thread = null;

	private boolean scn_repaint = false;
	public  void allowRepaint(final boolean doRepaint) { scn_repaint = doRepaint; }

	/**
	 * Override default paint to draw screen image in panel using current scn_background.
	 */
	public void paint(final Graphics g) {
		g.drawImage(scn_image,0,0,scn_width,scn_height,scn_back_color,this);
	}

	/**
	 * Start thread used to repaint image at fixed intervals whenever scn_repaint has been set true
	 */
	public synchronized void startScreenUpdates()
	{
		if (scn_update_thread == null) {
			scn_update_thread = new Thread(this);
			scn_update_thread.start();
		}
		setScreenReady(true);
		repaint();
		scn_repaint = true;
	}

	/**
	 * Set flag to top screen updates.
	 */
	public synchronized void stopScreenUpdates()
	{
		setScreenReady(false);
	}

	public void run()
	{
		while (scn_update_thread == Thread.currentThread())
		{
			try { // RPI-423 Catch repaint exception too.
				if (isScreenReady() && scn_repaint) {
					repaint();
					scn_repaint = false;
				}
				Thread.sleep(scn_update_wait);
			} catch (final Exception e) {
			}
		}
	}

	/**
	 * Initialize screen panel based on rows, columns, text font and font size, background and text color.
	 *
	 * @param new_rows
	 * @param new_cols
	 * @param new_font
	 * @param new_background_color
	 * @param new_text_color
	 */
	public void setScreen(final int new_rows, final int new_cols, final Font new_font,
						  final Color new_background_color, final Color new_text_color)
	{
		stopScreenUpdates();
		scn_rows = new_rows;
		scn_cols = new_cols;
		scn_font = new_font;
		scn_back_color = new_background_color;
		scn_text_color = new_text_color;
		scn_font_size = new_font.getSize();
		scn_image = new BufferedImage(100,100,BufferedImage.TYPE_INT_ARGB);
		scn_grid  = scn_image.createGraphics();
		calculateScreenSize();
		scn_panel = new JScrollPane(this);
		startScreenUpdates();
	}

	/**
	 * Resize screen to fill current window by adjusting to max font size that will fit.
	 */
	public void resizeScreen(final int maxCX, final int maxCY)
	{
		stopScreenUpdates();
		scn_font_size = min_font_size+1;
		while (scn_font_size < max_font_size) {
			scn_font = new Font(scn_font.getFontName(), Font.BOLD, scn_font_size);
			calculateScreenSize();
			if (   scn_image.getWidth()  < maxCX
				&& scn_image.getHeight() < maxCY) {
				scn_font_size++;
			} else {
				scn_font_size--;
				break;
			}
		}
		scn_font = new Font(scn_font.getFontName(), Font.BOLD, scn_font_size);
		calculateScreenSize();
		startScreenUpdates();
	}

	/**
	 * Calculate scn_width and scn_height for current scn_rows, scn_cols, and scn_font.
	 */
	private void calculateScreenSize()
	{
		scn_grid.setFont(scn_font);

		final FontMetrics fm = scn_grid.getFontMetrics();

		scn_context = scn_grid.getFontRenderContext();

		scn_char_width  = fm.charWidth('8');
		scn_char_base   = fm.getAscent();
		scn_char_height = fm.getHeight();
		final int scn_char_descent = scn_char_height-scn_char_base;
		scn_char_height -= scn_char_descent / 2;

		scn_height = scn_rows * scn_char_height + scn_char_descent;
		scn_width  = scn_cols * scn_char_width  + 4;

		scn_image  = new BufferedImage(scn_width, scn_height, BufferedImage.TYPE_INT_ARGB);
		scn_grid   = scn_image.createGraphics();
		scn_grid.setFont(scn_font);
		scn_grid.setColor(scn_text_color);
		scn_context = scn_grid.getFontRenderContext();
		scn_grid.setRenderingHint(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_ON);
	}
}
