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

package GED::Family;

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

    my $husband = $self->getHusband();
    $husband->removeFamilySpouse($self) if (defined $husband);

    my $wife = $self->getWife();
    $wife->removeFamilySpouse($self) if (defined $wife);

    foreach my $child ($self->getChildren())
    {
        $child->removeFamilyChild($self);
    }
    
    $self->{ged}->removeFamily($self);

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

sub getHusband
{
    my $self = shift;

    return $self->{husband};
}

sub setHusband
{
    my $self = shift;
    my $husband = shift;

    $self->{husband} = $husband;
    return $self;
}

sub removeHusband
{
    my $self = shift;
    my $husband = shift;

    delete $self->{husband};
    return $self;
}

sub getWife
{
    my $self = shift;

    return $self->{wife};
}

sub setWife
{
    my $self = shift;
    my $wife = shift;

    $self->{wife} = $wife;
    return $self;
}

sub removeWife
{
    my $self = shift;
    my $wife = shift;

    delete $self->{wife};
    return $self;
}

sub removeSpouse
{
    my $self = shift;
    my $spouse = shift;

    if ($self->getHusband() == $spouse)
    {
        $self->removeHusband();
    }

    if ($self->getWife() == $spouse)
    {
        $self->removeWife();
    }

    return $self;
}

sub getMarriage
{
    my $self = shift;

    return $self->{marriage};
}

sub setMarriage
{
    my $self = shift;
    my $marriage = shift;

    $self->{marriage} = $marriage;
    return $self;
}

sub getChildren
{
    my $self = shift;

    return values %{$self->{children}};
}

sub getChild
{
    my $self = shift;
    my $child = shift;

    return $self->{children}->{$child->getId()};
}

sub addChild
{
    my $self = shift;
    my $child = shift;

    $self->{children}->{$child->getId()} = $child;
    return $self;
}

sub removeChild
{
    my $self = shift;
    my $child = shift;

    delete $self->{children}->{$child->getId()};
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
