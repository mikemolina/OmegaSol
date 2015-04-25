C -*- Fortran -*-
C f77
C
C rimg2resf-corr.f - Conversion coordenadas imagen (topocentricas) a esfericas
C
C SINOPSIS
C   rimg2resf < archivo-datos-entrada > archivo-datos-salida
C
C DESCRIPCION
C El archivo de datos debe contener los siguientes datos en su respectivo orden:
C   - tiempo en FJM (d).
C   - posicion (x,y) en pixeles de la mancha solar.
C   - coordenadas eclipticas heliocentricas de la tierra (sistema HAE). r en UA,
C     angulos en grados; latitud ecliptica de la tierra aproximadamente 0 grados
C     por definicion.
C   - coordenadas cartesianas geocentricas del SDO (sistema ECI). xi en Km.
C El programa entrega en su respectivo orden: tiempo corregido, coordenadas
C cartesianas y esfericas de la mancha.
C
C
C    Copyright (C) 2015  Miguel Molina
C
C    This program is free software: you can redistribute it and/or modify
C    it under the terms of the GNU General Public License as published by
C    the Free Software Foundation, either version 3 of the License, or
C    (at your option) any later version.
C
C    This program is distributed in the hope that it will be useful,
C    but WITHOUT ANY WARRANTY; without even the implied warranty of
C    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
C    GNU General Public License for more details.
C
C    You should have received a copy of the GNU General Public License
C    along with this program.  If not, see <http://www.gnu.org/licenses/>.
C
C * Rev 1 - Fri, 10 Apr 2015 18:54:30 -050
C   - Adicion de movimiento relativo del satelite SDO en la transformacion de
C     coordenadas.
C   - Se definen "coordenadas esfericas*" donde la coordenada theta indica la
C     la latitud -90 < theta* < +90, en lugar de la usual colatitud 0 < theta
C     < 180; aqui theta* = 90 - theta.
C
C=====7=================================================================
      PROGRAM rimg2resf
      IMPLICIT NONE

      REAL* 8 rho, tprim, t 
      REAL*8 rimg(2), rctop(2), Rt(3), Rsgeo(3), Rshel(3), u(3)
      REAL*8 RMScart(3), RMSesf(3)

C     Ingreso de tiempo (FJM)
C     PRINT *, 'Tiempo:'
      READ *, tprim

C     Ingreso posicion mancha: x(px), y(px)
C     PRINT *, 'Pixel rx:'
      READ *, rimg(1)
C     PRINT *, 'Pixel ry:'
      READ *, rimg(2)

C     Ingreso posicion ecliptica heliocentrica de la tierra: r(UA), Lt(grados), Bt(grados)
C     PRINT *, 'Radio:'
      READ *, Rt(1)
C     PRINT *, 'Longitud ecliptica heliocentrica:'
      READ *, Rt(2)
C     PRINT *, 'Latitud ecliptica heliocentrica:'
      READ *, Rt(3)

C     Ingreso posicion ECI geocentrica del satelite: x(Km), y(Km), z(km)
C     PRINT *, 'xECI:'
      READ *, Rsgeo(1)
C     PRINT *, 'yECI:'
      READ *, Rsgeo(2)
C     PRINT *, 'zECI:'
      READ *, Rsgeo(3)

      CALL px2coortop(rimg, rctop)
      CALL uObsTop2uEclipHel(rctop, Rt, Rsgeo, Rshel, u)
      CALL PosicionMS(Rshel, u, RMScart, rho)
      CALL Cart2Esf(RMScart, RMSesf)

C     Correccion temporal Galileana; c(UA/d)
      t=tprim-rho/173.14463267424

C     Impresion de Datos: tiempo, coor. cartesianas, coor. esfericas.
C     Las repectivas unidades son: tiempo en dias, distancias en UA,
C     angulos en grados.
      WRITE(*,20) t, RMScart, RMSesf(1), RMSesf(2), RMSesf(3)
 20   FORMAT(' ', F11.5, 3(' ', E18.10E3), ' ', E18.10E3, 2(' ', F10.6))
      
      STOP
      END


