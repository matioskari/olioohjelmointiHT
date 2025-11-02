# OlioOhjelmointi harjoitustyö Sijoitussalkun simulaattori & backtesteri

Aihe: Sijoitussalkun simulaattori ja backtesteri

Kuvaus:
Tämä harjoitustyö on Swift-ohjelmointikielellä toteutettava komentorivisovellus,
joka simuloi sijoitussalkun kehitystä ja testaa sijoitusstrategioiden toimivuutta
historiallisen markkinadatan avulla.

Ohjelma mahdollistaa eri sijoitusstrategioiden, kuten
- Dollar-Cost Averaging (DCA)
- Liukuvan keskiarvon risteämisstrategia (Moving Average Crossover)
vertailun ja tuottojen laskennan käyttäen CSV-muotoista markkinadataa tai synteettisesti
generoitua dataa.

Simulaattori mallintaa todellisen sijoittamisen logiikkaa:
se pitää kirjaa omistuksista, kaupoista ja salkun arvon kehityksestä ajan mittaan.
Backtesteri käyttää näitä tietoja arvioidakseen, miten strategia olisi toiminut menneisyydessä.

Keskeiset ominaisuudet
- Markkinadatalähteet
  - CSV-tiedostosta luettava historiallinen data
  - Synteettisen datan generointi testikäyttöön (esim. satunnaisprosessi)
- Sijoitusstrategiat
  - *Dollar-Cost Averaging (DCA)* – sijoittaa kiinteän summan säännöllisesti
  - *Moving Average Crossover* – ostaa/myy kun lyhyt ja pitkä liukuva keskiarvo risteävät
- Salkunhallinta
  - Käteinen, positiot, keskihinnat ja realisoidut voitot/tappiot
  - Broker-luokka toteuttaa toimeksiannot ja kulut
- Riskimittarit
  - Kokonaistuotto, CAGR, volatiliteetti, max drawdown, Sharpen luku
- Raportointi
  - Tuottaa raportin salkun kehityksestä ja tallentaa sen tiedostoon (CSV/JSON)
  - Näyttää tulokset tekstipohjaisessa käyttöliittymässä (CLI)