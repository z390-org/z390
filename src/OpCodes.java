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
 * Helper class containing the complete op code information.
 *
 * @author jba68/z390
 */
public class OpCodes {

	final static String[] op_code = {
			"??",    // 00 comments
			"0101",  // 10 "0101" "PR" "E" 1
			"0102",  // 20 "0102" "UPT" "E" 1
			"0104",  //    "0104" "PTFF" "E" 1 Z9-1
			"0107",  // 30 "0107" "SCKPF" "E" 1
			"010A",  // 40 "010A" "PFPO" "E" 1    RPI 1013
			"010B",  // 40 "010B" "TAM" "E" 1
			"010C",  // 50 "010C" "SAM24" "E" 1
			"010D",  // 60 "010D" "SAM31" "E" 1
			"010E",  // 70 "010E" "SAM64" "E" 1
			"01FF",  // 80 "01FF" "TRAP2" "E" 1
			"04",  // 90 "04" "SPM" "RR" 2
			"05",  // 100 "05" "BALR" "RR" 2
			"06",  // 110 "06" "BCTR" "RR" 2
			"07",  // 120 "07" "BCR" "RR" 2
			"07F",  // 130 "07F" "BR" "BRX" 3
			"070",  // 140 "070" "NOPR" "BRX" 3
			"072",  // 150 "072" "BHR" "BRX" 3
			"074",  // 160 "074" "BLR" "BRX" 3
			"078",  // 170 "078" "BER" "BRX" 3
			"07D",  // 180 "07D" "BNHR" "BRX" 3
			"07B",  // 190 "07B" "BNLR" "BRX" 3
			"077",  // 200 "077" "BNER" "BRX" 3
			"072",  // 210 "072" "BPR" "BRX" 3
			"071",  // 220 "071" "BOR" "BRX" 3
			"074",  // 230 "074" "BMR" "BRX" 3
			"078",  // 240 "078" "BZR" "BRX" 3
			"07D",  // 250 "07D" "BNPR" "BRX" 3
			"07B",  // 260 "07B" "BNMR" "BRX" 3
			"077",  // 270 "077" "BNZR" "BRX" 3
			"07E",  // 280 "07E" "BNOR" "BRX" 3
			"0A",  // 290 "0A" "SVC" "I" 4
			"0B",  // 300 "0B" "BSM" "RR" 2
			"0C",  // 310 "0C" "BASSM" "RR" 2
			"0D",  // 320 "0D" "BASR" "RR" 2
			"0E",  // 330 "0E" "MVCL" "RR" 2
			"0F",  // 340 "0F" "CLCL" "RR" 2
			"10",  // 350 "10" "LPR" "RR" 2
			"11",  // 360 "11" "LNR" "RR" 2
			"12",  // 370 "12" "LTR" "RR" 2
			"13",  // 380 "13" "LCR" "RR" 2
			"14",  // 390 "14" "NR" "RR" 2
			"15",  // 400 "15" "CLR" "RR" 2
			"16",  // 410 "16" "OR" "RR" 2
			"17",  // 420 "17" "XR" "RR" 2
			"18",  // 430 "18" "LR" "RR" 2
			"19",  // 440 "19" "CR" "RR" 2
			"1A",  // 450 "1A" "AR" "RR" 2
			"1B",  // 460 "1B" "SR" "RR" 2
			"1C",  // 470 "1C" "MR" "RR" 2
			"1D",  // 480 "1D" "DR" "RR" 2
			"1E",  // 490 "1E" "ALR" "RR" 2
			"1F",  // 500 "1F" "SLR" "RR" 2
			"20",  // 510 "20" "LPDR" "RR" 2
			"21",  // 520 "21" "LNDR" "RR" 2
			"22",  // 530 "22" "LTDR" "RR" 2
			"23",  // 540 "23" "LCDR" "RR" 2
			"24",  // 550 "24" "HDR" "RR" 2
			"25",  // 560 "25" "LDXR" "RR" 2
			"25",  // 570 "25" "LRDR" "RR" 2
			"26",  // 580 "26" "MXR" "RR" 2
			"27",  // 590 "27" "MXDR" "RR" 2
			"28",  // 600 "28" "LDR" "RR" 2
			"29",  // 610 "29" "CDR" "RR" 2
			"2A",  // 620 "2A" "ADR" "RR" 2
			"2B",  // 630 "2B" "SDR" "RR" 2
			"2C",  // 640 "2C" "MDR" "RR" 2
			"2D",  // 650 "2D" "DDR" "RR" 2
			"2E",  // 660 "2E" "AWR" "RR" 2
			"2F",  // 670 "2F" "SWR" "RR" 2
			"30",  // 680 "30" "LPER" "RR" 2
			"31",  // 690 "31" "LNER" "RR" 2
			"32",  // 700 "32" "LTER" "RR" 2
			"33",  // 710 "33" "LCER" "RR" 2
			"34",  // 720 "34" "HER" "RR" 2
			"35",  // 730 "35" "LEDR" "RR" 2
			"35",  // 740 "35" "LRER" "RR" 2
			"36",  // 750 "36" "AXR" "RR" 2
			"37",  // 760 "37" "SXR" "RR" 2
			"38",  // 770 "38" "LER" "RR" 2
			"39",  // 780 "39" "CER" "RR" 2
			"3A",  // 790 "3A" "AER" "RR" 2
			"3B",  // 800 "3B" "SER" "RR" 2
			"3C",  // 810 "3C" "MDER" "RR" 2
			"3C",  // 820 "3C" "MER" "RR" 2
			"3D",  // 830 "3D" "DER" "RR" 2
			"3E",  // 840 "3E" "AUR" "RR" 2
			"3F",  // 850 "3F" "SUR" "RR" 2
			"40",  // 860 "40" "STH" "RX" 5
			"41",  // 870 "41" "LA" "RX" 5
			"42",  // 880 "42" "STC" "RX" 5
			"43",  // 890 "43" "IC" "RX" 5
			"44",  // 900 "44" "EX" "RX" 5
			"45",  // 910 "45" "BAL" "RX" 5
			"46",  // 920 "46" "BCT" "RX" 5
			"47",  // 930 "47" "BC" "RX" 5
			"47F",  // 940 "47F" "B" "BCX" 6
			"470",  // 950 "470" "NOP" "BCX" 6
			"472",  // 960 "472" "BH" "BCX" 6
			"474",  // 970 "474" "BL" "BCX" 6
			"478",  // 980 "478" "BE" "BCX" 6
			"47D",  // 990 "47D" "BNH" "BCX" 6
			"47B",  // 1000 "47B" "BNL" "BCX" 6
			"477",  // 1010 "477" "BNE" "BCX" 6
			"472",  // 1020 "472" "BP" "BCX" 6
			"471",  // 1030 "471" "BO" "BCX" 6
			"474",  // 1040 "474" "BM" "BCX" 6
			"478",  // 1050 "478" "BZ" "BCX" 6
			"47D",  // 1060 "47D" "BNP" "BCX" 6
			"47B",  // 1070 "47B" "BNM" "BCX" 6
			"477",  // 1080 "477" "BNZ" "BCX" 6
			"47E",  // 1090 "47E" "BNO" "BCX" 6
			"48",  // 1100 "48" "LH" "RX" 5
			"49",  // 1110 "49" "CH" "RX" 5
			"4A",  // 1120 "4A" "AH" "RX" 5
			"4B",  // 1130 "4B" "SH" "RX" 5
			"4C",  // 1140 "4C" "MH" "RX" 5
			"4D",  // 1150 "4D" "BAS" "RX" 5
			"4E",  // 1160 "4E" "CVD" "RX" 5
			"4F",  // 1170 "4F" "CVB" "RX" 5
			"50",  // 1180 "50" "ST" "RX" 5
			"51",  // 1190 "51" "LAE" "RX" 5
			"52",  // 1193 "52" "XDECO" "RX" 37 RPI 812
			"53",  // 1196 "53" "XDECI" "RX" 37 RPI 812	
			"54",  // 1200 "54" "N" "RX" 5
			"55",  // 1210 "55" "CL" "RX" 5
			"56",  // 1220 "56" "O" "RX" 5
			"57",  // 1230 "57" "X" "RX" 5
			"58",  // 1240 "58" "L" "RX" 5
			"59",  // 1250 "59" "C" "RX" 5
			"5A",  // 1260 "5A" "A" "RX" 5
			"5B",  // 1270 "5B" "S" "RX" 5
			"5C",  // 1280 "5C" "M" "RX" 5
			"5D",  // 1290 "5D" "D" "RX" 5
			"5E",  // 1300 "5E" "AL" "RX" 5
			"5F",  // 1310 "5F" "SL" "RX" 5
			"60",  // 1320 "60" "STD" "RX" 5
			"61",  // 1323 "61" "XHEXI" "RX" 37 RPI 812
			"62",  // 1326 "62" "XHEXO" "RX" 37 RPI 812
			"67",  // 1330 "67" "MXD" "RX" 5
			"68",  // 1340 "68" "LD" "RX" 5
			"69",  // 1350 "69" "CD" "RX" 5
			"6A",  // 1360 "6A" "AD" "RX" 5
			"6B",  // 1370 "6B" "SD" "RX" 5
			"6C",  // 1380 "6C" "MD" "RX" 5
			"6D",  // 1390 "6D" "DD" "RX" 5
			"6E",  // 1400 "6E" "AW" "RX" 5
			"6F",  // 1410 "6F" "SW" "RX" 5
			"70",  // 1420 "70" "STE" "RX" 5
			"71",  // 1430 "71" "MS" "RX" 5
			"78",  // 1440 "78" "LE" "RX" 5
			"79",  // 1450 "79" "CE" "RX" 5
			"7A",  // 1460 "7A" "AE" "RX" 5
			"7B",  // 1470 "7B" "SE" "RX" 5
			"7C",  // 1480 "7C" "MDE" "RX" 5
			"7C",  // 1490 "7C" "ME" "RX" 5
			"7D",  // 1500 "7D" "DE" "RX" 5
			"7E",  // 1510 "7E" "AU" "RX" 5
			"7F",  // 1520 "7F" "SU" "RX" 5
			"8000",  // 1530 "8000" "SSM" "S" 7
			"8200",  // 1540 "8200" "LPSW" "S" 7
			"83",  // 1550 "83" "DIAGNOSE" "DM" 8
			"84",  // 1560 "84" "BRXH" "RSI" 9
			"84",  // 1570 "84" "JXH" "RSI" 9
			"85",  // 1580 "85" "BRXLE" "RSI" 9
			"85",  // 1590 "85" "JXLE" "RSI" 9
			"86",  // 1600 "86" "BXH" "RS" 10
			"87",  // 1610 "87" "BXLE" "RS" 10
			"88",  // 1620 "88" "SRL" "RS" 10
			"89",  // 1630 "89" "SLL" "RS" 10
			"8A",  // 1640 "8A" "SRA" "RS" 10
			"8B",  // 1650 "8B" "SLA" "RS" 10
			"8C",  // 1660 "8C" "SRDL" "RS" 10
			"8D",  // 1670 "8D" "SLDL" "RS" 10
			"8E",  // 1680 "8E" "SRDA" "RS" 10
			"8F",  // 1690 "8F" "SLDA" "RS" 10
			"90",  // 1700 "90" "STM" "RS" 10
			"91",  // 1710 "91" "TM" "SI" 11
			"92",  // 1720 "92" "MVI" "SI" 11
			"9300",  // 1730 "9300" "TS" "S" 7
			"94",  // 1740 "94" "NI" "SI" 11
			"95",  // 1750 "95" "CLI" "SI" 11
			"96",  // 1760 "96" "OI" "SI" 11
			"97",  // 1770 "97" "XI" "SI" 11
			"98",  // 1780 "98" "LM" "RS" 10
			"99",  // 1790 "99" "TRACE" "RS" 10
			"9A",  // 1800 "9A" "LAM" "RS" 10
			"9B",  // 1810 "9B" "STAM" "RS" 10
			"A50",  // 1820 "A50" "IIHH" "RI" 12
			"A51",  // 1830 "A51" "IIHL" "RI" 12
			"A52",  // 1840 "A52" "IILH" "RI" 12
			"A53",  // 1850 "A53" "IILL" "RI" 12
			"A54",  // 1860 "A54" "NIHH" "RI" 12
			"A55",  // 1870 "A55" "NIHL" "RI" 12
			"A56",  // 1880 "A56" "NILH" "RI" 12
			"A57",  // 1890 "A57" "NILL" "RI" 12
			"A58",  // 1900 "A58" "OIHH" "RI" 12
			"A59",  // 1910 "A59" "OIHL" "RI" 12
			"A5A",  // 1920 "A5A" "OILH" "RI" 12
			"A5B",  // 1930 "A5B" "OILL" "RI" 12
			"A5C",  // 1940 "A5C" "LLIHH" "RI" 12
			"A5D",  // 1950 "A5D" "LLIHL" "RI" 12
			"A5E",  // 1960 "A5E" "LLILH" "RI" 12
			"A5F",  // 1970 "A5F" "LLILL" "RI" 12
			"A70",  // 1980 "A70" "TMLH" "RI" 12
			"A70",  // 1990 "A70" "TMH" "RI" 12
			"A71",  // 2000 "A71" "TMLL" "RI" 12
			"A71",  // 2010 "A71" "TML" "RI" 12
			"A72",  // 2020 "A72" "TMHH" "RI" 12
			"A73",  // 2030 "A73" "TMHL" "RI" 12
			"A74",  // 2040 "A74" "BRC" "RI" 12
			"A74F",  // 2050 "A74F" "J" "BRCX" 13
			"A740",  // 2060 "A740" "JNOP" "BRCX" 13
			"A74F",  // 2070 "A74F" "BRU" "BRCX" 13
			"A742",  // 2080 "A742" "BRH" "BRCX" 13
			"A744",  // 2090 "A744" "BRL" "BRCX" 13
			"A748",  // 2100 "A748" "BRE" "BRCX" 13
			"A74D",  // 2110 "A74D" "BRNH" "BRCX" 13
			"A74B",  // 2120 "A74B" "BRNL" "BRCX" 13
			"A747",  // 2130 "A747" "BRNE" "BRCX" 13
			"A742",  // 2140 "A742" "BRP" "BRCX" 13
			"A744",  // 2150 "A744" "BRM" "BRCX" 13
			"A748",  // 2160 "A748" "BRZ" "BRCX" 13
			"A741",  // 2170 "A741" "BRO" "BRCX" 13
			"A74D",  // 2180 "A74D" "BRNP" "BRCX" 13
			"A74B",  // 2190 "A74B" "BRNM" "BRCX" 13
			"A747",  // 2200 "A747" "BRNZ" "BRCX" 13
			"A74E",  // 2210 "A74E" "BRNO" "BRCX" 13
			"A742",  // 2220 "A742" "JH" "BRCX" 13
			"A744",  // 2230 "A744" "JL" "BRCX" 13
			"A748",  // 2240 "A748" "JE" "BRCX" 13
			"A74D",  // 2250 "A74D" "JNH" "BRCX" 13
			"A74B",  // 2260 "A74B" "JNL" "BRCX" 13
			"A747",  // 2270 "A747" "JNE" "BRCX" 13
			"A742",  // 2280 "A742" "JP" "BRCX" 13 
			"A744",  // 2290 "A744" "JM" "BRCX" 13
			"A748",  // 2300 "A748" "JZ" "BRCX" 13
			"A741",  // 2310 "A741" "JO" "BRCX" 13
			"A74D",  // 2320 "A74D" "JNP" "BRCX" 13
			"A74B",  // 2330 "A74B" "JNM" "BRCX" 13
			"A747",  // 2340 "A747" "JNZ" "BRCX" 13
			"A74E",  // 2350 "A74E" "JNO" "BRCX" 13
			"A75",  // 2360 "A75" "BRAS" "RI" 12
			"A75",  // 2370 "A75" "JAS" "RI" 12
			"A76",  // 2380 "A76" "BRCT" "RI" 12
			"A76",  // 2390 "A76" "JCT" "RI" 12
			"A77",  // 2400 "A77" "BRCTG" "RI" 12
			"A77",  // 2410 "A77" "JCTG" "RI" 12
			"A78",  // 2420 "A78" "LHI" "RI" 12
			"A79",  // 2430 "A79" "LGHI" "RI" 12
			"A7A",  // 2440 "A7A" "AHI" "RI" 12
			"A7B",  // 2450 "A7B" "AGHI" "RI" 12
			"A7C",  // 2460 "A7C" "MHI" "RI" 12
			"A7D",  // 2470 "A7D" "MGHI" "RI" 12
			"A7E",  // 2480 "A7E" "CHI" "RI" 12
			"A7F",  // 2490 "A7F" "CGHI" "RI" 12
			"A8",  // 2500 "A8" "MVCLE" "RS" 10
			"A9",  // 2510 "A9" "CLCLE" "RS" 10
			"AC",  // 2520 "AC" "STNSM" "SI" 11
			"AD",  // 2530 "AD" "STOSM" "SI" 11
			"AE",  // 2540 "AE" "SIGP" "RS" 10
			"AF",  // 2550 "AF" "MC" "SI" 11
			"B1",  // 2560 "B1" "LRA" "RX" 5
			"B202",  // 2570 "B202" "STIDP" "S" 7
			"B204",  // 2580 "B204" "SCK" "S" 7
			"B205",  // 2590 "B205" "STCK" "S" 7
			"B206",  // 2600 "B206" "SCKC" "S" 7
			"B207",  // 2610 "B207" "STCKC" "S" 7
			"B208",  // 2620 "B208" "SPT" "S" 7
			"B209",  // 2630 "B209" "STPT" "S" 7
			"B20A",  // 2640 "B20A" "SPKA" "S" 7
			"B20B",  // 2650 "B20B" "IPK" "S" 7
			"B20D",  // 2660 "B20D" "PTLB" "S" 7
			"B210",  // 2670 "B210" "SPX" "S" 7
			"B211",  // 2680 "B211" "STPX" "S" 7
			"B212",  // 2690 "B212" "STAP" "S" 7
			"B218",  // 2700 "B218" "PC" "S" 7
			"B219",  // 2710 "B219" "SAC" "S" 7
			"B21A",  // 2720 "B21A" "CFC" "S" 7
			"B221",  // 2730 "B221" "IPTE" "RRE" 14
			"B222",  // 2740 "B222" "IPM" "RRE" 14
			"B223",  // 2750 "B223" "IVSK" "RRE" 14
			"B224",  // 2760 "B224" "IAC" "RRE" 14
			"B225",  // 2770 "B225" "SSAR" "RRE" 14
			"B226",  // 2780 "B226" "EPAR" "RRE" 14
			"B227",  // 2790 "B227" "ESAR" "RRE" 14
			"B228",  // 2800 "B228" "PT" "RRE" 14
			"B229",  // 2810 "B229" "ISKE" "RRE" 14
			"B22A",  // 2820 "B22A" "RRBE" "RRE" 14
			"B22B",  // 2830 "B22B" "SSKE" "RRE" 14
			"B22C",  // 2840 "B22C" "TB" "RRE" 14
			"B22D",  // 2850 "B22D" "DXR" "RRE" 14
			"B22E",  // 2860 "B22E" "PGIN" "RRE" 14
			"B22F",  // 2870 "B22F" "PGOUT" "RRE" 14
			"B230",  // 2880 "B230" "CSCH" "S" 7
			"B231",  // 2890 "B231" "HSCH" "S" 7
			"B232",  // 2900 "B232" "MSCH" "S" 7
			"B233",  // 2910 "B233" "SSCH" "S" 7
			"B234",  // 2920 "B234" "STSCH" "S" 7
			"B235",  // 2930 "B235" "TSCH" "S" 7
			"B236",  // 2940 "B236" "TPI" "S" 7
			"B237",  // 2950 "B237" "SAL" "S" 7
			"B238",  // 2960 "B238" "RSCH" "S" 7
			"B239",  // 2970 "B239" "STCRW" "S" 7
			"B23A",  // 2980 "B23A" "STCPS" "S" 7
			"B23B",  // 2990 "B23B" "RCHP" "S" 7
			"B23C",  // 3000 "B23C" "SCHM" "S" 7
			"B240",  // 3010 "B240" "BAKR" "RRE" 14
			"B241",  // 3020 "B241" "CKSM" "RRE" 14
			"B244",  // 3030 "B244" "SQDR" "RRE" 14
			"B245",  // 3040 "B245" "SQER" "RRE" 14
			"B246",  // 3050 "B246" "STURA" "RRE" 14
			"B247",  // 3060 "B247" "MSTA" "RRE" 14
			"B248",  // 3070 "B248" "PALB" "RRE" 14
			"B249",  // 3080 "B249" "EREG" "RRE" 14
			"B24A",  // 3090 "B24A" "ESTA" "RRE" 14
			"B24B",  // 3100 "B24B" "LURA" "RRE" 14
			"B24C",  // 3110 "B24C" "TAR" "RRE" 14
			"B24D",  // 3120 "B24D" "CPYA" "RRE" 14
			"B24E",  // 3130 "B24E" "SAR" "RRE" 14
			"B24F",  // 3140 "B24F" "EAR" "RRE" 14
			"B250",  // 3150 "B250" "CSP" "RRE" 14
			"B252",  // 3160 "B252" "MSR" "RRE" 14
			"B254",  // 3170 "B254" "MVPG" "RRE" 14
			"B255",  // 3180 "B255" "MVST" "RRE" 14
			"B257",  // 3190 "B257" "CUSE" "RRE" 14
			"B258",  // 3200 "B258" "BSG" "RRE" 14
			"B25A",  // 3210 "B25A" "BSA" "RRE" 14
			"B25D",  // 3220 "B25D" "CLST" "RRE" 14
			"B25E",  // 3230 "B25E" "SRST" "RRE" 14
			"B263",  // 3240 "B263" "CMPSC" "RRE" 14
			"B276",  // 3250 "B276" "XSCH" "S" 7
			"B277",  // 3260 "B277" "RP" "S" 7
			"B278",  // 3270 "B278" "STCKE" "S" 7
			"B279",  // 3280 "B279" "SACF" "S" 7
			"B27C",  //      "B27C" "STCKF" "S" 7 Z9-2
			"B27D",  // 3290 "B27D" "STSI" "S" 7
			"B299",  // 3300 "B299" "SRNM" "S" 7
			"B29C",  // 3310 "B29C" "STFPC" "S" 7
			"B29D",  // 3320 "B29D" "LFPC" "S" 7
			"B2A5",  // 3330 "B2A5" "TRE" "RRE" 14
			"B2A6",  // 3340 "B2A6" "CUUTF" "RRE" 14
			"B2A6",  // 3350 "B2A6" "CU21" "RRE" 14
			"B2A7",  // 3360 "B2A7" "CUTFU" "RRE" 14
			"B2A7",  // 3370 "B2A7" "CU12" "RRE" 14
			"B2B0",  //      "B2B0" "STFLE" "S" 7 Z9-3
			"B2B1",  // 3380 "B2B1" "STFL" "S" 7
			"B2B2",  // 3390 "B2B2" "LPSWE" "S" 7
			"B2B8",    // 3392 "B2B8" "SRNMB" "S" 7 RPI 1125
			"B2B9",  // 3395 "B2B9" "SRNMT" "S" 7 DFP 56
			"B2BD",  // 3395 "B2BD" "LFAS"  "S" 7 DFP 55
			"B2FF",  // 3400 "B2FF" "TRAP4" "S" 7
			"B300",  // 3410 "B300" "LPEBR" "RRE" 14
			"B301",  // 3420 "B301" "LNEBR" "RRE" 14
			"B302",  // 3430 "B302" "LTEBR" "RRE" 14
			"B303",  // 3440 "B303" "LCEBR" "RRE" 14
			"B304",  // 3450 "B304" "LDEBR" "RRE" 14
			"B305",  // 3460 "B305" "LXDBR" "RRE" 14
			"B306",  // 3470 "B306" "LXEBR" "RRE" 14
			"B307",  // 3480 "B307" "MXDBR" "RRE" 14
			"B308",  // 3490 "B308" "KEBR" "RRE" 14
			"B309",  // 3500 "B309" "CEBR" "RRE" 14
			"B30A",  // 3510 "B30A" "AEBR" "RRE" 14
			"B30B",  // 3520 "B30B" "SEBR" "RRE" 14
			"B30C",  // 3530 "B30C" "MDEBR" "RRE" 14
			"B30D",  // 3540 "B30D" "DEBR" "RRE" 14
			"B30E",  // 3550 "B30E" "MAEBR" "RRF1" 15
			"B30F",  // 3560 "B30F" "MSEBR" "RRF1" 15
			"B310",  // 3570 "B310" "LPDBR" "RRE" 14
			"B311",  // 3580 "B311" "LNDBR" "RRE" 14
			"B312",  // 3590 "B312" "LTDBR" "RRE" 14
			"B313",  // 3600 "B313" "LCDBR" "RRE" 14
			"B314",  // 3610 "B314" "SQEBR" "RRE" 14
			"B315",  // 3620 "B315" "SQDBR" "RRE" 14
			"B316",  // 3630 "B316" "SQXBR" "RRE" 14
			"B317",  // 3640 "B317" "MEEBR" "RRE" 14
			"B318",  // 3650 "B318" "KDBR" "RRE" 14
			"B319",  // 3660 "B319" "CDBR" "RRE" 14
			"B31A",  // 3670 "B31A" "ADBR" "RRE" 14
			"B31B",  // 3680 "B31B" "SDBR" "RRE" 14
			"B31C",  // 3690 "B31C" "MDBR" "RRE" 14
			"B31D",  // 3700 "B31D" "DDBR" "RRE" 14
			"B31E",  // 3710 "B31E" "MADBR" "RRF1" 15
			"B31F",  // 3720 "B31F" "MSDBR" "RRF1" 15
			"B324",  // 3730 "B324" "LDER" "RRE" 14
			"B325",  // 3740 "B325" "LXDR" "RRE" 14
			"B326",  // 3750 "B326" "LXER" "RRE" 14
			"B32E",  // 3760 "B32E" "MAER" "RRF1" 15
			"B32F",  // 3770 "B32F" "MSER" "RRF1" 15
			"B336",  // 3780 "B336" "SQXR" "RRE" 14
			"B337",  // 3790 "B337" "MEER" "RRE" 14
			"B338",  //      "B338" "MAYLR" "RRF1" 15 Z9-4
			"B339",  //      "B339" "MYLR" "RRF1" 15 Z9-5
			"B33A",  //      "B33A" "MAYR" "RRF1" 15 Z9-6
			"B33B",  //      "B33B" "MYR" "RRF1" 15 Z9-7
			"B33C",  //      "B33C" "MAYHR" "RRF1" 15 Z9-8
			"B33D",  //      "B33D" "MYHR" "RRF1" 15 Z9-9
			"B33E",  // 3800 "B33E" "MADR" "RRF1" 15
			"B33F",  // 3810 "B33F" "MSDR" "RRF1" 15
			"B340",  // 3820 "B340" "LPXBR" "RRE" 14
			"B341",  // 3830 "B341" "LNXBR" "RRE" 14
			"B342",  // 3840 "B342" "LTXBR" "RRE" 14
			"B343",  // 3850 "B343" "LCXBR" "RRE" 14
			"B344",  // 3860 "B344" "LEDBR?" "RRE" 53 RPI 1125
			"B345",  // 3870 "B345" "LDXBR?" "RRE" 53 RPI 1125
			"B346",  // 3880 "B346" "LEXBR?" "RRE" 53 RPI 1125
			"B347",  // 3890 "B347" "FIXBR?" "RRF2" 54 RPI 1125
			"B348",  // 3900 "B348" "KXBR" "RRE" 14
			"B349",  // 3910 "B349" "CXBR" "RRE" 14
			"B34A",  // 3920 "B34A" "AXBR" "RRE" 14
			"B34B",  // 3930 "B34B" "SXBR" "RRE" 14
			"B34C",  // 3940 "B34C" "MXBR" "RRE" 14
			"B34D",  // 3950 "B34D" "DXBR" "RRE" 14
			"B350",  // 3960 "B350" "TBEDR" "RRF2" 34
			"B351",  // 3970 "B351" "TBDR" "RRF2" 34
			"B353",  // 3980 "B353" "DIEBR" "RRF2" 34
			"B357",  // 3990 "B357" "FIEBR?" "RRF2" 54 RPI 1125
			"B358",  // 4000 "B358" "THDER" "RRE" 14
			"B359",  // 4010 "B359" "THDR" "RRE" 14
			"B35B",  // 4020 "B35B" "DIDBR" "RRF2" 34
			"B35F",  // 4030 "B35F" "FIDBR?" "RRF2" 54 RPI 1125
			"B360",  // 4040 "B360" "LPXR" "RRE" 14
			"B361",  // 4050 "B361" "LNXR" "RRE" 14
			"B362",  // 4060 "B362" "LTXR" "RRE" 14
			"B363",  // 4070 "B363" "LCXR" "RRE" 14
			"B365",  // 4080 "B365" "LXR" "RRE" 14
			"B366",  // 4090 "B366" "LEXR" "RRE" 14
			"B367",  // 4100 "B367" "FIXR" "RRE" 14
			"B369",  // 4110 "B369" "CXR" "RRE" 14
			"B370",  // 4115 "B370" "LPDFR" "RRE"  14 DFP
			"B371",  // 4115 "B371" "LNDFR" "RRE"  14 DFP
			"B372",  // 4115 "B372" "CPSDR" "RRF2" 34 DFP
			"B373",  // 4115 "B373" "LCDFR" "RRE"  14 DFP
			"B374",  // 4120 "B374" "LZER" "RRE" 14
			"B375",  // 4130 "B375" "LZDR" "RRE" 14
			"B376",  // 4140 "B376" "LZXR" "RRE" 14
			"B377",  // 4150 "B377" "FIER" "RRE" 14
			"B37F",  // 4160 "B37F" "FIDR" "RRE" 14
			"B384",  // 4170 "B384" "SFPC" "RRE" 14
			"B385",  // 4175 "B385" "SFASR" "RRE" 14 DFP 57
			"B38C",  // 4180 "B38C" "EFPC" "RRE" 14
			"B390",  //      "B390" "CELFBR" "RRF3" 30 RPI 1125 Z196
			"B391",  //      "B391" "CDLFBR" "RRF3" 30 RPI 1125 Z196
			"B392",  //      "B392" "CXLFBR" "RRF3" 30 RPI 1125 Z196
			"B394",  // 4190 "B394?" "CEFBR" "RRE" 53 RPI 1125 Z196
			"B395",  // 4200 "B395?" "CDFBR" "RE3" 53 RPI 1125 Z196
			"B396",  // 4210 "B396?" "CXFBR" "RE3" 53 RPI 1125 Z196
			"B398",  // 4220 "B398" "CFEBR?" "RRF7" 34 RPI 1125 Z196
			"B399",  // 4230 "B399" "CFDBR?" "RRF7" 34 RPI 1125 Z196
			"B39A",  // 4240 "B39A" "CFXBR?" "RRF7" 34 RPI 1125 Z196
			"B39C",  // 'B39C' 'CLFEBR' 'RRF3' 30 RPI 1125 Z196
			"B39D",  // 'B39D' 'CLFDBR' 'RRF3' 30 RPI 1125 Z196
			"B39E",  // 'B39E' 'CLFXBR' 'RRF3' 30 RPI 1125 Z196
			"B3A0",  // 'B3A0' 'CELGBR' 'RRF3' 30 RPI 1125 Z196
			"B3A1",  // 'B3A1' 'CDLGBR' 'RRF3' 30 RPI 1125 Z196
			"B3A2",  // 'B3A2' 'CXLGBR' 'RRF3' 30 RPI 1125 Z196
			"B3A4",  // 4250 "B3A4" "CEGBR" "RRE" 53 RPI 1125 Z196
			"B3A5",  // 4260 "B3A5" "CDGBR" "RRE" 53 RPI 1125 Z196
			"B3A6",  // 4270 "B3A6" "CXGBR" "RRE" 53 RPI 1125 Z196
			"B3A8",  // 4280 "B3A8" "CGEBR" "RRF2" 54 RPI 1125 Z196
			"B3A9",  // 4290 "B3A9" "CGDBR" "RRF2" 54 RPI 1125 Z1964
			"B3AA",  // 4300 "B3AA" "CGXBR" "RRF2" 54 RPI 1125 Z1964
			"B3AC",  //      "B3AC" "CLGEBR" "RRF2" 30  RPI 1125 Z196
			"B3AD",  //      "B3AD" "CLGDBR" "RRF2" 30  RPI 1125 Z196
			"B3AE",  //      "B3AE" "CLGXBR" "RRF2" 30  RPI 1125 Z196		       
			"B3B4",  // 4310 "B3B4" "CEFR" "RRE" 14
			"B3B5",  // 4320 "B3B5" "CDFR" "RRE" 14
			"B3B6",  // 4330 "B3B6" "CXFR" "RRE" 14
			"B3B8",  // 4340 "B3B8" "CFER" "RRF2" 34
			"B3B9",  // 4350 "B3B9" "CFDR" "RRF2" 34
			"B3BA",  // 4360 "B3BA" "CFXR" "RRF2" 34
			"B3C1",  // 4365 "B3C1" "LDGR" "RRE" 14 DFP
			"B3C4",  // 4370 "B3C4" "CEGR" "RRE" 14
			"B3C5",  // 4380 "B3C5" "CDGR" "RRE" 14
			"B3C6",  // 4390 "B3C6" "CXGR" "RRE" 14
			"B3C8",  // 4400 "B3C8" "CGER" "RRF2" 34
			"B3C9",  // 4410 "B3C9" "CGDR" "RRF2" 34
			"B3CA",  // 4420 "B3CA" "CGXR" "RRF2" 34
			"B3CD",  // 4425 "B3CD" "LGDR" "RRE" 14 DFP
			"B3D0", // "MDTR?"  "B3D0" "RRR"  DFP 1  RPI 1125
			"B3D1", // "DDTR?"  "B3D1" "RRR"  DFP 2  RPI 1125
			"B3D2", // "ADTR?"  "B3D2" "RRR"  DFP 3  RPI 1125
			"B3D3", // "SDTR?"  "B3D3" "RRR"  DFP 4  RPI 1125
			"B3D4", // "LDETR"  "B3D4" "RRF4" DFP 5  
			"B3D5", // "LEDTR"  "B3D5" "RRF3" DFP 6  
			"B3D6", // "LTDTR"  "B3D6" "RRE"  DFP 7  
			"B3D7", // "FIDTR"  "B3D7" "RRF3" DFP 8  
			"B3D8", // "MXTR?"  "B3D8" "RRR"  DFP 9  RPI 1125
			"B3D9", // "DXTR?"  "B3D9" "RRR"  DFP 10 RPI 1125
			"B3DA", // "AXTR?"  "B3DA" "RRR"  DFP 11 RPI 1125
			"B3DB", // "SXTR?"  "B3DB" "RRR"  DFP 12 RPI 1125		       
			"B3DC", // "LXDTR" "RRF4" DFP 13
			"B3DD", // "LDXTR" "RRF3" DFP 14
			"B3DE", // "LTXTR" "RRE" DFP 15
			"B3DF", // "FIXTR" "RRF3" DFP 16
			"B3E0", // "KDTR" "RRE" DFP 17
			"B3E1", // "CGDTR?" "RRF7" DFP 18 RPI 1125
			"B3E2", // "CUDTR" "RRE" DFP 19
			"B3E3", // "CSDTR" "RRF4" DFP 20
			"B3E4", // "CDTR" "RRE" DFP 21
			"B3E5", // "EEDTR" "RRE" DFP 22
			"B3E7", // "ESDTR" "RRE" DFP 23
			"B3E8", // "KXTR" "RRE" DFP 24
			"B3E9", // "CGXTR?" "RRF7" DFP 25 RPI 1125
			"B3EA", // "CUXTR" "RRE" DFP 26
			"B3EB", // "CSXTR" "RRF4" DFP 27
			"B3EC", // "CXTR" "RRE" DFP 28
			"B3ED", // "EEXTR" "RRE" DFP 29
			"B3EF", // "ESXTR" "RRE" DFP 30
			"B3F1", // "CDGTR?" "RE3" DFP 31 RPI 1125
			"B3F2", // "CDUTR" "RRE" DFP 32
			"B3F3", // "CDSTR" "RRE" DFP 33
			"B3F4", // "CEDTR" "RRE" DFP 34
			"B3F5", // "QADTR" "RRF3" DFP 35
			"B3F6", // "IEDTR" "RRF2" DFP 36
			"B3F7", // "RRDTR" "RRF3" DFP 37
			"B3F9", // "CXGTR?" "RE3" DFP 38 RPI 1125
			"B3FA", // "CXUTR" "RRE" DFP 39
			"B3FB", // "CXSTR" "RRE" DFP 40
			"B3FC", // "CEXTR" "RRE" DFP 41
			"B3FD", // "QAXTR" "RRF3" DFP 42
			"B3FE", // "IEXTR" "RRF2" DFP 43
			"B3FF", // "RRXTR" "RRF3" DFP 44
			"B6",  // 4430 "B6" "STCTL" "RS" 10
			"B7",  // 4440 "B7" "LCTL" "RS" 10
			"B900",  // 4450 "B900" "LPGR" "RRE" 14
			"B901",  // 4460 "B901" "LNGR" "RRE" 14
			"B902",  // 4470 "B902" "LTGR" "RRE" 14
			"B903",  // 4480 "B903" "LCGR" "RRE" 14
			"B904",  // 4490 "B904" "LGR" "RRE" 14
			"B905",  // 4500 "B905" "LURAG" "RRE" 14
			"B906",  //      "B906" "LGBR" "RRE" 14 Z9-10
			"B907",  //      "B907" "LGHR" "RRE" 14 Z9-11
			"B908",  // 4510 "B908" "AGR" "RRE" 14
			"B909",  // 4520 "B909" "SGR" "RRE" 14
			"B90A",  // 4530 "B90A" "ALGR" "RRE" 14
			"B90B",  // 4540 "B90B" "SLGR" "RRE" 14
			"B90C",  // 4550 "B90C" "MSGR" "RRE" 14
			"B90D",  // 4560 "B90D" "DSGR" "RRE" 14
			"B90E",  // 4570 "B90E" "EREGG" "RRE" 14
			"B90F",  // 4580 "B90F" "LRVGR" "RRE" 14
			"B910",  // 4590 "B910" "LPGFR" "RRE" 14
			"B911",  // 4600 "B911" "LNGFR" "RRE" 14
			"B912",  // 4610 "B912" "LTGFR" "RRE" 14
			"B913",  // 4620 "B913" "LCGFR" "RRE" 14
			"B914",  // 4630 "B914" "LGFR" "RRE" 14
			"B916",  // 4640 "B916" "LLGFR" "RRE" 14
			"B917",  // 4650 "B917" "LLGTR" "RRE" 14
			"B918",  // 4660 "B918" "AGFR" "RRE" 14
			"B919",  // 4670 "B919" "SGFR" "RRE" 14
			"B91A",  // 4680 "B91A" "ALGFR" "RRE" 14
			"B91B",  // 4690 "B91B" "SLGFR" "RRE" 14
			"B91C",  // 4700 "B91C" "MSGFR" "RRE" 14
			"B91D",  // 4710 "B91D" "DSGFR" "RRE" 14
			"B91E",  // 4720 "B91E" "KMAC" "RRE" 14
			"B91F",  // 4730 "B91F" "LRVR" "RRE" 14
			"B920",  // 4740 "B920" "CGR" "RRE" 14
			"B921",  // 4750 "B921" "CLGR" "RRE" 14
			"B925",  // 4760 "B925" "STURG" "RRE" 14
			"B926",  //      "B926" "LBR" "RRE" 14 Z9-12
			"B927",  //      "B927" "LHR" "RRE" 14 Z9-13
			"B928",  // "B928","PCKMO","RE4"  14 RPI 1125 Z196
			"B92A",  // "B92A","KMF","RRE"    14 RPI 1125 Z196
			"B92B",  // "B92B","KMO","RRE"    14 RPI 1125 Z196
			"B92C",  // "B92C","PCC","RE4"    14 RPI 1125 Z196
			"B92D",  // "B92D","KMCTR","RRF2" 34 RPI 1125 Z196
			"B92E",  // 4770 "B92E" "KM" "RRE" 14
			"B92F",  // 4780 "B92F" "KMC" "RRE" 14
			"B930",  // 4790 "B930" "CGFR" "RRE" 14
			"B931",  // 4800 "B931" "CLGFR" "RRE" 14
			"B93E",  // 4810 "B93E" "KIMD" "RRE" 14
			"B93F",  // 4820 "B93F" "KLMD" "RRE" 14
			"B941",    // "B941","CFDTR","RRF"  30 RPI 1125 Z196
			"B942",   // "B942","CLGDTR","RRF" 30 RPI 1125 Z196
			"B943",   // "B943","CLFDTR","RRF" 30 RPI 1125 Z196		
			"B946",  // 4830 "B946" "BCTGR" "RRE" 14
			"B949",    // "B949","CFXTR","RRF3"   30 RPI 1125 Z196
			"B94A",   // "B94A","CLGXTR","RRF3"  30 RPI 1125 Z196
			"B94B",   // "B94B","CLFXTR","RRF3"  30 RPI 1125 Z196
			"B951",    // "B951","CDFTR","RRF3"   30 RPI 1125 Z196
			"B952",   // "B952","CDLGTR","RRF3"  30 RPI 1125 Z196
			"B953",   // "B953","CDLFTR","RRF3"  30 RPI 1125 Z196
			"B959",    // "B959","CXFTR","RRF3"   30 RPI 1125 Z196
			"B95A",   // "B95A","CXLGTR","RRF3"  30 RPI 1125 Z196
			"B95B",   // "B95B","CXLFTR","RRF3"  30 RPI 1125 Z196
			"B960",  // 10 "B960" "CGRT" "RRF5" 39 RPI 817
			"B9608",  // 20 "B9608" "CGRTE" "RRF6" 40 RPI 817
			"B9602",  // 30 "B9602" "CGRTH" "RRF6" 40 RPI 817
			"B9604",  // 40 "B9604" "CGRTL" "RRF6" 40 RPI 817
			"B9606",  // 50 "B9606" "CGRTNE" "RRF6" 40 RPI 817
			"B960C",  // 60 "B960C" "CGRTNH" "RRF6" 40 RPI 817
			"B960A",  // 70 "B960A" "CGRTNL" "RRF6" 40 RPI 817
			"B961",  // 10 "B961" "CLGRT" "RRF5" 39 RPI 817
			"B9618",  // 20 "B9618" "CLGRTE" "RRF6" 40 RPI 817
			"B9612",  // 30 "B9612" "CLGRTH" "RRF6" 40 RPI 817
			"B9614",  // 40 "B9614" "CLGRTL" "RRF6" 40 RPI 817
			"B9616",  // 50 "B9616" "CLGRTNE" "RRF6" 40 RPI 817
			"B961C",  // 60 "B961C" "CLGRTNH" "RRF6" 40 RPI 817
			"B961A",  // 70 "B961A" "CLGRTNL" "RRF6" 40 RPI 817
			"B972",  // 80 "B972" "CRT" "RRF5" 39 RPI 817
			"B9728",  // 90 "B9728" "CRTE" "RRF6" 40 RPI 817
			"B9722",  // 100 "B9722" "CRTH" "RRF6" 40 RPI 817
			"B9724",  // 110 "B9724" "CRTL" "RRF6" 40 RPI 817
			"B9726",  // 120 "B9726" "CRTNE" "RRF6" 40 RPI 817
			"B972C",  // 130 "B972C" "CRTNH" "RRF6" 40 RPI 817
			"B972A",  // 140 "B972A" "CRTNL" "RRF6" 40 RPI 817
			"B973",  // 80 "B973" "CLRT" "RRF5" 39 RPI 817
			"B9738",  // 90 "B9738" "CLRTE" "RRF6" 40 RPI 817
			"B9732",  // 100 "B9732" "CLRTH" "RRF6" 40 RPI 817
			"B9734",  // 110 "B9734" "CLRTL" "RRF6" 40 RPI 817
			"B9736",  // 120 "B9736" "CLRTNE" "RRF6" 40 RPI 817
			"B973C",  // 130 "B973C" "CLRTNH" "RRF6" 40 RPI 817
			"B973A",  // 140 "B973A" "CLRTNL" "RRF6" 40 RPI 817
			"B980",  // 4840 "B980" "NGR" "RRE" 14
			"B981",  // 4850 "B981" "OGR" "RRE" 14
			"B982",  // 4860 "B982" "XGR" "RRE" 14
			"B983",  //      "B983" "FLOGR" "RRE" 14 Z9-14
			"B984",  //      "B984" "LLGCR" "RRE" 14 Z9-15
			"B985",  //      "B985" "LLGHR" "RRE" 14 Z9-16
			"B986",  // 4870 "B986" "MLGR" "RRE" 14
			"B987",  // 4880 "B987" "DLGR" "RRE" 14
			"B988",  // 4890 "B988" "ALCGR" "RRE" 14
			"B989",  // 4900 "B989" "SLBGR" "RRE" 14
			"B98A",  // 4910 "B98A" "CSPG" "RRE" 14
			"B98D",  // 4920 "B98D" "EPSW" "RRE" 14
			"B98E",  // 4930 "B98E" "IDTE" "RRF2" 34
			"B990",  // 4940 "B990" "TRTT" "RRE" 14
			"B991",  // 4950 "B991" "TRTO" "RRE" 14
			"B992",  // 4960 "B992" "TROT" "RRE" 14
			"B993",  // 4970 "B993" "TROO" "RRE" 14
			"B994",  //      "B994" "LLCR" "RRE" 14 Z9-17
			"B995",  //      "B995" "LLHR" "RRE" 14 Z9-18
			"B996",  // 4980 "B996" "MLR" "RRE" 14
			"B997",  // 4990 "B997" "DLR" "RRE" 14
			"B998",  // 5000 "B998" "ALCR" "RRE" 14
			"B999",  // 5010 "B999" "SLBR" "RRE" 14
			"B99A",  // 5020 "B99A" "EPAIR" "RRE" 14
			"B99B",  // 5030 "B99B" "ESAIR" "RRE" 14
			"B99D",  // 5040 "B99D" "ESEA" "RRE" 14
			"B99E",  // 5050 "B99E" "PTI" "RRE" 14
			"B99F",  // 5060 "B99F" "SSAIR" "RRE" 14
			"B9A2",  // 10 "B9A2" "PTF" "RRE" 14 RPI 817
			"B9AA",  //      "B9AA" "LPTEA" "RRE" 14 Z9-19
			"B9AE",  // "B9AE","RRBM","RRE"  14 RPI 1125 Z196		
			"B9AF",  // 20 "B9AF" "PFMF" "RRF5" 39 RPI 817
			"B9B0",  // 5070 "B9B0" "CU14" "RRE" 14
			"B9B1",  // 5080 "B9B1" "CU24" "RRE" 14
			"B9B2",  // 5090 "B9B2" "CU41" "RRE" 14
			"B9B3",  // 5100 "B9B3" "CU42" "RRE" 14
			"B9BD",  // 30 "B9BD" "TRTRE" "RRF5" 39 RPI 817
			"B9BE",  // 5110 "B9BE" "SRSTU" "RRE" 14
			"B9BF",  // 40 "B9BF" "TRTE" "RRF5" 39 RPI 817
			"B9C8",    // "B9C8","AHHHR","RRF5"  39 RPI 1125 Z196
			"B9C9",    // "B9C9","SHHHR","RRF5"  39 RPI 1125 Z196
			"B9CA",   // "B9CA","ALHHHR","RRF5" 39 RPI 1125 Z196
			"B9CB",   // "B9CB","SLHHHR","RRF5" 39 RPI 1125 Z196
			"B9CD",     // "B9CD","CHHR","RRE"     14 RPI 1125 Z196
			"B9CF",    // "B9CF","CLHHR","RRE"    14 RPI 1125 Z196
			"B9D8",    // "B9D8","AHHLR","RRF5 "  39 RPI 1125 Z196
			"B9D9",    // "B9D9","SHHLR","RRF5 "  39 RPI 1125 Z196
			"B9DA",    // "B9DA","ALHHLR","RRF5 " 39 RPI 1125 Z196
			"B9DB",    // "B9DB","SLHHLR","RRF5 " 39 RPI 1125 Z196
			"B9DD",    // "B9DD","CHLR","RRE"     14 RPI 1125 Z196
			"B9DF",    // "B9DF","CLHLR","RRE"    14 RPI 1125 Z196     		       
			"B9E1",  // 5115 "B9E1" "POPCNT" "RRE" 14 RPI 1125
			"B9E2",    // "B9E2","LOCGR","RRF5"   39 RPI 1125 Z196
			"B9E4",    // "B9E4","NGRK","RRF5"    39 RPI 1125 Z196
			"B9E6",    // "B9E6","OGRK","RRF5"    39 RPI 1125 Z196
			"B9E7",    // "B9E7","XGRK","RRF5"    39 RPI 1125 Z196
			"B9E8",    // "B9E8","AGRK","RRF5"    39 RPI 1125 Z196
			"B9E9",    // "B9E9","SGRK","RRF5"    39 RPI 1125 Z196
			"B9EA",    // "B9EA","ALGRK","RRF5"   39 RPI 1125 Z196
			"B9EB",    // "B9EB","SLGRK","RRF5"   39 RPI 1125 Z196
			"B9F2",    // "B9F2","LOCR","RRF5"    39 RPI 1125 Z196
			"B9F4",    // "B9F4","NRK","RRF5"     39 RPI 1125 Z196
			"B9F6",    // "B9F6","ORK","RRF5"     39 RPI 1125 Z196
			"B9F7",    // "B9F7","XRK","RRF5"     39 RPI 1125 Z196
			"B9F8",    // "B9F8","ARK","RRF5"     39 RPI 1125 Z196
			"B9F9",    // "B9F9","SRK","RRF5"     39 RPI 1125 Z196
			"B9FA",    // "B9FA","ALRK","RRF5"    39 RPI 1125 Z196
			"B9FB",    // "B9FB","SLRK","RRF5"    39 RPI 1125 Z196 	
			"BA",  // 5120 "BA" "CS" "RS" 10
			"BB",  // 5130 "BB" "CDS" "RS" 10
			"BD",  // 5140 "BD" "CLM" "RS" 10
			"BE",  // 5150 "BE" "STCM" "RS" 10
			"BF",  // 5160 "BF" "ICM" "RS" 10
			"C00",  // 5170 "C00" "LARL" "RIL" 16
			"C01",  //      "C01" "LGFI" "RIL" 16 Z9-20
			"C04",  // 5180 "C04" "BRCL" "RIL" 16
			"C040",  // 5390 "C040" "JLNOP" "BLX" 33
			"C041",  // 5400 "C041" "BROL" "BLX" 33
			"C041",  // 5410 "C041" "JLO" "BLX" 33
			"C042",  // 5420 "C042" "BRHL" "BLX" 33
			"C042",  // 5430 "C042" "BRPL" "BLX" 33
			"C042",  // 5440 "C042" "JLH" "BLX" 33
			"C042",  // 5450 "C042" "JLP" "BLX" 33
			"C044",  // 5460 "C044" "BRLL" "BLX" 33
			"C044",  // 5470 "C044" "BRML" "BLX" 33
			"C044",  // 5480 "C044" "JLL" "BLX" 33
			"C044",  // 5490 "C044" "JLM" "BLX" 33
			"C047",  // 5500 "C047" "BRNEL" "BLX" 33
			"C047",  // 5510 "C047" "BRNZL" "BLX" 33
			"C047",  // 5520 "C047" "JLNE" "BLX" 33
			"C047",  // 5530 "C047" "JLNZ" "BLX" 33
			"C048",  // 5540 "C048" "BREL" "BLX" 33
			"C048",  // 5550 "C048" "BRZL" "BLX" 33
			"C048",  // 5560 "C048" "JLE" "BLX" 33
			"C048",  // 5570 "C048" "JLZ" "BLX" 33
			"C04B",  // 5580 "C04B" "BRNLL" "BLX" 33
			"C04B",  // 5590 "C04B" "BRNML" "BLX" 33
			"C04B",  // 5600 "C04B" "JLNL" "BLX" 33
			"C04B",  // 5610 "C04B" "JLNM" "BLX" 33
			"C04D",  // 5620 "C04D" "BRNHL" "BLX" 33
			"C04D",  // 5630 "C04D" "BRNPL" "BLX" 33
			"C04D",  // 5640 "C04D" "JLNH" "BLX" 33
			"C04D",  // 5650 "C04D" "JLNP" "BLX" 33
			"C04E",  // 5660 "C04E" "BRNOL" "BLX" 33
			"C04E",  // 5670 "C04E" "JLNO" "BLX" 33
			"C04F",  // 5680 "C04F" "BRUL" "BLX" 33
			"C04F",  // 5690 "C04F" "JLU" "BLX" 33
			"C05",  // 5210 "C05" "BRASL" "RIL" 16
			"C05",  // 5220 "C05" "JASL" "RIL" 16
			"C06",  //      "C06" "XIHF" "RIL" 16 Z9-21
			"C07",  //      "C07" "XILF" "RIL" 16 Z9-22
			"C08",  //      "C08" "IIHF" "RIL" 16 Z9-23
			"C09",  //      "C09" "IILF" "RIL" 16 Z9-24
			"C0A",  //      "C0A" "NIHF" "RIL" 16 Z9-25
			"C0B",  //      "C0B" "NILF" "RIL" 16 Z9-26
			"C0C",  //      "C0C" "OIHF" "RIL" 16 Z9-27
			"C0D",  //      "C0D" "OILF" "RIL" 16 Z9-28
			"C0E",  //      "C0E" "LLIHF" "RIL" 16 Z9-29
			"C0F",  //      "C0F" "LLILF" "RIL" 16 Z9-30
			"C20",  // 50 "C20" "MSGFI" "RIL" 16 RPI 817
			"C21",  // 60 "C21" "MSFI" "RIL" 16 RPI 817
			"C24",  //      "C24" "SLGFI" "RIL" 16 Z9-31
			"C25",  //      "C25" "SLFI" "RIL" 16 Z9-32
			"C28",  //      "C28" "AGFI" "RIL" 16 Z9-33
			"C29",  //      "C29" "AFI" "RIL" 16 Z9-34
			"C2A",  //      "C2A" "ALGFI" "RIL" 16 Z9-35
			"C2B",  //      "C2B" "ALFI" "RIL" 16 Z9-36
			"C2C",  //      "C2C" "CGFI" "RIL" 16 Z9-37
			"C2D",  //      "C2D" "CFI" "RIL" 16 Z9-38
			"C2E",  //      "C2E" "CLGFI" "RIL" 16 Z9-39
			"C2F",  //      "C2F" "CLFI" "RIL" 16 Z9-40
			"C42",  // 70 "C42" "LLHRL" "RIL" 16 RPI 817
			"C44",  // 80 "C44" "LGHRL" "RIL" 16 RPI 817
			"C45",  // 90 "C45" "LHRL" "RIL" 16 RPI 817
			"C46",  // 100 "C46" "LLGHRL" "RIL" 16 RPI 817
			"C47",  // 110 "C47" "STHRL" "RIL" 16 RPI 817
			"C48",  // 120 "C48" "LGRL" "RIL" 16 RPI 817
			"C4B",  // 130 "C4B" "STGRL" "RIL" 16 RPI 817
			"C4C",  // 140 "C4C" "LGFRL" "RIL" 16 RPI 817
			"C4D",  // 150 "C4D" "LRL" "RIL" 16 RPI 817
			"C4E",  // 160 "C4E" "LLGFRL" "RIL" 16 RPI 817
			"C4F",  // 170 "C4F" "STRL" "RIL" 16 RPI 817
			"C60",  // 180 "C60" "EXRL" "RIL" 16 RPI 817
			"C62",  // 190 "C62" "PFDRL" "RIL" 16 RPI 817
			"C64",  // 200 "C64" "CGHRL" "RIL" 16 RPI 817
			"C65",  // 210 "C65" "CHRL" "RIL" 16 RPI 817
			"C66",  // 220 "C66" "CLGHRL" "RIL" 16 RPI 817
			"C67",  // 230 "C67" "CLHRL" "RIL" 16 RPI 817
			"C68",  // 240 "C68" "CGRL" "RIL" 16 RPI 817
			"C6A",  // 250 "C6A" "CLGRL" "RIL" 16 RPI 817
			"C6C",  // 260 "C6C" "CGFRL" "RIL" 16 RPI 817
			"C6D",  // 270 "C6D" "CRL" "RIL" 16 RPI 817
			"C6E",  // 280 "C6E" "CLGFRL" "RIL" 16 RPI 817
			"C6F",  // 290 "C6F" "CLRL" "RIL" 16 RPI 817
			"C80",  //      "C80" "MVCOS" "SSF" 32 Z9-41
			"C81",  //      "C81" "ECTG" "SSF" 32 RPI 1013
			"C82",  //      "C82" "CSST" "SSF" 32 RPI 1013
			"C84",  // "C84","LPD","SSF2"  55 RPI 1125 Z196
			"C85",  // "C85","LPDG","SSF2" 55 RPI 1125 Z196
			"CC6", // "CC6","BRCTH","RIL"  16 RPI 1125 Z196
			"CC8", // "CC8","AIH","RIL"    16  RPI 1125 Z196
			"CCA", // "CCA","ALSIH","RIL"  16  RPI 1125 Z196
			"CCB", // "CCB","ALSIHN","RIL" 16  RPI 1125 Z196
			"CCD", // "CCD","CIH","RIL"    16  RPI 1125 Z196
			"CCF", // "CCF","CLIH","RIL"   16  RPI 1125 Z196
			"D0",  // 5230 "D0" "TRTR" "SS" 17
			"D1",  // 5240 "D1" "MVN" "SS" 17
			"D2",  // 5250 "D2" "MVC" "SS" 17
			"D3",  // 5260 "D3" "MVZ" "SS" 17
			"D4",  // 5270 "D4" "NC" "SS" 17
			"D5",  // 5280 "D5" "CLC" "SS" 17
			"D6",  // 5290 "D6" "OC" "SS" 17
			"D7",  // 5300 "D7" "XC" "SS" 17
			"D9",  // 5310 "D9" "MVCK" "SS" 17
			"DA",  // 5320 "DA" "MVCP" "SS" 17
			"DB",  // 5330 "DB" "MVCS" "SS" 17
			"DC",  // 5340 "DC" "TR" "SS" 17
			"DD",  // 5350 "DD" "TRT" "SS" 17
			"DE",  // 5360 "DE" "ED" "SS" 17
			"DF",  // 5370 "DF" "EDMK" "SS" 17
			"E00", // 5375 "E00" "XREAD" "RXSS" 38 RPI 812
			"E02", // 5375 "E02" "XPRNT" "RXSS" 38 RPI 812
			"E04", // 5375 "E04" "XPNCH" "RXSS" 38 RPI 812
			"E06", // 5375 "E06" "XDUMP" "RXSS" 38 RPI 812
			"E08", // 5375 "E08" "XLIMD" "RXSS" 38 RPI 812
			"E0A", // 5375 "E0A" "XGET"  "RXSS" 38 RPI 812
			"E0C", // 5375 "E0C" "XPUT"  "RXSS" 38 RPI 812
			"E1",  // 5380 "E1" "PKU" "RXSS" 17
			"E2",  // 5390 "E2" "UNPKU" "SS" 17
			"E302",  //      "E302" "LTG" "RXY" 18 Z9-42
			"E303",  // 5400 "E303" "LRAG" "RXY" 18
			"E304",  // 5410 "E304" "LG" "RXY" 18
			"E306",  // 5420 "E306" "CVBY" "RXY" 18
			"E308",  // 5430 "E308" "AG" "RXY" 18
			"E309",  // 5440 "E309" "SG" "RXY" 18
			"E30A",  // 5450 "E30A" "ALG" "RXY" 18
			"E30B",  // 5460 "E30B" "SLG" "RXY" 18
			"E30C",  // 5470 "E30C" "MSG" "RXY" 18
			"E30D",  // 5480 "E30D" "DSG" "RXY" 18
			"E30E",  // 5490 "E30E" "CVBG" "RXY" 18
			"E30F",  // 5500 "E30F" "LRVG" "RXY" 18
			"E312",  //      "E312" "LT" "RXY" 18 Z9-43
			"E313",  // 5510 "E313" "LRAY" "RXY" 18
			"E314",  // 5520 "E314" "LGF" "RXY" 18
			"E315",  // 5530 "E315" "LGH" "RXY" 18
			"E316",  // 5540 "E316" "LLGF" "RXY" 18
			"E317",  // 5550 "E317" "LLGT" "RXY" 18
			"E318",  // 5560 "E318" "AGF" "RXY" 18
			"E319",  // 5570 "E319" "SGF" "RXY" 18
			"E31A",  // 5580 "E31A" "ALGF" "RXY" 18
			"E31B",  // 5590 "E31B" "SLGF" "RXY" 18
			"E31C",  // 5600 "E31C" "MSGF" "RXY" 18
			"E31D",  // 5610 "E31D" "DSGF" "RXY" 18
			"E31E",  // 5620 "E31E" "LRV" "RXY" 18
			"E31F",  // 5630 "E31F" "LRVH" "RXY" 18
			"E320",  // 5640 "E320" "CG" "RXY" 18
			"E321",  // 5650 "E321" "CLG" "RXY" 18
			"E324",  // 5660 "E324" "STG" "RXY" 18
			"E326",  // 5670 "E326" "CVDY" "RXY" 18
			"E32E",  // 5680 "E32E" "CVDG" "RXY" 18
			"E32F",  // 5690 "E32F" "STRVG" "RXY" 18
			"E330",  // 5700 "E330" "CGF" "RXY" 18
			"E331",  // 5710 "E331" "CLGF" "RXY" 18
			"E332",  // 310 "E332" "LTGF" "RXY" 18 RPI 817
			"E334",  // 320 "E334" "CGH" "RXY" 18 RPI 817
			"E336",  // 330 "E336" "PFD" "RXY" 18 RPI 817
			"E33E",  // 5720 "E33E" "STRV" "RXY" 18
			"E33F",  // 5730 "E33F" "STRVH" "RXY" 18
			"E346",  // 5740 "E346" "BCTG" "RXY" 18
			"E350",  // 5750 "E350" "STY" "RXY" 18
			"E351",  // 5760 "E351" "MSY" "RXY" 18
			"E354",  // 5770 "E354" "NY" "RXY" 18
			"E355",  // 5780 "E355" "CLY" "RXY" 18
			"E356",  // 5790 "E356" "OY" "RXY" 18
			"E357",  // 5800 "E357" "XY" "RXY" 18
			"E358",  // 5810 "E358" "LY" "RXY" 18
			"E359",  // 5820 "E359" "CY" "RXY" 18
			"E35A",  // 5830 "E35A" "AY" "RXY" 18
			"E35B",  // 5840 "E35B" "SY" "RXY" 18
			"E35C",  // 340 "E35C" "MFY" "RXY" 18 RPI 817
			"E35E",  // 5850 "E35E" "ALY" "RXY" 18
			"E35F",  // 5860 "E35F" "SLY" "RXY" 18
			"E370",  // 5870 "E370" "STHY" "RXY" 18
			"E371",  // 5880 "E371" "LAY" "RXY" 18
			"E372",  // 5890 "E372" "STCY" "RXY" 18
			"E373",  // 5900 "E373" "ICY" "RXY" 18
			"E375",  // 350 "E375" "LAEY" "RXY" 18 RPI 817
			"E376",  // 5910 "E376" "LB" "RXY" 18
			"E377",  // 5920 "E377" "LGB" "RXY" 18
			"E378",  // 5930 "E378" "LHY" "RXY" 18
			"E379",  // 5940 "E379" "CHY" "RXY" 18
			"E37A",  // 5950 "E37A" "AHY" "RXY" 18
			"E37B",  // 5960 "E37B" "SHY" "RXY" 18
			"E37C",  // 360 "E37C" "MHY" "RXY" 18 RPI 817
			"E380",  // 5970 "E380" "NG" "RXY" 18
			"E381",  // 5980 "E381" "OG" "RXY" 18
			"E382",  // 5990 "E382" "XG" "RXY" 18
			"E386",  // 6000 "E386" "MLG" "RXY" 18
			"E387",  // 6010 "E387" "DLG" "RXY" 18
			"E388",  // 6020 "E388" "ALCG" "RXY" 18
			"E389",  // 6030 "E389" "SLBG" "RXY" 18
			"E38E",  // 6040 "E38E" "STPQ" "RXY" 18
			"E38F",  // 6050 "E38F" "LPQ" "RXY" 18
			"E390",  // 6060 "E390" "LLGC" "RXY" 18
			"E391",  // 6070 "E391" "LLGH" "RXY" 18
			"E394",  //      "E394" "LLC" "RXY" 18 Z9-44
			"E395",  //      "E395" "LLH" "RXY" 18 Z9-45
			"E396",  // 6080 "E396" "ML" "RXY" 18
			"E397",  // 6090 "E397" "DL" "RXY" 18
			"E398",  // 6100 "E398" "ALC" "RXY" 18
			"E399",  // 6110 "E399" "SLB" "RXY" 18
			"E3C0",  // "E3C0","LBH","RXY"   18  RPI 1125 Z196
			"E3C2",  // "E3C2","LLCH","RXY"  18  RPI 1125 Z196
			"E3C3",  // "E3C3","STCH","RXY"  18  RPI 1125 Z196
			"E3C4",  // "E3C4","LHH","RXY"   18  RPI 1125 Z196
			"E3C6",  // "E3C6","LLHH","RXY"  18  RPI 1125 Z196
			"E3C7",  // "E3C7","STHH","RXY"  18  RPI 1125 Z196
			"E3CA",  // "E3CA","LFH","RXY"   18  RPI 1125 Z196
			"E3CB",  // "E3CB","STFH","RXY"  18  RPI 1125 Z196
			"E3CD",  // "E3CD","CHF","RXY"   18  RPI 1125 Z196
			"E3CF",  // "E3CF","CLHF","RXY"  18  RPI 1125 Z196
			"E500",  // 6120 "E500" "LASP" "SSE" 19
			"E501",  // 6130 "E501" "TPROT" "SSE" 19
			"E502",  // 6140 "E502" "STRAG" "SSE" 19
			"E50E",  // 6150 "E50E" "MVCSK" "SSE" 19
			"E50F",  // 6160 "E50F" "MVCDK" "SSE" 19
			"E544",  // 370 "E544" "MVHHI" "SIL" 51 RPI 817
			"E548",  // 380 "E548" "MVGHI" "SIL" 51 RPI 817
			"E54C",  // 390 "E54C" "MVHI" "SIL" 51 RPI 817
			"E554",  // 400 "E554" "CHHSI" "SIL" 51 RPI 817
			"E555",  // 410 "E555" "CLHHSI" "SIL" 51 RPI 817
			"E558",  // 420 "E558" "CGHSI" "SIL" 51 RPI 817
			"E559",  // 430 "E559" "CLGHSI" "SIL" 51 RPI 817
			"E55C",  // 440 "E55C" "CHSI" "SIL" 51 RPI 817
			"E55D",  // 450 "E55D" "CLFHSI" "SIL" 51 RPI 817
			"E8",    // 6170 "E8" "MVCIN" "SS" 17
			"E9",    // 6180 "E9" "PKA" "SS" 31
			"EA",    // 6190 "EA" "UNPKA" "SS" 17
			"EB04",  // 6200 "EB04" "LMG" "RSY" 20
			"EB0A",  // 6210 "EB0A" "SRAG" "RSY" 20
			"EB0B",  // 6220 "EB0B" "SLAG" "RSY" 20
			"EB0C",  // 6230 "EB0C" "SRLG" "RSY" 20
			"EB0D",  // 6240 "EB0D" "SLLG" "RSY" 20
			"EB0F",  // 6250 "EB0F" "TRACG" "RSY" 20
			"EB14",  // 6260 "EB14" "CSY" "RSY" 20
			"EB1C",  // 6270 "EB1C" "RLLG" "RSY" 20
			"EB1D",  // 6280 "EB1D" "RLL" "RSY" 20
			"EB20",  // 6290 "EB20" "CLMH" "RSY" 20
			"EB21",  // 6300 "EB21" "CLMY" "RSY" 20
			"EB24",  // 6310 "EB24" "STMG" "RSY" 20
			"EB25",  // 6320 "EB25" "STCTG" "RSY" 20
			"EB26",  // 6330 "EB26" "STMH" "RSY" 20
			"EB2C",  // 6340 "EB2C" "STCMH" "RSY" 20
			"EB2D",  // 6350 "EB2D" "STCMY" "RSY" 20
			"EB2F",  // 6360 "EB2F" "LCTLG" "RSY" 20
			"EB30",  // 6370 "EB30" "CSG" "RSY" 20
			"EB31",  // 6380 "EB31" "CDSY" "RSY" 20
			"EB3E",  // 6390 "EB3E" "CDSG" "RSY" 20
			"EB44",  // 6400 "EB44" "BXHG" "RSY" 20
			"EB45",  // 6410 "EB45" "BXLEG" "RSY" 20
			"EB4C",  // 460 "EB4C" "ECAG" "RSY" 20 RPI 817
			"EB51",  // 6420 "EB51" "TMY" "SIY" 21
			"EB52",  // 6430 "EB52" "MVIY" "SIY" 21
			"EB54",  // 6440 "EB54" "NIY" "SIY" 21
			"EB55",  // 6450 "EB55" "CLIY" "SIY" 21
			"EB56",  // 6460 "EB56" "OIY" "SIY" 21
			"EB57",  // 6470 "EB57" "XIY" "SIY" 21
			"EB6A",  // 470 "EB6A" "ASI" "SIY" 21 RPI 817
			"EB6E",  // 480 "EB6E" "ALSI" "SIY" 21 RPI 817
			"EB7A",  // 490 "EB7A" "AGSI" "SIY" 21 RPI 817
			"EB7E",  // 500 "EB7E" "ALGSI" "SIY" 21 RPI 817
			"EB80",  // 6480 "EB80" "ICMH" "RSY" 20
			"EB81",  // 6490 "EB81" "ICMY" "RSY" 20
			"EB8E",  // 6500 "EB8E" "MVCLU" "RSY" 20
			"EB8F",  // 6510 "EB8F" "CLCLU" "RSY" 20
			"EB90",  // 6520 "EB90" "STMY" "RSY" 20
			"EB96",  // 6530 "EB96" "LMH" "RSY" 20
			"EB98",  // 6540 "EB98" "LMY" "RSY" 20
			"EB9A",  // 6550 "EB9A" "LAMY" "RSY" 20
			"EB9B",  // 6560 "EB9B" "STAMY" "RSY" 20
			"EBC0",  // 6570 "EBC0" "TP" "RSL" 22
			"EBDC",  //  "EBDC","SRAK","RSY  "  20 RPI 1125 Z196
			"EBDD",  //  "EBDD","SLAK","RSY  "  20 RPI 1125 Z196
			"EBDE",  //  "EBDE","SRLK","RSY  "  20 RPI 1125 Z196
			"EBDF",  //  "EBDF","SLLK","RSY  "  20 RPI 1125 Z196
			"EBE2",  //  "EBE2","LOCG","RSY2 "  20 RPI 1125 Z196
			"EBE3",  //  "EBE3","STOCG","RSY2 " 20 RPI 1125 Z196
			"EBE4",  //  "EBE4","LANG","RSY  "  20 RPI 1125 Z196
			"EBE6",  //  "EBE6","LAOG","RSY  "  20 RPI 1125 Z196
			"EBE7",  //  "EBE7","LAXG","RSY  "  20 RPI 1125 Z196
			"EBE8",  //  "EBE8","LAAG","RSY  "  20 RPI 1125 Z196
			"EBEA",  //  "EBEA","LAALG","RSY  " 20 RPI 1125 Z196
			"EBF2",  //  "EBF2","LOC","RSY2 "   20 RPI 1125 Z196
			"EBF3",  //  "EBF3","STOC","RSY2 "  20 RPI 1125 Z196
			"EBF4",  //  "EBF4","LAN","RSY  "   20 RPI 1125 Z196
			"EBF6",  //  "EBF6","LAO","RSY  "   20 RPI 1125 Z196
			"EBF7",  //  "EBF7","LAX","RSY  "   20 RPI 1125 Z196
			"EBF8",  //  "EBF8","LAA","RSY  "   20 RPI 1125 Z196
			"EBFA",  //  "EBFA","LAAL","RSY  "  20 RPI 1125 Z196
			"EC44",  // 6580 "EC44" "BRXHG" "RIE" 23
			"EC44",  // 6590 "EC44" "JXHG" "RIE" 23
			"EC45",  // 6600 "EC45" "BRXLG" "RIE" 23
			"EC45",  // 6610 "EC45" "JXLEG" "RIE" 23
			"EC51",  // "EC51","RISBLG#","RIE8"  52 RPI 1125 Z196  RPI 1164
			"EC51$003132",  // 'EC51$003132','LOAD (lOW  && HIGH) RISBLGZ','LLHFR','RIE8',52  RPI 1164
			"EC51$163132",  // 'EC51$163132','LOAD LOG HW (lOW  && HIGH) RISBLGZ','LLHLHR','RIE8',52  RPI 1164
			"EC51$243132",  // 'EC51$243132','LOAD LOG CH (lOW  && HIGH) RISBLGZ','LLCLHR','RIE8',52  RPI 1164
			"EC51Z", // "EC51Z","RISBLGZ","RIE8"  52 RPI 1125 Z196  RPI 1164
			"EC54",  // 510 "EC54" "RNSBG" "RIE8" 52 RPI 817
			"EC54$003100",     // 'EC54$003100','AND HIGH (HIGH && HIGH) RNSBG','NHHR','RIE8',52  RPI 1164
			"EC54$003132",     // 'EC54$003132','AND HIGH (HIGH && LOW ) RNSBG','NHLR','RIE8',52  RPI 1164
			"EC54$326332",     // 'EC54$326332','AND HIGH (lOW  && HIGH) RNSBG','NLHR','RIE8',52  RPI 1164
			"EC54T",  // 520 "EC54T" "RNSBGT" "RIE8" 52 RPI 817
			"EC55",  // 530 "EC55" "RISBG" "RIE8" 52 RPI 817
			"EC55Z",  // 540 "EC55Z" "RISBGZ" "RIE8" 52 RPI 817
			"EC56",  // 550 "EC56" "ROSBG" "RIE8" 52 RPI 817
			"EC56$003100",  // 'EC56$003100','OR  HIGH (HIGH && HIGH) ROSBG','OHHR','RIE8',52  RPI 1164
			"EC56$003132",  // 'EC56$003132','OR  HIGH (HIGH && LOW ) ROSBG','OHLR','RIE8',52  RPI 1164
			"EC56$326332",  // 'EC56$326332','OR  HIGH (lOW  && HIGH) ROSBG','OLHR','RIE8',52  RPI 1164
			"EC56T",  // 560 "EC56T" "ROSBGT" "RIE8" 52 RPI 817
			"EC57",  // 570 "EC57" "RXSBG" "RIE8" 52 RPI 817
			"EC57$003100",     // 'EC57$003100','XOR HIGH (HIGH && HIGH) RXSBG','XHHR','RIE8',52  RPI 1164
			"EC57$003132",     // 'EC57$003132','XOR HIGH (HIGH && LOW ) RXSBG','XHLR','RIE8',52  RPI 1164
			"EC57$326332",     // 'EC57$326332','AOR HIGH (lOW  && HIGH) RXSBG','XLHR','RIE8',52  RPI 1164
			"EC57T",  // 580 "EC57T" "RXSBGT" "RIE8" 52 RPI 817
			"EC5D",  // "EC5D","RISBHG#","RIE8"  52 RPI 1125 Z196 RPI 1164
			"EC5D$003100",  // 'EC5D$003100','LOAD (HIGH && HIGH) RISBHGZ','LHHR','RIE8',52  RPI 1164
			"EC5D$003132",  // 'EC5D$003132','LOAD (HIGH && LOW ) RISBHGZ','LHLR','RIE8',52  RPI 1164
			"EC5D$163100",  // 'EC5D$163100','LOAD LOG HW (HIGH && HIGH) RISBHGZ','LLHHHR','RIE8',52  RPI 1164
			"EC5D$163132",  // 'EC5D$163132','LOAD LOG HW (HIGH && LOW ) RISBHGZ','LLHHLR','RIE8',52  RPI 1164
			"EC5D$243100",  // 'EC5D$243100','LOAD LOG CH (HIGH && HIGH) RISBHGZ','LLCHHR','RIE8',52  RPI 1164
			"EC5D$243132",  // 'EC5D$243132','LOAD LOG CH (HIGH && LOW ) RISBHGZ','LLCHLR','RIE8',52  RPI 1164
			"EC5DZ", // "EC5DZ","RISBHGZ","RIE8"  52 RPI 1125 Z196  RPI 1164
			"EC64",  // 10 "EC64" "CGRJ" "RIE6" 49 RPI 817
			"EC648",  // 20 "EC648" "CGRJE" "RIE7" 50 RPI 817
			"EC642",  // 30 "EC642" "CGRJH" "RIE7" 50 RPI 817
			"EC644",  // 40 "EC644" "CGRJL" "RIE7" 50 RPI 817
			"EC646",  // 50 "EC646" "CGRJNE" "RIE7" 50 RPI 817
			"EC64C",  // 60 "EC64C" "CGRJNH" "RIE7" 50 RPI 817
			"EC64A",  // 70 "EC64A" "CGRJNL" "RIE7" 50 RPI 817
			"EC65",  // 80 "EC65" "CLGRJ" "RIE6" 49 RPI 817
			"EC658",  // 90 "EC658" "CLGRJE" "RIE7" 50 RPI 817
			"EC652",  // 100 "EC652" "CLGRJH" "RIE7" 50 RPI 817
			"EC654",  // 110 "EC654" "CLGRJL" "RIE7" 50 RPI 817
			"EC656",  // 120 "EC656" "CLGRJNE" "RIE7" 50 RPI 817
			"EC65C",  // 130 "EC65C" "CLGRJNH" "RIE7" 50 RPI 817
			"EC65A",  // 140 "EC65A" "CLGRJNL" "RIE7" 50 RPI 817		       
			"EC70",  // 150 "EC70" "CGIT" "RIE2" 41 RPI 817
			"EC708",  // 160 "EC708" "CGITE" "RIE3" 42 RPI 817
			"EC702",  // 170 "EC702" "CGITH" "RIE3" 42 RPI 817
			"EC704",  // 180 "EC704" "CGITL" "RIE3" 42 RPI 817
			"EC706",  // 190 "EC706" "CGITNE" "RIE3" 42 RPI 817
			"EC70C",  // 200 "EC70C" "CGITNH" "RIE3" 42 RPI 817
			"EC70A",  // 210 "EC70A" "CGITNL" "RIE3" 42 RPI 817
			"EC71",  // 150 "EC71" "CLGIT" "RIE2" 41 RPI 817
			"EC718",  // 160 "EC718" "CLGITE" "RIE3" 42 RPI 817
			"EC712",  // 170 "EC712" "CLGITH" "RIE3" 42 RPI 817
			"EC714",  // 180 "EC714" "CLGITL" "RIE3" 42 RPI 817
			"EC716",  // 190 "EC716" "CLGITNE" "RIE3" 42 RPI 817
			"EC71C",  // 200 "EC71C" "CLGITNH" "RIE3" 42 RPI 817
			"EC71A",  // 210 "EC71A" "CLGITNL" "RIE3" 42 RPI 817
			"EC72",  // 220 "EC72" "CIT" "RIE2" 41 RPI 817
			"EC728",  // 230 "EC728" "CITE" "RIE3" 42 RPI 817
			"EC722",  // 240 "EC722" "CITH" "RIE3" 42 RPI 817
			"EC724",  // 250 "EC724" "CITL" "RIE3" 42 RPI 817
			"EC726",  // 260 "EC726" "CITNE" "RIE3" 42 RPI 817
			"EC72C",  // 270 "EC72C" "CITNH" "RIE3" 42 RPI 817
			"EC72A",  // 280 "EC72A" "CITNL" "RIE3" 42 RPI 817
			"EC73",  // 220 "EC73" "CLFIT" "RIE2" 41 RPI 817
			"EC738",  // 230 "EC738" "CLFITE" "RIE3" 42 RPI 817
			"EC732",  // 240 "EC732" "CLFITH" "RIE3" 42 RPI 817
			"EC734",  // 250 "EC734" "CLFITL" "RIE3" 42 RPI 817
			"EC736",  // 260 "EC736" "CLFITNE" "RIE3" 42 RPI 817
			"EC73C",  // 270 "EC73C" "CLFITNH" "RIE3" 42 RPI 817
			"EC73A",  // 280 "EC73A" "CLFITNL" "RIE3" 42 RPI 817
			"EC76",  // 150 "EC76" "CRJ" "RIE6" 49 RPI 817
			"EC768",  // 160 "EC768" "CRJE" "RIE7" 50 RPI 817
			"EC762",  // 170 "EC762" "CRJH" "RIE7" 50 RPI 817
			"EC764",  // 180 "EC764" "CRJL" "RIE7" 50 RPI 817
			"EC766",  // 190 "EC766" "CRJNE" "RIE7" 50 RPI 817
			"EC76C",  // 200 "EC76C" "CRJNH" "RIE7" 50 RPI 817
			"EC76A",  // 210 "EC76A" "CRJNL" "RIE7" 50 RPI 817
			"EC77",  // 220 "EC77" "CLRJ" "RIE6" 49 RPI 817
			"EC778",  // 230 "EC778" "CLRJE" "RIE7" 50 RPI 817
			"EC772",  // 240 "EC772" "CLRJH" "RIE7" 50 RPI 817
			"EC774",  // 250 "EC774" "CLRJL" "RIE7" 50 RPI 817
			"EC776",  // 260 "EC776" "CLRJNE" "RIE7" 50 RPI 817
			"EC77C",  // 270 "EC77C" "CLRJNH" "RIE7" 50 RPI 817
			"EC77A",  // 280 "EC77A" "CLRJNL" "RIE7" 50 RPI 817
			"EC7C",  // 290 "EC7C" "CGIJ" "RIE4" 43 RPI 817
			"EC7C8",  // 300 "EC7C8" "CGIJE" "RIE5" 44 RPI 817
			"EC7C2",  // 310 "EC7C2" "CGIJH" "RIE5" 44 RPI 817
			"EC7C4",  // 320 "EC7C4" "CGIJL" "RIE5" 44 RPI 817
			"EC7C6",  // 330 "EC7C6" "CGIJNE" "RIE5" 44 RPI 817
			"EC7CC",  // 340 "EC7CC" "CGIJNH" "RIE5" 44 RPI 817
			"EC7CA",  // 350 "EC7CA" "CGIJNL" "RIE5" 44 RPI 817
			"EC7D",  // 360 "EC7D" "CLGIJ" "RIE4" 43 RPI 817
			"EC7D8",  // 370 "EC7D8" "CLGIJE" "RIE5" 44 RPI 817
			"EC7D2",  // 380 "EC7D2" "CLGIJH" "RIE5" 44 RPI 817
			"EC7D4",  // 390 "EC7D4" "CLGIJL" "RIE5" 44 RPI 817
			"EC7D6",  // 400 "EC7D6" "CLGIJNE" "RIE5" 44 RPI 817
			"EC7DC",  // 410 "EC7DC" "CLGIJNH" "RIE5" 44 RPI 817
			"EC7DA",  // 420 "EC7DA" "CLGIJNL" "RIE5" 44 RPI 817
			"EC7E",  // 430 "EC7E" "CIJ" "RIE4" 43 RPI 817
			"EC7E8",  // 440 "EC7E8" "CIJE" "RIE5" 44 RPI 817
			"EC7E2",  // 450 "EC7E2" "CIJH" "RIE5" 44 RPI 817
			"EC7E4",  // 460 "EC7E4" "CIJL" "RIE5" 44 RPI 817
			"EC7E6",  // 470 "EC7E6" "CIJNE" "RIE5" 44 RPI 817
			"EC7EC",  // 480 "EC7EC" "CIJNH" "RIE5" 44 RPI 817
			"EC7EA",  // 490 "EC7EA" "CIJNL" "RIE5" 44 RPI 817
			"EC7F",  // 500 "EC7F" "CLIJ" "RIE4" 43 RPI 817
			"EC7F8",  // 510 "EC7F8" "CLIJE" "RIE5" 44 RPI 817
			"EC7F2",  // 520 "EC7F2" "CLIJH" "RIE5" 44 RPI 817
			"EC7F4",  // 530 "EC7F4" "CLIJL" "RIE5" 44 RPI 817
			"EC7F6",  // 540 "EC7F6" "CLIJNE" "RIE5" 44 RPI 817
			"EC7FC",  // 550 "EC7FC" "CLIJNH" "RIE5" 44 RPI 817
			"EC7FA",  // 560 "EC7FA" "CLIJNL" "RIE5" 44 RPI 817
			"ECD8",  // "ECD8","AHIK","RIE9"    57 RPI 1125 Z196
			"ECD9",  // "ECD9","AGHIK","RIE9"   57 RPI 1125 Z196
			"ECDA",  // "ECDA","ALHSIK","RIE9"  57 RPI 1125 Z196
			"ECDB",  // "ECDB","ALGHSIK","RIE9" 57 RPI 1125 Z196
			"ECE4",  // 570 "ECE4" "CGRB" "RRS1" 45 RPI 817
			"ECE48",  // 580 "ECE48" "CGRBE" "RRS2" 46 RPI 817
			"ECE42",  // 590 "ECE42" "CGRBH" "RRS2" 46 RPI 817
			"ECE44",  // 600 "ECE44" "CGRBL" "RRS2" 46 RPI 817
			"ECE46",  // 610 "ECE46" "CGRBNE" "RRS2" 46 RPI 817
			"ECE4C",  // 620 "ECE4C" "CGRBNH" "RRS2" 46 RPI 817
			"ECE4A",  // 630 "ECE4A" "CGRBNL" "RRS2" 46 RPI 817
			"ECE5",  // 640 "ECE5" "CLGRB" "RRS1" 45 RPI 817
			"ECE58",  // 650 "ECE58" "CLGRBE" "RRS2" 46 RPI 817
			"ECE52",  // 660 "ECE52" "CLGRBH" "RRS2" 46 RPI 817
			"ECE54",  // 670 "ECE54" "CLGRBL" "RRS2" 46 RPI 817
			"ECE56",  // 680 "ECE56" "CLGRBNE" "RRS2" 46 RPI 817
			"ECE5C",  // 690 "ECE5C" "CLGRBNH" "RRS2" 46 RPI 817
			"ECE5A",  // 700 "ECE5A" "CLGRBNL" "RRS2" 46 RPI 817
			"ECF6",  // 710 "ECF6" "CRB" "RRS1" 45 RPI 817
			"ECF68",  // 720 "ECF68" "CRBE" "RRS2" 46 RPI 817
			"ECF62",  // 730 "ECF62" "CRBH" "RRS2" 46 RPI 817
			"ECF64",  // 740 "ECF64" "CRBL" "RRS2" 46 RPI 817
			"ECF66",  // 750 "ECF66" "CRBNE" "RRS1" 45 RPI 817
			"ECF6C",  // 760 "ECF6C" "CRBNH" "RRS2" 46 RPI 817
			"ECF6A",  // 770 "ECF6A" "CRBNL" "RRS2" 46 RPI 817
			"ECF7",  // 780 "ECF7" "CLRB" "RRS1" 45 RPI 817
			"ECF78",  // 790 "ECF78" "CLRBE" "RRS2" 46 RPI 817
			"ECF72",  // 800 "ECF72" "CLRBH" "RRS2" 46 RPI 817
			"ECF74",  // 810 "ECF74" "CLRBL" "RRS2" 46 RPI 817
			"ECF76",  // 820 "ECF76" "CLRBNE" "RRS2" 46 RPI 817
			"ECF7C",  // 830 "ECF7C" "CLRBNH" "RRS2" 46 RPI 817
			"ECF7A",  // 840 "ECF7A" "CLRBNL" "RRS2" 46 RPI 817
			"ECFC",  // 850 "ECFC" "CGIB" "RRS3" 47 RPI 817
			"ECFC8",  // 860 "ECFC8" "CGIBE" "RRS4" 48 RPI 817
			"ECFC2",  // 870 "ECFC2" "CGIBH" "RRS4" 48 RPI 817
			"ECFC4",  // 880 "ECFC4" "CGIBL" "RRS4" 48 RPI 817
			"ECFC6",  // 890 "ECFC6" "CGIBNE" "RRS4" 48 RPI 817
			"ECFCC",  // 900 "ECFCC" "CGIBNH" "RRS4" 48 RPI 817
			"ECFCA",  // 910 "ECFCA" "CGIBNL" "RRS4" 48 RPI 817
			"ECFD",  // 920 "ECFD" "CLGIB" "RRS3" 47 RPI 817
			"ECFD8",  // 930 "ECFD8" "CLGIBE" "RRS4" 48 RPI 817
			"ECFD2",  // 940 "ECFD2" "CLGIBH" "RRS4" 48 RPI 817
			"ECFD4",  // 950 "ECFD4" "CLGIBL" "RRS4" 48 RPI 817
			"ECFD6",  // 960 "ECFD6" "CLGIBNE" "RRS4" 48 RPI 817
			"ECFDC",  // 970 "ECFDC" "CLGIBNH" "RRS4" 48 RPI 817
			"ECFDA",  // 980 "ECFDA" "CLGIBNL" "RRS4" 48 RPI 817
			"ECFE",  // 990 "ECFE" "CIB" "RRS3" 47 RPI 817
			"ECFE8",  // 1000 "ECFE8" "CIBE" "RRS4" 48 RPI 817
			"ECFE2",  // 1010 "ECFE2" "CIBH" "RRS4" 48 RPI 817
			"ECFE4",  // 1020 "ECFE4" "CIBL" "RRS4" 48 RPI 817
			"ECFE6",  // 1030 "ECFE6" "CIBNE" "RRS4" 48 RPI 817
			"ECFEC",  // 1040 "ECFEC" "CIBNH" "RRS4" 48 RPI 817
			"ECFEA",  // 1050 "ECFEA" "CIBNL" "RRS4" 48 RPI 817
			"ECFF",  // 1060 "ECFF" "CLIB" "RRS3" 47 RPI 817
			"ECFF8",  // 1070 "ECFF8" "CLIBE" "RRS4" 48 RPI 817
			"ECFF2",  // 1080 "ECFF2" "CLIBH" "RRS4" 48 RPI 817
			"ECFF4",  // 1090 "ECFF4" "CLIBL" "RRS4" 48 RPI 817
			"ECFF6",  // 1100 "ECFF6" "CLIBNE" "RRS4" 48 RPI 817
			"ECFFC",  // 1110 "ECFFC" "CLIBNH" "RRS4" 48 RPI 817
			"ECFFA",  // 1120 "ECFFA" "CLIBNL" "RRS4" 48 RPI 817		       
			"ED04",  // 6620 "ED04" "LDEB" "RXE" 24
			"ED05",  // 6630 "ED05" "LXDB" "RXE" 24
			"ED06",  // 6640 "ED06" "LXEB" "RXE" 24
			"ED07",  // 6650 "ED07" "MXDB" "RXE" 24
			"ED08",  // 6660 "ED08" "KEB" "RXE" 24
			"ED09",  // 6670 "ED09" "CEB" "RXE" 24
			"ED0A",  // 6680 "ED0A" "AEB" "RXE" 24
			"ED0B",  // 6690 "ED0B" "SEB" "RXE" 24
			"ED0C",  // 6700 "ED0C" "MDEB" "RXE" 24
			"ED0D",  // 6710 "ED0D" "DEB" "RXE" 24
			"ED0E",  // 6720 "ED0E" "MAEB" "RXF" 25
			"ED0F",  // 6730 "ED0F" "MSEB" "RXF" 25
			"ED10",  // 6740 "ED10" "TCEB" "RXE" 24
			"ED11",  // 6750 "ED11" "TCDB" "RXE" 24
			"ED12",  // 6760 "ED12" "TCXB" "RXE" 24
			"ED14",  // 6770 "ED14" "SQEB" "RXE" 24
			"ED15",  // 6780 "ED15" "SQDB" "RXE" 24
			"ED17",  // 6790 "ED17" "MEEB" "RXE" 24
			"ED18",  // 6800 "ED18" "KDB" "RXE" 24
			"ED19",  // 6810 "ED19" "CDB" "RXE" 24
			"ED1A",  // 6820 "ED1A" "ADB" "RXE" 24
			"ED1B",  // 6830 "ED1B" "SDB" "RXE" 24
			"ED1C",  // 6840 "ED1C" "MDB" "RXE" 24
			"ED1D",  // 6850 "ED1D" "DDB" "RXE" 24
			"ED1E",  // 6860 "ED1E" "MADB" "RXF" 25
			"ED1F",  // 6870 "ED1F" "MSDB" "RXF" 25
			"ED24",  // 6880 "ED24" "LDE" "RXE" 24
			"ED25",  // 6890 "ED25" "LXD" "RXE" 24
			"ED26",  // 6900 "ED26" "LXE" "RXE" 24
			"ED2E",  // 6910 "ED2E" "MAE" "RXF" 25
			"ED2F",  // 6920 "ED2F" "MSE" "RXF" 25
			"ED34",  // 6930 "ED34" "SQE" "RXE" 24
			"ED35",  // 6940 "ED35" "SQD" "RXE" 24
			"ED37",  // 6950 "ED37" "MEE" "RXE" 24
			"ED38",  //      "ED38" "MAYL" "RXF" 25 Z9-46
			"ED39",  //      "ED39" "MYL" "RXF" 25 Z9-47
			"ED3A",  //      "ED3A" "MAY" "RXF" 25 Z9-48
			"ED3B",  //      "ED3B" "MY" "RXF" 25 Z9-49  RPI 298
			"ED3C",  //      "ED3C" "MAYH" "RXF" 25 Z9-50
			"ED3D",  //      "ED3D" "MYH" "RXF" 25 Z9-51  RPI 298
			"ED3E",  // 6960 "ED3E" "MAD" "RXF" 25
			"ED3F",  // 6970 "ED3F" "MSD" "RXF" 25
			"ED40", // "SLDT" "RXF" DFP 45
			"ED41", // "SRDT" "RXF" DFP 46
			"ED48", // "SLXT" "RXF" DFP 47
			"ED49", // "SRXT" "RXF" DFP 48
			"ED50", // "TDCET" "RXE" DFP 49
			"ED51", // "TDGET" "RXE" DFP 50
			"ED54", // "TDCDT" "RXE" DFP 51
			"ED55", // "TDGDT" "RXE" DFP 52
			"ED58", // "TDCXT" "RXE" DFP 53
			"ED59", // "TDGXT" "RXE" DFP 54
			"ED64",  // 6980 "ED64" "LEY" "RXY" 18
			"ED65",  // 6990 "ED65" "LDY" "RXY" 18
			"ED66",  // 7000 "ED66" "STEY" "RXY" 18
			"ED67",  // 7010 "ED67" "STDY" "RXY" 18
			"EE",  // 7020 "EE" "PLO" "SS3" 27
			"EF",  // 7030 "EF" "LMD" "SS4" 28
			"F0",  // 7040 "F0" "SRP" "SS5" 29
			"F1",  // 7050 "F1" "MVO" "SS2" 26
			"F2",  // 7060 "F2" "PACK" "SS2" 26
			"F3",  // 7070 "F3" "UNPK" "SS2" 26
			"F8",  // 7080 "F8" "ZAP" "SS2" 26
			"F9",  // 7090 "F9" "CP" "SS2" 26
			"FA",  // 7100 "FA" "AP" "SS2" 26
			"FB",  // 7110 "FB" "SP" "SS2" 26
			"FC",  // 7120 "FC" "MP" "SS2" 26
			"FD",  // 7130 "FD" "DP" "SS2" 26
	};
}
