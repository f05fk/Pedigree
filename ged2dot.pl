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

my @ged = <>;
chomp @ged;

my %indis = ();
my %fams = ();

while ($_ = shift @ged)
{
    if (m/^0 HEAD$/)
    {
        while ($_ = shift @ged)
        {
            if (m/^0/)
            {
                unshift @ged, $_;
                last;
            }
        }

        next;
    }

    if (m/^0 \@(.+)\@ INDI$/)
    {
        my $indi = {};
        $indis{$1} = $indi;

        while ($_ = shift @ged)
        {
            if (m/^1 NAME (.+) \/(.+)\/$/)
            {
                $indi->{name} = "$1 $2";
                next;
            }

            if (m/^1 NAME (.+) \/\/$/)
            {
                $indi->{name} = $1;
                next;
            }

            if (m/^1 SEX (.+)$/)
            {
                $indi->{sex} = $1;
                next;
            }

            if (m/^1 BIRT$/)
            {
                while ($_ = shift @ged)
                {
                    if (m/^2 DATE ?(.*)$/)
                    {
                        $indi->{birt}->{date} = $1;
                        next;
                    }

                    if (m/^2 PLAC ?(.*)$/)
                    {
                        $indi->{birt}->{plac} = $1;
                        next;
                    }

                    if (m/^[01]/)
                    {
                        unshift @ged, $_;
                        last;
                    }

                    print STDERR "unknown: $_\n";
                }

                next;
            }

            if (m/^1 DEAT$/)
            {
                while ($_ = shift @ged)
                {
                    if (m/^2 DATE ?(.*)$/)
                    {
                        $indi->{deat}->{date} = $1;
                        next;
                    }

                    if (m/^2 PLAC ?(.*)$/)
                    {
                        $indi->{deat}->{plac} = $1;
                        next;
                    }

                    if (m/^[01]/)
                    {
                        unshift @ged, $_;
                        last;
                    }

                    print STDERR "unknown: $_\n";
                }

                next;
            }

            if (m/^1 FAMC \@(.+)\@$/)
            {
                $indi->{famc} = $1;
                next;
            }

            if (m/^1 FAMS \@(.+)\@$/)
            {
                $indi->{fams}->{$1} = $1;
                next;
            }

            if (m/^0/)
            {
                unshift @ged, $_;
                last;
            }

            print STDERR "unknown: $_\n";
        }

        next;
    }

    if (m/^0 \@(.+)\@ FAM$/)
    {
        my $fam = {};
        $fams{$1} = $fam;

        while ($_ = shift @ged)
        {
            if (m/^1 HUSB \@(.+)\@$/)
            {
                $fam->{husb} = $1;
                next;
            }

            if (m/^1 WIFE \@(.+)\@$/)
            {
                $fam->{wife} = $1;
                next;
            }

            if (m/^1 MARR$/)
            {
                $fam->{marr}->{marr} = 1;

                while ($_ = shift @ged)
                {
                    if (m/^2 DATE ?(.*)$/)
                    {
                        $fam->{marr}->{date} = $1;
                        next;
                    }

                    if (m/^2 PLAC ?(.*)$/)
                    {
                        $fam->{marr}->{plac} = $1;
                        next;
                    }

                    if (m/^[01]/)
                    {
                        unshift @ged, $_;
                        last;
                    }

                    print STDERR "unknown: $_\n";
                }

                next;
            }

            if (m/^1 CHIL \@(.+)\@$/)
            {
                $fam->{chil}->{$1} = $1;
                next;
            }

            if (m/^0/)
            {
                unshift @ged, $_;
                last;
            }

            print STDERR "unknown: $_\n";
        }

        next;
    }

    if (m/^0 TRLR$/)
    {
        while ($_ = shift @ged)
        {
            if (m/^0/)
            {
                unshift @ged, $_;
                last;
            }
        }

        next;
    }

    print STDERR "unknown: $_\n";
}

print "digraph G\n{\n";

foreach my $fam (keys %fams)
{
    print "    $fam [label=\"";

    my $marr = $fams{$fam}->{marr}->{marr};
    if ($marr)
    {
        print "oo";
    }

    my $marr_date = $fams{$fam}->{marr}->{date};
    my $marr_plac = $fams{$fam}->{marr}->{plac};
    if ($marr_date && $marr_plac)
    {
        print " $marr_date\\n$marr_plac"
    }
    elsif ($marr_date)
    {
        print " $marr_date"
    }
    elsif ($marr_plac)
    {
        print " $marr_plac"
    }

    print "\"];\n";
}

foreach my $indi (keys %indis)
{
    print "    $indi [shape=box,label=\"";

    my $name = $indis{$indi}->{name};
    print $name;

    my $birt_date = $indis{$indi}->{birt}->{date};
    my $birt_plac = $indis{$indi}->{birt}->{plac};
    if ($birt_date && $birt_plac)
    {
        print "\\n* $birt_date, $birt_plac"
    }
    elsif ($birt_date)
    {
        print "\\n* $birt_date"
    }
    elsif ($birt_plac)
    {
        print "\\n* $birt_plac"
    }

    my $deat_date = $indis{$indi}->{deat}->{date};
    my $deat_plac = $indis{$indi}->{deat}->{plac};
    if ($deat_date && $deat_plac)
    {
        print "\\n+ $deat_date, $deat_plac"
    }
    elsif ($deat_date)
    {
        print "\\n+ $deat_date"
    }
    elsif ($deat_plac)
    {
        print "\\n+ $deat_plac"
    }

    print "\"];\n";

    my $famc = $indis{$indi}->{famc};
    if ($famc)
    {
        print "    $famc -> $indi;\n";
    }

    foreach my $fams (keys %{$indis{$indi}->{fams}})
    {
        print "    $indi -> $fams;\n";
    }
}

print "}\n";
