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

package GED::GED;

use strict;

use GED::Individual;
use GED::Family;

sub new
{
    my $self = {};
    bless $self;
    my $classname = shift;

    my $ged_file_name = shift;
    $self->load($ged_file_name);

    return $self;
}

sub getIndividuals
{
    my $self = shift;

    return values %{$self->{individuals}};
}

sub getIndividual
{
    my $self = shift;
    my $id = shift;

    return $self->{individuals}->{$id};
}

sub getOrCreateIndividual
{
    my $self = shift;
    my $id = shift;

    my $individual = $self->getIndividual($id);
    if (!defined $individual)
    {
        $individual = new GED::Individual($id, $self);
        $self->addIndividual($individual);
    }
    return $individual;
}

sub addIndividual
{
    my $self = shift;
    my $individual = shift;

    $self->{individuals}->{$individual->getId()} = $individual;
    return $self;
}

sub removeIndividual
{
    my $self = shift;
    my $individual = shift;

    delete $self->{individuals}->{$individual->getId()};
    return $self;
}

sub getFamilies
{
    my $self = shift;

    return values %{$self->{families}};
}

sub getFamily
{
    my $self = shift;
    my $id = shift;

    return $self->{families}->{$id};
}

sub getOrCreateFamily
{
    my $self = shift;
    my $id = shift;

    my $family = $self->getFamily($id);
    if (!defined $family)
    {
        $family = new GED::Family($id, $self);
        $self->addFamily($family);
    }
    return $family;
}

sub addFamily
{
    my $self = shift;
    my $family = shift;

    $self->{families}->{$family->getId()} = $family;
    return $self;
}

sub removeFamily
{
    my $self = shift;
    my $family = shift;

    delete $self->{families}->{$family->getId()};
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

        # 0 @B1@ SUBM
        if (m/^0 \@(.+)\@ SUBM$/)
        {
            my $submitter = {};
            $self->{submitters}->{$1} = $submitter;
            $submitter->{id} = $1;

            $self->parse_individual($submitter);
            next;
        }

        # 0 @I5@ INDI
        if (m/^0 \@(.+)\@ INDI$/)
        {
            my $individual = $self->getOrCreateIndividual($1);
            $self->parse_individual($individual);
            next;
        }

        # 0 @F2@ FAM
        if (m/^0 \@(.+)\@ FAM$/)
        {
            my $family = $self->getOrCreateFamily($1);
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
        # 1 NAME Claus /Schrammel/ DI
        if (m/^1 NAME (.+) \/(.+)\/ (.*?)$/)
        {
            $individual->{firstname} = $1;
            $individual->{lastname} = $2;
            $individual->{title} = $3;
            $individual->{name} = "$3 $1 $2";
            next;
        }

        # 1 NAME Claus /Schrammel/
        if (m/^1 NAME (.+) \/(.+)\/$/)
        {
            $individual->{firstname} = $1;
            $individual->{lastname} = $2;
            $individual->{name} = "$1 $2";
            next;
        }

        # 1 NAME Claus //
        if (m/^1 NAME (.+) \/\/$/)
        {
            $individual->{firstname} = $1;
            $individual->{name} = $1;
            next;
        }

        # 1 NAME Claus
        if (m/^1 NAME (.+)$/)
        {
            $individual->{firstname} = $1;
            $individual->{name} = $1;
            next;
        }

        # 1 SEX M
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

        if (m/^1 OCCU (.+)$/)
        {
            $individual->{occupation} = $1;

            $_ = shift @{$self->{ged_file}};
            if (!m/^2 DATE/)
            {
                unshift @{$self->{ged_file}}, $_;
                next;
            }

            $_ = shift @{$self->{ged_file}};
            if (!m/^2 PLAC/)
            {
                unshift @{$self->{ged_file}}, $_;
                next;
            }

            next;
        }

        # 1 FAMC @F54@
        if (m/^1 FAMC \@(.+)\@$/)
        {
            $individual->{familyChild} = $self->getOrCreateFamily($1);
            next;
        }

        # 1 FAMS @F2@
        if (m/^1 FAMS \@(.+)\@$/)
        {
            $individual->{familiesSpouse}->{$1} = $self->getOrCreateFamily($1);
            next;
        }

        if (m/^1 NOTE (.+)$/)
        {
            $individual->{note} = $1;
            next;
        }

        if (m/^1 CHAN$/)
        {
            $individual->{change} = {};
            $self->parse_date_place($individual->{change});
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
        # 1 HUSB @I5@
        if (m/^1 HUSB \@(.+)\@$/)
        {
            $family->{husband} = $self->getOrCreateIndividual($1);
            next;
        }

        # 1 WIFE @I3@
        if (m/^1 WIFE \@(.+)\@$/)
        {
            $family->{wife} = $self->getOrCreateIndividual($1);
            next;
        }

        if (m/^1 MARR$/)
        {
            $family->{marriage} = {};
            $self->parse_date_place($family->{marriage});
            next;
        }

        # 1 CHIL @I999@
        if (m/^1 CHIL \@(.+)\@$/)
        {
            $family->{children}->{$1} = $self->getOrCreateIndividual($1);
            next;
        }

        if (m/^1 NOTE (.+)$/)
        {
            $family->{note} = $1;
            next;
        }

        if (m/^1 CHAN$/)
        {
            $family->{change} = {};
            $self->parse_date_place($family->{change});
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
                          'apr' => 'April', 'may' => 'Mai', 'jun' => 'Juni',
                          'jul' => 'Juli', 'aug' => 'August',
                          'sep' => 'September', 'oct' => 'Oktober',
                          'nov' => 'November', 'dec' => 'Dezember',
                          'abt' => 'ca.', 'ca' => 'ca.',
                          'mrz' => 'März', 'mai' => 'Mai',
                          'okt' => 'Oktober', 'dez' => 'Dezember'
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

        # 3 TIME 12:34:56
        if (m/^3 TIME ?(.*)$/)
        {
            $date_place->{time} = $1;
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
    print GED "1 CHAR LATIN1\n";
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
            print GED "1 NAME ", $individual->{firstname}, " /",
                                 $individual->{lastname}, "/\n";
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

        if ($individual->{occupation})
        {
            print GED "1 OCCU ", $individual->{occupation}, "\n";
        }

        foreach my $family_spouse (sort {substr($a,1) <=> substr($b,1)}
                                   keys %{$individual->{familiesSpouse}})
        {
            print GED "1 FAMS @", $family_spouse, "@\n";
        }

        if ($individual->{familyChild})
        {
            print GED "1 FAMC @", $individual->{familyChild}->{id}, "@\n";
        }
    }

    foreach my $family_id (sort {substr($a,1) <=> substr($b,1)}
                           keys %{$self->{families}})
    {
        my $family = $self->{families}->{$family_id};

        print GED "0 @", $family_id, "@ FAM\n";

        if ($family->{husband})
        {
            print GED "1 HUSB @", $family->{husband}->{id}, "@\n";
        }

        if ($family->{wife})
        {
            print GED "1 WIFE @", $family->{wife}->{id}, "@\n";
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
