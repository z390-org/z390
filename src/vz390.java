import java.io.File;
import java.nio.ByteBuffer;

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
 * vz390 is the emulator component of z390 called from sz390
 * to perform which VSAM access method services.
 */
public class vz390
{
	// Global variables
	private tz390  tz390 = null;
	private pz390 _pz390 = null;
	private sz390  sz390 = null;

	public  byte cur_vsam_op = 0;
	public final static byte vsam_op_open  = 19;
	public final static byte vsam_op_close = 20;

	// VCDT - VSAM Catalog Definition Table (See mac\VCDTD for VCDT, VCLR, VAIX, VPTH DSECTS)
	private int cur_vcdt_addr = 0; // Address loaded VCDT VSAM catalog
//	private String cur_vcdt_id; // VCDTID C'VCDT'					// JBA-unused
//	private String cur_vcdt_name; // VCDTNAME name of VCDT catalog	// JBA-unused
//	private int cur_vcdt_aixt = 0; // VCDTAIXT tot aix indexes		// JBA-unused
	private int cur_vcdt_ptha = 0; // VCDTPTHA addr path entry
	private int cur_vcdt_dcba = 0;
//	private final static int vcdt_id = 0; // VCDTID C'VCDT'
//	private final static int vcdt_name = 4; // VCDTNAME name of catalog
	private final static int vcdt_clrt = 12; // VCDTCLRT tot base clusters
	private final static int vcdt_clra = 16; // VCDTCLRA addr base cluster entry
//	private final static int vcdt_aixt = 20; // VCDTAIXT tot aix indexes
//	private final static int vcdt_aixa = 24; // VCDTAIXA addr aix index
	private final static int vcdt_ptht = 28; // VCDTPTHT tot paths
	private final static int vcdt_ptha = 32; // VCDTPTHA addr path
	private final static int vcdt_dcba = 36; // VCDTDCBA addr model DCB for ACB allocation
//	private String cur_vcdt_file_name; // from ACB DDNAME/DSNAME // JBA-unused
	private String cur_vcdt_path;
	private int cur_vcdt_tiot = 0; // index of tiot entry + 1

	// VCLR - VSAM Cluster entry in VCDT catalog
//	private String cur_vcltr_id; // VCLRID C"VCLR"								// JBA-unused
//	private String cur_vclr_type; // VCLRTYPE type of base cluster				// JBA-unused
	private int cur_vclr_flag = 0; // VCLRFLAG 4 bytes of flags
//	private int cur_vclr_lavg = 0; // VCLRLAVG average record length for VREC	// JBA-unused
	private int cur_vclr_lrec = 0; // VCLRLREC max length or fixed length
	private int cur_vclr_klen = 0; // VCLRKLEN KSDS primary key length
	private int cur_vclr_koff = 0; // VCLRKOFF KSDS primary key offset
//	private int cur_vclr_aixn = 0; // VCLRAIXN total alternate indexes with upgrade for cluster7 // JBA-unused
//	private int cur_vclr_aixa = 0; // VCLRAIXA addr of VAIX addr table			// JBA-unused
//	private final static int vclr_id   =  0; // VCLRID C'VCLR'					// JBA-unused
	private final static int vclr_name =  4; // VCLRNAME name of base cluster
//	private final static int vclr_type = 12; // VCLRTYPE ESDS/RRDS/ESDS/LDS		// JBA-unused
	private final static int vclr_flag = 16; // VCLRFLAG option flags

	// cur_vclr_flag bits
	private final static int vclr_flag_vrec = 0x80000000; // VCLRVREC variable record length
	private final static int vclr_flag_ruse = 0x40000000; // VCLRRUSE reset EOF at ACB open
	private final static int vclr_flag_ksds = 0x08000000; // VCLRKSDS key sequential (default)
	private final static int vclr_flag_rrds = 0x04000000; // VCLRRRDS relative record data set
	private final static int vclr_flag_esds = 0x02000000; // VCLRESDS entry sequenced data set
	private final static int vclr_flag_lds  = 0x01000000; // VCLRLDS linear
//	private final static int vclr_lavg = 20; // VCLRLAVG average record length for VREC
	private final static int vclr_lrec = 24; // VCLRLREC max or fixed record length
	private final static int vclr_klen = 28; // VCLRKLEN KSDS primary key length
//	private final static int vclr_koff = 32; // VCLRKOFF KSDS primary key offset
	private final static int vclr_vesa = 36; // VCLRVESA addr optional VES DSNAME (Def NAME.VES)
	private final static int vclr_vx0a = 40; // VCLRVX0A addr optional VX0 DSNAME (Def NAME.VX0)
//	private final static int vclr_aixt = 44; // VCLRAIXT total AIX with upgrade for cluster changes
//	private final static int vclr_aixa = 48; // VCLRAIXA addr of table with AIX upgrade catalog entries
//	private final static int vclr_ci   = 52; // VCLRCI optional CI size RPI 704
	private final static int vclr_len  = 56; // VCLRLEN length of VCLR catalog entry

	// VAIX alternate index VCDT catalog entries
	private int cur_vaix_addr = 0; // cur aix section addr
//	private String cur_vaix_id; // VAIXID C'VAIX'												// JBA-unused
//	private String cur_vaix_name; // VAIXNAME name of alternate index							// JBA-unused
//	private String cur_vaix_reln; // VAIXRELN name of related VCLR base cluster					// JBA-unused
//	private int cur_vaix_flag = 0; // VAIXFLAG option flags										// JBA-unused
//	private int cur_vaix_klen = 0; // VAIXKLEN length of aix key in base cluster				// JBA-unused
//	private int cur_vaix_koff = 0; // VAIXKOFF offset of aix key in base cluster				// JBA-unused
//	private int cur_vaix_rela = 0; // VAIXRELA addr related VCLR base cluster catalog entry		// JBA-unused
//	private final static int vaix_id   =  0; // VAIXID C'VAIX'									// JBA-unused
//	private final static int vaix_name =  4; // VAIXNAME name of AIX							// JBA-unused
//	private final static int vaix_reln = 12; // VAIXRELN name of related VCLR base cluster		// JBA-unused
//	private final static int vaix_flag = 20; // VAIXFLAG 4 bytes of option flags RPI 865		// JBA-unused
//	private final static int vaix_flag_ruse = 0x80000000; // VAIXRUSE reset aix eof at open		// JBA-unused
//	private final static int vaix_flag_ukey = 0x40000000; // VAIXUKEY inforce unique keys		// JBA-unused
//	private final static int vaix_flag_uaix = 0x20000000; // VAIXUAIX upgrade AIX for base cluster updates // JBA-unused
	private final static int vaix_klen = 24; // VAIXKLEN aix key length in VES  RPI-865
//	private final static int vaix_koff = 28; // VAIXKOFF aix key offset in VES  RPI-865			// JBA-unused
	private final static int vaix_vxna = 32; // VAIXVXNA addr optional VXN DSNAME (def. NAME.VXN)  RPI 865
	private final static int vaix_rela = 36; // VAIXRELA addr of related VCLR base cluster catalog entry RPI 865
//	private final static int vaix_len  = 40; // VAIXLEN length of VAIX catalog entry RPI-865	// JBA-unused

	// VPTH path VCDT catalog entry
//	private String cur_vpth_id;				// VPTHID C'VPTH' // JBA-unused
//	private String cur_vpth_name;			// VPTHNAME name of path // JBA-unused
//	private String cur_vpth_entn;			// VPTHENTN name of path (VAIX or VCLR) // JBA-unused
//	private int cur_vpth_enta = 0;			// VPTHENTA addr of VAIX or VCLR entry for path // JBA-unused
//	private final static int vpth_id   =  0; // VPTHID C'VPTH'
	private final static int vpth_name =  4; // VPTHNAME name of path
//	private final static int vpth_entn = 12; // VPTHENTN name of entry VAIX or VCLR path
	private final static int vpth_flag = 20; // VPTHFLAG 4 bytes of option flags
	private final static int vpth_flag_aixp = 0x80000000; // VPTHUAIX update all upgrade AIX's for base cluster
	private final static int vpth_flag_aixu = 0x40000000; // VPTHPAIX path is for VAIX vs alias VCLR
	private final static int vpth_enta = 24; // VPTHENTA addr of entry VAIX or VCLR entry
	private final static int vpth_len  = 28; // VPTHLEN length of VPTH catalog entry

	// ACB
	private boolean open_acb_mod = true; // RPI-701 true unless REPRO output
	private int    cur_acb_addr  = 0;
//	private byte   cur_acb_id;			// ACBID x'A0' // JBA-unused
//	private byte   cur_acb_stype;		// ACBSTYPE x'11' - x'1F' VSAM vs VTAM types // JBA-unused
//	private short  cur_acb_len;			// ACBLEN length of ACB // JBA-unused
//	private int    cur_acb_ambl  = 0;	// ACBAMBL AMB list pointer // JBA-unused
//	private int    cur_acb_ifr   = 0;	// ACBIFR VTAM interface routine 0 for VSAM // JBA-unused
	private int    cur_acb_macrf = 0;	// ACBMACRF 4 bytes of option bits
	private byte   cur_acb_oflgs = 0;
	public  String cur_acb_vclrn;		// ACBVCLRN label of ACB (def. VCLR/VPTH entry)
	private int    cur_acb_vclra = 0;	// ACBVCLRA addr of VCLR entry in VCDT catalog
	private int    cur_acb_vaixa = 0;	// ACBVAIXA addr of VAIX entry in VCDT catalog for path
	private int    cur_acb_dcbt  = 0;	// ACBDCBT total DCB's for VES, VX0, and VNN upgrades
	private int    cur_acb_dcba  = 0;	// ACBDCBA addr of dyn alloc DCB table
	private int    cur_acb_openc = 0;	// ACBOPENC unique open ACB count used to reset RPL position
//	private final static acb_id        =  0;	// ACBID x'A0'									// JBA-unused
//	private final static acb_stype     =  1;	// ACBSTYPE x'11' - x'1F' for VSAM vs VTAM		// JBA-unused
//	private final static acb_len       =  2;	// ACBLEN half word length of ACB				// JBA-unused
//	private final static acb_ambl      =  4;	// ACBAMBL AMB list								// JBA-unused
//	private final static acb_ifr       =  8;	// ACBIFR VTAM interface routine (0 for VSAM)	// JBA-unused
	private final static int acb_macrf = 12;	// ACBMACRF macrf flags
	private int tot_dcb_alloc = 0;	// counter for unique ddnames "V??#NNNN"
	private final static int acb_macrf_key = 0x80000000; // ACBMACR1_KEY key access
	private final static int acb_macrf_adr = 0x40000000; // ACBMACR1_ADR access bu RBA or XRBA
//	private final static int acb_macrf_cnv = 0x20000000; // ACBMACR1_CNV control interval access (not supported)
	private final static int acb_macrf_seq = 0x10000000; // ACBMACR1_SEQ sequential access
//	private final static int acb_macrf_dir = 0x08000000; // ACBMACR1_DIR direct access
//	private final static int acb_macrf_in = 0x04000000; // ACBMACR1_IN input only
	private final static int acb_macrf_out = 0x02000000; // ACBMACR1_OUT output add, update, delete
//	private final static int acb_macrf_ubf = 0x01000000; // ACBMACR1_UBF user buffer management (ignored)
//	private final static int acb_macrf_skp = 0x00800000; // ACBMACR2_SKP skip sequential access
//	private final static int acb_macrf_nlogon = 0x00400000; // ACBMACR2_NLOGON no logon required
//	private final static int acb_macrf_rst = 0x00200000;	// ACBMACR2_RST data set reusable (reset rba at open)
//	private final static int acb_macrf_dsn = 0x00100000;	// ACBMACR2_DSN subtask sharing based on DSN
//	private final static int acb_macrf_aix = 0x00080000;	// ACBMACR2_AIX process alt. index versus base
//	private final static int acb_macrf_lsr = 0x00040000;	// ACBMACR2_LSR local shared resources
//	private final static int acb_macrf_gsr = 0x00020000;	// ACBMACR2_GSR global shared resources
//	private final static int acb_macrf_ici = 0x00010000;	// ACBMACR2_ICI improve control interval processing
//	private final static int acb_macrf_dfr = 0x00008000;	// ACBMACR3_DFR defer puts until WRTBUF or required
//	private final static int acb_macrf_sis = 0x00004000;	// ACBMACR3_SIS sequential insert strategy
//	private final static int acb_macrf_cfx = 0x00002000;	// ACBMACR3_CFX fix control blocks and buffers
	private final static int acb_oflgs       = 16;			// ACBPFLGS offset to open flag
	private final static byte acb_oflgs_open = (byte) 0x80;	// ACB_OPEN open
//	private final static byte acb_oflgs_in   = (byte) 0x40;	// ACBGET only
	private final static byte acb_oflgs_out  = (byte) 0x20;	// ACBPUT output add, update, delete
	private final static byte acb_oflgs_aixp = (byte) 0x10;	// ACBAIXP use aix vs primary key
	private final static byte acb_oflgs_aixu = (byte) 0x08;	// ACBAIXU ugrade aix indexes for VCLR
	private final static int  acb_ddnam = 20; // ACBDDNAM DDNAME > env. var.> VCDT[.VCLR/VPTH)
	private final static int  acb_dsnam = 28; // ACBDSNAM DSNAME addr > VCDT[.VCLR/VPTH]
	private final static int  acb_vclrn = 32; // ACBVCLRN name from label field (def VCDT entry)
	private final static int  acb_vclra = 40; // ACBVCLRA addr VCLR in VCDT catalog
	private final static int  acb_vaixa = 44; // ACBVAIXA addr VAIX in VCDT catalog for alt path
	private final static int  acb_dcbt  = 48; // ACBDCBN total DCB's for this ACB
	private final static int  acb_dcba  = 52; // ACBDCBA addr of dynamically allocated DCB's
	private final static int  acb_openc = 56; // ACBOPENC unique open ACB ocunt RPI 702

	// RPL request list
	private int cur_rpl_addr  = 0; // cur RPL address
//	private int cur_rpl_ecb   = 0; // addr ECB to post completion
//	private int cur_rpl_feedb = 0; // feedback codes // JBA-unused
	private int cur_rpl_area  = 0; // addr record area
	private int cur_rpl_arg   = 0; // argument with KSDS key, RRDS rec #, or RBA/XRBA
	private int cur_rpl_opt   = 0; // RPL option flags

	// cur_rpl_opt flag bits
//	private final static int rpl_opt_loc   = 0x8000; // RPL option leave rec in buffer
//	private final static int rpl_opt_dir   = 0x4000; // RPL option direct access
	private final static int rpl_opt_seq   = 0x2000; // RPL option sequential access
//	private final static int rpl_opt_skp   = 0x1000; // RPL option skip sequential access
//	private final static int rpl_opt_asy   = 0x0800; // RPL option
	private final static int rpl_opt_kge   = 0x0400; // RPL option
	private final static int rpl_opt_gen   = 0x0200; // RPL option
	private final static int rpl_opt_xrba  = 0x0100; // RPL option
	private final static int rpl_opt_key   = 0x0080; // RPL option
	private final static int rpl_opt_adr   = 0x0040; // RPL option
//	private final static int rpl_opt_cnv   = 0x0020; // RPL option
	private final static int rpl_opt_bwd   = 0x0010; // RPL option
	private final static int rpl_opt_lrd   = 0x0008; // RPL option
//	private final static int rpl_opt_waitx = 0x0004; // RPL option
	private final static int rpl_opt_upd   = 0x0002; // RPL option
//	private final static int rpl_opt_nsp   = 0x0001; // RPL option
//	private int  cur_rpl_next  = 0; // RPL next RPL address in chained requests
	private int  cur_rpl_lrec  = 0; // RPL record length for RECV PUT
	private long cur_rpl_lxrba = 0; // RPL last rec VES/VX0 XRBA RPI 702 if neg = last KSIR XRBA RPI 723
	private long cur_rpl_cxrba = 0; // RPL cur position VES/VX0 RPI 702
//	private int  cur_rpl_larea = 0; // RPL area length // JBA-unused
	private int  cur_rpl_flag  = 0; // RPL flags for UPD positioning etc.
	private long cur_rpl_ksit  = 0; // XRBA of current KSIT
	private long cur_rpl_ksir  = 0; // XRBA of current KSIR

	// cur_rpl_flag bits
	private final static int rpl_flag_getok = 0x80000000; // Previous RPL GET successful
	private final static int rpl_flag_getnf = 0x40000000; // Previous RPL GET record not found
	private final static int rpl_flag_ksit  = 0x20000000; // Get/put in KSIT

	// RPL field offsets
//	private final static int rpl_ecb   =  4; // RPL address ecb to post // JBA-unused
	private final static int rpl_feedb =  8; // RPL feedback
	private final static int rpl_lkey  = 12; // RPL length of generic key
	private final static int rpl_acb   = 16; // RPL acb addr
	private final static int rpl_area  = 20; // RPL record area
	private final static int rpl_arg   = 24; // RPL argment for KSDS key, RRDS #, ESDS/LDS RBA/XRBA
	private final static int rpl_opt   = 28; // RPL options 2 bytes and 2 bytes filler
//	private final static int rpl_next  = 32; // RPL next RPL in chain // JBA-unused
	private final static int rpl_lrec  = 36; // RPL length of record for recv PUT
	private final static int rpl_lxrba = 40; // RPL last rec XRBA in VES or VX0 RPI 702
	private final static int rpl_cxrba = 48; // RPL cur pos XRBA in VES or VX0 RPI 702
	private final static int rpl_openc = 56; // RPL unique open ACB count RPI 702
//	private final static int rpl_larea = 60; // RPL length of record area // JBA-unused
	private final static int rpl_flag  = 64; // RPL flags for UPD positioning etc.
	private final static int rpl_ksit  = 68; // RPL current KSIT XRBA
	private final static int rpl_ksir  = 76; // RPL current KSIR XRBA
	private final static int rpl_len   = 84; // RPI-750

	// VSAM RPL feedback codes 4 bytes (PDF,RC,CC,RNC)
	private byte pdf_def =  0; // default Problem Determination Field
	private final static byte rc_ok   =  0; // operation successful
	private final static byte rc_log  =  8; // RPL logical error
	private final static byte rc_phy  = 12; // RPL physical error
	private final static byte cmp_ves =  0; // RPLBASER error accessing ES base
	private final static byte cmp_vx0 =  1; // primary KSDS ro VRRDS index
//	private final static byte cmp_vxn =  2; // RPLAIXER error accessing AIX index // JBA-unused

	// rc_ok reason codes (see MVS 3.8 IDARMRCD.MAC)
	private final static byte rn_ok = 0; // ok

	// rc_log logical error reason codes
	private final static byte rn_eod = 4; // RPLEODER end of data
	private final static byte rn_dup_key = 8; // RPLDUP attempt to write dup pri or unique aix key
	private final static byte rn_out_of_seq = 12; // RPLSEQCK skip seq key out of sequence
	private final static byte rn_rcd_not_fnd = 16; // RPLNOREC record not found
	private final static byte rn_rba_not_rcd = 32; // RPLINRBA RBA not a record address
//	private final static byte rn_area_len_err = 44; // RPLINBUF record area too small
	private final static byte rn_inv_acc_type = 68; // RPLINACC invalid RPL access for ACB MACRF
//	private final static byte rn_inv_key_req = 72; // RPLINKEY invalid key req for ESDS/RRDS
	private final static byte rn_inv_rpl_opt = 104; // RPLINVP invalid RPL options
	private final static byte rn_inv_rec_len = 108; // RPLINLEN rec len > max or <> fixed len
//	private final static byte rn_inv_key_len = 112; // RPLKEYLC key len > max or 0
//	private final static byte rn_inv_rec_num = (byte) 192; // RPLIRRNO invalid RRDS record #
	private final static byte rn_inv_rba_req = (byte) 196; // RPLRRADR invalid RBA req to RRDS
	private final static byte rn_acb_not_open = (byte) 235; // z390 catch all
	private String rn_log_reason[] = new String[256];

	// rc_phy physical read/write error reason codes
	private final static byte rn_read_data_err = 4; // RPLRDERD data read error
	private final static byte rn_read_index_err = 8; // RPLRDERI index read error
	private final static byte rn_write_data_err = 16; // RPLWTERD data write error
	private final static byte rn_write_index_err = 20; // RPLWTERI index write error
	private String rn_phy_reason[] = new String[256];

