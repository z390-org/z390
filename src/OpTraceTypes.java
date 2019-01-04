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
 * Helper class for complete op type information.
 *
 * @author jba68/z390
 */
public class OpTraceTypes {

	final static int[] op_trace_type = {
			00,  // comments
			10,  //  10 "0101" "PR" "E" 1
			10,  //  20 "0102" "UPT" "E" 1
			10,  //     "0104" "PTFF" "E" 1 Z9-1
			10,  //  30 "0107" "SCKPF" "E" 1
			10,  //  40 "010A" "PFPO" "E" 1   RPI 1013
			10,  //  40 "010B" "TAM" "E" 1
			10,  //  50 "010C" "SAM24" "E" 1
			10,  //  60 "010D" "SAM31" "E" 1
			10,  //  70 "010E" "SAM64" "E" 1
			10,  //  80 "01FF" "TRAP2" "E" 1
			20,  //  90 "04" "SPM" "RR" 2
			20,  // 100 "05" "BALR" "RR" 2
			20,  // 110 "06" "BCTR" "RR" 2
			30,  // 120 "07" "BCR" "RR" 2
			30,  // 130 "07F" "BR" "BRX" 3
			30,  // 140 "070" "NOPR" "BRX" 3
			30,  // 150 "072" "BHR" "BRX" 3
			30,  // 160 "074" "BLR" "BRX" 3
			30,  // 170 "078" "BER" "BRX" 3
			30,  // 180 "07D" "BNHR" "BRX" 3
			30,  // 190 "07B" "BNLR" "BRX" 3
			30,  // 200 "077" "BNER" "BRX" 3
			30,  // 210 "072" "BPR" "BRX" 3
			30,  // 220 "071" "BOR" "BRX" 3
			30,  // 230 "074" "BMR" "BRX" 3
			30,  // 240 "078" "BZR" "BRX" 3
			30,  // 250 "07D" "BNPR" "BRX" 3
			30,  // 260 "07B" "BNMR" "BRX" 3
			30,  // 270 "077" "BNZR" "BRX" 3
			30,  // 280 "07E" "BNOR" "BRX" 3
			40,  // 290 "0A" "SVC" "I" 4
			20,  // 300 "0B" "BSM" "RR" 2
			20,  // 310 "0C" "BASSM" "RR" 2
			20,  // 320 "0D" "BASR" "RR" 2
			22,  // 330 "0E" "MVCL" "RR" 2
			22,  // 340 "0F" "CLCL" "RR" 2
			20,  // 350 "10" "LPR" "RR" 2
			20,  // 360 "11" "LNR" "RR" 2
			20,  // 370 "12" "LTR" "RR" 2
			20,  // 380 "13" "LCR" "RR" 2
			20,  // 390 "14" "NR" "RR" 2
			20,  // 400 "15" "CLR" "RR" 2
			20,  // 410 "16" "OR" "RR" 2
			20,  // 420 "17" "XR" "RR" 2
			20,  // 430 "18" "LR" "RR" 2
			20,  // 440 "19" "CR" "RR" 2
			20,  // 450 "1A" "AR" "RR" 2
			20,  // 460 "1B" "SR" "RR" 2
			23,  // 470 "1C" "MR" "RR" 2
			23,  // 480 "1D" "DR" "RR" 2
			20,  // 490 "1E" "ALR" "RR" 2
			20,  // 500 "1F" "SLR" "RR" 2
			21,  // 510 "20" "LPDR" "RR" 2
			21,  // 520 "21" "LNDR" "RR" 2
			21,  // 530 "22" "LTDR" "RR" 2
			21,  // 540 "23" "LCDR" "RR" 2
			21,  // 550 "24" "HDR" "RR" 2
			21,  // 560 "25" "LDXR" "RR" 2
			21,  // 570 "25" "LRDR" "RR" 2
			21,  // 580 "26" "MXR" "RR" 2
			21,  // 590 "27" "MXDR" "RR" 2
			21,  // 600 "28" "LDR" "RR" 2
			21,  // 610 "29" "CDR" "RR" 2
			21,  // 620 "2A" "ADR" "RR" 2
			21,  // 630 "2B" "SDR" "RR" 2
			21,  // 640 "2C" "MDR" "RR" 2
			21,  // 650 "2D" "DDR" "RR" 2
			21,  // 660 "2E" "AWR" "RR" 2
			21,  // 670 "2F" "SWR" "RR" 2
			21,  // 680 "30" "LPER" "RR" 2
			21,  // 690 "31" "LNER" "RR" 2
			21,  // 700 "32" "LTER" "RR" 2
			21,  // 710 "33" "LCER" "RR" 2
			21,  // 720 "34" "HER" "RR" 2
			21,  // 730 "35" "LEDR" "RR" 2
			21,  // 740 "35" "LRER" "RR" 2
			21,  // 750 "36" "AXR" "RR" 2
			21,  // 760 "37" "SXR" "RR" 2
			21,  // 770 "38" "LER" "RR" 2
			21,  // 780 "39" "CER" "RR" 2
			21,  // 790 "3A" "AER" "RR" 2
			21,  // 800 "3B" "SER" "RR" 2
			21,  // 810 "3C" "MDER" "RR" 2
			21,  // 820 "3C" "MER" "RR" 2
			21,  // 830 "3D" "DER" "RR" 2
			21,  // 840 "3E" "AUR" "RR" 2
			21,  // 850 "3F" "SUR" "RR" 2
			53,  // 860 "40" "STH" "RX" 5
			52,  // 870 "41" "LA" "RX" 5
			56,  // 880 "42" "STC" "RX" 5
			56,  // 890 "43" "IC" "RX" 5
			59,  // 900 "44" "EX" "RX" 5  // RPI 1035
			51,  // 910 "45" "BAL" "RX" 5
			50,  // 920 "46" "BCT" "RX" 5
			50,  // 930 "47" "BC" "RX" 5
			60,  // 940 "47F" "B" "BCX" 6
			60,  // 950 "470" "NOP" "BCX" 6
			60,  // 960 "472" "BH" "BCX" 6
			60,  // 970 "474" "BL" "BCX" 6
			60,  // 980 "478" "BE" "BCX" 6
			60,  // 990 "47D" "BNH" "BCX" 6
			60,  // 1000 "47B" "BNL" "BCX" 6
			60,  // 1010 "477" "BNE" "BCX" 6
			60,  // 1020 "472" "BP" "BCX" 6
			60,  // 1030 "471" "BO" "BCX" 6
			60,  // 1040 "474" "BM" "BCX" 6
			60,  // 1050 "478" "BZ" "BCX" 6
			60,  // 1060 "47D" "BNP" "BCX" 6
			60,  // 1070 "47B" "BNM" "BCX" 6
			60,  // 1080 "477" "BNZ" "BCX" 6
			60,  // 1090 "47E" "BNO" "BCX" 6
			53,  // 1100 "48" "LH" "RX" 5
			53,  // 1110 "49" "CH" "RX" 5
			53,  // 1120 "4A" "AH" "RX" 5
			53,  // 1130 "4B" "SH" "RX" 5
			53,  // 1140 "4C" "MH" "RX" 5
			50,  // 1150 "4D" "BAS" "RX" 5
			57,  // 1160 "4E" "CVD" "RX" 5  RPI 588
			57,  // 1170 "4F" "CVB" "RX" 5  RPI 588
			50,  // 1180 "50" "ST" "RX" 5
			52,  // 1190 "51" "LAE" "RX" 5
			50,  // 1193 "52" "XDECO" "RX" 37 RPI 812
			50,  // 1196 "53" "XDECI" "RX" 37 RPI 812	
			50,  // 1200 "54" "N" "RX" 5
			50,  // 1210 "55" "CL" "RX" 5
			50,  // 1220 "56" "O" "RX" 5
			50,  // 1230 "57" "X" "RX" 5
			50,  // 1240 "58" "L" "RX" 5
			50,  // 1250 "59" "C" "RX" 5
			50,  // 1260 "5A" "A" "RX" 5
			50,  // 1270 "5B" "S" "RX" 5
			55,  // 1280 "5C" "M" "RX" 5
			55,  // 1290 "5D" "D" "RX" 5
			50,  // 1300 "5E" "AL" "RX" 5
			50,  // 1310 "5F" "SL" "RX" 5
			54,  // 1320 "60" "STD" "RX" 5
			50,  // 1323 "61" "XHEXI" "RX" 37 RPI 812
			50,  // 1326 "62" "XHEXO" "RX" 37 RPI 812
			54,  // 1330 "67" "MXD" "RX" 5
			54,  // 1340 "68" "LD" "RX" 5
			54,  // 1350 "69" "CD" "RX" 5
			54,  // 1360 "6A" "AD" "RX" 5
			54,  // 1370 "6B" "SD" "RX" 5
			54,  // 1380 "6C" "MD" "RX" 5
			54,  // 1390 "6D" "DD" "RX" 5
			54,  // 1400 "6E" "AW" "RX" 5
			54,  // 1410 "6F" "SW" "RX" 5
			58,  // 1420 "70" "STE" "RX" 5  // RPI 834
			50,  // 1430 "71" "MS" "RX" 5  RPI 627
			58,  // 1440 "78" "LE" "RX" 5  // RPI 834
			58,  // 1450 "79" "CE" "RX" 5  // RPI 834
			58,  // 1460 "7A" "AE" "RX" 5  // RPI 834
			58,  // 1470 "7B" "SE" "RX" 5  // RPI 834
			58,  // 1480 "7C" "MDE" "RX" 5  // RPI 834
			58,  // 1490 "7C" "ME" "RX" 5  // RPI 834
			58,  // 1500 "7D" "DE" "RX" 5  // RPI 834
			58,  // 1510 "7E" "AU" "RX" 5  // RPI 834
			58,  // 1520 "7F" "SU" "RX" 5  // RPI 834
			70,  // 1530 "8000" "SSM" "S" 7
			70,  // 1540 "8202" "LPSW" "S" 7
			80,  // 1550 "83" "DIAGNOSE" "DM" 8
			91,  // 1560 "84" "BRXH" "RSI" 9
			91,  // 1570 "84" "JXH" "RSI" 9
			91,  // 1580 "85" "BRXLE" "RSI" 9
			91,  // 1590 "85" "JXLE" "RSI" 9
			103,  // 1600 "86" "BXH" "RS" 10
			103,  // 1610 "87" "BXLE" "RS" 10
			102,  // 1620 "88" "SRL" "RS" 10
			102,  // 1630 "89" "SLL" "RS" 10
			102,  // 1640 "8A" "SRA" "RS" 10
			102,  // 1650 "8B" "SLA" "RS" 10
			102,  // 1660 "8C" "SRDL" "RS" 10
			102,  // 1670 "8D" "SLDL" "RS" 10
			102,  // 1680 "8E" "SRDA" "RS" 10
			102,  // 1690 "8F" "SLDA" "RS" 10
			100,  // 1700 "90" "STM" "RS" 10
			110,  // 1710 "91" "TM" "SI" 11
			110,  // 1720 "92" "MVI" "SI" 11
			70,  // 1730 "93" "TS" "S" 7
			110,  // 1740 "94" "NI" "SI" 11
			110,  // 1750 "95" "CLI" "SI" 11
			110,  // 1760 "96" "OI" "SI" 11
			110,  // 1770 "97" "XI" "SI" 11
			100,  // 1780 "98" "LM" "RS" 10
			100,  // 1790 "99" "TRACE" "RS" 10
			100,  // 1800 "9A" "LAM" "RS" 10
			100,  // 1810 "9B" "STAM" "RS" 10
			120,  // 1820 "A50" "IIHH" "RI" 12
			120,  // 1830 "A51" "IIHL" "RI" 12
			120,  // 1840 "A52" "IILH" "RI" 12
			120,  // 1850 "A53" "IILL" "RI" 12
			120,  // 1860 "A54" "NIHH" "RI" 12
			120,  // 1870 "A55" "NIHL" "RI" 12
			120,  // 1880 "A56" "NILH" "RI" 12
			120,  // 1890 "A57" "NILL" "RI" 12
			120,  // 1900 "A58" "OIHH" "RI" 12
			120,  // 1910 "A59" "OIHL" "RI" 12
			120,  // 1920 "A5A" "OILH" "RI" 12
			120,  // 1930 "A5B" "OILL" "RI" 12
			120,  // 1940 "A5C" "LLIHH" "RI" 12
			120,  // 1950 "A5D" "LLIHL" "RI" 12
			120,  // 1960 "A5E" "LLILH" "RI" 12
			120,  // 1970 "A5F" "LLILL" "RI" 12
			123,  // 1980 "A70" "TMLH" "RI" 12
			123,  // 1990 "A70" "TMH" "RI" 12
			123,  // 2000 "A71" "TMLL" "RI" 12
			123,  // 2010 "A71" "TML" "RI" 12
			123,  // 2020 "A72" "TMHH" "RI" 12
			123,  // 2030 "A73" "TMHL" "RI" 12
			130,  // 2040 "A74" "BRC" "RI" 12
			130,  // 2050 "A74F" "J" "BRCX" 13
			130,  // 2060 "A740" "JNOP" "BRCX" 13
			130,  // 2070 "A74F" "BRU" "BRCX" 13
			130,  // 2080 "A742" "BRH" "BRCX" 13
			130,  // 2090 "A744" "BRL" "BRCX" 13
			130,  // 2100 "A748" "BRE" "BRCX" 13
			130,  // 2110 "A74D" "BRNH" "BRCX" 13
			130,  // 2120 "A74B" "BRNL" "BRCX" 13
			130,  // 2130 "A747" "BRNE" "BRCX" 13
			130,  // 2140 "A742" "BRP" "BRCX" 13
			130,  // 2150 "A744" "BRM" "BRCX" 13
			130,  // 2160 "A748" "BRZ" "BRCX" 13
			130,  // 2170 "A741" "BRO" "BRCX" 13
			130,  // 2180 "A74D" "BRNP" "BRCX" 13
			130,  // 2190 "A74B" "BRNM" "BRCX" 13
			130,  // 2200 "A747" "BRNZ" "BRCX" 13
			130,  // 2210 "A74E" "BRNO" "BRCX" 13
			130,  // 2220 "A742" "JH" "BRCX" 13
			130,  // 2230 "A744" "JL" "BRCX" 13
			130,  // 2240 "A748" "JE" "BRCX" 13
			130,  // 2250 "A74D" "JNH" "BRCX" 13
			130,  // 2260 "A74B" "JNL" "BRCX" 13
			130,  // 2270 "A747" "JNE" "BRCX" 13
			130,  // 2280 "A742" "JP" "BRCX" 13 
			130,  // 2290 "A744" "JM" "BRCX" 13
			130,  // 2300 "A748" "JZ" "BRCX" 13
			130,  // 2310 "A741" "JO" "BRCX" 13
			130,  // 2320 "A74D" "JNP" "BRCX" 13
			130,  // 2330 "A74B" "JNM" "BRCX" 13
			130,  // 2340 "A747" "JNZ" "BRCX" 13
			130,  // 2350 "A74E" "JNO" "BRCX" 13
			121,  // 2360 "A75" "BRAS" "RI" 12
			121,  // 2370 "A75" "JAS" "RI" 12
			121,  // 2380 "A76" "BRCT" "RI" 12
			121,  // 2390 "A76" "JCT" "RI" 12
			121,  // 2400 "A77" "BRCTG" "RI" 12
			121,  // 2410 "A77" "JCTG" "RI" 12
			122,  // 2420 "A78" "LHI" "RI" 12
			123,  // 2430 "A79" "LGHI" "RI" 12
			122,  // 2440 "A7A" "AHI" "RI" 12
			123,  // 2450 "A7B" "AGHI" "RI" 12
			122,  // 2460 "A7C" "MHI" "RI" 12
			123,  // 2470 "A7D" "MGHI" "RI" 12
			122,  // 2480 "A7E" "CHI" "RI" 12
			123,  // 2490 "A7F" "CGHI" "RI" 12
			104,  // 2500 "A8" "MVCLE" "RS" 10  RPI 1112
			104,  // 2510 "A9" "CLCLE" "RS" 10  RPI 1112
			110,  // 2520 "AC" "STNSM" "SI" 11
			110,  // 2530 "AD" "STOSM" "SI" 11
			100,  // 2540 "AE" "SIGP" "RS" 10
			110,  // 2550 "AF" "MC" "SI" 11
			50,  // 2560 "B1" "LRA" "RX" 5
			70,  // 2570 "B202" "STIDP" "S" 7
			70,  // 2580 "B204" "SCK" "S" 7
			70,  // 2590 "B205" "STCK" "S" 7
			70,  // 2600 "B206" "SCKC" "S" 7
			70,  // 2610 "B207" "STCKC" "S" 7
			70,  // 2620 "B208" "SPT" "S" 7
			70,  // 2630 "B209" "STPT" "S" 7
			70,  // 2640 "B20A" "SPKA" "S" 7
			70,  // 2650 "B20B" "IPK" "S" 7
			70,  // 2660 "B20D" "PTLB" "S" 7
			70,  // 2670 "B210" "SPX" "S" 7
			70,  // 2680 "B211" "STPX" "S" 7
			70,  // 2690 "B212" "STAP" "S" 7
			70,  // 2700 "B218" "PC" "S" 7
			70,  // 2710 "B219" "SAC" "S" 7
			70,  // 2720 "B21A" "CFC" "S" 7
			140,  // 2730 "B221" "IPTE" "RRE" 14
			140,  // 2740 "B222" "IPM" "RRE" 14
			140,  // 2750 "B223" "IVSK" "RRE" 14
			140,  // 2760 "B224" "IAC" "RRE" 14
			140,  // 2770 "B225" "SSAR" "RRE" 14
			140,  // 2780 "B226" "EPAR" "RRE" 14
			140,  // 2790 "B227" "ESAR" "RRE" 14
			140,  // 2800 "B228" "PT" "RRE" 14
			140,  // 2810 "B229" "ISKE" "RRE" 14
			140,  // 2820 "B22A" "RRBE" "RRE" 14
			140,  // 2830 "B22B" "SSKE" "RRE" 14
			140,  // 2840 "B22C" "TB" "RRE" 14
			142,  // 2850 "B22D" "DXR" "RRE" 14
			140,  // 2860 "B22E" "PGIN" "RRE" 14
			140,  // 2870 "B22F" "PGOUT" "RRE" 14
			70,  // 2880 "B230" "CSCH" "S" 7
			70,  // 2890 "B231" "HSCH" "S" 7
			70,  // 2900 "B232" "MSCH" "S" 7
			70,  // 2910 "B233" "SSCH" "S" 7
			70,  // 2920 "B234" "STSCH" "S" 7
			70,  // 2930 "B235" "TSCH" "S" 7
			70,  // 2940 "B236" "TPI" "S" 7
			70,  // 2950 "B237" "SAL" "S" 7
			70,  // 2960 "B238" "RSCH" "S" 7
			70,  // 2970 "B239" "STCRW" "S" 7
			70,  // 2980 "B23A" "STCPS" "S" 7
			70,  // 2990 "B23B" "RCHP" "S" 7
			70,  // 3000 "B23C" "SCHM" "S" 7
			140,  // 3010 "B240" "BAKR" "RRE" 14
			140,  // 3020 "B241" "CKSM" "RRE" 14
			142,  // 3030 "B244" "SQDR" "RRE" 14
			142,  // 3040 "B245" "SQER" "RRE" 14
			140,  // 3050 "B246" "STURA" "RRE" 14
			140,  // 3060 "B247" "MSTA" "RRE" 14
			140,  // 3070 "B248" "PALB" "RRE" 14
			140,  // 3080 "B249" "EREG" "RRE" 14
			140,  // 3090 "B24A" "ESTA" "RRE" 14
			140,  // 3100 "B24B" "LURA" "RRE" 14
			140,  // 3110 "B24C" "TAR" "RRE" 14
			149,  // 3120 "B24D" "CPYA" "RRE" 14 // RPI 1055
			149,  // 3130 "B24E" "SAR" "RRE" 14 // RPI 1055
			149,  // 3140 "B24F" "EAR" "RRE" 14 // RPI 1055
			140,  // 3150 "B250" "CSP" "RRE" 14
			140,  // 3160 "B252" "MSR" "RRE" 14
			140,  // 3170 "B254" "MVPG" "RRE" 14
			140,  // 3180 "B255" "MVST" "RRE" 14
			140,  // 3190 "B257" "CUSE" "RRE" 14
			140,  // 3200 "B258" "BSG" "RRE" 14
			140,  // 3210 "B25A" "BSA" "RRE" 14
			140,  // 3220 "B25D" "CLST" "RRE" 14
			140,  // 3230 "B25E" "SRST" "RRE" 14
			140,  // 3240 "B263" "CMPSC" "RRE" 14
			70,  // 3250 "B276" "XSCH" "S" 7
			70,  // 3260 "B277" "RP" "S" 7
			70,  // 3270 "B278" "STCKE" "S" 7
			70,  // 3280 "B279" "SACF" "S" 7
			70,  //      "B27C" "STCKF" "S" 7 Z9-2
			70,  // 3290 "B27D" "STSI" "S" 7
			71,  // 3300 "B299" "SRNM" "S" 7
			72,  // 3310 "B29C" "STFPC" "S" 7
			72,  // 3320 "B29D" "LFPC" "S" 7
			140,  // 3330 "B2A5" "TRE" "RRE" 14
			140,  // 3340 "B2A6" "CUUTF" "RRE" 14
			140,  // 3350 "B2A6" "CU21" "RRE" 14
			140,  // 3360 "B2A7" "CUTFU" "RRE" 14
			140,  // 3370 "B2A7" "CU12" "RRE" 14
			70,  //      "B2B0" "STFLE" "S" 7 Z9-3
			70,  // 3380 "B2B1" "STFL" "S" 7
			70,  // 3390 "B2B2" "LPSWE" "S" 7
			70,  // 3392 "B2B8" "SRNMB" "S" 7 RPI 1125
			71,  // 3395 "B2B9" "T" "S" 7 DFP 56
			72,  // 3395 "B2BD" "LFAS"  "S" 7 DFP 55
			70,  // 3400 "B2FF" "TRAP4" "S" 7
			142,  // 3410 "B300" "LPEBR" "RRE" 14
			142,  // 3420 "B301" "LNEBR" "RRE" 14
			142,  // 3430 "B302" "LTEBR" "RRE" 14
			142,  // 3440 "B303" "LCEBR" "RRE" 14
			142,  // 3450 "B304" "LDEBR" "RRE" 14
			142,  // 3460 "B305" "LXDBR" "RRE" 14
			142,  // 3470 "B306" "LXEBR" "RRE" 14
			142,  // 3480 "B307" "MXDBR" "RRE" 14
			142,  // 3490 "B308" "KEBR" "RRE" 14
			142,  // 3500 "B309" "CEBR" "RRE" 14
			142,  // 3510 "B30A" "AEBR" "RRE" 14
			142,  // 3520 "B30B" "SEBR" "RRE" 14
			142,  // 3530 "B30C" "MDEBR" "RRE" 14
			142,  // 3540 "B30D" "DEBR" "RRE" 14
			150,  // 3550 "B30E" "MAEBR" "RRF1" 15
			150,  // 3560 "B30F" "MSEBR" "RRF1" 15
			142,  // 3570 "B310" "LPDBR" "RRE" 14
			142,  // 3580 "B311" "LNDBR" "RRE" 14
			142,  // 3590 "B312" "LTDBR" "RRE" 14
			142,  // 3600 "B313" "LCDBR" "RRE" 14
			142,  // 3610 "B314" "SQEBR" "RRE" 14
			142,  // 3620 "B315" "SQDBR" "RRE" 14
			142,  // 3630 "B316" "SQXBR" "RRE" 14
			142,  // 3640 "B317" "MEEBR" "RRE" 14
			142,  // 3650 "B318" "KDBR" "RRE" 14
			142,  // 3660 "B319" "CDBR" "RRE" 14
			142,  // 3670 "B31A" "ADBR" "RRE" 14
			142,  // 3680 "B31B" "SDBR" "RRE" 14
			142,  // 3690 "B31C" "MDBR" "RRE" 14
			142,  // 3700 "B31D" "DDBR" "RRE" 14
			150,  // 3710 "B31E" "MADBR" "RRF1" 15
			150,  // 3720 "B31F" "MSDBR" "RRF1" 15
			142,  // 3730 "B324" "LDER" "RRE" 14
			142,  // 3740 "B325" "LXDR" "RRE" 14
			142,  // 3750 "B326" "LXER" "RRE" 14
			150,  // 3760 "B32E" "MAER" "RRF1" 15
			150,  // 3770 "B32F" "MSER" "RRF1" 15
			142,  // 3780 "B336" "SQXR" "RRE" 14
			142,  // 3790 "B337" "MEER" "RRE" 14
			150,  //      "B338" "MAYLR" "RRF1" 15 Z9-4
			150,  //      "B339" "MYLR" "RRF1" 15 Z9-5
			150,  //      "B33A" "MAYR" "RRF1" 15 Z9-6
			150,  //      "B33B" "MYR" "RRF1" 15 Z9-7
			150,  //      "B33C" "MAYHR" "RRF1" 15 Z9-8
			150,  //      "B33D" "MYHR" "RRF1" 15 Z9-9
			150,  // 3800 "B33E" "MADR" "RRF1" 15
			150,  // 3810 "B33F" "MSDR" "RRF1" 15
			142,  // 3820 "B340" "LPXBR" "RRE" 14
			142,  // 3830 "B341" "LNXBR" "RRE" 14
			142,  // 3840 "B342" "LTXBR" "RRE" 14
			142,  // 3850 "B343" "LCXBR" "RRE" 14
			142,  // 3860 "B344" "LEDBR?" "RRE" 53 RPI 1125
			142,  // 3870 "B345" "LDXBR?" "RRE" 53 RPI 1125
			142,  // 3880 "B346" "LEXBR?" "RRE" 53 RPI 1125
			340,  // 3890 "B347" "FIXBR?" "RRF2" 54 RPI 1125
			142,  // 3900 "B348" "KXBR" "RRE" 14
			142,  // 3910 "B349" "CXBR" "RRE" 14
			142,  // 3920 "B34A" "AXBR" "RRE" 14
			142,  // 3930 "B34B" "SXBR" "RRE" 14
			142,  // 3940 "B34C" "MXBR" "RRE" 14
			142,  // 3950 "B34D" "DXBR" "RRE" 14
			340,  // 3960 "B350" "TBEDR" "RRF2" 34
			340,  // 3970 "B351" "TBDR" "RRF2" 34
			300,  // 3980 "B353" "DIEBR" "RRF3" 30
			340,  // 3990 "B357" "FIEBR?" "RRF2" 54 RPI 1125
			142,  // 4000 "B358" "THDER" "RRE" 14
			142,  // 4010 "B359" "THDR" "RRE" 14
			300,  // 4020 "B35B" "DIDBR" "RRF3" 30
			340,  // 4030 "B35F" "FIDBR?" "RRF2" 54 RPI 1125
			142,  // 4040 "B360" "LPXR" "RRE" 14
			142,  // 4050 "B361" "LNXR" "RRE" 14
			142,  // 4060 "B362" "LTXR" "RRE" 14
			142,  // 4070 "B363" "LCXR" "RRE" 14
			142,  // 4080 "B365" "LXR" "RRE" 14
			142,  // 4090 "B366" "LEXR" "RRE" 14
			142,  // 4100 "B367" "FIXR" "RRE" 14
			142,  // 4110 "B369" "CXR" "RRE" 14
			142,  // 4115 "B370" "LPDFR" "RRE"  14 DFP
			142,  // 4115 "B371" "LNDFR" "RRE"  14 DFP
			340,  // 4115 "B372" "CPSDR" "RRF2" 34 DFP
			142,  // 4115 "B373" "LCDFR" "RRE"  14 DFP
			142,  // 4120 "B374" "LZER" "RRE" 14
			142,  // 4130 "B375" "LZDR" "RRE" 14
			142,  // 4140 "B376" "LZXR" "RRE" 14
			142,  // 4150 "B377" "FIER" "RRE" 14
			142,  // 4160 "B37F" "FIDR" "RRE" 14
			142,  // 4170 "B384" "SFPC" "RRE" 14
			142,  // 4175 "B385" "SFASR" "RRE" 14 DFP 57
			142,  // 4180 "B38C" "EFPC" "RRE" 14
			301,  //      "B390" "CELFBR" "RRF3" 30 RPI 1125 Z196
			301,  //      "B391" "CDLFBR" "RRF3" 30 RPI 1125 Z196
			301,  //      "B392" "CXLFBR" "RRF3" 30 RPI 1125 Z196
			146,  // 4190 "B394" "CEFBR?" "RRE" 14  RPI 643 RPI 1125
			146,  // 4200 "B395" "CDFBR?" "RRE" 14  RPI 643 RPI 1125
			146,  // 4210 "B396" "CXFBR?" "RRE" 14  RPI 643 RPI 1125
			341,  // 4220 "B398" "CFEBR?" "RRF2" 34 RPI 1125 Z196
			341,  // 4230 "B399" "CFDBR?" "RRF2" 34 RPI 1125 Z196
			341,  // 4240 "B39A" "CFXBR?" "RRF2" 34 RPI 1125 Z196
			303,    // 'B39C' 'CLFEBR' 'RRF3' 30 RPI 1125 Z196
			303,    // 'B39D' 'CLFDBR' 'RRF3' 30 RPI 1125 Z196
			303,    // 'B39E' 'CLFXBR' 'RRF3' 30 RPI 1125 Z196
			304,    // 'B3A0' 'CELGBR' 'RRF3' 30 RPI 1125 Z196
			304,    // 'B3A1' 'CDLGBR' 'RRF3' 30 RPI 1125 Z196
			304,    // 'B3A2' 'CXLGBR' 'RRF3' 30 RPI 1125 Z196
			141,  // 4250 "B3A4" "CEGBR?" "RRE"  53  RPI 1125 Z196
			141,  // 4260 "B3A5" "CDGBR?" "RRE"  53  RPI 1125 Z196
			141,  // 4270 "B3A6" "CXGBR?" "RRE"  53  RPI 1125 Z196
			342,  // 4280 "B3A8" "CGEBR?" "RRF2" 54  RPI 1125 Z196 
			342,  // 4290 "B3A9" "CGDBR?" "RRF2" 54  RPI 1125 Z196
			342,  // 4300 "B3AA" "CGXBR?" "RRF2" 54  RPI 1125 Z196
			342,    //      "B3AC" "CLGEBR" "RRF2" 30  RPI 1125 Z196
			342,    //      "B3AD" "CLGDBR" "RRF2" 30  RPI 1125 Z196
			342,    //      "B3AE" "CLGXBR" "RRF2" 30  RPI 1125 Z196
			146,  // 4310 "B3B4" "CEFR" "RRE" 14
			146,  // 4320 "B3B5" "CDFR" "RRE" 14
			146,  // 4330 "B3B6" "CXFR" "RRE" 14
			341,  // 4340 "B3B8" "CFER" "RRF2" 34
			341,  // 4350 "B3B9" "CFDR" "RRF2" 34
			341,  // 4360 "B3BA" "CFXR" "RRF2" 34
			141,  // 4365 "B3C1" "LDGR" "RRE" 14 DFP
			141,  // 4370 "B3C4" "CEGR" "RRE" 14
			141,  // 4380 "B3C5" "CDGR" "RRE" 14
			141,  // 4390 "B3C6" "CXGR" "RRE" 14
			342,  // 4400 "B3C8" "CGER" "RRF2" 34
			342,  // 4410 "B3C9" "CGDR" "RRF2" 34
			342,  // 4420 "B3CA" "CGXR" "RRF2" 34
			145,  // 4425 "B3CD" "LGDR" "RRE" 14 DFP
			360, // "MDTR?" "B3D0" "RRR" DFP 1 RPI 1125
			360, // "DDTR?" "B3D1" "RRR" DFP 2 RPI 1125
			360, // "ADTR?" "B3D2" "RRR" DFP 3 RPI 1125
			360, // "SDTR?" "B3D3" "RRR" DFP 4 RPI 1125
			350, // "LDETR" "B3D4" "RRF4" DFP 5
			301, // "LEDTR" "B3D5" "RRF3" DFP 6
			142, // "LTDTR" "B3D6" "RRE" DFP 7
			301, // "FIDTR" "B3D7" "RRF3" DFP 8
			360, // "MXTR?" "B3D8" "RRR" DFP 9  RPI 1125
			360, // "DXTR?" "B3D9" "RRR" DFP 10 RPI 1125
			360, // "AXTR?" "B3DA" "RRR" DFP 11 RPI 1125
			360, // "SXTR?" "B3DB" "RRR" DFP 12 RPI 1125
			350, // "LXDTR" "B3DC" "RRF4" DFP 13
			301, // "LDXTR" "B3DD" "RRF3" DFP 14
			142, // "LTXTR" "B3DE" "RRE" DFP 15
			301, // "FIXTR" "B3DF" "RRF3" DFP 16
			142, // "KDTR" "B3E0" "RRE" DFP 17
			342, // "CGDTR?" "B3E1" "RRF7" DFP 18 RPI 1125
			145, // "CUDTR" "B3E2" "RRE" DFP 19
			351, // "CSDTR" "B3E3" "RRF4" DFP 20  // RPI 798
			142, // "CDTR" "B3E4" "RRE" DFP 21
			145, // "EEDTR" "B3E5" "RRE" DFP 22
			145, // "ESDTR" "B3E7" "RRE" DFP 23
			142, // "KXTR" "B3E8" "RRE" DFP 24
			342, // "CGXTR?" "B3E9" "RRF7" DFP 25 RPI 1125
			145, // "CUXTR" "B3EA" "RRE" DFP 26
			351, // "CSXTR" "B3EB" "RRF4" DFP 27  // RPI 798
			142, // "CXTR" "B3EC" "RRE" DFP 28
			145, // "EEXTR" "B3ED" "RRE" DFP 29
			145, // "ESXTR" "B3EF" "RRE" DFP 30
			141, // "CDGTR?" "B3F1" "RRF7" DFP 31 RPI 1125
			141, // "CDUTR" "B3F2" "RRE" DFP 32
			141, // "CDSTR" "B3F3" "RRE" DFP 33
			142, // "CEDTR" "B3F4" "RRE" DFP 34
			300, // "QADTR" "B3F5" "RRF3" DFP 35
			343, // "IEDTR" "B3F6" "RRF2" DFP 36
			302, // "RRDTR" "B3F7" "RRF3" DFP 37 RPI 798
			141, // "CXGTR?" "B3F9" "RRF7" DFP 38 RPI 1125
			141, // "CXUTR" "B3FA" "RRE" DFP 39
			141, // "CXSTR" "B3FB" "RRE" DFP 40
			142, // "CEXTR" "B3FC" "RRE" DFP 41
			300, // "QAXTR" "B3FD" "RRF3" DFP 42
			343, // "IEXTR" "B3FE" "RRF2" DFP 43
			302, // "RRXTR" "B3FF" "RRF3" DFP 44 RPI 798
			100,  // 4430 "B6" "STCTL" "RS" 10
			100,  // 4440 "B7" "LCTL" "RS" 10
			144,  // 4450 "B900" "LPGR" "RRE" 14
			144,  // 4460 "B901" "LNGR" "RRE" 14
			144,  // 4470 "B902" "LTGR" "RRE" 14
			144,  // 4480 "B903" "LCGR" "RRE" 14
			144,  // 4490 "B904" "LGR" "RRE" 14
			144,  // 4500 "B905" "LURAG" "RRE" 14
			144,  //      "B906" "LGBR" "RRE" 14 Z9-10
			144,  //      "B907" "LGHR" "RRE" 14 Z9-11
			144,  // 4510 "B908" "AGR" "RRE" 14
			144,  // 4520 "B909" "SGR" "RRE" 14
			144,  // 4530 "B90A" "ALGR" "RRE" 14
			144,  // 4540 "B90B" "SLGR" "RRE" 14
			144,  // 4550 "B90C" "MSGR" "RRE" 14
			144,  // 4560 "B90D" "DSGR" "RRE" 14
			144,  // 4570 "B90E" "EREGG" "RRE" 14
			144,  // 4580 "B90F" "LRVGR" "RRE" 14
			148,  // 4590 "B910" "LPGFR" "RRE" 14
			148,  // 4600 "B911" "LNGFR" "RRE" 14
			148,  // 4610 "B912" "LTGFR" "RRE" 14
			148,  // 4620 "B913" "LCGFR" "RRE" 14
			148,  // 4630 "B914" "LGFR" "RRE" 14
			148,  // 4640 "B916" "LLGFR" "RRE" 14
			144,  // 4650 "B917" "LLGTR" "RRE" 14
			148,  // 4660 "B918" "AGFR" "RRE" 14
			148,  // 4670 "B919" "SGFR" "RRE" 14
			148,  // 4680 "B91A" "ALGFR" "RRE" 14
			148,  // 4690 "B91B" "SLGFR" "RRE" 14
			148,  // 4700 "B91C" "MSGFR" "RRE" 14
			148,  // 4710 "B91D" "DSGFR" "RRE" 14
			144,  // 4720 "B91E" "KMAC" "RRE" 14
			144,  // 4730 "B91F" "LRVR" "RRE" 14
			144,  // 4740 "B920" "CGR" "RRE" 14
			144,  // 4750 "B921" "CLGR" "RRE" 14
			144,  // 4760 "B925" "STURG" "RRE" 14
			144,  //      "B926" "LBR" "RRE" 14 Z9-12
			144,  //      "B927" "LHR" "RRE" 14 Z9-13
			144,  // "B928","PCKMO","RE4"  14 RPI 1125 Z196
			144,  // "B92A","KMF","RRE"    14 RPI 1125 Z196
			144,  // "B92B","KMO","RRE"    14 RPI 1125 Z196
			144,  // "B92C","PCC","RE4"    14 RPI 1125 Z196
			343,  // "B92D","KMCTR","RRF2" 34 RPI 1125 Z196
			144,  // 4770 "B92E" "KM" "RRE" 14
			144,  // 4780 "B92F" "KMC" "RRE" 14
			144,  // 4790 "B930" "CGFR" "RRE" 14
			144,  // 4800 "B931" "CLGFR" "RRE" 14
			144,  // 4810 "B93E" "KIMD" "RRE" 14
			144,  // 4820 "B93F" "KLMD" "RRE" 14
			303,    // "B941","CFDTR","RRF"  30 RPI 1125 Z196
			305,   // "B942","CLGDTR","RRF" 30 RPI 1125 Z196
			303,   // "B943","CLFDTR","RRF" 30 RPI 1125 Z196
			144,  // 4830 "B946" "BCTGR" "RRE" 14
			303,    // "B949","CFXTR","RRF3"   30 RPI 1125 Z196
			305,   // "B94A","CLGXTR","RRF3"  30 RPI 1125 Z196
			303,   // "B94B","CLFXTR","RRF3"  30 RPI 1125 Z196
			301,    // "B951","CDFTR","RRF3"   30 RPI 1125 Z196
			304,   // "B952","CDLGTR","RRF3"  30 RPI 1125 Z196
			306,   // "B953","CDLFTR","RRF3"  30 RPI 1125 Z196
			306,    // "B959","CXFTR","RRF3"   30 RPI 1125 Z196" 
			304,   // "B95A","CXLGTR","RRF3"  30 RPI 1125 Z196
			306,   // "B95B","CXLFTR","RRF3"  30 RPI 1125 Z196
			151,  // 10 "B960" "CGRT" "RRF5" 39 RPI 817
			151,  // 20 "B9608" "CGRTE" "RRF6" 40 RPI 817
			151,  // 30 "B9602" "CGRTH" "RRF6" 40 RPI 817
			151,  // 40 "B9604" "CGRTL" "RRF6" 40 RPI 817
			151,  // 50 "B9606" "CGRTNE" "RRF6" 40 RPI 817
			151,  // 60 "B960C" "CGRTNH" "RRF6" 40 RPI 817
			151,  // 70 "B960A" "CGRTNL" "RRF6" 40 RPI 817
			151,  // 10 "B961" "CLGRT" "RRF5" 39 RPI 817
			151,  // 20 "B9618" "CLGRTE" "RRF6" 40 RPI 817
			151,  // 30 "B9612" "CLGRTH" "RRF6" 40 RPI 817
			151,  // 40 "B9614" "CLGRTL" "RRF6" 40 RPI 817
			151,  // 50 "B9616" "CLGRTNE" "RRF6" 40 RPI 817
			151,  // 60 "B961C" "CLGRTNH" "RRF6" 40 RPI 817
			151,  // 70 "B961A" "CLGRTNL" "RRF6" 40 RPI 817
			152,  // 150 "B972" "CRT" "RRF5" 39 RPI 817
			152,  // 160 "B9728" "CRTE" "RRF6" 40 RPI 817
			152,  // 170 "B9722" "CRTH" "RRF6" 40 RPI 817
			152,  // 180 "B9724" "CRTL" "RRF6" 40 RPI 817
			152,  // 190 "B9726" "CRTNE" "RRF6" 40 RPI 817
			152,  // 200 "B972C" "CRTNH" "RRF6" 40 RPI 817
			152,  // 210 "B972A" "CRTNL" "RRF6" 40 RPI 817
			152,  // 80 "B973" "CLRT" "RRF5" 39 RPI 817
			152,  // 90 "B9738" "CLRTE" "RRF6" 40 RPI 817
			152,  // 100 "B9732" "CLRTH" "RRF6" 40 RPI 817
			152,  // 110 "B9734" "CLRTL" "RRF6" 40 RPI 817
			152,  // 120 "B9736" "CLRTNE" "RRF6" 40 RPI 817
			152,  // 130 "B973C" "CLRTNH" "RRF6" 40 RPI 817
			152,  // 140 "B973A" "CLRTNL" "RRF6" 40 RPI 817
			144,  // 4840 "B980" "NGR" "RRE" 14
			144,  // 4850 "B981" "OGR" "RRE" 14
			144,  // 4860 "B982" "XGR" "RRE" 14
			144,  //      "B983" "FLOGR" "RRE" 14 Z9-14
			144,  //      "B984" "LLGCR" "RRE" 14 Z9-15
			144,  //      "B985" "LLGHR" "RRE" 14 Z9-16
			144,  // 4870 "B986" "MLGR" "RRE" 14
			144,  // 4880 "B987" "DLGR" "RRE" 14
			144,  // 4890 "B988" "ALCGR" "RRE" 14
			144,  // 4900 "B989" "SLBGR" "RRE" 14
			144,  // 4910 "B98A" "CSPG" "RRE" 14
			144,  // 4920 "B98D" "EPSW" "RRE" 14
			340,  // 4930 "B98E" "IDTE" "RRF2" 34
			143,  // 4940 "B990" "TRTT" "RRE" 14
			143,  // 4950 "B991" "TRTO" "RRE" 14
			143,  // 4960 "B992" "TROT" "RRE" 14
			143,  // 4970 "B993" "TROO" "RRE" 14
			144,  //      "B994" "LLCR" "RRE" 14 Z9-17
			144,  //      "B995" "LLHR" "RRE" 14 Z9-18
			144,  // 4980 "B996" "MLR" "RRE" 14
			144,  // 4990 "B997" "DLR" "RRE" 14
			144,  // 5000 "B998" "ALCR" "RRE" 14
			144,  // 5010 "B999" "SLBR" "RRE" 14
			144,  // 5020 "B99A" "EPAIR" "RRE" 14
			144,  // 5030 "B99B" "ESAIR" "RRE" 14
			144,  // 5040 "B99D" "ESEA" "RRE" 14
			144,  // 5050 "B99E" "PTI" "RRE" 14
			144,  // 5060 "B99F" "SSAIR" "RRE" 14
			147,  // 10 "B9A2" "PTF" "RRE" 14  RPI 817
			144,  // 20 "B9AF" "PFMF" "RRF5" 39  RPI 817
			144,  //      "B9AA" "LPTEA" "RRE" 14 Z9-19
			140,  // "B9AE","RRBM","RRE"  14 RPI 1125 Z196
			144,  // 5070 "B9B0" "CU14" "RRE" 14
			144,  // 5080 "B9B1" "CU24" "RRE" 14
			144,  // 5090 "B9B2" "CU41" "RRE" 14
			144,  // 5100 "B9B3" "CU42" "RRE" 14
			144,  // 30 "B9BD" "TRTRE" "RRF5" 39  RPI 817
			144,  // 5110 "B9BE" "SRSTU" "RRE" 14
			144,  // 40 "B9BF" "TRTE" "RRF5" 39  RPI 817
			410,    // "B9C8","AHHHR","RRF5"  39 RPI 1125 Z196
			410,    // "B9C9","SHHHR","RRF5"  39 RPI 1125 Z196
			410,   // "B9CA","ALHHHR","RRF5" 39 RPI 1125 Z196
			410,   // "B9CB","SLHHHR","RRF5" 39 RPI 1125 Z196
			144,   // "B9CD","CHHR","RRE"     14 RPI 1125 Z196
			144,   // "B9CF","CLHHR","RRE"    14 RPI 1125 Z196
			410,   // "B9D8","AHHLR","RRF5 "  39 RPI 1125 Z196
			410,   // "B9D9","SHHLR","RRF5 "  39 RPI 1125 Z196
			410,   // "B9DA","ALHHLR","RRF5 " 39 RPI 1125 Z196
			410,   // "B9DB","SLHHLR","RRF5 " 39 RPI 1125 Z196
			144,   // "B9DD","CHLR","RRE"     14 RPI 1125 Z196
			144,    // "B9DF","CLHLR","RRE"    14 RPI 1125 Z196
			144,  // 5115 "b9E1" "POPCNT" "RRE" 14 RPI 1125
			141,     // "B9E2","LOCGR","RRF5"   39 RPI 1125 Z196
			153,     // "B9E4","NGRK","RRF5"    39 RPI 1125 Z196
			153,     // "B9E6","OGRK","RRF5"    39 RPI 1125 Z196
			153,     // "B9E7","XGRK","RRF5"    39 RPI 1125 Z196
			153,     // "B9E8","AGRK","RRF5"    39 RPI 1125 Z196
			153,     // "B9E9","SGRK","RRF5"    39 RPI 1125 Z196
			153,     // "B9EA","ALGRK","RRF5"   39 RPI 1125 Z196
			153,     // "B9EB","SLGRK","RRF5"   39 RPI 1125 Z196
			142,     // "B9F2","LOCR","RRF5"    39 RPI 1125 Z196
			154,     // "B9F4","NRK","RRF5"     39 RPI 1125 Z196
			154,     // "B9F6","ORK","RRF5"     39 RPI 1125 Z196
			154,     // "B9F7","XRK","RRF5"     39 RPI 1125 Z196
			154,     // "B9F8","ARK","RRF5"     39 RPI 1125 Z196
			154,     // "B9F9","SRK","RRF5"     39 RPI 1125 Z196
			154,     // "B9FA","ALRK","RRF5"    39 RPI 1125 Z196
			154,     // "B9FB","SLRK","RRF5"    39 RPI 1125 Z196
			100,  // 5120 "BA" "CS" "RS" 10
			100,  // 5130 "BB" "CDS" "RS" 10
			101,  // 5140 "BD" "CLM" "RS" 10
			101,  // 5150 "BE" "STCM" "RS" 10
			101,  // 5160 "BF" "ICM" "RS" 10
			162,  // 5170 "C00" "LARL" "RIL" 16
			160,  //      "C01" "LGFI" "RIL" 16 Z9-20
			330,  // 5180 "C04" "BRCL" "RIL" 16
			330,  // 5390 "C040" "JLNOP" "BLX" 33
			330,  // 5400 "C041" "BROL" "BLX" 33
			330,  // 5410 "C041" "JLO" "BLX" 33
			330,  // 5420 "C042" "BRHL" "BLX" 33
			330,  // 5430 "C042" "BRPL" "BLX" 33
			330,  // 5440 "C042" "JLH" "BLX" 33
			330,  // 5450 "C042" "JLP" "BLX" 33
			330,  // 5460 "C044" "BRLL" "BLX" 33
			330,  // 5470 "C044" "BRML" "BLX" 33
			330,  // 5480 "C044" "JLL" "BLX" 33
			330,  // 5490 "C044" "JLM" "BLX" 33
			330,  // 5500 "C047" "BRNEL" "BLX" 33
			330,  // 5510 "C047" "BRNZL" "BLX" 33
			330,  // 5520 "C047" "JLNE" "BLX" 33
			330,  // 5530 "C047" "JLNZ" "BLX" 33
			330,  // 5540 "C048" "BREL" "BLX" 33
			330,  // 5550 "C048" "BRZL" "BLX" 33
			330,  // 5560 "C048" "JLE" "BLX" 33
			330,  // 5570 "C048" "JLZ" "BLX" 33
			330,  // 5580 "C04B" "BRNLL" "BLX" 33
			330,  // 5590 "C04B" "BRNML" "BLX" 33
			330,  // 5600 "C04B" "JLNL" "BLX" 33
			330,  // 5610 "C04B" "JLNM" "BLX" 33
			330,  // 5620 "C04D" "BRNHL" "BLX" 33
			330,  // 5630 "C04D" "BRNPL" "BLX" 33
			330,  // 5640 "C04D" "JLNH" "BLX" 33
			330,  // 5650 "C04D" "JLNP" "BLX" 33
			330,  // 5660 "C04E" "BRNOL" "BLX" 33
			330,  // 5670 "C04E" "JLNO" "BLX" 33
			330,  // 5680 "C04F" "BRUL" "BLX" 33
			330,  // 5690 "C04F" "JLU" "BLX" 33
			163,  // 5210 "C05" "BRASL" "RIL" 16
			163,  // 5220 "C05" "JASL" "RIL" 16
			160,  //      "C06" "XIHF" "RIL" 16 Z9-21
			160,  //      "C07" "XILF" "RIL" 16 Z9-22
			160,  //      "C08" "IIHF" "RIL" 16 Z9-23
			160,  //      "C09" "IILF" "RIL" 16 Z9-24
			160,  //      "C0A" "NIHF" "RIL" 16 Z9-25
			160,  //      "C0B" "NILF" "RIL" 16 Z9-26
			160,  //      "C0C" "OIHF" "RIL" 16 Z9-27
			160,  //      "C0D" "OILF" "RIL" 16 Z9-28
			160,  //      "C0E" "LLIHF" "RIL" 16 Z9-29
			160,  //      "C0F" "LLILF" "RIL" 16 Z9-30
			160,  // 50 "C20" "MSGFI" "RIL" 16  RPI 817
			161,  // 60 "C21" "MSFI" "RIL" 16  RPI 817
			160,  //      "C24" "SLGFI" "RIL" 16 Z9-31
			161,  //      "C25" "SLFI" "RIL" 16 Z9-32
			160,  //      "C28" "AGFI" "RIL" 16 Z9-33
			161,  //      "C29" "AFI" "RIL" 16 Z9-34
			160,  //      "C2A" "ALGFI" "RIL" 16 Z9-35
			161,  //      "C2B" "ALFI" "RIL" 16 Z9-36
			160,  //      "C2C" "CGFI" "RIL" 16 Z9-37
			161,  //      "C2D" "CFI" "RIL" 16 Z9-38
			160,  //      "C2E" "CLGFI" "RIL" 16 Z9-39
			161,  //      "C2F" "CLFI" "RIL" 16 Z9-40
			164,  // 70 "C42" "LLHRL" "RIL" 16  RPI 817
			168,  // 80 "C44" "LGHRL" "RIL" 16  RPI 817
			164,  // 90 "C45" "LHRL" "RIL" 16  RPI 817
			168,  // 100 "C46" "LLGHRL" "RIL" 16  RPI 817
			164,  // 110 "C47" "STHRL" "RIL" 16  RPI 817
			165,  // 120 "C48" "LGRL" "RIL" 16  RPI 817
			165,  // 130 "C4B" "STGRL" "RIL" 16  RPI 817
			166, // 140 "C4C" "LGFRL" "RIL" 16  RPI 817
			167, // 150 "C4D" "LRL" "RIL" 16  RPI 817
			166, // 160 "C4E" "LLGFRL" "RIL" 16  RPI 817
			167, // 170 "C4F" "STRL" "RIL" 16  RPI 817
			163,  // 180 "C60" "EXRL" "RIL" 16  RPI 817
			169,  // 190 "C62" "PFDRL" "RIL" 16  RPI 817
			168,  // 200 "C64" "CGHRL" "RIL" 16  RPI 817
			164,  // 210 "C65" "CHRL" "RIL" 16  RPI 817
			168,  // 220 "C66" "CLGHRL" "RIL" 16  RPI 817
			164,  // 230 "C67" "CLHRL" "RIL" 16  RPI 817
			165,  // 240 "C68" "CGRL" "RIL" 16  RPI 817
			165,  // 250 "C6A" "CLGRL" "RIL" 16  RPI 817
			166,  // 260 "C6C" "CGFRL" "RIL" 16  RPI 817
			167,  // 270 "C6D" "CRL" "RIL" 16  RPI 817
			166,  // 280 "C6E" "CLGFRL" "RIL" 16  RPI 817
			167,  // 290 "C6F" "CLRL" "RIL" 16  RPI 817
			320,  // "C80" "MVCOS" "SSF" 32 Z9-41 RPI 817
			320,  // "C81" "ECTG" "SSF" 32 RPI 1013
			320,  // "C82" "CSST" "SSF" 32 RPI 1013
			321,  // "C84","LPD","SSF2"  55 RPI 1125 Z196
			321,  // "C85","LPDG","SSF2" 55 RPI 1125 Z196
			163, // "CC6","BRCTH","RIL"  16 RPI 1125 Z196
			160, // "CC8","AIH","RIL"    16  RPI 1125 Z196
			160, // "CCA","ALSIH","RIL"  16  RPI 1125 Z196
			160, // "CCB","ALSIHN","RIL" 16  RPI 1125 Z196
			160, // "CCD","CIH","RIL"    16  RPI 1125 Z196
			160, // "CCF","CLIH","RIL"   16  RPI 1125 Z196
			170,  // 5230 "D0" "TRTR" "SS" 17
			170,  // 5240 "D1" "MVN" "SS" 17
			170,  // 5250 "D2" "MVC" "SS" 17
			170,  // 5260 "D3" "MVZ" "SS" 17
			170,  // 5270 "D4" "NC" "SS" 17
			170,  // 5280 "D5" "CLC" "SS" 17
			170,  // 5290 "D6" "OC" "SS" 17
			170,  // 5300 "D7" "XC" "SS" 17
			170,  // 5310 "D9" "MVCK" "SS" 17
			170,  // 5320 "DA" "MVCP" "SS" 17
			170,  // 5330 "DB" "MVCS" "SS" 17
			170,  // 5340 "DC" "TR" "SS" 17
			170,  // 5350 "DD" "TRT" "SS" 17
			170,  // 5360 "DE" "ED" "SS" 17
			170,  // 5370 "DF" "EDMK" "SS" 17
			171,  // 5375 "E00" "XREAD" "RXSS" 38 RPI 812
			171,  // 5375 "E02" "XPRNT" "RXSS" 38 RPI 812
			171,  // 5375 "E04" "XPNCH" "RXSS" 38 RPI 812
			171,  // 5375 "E06" "XDUMP" "RXSS" 38 RPI 812
			171,  // 5375 "E08" "XLIMD" "RXSS" 38 RPI 812
			171,  // 5375 "E0A" "XGET"  "RXSS" 38 RPI 812
			171,  // 5375 "E0C" "XPUT"  "RXSS" 38 RPI 812
			170,  // 5380 "E1" "PKU" "SS" 17
			170,  // 5390 "E2" "UNPKU" "SS" 17
			180,  //      "E302" "LTG" "RXY" 18 Z9-42
			180,  // 5400 "E303" "LRAG" "RXY" 18
			180,  // 5410 "E304" "LG" "RXY" 18
			57,   // 5420 "E306" "CVBY" "RXY" 18  RPI 588
			180,  // 5430 "E308" "AG" "RXY" 18
			180,  // 5440 "E309" "SG" "RXY" 18
			180,  // 5450 "E30A" "ALG" "RXY" 18
			180,  // 5460 "E30B" "SLG" "RXY" 18
			180,  // 5470 "E30C" "MSG" "RXY" 18
			180,  // 5480 "E30D" "DSG" "RXY" 18
			188,  // 5490 "E30E" "CVBG" "RXY" 18  RPI 588
			180,  // 5500 "E30F" "LRVG" "RXY" 18
			180,  //      "E312" "LT" "RXY" 18 Z9-43
			180,  // 5510 "E313" "LRAY" "RXY" 18
			184,  // 5520 "E314" "LGF" "RXY" 18
			182,  // 5530 "E315" "LGH" "RXY" 18
			184,  // 5540 "E316" "LLGF" "RXY" 18
			180,  // 5550 "E317" "LLGT" "RXY" 18
			184,  // 5560 "E318" "AGF" "RXY" 18
			184,  // 5570 "E319" "SGF" "RXY" 18
			184,  // 5580 "E31A" "ALGF" "RXY" 18
			184,  // 5590 "E31B" "SLGF" "RXY" 18
			184,  // 5600 "E31C" "MSGF" "RXY" 18
			184,  // 5610 "E31D" "DSGF" "RXY" 18
			180,  // 5620 "E31E" "LRV" "RXY" 18
			182,  // 5630 "E31F" "LRVH" "RXY" 18
			180,  // 5640 "E320" "CG" "RXY" 18
			180,  // 5650 "E321" "CLG" "RXY" 18
			180,  // 5660 "E324" "STG" "RXY" 18
			57,   // 5670 "E326" "CVDY" "RXY" 18  RPI 588
			188,  // 5680 "E32E" "CVDG" "RXY" 18  RPI 588
			180,  // 5690 "E32F" "STRVG" "RXY" 18
			184,  // 5700 "E330" "CGF" "RXY" 18
			184,  // 5710 "E331" "CLGF" "RXY" 18
			184,  // 310 "E332" "LTGF" "RXY" 18  RPI 817
			182,  // 320 "E334" "CGH" "RXY" 18  RPI 817
			189,  // 330 "E336" "PFD" "RXY" 18  RPI 817
			180,  // 5720 "E33E" "STRV" "RXY" 18
			182,  // 5730 "E33F" "STRVH" "RXY" 18
			180,  // 5740 "E346" "BCTG" "RXY" 18
			50,  // 5750 "E350" "STY" "RXY" 18
			50,   // 5760 "E351" "MSY" "RXY" 18
			50,   // 5770 "E354" "NY" "RXY" 18
			50,   // 5780 "E355" "CLY" "RXY" 18
			50,   // 5790 "E356" "OY" "RXY" 18
			50,   // 5800 "E357" "XY" "RXY" 18
			50,   // 5810 "E358" "LY" "RXY" 18
			50,   // 5820 "E359" "CY" "RXY" 18
			50,   // 5830 "E35A" "AY" "RXY" 18
			50,   // 5840 "E35B" "SY" "RXY" 18
			50,  // 340 "E35C" "MFY" "RXY" 18  RPI 817
			50,   // 5850 "E35E" "ALY" "RXY" 18
			50,   // 5860 "E35F" "SLY" "RXY" 18
			53,  // 5870 "E370" "STHY" "RXY" 18
			52,  // 5880 "E371" "LAY" "RXY" 18  RPI 738 RPI 1149
			186,  // 5890 "E372" "STCY" "RXY" 18
			186,  // 5900 "E373" "ICY" "RXY" 18
			52,  // 350 "E375" "LAEY" "RXY" 18  RPI 817
			186,  // 5910 "E376" "LB" "RXY" 18
			185,  // 5920 "E377" "LGB" "RXY" 18
			53,  // 5930 "E378" "LHY" "RXY" 18
			53,  // 5940 "E379" "CHY" "RXY" 18
			53,  // 5950 "E37A" "AHY" "RXY" 18
			53,  // 5960 "E37B" "SHY" "RXY" 18
			53,  // 360 "E37C" "MHY" "RXY" 18  RPI 817
			180,  // 5970 "E380" "NG" "RXY" 18
			180,  // 5980 "E381" "OG" "RXY" 18
			180,  // 5990 "E382" "XG" "RXY" 18
			183,  // 6000 "E386" "MLG" "RXY" 18
			183,  // 6010 "E387" "DLG" "RXY" 18
			180,  // 6020 "E388" "ALCG" "RXY" 18
			180,  // 6030 "E389" "SLBG" "RXY" 18
			180,  // 6040 "E38E" "STPQ" "RXY" 18
			180,  // 6050 "E38F" "LPQ" "RXY" 18
			185,  // 6060 "E390" "LLGC" "RXY" 18
			182,  // 6070 "E391" "LLGH" "RXY" 18
			186,  //      "E394" "LLC" "RXY" 18 Z9-44
			53,  //      "E395" "LLH" "RXY" 18 Z9-45
			180,  // 6080 "E396" "ML" "RXY" 18
			180,  // 6090 "E397" "DL" "RXY" 18
			187,  // 6100 "E398" "ALC" "RXY" 18
			187,  // 6110 "E399" "SLB" "RXY" 18
			185,  // "E3C0","LBH","RXY"   18  RPI 1125 Z196
			185,  // "E3C2","LLCH","RXY"  18  RPI 1125 Z196
			185,  // "E3C3","STCH","RXY"  18  RPI 1125 Z196
			182,  // "E3C4","LHH","RXY"   18  RPI 1125 Z196
			182,  // "E3C6","LLHH","RXY"  18  RPI 1125 Z196
			182,  // "E3C7","STHH","RXY"  18  RPI 1125 Z196
			184,  // "E3CA","LFH","RXY"   18  RPI 1125 Z196
			184,  // "E3CB","STFH","RXY"  18  RPI 1125 Z196
			184,  // "E3CD","CHF","RXY"   18  RPI 1125 Z196
			184,  // "E3CF","CLHF","RXY"  18  RPI 1125 Z19
			190,  // 6120 "E500" "LASP" "SSE" 19
			190,  // 6130 "E501" "TPROT" "SSE" 19
			190,  // 6140 "E502" "STRAG" "SSE" 19
			190,  // 6150 "E50E" "MVCSK" "SSE" 19
			190,  // 6160 "E50F" "MVCDK" "SSE" 19
			390,  // 370 "E544" "MVHHI" "SIL" 51  RPI 817
			391,  // 380 "E548" "MVGHI" "SIL" 51  RPI 817
			392,  // 390 "E54C" "MVHI" "SIL" 51  RPI 817
			390,  // 400 "E554" "CHHSI" "SIL" 51  RPI 817
			390,  // 410 "E555" "CLHHSI" "SIL" 51  RPI 817
			391,  // 420 "E558" "CGHSI" "SIL" 51  RPI 817
			391,  // 430 "E559" "CLGHSI" "SIL" 51  RPI 817
			392,  // 440 "E55C" "CHSI" "SIL" 51  RPI 817
			392,  // 450 "E55D" "CLFHSI" "SIL" 51  RPI 817
			170,  // 6170 "E8" "MVCIN" "SS" 17
			310,  // 6180 "E9" "PKA" "SS" 31
			170,  // 6190 "EA" "UNPKA" "SS" 17
			206,  // 6200 "EB04" "LMG" "RSY" 20
			203,  // 6210 "EB0A" "SRAG" "RSY" 20
			203,  // 6220 "EB0B" "SLAG" "RSY" 20
			203,  // 6230 "EB0C" "SRLG" "RSY" 20
			203,  // 6240 "EB0D" "SLLG" "RSY" 20
			206,  // 6250 "EB0F" "TRACG" "RSY" 20
			200,  // 6260 "EB14" "CSY" "RSY" 20
			203,  // 6270 "EB1C" "RLLG" "RSY" 20
			204,  // 6280 "EB1D" "RLL" "RSY" 20
			201,  // 6290 "EB20" "CLMH" "RSY" 20
			202,  // 6300 "EB21" "CLMY" "RSY" 20
			206,  // 6310 "EB24" "STMG" "RSY" 20
			206,  // 6320 "EB25" "STCTG" "RSY" 20
			206,  // 6330 "EB26" "STMH" "RSY" 20
			201,  // 6340 "EB2C" "STCMH" "RSY" 20
			202,  // 6350 "EB2D" "STCMY" "RSY" 20
			206,  // 6360 "EB2F" "LCTLG" "RSY" 20
			206,  // 6370 "EB30" "CSG" "RSY" 20
			200,  // 6380 "EB31" "CDSY" "RSY" 20
			206,  // 6390 "EB3E" "CDSG" "RSY" 20
			205,  // 6400 "EB44" "BXHG" "RSY" 20
			205,  // 6410 "EB45" "BXLEG" "RSY" 20
			203,  // 460 "EB4C" "ECAG" "RSY" 20  RPI 817
			210,  // 6420 "EB51" "TMY" "SIY" 21
			210,  // 6430 "EB52" "MVIY" "SIY" 21
			210,  // 6440 "EB54" "NIY" "SIY" 21
			210,  // 6450 "EB55" "CLIY" "SIY" 21
			210,  // 6460 "EB56" "OIY" "SIY" 21
			210,  // 6470 "EB57" "XIY" "SIY" 21
			211,  // 470 "EB6A" "ASI" "SIY" 21  RPI 817
			211,  // 480 "EB6E" "ALSI" "SIY" 21  RPI 817
			212,  // 490 "EB7A" "AGSI" "SIY" 21  RPI 817
			212,  // 500 "EB7E" "ALGSI" "SIY" 21  RPI 817
			201,  // 6480 "EB80" "ICMH" "RSY" 20
			202,  // 6490 "EB81" "ICMY" "RSY" 20
			200,  // 6500 "EB8E" "MVCLU" "RSY" 20
			200,  // 6510 "EB8F" "CLCLU" "RSY" 20
			200,  // 6520 "EB90" "STMY" "RSY" 20
			200,  // 6530 "EB96" "LMH" "RSY" 20
			200,  // 6540 "EB98" "LMY" "RSY" 20
			200,  // 6550 "EB9A" "LAMY" "RSY" 20
			200,  // 6560 "EB9B" "STAMY" "RSY" 20
			220,  // 6570 "EBC0" "TP" "RSL" 22
			200,  //  "EBDC","SRAK","RSY  "  20 RPI 1125 Z196
			200,  //  "EBDD","SLAK","RSY  "  20 RPI 1125 Z196
			200,  //  "EBDE","SRLK","RSY  "  20 RPI 1125 Z196
			200,  //  "EBDF","SLLK","RSY  "  20 RPI 1125 Z196
			207,  //  "EBE2","LOCG","RSY2 "  20 RPI 1125 Z196
			207,  //  "EBE3","STOCG","RSY2 " 20 RPI 1125 Z196
			208,  //  "EBE4","LANG","RSY  "  20 RPI 1125 Z196
			208,  //  "EBE6","LAOG","RSY  "  20 RPI 1125 Z196
			208,  //  "EBE7","LAXG","RSY  "  20 RPI 1125 Z196
			208,  //  "EBE8","LAAG","RSY  "  20 RPI 1125 Z196
			208,  //  "EBEA","LAALG","RSY  " 20 RPI 1125 Z196
			209,  //  "EBF2","LOC","RSY2 "   20 RPI 1125 Z196
			209,  //  "EBF3","STOC","RSY2 "  20 RPI 1125 Z196
			200,  //  "EBF4","LAN","RSY  "   20 RPI 1125 Z196
			200,  //  "EBF6","LAO","RSY  "   20 RPI 1125 Z196
			200,  //  "EBF7","LAX","RSY  "   20 RPI 1125 Z196
			200,  //  "EBF8","LAA","RSY  "   20 RPI 1125 Z196
			200,  //  "EBFA","LAAL","RSY  "  20 RPI 1125 Z196
			230,  // 6580 "EC44" "BRXHG" "RIE" 23
			230,  // 6590 "EC44" "JXHG" "RIE" 23
			230,  // 6600 "EC45" "BRXLG" "RIE" 23
			230,  // 6610 "EC45" "JXLEG" "RIE" 23
			400,  // "EC51","RISBLG","RIE8"  52 RPI 1125 Z196
			400,  // 'EC51$003132','LOAD (lOW  && HIGH) RISBLGZ','LLHFR','RIE8',52  RPI 1164
			400,  // 'EC51$163132','LOAD LOG HW (lOW  && HIGH) RISBLGZ','LLHLHR','RIE8',52  RPI 1164
			400,  // 'EC51$243132','LOAD LOG CH (lOW  && HIGH) RISBLGZ','LLCLHR','RIE8',52  RPI 1164
			400,  // "EC51Z","RISBLGZ","RIE8"  52 RPI 1125 Z196  RPI 1164
			400,  // 510 "EC54" "RNSBG" "RIE8" 52  RPI 817
			400,     // 'EC54$003100','AND HIGH (HIGH && HIGH) RNSBG','NHHR','RIE8',52  RPI 1164
			400,     // 'EC54$003132','AND HIGH (HIGH && LOW ) RNSBG','NHLR','RIE8',52  RPI 1164
			400,     // 'EC54$326332','AND HIGH (lOW  && HIGH) RNSBG','NLHR','RIE8',52  RPI 1164
			400,  // 520 "EC54T" "RNSBGT" "RIE8" 52  RPI 817
			400,  // 530 "EC55" "RISBG" "RIE8" 52  RPI 817
			400,  // 540 "EC55Z" "RISBGZ" "RIE8" 52  RPI 817
			400,  // 550 "EC56" "ROSBG" "RIE8" 52  RPI 817
			400,  // 'EC56$003100','OR  HIGH (HIGH && HIGH) ROSBG','OHHR','RIE8',52  RPI 1164
			400,  // 'EC56$003132','OR  HIGH (HIGH && LOW ) ROSBG','OHLR','RIE8',52  RPI 1164
			400,  // 'EC56$326332','OR  HIGH (lOW  && HIGH) ROSBG','OLHR','RIE8',52  RPI 1164
			400,  // 560 "EC56T" "ROSBGT" "RIE8" 52  RPI 817
			400,  // 570 "EC57" "RXSBG" "RIE8" 52  RPI 817
			400,     // 'EC57$003100','XOR HIGH (HIGH && HIGH) RXSBG','XHHR','RIE8',52  RPI 1164
			400,     // 'EC57$003132','XOR HIGH (HIGH && LOW ) RXSBG','XHLR','RIE8',52  RPI 1164
			400,     // 'EC57$326332','AOR HIGH (lOW  && HIGH) RXSBG','XLHR','RIE8',52  RPI 1164
			400,  // 580 "EC57T" "RXSBGT" "RIE8" 52  RPI 817
			400,  // "EC5D","RISBHG","RIE8"  52 RPI 1125 Z196
			400,  // 'EC5D$003100','LOAD (HIGH && HIGH) RISBHGZ','LHHR','RIE8',52  RPI 1164
			400,  // 'EC5D$003132','LOAD (HIGH && LOW ) RISBHGZ','LHLR','RIE8',52  RPI 1164
			400,  // 'EC5D$163100','LOAD LOG HW (HIGH && HIGH) RISBHGZ','LLHHHR','RIE8',52  RPI 1164
			400,  // 'EC5D$163132','LOAD LOG HW (HIGH && LOW ) RISBHGZ','LLHHLR','RIE8',52  RPI 1164
			400,  // 'EC5D$243100','LOAD LOG CH (HIGH && HIGH) RISBHGZ','LLCHHR','RIE8',52  RPI 1164
			400,  // 'EC5D$243132','LOAD LOG CH (HIGH && LOW ) RISBHGZ','LLCHLR','RIE8',52  RPI 1164
			400,  // "EC5DZ","RISBHGZ","RIE8"  52 RPI 1125 Z196  RPI 1164
			234,  // 10 "EC64" "CGRJ" "RIE6" 49 RPI 817
			234,  // 20 "EC648" "CGRJE" "RIE7" 50 RPI 817
			234,  // 30 "EC642" "CGRJH" "RIE7" 50 RPI 817
			234,  // 40 "EC644" "CGRJL" "RIE7" 50 RPI 817
			234,  // 50 "EC646" "CGRJNE" "RIE7" 50 RPI 817
			234,  // 60 "EC64C" "CGRJNH" "RIE7" 50 RPI 817
			234,  // 70 "EC64A" "CGRJNL" "RIE7" 50 RPI 817
			234,  // 80 "EC65" "CLGRJ" "RIE6" 49 RPI 817
			234,  // 90 "EC658" "CLGRJE" "RIE7" 50 RPI 817
			234,  // 100 "EC652" "CLGRJH" "RIE7" 50 RPI 817
			234,  // 110 "EC654" "CLGRJL" "RIE7" 50 RPI 817
			234,  // 120 "EC656" "CLGRJNE" "RIE7" 50 RPI 817
			234,  // 130 "EC65C" "CLGRJNH" "RIE7" 50 RPI 817
			234,  // 140 "EC65A" "CLGRJNL" "RIE7" 50 RPI 817
			232,  // 1010 "EC70" "CGIT" "RIE2" 41 RPI 817
			232,  // 1020 "EC708" "CGITE" "RIE3" 42 RPI 817
			232,  // 1030 "EC702" "CGITH" "RIE3" 42 RPI 817
			232,  // 1040 "EC704" "CGITL" "RIE3" 42 RPI 817
			232,  // 1050 "EC706" "CGITNE" "RIE3" 42 RPI 817
			232,  // 1060 "EC70C" "CGITNH" "RIE3" 42 RPI 817
			232,  // 1070 "EC70A" "CGITNL" "RIE3" 42 RPI 817 
			232,  // 150 "EC71" "CLGIT" "RIE2" 41 RPI 817
			232,  // 160 "EC718" "CLGITE" "RIE3" 42 RPI 817
			232,  // 170 "EC712" "CLGITH" "RIE3" 42 RPI 817
			232,  // 180 "EC714" "CLGITL" "RIE3" 42 RPI 817
			232,  // 190 "EC716" "CLGITNE" "RIE3" 42 RPI 817
			232,  // 200 "EC71C" "CLGITNH" "RIE3" 42 RPI 817
			232,  // 210 "EC71A" "CLGITNL" "RIE3" 42 RPI 817
			231,  // 1150 "EC72" "CIT" "RIE2" 41 RPI 817
			231,  // 1160 "EC728" "CITE" "RIE3" 42 RPI 817
			231,  // 1170 "EC722" "CITH" "RIE3" 42 RPI 817
			231,  // 1180 "EC724" "CITL" "RIE3" 42 RPI 817
			231,  // 1190 "EC726" "CITNE" "RIE3" 42 RPI 817
			231,  // 1200 "EC72C" "CITNH" "RIE3" 42 RPI 817
			231,  // 1210 "EC72A" "CITNL" "RIE3" 42 RPI 817
			231,  // 220 "EC73" "CLFIT" "RIE2" 41 RPI 817
			231,  // 230 "EC738" "CLFITE" "RIE3" 42 RPI 817
			231,  // 240 "EC732" "CLFITH" "RIE3" 42 RPI 817
			231,  // 250 "EC734" "CLFITL" "RIE3" 42 RPI 817
			231,  // 260 "EC736" "CLFITNE" "RIE3" 42 RPI 817
			231,  // 270 "EC73C" "CLFITNH" "RIE3" 42 RPI 817
			231,  // 280 "EC73A" "CLFITNL" "RIE3" 42 RPI 817
			235,  // 150 "EC76" "CRJ" "RIE6" 49 RPI 817
			235,  // 160 "EC768" "CRJE" "RIE7" 50 RPI 817
			235,  // 170 "EC762" "CRJH" "RIE7" 50 RPI 817
			235,  // 180 "EC764" "CRJL" "RIE7" 50 RPI 817
			235,  // 190 "EC766" "CRJNE" "RIE7" 50 RPI 817
			235,  // 200 "EC76C" "CRJNH" "RIE7" 50 RPI 817
			235,  // 210 "EC76A" "CRJNL" "RIE7" 50 RPI 817
			235,  // 220 "EC77" "CLRJ" "RIE6" 49 RPI 817
			235,  // 230 "EC778" "CLRJE" "RIE7" 50 RPI 817
			235,  // 240 "EC772" "CLRJH" "RIE7" 50 RPI 817
			235,  // 250 "EC774" "CLRJL" "RIE7" 50 RPI 817
			235,  // 260 "EC776" "CLRJNE" "RIE7" 50 RPI 817
			235,  // 270 "EC77C" "CLRJNH" "RIE7" 50 RPI 817
			235,  // 280 "EC77A" "CLRJNL" "RIE7" 50 RPI 817
			233,  // 290 "EC7C" "CGIJ" "RIE4" 43 RPI 817
			233,  // 300 "EC7C8" "CGIJE" "RIE5" 44 RPI 817
			233,  // 310 "EC7C2" "CGIJH" "RIE5" 44 RPI 817
			233,  // 320 "EC7C4" "CGIJL" "RIE5" 44 RPI 817
			233,  // 330 "EC7C6" "CGIJNE" "RIE5" 44 RPI 817
			233,  // 340 "EC7CC" "CGIJNH" "RIE5" 44 RPI 817
			233,  // 350 "EC7CA" "CGIJNL" "RIE5" 44 RPI 817
			233,  // 360 "EC7D" "CLGIJ" "RIE4" 43 RPI 817
			233,  // 370 "EC7D8" "CLGIJE" "RIE5" 44 RPI 817
			233,  // 380 "EC7D2" "CLGIJH" "RIE5" 44 RPI 817
			233,  // 390 "EC7D4" "CLGIJL" "RIE5" 44 RPI 817
			233,  // 400 "EC7D6" "CLGIJNE" "RIE5" 44 RPI 817
			233,  // 410 "EC7DC" "CLGIJNH" "RIE5" 44 RPI 817
			233,  // 420 "EC7DA" "CLGIJNL" "RIE5" 44 RPI 817
			236,  // 430 "EC7E" "CIJ" "RIE4" 43 RPI 817
			236,  // 440 "EC7E8" "CIJE" "RIE5" 44 RPI 817
			236,  // 450 "EC7E2" "CIJH" "RIE5" 44 RPI 817
			236,  // 460 "EC7E4" "CIJL" "RIE5" 44 RPI 817
			236,  // 470 "EC7E6" "CIJNE" "RIE5" 44 RPI 817
			236,  // 480 "EC7EC" "CIJNH" "RIE5" 44 RPI 817
			236,  // 490 "EC7EA" "CIJNL" "RIE5" 44 RPI 817
			236,  // 500 "EC7F" "CLIJ" "RIE4" 43 RPI 817
			236,  // 510 "EC7F8" "CLIJE" "RIE5" 44 RPI 817
			236,  // 520 "EC7F2" "CLIJH" "RIE5" 44 RPI 817
			236,  // 530 "EC7F4" "CLIJL" "RIE5" 44 RPI 817
			236,  // 540 "EC7F6" "CLIJNE" "RIE5" 44 RPI 817
			236,  // 550 "EC7FC" "CLIJNH" "RIE5" 44 RPI 817
			236,  // 560 "EC7FA" "CLIJNL" "RIE5" 44 RPI 817
			420,  // "ECD8","AHIK","RIE9"    57 RPI 1125 Z196
			430,  // "ECD9","AGHIK","RIE9"   57 RPI 1125 Z196
			420,  // "ECDA","ALHSIK","RIE9"  57 RPI 1125 Z196
			430,  // "ECDB","ALGHSIK","RIE9"
			370,  // 570 "ECE4" "CGRB" "RRS1" 45 RPI 817
			370,  // 580 "ECE48" "CGRBE" "RRS2" 4370, RPI 817
			370,  // 590 "ECE42" "CGRBH" "RRS2" 46 RPI 817
			370,  // 600 "ECE44" "CGRBL" "RRS2" 46 RPI 817
			370,  // 610 "ECE46" "CGRBNE" "RRS2" 46 RPI 817
			370,  // 620 "ECE4C" "CGRBNH" "RRS2" 46 RPI 817
			370,  // 630 "ECE4A" "CGRBNL" "RRS2" 46 RPI 817
			370,  // 640 "ECE5" "CLGRB" "RRS1" 45 RPI 817
			370,  // 650 "ECE58" "CLGRBE" "RRS2" 46 RPI 817
			370,  // 660 "ECE52" "CLGRBH" "RRS2" 46 RPI 817
			370,  // 670 "ECE54" "CLGRBL" "RRS2" 46 RPI 817
			370,  // 680 "ECE56" "CLGRBNE" "RRS2" 46 RPI 817
			370,  // 690 "ECE5C" "CLGRBNH" "RRS2" 46 RPI 817
			370,  // 700 "ECE5A" "CLGRBNL" "RRS2" 46 RPI 817
			371,  // 710 "ECF6" "CRB" "RRS1" 45 RPI 817
			371,  // 720 "ECF68" "CRBE" "RRS2" 46 RPI 817
			371,  // 730 "ECF62" "CRBH" "RRS2" 46 RPI 817
			371,  // 740 "ECF64" "CRBL" "RRS2" 46 RPI 817
			371,  // 750 "ECF66" "CRBNE" "RRS1" 45 RPI 817
			371,  // 760 "ECF6C" "CRBNH" "RRS2" 46 RPI 817
			371,  // 770 "ECF6A" "CRBNL" "RRS2" 46 RPI 817
			371,  // 780 "ECF7" "CLRB" "RRS1" 45 RPI 817
			371,  // 790 "ECF78" "CLRBE" "RRS2" 46 RPI 817
			371,  // 800 "ECF72" "CLRBH" "RRS2" 46 RPI 817
			371,  // 810 "ECF74" "CLRBL" "RRS2" 46 RPI 817
			371,  // 820 "ECF76" "CLRBNE" "RRS2" 46 RPI 817
			371,  // 830 "ECF7C" "CLRBNH" "RRS2" 46 RPI 817
			371,  // 840 "ECF7A" "CLRBNL" "RRS2" 46 RPI 817
			380,  // 850 "ECFC" "CGIB" "RRS3" 47 RPI 817
			380,  // 860 "ECFC8" "CGIBE" "RRS4" 48 RPI 817
			380,  // 870 "ECFC2" "CGIBH" "RRS4" 48 RPI 817
			380,  // 880 "ECFC4" "CGIBL" "RRS4" 48 RPI 817
			380,  // 890 "ECFC6" "CGIBNE" "RRS4" 48 RPI 817
			380,  // 900 "ECFCC" "CGIBNH" "RRS4" 48 RPI 817
			380,  // 910 "ECFCA" "CGIBNL" "RRS4" 48 RPI 817
			380,  // 920 "ECFD" "CLGIB" "RRS3" 47 RPI 817
			380,  // 930 "ECFD8" "CLGIBE" "RRS4" 48 RPI 817
			380,  // 940 "ECFD2" "CLGIBH" "RRS4" 48 RPI 817
			380,  // 950 "ECFD4" "CLGIBL" "RRS4" 48 RPI 817
			380,  // 960 "ECFD6" "CLGIBNE" "RRS4" 48 RPI 817
			380,  // 970 "ECFDC" "CLGIBNH" "RRS4" 48 RPI 817
			380,  // 980 "ECFDA" "CLGIBNL" "RRS4" 48 RPI 817
			381,  // 990 "ECFE" "CIB" "RRS3" 47 RPI 817
			381,  // 1000 "ECFE8" "CIBE" "RRS4" 48 RPI 817
			381,  // 1010 "ECFE2" "CIBH" "RRS4" 48 RPI 817
			381,  // 1020 "ECFE4" "CIBL" "RRS4" 48 RPI 817
			381,  // 1030 "ECFE6" "CIBNE" "RRS4" 48 RPI 817
			381,  // 1040 "ECFEC" "CIBNH" "RRS4" 48 RPI 817
			381,  // 1050 "ECFEA" "CIBNL" "RRS4" 48 RPI 817
			381,  // 1060 "ECFF" "CLIB" "RRS3" 47 RPI 817
			381,  // 1070 "ECFF8" "CLIBE" "RRS4" 48 RPI 817
			381,  // 1080 "ECFF2" "CLIBH" "RRS4" 48 RPI 817
			381,  // 1090 "ECFF4" "CLIBL" "RRS4" 48 RPI 817
			381,  // 1100 "ECFF6" "CLIBNE" "RRS4" 48 RPI 817
			381,  // 1110 "ECFFC" "CLIBNH" "RRS4" 48 RPI 817
			381,  // 1120 "ECFFA" "CLIBNL" "RRS4" 48 RPI 817
			240,  // 6620 "ED04" "LDEB" "RXE" 24
			240,  // 6630 "ED05" "LXDB" "RXE" 24
			240,  // 6640 "ED06" "LXEB" "RXE" 24
			240,  // 6650 "ED07" "MXDB" "RXE" 24
			240,  // 6660 "ED08" "KEB" "RXE" 24
			240,  // 6670 "ED09" "CEB" "RXE" 24
			240,  // 6680 "ED0A" "AEB" "RXE" 24
			240,  // 6690 "ED0B" "SEB" "RXE" 24
			240,  // 6700 "ED0C" "MDEB" "RXE" 24
			240,  // 6710 "ED0D" "DEB" "RXE" 24
			250,  // 6720 "ED0E" "MAEB" "RXF" 25
			250,  // 6730 "ED0F" "MSEB" "RXF" 25
			240,  // 6740 "ED10" "TCEB" "RXE" 24
			240,  // 6750 "ED11" "TCDB" "RXE" 24
			240,  // 6760 "ED12" "TCXB" "RXE" 24
			240,  // 6770 "ED14" "SQEB" "RXE" 24
			240,  // 6780 "ED15" "SQDB" "RXE" 24
			240,  // 6790 "ED17" "MEEB" "RXE" 24
			240,  // 6800 "ED18" "KDB" "RXE" 24
			240,  // 6810 "ED19" "CDB" "RXE" 24
			240,  // 6820 "ED1A" "ADB" "RXE" 24
			240,  // 6830 "ED1B" "SDB" "RXE" 24
			240,  // 6840 "ED1C" "MDB" "RXE" 24
			240,  // 6850 "ED1D" "DDB" "RXE" 24
			250,  // 6860 "ED1E" "MADB" "RXF" 25
			250,  // 6870 "ED1F" "MSDB" "RXF" 25
			240,  // 6880 "ED24" "LDE" "RXE" 24
			240,  // 6890 "ED25" "LXD" "RXE" 24
			240,  // 6900 "ED26" "LXE" "RXE" 24
			250,  // 6910 "ED2E" "MAE" "RXF" 25
			250,  // 6920 "ED2F" "MSE" "RXF" 25
			240,  // 6930 "ED34" "SQE" "RXE" 24
			240,  // 6940 "ED35" "SQD" "RXE" 24
			240,  // 6950 "ED37" "MEE" "RXE" 24
			250,  //      "ED38" "MAYL" "RXF" 25 Z9-46
			250,  //      "ED39" "MYL" "RXF" 25 Z9-47
			250,  //      "ED3A" "MAY" "RXF" 25 Z9-48
			250,  //      "ED3B" "MY" "RXF" 25 Z9-49 RPI 298
			250,  //      "ED3C" "MAYH" "RXF" 25 Z9-50
			250,  //      "ED3D" "MYH" "RXF" 25 Z9-51 RPI 298
			250,  // 6960 "ED3E" "MAD" "RXF" 25
			250,  // 6970 "ED3F" "MSD" "RXF" 25
			251, // "SLDT" "ED40" "RXF" DFP 45
			251, // "SRDT" "ED41" "RXF" DFP 46
			251, // "SLXT" "ED48" "RXF" DFP 47
			251, // "SRXT" "ED49" "RXF" DFP 48
			241, // "TDCET" "ED50" "RXE" DFP 49
			241, // "TDGET" "ED51" "RXE" DFP 50
			241, // "TDCDT" "ED54" "RXE" DFP 51
			241, // "TDGDT" "ED55" "RXE" DFP 52
			241, // "TDCXT" "ED58" "RXE" DFP 53
			241, // "TDGXT" "ED59" "RXE" DFP 54
			180,  // 6980 "ED64" "LEY" "RXY" 18
			180,  // 6990 "ED65" "LDY" "RXY" 18
			180,  // 7000 "ED66" "STEY" "RXY" 18
			180,  // 7010 "ED67" "STDY" "RXY" 18
			270,  // 7020 "EE" "PLO" "SS3" 27
			280,  // 7030 "EF" "LMD" "SS4" 28
			290,  // 7040 "F0" "SRP" "SS5" 29
			260,  // 7050 "F1" "MVO" "SS2" 26
			260,  // 7060 "F2" "PACK" "SS2" 26
			260,  // 7070 "F3" "UNPK" "SS2" 26
			260,  // 7080 "F8" "ZAP" "SS2" 26
			260,  // 7090 "F9" "CP" "SS2" 26
			260,  // 7100 "FA" "AP" "SS2" 26
			260,  // 7110 "FB" "SP" "SS2" 26
			260,  // 7120 "FC" "MP" "SS2" 26
			260,  // 7130 "FD" "DP" "SS2" 26
	};
}
