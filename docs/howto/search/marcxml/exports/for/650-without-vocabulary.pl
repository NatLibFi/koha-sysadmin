#!/usr/bin/env perl

use Modern::Perl;
use XML::LibXML::Reader;
use XML::LibXML::XPathContext;

binmode STDOUT, ":utf8";

# XML namespaces are dreadful, but we must play along
# to make marcxml and libxml2 work together.
my %namespace = ( marc => 'http://www.loc.gov/MARC21/slim' );

sub do_record {
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
