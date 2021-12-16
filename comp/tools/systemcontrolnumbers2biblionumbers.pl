#!/usr/bin/perl

# 2019 NatLibFi
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

use Modern::Perl;
use Getopt::Long;

use Koha::SearchEngine;
use Koha::SearchEngine::Search;

use open ':std', ':encoding(UTF-8)';  # Defuse UTF-8 BOMs

my ($help, $syscontrolnumberfile, $prefix) = (0, '', '');

GetOptions(
    'h|help' => \$help,
    'f|syscontrolnumfile=s' => \$syscontrolnumberfile,
    'p|prefix=s' => \$prefix,
    );

my $usage = << 'ENDUSAGE';
This script prints corresponding biblionumbers for given list of
system control numbers (035a) in a file.

USAGE:
perl systemcontrolnumbers2biblionumbers.pl -f syscontrolnums.txt

ENDUSAGE


sub get_systemcontrolnums {
    open my $fh, '<', $syscontrolnumberfile
        or die "$syscontrolnumberfile: $!";
    my @systemcontrolnumbers = <$fh>;
    close $fh;
    chomp @systemcontrolnumbers;
    @systemcontrolnumbers = grep { $_ ne '' } @systemcontrolnumbers;
    return @systemcontrolnumbers;
}

sub print_biblionumber {
    my $system_control_number = shift;
    my $query = "system-control-number=\"$system_control_number\"";
    my $searcher = Koha::SearchEngine::Search->new({
            index => $Koha::SearchEngine::BIBLIOS_INDEX});

    # Expect $results to be ref to array of MARC::Records. Fetches only 2:
    my ($err, $results, $total_hits) =
        $searcher->simple_search_compat($query,0,2);

    if ($err) {
	print STDERR "Error: $err from search $query";
    } elsif ($total_hits == 0) {
	print STDERR "No hits for $system_control_number, skipping\n";
    } elsif ($total_hits > 1) {
	print STDERR "Multiple hits ($total_hits) ",
                "for $system_control_number, skipping\n";

	# To print multiple hits, maybe use something like:
	#for my $result (@$results) {
	#    print $searcher->extract_biblionumber( $result ) . "\n";
	#}
    } else {
	print $searcher->extract_biblionumber( @$results[0] ) . "\n";
    }
}

sub main {
    if ($help || !$syscontrolnumberfile) {
	print $usage;
	exit 0;
    }

    my @systemcontrolnumbers = get_systemcontrolnums();

    foreach my $systemcontrolnum (@systemcontrolnumbers) {
	$systemcontrolnum = $prefix . $systemcontrolnum;
	print_biblionumber($systemcontrolnum);
    }
}

main();
