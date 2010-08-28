#!/usr/bin/perl
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

use strict;

use GED::GED;
use DOT::DOT;

my $ged = new GED::GED($ARGV[0]);
my $dot = new DOT::DOT();

foreach my $family ($ged->getFamilies())
{
    if ($family->{marriage})
    {
        my $husband = $family->getHusband();
        my $wife = $family->getWife();

        # group the family together
        $family->{group} = $family->{id};
        $husband->{group} = $family->{id};
        $wife->{group} = $family->{id};
    }

    $dot->family($family);
}

foreach my $individual ($ged->getIndividuals())
{
    $dot->individual($individual);

    my $familyChild = $individual->getFamilyChild();
    if ($familyChild)
    {
        $dot->link($familyChild, $individual);
    }

    foreach my $familySpouse ($individual->getFamiliesSpouse())
    {
        $dot->link($individual, $familySpouse);
    }
}

$dot->close();
