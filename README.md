OmegaSol
========

**Observador de Manchas Estratégico para la Generación Automática** de datos de posición 3D de manchas solares

![Screenshot](https://raw.githubusercontent.com/mikemolina/OmegaSol/master/share/images/20150214_101555_4096_HMII-Trayectoria.png)

SINOPSIS
-------

    ./gendata.sh [directorio imágenes] [archivo datos]

DESCRIPCIÓN
-----------

El proyecto **OmegaSol** se trata de una recopilación de scripts y rutinas de cálculo para **O***bservar* **M***anchas* solares **E***stratégicamente* y **G***enerar* **A***utomáticamente* datos del vector posición 3D de manchas solares a partir de imágenes 2D registradas por el satélite-instrumento [SDO/HMI](http://sdo.gsfc.nasa.gov/).

El proyecto publicado aquí aún no contiene una rutina de instalación ni una documentación y es mostrado con fines educativos. Quizás, más adelante!

REQUISITOS
----------

* Paquete Netpbm <[http://netpbm.sourceforge.net/](http://netpbm.sourceforge.net/)>.
* Perl <[https://www.perl.org/](https://www.perl.org/)>.
* Coreutils <[https://www.gnu.org/software/coreutils/](https://www.gnu.org/software/coreutils/)>,  *sed*, *grep*, *awk*. Incluidos por defecto en sistemas UNIX (Linux y Mac). Para Windows incluidos en <[MinGW/MSYS](http://sourceforge.net/projects/mingwbuilds/files/external-binary-packages/)>.
* Kalendas <[https://github.com/mikemolina/kalendas](https://github.com/mikemolina/kalendas)>.
* Compilador fortran 77 (consulte en la distribución de su SO).

USO
---

Compilar el código en *./src* con **make**; las imágenes HMI deben ser de tamaño 4096x4096. En la terminal ir al directorio *./bin* y ejecutar

    ./gendata.sh ruta/a/directorio/imagenes datos.txt

Las efemérides de SDO están aproximadamente para Feb-2015 y Mar-2015.

EJEMPLO
-------

Para ejecutar el ejemplo de prueba, escribir en la terminal

    cd bin
    ./gendata.sh ../share/data/ test.txt

LICENCIA
--------

Los códigos, rutinas y scripts contenidos en este proyecto son considerados como software libre y pueden distribuirse bajo los términos de la licencia  GNU General Public License (GNU GPL), la cual se encuentra incluida en esta distribución en el archivo COPYING.
