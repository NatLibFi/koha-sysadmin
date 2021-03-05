#!/usr/bin/perl

use Modern::Perl;

# Get inside your FOSS ILS Koha Perl environment and uncomment!
#use Koha::Item;

# Define some default subfield values for all items to be added
# ( https://wiki.koha-community.org/wiki/Holdings_data_fields_(9xx) )
my (    $_8,    $a,     $b,     $c,     $o,     $y ) =
    qw( FEN     MFVAR   MFVAR   VARMF   MF      LS );

# USAGE: ./from-tsv.pl [ITEMSFILE]...
# (OR use standard input instead of named files)
while (my $itsv = <>) {
    chomp $itsv;

    # We should have read one line from our input,
    # with these tab-separated item subfield values:
    my ($biblionumber, $k, $h, $z) =
        split /\t/, $itsv;

    print "$itsv\t"; # Log what we are processing to STDOUT
    my $item = Koha::Item->new( {
            biblionumber => $biblionumber,
            holding_id => $k, # Does your Koha have MFHD records?
            ccode => $_8,
            homebranch => $a,
            holdingbranch => $b,
            location => $c,
            enumchron => $h,
            itemcallnumber => $o,
            #barcode => $p,
            itype => $y,
            itemnotes_nonpublic => $z,
        } )->store; # If this fails, you have the log, haven’t you?
    say my $inum = $item->itemnumber(); # Finish successful logline
    $item->update( { barcode => "INUM$inum" } );
}
