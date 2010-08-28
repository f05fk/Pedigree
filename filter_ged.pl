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

if (scalar(@ARGV) < 4)
{
    print "usage: $0 origin.ged dest.ged bound [...] start\n";
    exit 1;
}

my $origin = shift;
my $dest = shift;

my $ged = new GED::GED($origin);

while (scalar(@ARGV) > 1)
{
    my $boundary = shift;

    if ($boundary =~ m/^I/)
    {
        my $individual = $ged->getIndividual($boundary);
        $individual->{keep} = 1;
    }

    if ($boundary =~ m/^F/)
    {
        my $family = $ged->getFamily($boundary);
        $family->{keep} = 1;
    }
}

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
    return if ($family->{keep});

    $family->{keep} = 1;

    &keep_individual($family->getHusband());
    &keep_individual($family->getWife());

    foreach my $child ($family->getChildren())
    {
        &keep_individual($child);
    }
}

sub keep_individual
{
    my $individual = shift;

    # exit if not exists
    return if (!defined $individual);

    # exit if already visited
    return if ($individual->{keep});

    $individual->{keep} = 1;

    &keep_family($individual->getFamilyChild());

    foreach my $familySpouse ($individual->getFamiliesSpouse())
    {
        &keep_family($familySpouse);
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
