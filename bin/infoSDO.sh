#! /bin/sh
#
# infoSDO.sh -Shell-script para consultar la posicion del satelite SDO
#
# Fuente efemerides: http://ssd.jpl.nasa.gov/horizons.cgi
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

# Direccion archivo de datos efemerides SDO
srcdata="../share/efemerides/efemerides_SDO-ICEJ2000-feb.txt.gz"

if [ $# -le 1 ]; then
    echo "Uso: $0 YYYY-MM-DD hh:mm"
    exit 1
fi

# Year
AA=`echo $1 | sed 's/\([0-9]*\)-[0-9]*-[0-9]*/\1/'`
# Mes
MM=`echo $1 | sed 's/[0-9]*-\([0-9]*\)-[0-9]*/\1/'`
# Dia
DD=`echo $1 | sed 's/[0-9]*-[0-9]*-\([0-9]*\)/\1/'`
# Hora
hh=`echo $2 | sed 's/\([0-9]*\):[0-9]*/\1/'`
# Minuto  
mm=`echo $2 | sed 's/[0-9]*:\([0-9]*\)/\1/'`

# Nombre del mes abreviado
case ${MM} in
  01) MM="Jan";;
  02) MM="Feb";;
  03) MM="Mar";;
  04) MM="Apr";;
  05) MM="May";;
  06) MM="Jun";;
  07) MM="Jul";;
  08) MM="Aug";;
  09) MM="Sep";;
  10) MM="Oct";;
  11) MM="Nov";;
  12) MM="Dec";;
esac

linea=`zcat $srcdata | sed -e '1,90d' | grep --color=never -n "${AA}-${MM}-${DD} ${hh}:${mm}" | sed -e 's/\([0-9]\+\).*/\1/'`
r=`zcat $srcdata | sed -e '1,90d' | sed -n -e "$(($linea+1))p" | awk '{print $1, $2, $3}'`
echo "$r"
