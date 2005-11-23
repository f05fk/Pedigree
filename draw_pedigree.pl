#!/usr/bin/perl
#########################################################################
# Copyright (C) 2005 Claus Schrammel                                    #
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

use strict;

use GED;
use DOT;

my $ged = new GED($ARGV[0]);
my $dot = new DOT();

pedigree($ARGV[1]);

$dot->close();

exit 0;

#
# draw pedigree
#
sub pedigree
{
    my $individual = shift;

    return if (!$individual);

    $dot->individual($ged->{individuals}->{$individual});

    my $family_children = $ged->{individuals}->{$individual}->{family_children};
    if ($family_children)
    {
        my $father = $ged->{families}->{$family_children}->{husband};
        my $mother = $ged->{families}->{$family_children}->{wife};

        if ($father)
        {
            pedigree($father);
            $dot->link($ged->{individuals}->{$father},
                       $ged->{individuals}->{$individual});
        }

        if ($mother)
        {
            pedigree($mother);
            $dot->link($ged->{individuals}->{$mother},
                       $ged->{individuals}->{$individual});
        }
    }

}
