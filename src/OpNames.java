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
 * OpNames is a helper class containing opcode tables for trace.
 */
public class OpNames {
	/**
	 * Opcode tables for trace
	 */
	final static String[] op_name = {
			"*",		//   00	Comments
			"PR",		//   10	"0101"	"PR"	"E"		  1
			"UPT",		//   20	"0102"	"UPT"	"E"		  1
			"PTFF",		//		"0104"	"PTFF"	"E"		  1 // Z9-1
			"SCKPF",	//	 30	"0107"	"SCKPF"	"E"		  1
			"PFPO",		//	 40	"010A"	"PFPO"	"E"		  1 // RPI-1013
			"TAM",		//	 40	"010B"	"TAM"	"E"		  1
			"SAM24",	//	 50	"010C"	"SAM24"	"E"		  1
			"SAM31",	//	 60	"010D"	"SAM31"	"E"		  1
			"SAM64",	//	 70	"010E"	"SAM64"	"E"		  1
			"TRAP2",	//	 80	"01FF"	"TRAP2"	"E"		  1
			"SPM",		//	 90	"04"	"SPM"	"RR"	  2
			"BALR",		//	100	"05"	"BALR"	"RR"	  2
			"BCTR",		//	110	"06"	"BCTR"	"RR"	  2
			"BCR",		//	120	"07"	"BCR"	"RR"	  2
			"BR",		//	130	"07F"	"BR"	"BRX"	  3
			"NOPR",		//	140	"070"	"NOPR"	"BRX"	  3
			"BHR",		//	150	"072"	"BHR"	"BRX"	  3
			"BLR",		//	160	"074"	"BLR"	"BRX"	  3
			"BER",		//	170	"078"	"BER"	"BRX"	  3
			"BNHR",		//	180	"07D"	"BNHR"	"BRX"	  3
			"BNLR",		//	190	"07B"	"BNLR"	"BRX"	  3
			"BNER",		//	200	"077"	"BNER"	"BRX"	  3
			"BPR",		//	210	"072"	"BPR"	"BRX"	  3
			"BOR",		//	220	"071"	"BOR"	"BRX"	  3
			"BMR",		//	230	"074"	"BMR"	"BRX"	  3
			"BZR",		//	240	"078"	"BZR"	"BRX"	  3
			"BNPR",		//	250	"07D"	"BNPR"	"BRX"	  3
			"BNMR",		//	260	"07B"	"BNMR"	"BRX"	  3
			"BNZR",		//	270	"077"	"BNZR"	"BRX"	  3
			"BNOR",		//	280	"07E"	"BNOR"	"BRX"	  3
			"SVC",		//	290	"0A"	"SVC"	"I"		  4
			"BSM",		//	300	"0B"	"BSM"	"RR"	  2
			"BASSM",	//	310	"0C"	"BASSM"	"RR"	  2
			"BASR",		//	320	"0D"	"BASR"	"RR"	  2
			"MVCL",		//	330	"0E"	"MVCL"	"RR"	  2
			"CLCL",		//	340	"0F"	"CLCL"	"RR"	  2
			"LPR",		//	350	"10"	"LPR"	"RR"	  2
			"LNR",		//	360	"11"	"LNR"	"RR"	  2
			"LTR",		//	370	"12"	"LTR"	"RR"	  2
			"LCR",		//	380	"13"	"LCR"	"RR"	  2
			"NR",		//	390	"14"	"NR"	"RR"	  2
			"CLR",		//	400	"15"	"CLR"	"RR"	  2
			"OR",		//	410	"16"	"OR"	"RR"	  2
			"XR",		//	420	"17"	"XR"	"RR"	  2
			"LR",		//	430	"18"	"LR"	"RR"	  2
			"CR",		//	440	"19"	"CR"	"RR"	  2
			"AR",		//	450	"1A"	"AR"	"RR"	  2
			"SR",		//	460	"1B"	"SR"	"RR"	  2
			"MR",		//	470	"1C"	"MR"	"RR"	  2
			"DR",		//	480	"1D"	"DR"	"RR"	  2
			"ALR",		//	490	"1E"	"ALR"	"RR"	  2
			"SLR",		//	500	"1F"	"SLR"	"RR"	  2
			"LPDR",		//	510	"20"	"LPDR"	"RR"	  2
			"LNDR",		//	520	"21"	"LNDR"	"RR"	  2
			"LTDR",		//	530	"22"	"LTDR"	"RR"	  2
			"LCDR",		//	540	"23"	"LCDR"	"RR"	  2
			"HDR",		//	550	"24"	"HDR"	"RR"	  2
			"LDXR",		//	560	"25"	"LDXR"	"RR"	  2
			"LRDR",		//	570	"25"	"LRDR"	"RR"	  2
			"MXR",		//	580	"26"	"MXR"	"RR"	  2
			"MXDR",		//	590	"27"	"MXDR"	"RR"	  2
			"LDR",		//	600	"28"	"LDR"	"RR"	  2
			"CDR",		//	610	"29"	"CDR"	"RR"	  2
			"ADR",		//	620	"2A"	"ADR"	"RR"	  2
			"SDR",		//	630	"2B"	"SDR"	"RR"	  2
			"MDR",		//	640	"2C"	"MDR"	"RR"	  2
			"DDR",		//	650	"2D"	"DDR"	"RR"	  2
			"AWR",		//	660	"2E"	"AWR"	"RR"	  2
			"SWR",		//	670	"2F"	"SWR"	"RR"	  2
			"LPER",		//	680	"30"	"LPER"	"RR"	  2
			"LNER",		//	690	"31"	"LNER"	"RR"	  2
			"LTER",		//	700	"32"	"LTER"	"RR"	  2
			"LCER",		//	710	"33"	"LCER"	"RR"	  2
			"HER",		//	720	"34"	"HER"	"RR"	  2
			"LEDR",		//	730	"35"	"LEDR"	"RR"	  2
			"LRER",		//	740	"35"	"LRER"	"RR"	  2
			"AXR",		//	750	"36"	"AXR"	"RR"	  2
			"SXR",		//	760	"37"	"SXR"	"RR"	  2
			"LER",		//	770	"38"	"LER"	"RR"	  2
			"CER",		//	780	"39"	"CER"	"RR"	  2
			"AER",		//	790	"3A"	"AER"	"RR"	  2
			"SER",		//	800	"3B"	"SER"	"RR"	  2
			"MDER",		//	810	"3C"	"MDER"	"RR"	  2
			"MER",		//	820	"3C"	"MER"	"RR"	  2
			"DER",		//	830	"3D"	"DER"	"RR"	  2
			"AUR",		//	840	"3E"	"AUR"	"RR"	  2
			"SUR",		//	850	"3F"	"SUR"	"RR"	  2
			"STH",		//	860	"40"	"STH"	"RX"	  5
			"LA",		//	870	"41"	"LA"	"RX"	  5
			"STC",		//	880	"42"	"STC"	"RX"	  5
			"IC",		//	890	"43"	"IC"	"RX"	  5
			"EX",		//	900	"44"	"EX"	"RX"	  5
			"BAL",		//	910	"45"	"BAL"	"RX"	  5
			"BCT",		//	920	"46"	"BCT"	"RX"	  5
			"BC",		//	930	"47"	"BC"	"RX"	  5
			"B",		//	940	"47F"	"B"		"BCX"	  6
			"NOP",		//	950	"470"	"NOP"	"BCX"	  6
			"BH",		//	960	"472"	"BH"	"BCX"	  6
			"BL",		//	970	"474"	"BL"	"BCX"	  6
			"BE",		//	980	"478"	"BE"	"BCX"	  6
			"BNH",		//	990	"47D"	"BNH"	"BCX"	  6
			"BNL",		// 1000	"47B"	"BNL"	"BCX"	  6
			"BNE",		// 1010	"477"	"BNE"	"BCX"	  6
			"BP",		// 1020	"472"	"BP"	"BCX"	  6
			"BO",		// 1030	"471"	"BO"	"BCX"	  6
			"BM",		// 1040 "474"	"BM"	"BCX"	  6
			"BZ",		// 1050 "478"	"BZ"	"BCX"	  6
			"BNP",		// 1060 "47D"	"BNP"	"BCX"	  6
			"BNM",		// 1070 "47B"	"BNM"	"BCX"	  6
			"BNZ",		// 1080 "477"	"BNZ"	"BCX"	  6
			"BNO",		// 1090 "47E"	"BNO"	"BCX"	  6
			"LH",		// 1100 "48"	"LH"	"RX"	  5
			"CH",		// 1110 "49"	"CH"	"RX"	  5
			"AH",		// 1120 "4A"	"AH"	"RX"	  5
			"SH",		// 1130 "4B"	"SH"	"RX"	  5
			"MH",		// 1140 "4C"	"MH"	"RX"	  5
			"BAS",		// 1150 "4D"	"BAS"	"RX"	  5
			"CVD",		// 1160 "4E"	"CVD"	"RX"	  5
			"CVB",		// 1170 "4F"	"CVB"	"RX"	  5
			"ST",		// 1180 "50"	"ST"	"RX"	  5
			"LAE",		// 1190 "51"	"LAE"	"RX"	  5
			"XDECO",	// 1193 "52"	"XDECO"	"RX"	 37 // RPI-0812
			"XDECI",	// 1196 "53"	"XDECI"	"RX"	 37 // RPI-0812
			"N",		// 1200 "54"	"N"		"RX"	  5
			"CL",		// 1210 "55"	"CL"	"RX"	  5
			"O",		// 1220 "56"	"O"		"RX"	  5
			"X",		// 1230 "57"	"X"		"RX"	  5
			"L",		// 1240 "58"	"L"		"RX"	  5
			"C",		// 1250 "59"	"C"		"RX"	  5
			"A",		// 1260 "5A"	"A"		"RX"	  5
			"S",		// 1270 "5B"	"S"		"RX"	  5
			"M",		// 1280 "5C"	"M"		"RX"	  5
			"D",		// 1290 "5D"	"D"		"RX"	  5
			"AL",		// 1300 "5E"	"AL"	"RX"	  5
			"SL",		// 1310 "5F"	"SL"	"RX"	  5
			"STD",		// 1320 "60"	"STD"	"RX"	  5
			"XHEXI",	// 1323 "61"	"XHEXI"	"RX"	 37 // RPI-0812
			"XHEXO",	// 1326 "62"	"XHEXO"	"RX"	 37 // RPI-0812
			"MXD",		// 1330 "67"	"MXD"	"RX"	  5
			"LD",		// 1340 "68"	"LD"	"RX"	  5
			"CD",		// 1350 "69"	"CD"	"RX"	  5
			"AD",		// 1360 "6A"	"AD"	"RX"	  5
			"SD",		// 1370 "6B"	"SD"	"RX"	  5
			"MD",		// 1380 "6C"	"MD"	"RX"	  5
			"DD",		// 1390 "6D"	"DD"	"RX"	  5
			"AW",		// 1400 "6E"	"AW"	"RX"	  5
			"SW",		// 1410 "6F"	"SW"	"RX"	  5
			"STE",		// 1420 "70"	"STE"	"RX"	  5
			"MS",		// 1430 "71"	"MS"	"RX"	  5
			"LE",		// 1440 "78"	"LE"	"RX"	  5
			"CE",		// 1450 "79"	"CE"	"RX"	  5
			"AE",		// 1460 "7A"	"AE"	"RX"	  5
			"SE",		// 1470 "7B"	"SE"	"RX"	  5
			"MDE",		// 1480 "7C"	"MDE"	"RX"	  5
			"ME",		// 1490 "7C"	"ME"	"RX"	  5
			"DE",		// 1500 "7D"	"DE"	"RX"	  5
			"AU",		// 1510 "7E"	"AU"	"RX"	  5
			"SU",		// 1520 "7F"	"SU"	"RX"	  5
			"SSM",		// 1530 "8000"	"SSM"	"S"		  7
			"LPSW",		// 1540 "8200"	"LPSW"	"S"		  7
			"DIAGNOSE",	// 1550 "83"	"DIAGNOSE" "DM"	  8
			"BRXH",		// 1560 "84"	"BRXH"	"RSI"	  9
			"JXH",		// 1570 "84"	"JXH"	"RSI"	  9
			"BRXLE",	// 1580 "85"	"BRXLE"	"RSI"	  9
			"JXLE",		// 1590 "85"	"JXLE"	"RSI"	  9
			"BXH",		// 1600 "86"	"BXH"	"RS"	 10
			"BXLE",		// 1610 "87"	"BXLE"	"RS"	 10
			"SRL",		// 1620 "88"	"SRL"	"RS"	 10
			"SLL",		// 1630 "89"	"SLL"	"RS"	 10
			"SRA",		// 1640 "8A"	"SRA"	"RS"	 10
			"SLA",		// 1650 "8B"	"SLA"	"RS"	 10
			"SRDL",		// 1660 "8C"	"SRDL"	"RS"	 10
			"SLDL",		// 1670 "8D"	"SLDL"	"RS"	 10
			"SRDA",		// 1680 "8E"	"SRDA"	"RS"	 10
			"SLDA",		// 1690 "8F"	"SLDA"	"RS"	 10
			"STM",		// 1700 "90"	"STM"	"RS"	 10
			"TM",		// 1710 "91"	"TM"	"SI"	 11
			"MVI",		// 1720 "92"	"MVI"	"SI"	 11
			"TS",		// 1730 "9300"	"TS"	"S"		  7
			"NI",		// 1740 "94"	"NI"	"SI"	 11
			"CLI",		// 1750 "95"	"CLI"	"SI"	 11
			"OI",		// 1760 "96"	"OI"	"SI"	 11
			"XI",		// 1770 "97"	"XI"	"SI"	 11
			"LM",		// 1780 "98"	"LM"	"RS"	 10
			"TRACE",	// 1790 "99"	"TRACE"	"RS"	 10
			"LAM",		// 1800 "9A"	"LAM"	"RS"	 10
			"STAM",		// 1810 "9B"	"STAM"	"RS"	 10
			"IIHH",		// 1820 "A50"	"IIHH"	"RI"	 12
			"IIHL",		// 1830 "A51"	"IIHL"	"RI"	 12
			"IILH",		// 1840 "A52"	"IILH"	"RI"	 12
			"IILL",		// 1850 "A53"	"IILL"	"RI"	 12
			"NIHH",		// 1860 "A54"	"NIHH"	"RI"	 12
			"NIHL",		// 1870 "A55"	"NIHL"	"RI"	 12
			"NILH",		// 1880 "A56"	"NILH"	"RI"	 12
			"NILL",		// 1890 "A57"	"NILL"	"RI"	 12
			"OIHH",		// 1900 "A58"	"OIHH"	"RI"	 12
			"OIHL",		// 1910 "A59"	"OIHL"	"RI"	 12
			"OILH",		// 1920 "A5A"	"OILH"	"RI"	 12
			"OILL",		// 1930 "A5B"	"OILL"	"RI"	 12
			"LLIHH",	// 1940 "A5C"	"LLIHH"	"RI"	 12
			"LLIHL",	// 1950 "A5D"	"LLIHL"	"RI"	 12
			"LLILH",	// 1960 "A5E"	"LLILH"	"RI"	 12
			"LLILL",	// 1970 "A5F"	"LLILL"	"RI"	 12
			"TMLH",		// 1980 "A70"	"TMLH"	"RI"	 12
			"TMH",		// 1990 "A70"	"TMH"	"RI"	 12
			"TMLL",		// 2000 "A71"	"TMLL"	"RI"	 12
			"TML",		// 2010 "A71"	"TML"	"RI"	 12
			"TMHH",		// 2020 "A72"	"TMHH"	"RI"	 12
			"TMHL",		// 2030 "A73"	"TMHL"	"RI"	 12
			"BRC",		// 2040 "A74"	"BRC"	"RI"	 12
			"J",		// 2050 "A74F"	"J"		"BRCX"	 13
			"JNOP",		// 2060 "A740"	"JNOP"	"BRCX"	 13
			"BRU",		// 2070 "A74F"	"BRU"	"BRCX"	 13
			"BRH",		// 2080 "A742"	"BRH"	"BRCX"	 13
			"BRL",		// 2090 "A744"	"BRL"	"BRCX"	 13
			"BRE",		// 2100 "A748"	"BRE"	"BRCX"	 13
			"BRNH",		// 2110 "A74D"	"BRNH"	"BRCX"	 13
			"BRNL",		// 2120 "A74B"	"BRNL"	"BRCX"	 13
			"BRNE",		// 2130 "A747"	"BRNE"	"BRCX"	 13
			"BRP",		// 2140 "A742"	"BRP"	"BRCX"	 13
			"BRM",		// 2150 "A744"	"BRM"	"BRCX"	 13
			"BRZ",		// 2160 "A748"	"BRZ"	"BRCX"	 13
			"BRO",		// 2170 "A741"	"BRO"	"BRCX"	 13
			"BRNP",		// 2180 "A74D"	"BRNP"	"BRCX"	 13
			"BRNM",		// 2190 "A74B"	"BRNM"	"BRCX"	 13
			"BRNZ",		// 2200 "A747"	"BRNZ"	"BRCX"	 13
			"BRNO",		// 2210 "A74E"	"BRNO"	"BRCX"	 13
			"JH",		// 2220 "A742"	"JH"	"BRCX"	 13
			"JL",		// 2230 "A744"	"JL"	"BRCX"	 13
			"JE",		// 2240 "A748"	"JE"	"BRCX"	 13
			"JNH",		// 2250 "A74D"	"JNH"	"BRCX"	 13
			"JNL",		// 2260 "A74B"	"JNL"	"BRCX"	 13
			"JNE",		// 2270 "A747"	"JNE"	"BRCX"	 13
			"JP",		// 2280 "A742"	"JP"	"BRCX"	 13
			"JM",		// 2290 "A744"	"JM"	"BRCX"	 13
			"JZ",		// 2300 "A748"	"JZ"	"BRCX"	 13
			"JO",		// 2310 "A741"	"JO"	"BRCX"	 13
			"JNP",		// 2320 "A74D"	"JNP"	"BRCX"	 13
			"JNM",		// 2330 "A74B"	"JNM"	"BRCX"	 13
			"JNZ",		// 2340 "A747"	"JNZ"	"BRCX"	 13
			"JNO",		// 2350 "A74E"	"JNO"	"BRCX"	 13
			"BRAS",		// 2360 "A75"	"BRAS"	"RI"	 12
			"JAS",		// 2370 "A75"	"JAS"	"RI"	 12
			"BRCT",		// 2380 "A76"	"BRCT"	"RI"	 12
			"JCT",		// 2390 "A76"	"JCT"	"RI"	 12
			"BRCTG",	// 2400 "A77"	"BRCTG"	"RI"	 12
			"JCTG",		// 2410 "A77"	"JCTG"	"RI"	 12
			"LHI",		// 2420 "A78"	"LHI"	"RI"	 12
			"LGHI",		// 2430 "A79"	"LGHI"	"RI"	 12
			"AHI",		// 2440 "A7A"	"AHI"	"RI"	 12
			"AGHI",		// 2450 "A7B"	"AGHI"	"RI"	 12
			"MHI",		// 2460 "A7C"	"MHI"	"RI"	 12
			"MGHI",		// 2470 "A7D"	"MGHI"	"RI"	 12
			"CHI",		// 2480 "A7E"	"CHI"	"RI"	 12
			"CGHI",		// 2490 "A7F"	"CGHI"	"RI"	 12
			"MVCLE",	// 2500 "A8"	"MVCLE"	"RS"	 10
			"CLCLE",	// 2510 "A9"	"CLCLE"	"RS"	 10
			"STNSM",	// 2520 "AC"	"STNSM"	"SI"	 11
			"STOSM",	// 2530 "AD"	"STOSM"	"SI"	 11
			"SIGP",		// 2540 "AE"	"SIGP"	"RS"	 10
			"MC",		// 2550 "AF"	"MC"	"SI"	 11
			"LRA",		// 2560 "B1"	"LRA"	"RX"	  5
			"STIDP",	// 2570 "B202"	"STIDP"	"S"		  7
			"SCK",		// 2580 "B204"	"SCK"	"S"		  7
			"STCK",		// 2590 "B205"	"STCK"	"S"		  7
			"SCKC",		// 2600 "B206"	"SCKC"	"S"		  7
			"STCKC",	// 2610 "B207"	"STCKC"	"S"		  7
			"SPT",		// 2620 "B208"	"SPT"	"S"		  7
			"STPT",		// 2630 "B209"	"STPT"	"S"		  7
			"SPKA",		// 2640 "B20A"	"SPKA"	"S"		  7
			"IPK",		// 2650 "B20B"	"IPK"	"S"		  7
			"PTLB",		// 2660 "B20D"	"PTLB"	"S"		  7
			"SPX",		// 2670 "B210"	"SPX"	"S"		  7
			"STPX",		// 2680 "B211"	"STPX"	"S"		  7
			"STAP",		// 2690 "B212"	"STAP"	"S"		  7
			"PC",		// 2700 "B218"	"PC"	"S"		  7
			"SAC",		// 2710 "B219"	"SAC"	"S"		  7
			"CFC",		// 2720 "B21A"	"CFC"	"S"		  7
			"IPTE",		// 2730 "B221"	"IPTE"	"RRE"	 14
			"IPM",		// 2740 "B222"	"IPM"	"RRE"	 14
			"IVSK",		// 2750 "B223"	"IVSK"	"RRE"	 14
			"IAC",		// 2760 "B224"	"IAC"	"RRE"	 14
			"SSAR",		// 2770 "B225"	"SSAR"	"RRE"	 14
			"EPAR",		// 2780 "B226"	"EPAR"	"RRE"	 14
			"ESAR",		// 2790 "B227"	"ESAR"	"RRE"	 14
			"PT",		// 2800 "B228"	"PT"	"RRE"	 14
			"ISKE",		// 2810 "B229"	"ISKE"	"RRE"	 14
			"RRBE",		// 2820 "B22A"	"RRBE"	"RRE"	 14
			"SSKE",		// 2830 "B22B"	"SSKE"	"RRE"	 14
			"TB",		// 2840 "B22C"	"TB"	"RRE"	 14
			"DXR",		// 2850 "B22D"	"DXR"	"RRE"	 14
			"PGIN",		// 2860 "B22E"	"PGIN"	"RRE"	 14
			"PGOUT",	// 2870 "B22F"	"PGOUT"	"RRE"	 14
			"CSCH",		// 2880 "B230"	"CSCH"	"S"		  7
			"HSCH",		// 2890 "B231"	"HSCH"	"S"		  7
			"MSCH",		// 2900 "B232"	"MSCH"	"S"		  7
			"SSCH",		// 2910 "B233"	"SSCH"	"S"		  7
			"STSCH",	// 2920 "B234"	"STSCH"	"S"		  7
			"TSCH",		// 2930 "B235"	"TSCH"	"S"		  7
			"TPI",		// 2940 "B236"	"TPI"	"S"		  7
			"SAL",		// 2950 "B237"	"SAL"	"S"		  7
			"RSCH",		// 2960 "B238"	"RSCH"	"S"		  7
			"STCRW",	// 2970 "B239"	"STCRW"	"S"		  7
			"STCPS",	// 2980 "B23A"	"STCPS"	"S"		  7
			"RCHP",		// 2990 "B23B"	"RCHP"	"S"		  7
			"SCHM",		// 3000 "B23C"	"SCHM"	"S"		  7
			"BAKR",		// 3010 "B240"	"BAKR"	"RRE"	 14
			"CKSM",		// 3020 "B241"	"CKSM"	"RRE"	 14
			"SQDR",		// 3030 "B244"	"SQDR"	"RRE"	 14
			"SQER",		// 3040 "B245"	"SQER"	"RRE"	 14
			"STURA",	// 3050 "B246"	"STURA"	"RRE"	 14
			"MSTA",		// 3060 "B247"	"MSTA"	"RRE"	 14
			"PALB",		// 3070 "B248"	"PALB"	"RRE"	 14
			"EREG",		// 3080 "B249"	"EREG"	"RRE"	 14
			"ESTA",		// 3090 "B24A"	"ESTA"	"RRE"	 14
			"LURA",		// 3100 "B24B"	"LURA"	"RRE"	 14
			"TAR",		// 3110 "B24C"	"TAR"	"RRE"	 14
			"CPYA",		// 3120 "B24D"	"CPYA"	"RRE"	 14
			"SAR",		// 3130 "B24E"	"SAR"	"RRE"	 14
			"EAR",		// 3140 "B24F"	"EAR"	"RRE"	 14
			"CSP",		// 3150 "B250"	"CSP"	"RRE"	 14
			"MSR",		// 3160 "B252"	"MSR"	"RRE"	 14
			"MVPG",		// 3170 "B254"	"MVPG"	"RRE"	 14
			"MVST",		// 3180 "B255"	"MVST"	"RRE"	 14
			"CUSE",		// 3190 "B257"	"CUSE"	"RRE"	 14
			"BSG",		// 3200 "B258"	"BSG"	"RRE"	 14
			"BSA",		// 3210 "B25A"	"BSA"	"RRE"	 14
			"CLST",		// 3220 "B25D"	"CLST"	"RRE"	 14
			"SRST",		// 3230 "B25E"	"SRST"	"RRE"	 14
			"CMPSC",	// 3240 "B263"	"CMPSC"	"RRE"	 14
			"XSCH",		// 3250 "B276"	"XSCH"	"S"		  7
			"RP",		// 3260 "B277"	"RP"	"S"		  7
			"STCKE",	// 3270 "B278"	"STCKE"	"S"		  7
			"SACF",		// 3280 "B279"	"SACF"	"S"		  7
			"STCKF",	//		"B27C"	"STCKF"	"S"		  7 // Z9-2
			"STSI",		// 3290 "B27D"	"STSI"	"S"		  7
			"SRNM",		// 3300 "B299"	"SRNM"	"S"		  7
			"STFPC",	// 3310 "B29C"	"STFPC"	"S"		  7
			"LFPC",		// 3320 "B29D"	"LFPC"	"S"		  7
			"TRE",		// 3330 "B2A5"	"TRE"	"RRE"	 14
			"CUUTF",	// 3340 "B2A6"	"CUUTF"	"RRE"	 14
			"CU21",		// 3350 "B2A6"	"CU21"	"RRE"	 14
			"CUTFU",	// 3360 "B2A7"	"CUTFU"	"RRE"	 14
			"CU12",		// 3370 "B2A7"	"CU12"	"RRE"	 14
			"STFLE",	//		"B2B0"	"STFLE"	"S"		  7 // Z9-3
			"STFL",		// 3380 "B2B1"	"STFL"	"S"		  7
			"LPSWE",	// 3390 "B2B2"	"LPSWE"	"S"		  7
			"SRNMB",	// 3392 "B2B8"	"SRNMB"	"S"		  7 // RPI-1125
			"SRNMT",	// 3395 "B2B9"	"SRNMT"	"S"		  7 DFP 56
			"LFAS",		// 3395 "B2BD"	"LFAS"  "S"		  7 DFP 55
			"TRAP4",	// 3400 "B2FF"	"TRAP4"	"S"		  7
			"LPEBR",	// 3410 "B300"	"LPEBR"	"RRE"	 14
			"LNEBR",	// 3420 "B301"	"LNEBR"	"RRE"	 14
			"LTEBR",	// 3430 "B302"	"LTEBR"	"RRE"	 14
			"LCEBR",	// 3440 "B303"	"LCEBR"	"RRE"	 14
			"LDEBR",	// 3450 "B304"	"LDEBR"	"RRE"	 14
			"LXDBR",	// 3460 "B305"	"LXDBR"	"RRE"	 14
			"LXEBR",	// 3470 "B306"	"LXEBR"	"RRE"	 14
			"MXDBR",	// 3480 "B307"	"MXDBR"	"RRE"	 14
			"KEBR",		// 3490 "B308"	"KEBR"	"RRE"	 14
			"CEBR",		// 3500 "B309"	"CEBR"	"RRE"	 14
			"AEBR",		// 3510 "B30A"	"AEBR"	"RRE"	 14
			"SEBR",		// 3520 "B30B"	"SEBR"	"RRE"	 14
			"MDEBR",	// 3530 "B30C"	"MDEBR"	"RRE"	 14
			"DEBR",		// 3540 "B30D"	"DEBR"	"RRE"	 14
			"MAEBR",	// 3550 "B30E"	"MAEBR"	"RRF1"	 15
			"MSEBR",	// 3560 "B30F"	"MSEBR"	"RRF1"	 15
			"LPDBR",	// 3570 "B310"	"LPDBR"	"RRE"	 14
			"LNDBR",	// 3580 "B311"	"LNDBR"	"RRE"	 14
			"LTDBR",	// 3590 "B312"	"LTDBR"	"RRE"	 14
			"LCDBR",	// 3600 "B313"	"LCDBR"	"RRE"	 14
			"SQEBR",	// 3610 "B314"	"SQEBR"	"RRE"	 14
			"SQDBR",	// 3620 "B315"	"SQDBR"	"RRE"	 14
			"SQXBR",	// 3630 "B316"	"SQXBR"	"RRE"	 14
			"MEEBR",	// 3640 "B317"	"MEEBR"	"RRE"	 14
			"KDBR",		// 3650 "B318"	"KDBR"	"RRE"	 14
			"CDBR",		// 3660 "B319"	"CDBR"	"RRE"	 14
			"ADBR",		// 3670 "B31A"	"ADBR"	"RRE"	 14
			"SDBR",		// 3680 "B31B"	"SDBR"	"RRE"	 14
			"MDBR",		// 3690 "B31C"	"MDBR"	"RRE"	 14
			"DDBR",		// 3700 "B31D"	"DDBR"	"RRE"	 14
			"MADBR",	// 3710 "B31E"	"MADBR"	"RRF1"	 15
			"MSDBR",	// 3720 "B31F"	"MSDBR"	"RRF1"	 15
			"LDER",		// 3730 "B324"	"LDER"	"RRE"	 14
			"LXDR",		// 3740 "B325"	"LXDR"	"RRE"	 14
			"LXER",		// 3750 "B326"	"LXER"	"RRE"	 14
			"MAER",		// 3760 "B32E"	"MAER"	"RRF1"	 15
			"MSER",		// 3770 "B32F"	"MSER"	"RRF1"	 15
			"SQXR",		// 3780 "B336"	"SQXR"	"RRE"	 14
			"MEER",		// 3790 "B337"	"MEER"	"RRE"	 14
			"MAYLR",	//		"B338"	"MAYLR"	"RRF1"	 15 // Z9-4
			"MYLR",		//		"B339"	"MYLR"	"RRF1"	 15 // Z9-5
			"MAYR",		//		"B33A"	"MAYR"	"RRF1"	 15 // Z9-6
			"MYR",		//		"B33B"	"MYR"	"RRF1"	 15 // Z9-7
			"MAYHR",	//		"B33C"	"MAYHR"	"RRF1"	 15 // Z9-8
			"MYHR",		//		"B33D"	"MYHR"	"RRF1"	 15 // Z9-9
			"MADR",		// 3800 "B33E"	"MADR"	"RRF1"	 15
			"MSDR",		// 3810 "B33F"	"MSDR"	"RRF1"	 15
			"LPXBR",	// 3820 "B340"	"LPXBR"	"RRE"	 14
			"LNXBR",	// 3830 "B341"	"LNXBR"	"RRE"	 14
			"LTXBR",	// 3840 "B342"	"LTXBR"	"RRE"	 14
			"LCXBR",	// 3850 "B343"	"LCXBR"	"RRE"	 14
			"LEDBR?",	// 3860 "B344"	"LEDBR?" "RRE"	 53 // RPI-1125
			"LDXBR?",	// 3870 "B345"	"LDXBR?" "RRE"	 53 // RPI-1125
			"LEXBR?",	// 3880 "B346"	"LEXBR?" "RRE"	 53 // RPI-1125
			"FIXBR?",	// 3890 "B347"	"FIXBR?" "RRF2"	 54 // RPI-1125
			"KXBR",		// 3900 "B348"	"KXBR"	"RRE"	 14
			"CXBR",		// 3910 "B349"	"CXBR"	"RRE"	 14
			"AXBR",		// 3920 "B34A"	"AXBR"	"RRE"	 14
			"SXBR",		// 3930 "B34B"	"SXBR"	"RRE"	 14
			"MXBR",		// 3940 "B34C"	"MXBR"	"RRE"	 14
			"DXBR",		// 3950 "B34D"	"DXBR"	"RRE"	 14
			"TBEDR",	// 3960 "B350"	"TBEDR"	"RRF2"	 34
			"TBDR",		// 3970 "B351"	"TBDR"	"RRF2"	 34
			"DIEBR",	// 3980	"B353"	"DIEBR"	"RRF3"	 30
			"FIEBR?",	// 3990	"B357"	"FIEBR?" "RRF2"	 54 // RPI-1125
			"THDER",	// 4000	"B358"	"THDER"	"RRE"	 14
			"THDR",		// 4010	"B359"	"THDR"	"RRE"	 14
			"DIDBR",	// 4020	"B35B"	"DIDBR"	"RRF3"	 30
			"FIDBR?",	// 4030	"B35F"	"FIDBR?" "RRF2"	 54 // RPI-1125
			"LPXR",		// 4040	"B360"	"LPXR"	"RRE"	 14
			"LNXR",		// 4050	"B361"	"LNXR"	"RRE"	 14
			"LTXR",		// 4060	"B362"	"LTXR"	"RRE"	 14
			"LCXR",		// 4070	"B363"	"LCXR"	"RRE"	 14
			"LXR",		// 4080	"B365"	"LXR"	"RRE"	 14
			"LEXR",		// 4090	"B366"	"LEXR"	"RRE"	 14
			"FIXR",		// 4100	"B367"	"FIXR"	"RRE"	 14
			"CXR",		// 4110	"B369"	"CXR"	"RRE"	 14
			"LPDFR",	// 4115	"B370"	"LPDFR"	"RRE"	 14 DFP
			"LNDFR",	// 4115	"B371"	"LNDFR"	"RRE"	 14 DFP
			"CPSDR",	// 4115	"B372"	"CPSDR"	"RRF2"	 34 DFP
			"LCDFR",	// 4115	"B373"	"LCDFR"	"RRE"	 14 DFP
			"LZER",		// 4120	"B374"	"LZER"	"RRE"	 14
			"LZDR",		// 4130	"B375"	"LZDR"	"RRE"	 14
			"LZXR",		// 4140	"B376"	"LZXR"	"RRE"	 14
			"FIER",		// 4150	"B377"	"FIER"	"RRE"	 14
			"FIDR",		// 4160	"B37F"	"FIDR"	"RRE"	 14
			"SFPC",		// 4170	"B384"	"SFPC"	"RRE"	 14
			"SFASR",	// 4175	"B385"	"SFASR"	"RRE"	 14 DFP 57
			"EFPC",		// 4180	"B38C"	"EFPC"	"RRE"	 14
			"CELFBR",	//		"B390"	"CELFBR" "RRF3"	 30 // RPI-1125 Z196
			"CDLFBR",	//		"B391"	"CDLFBR" "RRF3"	 30 // RPI-1125 Z196
			"CXLFBR",	//		"B392"	"CXLFBR" "RRF3"	 30 // RPI-0005 Z112196
			"CEFBR?",	// 4190 "B394"	"CEFBR?" "RRE"	 53 // RPI-1125 Z196
			"CDFBR?",	// 4200 "B395"	"CDFBR?" "RRE"	 53 // RPI-1125 Z196
			"CXFBR?",	// 4210 "B396"	"CXFBR?" "RRE"	 53 // RPI-1125 Z196
			"CFEBR?",	// 4220 "B398"	"CFEBR?" "RRF2"	 34 // RPI-1125 Z196
			"CFDBR?",	// 4230 "B399"	"CFDBR?" "RRF2"	 34 // RPI-1125 Z196
			"CFXBR?",	// 4240 "B39A"	"CFXBR?" "RRF2"	 34 // RPI-1125 Z196
			"CLFEBR",	//		'B39C'	'CLFEBR' 'RRF3'	 30 // RPI-1125 Z196
			"CLFDBR",	//		'B39D'	'CLFDBR' 'RRF3'	 30 // RPI-1125 Z196
			"CLFXBR",	//		'B39E'	'CLFXBR' 'RRF3'	 30 // RPI-1125 Z196
			"CELGBR",	//		'B3A0'	'CELGBR' 'RRF3'	 30 // RPI-1125 Z196
			"CDLGBR",	//		'B3A1'	'CDLGBR' 'RRF3'	 30 // RPI-1125 Z196
			"CXLGBR",	//		'B3A2'	'CXLGBR' 'RRF3'	 30 // RPI-1125 Z196
			"CEGBR?",	// 4250	"B3A4"	"CEGBR?" "RRE"	 53 // RPI-1125 Z196
			"CDGBR?",	// 4260	"B3A5"	"CDGBR?" "RRE"	 53 // RPI-1125 Z196
			"CXGBR?",	// 4270	"B3A6"	"CXGBR?" "RRE"	 53 // RPI-1125 Z196
			"CGEBR?",	// 4280	"B3A8"	"CGEBR?" "RRF2"	 54 // RPI-1125 Z196
			"CGDBR?",	// 4290	"B3A9"	"CGDBR?" "RRF2"	 54 // RPI-1125 Z196
			"CGXBR?",	// 4300	"B3AA"	"CGXBR?" "RRF2"	 54 // RPI-1125 Z196
			"CLGEBR",	//		"B3AC"	"CLGEBR" "RRF2"	 30 // RPI-1125 Z196
			"CLGDBR",	//		"B3AD"	"CLGDBR" "RRF2"	 30 // RPI-1125 Z196
			"CLGXBR",	//		"B3AE"	"CLGXBR" "RRF2"	 30 // RPI-1125 Z196
			"CEFR",		// 4310 "B3B4"	"CEFR"	"RRE" 14
			"CDFR",		// 4320 "B3B5"	"CDFR"	"RRE" 14
			"CXFR",		// 4330 "B3B6"	"CXFR"	"RRE" 14
			"CFER",		// 4340 "B3B8"	"CFER"	"RRF2" 34
			"CFDR",		// 4350 "B3B9"	"CFDR"	"RRF2" 34
			"CFXR",		// 4360 "B3BA"	"CFXR"	"RRF2" 34
			"LDGR",		// 4365 "B3C1"	"LDGR"	"RRE" 14 DFP
			"CEGR",		// 4370 "B3C4"	"CEGR"	"RRE" 14
			"CDGR",		// 4380 "B3C5"	"CDGR"	"RRE" 14
			"CXGR",		// 4390 "B3C6"	"CXGR"	"RRE" 14
			"CGER",		// 4400 "B3C8"	"CGER"	"RRF2" 34
			"CGDR",		// 4410 "B3C9"	"CGDR"	"RRF2" 34
			"CGXR",		// 4420 "B3CA"	"CGXR"	"RRF2" 34
			"LGDR",		// 4425 "B3CD"	"LGDR"	"RRE" 14 DFP
			"MDTR?",	//		"B3D0"	"RRR"	 DFP  1 RPI-1125
			"DDTR?",	//		"B3D1"	"RRR"	 DFP  2 RPI-1125
			"ADTR?",	//		"B3D2"	"RRR"	 DFP  3 RPI-1125
			"SDTR?",	//		"B3D3"	"RRR"	 DFP  4 RPI-1125
			"LDETR",	//		"B3D4"	"RRF4"	 DFP  5 
			"LEDTR",	//		"B3D5"	"RRF3"	 DFP  6 
			"LTDTR",	//		"B3D6"	"RRE"	 DFP  7 
			"FIDTR",	//		"B3D7"	"RRF3"	 DFP  8 
			"MXTR?",	//		"B3D8"	"RRR"	 DFP  9 RPI-1125
			"DXTR?",	//		"B3D9"	"RRR"	 DFP 10 RPI-1125
			"AXTR?",	//		"B3DA"	"RRR"	 DFP 11 RPI-1125
			"SXTR?",	//		"B3DB"	"RRR"	 DFP 12 RPI-1125
			"LXDTR",	//		"B3DC"	"RRF4"	 DFP 13
			"LDXTR",	//		"B3DD"	"RRF3"	 DFP 14
			"LTXTR",	//		"B3DE"	"RRE"	 DFP 15
			"FIXTR",	//		"B3DF"	"RRF3"	 DFP 16
			"KDTR",		//		"B3E0"	"RRE"	 DFP 17
			"CGDTR?",	//		"B3E1"	"RRF7"	 DFP 18 // RPI-1125
			"CUDTR",	//		"B3E2"	"RRE"	 DFP 19
			"CSDTR",	//		"B3E3"	"RRF4"	 DFP 20
			"CDTR",		//		"B3E4"	"RRE"	 DFP 21
			"EEDTR",	//		"B3E5"	"RRE"	 DFP 22
			"ESDTR",	//		"B3E7"	"RRE"	 DFP 23
			"KXTR",		//		"B3E8"	"RRE"	 DFP 24
			"CGXTR?",	//		"B3E9"	"RRF7"	 DFP 25 // RPI-1125
			"CUXTR",	//		"B3EA"	"RRE"	 DFP 26
			"CSXTR",	//		"B3EB"	"RRF4"	 DFP 27
			"CXTR",		//		"B3EC"	"RRE"	 DFP 28
			"EEXTR",	//		"B3ED"	"RRE"	 DFP 29
			"ESXTR",	//		"B3EF"	"RRE"	 DFP 30
			"CDGTR?",	//		"B3F1"	"RE3"	 DFP 31 // RPI-1125
			"CDUTR",	//		"B3F2"	"RRE"	 DFP 32
			"CDSTR",	//		"B3F3"	"RRE"	 DFP 33
			"CEDTR",	//		"B3F4"	"RRE"	 DFP 34
			"QADTR",	//		"B3F5"	"RRF3"	 DFP 35
			"IEDTR",	//		"B3F6"	"RRF2"	 DFP 36
			"RRDTR",	//		"B3F7"	"RRF3"	 DFP 37
			"CXGTR?",	//		"B3F9"	"RE3"	 DFP 38 // RPI-1125
			"CXUTR",	//		"B3FA"	"RRE"	 DFP 39
			"CXSTR",	//		"B3FB"	"RRE"	 DFP 40
			"CEXTR",	//		"B3FC"	"RRE"	 DFP 41
			"QAXTR",	//		"B3FD"	"RRF3"	 DFP 42
			"IEXTR",	//		"B3FE"	"RRF2"	 DFP 43
			"RRXTR",	//		"B3FF"	"RRF3"	 DFP 44
			"STCTL",	// 4430	"B6"	"STCTL"	"RS" 10
			"LCTL",		// 4440	"B7"	"LCTL"	"RS" 10
			"LPGR",		// 4450	"B900"	"LPGR"	"RRE" 14
			"LNGR",		// 4460	"B901"	"LNGR"	"RRE" 14
			"LTGR",		// 4470	"B902"	"LTGR"	"RRE" 14
			"LCGR",		// 4480	"B903"	"LCGR"	"RRE" 14
			"LGR",		// 4490	"B904"	"LGR"	"RRE" 14
			"LURAG",	// 4500	"B905"	"LURAG"	"RRE" 14
			"LGBR",		//		"B906"	"LGBR"	"RRE" 14 Z9-10
			"LGHR",		//		"B907"	"LGHR"	"RRE" 14 Z9-11
			"AGR",		// 4510 "B908"	"AGR"	"RRE" 14
			"SGR",		// 4520 "B909"	"SGR"	"RRE" 14
			"ALGR",		// 4530 "B90A"	"ALGR"	"RRE" 14
			"SLGR",		// 4540 "B90B"	"SLGR"	"RRE" 14
			"MSGR",		// 4550 "B90C"	"MSGR"	"RRE" 14
			"DSGR",		// 4560 "B90D"	"DSGR"	"RRE" 14
			"EREGG",	// 4570 "B90E"	"EREGG"	"RRE" 14
			"LRVGR",	// 4580 "B90F"	"LRVGR"	"RRE" 14
			"LPGFR",	// 4590 "B910"	"LPGFR"	"RRE" 14
			"LNGFR",	// 4600 "B911"	"LNGFR"	"RRE" 14
			"LTGFR",	// 4610 "B912"	"LTGFR"	"RRE" 14
			"LCGFR",	// 4620 "B913"	"LCGFR"	"RRE" 14
			"LGFR",		// 4630 "B914"	"LGFR"	"RRE" 14
			"LLGFR",	// 4640 "B916"	"LLGFR"	"RRE" 14
			"LLGTR",	// 4650 "B917"	"LLGTR"	"RRE" 14
			"AGFR",		// 4660 "B918"	"AGFR"	"RRE" 14
			"SGFR",		// 4670 "B919"	"SGFR"	"RRE" 14
			"ALGFR",	// 4680 "B91A"	"ALGFR"	"RRE" 14
			"SLGFR",	// 4690 "B91B"	"SLGFR"	"RRE" 14
			"MSGFR",	// 4700 "B91C"	"MSGFR"		"RRE"	 14
			"DSGFR",	// 4710 "B91D"	"DSGFR"		"RRE"	 14
			"KMAC",		// 4720 "B91E"	"KMAC"		"RRE"	 14
			"LRVR",		// 4730 "B91F"	"LRVR"		"RRE"	 14
			"CGR",		// 4740 "B920"	"CGR"		"RRE"	 14
			"CLGR",		// 4750 "B921"	"CLGR"		"RRE"	 14
			"STURG",	// 4760 "B925"	"STURG"		"RRE"	 14
			"LBR",		//		"B926"	"LBR"		"RRE"	 14 Z9-12
			"LHR",		//		"B927"	"LHR"		"RRE"	 14 Z9-13
			"PCKMO",	//		"B928"	"PCKMO"		"RE4"	 14 // RPI-1125 Z196
			"KMF",		//		"B92A"	"KMF"		"RRE"	 14 // RPI-1125 Z196
			"KMO",		//		"B92B"	"KMO"		"RRE"	 14 // RPI-1125 Z196
			"PCC",		//		"B92C"	"PCC"		"RE4"	 14 // RPI-1125 Z196
			"KMCTR",	//		"B92D"	"KMCTR"		"RRF2"	 34 // RPI-1125 Z196
			"KM",		// 4770	"B92E"	"KM"		"RRE"	 14
			"KMC",		// 4780	"B92F"	"KMC"		"RRE"	 14
			"CGFR",		// 4790	"B930"	"CGFR"		"RRE"	 14
			"CLGFR",	// 4800	"B931"	"CLGFR"		"RRE"	 14
			"KIMD",		// 4810	"B93E"	"KIMD"		"RRE"	 14
			"KLMD",		// 4820	"B93F"	"KLMD"		"RRE"	 14
			"CFDTR",	//		"B941"	"CFDTR"		"RRF3"	 30 // RPI-1125 Z196
			"CLGDTR",	//		"B942"	"CLGDTR"	"RRF3"	 30 // RPI-1125 Z196
			"CLFDTR",	//		"B943"	"CLFDTR"	"RRF3"	 30 // RPI-1125 Z196
			"BCTGR",	// 4830 "B946"	"BCTGR"		"RRE"	 14
			"CFXTR",	//		"B949"	"CFXTR"		"RRF3"	 30 // RPI-1125 Z196
			"CLGXTR",	//		"B94A"	"CLGXTR"	"RRF3"	 30 // RPI-1125 Z196
			"CLFXTR",	//		"B94B"	"CLFXTR"	"RRF3"	 30 // RPI-1125 Z196
			"CDFTR",	//		"B951"	"CDFTR"		"RRF3"	 30 // RPI-1125 Z196
			"CDLGTR",	//		"B952"	"CDLGTR"	"RRF3"	 30 // RPI-1125 Z196
			"CDLFTR",	//		"B953"	"CDLFTR"	"RRF3"	 30 // RPI-1125 Z196
			"CXFTR",	//		"B959"	"CXFTR"		"RRF3"	 30 // RPI-1125 Z196
			"CXLGTR",	//		"B95A"	"CXLGTR"	"RRF3"	 30 // RPI-1125 Z196
			"CXLFTR",	//		"B95B"	"CXLFTR"	"RRF3"	 30 // RPI-1125 Z196
			"CGRT",		//	 10	"B960"	"CGRT"	"RRF5" 39 // RPI-0817
			"CGRTE",	//	 20	"B9608"	"CGRTE"	"RRF6" 40 // RPI-0817
			"CGRTH",	//	 30	"B9602"	"CGRTH"	"RRF6" 40 // RPI-0817
			"CGRTL",	//	 40	"B9604"	"CGRTL"	"RRF6" 40 // RPI-0817
			"CGRTNE",	//	 50	"B9606"	"CGRTNE"	"RRF6" 40 // RPI-0817
			"CGRTNH",	//	 60	"B960C"	"CGRTNH"	"RRF6" 40 // RPI-0817
			"CGRTNL",	//	 70	"B960A"	"CGRTNL"	"RRF6" 40 // RPI-0817
			"CLGRT",	//	 10	"B961"	"CLGRT"	"RRF5" 39 // RPI-0817
			"CLGRTE",	//	 20	"B9618"	"CLGRTE"	"RRF6" 40 // RPI-0817
			"CLGRTH",	//	 30	"B9612"	"CLGRTH"	"RRF6" 40 // RPI-0817
			"CLGRTL",	//	 40	"B9614"	"CLGRTL"	"RRF6" 40 // RPI-0817
			"CLGRTNE",	//	 50	"B9616"	"CLGRTNE"	"RRF6" 40 // RPI-0817
			"CLGRTNH",	//	 60	"B961C"	"CLGRTNH"	"RRF6" 40 // RPI-0817
			"CLGRTNL",	//	 70	"B961A"	"CLGRTNL"	"RRF6" 40 // RPI-0817
			"CRT",		//	150 "B972"	"CRT"	"RRF5" 39 // RPI-0817
			"CRTE",		//	160 "B9728"	"CRTE"	"RRF6" 40 // RPI-0817
			"CRTH",		//	170 "B9722"	"CRTH"	"RRF6" 40 // RPI-0817
			"CRTL",		//	180 "B9724"	"CRTL"	"RRF6" 40 // RPI-0817
			"CRTNE",	//	190 "B9726"	"CRTNE"	"RRF6" 40 // RPI-0817
			"CRTNH",	//	200 "B972C"	"CRTNH"	"RRF6" 40 // RPI-0817
			"CRTNL",	//	210 "B972A"	"CRTNL"	"RRF6" 40 // RPI-0817
			"CLRT",		//	 80 "B973"	"CLRT"	"RRF5" 39 // RPI-0817
			"CLRTE",	//	 90 "B9738"	"CLRTE"	"RRF6" 40 // RPI-0817
			"CLRTH",	//	100 "B9732"	"CLRTH"	"RRF6" 40 // RPI-0817
			"CLRTL",	//	110 "B9734"	"CLRTL"	"RRF6" 40 // RPI-0817
			"CLRTNE",	//	120 "B9736"	"CLRTNE"	"RRF6" 40 // RPI-0817
			"CLRTNH",	//	130 "B973C"	"CLRTNH"	"RRF6" 40 // RPI-0817
			"CLRTNL",	//	140 "B973A"	"CLRTNL"	"RRF6" 40 // RPI-0817
			"NGR",		// 4840	"B980"	"NGR"	"RRE"	 14
			"OGR",		// 4850	"B981"	"OGR"	"RRE"	 14
			"XGR",		// 4860	"B982"	"XGR"	"RRE"	 14
			"FLOGR",	//		"B983"	"FLOGR"	"RRE"	 14 // Z9-14
			"LLGCR",	//		"B984"	"LLGCR"	"RRE"	 14 // Z9-15
			"LLGHR",	//		"B985"	"LLGHR"	"RRE"	 14 // Z9-16
			"MLGR",		// 4870	"B986"	"MLGR"	"RRE"	 14
			"DLGR",		// 4880	"B987"	"DLGR"	"RRE"	 14
			"ALCGR",	// 4890	"B988"	"ALCGR"	"RRE"	 14
			"SLBGR",	// 4900	"B989"	"SLBGR"	"RRE"	 14
			"CSPG",		// 4910	"B98A"	"CSPG"	"RRE"	 14
			"EPSW",		// 4920	"B98D"	"EPSW"	"RRE"	 14
			"IDTE",		// 4930	"B98E"	"IDTE"	"RRF2"	 34
			"TRTT",		// 4940	"B990"	"TRTT"	"RRE"	 14
			"TRTO",		// 4950	"B991"	"TRTO"	"RRE"	 14
			"TROT",		// 4960	"B992"	"TROT"	"RRE"	 14
			"TROO",		// 4970	"B993"	"TROO"	"RRE"	 14
			"LLCR",		//		"B994"	"LLCR"	"RRE"	 14 // Z9-17
			"LLHR",		//		"B995"	"LLHR"	"RRE"	 14 // Z9-18
			"MLR",		// 4980	"B996"	"MLR"	"RRE"	 14
			"DLR",		// 4990	"B997"	"DLR"	"RRE"	 14
			"ALCR",		// 5000	"B998"	"ALCR"	"RRE"	 14
			"SLBR",		// 5010	"B999"	"SLBR"	"RRE"	 14
			"EPAIR",	// 5020	"B99A"	"EPAIR"	"RRE"	 14
			"ESAIR",	// 5030	"B99B"	"ESAIR"	"RRE"	 14
			"ESEA",		// 5040	"B99D"	"ESEA"	"RRE"	 14
			"PTI",		// 5050	"B99E"	"PTI"	"RRE"	 14
			"SSAIR",	// 5060	"B99F"	"SSAIR"	"RRE"	 14
			"PTF",		//	 10	"B9A2"	"PTF"	"RRE"	 14 // RPI-0817
			"LPTEA",	//		"B9AA"	"LPTEA"	"RRE"	 14 Z9-19
			"RRBM",		//		"B9AE"	"RRBM"	"RRE"	 14 // RPI-1125 Z196 
			"PFMF",		//	 20 "B9AF"	"PFMF"	"RRF5"	 39 // RPI-0817
			"CU14",		// 5070 "B9B0"	"CU14"	"RRE"	 14
			"CU24",		// 5080 "B9B1"	"CU24"	"RRE"	 14
			"CU41",		// 5090 "B9B2"	"CU41"	"RRE"	 14
			"CU42",		// 5100 "B9B3"	"CU42"	"RRE"	 14
			"TRTRE",	// 30 "B9BD"	"TRTRE"	"RRF5"	 39 // RPI-0817
			"SRSTU",	// 5110 "B9BE"	"SRSTU"	"RRE"	 14
			"TRTE",		// 40 "B9BF"	"TRTE"	"RRF5" 39 // RPI-0817
			"AHHHR",	// "B9C8","AHHHR","RRF5"  39 // RPI-1125 Z196
			"SHHHR",	// "B9C9","SHHHR","RRF5"  39 // RPI-1125 Z196
			"ALHHHR",	// "B9CA","ALHHHR","RRF5" 39 // RPI-1125 Z196
			"SLHHHR",	// "B9CB","SLHHHR","RRF5" 39 // RPI-1125 Z196
			"CHHR",		// "B9CD","CHHR","RRE"     14 // RPI-1125 Z196
			"CLHHR",	// "B9CF","CLHHR","RRE"    14 // RPI-1125 Z196
			"AHHLR",	// "B9D8","AHHLR","RRF5 "  39 // RPI-1125 Z196
			"SHHLR",	// "B9D9","SHHLR","RRF5 "  39 // RPI-1125 Z196
			"ALHHLR",	// "B9DA","ALHHLR","RRF5 " 39 // RPI-1125 Z196
			"SLHHLR",	// "B9DB","SLHHLR","RRF5 " 39 // RPI-1125 Z196
			"CHLR",		// "B9DD","CHLR","RRE"     14 // RPI-1125 Z196
			"CLHLR",	// "B9DF","CLHLR","RRE"    14 // RPI-1125 Z196
			"POPCNT",	// 5115 "B9E1"	"POPCNT"	"RRE" 14 // RPI-1125
			"LOCGR",	// "B9E2","LOCGR","RRF5"   39 // RPI-1125 Z196
			"NGRK",		// "B9E4","NGRK","RRF5"    39 // RPI-1125 Z196
			"OGRK",		// "B9E6","OGRK","RRF5"    39 // RPI-1125 Z196
			"XGRK",		// "B9E7","XGRK","RRF5"    39 // RPI-1125 Z196
			"AGRK",		// "B9E8","AGRK","RRF5"    39 // RPI-1125 Z196
			"SGRK",		// "B9E9","SGRK","RRF5"    39 // RPI-1125 Z196
			"ALGRK",	// "B9EA","ALGRK","RRF5"   39 // RPI-1125 Z196
			"SLGRK",	// "B9EB","SLGRK","RRF5"   39 // RPI-1125 Z196
			"LOCR",		// "B9F2","LOCR","RRF5"    39 // RPI-1125 Z196
			"NRK",		// "B9F4","NRK","RRF5"     39 // RPI-1125 Z196
			"ORK",		// "B9F6","ORK","RRF5"     39 // RPI-1125 Z196
			"XRK",		// "B9F7","XRK","RRF5"     39 // RPI-1125 Z196
			"ARK",		// "B9F8","ARK","RRF5"     39 // RPI-1125 Z196
			"SRK",		// "B9F9","SRK","RRF5"     39 // RPI-1125 Z196
			"ALRK",		// "B9FA","ALRK","RRF5"    39 // RPI-1125 Z196
			"SLRK",		// "B9FB","SLRK","RRF5"    39 // RPI-1125 Z196
			"CS",		// 5120 "BA"	"CS"	"RS" 10
			"CDS",		// 5130 "BB"	"CDS"	"RS" 10
			"CLM",		// 5140 "BD"	"CLM"	"RS" 10
			"STCM",		// 5150 "BE"	"STCM"	"RS" 10
			"ICM",		// 5160 "BF"	"ICM"	"RS" 10
			"LARL",		// 5170 "C00"	"LARL"	"RIL" 16
			"LGFI",		//		"C01"	"LGFI"	"RIL" 16 Z9-20
			"BRCL",		// 5180 "C04"	"BRCL"	"RIL" 16
			"JLNOP",	// 5390 "C040"	"JLNOP"	"BLX" 33
			"BROL",		// 5400 "C041"	"BROL"	"BLX" 33
			"JLO",		// 5410 "C041"	"JLO"	"BLX" 33
			"BRHL",		// 5420 "C042"	"BRHL"	"BLX" 33
			"BRPL",		// 5430 "C042"	"BRPL"	"BLX" 33
			"JLH",		// 5440 "C042"	"JLH"	"BLX" 33
			"JLP",		// 5450 "C042"	"JLP"	"BLX" 33
			"BRLL",		// 5460 "C044"	"BRLL"	"BLX" 33
			"BRML",		// 5470 "C044"	"BRML"	"BLX" 33
			"JLL",		// 5480 "C044"	"JLL"	"BLX" 33
			"JLM",		// 5490 "C044"	"JLM"	"BLX" 33
			"BRNEL",	// 5500 "C047"	"BRNEL"	"BLX" 33
			"BRNZL",	// 5510 "C047"	"BRNZL"	"BLX" 33
			"JLNE",		// 5520 "C047"	"JLNE"	"BLX" 33
			"JLNZ",		// 5530 "C047"	"JLNZ"	"BLX" 33
			"BREL",		// 5540 "C048"	"BREL"	"BLX" 33
			"BRZL",		// 5550 "C048"	"BRZL"	"BLX" 33
			"JLE",		// 5560 "C048"	"JLE"	"BLX" 33
			"JLZ",		// 5570 "C048"	"JLZ"	"BLX" 33
			"BRNLL",	// 5580 "C04B"	"BRNLL"	"BLX" 33
			"BRNML",	// 5590 "C04B"	"BRNML"	"BLX" 33
			"JLNL",		// 5600 "C04B"	"JLNL"	"BLX" 33
			"JLNM",		// 5610 "C04B"	"JLNM"	"BLX" 33
			"BRNHL",	// 5620 "C04D"	"BRNHL"	"BLX" 33
			"BRNPL",	// 5630 "C04D"	"BRNPL"	"BLX" 33
			"JLNH",		// 5640 "C04D"	"JLNH"	"BLX" 33
			"JLNP",		// 5650 "C04D"	"JLNP"	"BLX" 33
			"BRNOL",	// 5660 "C04E"	"BRNOL"	"BLX" 33
			"JLNO",		// 5670 "C04E"	"JLNO"	"BLX" 33
			"BRUL",		// 5680 "C04F"	"BRUL"	"BLX" 33
			"JLU",		// 5690 "C04F"	"JLU"	"BLX" 33
			"BRASL",	// 5210 "C05"	"BRASL"	"RIL" 16
			"JASL",		// 5220 "C05"	"JASL"	"RIL" 16
			"XIHF",		//      "C06"	"XIHF"	"RIL" 16 Z9-21
			"XILF",		//      "C07"	"XILF"	"RIL" 16 Z9-22
			"IIHF",		//      "C08"	"IIHF"	"RIL" 16 Z9-23
			"IILF",		//      "C09"	"IILF"	"RIL" 16 Z9-24
			"NIHF",		//      "C0A"	"NIHF"	"RIL" 16 Z9-25
			"NILF",		//      "C0B"	"NILF"	"RIL" 16 Z9-26
			"OIHF",		//      "C0C"	"OIHF"	"RIL" 16 Z9-27
			"OILF",		//      "C0D"	"OILF"	"RIL" 16 Z9-28
			"LLIHF",	//      "C0E"	"LLIHF"	"RIL" 16 Z9-29
			"LLILF",	//      "C0F"	"LLILF"	"RIL" 16 Z9-30
			"MSGFI",	// 50 "C20"	"MSGFI"	"RIL" 16 // RPI-0817
			"MSFI",		// 60 "C21"	"MSFI"	"RIL" 16 // RPI-0817
			"SLGFI",	//      "C24"	"SLGFI"	"RIL" 16 Z9-31
			"SLFI",		//      "C25"	"SLFI"	"RIL" 16 Z9-32
			"AGFI",		//      "C28"	"AGFI"	"RIL" 16 Z9-33
			"AFI",		//      "C29"	"AFI"	"RIL" 16 Z9-34
			"ALGFI",	//      "C2A"	"ALGFI"	"RIL" 16 Z9-35
			"ALFI",		//      "C2B"	"ALFI"	"RIL" 16 Z9-36
			"CGFI",		//      "C2C"	"CGFI"	"RIL" 16 Z9-37
			"CFI",		//      "C2D"	"CFI"	"RIL" 16 Z9-38
			"CLGFI",	//		"C2E"	"CLGFI"	"RIL" 16 Z9-39
			"CLFI",		//		"C2F"	"CLFI"	"RIL" 16 Z9-40
			"LLHRL",	//	 70	"C42"	"LLHRL"	"RIL" 16 // RPI-0817
			"LGHRL",	//	 80	"C44"	"LGHRL"	"RIL" 16 // RPI-0817
			"LHRL",		//	 90	"C45"	"LHRL"	"RIL" 16 // RPI-0817
			"LLGHRL",	// 100	"C46"	"LLGHRL"	"RIL" 16 // RPI-0817
			"STHRL",	// 110	"C47"	"STHRL"	"RIL" 16 // RPI-0817
			"LGRL",		// 120	"C48"	"LGRL"	"RIL" 16 // RPI-0817
			"STGRL",	// 130	"C4B"	"STGRL"	"RIL" 16 // RPI-0817
			"LGFRL",	// 140	"C4C"	"LGFRL"	"RIL" 16 // RPI-0817
			"LRL",		// 150	"C4D"	"LRL"	"RIL" 16 // RPI-0817
			"LLGFRL",	// 160	"C4E"	"LLGFRL"	"RIL" 16 // RPI-0817
			"STRL",		// 170	"C4F"	"STRL"	"RIL" 16 // RPI-0817
			"EXRL",		// 180	"C60"	"EXRL"	"RIL" 16 // RPI-0817
			"PFDRL",	// 190	"C62"	"PFDRL"	"RIL" 16 // RPI-0817
			"CGHRL",	// 200	"C64"	"CGHRL"	"RIL" 16 // RPI-0817
			"CHRL",		// 210	"C65"	"CHRL"	"RIL" 16 // RPI-0817
			"CLGHRL",	// 220	"C66"	"CLGHRL"	"RIL" 16 // RPI-0817
			"CLHRL",	// 230	"C67"	"CLHRL"	"RIL" 16 // RPI-0817
			"CGRL",		// 240	"C68"	"CGRL"	"RIL" 16 // RPI-0817
			"CLGRL",	// 250	"C6A"	"CLGRL"	"RIL" 16 // RPI-0817
			"CGFRL",	// 260	"C6C"	"CGFRL"	"RIL" 16 // RPI-0817
			"CRL",		// 270	"C6D"	"CRL"	"RIL" 16 // RPI-0817
			"CLGFRL",	// 280	"C6E"	"CLGFRL"	"RIL" 16 // RPI-0817
			"CLRL",		// 290	"C6F"	"CLRL"	"RIL" 16 // RPI-0817
			"MVCOS",	//		"C80"	"MVCOS"	"SSF" 32 Z9-41 // RPI 606
			"ECTG",		//		"C81"	"ECTG"	"SSF" 32  // RPI 1013
			"CSST",		//		"C82"	"CSST"	"SSF" 32  // RPI 1013
			"LPD",		//		"C84","LPD","SSF2"  55 // RPI-1125 Z196
			"LPDG",		//		"C85","LPDG","SSF2" 55 // RPI-1125 Z196
			"BRCTH",	//		"CC6","BRCTH","RIL"  16 // RPI-1125 Z196
			"AIH",		//		"CC8","AIH","RIL"    16  // RPI-1125 Z196
			"ALSIH",	//		"CCA","ALSIH","RIL"  16  // RPI-1125 Z196
			"ALSIHN",	//		"CCB","ALSIHN","RIL" 16  // RPI-1125 Z196
			"CIH",		//		"CCD","CIH","RIL"    16  // RPI-1125 Z196
			"CLIH",		//		"CCF","CLIH","RIL"   16  // RPI-1125 Z196
			"TRTR",		// 5230 "D0"	"TRTR"	"SS" 17
			"MVN",		// 5240 "D1"	"MVN"	"SS" 17
			"MVC",		// 5250 "D2"	"MVC"	"SS" 17
			"MVZ",		// 5260 "D3"	"MVZ"	"SS" 17
			"NC",		// 5270 "D4"	"NC"	"SS" 17
			"CLC",		// 5280 "D5"	"CLC"	"SS" 17
			"OC",		// 5290 "D6"	"OC"	"SS" 17
			"XC",		// 5300 "D7"	"XC"	"SS" 17
			"MVCK",		// 5310 "D9"	"MVCK"	"SS" 17
			"MVCP",		// 5320 "DA"	"MVCP"	"SS" 17
			"MVCS",		// 5330 "DB"	"MVCS"	"SS" 17
			"TR",		// 5340 "DC"	"TR"	"SS" 17
			"TRT",		// 5350 "DD"	"TRT"	"SS" 17
			"ED",		// 5360 "DE"	"ED"	"SS" 17
			"EDMK",		// 5370 "DF"	"EDMK"	"SS" 17
			"XREAD",	// 5375 "E00"	"XREAD"	"RXSS" 38 RPI 812
			"XPRNT",	// 5375 "E02"	"XPRNT"	"RXSS" 38 RPI 812
			"XPNCH",	// 5375 "E04"	"XPNCH"	"RXSS" 38 RPI 812
			"XDUMP",	// 5375 "E06"	"XDUMP"	"RXSS" 38 RPI 812
			"XLIMD",	// 5375 "E08"	"XLIMD"	"RXSS" 38 RPI 812
			"XGET",		// 5375 "E0A"	"XGET"  "RXSS" 38 RPI 812
			"XPUT",		// 5375 "E0C"	"XPUT"  "RXSS" 38 RPI 812
			"PKU",		// 5380 "E1"	"PKU"	"RXSS" 17
			"UNPKU",	// 5390 "E2"	"UNPKU"	"SS" 17
			"LTG",		//      "E302"	"LTG"	"RXY" 18 Z9-42
			"LRAG",		// 5400 "E303"	"LRAG"	"RXY" 18
			"LG",		// 5410 "E304"	"LG"	"RXY" 18
			"CVBY",		// 5420 "E306"	"CVBY"	"RXY" 18
			"AG",		// 5430 "E308"	"AG"	"RXY" 18
			"SG",		// 5440 "E309"	"SG"	"RXY" 18
			"ALG",		// 5450 "E30A"	"ALG"	"RXY" 18
			"SLG",		// 5460 "E30B"	"SLG"	"RXY" 18
			"MSG",		// 5470 "E30C"	"MSG"	"RXY" 18
			"DSG",		// 5480 "E30D"	"DSG"	"RXY" 18
			"CVBG",		// 5490 "E30E"	"CVBG"	"RXY" 18
			"LRVG",		// 5500 "E30F"	"LRVG"	"RXY" 18
			"LT",		//      "E312"	"LT"	"RXY" 18 Z9-43
			"LRAY",		// 5510 "E313"	"LRAY"	"RXY" 18
			"LGF",		// 5520 "E314"	"LGF"	"RXY" 18
			"LGH",		// 5530 "E315"	"LGH"	"RXY" 18
			"LLGF",		// 5540 "E316"	"LLGF"	"RXY" 18
			"LLGT",		// 5550 "E317"	"LLGT"	"RXY" 18
			"AGF",		// 5560 "E318"	"AGF"	"RXY" 18
			"SGF",		// 5570 "E319"	"SGF"	"RXY" 18
			"ALGF",		// 5580 "E31A"	"ALGF"	"RXY" 18
			"SLGF",		// 5590 "E31B"	"SLGF"	"RXY" 18
			"MSGF",		// 5600 "E31C"	"MSGF"	"RXY" 18
			"DSGF",		// 5610 "E31D"	"DSGF"	"RXY" 18
			"LRV",		// 5620 "E31E"	"LRV"	"RXY" 18
			"LRVH",		// 5630 "E31F"	"LRVH"	"RXY" 18
			"CG",		// 5640 "E320"	"CG"	"RXY" 18
			"CLG",		// 5650 "E321"	"CLG"	"RXY" 18
			"STG",		// 5660 "E324"	"STG"	"RXY" 18
			"CVDY",		// 5670 "E326"	"CVDY"	"RXY" 18
			"CVDG",		// 5680 "E32E"	"CVDG"	"RXY" 18
			"STRVG",	// 5690 "E32F"	"STRVG"	"RXY" 18
			"CGF",		// 5700 "E330"	"CGF"	"RXY" 18
			"CLGF",		// 5710 "E331"	"CLGF"	"RXY" 18
			"LTGF",		// 310 "E332"	"LTGF"	"RXY" 18 // RPI-0817
			"CGH",		// 320 "E334"	"CGH"	"RXY" 18 // RPI-0817
			"PFD",		// 330 "E336"	"PFD"	"RXY" 18 // RPI-0817
			"STRV",		// 5720 "E33E"	"STRV"	"RXY" 18
			"STRVH",	// 5730 "E33F"	"STRVH"	"RXY" 18
			"BCTG",		// 5740 "E346"	"BCTG"	"RXY" 18
			"STY",		// 5750 "E350"	"STY"	"RXY" 18
			"MSY",		// 5760 "E351"	"MSY"	"RXY" 18
			"NY",		// 5770 "E354"	"NY"	"RXY" 18
			"CLY",		// 5780 "E355"	"CLY"	"RXY" 18
			"OY",		// 5790 "E356"	"OY"	"RXY" 18
			"XY",		// 5800 "E357"	"XY"	"RXY" 18
			"LY",		// 5810 "E358"	"LY"	"RXY" 18
			"CY",		// 5820 "E359"	"CY"	"RXY" 18
			"AY",		// 5830 "E35A"	"AY"	"RXY" 18
			"SY",		// 5840 "E35B"	"SY"	"RXY" 18
			"MFY",		// 340 "E35C"	"MFY"	"RXY" 18 // RPI-0817
			"ALY",		// 5850 "E35E"	"ALY"	"RXY" 18
			"SLY",		// 5860 "E35F"	"SLY"	"RXY" 18
			"STHY",		// 5870 "E370"	"STHY"	"RXY" 18
			"LAY",		// 5880 "E371"	"LAY"	"RXY" 18
			"STCY",		// 5890 "E372"	"STCY"	"RXY" 18
			"ICY",		// 5900 "E373"	"ICY"	"RXY" 18
			"LAEY",		// 350 "E375"	"LAEY"	"RXY" 18 // RPI-0817
			"LB",		// 5910 "E376"	"LB"	"RXY" 18
			"LGB",		// 5920 "E377"	"LGB"	"RXY" 18
			"LHY",		// 5930 "E378"	"LHY"	"RXY" 18
			"CHY",		// 5940 "E379"	"CHY"	"RXY" 18
			"AHY",		// 5950 "E37A"	"AHY"	"RXY" 18
			"SHY",		// 5960 "E37B"	"SHY"	"RXY" 18
			"MHY",		// 360 "E37C"	"MHY"	"RXY" 18 // RPI-0817
			"NG",		// 5970 "E380"	"NG"	"RXY" 18
			"OG",		// 5980 "E381"	"OG"	"RXY" 18
			"XG",		// 5990 "E382"	"XG"	"RXY" 18
			"MLG",		// 6000 "E386"	"MLG"	"RXY" 18
			"DLG",		// 6010 "E387"	"DLG"	"RXY" 18
			"ALCG",		// 6020 "E388"	"ALCG"	"RXY" 18
			"SLBG",		// 6030 "E389"	"SLBG"	"RXY" 18
			"STPQ",		// 6040 "E38E"	"STPQ"	"RXY" 18
			"LPQ",		// 6050 "E38F"	"LPQ"	"RXY" 18
			"LLGC",		// 6060 "E390"	"LLGC"	"RXY" 18
			"LLGH",		// 6070 "E391"	"LLGH"	"RXY" 18
			"LLC",		//      "E394"	"LLC"	"RXY" 18 Z9-44
			"LLH",		//      "E395"	"LLH"	"RXY" 18 Z9-45
			"ML",		// 6080 "E396"	"ML"	"RXY" 18
			"DL",		// 6090 "E397"	"DL"	"RXY" 18
			"ALC",		// 6100 "E398"	"ALC"	"RXY" 18
			"SLB",		// 6110 "E399"	"SLB"	"RXY" 18
			"LBH",		//      "E3C0","LBH","RXY"   18  // RPI-1125 Z196
			"LLCH",		// "E3C2","LLCH","RXY"  18  // RPI-1125 Z196
			"STCH",		// "E3C3","STCH","RXY"  18  // RPI-1125 Z196
			"LHH",		// "E3C4","LHH","RXY"   18  // RPI-1125 Z196
			"LLHH",		// "E3C6","LLHH","RXY"  18  // RPI-1125 Z196
			"STHH",		// "E3C7","STHH","RXY"  18  // RPI-1125 Z196
			"LFH",		// "E3CA","LFH","RXY"   18  // RPI-1125 Z196
			"STFH",		// "E3CB","STFH","RXY"  18  // RPI-1125 Z196
			"CHF",		// "E3CD","CHF","RXY"   18  // RPI-1125 Z196
			"CLHF",		// "E3CF","CLHF","RXY"  18  // RPI-1125 Z196
			"LASP",		// 6120 "E500"	"LASP"	"SSE" 19
			"TPROT",	// 6130 "E501"	"TPROT"	"SSE" 19
			"STRAG",	// 6140 "E502"	"STRAG"	"SSE" 19
			"MVCSK",	// 6150 "E50E"	"MVCSK"	"SSE" 19
			"MVCDK",	// 6160 "E50F"	"MVCDK"	"SSE" 19
			"MVHHI",	// 370 "E544"	"MVHHI"	"SIL" 51 // RPI-0817
			"MVGHI",	// 380 "E548"	"MVGHI"	"SIL" 51 // RPI-0817
			"MVHI",		// 390 "E54C"	"MVHI"	"SIL" 51 // RPI-0817
			"CHHSI",	// 400 "E554"	"CHHSI"	"SIL" 51 // RPI-0817
			"CLHHSI",	// 410 "E555"	"CLHHSI"	"SIL" 51 // RPI-0817
			"CGHSI",	// 420 "E558"	"CGHSI"	"SIL" 51 // RPI-0817
			"CLGHSI",	// 430 "E559"	"CLGHSI"	"SIL" 51 // RPI-0817
			"CHSI",		// 440 "E55C"	"CHSI"	"SIL" 51 // RPI-0817
			"CLFHSI",	// 450 "E55D"	"CLFHSI"	"SIL" 51 // RPI-0817
			"MVCIN",	// 6170 "E8"	"MVCIN"	"SS" 17
			"PKA",		// 6180 "E9"	"PKA"	"SS" 31
			"UNPKA",	// 6190 "EA"	"UNPKA"	"SS" 17
			"LMG",		// 6200 "EB04"	"LMG"	"RSY" 20
			"SRAG",		// 6210 "EB0A"	"SRAG"	"RSY" 20
			"SLAG",		// 6220 "EB0B"	"SLAG"	"RSY" 20
			"SRLG",		// 6230 "EB0C"	"SRLG"	"RSY" 20
			"SLLG",		// 6240 "EB0D"	"SLLG"	"RSY" 20
			"TRACG",	// 6250 "EB0F"	"TRACG"	"RSY" 20
			"CSY",		// 6260 "EB14"	"CSY"	"RSY" 20
			"RLLG",		// 6270 "EB1C"	"RLLG"	"RSY" 20
			"RLL",		// 6280 "EB1D"	"RLL"	"RSY" 20
			"CLMH",		// 6290 "EB20"	"CLMH"	"RSY" 20
			"CLMY",		// 6300 "EB21"	"CLMY"	"RSY" 20
			"STMG",		// 6310 "EB24"	"STMG"	"RSY" 20
			"STCTG",	// 6320 "EB25"	"STCTG"	"RSY" 20
			"STMH",		// 6330 "EB26"	"STMH"	"RSY" 20
			"STCMH",	// 6340 "EB2C"	"STCMH"	"RSY" 20
			"STCMY",	// 6350 "EB2D"	"STCMY"	"RSY" 20
			"LCTLG",	// 6360 "EB2F"	"LCTLG"	"RSY" 20
			"CSG",		// 6370 "EB30"	"CSG"	"RSY" 20
			"CDSY",		// 6380 "EB31"	"CDSY"	"RSY" 20
			"CDSG",		// 6390 "EB3E"	"CDSG"	"RSY" 20
			"BXHG",		// 6400 "EB44"	"BXHG"	"RSY" 20
			"BXLEG",	// 6410 "EB45"	"BXLEG"	"RSY" 20
			"ECAG",		// 460 "EB4C"	"ECAG"	"RSY" 20 // RPI-0817
			"TMY",		// 6420 "EB51"	"TMY"	"SIY" 21
			"MVIY",		// 6430 "EB52"	"MVIY"	"SIY" 21
			"NIY",		// 6440 "EB54"	"NIY"	"SIY" 21
			"CLIY",		// 6450 "EB55"	"CLIY"	"SIY" 21
			"OIY",		// 6460 "EB56"	"OIY"	"SIY" 21
			"XIY",		// 6470 "EB57"	"XIY"	"SIY" 21
			"ASI",		// 470 "EB6A"	"ASI"	"SIY" 21 // RPI-0817
			"ALSI",		// 480 "EB6E"	"ALSI"	"SIY" 21 // RPI-0817
			"AGSI",		// 490 "EB7A"	"AGSI"	"SIY" 21 // RPI-0817
			"ALGSI",	// 500 "EB7E"	"ALGSI"	"SIY" 21 // RPI-0817
			"ICMH",		// 6480 "EB80"	"ICMH"	"RSY" 20
			"ICMY",		// 6490 "EB81"	"ICMY"	"RSY" 20
			"MVCLU",	// 6500 "EB8E"	"MVCLU"	"RSY" 20
			"CLCLU",	// 6510 "EB8F"	"CLCLU"	"RSY" 20
			"STMY",		// 6520 "EB90"	"STMY"	"RSY" 20
			"LMH",		// 6530 "EB96"	"LMH"	"RSY" 20
			"LMY",		// 6540 "EB98"	"LMY"	"RSY" 20
			"LAMY",		// 6550 "EB9A"	"LAMY"	"RSY" 20
			"STAMY",	// 6560 "EB9B"	"STAMY"	"RSY" 20
			"TP",		// 6570 "EBC0"	"TP"	"RSL" 22
			"SRAK",		//  "EBDC","SRAK","RSY  "  20 // RPI-1125 Z196
			"SLAK",		//  "EBDD","SLAK","RSY  "  20 // RPI-1125 Z196
			"SRLK",		//  "EBDE","SRLK","RSY  "  20 // RPI-1125 Z196
			"SLLK",		//  "EBDF","SLLK","RSY  "  20 // RPI-1125 Z196
			"LOCG",		//  "EBE2","LOCG","RSY2 "  20 // RPI-1125 Z196
			"STOCG",	//  "EBE3","STOCG","RSY2 " 20 // RPI-1125 Z196
			"LANG",		//  "EBE4","LANG","RSY  "  20 // RPI-1125 Z196
			"LAOG",		//  "EBE6","LAOG","RSY  "  20 // RPI-1125 Z196
			"LAXG",		//  "EBE7","LAXG","RSY  "  20 // RPI-1125 Z196
			"LAAG",		//  "EBE8","LAAG","RSY  "  20 // RPI-1125 Z196
			"LAALG",	//  "EBEA","LAALG","RSY  " 20 // RPI-1125 Z196
			"LOC",		//  "EBF2","LOC","RSY2 "   20 // RPI-1125 Z196
			"STOC",		//  "EBF3","STOC","RSY2 "  20 // RPI-1125 Z196
			"LAN",		//  "EBF4","LAN","RSY  "   20 // RPI-1125 Z196
			"LAO",		//  "EBF6","LAO","RSY  "   20 // RPI-1125 Z196
			"LAX",		//  "EBF7","LAX","RSY  "   20 // RPI-1125 Z196
			"LAA",		//  "EBF8","LAA","RSY  "   20 // RPI-1125 Z196
			"LAAL",		//  "EBFA","LAAL","RSY  "  20 // RPI-1125 Z196
			"BRXHG",	// 6580 "EC44"	"BRXHG"	"RIE" 23
			"JXHG",		// 6590 "EC44"	"JXHG"	"RIE" 23
			"BRXLG",	// 6600 "EC45"	"BRXLG"	"RIE" 23
			"JXLEG",	// 6610 "EC45"	"JXLEG"	"RIE" 23    
			"RISBLG",	// "EC51","RISBLG","RIE8"  52 // RPI-1125 Z196
			"LLHFR",	// 'EC51$003132','LOAD (lOW  && HIGH) RISBLGZ','LLHFR','RIE8',52  RPI 1164
			"LLHLHR",	// 'EC51$163132','LOAD LOG HW (lOW  && HIGH) RISBLGZ','LLHLHR','RIE8',52  RPI 1164
			"LLCLHR",	// 'EC51$243132','LOAD LOG CH (lOW  && HIGH) RISBLGZ','LLCLHR','RIE8',52  RPI 1164
			"RISBLGZ",	// "EC51Z","RISBLGZ","RIE8"  52 // RPI-1125 Z196  RPI 1164
			"RNSBG",	// 510 "EC54"	"RNSBG"	"RIE8" 52 // RPI-0817
			"NHHR",		// 'EC54$003100','AND HIGH (HIGH && HIGH) RNSBG','NHHR','RIE8',52  RPI 1164
			"NHLR",		// 'EC54$003132','AND HIGH (HIGH && LOW ) RNSBG','NHLR','RIE8',52  RPI 1164
			"NLHR",		// 'EC54$326332','AND HIGH (lOW  && HIGH) RNSBG','NLHR','RIE8',52  RPI 1164
			"RNSBGT",	// 520 "EC54T"	"RNSBGT"	"RIE8" 52 // RPI-0817
			"RISBG",	// 530 "EC55"	"RISBG"	"RIE8" 52 // RPI-0817
			"RISBGZ",	// 540 "EC55Z"	"RISBGZ"	"RIE8" 52 // RPI-0817
			"ROSBG",	// 550 "EC56"	"ROSBG"	"RIE8" 52 // RPI-0817
			"OHHR",		// 'EC56$003100','OR  HIGH (HIGH && HIGH) ROSBG','OHHR','RIE8',52  RPI 1164
			"OHLR",		// 'EC56$003132','OR  HIGH (HIGH && LOW ) ROSBG','OHLR','RIE8',52  RPI 1164
			"OLHR",		// 'EC56$326332','OR  HIGH (lOW  && HIGH) ROSBG','OLHR','RIE8',52  RPI 1164
			"ROSBGT",	// 560 "EC56T"	"ROSBGT"	"RIE8" 52 // RPI-0817
			"RXSBG",	// 570 "EC57"	"RXSBG"	"RIE8" 52 // RPI-0817
			"XHHR",		// 'EC57$003100','XOR HIGH (HIGH && HIGH) RXSBG','XHHR','RIE8',52  RPI 1164
			"XHLR",		// 'EC57$003132','XOR HIGH (HIGH && LOW ) RXSBG','XHLR','RIE8',52  RPI 1164
			"XLHR",		// 'EC57$326332','AOR HIGH (lOW  && HIGH) RXSBG','XLHR','RIE8',52  RPI 1164	
			"RXSBGT",	// 580 "EC57T"	"RXSBGT"	"RIE8" 52 // RPI-0817
			"RISBHG",	// "EC5D","RISBHG","RIE8"  52 // RPI-1125 Z196
			"LHHR",		// 'EC5D$003100','LOAD (HIGH && HIGH) RISBHGZ','LHHR','RIE8',52  RPI 1164
			"LHLR",		// 'EC5D$003132','LOAD (HIGH && LOW ) RISBHGZ','LHLR','RIE8',52  RPI 1164
			"LLHHHR",	// 'EC5D$163100','LOAD LOG HW (HIGH && HIGH) RISBHGZ','LLHHHR','RIE8',52  RPI 1164
			"LLHHLR",	// 'EC5D$163132','LOAD LOG HW (HIGH && LOW ) RISBHGZ','LLHHLR','RIE8',52  RPI 1164
			"LLCHHR",	// 'EC5D$243100','LOAD LOG CH (HIGH && HIGH) RISBHGZ','LLCHHR','RIE8',52  RPI 1164
			"LLCHLR",	// 'EC5D$243132','LOAD LOG CH (HIGH && LOW ) RISBHGZ','LLCHLR','RIE8',52  RPI 1164
			"RISBHGZ",	// "EC5DZ","RISBHGZ","RIE8"  52 // RPI-1125 Z196  RPI 1164
			"CGRJ",		// 10 "EC64"	"CGRJ"	"RIE6" 49 // RPI-0817
			"CGRJE",	// 20 "EC648"	"CGRJE"	"RIE7" 50 // RPI-0817
			"CGRJH",	// 30 "EC642"	"CGRJH"	"RIE7" 50 // RPI-0817
			"CGRJL",	// 40 "EC644"	"CGRJL"	"RIE7" 50 // RPI-0817
			"CGRJNE",	// 50 "EC646"	"CGRJNE"	"RIE7" 50 // RPI-0817
			"CGRJNH",	// 60 "EC64C"	"CGRJNH"	"RIE7" 50 // RPI-0817
			"CGRJNL",	// 70 "EC64A"	"CGRJNL"	"RIE7" 50 // RPI-0817
			"CLGRJ",	// 80 "EC65"	"CLGRJ"	"RIE6" 49 // RPI-0817
			"CLGRJE",	// 90 "EC658"	"CLGRJE"	"RIE7" 50 // RPI-0817
			"CLGRJH",	// 100 "EC652"	"CLGRJH"	"RIE7" 50 // RPI-0817
			"CLGRJL",	// 110 "EC654"	"CLGRJL"	"RIE7" 50 // RPI-0817
			"CLGRJNE",	// 120 "EC656"	"CLGRJNE"	"RIE7" 50 // RPI-0817
			"CLGRJNH",	// 130 "EC65C"	"CLGRJNH"	"RIE7" 50 // RPI-0817
			"CLGRJNL",	// 140 "EC65A"	"CLGRJNL"	"RIE7" 50 // RPI-0817		       
			"CGIT",		// 1010 "EC70"	"CGIT"	"RIE2" 41 // RPI-0817
			"CGITE",	// 1020 "EC708"	"CGITE"	"RIE3" 42 // RPI-0817
			"CGITH",	// 1030 "EC702"	"CGITH"	"RIE3" 42 // RPI-0817
			"CGITL",	// 1040 "EC704"	"CGITL"	"RIE3" 42 // RPI-0817
			"CGITNE",	// 1050 "EC706"	"CGITNE"	"RIE3" 42 // RPI-0817
			"CGITNH",	// 1060 "EC70C"	"CGITNH"	"RIE3" 42 // RPI-0817
			"CGITNL",	// 1070 "EC70A"	"CGITNL"	"RIE3" 42 // RPI-0817
			"CLGIT",	// 150 "EC71"	"CLGIT"	"RIE2" 41 // RPI-0817
			"CLGITE",	// 160 "EC718"	"CLGITE"	"RIE3" 42 // RPI-0817
			"CLGITH",	// 170 "EC712"	"CLGITH"	"RIE3" 42 // RPI-0817
			"CLGITL",	// 180 "EC714"	"CLGITL"	"RIE3" 42 // RPI-0817
			"CLGITNE",	// 190 "EC716"	"CLGITNE"	"RIE3" 42 // RPI-0817
			"CLGITNH",	// 200 "EC71C"	"CLGITNH"	"RIE3" 42 // RPI-0817
			"CLGITNL",	// 210 "EC71A"	"CLGITNL"	"RIE3" 42 // RPI-0817
			"CIT",		// 1150 "EC72"	"CIT"	"RIE2" 41 // RPI-0817
			"CITE",		// 1160 "EC728"	"CITE"	"RIE3" 42 // RPI-0817
			"CITH",		// 1170 "EC722"	"CITH"	"RIE3" 42 // RPI-0817
			"CITL",		// 1180 "EC724"	"CITL"	"RIE3" 42 // RPI-0817
			"CITNE",	// 1190 "EC726"	"CITNE"	"RIE3" 42 // RPI-0817
			"CITNH",	// 1200 "EC72C"	"CITNH"	"RIE3" 42 // RPI-0817
			"CITNL",	// 1210 "EC72A"	"CITNL"	"RIE3" 42 // RPI-0817
			"CLFIT",	// 220 "EC73"	"CLFIT"	"RIE2" 41 // RPI-0817
			"CLFITE",	// 230 "EC738"	"CLFITE"	"RIE3" 42 // RPI-0817
			"CLFITH",	// 240 "EC732"	"CLFITH"	"RIE3" 42 // RPI-0817
			"CLFITL",	// 250 "EC734"	"CLFITL"	"RIE3" 42 // RPI-0817
			"CLFITNE",	// 260 "EC736"	"CLFITNE"	"RIE3" 42 // RPI-0817
			"CLFITNH",	// 270 "EC73C"	"CLFITNH"	"RIE3" 42 // RPI-0817
			"CLFITNL",	// 280 "EC73A"	"CLFITNL"	"RIE3" 42 // RPI-0817
			"CRJ",		// 150 "EC76"	"CRJ"	"RIE6" 49 // RPI-0817
			"CRJE",		// 160 "EC768"	"CRJE"	"RIE7" 50 // RPI-0817
			"CRJH",		// 170 "EC762"	"CRJH"	"RIE7" 50 // RPI-0817
			"CRJL",		// 180 "EC764"	"CRJL"	"RIE7" 50 // RPI-0817
			"CRJNE",	// 190 "EC766"	"CRJNE"	"RIE7" 50 // RPI-0817
			"CRJNH",	// 200 "EC76C"	"CRJNH"	"RIE7" 50 // RPI-0817
			"CRJNL",	// 210 "EC76A"	"CRJNL"	"RIE7" 50 // RPI-0817
			"CLRJ",		// 220 "EC77"	"CLRJ"	"RIE6" 49 // RPI-0817
			"CLRJE",	// 230 "EC778"	"CLRJE"	"RIE7" 50 // RPI-0817
			"CLRJH",	// 240 "EC772"	"CLRJH"	"RIE7" 50 // RPI-0817
			"CLRJL",	// 250 "EC774"	"CLRJL"	"RIE7" 50 // RPI-0817
			"CLRJNE",	// 260 "EC776"	"CLRJNE"	"RIE7" 50 // RPI-0817
			"CLRJNH",	// 270 "EC77C"	"CLRJNH"	"RIE7" 50 // RPI-0817
			"CLRJNL",	// 280 "EC77A"	"CLRJNL"	"RIE7" 50 // RPI-0817
			"CGIJ",		// 290 "EC7C"	"CGIJ"	"RIE4" 43 // RPI-0817
			"CGIJE",	// 300 "EC7C8"	"CGIJE"	"RIE5" 44 // RPI-0817
			"CGIJH",	// 310 "EC7C2"	"CGIJH"	"RIE5" 44 // RPI-0817
			"CGIJL",	// 320 "EC7C4"	"CGIJL"	"RIE5" 44 // RPI-0817
			"CGIJNE",	// 330 "EC7C6"	"CGIJNE"	"RIE5" 44 // RPI-0817
			"CGIJNH",	// 340 "EC7CC"	"CGIJNH"	"RIE5" 44 // RPI-0817
			"CGIJNL",	// 350 "EC7CA"	"CGIJNL"	"RIE5" 44 // RPI-0817
			"CLGIJ",	// 360 "EC7D"	"CLGIJ"	"RIE4" 43 // RPI-0817
			"CLGIJE",	// 370 "EC7D8"	"CLGIJE"	"RIE5" 44 // RPI-0817
			"CLGIJH",	// 380 "EC7D2"	"CLGIJH"	"RIE5" 44 // RPI-0817
			"CLGIJL",	// 390 "EC7D4"	"CLGIJL"	"RIE5" 44 // RPI-0817
			"CLGIJNE",	// 400 "EC7D6"	"CLGIJNE"	"RIE5" 44 // RPI-0817
			"CLGIJNH",	// 410 "EC7DC"	"CLGIJNH"	"RIE5" 44 // RPI-0817
			"CLGIJNL",	// 420 "EC7DA"	"CLGIJNL"	"RIE5" 44 // RPI-0817
			"CIJ",		// 430 "EC7E"	"CIJ"	"RIE4" 43 // RPI-0817
			"CIJE",		// 440 "EC7E8"	"CIJE"	"RIE5" 44 // RPI-0817
			"CIJH",		// 450 "EC7E2"	"CIJH"	"RIE5" 44 // RPI-0817
			"CIJL",		// 460 "EC7E4"	"CIJL"	"RIE5" 44 // RPI-0817
			"CIJNE",	// 470 "EC7E6"	"CIJNE"	"RIE5" 44 // RPI-0817
			"CIJNH",	// 480 "EC7EC"	"CIJNH"	"RIE5" 44 // RPI-0817
			"CIJNL",	// 490 "EC7EA"	"CIJNL"	"RIE5" 44 // RPI-0817
			"CLIJ",		// 500 "EC7F"	"CLIJ"	"RIE4" 43 // RPI-0817
			"CLIJE",	// 510 "EC7F8"	"CLIJE"	"RIE5" 44 // RPI-0817
			"CLIJH",	// 520 "EC7F2"	"CLIJH"	"RIE5" 44 // RPI-0817
			"CLIJL",	// 530 "EC7F4"	"CLIJL"	"RIE5" 44 // RPI-0817
			"CLIJNE",	// 540 "EC7F6"	"CLIJNE"	"RIE5" 44 // RPI-0817
			"CLIJNH",	// 550 "EC7FC"	"CLIJNH"	"RIE5" 44 // RPI-0817
			"CLIJNL",	// 560 "EC7FA"	"CLIJNL"	"RIE5" 44 // RPI-0817
			"AHIK",		//		"ECD8","AHIK","RIE9"    57 // RPI-1125 Z196
			"AGHIK",	//		"ECD9","AGHIK","RIE9"   57 // RPI-1125 Z196
			"ALHSIK",	//		"ECDA","ALHSIK","RIE9"  57 // RPI-1125 Z196
			"ALGHSIK",	//		"ECDB","ALGHSIK","RIE9" 57 // RPI-1125 Z196
			"CGRB",		//	570	"ECE4"	"CGRB"	"RRS1" 45 // RPI-0817
			"CGRBE",	//	580	"ECE48"	"CGRBE"	"RRS2" 46 // RPI-0817
			"CGRBH",	//	590	"ECE42"	"CGRBH"	"RRS2" 46 // RPI-0817
			"CGRBL",	//	600	"ECE44"	"CGRBL"	"RRS2" 46 // RPI-0817
			"CGRBNE",	//	610	"ECE46"	"CGRBNE"	"RRS2" 46 // RPI-0817
			"CGRBNH",	//	620	"ECE4C"	"CGRBNH"	"RRS2" 46 // RPI-0817
			"CGRBNL",	//	630	"ECE4A"	"CGRBNL"	"RRS2" 46 // RPI-0817
			"CLGRB",	//	640	"ECE5"	"CLGRB"	"RRS1" 45 // RPI-0817
			"CLGRBE",	//	650	"ECE58"	"CLGRBE"	"RRS2" 46 // RPI-0817
			"CLGRBH",	//	660	"ECE52"	"CLGRBH"	"RRS2" 46 // RPI-0817
			"CLGRBL",	//	670	"ECE54"	"CLGRBL"	"RRS2" 46 // RPI-0817
			"CLGRBNE",	//	680	"ECE56"	"CLGRBNE"	"RRS2" 46 // RPI-0817
			"CLGRBNH",	//	690	"ECE5C"	"CLGRBNH"	"RRS2" 46 // RPI-0817
			"CLGRBNL",	// 700 "ECE5A"	"CLGRBNL"	"RRS2" 46 // RPI-0817
			"CRB",		// 710 "ECF6"	"CRB"	"RRS1" 45 // RPI-0817
			"CRBE",		// 720 "ECF68"	"CRBE"	"RRS2" 46 // RPI-0817
			"CRBH",		// 730 "ECF62"	"CRBH"	"RRS2" 46 // RPI-0817
			"CRBL",		// 740 "ECF64"	"CRBL"	"RRS2" 46 // RPI-0817
			"CRBNE",	// 750 "ECF66"	"CRBNE"	"RRS2" 45 // RPI-0817
			"CRBNH",	// 760 "ECF6C"	"CRBNH"	"RRS2" 46 // RPI-0817
			"CRBNL",	// 770 "ECF6A"	"CRBNL"	"RRS2" 46 // RPI-0817
			"CLRB",		// 780 "ECF7"	"CLRB"	"RRS1" 45 // RPI-0817
			"CLRBE",	// 790 "ECF78"	"CLRBE"	"RRS2" 46 // RPI-0817
			"CLRBH",	// 800 "ECF72"	"CLRBH"	"RRS2" 46 // RPI-0817
			"CLRBL",	// 810 "ECF74"	"CLRBL"	"RRS2" 46 // RPI-0817
			"CLRBNE",	// 820 "ECF76"	"CLRBNE"	"RRS2" 46 // RPI-0817
			"CLRBNH",	// 830 "ECF7C"	"CLRBNH"	"RRS2" 46 // RPI-0817
			"CLRBNL",	// 840 "ECF7A"	"CLRBNL"	"RRS2" 46 // RPI-0817
			"CGIB",		// 850 "ECFC"	"CGIB"	"RRS3" 47 // RPI-0817
			"CGIBE",	// 860 "ECFC8"	"CGIBE"	"RRS4" 48 // RPI-0817
			"CGIBH",	// 870 "ECFC2"	"CGIBH"	"RRS4" 48 // RPI-0817
			"CGIBL",	// 880 "ECFC4"	"CGIBL"	"RRS4" 48 // RPI-0817
			"CGIBNE",	// 890 "ECFC6"	"CGIBNE"	"RRS4" 48 // RPI-0817
			"CGIBNH",	// 900 "ECFCC"	"CGIBNH"	"RRS4" 48 // RPI-0817
			"CGIBNL",	// 910 "ECFCA"	"CGIBNL"	"RRS4" 48 // RPI-0817
			"CLGIB",	// 920 "ECFD"	"CLGIB"	"RRS3" 47 // RPI-0817
			"CLGIBE",	// 930 "ECFD8"	"CLGIBE"	"RRS4" 48 // RPI-0817
			"CLGIBH",	// 940 "ECFD2"	"CLGIBH"	"RRS4" 48 // RPI-0817
			"CLGIBL",	// 950 "ECFD4"	"CLGIBL"	"RRS4" 48 // RPI-0817
			"CLGIBNE",	// 960 "ECFD6"	"CLGIBNE"	"RRS4" 48 // RPI-0817
			"CLGIBNH",	// 970 "ECFDC"	"CLGIBNH"	"RRS4" 48 // RPI-0817
			"CLGIBNL",	// 980 "ECFDA"	"CLGIBNL"	"RRS4" 48 // RPI-0817
			"CIB",		// 990 "ECFE"	"CIB"	"RRS3" 47 // RPI-0817
			"CIBE",		// 1000 "ECFE8"	"CIBE"	"RRS4" 48 // RPI-0817
			"CIBH",		// 1010 "ECFE2"	"CIBH"	"RRS4" 48 // RPI-0817
			"CIBL",		// 1020 "ECFE4"	"CIBL"	"RRS4" 48 // RPI-0817
			"CIBNE",	// 1030 "ECFE6"	"CIBNE"	"RRS4" 48 // RPI-0817
			"CIBNH",	// 1040 "ECFEC"	"CIBNH"	"RRS4" 48 // RPI-0817
			"CIBNL",	// 1050 "ECFEA"	"CIBNL"	"RRS4" 48 // RPI-0817
			"CLIB",		// 1060 "ECFF"	"CLIB"	"RRS3" 47 // RPI-0817
			"CLIBE",	// 1070 "ECFF8"	"CLIBE"	"RRS4" 48 // RPI-0817
			"CLIBH",	// 1080 "ECFF2"	"CLIBH"	"RRS4" 48 // RPI-0817
			"CLIBL",	// 1090 "ECFF4"	"CLIBL"	"RRS4" 48 // RPI-0817
			"CLIBNE",	// 1100 "ECFF6"	"CLIBNE"	"RRS4" 48 // RPI-0817
			"CLIBNH",	// 1110 "ECFFC"	"CLIBNH"	"RRS4" 48 // RPI-0817
			"CLIBNL",	// 1120 "ECFFA"	"CLIBNL"	"RRS4" 48 // RPI-0817
			"LDEB",		// 6620 "ED04"	"LDEB"	"RXE"	 24
			"LXDB",		// 6630 "ED05"	"LXDB"	"RXE"	 24
			"LXEB",		// 6640 "ED06"	"LXEB"	"RXE"	 24
			"MXDB",		// 6650 "ED07"	"MXDB"	"RXE"	 24
			"KEB",		// 6660 "ED08"	"KEB"	"RXE"	 24
			"CEB",		// 6670 "ED09"	"CEB"	"RXE"	 24
			"AEB",		// 6680 "ED0A"	"AEB"	"RXE"	 24
			"SEB",		// 6690 "ED0B"	"SEB"	"RXE"	 24
			"MDEB",		// 6700 "ED0C"	"MDEB"	"RXE"	 24
			"DEB",		// 6710 "ED0D"	"DEB"	"RXE"	 24
			"MAEB",		// 6720 "ED0E"	"MAEB"	"RXF"	 25
			"MSEB",		// 6730 "ED0F"	"MSEB"	"RXF"	 25
			"TCEB",		// 6740 "ED10"	"TCEB"	"RXE"	 24
			"TCDB",		// 6750 "ED11"	"TCDB"	"RXE"	 24
			"TCXB",		// 6760 "ED12"	"TCXB"	"RXE"	 24
			"SQEB",		// 6770 "ED14"	"SQEB"	"RXE"	 24
			"SQDB",		// 6780 "ED15"	"SQDB"	"RXE"	 24
			"MEEB",		// 6790 "ED17"	"MEEB"	"RXE"	 24
			"KDB",		// 6800 "ED18"	"KDB"	"RXE"	 24
			"CDB",		// 6810 "ED19"	"CDB"	"RXE"	 24
			"ADB",		// 6820 "ED1A"	"ADB"	"RXE"	 24
			"SDB",		// 6830 "ED1B"	"SDB"	"RXE"	 24
			"MDB",		// 6840 "ED1C"	"MDB"	"RXE"	 24
			"DDB",		// 6850 "ED1D"	"DDB"	"RXE"	 24
			"MADB",		// 6860 "ED1E"	"MADB"	"RXF"	 25
			"MSDB",		// 6870 "ED1F"	"MSDB"	"RXF"	 25
			"LDE",		// 6880 "ED24"	"LDE"	"RXE"	 24
			"LXD",		// 6890 "ED25"	"LXD"	"RXE"	 24
			"LXE",		// 6900 "ED26"	"LXE"	"RXE"	 24
			"MAE",		// 6910 "ED2E"	"MAE"	"RXF"	 25
			"MSE",		// 6920 "ED2F"	"MSE"	"RXF"	 25
			"SQE",		// 6930 "ED34"	"SQE"	"RXE"	 24
			"SQD",		// 6940 "ED35"	"SQD"	"RXE"	 24
			"MEE",		// 6950	"ED37"	"MEE"	"RXE"	 24
			"MAYL",		//		"ED38"	"MAYL"	"RXF"	 25 Z9-46
			"MYL",		//		"ED39"	"MYL"  "RXF"	 25 Z9-47
			"MAY",		//		"ED3A"	"MAY"	"RXF"	 25 Z9-48
			"MY",		//		"ED3B"	"MY"	"RXF"	 25 Z9-49 RPI 298
			"MAYH",		//		"ED3C"	"MAYH"	"RXF"	 25 Z9-50
			"MYH",		//		"ED3D"	"MYH"	"RXF"	 25 Z9-51 RPI 298
			"MAD",		// 6960	"ED3E"	"MAD"	"RXF"	 25
			"MSD",		// 6970	"ED3F"	"MSD"	"RXF"	 25
			"SLDT",		//		"ED40"	"RXF"	 DFP	 45
			"SRDT",		//		"ED41"	"RXF"	 DFP	 46
			"SLXT",		//		"ED48"	"RXF"	 DFP	 47
			"SRXT",		//		"ED49"	"RXF"	 DFP	 48
			"TDCET",	//		"ED50"	"RXE"	 DFP	 49
			"TDGET",	//		"ED51"	"RXE"	 DFP	 50
			"TDCDT",	//		"ED54"	"RXE"	 DFP	 51
			"TDGDT",	//		"ED55"	"RXE"	 DFP	 52
			"TDCXT",	//		"ED58"	"RXE"	 DFP	 53
			"TDGXT",	//		"ED59"	"RXE"	 DFP	 54
			"LEY",		// 6980	"ED64"	"LEY"	"RXY"	 18
			"LDY",		// 6990	"ED65"	"LDY"	"RXY"	 18
			"STEY",		// 7000	"ED66"	"STEY"	"RXY"	 18
			"STDY",		// 7010	"ED67"	"STDY"	"RXY"	 18
			"PLO",		// 7020	"EE"	"PLO"	"SS3"	 27
			"LMD",		// 7030	"EF"	"LMD"	"SS4"	 28
			"SRP",		// 7040	"F0"	"SRP"	"SS5"	 29
			"MVO",		// 7050	"F1"	"MVO"	"SS2"	 26
			"PACK",		// 7060	"F2"	"PACK"	"SS2"	 26
			"UNPK",		// 7070	"F3"	"UNPK"	"SS2"	 26
			"ZAP",		// 7080	"F8"	"ZAP"	"SS2"	 26
			"CP",		// 7090	"F9"	"CP"	"SS2"	 26
			"AP",		// 7100	"FA"	"AP"	"SS2"	 26
			"SP",		// 7110	"FB"	"SP"	"SS2"	 26
			"MP",		// 7120	"FC"	"MP"	"SS2"	 26
			"DP",		// 7130	"FD"	"DP"	"SS2"	 26
			"CCW",		// 7140	"CCW"					101
			"CCW0",		// 7150	"CCW0"					102
			"CCW1",		// 7160	"CCW1"					103
			"DC",		// 7170	"DC"					104
			"DS",		// 7180	"DS"					105
			"ALIAS",	// 7190	"ALIAS"					106
			"AMODE",	// 7200	"AMODE"					107
			"CATTR",	// 7210	"CATTR"					108
			"COM",		// 7220	"COM"					109
			"CSECT",	// 7230	"CSECT"					110
			"CXD",		// 7240	"CXD"					111
			"DSECT",	// 7250	"DSECT"					112
			"DXD",		// 7260	"DXD"					113
			"ENTRY",	// 7270	"ENTRY"					114
			"EXTRN",	// 7280	"EXTRN"					115
			"LOCTR",	// 7290	"LOCTR"					116
			"RMODE",	// 7300	"RMODE"					117
			"RSECT",	// 7310	"RSECT"					118
			"START",	// 7320	"START"					119
			"WXTRN",	// 7330	"WXTRN"					120
			"XATTR",	// 7340	"XATTR"					121
			"",			// 7350	""						122
			"DROP",		// 7360	"DROP"					123
			"USING",	// 7370	"USING"					124
			"AEJECT",	// 7380	"AEJECT"				125
			"ASPACE",	// 7390	"ASPACE"				126
			"CEJECT",	// 7400	"CEJECT"				127
			"EJECT",	// 7410	"EJECT"					128
			"PRINT",	// 7420	"PRINT"					129
			"SPACE",	// 7430	"SPACE"					130
			"TITLE",	// 7440	"TITLE"					131
			"ADATA",	// 7450	"ADATA"					132
			"CNOP",		// 7460	"CNOP"					133
			"COPY",		// 7470	"COPY"					224
			"END",		// 7480	"END"					135
			"EQU",		// 7490	"EQU"					136
			"EXITCTL",	// 7500	"EXITCTL"				137
			"ICTL",		// 7510	"ICTL"					138
			"ISEQ",		// 7520	"ISEQ"					139
			"LTORG",	// 7530	"LTORG"					140
			"OPSYN",	// 7540	"OPSYN"					225
			"ORG",		// 7550	"ORG"					142
			"POP",		// 7560	"POP"					143
			"PUNCH",	// 7570	"PUNCH"					223
			"PUSH",		// 7580	"PUSH"					145
			"REPRO",	// 7590	"REPRO"					146
			"ACONTROL",	// 7595	"ACONTROL"				147 // RPI-0368
			"ACTR",		// 7600	"ACTR"					201
			"AGO",		// 7610	"AGO"					202
			"AIF",		// 7620	"AIF"					203
			"AINSERT",	// 7630	"AINSERT"				204
			"ANOP",		// 7640	"ANOP"					205
			"AREAD",	// 7650	"AREAD"					206
			"GBLA",		// 7660	"GBLA"					207
			"GBLB",		// 7670	"GBLB"					208
			"GBLC",		// 7680	"GBLC"					209
			"LCLA",		// 7690	"LCLA"					210
			"LCLB",		// 7700	"LCLB"					211
			"LCLC",		// 7710	"LCLC"					212
			"MHELP",	// 7720	"MHELP"					213
			"MNOTE",	// 7730	"MNOTE"					214
			"SETA",		// 7740	"SETA"					215
			"SETAF",	// 7750	"SETAF"					216
			"SETB",		// 7760	"SETB"					217
			"SETC",		// 7770	"SETC"					218
			"SETCF",	// 7780	"SETCF"					219
			"MACRO",	// 7790	"MACRO"					220
			"MEND",		// 7800	"MEND"					221
			"MEXIT",	// 7810	"MEXIT"					222
			"AGOB",		// 7820	"AGOB"					226
			"AIFB",		// 7830	"AIFB"					227
	};
}