	// excp level I/O
	private int cur_ves_tiot_index = 0;
	private long cur_ves_xrba = 0;
	private long last_ves_xrba = 0; // last ves rec xrba RPI-702
	private int cur_vx0_tiot_index = 0;
	private long cur_vx0_xrba = 0;
//	private long cur_vx0_ves_xrba = 0; // JBA-unused
//	private byte[]  null_rec_bytes; // JBA-unused
//	private byte[] cur_rec_bytes; // JBA-unused
//	private long cur_vxn_xrba = 0; // JBA-unused
	private long bwd_xrba = 0;

	// find ksds key variables
	private byte[] cur_key;
	private ByteBuffer cur_key_buff; // RPI 750
	private byte[] last_key;
	private long vx0_lrec = 0;
	private int comp_key_len = 0; // RPI 750
	private long last_key_rec = 0;
	private long last_key_vx0_xrba = 0;
	private long last_key_ves_xrba = 0;
	private int last_key_gen_rc = 0;
	private long prev_key_rec = 0;
	private long prev_key_vx0_xrba = 0;
	private long prev_key_ves_xrba = 0;
	private int prev_key_gen_rc = 0;

	// statistics option statistics for log
	public  int tot_vsam_oper = 0;
	public  int tot_acb_open = 0;
	public  int tot_acb_close = 0;
	public  int tot_rpl_get = 0;
	public  int tot_rpl_put = 0;
	public  int tot_avl_find   = 0; // RPI 806 KSIR finds in AVL tree
	public  int max_avl_height = 0; // RPI 806 max height of AVL tree
	public  int tot_avl_insert_ksit = 0; // RPI 806 KSIT inserts trees
	public  int tot_avl_insert_ksir = 0; // RPI 806 KSIR insert record in tree 
	public  int tot_avl_rotate    = 0; // RPI 806 KSIR rotates to bal AVL tree
	public  int tot_avl_rotate_ll = 0; // RPI 806 KSIR rotates to bal AVL tree
	public  int tot_avl_rotate_lr = 0; // RPI 806 KSIR rotates to bal AVL tree
	public  int tot_avl_rotate_rr = 0; // RPI 806 KSIR rotates to bal AVL tree
	public  int tot_avl_rotate_rl = 0; // RPI 806 KSIR rotates to bal AVL tree
	public  int tot_rpl_point = 0;
	public  int tot_rpl_erase = 0;
	public  int tot_ves_cache = 0;
	public  int tot_ves_read = 0;
	public  int tot_ves_write = 0;
	public  int tot_vxn_cache = 0;
	public  int tot_vxn_read = 0;
	public  int tot_vxn_write = 0;
	public  int tot_vxn_find  = 0;
	public  int max_vxn_height = 0;

	// KSDS work areas
	private int comp_rc = 0; // result of last key compare
	private int comp_key_gen_rc = 0; // RPI 757

	// KSDS insert top control block ZKSITD
	private byte[] cb_byte = null;
	private ByteBuffer cb = null;
	private long cur_ksit_xrba = 0;
	private final static int ksit_id_val = 0xD2E2C9E3; // RPI 723 C'KSIT"
	private long cur_ksit_top = 0; // top of balanced tree KSIR
	private long cur_ksit_fst = 0; // next first and lowest KSIR XRBA (-1 none, high bit if last add)
	private long cur_ksit_lst = 0; // next last and higher KSIR XRBA (-1 none, high bit if last add)
	private int ksit_id = 0; // id
	private final static int ksit_top = 4; // top KSIR XRBA
	private final static int ksit_fst = 12; // first and lowest KSIR XRBA
	private final static int ksit_lst = 20; // last and highest KSIR XRBA
	private final static int ksit_len = 28; // KSIT length
//	private byte[] cbksit_byte = new byte[ksit_len]; // JBA-unused

	// KSDS insert record control block ZKSIRD
	private long cur_ksir_xrba = 0;
	private final static long xrba_high_bit = (long) 1 << 63;
	private final static long xrba_max_pos  = (long) -1 >>> 1;
	private final static int ksir_id_val = 0xD2E2C9D9; // RPI 723 C'KSIR'
	private long cur_ksir_par  = 0; // parent KSIR or KSIT
	private long cur_ksir_low  = 0; // lower  KSIR XRBA (-1 none, high bit if last add)
	private long cur_ksir_high = 0; // higher KSIR XRBA (-1 none, high bit if last add)
	private long cur_ksir_fwd  = 0; // next seq forward KSIR XRBA (-1 none)
	private long cur_ksir_bwd  = 0; // next seq backward KSIR XRBA (-1 none)
	private long cur_ksir_rec  = 0; // xrba of cur record (may change for var update)
	private byte cur_ksir_low_height  = 0; // max height of low  node
	private byte cur_ksir_high_height = 0; // max height of high node
	private final static int ksir_id   =  0; // id C'KSIR'
	private final static int ksir_par  =  4; // parent KSIR or KSIT
	private final static int ksir_low  = 12; // next lower KSIR or -1 (high bit if last add)
	private final static int ksir_high = 20; // next highest KSIR or -1 (high bit if last add)
	private final static int ksir_bwd  = 28; // next backward KSIR or -1
	private final static int ksir_fwd  = 36; // next forward KSIR or -1
	private final static int ksir_rec  = 44; // xrba of cur record (may change for var update)
	private final static int ksir_low_height  = 52; // max height of low node
	private final static int ksir_high_height = 53; // max height of high node
	private final static int ksir_len  = 54; // KSIR length

	// AVT Balance KSIT variables - RPI-806
	private boolean avl_left       = false;    // rotate left or right side
	private boolean avl_unbalanced = false; // rotation required for avl_r KSIR
	private long avl_r_xrba; // AVL rotation ksir
	private long avl_r_par;  // r parent
	private long avl_r_low;  // r lower left
	private long avl_r_high; // r higher right 
	private byte avl_r_low_height; // r low branch height
	private byte avl_r_high_height; // r high branch height
	private long avl_x_xrba; // AVL next lower/higher ksir to move up
	private long avl_x_low;  // x lower left
	private long avl_x_high; // x higher right	
	private byte avl_x_low_height; // r low branch height
	private byte avl_x_high_height; // r high branch height
	private long avl_w_xrba; // AVL next lower/higher ksir from x for LR/RL rotate
	private long avl_w_low;  // x lower left
	private long avl_w_high; // x higher right
	private byte avl_w_low_height; // r low branch height
	private byte avl_w_high_height; // r high branch height

	// VSAM Cache Buffer (vcb_) data areas
	private boolean vcb_alloc = false;
	private final static int   max_vcb = 10000; // max vcb alloc allowed
	private final static int   max_vcb_hash = 40003; // hash index with no dup allowed 
	private final static int   max_vcb_lrec = 64; // max vcb record size allowed
	private int   tot_vcb = 1; // total vcb allocated + 1 to skip 0 index
//	private int   tot_vcb_req  = 0; // total buffers requested			// JBA-unused
//	private int   tot_vcb_hits = 0; // total buffers reused (saved I/O)	// JBA-unused
	private int   cur_vcb_tiot = 0; // file tiot index
	private long  cur_vcb_xrba = 0; // file xrba addr
	private int   cur_vcb_lrec = 0; // file rec length
	private int   vcb_index = -1; // index of alloc vcb
	private int[]  vcb_tiot = new int[max_vcb];
	private long[] vcb_xrba = new long[max_vcb];
	private int[]  vcb_lrec = new int[max_vcb];
	private int[]  vcb_addr = new int[max_vcb];
	private int cur_vcb_addr = 0; // addr next vcb buffer to alloc
	private byte[] vcb_byte = new byte[max_vcb * max_vcb_lrec]; // vcb buffer
	private ByteBuffer vcb_buff = ByteBuffer.wrap(vcb_byte, 0, max_vcb * max_vcb_lrec);
	private int[] vcb_hash_index = new int[max_vcb_hash];

	// VSAM cache buffer Least recently used and most recently used queues
	private int vcb_lru = 0;
	private int vcb_mru = 0;
	private int[] vcb_mru_prev = new int[max_vcb];
	private int[] vcb_mru_next = new int[max_vcb];

	/**
	 * Initialize vz390
	 * @param shared_tz390
	 * @param shared_pz390
	 * @param shared_sz390
	 */
	public void init_vz390(tz390 shared_tz390, pz390 shared_pz390, sz390 shared_sz390)
	{
		tz390 = shared_tz390;
		_pz390 = shared_pz390;
		sz390 = shared_sz390;
		init_rn_codes();
	}

	/**
	 * Initialize logical and physical reason codes for use in set_feedback tracing.
	 */
	private void init_rn_codes()
	{
		rn_log_reason[  4] = "end of data";
		rn_log_reason[  8] = "duplicate key";
		rn_log_reason[ 12] = "out of seq";
		rn_log_reason[ 16] = "record not found";
		rn_log_reason[ 32] = "rba address not_a record";
		rn_log_reason[ 44] = "area length too small";
		rn_log_reason[ 68] = "invalid RPL access type for ACB";
		rn_log_reason[ 72] = "invalid key request for ESDS/RRDS";
		rn_log_reason[104] = "invalid RPL_option";
		rn_log_reason[108] = "invalid record length";
		rn_log_reason[112] = "invalid key length";
		rn_log_reason[192] = "invalid RRDS record number";
		rn_log_reason[196] = "invalid RRDS RBA request";
		rn_log_reason[235] = "ACB not open";

		rn_phy_reason[ 4] = "read data error";
		rn_phy_reason[ 8] = "read index error";
		rn_phy_reason[16] = "write data error";
		rn_phy_reason[20] = "write index error";
	}

	/**
	 * Execute VSAM access method service requested.
	 */
	public void svc_vsam()
	{
		switch (cur_vsam_op) {
		case 1: // GET R1=A(RPL)
			svc_rpl_get();
			break;
		case 2: // PUT R1=A(RPL)
			svc_rpl_put();
			break;
		case 3: // ERASE R1=A(RPL)
			svc_rpl_erase();
			break;
		case 4: // POINT R1=A(RPL)
			svc_rpl_point();
			break;
		case 19: // OPEN R1=A(ACB)
			svc_open_acb();
			break;
		case 20: // CLOSE R1=A(ACB)
			svc_close_acb();
			break;
		default:
			_pz390.set_psw_check(Constants.psw_pic_oper);
		}
	}

	/**
	 * Open ACB defining VSAM ESDS, RRDS, or KSDS
	 * 1. Use DDNAME/DSNAME to load VCDT and find VCLR entry based on cat.name or search for VCLR with matching ACBNAME. RPI 681
	 * 2. Verify ACB vs VCDT options
	 * 3. Open VES, VX0, and any upgrade VXN's
	 * 4. If REPRO and OUTPUT, then reset ves/vx0 eof RPI 701
	 *
	 * Notes:
	 * Issue ABEND 013 if open fails.
	 */
	public void svc_open_acb()
	{
		tot_acb_open++;
		tot_vsam_oper++;
		if (_pz390.reg.get(pz390.r0 + 3) == sz390.dcb_oflgs_w
				&& tz390.pgm_name.toUpperCase().equals("REPRO")) {
			open_acb_mod = false;
		} else {
			open_acb_mod = true;
		}
		cur_acb_addr = _pz390.reg.getInt(pz390.r1) & _pz390.psw_amode;
		fetch_acb_fields();
		if (cur_acb_oflgs != 0) {
			_pz390.mem.putInt(pz390.r15, 4);
			return;
		}
		if (   load_vcdt() // load VCDT catalog
			&& find_vclr() // find VCLR cluster
			&& check_acb_macrf() // check VCLR/ACB options
			&& open_acb_dcbs()) { // open DCB's for VES,VX0,VXN's
			// set acb oflg open flag and in/out flags
			_pz390.mem.put(cur_acb_addr + acb_oflgs, (byte) (sz390.cur_open_opt | acb_oflgs_open));
			_pz390.mem.putInt(cur_acb_addr + acb_vclra, cur_acb_vclra);
			_pz390.mem.putInt(cur_acb_addr + acb_vaixa, cur_acb_vaixa);
			cur_acb_openc = tot_acb_open;
			_pz390.mem.putInt(cur_acb_addr + acb_openc, cur_acb_openc);
			_pz390.reg.putInt(pz390.r15, 0);
		} else {
			_pz390.reg.putInt(pz390.r15, 8); // RPI 688 VSAM open failed
		}
	}

	/**
	 * Close open acb
	 * 1. Close VESDCB
	 * 2. Close VX0 if not ESDS or fixed RRDS
	 * 2. If KSDS index updates pending, rewrite VXNDCB's from key index trees.
	 */
	public void svc_close_acb()
	{
		tot_acb_close++;
		tot_vsam_oper++;
		cur_acb_addr = _pz390.reg.getInt(pz390.r1) & _pz390.psw_amode;
		fetch_acb_fields();
		if ((cur_acb_oflgs & acb_oflgs_open) == 0) {
			_pz390.reg.putInt(pz390.r15, 4);
			return;
		}
		if (close_acb_dcbs()) {
			// reset acb oflg open flag and in/out flags
			_pz390.mem.put(cur_acb_addr + acb_oflgs, (byte) 0);
			_pz390.reg.putInt(pz390.r15, 0);
		} else {
			_pz390.reg.putInt(pz390.r15, 4);
		}
	}

	/**
	 * Load VCDT using ACB DSNAME or DDNAME
	 * 1. If file spec includes dot, use suffix to find VCDT entry else use ACBNAME field.
	 * 2. Set ACBDCBN, and ACBDCBA from VCDT VCLR or VPTH entry.
	 *
	 * @return
	 */
	private boolean load_vcdt()
	{
		int cur_dsn_addr = _pz390.mem.getInt(cur_acb_addr + acb_dsnam);
		if (cur_dsn_addr == 0) {
			_pz390.reg.putInt(pz390.r15, (cur_acb_addr + acb_ddnam) | 0x80000000);
		} else {
			_pz390.reg.putInt(pz390.r15, cur_dsn_addr);
		}
		sz390.load_vcdt_mode = true;
		sz390.svc_load();
		sz390.load_vcdt_mode = false;
		if (_pz390.reg.getInt(pz390.r15) == 0) {
			// set current VCDT address, path, tiot index
			cur_vcdt_addr = _pz390.reg.getInt(pz390.r0) & _pz390.psw_amode;
			cur_vcdt_path = sz390.load_pgm_dir;
			cur_vcdt_tiot = sz390.cur_cde + 1;
			sz390.put_ascii_string(sz390.load_vcdt_entry, cur_acb_addr + acb_vclrn, 8, ' ');
			return true;
		}
		return false;
	}

	/**
	 * Find VCLR/VPTH entry in VCDT
	 * 1. Set cur_vclra_addr
	 * 2. Set cur_vptha_addr or 0
	 *    a. If vpth_flag_aixp, set acb_oflgs_aixp else 0
	 *    b. If vpth_flag_aixu, set acb_oflgs_aixu else 0
	 * 3. Set cur_vcdt_dcba for use by init_acb_dcb.
	 *
	 * @return
	 */
	private boolean find_vclr()
	{
		cur_vcdt_dcba = _pz390.mem.getInt(cur_vcdt_addr + vcdt_dcba);
		int cur_vcdt_clrt = _pz390.mem.getInt(cur_vcdt_addr + vcdt_clrt); // VCDTCLRT total base clusters
		cur_acb_vclra = _pz390.mem.getInt(cur_vcdt_addr + vcdt_clra);
		while (cur_vcdt_clrt > 0) {
			final String cur_vclr_name = sz390.get_ascii_string(cur_acb_vclra + vclr_name, 8, false); // VCLRNAME name of base cluster
			if (sz390.load_vcdt_entry.equals(cur_vclr_name)) {
				_pz390.mem.putInt(cur_acb_addr + acb_vclra, cur_acb_vclra);
				fetch_vclr_fields();
				cur_vcdt_ptha = 0; // no path RPI 865 
				return true;
			}
			cur_acb_vclra = cur_acb_vclra + vclr_len;
			cur_vcdt_clrt--;
		}
		int cur_vcdt_ptht = _pz390.mem.getInt(cur_vcdt_addr + vcdt_ptht);  // RPI 965 // VCDTPTHT total paths
		cur_vcdt_ptha = _pz390.mem.getInt(cur_vcdt_addr + vcdt_ptha);  // RPI 865
		while (cur_vcdt_ptht > 0) {
			if (sz390.load_vcdt_entry.equals(sz390.get_ascii_string(
				cur_vcdt_ptha + vpth_name, 8, false))) {
				final int cur_vpth_flag = _pz390.mem.getInt(cur_vcdt_ptha + vpth_flag); // RPI-865 // VPTHFLAG 4 byte option flags
				cur_vaix_addr = _pz390.mem.getInt(cur_vcdt_ptha + vpth_enta); // RPI 865
				if ((cur_vpth_flag & vpth_flag_aixp) != 0) {
					cur_acb_vaixa = _pz390.mem.getInt(cur_vcdt_ptha + vpth_enta);
					cur_acb_oflgs = (byte) (cur_acb_oflgs | acb_oflgs_aixp);	// use aix path access vs primary
					cur_acb_vclra = _pz390.mem.getInt(cur_acb_vaixa + vaix_rela);
				} else {
					cur_acb_vclra = _pz390.mem.getInt(cur_vcdt_ptha + vpth_enta); // RPI 865 
					cur_acb_vaixa = 0;
				}
				_pz390.mem.putInt(cur_acb_addr + acb_vclra, cur_acb_vclra);
				_pz390.mem.putInt(cur_acb_addr + acb_vaixa, cur_acb_vaixa);
				if ((cur_vpth_flag & vpth_flag_aixu) != 0) {
					cur_acb_oflgs = (byte) (cur_acb_oflgs | acb_oflgs_aixp);	// allow aix upgrades if any
				}
				_pz390.mem.putInt(cur_acb_addr + acb_vclra, cur_acb_vclra);
				fetch_vclr_fields();
				_pz390.mem.putInt(cur_acb_addr + acb_vaixa, cur_vaix_addr);
				return true;
			}
			cur_vcdt_ptha = cur_vcdt_ptha + vpth_len;
			cur_vcdt_ptht--;
		}
		return false;
	}

	/**
	 * Fetch acb fields from cur_acb_addr.
	 */
	private void fetch_acb_fields()
	{
		cur_acb_macrf = _pz390.mem.getInt(cur_acb_addr + acb_macrf);
		cur_acb_oflgs = _pz390.mem.get(cur_acb_addr + acb_oflgs);
		cur_acb_vclra = _pz390.mem.getInt(cur_acb_addr + acb_vclra);
		cur_acb_vaixa = _pz390.mem.getInt(cur_acb_addr + acb_vaixa);
		cur_acb_dcbt = _pz390.mem.getInt(cur_acb_addr + acb_dcbt);
		cur_acb_dcba = _pz390.mem.getInt(cur_acb_addr + acb_dcba);
		cur_acb_openc = _pz390.mem.getInt(cur_acb_addr + acb_openc);
		final int cur_ves_dcba = cur_acb_dcba;
		final int cur_vx0_dcba = cur_acb_dcba + sz390.dcb_len;
		if ((cur_acb_oflgs & acb_oflgs_open) != 0) {
			cur_ves_tiot_index = _pz390.mem.getInt(cur_ves_dcba + sz390.dcb_iobad) - 1;
			if (cur_ves_tiot_index < 0) {
				sz390.abort_error(22, "VSAM DCB/TIOT Corrupted");
			}
			cur_vx0_tiot_index = _pz390.mem.getInt(cur_vx0_dcba + sz390.dcb_iobad) - 1;
			fetch_vclr_fields(); // RPI 697
		} else {
			cur_ves_tiot_index = -1;
			cur_vx0_tiot_index = -1;
		}
	}

	/**
	 * Fetch current vclr fields used by rpl_get/put. Note open_acb does additional vclr field fetches.
	 */
	private void fetch_vclr_fields()
	{
		cur_vclr_flag = _pz390.mem.getInt(cur_acb_vclra + vclr_flag);
		cur_vclr_lrec = _pz390.mem.getInt(cur_acb_vclra + vclr_lrec);
		if (cur_vcdt_ptha != 0){  // RPI 865 
			cur_vclr_klen = _pz390.mem.getInt(cur_vaix_addr + vaix_klen);
		} else {
			cur_vclr_klen = _pz390.mem.getInt(cur_acb_vclra + vclr_klen);
		}
	}

