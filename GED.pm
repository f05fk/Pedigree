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

sub save
{
    my $self = shift;
    my $ged_file_name = shift;

    open GED, ">$ged_file_name"
        or die "cannot open GED file '$ged_file_name': $!";

    print GED "0 HEAD\n";
    print GED "1 CHAR Windows\n";
    print GED "1 GEDC\n";
    print GED "2 VERS 5.5\n";
    print GED "2 FORM LINEAGE-LINKED\n";

    $self->write();

    print GED "0 TRLR\n";

    close GED;
}

sub write
{
    my $self = shift;

    foreach my $individual_id (sort {substr($a,1) <=> substr($b,1)}
                               keys %{$self->{individuals}})
    {
        my $individual = $self->{individuals}->{$individual_id};

        print GED "0 @", $individual_id, "@ INDI\n";

        if ($individual->{name})
        {
            print GED "1 NAME ", $individual->{name}, " //\n";
        }

        if ($individual->{sex})
        {
            print GED "1 SEX ", $individual->{sex}, "\n";
        }

        if ($individual->{birth})
        {
            print GED "1 BIRT\n";

            if ($individual->{birth}->{date})
            {
                print GED "2 DATE ", &write_date($individual->{birth}->{date}), "\n";
            }

            if ($individual->{birth}->{place})
            {
                print GED "2 PLAC ", $individual->{birth}->{place}, "\n";
            }
        }

        if ($individual->{death})
        {
            print GED "1 DEAT\n";

            if ($individual->{death}->{date})
            {
                print GED "2 DATE ", &write_date($individual->{death}->{date}), "\n";
            }

            if ($individual->{death}->{place})
            {
                print GED "2 PLAC ", $individual->{death}->{place}, "\n";
            }
        }

        foreach my $family_spouse (sort {substr($a,1) <=> substr($b,1)}
                                   keys %{$individual->{family_spouse}})
        {
            print GED "1 FAMS @", $family_spouse, "@\n";
        }

        if ($individual->{family_child})
        {
            print GED "1 FAMC @", $individual->{family_child}, "@\n";
        }
    }

    foreach my $family_id (sort {substr($a,1) <=> substr($b,1)}
                           keys %{$self->{families}})
    {
        my $family = $self->{families}->{$family_id};

        print GED "0 @", $family_id, "@ FAM\n";

        if ($family->{husband})
        {
            print GED "1 HUSB @", $family->{husband}, "@\n";
        }

        if ($family->{wife})
        {
            print GED "1 WIFE @", $family->{wife}, "@\n";
        }

        if ($family->{marriage})
        {
            print GED "1 MARR\n";

            if ($family->{marriage}->{date})
            {
                print GED "2 DATE ", &write_date($family->{marriage}->{date}), "\n";
            }

            if ($family->{marriage}->{place})
            {
                print GED "2 PLAC ", $family->{marriage}->{place}, "\n";
            }
        }

        foreach my $child (sort {substr($a,1) <=> substr($b,1)}
                           keys %{$family->{children}})
        {
            print GED "1 CHIL @", $child, "@\n";
        }
    }
}

sub write_date
{
    my $date = shift;

    $date =~ s/\.//;

    $date =~ s/Jänner/Jan/i;
    $date =~ s/Feber/Feb/i;
    $date =~ s/März/Mar/i;
    $date =~ s/April/Apr/i;
    $date =~ s/Mai/Mai/i;
    $date =~ s/Juni/Jun/i;
    $date =~ s/Juli/Jul/i;
    $date =~ s/August/Aug/i;
    $date =~ s/September/Sep/i;
    $date =~ s/Oktober/Okt/i;
    $date =~ s/November/Nov/i;
    $date =~ s/Dezember/Dec/i;

    return $date;
}


1;

__END__
