#! /bin/sh
#
# infoStereo.sh - Shell-script para consultar posición de la tierra desde la pagina "Where is STEREO?"
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

# Direccion pagina "Where is STEREO?"
url="http://stereo-ssc.nascom.nasa.gov/cgi-bin/make_where_gif"

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

# Consulta, otro modo
#wget --post-data "day=${dd}&month=${MM}&year=${AA}&hour=${hh}&minute=${mm}" -O test.txt $url

# Distancia Heliocentrica
RH=`wget -q --post-data "day=${DD}&month=${MM}&year=${AA}&hour=${hh}&minute=${mm}" -O - $url | grep 'Heliocentric distance' | awk '{print $5}'`
# Longitud Ecliptica respecto al punto de Aries
HAE=`wget -q --post-data "day=${DD}&month=${MM}&year=${AA}&hour=${hh}&minute=${mm}" -O - $url | grep 'HAE longitude' | awk '{print $4}'`
echo "$RH $HAE 0.0"
