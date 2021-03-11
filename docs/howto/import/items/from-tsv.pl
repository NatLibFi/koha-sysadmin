#!/usr/bin/perl

use Modern::Perl;
sub timestamp { use POSIX; strftime('%Y%m%dT%H%M%SZ', gmtime) }

# Get inside your FOSS ILS Koha Perl environment and uncomment!
#use Koha::Item;
#use Koha::SearchEngine::Indexer;

# For efficiency, we will be doing separately (comment out to skip):
my $do_import_items++;          # (one by one, when looping over <>)
my $do_update_biblios_index++;  # (for biblionumbers encountered)

my %to_reindex;

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
    my ($biblionumber, $k, $h, $z) = split /\t/, $itsv;
    say "Skipping\t$itsv" and next  # Maybe an empty line?
        unless defined $biblionumber && $biblionumber =~ /^\d+$/;

    if ($do_import_items) {
        # Log what we are processing to standard output
        print timestamp, " adding\t$itsv\t";
        # If this fails, you kept log, didn’t you?
        my $item = Koha::Item->new( {
                biblionumber => $biblionumber,
                holding_id => $k,  # Does your Koha have MFHD records?
                ccode => $_8,
                homebranch => $a,
                holdingbranch => $b,
                location => $c,
                enumchron => $h,
                itemcallnumber => $o,
                #barcode => $p,
                itype => $y,
                itemnotes_nonpublic => $z,
            } )->store(my $dontindex = { skip_record_index => 1 });
        say my $inum = $item->itemnumber();  # Finish successful logline
        $item->set({ barcode => "INUM$inum" })->store($dontindex);
    }
    ++$to_reindex{$biblionumber};
}

if ($do_update_biblios_index) {
    my $count = my @bnos = keys %to_reindex;
    say timestamp, " updating search index for $count biblionumbers";
    Koha::SearchEngine::Indexer->new(
        { index => $Koha::SearchEngine::BIBLIOS_INDEX }
    )->index_records(\@bnos, 'specialUpdate', 'biblioserver');
}

say timestamp, " finishing.";
