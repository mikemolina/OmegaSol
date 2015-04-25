# -*- Makefile -*-
#
# Makefile - Compilacion de rimg2resf-corr.f
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

SRC = rimg2resf-corr.f
EXE = rimg2resf

all:
	@echo "Para compilar rimg2resf-corr.f use:"
	@echo "  make [opcion]"
	@echo "Opciones:"
	@echo " mingw     - Compilador fortran Windows/MinGW"
	@echo " linux-gnu - Compilador fortran Linux/GNU"
	@echo " linux-f77 - Compilador fortran Linux/fort77"

mingw:
	gfortran -static-libgcc -static-libgfortran -o ../bin/$(EXE) $(SRC)

linux-gnu:
	gfortran -o ../bin/$(EXE) $(SRC)

linux-f77:
	f77 -o ../bin/$(EXE) $(SRC)

clean:
	rm -f ../bin/$(EXE)
