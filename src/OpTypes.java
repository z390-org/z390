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
 * Helper class containing op type length and op type information.
 *
 * @author jba68/z390
 */
public class OpTypes {

	final static int[] op_type_len = {
			0, // 0 comment place holder	
			2, // 1 "E"     8 PR    oooo
			2, // 2 "RR"   60 LR    oorr
			2, // 3 "BRX"  16 BER   oomr
			2, // 4 "I"     1 SVC   00ii
			4, // 5 "RX"   52 L     oorxbddd
			4, // 6 "BCX"  16 BE    oomxbddd
			4, // 7 "S"    43 SPM   oo00bddd
			4, // 8 "DM"    1 DIAGNOSE 83000000
			4, // 9 "RSI"   4 BRXH  oorriiii
			4, //10 "RS"   25       oorrbddd
			4, //11 "SI"    9 CLI   ooiibddd
			4, //12 "RI"   37 IIHH  ooroiiii
			4, //13 "BRCX" 31 BRE   oomoiiii
			4, //14 "RRE" 185 MSR   oooo00rr
			4, //15 "RRF1" 28 MAER  oooor0rr (r1,r3,r2 maps to r1,r3,r2)
			6, //16 "RIL"   6 BRCL  oomollllllll
			6, //17 "SS"   32 MVC   oollbdddbddd  
			6, //18 "RXY"  76 MLG   oorxbdddhhoo
			6, //19 "SSE"   5 LASP  oooobdddbddd
			6, //20 "RSY"  31 LMG   oorrbdddhhoo
			6, //21 "SIY"   6 TMY   ooiibdddhhoo
			6, //22 "RSL"   1 TP    oor0bddd00oo
			6, //23 "RIE"   4 BRXLG oorriiii00oo
			6, //24 "RXE"  28 ADB   oorxbddd00oo
			6, //25 "RXF"   8 MAE   oorxbdddr0oo (note r3 before r1)
			6, //26  AP  SS2  oollbdddbddd
			6, //27  PLO SS3  oorrbdddbddd  r1,s2,r3,s4
			6, //28  LMD SS5  oorrbdddbddd  r1,r3,s2,s4
			6, //29  SRP SS2  oolibdddbddd s1(l1),s2,i3
			4, //30 "RRF3" 30 DIEBR oooormrr (r1,r3,r2,m4 maps to r3,m4,r1,r2) RPI 407 fix (was 6)
			6, //31 "SS" PKA oollbdddbddd  ll from S2 
			6, //32 "SSF" MVCOS oor0bdddbddd (s1,s2,r3) z9-41
			6, //33 "BLX" BRCL  oomollllllll (label)
			4, //34 "RRF2" FIXBR oooom0rr (r1,m3,r2 maps to m3,r1,r2) RPI 407 fix was 6
			4, //35 "FFR4" CSDTR oooo0mrr (r1,r2,m4 maps to m4,r1,r2) RPI 407 add new
			4, //36 "RRR"  
			4, //37 "RXAS" RX    if ASSIST
			6, //38 "RXSS" RX-SS if ASSIST else PKU x'E1'
			4, //39 "RRF5" CRT   RPI 817
			4, //40 "RRF6" CRTE  RPI 817
			6, //41 "RIE2" CIT   RPI 817
			6, //42 "RIE3" CITE  RPI 817
			6, //43 "RIE4" CGIJ  RPI 817
			6, //44 "RIE5" CGIJE RPI 817
			6, //45 "RRS1" CGRB  RPI 817
			6, //46 "RRS2" CGRBE RPI 817
			6, //47 "RRS3" CGIB  RPI 817
			6, //48 "RRS4" CGIBE RPI 817
			6, //49 "RIE6" CGRJ  RPI 817
			6, //50 "RIE7" CGRJE RPI 817
			6, //51 "SIL"  MVHHI RPI 817
			6, //52 "RIE2"
			4, //53 
			4, //54
			6, //55
			6, //56
			6  //57
	};

//	final static int max_op_type_offset = 57; // see changes required RPI 812, RPI 817, RPI 1125
	final static int max_op_type_offset = op_type_len.length-1;

