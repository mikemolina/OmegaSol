#! /usr/bin/perl
# 
# centrado.pl - Busqueda del centro del disco solar y centroide de una mancha solar
#
# SINOPSIS
#    centrado.pl imagen-ascii-PNM > archivo-datos
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

use Math::Trig;

die "No existe archivo...\n" unless $ARGV[0];

# Depuracion: 0, 1, 2
$debug=0;

# Corte del degradado de disco; depende de la resolucion de la imagen
$cutdeg=30;

# Intensidad maxima en la umbra de la mancha solar
$IMAXUMS=15;

# Columna -> x
# Fila -> y
# xmin:= pixel no nulo extremo izquierdo
# xmax:= pixel no nulo extremo derecho
# ymin:= pixel no nulo extremo superior
# ymax:= pixel no nulo extremo inferior
# DXMAX:= distancia maxima de separacion en X
# fila_DXMAX:= fila que posee DXMAX
# centroX:= (xmin+xmax)/2
# centroY:= (ymin+ymax)/2

$DXMAX=0;
$linea=0;
$ymin=0;
$ymax=0;
$cont=0;

while(<>){
    @arreglo=split;
#   Ancho imagen
    $W=$arreglo[0] if $linea == 1;
    if( $linea >= 3 ){
	$iy=$linea-2;
#       Busqueda xmin, ymin, ymax
	$xmin=0;
	for( $ix=1; $ix <= $W; $ix++ ){
	    $px=$arreglo[$ix-1];
	    if( $px !~ /0/ ){
		$xmin=$ix if $xmin == 0;
		$ymin=$iy if $ymin == 0;
		$ymax=$iy if $iy > $ymax;
		last;
	    }
	}
#       Busqueda xmax
	$xmax=0;
	for( $ix=$W; $ix>=1; $ix-- ){
	    $px=$arreglo[$ix-1];
	    if( $px !~ /0/ ){
		$xmax=$ix if $xmax == 0;
		last;
	    }
	}
	$distX=$xmax-$xmin;
#       Centrado en X
	if( $distX > $DXMAX ){
	    $DXMAX=$distX;
	    $fila_DXMAX=$iy;
	    $xmin0=$xmin;
	    $xmax0=$xmax;
	}
#       Busqueda de mancha.
#       La busqueda se realiza en una "region tropical solar" de 5/16 de H por
#       encima(debajo) del ecuador solar con el fin de evitar la lectura de
#       "falso positivo" de mancha solar, sobre en todo en las regiones polares.
#       Para superar el efecto de degradado del limbo solar el parametro cutdeg
#       permite recortar el degradado y buscar la mancha en una region
#       $xmin+$cutdeg <= $ix <= $xmax-$cutdeg.
	if( ($iy >= 768) && ($iy <= 3328) ){
	    for( $ix=$xmin+$cutdeg; $ix <= $xmax-$cutdeg; $ix++ ){
		$px=$arreglo[$ix-1];
		if( $px <= $IMAXUMS ){
		    $rad=sqrt($ix*$ix+$iy*$iy);
		    $theta=rad2deg(atan2($iy,$ix));
		    $Data[$cont]=[$ix,$iy,$rad,$theta,$px];
		    print "Pixel manchado! Data(n, X, -Y, r, -theta, I) = ($cont, $ix, $iy, $rad, $theta, $px)\n" if $debug == 2;
		    $cont++;
		}
	    }
	}
    }
    $linea++;
#   Evitar lectura de texto en la parte inferior-izquierda
    last if $iy == 4050;
}

# Centro del disco
$centroX=($xmax0+$xmin0)*0.5;
$centroY=($ymax+$ymin)*0.5;

print "$centroX $centroY\n" if $debug == 0;
if( $debug == 1 ){
    $DYMAX=$ymax-$ymin;
    print "Lineas: $linea, Fila DXMAX: $fila_DXMAX\n";
    print "xmin=$xmin0, xmax=$xmax0, centro X0 = $centroX, distX=$DXMAX\n";
    print "ymin=$ymin, ymax=$ymax, centro Y0 = $centroY, distY=$DYMAX\n";
}

# Ordenar arreglo de "pixeles manchados" por radio ascendente
@Data = sort { $a->[2] <=> $b->[2] } @Data;

# Muestra posicion de "pixeles manchados"
if( $debug == 1 ){
    print "------------------------------------------------\n";
    print "pixel  x  -y  rad  -theta  intensidad\n";
    print "------------------------------------------------\n";
    for( $in=0; $in<$cont; $in++ ){
	print "$in ";
	for( $idat=0; $idat<5; $idat++ ){
	    print "$Data[$in][$idat] ";
	}
	print "\n";
    }
}

# Centroide de mancha i-esima
if( $debug == 0 ){
    @mancha=&centroide(@Data);
    for( $in=0; $in<=$#mancha; $in++ ){
	print "$in ";
	for( $idat=0; $idat<3; $idat++ ){
	    print "$mancha[$in][$idat] ";
	}
	print "\n";
    }
}


##############################
# Centroide de la mancha solar
##############################
sub centroide{
    my @sdat=@_;
    my @cent_ms;
    my $sxc, $syc, $srad, $sradant, $scont, $sn, $sdat, $si;
    $sxc=$sdat[0][0];
    $syc=$sdat[0][1];
    $sradant=$sdat[0][2];
    $scont=1;
    $si=0;
    for($sn=1; $sn<=$#sdat; $sn++){
	$srad=$sdat[$sn][2];
	if( $srad-$sradant <= 2 ){
	    # Pixeles vecinos
	    $sradant=$srad;
	    $sxc+=$sdat[$sn][0];
	    $syc+=$sdat[$sn][1];
	    $scont++;
	}else{
	    # Pixeles NO vecinos
	    $cent_ms[$si][0]=$sxc/$scont;
	    $cent_ms[$si][1]=$syc/$scont;
	    $cent_ms[$si][2]=$scont;
	    $sradant=$srad;
	    $sxc=$sdat[$sn][0];
	    $syc=$sdat[$sn][1];
	    $scont=1;
	    $si++;
	}
    }
    # Ultima mancha
    $cent_ms[$si][0]=$sxc/$scont;
    $cent_ms[$si][1]=$syc/$scont;
    $cent_ms[$si][2]=$scont;
    # centroide mancha solar:
    # cent_ms[0] -> centroide x [px],
    # cent_ms[1] -> centroide y [px],
    # cent_ms[2] -> area [px^2]
    return @cent_ms;
}
