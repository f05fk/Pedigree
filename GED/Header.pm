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

package GED::Header;

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

sub getCharset
{
    my $self = shift;

    return $self->{charset};
}

sub setCharset
{
    my $self = shift;
    my $charset = shift;

    $self->{charset} = $charset;
    return $self;
}

sub parse
{
    my $self = shift;
    my $ged = $self->{ged};

    while ($_ = shift @{$ged->{ged_file}})
    {
        # 1 CHAR LATIN1
        if (m/^1 CHAR ?(.*)$/)
        {
            $self->{charset} = $1;
            next;
        }

        if (m/^[0]/)
        {
            unshift @{$ged->{ged_file}}, $_;
            last;
        }

        #print STDERR "Header.parse(): unknown: $_\n";
    }
}

sub write
{
    my $self = shift;
    my $fh = shift;

    print $fh "0 HEAD\n";
    print $fh "1 CHAR $self->{charset}\n";
    print $fh "1 GEDC\n";
    print $fh "2 VERS 5.5\n";
    print $fh "2 FORM LINEAGE-LINKED\n";
}


1;

__END__