	final static int[] op_type = {
			0,  // comments
			1,  // 10 "0101" "PR" "E" 1
			1,  // 20 "0102" "UPT" "E" 1
			1,  //    "0104" "PTFF" "E" 1 Z9-1
			1,  // 30 "0107" "SCKPF" "E" 1
			1,  // 40 "010A" "PFPO" "E" 1   RPI 1013
			1,  // 40 "010B" "TAM" "E" 1
			1,  // 50 "010C" "SAM24" "E" 1
			1,  // 60 "010D" "SAM31" "E" 1
			1,  // 70 "010E" "SAM64" "E" 1
			1,  // 80 "01FF" "TRAP2" "E" 1
			2,  // 90 "04" "SPM" "RR" 2
			2,  // 100 "05" "BALR" "RR" 2
			2,  // 110 "06" "BCTR" "RR" 2
			2,  // 120 "07" "BCR" "RR" 2
			3,  // 130 "07F" "BR" "BRX" 3
			3,  // 140 "070" "NOPR" "BRX" 3
			3,  // 150 "072" "BHR" "BRX" 3
			3,  // 160 "074" "BLR" "BRX" 3
			3,  // 170 "078" "BER" "BRX" 3
			3,  // 180 "07D" "BNHR" "BRX" 3
			3,  // 190 "07B" "BNLR" "BRX" 3
			3,  // 200 "077" "BNER" "BRX" 3
			3,  // 210 "072" "BPR" "BRX" 3
			3,  // 220 "071" "BOR" "BRX" 3
			3,  // 230 "074" "BMR" "BRX" 3
			3,  // 240 "078" "BZR" "BRX" 3
			3,  // 250 "07D" "BNPR" "BRX" 3
			3,  // 260 "07B" "BNMR" "BRX" 3
			3,  // 270 "077" "BNZR" "BRX" 3
			3,  // 280 "07E" "BNOR" "BRX" 3
			4,  // 290 "0A" "SVC" "I" 4
			2,  // 300 "0B" "BSM" "RR" 2
			2,  // 310 "0C" "BASSM" "RR" 2
			2,  // 320 "0D" "BASR" "RR" 2
			2,  // 330 "0E" "MVCL" "RR" 2
			2,  // 340 "0F" "CLCL" "RR" 2
			2,  // 350 "10" "LPR" "RR" 2
			2,  // 360 "11" "LNR" "RR" 2
			2,  // 370 "12" "LTR" "RR" 2
			2,  // 380 "13" "LCR" "RR" 2
			2,  // 390 "14" "NR" "RR" 2
			2,  // 400 "15" "CLR" "RR" 2
			2,  // 410 "16" "OR" "RR" 2
			2,  // 420 "17" "XR" "RR" 2
			2,  // 430 "18" "LR" "RR" 2
			2,  // 440 "19" "CR" "RR" 2
			2,  // 450 "1A" "AR" "RR" 2
			2,  // 460 "1B" "SR" "RR" 2
			2,  // 470 "1C" "MR" "RR" 2
			2,  // 480 "1D" "DR" "RR" 2
			2,  // 490 "1E" "ALR" "RR" 2
			2,  // 500 "1F" "SLR" "RR" 2
			2,  // 510 "20" "LPDR" "RR" 2
			2,  // 520 "21" "LNDR" "RR" 2
			2,  // 530 "22" "LTDR" "RR" 2
			2,  // 540 "23" "LCDR" "RR" 2
			2,  // 550 "24" "HDR" "RR" 2
			2,  // 560 "25" "LDXR" "RR" 2
			2,  // 570 "25" "LRDR" "RR" 2
			2,  // 580 "26" "MXR" "RR" 2
			2,  // 590 "27" "MXDR" "RR" 2
			2,  // 600 "28" "LDR" "RR" 2
			2,  // 610 "29" "CDR" "RR" 2
			2,  // 620 "2A" "ADR" "RR" 2
			2,  // 630 "2B" "SDR" "RR" 2
			2,  // 640 "2C" "MDR" "RR" 2
			2,  // 650 "2D" "DDR" "RR" 2
			2,  // 660 "2E" "AWR" "RR" 2
			2,  // 670 "2F" "SWR" "RR" 2
			2,  // 680 "30" "LPER" "RR" 2
			2,  // 690 "31" "LNER" "RR" 2
			2,  // 700 "32" "LTER" "RR" 2
			2,  // 710 "33" "LCER" "RR" 2
			2,  // 720 "34" "HER" "RR" 2
			2,  // 730 "35" "LEDR" "RR" 2
			2,  // 740 "35" "LRER" "RR" 2
			2,  // 750 "36" "AXR" "RR" 2
			2,  // 760 "37" "SXR" "RR" 2
			2,  // 770 "38" "LER" "RR" 2
			2,  // 780 "39" "CER" "RR" 2
			2,  // 790 "3A" "AER" "RR" 2
			2,  // 800 "3B" "SER" "RR" 2
			2,  // 810 "3C" "MDER" "RR" 2
			2,  // 820 "3C" "MER" "RR" 2
			2,  // 830 "3D" "DER" "RR" 2
			2,  // 840 "3E" "AUR" "RR" 2
			2,  // 850 "3F" "SUR" "RR" 2
			5,  // 860 "40" "STH" "RX" 5
			5,  // 870 "41" "LA" "RX" 5
			5,  // 880 "42" "STC" "RX" 5
			5,  // 890 "43" "IC" "RX" 5
			5,  // 900 "44" "EX" "RX" 5
			5,  // 910 "45" "BAL" "RX" 5
			5,  // 920 "46" "BCT" "RX" 5
			5,  // 930 "47" "BC" "RX" 5
			6,  // 940 "47F" "B" "BCX" 6
			6,  // 950 "470" "NOP" "BCX" 6
			6,  // 960 "472" "BH" "BCX" 6
			6,  // 970 "474" "BL" "BCX" 6
			6,  // 980 "478" "BE" "BCX" 6
			6,  // 990 "47D" "BNH" "BCX" 6
			6,  // 1000 "47B" "BNL" "BCX" 6
			6,  // 1010 "477" "BNE" "BCX" 6
			6,  // 1020 "472" "BP" "BCX" 6
			6,  // 1030 "471" "BO" "BCX" 6
			6,  // 1040 "474" "BM" "BCX" 6
			6,  // 1050 "478" "BZ" "BCX" 6
			6,  // 1060 "47D" "BNP" "BCX" 6
			6,  // 1070 "47B" "BNM" "BCX" 6
			6,  // 1080 "477" "BNZ" "BCX" 6
			6,  // 1090 "47E" "BNO" "BCX" 6
			5,  // 1100 "48" "LH" "RX" 5
			5,  // 1110 "49" "CH" "RX" 5
			5,  // 1120 "4A" "AH" "RX" 5
			5,  // 1130 "4B" "SH" "RX" 5
			5,  // 1140 "4C" "MH" "RX" 5
			5,  // 1150 "4D" "BAS" "RX" 5
			5,  // 1160 "4E" "CVD" "RX" 5
			5,  // 1170 "4F" "CVB" "RX" 5
			5,  // 1180 "50" "ST" "RX" 5
			5,  // 1190 "51" "LAE" "RX" 5
			37, // 1193 "52" "XDECO" "RX" 37 RPI 812
			37, // 1196 "53" "XDECI" "RX" 37 RPI 812	
			5,  // 1200 "54" "N" "RX" 5
			5,  // 1210 "55" "CL" "RX" 5
			5,  // 1220 "56" "O" "RX" 5
			5,  // 1230 "57" "X" "RX" 5
			5,  // 1240 "58" "L" "RX" 5
			5,  // 1250 "59" "C" "RX" 5
			5,  // 1260 "5A" "A" "RX" 5
			5,  // 1270 "5B" "S" "RX" 5
			5,  // 1280 "5C" "M" "RX" 5
			5,  // 1290 "5D" "D" "RX" 5
			5,  // 1300 "5E" "AL" "RX" 5
			5,  // 1310 "5F" "SL" "RX" 5
			5,  // 1320 "60" "STD" "RX" 5
			37, // 1323 "61" "XHEXI" "RX" 37 RPI 812
			37, // 1326 "62" "XHEXO" "RX" 37 RPI 812
			5,  // 1330 "67" "MXD" "RX" 5
			5,  // 1340 "68" "LD" "RX" 5
			5,  // 1350 "69" "CD" "RX" 5
			5,  // 1360 "6A" "AD" "RX" 5
			5,  // 1370 "6B" "SD" "RX" 5
			5,  // 1380 "6C" "MD" "RX" 5
			5,  // 1390 "6D" "DD" "RX" 5
			5,  // 1400 "6E" "AW" "RX" 5
			5,  // 1410 "6F" "SW" "RX" 5
			5,  // 1420 "70" "STE" "RX" 5
			5,  // 1430 "71" "MS" "RX" 5
			5,  // 1440 "78" "LE" "RX" 5
			5,  // 1450 "79" "CE" "RX" 5
			5,  // 1460 "7A" "AE" "RX" 5
			5,  // 1470 "7B" "SE" "RX" 5
			5,  // 1480 "7C" "MDE" "RX" 5
			5,  // 1490 "7C" "ME" "RX" 5
			5,  // 1500 "7D" "DE" "RX" 5
			5,  // 1510 "7E" "AU" "RX" 5
			5,  // 1520 "7F" "SU" "RX" 5
			7,  // 1530 "8000" "SSM" "S" 7
			7,  // 1540 "8202" "LPSW" "S" 7
			8,  // 1550 "83" "DIAGNOSE" "DM" 8
			9,  // 1560 "84" "BRXH" "RSI" 9
			9,  // 1570 "84" "JXH" "RSI" 9
			9,  // 1580 "85" "BRXLE" "RSI" 9
			9,  // 1590 "85" "JXLE" "RSI" 9
			10,  // 1600 "86" "BXH" "RS" 10
			10,  // 1610 "87" "BXLE" "RS" 10
			10,  // 1620 "88" "SRL" "RS" 10
			10,  // 1630 "89" "SLL" "RS" 10
			10,  // 1640 "8A" "SRA" "RS" 10
			10,  // 1650 "8B" "SLA" "RS" 10
			10,  // 1660 "8C" "SRDL" "RS" 10
			10,  // 1670 "8D" "SLDL" "RS" 10
			10,  // 1680 "8E" "SRDA" "RS" 10
			10,  // 1690 "8F" "SLDA" "RS" 10
			10,  // 1700 "90" "STM" "RS" 10
			11,  // 1710 "91" "TM" "SI" 11
			11,  // 1720 "92" "MVI" "SI" 11
			7,  // 1730 "93" "TS" "S" 7
			11,  // 1740 "94" "NI" "SI" 11
			11,  // 1750 "95" "CLI" "SI" 11
			11,  // 1760 "96" "OI" "SI" 11
			11,  // 1770 "97" "XI" "SI" 11
			10,  // 1780 "98" "LM" "RS" 10
			10,  // 1790 "99" "TRACE" "RS" 10
			10,  // 1800 "9A" "LAM" "RS" 10
			10,  // 1810 "9B" "STAM" "RS" 10
			12,  // 1820 "A50" "IIHH" "RI" 12
			12,  // 1830 "A51" "IIHL" "RI" 12
			12,  // 1840 "A52" "IILH" "RI" 12
			12,  // 1850 "A53" "IILL" "RI" 12
			12,  // 1860 "A54" "NIHH" "RI" 12
			12,  // 1870 "A55" "NIHL" "RI" 12
			12,  // 1880 "A56" "NILH" "RI" 12
			12,  // 1890 "A57" "NILL" "RI" 12
			12,  // 1900 "A58" "OIHH" "RI" 12
			12,  // 1910 "A59" "OIHL" "RI" 12
			12,  // 1920 "A5A" "OILH" "RI" 12
			12,  // 1930 "A5B" "OILL" "RI" 12
			12,  // 1940 "A5C" "LLIHH" "RI" 12
			12,  // 1950 "A5D" "LLIHL" "RI" 12
			12,  // 1960 "A5E" "LLILH" "RI" 12
			12,  // 1970 "A5F" "LLILL" "RI" 12
			12,  // 1980 "A70" "TMLH" "RI" 12
			12,  // 1990 "A70" "TMH" "RI" 12
			12,  // 2000 "A71" "TMLL" "RI" 12
			12,  // 2010 "A71" "TML" "RI" 12
			12,  // 2020 "A72" "TMHH" "RI" 12
			12,  // 2030 "A73" "TMHL" "RI" 12
			12,  // 2040 "A74" "BRC" "RI" 12
			13,  // 2050 "A74F" "J" "BRCX" 13
			13,  // 2060 "A740" "JNOP" "BRCX" 13
			13,  // 2070 "A74F" "BRU" "BRCX" 13
			13,  // 2080 "A742" "BRH" "BRCX" 13
			13,  // 2090 "A744" "BRL" "BRCX" 13
			13,  // 2100 "A748" "BRE" "BRCX" 13
			13,  // 2110 "A74D" "BRNH" "BRCX" 13
			13,  // 2120 "A74B" "BRNL" "BRCX" 13
			13,  // 2130 "A747" "BRNE" "BRCX" 13
			13,  // 2140 "A742" "BRP" "BRCX" 13
			13,  // 2150 "A744" "BRM" "BRCX" 13
			13,  // 2160 "A748" "BRZ" "BRCX" 13
			13,  // 2170 "A741" "BRO" "BRCX" 13
			13,  // 2180 "A74D" "BRNP" "BRCX" 13
			13,  // 2190 "A74B" "BRNM" "BRCX" 13
			13,  // 2200 "A747" "BRNZ" "BRCX" 13
			13,  // 2210 "A74E" "BRNO" "BRCX" 13
			13,  // 2220 "A742" "JH" "BRCX" 13
			13,  // 2230 "A744" "JL" "BRCX" 13
			13,  // 2240 "A748" "JE" "BRCX" 13
			13,  // 2250 "A74D" "JNH" "BRCX" 13
			13,  // 2260 "A74B" "JNL" "BRCX" 13
			13,  // 2270 "A747" "JNE" "BRCX" 13
			13,  // 2280 "A742" "JP" "BRCX" 13 
			13,  // 2290 "A744" "JM" "BRCX" 13
			13,  // 2300 "A748" "JZ" "BRCX" 13
			13,  // 2310 "A741" "JO" "BRCX" 13
			13,  // 2320 "A74D" "JNP" "BRCX" 13
			13,  // 2330 "A74B" "JNM" "BRCX" 13
			13,  // 2340 "A747" "JNZ" "BRCX" 13
			13,  // 2350 "A74E" "JNO" "BRCX" 13
			12,  // 2360 "A75" "BRAS" "RI" 12
			12,  // 2370 "A75" "JAS" "RI" 12
			12,  // 2380 "A76" "BRCT" "RI" 12
			12,  // 2390 "A76" "JCT" "RI" 12
			12,  // 2400 "A77" "BRCTG" "RI" 12
			12,  // 2410 "A77" "JCTG" "RI" 12
			12,  // 2420 "A78" "LHI" "RI" 12
			12,  // 2430 "A79" "LGHI" "RI" 12
			12,  // 2440 "A7A" "AHI" "RI" 12
			12,  // 2450 "A7B" "AGHI" "RI" 12
			12,  // 2460 "A7C" "MHI" "RI" 12
			12,  // 2470 "A7D" "MGHI" "RI" 12
			12,  // 2480 "A7E" "CHI" "RI" 12
			12,  // 2490 "A7F" "CGHI" "RI" 12
			10,  // 2500 "A8" "MVCLE" "RS" 10
			10,  // 2510 "A9" "CLCLE" "RS" 10
			11,  // 2520 "AC" "STNSM" "SI" 11
			11,  // 2530 "AD" "STOSM" "SI" 11
			10,  // 2540 "AE" "SIGP" "RS" 10
			11,  // 2550 "AF" "MC" "SI" 11
			5,  // 2560 "B1" "LRA" "RX" 5
			7,  // 2570 "B202" "STIDP" "S" 7
			7,  // 2580 "B204" "SCK" "S" 7
			7,  // 2590 "B205" "STCK" "S" 7
			7,  // 2600 "B206" "SCKC" "S" 7
			7,  // 2610 "B207" "STCKC" "S" 7
			7,  // 2620 "B208" "SPT" "S" 7
			7,  // 2630 "B209" "STPT" "S" 7
			7,  // 2640 "B20A" "SPKA" "S" 7
			7,  // 2650 "B20B" "IPK" "S" 7
			7,  // 2660 "B20D" "PTLB" "S" 7
			7,  // 2670 "B210" "SPX" "S" 7
			7,  // 2680 "B211" "STPX" "S" 7
			7,  // 2690 "B212" "STAP" "S" 7
			7,  // 2700 "B218" "PC" "S" 7
			7,  // 2710 "B219" "SAC" "S" 7
			7,  // 2720 "B21A" "CFC" "S" 7
			14,  // 2730 "B221" "IPTE" "RRE" 14
			14,  // 2740 "B222" "IPM" "RRE" 14
			14,  // 2750 "B223" "IVSK" "RRE" 14
			14,  // 2760 "B224" "IAC" "RRE" 14
			14,  // 2770 "B225" "SSAR" "RRE" 14
			14,  // 2780 "B226" "EPAR" "RRE" 14
			14,  // 2790 "B227" "ESAR" "RRE" 14
			14,  // 2800 "B228" "PT" "RRE" 14
			14,  // 2810 "B229" "ISKE" "RRE" 14
			14,  // 2820 "B22A" "RRBE" "RRE" 14
			14,  // 2830 "B22B" "SSKE" "RRE" 14
			14,  // 2840 "B22C" "TB" "RRE" 14
			14,  // 2850 "B22D" "DXR" "RRE" 14
			14,  // 2860 "B22E" "PGIN" "RRE" 14
			14,  // 2870 "B22F" "PGOUT" "RRE" 14
			7,  // 2880 "B230" "CSCH" "S" 7
			7,  // 2890 "B231" "HSCH" "S" 7
			7,  // 2900 "B232" "MSCH" "S" 7
			7,  // 2910 "B233" "SSCH" "S" 7
			7,  // 2920 "B234" "STSCH" "S" 7
			7,  // 2930 "B235" "TSCH" "S" 7
			7,  // 2940 "B236" "TPI" "S" 7
			7,  // 2950 "B237" "SAL" "S" 7
			7,  // 2960 "B238" "RSCH" "S" 7
			7,  // 2970 "B239" "STCRW" "S" 7
			7,  // 2980 "B23A" "STCPS" "S" 7
			7,  // 2990 "B23B" "RCHP" "S" 7
			7,  // 3000 "B23C" "SCHM" "S" 7
			14,  // 3010 "B240" "BAKR" "RRE" 14
			14,  // 3020 "B241" "CKSM" "RRE" 14
			14,  // 3030 "B244" "SQDR" "RRE" 14
			14,  // 3040 "B245" "SQER" "RRE" 14
			14,  // 3050 "B246" "STURA" "RRE" 14
			14,  // 3060 "B247" "MSTA" "RRE" 14
			14,  // 3070 "B248" "PALB" "RRE" 14
			14,  // 3080 "B249" "EREG" "RRE" 14
			14,  // 3090 "B24A" "ESTA" "RRE" 14
			14,  // 3100 "B24B" "LURA" "RRE" 14
			14,  // 3110 "B24C" "TAR" "RRE" 14
			14,  // 3120 "B24D" "CPYA" "RRE" 14
			14,  // 3130 "B24E" "SAR" "RRE" 14
			14,  // 3140 "B24F" "EAR" "RRE" 14
			14,  // 3150 "B250" "CSP" "RRE" 14
			14,  // 3160 "B252" "MSR" "RRE" 14
			14,  // 3170 "B254" "MVPG" "RRE" 14
			14,  // 3180 "B255" "MVST" "RRE" 14
			14,  // 3190 "B257" "CUSE" "RRE" 14
			14,  // 3200 "B258" "BSG" "RRE" 14
			14,  // 3210 "B25A" "BSA" "RRE" 14
			14,  // 3220 "B25D" "CLST" "RRE" 14
			14,  // 3230 "B25E" "SRST" "RRE" 14
			14,  // 3240 "B263" "CMPSC" "RRE" 14
			7,  // 3250 "B276" "XSCH" "S" 7
			7,  // 3260 "B277" "RP" "S" 7
			7,  // 3270 "B278" "STCKE" "S" 7
			7,  // 3280 "B279" "SACF" "S" 7
			7,  //      "B27C" "STCKF" "S" 7 Z9-2
			7,  // 3290 "B27D" "STSI" "S" 7
			7,  // 3300 "B299" "SRNM" "S" 7
			7,  // 3310 "B29C" "STFPC" "S" 7
			7,  // 3320 "B29D" "LFPC" "S" 7
			14,  // 3330 "B2A5" "TRE" "RRE" 14
			14,  // 3340 "B2A6" "CUUTF" "RRE" 14
			14,  // 3350 "B2A6" "CU21" "RRE" 14
			14,  // 3360 "B2A7" "CUTFU" "RRE" 14
			14,  // 3370 "B2A7" "CU12" "RRE" 14
			7,  //      "B2B0" "STFLE" "S" 7 Z9-3
			7,  // 3380 "B2B1" "STFL" "S" 7
			7,  // 3390 "B2B2" "LPSWE" "S" 7
			7,  // 3392 "B2B8" "SRNMB" "S" 7 RPI 1125
			7,  // 3395 "B2B9" "SRNMT" "S" 7 DFP 56
			7,  // 3395 "B2BD" "LFAS"  "S" 7 DFP 55
			7,  // 3400 "B2FF" "TRAP4" "S" 7
			14,  // 3410 "B300" "LPEBR" "RRE" 14
			14,  // 3420 "B301" "LNEBR" "RRE" 14
			14,  // 3430 "B302" "LTEBR" "RRE" 14
			14,  // 3440 "B303" "LCEBR" "RRE" 14
			14,  // 3450 "B304" "LDEBR" "RRE" 14
			14,  // 3460 "B305" "LXDBR" "RRE" 14
			14,  // 3470 "B306" "LXEBR" "RRE" 14
			14,  // 3480 "B307" "MXDBR" "RRE" 14
			14,  // 3490 "B308" "KEBR" "RRE" 14
			14,  // 3500 "B309" "CEBR" "RRE" 14
			14,  // 3510 "B30A" "AEBR" "RRE" 14
			14,  // 3520 "B30B" "SEBR" "RRE" 14
			14,  // 3530 "B30C" "MDEBR" "RRE" 14
			14,  // 3540 "B30D" "DEBR" "RRE" 14
			15,  // 3550 "B30E" "MAEBR" "RRF1" 15
			15,  // 3560 "B30F" "MSEBR" "RRF1" 15
			14,  // 3570 "B310" "LPDBR" "RRE" 14
			14,  // 3580 "B311" "LNDBR" "RRE" 14
			14,  // 3590 "B312" "LTDBR" "RRE" 14
			14,  // 3600 "B313" "LCDBR" "RRE" 14
			14,  // 3610 "B314" "SQEBR" "RRE" 14
			14,  // 3620 "B315" "SQDBR" "RRE" 14
			14,  // 3630 "B316" "SQXBR" "RRE" 14
			14,  // 3640 "B317" "MEEBR" "RRE" 14
			14,  // 3650 "B318" "KDBR" "RRE" 14
			14,  // 3660 "B319" "CDBR" "RRE" 14
			14,  // 3670 "B31A" "ADBR" "RRE" 14
			14,  // 3680 "B31B" "SDBR" "RRE" 14
			14,  // 3690 "B31C" "MDBR" "RRE" 14
			14,  // 3700 "B31D" "DDBR" "RRE" 14
			15,  // 3710 "B31E" "MADBR" "RRF1" 15
			15,  // 3720 "B31F" "MSDBR" "RRF1" 15
			14,  // 3730 "B324" "LDER" "RRE" 14
			14,  // 3740 "B325" "LXDR" "RRE" 14
			14,  // 3750 "B326" "LXER" "RRE" 14
			15,  // 3760 "B32E" "MAER" "RRF1" 15
			15,  // 3770 "B32F" "MSER" "RRF1" 15
			14,  // 3780 "B336" "SQXR" "RRE" 14
			14,  // 3790 "B337" "MEER" "RRE" 14
			15,  //      "B338" "MAYLR" "RRF1" 15 Z9-4
			15,  //      "B339" "MYLR" "RRF1" 15 Z9-5
			15,  //      "B33A" "MAYR" "RRF1" 15 Z9-6
			15,  //      "B33B" "MYR" "RRF1" 15 Z9-7
			15,  //      "B33C" "MAYHR" "RRF1" 15 Z9-8
			15,  //      "B33D" "MYHR" "RRF1" 15 Z9-9
			15,  // 3800 "B33E" "MADR" "RRF1" 15
			15,  // 3810 "B33F" "MSDR" "RRF1" 15
			14,  // 3820 "B340" "LPXBR" "RRE" 14
			14,  // 3830 "B341" "LNXBR" "RRE" 14
			14,  // 3840 "B342" "LTXBR" "RRE" 14
			14,  // 3850 "B343" "LCXBR" "RRE" 14
			53,  // 3860 "B344" "LEDBR?" "RRE" 53 RPI 1125
			53,  // 3870 "B345" "LDXBR?" "RRE" 53 RPI 1125
			53,  // 3880 "B346" "LEXBR?" "RRE" 53 RPI 1125
			54,  // 3890 "B347" "FIXBR?" "RRF2" 54 RPI 1125
			14,  // 3900 "B348" "KXBR" "RRE" 14
			14,  // 3910 "B349" "CXBR" "RRE" 14
			14,  // 3920 "B34A" "AXBR" "RRE" 14
			14,  // 3930 "B34B" "SXBR" "RRE" 14
			14,  // 3940 "B34C" "MXBR" "RRE" 14
			14,  // 3950 "B34D" "DXBR" "RRE" 14
			34,  // 3960 "B350" "TBEDR" "RRF2" 34
			34,  // 3970 "B351" "TBDR" "RRF2" 34
			30,  // 3980 "B353" "DIEBR" "RRF3" 30
			54,  // 3990 "B357" "FIEBR?" "RRF2" 54 RPI 1125
			14,  // 4000 "B358" "THDER" "RRE" 14
			14,  // 4010 "B359" "THDR" "RRE" 14
			30,  // 4020 "B35B" "DIDBR" "RRF3" 30
			54,  // 4030 "B35F" "FIDBR?" "RRF2" 54 RPI 1125
			14,  // 4040 "B360" "LPXR" "RRE" 14
			14,  // 4050 "B361" "LNXR" "RRE" 14
			14,  // 4060 "B362" "LTXR" "RRE" 14
			14,  // 4070 "B363" "LCXR" "RRE" 14
			14,  // 4080 "B365" "LXR" "RRE" 14
			14,  // 4090 "B366" "LEXR" "RRE" 14
			14,  // 4100 "B367" "FIXR" "RRE" 14
			14,  // 4110 "B369" "CXR" "RRE" 14
			14,  // 4115 "B370" "LPDFR" "RRE"  14 DFP
			14,  // 4115 "B371" "LNDFR" "RRE"  14 DFP
			34,  // 4115 "B372" "CPSDR" "RRF2" 34 DFP
			14,  // 4115 "B373" "LCDFR" "RRE"  14 DFP
			14,  // 4120 "B374" "LZER" "RRE" 14
			14,  // 4130 "B375" "LZDR" "RRE" 14
			14,  // 4140 "B376" "LZXR" "RRE" 14
			14,  // 4150 "B377" "FIER" "RRE" 14
			14,  // 4160 "B37F" "FIDR" "RRE" 14
			14,  // 4170 "B384" "SFPC" "RRE" 14
			14,  // 4175 "B385" "SFASR" "RRE" 14 DFP 57
			14,  // 4180 "B38C" "EFPC" "RRE" 14
			30,  //      "B390" "CELFBR" "RRF3" 30 RPI 1125 Z196
			30,  //      "B391" "CDLFBR" "RRF3" 30 RPI 1125 Z196
			30,  //      "B392" "CXLFBR" "RRF3" 30 RPI 1125 Z196
			53,  // 4190 "B394" "CEFBR?" "RRE" 53 RPI 1125 Z196
			53,  // 4200 "B395" "CDFBR?" "RRE" 53 RPI 1125 Z196
			53,  // 4210 "B396" "CXFBR?" "RRE" 53 RPI 1125 Z196
			54,  // 4220 "B398" "CFEBR?" "RRF" 54 RPI 1125 Z196 was RRF2 34
			54,  // 4230 "B399" "CFDBR?" "RRF" 54 RPI 1125 Z196 was RRF2 34
			54,  // 4240 "B39A" "CFXBR?" "RRF" 54 RPI 1125 Z196 was RRF2 34
			30,    // 'B39C' 'CLFEBR' 'RRF3' 30 RPI 1125 Z196
			30,    // 'B39D' 'CLFDBR' 'RRF3' 30 RPI 1125 Z196
			30,    // 'B39E' 'CLFXBR' 'RRF3' 30 RPI 1125 Z196
			30,    // 'B3A0' 'CELGBR' 'RRF3' 30 RPI 1125 Z196
			30,    // 'B3A1' 'CDLGBR' 'RRF3' 30 RPI 1125 Z196
			30,    // 'B3A2' 'CXLGBR' 'RRF3' 30 RPI 1125 Z196
			53,  // 4250 "B3A4" "CEGBR" "RRE" 53 RPI 1125 Z196
			53,  // 4260 "B3A5" "CDGBR" "RRE" 53 RPI 1125 Z196
			53,  // 4270 "B3A6" "CXGBR" "RRE" 53 RPI 1125 Z196
			54,  // 4280 "B3A8" "CGEBR" "RRF2" 54 RPI 1125 Z196
			54,  // 4290 "B3A9" "CGDBR" "RRF2" 54 RPI 1125 Z196
			54,  // 4300 "B3AA" "CGXBR" "RRF2" 54 RPI 1125 Z196
			30,    //      "B3AC" "CLGEBR" "RRF2" 30  RPI 1125 Z196
			30,    //      "B3AD" "CLGDBR" "RRF2" 30  RPI 1125 Z196
			30,    //      "B3AE" "CLGXBR" "RRF2" 30  RPI 1125 Z196
			14,  // 4310 "B3B4" "CEFR" "RRE" 14
			14,  // 4320 "B3B5" "CDFR" "RRE" 14
			14,  // 4330 "B3B6" "CXFR" "RRE" 14
			34,  // 4340 "B3B8" "CFER" "RRF2" 34
			34,  // 4350 "B3B9" "CFDR" "RRF2" 34
			34,  // 4360 "B3BA" "CFXR" "RRF2" 34
			14,  // 4365 "B3C1" "LDGR" "RRE" 14 DFP
			14,  // 4370 "B3C4" "CEGR" "RRE" 14
			14,  // 4380 "B3C5" "CDGR" "RRE" 14
			14,  // 4390 "B3C6" "CXGR" "RRE" 14
			34,  // 4400 "B3C8" "CGER" "RRF2" 34
			34,  // 4410 "B3C9" "CGDR" "RRF2" 34
			34,  // 4420 "B3CA" "CGXR" "RRF2" 34
			14,  // 4425 "B3CD" "LGDR" "RRE" 14 DFP    
			36, // "MDTR?"  "B3D0" "RRR"  DFP 1  RPI 1125
			36, // "DDTR?"  "B3D1" "RRR"  DFP 2  RPI 1125
			36, // "ADTR?"  "B3D2" "RRR"  DFP 3  RPI 1125
			36, // "SDTR?"  "B3D3" "RRR"  DFP 4  RPI 1125
			35, // "LDETR"  "B3D4" "RRF4" DFP 5  
			30, // "LEDTR"  "B3D5" "RRF3" DFP 6  
			14, // "LTDTR"  "B3D6" "RRE"  DFP 7  
			30, // "FIDTR"  "B3D7" "RRF3" DFP 8  
			36, // "MXTR?"  "B3D8" "RRR"  DFP 9  RPI 1125
			36, // "DXTR?"  "B3D9" "RRR"  DFP 10 RPI 1125
			36, // "AXTR?"  "B3DA" "RRR"  DFP 11 RPI 1125
			36, // "SXTR?"  "B3DB" "RRR"  DFP 12 RPI 1125
			35, // "LXDTR" "B3DC" "RRF4" DFP 13
			30, // "LDXTR" "B3DD" "RRF3" DFP 14
			14, // "LTXTR" "B3DE" "RRE"  DFP 15
			30, // "FIXTR" "B3DF" "RRF3" DFP 16
			14, // "KDTR" "B3E0" "RRE" DFP 17
			54, // "CGDTR?" "B3E1" "RRF7" DFP 18 RPI 1125
			14, // "CUDTR" "B3E2" "RRE" DFP 19
			35, // "CSDTR" "B3E3" "RRF4" DFP 20
			14, // "CDTR" "B3E4" "RRE" DFP 21
			14, // "EEDTR" "B3E5" "RRE" DFP 22
			14, // "ESDTR" "B3E7" "RRE" DFP 23
			14, // "KXTR" "B3E8" "RRE" DFP 24
			54, // "CGXTR?" "B3E9" "RRF7" DFP 25 RPI 1125
			14, // "CUXTR" "B3EA" "RRE" DFP 26
			35, // "CSXTR" "B3EB" "RRF4" DFP 27
			14, // "CXTR" "B3EC" "RRE" DFP 28
			14, // "EEXTR" "B3ED" "RRE" DFP 29
			14, // "ESXTR" "B3EF" "RRE" DFP 30
			53, // "CDGTR?" "B3F1" "RE3" DFP 31 RPI 1125
			14, // "CDUTR" "B3F2" "RRE" DFP 32
			14, // "CDSTR" "B3F3" "RRE" DFP 33
			14, // "CEDTR" "B3F4" "RRE" DFP 34
			30, // "QADTR" "B3F5" "RRF3" DFP 35
			34, // "IEDTR" "B3F6" "RRF2" DFP 36
			30, // "RRDTR" "B3F7" "RRF3" DFP 37
			53, // "CXGTR?" "B3F9" "RE3" DFP 38 RPI 1125
			14, // "CXUTR" "B3FA" "RRE" DFP 39
			14, // "CXSTR" "B3FB" "RRE" DFP 40
			14, // "CEXTR" "B3FC" "RRE" DFP 41
			30, // "QAXTR" "B3FD" "RRF3" DFP 42
			34, // "IEXTR" "B3FE" "RRF2" DFP 43
			30, // "RRXTR" "B3FF" "RRF3" DFP 44
			10,  // 4430 "B6" "STCTL" "RS" 10
			10,  // 4440 "B7" "LCTL" "RS" 10
			14,  // 4450 "B900" "LPGR" "RRE" 14
			14,  // 4460 "B901" "LNGR" "RRE" 14
			14,  // 4470 "B902" "LTGR" "RRE" 14
			14,  // 4480 "B903" "LCGR" "RRE" 14
			14,  // 4490 "B904" "LGR" "RRE" 14
			14,  // 4500 "B905" "LURAG" "RRE" 14
			14,  //      "B906" "LGBR" "RRE" 14 Z9-10
			14,  //      "B907" "LGHR" "RRE" 14 Z9-11
			14,  // 4510 "B908" "AGR" "RRE" 14
			14,  // 4520 "B909" "SGR" "RRE" 14
			14,  // 4530 "B90A" "ALGR" "RRE" 14
			14,  // 4540 "B90B" "SLGR" "RRE" 14
			14,  // 4550 "B90C" "MSGR" "RRE" 14
			14,  // 4560 "B90D" "DSGR" "RRE" 14
			14,  // 4570 "B90E" "EREGG" "RRE" 14
			14,  // 4580 "B90F" "LRVGR" "RRE" 14
			14,  // 4590 "B910" "LPGFR" "RRE" 14
			14,  // 4600 "B911" "LNGFR" "RRE" 14
			14,  // 4610 "B912" "LTGFR" "RRE" 14
			14,  // 4620 "B913" "LCGFR" "RRE" 14
			14,  // 4630 "B914" "LGFR" "RRE" 14
			14,  // 4640 "B916" "LLGFR" "RRE" 14
			14,  // 4650 "B917" "LLGTR" "RRE" 14
			14,  // 4660 "B918" "AGFR" "RRE" 14
			14,  // 4670 "B919" "SGFR" "RRE" 14
			14,  // 4680 "B91A" "ALGFR" "RRE" 14
			14,  // 4690 "B91B" "SLGFR" "RRE" 14
			14,  // 4700 "B91C" "MSGFR" "RRE" 14
			14,  // 4710 "B91D" "DSGFR" "RRE" 14
			14,  // 4720 "B91E" "KMAC" "RRE" 14
			14,  // 4730 "B91F" "LRVR" "RRE" 14
			14,  // 4740 "B920" "CGR" "RRE" 14
			14,  // 4750 "B921" "CLGR" "RRE" 14
			14,  // 4760 "B925" "STURG" "RRE" 14
			14,  //      "B926" "LBR" "RRE" 14 Z9-12
			14,  //      "B927" "LHR" "RRE" 14 Z9-13
			14,  // "B928","PCKMO","RE4"  14 RPI 1125 Z196
			14,  // "B92A","KMF","RRE"    14 RPI 1125 Z196
			14,  // "B92B","KMO","RRE"    14 RPI 1125 Z196
			14,  // "B92C","PCC","RE4"    14 RPI 1125 Z196
			34,  // "B92D","KMCTR","RRF2" 34 RPI 1125 Z196
			14,  // 4770 "B92E" "KM" "RRE" 14
			14,  // 4780 "B92F" "KMC" "RRE" 14
			14,  // 4790 "B930" "CGFR" "RRE" 14
			14,  // 4800 "B931" "CLGFR" "RRE" 14
			14,  // 4810 "B93E" "KIMD" "RRE" 14
			14,  // 4820 "B93F" "KLMD" "RRE" 14
			30,    // "B941","CFDTR","RRF"  30 RPI 1125 Z196
			30,   // "B942","CLGDTR","RRF" 30 RPI 1125 Z196
			30,   // "B943","CLFDTR","RRF" 30 RPI 1125 Z196
			14,  // 4830 "B946" "BCTGR" "RRE" 14
			30,    // "B949","CFXTR","RRF3"   30 RPI 1125 Z196
			30,   // "B94A","CLGXTR","RRF3"  30 RPI 1125 Z196
			30,   // "B94B","CLFXTR","RRF3"  30 RPI 1125 Z196
			30,    // "B951","CDFTR","RRF3"   30 RPI 1125 Z196
			30,   // "B952","CDLGTR","RRF3"  30 RPI 1125 Z196
			30,   // "B953","CDLFTR","RRF3"  30 RPI 1125 Z196
			30,    // "B959","CXFTR","RRF3"   30 RPI 1125 Z196" 
			30,   // "B95A","CXLGTR","RRF3"  30 RPI 1125 Z196
			30,   // "B95B","CXLFTR","RRF3"  30 RPI 1125 Z196
			39,  // 10 "B960" "CGRT" "RRF5" 39 RPI 817
			40,  // 20 "B9608" "CGRTE" "RRF6" 40 RPI 817
			40,  // 30 "B9602" "CGRTH" "RRF6" 40 RPI 817
			40,  // 40 "B9604" "CGRTL" "RRF6" 40 RPI 817
			40,  // 50 "B9606" "CGRTNE" "RRF6" 40 RPI 817
			40,  // 60 "B960C" "CGRTNH" "RRF6" 40 RPI 817
			40,  // 70 "B960A" "CGRTNL" "RRF6" 40 RPI 817
			39,  // 10 "B961" "CLGRT" "RRF5" 39 RPI 817
			40,  // 20 "B9618" "CLGRTE" "RRF6" 40 RPI 817
			40,  // 30 "B9612" "CLGRTH" "RRF6" 40 RPI 817
			40,  // 40 "B9614" "CLGRTL" "RRF6" 40 RPI 817
			40,  // 50 "B9616" "CLGRTNE" "RRF6" 40 RPI 817
			40,  // 60 "B961C" "CLGRTNH" "RRF6" 40 RPI 817
			40,  // 70 "B961A" "CLGRTNL" "RRF6" 40 RPI 817
			39,  // 150 "B972" "CRT" "RRF5" 39 RPI 817
			40,  // 160 "B9728" "CRTE" "RRF6" 40 RPI 817
			40,  // 170 "B9722" "CRTH" "RRF6" 40 RPI 817
			40,  // 180 "B9724" "CRTL" "RRF6" 40 RPI 817
			40,  // 190 "B9726" "CRTNE" "RRF6" 40 RPI 817
			40,  // 200 "B972C" "CRTNH" "RRF6" 40 RPI 817
			40,  // 210 "B972A" "CRTNL" "RRF6" 40 RPI 817      
			39,  // 80 "B973" "CLRT" "RRF5" 39 RPI 817
			40,  // 90 "B9738" "CLRTE" "RRF6" 40 RPI 817
			40,  // 100 "B9732" "CLRTH" "RRF6" 40 RPI 817
			40,  // 110 "B9734" "CLRTL" "RRF6" 40 RPI 817
			40,  // 120 "B9736" "CLRTNE" "RRF6" 40 RPI 817
			40,  // 130 "B973C" "CLRTNH" "RRF6" 40 RPI 817
			40,  // 140 "B973A" "CLRTNL" "RRF6" 40 RPI 817
			14,  // 4840 "B980" "NGR" "RRE" 14
			14,  // 4850 "B981" "OGR" "RRE" 14
			14,  // 4860 "B982" "XGR" "RRE" 14
			14,  //      "B983" "FLOGR" "RRE" 14 Z9-14
			14,  //      "B984" "LLGCR" "RRE" 14 Z9-15
			14,  //      "B985" "LLGHR" "RRE" 14 Z9-16
			14,  // 4870 "B986" "MLGR" "RRE" 14
			14,  // 4880 "B987" "DLGR" "RRE" 14
			14,  // 4890 "B988" "ALCGR" "RRE" 14
			14,  // 4900 "B989" "SLBGR" "RRE" 14
			14,  // 4910 "B98A" "CSPG" "RRE" 14
			14,  // 4920 "B98D" "EPSW" "RRE" 14
			34,  // 4930 "B98E" "IDTE" "RRF2" 34
			14,  // 4940 "B990" "TRTT" "RRE" 14
			14,  // 4950 "B991" "TRTO" "RRE" 14
			14,  // 4960 "B992" "TROT" "RRE" 14
			14,  // 4970 "B993" "TROO" "RRE" 14
			14,  //      "B994" "LLCR" "RRE" 14 Z9-17
			14,  //      "B995" "LLHR" "RRE" 14 Z9-18
			14,  // 4980 "B996" "MLR" "RRE" 14
			14,  // 4990 "B997" "DLR" "RRE" 14
			14,  // 5000 "B998" "ALCR" "RRE" 14
			14,  // 5010 "B999" "SLBR" "RRE" 14
			14,  // 5020 "B99A" "EPAIR" "RRE" 14
			14,  // 5030 "B99B" "ESAIR" "RRE" 14
			14,  // 5040 "B99D" "ESEA" "RRE" 14
			14,  // 5050 "B99E" "PTI" "RRE" 14
			14,  // 5060 "B99F" "SSAIR" "RRE" 14
			14,  // 10 "B9A2" "PTF" "RRE" 14  RPI 817
			14,  //      "B9AA" "LPTEA" "RRE" 14 Z9-196
			14,  // "B9AE","RRBM","RRE"  14 RPI 1125 Z196
			39,  // 20 "B9AF" "PFMF" "RRF5" 39  RPI 817
			14,  // 5070 "B9B0" "CU14" "RRE" 14
			14,  // 5080 "B9B1" "CU24" "RRE" 14
			14,  // 5090 "B9B2" "CU41" "RRE" 14
			14,  // 5100 "B9B3" "CU42" "RRE" 14
			39,  // 30 "B9BD" "TRTRE" "RRF5" 39  RPI 817
			14,  // 5110 "B9BE" "SRSTU" "RRE" 14
			39,  // 40 "B9BF" "TRTE" "RRF5" 39  RPI 817
			39,    // "B9C8","AHHHR","RRF5"  39 RPI 1125 Z196
			39,    // "B9C9","SHHHR","RRF5"  39 RPI 1125 Z196
			39,   // "B9CA","ALHHHR","RRF5" 39 RPI 1125 Z196
			39,   // "B9CB","SLHHHR","RRF5" 39 RPI 1125 Z196
			14,     // "B9CD","CHHR","RRE"     14 RPI 1125 Z196
			14,    // "B9CF","CLHHR","RRE"    14 RPI 1125 Z196
			39,    // "B9D8","AHHLR","RRF5 "  39 RPI 1125 Z196
			39,    // "B9D9","SHHLR","RRF5 "  39 RPI 1125 Z196
			39,    // "B9DA","ALHHLR","RRF5 " 39 RPI 1125 Z196
			39,    // "B9DB","SLHHLR","RRF5 " 39 RPI 1125 Z196
			39,    // "B9DD","CHLR","RRE"     14 RPI 1125 Z196
			14,    // "B9DF","CLHLR","RRE"    14 RPI 1125 Z196
			14,  // 5115 "B9E1" "POPCNT" "RRE" 14 RPI 1125
			39,     // "B9E2","LOCGR","RRF5"   39 RPI 1125 Z196
			39,     // "B9E4","NGRK","RRF5"    39 RPI 1125 Z196
			39,     // "B9E6","OGRK","RRF5"    39 RPI 1125 Z196
			39,     // "B9E7","XGRK","RRF5"    39 RPI 1125 Z196
			39,     // "B9E8","AGRK","RRF5"    39 RPI 1125 Z196
			39,     // "B9E9","SGRK","RRF5"    39 RPI 1125 Z196
			39,     // "B9EA","ALGRK","RRF5"   39 RPI 1125 Z196
			39,     // "B9EB","SLGRK","RRF5"   39 RPI 1125 Z196
			39,     // "B9F2","LOCR","RRF5"    39 RPI 1125 Z196
			39,     // "B9F4","NRK","RRF5"     39 RPI 1125 Z196
			39,     // "B9F6","ORK","RRF5"     39 RPI 1125 Z196
			39,     // "B9F7","XRK","RRF5"     39 RPI 1125 Z196
			39,     // "B9F8","ARK","RRF5"     39 RPI 1125 Z196
			39,     // "B9F9","SRK","RRF5"     39 RPI 1125 Z196
			39,     // "B9FA","ALRK","RRF5"    39 RPI 1125 Z196
			39,     // "B9FB","SLRK","RRF5"    39 RPI 1125 Z196 
			10,  // 5120 "BA" "CS" "RS" 10
			10,  // 5130 "BB" "CDS" "RS" 10
			10,  // 5140 "BD" "CLM" "RS" 10
			10,  // 5150 "BE" "STCM" "RS" 10
			10,  // 5160 "BF" "ICM" "RS" 10
			16,  // 5170 "C00" "LARL" "RIL" 16
			16,  //      "C01" "LGFI" "RIL" 16 Z9-20
			16,  // 5180 "C04" "BRCL" "RIL" 16
			33,  // 5390 "C040" "JLNOP" "BLX" 33
			33,  // 5400 "C041" "BROL" "BLX" 33
			33,  // 5410 "C041" "JLO" "BLX" 33
			33,  // 5420 "C042" "BRHL" "BLX" 33
			33,  // 5430 "C042" "BRPL" "BLX" 33
			33,  // 5440 "C042" "JLH" "BLX" 33
			33,  // 5450 "C042" "JLP" "BLX" 33
			33,  // 5460 "C044" "BRLL" "BLX" 33
			33,  // 5470 "C044" "BRML" "BLX" 33
			33,  // 5480 "C044" "JLL" "BLX" 33
			33,  // 5490 "C044" "JLM" "BLX" 33
			33,  // 5500 "C047" "BRNEL" "BLX" 33
			33,  // 5510 "C047" "BRNZL" "BLX" 33
			33,  // 5520 "C047" "JLNE" "BLX" 33
			33,  // 5530 "C047" "JLNZ" "BLX" 33
			33,  // 5540 "C048" "BREL" "BLX" 33
			33,  // 5550 "C048" "BRZL" "BLX" 33
			33,  // 5560 "C048" "JLE" "BLX" 33
			33,  // 5570 "C048" "JLZ" "BLX" 33
			33,  // 5580 "C04B" "BRNLL" "BLX" 33
			33,  // 5590 "C04B" "BRNML" "BLX" 33
			33,  // 5600 "C04B" "JLNL" "BLX" 33
			33,  // 5610 "C04B" "JLNM" "BLX" 33
			33,  // 5620 "C04D" "BRNHL" "BLX" 33
			33,  // 5630 "C04D" "BRNPL" "BLX" 33
			33,  // 5640 "C04D" "JLNH" "BLX" 33
			33,  // 5650 "C04D" "JLNP" "BLX" 33
			33,  // 5660 "C04E" "BRNOL" "BLX" 33
			33,  // 5670 "C04E" "JLNO" "BLX" 33
			33,  // 5680 "C04F" "BRUL" "BLX" 33
			33,  // 5690 "C04F" "JLU" "BLX" 33
			16,  // 5210 "C05" "BRASL" "RIL" 16
			16,  // 5220 "C05" "JASL" "RIL" 16
			16,  //      "C06" "XIHF" "RIL" 16 Z9-21
			16,  //      "C07" "XILF" "RIL" 16 Z9-22
			16,  //      "C08" "IIHF" "RIL" 16 Z9-23
			16,  //      "C09" "IILF" "RIL" 16 Z9-24
			16,  //      "C0A" "NIHF" "RIL" 16 Z9-25
			16,  //      "C0B" "NILF" "RIL" 16 Z9-26
			16,  //      "C0C" "OIHF" "RIL" 16 Z9-27
			16,  //      "C0D" "OILF" "RIL" 16 Z9-28
			16,  //      "C0E" "LLIHF" "RIL" 16 Z9-29
			16,  //      "C0F" "LLILF" "RIL" 16 Z9-30
			16,  // 50 "C20" "MSGFI" "RIL" 16  RPI 817
			16,  // 60 "C21" "MSFI" "RIL" 16  RPI 817
			16,  //      "C24" "SLGFI" "RIL" 16 Z9-31
			16,  //      "C25" "SLFI" "RIL" 16 Z9-32
			16,  //      "C28" "AGFI" "RIL" 16 Z9-33
			16,  //      "C29" "AFI" "RIL" 16 Z9-34
			16,  //      "C2A" "ALGFI" "RIL" 16 Z9-35
			16,  //      "C2B" "ALFI" "RIL" 16 Z9-36
			16,  //      "C2C" "CGFI" "RIL" 16 Z9-37
			16,  //      "C2D" "CFI" "RIL" 16 Z9-38
			16,  //      "C2E" "CLGFI" "RIL" 16 Z9-39
			16,  //      "C2F" "CLFI" "RIL" 16 Z9-40
			16,  // 70 "C42" "LLHRL" "RIL" 16  RPI 817
			16,  // 80 "C44" "LGHRL" "RIL" 16  RPI 817
			16,  // 90 "C45" "LHRL" "RIL" 16  RPI 817
			16,  // 100 "C46" "LLGHRL" "RIL" 16  RPI 817
			16,  // 110 "C47" "STHRL" "RIL" 16  RPI 817
			16,  // 120 "C48" "LGRL" "RIL" 16  RPI 817
			16,  // 130 "C4B" "STGRL" "RIL" 16  RPI 817
			16,  // 140 "C4C" "LGFRL" "RIL" 16  RPI 817
			16,  // 150 "C4D" "LRL" "RIL" 16  RPI 817
			16,  // 160 "C4E" "LLGFRL" "RIL" 16  RPI 817
			16,  // 170 "C4F" "STRL" "RIL" 16  RPI 817
			16,  // 180 "C60" "EXRL" "RIL" 16  RPI 817
			16,  // 190 "C62" "PFDRL" "RIL" 16  RPI 817
			16,  // 200 "C64" "CGHRL" "RIL" 16  RPI 817
			16,  // 210 "C65" "CHRL" "RIL" 16  RPI 817
			16,  // 220 "C66" "CLGHRL" "RIL" 16  RPI 817
			16,  // 230 "C67" "CLHRL" "RIL" 16  RPI 817
			16,  // 240 "C68" "CGRL" "RIL" 16  RPI 817
			16,  // 250 "C6A" "CLGRL" "RIL" 16  RPI 817
			16,  // 260 "C6C" "CGFRL" "RIL" 16  RPI 817
			16,  // 270 "C6D" "CRL" "RIL" 16  RPI 817
			16,  // 280 "C6E" "CLGFRL" "RIL" 16  RPI 817
			16,  // 290 "C6F" "CLRL" "RIL" 16  RPI 817
			32,  //      "C80" "MVCOS" "SSF" 32 Z9-41	
			32,  //      "C81" "ECTG" "SSF" 32 RPI 1013
			32,  //      "C82" "CSST" "SSF" 32 RPI 1013
			55,  // "C84","LPD","SSF2"  55 RPI 1125 Z196
			55,  // "C85","LPDG","SSF2" 55 RPI 1125 Z196
			16, // "CC6","BRCTH","RIL"  16 RPI 1125 Z196
			16, // "CC8","AIH","RIL"    16  RPI 1125 Z196
			16, // "CCA","ALSIH","RIL"  16  RPI 1125 Z196
			16, // "CCB","ALSIHN","RIL" 16  RPI 1125 Z196
			16, // "CCD","CIH","RIL"    16  RPI 1125 Z196
			16, // "CCF","CLIH","RIL"   16  RPI 1125 Z196
			17,  // 5230 "D0" "TRTR" "SS" 17
			17,  // 5240 "D1" "MVN" "SS" 17
			17,  // 5250 "D2" "MVC" "SS" 17
			17,  // 5260 "D3" "MVZ" "SS" 17
			17,  // 5270 "D4" "NC" "SS" 17
			17,  // 5280 "D5" "CLC" "SS" 17
			17,  // 5290 "D6" "OC" "SS" 17
			17,  // 5300 "D7" "XC" "SS" 17
			17,  // 5310 "D9" "MVCK" "SS" 17
			17,  // 5320 "DA" "MVCP" "SS" 17
			17,  // 5330 "DB" "MVCS" "SS" 17
			17,  // 5340 "DC" "TR" "SS" 17
			17,  // 5350 "DD" "TRT" "SS" 17
			17,  // 5360 "DE" "ED" "SS" 17
			17,  // 5370 "DF" "EDMK" "SS" 17
			38,  // 5375 "E00" "XREAD" "RXSS" 38 RPI 812
			38,  // 5375 "E02" "XPRNT" "RXSS" 38 RPI 812
			38,  // 5375 "E04" "XPNCH" "RXSS" 38 RPI 812
			38,  // 5375 "E06" "XDUMP" "RXSS" 38 RPI 812
			38,  // 5375 "E08" "XLIMD" "RXSS" 38 RPI 812
			38,  // 5375 "E0A" "XGET"  "RXSS" 38 RPI 812
			38,  // 5375 "E0C" "XPUT"  "RXSS" 38 RPI 812
			17,  // 5380 "E1" "PKU" "RXSS" 17
			17,  // 5390 "E2" "UNPKU" "SS" 17
			18,  //      "E302" "LTG" "RXY" 18 Z9-42
			18,  // 5400 "E303" "LRAG" "RXY" 18
			18,  // 5410 "E304" "LG" "RXY" 18
			18,  // 5420 "E306" "CVBY" "RXY" 18
			18,  // 5430 "E308" "AG" "RXY" 18
			18,  // 5440 "E309" "SG" "RXY" 18
			18,  // 5450 "E30A" "ALG" "RXY" 18
			18,  // 5460 "E30B" "SLG" "RXY" 18
			18,  // 5470 "E30C" "MSG" "RXY" 18
			18,  // 5480 "E30D" "DSG" "RXY" 18
			18,  // 5490 "E30E" "CVBG" "RXY" 18
			18,  // 5500 "E30F" "LRVG" "RXY" 18
			18,  //      "E312" "LT" "RXY" 18 Z9-43
			18,  // 5510 "E313" "LRAY" "RXY" 18
			18,  // 5520 "E314" "LGF" "RXY" 18
			18,  // 5530 "E315" "LGH" "RXY" 18
			18,  // 5540 "E316" "LLGF" "RXY" 18
			18,  // 5550 "E317" "LLGT" "RXY" 18
			18,  // 5560 "E318" "AGF" "RXY" 18
			18,  // 5570 "E319" "SGF" "RXY" 18
			18,  // 5580 "E31A" "ALGF" "RXY" 18
			18,  // 5590 "E31B" "SLGF" "RXY" 18
			18,  // 5600 "E31C" "MSGF" "RXY" 18
			18,  // 5610 "E31D" "DSGF" "RXY" 18
			18,  // 5620 "E31E" "LRV" "RXY" 18
			18,  // 5630 "E31F" "LRVH" "RXY" 18
			18,  // 5640 "E320" "CG" "RXY" 18
			18,  // 5650 "E321" "CLG" "RXY" 18
			18,  // 5660 "E324" "STG" "RXY" 18
			18,  // 5670 "E326" "CVDY" "RXY" 18
			18,  // 5680 "E32E" "CVDG" "RXY" 18
			18,  // 5690 "E32F" "STRVG" "RXY" 18
			18,  // 5700 "E330" "CGF" "RXY" 18
			18,  // 5710 "E331" "CLGF" "RXY" 18
			18,  // 310 "E332" "LTGF" "RXY" 18  RPI 817
			18,  // 320 "E334" "CGH" "RXY" 18  RPI 817
			18,  // 330 "E336" "PFD" "RXY" 18  RPI 817
			18,  // 5720 "E33E" "STRV" "RXY" 18
			18,  // 5730 "E33F" "STRVH" "RXY" 18
			18,  // 5740 "E346" "BCTG" "RXY" 18
			18,  // 5750 "E350" "STY" "RXY" 18
			18,  // 5760 "E351" "MSY" "RXY" 18
			18,  // 5770 "E354" "NY" "RXY" 18
			18,  // 5780 "E355" "CLY" "RXY" 18
			18,  // 5790 "E356" "OY" "RXY" 18
			18,  // 5800 "E357" "XY" "RXY" 18
			18,  // 5810 "E358" "LY" "RXY" 18
			18,  // 5820 "E359" "CY" "RXY" 18
			18,  // 5830 "E35A" "AY" "RXY" 18
			18,  // 5840 "E35B" "SY" "RXY" 18
			18,  // 340 "E35C" "MFY" "RXY" 18  RPI 817
			18,  // 5850 "E35E" "ALY" "RXY" 18
			18,  // 5860 "E35F" "SLY" "RXY" 18
			18,  // 5870 "E370" "STHY" "RXY" 18
			18,  // 5880 "E371" "LAY" "RXY" 18
			18,  // 5890 "E372" "STCY" "RXY" 18
			18,  // 5900 "E373" "ICY" "RXY" 18
			18,  // 350 "E375" "LAEY" "RXY" 18  RPI 817
			18,  // 5910 "E376" "LB" "RXY" 18
			18,  // 5920 "E377" "LGB" "RXY" 18
			18,  // 5930 "E378" "LHY" "RXY" 18
			18,  // 5940 "E379" "CHY" "RXY" 18
			18,  // 5950 "E37A" "AHY" "RXY" 18
			18,  // 5960 "E37B" "SHY" "RXY" 18
			18,  // 360 "E37C" "MHY" "RXY" 18  RPI 817
			18,  // 5970 "E380" "NG" "RXY" 18
			18,  // 5980 "E381" "OG" "RXY" 18
			18,  // 5990 "E382" "XG" "RXY" 18
			18,  // 6000 "E386" "MLG" "RXY" 18
			18,  // 6010 "E387" "DLG" "RXY" 18
			18,  // 6020 "E388" "ALCG" "RXY" 18
			18,  // 6030 "E389" "SLBG" "RXY" 18
			18,  // 6040 "E38E" "STPQ" "RXY" 18
			18,  // 6050 "E38F" "LPQ" "RXY" 18
			18,  // 6060 "E390" "LLGC" "RXY" 18
			18,  // 6070 "E391" "LLGH" "RXY" 18
			18,  //      "E394" "LLC" "RXY" 18 Z9-44
			18,  //      "E395" "LLH" "RXY" 18 Z9-45
			18,  // 6080 "E396" "ML" "RXY" 18
			18,  // 6090 "E397" "DL" "RXY" 18
			18,  // 6100 "E398" "ALC" "RXY" 18
			18,  // 6110 "E399" "SLB" "RXY" 18
			18,  // "E3C0","LBH","RXY"   18  RPI 1125 Z196
			18,  // "E3C2","LLCH","RXY"  18  RPI 1125 Z196
			18,  // "E3C3","STCH","RXY"  18  RPI 1125 Z196
			18,  // "E3C4","LHH","RXY"   18  RPI 1125 Z196
			18,  // "E3C6","LLHH","RXY"  18  RPI 1125 Z196
			18,  // "E3C7","STHH","RXY"  18  RPI 1125 Z196
			18,  // "E3CA","LFH","RXY"   18  RPI 1125 Z196
			18,  // "E3CB","STFH","RXY"  18  RPI 1125 Z196
			18,  // "E3CD","CHF","RXY"   18  RPI 1125 Z196
			18,  // "E3CF","CLHF","RXY"  18  RPI 1125 Z196
			19,  // 6120 "E500" "LASP" "SSE" 19
			19,  // 6130 "E501" "TPROT" "SSE" 19
			19,  // 6140 "E502" "STRAG" "SSE" 19
			19,  // 6150 "E50E" "MVCSK" "SSE" 19
			19,  // 6160 "E50F" "MVCDK" "SSE" 19
			51,  // 370 "E544" "MVHHI" "SIL" 51  RPI 817
			51,  // 380 "E548" "MVGHI" "SIL" 51  RPI 817
			51,  // 390 "E54C" "MVHI" "SIL" 51  RPI 817
			51,  // 400 "E554" "CHHSI" "SIL" 51  RPI 817
			51,  // 410 "E555" "CLHHSI" "SIL" 51  RPI 817
			51,  // 420 "E558" "CGHSI" "SIL" 51  RPI 817
			51,  // 430 "E559" "CLGHSI" "SIL" 51  RPI 817
			51,  // 440 "E55C" "CHSI" "SIL" 51  RPI 817
			51,  // 450 "E55D" "CLFHSI" "SIL" 51  RPI 817
			17,  // 6170 "E8" "MVCIN" "SS" 17
			31,  // 6180 "E9" "PKA" "SS" 31
			17,  // 6190 "EA" "UNPKA" "SS" 17
			20,  // 6200 "EB04" "LMG" "RSY" 20
			20,  // 6210 "EB0A" "SRAG" "RSY" 20
			20,  // 6220 "EB0B" "SLAG" "RSY" 20
			20,  // 6230 "EB0C" "SRLG" "RSY" 20
			20,  // 6240 "EB0D" "SLLG" "RSY" 20
			20,  // 6250 "EB0F" "TRACG" "RSY" 20
			20,  // 6260 "EB14" "CSY" "RSY" 20
			20,  // 6270 "EB1C" "RLLG" "RSY" 20
			20,  // 6280 "EB1D" "RLL" "RSY" 20
			20,  // 6290 "EB20" "CLMH" "RSY" 20
			20,  // 6300 "EB21" "CLMY" "RSY" 20
			20,  // 6310 "EB24" "STMG" "RSY" 20
			20,  // 6320 "EB25" "STCTG" "RSY" 20
			20,  // 6330 "EB26" "STMH" "RSY" 20
			20,  // 6340 "EB2C" "STCMH" "RSY" 20
			20,  // 6350 "EB2D" "STCMY" "RSY" 20
			20,  // 6360 "EB2F" "LCTLG" "RSY" 20
			20,  // 6370 "EB30" "CSG" "RSY" 20
			20,  // 6380 "EB31" "CDSY" "RSY" 20
			20,  // 6390 "EB3E" "CDSG" "RSY" 20
			20,  // 6400 "EB44" "BXHG" "RSY" 20
			20,  // 6410 "EB45" "BXLEG" "RSY" 20
			20,  // 460 "EB4C" "ECAG" "RSY" 20  RPI 817
			21,  // 6420 "EB51" "TMY" "SIY" 21
			21,  // 6430 "EB52" "MVIY" "SIY" 21
			21,  // 6440 "EB54" "NIY" "SIY" 21
			21,  // 6450 "EB55" "CLIY" "SIY" 21
			21,  // 6460 "EB56" "OIY" "SIY" 21
			21,  // 6470 "EB57" "XIY" "SIY" 21
			21,  // 470 "EB6A" "ASI" "SIY" 21  RPI 817
			21,  // 480 "EB6E" "ALSI" "SIY" 21  RPI 817
			21,  // 490 "EB7A" "AGSI" "SIY" 21  RPI 817
			21,  // 500 "EB7E" "ALGSI" "SIY" 21  RPI 817
			20,  // 6480 "EB80" "ICMH" "RSY" 20
			20,  // 6490 "EB81" "ICMY" "RSY" 20
			20,  // 6500 "EB8E" "MVCLU" "RSY" 20
			20,  // 6510 "EB8F" "CLCLU" "RSY" 20
			20,  // 6520 "EB90" "STMY" "RSY" 20
			20,  // 6530 "EB96" "LMH" "RSY" 20
			20,  // 6540 "EB98" "LMY" "RSY" 20
			20,  // 6550 "EB9A" "LAMY" "RSY" 20
			20,  // 6560 "EB9B" "STAMY" "RSY" 20
			22,  // 6570 "EBC0" "TP" "RSL" 22
			20,  //  "EBDC","SRAK","RSY  "  20 RPI 1125 Z196
			20,  //  "EBDD","SLAK","RSY  "  20 RPI 1125 Z196
			20,  //  "EBDE","SRLK","RSY  "  20 RPI 1125 Z196
			20,  //  "EBDF","SLLK","RSY  "  20 RPI 1125 Z196
			56,  //  "EBE2","LOCG","RSY2 "  20 RPI 1125 Z196
			56,  //  "EBE3","STOCG","RSY2 " 20 RPI 1125 Z196
			20,  //  "EBE4","LANG","RSY  "  20 RPI 1125 Z196
			20,  //  "EBE6","LAOG","RSY  "  20 RPI 1125 Z196
			20,  //  "EBE7","LAXG","RSY  "  20 RPI 1125 Z196
			20,  //  "EBE8","LAAG","RSY  "  20 RPI 1125 Z196
			20,  //  "EBEA","LAALG","RSY  " 20 RPI 1125 Z196
			56,  //  "EBF2","LOC","RSY2 "   20 RPI 1125 Z196
			56,  //  "EBF3","STOC","RSY2 "  20 RPI 1125 Z196
			20,  //  "EBF4","LAN","RSY  "   20 RPI 1125 Z196
			20,  //  "EBF6","LAO","RSY  "   20 RPI 1125 Z196
			20,  //  "EBF7","LAX","RSY  "   20 RPI 1125 Z196
			20,  //  "EBF8","LAA","RSY  "   20 RPI 1125 Z196
			20,  //  "EBFA","LAAL","RSY  "  20 RPI 1125 Z196
			23,  // 6580 "EC44" "BRXHG" "RIE" 23
			23,  // 6590 "EC44" "JXHG" "RIE" 23
			23,  // 6600 "EC45" "BRXLG" "RIE" 23
			23,  // 6610 "EC45" "JXLEG" "RIE" 23
			52,  // "EC51","RISBLG#","RIE8"  52 RPI 1125 Z196 RPI 1164
			52,  // 'EC51$003132','LOAD (lOW  && HIGH) RISBLGZ','LLHFR','RIE8',52  RPI 1164
			52,  // 'EC51$163132','LOAD LOG HW (lOW  && HIGH) RISBLGZ','LLHLHR','RIE8',52  RPI 1164
			52,  // 'EC51$243132','LOAD LOG CH (lOW  && HIGH) RISBLGZ','LLCLHR','RIE8',52  RPI 1164
			52,  // "EC51Z","RISBLGZ","RIE8"  52 RPI 1125 Z196  RPI 1164
			52,  // 510 "EC54" "RNSBG" "RIE8" 52  RPI 817
			52,     // 'EC54$003100','AND HIGH (HIGH && HIGH) RNSBG','NHHR','RIE8',52  RPI 1164
			52,     // 'EC54$003132','AND HIGH (HIGH && LOW ) RNSBG','NHLR','RIE8',52  RPI 1164
			52,     // 'EC54$326332','AND HIGH (lOW  && HIGH) RNSBG','NLHR','RIE8',52  RPI 1164
			52,  // 520 "EC54T" "RNSBGT" "RIE8" 52  RPI 817
			52,  // 530 "EC55" "RISBG" "RIE2" 52  RPI 817
			52,  // 540 "EC55Z" "RISBGZ" "RIE8" 52  RPI 817
			52,  // 550 "EC56" "ROSBG" "RIE8" 52  RPI 817
			52,  // 'EC56$003100','OR  HIGH (HIGH && HIGH) ROSBG','OHHR','RIE8',52  RPI 1164
			52,  // 'EC56$003132','OR  HIGH (HIGH && LOW ) ROSBG','OHLR','RIE8',52  RPI 1164
			52,  // 'EC56$326332','OR  HIGH (lOW  && HIGH) ROSBG','OLHR','RIE8',52  RPI 1164
			52,  // 560 "EC56T" "ROSBGT" "RIE8" 52  RPI 817
			52,  // 570 "EC57" "RXSBG" "RIE8" 52  RPI 817
			52,     // 'EC57$003100','XOR HIGH (HIGH && HIGH) RXSBG','XHHR','RIE8',52  RPI 1164
			52,     // 'EC57$003132','XOR HIGH (HIGH && LOW ) RXSBG','XHLR','RIE8',52  RPI 1164
			52,     // 'EC57$326332','AOR HIGH (lOW  && HIGH) RXSBG','XLHR','RIE8',52  RPI 1164
			52,  // 580 "EC57T" "RXSBGT" "RIE8" 52  RPI 817
			52,  // "EC5D","RISBHG#","RIE8"  52 RPI 1125 Z196 RPI 1164
			52,  // 'EC5D$003100','LOAD (HIGH && HIGH) RISBHGZ','LHHR','RIE8',52  RPI 1164
			52,  // 'EC5D$003132','LOAD (HIGH && LOW ) RISBHGZ','LHLR','RIE8',52  RPI 1164
			52,  // 'EC5D$163100','LOAD LOG HW (HIGH && HIGH) RISBHGZ','LLHHHR','RIE8',52  RPI 1164
			52,  // 'EC5D$163132','LOAD LOG HW (HIGH && LOW ) RISBHGZ','LLHHLR','RIE8',52  RPI 1164
			52,  // 'EC5D$243100','LOAD LOG CH (HIGH && HIGH) RISBHGZ','LLCHHR','RIE8',52  RPI 1164
			52,  // 'EC5D$243132','LOAD LOG CH (HIGH && LOW ) RISBHGZ','LLCHLR','RIE8',52  RPI 1164
			52,  // "EC5DZ","RISBHGZ","RIE8"  52 RPI 1125 Z196  RPI 1164
			49,  // 10 "EC64" "CGRJ" "RIE6" 49 RPI 817
			50,  // 20 "EC648" "CGRJE" "RIE7" 50 RPI 817
			50,  // 30 "EC642" "CGRJH" "RIE7" 50 RPI 817
			50,  // 40 "EC644" "CGRJL" "RIE7" 50 RPI 817
			50,  // 50 "EC646" "CGRJNE" "RIE7" 50 RPI 817
			50,  // 60 "EC64C" "CGRJNH" "RIE7" 50 RPI 817
			50,  // 70 "EC64A" "CGRJNL" "RIE7" 50 RPI 817
			49,  // 80 "EC65" "CLGRJ" "RIE6" 49 RPI 817
			50,  // 90 "EC658" "CLGRJE" "RIE7" 50 RPI 817
			50,  // 100 "EC652" "CLGRJH" "RIE7" 50 RPI 817
			50,  // 110 "EC654" "CLGRJL" "RIE7" 50 RPI 817
			50,  // 120 "EC656" "CLGRJNE" "RIE7" 50 RPI 817
			50,  // 130 "EC65C" "CLGRJNH" "RIE7" 50 RPI 817
			50,  // 140 "EC65A" "CLGRJNL" "RIE7" 50 RPI 817
			41,  // 1010 "EC70" "CGIT" "RIE2" 41 RPI 817
			42,  // 1020 "EC708" "CGITE" "RIE3" 42 RPI 817
			42,  // 1030 "EC702" "CGITH" "RIE3" 42 RPI 817
			42,  // 1040 "EC704" "CGITL" "RIE3" 42 RPI 817
			42,  // 1050 "EC706" "CGITNE" "RIE3" 42 RPI 817
			42,  // 1060 "EC70C" "CGITNH" "RIE3" 42 RPI 817
			42,  // 1070 "EC70A" "CGITNL" "RIE3" 42 RPI 817 
			41,  // 150 "EC71" "CLGIT" "RIE2" 41 RPI 817
			42,  // 160 "EC718" "CLGITE" "RIE3" 42 RPI 817
			42,  // 170 "EC712" "CLGITH" "RIE3" 42 RPI 817
			42,  // 180 "EC714" "CLGITL" "RIE3" 42 RPI 817
			42,  // 190 "EC716" "CLGITNE" "RIE3" 42 RPI 817
			42,  // 200 "EC71C" "CLGITNH" "RIE3" 42 RPI 817
			42,  // 210 "EC71A" "CLGITNL" "RIE3" 42 RPI 817
			41,  // 1150 "EC72" "CIT" "RIE2" 41 RPI 817
			42,  // 1160 "EC728" "CITE" "RIE3" 42 RPI 817
			42,  // 1170 "EC722" "CITH" "RIE3" 42 RPI 817
			42,  // 1180 "EC724" "CITL" "RIE3" 42 RPI 817
			42,  // 1190 "EC726" "CITNE" "RIE3" 42 RPI 817
			42,  // 1200 "EC72C" "CITNH" "RIE3" 42 RPI 817
			42,  // 1210 "EC72A" "CITNL" "RIE3" 42 RPI 817
			41,  // 220 "EC73" "CLFIT" "RIE2" 41 RPI 817
			42,  // 230 "EC738" "CLFITE" "RIE3" 42 RPI 817
			42,  // 240 "EC732" "CLFITH" "RIE3" 42 RPI 817
			42,  // 250 "EC734" "CLFITL" "RIE3" 42 RPI 817
			42,  // 260 "EC736" "CLFITNE" "RIE3" 42 RPI 817
			42,  // 270 "EC73C" "CLFITNH" "RIE3" 42 RPI 817
			42,  // 280 "EC73A" "CLFITNL" "RIE3" 42 RPI 817
			49,  // 150 "EC76" "CRJ" "RIE6" 49 RPI 817
			50,  // 160 "EC768" "CRJE" "RIE7" 50 RPI 817
			50,  // 170 "EC762" "CRJH" "RIE7" 50 RPI 817
			50,  // 180 "EC764" "CRJL" "RIE7" 50 RPI 817
			50,  // 190 "EC766" "CRJNE" "RIE7" 50 RPI 817
			50,  // 200 "EC76C" "CRJNH" "RIE7" 50 RPI 817
			50,  // 210 "EC76A" "CRJNL" "RIE7" 50 RPI 817
			49,  // 220 "EC77" "CLRJ" "RIE6" 49 RPI 817
			50,  // 230 "EC778" "CLRJE" "RIE7" 50 RPI 817
			50,  // 240 "EC772" "CLRJH" "RIE7" 50 RPI 817
			50,  // 250 "EC774" "CLRJL" "RIE7" 50 RPI 817
			50,  // 260 "EC776" "CLRJNE" "RIE7" 50 RPI 817
			50,  // 270 "EC77C" "CLRJNH" "RIE7" 50 RPI 817
			50,  // 280 "EC77A" "CLRJNL" "RIE7" 50 RPI 817
			43,  // 290 "EC7C" "CGIJ" "RIE4" 43 RPI 817
			44,  // 300 "EC7C8" "CGIJE" "RIE5" 44 RPI 817
			44,  // 310 "EC7C2" "CGIJH" "RIE5" 44 RPI 817
			44,  // 320 "EC7C4" "CGIJL" "RIE5" 44 RPI 817
			44,  // 330 "EC7C6" "CGIJNE" "RIE5" 44 RPI 817
			44,  // 340 "EC7CC" "CGIJNH" "RIE5" 44 RPI 817
			44,  // 350 "EC7CA" "CGIJNL" "RIE5" 44 RPI 817
			43,  // 360 "EC7D" "CLGIJ" "RIE4" 43 RPI 817
			44,  // 370 "EC7D8" "CLGIJE" "RIE5" 44 RPI 817
			44,  // 380 "EC7D2" "CLGIJH" "RIE5" 44 RPI 817
			44,  // 390 "EC7D4" "CLGIJL" "RIE5" 44 RPI 817
			44,  // 400 "EC7D6" "CLGIJNE" "RIE5" 44 RPI 817
			44,  // 410 "EC7DC" "CLGIJNH" "RIE5" 44 RPI 817
			44,  // 420 "EC7DA" "CLGIJNL" "RIE5" 44 RPI 817
			43,  // 430 "EC7E" "CIJ" "RIE4" 43 RPI 817
			44,  // 440 "EC7E8" "CIJE" "RIE5" 44 RPI 817
			44,  // 450 "EC7E2" "CIJH" "RIE5" 44 RPI 817
			44,  // 460 "EC7E4" "CIJL" "RIE5" 44 RPI 817
			44,  // 470 "EC7E6" "CIJNE" "RIE5" 44 RPI 817
			44,  // 480 "EC7EC" "CIJNH" "RIE5" 44 RPI 817
			44,  // 490 "EC7EA" "CIJNL" "RIE5" 44 RPI 817
			43,  // 500 "EC7F" "CLIJ" "RIE4" 43 RPI 817
			44,  // 510 "EC7F8" "CLIJE" "RIE5" 44 RPI 817
			44,  // 520 "EC7F2" "CLIJH" "RIE5" 44 RPI 817
			44,  // 530 "EC7F4" "CLIJL" "RIE5" 44 RPI 817
			44,  // 540 "EC7F6" "CLIJNE" "RIE5" 44 RPI 817
			44,  // 550 "EC7FC" "CLIJNH" "RIE5" 44 RPI 817
			44,  // 560 "EC7FA" "CLIJNL" "RIE5" 44 RPI 817
			57,  // "ECD8","AHIK","RIE9"    57 RPI 1125 Z196
			57,  // "ECD9","AGHIK","RIE9"   57 RPI 1125 Z196
			57,  // "ECDA","ALHSIK","RIE9"  57 RPI 1125 Z196
			57,  // "ECDB","ALGHSIK","RIE9" 57 RPI 1125 Z196
			45,  // 570 "ECE4" "CGRB" "RRS1" 45 RPI 817
			46,  // 580 "ECE48" "CGRBE" "RRS2" 446, RPI 817
			46,  // 590 "ECE42" "CGRBH" "RRS2" 46 RPI 817
			46,  // 600 "ECE44" "CGRBL" "RRS2" 46 RPI 817
			46,  // 610 "ECE46" "CGRBNE" "RRS2" 46 RPI 817
			46,  // 620 "ECE4C" "CGRBNH" "RRS2" 46 RPI 817
			46,  // 630 "ECE4A" "CGRBNL" "RRS2" 46 RPI 817
			45,  // 640 "ECE5" "CLGRB" "RRS1" 45 RPI 817
			46,  // 650 "ECE58" "CLGRBE" "RRS2" 46 RPI 817
			46,  // 660 "ECE52" "CLGRBH" "RRS2" 46 RPI 817
			46,  // 670 "ECE54" "CLGRBL" "RRS2" 46 RPI 817
			46,  // 680 "ECE56" "CLGRBNE" "RRS2" 46 RPI 817
			46,  // 690 "ECE5C" "CLGRBNH" "RRS2" 46 RPI 817
			46,  // 700 "ECE5A" "CLGRBNL" "RRS2" 46 RPI 817
			45,  // 710 "ECF6" "CRB" "RRS1" 45 RPI 817
			46,  // 720 "ECF68" "CRBE" "RRS2" 46 RPI 817
			46,  // 730 "ECF62" "CRBH" "RRS2" 46 RPI 817
			46,  // 740 "ECF64" "CRBL" "RRS2" 46 RPI 817
			46,  // 750 "ECF66" "CRBNE" "RRS2" 45 RPI 817
			46,  // 760 "ECF6C" "CRBNH" "RRS2" 46 RPI 817
			46,  // 770 "ECF6A" "CRBNL" "RRS2" 46 RPI 817
			45,  // 780 "ECF7" "CLRB" "RRS1" 45 RPI 817
			46,  // 790 "ECF78" "CLRBE" "RRS2" 46 RPI 817
			46,  // 800 "ECF72" "CLRBH" "RRS2" 46 RPI 817
			46,  // 810 "ECF74" "CLRBL" "RRS2" 46 RPI 817
			46,  // 820 "ECF76" "CLRBNE" "RRS2" 46 RPI 817
			46,  // 830 "ECF7C" "CLRBNH" "RRS2" 46 RPI 817
			46,  // 840 "ECF7A" "CLRBNL" "RRS2" 46 RPI 817
			47,  // 850 "ECFC" "CGIB" "RRS3" 47 RPI 817
			48,  // 860 "ECFC8" "CGIBE" "RRS4" 48 RPI 817
			48,  // 870 "ECFC2" "CGIBH" "RRS4" 48 RPI 817
			48,  // 880 "ECFC4" "CGIBL" "RRS4" 48 RPI 817
			48,  // 890 "ECFC6" "CGIBNE" "RRS4" 48 RPI 817
			48,  // 900 "ECFCC" "CGIBNH" "RRS4" 48 RPI 817
			48,  // 910 "ECFCA" "CGIBNL" "RRS4" 48 RPI 817
			47,  // 920 "ECFD" "CLGIB" "RRS3" 47 RPI 817
			48,  // 930 "ECFD8" "CLGIBE" "RRS4" 48 RPI 817
			48,  // 940 "ECFD2" "CLGIBH" "RRS4" 48 RPI 817
			48,  // 950 "ECFD4" "CLGIBL" "RRS4" 48 RPI 817
			48,  // 960 "ECFD6" "CLGIBNE" "RRS4" 48 RPI 817
			48,  // 970 "ECFDC" "CLGIBNH" "RRS4" 48 RPI 817
			48,  // 980 "ECFDA" "CLGIBNL" "RRS4" 48 RPI 817
			47,  // 990 "ECFE" "CIB" "RRS3" 47 RPI 817
			48,  // 1000 "ECFE8" "CIBE" "RRS4" 48 RPI 817
			48,  // 1010 "ECFE2" "CIBH" "RRS4" 48 RPI 817
			48,  // 1020 "ECFE4" "CIBL" "RRS4" 48 RPI 817
			48,  // 1030 "ECFE6" "CIBNE" "RRS4" 48 RPI 817
			48,  // 1040 "ECFEC" "CIBNH" "RRS4" 48 RPI 817
			48,  // 1050 "ECFEA" "CIBNL" "RRS4" 48 RPI 817
			47,  // 1060 "ECFF" "CLIB" "RRS3" 47 RPI 817
			48,  // 1070 "ECFF8" "CLIBE" "RRS4" 48 RPI 817
			48,  // 1080 "ECFF2" "CLIBH" "RRS4" 48 RPI 817
			48,  // 1090 "ECFF4" "CLIBL" "RRS4" 48 RPI 817
			48,  // 1100 "ECFF6" "CLIBNE" "RRS4" 48 RPI 817
			48,  // 1110 "ECFFC" "CLIBNH" "RRS4" 48 RPI 817
			48,  // 1120 "ECFFA" "CLIBNL" "RRS4" 48 RPI 817
			24,  // 6620 "ED04" "LDEB" "RXE" 24
			24,  // 6630 "ED05" "LXDB" "RXE" 24
			24,  // 6640 "ED06" "LXEB" "RXE" 24
			24,  // 6650 "ED07" "MXDB" "RXE" 24
			24,  // 6660 "ED08" "KEB" "RXE" 24
			24,  // 6670 "ED09" "CEB" "RXE" 24
			24,  // 6680 "ED0A" "AEB" "RXE" 24
			24,  // 6690 "ED0B" "SEB" "RXE" 24
			24,  // 6700 "ED0C" "MDEB" "RXE" 24
			24,  // 6710 "ED0D" "DEB" "RXE" 24
			25,  // 6720 "ED0E" "MAEB" "RXF" 25
			25,  // 6730 "ED0F" "MSEB" "RXF" 25
			24,  // 6740 "ED10" "TCEB" "RXE" 24
			24,  // 6750 "ED11" "TCDB" "RXE" 24
			24,  // 6760 "ED12" "TCXB" "RXE" 24
			24,  // 6770 "ED14" "SQEB" "RXE" 24
			24,  // 6780 "ED15" "SQDB" "RXE" 24
			24,  // 6790 "ED17" "MEEB" "RXE" 24
			24,  // 6800 "ED18" "KDB" "RXE" 24
			24,  // 6810 "ED19" "CDB" "RXE" 24
			24,  // 6820 "ED1A" "ADB" "RXE" 24
			24,  // 6830 "ED1B" "SDB" "RXE" 24
			24,  // 6840 "ED1C" "MDB" "RXE" 24
			24,  // 6850 "ED1D" "DDB" "RXE" 24
			25,  // 6860 "ED1E" "MADB" "RXF" 25
			25,  // 6870 "ED1F" "MSDB" "RXF" 25
			24,  // 6880 "ED24" "LDE" "RXE" 24
			24,  // 6890 "ED25" "LXD" "RXE" 24
			24,  // 6900 "ED26" "LXE" "RXE" 24
			25,  // 6910 "ED2E" "MAE" "RXF" 25
			25,  // 6920 "ED2F" "MSE" "RXF" 25
			24,  // 6930 "ED34" "SQE" "RXE" 24
			24,  // 6940 "ED35" "SQD" "RXE" 24
			24,  // 6950 "ED37" "MEE" "RXE" 24
			25,  //      "ED38" "MAYL" "RXF" 25 Z9-46
			25,  //      "ED39" "MYL" "RXF" 25 Z9-47
			25,  //      "ED3A" "MAY" "RXF" 25 Z9-48
			25,  //      "ED3B" "MY" "RXF" 25 Z9-49 RPI 298
			25,  //      "ED3C" "MAYH" "RXF" 25 Z9-50
			25,  //      "ED3D" "MYH" "RXF" 25 Z9-51 RPI 298
			25,  // 6960 "ED3E" "MAD" "RXF" 25
			25,  // 6970 "ED3F" "MSD" "RXF" 25
			25, // "SLDT" "ED40" "RXF" DFP 45
			25, // "SRDT" "ED41" "RXF" DFP 46
			25, // "SLXT" "ED48" "RXF" DFP 47
			25, // "SRXT" "ED49" "RXF" DFP 48
			24, // "TDCET" "ED50" "RXE" DFP 49
			24, // "TDGET" "ED51" "RXE" DFP 50
			24, // "TDCDT" "ED54" "RXE" DFP 51
			24, // "TDGDT" "ED55" "RXE" DFP 52
			24, // "TDCXT" "ED58" "RXE" DFP 53
			24, // "TDGXT" "ED59" "RXE" DFP 54
			18,  // 6980 "ED64" "LEY" "RXY" 18
			18,  // 6990 "ED65" "LDY" "RXY" 18
			18,  // 7000 "ED66" "STEY" "RXY" 18
			18,  // 7010 "ED67" "STDY" "RXY" 18
			27,  // 7020 "EE" "PLO" "SS3" 27
			28,  // 7030 "EF" "LMD" "SS4" 28
			29,  // 7040 "F0" "SRP" "SS5" 29
			26,  // 7050 "F1" "MVO" "SS2" 26
			26,  // 7060 "F2" "PACK" "SS2" 26
			26,  // 7070 "F3" "UNPK" "SS2" 26
			26,  // 7080 "F8" "ZAP" "SS2" 26
			26,  // 7090 "F9" "CP" "SS2" 26
			26,  // 7100 "FA" "AP" "SS2" 26
			26,  // 7110 "FB" "SP" "SS2" 26
			26,  // 7120 "FC" "MP" "SS2" 26
			26,  // 7130 "FD" "DP" "SS2" 26
			101,  // 7140  "CCW"  101
			102,  // 7150  "CCW0"  102
			103,  // 7160  "CCW1"  103
			104,  // 7170  "DC"  104
			105,  // 7180  "DS"  105
			106,  // 7190  "ALIAS"  106
			107,  // 7200  "AMODE"  107
			108,  // 7210  "CATTR"  108
			109,  // 7220  "COM"  109
			110,  // 7230  "CSECT"  110
			111,  // 7240  "CXD"  111
			112,  // 7250  "DSECT"  112
			113,  // 7260  "DXD"  113
			114,  // 7270  "ENTRY"  114
			115,  // 7280  "EXTRN"  115
			116,  // 7290  "LOCTR"  116
			117,  // 7300  "RMODE"  117
			118,  // 7310  "RSECT"  118
			119,  // 7320  "START"  119
			120,  // 7330  "WXTRN"  120
			121,  // 7340  "XATTR"  121
			122,  // 7350  ""  122
			123,  // 7360  "DROP"  123
			124,  // 7370  "USING"  124
			125,  // 7380  "AEJECT"  125
			126,  // 7390  "ASPACE"  126
			127,  // 7400  "CEJECT"  127
			128,  // 7410  "EJECT"  128
			129,  // 7420  "PRINT"  129
			130,  // 7430  "SPACE"  130
			131,  // 7440  "TITLE"  131
			132,  // 7450  "ADATA"  132
			133,  // 7460  "CNOP"  133
			224,  // 7470  "COPY"  224
			135,  // 7480  "END"  135
			136,  // 7490  "EQU"  136
			137,  // 7500  "EXITCTL"  137
			138,  // 7510  "ICTL"  138
			139,  // 7520  "ISEQ"  139
			140,  // 7530  "LTORG"  140
			225,  // 7540  "OPSYN"  225 //RPI150
			142,  // 7550  "ORG"  142
			143,  // 7560  "POP"  143
			223,  // 7570  "PUNCH"  223
			145,  // 7580  "PUSH"  145
			146,  // 7590  "REPRO"  146
			147,  // 7595  "ACONTROL" 147 // RPI 368
			201,  // 7600  "ACTR"
			202,  // 7610  "AGO"
			203,  // 7625  "AIF"
			204,  // 7630  "AINSERT"
			205,  // 7640  "ANOP"
			206,  // 7650  "AREAD"
			207,  // 7660  "GBLA"
			208,  // 7670  "GBLB"
			209,  // 7680  "GBLC"
			210,  // 7690  "LCLA"
			211,  // 7700  "LCLB"
			212,  // 7710  "LCLC"
			213,  // 7720  "MHELP"
			214,  // 7730  "MNOTE"
			215,  // 7740  "SETA"
			216,  // 7750  "SETAF"
			217,  // 7760  "SETB"
			218,  // 7770  "SETC"
			219,  // 7780  "SETCF"
			220,  // 7790  "MACRO"
			221,  // 7800  "MEND"
			222,  // 7810  "MEXIT"
			226,  // 7820  "AGOB"
			227,  // 7830  "AIFB"
	};
}
