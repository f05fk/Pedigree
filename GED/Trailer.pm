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

package GED::Trailer;

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

sub parse
{
    my $self = shift;
    my $ged = $self->{ged};

    while ($_ = shift @{$ged->{ged_file}})
    {
        if (m/^[0]/)
        {
            unshift @{$ged->{ged_file}}, $_;
            last;
        }

        #print STDERR "Trailer.parse(): unknown: $_\n";
    }
}

sub write
{
    my $self = shift;
    my $fh = shift;

    print $fh "0 TRLR\n";
}


1;

__END__
