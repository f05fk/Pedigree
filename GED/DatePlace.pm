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

package GED::DatePlace;

use strict;

sub new
{
    my $self = {};
    bless $self;
    my $classname = shift;

    my $ged = shift;
    $self->{ged} = $ged;

    return $self;
}

sub getDate
{
    my $self = shift;

    return $self->{date};
}

sub setDate
{
    my $self = shift;
    my $date = shift;

    $self->{date} = $date;
    return $self;
}

sub getTime
{
    my $self = shift;

    return $self->{time};
}

sub setTime
{
    my $self = shift;
    my $time = shift;

    $self->{time} = $time;
    return $self;
}

sub getPlace
{
    my $self = shift;

    return $self->{place};
}

sub setPlace
{
    my $self = shift;
    my $place = shift;

    $self->{place} = $place;
    return $self;
}

sub parse
{
    my $self = shift;
    my $ged = $self->{ged};

    while ($_ = shift @{$ged->{ged_file}})
    {
        # 2 DATE 16 MAY 1975
        if (m/^2 DATE ?(.*)$/)
        {
            my $date = $1;
            my ($day, $month, $year);

            # 2 DATE 1975
            if ($date =~ m/^(\d*)$/)
            {
                $year = $1;
            }
            # 2 DATE MAY 1975
            elsif ($date =~ m/^(\w*)\s*(\d*)$/)
            {
                ($month, $year) = ($1, $2);
            }
            # 2 DATE 16 MAY
            elsif ($date =~ m/^(\d*)\s*(\w*)$/)
            {
                ($day, $month) = ($1, $2);
            }
            # 2 DATE 16 MAY 1975
            elsif ($date =~ m/^(\d*)\s*(\w*)\s*(\d*)$/)
            {
                ($day, $month, $year) = ($1, $2, $3);
            }
            else
            {
                print STDERR "DatePlace.parse(): unknown date: $_\n";
                next;
            }

            undef $date;

            if ($day)
            {
                $date = "$day.";
            }

            if ($month)
            {
                $month = &parse_month($month);

                if (!$month)
                {
                    print STDERR "DatePlace.parse(): unknown month: $_\n";
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

            $self->{date} = $date;
            next;
        }

        # 3 TIME 12:34:56
        if (m/^3 TIME ?(.*)$/)
        {
            $self->{time} = $1;
            next;
        }

        if (m/^2 PLAC ?(.*)$/)
        {
            $self->{place} = $1;
            next;
        }

        if (m/^[01]/)
        {
            unshift @{$ged->{ged_file}}, $_;
            last;
        }

        print STDERR "DatePlace.parse(): unknown: $_\n";
    }
}

sub write
{
    my $self = shift;
    my $fh = shift;

    if ($self->{date})
    {
        print $fh "2 DATE ", &write_date($self->{date}), "\n";
    }

    if ($self->{time})
    {
        print $fh "3 TIME ", $self->{time}, "\n";
    }

    if ($self->{place})
    {
        print $fh "2 PLAC ", $self->{place}, "\n";
    }
}

sub parse_month
{
    my $month = shift;

    $month = lc($month);
    $month = {'jan' => 'J�nner',
#              'jan' => 'Jänner',
              'feb' => 'Feber',
              'mar' => 'M�rz',
#              'mar' => 'März',
              'apr' => 'April',
              'may' => 'Mai',
              'jun' => 'Juni',
              'jul' => 'Juli',
              'aug' => 'August',
              'sep' => 'September',
              'oct' => 'Oktober',
              'nov' => 'November',
              'dec' => 'Dezember',
              'abt' => 'ca.',
              'ca' => 'ca.',
              'mrz' => 'M�rz',
#              'mrz' => 'März',
              'mai' => 'Mai',
              'okt' => 'Oktober',
              'dez' => 'Dezember'
             }->{$month};

    return $month;
}

sub write_date
{
    my $date = shift;

    $date =~ s/\.//;

    $date =~ s/J�nner/JAN/i;
#    $date =~ s/Jänner/JAN/i;
    $date =~ s/Feber/FEB/i;
    $date =~ s/M�rz/MAR/i;
#    $date =~ s/März/MAR/i;
    $date =~ s/April/APR/i;
    $date =~ s/Mai/MAY/i;
    $date =~ s/Juni/JUN/i;
    $date =~ s/Juli/JUL/i;
    $date =~ s/August/AUG/i;
    $date =~ s/September/SEP/i;
    $date =~ s/Oktober/OCT/i;
    $date =~ s/November/NOV/i;
    $date =~ s/Dezember/DEC/i;

    $date =~ s/ca/ABT/i;

    return $date;
}


1;

__END__
