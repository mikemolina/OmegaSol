OmegaSol
========

**Observador de Manchas Estratégico para la Generación Automática** de datos de posición 3D de manchas solares

![Screenshot](https://raw.githubusercontent.com/mikemolina/OmegaSol/master/share/doc/20150214_101555_4096_HMII-Trayectoria.png)

SINOPSIS
-------

    ./gendata.sh [directorio imágenes] [archivo awk] [archivo efemérides SDO] [archivo datos]

DESCRIPCIÓN
-----------

El proyecto **OmegaSol** se trata de una recopilación de scripts y rutinas de cálculo para **O***bservar* **M***anchas* solares **E***stratégicamente* y **G***enerar* **A***utomáticamente* datos del vector posición 3D de manchas solares a partir de imágenes 2D registradas por el satélite-instrumento [SDO/HMI](http://sdo.gsfc.nasa.gov/).

El proyecto publicado aquí aún no contiene una rutina de instalación ni una documentación y es mostrado con fines educativos. Quizás, más adelante!

REQUISITOS
----------

* Paquete [Netpbm](http://netpbm.sourceforge.net/) (consulte en la distribución de su SO).
* [Perl](https://www.perl.org/).
* Herramientas de [Coreutils](https://www.gnu.org/software/coreutils/) (*sed*, *grep*, *awk*), incluidos por defecto en sistemas UNIX (Linux y Mac). Para Windows incluidos en [MinGW/MSYS](http://sourceforge.net/projects/mingwbuilds/files/external-binary-packages/).
* [Kalendas](http://mikemolina.github.io/kalendas-home).
* Compilador fortran 77 (consulte en la distribución de su SO).

USO
---

Compilar el código en *./src* con **make**; las imágenes HMI deben ser de tamaño 4096x4096; el script **infoStereo.sh** necesita conexión a red. En la terminal ir al directorio *./bin* y ejecutar

    ./gendata.sh ruta/directorio/imagenes ruta/archivo/awk ruta/efemérides/SDO datos.txt

Las efemérides de SDO son generadas desde [HORIZONS Web-Interface](http://ssd.jpl.nasa.gov/horizons.cgi), en un archivo de texto comprimido en *gzip* según el formulario de la figura.

![Screenshot](https://raw.githubusercontent.com/mikemolina/OmegaSol/master/share/doc/formulario-horizons.png)

EJEMPLO
-------

Para ejecutar el ejemplo de prueba, escribir en la terminal

    cd bin
    ./gendata.sh ../share/images/mancha ../share/awk/manchamax-5.awk \
    ../share/efemerides/efemerides_SDO-ICEJ2000-feb.txt.gz ../share/data/test-inf.dat

LICENCIA
--------

Los códigos, rutinas y scripts contenidos en este proyecto son considerados como software libre y pueden distribuirse bajo los términos de la licencia  GNU General Public License (GNU GPL), la cual se encuentra incluida en esta distribución en el archivo COPYING.
