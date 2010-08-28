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

use IO::File;

use GED::Header;
use GED::Individual;
use GED::Family;
use GED::Trailer;

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
            my $header = new GED::Header($self);
            $self->{header} = $header;

            $header->parse();
            next;
        }

        # 0 @B1@ SUBM
        if (m/^0 \@(.+)\@ SUBM$/)
        {
            my $submitter = new GED::Individual($1, $self);
            $self->{submitters}->{$1} = $submitter;

            $submitter->parse();
            next;
        }

        # 0 @I5@ INDI
        if (m/^0 \@(.+)\@ INDI$/)
        {
            my $individual = $self->getOrCreateIndividual($1);
            $individual->parse();
            next;
        }

        # 0 @F2@ FAM
        if (m/^0 \@(.+)\@ FAM$/)
        {
            my $family = $self->getOrCreateFamily($1);
            $family->parse();
            next;
        }

        if (m/^0 TRLR$/)
        {
            my $trailer = new GED::Trailer($self);
            $self->{trailer} = $trailer;

            $trailer->parse();
            next;
        }

        print STDERR "GED.parse(): unknown: $_\n";
    }

}

sub save
{
    my $self = shift;
    my $ged_file_name = shift;

    my $fh = new IO::File(">$ged_file_name")
        or die "cannot open GED file '$ged_file_name': $!";

    $self->{header}->write($fh);

    foreach my $individual (sort {substr($a->getId(),1) <=> substr($b->getId(),1)}
                            $self->getIndividuals())
    {
        $individual->write($fh);
    }

    foreach my $family (sort {substr($a->getId(),1) <=> substr($b->getId(),1)}
                        $self->getFamilies())
    {
        $family->write($fh);
    }

    $self->{trailer}->write($fh);

    $fh->close();
}


1;

__END__
