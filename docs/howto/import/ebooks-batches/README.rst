E-kirjapakettien tuonti Kohaan
==============================


Kirjastojen hankkimia e-kirjapaketteja
ei ole luetteloitu Melindaan.
Ainakin ProQuestin Ebook Central (ebrary) toimittaa
tilaukseen kuuluvista kirjoista Marc-tietueet,
jotka voidaan sopivan ``usemarcon``-konversion jälkeen
tuoda suoraan Kohaan.

Ebook Centralista saadaan kuukausittain
``.csv`` ja ``.mrc`` -muotoiset päivitystiedostot,
joiden perusteella Kohasta poistetaan
kirjaston tilaamasta paketista poistuneet kirjat
ja lisätään uudet.

Vanhoille e-kirjatietueille on voitu luoda
tietokantaan erilliset varastotietueet.
Kun e-kirjoja poistuu tilauksista,
varastotietueet on asiallista poistaa ennen biblioita.
Kohan uusissa e-kirjatietueissa on pidetty järkevimpänä
varastotietueen sijaan lisätä pelkkä 852-kenttä biblioon.

Vanhoihin e-kirjalinkkeihin on voitu
jo tietokantaan kovakoodata kirjaston EZproxy.
Uusiin linkkeihin proksyä ei tarvinne lisätä,
koska Finna huolehtii asiasta.


Hyödyllisiä työkaluja
---------------------

``cut``, ``tail``,
``sort``, ``uniq``, ``wc``,
``diff``, ``grep``,
``sed``/``tr``/Vim/? ...

usemarcon
~~~~~~~~~

Asenna ``usemarcon``
`Kansalliskirjaston revosta <https://github.com/NatLibFi/usemarcon>`_
sopivaan paikkaan omalle koneellesi tai muualle.

Ebook Central -tietueiden konversiosäännöt on forkattu
`NatLibFi/USEMARCON-ebrary <https://github.com/NatLibFi/USEMARCON-ebrary>`_
-säännöistä.

Tarkista että ``.rul``:ssa määritellään lisättävä 852-kenttä
ja muut kirjastokohtaiset tiedot oikein.

Aseta ``.ini``’ssä ``OutputFileFormat=MARCXML``
tietueiden jatkokäsittelyn helpottamiseksi.

ebrary-konversion jälkeen ajetaan tarvittaessa vielä
`rda_fin2swe-MARCXML <https://github.com/NatLibFi/USEMARCON-rda_fin2swe>`_
-ruotsinnoskonversio.


Poistot
-------

Poistettavien biblioiden selvittämiseen::

  koha-sysadmin/comp/tools/systemcontrolnumbers2biblionumbers.pl

| ``-f FILU``’tse välitettäviin tunnisteisiin saa esimerkiksi
| ``-p '(CaPaEBR)EBC'``:llä hakua varten lisätyksi Kohassa
  035 $a:ssa käytetyn prefiksin.

Biblioihin liittyvien varastotietueiden listaus::

  mysql -BNe "select holding_id from holdings where biblionumber in (
              `paste -sd, bibnums_list` )" > holdings_list

Parempaa varastotietueiden massapoistotyökalua odotellessa apuna
voi käyttää `simppeliä Perl-silmukkaa <delete_holdings.pl>`_.

.. include:: delete_holdings.pl
  :code: perl

Biblioiden poisto onnistuu intrawebitse virkailijatyökalullakin,
jolla kannattaa myös ennen poistoajoja pistotarkistaa, että
tietueisiin liittyvien varastotietueiden poistolista on oikea.


Lisäykset
---------

Ajetaan haluttu ``usemarcon``-konversio ``.mrc``-lisäystiedostolle.

Ylimääräisenä tarkistuksena voi ``grep``’ata
lisättävien MARC-tietueiden tunnisteet ja 
tarkistaa ``systemcontrolnumbers2biblionumbers.pl``:llä,
ettei tietueita ole Kohassa jo entuudestaan.

Tiedoston välivarastointi (stage marc import) palvelimelta käsin:
``~/Koha/misc/stage_file.pl``

``--match``:lle annetaan haluttaessa
tietueiden yhdistämissääntöjen (Record matching rules)
``marc_matchers``-tietokantataulusta selviävä
``matcher_id`` (*ei* ``code``).
(Mahdollisesti säännössä halutaan käyttää
hakuindeksiä *system-control-number*
ja osumapisteen osissa kentän 035 osakenttää a,
normalisointisääntönä *none*.)

Mahdollisesti välivarastoinnin voisi tehdä intrawebitsekin...

Webin puolella tarkistetaan erän asetukset ja tiedot.
Jos tietueita on jo entuudestaan Kohassa,
kenties halutaan käyttää
Korvaa tietue tuotavalla tietueella -sääntöä
(Replace existing record with incoming record).
