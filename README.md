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
