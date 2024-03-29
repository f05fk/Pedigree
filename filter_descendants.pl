#!/usr/bin/perl
#########################################################################
# Copyright (C) Claus Schrammel <claus@f05fk.net>                       #
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
#                                                                       #
# SPDX-License-Identifier: GPL-3.0-or-later                             #
#########################################################################

use strict;

use GED::GED;

if (scalar(@ARGV) != 3)
{
    print "usage: $0 origin.ged dest.ged start\n";
    exit 1;
}

my $origin = shift;
my $dest = shift;

my $ged = new GED::GED($origin);

my $start = shift;

if ($start =~ m/^I/)
{
    &keep_individual($ged->getIndividual($start));
}

if ($start =~ m/^F/)
{
    &keep_family($ged->getFamily($start));
}

&remove_entries();

$ged->save($dest);

exit 0;

sub keep_family
{
    my $family = shift;

    # exit if not exists
    return if (!defined $family);

    # exit if already visited
    return if ($family->{keep} == 1);

    $family->{keep} = 1;

    &keep_spouse($family->getHusband());
    &keep_spouse($family->getWife());

    foreach my $child ($family->getChildren()) {
        &keep_individual($child);
    }
}

sub keep_spouse
{
    my $individual = shift;

    # exit if not exists
    return if (!defined $individual);

    # exit if already visited
    return if ($individual->{keep} == 1);

    $individual->{keep} = 0.5;
}

sub keep_individual
{
    my $individual = shift;

    # exit if not exists
    return if (!defined $individual);

    # exit if already visited
    return if ($individual->{keep} == 1);

    $individual->{keep} = 1;

    foreach my $family ($individual->getFamiliesSpouse()) {
        &keep_family($family);
    }
}

sub remove_entries
{
    foreach my $family ($ged->getFamilies())
    {
        if (!$family->{keep})
        {
            $family->remove();
        }
    }

    foreach my $individual ($ged->getIndividuals())
    {
        if (!$individual->{keep})
        {
            $individual->remove();
        }
    }
}
