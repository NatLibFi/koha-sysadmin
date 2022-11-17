Koha ja sähköposti
==================

Tiedekirjastojen Koha-asennuksissa on käytössä (noin) kolme
eri lähestymistapaa sähköpostien lähettämiseen. Tavat eroavat
toisistaan siinä, minkä **domainin** (esimerkiksi helsinki.fi)
nimissä viestit lähetetään ja miten tämä tehdään vakuuttavasti,
niin ettei viestiä tulkita spämmiksi.

Spämmin torjunnassa ollaan tarkkoja siitä, minkä osoitteen
lähettävä sovellus (eli Koha) ilmoittaa viestin eteenpäin
välittävälle SMTP-palvelimelle **Envelope Sender** -osoitteenaan.
Jos viestin välittäminen epäonnistuu, paluuviesti (bounce-viesti)
yritetään toimittaa tähän osoitteeseen.
Osoite ei välttämättä ole sama kuin vastaanottajan silmiä
varten viestin From- tai Reply To -kenttään merkitty osoite.
Vastaanottaja saattaa pystyä päättelemään Sender-osoitteen
viestin Return Path -kentästä, mutta perinteisesti
sähköpostiohjelmat ovat oletuksena piilottaneet tämän kentän.

Tapa 1: Lähettäjänä ja välittäjänä CSC
--------------------------------------

Useimmilla tiede-Kohilla Sender-osoite on muotoa
no-reply-kirjasto@csc.fi, ja viestit välitetään
CSC:n SMTP-palvelimen kautta.
Kyseessä on aliasosoite, johon tulevat paluuviestit
CSC:n sähköpostiylläpito on automaattisesti ohjannut
eteenpäin kirjaston toivomaan ”**bounce**”-osoitteeseen.
Käytössä olevat ohjaukset on dokumentoitu Kohan
Eduuni-wikisivuilla.

Tässä vaihtoehdossa aliaksen takana oleva ”bounce”-osoite,
johon paluuviestit lopulta ohjautuvat, ei välttämättä näy
Kohan asetuksissa missään. Sama osoite on kuitenkin mahdollista
ilmoittaa viestin Reply-To-kentässä, jos halutaan, että
asiakas voi helposti vastata viestiin sähköpostiohjelman
Reply-toiminnolla. Tämä ei välttämättä ole suositeltavaa.

Suositeltavaa lienee, että From-kentässä säädetään
tässä lähestymistavassa näkymään no-reply-aliasosoite.
(Näihin viesteissä asiakkaille näkyviin osoitteisiin
vaikuttaa useampi Kohan asetus – joiden dokumentointi
kuulunee Koha-yhteisön wikiin?)

Tapa 2: Lähettäjänä kirjasto, välittäjänä CSC
---------------------------------------------

Jos kirjasto haluaa CSC:n tarjoaman no-reply-aliasosoitteen
sijaan käyttää omaa osoitettaan Sender-osoitteena, Koha voi
silti välittää viestit CSC:n SMTP-palvelimen kautta, kunhan 
Sender Policy Framework eli **SPF** on kunnossa.
Tämä tarkoittaa, että Sender-osoitteesta ilmenevän domainin
DNS-nimipalvelutiedoissa on merkintä, että CSC voi lähettää
viestejä kyseisen domainin nimissä.

Vaihtoehtona SPF:lle käytetään joskus myös
**DKIM**-allekirjoituksia, mutta tämä vaihtoehto ei
liene(?) ollut tiede-Kohissa käytössä eikä ehkä relevantti.

Tapa 3: Lähettäjänä ja välittäjänä oma organisaatio
---------------------------------------------------

Joissakin kirjastoissa Sender-osoitteena on käytetty omaa
osoitetta niin, että Koha välittää viestit kyseessä olevan
korkeakoulun oman SMTP-palvelimen kautta.
SMTP-palvelin tunnistaa ehkä Koha-palvelimen sallituksi
IP-osoitteen perusteella, tai sitten Koha tunnistautuu
sallituksi lähettäjäksi jollakin muulla, erikseen
sovitulla tavalla.
