#!/usr/bin/perl
  
use Modern::Perl;

use C4::Holdings;  # Using NatLibFi Koha features

while (<>) {
    chomp;
    say "Processing $_";
    # my $error = DelHolding($_);  # Feel brave && uncomment
    $error && say $error;
}