	/**
	 * Fetch RPL, ACB, and VCDT fields for GET, PUT, etc.
	 */
	private void fetch_rpl_fields()
	{
		cur_rpl_addr = _pz390.reg.getInt(pz390.r1) & _pz390.psw_amode;
	//	cur_rpl_ecb  = _pz390.mem.getInt(cur_rpl_addr + rpl_ecb); // JBA-unused
		final int cur_rpl_lkey = _pz390.mem.getInt(cur_rpl_addr + rpl_lkey); // generic key length
		if (cur_rpl_lkey == 0) { // RPI-750
			comp_key_len = cur_vclr_klen;
		} else {
			comp_key_len = cur_rpl_lkey;
		}
		cur_acb_addr = _pz390.mem.getInt(  cur_rpl_addr + rpl_acb);
		cur_rpl_area = _pz390.mem.getInt(  cur_rpl_addr + rpl_area);
		cur_rpl_arg  = _pz390.mem.getInt(  cur_rpl_addr + rpl_arg);
		cur_rpl_opt  = _pz390.mem.getShort(cur_rpl_addr + rpl_opt);
	//	cur_rpl_next = _pz390.mem.getInt(  cur_rpl_addr + rpl_next); // JBA-unused
		cur_rpl_lrec = _pz390.mem.getInt(  cur_rpl_addr + rpl_lrec);
		if (cur_rpl_lrec == 0) {
			cur_rpl_lrec = cur_vclr_lrec; // RPI 750
		}
	//	cur_rpl_larea = _pz390.mem.getInt( cur_rpl_addr + rpl_larea); // JBA-unused
		cur_rpl_lxrba = _pz390.mem.getLong(cur_rpl_addr + rpl_lxrba);	// last rec RPI-702
		cur_rpl_cxrba = _pz390.mem.getLong(cur_rpl_addr + rpl_cxrba);	// curr pos RPI-702
		int cur_rpl_openc = _pz390.mem.getInt( cur_rpl_addr + rpl_openc); // unique ACB open count to detect req'd pos reet RPI 702
		cur_rpl_flag  = _pz390.mem.getInt( cur_rpl_addr + rpl_flag);	// last rec RPI-702
		cur_rpl_ksit  = _pz390.mem.getLong(cur_rpl_addr + rpl_ksit);	// curr pos RPI-702
		cur_rpl_ksir  = _pz390.mem.getLong(cur_rpl_addr + rpl_ksir);
		fetch_acb_fields(); // RPI-697
		if (cur_rpl_openc != cur_acb_openc) {
			cur_rpl_openc = cur_acb_openc;
			_pz390.mem.putInt(cur_rpl_addr + rpl_openc, cur_rpl_openc);
			set_rpl_lxrba(0); // reset last record
			set_rpl_cxrba(0); // reset cur pos for new acb
			if (tz390.opt_tracev) {
				tz390.put_trace("VSAM RPL  RESET FOR NEW ACB");
			}
		}
	}

	/**
	 * Check for consistency between VCDT and ACB options and if.
	 *
	 * @return
	 */
	private boolean check_acb_macrf()
	{
		if ((cur_vclr_flag & vclr_flag_esds) != 0) {
			// ESDS
		} else if ((cur_vclr_flag & vclr_flag_rrds) != 0) {
			// RRDS
			if ((cur_acb_macrf & acb_macrf_key) == 0) {
				sz390.put_log("OPEN ACB RRDS requires KEY rel rcd access");
				_pz390.reg.putInt(pz390.r15, 8);
				return false;
			}
		}
		_pz390.reg.putInt(pz390.r15, 0);
		return true;
	}

	/*
	 * 1. Dynamically allocate and open dcbs required for VES, VX0, and any upgrade VXN's.
	 * 2. Allocate memory for last key if KSDS.
	 */
	private boolean open_acb_dcbs()
	{
		int save_open_flags = _pz390.reg.getInt(pz390.r0);
		if ((cur_acb_oflgs & acb_oflgs_aixu) != 0) {
			cur_acb_dcbt = _pz390.mem.getInt(cur_acb_addr + acb_dcbt);
		} else if ((cur_vclr_flag & vclr_flag_esds) != 0 // RPI 672
				|| (cur_vclr_flag & vclr_flag_lds) != 0) {
			cur_acb_dcbt = 1; // open VES only for ESDS, VRRDS, LDS
		} else {
			cur_acb_dcbt = 2;
		}
		_pz390.mem.putInt(cur_acb_addr + acb_dcbt, cur_acb_dcbt);
		_pz390.reg.putInt(pz390.r0, 0); // force 24 bit
		_pz390.reg.putInt(pz390.r1, cur_acb_dcbt * sz390.dcb_len);
		sz390.svc_getmain();
		if (_pz390.reg.getInt(pz390.r15) != 0) {
			_pz390.set_psw_check(Constants.psw_pic_gm_err);
		}
		_pz390.reg.putInt(pz390.r0, save_open_flags); // restore open options
		cur_acb_dcba = _pz390.reg.getInt(pz390.r1);
		_pz390.mem.putInt(cur_acb_addr + acb_dcba, cur_acb_dcba);
		final int cur_vclr_vesa = _pz390.mem.getInt(cur_acb_vclra + vclr_vesa); // VCLRVESA addr DSNAME override for VES
		init_acb_dcb(cur_acb_dcba, cur_vclr_lrec, cur_vclr_vesa, "VES#");
		if (!open_acb_dcb(cur_acb_dcba)) {
			return false;
		}
		if (cur_acb_dcbt > 1) {
			if (cur_vcdt_ptha != 0 && cur_vaix_addr != 0){  // RPI 865  
				// open aix if pat
				init_acb_dcb(cur_acb_dcba + sz390.dcb_len, 8 + _pz390.mem.getInt(cur_vaix_addr + vaix_klen),
					_pz390.mem.getInt(cur_vaix_addr + vaix_vxna), "VXN#");
			} else {
				final int cur_vclr_vx0a = _pz390.mem.getInt(cur_acb_vclra + vclr_vx0a); // VCLRVX0A addr DSNAME override for VX0
				init_acb_dcb(cur_acb_dcba + sz390.dcb_len, 8 + cur_vclr_klen, cur_vclr_vx0a, "VX0#");
			}
			if (!open_acb_dcb(cur_acb_dcba + sz390.dcb_len)) {
				return false;
			}
			cur_acb_dcba = cur_acb_dcba + 2 * sz390.dcb_len;
			int index = 2;
			while (index < cur_acb_dcbt) {
				// open aix upgrade dcb's
				cur_vaix_addr = _pz390.mem.getInt(cur_acb_vaixa);
				final int cur_vaix_vxna = _pz390.mem.getInt(cur_vaix_addr + vaix_vxna); // VAIXVXNA addr optional DSNAME (def. NAME.VXN)
			//	cur_vaix_klen = _pz390.mem.getInt(cur_vaix_addr + vaix_klen); // JBA-unused
				init_acb_dcb(cur_acb_dcba, 8 + cur_vclr_klen, cur_vaix_vxna, "VXN#");
				if (!open_acb_dcb(cur_acb_dcba)) {
					return false;
				}
				cur_acb_dcba = cur_acb_dcba + sz390.dcb_len;
				cur_acb_vaixa = cur_acb_vaixa + 4;
				index++;
			}
		}
		return true;
	}

	/**
	 * Copy model DCB from vcdt_dcba to new dynamically allocated DCB address and set DCBLRECLF and DCBDSNAM fields.
	 *
	 * @param dcb_addr
	 * @param dcb_lrecl_f
	 * @param dcb_dsname
	 * @param dcb_ddname
	 */
	private void init_acb_dcb(final int dcb_addr, final int dcb_lrecl_f, final int dcb_dsname, final String dcb_ddname)
	{
		System.arraycopy(_pz390.mem_byte, cur_vcdt_dcba, _pz390.mem_byte, dcb_addr, sz390.dcb_len);
		_pz390.mem.putInt(dcb_addr + sz390.dcb_lrecl_f, dcb_lrecl_f);
		_pz390.mem.putInt(dcb_addr + sz390.dcb_dsnam, dcb_dsname);
		tot_dcb_alloc++;
		sz390.put_ascii_string(tz390.left_justify(dcb_ddname + tot_dcb_alloc, 8), dcb_addr+ sz390.dcb_ddnam, 8, ' ');
	}

	/**
	 * Dynamically allocate and open DCB for VES, VX0, VXN's
	 *
	 * @param dcb_addr
	 * @return
	 */
	private boolean open_acb_dcb(final int dcb_addr)
	{
		// use same flags in r0 for open acb and dcb's.
		sz390.cur_dcb_addr = dcb_addr;
		get_vcdt_path();
		sz390.svc_open_dcb(cur_vcdt_path);
		if (_pz390.reg.getInt(pz390.r15) == 0) {
			if ((cur_vclr_flag & vclr_flag_ruse) != 0 || !open_acb_mod) { // RPI-701
				reuse_file(dcb_addr);
			}
			return true;
		} else {
			return false;
		}
	}

	/**
	 * Close dynamically allocated ACB DCB's.
	 *
	 * @return
	 */
	private boolean close_acb_dcbs()
	{
		if ((cur_acb_oflgs & acb_oflgs_aixu) != 0) {
			cur_acb_dcbt = _pz390.mem.getInt(cur_acb_addr + acb_dcbt);
		} else if ((cur_vclr_flag & vclr_flag_esds) != 0
				|| (cur_vclr_flag & vclr_flag_lds) != 0) {
			cur_acb_dcbt = 1; // open VES and VX0 with no AIX upgrades
		} else {
			cur_acb_dcbt = 2;
		}
		int index = 0;
		while (index < cur_acb_dcbt) {
			sz390.cur_dcb_addr = cur_acb_dcba;
			sz390.svc_close_dcb();
			if (_pz390.reg.getInt(pz390.r15) != 0) {
				return false;
			}
			cur_acb_dcba = cur_acb_dcba + sz390.dcb_len;
			index++;
		}
		_pz390.reg.putInt(pz390.r0, cur_acb_dcbt * sz390.dcb_len);
		cur_acb_dcba = _pz390.mem.getInt(cur_acb_addr + acb_dcba);
		_pz390.reg.putInt(pz390.r1, cur_acb_dcba);
		sz390.svc_freemain();
		if (_pz390.reg.getInt(pz390.r15) != 0) {
			_pz390.set_psw_check(Constants.psw_pic_gm_err);
		}
		return true;
	}

	/**
	 * Get VCDT path for use in VX?DCB file opens.
	 */
	private void get_vcdt_path()
	{
		final int index = sz390.cde_file[cur_vcdt_tiot - 1].lastIndexOf(File.separator);
		if (index > 0) {
			cur_vcdt_path = sz390.cde_file[cur_vcdt_tiot - 1].substring(0,index + 1);
		} else {
			cur_vcdt_path = "";
		}
	}

	/**
	 * Retrieve record from open VSAM ACB/VCDT cluster.
	 */
	private void svc_rpl_get()
	{
		tot_rpl_get++;
		tot_vsam_oper++;
		fetch_rpl_fields();
		if (tz390.opt_tracev) {
			tz390.put_trace("VSAM GET   RPL=" + tz390.get_hex(cur_rpl_addr, 8));
		}
		if ((cur_acb_oflgs & acb_oflgs_open) == 0) {
			// acb not open
			set_feedback(pdf_def, rc_log, cmp_ves, rn_acb_not_open);
			return;
		}
		if ((cur_vclr_flag & vclr_flag_esds) != 0) {
			// ESDS get
			if ((cur_rpl_opt & rpl_opt_key) != 0) {
				set_feedback(pdf_def, rc_log, cmp_ves, rn_inv_rpl_opt);
				return;
			}
			if ((cur_rpl_opt & rpl_opt_seq) != 0) {
				if ((cur_acb_macrf & acb_macrf_seq) != 0) {
					rpl_get_esds_seq();
				} else {
					set_feedback(pdf_def, rc_log, cmp_ves, rn_inv_rpl_opt);
				}
			} else if ((cur_rpl_opt & rpl_opt_adr) != 0) {
				if ((cur_acb_macrf & acb_macrf_adr) != 0) {
					rpl_get_esds_adr();
				} else {
					set_feedback(pdf_def, rc_log, cmp_ves, rn_inv_rpl_opt);
				}
			} else {
				// Unknown or unsupported operation
				set_feedback(pdf_def, rc_log, cmp_ves, rn_inv_rpl_opt);
			}
		} else if ((cur_vclr_flag & vclr_flag_rrds) != 0) {
			// RRDS get
			if ((cur_rpl_opt & rpl_opt_adr) != 0) {
				set_feedback(pdf_def, rc_log, cmp_ves, rn_inv_rpl_opt);
				return;
			}
			if ((cur_rpl_opt & rpl_opt_seq) != 0) { // RPI 739
				rpl_get_rrds_seq();
			} else {
				rpl_get_rrds_key();
			}
		} else if ((cur_vclr_flag & vclr_flag_ksds) != 0) {
			if ((cur_rpl_opt & rpl_opt_seq) != 0) { // RPI 739
				rpl_get_ksds_seq();
			} else {
				rpl_get_ksds_key();
			}
		} else {
			// add LDS support
			set_feedback(pdf_def, rc_log, cmp_ves, rn_inv_rpl_opt);
		}
	}

	/**
	 * ESDS seq get
	 */
	private void rpl_get_esds_seq()
	{
		if ((cur_rpl_opt & rpl_opt_bwd) != 0) {
			if (!set_esds_bwd_next()) {
				return; // RPI 672 error or eod
			}
		}
		cur_ves_xrba = cur_rpl_cxrba;
		if (cur_ves_xrba >= sz390.tiot_eof_rba[cur_ves_tiot_index]) {
			// return logical end of file
			set_feedback(pdf_def, rc_log, cmp_ves, rn_eod);
			return;
		}
		set_rpl_lxrba(cur_ves_xrba);
		set_rpl_arg_rba(); // set RBA/XRBA in RPLARG
		// read ves record
		if (!read_ves_rec()) { // rpi 672
			return;
		}
		if ((cur_rpl_opt & rpl_opt_bwd) == 0) {
			set_rpl_cxrba(cur_ves_xrba);
		}
		if ((cur_rpl_opt & rpl_opt_upd) != 0) {
			// set successful get flag for possible UPD put update
			set_rpl_cur_rec(true);
		}
		// return successful write of ves rec and vx0 index
		set_feedback(pdf_def, rc_ok, cmp_ves, rn_ok);
	}

	/**
	 * ESDS get by rba or xrba
	 */
	private void rpl_get_esds_adr()
	{
		// get ves rba or xrba from RPLARG addr
		if ((cur_rpl_opt & rpl_opt_xrba) != 0) {
			cur_ves_xrba = _pz390.mem.getLong(cur_rpl_arg);
		} else {
			cur_ves_xrba = _pz390.mem.getInt(cur_rpl_arg);
		}
		if (cur_ves_xrba == -1) {
			// replace high value XRBA with eof xrba
			cur_ves_xrba = sz390.tiot_eof_rba[cur_ves_tiot_index];
		}
		if (cur_ves_xrba >= sz390.tiot_eof_rba[cur_ves_tiot_index] || cur_ves_xrba < 0) {
			// return logical invalid rba request error
			set_feedback(pdf_def, rc_log, cmp_ves, rn_rba_not_rcd); // RPI 697
			return;
		}
		set_rpl_lxrba(cur_ves_xrba);
		// read ves record at cur vs0 index
		if (!read_ves_rec()) { // RPI 688 RPI 672
			return;
		}
		set_rpl_cxrba(cur_ves_xrba);
		// set successful get flag for possible UPD put update
		set_rpl_cur_rec(true);
		// return successful read of ves rec and vx0 index
		set_feedback(pdf_def, rc_ok, cmp_ves, rn_ok);
	}

	/**
	 * Set RPLLXRBA last rec XRBA 1. VES for ESDS/RRDS 2. VX0 for KSDS/VRRDS.
	 *
	 * @param xrba
	 */
	private void set_rpl_lxrba(final long xrba)
	{
		cur_rpl_lxrba = xrba;
		_pz390.mem.putLong(cur_rpl_addr + rpl_lxrba, cur_rpl_lxrba);
	}

	/**
	 * Set RPL cur pos xrba
	 * 1. VES for ESDS/RRDS
	 * 2. VX0 for KSDS/VRRDS.
	 *
	 * @param xrba
	 */
	private void set_rpl_cxrba(final long xrba)
	{
		cur_rpl_cxrba = xrba;
		_pz390.mem.putLong(cur_rpl_addr + rpl_cxrba, cur_rpl_cxrba);
	}

	/**
	 * Set RPLLXRBA last rec XRBA
	 * 1. VES for ESDS/RRDS
	 * 2. VX0 for KSDS/VRRDS
	 */
	private void set_rpl_ksit()
	{
		if (tz390.opt_tracev) {
			tz390.put_trace("VSAM RPL KSIT XRBA=" + tz390.get_long_hex(cur_ksit_xrba, 16));
			tz390.put_trace("VSAM RPL KSIR XRBA=" + tz390.get_long_hex(cur_ksir_xrba, 16));
		}
		_pz390.mem.putLong(cur_rpl_addr + rpl_ksit, cur_ksit_xrba);
		_pz390.mem.putLong(cur_rpl_addr + rpl_ksir, cur_ksir_xrba);
	}

	/**
	 * Store cur_ves_xrba as RBA or XRBA in RPLARG and limit check.
	 */
	private void set_rpl_arg_rba()
	{
		if ((cur_rpl_opt & rpl_opt_xrba) != 0) {
			if (cur_ves_xrba > tz390.max_file_size || cur_ves_xrba < 0) {
				set_feedback(pdf_def, rc_log, cmp_ves, rn_inv_rba_req);
				return;
			}
			_pz390.mem.putLong(cur_rpl_arg, cur_ves_xrba);
		} else {
			if (cur_ves_xrba > tz390.max_file_size
					|| cur_ves_xrba > tz390.max_rba_size || cur_ves_xrba < 0) {
				set_feedback(pdf_def, rc_log, cmp_ves, rn_inv_rba_req);
				return;
			}
			_pz390.mem.putInt(cur_rpl_arg, (int) cur_ves_xrba);
		}
	}

	/**
	 * Get next KSDS seq. rcd else eof/error.
	 */
	private void rpl_get_ksds_seq()
	{
		if ((cur_rpl_flag & rpl_flag_ksit) != 0) {
			// read rec for cur ksir in ksit and pos to next ksir or next index
			if (!read_ksir_cur_rec()) {
				return;
			}
		} else {
			// set cur_vx0_xrba to next ksds index
			// else eod or error
			if (!set_ksds_next_index()) {
				return;
			}
			// read ksds index else error
			if (!read_ksds_index()) {
				return;
			}
			if (cur_ves_xrba < 0) {
				// position to first KSIR in KSIT else error
				if (!get_first_seq_ksir()) {
					return;
				}
				// read rec for cur ksir and
				// pos to next ksir or next index
				if (!read_ksir_cur_rec()) {
					return;
				}
			} else {
				// read rec for cur ksds index
				if (!read_ves_rec()) { // rpi 672
					return;
				}
				if ((cur_rpl_opt & rpl_opt_bwd) == 0) { // RPI 779
					// if fwd advance to next index now
					set_rpl_ksds_next();
				}
				set_rpl_cxrba(cur_vx0_xrba);
			}
		}
		// return successful read
		// of next record
		set_feedback(pdf_def, rc_ok, cmp_ves, rn_ok);
	}

	/**
	 * Position to first KSIR in KSIT for either FWD or BWD seq. access.
	 *
	 * @return
	 */
	private boolean get_first_seq_ksir()
	{
		if (!read_ksit()) {
			return false;
		}
		if ((cur_rpl_opt & rpl_opt_bwd) != 0) { // RPI-779
			cur_rpl_ksir = cur_ksit_lst;
		} else {
			cur_rpl_ksir = cur_ksit_fst;
		}
		return true;
	}

	/**
	 * Read record from current KSIR and postion to next KSIR or index entry or return eod.
	 *
	 * @return
	 */
	private boolean read_ksir_cur_rec()
	{
		// read cur KSIR in KSIT
		if (!read_ksir(cur_rpl_ksir)) {
			return false;
		}
		cur_ves_xrba = cur_ksir_rec;
		if (!read_ves_rec()) { // rpi 672
			return false;
		}
		if ((cur_rpl_opt & rpl_opt_bwd) != 0) {
			cur_rpl_ksir = cur_ksir_bwd;
		} else {
			cur_rpl_ksir = cur_ksir_fwd;
		}
		if (cur_rpl_ksir == -1) {
			// at end of KSIT reset for next
			// read ksds index entry
			reset_rpl_cur_rec_flags();
			if ((cur_rpl_opt & rpl_opt_bwd) == 0) {
				set_rpl_ksds_next();
			}
		}
		set_rpl_cur_rec(true);
		return true;
	}

