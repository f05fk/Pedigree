#!/usr/bin/perl
#########################################################################
# Copyright (C) 2010 Claus Schrammel                                    #
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

package GED::Individual;

use strict;

use GED::DatePlace;

sub new
{
    my $self = {};
    bless $self;
    my $classname = shift;

    my $id = shift;
    $self->{id} = $id;

    my $ged = shift;
    $self->{ged} = $ged;

    return $self;
}

sub remove
{
    my $self = shift;

    my $familyChild = $self->getFamilyChild();
    $familyChild->removeChild($self) if (defined $familyChild);

    foreach my $familySpouse ($self->getFamiliesSpouse())
    {
        $familySpouse->removeSpouse($self);
    }

    $self->{ged}->removeIndividual($self);

    return $self;
}

sub getId
{
    my $self = shift;

    return $self->{id};
}

sub setId
{
    my $self = shift;
    my $id = shift;

    $self->{id} = $id;
    return $self;
}

sub getFirstname
{
    my $self = shift;

    return $self->{firstname};
}

sub setFirstname
{
    my $self = shift;
    my $firstname = shift;

    $self->{firstname} = $firstname;
    return $self;
}

sub getLastname
{
    my $self = shift;

    return $self->{lastname};
}

sub setLastname
{
    my $self = shift;
    my $lastname = shift;

    $self->{lastname} = $lastname;
    return $self;
}

sub getTitle
{
    my $self = shift;

    return $self->{title};
}

sub setTitle
{
    my $self = shift;
    my $title = shift;

    $self->{title} = $title;
    return $self;
}

sub getName
{
    my $self = shift;

    return $self->{name};
}

sub setName
{
    my $self = shift;
    my $name = shift;

    $self->{name} = $name;
    return $self;
}

sub getSex
{
    my $self = shift;

    return $self->{sex};
}

sub setSex
{
    my $self = shift;
    my $sex = shift;

    $self->{sex} = $sex;
    return $self;
}

sub getBirth
{
    my $self = shift;

    return $self->{birth};
}

sub setBirth
{
    my $self = shift;
    my $birth = shift;

    $self->{birth} = $birth;
    return $self;
}

sub getDeath
{
    my $self = shift;

    return $self->{death};
}

sub setDeath
{
    my $self = shift;
    my $death = shift;

    $self->{death} = $death;
    return $self;
}

sub getOccupation
{
    my $self = shift;

    return $self->{occupation};
}

sub setOccupation
{
    my $self = shift;
    my $occupation = shift;

    $self->{occupation} = $occupation;
    return $self;
}

sub getFamilyChild
{
    my $self = shift;

    return $self->{familyChild};
}

sub setFamilyChild
{
    my $self = shift;
    my $familyChild = shift;

    $self->{familyChild} = $familyChild;
    return $self;
}

sub removeFamilyChild
{
    my $self = shift;
    my $familyChild = shift;

    delete $self->{familyChild};
    return $self;
}

sub getFamiliesSpouse
{
    my $self = shift;

    return values %{$self->{familiesSpouse}};
}

sub getFamilySpouse
{
    my $self = shift;
    my $familySpouse = shift;

    return $self->{familiesSpouse}->{$familySpouse->getId()};
}

sub addFamilySpouse
{
    my $self = shift;
    my $familySpouse = shift;

    $self->{familiesSpouse}->{$familySpouse->getId()} = $familySpouse;
    return $self;
}

sub removeFamilySpouse
{
    my $self = shift;
    my $familySpouse = shift;

    delete $self->{familiesSpouse}->{$familySpouse->getId()};
    return $self;
}

sub getNote
{
    my $self = shift;

    return $self->{note};
}

sub setNote
{
    my $self = shift;
    my $note = shift;

    $self->{note} = $note;
    return $self;
}

sub getChange
{
    my $self = shift;

    return $self->{change};
}

sub setChange
{
    my $self = shift;
    my $change = shift;

    $self->{change} = $change;
    return $self;
}

