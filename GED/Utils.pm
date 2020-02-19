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

package GED::Utils;

use strict;

use GED::GED;

#sub new
#{
#    my $self = {};
#    bless $self;
#    my $classname = shift;
#
#    my $ged = shift;
#    $self->{ged} = $ged;
#
#    return $self;
#}

sub findLoops
{
    my $self = shift;
#    my $ged = $self->{ged};
    my $ged = shift;

    foreach my $element ($ged->getIndividuals(), $ged->getFamilies())
    {
        if (scalar($element->getSuccessors()) > 1)
        {
            my @path0 = $ged->getDescendants(($element->getSuccessors())[0]);
            my @path1 = $ged->getDescendants(($element->getSuccessors())[1]);

            my $match0;
            my $match1;
            for my $current0 (@path0)
            {
                if (grep {$_ == $current0} @path1)
                {
                    $match0 = $current0;
                    last;
                }
            }
            for my $current1 (@path1)
            {
                if (grep {$_ == $current1} @path0)
                {
                    $match1 = $current1;
                    last;
                }
            }

            if (!defined $match0 && !defined $match1) {
                next;
            }
            if (!defined $match0 || !defined $match1) {
                print STDERR "ERROR: only one match\n";
                next;
            }
            if ($match0 != $match1) {
                print STDERR "ERROR: matches don't match\n";
                next;
            }

            $element->{loop} = 1;
            for my $current0 (@path0)
            {
                $current0->{loop} = 1;
                last if ($current0 == $match0);
            }
            for my $current1 (@path1)
            {
                $current1->{loop} = 1;
                last if ($current1 == $match1);
            }
        }
    }
}


1;

__END__