	/**
	 * Display error message for KSIR broken links and set feedback ves data error.
	 *
	 * @param type
	 * @param xrba1
	 * @param xrba2
	 */
	private void broken_ksir_link(String type, long xrba1, long xrba2)
	{
		sz390.put_log("VSAM KSIR BROKEN LINK " + type 
					+ " XRBA1=" + tz390.get_long_hex(xrba1,16)
					+ " XRBA1=" + tz390.get_long_hex(xrba2,16));
		set_feedback(pdf_def, rc_phy, cmp_ves, rn_read_data_err);
	}

	/**
	 * Set cur_vx0_xrba to next ksds index going forward or backward else set eod.
	 *
	 * @return
	 */
	private boolean set_ksds_next_index()
	{
		if ((cur_rpl_opt & rpl_opt_bwd) != 0) {
			cur_vx0_xrba = cur_rpl_cxrba;
			if (cur_vx0_xrba == 0) {
				set_feedback(pdf_def, rc_log, cmp_ves, rn_eod);
				// return logical end of data to front of file
				return false;
			}
			cur_vx0_xrba = cur_vx0_xrba - 8 - cur_vclr_klen;
			set_rpl_cxrba(cur_vx0_xrba);
		} else {
			cur_vx0_xrba = cur_rpl_cxrba;
		}
		if (cur_vx0_xrba > tz390.max_file_size || cur_vx0_xrba < 0) {
			set_feedback(pdf_def, rc_log, cmp_ves, rn_inv_rba_req);
			return false;
		}
		if (cur_vx0_xrba >= sz390.tiot_eof_rba[cur_vx0_tiot_index]) {
			// return eod at end of index
			set_feedback(pdf_def, rc_log, cmp_ves, rn_eod);
			return false;
		}
		return true;
	}

	/**
	 * Setup for next seq record either in KSIT or VX0 index and turn off rpl_flag_ksit if done.
	 */
	private void set_rpl_ksds_next()
	{
		if ((cur_rpl_flag & rpl_flag_ksit) != 0) {
			if (cur_rpl_ksir != -1) {
				cur_rpl_flag = cur_rpl_flag ^ rpl_flag_ksit;
				set_rpl_flag();
				set_vx0_ksds_next();
			} else {
				cur_rpl_flag = cur_rpl_flag | rpl_flag_ksit;
				set_rpl_ksit();
			}
		} else {
			set_vx0_ksds_next();
		}
		set_rpl_cxrba(cur_vx0_xrba);
	}

	/**
	 * Store rpl_flag.
	 */
	private void set_rpl_flag()
	{
		if (tz390.opt_tracev) {
			tz390.put_trace("VSAM RPL FLAG=" + tz390.get_hex(cur_rpl_flag, 8));
		}
		_pz390.mem.putLong(cur_rpl_addr + rpl_flag, cur_rpl_flag);
	}

	/**
	 * inc or dec vx0 for next key index entry.
	 */
	private void set_vx0_ksds_next()
	{
		if ((cur_rpl_opt & rpl_opt_bwd) != 0) {
			cur_vx0_xrba = cur_vx0_xrba - 8 - cur_vclr_klen;
		} else {
			cur_vx0_xrba = cur_vx0_xrba + 8 + cur_vclr_klen;
		}
	}

	/**
	 * Get KSDS get by key.
	 */
	private void rpl_get_ksds_key()
	{
		reset_rpl_cur_rec_flags();
		if (!find_ksds_key()) {
			// key not found - set get not found flag for possible UPD insert
			set_rpl_cur_rec(false);
			set_feedback(pdf_def, rc_log, cmp_ves, rn_rcd_not_fnd);
			return;
		}
		set_rpl_lxrba(cur_vx0_xrba);
		// read ves record at cur vs0 index
		if (!read_ves_rec()) { // RPI-688 RPI-672
			return;
		}
		if ((cur_rpl_opt & rpl_opt_gen) != 0) {
			System // RPI-779
			.arraycopy(_pz390.mem_byte, cur_rpl_area + cur_vclr_koff,
					   _pz390.mem_byte, cur_rpl_arg,   cur_vclr_klen);
		}
		set_rpl_cxrba(cur_vx0_xrba);
		set_rpl_cur_rec(true);
		// return successful read of ves rec and vx0 index
		set_feedback(pdf_def, rc_ok, cmp_ves, rn_ok);
	}

	/**
	 * Get for open RRDS file.
	 * Notes:
	 * Read vx0 XRBA for rel. rcd #
	 */
	private void rpl_get_rrds_key()
	{
		if ((cur_rpl_opt & rpl_opt_kge) != 0) {
			while (cur_vx0_xrba < sz390.tiot_eof_rba[cur_vx0_tiot_index]
					&& !get_rrds_ves_xrba(true)) {
				cur_vx0_xrba = cur_vx0_xrba + 8;
			}
			if (cur_vx0_xrba >= sz390.tiot_eof_rba[cur_vx0_tiot_index]) {
				set_feedback(pdf_def, rc_log, cmp_ves, rn_rcd_not_fnd);
				return;
			}
		} else {
			if (!get_rrds_ves_xrba(true)) {
				// RRDS rec not written or too big
				set_feedback(pdf_def, rc_log, cmp_ves, rn_rcd_not_fnd);
				return;
			}
		}
		// read existing record
		if (!read_ves_rec()) {
			return;
		}
		// return successful read of ves rec and vx0 index
		set_feedback(pdf_def, rc_ok, cmp_ves, rn_ok);
	}

	/**
	 * Get seq for RRDS file.
	 * Notes:
	 * Read vx0 at rpl_cxrba to get ves xrba.
	 */
	private void rpl_get_rrds_seq()
	{
		boolean null_rec;

		cur_vx0_xrba = cur_rpl_cxrba;
		if ((cur_rpl_opt & rpl_opt_bwd) != 0) {
			// read vrrds index backward
			null_rec = true;
			while (null_rec) {
				if (cur_vx0_xrba <= 0) {
					// return end of data
					set_feedback(pdf_def, rc_log, cmp_ves, rn_eod);
					return;
				}
				cur_vx0_xrba = cur_vx0_xrba - 8;
				set_rpl_cxrba(cur_vx0_xrba); // RPI 702
				// read existing record
				if (get_rrds_ves_xrba(false)) {
					// exit search with non null index rec
					null_rec = false;
					_pz390.mem.putInt(cur_rpl_arg, (int) ((cur_vx0_xrba >> 3) + 1)); // RPI-724
				}
			}
			if (!read_ves_rec()) { // RPI-672
				return;
			}
		} else {
			null_rec = true;
			while (null_rec) {
				if (cur_vx0_xrba >= sz390.tiot_eof_rba[cur_vx0_tiot_index]) {
					// return end of data
					set_feedback(pdf_def, rc_log, cmp_ves, rn_eod);
					return;
				}
				// read existing record
				if (get_rrds_ves_xrba(false)) {
					null_rec = false;
					_pz390.mem.putInt(cur_rpl_arg, (int) (cur_vx0_xrba >> 3) + 1); // RPI-724
				}
				cur_vx0_xrba = cur_vx0_xrba + 8;
				set_rpl_cxrba(cur_vx0_xrba); // RPI-702
			}
			if (!read_ves_rec()) { // RPI-672
				return;
			}
		}
		// return successful rrds read
		set_feedback(pdf_def, rc_ok, cmp_ves, rn_ok);
	}

	/**
	 * Search vx0 for ksds key in rplarg and set cur_vx0_xrba entry if found else false.
	 *
	 * @return
	 */
	private boolean find_ksds_key()
	{
		tot_vxn_find++;
		vx0_lrec = 8 + cur_vclr_klen;
		long high_key_rec = sz390.tiot_eof_rba[cur_vx0_tiot_index] / vx0_lrec;
		long low_key_rec = 0;
		long next_key_rec = (high_key_rec + low_key_rec + 1) / 2;
		if (next_key_rec == high_key_rec) {
			next_key_rec = 0; // RPI-1016
		}
		last_key_rec = -1;
		prev_key_rec = -1;
		if (tz390.opt_tracev) {
			tz390.put_trace("VSAM FIND KEY=" + tz390.get_hex(cur_rpl_arg, 8)
					+ " LEN=" + tz390.get_hex(comp_key_len, 8));
			sz390.dump_mem(_pz390.mem, cur_rpl_arg, comp_key_len);
		}
		byte cur_node_depth = 0;
		while (next_key_rec != last_key_rec && next_key_rec != prev_key_rec) {
			cur_node_depth++;
			if (cur_node_depth > max_vxn_height){
				max_vxn_height = cur_node_depth;
			}
			cur_vx0_xrba = next_key_rec * vx0_lrec;
			if (read_ksds_index()) {
				prev_key_rec = last_key_rec;
				prev_key_vx0_xrba = last_key_vx0_xrba;
				prev_key_ves_xrba = last_key_ves_xrba;
				prev_key_gen_rc = last_key_gen_rc;
				last_key_rec = next_key_rec;
				last_key_vx0_xrba = cur_vx0_xrba;
				last_key_ves_xrba = cur_ves_xrba;
				comp_key(cur_rpl_arg, cur_key);
				last_key_gen_rc = comp_key_gen_rc;
				if (comp_rc == 0) {
					if (cur_ves_xrba < 0) {
						if (find_ksir()) {
							cur_ves_xrba = cur_ksir_rec;
							set_rpl_cur_rec(true);
							return true;
						} else {
							return false;
						}
					}
					set_rpl_cur_rec(true);
					return true;
				}
				if (comp_rc > 0) {
					low_key_rec = next_key_rec;
				} else {
					high_key_rec = next_key_rec;
				}
				next_key_rec = (high_key_rec + low_key_rec + 1) / 2;
				if (next_key_rec == last_key_rec && next_key_rec > 0) {
					next_key_rec--;
				}
			} else {
				return false;
			}
		}
		if (cur_ves_xrba < 0) {
			if (find_ksir()) {
				set_rpl_cur_rec(true);
				return true;
			}
		} else if ((cur_rpl_opt & rpl_opt_kge) != 0) { // RPI 750
			if (comp_rc > 0 && prev_key_rec > last_key_rec) { // RPI 750
				// if this rec key is low and previous rec key was higher than return previous key for KGE
				cur_vx0_xrba = prev_key_vx0_xrba;
				cur_ves_xrba = prev_key_ves_xrba;
				comp_key_gen_rc = prev_key_gen_rc;
			}
			if ((cur_rpl_opt & rpl_opt_gen) != 0 && comp_key_gen_rc > 0) {
				return false;
			}
			if (cur_ves_xrba < 0) { // RPI-723
				if (!find_ksir()) {
					return false;
				}
				cur_ves_xrba = cur_ksir_rec;
			}
			set_rpl_cur_rec(true);
			return true;
		} else if ((cur_rpl_opt & rpl_opt_gen) != 0) {
			if (comp_rc > 0 && prev_key_rec > last_key_rec) { // RPI 750
				// if this rec key is low and previous rec key was higher than return previous key for KGE
				cur_vx0_xrba = prev_key_vx0_xrba;
				cur_ves_xrba = prev_key_ves_xrba;
				comp_key_gen_rc = prev_key_gen_rc;
			}
			if (comp_key_gen_rc == 0) {
				if (cur_ves_xrba < 0) {
					if (!find_ksir()) {
						return false;
					}
					cur_ves_xrba = cur_ksir_rec;
				}
				set_rpl_cur_rec(true);
				return true;
			}
		}
		return false;
	}

	/**
	 * Set rpl_flag_getok or rpl_flag_getnf and save along with rpl_flag_ksit possible following put or insert.
	 *
	 * @param found
	 */
	private void set_rpl_cur_rec(final boolean found)
	{
		if (found) {
			cur_rpl_flag = cur_rpl_flag | rpl_flag_getok;
		} else {
			cur_rpl_flag = cur_rpl_flag | rpl_flag_getnf;
		}
		_pz390.mem.putInt( cur_rpl_addr + rpl_flag, cur_rpl_flag);
		_pz390.mem.putLong(cur_rpl_addr + rpl_ksit, cur_rpl_ksit);
		_pz390.mem.putLong(cur_rpl_addr + rpl_ksir, cur_rpl_ksir);
	}

	/**
	 * Reset flags for RPL current record.
	 */
	private void reset_rpl_cur_rec_flags()
	{
		cur_rpl_flag = cur_rpl_flag & (-1 ^ (rpl_flag_ksit | rpl_flag_getok | rpl_flag_getnf));
		_pz390.mem.putInt(cur_rpl_addr + rpl_flag, cur_rpl_flag);
	}

	/**
	 * Search ksit binary tree at cur_vx0_xrba (negative).
	 * 1. Set cur_ves_xrba to record if found 
	 * 2. Set cur_rpl_ksir to last ksir for use by insert_ksir
	 * 3. Set avl_r_xrba/par/low/high if ksir found requiring AVL
	 *    rotation to keep tree balanced after KSIR is inserted.
	 *
	 * @return
	 */
	private boolean find_ksir()
	{
		tot_avl_find++;
		if (tz390.opt_tracev) {
			tz390.put_trace("VSAM AVL FIND KSIR");
		}
		if (cur_ves_xrba == -1) {
			return false; // vx0 key record deleted
		}
		if (read_ksit()) {
			long last_gen_ksir = -1;
			cur_ksir_xrba = cur_ksit_top;
			byte prev_node_height = -1;
			byte cur_node_height  = 0;
			while (cur_ksir_xrba != -1) {
				if (!read_ksir(cur_ksir_xrba)) {
					return false; // io error
				}
				if (!read_ksir_key()) {
					return false; // io error
				}
				if (comp_key(cur_rpl_arg, cur_key) == 0) {
					return get_ksir_rec();
				}
				if ((cur_rpl_opt & rpl_opt_gen) != 0) { // RPI 723
					if (comp_key_gen_rc == 0
							|| (cur_rpl_opt & rpl_opt_kge) != 0) {
						last_gen_ksir = cur_ksir_xrba;
					}
				}
				cur_node_height = (byte)(Math.max(cur_ksir_low_height,cur_ksir_high_height));
				if (cur_node_height > max_avl_height){
					max_avl_height = cur_node_height;
				}
				if (prev_node_height != -1){
					if (prev_node_height != cur_node_height + 1){
						sz390.put_log("VSAM AVL NODE HEIGHT ERROR ");
						set_feedback(pdf_def, rc_phy, cmp_ves, rn_read_data_err);
						return false;
					}
				}
				if (comp_rc < 0) {
					prev_node_height = cur_ksir_low_height;
					cur_ksir_xrba = cur_ksir_low;
				} else {
					prev_node_height = cur_ksir_high_height;
					cur_ksir_xrba = cur_ksir_high;
				}
			}
			if (last_gen_ksir != -1) {
				cur_ksir_xrba = last_gen_ksir;
				return get_ksir_rec();
			}
		}
		return false;
	}

	/**
	 * Set cur_ves_xrba to ksir rec unless deleted.
	 *
	 * @return
	 */
	private boolean get_ksir_rec()
	{
		if (cur_ksir_rec > 0) {
			// KSIR with matching record found
			cur_ves_xrba = cur_ksir_rec;
			return true;
		} else {
			return false; // deleted record
		}
	}

	/**
	 * 1. If random access by key rec #, then cur_vx0_rba = rec# * 8 else cur_vx0_xrba = cur_rpl_cxrba.
	 * 2. Set cur_ves_xrba as follows if cur_vx0_xrba > eod set cur_vx0_xrba = -1 (not found) and return false
	 * 2. Set cur_ves_xrba as follows:
	 *    a. -1 if 0 return false (no rec found)
	 *    b. xrba and return true.
	 *
	 * Note:
	 * VX0 XRBA's for valid records are stored +1. to distinguish 0 as unwritten VES XRBA.
	 *
	 * @param key
	 * @return
	 */
	private boolean get_rrds_ves_xrba(final boolean key)
	{
		if (key) {
			final long rrn = (long) _pz390.mem.getInt(cur_rpl_arg); // RPI-724
			if (rrn == -1) {
				cur_vx0_xrba = sz390.tiot_eof_rba[cur_vx0_tiot_index];
			} else if (rrn > 0) {
				cur_vx0_xrba = (rrn - 1) << 3; // RPI 724
			} else {
				set_feedback(pdf_def, rc_log, cmp_ves, rn_inv_rba_req);
				return false;
			}
		} else {
			cur_vx0_xrba = cur_rpl_cxrba;
		}
		set_rpl_lxrba(cur_vx0_xrba); // RPI 702
		if (cur_vx0_xrba > tz390.max_file_size || cur_vx0_xrba < 0) {
			set_feedback(pdf_def, rc_log, cmp_ves, rn_inv_rba_req);
			return false;
		}
		if (cur_vx0_xrba >= sz390.tiot_eof_rba[cur_vx0_tiot_index]) {
			// RRDS rec not written yet
			cur_ves_xrba = -1;
			return false;
		}
		if (!read_xrba_ptr()) {
			// I/O error on index
			set_feedback(pdf_def, rc_phy, cmp_vx0, rn_read_index_err);
			cur_ves_xrba = -1;
			return false;
		}
		if (cur_ves_xrba == 0) {
			// RRDS record not found
			cur_ves_xrba = -1;
			return false;
		}
		// remove odd bit from RRDS VES XRBA
		cur_ves_xrba--;
		if (cur_ves_xrba > tz390.max_file_size || cur_ves_xrba < 0) {
			set_feedback(pdf_def, rc_log, cmp_ves, rn_inv_rba_req);
			return false;
		}
		return true;
	}

	/**
	 * Update or write new record in open VSAM ACB/VCDT cluster.
	 */
	private void svc_rpl_put()
	{
		tot_rpl_put++;
		tot_vsam_oper++;
		fetch_rpl_fields();
		if (tz390.opt_tracev) {
			tz390.put_trace("VSAM PUT   RPL=" + tz390.get_hex(cur_rpl_addr, 8));
		}
		if ((cur_acb_oflgs & acb_oflgs_open) == 0) {
			set_feedback(pdf_def, rc_log, cmp_ves, rn_acb_not_open);
			return;
		}
		if ((cur_acb_oflgs & acb_oflgs_out) == 0
				|| (cur_acb_macrf & acb_macrf_out) == 0) {
			set_feedback(pdf_def, rc_log, cmp_ves, rn_inv_rpl_opt);
			return;
		}
		if ((cur_vclr_flag & vclr_flag_esds) != 0) {
			// ESDS out - add rec to VES
			rpl_put_esds();
		} else if ((cur_vclr_flag & vclr_flag_rrds) != 0) {
			// RRDS out
			rpl_put_rrds();
		} else if ((cur_vclr_flag & vclr_flag_ksds) != 0) {
			// KSDS out
			rpl_put_ksds();
		} else {
			// add LDS support
			set_feedback(pdf_def, rc_log, cmp_ves, rn_inv_rpl_opt);
		}
	}

	/**
	 * Put for open ESDS output file.
	 */
	private void rpl_put_esds()
	{
		if ((cur_rpl_opt & rpl_opt_key) != 0) {
			set_feedback(pdf_def, rc_log, cmp_ves, rn_inv_rpl_opt);
			return;
		}
		if ((cur_rpl_opt & rpl_opt_upd) != 0
				|| (cur_rpl_opt & rpl_opt_adr) != 0) {
			if ((cur_rpl_flag & rpl_flag_getok) != 0) {
				// turn off successful get flag and set xrba to rewrite record
				reset_rpl_cur_rec_flags();
				cur_ves_xrba = cur_rpl_lxrba;
			} else {
				// required get not done successfully
				set_feedback(pdf_def, rc_log, cmp_ves, rn_inv_acc_type);
				return;
			}
		} else {
			cur_ves_xrba = sz390.tiot_eof_rba[cur_ves_tiot_index];
		}
		set_rpl_lxrba(cur_ves_xrba);
		set_rpl_arg_rba(); // set RBA/XRBA in RPLARG
		if (!write_ves_rec()) {
			return;
		}
		if ((cur_rpl_opt & rpl_opt_upd) == 0
				&& (cur_rpl_opt & rpl_opt_seq) != 0) {
			// update eof for sequential ESDS put
			try {
				cur_ves_xrba = sz390.tiot_file[cur_ves_tiot_index].length();
				sz390.tiot_eof_rba[cur_ves_tiot_index] = cur_ves_xrba;
			} catch (Exception e) {
				set_feedback(pdf_def, rc_phy, cmp_ves, rn_write_data_err);
			}
		}
		set_rpl_cxrba(cur_ves_xrba);
		// return successful write of ves rec and vx0 index
		set_feedback(pdf_def, rc_ok, cmp_ves, rn_ok);
	}

