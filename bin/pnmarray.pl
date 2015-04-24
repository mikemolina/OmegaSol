#! /usr/bin/perl
#
# pnmarray.pl - Crea imagen PNM ascii (decimal) en un arreglo WxH
#
# SINOPSIS
#   pnmarray.pl img-PNM > img-PNM-array
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

die "No existe archivo...\n" unless $ARGV[0];

$linea=0;
$cont=0;
while(<>){
    @arreglo=split;
    $W=$arreglo[0] if $linea == 1;
    if( $linea >= 3 ){
	$cont+=1+$#arreglo;
	if( $cont < $W ){
	    push(@fila,@arreglo);
	}elsif( $cont == $W ){
	    push(@fila,@arreglo);
	    print "@fila\n";
	    $cont=0;
	    @fila=();
	}
    }else{
	print "@arreglo\n";
    }
    $linea++;
}