sub parse
{
    my $self = shift;
    my $ged = $self->{ged};

    while ($_ = shift @{$ged->{ged_file}})
    {
        # 1 NAME Claus /Schrammel/ DI
        if (m/^1 NAME (.+) \/(.+)\/ (.*?)$/)
        {
            $self->{firstname} = $1;
            $self->{lastname} = $2;
            $self->{title} = $3;
            $self->{name} = "$3 $1 $2";
            next;
        }

        # 1 NAME Claus /Schrammel/
        if (m/^1 NAME (.+) \/(.+)\/$/)
        {
            $self->{firstname} = $1;
            $self->{lastname} = $2;
            $self->{name} = "$1 $2";
            next;
        }

        # 1 NAME Claus //
        if (m/^1 NAME (.+) \/\/$/)
        {
            $self->{firstname} = $1;
            $self->{name} = $1;
            next;
        }

        # 1 NAME /Schrammel/
        if (m/^1 NAME \/(.+)\/$/)
        {
            $self->{lastname} = $1;
            $self->{name} = $1;
            next;
        }

        # 1 NAME Claus
        if (m/^1 NAME (.+)$/)
        {
            $self->{firstname} = $1;
            $self->{name} = $1;
            next;
        }

        # 1 SEX M
        if (m/^1 SEX (.+)$/)
        {
            $self->{sex} = $1;
            next;
        }

        if (m/^1 BIRT$/)
        {
            $self->{birth} = new GED::DatePlace($ged);
            $self->{birth}->parse();
            next;
        }

        if (m/^1 DEAT$/)
        {
            $self->{death} = new GED::DatePlace($ged);
            $self->{death}->parse();
            next;
        }

        if (m/^1 OCCU (.+)$/)
        {
            $self->{occupation} = $1;
            $self->{occupation_date_place} = new GED::DatePlace($ged);
            $self->{occupation_date_place}->parse();
            next;
        }

        # 1 FAMC @F54@
        if (m/^1 FAMC \@(.+)\@$/)
        {
            $self->{familyChild} = $ged->getOrCreateFamily($1);
            next;
        }

        # 1 FAMS @F2@
        if (m/^1 FAMS \@(.+)\@$/)
        {
            $self->{familiesSpouse}->{$1} = $ged->getOrCreateFamily($1);
            next;
        }

        if (m/^1 NOTE (.+)$/)
        {
            $self->{note} = $1;
            next;
        }

        if (m/^1 CHAN$/)
        {
            $self->{change} = new GED::DatePlace($ged);
            $self->{change}->parse();
            next;
        }

        if (m/^0/)
        {
            unshift @{$ged->{ged_file}}, $_;
            last;
        }

        print STDERR "Individual.parse(): unknown: $_\n";
    }
}

sub write
{
    my $self = shift;
    my $fh = shift;

    print $fh "0 @", $self->{id}, "@ INDI\n";

    if ($self->{name})
    {
        my $name = "/" . $self->{lastname} . "/";
        $name = $self->{firstname} . " " . $name if($self->{firstname});
        $name = $name . " " . $self->{title} if ($self->{title});
        print $fh "1 NAME ", $name, "\n";
    }

    if ($self->{sex})
    {
        print $fh "1 SEX ", $self->{sex}, "\n";
    }

    if ($self->{birth})
    {
        print $fh "1 BIRT\n";
        $self->{birth}->write($fh);
    }

    if ($self->{death})
    {
        print $fh "1 DEAT\n";
        $self->{death}->write($fh);
    }

    if ($self->{occupation})
    {
        print $fh "1 OCCU ", $self->{occupation}, "\n";
        $self->{occupation_date_place}->write($fh);
    }

    foreach my $familySpouse (sort {substr($a->getId(),1) <=> substr($b->getId(),1)}
                             $self->getFamiliesSpouse())
    {
        print $fh "1 FAMS @", $familySpouse->getId(), "@\n";
    }

    if ($self->{familyChild})
    {
        print $fh "1 FAMC @", $self->{familyChild}->getId(), "@\n";
    }

#    if ($self->{note})
#    {
#        print $fh "1 NOTE ", $self->{note}, "\n";
#    }
#
#    if ($self->{change})
#    {
#        print $fh "1 CHAN\n";
#        $self->{change}->write($fh);
#    }
}


1;

__END__
