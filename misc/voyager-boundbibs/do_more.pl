#!/usr/bin/env perl

use Modern::Perl;
use Getopt::Std;
use XML::LibXML::Reader;
use XML::LibXML::XPathContext;

# XPath with LibXML and namespaces is a bit... complicated.
my %XML_NS = ( marc => 'http://www.loc.gov/MARC21/slim' );

# Refs-to-be to simple key–value hashes of ID’s
my ($BIB_MFHDS, $MFHD_BIBS, $BIB_KOHANUMs);

binmode STDOUT, ":utf8";

sub say_all {
    while (my ($mfhd_id, $bib_ids) = each %$MFHD_BIBS) {
        say join ', ', map @{ $BIB_KOHANUMs->{$_} || [] }, @{ $bib_ids };
    }
}

sub read_table_into_hashes {
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

sub main {
    getopts 'b:k:', \my %opts
        or die "USAGE: $0 -bBIB_MFHD -kKOHABNO_001 -rBIBS.xml -wMFHDS.xml\n";
    read_table_into_hashes $opts{'b'}, $BIB_MFHDS = {},
                                       $MFHD_BIBS = {};
    read_table_into_hashes $opts{'k'}, undef, $BIB_KOHANUMs = {};
    say_all;
}

sub do_bibs {
    my $context = shift;
    my @fields = $context->findnodes('
        marc:datafield[@tag=650][@ind2="4"]/
        marc:subfield[@code="a"]/text() ');
    if (@fields) {
        my $bibno = $context->findvalue('
            marc:datafield[@tag="999"]/marc:subfield[@code="c"] ');
        my ($ctrlno, $identifier) = (
            $context->findvalue('marc:controlfield[@tag="001"]'),
            $context->findvalue('marc:controlfield[@tag="003"]') );
        for (@fields) {
            say "$ctrlno\t$identifier\t$bibno\t$_";
        }
    }
}

sub do_mfhds {
    my ($context, $asdf);
}

sub read_xml {
    my ($file, $do_record_sub) = @_;
    my $reader = XML::LibXML::Reader->new(location => $file)
        or warn("WARNING: Cannot read $file\n"), next;

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

main();
