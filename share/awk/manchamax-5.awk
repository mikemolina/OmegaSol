# manchamax-5.awk - Busca la mancha de area maxima entre 1530 < x < 1700
#
#
#    Copyright (C) 2015  Miguel Molina
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
{
    if ($3>1530 && $3<1700)
	if ($NF>amax)
	    amax=$NF
}
END { print amax }
