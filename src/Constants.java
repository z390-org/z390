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
 * z390 constants...
 *
 * @author jba68/z390
 */
public class Constants {
	final static String sCopyright2011 = "Copyright 2011 Automated Software Tools Corporation";
	final static String sCopyright2013 = "Copyright 2013 Cat Herder Software, LLC";
	final static String sCopyright2018 = "Copyright 2018 Joachim Bartz, Germany";
	final static String sGnuLicence    = "z390 is licensed under GNU General Public License";
	
	final static int minFontSize = 8;
	final static int maxFontSize = 72;
	final static int numDefaultFontSize = 14;

	final static int posMainFrameX = 24;
	final static int posMainFrameY = 24;

	final static int numBorderWidth = 2;

	final static int numDefaultCommandColumns = 75; // RPI 685

	final static int tn_cursor_wait_int = 1;

	final static int psw_pic_exit     = 0; // exit normally
	final static int psw_pic_io       = 0x013;
	final static int psw_pic_oper     = 0x0c1;
	final static int psw_pic_priv     = 0x0c2;
	final static int psw_pic_exec     = 0x0c3;
	final static int psw_pic_prot     = 0x0c4;
	final static int psw_pic_addr     = 0x0c5;
	final static int psw_pic_spec     = 0x0c6;
	final static int psw_pic_data     = 0x0c7;
	final static int psw_pic_fx_ovf   = 0x0c8;
	final static int psw_pic_fx_div   = 0x0c9;
	final static int psw_pic_pd_ovf   = 0x0ca;
	final static int psw_pic_pd_div   = 0x0cb;
	final static int psw_pic_fp_ovf   = 0x0cc;
	final static int psw_pic_fp_unf   = 0x0cd;
	final static int psw_pic_fp_sig   = 0x0ce;
	final static int psw_pic_fp_div   = 0x0cf;
	final static int psw_pic_timeout  = 0x422;
	final static int psw_pic_gm_err   = 0x804; // getmain request invalid
	final static int psw_pic_link_err = 0x806; // link failed
	final static int psw_pic_no_mem   = 0x80a; // out of memory
	final static int psw_pic_fm_err   = 0x90a; // freemain request invalid
	final static int psw_pic_bad_mem  = 0xa0a; // memory corruption
	final static int psw_pic_stkerr   = 0xf01; // pc stack errror
	final static int psw_pic_operr    = 0xf02; // opcode mask error
	final static int psw_pic_interr   = 0xf03; // Bigint error
	final static int psw_pic_memerr   = 0xf04; // memory exceeded
	final static int psw_pic_waiterr  = 0xf05; // wait for pz390 thread error
	final static int psw_pic_error    = 0xfff; // internal error

//				 byte ascii_lf      = 0x0a;
//				 byte ascii_cr      = 0x0d;
//				 byte ascii_period  = (byte) '.';
	final static byte ascii_space   = (byte) ' ';

//				 byte ebcdic_period = 0x4B;
	final static byte ebcdic_space  = 0x40;
}