	/**
	 * Put for open KSDS output file.
	 */
	private void rpl_put_ksds()
	{
		if ((cur_rpl_opt & rpl_opt_upd) != 0) {
			if ((cur_rpl_flag & rpl_flag_getok) != 0) {
				if (!update_ksds_rec()) {
					return;
				}
				reset_rpl_cur_rec_flags();
			} else if ((cur_rpl_flag & rpl_flag_getnf) != 0) {
				// turn off unsuccessful get flag and set xrba to rewrite record
				if (!insert_ksds_rec()) {
					return;
				}
				reset_rpl_cur_rec_flags();
			} else {
				// required ksds get not done successfully
				set_feedback(pdf_def, rc_log, cmp_ves, rn_inv_acc_type);
				return;
			}
		} else if ((cur_rpl_opt & rpl_opt_seq) != 0) {
			cur_ves_xrba = sz390.tiot_eof_rba[cur_ves_tiot_index];
			cur_vx0_xrba = sz390.tiot_eof_rba[cur_vx0_tiot_index];
			if (last_key != null){ // RPI 1024 by JM
				if (cur_vx0_xrba > 0
					&& comp_key(cur_rpl_area + cur_vclr_koff, last_key) <= 0) {
					if (comp_rc == 0) {
						// ksds dup primary key
						set_feedback(pdf_def, rc_log, cmp_ves, rn_dup_key);
					} else {
						// ksds out of seq primary key
						set_feedback(pdf_def, rc_log, cmp_ves, rn_out_of_seq);
					}
					return;
				}
			}
			if (last_key == null || last_key.length < cur_vclr_klen) {
				last_key = new byte[cur_vclr_klen];
			}
			System.arraycopy(_pz390.mem_byte, cur_rpl_area + cur_vclr_koff, last_key, 0, cur_vclr_klen);
			set_rpl_lxrba(cur_vx0_xrba);
			if (!write_ves_rec()) {
				return;
			}
			// Update ves eof for sequential KSDS put
			try {
				sz390.tiot_eof_rba[cur_ves_tiot_index] = sz390.tiot_file[cur_ves_tiot_index].length();
			} catch (final Exception e) {
				set_feedback(pdf_def, rc_phy, cmp_ves, rn_write_data_err);
			}
			// update vx0 index to new ves xrba
			// and key added to eof
			if (!write_ksds_index()) {
				return;
			}
			set_rpl_cxrba(cur_vx0_xrba);
			// update vx0 eof for sequential KSDS put
			try {
				sz390.tiot_eof_rba[cur_vx0_tiot_index] = sz390.tiot_file[cur_vx0_tiot_index]
						.length();
			} catch (Exception e) {
				set_feedback(pdf_def, rc_phy, cmp_ves, rn_write_data_err);
			}
		} else {
			// ksds put rquires UPD or SEQ
			set_feedback(pdf_def, rc_log, cmp_ves, rn_inv_acc_type);
			return;
		}
		// return successful ksds put
		set_feedback(pdf_def, rc_ok, cmp_ves, rn_ok);
	}

	/**
	 * Put for open RRDS output file
	 *
	 * Notes:
	 * 1. Always use rel rec # to calc XRBA.
	 * 1. Read vx0 XRBA for rel. rcd #
	 * 2. If XRBA = 0, add rec to VES else rewrite
	 */
	private void rpl_put_rrds()
	{
		if ((cur_rpl_opt & rpl_opt_adr) != 0) {
			set_feedback(pdf_def, rc_log, cmp_ves, rn_inv_rpl_opt);
			return;
		}
		if (get_rrds_ves_xrba(true)) {
			// rewrite or replace with bigger added record at end
			if (rewrite_ves_rec(cur_vx0_tiot_index, cur_vx0_xrba)) {
				return;
			}
		} else if (cur_ves_xrba == -1) {
			if (!add_ves_rec(cur_vx0_tiot_index, cur_vx0_xrba)) {
				return;
			}
		} else {
			// exit with invalid RRDS rec #
			return;
		}
		if ((cur_rpl_opt & rpl_opt_bwd) != 0) {
			cur_vx0_xrba = cur_vx0_xrba - 8;
		} else {
			cur_vx0_xrba = cur_vx0_xrba + 8;
		}
		set_rpl_cxrba(cur_vx0_xrba);
		// return successful write of ves rec and vx0 index
		set_feedback(pdf_def, rc_ok, cmp_ves, rn_ok);
	}

	/**
	 * Rewrite RRDS or KSDS record at cur_ves_xrba and update index xrba if it changed due to variable length change.
	 *
	 * @param tiot_index
	 * @param xrba_index
	 * @return
	 */
	private boolean rewrite_ves_rec(final int tiot_index, final long xrba_index)
	{
		try {
			int write_lrec;

			if ((cur_vclr_flag & vclr_flag_vrec) == 0) {
				// fixed length
				write_lrec = cur_rpl_lrec;
			} else {
				// var length
				if (get_vcb_buff(cur_ves_tiot_index, cur_ves_xrba, 4)) {
					write_lrec = vcb_buff.getInt(vcb_addr[vcb_index]);
				} else {
					sz390.tiot_file[cur_ves_tiot_index].seek(cur_ves_xrba);
					write_lrec = sz390.tiot_file[cur_ves_tiot_index].readInt();
					if (vcb_alloc) {
						vcb_buff.putInt(vcb_addr[vcb_index], write_lrec);
					}
				}
			}
			if (write_lrec == cur_rpl_lrec) {
				// rewrite record
				if (!write_ves_rec()) {
					return false;
				}
			} else {
				if (!add_ves_rec(tiot_index, xrba_index)) {
					return false;
				}
			}
		} catch (final Exception e) {
			set_feedback(pdf_def, rc_phy, cmp_ves, rn_write_data_err);
			return false;
		}
		return true;
	}

	/**
	 * Add RRDS or KSDS record to VES and update index XRBA address which may be in VX0 or in VES KSIR.
	 *
	 * @param tiot_index
	 * @param index_xrba
	 * @return
	 */
	private boolean add_ves_rec(final int tiot_index, final long index_xrba)
	{
		cur_ves_xrba = sz390.tiot_eof_rba[cur_ves_tiot_index];
		if (!write_ves_rec()) {
			return false;
		}
		try {
			// update VES end of file addr
			sz390.tiot_eof_rba[cur_ves_tiot_index] = sz390.tiot_file[cur_ves_tiot_index]
					.length();
		} catch (Exception e) {
			set_feedback(pdf_def, rc_phy, cmp_ves, rn_write_data_err);
			return false;
		}
		if (tiot_index > -1) { // RPI 723
			cur_ves_xrba = last_ves_xrba;
			cur_vx0_xrba = cur_rpl_lxrba;
			if ((cur_vclr_flag & vclr_flag_rrds) != 0) {
				// update RRDS vx0 index to VES XRBA+1 to indicate valid record
				if (!write_xrba_ptr(cur_vx0_tiot_index, cur_vx0_xrba,
						cur_ves_xrba + 1)) { // rpi 688
					return false;
				}
			} else {
				// update KSDS vx0 index to VES XRBA+1 to indicate valid record
				if (!write_xrba_ptr(cur_vx0_tiot_index, cur_vx0_xrba,
						cur_ves_xrba)) { // RPI 723
					return false;
				}
			}
		}
		return true;
	}

	/**
	 * Erase current record retrieved from open VSAM ACB/VCDT cluster.
	 * Notes:
	 * The current XRBA in VX0 primary index is set to high values.
	 */
	private void svc_rpl_erase()
	{
		tot_rpl_erase++;
		fetch_rpl_fields();
		if (tz390.opt_tracev) {
			tz390.put_trace("VSAM ERASE RPL=" + tz390.get_hex(cur_rpl_addr, 8));
		}
		if ((cur_acb_oflgs & acb_oflgs_open) == 0) {
			set_feedback(pdf_def, rc_log, cmp_ves, rn_acb_not_open);
			return;
		}
	}

	/**
	 * Set current position to specified key, record, or RBA in ESDS base.
	 */
	private void svc_rpl_point()
	{
		tot_rpl_point++;
		fetch_rpl_fields();
		if (tz390.opt_tracev) {
			tz390.put_trace("VSAM POINT RPL=" + tz390.get_hex(cur_rpl_addr, 8));
		}
		if ((cur_acb_oflgs & acb_oflgs_open) == 0) {
			set_feedback(pdf_def, rc_log, cmp_ves, rn_acb_not_open);
			return;
		}
		// cancel last rec position
		reset_rpl_cur_rec_flags();
		set_rpl_lxrba(-1);
		if ((cur_vclr_flag & vclr_flag_esds) != 0) {
			// ESDS POINT
			if ((cur_rpl_opt & rpl_opt_lrd) != 0) {
				// position to eof xrba
				cur_ves_xrba = sz390.tiot_eof_rba[cur_ves_tiot_index];
			} else {
				if ((cur_rpl_opt & rpl_opt_xrba) != 0) {
					cur_ves_xrba = _pz390.mem.getLong(cur_rpl_arg);
					if (cur_ves_xrba == -1) {
						// replace high value XRBA with eof xrba
						cur_ves_xrba = sz390.tiot_eof_rba[cur_ves_tiot_index];
					}
					if (tz390.opt_tracev) {
						tz390.put_trace("VSAM POINT XRBA="
								+ tz390.get_long_hex(cur_ves_xrba, 16));
					}
					if (cur_ves_xrba < 0
							|| cur_ves_xrba > sz390.tiot_eof_rba[cur_ves_tiot_index]
							|| cur_ves_xrba > tz390.max_file_size // RPI 707
							|| ((cur_vclr_flag & vclr_flag_vrec) == 0 // RPI
																		// 706
							&& cur_ves_xrba / cur_vclr_lrec * cur_vclr_lrec != cur_ves_xrba)) {
						// return logical invalid rba request error
						set_feedback(pdf_def, rc_log, cmp_ves, rn_rba_not_rcd); // RPI-697
						return;
					}
					_pz390.mem.putLong(cur_rpl_arg, cur_ves_xrba);
				} else {
					cur_ves_xrba = _pz390.mem.getInt(cur_rpl_arg);
					if (cur_ves_xrba == -1) {
						// replace high value XRBA with eof xrba
						cur_ves_xrba = sz390.tiot_eof_rba[cur_ves_tiot_index];
					}
					if (tz390.opt_tracev) {
						tz390.put_trace("VSAM POINT  RBA="
								+ tz390.get_hex((int) cur_ves_xrba, 8));
					}
					if (cur_ves_xrba < 0
							|| cur_ves_xrba > sz390.tiot_eof_rba[cur_ves_tiot_index]
							|| cur_ves_xrba > tz390.max_file_size // RPI 707
							|| cur_ves_xrba > tz390.max_rba_size // RPI 707
							|| ((cur_vclr_flag & vclr_flag_vrec) == 0 // RPI
																		// 706
							&& cur_ves_xrba / cur_vclr_lrec * cur_vclr_lrec != cur_ves_xrba)) {
						// return logical invalid rba request error
						set_feedback(pdf_def, rc_log, cmp_ves, rn_rba_not_rcd); // RPI-697
						return;
					}
				}
				_pz390.mem.putInt(cur_rpl_arg, (int) cur_ves_xrba);
			}
			set_rpl_cxrba(cur_ves_xrba);
		} else if ((cur_vclr_flag & vclr_flag_ksds) != 0) {
			// KSDS POINT
			if ((cur_rpl_opt & rpl_opt_lrd) != 0 || rpl_key_high_values()) { // RPI-779
				// position to eof xrba
				cur_vx0_xrba = sz390.tiot_eof_rba[cur_vx0_tiot_index];
			} else {
				if (!find_ksds_key()) {
					if ((cur_rpl_opt & rpl_opt_kge) != 0) {
						if (last_key_rec < prev_key_rec) {
							cur_vx0_xrba = prev_key_rec * vx0_lrec;
						} else {
							cur_vx0_xrba = last_key_rec * vx0_lrec;
						}
					} else {
						// KSDS key not found
						set_feedback(pdf_def, rc_log, cmp_ves, rn_rcd_not_fnd);
						return; // RPI 706
					}
				}
			}
			set_rpl_cxrba(cur_vx0_xrba);
		} else if ((cur_vclr_flag & vclr_flag_rrds) != 0) {
			// RRDS\VRRDS
			final int cur_ves_rec = _pz390.mem.getInt(cur_rpl_arg);
			if ((cur_rpl_opt & rpl_opt_lrd) != 0) {
				// position to eof xrba
				cur_vx0_xrba = sz390.tiot_eof_rba[cur_vx0_tiot_index];
			} else {
				if (cur_ves_rec == -1) {
					// set xrba to eof
					cur_vx0_xrba = sz390.tiot_eof_rba[cur_vx0_tiot_index];
				} else {
					cur_vx0_xrba = (cur_ves_rec - 1) // Rpi 724
					<< 3;
				}
				if (cur_vx0_xrba > tz390.max_file_size || cur_vx0_xrba < 0) {
					// return logical invalid rba request error
					set_feedback(pdf_def, rc_log, cmp_ves, rn_rba_not_rcd); // RPI-697
					return;
				}
			}
			set_rpl_cxrba(cur_vx0_xrba);
		} else {
			// LDS point not supported yet
			set_feedback(pdf_def, rc_log, cmp_ves, rn_inv_rpl_opt);
			return; // RPI 706
		}
		// return successful POINT // RPI 706
		set_feedback(pdf_def, rc_ok, cmp_ves, rn_ok);
	}

	/**
	 * Store RPLFEEDB 4 byte field with:
	 *   0 - pdf_ Problem Determination Field
	 *   1 - rc_ return code (also stored in R15)
	 *   2 - cmp_ component code
	 *   3 - rn_ reason code for corresponding rc_
	 *
	 * @param pdf
	 * @param rc
	 * @param cmp
	 * @param rn
	 */
	private void set_feedback(final byte pdf, final byte rc, final byte cmp, final byte rn)
	{
		final int feedback = ((pdf << 8 | rc) << 8 | cmp) << 8 | (rn & 0xff);
		_pz390.mem.putInt(cur_rpl_addr + rpl_feedb, feedback);
		_pz390.reg.putInt(pz390.r15, rc & 0xff);
		if (tz390.opt_tracev) {
			String type = "unknown";
			String reason = null;
			switch (rc) {
			case 8: // logical error
				type = "logical";
				reason = rn_log_reason[rn & 0xff];
				break;
			case 12: // physical error
				type = "physical";
				reason = rn_phy_reason[rn & 0xff];
				break;
			}
			if (reason == null) {
				reason = "unknown";
			}
			if (rc != 0) {
				tz390.put_trace("VSAM RPL FEEDBACK="
						+ tz390.get_hex(feedback, 8) + " TYPE=" + type
						+ " REASON=" + reason);
			}
			tz390.put_trace("VSAM RPL ADDR=" + tz390.get_hex(cur_rpl_addr, 8)
					+ " LEN=" + tz390.get_hex(rpl_len, 8));
			sz390.dump_mem(_pz390.mem, cur_rpl_addr, rpl_len);
			int cur_rpl_arg_len = cur_vclr_klen; // RPI 779
			if ((cur_vclr_flag & vclr_flag_ksds) == 0) {
				if ((cur_rpl_opt & rpl_opt_xrba) != 0) {
					cur_rpl_arg_len = 8;
				} else {
					cur_rpl_arg_len = 4;
				}
			}
			tz390.put_trace("VSAM RPL ARG =" + tz390.get_hex(cur_rpl_arg, 8)
					+ " LEN=" + tz390.get_hex(cur_rpl_arg_len, 8) + " KLEN="
					+ tz390.get_hex(cur_vclr_klen, 8)); // RPI-779
			sz390.dump_mem(_pz390.mem, cur_rpl_arg, cur_rpl_arg_len); // RPI-779
			tz390.put_trace("VSAM RPL AREA=" + tz390.get_hex(cur_rpl_area, 8)
					+ " LEN=" + tz390.get_hex(cur_rpl_lrec, 8));
			sz390.dump_mem(_pz390.mem, cur_rpl_area, cur_rpl_lrec);
		}
	}

	/**
	 * Read record from VES into RPLAREA and set length in RPLLREC to the VES ESDS base cluster data file at specified xrba.
	 *
	 * Notes:
	 * If ESDS, skip duplicate length after record. // RPI-672
	 *
	 * @return
	 */
	private boolean read_ves_rec()
	{
		if (cur_ves_xrba >= sz390.tiot_eof_rba[cur_ves_tiot_index] || cur_ves_xrba < 0) {
			// return logical invalid rba request error
			if ((cur_vclr_flag & vclr_flag_rrds) != 0) {
				if ((cur_rpl_opt & rpl_opt_seq) != 0) { // RPI 724
					set_feedback(pdf_def, rc_log, cmp_ves, rn_eod);
				} else {
					set_feedback(pdf_def, rc_log, cmp_ves, rn_inv_rba_req);
				}
			} else {
				set_feedback(pdf_def, rc_log, cmp_ves, rn_rba_not_rcd); // RPI-697
			}
			return false;
		}
		set_rpl_lxrba(cur_ves_xrba); // RPI-865
		if ((cur_vclr_flag & vclr_flag_vrec) != 0) {
			// read variable length record putting
			// 4 length prefix into RPLLREC and the remainder in RPLAREA
			try {
				if (get_vcb_buff(cur_ves_tiot_index, cur_ves_xrba, 4)) {
					tot_ves_cache++;
					cur_rpl_lrec = vcb_buff.getInt(vcb_addr[vcb_index]);
				} else {
					tot_ves_read++;
					// read var ves rec len prefix
					sz390.tiot_file[cur_ves_tiot_index].seek(cur_ves_xrba);
					cur_rpl_lrec = sz390.tiot_file[cur_ves_tiot_index]
							.readInt();
					if (vcb_alloc) {
						vcb_buff.putInt(vcb_addr[vcb_index], cur_rpl_lrec);
					}
				}
				if (cur_rpl_lrec < 1 || cur_rpl_lrec > cur_vclr_lrec) {
					// prefix lrec invalid
					if (tz390.opt_tracev) {
						tz390.put_trace("VSAM READ INVALID VREC PFX LREC = "
								+ tz390.get_hex(cur_rpl_lrec, 8) + " AT XRBA="
								+ tz390.get_long_hex(cur_ves_xrba, 16));
					}
					set_feedback(pdf_def, rc_log, cmp_ves, rn_inv_rec_len);
					return false;
				}
				_pz390.mem.putInt(cur_rpl_addr + rpl_lrec, cur_rpl_lrec); // RPI-688
				if (get_vcb_buff(cur_ves_tiot_index, cur_ves_xrba + 4, cur_rpl_lrec)) {
					tot_ves_cache++;
					System.arraycopy(vcb_byte, vcb_addr[vcb_index],
							_pz390.mem_byte, cur_rpl_area, cur_rpl_lrec);
				} else {
					tot_ves_read++;
					// read var ves rec
					sz390.tiot_file[cur_ves_tiot_index].seek(cur_ves_xrba + 4);
					sz390.tiot_file[cur_ves_tiot_index].read(_pz390.mem_byte,
							cur_rpl_area, cur_rpl_lrec);
					if (vcb_alloc) {
						System.arraycopy(_pz390.mem_byte, cur_rpl_area,
								vcb_byte, vcb_addr[vcb_index], cur_rpl_lrec);
					}
				}
				if (tz390.opt_tracev) {
					tz390.put_trace("VSAM EXCP READ  VREC  XRBA="
							+ tz390.get_long_hex(cur_ves_xrba + 4, 16)
							+ " LEN=" + tz390.get_hex(cur_rpl_lrec, 8));
				}
				int read_lrec = 4 + cur_rpl_lrec;
				if ((cur_vclr_flag & vclr_flag_esds) != 0) {
					read_lrec = read_lrec + 4;
					int ver_rpl_lrec;
					if (get_vcb_buff(cur_ves_tiot_index, cur_ves_xrba + 4 + cur_rpl_lrec, 4)) {
						tot_ves_cache++;
						ver_rpl_lrec = vcb_buff.getInt(vcb_addr[vcb_index]);
					} else {
						tot_ves_read++;
						// read ESDS var ves rec suffix len
						sz390.tiot_file[cur_ves_tiot_index].seek(cur_ves_xrba + 4 + cur_rpl_lrec);
						ver_rpl_lrec = sz390.tiot_file[cur_ves_tiot_index].readInt();
						if (vcb_alloc) {
							vcb_buff.putInt(vcb_addr[vcb_index], ver_rpl_lrec);
						}
					}
					if (ver_rpl_lrec != cur_rpl_lrec) {
						// prefix lrec not equal sfx lrec
						if (tz390.opt_tracev) {
							tz390.put_trace("VSAM EXCP READ ERROR PFX RECLEN = "
											+ tz390.get_hex(cur_rpl_lrec, 8)
											+ " SFX RECLEN="
											+ tz390.get_hex(ver_rpl_lrec, 8));
						}
						set_feedback(pdf_def, rc_log, cmp_ves, rn_inv_rec_len);
						return false;
					}
				}
				cur_ves_xrba = cur_ves_xrba + read_lrec;
				sz390.tot_dcb_read++;
				sz390.tot_dcb_oper++;
				return true;
			} catch (final Exception e) {
				set_feedback(pdf_def, rc_phy, cmp_ves, rn_read_data_err);
				return false;
			}
		} else {
			// read fixed length record
			cur_rpl_lrec = cur_vclr_lrec;
			try {
				if (get_vcb_buff(cur_ves_tiot_index, cur_ves_xrba, cur_rpl_lrec)) {
					tot_ves_cache++;
					System.arraycopy(vcb_byte, vcb_addr[vcb_index],
							_pz390.mem_byte, cur_rpl_area, cur_rpl_lrec);
				} else {
					tot_ves_read++;
					// read fixed ves rec
					sz390.tiot_file[cur_ves_tiot_index].seek(cur_ves_xrba);
					sz390.tiot_file[cur_ves_tiot_index].read(_pz390.mem_byte,
							cur_rpl_area, cur_rpl_lrec);
					if (vcb_alloc) {
						System.arraycopy(_pz390.mem_byte, cur_rpl_area,
								vcb_byte, vcb_addr[vcb_index], cur_rpl_lrec);
					}
				}
				if (tz390.opt_tracev) {
					tz390.put_trace("VSAM EXCP READ  FREC XRBA="
							+ tz390.get_long_hex(cur_ves_xrba, 16) + " LEN="
							+ tz390.get_hex(cur_rpl_lrec, 8));
				}
				cur_ves_xrba = cur_ves_xrba + cur_rpl_lrec;
				sz390.tot_dcb_read++;
				sz390.tot_dcb_oper++;
				return true;
			} catch (Exception e) {
				set_feedback(pdf_def, rc_phy, cmp_ves, rn_read_data_err);
				return false;
			}
		}
	}

