#!/usr/bin/perl

# 2019 NatLibFi Brunberg J
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

use strict;
use warnings;

use C4::Context;

binmode(STDOUT, ":utf8");

while (my $line = <>) {
    my @table_and_key = (
            [ qw( issues        issue_id        ) ],
            [ qw( accountlines  accountlines_id ) ],
            [ qw( reserves      reserve_id      ) ] );
    my @to_update = map { $_->[0] } @table_and_key;

    # Accept a line with two borrowernumbers like:
    # FROM [,] TO [[,] COMMENTS]
    $line =~ m/^([1-9][0-9]*) *,? *([1-9][0-9]*) *([ ,] *(.*))?$/
        or print "Line ignored: $line\n" and next;
    my %borrower = ( from => { number => $1 },
                     to   => { number => $2 } );
    print "\nProcessing line: $line";

    # Get borrowers' information and counts.
    my $dbh = C4::Context->new_dbh;   # Not so efficient, but...
    for my $whom ('from', 'to') {
        my $res = $dbh->selectrow_hashref(
                " select cardnumber, surname, firstname,
                      email, phone, address, zipcode, city
                  from borrowers
                  where borrowernumber = ?; ",
                undef,
                $borrower{$whom}{'number'}
            ) or die "DB ERROR: ${$dbh->errstr}\n";
        $borrower{$whom}{'info'} = $res;

        $res = $dbh->selectrow_arrayref(
                " select attribute
                  from borrower_attributes
                  where borrowernumber = ?
                    and code = 'SSN'; ",
                undef,
                $borrower{$whom}{'number'}
            ) or die "DB ERROR: ${$dbh->errstr}\n";
        $borrower{$whom}{'info'}{'hetu'} = $res->[0] if $res;

        for my $what (@to_update) {
            $res = $dbh->selectrow_arrayref(
                    " select count(*)
                      from $what
                      where borrowernumber = ?; ",
                    undef,
                    $borrower{$whom}{'number'}
                ) or die "DB ERROR: ${$dbh->errstr}\n";
            push @{$borrower{$whom}{'old_count'}}, $res->[0];
        }
    }
    $dbh->disconnect;   #... at least this shouldn't time out...

    # Show what we have and confirm.
    print "Confirm transfer (@to_update)\n";
    for my $whom ('from', 'to') {
        my $iref = $borrower{$whom}{'info'};

        no warnings 'uninitialized';
        print "$whom $iref->{'cardnumber'}",
            " (@{$borrower{$whom}{'old_count'}})",
            " aka $iref->{'hetu'}",
            " $iref->{'surname'} $iref->{'firstname'}",
            " <$iref->{'email'}> {",
            "$iref->{'address'}, $iref->{'zipcode'} $iref->{'city'}",
            "}, $iref->{'phone'}\n";
    }

    print "? ";
    unless ( (<STDIN> // 'no') =~ m/^ *y(es)? *?$/i ) {
        print "Processing of line was cancelled.\n";
        next;
    }

    # Print what is to be transferred, and finally
    # update database (if not commented out below).
    $dbh = C4::Context->new_dbh;      # ... if the user is slow.
    for my $t_k (@table_and_key) {
        my @row_id = map { @$_ } $dbh->selectall_array(
                " select $t_k->[1]
                  from $t_k->[0]
                  where borrowernumber = ?
                  order by $t_k->[1]; ",
                undef,
                $borrower{'from'}{'number'}
            );

        print "Updating from $borrower{'from'}{'number'}",
            " $t_k->[0]: @row_id.\n";

my $commented = <<'COMMENTEND';
        my $rows = $dbh->do(
                " update $t_k->[0]
                  set borrowernumber = ?
                  where borrowernumber = ?; ",
                undef,
                $borrower{'to'}{'number'},
                $borrower{'from'}{'number'}
            ) or die "DB ERROR: ${$dbh->errstr}\n";
        # Note that if 0, then $rows eq '0E0', so it will print.
        print "Updated $rows $t_k[0] rows",
            " from $borrower{'from'}{'number'}",
            " to $borrower{'to'}{'number'}.\n" if $rows;
COMMENTEND
    }
    $dbh->disconnect;
}
