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

foreach my $family_id (keys %{$ged->{families}})
{
    my $family = $ged->{families}->{$family_id};

    $dot->family($family);
}

foreach my $individual_id (keys %{$ged->{individuals}})
{
    my $individual = $ged->{individuals}->{$individual_id};

    $dot->individual($individual);

    my $family_id_child = $individual->{family_child};
    if ($family_id_child)
    {
        $dot->link($ged->{families}->{$family_id_child}, $individual);
    }

    foreach my $family_id_spouse
                (keys %{$individual->{family_spouse}})
    {
        $dot->link($individual, $ged->{families}->{$family_id_spouse});
    }
}

$dot->close();
