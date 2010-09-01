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

package DOT::DOT;

use strict;

sub new
{
    my $self = {};
    bless $self;
    my $classname = shift;

    print "digraph G\n{\n";

    return $self;
}

sub close
{
    my $self = shift;

    print "}\n";
}

sub family
{
    my $self = shift;
    my $family = shift;

    # family node with start of label attribute
    print "    ", $family->{id}, " [shape=ellipse,label=\"";

    # married couples
    my $marriage = $family->{marriage};
    if ($marriage)
    {
        print "oo";
    }

    # marriage details
    my $marriage_date = $family->{marriage}->{date};
    my $marriage_place = $family->{marriage}->{place};
    if ($marriage_date && $marriage_place)
    {
        print " $marriage_date\\n$marriage_place";
    }
    elsif ($marriage_date)
    {
        print " $marriage_date";
    }
    elsif ($marriage_place)
    {
        print " $marriage_place";
    }

    # close the label
    print "\"";

    # group DOT nodes
    if ($family->{group})
    {
        print ",group=\"", $family->{group}, "\"";
    }

    if ($family->{loop})
    {
        print ",style=\"filled\",color=\"red\"";
    }

    # close the node attributes
    print "];\n";
}

sub individual
{
    my $self = shift;
    my $individual = shift;

    # individual node with start of label attribute
    print "    ", $individual->{id}, " [shape=box,label=\"";

    # name
    my $name = $individual->{name};
    print $name;

    # profession
    my $occupation = $individual->{occupation};
    if ($occupation)
    {
        print "\\n$occupation";
    }

    # birth details
    my $birth_date = $individual->{birth}->{date};
    my $birth_place = $individual->{birth}->{place};
    if ($birth_date && $birth_place)
    {
        print "\\n* $birth_date, $birth_place";
    }
    elsif ($birth_date)
    {
        print "\\n* $birth_date";
    }
    elsif ($birth_place)
    {
        print "\\n* $birth_place";
    }

    # death details
    my $death_date = $individual->{death}->{date};
    my $death_place = $individual->{death}->{place};
    if ($death_date && $death_place)
    {
        print "\\n+ $death_date, $death_place";
    }
    elsif ($death_date)
    {
        print "\\n+ $death_date";
    }
    elsif ($death_place)
    {
        print "\\n+ $death_place";
    }

    # close the label
    print "\"";

    # group DOT nodes
    if ($individual->{group})
    {
        print ",group=\"", $individual->{group}, "\"";
    }

    if ($individual->{loop})
    {
        print ",style=\"filled\",color=\"red\"";
    }

    # close the node attributes
    print "];\n";
}

sub link
{
    my $self = shift;
    my $from = shift;
    my $to = shift;

    my $weight = shift;

    # edge with attributes
    print "    ", $from->{id}, " -> ", $to->{id}, " [style=bold";

    # weight
    if ($weight)
    {
        print ",weight=", $weight;
    }
    else
    {
        print ",weight=1";
    }

    # close the edge attributes
    print "];\n";
}


1;

__END__
