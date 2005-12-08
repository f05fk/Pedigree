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

package GED;

use strict;

sub new
{
    my $self = {};
    bless $self;
    my $classname = shift;

    my $ged_file_name = shift;
    $self->load($ged_file_name);

    return $self;
}

sub load
{
    my $self = shift;
    my $ged_file_name = shift;

    # read-in the file
    open GED, "<$ged_file_name"
        or die "cannot open GED file '$ged_file_name': $!";
    @{$self->{ged_file}} = <GED>;
    chomp @{$self->{ged_file}};
    close GED;

    # empty the internal data structure
    $self->{individuals} = {};
    $self->{families} = {};

    # parse the ged file
    $self->parse();

    # remove the empty arrayref from the hash completely
    delete $self->{ged_file};
}

sub parse
{
    my $self = shift;

    while ($_ = shift @{$self->{ged_file}})
    {
        if (m/^0 HEAD$/)
        {
            while ($_ = shift @{$self->{ged_file}})
            {
                if (m/^0/)
                {
                    unshift @{$self->{ged_file}}, $_;
                    last;
                }
            }

            next;
        }

        if (m/^0 \@(.+)\@ INDI$/)
        {
            my $individual = {};
            $self->{individuals}->{$1} = $individual;
            $individual->{id} = $1;

            $self->parse_individual($individual);
            next;
        }

        if (m/^0 \@(.+)\@ FAM$/)
        {
            my $family = {};
            $self->{families}->{$1} = $family;
            $family->{id} = $1;

            $self->parse_family($family);
            next;
        }

        if (m/^0 TRLR$/)
        {
            while ($_ = shift @{$self->{ged_file}})
            {
                if (m/^0/)
                {
                    unshift @{$self->{ged_file}}, $_;
                    last;
                }
            }

            next;
        }

        print STDERR "unknown: $_\n";
    }

}

sub parse_individual
{
    my $self = shift;
    my $individual = shift;

    while ($_ = shift @{$self->{ged_file}})
    {
        if (m/^1 NAME (.+) \/(.+)\/$/)
        {
            $individual->{name} = "$1 $2";
            next;
        }

        if (m/^1 NAME (.+) \/\/$/)
        {
            $individual->{name} = $1;
            next;
        }

        if (m/^1 SEX (.+)$/)
        {
            $individual->{sex} = $1;
            next;
        }

        if (m/^1 BIRT$/)
        {
            $individual->{birth} = {};
            $self->parse_date_place($individual->{birth});
            next;
        }

        if (m/^1 DEAT$/)
        {
            $individual->{death} = {};
            $self->parse_date_place($individual->{death});
            next;
        }

        if (m/^1 FAMC \@(.+)\@$/)
        {
            $individual->{family_child} = $1;
            next;
        }

        if (m/^1 FAMS \@(.+)\@$/)
        {
            $individual->{family_spouse}->{$1} = $1;
            next;
        }

        if (m/^0/)
        {
            unshift @{$self->{ged_file}}, $_;
            last;
        }

        print STDERR "unknown: $_\n";
    }
}

sub parse_family
{
    my $self = shift;
    my $family = shift;


    while ($_ = shift @{$self->{ged_file}})
    {
        if (m/^1 HUSB \@(.+)\@$/)
        {
            $family->{husband} = $1;
            next;
        }

        if (m/^1 WIFE \@(.+)\@$/)
        {
            $family->{wife} = $1;
            next;
        }

        if (m/^1 MARR$/)
        {
            $family->{marriage} = {};
            $self->parse_date_place($family->{marriage});
            next;
        }

        if (m/^1 CHIL \@(.+)\@$/)
        {
            $family->{children}->{$1} = $1;
            next;
        }

        if (m/^0/)
        {
            unshift @{$self->{ged_file}}, $_;
            last;
        }

        print STDERR "unknown: $_\n";
    }
}

sub parse_date_place
{
    my $self = shift;
    my $date_place = shift;

    while ($_ = shift @{$self->{ged_file}})
    {
        if (m/^2 DATE ?(.*)$/)
        {
            my $date = $1;
            my ($day, $month, $year);


            if ($date =~ m/^(\d*)$/)
            {
                $year = $1;
            }
            elsif ($date =~ m/^(\w*)\s*(\d*)$/)
            {
                ($month, $year) = ($1, $2);
            }
            elsif ($date =~ m/^(\d*)\s*(\w*)$/)
            {
                ($day, $month) = ($1, $2);
            }
            elsif ($date =~ m/^(\d*)\s*(\w*)\s*(\d*)$/)
            {
                ($day, $month, $year) = ($1, $2, $3);
            }
            else
            {
                print STDERR "unknown: $_\n";
                next;
            }

            undef $date;

            if ($day)
            {
                $date = "$day.";
            }

            if ($month)
            {
                $month = lc($month);
                $month = {'jan' => 'Jänner', 'feb' => 'Feber', 'mar' => 'März',
                          'apr' => 'April', 'mai' => 'Mai', 'jun' => 'Juni',
                          'jul' => 'Juli', 'aug' => 'August',
                          'sep' => 'September', 'okt' => 'Oktober',
                          'nov' => 'November', 'dec' => 'Dezember',
#                          'mrz' => 'März', 'dez' => 'Dezember'
                         }->{$month};
                if (!$month)
                {
                    print STDERR "unknown month: $_\n";
                    next;
                }

                if ($date)
                {
                    $date .= " $month";
                }
                else
                {
                    $date = $month;
                }
            }

            if ($year)
            {
                if ($date)
                {
                    $date .= " $year";
                }
                else
                {
                    $date = $year;
                }
            }

            $date_place->{date} = $date;
            next;
        }

        if (m/^2 PLAC ?(.*)$/)
        {
            $date_place->{place} = $1;
            next;
        }

        if (m/^[01]/)
        {
            unshift @{$self->{ged_file}}, $_;
            last;
        }

        print STDERR "unknown: $_\n";
    }
}


1;

__END__
