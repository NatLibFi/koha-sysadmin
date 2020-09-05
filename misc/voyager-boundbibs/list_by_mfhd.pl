#!/usr/bin/env perl

use Modern::Perl;
use Getopt::Std;
use XML::LibXML::Reader;
use XML::LibXML::XPathContext;

# LibXML offers no conveniences for XPaths with namespaces.
my %XML_NS = ( marc => 'http://www.loc.gov/MARC21/slim' );

# Refs-to-be to simple key–value hashes of ID’s
my ($BIB_MFHDS, $MFHD_BIBS, $BIB_KOHANUMs);
my ($BIB_TITLE, $MFHD_CALLNO, $KNUM_KHOSTS, $KHOST_KNUMS);

binmode STDOUT, ":utf8";

sub is_complicated {
    my $mfhd_id = shift;
    my ($bounds_found, $others_found) = (0, 0);
    for my $bib_id (@{ $MFHD_BIBS->{$mfhd_id} }) {
        unless ($bounds_found) {
            for my $m2_id (@{ $BIB_MFHDS->{$bib_id} }) {
                @{ $MFHD_BIBS->{$m2_id} } > 1
                    and $bounds_found = 1;
            }
        }
        @{ $BIB_MFHDS->{$bib_id} } > 1
            and $others_found = 1;
    }
    return $bounds_found && $others_found;
}

sub bounds_differ {
    my @mfhds_to_check = shift;
    my (%matched_mfhds, %matched_khosts);

    MFHD: while (@mfhds_to_check) {
        my $mfhd_id = shift @mfhds_to_check;
        next if $matched_mfhds{$mfhd_id};
        my @mfhd_bibs = @{ $MFHD_BIBS->{$mfhd_id} || [] }; 
        next unless @mfhd_bibs > 1; # TODO: match single-bib to Koha Holding?

        my %possible_khosts;
        for my $bib_id (@mfhd_bibs) {
            my @bib_kohanum = @{ $BIB_KOHANUMs->{$bib_id} || [] };
            return 1 unless @bib_kohanum == 1; # not checked again in KANDI
            for (@{ $KNUM_KHOSTS->{$bib_kohanum[0]} || [] }) {
                $matched_khosts{$_} or $possible_khosts{$_} = 1;
            }
            push @mfhds_to_check, @{ $BIB_MFHDS->{$bib_id} || [] };
        }
        
        KANDI: for my $kandidate (keys %possible_khosts) {
            my @khost_knums = @{ $KHOST_KNUMS->{$kandidate} || [] };
            next unless @khost_knums == @mfhd_bibs;
            for my $kno (map $BIB_KOHANUMs->{$_}[0], @mfhd_bibs) {
                next KANDI unless grep $_ == $kno, @khost_knums;
            }
            $matched_mfhds{$mfhd_id} = $matched_khosts{$kandidate} = 1;
            next MFHD;
        }
        return 1;
    }
    return 0;
}

sub say_all {
    say join "\t", qw(Sijainti Nimeke biblionumber BIB_ID MFHD_ID);
    while (my ($mfhd_id, $bib_ids) = each %$MFHD_BIBS) {
        #next unless is_complicated $mfhd_id;
        next unless bounds_differ $mfhd_id;
        for my $bib_id (@$bib_ids) {
            say join "\t",
                    $MFHD_CALLNO->{$mfhd_id} || "",
                    $BIB_TITLE->{$bib_id} || "",
                    $BIB_KOHANUMs->{$bib_id}[0] || "",
                    $bib_id,
                    $mfhd_id;
        }
    }
}

sub read_associations_into_hashes {
    my ($file, $forwards, $backwards) = @_;
    open my $fh, '<', $file
        or die "Could not open $file\n";
    while (<$fh>) {
        chomp;
        my ($first, $second) = split;
        $forwards and push @{ $forwards->{$first} }, $second;
        $backwards and push @{ $backwards->{$second} }, $first;
    }
}

sub do_bib_node {
    my $context = shift;
    my $bib_id = $context->findvalue('marc:controlfield[@tag="001"]');
    $BIB_TITLE->{$bib_id} = join ' ', $context->findnodes('
        marc:datafield[@tag="245"]/*/text() ');
}

sub do_holdings_node {
    my $context = shift;
    my $mfhd_id = $context->findvalue('marc:controlfield[@tag="001"]');
    $MFHD_CALLNO->{$mfhd_id} = join ' ', $context->findnodes('
        marc:datafield[@tag="852"]/
        *[@code="b" or @code="h" or @code="i"]/text() ');
}

sub do_koha_record {
    my $xpc = shift;
    my $bibno = $xpc->findvalue('
        marc:datafield[@tag="999"]/*[@code="c"] ');

    for my $field ( $xpc->findnodes('marc:datafield[@tag="773"]') ) {
        next unless 'Yhteissidos' eq
                $xpc->findvalue('marc:subfield[@code="i"]', $field);

        my $host = $xpc->findvalue('marc:subfield[@code="w"]', $field);

        push @{ $KHOST_KNUMS->{$host} }, $bibno;
        push @{ $KNUM_KHOSTS->{$bibno} }, $host;
    }
}

sub read_xml {
    my ($file, $do_record_sub) = @_;
    return unless $file; # (Yes, "0" too is false and ignored.)
    my $reader = XML::LibXML::Reader->new(location => $file)
        or warn("WARNING: Cannot read $file\n"), return;

    my $xpc = XML::LibXML::XPathContext->new();
    while (my ($prefix, $uri) = each %XML_NS) {
        $xpc->registerNs($prefix, $uri);
    }

    while ($reader->read) {
        next unless $reader->nodeType == XML_READER_TYPE_ELEMENT;
        next unless $reader->name eq 'record';

        $xpc->setContextNode( $reader->copyCurrentNode(1) );

        my $uri = $reader->namespaceURI || '';
        warn "WARNING: record has foreign XML namespace $uri\n"
            unless grep $_ eq $uri, values %XML_NS;

        $do_record_sub->($xpc);

        $reader->next;
    }
}

sub run {
    getopts 'b:k:r:w:x:', \my %opts
        or die "USAGE: $0 -bBIB_MFHD -kKOHABNO_001 " # Always required
                . "-rBIBS.xml -wMFHDS.xml " # For titles and callnumbers
                . "-xKOHABIBLIOS.xml\n"; # To list only differing bounds

    read_associations_into_hashes(@$_) for (
        [ $opts{'b'} || '-b', $BIB_MFHDS = {}, $MFHD_BIBS = {}    ],
        [ $opts{'k'} || '-k', undef,           $BIB_KOHANUMs = {} ],
    );

    read_xml $opts{'r'}, \&do_bib_node;
    read_xml $opts{'w'}, \&do_holdings_node;
    read_xml $opts{'x'}, \&do_koha_record;

    say_all;
}

run;
