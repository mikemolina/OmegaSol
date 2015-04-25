#! /bin/sh
#
# gendata.sh - Automatizacion de programas para determinar posicion de mancha solar
#
# SINOPSIS
#   gendata.sh [directorio imgs] [archivo datos]
#
# Notas
#  * Rutina para mostrar centro de una mancha mas grande que un area minima (AMINMS),
#    guardando (xcm, ycm, area) en la varible MSRC
#    MSRC="$(sed -e '1d' $1.txt | awk '$NF > tmin {print $2, $3, $NF}' tmin=$AMINMS)"
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

# Depuracion
debug="0"

# Funcion conversion jpg -> pgm-arreglada
jpg2pgmarray() {
   input="$1"
   output="$(basename $1 .jpg)"
   output="${output}.pgm"
   jpegtopnm $input 2>/dev/null | ppmtopgm | pnmnoraw > t.pgm
   ./pnmarray.pl t.pgm > $output
   rm -f t.pgm
}

# Funcion para obtener datos de centrado
getdatacentro() {
   pgmfile="${1%.jpg}"
   pgmfile="${pgmfile}.pgm"
   ./centrado.pl "$pgmfile" > "$2.txt"
   rm -f "$pgmfile"
}

# Funcion para conversion cadena tiempo -> fecha formato YYYY-MM-DD hh:mm
cadt2fecha() {
   YY="$(echo $1 | cut -b 1-4)"
   MM="$(echo $1 | cut -b 5-6)"
   DD="$(echo $1 | cut -b 7-8)"
   hh="$(echo $1 | cut -b 10-11)"
   mm="$(echo $1 | cut -b 12-13 | sed -e 's/0\([0-9]\)/\1/')"
   ss="$(echo $1 | cut -b 14-15 | sed -e 's/0\([0-9]\)/\1/')"
#  Redondeo en minutos
#  Cuidado! Bug cuando lista imagenes contiene minuto 59.
#  Ver con: ls LSTIMG | cut -b 12-15 | grep '^59'
   if [ $ss -ge 30 ]; then
      mm=$(($mm+1))
   fi
   if [ $mm -lt 10 ]; then
      mm="0${mm}"
   fi
   echo "${YY}-${MM}-${DD} ${hh}:${mm}"
}

# Funcion para obtener coordenadas topocentricas
getcoortopcent() {
   arg="AD,$(cadt2fecha $1 | sed -e 's/-\|[[:space:]]/,/g'):00"
   FJM=`kalendas --calc2FJM "($arg)" | sed -e 's/MJD = //'`
#  Muestra centro disco: SOLRC(xcs, ycs)
   SOLRC="$(sed -n -e '1p' $1.txt)"
#  Muestra centro de la mancha mas grande; MSRC(xcm, ycm, area)
   AMAXMS="$(sed -e '1d' $1.txt | awk -f ../share/awk/manchamax-5.awk)"
   MSRC="$(awk -v tammax=$AMAXMS '$NF ~ "^"tammax"$" { print $2, $3, $NF }' $1.txt)"
   if [ "$debug" = "1" ]; then
      echo "Fecha, centro disco solar, centroide mancha solar, area, tiempo:" >> log.txt
      echo "$1 $SOLRC $MSRC $FJM" >> log.txt
   fi
#  Transformacion de coordenadas: rp = R[reflexion-x].(rcm-rcs)
   echo "$SOLRC $MSRC $FJM" | awk \
       'function xp(xcm,xcs){ return xcm-xcs; } \
        function yp(ycm,ycs){ return -ycm+ycs; } \
        { printf("%11.5f %6.1f %6.1f\n", $6, xp($3,$1), yp($4,$2)) }'
}

# Funcion para obtener coordenadas eclipticas heliocentricas de la tierra
# Consulta desde la paqina web de STEREO
getcoortierra() {
   arg="$(cadt2fecha $1)"
   CEHT=`./infoStereo.sh $arg`
   echo "$CEHT"
}

# Funcion para obtener coordenadas ECI geocentricas del satelite SDO
getcoorsdo() {
   arg="$(cadt2fecha $1)"
   CGS=`./infoSDO.sh $arg`
   echo "$CGS"
}

# Ayuda
if [ $# -lt 2 -o $# -gt 2 ]; then
   echo "Uso: `basename \"$0\"` [directorio imagenes] [archivo datos]" 1>&2
   exit 1
fi

# Directorio de imagenes
if [ -d "$1" ]; then
   IMGDIR="$(cd "$1" > /dev/null; pwd)"
   if ls $IMGDIR/*.jpg > /dev/null 2>&1
   then
      echo "Directorio imagenes: $IMGDIR"
   else
      echo "Directorio \"$IMGDIR\" no contiene imagenes."
      exit 1
   fi
else
   echo "No existe directorio \"$1\"."
   exit 1
fi

# Lista de imagenes
LSTIMG="$(ls $IMGDIR | sort)"
echo "Numero de imagenes a procesar: $(echo $LSTIMG | wc -w)"

# Archivo de salida
OUTDATA="$2"
test -f "$OUTDATA" && rm -f "$OUTDATA"
test -f log.txt && rm -f log.txt

####################
# Rutina Principal #
####################
for img in $LSTIMG
do
   fecha="${img%_4096_HMII.jpg}"
   echo "Procesando imagen < $fecha >"
   echo "   Analizando imagen $fecha ..."
   jpg2pgmarray "${IMGDIR}/${img}"
   getdatacentro "$img" "$fecha"
   DAT1="$(getcoortopcent $fecha)"
   echo "$DAT1" | sed -e 's/[[:space:]]\+/\n/g' > input-${fecha}.txt
   echo "   consultando posicion de la tierra ..."
   DAT2="$(getcoortierra $fecha)"
   echo $DAT2 | sed -e 's/[[:space:]]\+/\n/g' >> input-${fecha}.txt
   echo "   consultando posicion del satelite ..."
   DAT3="$(getcoorsdo $fecha)"
   echo $DAT3 | sed -e 's/[[:space:]]\+/\n/g' >> input-${fecha}.txt
   echo "   hallando coordenadas de la mancha ..."
   ./rimg2resf < input-${fecha}.txt >> $OUTDATA
   rm -f ${fecha}.txt input-${fecha}.txt
done 
