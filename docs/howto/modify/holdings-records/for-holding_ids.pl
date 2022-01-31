#!/usr/bin/perl

use Modern::Perl;
sub timestamp { use POSIX; strftime('%Y%m%dT%H%M%SZ', gmtime) }

# Get inside your FOSS ILS Koha Perl environment and uncomment!
use Koha::Holdings;
use Koha::SearchEngine::Indexer;

# For efficiency, we will be doing separately (set to 0 to skip):
my $do_modify_holdings_records = 1;  # (id by id, when looping over <>)
my $do_update_biblios_index = 1;     # (for biblionumbers encountered)

my %to_reindex;

# USAGE: ./for-holding_ids.pl [IDFILE]...
# (OR use standard input instead of named files)
while (my $holding_id = <>) {
    chomp $holding_id;

    # Log to standard output. Do save it, will you?
    say "Skipping $holding_id"  # Maybe an empty line?
        and next unless $holding_id =~ /^\d+$/;

    my $holding = Koha::Holdings->find($holding_id);
    my $biblionumber = $holding->biblionumber();

    say "No biblionumber found for, skipping $holding_id"
        and next unless $biblionumber;
    
    if ($do_modify_holdings_records) {
        my $record = $holding->metadata()->record();
        my $field = $record->field('852');

        if ($field->subfield('c') eq 'ROTAVO') {
            $field->update(c => 'MUSAVO');

            say timestamp, " modifying\t$holding_id";

            $holding->set_marc({ record => $record });
            $holding->store({ skip_record_index => 1 });
        } else {
            say "Not modifying $holding_id";
        }
    }
    ++$to_reindex{$biblionumber}
}

if ($do_update_biblios_index) {
    my $count = my @bnos = sort keys %to_reindex;
    say timestamp, " updating search index for $count biblionumbers";
    Koha::SearchEngine::Indexer->new(
        { index => $Koha::SearchEngine::BIBLIOS_INDEX }
    )->index_records(\@bnos, 'specialUpdate', 'biblioserver');
}

say timestamp, " finishing.";
