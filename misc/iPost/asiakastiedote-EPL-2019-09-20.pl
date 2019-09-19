#!/usr/bin/perl

# 2019 NatLibFi Brunberg J
#
# A simple while loop that copies an inlined iPost EPL letter to many
# recipients.  Output is to STDOUT, and you may need to convert it
# yourself both to Latin charset and DOS format with CRLF linebreaks
# before sftp transfer to Posti.

use strict;
use warnings;

my $id__pwd = '**********';  # should be 6 + 4 chars
my $contact = 'koha-posti@....fi/Kansalliskirjasto';
my $department = 'OURWBSNO';
my $creceipt = 'koha-posti@....fi';

print <<"HEADEREND";
EPL1${id__pwd}0TT001SDZ0                $contact
HEADEREND
# Set 16th chr ^ to T for testing, blank for production.
# (See: iPost EPL Design Guide, 05.05.2018)

while (<>) {
    chomp;
    # Expect input in .tsv format:
    my ($name, $address, $zip_, $city) = split /\t/;
    $zip_ =~ /^\d{5}$/ or die "ERROR: $name has bad zip $zip_.\n";

    print <<"MESSAGEND";
EPLKFI$zip_   100                       $department
10Kansalliskirjasto
EPL8DEFF
 0PL 15
 000014 HELSINGIN YLIOPISTO
20$name
00$address
 0$zip_ $city
5020.09.2019
00TIEDOTE
 0MEDDELANDE
 0NOTICE
00Kansalliskirjasto
 0Nationalbiblioteket
 0The National Library of Finland
00Unioninkatu 36, Helsinki
 0Unionsgatan 36, Helsingfors
00https://www.kansalliskirjasto.fi/
37Tiedote Kansalliskirjaston asiakkaille: Syksyn 2019 muutokset /
 7Förändringar i Nationalbibliotekets tjänster i hösten 2019 /
 7Changes in National Library of Finland's services in autumn 2019
 H
 H
 7Hyvä Kansalliskirjaston asiakas
 H
 H    Kansalliskirjasto vaihtoi kirjastojärjestelmänsä syksyllä 2019.
 H    Kansalliskirjaston aineistot ja lainat siirtyivät 24.8. alkaneen
 H    katkon aikana Helkasta Kansalliskirjaston omaan hakupalveluun
 H    (kansalliskirjasto.finna.fi). Kansalliskirjaston lainat voi
 H    nyt uusia vain Kansalliskirjaston hakupalvelussa. Päivitäthän
 H    asiakastietojen muutokset (esimerkiksi puhelinnumero ja osoite)
 H    jatkossa molempiin erikseen, jos olet asiakkaana sekä
 H    Kansalliskirjastossa että Helka-kirjastoissa.
 H
 7    Hae uusi kirjastokortti käyttöösi
 H
 H    Kansalliskirjaston käyttäjänä tarvitset oman kansalliskirjasto-
 H    kortin. Sen saat 2.9. alkaen käymällä Kansalliskirjastossa.
 H    Ota mukaan henkilöllisyystodistus.
 H
 H    Kansalliskirjastossa Helka-korttia voi käyttää vain
 H    30.11. saakka. Helka-kortti toimii jatkossakin Helka-
 H    kirjastoissa asioidessa. Uusi kansalliskirjastokortti
 H    kannattaa hakea mahdollisimman pian, jotta lainojen
 H    uusimisiin ei myöhemmin tule katkoksia.
 H
 7    Tutustu uusiin käyttösääntöihin ja rekisteriselosteeseen
 H
 H    Kirjaston käyttösäännöt 2.9. alkaen:
 H    https://www.kansalliskirjasto.fi/fi/asiointi/
 H    tyoskentely-kirjastossa/kansalliskirjaston-kayttosaannot
 H
 H    Uuden kirjastokortin tietosuojaseloste:
 H    https://kansalliskirjasto.finna.fi/Content/about
 H    ?lng=fi#tietosuojaseloste
 H
 H    Lue lisää muutoksista sekä niiden vaikutuksista
 H    Usein kysyttyjä kysymyksiä -sivulta:
 H    https://www.kansalliskirjasto.fi/fi/asiointi/neuvonta/
 H    syksyn-2019-muutokset
 H
 H    Voit ottaa yhteyttä neuvontaamme sähköpostitse osoitteessa
 H    kk-palvelu\@helsinki.fi tai puhelimitse numeroon 02941 23196.
1H
EPL8DEFF
 H
 7Bästa kunder
 H
 H    Nationalbiblioteket bytte ut sitt bibliotekssystem i hösten 2019.
 H    Alla Nationalbibliotekets material och lån förflyttat från Helka
 H    till Nationalbibliotekets egen söktjänst kansalliskirjasto.finna.fi
 H    under ett avbrott som inleds 24.8. I fortsättningen kan du förnya
 H    dina lån i Nationalbibliotekets söktjänst. Ärenden som hör till
 H    Nationalbiblioteket kan i fortsättningen inte skötas i andra
 H    Helkabibliotek. Också ändringar i kunduppgifter (t.ex.
 H    telefonnummer och adress) ska i fortsättningen meddelas
 H    separat till Nationalbiblioteket och andra Helkabibliotek.
 H
 7    Så här får du det nya bibliotekskortet
 H
 H    Du får Nationalbibliotekskortet från och med 2.9 genom att besöka
 H    Nationalbiblioteket. Kom ihåg att ta med ett identitesbevis.
 H
 H    I Nationalbiblioteket kan Helkakortet ända fram till 30.11.
 H    Helkakortet fungerar som tidigare i Helkabibliotek. Det lönar sig
 H    ändå att ansöka om det nya Nationalbibliotekskortet så snart som
 H    möjligt för att undvika att det senare blir fördröjningar när du
 H    ska förnya lån.
 H
 7    Nya användarregler och registerbeskrivning
 H
 H    Nationalbibliotekets användarregler från 2.9:
 H    https://www.kansalliskirjasto.fi/sv/
 H    nationalbibliotekets-anvandarregler
 H
 H    Nationalbibliotekskorts registerbeskrivning: 
 H    https://kansalliskirjasto.finna.fi/Content/about
 H    ?lng=sv#dataskyddsbeskrivning
 H
 H    Läs mer om förändringar i:
 H    https://www.kansalliskirjasto.fi/sv/som-kund/kundtjanst/
 H    forandringar-i-bibliotekets-tjanster-hosten-2019
 H
 H    Du kan kontakta vår kundtjänst per e-post på adressen
 H    kk-palvelu\@helsinki.fi eller per telefon på numret 02941 23196.
1H
EPL8DEFF
 H
 7Dear customer
 H
 H    In the autumn 2019 new library systems was introduced at the
 H    National Library of Finland. During a break in services beginning
 H    on 24 August, all National Library materials and loans were
 H    transferred from Helka to the National Library Search Service
 H    kansalliskirjasto.finna.fi. From 2 September onwards, National
 H    Library loan renewals, requests and reservations are made through
 H    the National Library Search. Those will no longer be possible
 H    through other Helka libraries. In future, phone numbers, home
 H    addresses and other customer details will also be updated
 H    separately for the National Library and Helka libraries.
 H
 7    Get your new library card
 H
 H    A National Library card can be obtained from 2 September
 H    onwards by visiting the National Library. Please remember
 H    to bring official proof of identity with you.
 H
 H    At the National Library, Helka cards will only be accepted until
 H    30 November. Helka library cards will remain valid when using
 H    services provided by Helka libraries. You should obtain a new
 H    National Library card as soon as possible to avoid gaps in
 H    renewing loans.
 H
 7    New Rules of the National Library of Finland
 7    and Data Protection Statement
 H
 H    Rules of the National Library of Finland from 2.9.2019:
 H    https://www.kansalliskirjasto.fi/en/
 H    rules-of-the-national-library-of-finland
 H
 H    New Data Protection Statement:
 H    https://kansalliskirjasto.finna.fi/Content/about
 H    ?lng=en-gb#tietosuojaseloste
 H
 H    Read more on changes:
 H    https://www.kansalliskirjasto.fi/en/using-the-library/
 H    information/changes-in-autumn-2019
 H
 H    You can contact our information service by email at
 H    kk-palvelu\@helsinki.fi or by phone at +358 2941 23196.
MESSAGEND
}
print "EPLZ$creceipt\n";
