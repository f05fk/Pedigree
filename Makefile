#########################################################################
# Copyright (C) 2005-2010 Claus Schrammel                               #
#                                                                       #
# This program is free software: you can redistribute it and/or modify  #
# it under the terms of the GNU General Public License as published by  #
# the Free Software Foundation, either version 3 of the License, or     #
# (at your option) any later version.                                   #
#                                                                       #
# This program is distributed in the hope that it will be useful,       #
# but WITHOUT ANY WARRANTY; without even the implied warranty of        #
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         #
# GNU General Public License for more details.                          #
#                                                                       #
# You should have received a copy of the GNU General Public License     #
# along with this program.  If not, see <http://www.gnu.org/licenses/>. #
#########################################################################

.PHONY: all clean

all:
	@echo "make <name>.png"

%.png: %.dot
	dot -Gcharset=latin1 -Tpng -o $*.png $*.dot

%.dot: %.ged draw_all.pl GED/GED.pm DOT/DOT.pm
	./draw_all.pl $*.ged > $*.dot

barbara.ged: gesamt.ged filter_pedigree.pl Makefile
	./filter_pedigree.pl gesamt.ged $@ I3

claus.ged: gesamt.ged filter_pedigree.pl Makefile
	./filter_pedigree.pl gesamt.ged $@ I5

august_schrammel.ged: gesamt.ged filter_pedigree.pl Makefile
	./filter_pedigree.pl gesamt.ged $@ I169

anton_schreiner.ged: gesamt.ged filter_pedigree.pl Makefile
	./filter_pedigree.pl gesamt.ged $@ I140

apollonia_schreiner.ged: gesamt.ged filter_pedigree.pl Makefile
	./filter_pedigree.pl gesamt.ged $@ I141

anton_supper.ged: gesamt.ged filter_pedigree.pl Makefile
	./filter_pedigree.pl gesamt.ged $@ I15

maria_supper.ged: gesamt.ged filter_pedigree.pl Makefile
	./filter_pedigree.pl gesamt.ged $@ I16

schrammel.ged: gesamt.ged filter_ged.pl Makefile
	./filter_ged.pl gesamt.ged $@ I3 F2

schreiner.ged: gesamt.ged filter_ged.pl Makefile
	./filter_ged.pl gesamt.ged $@ I5 F2

clean:
	rm -f *.png *.dot
	rm -f barbara.ged claus.ged schrammel.ged schreiner.ged
	rm -f anton_schreiner.ged anton_supper.ged apollonia_schreiner.ged august_schrammel.ged maria_supper.ged