	/**
	 * Write current RPL record in RPLAREA with length RPLLREC to the VES base cluster data file at specified xrba.
	 * 
	 * Notes:
	 * 1. Variable length records have 4 byte length preceding record.
	 * 2. ESDS variable length records also have 4 byte length following record
	 *    to support BWD read backward option without any index.
	 * 3. Used by ESDS, RRDS, and KSDS when not inserted record.
	 * 
	 * @return
	 */
	private boolean write_ves_rec()
	{
		if (cur_ves_xrba > tz390.max_file_size || cur_ves_xrba < 0) {
			set_feedback(pdf_def, rc_log, cmp_ves, rn_rba_not_rcd); // RPI 697
			return false;
		}
		if ((cur_vclr_flag & vclr_flag_vrec) != 0) {
			// write variable length record 4 byte prefix
			try {
				tot_ves_write++;
				// write ves var prefix lrec
				sz390.tiot_file[cur_ves_tiot_index].seek(cur_ves_xrba);
				sz390.tiot_file[cur_ves_tiot_index].writeInt(cur_rpl_lrec);
				if (get_vcb_buff(cur_ves_tiot_index, cur_ves_xrba, 4)
						|| vcb_alloc) {
					vcb_buff.putInt(vcb_addr[vcb_index], cur_rpl_lrec);
				}
				tot_ves_write++;
				// write ves var rec
				sz390.tiot_file[cur_ves_tiot_index].seek(cur_ves_xrba + 4);
				sz390.tiot_file[cur_ves_tiot_index].write(_pz390.mem_byte,
						cur_rpl_area, cur_rpl_lrec);
				if (get_vcb_buff(cur_ves_tiot_index, cur_ves_xrba + 4, cur_rpl_lrec)
						|| vcb_alloc) {
					System.arraycopy(_pz390.mem_byte, cur_rpl_area, vcb_byte,
							vcb_addr[vcb_index], cur_rpl_lrec);
				}
				if (tz390.opt_tracev) {
					tz390.put_trace("VSAM EXCP WRITE VREC  XRBA="
							+ tz390.get_long_hex(cur_ves_xrba + 4, 16)
							+ " LEN=" + tz390.get_hex(cur_rpl_lrec, 8));
				}
				int write_lrec = 0;
				if ((cur_vclr_flag & vclr_flag_esds) != 0) {
					write_lrec = 4 + cur_rpl_lrec + 4;
					tot_ves_write++;
					// write ESDS var rec sfx lrec used to read backward
					sz390.tiot_file[cur_ves_tiot_index].seek(cur_ves_xrba + 4 + cur_rpl_lrec);
					sz390.tiot_file[cur_ves_tiot_index].writeInt(cur_rpl_lrec);
					if (get_vcb_buff(cur_ves_tiot_index, cur_ves_xrba + 4 + cur_rpl_lrec, 4)
							|| vcb_alloc) {
						vcb_buff.putInt(vcb_addr[vcb_index], cur_rpl_lrec);
					}
				} else {
					write_lrec = 4 + cur_rpl_lrec;
				}
				last_ves_xrba = cur_ves_xrba; // rpi-702
				cur_ves_xrba = cur_ves_xrba + write_lrec;
				sz390.tot_dcb_write++;
				sz390.tot_dcb_oper++;
				return true;
			} catch (final Exception e) {
				set_feedback(pdf_def, rc_phy, cmp_ves, rn_write_data_err);
				return false;
			}
		} else {
			// write fixed length record
			cur_rpl_lrec = cur_vclr_lrec;
			try {
				tot_ves_write++;
				sz390.tiot_file[cur_ves_tiot_index].seek(cur_ves_xrba);
				sz390.tiot_file[cur_ves_tiot_index].write(_pz390.mem_byte,
						cur_rpl_area, cur_rpl_lrec);
				if (get_vcb_buff(cur_ves_tiot_index, cur_ves_xrba, cur_rpl_lrec)
						|| vcb_alloc) {
					System.arraycopy(_pz390.mem_byte, cur_rpl_area, vcb_byte,
							vcb_addr[vcb_index], cur_rpl_lrec);
				}
				if (tz390.opt_tracev) {
					tz390.put_trace("VSAM EXCP WRITE FREC XRBA="
							+ tz390.get_long_hex(cur_ves_xrba, 16) + " LEN="
							+ tz390.get_hex(cur_rpl_lrec, 8));
				}
				last_ves_xrba = cur_ves_xrba;
				cur_ves_xrba = cur_ves_xrba + cur_rpl_lrec;
				sz390.tot_dcb_write++;
				sz390.tot_dcb_oper++;
				return true;
			} catch (final Exception e) {
				set_feedback(pdf_def, rc_phy, cmp_ves, rn_write_data_err);
				return false;
			}
		}
	}

	/**
	 * Write control block in ves at xrba into cb byte array.
	 * 
	 * @param cb_xrba
	 * @param cb_len
	 * @return
	 */
	private boolean write_ves_cb(final long cb_xrba, final int cb_len)
	{
		if (cb_xrba > tz390.max_file_size) {
			set_feedback(pdf_def, rc_log, cmp_ves, rn_inv_rba_req);
			return false;
		}
		try {
			tot_ves_write++;
			sz390.tiot_file[cur_ves_tiot_index].seek(cb_xrba);
			sz390.tiot_file[cur_ves_tiot_index].write(cb_byte, 0, cb_len);
			if (get_vcb_buff(cur_ves_tiot_index, cb_xrba, cb_len) || vcb_alloc) {
				System.arraycopy(cb_byte, 0, vcb_byte, vcb_addr[vcb_index], cb_len);
			}
			if (tz390.opt_tracev) {
				tz390.put_trace("VSAM EXCP WRITE CB XRBA="
						+ tz390.get_long_hex(cb_xrba, 16) + " LEN="
						+ tz390.get_hex(cb_len, 8));
				sz390.dump_mem(cb, 0, cb_len); // RPI 723
			}
			sz390.tot_dcb_write++;
			sz390.tot_dcb_oper++;
			return true;
		} catch (final Exception e) {
			set_feedback(pdf_def, rc_phy, cmp_ves, rn_write_data_err);
			return false;
		}
	}

	/**
	 * Read control block in ves at xrba into cb byte array.
	 *
	 * @param cb_xrba
	 * @param cb_len
	 * @return
	 */
	private boolean read_ves_cb(final long cb_xrba, final int cb_len)
	{
		if (cb_xrba > tz390.max_file_size) {
			set_feedback(pdf_def, rc_log, cmp_ves, rn_inv_rba_req);
			return false;
		}
		try {
			// read ves at xrba into cb for cb_len
			if (cb_byte == null || cb_byte.length < cb_len) {
				cb_byte = new byte[cb_len];
				cb = ByteBuffer.wrap(cb_byte, 0, cb_len);
			}
			if (get_vcb_buff(cur_ves_tiot_index, cb_xrba, cb_len)) {
				tot_ves_cache++;
				System.arraycopy(vcb_byte, vcb_addr[vcb_index], cb_byte, 0, cb_len);
			} else {
				tot_ves_read++;
				// read ksds ves xrba+pri key
				sz390.tiot_file[cur_ves_tiot_index].seek(cb_xrba);
				sz390.tiot_file[cur_ves_tiot_index].read(cb_byte, 0, cb_len);
				if (vcb_alloc) {
					System.arraycopy(cb_byte, 0, vcb_byte, vcb_addr[vcb_index], cb_len);
				}
			}
			if (tz390.opt_tracev) {
				tz390.put_trace("VSAM EXCP READ CB XRBA="
						+ tz390.get_long_hex(cb_xrba, 16));
				sz390.dump_mem(cb, 0, cb_len); // RPI 723
			}
			sz390.tot_dcb_read++;
			sz390.tot_dcb_oper++;
			return true;
		} catch (final Exception e) {
			set_feedback(pdf_def, rc_phy, cmp_ves, rn_read_data_err);
			return false;
		}
	}

	/**
	 * Read ksds index entry with key at cur_vx0_xrba and set cur_ves_xrba and cur_key.
	 * @return
	 */
	private boolean read_ksds_index() {
		if (!read_xrba_ptr()) {
			return false;
		}
		if (cur_vx0_xrba + 8 > tz390.max_file_size) {
			set_feedback(pdf_def, rc_log, cmp_ves, rn_inv_rba_req);
			return false;
		}
		try {
			if (cur_key == null || cur_key.length < cur_vclr_klen) {
				cur_key = new byte[cur_vclr_klen];
				cur_key_buff = ByteBuffer.wrap(cur_key, 0, cur_vclr_klen);
			}
			if (get_vcb_buff(cur_vx0_tiot_index, cur_vx0_xrba + 8,
					cur_vclr_klen)) {
				tot_vxn_cache++;
				System.arraycopy(vcb_byte, vcb_addr[vcb_index], cur_key, 0, cur_vclr_klen);
			} else {
				tot_vxn_read++;
				// read ksds ves xrba+pri key
				sz390.tiot_file[cur_vx0_tiot_index].seek(cur_vx0_xrba + 8);
				sz390.tiot_file[cur_vx0_tiot_index].read(cur_key, 0, cur_vclr_klen);
				if (vcb_alloc) {
					System.arraycopy(cur_key, 0, vcb_byte, vcb_addr[vcb_index], cur_vclr_klen);
				}
			}
			if (tz390.opt_tracev) {
				tz390.put_trace("VSAM EXCP READ KSDS INDEX KEY XRBA="
						+ tz390.get_long_hex(cur_vx0_xrba + 8, 16));
				sz390.dump_mem(cur_key_buff, 0, cur_vclr_klen); // RPI 750

			}
			sz390.tot_dcb_read++;
			sz390.tot_dcb_oper++;
			return true;
		} catch (final Exception e) {
			set_feedback(pdf_def, rc_phy, cmp_vx0, rn_read_index_err);
			return false;
		}
	}

	/**
	 * Read ksir key at cur_ksir_rec + cur_vclr_koff into cur_key.
	 *
	 * @return
	 */
	private boolean read_ksir_key()
	{
		cur_ves_xrba = cur_ksir_rec;
		if (cur_ves_xrba < 0) {
			// read key even if rec deleted
			cur_ves_xrba = -cur_ves_xrba;
		}
		cur_ves_xrba = cur_ves_xrba + cur_vclr_koff;
		if (cur_ves_xrba > tz390.max_file_size) {
			set_feedback(pdf_def, rc_log, cmp_ves, rn_inv_rba_req);
			return false;
		}
		try {
			if (cur_key == null || cur_key.length < cur_vclr_klen) {
				cur_key = new byte[cur_vclr_klen];
				cur_key_buff = ByteBuffer.wrap(cur_key, 0, cur_vclr_klen);
			}
			if (get_vcb_buff(cur_ves_tiot_index, cur_ves_xrba, cur_vclr_klen)) {
				tot_vxn_cache++;
				System.arraycopy(vcb_byte, vcb_addr[vcb_index], cur_key, 0,
						cur_vclr_klen);
			} else {
				tot_vxn_read++;
				// read ksds rec key
				sz390.tiot_file[cur_ves_tiot_index].seek(cur_ves_xrba);
				sz390.tiot_file[cur_ves_tiot_index].read(cur_key, 0,
						cur_vclr_klen);
				if (vcb_alloc) {
					System.arraycopy(cur_key, 0, vcb_byte, vcb_addr[vcb_index],
							cur_vclr_klen);
				}
			}
			if (tz390.opt_tracev) {
				tz390.put_trace("VSAM EXCP READ KSIR KEY AT XRBA="
						+ tz390.get_long_hex(cur_ves_xrba, 16));
				sz390.dump_mem(cur_key_buff, 0, cur_vclr_klen); // RPI 723
			}
			sz390.tot_dcb_read++;
			sz390.tot_dcb_oper++;
			return true;
		} catch (Exception e) {
			set_feedback(pdf_def, rc_phy, cmp_ves, rn_read_data_err);
			return false;
		}
	}

	/**
	 * Read ves xrba prt in vx0 at cur_vx0_xrba and set cur_ves_xrba.
	 *
	 * @return
	 */
	private boolean read_xrba_ptr()
	{
		if (cur_vx0_xrba > tz390.max_file_size) {
			set_feedback(pdf_def, rc_log, cmp_ves, rn_inv_rba_req);
			return false;
		}
		try {
			if (get_vcb_buff(cur_vx0_tiot_index, cur_vx0_xrba, 8)) {
				tot_vxn_cache++;
				cur_ves_xrba = vcb_buff.getLong(vcb_addr[vcb_index]);
			} else {
				tot_vxn_read++;
				// read vrrds ves xrba
				sz390.tiot_file[cur_vx0_tiot_index].seek(cur_vx0_xrba);
				cur_ves_xrba = sz390.tiot_file[cur_vx0_tiot_index].readLong();
				if (vcb_alloc) {
					vcb_buff.putLong(vcb_addr[vcb_index], cur_ves_xrba);
				}
			}
			if (tz390.opt_tracev) {
				tz390.put_trace("VSAM EXCP READ  XRBA PTR AT VX0 XRBA="
						+ tz390.get_long_hex(cur_vx0_xrba, 16) + " VES XRBA="
						+ tz390.get_long_hex(cur_ves_xrba, 16));
			}
			sz390.tot_dcb_read++;
			sz390.tot_dcb_oper++;
			return true;
		} catch (final Exception e) {
			set_feedback(pdf_def, rc_phy, cmp_vx0, rn_write_index_err);
			return false;
		}
	}

	/**
	 * Write ksds primary index entry with last_ves_xrba ptr and key.
	 *
	 * @return
	 */
	private boolean write_ksds_index()
	{
		if (!write_xrba_ptr(cur_vx0_tiot_index, cur_vx0_xrba, last_ves_xrba)) {
			return false;
		}
		if (cur_vx0_xrba + 8 > tz390.max_file_size) {
			set_feedback(pdf_def, rc_log, cmp_ves, rn_inv_rba_req);
			return false;
		}
		try {
			tot_vxn_write++;
			// write ves xrba and key from rpl area + koff - 8
			sz390.tiot_file[cur_vx0_tiot_index].seek(cur_vx0_xrba + 8);
			sz390.tiot_file[cur_vx0_tiot_index].write(_pz390.mem_byte,
					cur_rpl_area + cur_vclr_koff, cur_vclr_klen);
			if (get_vcb_buff(cur_vx0_tiot_index, cur_vx0_xrba + 8, cur_vclr_klen)
					|| vcb_alloc) {
				System.arraycopy(_pz390.mem_byte, cur_rpl_area + cur_vclr_koff,
						vcb_byte, vcb_addr[vcb_index], cur_vclr_klen);
			}
			if (tz390.opt_tracev) {
				tz390.put_trace("VSAM EXCP WRITE KSDS  INDEX KEY XRBA="
						+ tz390.get_long_hex(cur_vx0_xrba + 8, 16));
				sz390.dump_mem(_pz390.mem, cur_rpl_area + cur_vclr_koff, cur_vclr_klen);
			}
			cur_vx0_xrba = cur_vx0_xrba + 8 + cur_vclr_klen;
			sz390.tot_dcb_write++;
			sz390.tot_dcb_oper++;
			return true;
		} catch (final Exception e) {
			set_feedback(pdf_def, rc_phy, cmp_vx0, rn_write_index_err);
			return false;
		}
	}

	/**
	 * Write ves rcd xrba ptr at vx0/ves(KSIR) index xrba in and update cache for reuse.
	 *
	 * @param tiot_index
	 * @param xrba_index
	 * @param xrba_rec
	 * @return
	 */
	private boolean write_xrba_ptr(final int tiot_index, final long xrba_index, final long xrba_rec)
	{
		if (xrba_index > tz390.max_file_size) {
			set_feedback(pdf_def, rc_log, cmp_ves, rn_inv_rba_req);
			return false;
		}
		try {
			// write index
			tot_vxn_write++;
			sz390.tiot_file[tiot_index].seek(xrba_index);
			sz390.tiot_file[tiot_index].writeLong(xrba_rec); // RPI 702
			if (get_vcb_buff(tiot_index, xrba_index, 8) || vcb_alloc) {
				vcb_buff.putLong(vcb_addr[vcb_index], xrba_rec);
			}
			if (tz390.opt_tracev) {
				tz390.put_trace("VSAM EXCP WRITE INDEX XRBA="
						+ tz390.get_long_hex(xrba_index, 16) + " VES XRBA="
						+ tz390.get_long_hex(xrba_rec, 16));
			}
			sz390.tot_dcb_write++;
			sz390.tot_dcb_oper++;
			return true;
		} catch (final Exception e) {
			set_feedback(pdf_def, rc_phy, cmp_vx0, rn_write_index_err);
			return false;
		}
	}

	/**
	 * Reset file length and tiot_eof addr for files being reused either due to reuse option or REPRO seq out options.
	 * 
	 * @param adcb
	 * @return
	 */
	private boolean reuse_file(final int adcb)
	{
		final int tiot_index = _pz390.mem.getInt(adcb + sz390.dcb_iobad) - 1;
		try {
			sz390.tiot_file[tiot_index].setLength(0);
			sz390.tiot_eof_rba[tiot_index] = 0;
			return true;
		} catch (final Exception e) {
			set_feedback(pdf_def, rc_phy, cmp_vx0, rn_write_index_err);
			return false;
		}
	}

