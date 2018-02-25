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
 * GUAM view type enums
 * 
 * @author jba68/z390
 */
public enum GuamViewTypes {
	NONE(0),
	MCS(1),
	SCREEN(2),
	GRAPH(3);
	
	private final int view_type;

	private GuamViewTypes(final int vt) {
		view_type = vt;
	}

	public int getViewTypeNumber() {
		return view_type;
	}

	public static GuamViewTypes fromInteger(final int vt) {
		switch(vt) {
		case 1: return MCS;
		case 2: return SCREEN;
		case 3: return GRAPH;
		default:
		case 0: return NONE;
		}
	}
}
