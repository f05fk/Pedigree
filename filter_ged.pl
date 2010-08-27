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

use GED;

if (scalar(@ARGV) < 4)
{
    print "usage: $0 origin.ged dest.ged bound [...] start\n";
    exit 1;
}

my $origin = shift;
my $dest = shift;

my $ged = new GED($origin);

while (scalar(@ARGV) > 1)
{
    my $boundary = shift;

    if ($boundary =~ m/^I/)
    {
        my $individual = $ged->{individuals}->{$boundary};
        $individual->{keep} = 1;
    }

    if ($boundary =~ m/^F/)
    {
        my $family = $ged->{families}->{$boundary};
        $family->{keep} = 1;
    }
}

my $start = shift;

if ($start =~ m/^I/)
{
    &keep_individual($start);
}

if ($start =~ m/^F/)
{
    &keep_family($start);
}

&remove_entries();

$ged->save($dest);

exit 0;

sub keep_family
{
    my $family_id = shift;
    my $family = $ged->{families}->{$family_id};

    # exit if not exists
    return if (!$family);

    # exit if already visited
    return if ($family->{keep});

    $family->{keep} = 1;

    &keep_individual($family->{husband});
    &keep_individual($family->{wife});

    foreach my $child (keys %{$family->{children}})
    {
        &keep_individual($child);
    }
}

sub keep_individual
{
    my $individual_id = shift;
    my $individual = $ged->{individuals}->{$individual_id};

    # exit if not exists
    return if (!$individual);

    # exit if already visited
    return if ($individual->{keep});

    $individual->{keep} = 1;

    &keep_family($individual->{family_child});

    foreach my $family_spouse (keys %{$individual->{family_spouse}})
    {
        &keep_family($family_spouse);
    }
}

sub remove_entries
{
    foreach my $family_id (keys %{$ged->{families}})
    {
        my $family = $ged->{families}->{$family_id};

        if ($family->{keep})
        {
            my $husband = $ged->{individuals}->{$family->{husband}};
            if (!$husband || !$husband->{keep})
            {
                delete $family->{husband};
            }

            my $wife = $ged->{individuals}->{$family->{wife}};
            if (!$wife || !$wife->{keep})
            {
                delete $family->{wife};
            }

            foreach my $child_id (keys %{$family->{children}})
            {
                my $child = $ged->{individuals}->{$child_id};
                if (!$child || !$child->{keep})
                {
                    delete $family->{children}->{$child_id};
                }
            }
        }
        else
        {
            delete $ged->{families}->{$family_id};
        }
    }

    foreach my $individual_id (keys %{$ged->{individuals}})
    {
        my $individual = $ged->{individuals}->{$individual_id};

        if ($individual->{keep})
        {
            my $family_child = $ged->{families}->{$individual->{family_child}};
            if (!$family_child || !$family_child->{keep})
            {
                delete $individual->{family_child};
            }

            foreach my $family_spouse_id (keys %{$individual->{family_spouse}})
            {
                my $family_spouse = $ged->{families}->{$family_spouse_id};
                if (!$family_spouse || !$family_spouse->{keep})
                {
                    delete $individual->{family_spouse}->{$family_spouse_id};
                }
            }
        }
        else
        {
            delete $ged->{individuals}->{$individual_id};
        }
    }
}
