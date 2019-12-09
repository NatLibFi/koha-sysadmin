(Luonnos Tietolinjassa 2019(2) julkaistuun
[artikkeliin] (http://urn.fi/URN:NBN:fi-fe2019120445617))

Koha ja varastotietueen tarkoitus
=================================

Korkeakoulujen käyttämä Voyager-kirjastojärjestelmä
lähestyy Suomessa loppuaan.
Lokakuussa 2019 olivat Voyagerista uusiin tietokantoihin
siirtyneet kaikki viisitoista kirjastoa ja kimppaa, jotka
valitsivat korvaajaksi _vapaita ojelmistoja_ edustavan Kohan.
Siirtymää vauhditti yhteisön tuki, sillä yleisissä kirjastoissa
Kohaa on Suomessakin ehditty käyttää jo muutaman vuoden ajan.

Vapaata ohjelmistoa on periaatteessa mahdollista
kehittää ja räätälöidä täysin kirjastojen tarpeiden mukaan,
jos aika vain riittää, ja kunhan ohjelmiston vapautta
ei GPL-ehtojen vastaisesti rajoiteta.
Eräs Kohan käyttöönotossa pohdittavaksi tullut
kirjastojärjestelmän kehityskysymys
liittyy vanhassa järjestelmässä Voyagerissa
käytettyihin varastotietueisiin eli MFHD:ihin
(_MARC 21 Format for Holdings Data_),
joille Kohassa ei ole ollut tukea valmiiksi.

## Mikä on varastotietue?

MARC 21 -muotoinen bibliografinen tietue
kuvailee kirjan tai muun sellaisen,
mutta jättää avoimeksi kysymyksen:
miksi se on kuvailtu kirjaston tietokantaan?
Usein vastaukseksi riittää,
että kirja kuuluu kirjaston kokoelmiin,
eikä tätä tarvitse kertoa jokaiselle kirjalle erikseen.
Ehkä tietokantaa käyttää vain yksi kirjasto,
tai jos vaikka kirjastoja on useampikin,
ehkä kokoelmat ovat siinä määrin yhteisiä,
että niistä puhutaan vain monikossa.

Kun samassa tietokannassa elää rinnan useampi itsellinen kokoelma,
bibliografiseen tietueeseen halutaan ehkä
liittää kirjasto- tai kokoelmakohtaista tietoa,
joka halutaan pitää yhteisestä tietueesta erillään.
Tätä varten ovat varastotietueet.

Varastotietueet oikeuttavat
bibliografisen tietueen olemassaolon tietokannassa
liittämällä sen yhteen tai useampaan kokoelmaan
eli kuvailemalla tietueen roolin osana kokoelmaa.

Yksinkertaisimmillaan varastotietueessa kerrotaankin
vain kokoelmatieto ja hyllypaikka MARC-kentässä 852.
Yhtä ainoaa kenttää ei välttämättä ole perusteltua
sijoittaa omaan erilliseen varastotietueeseen,
ja MARC 21 -formaatti sallii kentän lisäämisen
suoraan bibliografiseen tietueeseenkin.
Kuitenkin jos sijaintitietoja on enemmän kuin yksi
ja niihin liittyy muutakin tietoa (esimerkiksi niteitä), 
erillinen varastotietue tarvitaan liittämään
yhteen kuuluvat tiedot toisiinsa.

## Tarttuuko se?

Varastotietuekentät kuuluvat MARC 21 -formaattiin,
mutta ne on eriytetty bibliografisista tiedoista,
eikä formaatti pakota käyttämään niitä.

Tärkein syy yhteisen MARC-formaatin käyttöön on
kuvailutietojen siirtäminen järjestelmien välillä.
Varastotietoja ei kuitenkaan perinteisesti
ole ollut tarvetta siirtää järjestelmien välillä
muuten kuin järjestelmävaihdoksen yhteydessä,
eivätkä varastotietueet ole joustavin tietorakenne
esimerkiksi kelluville kokoelmille.
Sen verran ilmaisuvoimaisia ne kuitenkin ovat,
että niitä on järjestelmävaihdoksen yhteydessä ollut
vaikea nopeasti korvata muullakaan ratkaisulla.
On käynyt niin, että Voyagerista on datan mukana
tuotu Kohaan myös varastotietueen käsite.

Varastotietueet ovat siis tarttuvia,
samaan tapaan kuin vapaa ohjelmakoodi.

## Tarvitaanko torjuntaa?

Kuten MARC-formaatti yleisemminkin myös varastotietueet
ovat käytännössä osoittaneet olevansa sekä toimivia
että myös enemmän tai vähemmän vaikesti hävitettäviä.
Kohaan on Kansalliskirjastossa lisätty
mahdollisuus varastotietueiden käyttöön,
mutta pakkoa ei ole.

Kansalliskirjaston omassa tietokannassa
varastotietueiden käyttöä jatketaan,
koska niitä tarvitaan kokoelmatietoihin.
Monessa muussa entisessä Voyager-kirjastossa
varastotietueet ovat vain ylimääräinen kerros 
bibliografisen tietueen ja nidetietojen välissä,
ja niistä ollaan siksi luopumassa.
Ainakin väliaikaisesti nähdään myös hybridimallia:
samassa kirjastossa osassa tietueista
on varastotietueet ja toisissa ei.
Koha on joustava.
