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


1;

__END__