	/**
	 * Backup to next record for ESDS SEQ BWD retrieval and return logical EOD error if at front of file.
	 *
	 * @return
	 */
	private boolean set_esds_bwd_next()
	{
		cur_ves_xrba = cur_rpl_cxrba;
		if (cur_ves_xrba == 0) {
			set_feedback(pdf_def, rc_log, cmp_ves, rn_eod);
			// return logical end of data to front of file
			return false;
		}
		if ((cur_vclr_flag & vclr_flag_vrec) != 0) {
			// Read prev rcd suffix record length at cur xrba - 4 and update tiot cur rec rba to rba - lrec - 8
			try {
				if (get_vcb_buff(cur_ves_tiot_index, cur_ves_xrba - 4, 4)) {
					tot_ves_cache++;
					cur_rpl_lrec = vcb_buff.getInt(vcb_addr[vcb_index]);
				} else {
					tot_ves_read++;
					// read var rec suffix length at xrba-4 to go backward
					sz390.tiot_file[cur_ves_tiot_index].seek(cur_ves_xrba - 4);
					cur_rpl_lrec = sz390.tiot_file[cur_ves_tiot_index].readInt();
					if (vcb_alloc) {
						vcb_buff.putInt(vcb_addr[vcb_index], cur_rpl_lrec);
					}
				}
				if (cur_rpl_lrec <= 0 || cur_rpl_lrec > cur_vclr_lrec) {
					if (tz390.opt_tracev) {
						tz390.put_trace("VSAM INVALID EXCP READ PREV SFX RECLEN="
										+ tz390.get_hex(cur_rpl_lrec, 8));
					}
					set_feedback(pdf_def, rc_log, cmp_ves, rn_inv_rec_len);
					return false;
				}
				bwd_xrba = cur_ves_xrba - cur_rpl_lrec - 8;
				if (bwd_xrba < 0) {
					if (tz390.opt_tracev) {
						tz390.put_trace("VSAM INVALID BWD XRBA="
								+ tz390.get_long_hex(bwd_xrba, 16) + "RECLEN="
								+ tz390.get_hex(cur_rpl_lrec, 8));
					}
					set_feedback(pdf_def, rc_log, cmp_ves, rn_inv_rec_len);
					return false;
				}
			} catch (final Exception e) {
				set_feedback(pdf_def, rc_phy, cmp_ves, rn_read_data_err);
				return false;
			}
		} else {
			bwd_xrba = cur_ves_xrba - cur_vclr_lrec;
			if (bwd_xrba < 0) {
				if (tz390.opt_tracev) {
					tz390.put_trace("VSAM INVALID BWD XRBA="
							+ tz390.get_long_hex(bwd_xrba, 16) + "RECLEN="
							+ tz390.get_hex(cur_rpl_lrec, 8));
				}
				set_feedback(pdf_def, rc_log, cmp_ves, rn_inv_rec_len);
				return false;
			}
		}
		set_rpl_cxrba(bwd_xrba);
		return true;
	}

	/**
	 * Compare key in RPLAREA+KEYOFF with key in last_vx0_key or cur_vx0_key array
	 * using comp_key_len set by rpl fetch -1, 0, 1 for low, equal, high.
	 *
	 * Notes:
	 * Set matching_key_bytes for generic key processing.
	 *
	 * @param key1_loc
	 * @param key_byte
	 * @return
	 */
	private int comp_key(int key1_loc, final byte[] key_byte) {
		/*
		 */
		int key1_end = key1_loc + cur_vclr_klen;
		int comp_key_end = key1_loc + comp_key_len;
		byte arg_key_byte = 0;
		int key2_loc = 0;
		while (key1_loc < key1_end) {
			if (key1_loc < comp_key_end) {
				arg_key_byte = _pz390.mem_byte[key1_loc];
			} else {
				arg_key_byte = 0;
			}
			if (arg_key_byte != key_byte[key2_loc]) {
				if ((arg_key_byte & 0xff) > (key_byte[key2_loc] & 0xff)) {
					comp_rc = 1;
				} else {
					comp_rc = -1;
				}
				if (key1_loc >= comp_key_end) {
					comp_key_gen_rc = 0;
				} else {
					comp_key_gen_rc = comp_rc;
				}
				return comp_rc;
			} else {
				key1_loc++;
				key2_loc++;
			}
		}
		comp_rc = 0;
		return comp_rc;
	}

	/**
	 * Compare key in RPLAREA+KEYOFF with high values RPI-779 using
	 * cur_vclr_klen -1, 0, 1 for low, equal, high.
	 *
	 * @return
	 */
	private boolean rpl_key_high_values()
	{
		int index = 0;
		while (index < cur_vclr_klen
				&& (_pz390.mem_byte[cur_rpl_arg + index] & 0xff) == 0xff) {
			;
			index++;
		}
		if (index == cur_vclr_klen) {
			return true;
		} else {
			return false;
		}
	}

	/**
	 * Get VSAM Cache Buffer (VCB) for file tiot_index, xrba, rec_len 
	 * 1. If rec_len > max_vcb_lrec return false.
	 * 2. search for allocated vcb If not found add new vcb up to max_vcb
	 *    else replace least recently used allocated vcb.
	 * 3. Set vcb_index and return true.
	 * 
	 * @param tiot_index
	 * @param xrba
	 * @param rec_len
	 * @return
	 */
	private boolean get_vcb_buff(int tiot_index, long xrba, int rec_len)
	{
		vcb_alloc = false;
		vcb_index = -1;
		if (!tz390.opt_vcb) {
			return false;
		}
		cur_vcb_tiot = tiot_index;
		cur_vcb_xrba = xrba;
		cur_vcb_lrec = rec_len;
		// tot_vcb_req++; // JBA-unused
		if (cur_vcb_lrec > max_vcb_lrec) {
			return false;
		}
		if (find_vcb()) {
			// vcb_index = matching VCB for read without I/O or for write update plus I/O to update file
			update_vcb_mru();
			// tot_vcb_hits++; // JBA-unused
			vcb_alloc = true;
			return true;
		}
		if (tot_vcb < max_vcb) {
			vcb_index = tot_vcb;
			tot_vcb++;
			vcb_addr[vcb_index] = cur_vcb_addr;
			cur_vcb_addr = cur_vcb_addr + max_vcb_lrec;
		} else {
			vcb_index = vcb_lru;
		}
		vcb_tiot[vcb_index] = cur_vcb_tiot;
		vcb_xrba[vcb_index] = cur_vcb_xrba;
		vcb_lrec[vcb_index] = cur_vcb_lrec;
		final int vcb_hash = calc_vcb_hash();
		vcb_hash_index[vcb_hash] = vcb_index; // replace hash
		update_vcb_mru();
		vcb_alloc = true;
		return false;
	}

	/**
	 * Move current vcb at vcb_index to most recently used (vcb_mru).
	 */
	private void update_vcb_mru()
	{
		// Remove current VCB from MRC list to allow moving it to top.
		final int next_vcb = vcb_mru_next[vcb_index];
		final int prev_vcb = vcb_mru_prev[vcb_index];
		if (prev_vcb > 0) {
			vcb_mru_next[prev_vcb] = next_vcb;
		}
		if (next_vcb > 0) {
			vcb_mru_prev[next_vcb] = prev_vcb;
		}
		// Update LRU if moving LRU to MRU.
		if (vcb_lru == vcb_index) {
			vcb_lru = vcb_mru_prev[vcb_index];
		}
		// Move vcb_index to top of MRU list.
		vcb_mru_prev[vcb_index] = 0;
		vcb_mru_next[vcb_index] = vcb_mru;
		if (vcb_mru > 0) {
			vcb_mru_prev[vcb_mru] = vcb_index;
		}
		vcb_mru = vcb_index;
	}

	/**
	 * Find matching vcb with same tiot, xrba, and record length
	 * If found set vcb_index and return true else false
	 *
	 * @return
	 */
	private boolean find_vcb()
	{
		vcb_index = -1;
		vcb_alloc = false;
		if (tot_vcb == 1) {
			return false;
		}
		final int vcb_hash = calc_vcb_hash();
		vcb_index = vcb_hash_index[vcb_hash];
		if (vcb_index > 0 && vcb_xrba[vcb_index] == cur_vcb_xrba
				&& vcb_lrec[vcb_index] == cur_vcb_lrec
				&& vcb_tiot[vcb_index] == cur_vcb_tiot) {
			vcb_alloc = true;
			return true;
		} else {
			return false;
		}
	}

	/**
	 * Calculate VCB hash index from tiot + xrba + lrec
	 *
	 * Notes:
	 * If two VCB requests generate same hash only the latest will be found and the
	 * prior one will eventually be replaced via LRU.
	 * 
	 * @return
	 */
	private int calc_vcb_hash()
	{
		// Return remainder using % mod operator.
		final int hash = ((int) ((cur_vcb_tiot + cur_vcb_xrba + cur_vcb_lrec) % max_vcb_hash));
		if (tz390.opt_traceall) {
			tz390.put_trace("VSAM VCB INDEX="
					+ tz390.right_justify("" + vcb_index, 4) + " HASH="
					+ tz390.right_justify("" + hash, 4) + " TIOT="
					+ cur_vcb_tiot + " XRBA="
					+ tz390.get_long_hex(cur_vcb_xrba, 16) + " LREC="
					+ tz390.right_justify("" + cur_vcb_lrec, 4));
		}
		return hash;
	}

	/**
	 * Read KSIT into cb array and set cur_ksit xrbas.
	 *
	 * @return
	 */
	private boolean read_ksit()
	{
		cur_rpl_flag = cur_rpl_flag | rpl_flag_ksit;
		cur_ksit_xrba = xrba_max_pos & cur_ves_xrba;
		if (read_ves_cb(cur_ksit_xrba, ksit_len)) {
			final int cur_ksit_id = cb.getInt(ksit_id); // C'KSIT'
			if (cur_ksit_id != ksit_id_val) {
				set_feedback(pdf_def, rc_phy, cmp_ves, rn_read_data_err);
				return false;
			}
			cur_ksit_top = cb.getLong(ksit_top);
			cur_ksit_fst = cb.getLong(ksit_fst);
			cur_ksit_lst = cb.getLong(ksit_lst);
			return true;
		} else {
			set_feedback(pdf_def, rc_phy, cmp_ves, rn_read_data_err);
			return false;
		}
	}

	/**
	 * Read KSIR int cb and set cur_ksit xrba's.
	 *
	 * @param xrba
	 * @return
	 */
	private boolean read_ksir(final long xrba)
	{
		cur_ksir_xrba = xrba;
		if (cur_ksir_xrba < cur_ksit_xrba) {
			// file corruption error as ksir's always beyond ksit
			set_feedback(pdf_def, rc_log, cmp_ves, rn_inv_rba_req);
			return false;
		}
		if (read_ves_cb(cur_ksir_xrba, ksir_len)) {
			final int cur_ksir_id = cb.getInt(ksir_id); // C'KSIR'
			if (cur_ksir_id != ksir_id_val) {
				set_feedback(pdf_def, rc_phy, cmp_ves, rn_read_data_err);
				return false;
			}
			cur_ksir_par  = cb.getLong(ksir_par);
			cur_ksir_low  = cb.getLong(ksir_low);
			cur_ksir_high = cb.getLong(ksir_high);
			cur_ksir_fwd  = cb.getLong(ksir_fwd);
			cur_ksir_bwd  = cb.getLong(ksir_bwd);
			cur_ksir_rec  = cb.getLong(ksir_rec);
			cur_ksir_low_height  = cb.get(ksir_low_height);
			cur_ksir_high_height = cb.get(ksir_high_height);
			cur_rpl_ksir = cur_ksir_xrba;
			return true;
		} else {
			set_feedback(pdf_def, rc_phy, cmp_ves, rn_read_data_err);
			return false;
		}
	}

	/**
	 * Rewrite ksds record following successful GET with UPD.
	 *
	 * @return
	 */
	private boolean update_ksds_rec()
	{
		cur_vx0_xrba = cur_rpl_lxrba;
		if (!read_ksds_index()) {
			return false;
		}
		if (cur_ves_xrba >= 0) {
			if (rewrite_ves_rec(cur_vx0_tiot_index, cur_vx0_xrba)) {
				return false;
			}
		} else {
			if (!read_ksir(cur_rpl_ksir)) {
				return false;
			}
			cur_ves_xrba = cur_ksir_rec;
			if (rewrite_ves_rec(-1, -1)) { // RPI 723
				return false;
			}
			if (cur_ves_xrba != cur_ksir_rec) { // RPI 723
				cur_ksir_rec = cur_ves_xrba;
				if (!write_ksir()) {
					return false;
				}
			}
		}
		return true;
	}

	/**
	 * Insert ksds record following unsuccessful GET with UPD.
	 *
	 * @return
	 */
	private boolean insert_ksds_rec()
	{
		if ((cur_rpl_flag & rpl_flag_ksit) != 0) {
			// insert in current KSIT
			if (!insert_ksir()) {
				return false;
			}
		} else if (cur_vx0_xrba + 8 + cur_vclr_klen >= sz390.tiot_eof_rba[cur_vx0_tiot_index]) {
			// add record to vx0 index at end
			cur_vx0_xrba = sz390.tiot_eof_rba[cur_vx0_tiot_index];
			if (!add_ves_rec(cur_vx0_tiot_index, cur_vx0_xrba)) {
				return false;
			}
		} else {
			// insert new KSIT for current vx0 index
			if (!insert_ksit()) {
				return false;
			}
		}
		return true;
	}

	/**
	 * Insert new KSIT for cur_vx0 entry with KSIR for existing record and KSIR for new inserted record.
	 *
	 * @return
	 */
	private boolean insert_ksit()
	{
		tot_avl_insert_ksit++;
		tot_avl_insert_ksir = tot_avl_insert_ksir + 2;
		if (tz390.opt_tracev){
			tz390.put_trace("VSAM AVL INSERT KSIT");
		}
		cur_ksit_xrba = alloc_ves(ksit_len);
		cur_ksit_fst = alloc_ves(ksir_len);
		cur_ksit_lst = alloc_ves(ksir_len);
		cur_ksit_top = cur_ksit_lst;
		if (!write_ksit()) {
			return false;
		}
		if (!read_ksds_index()) { // RPI 723
			return false;
		}
		if (comp_key(cur_rpl_arg, cur_key) > 0) {
			// write low ksir with existing index rec
			cur_ksir_xrba = cur_ksit_fst;
			cur_ksir_par = cur_ksit_lst; 
			cur_ksir_low = -1;
			cur_ksir_high = -1;
			cur_ksir_bwd = -1;
			cur_ksir_fwd = cur_ksit_lst;
			cur_ksir_rec = cur_ves_xrba;
			cur_ksir_low_height = 0;
			cur_ksir_high_height = 0;
			if (!write_ksir()) {
				return false;
			}
			// write new high ksir with existing index rec
			cur_ksir_xrba = cur_ksit_lst;
			cur_ksir_par = cur_ksit_xrba; 
			cur_ksir_low = cur_ksit_fst;
			cur_ksir_high = -1;
			cur_ksir_bwd = cur_ksit_fst;
			cur_ksir_fwd = -1;
			if (!add_ves_rec(-1, -1)) { // RPI 723
				return false;
			}
			cur_ksir_rec = last_ves_xrba; // RPI 723
			cur_ksir_low_height = 1; // RPI 806
			if (cur_ksir_low_height > max_avl_height){
				max_avl_height = cur_ksir_low_height;
			}
			cur_ksir_high_height = 0;
			if (!write_ksir()) {
				return false;
			}
			// rewrite the new vx0 neg ksit pointer
			if (!write_xrba_ptr(cur_vx0_tiot_index, cur_vx0_xrba, xrba_high_bit | cur_ksit_xrba)) {
				return false;
			}
		} else {
			// this is a new low key for first vx0 index KSIT insert
			// write high ksir for index rec first
			cur_ksir_xrba = cur_ksit_lst;
			cur_ksir_par = cur_ksit_fst;
			cur_ksir_low = cur_ksit_fst;
			cur_ksir_high = -1;
			cur_ksir_bwd = cur_ksit_fst;
			cur_ksir_fwd = -1;
			cur_ksir_rec = cur_ves_xrba;
			cur_ksir_low_height = 1; // RPI 806
			if (cur_ksir_low_height > max_avl_height){
				max_avl_height = cur_ksir_low_height;
			}
			cur_ksir_high_height = 0;
			if (!write_ksir()) {
				return false;
			}
			// write new low ksir
			cur_ksir_xrba = cur_ksit_fst;
			cur_ksir_par = cur_ksit_xrba;
			cur_ksir_low = -1;
			cur_ksir_high = -1;
			cur_ksir_bwd = -1;
			cur_ksir_fwd = cur_ksit_lst;
			if (!add_ves_rec(-1, -1)) {
				return false;
			}
			cur_ksir_rec = cur_ves_xrba;
			cur_ksir_low_height = 0;
			cur_ksir_high_height = 0;
			if (!write_ksir()) {
				return false;
			}
			// rewrite the new vx0 ksit neg pointer plus new index key
			last_ves_xrba = xrba_high_bit | cur_ksit_xrba; // RPI 723
			if (!write_ksds_index()) {
				return false;
			}
		}
		return true;
	}

	/**
	 * Return xrba of new ves cb/rec area and update eof xrba.
	 *
	 * @param cb_len
	 * @return
	 */
	private long alloc_ves(int cb_len)
	{
		final long xrba = sz390.tiot_eof_rba[cur_ves_tiot_index];
		sz390.tiot_eof_rba[cur_ves_tiot_index] = xrba + cb_len;
		return xrba;
	}

	/**
	 * Insert new KSIR to existing KSIT at current KSIR and balance AVT tree by rotating KSIR's if needed.
	 * @return
	 */
	private boolean insert_ksir()
	{
		long save_ksir_xrba = -1;
		long prev_ksir_xrba = 0;
		long prev_ksir_bwd = 0;
		long prev_ksir_fwd = 0;
		tot_avl_insert_ksir++;
		if (tz390.opt_tracev){
			tz390.put_trace("VSAM AVL INSERT KSIR");
		}
		if (!read_ksir(cur_rpl_ksir)) {
			return false;
		}
		if (!read_ksir_key()) {
			return false;
		}
		if (comp_key(cur_rpl_area, cur_key) < 0) {
			// insert on low side of cur ksir
			prev_ksir_xrba = cur_ksir_xrba;
			prev_ksir_bwd = cur_ksir_bwd;
			// rewrite cur ksir with ptrs to
			// new lower ksir
			cur_ksir_low = alloc_ves(ksir_len);
			cur_ksir_bwd = cur_ksir_low;
			if (!write_ksir()) {
				return false;
			}
			// write inserted record
			if (!add_ves_rec(-1, -1)) { // RPI 723
				return false;
			}
			cur_ksir_rec = last_ves_xrba; // RPI 723
			// write new inserted ksir
			cur_ksir_xrba = cur_ksir_low;
			cur_ksir_par = prev_ksir_xrba;
			cur_ksir_low = -1;
			cur_ksir_high = -1;
			cur_ksir_bwd = prev_ksir_bwd;
			cur_ksir_fwd = prev_ksir_xrba;
			cur_ksir_low_height = 0;
			cur_ksir_high_height = 0;
			if (!write_ksir()) {
				return false;
			}
			if (cur_ksir_bwd != -1) {
				// update fwd for bwd ksir
				save_ksir_xrba = cur_ksir_xrba;
				if (!read_ksir(cur_ksir_bwd)) {
					return false;
				}
				cur_ksir_fwd = save_ksir_xrba;
				if (!write_ksir()) {
					return false;
				}
			} else {
				// this is new lowest KSIR
				// update KSIT first KSIR pointer
				cur_ksit_fst = cur_ksir_xrba;
				if (!write_ksit()) {
					return false;
				}
				// rewrite the new vx0 ksit neg pointer plus new index key
				last_ves_xrba = xrba_high_bit | cur_ksit_xrba; // RPI 723
				if (!write_ksds_index()) {
					return false;
				}
			}
		} else {
			// insert on high side
			prev_ksir_xrba = cur_ksir_xrba;
			prev_ksir_fwd = cur_ksir_fwd;
			cur_ksir_high = alloc_ves(ksir_len);
			cur_ksir_fwd = cur_ksir_high;
			// rewrite cur with new KSIR on high side
			if (!write_ksir()) {
				// rewrite ksir with ptrs to new higher ksir
				return false;
			}
			// write new KSIR on high side
			cur_ksir_xrba = cur_ksir_high;
			cur_ksir_par = prev_ksir_xrba;
			cur_ksir_low = -1;
			cur_ksir_high = -1;
			cur_ksir_bwd = prev_ksir_xrba;
			cur_ksir_fwd = prev_ksir_fwd;
			if (!add_ves_rec(-1, -1)) { // RPI 723
				return false;
			}
			cur_ksir_rec = last_ves_xrba; // RPI 723
			cur_ksir_low_height = 0;
			cur_ksir_high_height = 0;
			// write new KSIR
			if (!write_ksir()) {
				return false;
			}
			if (cur_ksir_fwd != -1) {
				// update bwd for fwd ksir
				save_ksir_xrba = cur_ksir_xrba;
				if (!read_ksir(cur_ksir_fwd)) {
					return false;
				}
				cur_ksir_bwd = save_ksir_xrba;
				if (!write_ksir()) {
					return false;
				}
			} else {
				// this is new highest KSIR in KSIT
				// update ksit last KSIR
				cur_ksit_lst = cur_ksir_xrba;
				if (!write_ksit()) {
					return false;
				}
			}
		}
		if (save_ksir_xrba != -1){
			if (!read_ksir(save_ksir_xrba)){
				return false;
			}
		}
		if (!avl_update_height()){
			// error while checking balance
			return false;
		}
		if (avl_unbalanced
			&& !avl_rotate_ksir()){
			// error while rotating KSIR
			return false;
		}
		return true;
	}

