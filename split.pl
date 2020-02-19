#!/usr/bin/perl
#########################################################################
# Copyright (C) 2012 Claus Schrammel                                    #
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

use strict;
use warnings;

my $orientation = "-p";
my $y_sheets = 1;
my $file;

foreach my $arg (@ARGV)
{
    $orientation = $arg if ($arg eq "-p");
    $orientation = $arg if ($arg eq "-l");
    $y_sheets = $1 if ($arg =~ m/^-(\d+)$/);
    $file = $1 if ($arg =~ m/(.+)\.png$/);
}
print "orientation $orientation\n";
print "y_sheets $y_sheets\n";
print "file $file\n";

my $output = `file $file.png`;
$output =~ m/(\d+) x (\d+)/   || die "cannot get image size";
my $x_orig = $1;
my $y_orig = $2;
print "x_orig $x_orig\n";
print "y_orig $y_orig\n";

my $y_sheet = int($y_orig / $y_sheets + 0.99999);
print "y_sheet $y_sheet\n";
my $x_sheet_tmp = $y_sheet / 297.0 * 210.0 if ($orientation eq "-p");
print "x_sheet_tmp $x_sheet_tmp\n";
   $x_sheet_tmp = $y_sheet / 210.0 * 297.0 if ($orientation eq "-l");
print "x_sheet_tmp $x_sheet_tmp\n";
#my $sheets = int($x_orig / $x_sheet_tmp + 0.99999);
my $sheets = int($x_orig / $x_sheet_tmp + 0.9);
print "sheets $sheets\n";
my $x_sheet = int($x_orig / $sheets + 0.99999);
print "x_sheet $x_sheet\n";

system("./split.sh $file ${x_sheet}x${y_sheet}");
