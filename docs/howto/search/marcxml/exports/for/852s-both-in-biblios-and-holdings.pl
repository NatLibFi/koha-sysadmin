#!/usr/bin/env perl

use Modern::Perl;
use XML::LibXML::Reader;
use XML::LibXML::XPathContext;

binmode STDOUT, ":utf8";

# XML namespaces are dreadful, but we must play along
# to make marcxml and libxml2 work together.
my %namespace = ( marc => 'http://www.loc.gov/MARC21/slim' );

# Valid xml is expected.  Each file may be either
# a single marc record or a collection of records.
warn "USAGE: $0 RECORDs.xml ...\n" unless @ARGV;

sub do_record {
    my $xpc = shift;
    my $cno = $xpc->findvalue( # Which biblio is this ...
        'marc:datafield[@tag="999"]/marc:subfield[@code="c"]');
    my $eno = $xpc->findvalue( # ... or related holdings record?
        'marc:datafield[@tag="999"]/marc:subfield[@code="e"]');

    for my $field ($xpc->findnodes('marc:datafield[@tag="852"]')) {
        my $ind12 = $xpc->findvalue('concat(@ind1, @ind2)', $field);
        my $subfields = join ' |',
                map $xpc->findvalue('concat(@code, text())', $_),
                $xpc->findnodes('marc:subfield', $field);

        say "$cno\t$eno\t852 $ind12 |$subfields";
    }
}

# Each record node found is just passed to the &do_record sub.
# This parsing approach adapted from ‘Perl XML::LibXML by Example’,
# http://grantm.github.io/perl-libxml-by-example/large-docs.html
for my $file (@ARGV) {
    my $reader = XML::LibXML::Reader->new(location => $file)
        or warn("WARNING: Cannot read $file\n"), next;

    my $xpc = XML::LibXML::XPathContext->new();
    while (my ($prefix, $uri) = each %namespace) {
        $xpc->registerNs($prefix, $uri);
    }

    while ($reader->read) {
        next unless $reader->nodeType == XML_READER_TYPE_ELEMENT;
        next unless $reader->name eq 'record';

        $xpc->setContextNode( $reader->copyCurrentNode(1) );

        my $uri = $reader->namespaceURI || '';
        warn "WARNING: record has foreign XML namespace $uri\n"
            unless grep $_ eq $uri, values %namespace;

        do_record $xpc;

        $reader->next;
    }
}