	/**
	 * Search up KSIR nodes from insertion and perform the following steps:
	 *   1.  Increment height of all nodes on path prior to unbalanced node.
	 *   2.  Find first (and only) node which may be unbalanced (left vs right height differs by 2).
	 *   3.  If unbalanced node found, set avl_unbalanced and avl_r_xrba 
	 * Notes:
	 *   1.  Only returns false if I/O error
	 *
	 * @return
	 */
	private boolean avl_update_height()
	{
		avl_unbalanced = false;
		long save_ksir_xrba = cur_ksir_xrba; // save insert
		// start with node above inserted record
		long prev_node_xrba = cur_ksir_xrba; // previous ksir on path
		// byte cur_node_height = 0; // JBA - Unused (no reads).
		long cur_node_xrba = cur_ksir_par; // current node on path to insert
		if (tz390.opt_tracev) {
			tz390.put_trace("VSAM AVL UPDATE HEIGHT");
		}
		while (cur_node_xrba != cur_ksit_xrba){
			// read next node to update height
			if (!read_ksir(cur_node_xrba)){
				return false;
			}
			if (   cur_ksir_low  != prev_node_xrba
				&& cur_ksir_high != prev_node_xrba){
				broken_ksir_link("PAR",cur_ksir_xrba,prev_node_xrba);
				return false;
			}
			if (cur_ksir_low == prev_node_xrba){
				// update height on low side if cur node
				if (cur_ksir_low_height - cur_ksir_high_height >= 1){
					// node unbalanced - rotate left
					avl_unbalanced = true;
					avl_left = true;
					avl_r_xrba = cur_node_xrba;
					cur_ksir_xrba = save_ksir_xrba;
					// exit with updated r to rotate
					// in cur ksir (not written)
					return true;
				}
				cur_ksir_low_height++;
				if (cur_ksir_low_height > max_avl_height){
					max_avl_height = cur_ksir_low_height;
				}
				if (!write_ksir()){
					// write updated node heights
					return false;
				}
				if (cur_ksir_low_height == cur_ksir_high_height){
					// done with updates if not high
					cur_ksir_xrba = save_ksir_xrba;
					return true;
				} else if (cur_ksir_low_height < cur_ksir_high_height){
					unbalanced_ksir_error("LEFT UPDATE ");
					return false;
				}
			} else {
				// update height on high side
				if (cur_ksir_high_height - cur_ksir_low_height >= 1){
					// node unbalanced - rotate right
					avl_unbalanced = true;
					avl_left = false;
					avl_r_xrba = cur_node_xrba;
					cur_ksir_xrba = save_ksir_xrba;
					// exit with updated r to rotate
					// note not written yet
					return true;
				}
				cur_ksir_high_height++;
				if (cur_ksir_high_height > max_avl_height){
					max_avl_height = cur_ksir_high_height;
				}
				if (!write_ksir()){
					// write updated node heights
					return false;
				}
				if (cur_ksir_low_height == cur_ksir_high_height){
					// done with update if equal
					cur_ksir_xrba = save_ksir_xrba;
					return true;
				} else if (cur_ksir_high_height < cur_ksir_low_height){
					unbalanced_ksir_error("RIGHT UPDATE");
					return false;
				}
			}
			prev_node_xrba = cur_ksir_xrba;
			cur_node_xrba = cur_ksir_par;
			// cur_node_height++; // JBA - Unused.
		}
		cur_ksir_xrba = save_ksir_xrba;
		return true;
	}

	/**
	 * Verify updated T1-T4 within +-1
	 * @param type
	 * @param t1
	 * @param t2
	 * @param t3
	 * @param t4
	 * @return
	 */
	private boolean check_heights(final String type, final byte t1, final byte t2, final byte t3, final byte t4)
	{
		if (   Math.abs(t1-t2) > 1
			|| Math.abs(t1-t3) > 1
			|| Math.abs(t1-t4) > 1
			|| Math.abs(t2-t3) > 1
			|| Math.abs(t2-t4) > 1
			|| Math.abs(t3-t4) > 1) {
			unbalanced_ksir_error(type);
			return false;
		}
		return true;  
	}

	/**
	 * Display unbalanced KSIR found.
	 * @param type
	 */
	private void unbalanced_ksir_error(final String type)
	{
		sz390.put_log("VSAM AVL UNBALANCED KSIR ERROR TYPE " + type);
		set_feedback(pdf_def, rc_phy, cmp_ves, rn_read_data_err);
	}

	/**
	 * Perform AVL rotation around the last avl_r_xrba found during find_ksir prior to insert.
	 * Note the KSIR to be rotated may be anywhere between the inserted KSIR and the KSIT.
	 * Only one rotation is required per insert.
	 *
	 * @return
	 */
	private boolean avl_rotate_ksir() {
		/*
		 * The AVL tree is named after its two inventors
		 * G.M. Adelson-Velsky and E.M. Landis. who published it in their 1962
		 * paper "An algorithm for the organization of information."
		 * 
		 * For good overview of the process to maintain balanced tree during
		 * random insertions, see * *
		 * http://sky.fit.qut.edu.au/~maire/avl/System/AVLTree.html
		 * In summary the process is as follows: 
		 * 1. Following binary search of tree to insert record at correct node, update
		 *    current and parent nodes to 1 of 3 possible states: 
		 *    a. left/low side +1 depth (high bit in cur_ksir_low) 
		 *    b. even 
		 *    c. right/high side +1 depth (high bit in cur_ksir_high) 
		 * 2. If node found with new +2 state, rotate as follows
		 *    to rebalance which ends the update process. 
		 *    a. LL - move left  left node up one level by swapping n ode with left node. 
		 *    b. RR - move right right node up one level by swapping node with right node 
		 *    c. LR - move left  right node up one level by swapping node with left right node.
		 *    d. RL - move right left node up one level by swapping mode with right left node.
		 */
		tot_avl_rotate++;
		final long save_ksir_xrba = cur_ksir_xrba; // save insert ksir
		if (!read_ksir(avl_r_xrba)){
			return false;
		}
		avl_r_par = cur_ksir_par;
		avl_r_low = cur_ksir_low;
		avl_r_high = cur_ksir_high;
		avl_r_low_height  = cur_ksir_low_height;
		avl_r_high_height = cur_ksir_high_height;
		if (avl_left){
			if (!read_ksir(avl_r_low)){
				return false;
			}
			if (cur_ksir_par != avl_r_xrba){
				broken_ksir_link("PAR",cur_ksir_xrba,save_ksir_xrba);
				return false;
			}
			avl_x_xrba = cur_ksir_xrba;
			avl_x_low  = cur_ksir_low;
			avl_x_high = cur_ksir_high;
			avl_x_low_height  = cur_ksir_low_height;
			avl_x_high_height = cur_ksir_high_height;
			if (cur_ksir_low_height > cur_ksir_high_height){
				if (!avl_rotate_left_left()){
					return false;
				}
			} else {
				if (!avl_rotate_left_right()){
					return false;
				}
			}
		} else {
			if (!read_ksir(avl_r_high)){
				return false;
			}
			if (cur_ksir_par != avl_r_xrba){
				broken_ksir_link("PAR",cur_ksir_xrba,save_ksir_xrba);
				return false;
			}
			avl_x_xrba = cur_ksir_xrba;
			avl_x_low  = cur_ksir_low;
			avl_x_high = cur_ksir_high;
			avl_x_low_height  = cur_ksir_low_height;
			avl_x_high_height = cur_ksir_high_height;
			if (cur_ksir_high_height > cur_ksir_low_height){
				if (!avl_rotate_right_right()){
					return false;
				}
			} else {
				if (!avl_rotate_right_left()){
					return false;
				}
			}
		}
		cur_ksir_xrba = save_ksir_xrba; // restore to inserted ksir
		return true;
	}

	/**
	 * avl rotate x to r, and r to x_high, and x_high to r_low.
	 *
	 * @return
	 */
	private boolean avl_rotate_left_left()
	{
		tot_avl_rotate_ll++;
		if (tz390.opt_tracev){
			tz390.put_trace("VSAM AVL ROTATE LEFT LEFT");
		}
		// verify heights T1=T2=T3-1
		if (!check_heights("LEFT LEFT",(byte)(avl_x_low_height -1),
				avl_r_high_height,avl_x_high_height,avl_x_high_height)) {
			return false;
		}
		// Update x which is current ksir with new parent and new high ptr to r
		cur_ksir_par = avl_r_par;
		cur_ksir_high = avl_r_xrba;
		cur_ksir_high_height = (byte)(Math.max(avl_r_high_height,avl_x_high_height) + 1); // max T2,T3 +1
		if (!write_ksir()){
			return false;
		}
		// Update parent KSIR or KSIT
		if (avl_r_par == cur_ksit_xrba){
			// update KSIT with ptr to x
			cur_ksit_top = avl_x_xrba;
			if (!write_ksit()){
				return false;
			}
		} else {
			// update parent KSIR with ptr to x
			if (!read_ksir(avl_r_par)){
				return false;
			}
			if (cur_ksir_low == avl_r_xrba){
				cur_ksir_low = avl_x_xrba;
			} else if (cur_ksir_high == avl_r_xrba){
				cur_ksir_high = avl_x_xrba;
			} else {
				broken_ksir_link("PAR",cur_ksir_xrba,avl_r_xrba);
				return false;
			}
			if (!write_ksir()){
				return false;
			}
		}
		// Update r with new x par and new x high replacing r low
		if (!read_ksir(avl_r_xrba)){
			return false;
		}
		cur_ksir_par = avl_x_xrba;
		cur_ksir_low = avl_x_high; 
		cur_ksir_low_height = avl_x_high_height; // copy T2
		if (!write_ksir()){
			return false;
		}
		// update x_high (T2) par to r
		if (avl_x_high != -1){
			if (!read_ksir(avl_x_high)){
				return false;
			}
			cur_ksir_par = avl_r_xrba;
			if (!write_ksir()){
				return false;
			}
		}
		return true;
	}

	/**
	 * avl rotate w (x_high) to r, r to w_high, w_low to x_high, and w_high to r_low.
	 *
	 * @return
	 */
	private boolean avl_rotate_left_right()
	{
		tot_avl_rotate_lr++;
		if (tz390.opt_tracev){
			tz390.put_trace("VSAM AVL ROTATE LEFT RIGHT");
		}
		// Read and update w first with new r parent, x low, r high
		if (!read_ksir(avl_x_high)){
			return false;
		}
		avl_w_xrba = cur_ksir_xrba;
		avl_w_low  = cur_ksir_low;
		avl_w_high = cur_ksir_high;
		avl_w_low_height  = cur_ksir_low_height;
		avl_w_high_height = cur_ksir_high_height;
		// verify heights T1=T2=T3=T4
		if (!check_heights("LEFT RIGHT"
				,avl_x_low_height,avl_w_low_height
				,avl_w_high_height,avl_r_high_height)){
			return false;
		}
		cur_ksir_par  = avl_r_par;
		cur_ksir_low  = avl_x_xrba;
		cur_ksir_high = avl_r_xrba;
		cur_ksir_low_height  = (byte)(Math.max(avl_x_low_height,avl_w_low_height) + 1); 
		cur_ksir_high_height = (byte)(Math.max(avl_w_high_height,avl_r_high_height) + 1);
		if (!write_ksir()){
			return false;
		}
		// update parent KSIR or KSIT
		if (avl_r_par == cur_ksit_xrba){
			// update KSIT with ptr to x
			cur_ksit_top = avl_w_xrba;
			if (!write_ksit()){
				return false;
			}
		} else {
			// update parent KSIR with ptr to x
			if (!read_ksir(avl_r_par)){
				return false;
			}
			if (cur_ksir_low == avl_r_xrba){
				cur_ksir_low = avl_w_xrba;
			} else if (cur_ksir_high == avl_r_xrba){
				cur_ksir_high = avl_w_xrba;
			} else {
				broken_ksir_link("PAR",cur_ksir_xrba,avl_r_xrba);
				return false;
			}
			if (!write_ksir()){
				return false;
			}
		}
		// update w_high (T3) par to r
		if (avl_w_high != -1){
			if (!read_ksir(avl_w_high)){
				return false;
			}
			cur_ksir_par = avl_r_xrba;
			if (!write_ksir()){
				return false;
			}
		}
		// Update r with new w par and new w high replacing r low
		if (!read_ksir(avl_r_xrba)){
			return false;
		}
		cur_ksir_par = avl_w_xrba;
		cur_ksir_low = avl_w_high;
		cur_ksir_low_height = avl_w_high_height; // copy T3
		if (!write_ksir()){
			return false;
		}
		// Update x with new w parent and new w low replacing x high
		if (!read_ksir(avl_x_xrba)){
			return false;
		}
		cur_ksir_par  = avl_w_xrba;
		cur_ksir_high = avl_w_low;
		cur_ksir_high_height = avl_w_low_height; // copy T2`
		if (!write_ksir()){
			return false;
		}
		// update w_low (T2) par to x
		if (avl_w_low != -1){
			if (!read_ksir(avl_w_low)){
				return false;
			}
			cur_ksir_par = avl_x_xrba;
			if (!write_ksir()){
				return false;
			}
		}
		return true;
	}

	/**
	 * avl rotate x to r, and r to x_low, and x_low to r_high.
	 *
	 * @return
	 */
	private boolean avl_rotate_right_right()
	{
		tot_avl_rotate_rr++;
		if (tz390.opt_tracev) {
			tz390.put_trace("VSAM AVL ROTATE RIGHT RIGHT");
		}

		// Verify heights T1=T2=T3-1
		if (!check_heights("RIGHT RIGHT", avl_r_low_height, avl_x_low_height, (byte)(avl_x_high_height -1), (byte)(avl_x_high_height -1))) {
			return false;
		}

		// Update x which is current ksir with new parent and new high ptr to r.
		cur_ksir_par = avl_r_par;
		cur_ksir_low = avl_r_xrba;
		cur_ksir_low_height = (byte)(Math.max(avl_r_low_height,avl_x_low_height) + 1); // max T1,T2 +1
		if (!write_ksir()){
			return false;
		}

		// Update parent KSIR or KSIT.
		if (avl_r_par == cur_ksit_xrba){
			// update KSIT with ptr to x
			cur_ksit_top = avl_x_xrba;
			if (!write_ksit()){
				return false;
			}
		} else {
			// update parent KSIR with ptr to x
			if (!read_ksir(avl_r_par)){
				return false;
			}
			if (cur_ksir_low == avl_r_xrba){
				cur_ksir_low = avl_x_xrba;
			} else if(cur_ksir_high == avl_r_xrba) {
				cur_ksir_high = avl_x_xrba;
			} else {
				broken_ksir_link("PAR",cur_ksir_xrba,avl_r_xrba);
				return false;
			}
			if (!write_ksir()){
				return false;
			}
		}
		// update x_low (T2) par to r
		if (avl_x_low != -1){
			if (!read_ksir(avl_x_low)){
				return false;
			}
			cur_ksir_par = avl_r_xrba;
			if (!write_ksir()){
				return false;
			}
		}
		// Update r with new x par and new x low replacing r high
		if (!read_ksir(avl_r_xrba)){
			return false;
		}
		cur_ksir_par = avl_x_xrba;
		cur_ksir_high = avl_x_low;
		cur_ksir_high_height = avl_x_low_height; // copy T2
		if (!write_ksir()){
			return false;
		}
		return true;
	}

	/**
	 * avl rotate w (x_low) to r, r to w_low, w_high to x_low, and w_low to r_high.
	 *
	 * @return
	 */
	private boolean avl_rotate_right_left()
	{
		tot_avl_rotate_rl++;
		if (tz390.opt_tracev){
			tz390.put_trace("VSAM AVL ROTATE RIGHT LEFT");
		}

		// Read and update w first with new r parent, r low, x high
		if (!read_ksir(avl_x_low)) {
			return false;
		}
		avl_w_xrba = cur_ksir_xrba;
		avl_w_low  = cur_ksir_low;
		avl_w_high = cur_ksir_high;
		avl_w_low_height  = cur_ksir_low_height;
		avl_w_high_height = cur_ksir_high_height;

		// Verify heights T1=T2=T3=T4
		if (!check_heights("RIGHT LEFT", avl_r_low_height, avl_w_low_height, avl_w_high_height, avl_x_high_height)) {
			return false;
		}
		cur_ksir_par  = avl_r_par;
		cur_ksir_low  = avl_r_xrba;
		cur_ksir_high = avl_x_xrba;
		cur_ksir_low_height  = (byte)(Math.max(avl_r_low_height, avl_w_low_height ) + 1); 
		cur_ksir_high_height = (byte)(Math.max(avl_w_high_height,avl_x_high_height) + 1);
		if (!write_ksir()) {
			return false;
		}

		// Update parent KSIR or KSIT
		if (avl_r_par == cur_ksit_xrba){
			// update KSIT with ptr to x
			cur_ksit_top = avl_w_xrba;
			if (!write_ksit()) {
				return false;
			}
		} else {
			// update parent KSIR with ptr to x
			if (!read_ksir(avl_r_par)) {
				return false;
			}
			if (cur_ksir_low == avl_r_xrba){
				cur_ksir_low = avl_w_xrba;
			} else if (cur_ksir_high == avl_r_xrba){
				cur_ksir_high = avl_w_xrba;
			} else {
				broken_ksir_link("PAR",cur_ksir_xrba,avl_r_xrba);
				return false;
			}
			if (!write_ksir()){
				return false;
			}
		}

		// Update r with new w par and new w low replacing r high.
		if (!read_ksir(avl_r_xrba)){
			return false;
		}
		cur_ksir_par  = avl_w_xrba;
		cur_ksir_high = avl_w_low;
		cur_ksir_high_height = avl_w_low_height; // copy T2
		if (!write_ksir()){
			return false;
		}
		// update w_low (T2) par to r
		if (avl_w_low != -1){
			if (!read_ksir(avl_w_low)){
				return false;
			}
			cur_ksir_par = avl_r_xrba;
			if (!write_ksir()){
				return false;
			}
		}

		// Update x with new w parent and new w high replacing x low.
		if (!read_ksir(avl_x_xrba)){
			return false;
		}
		cur_ksir_par  = avl_w_xrba;
		cur_ksir_low  = avl_w_high;
		cur_ksir_low_height = avl_w_high_height; // copy T3
		if (!write_ksir()){
			return false;
		}
		// update w_high (T3) par to x
		if (avl_w_high != -1){
			if (!read_ksir(avl_w_high)){
				return false;
			}
			cur_ksir_par = avl_x_xrba;
			if (!write_ksir()){
				return false;
			}
		}
		return true;
	}

	/**
	 * Write new KSIT at ves eof xrba.
	 *
	 * @return
	 */
	private boolean write_ksit()
	{
		if (cb_byte == null || cb_byte.length < ksit_len) {
			cb_byte = new byte[ksit_len];
			cb = ByteBuffer.wrap(cb_byte, 0, ksit_len);
		}
		cb.putInt( ksit_id,  ksit_id_val);
		cb.putLong(ksit_top, cur_ksit_top);
		cb.putLong(ksit_fst, cur_ksit_fst);
		cb.putLong(ksit_lst, cur_ksit_lst);
		if (!write_ves_cb(cur_ksit_xrba, ksit_len)) {
			return false;
		}
		cur_rpl_ksit = cur_ksit_xrba;
		return true;
	}

	/**
	 * Write ves KSIR at cur_ksir_xrba.
	 *
	 * @return
	 */
	private boolean write_ksir()
	{
		if (cb_byte == null || cb_byte.length < ksir_len) {
			cb_byte = new byte[ksir_len];
			cb = ByteBuffer.wrap(cb_byte, 0, ksir_len);
		}
		cb.putInt( ksir_id,   ksir_id_val);
		cb.putLong(ksir_par,  cur_ksir_par);
		cb.putLong(ksir_low,  cur_ksir_low);
		cb.putLong(ksir_high, cur_ksir_high);
		cb.putLong(ksir_bwd,  cur_ksir_bwd);
		cb.putLong(ksir_fwd,  cur_ksir_fwd);
		cb.putLong(ksir_rec,  cur_ksir_rec);
		cb.put(ksir_low_height, cur_ksir_low_height);
		cb.put(ksir_high_height, cur_ksir_high_height);
		if (!write_ves_cb(cur_ksir_xrba, ksir_len)) {
			return false;
		}
		return true;
	}
}