C===========================================================
C     Conversion coor. imagen [px] a coor. topocentricas ["]
C     Resolucion SDO(HMI): 0.5"/px.
C===========================================================
      SUBROUTINE px2coortop(Vin, Vout)
      IMPLICIT NONE
      REAL*8 PI
      PARAMETER(PI=3.141592653589793)
      REAL*8 Vin(2), Vout(2)

      Vout(1)=Vin(1)*PI/1296000.0
      Vout(2)=Vin(2)*PI/1296000.0

      RETURN
      END SUBROUTINE px2coortop

C===========================================================
C     Transformacion observador a ecliptico
C     Transforma vector unitario del observador topocentrico
C     a ecliptico heliocentrico.
C===========================================================
      SUBROUTINE uObsTop2uEclipHel(Vang, Rt0, Rs0, RSDO, v)
      IMPLICIT NONE
      REAL*8 PI, epsilon
      PARAMETER(PI=3.141592653589793, EPSILON=0.409092804222329)
      INTEGER i, j, k
      REAL*8 L, B
      REAL*8 Vang(2), Rt0(3), Rs0(3), v(3), RSDO(3)
      REAL*8 vprim(3), RTIERRA(3), RSDOesf(3)
      REAL*8 Rinvepsilon(3,3), RinvL(3,3), RinvB(3,3)

C     Angulos grad -> rad
      L=Rt0(2)*PI/180.0
      B=Rt0(3)*PI/180.0
C     Coor. cartesianas tierra en el ecliptico heliocentrico
      RTIERRA(1)=Rt0(1)*DCOS(B)*DCOS(L)
      RTIERRA(2)=Rt0(1)*DCOS(B)*DSIN(L)
      RTIERRA(3)=Rt0(1)*DSIN(B)
C     Coor. cartesianas SDO en el ECI geocentrico en UA
      DO i=1,3
         RSDO(i)=Rs0(i)/149597870.7
      END DO
C     Matriz de rotacion inversa respecto a la oblicuidad ecliptica
      Rinvepsilon(1,1)=1.0
      Rinvepsilon(1,2)=0.0
      Rinvepsilon(1,3)=0.0
      Rinvepsilon(2,1)=0.0
      Rinvepsilon(2,2)=DCOS(EPSILON)
      Rinvepsilon(2,3)=DSIN(EPSILON)
      Rinvepsilon(3,1)=0.0
      Rinvepsilon(3,2)=-DSIN(EPSILON)
      Rinvepsilon(3,3)=DCOS(EPSILON)
C     Coor. cartesianas SDO en el ecliptico heliocentrico
      DO i=1,3
         v(i)=0.0
      END DO
      DO i=1,3
         DO j=1,3
            v(i)=v(i)+Rinvepsilon(i,j)*RSDO(j)
         END DO
      END DO
      DO i=1,3
         RSDO(i)=RTIERRA(i)+v(i)
      END DO
C     Coor. esfericas* SDO en el ecliptico heliocentrico
      CALL Cart2Esf(RSDO, RSDOesf)
C     Angulos de rotacion para alinear SDO al centro del Sol
      L=RSDOesf(3)*PI/180.0
      B=RSDOesf(2)*PI/180.0
C     Matriz de rotacion inversa para L
      RinvL(1,1)=DCOS(L)
      RinvL(1,2)=-DSIN(L)
      RinvL(1,3)=0.0
      RinvL(2,1)=DSIN(L)
      RinvL(2,2)=DCOS(L)
      RinvL(2,3)=0.0
      RinvL(3,1)=0.0
      RinvL(3,2)=0.0
      RinvL(3,3)=1.0
C     Matriz de rotacion inversa para B
      RinvB(1,1)=DCOS(B)
      RinvB(1,2)=0.0
      RinvB(1,3)=-DSIN(B)
      RinvB(2,1)=0.0
      RinvB(2,2)=1.0
      RinvB(2,3)=0.0
      RinvB(3,1)=DSIN(B)
      RinvB(3,2)=0.0
      RinvB(3,3)=DCOS(B)
C     Cosenos directores vec{u'} observador topocentrico
      vprim(1)=-DCOS(Vang(1))*DCOS(Vang(2))
      vprim(2)=DSIN(Vang(1))*DCOS(Vang(2))
      vprim(3)=DSIN(Vang(2))
C     Cosenos directores vec{u} ecliptico heliocentrico
      DO i=1,3
         v(i)=0.0
      END DO
      DO i=1,3
         DO j=1,3
            DO k=1,3
               v(i)=v(i)+RinvL(i,j)*RinvB(j,k)*vprim(k)
            END DO
         END DO
      END DO
      
      RETURN
      END SUBROUTINE uObsTop2uEclipHel

C===========================================================
C     Posicion mancha solar ecliptico heliocentrico
C     Rsol=695 660/149 597 870.7 UA
C===========================================================
      SUBROUTINE PosicionMS(Rs0, v, RMS0, rho0)
      IMPLICIT NONE
      INTEGER i
      REAL*8 PI, RSOL
      PARAMETER(PI=3.141592653589793, RSOL=4.65019987747727D-3)
      REAL*8 rho0, PP, norma, normaRs
      REAL*8 Rs0(3), v(3), RMS0(3)

C     Producto punto Rs0.V
      PP=0.0
      DO i=1,3
         PP=PP+Rs0(i)*v(i)
      END DO
      normaRs=norma(Rs0, 3)
C     Distancia tierra-mancha
      rho0=-PP-SQRT(PP*PP-normaRs*normaRs+RSOL*RSOL)
C     Posicion mancha solar en coor. cartesianas
      DO i=1,3
         RMS0(i)=Rs0(i)+rho0*v(i)
      END DO

      RETURN
      END SUBROUTINE PosicionMS

C===========================================================
C     Conversion coordenadas cartesianas a esfericas
C     La rutina entrega r(UA), theta*(grados), phi(grados).
C     Referencias:
C     Vcart(1)=x, Vcart(2)=y, Vcart(3)=z
C     Vesf(1)=r, Vesf(2)=theta*, Vesf(3)=phi
C===========================================================
      SUBROUTINE Cart2Esf(Vcart, Vesf)
      IMPLICIT NONE
      REAL*8 PI
      PARAMETER(PI=3.141592653589793)
      INTEGER i
      REAL*8 Vcart(3), Vesf(3)

C     Radio
      Vesf(1)=0.0
      DO i=1,3
         Vesf(1)=Vesf(1)+Vcart(i)*Vcart(i)
      END DO
      Vesf(1)=SQRT(Vesf(1))
C     Latitud (theta*)
      Vesf(2)=DASIN(Vcart(3)/Vesf(1))*180.0/PI
C     Azimut (phi)
      Vesf(3)=DATAN2(Vcart(2),Vcart(1))*180.0/PI
      IF(Vesf(3)<0.0) THEN
         Vesf(3)=360.0+Vesf(3)
      END IF

      RETURN
      END SUBROUTINE Cart2Esf

C===========================================================
C     Norma de un vector
C===========================================================
      FUNCTION norma(V,n)
      IMPLICIT NONE
      INTEGER n, i
      REAL*8 norma, norma2
      REAL*8 V(*)

      norma2=0.0
      DO i=1,n
         norma2=norma2+V(i)*V(i)
      END DO
      norma=SQRT(norma2)

      RETURN
      END FUNCTION norma
