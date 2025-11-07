# OlioOhjelmointi harjoitustyö Sijoitussalkun simulaattori & backtesteri

📈 PortfolioSimulator
CLI-pohjainen sijoitussimulaattori — analysoi strategioita, visualisoi tulokset ASCII-grafiikalla, ajaa CSV-markkinadataa ja tuottaa raportit.
  Yleiskuvaus

PortfolioSimulator on Swiftillä toteutettu sijoitusstrategioiden simulaattori, jolla voi:

✅ Simuloida Dollar-Cost Averaging (DCA) -strategiaa
✅ Simuloida Moving Average Crossover (MA 10/25) -strategiaa
✅ Ladata oikeaa markkinadataa CSV-tiedostosta
✅ Analysoida tuottoja — CAGR, Max Drawdown, Sharpe
✅ Visualisoida salkun kehityksen ASCII-tyylisenä kurssikäyränä
✅ Tulostaa tulokset CSV- ja JSON-raportteina

Projekti toimii täysin komentoriviltä, ja sen voi ajaa millä tahansa Swift-ympäristöllä (macOS, Linux, Windows Swift toolchain).

Asennus
1. Kloonaa projekti
  git clone https://github.com/matioskari/olioohjelmointiHT.git
  cd olioohjelmointiHT

2. Rakenna projekti
  swift build

3. Aja simulaattori
  swift run PortfolioSimulator


Käyttövalikko (CLI)

Ohjelma avaa valikon:

--- MENU ------------------------------------
1. Run Dollar-Cost Averaging (DCA)
2. Run Moving Average Crossover
3. Load & run with CSV data
4. Show ASCII Equity Curve
5. Exit
---------------------------------------------

📊 Esimerkkiajo CSV-datalla

Komentoriviltä:

swift run PortfolioSimulator -- --strategy ma --csv data.csv


Tuloste:

✅ CSVDataSource: loaded 251 candles.
=== Report ===
Strategy: Moving Average Crossover (10/25)
Trades: 9
CAGR: -0.43%
Max Drawdown: -1.12%
Sharpe: -0.64
Final equity: 9963.65 USD


ASCII-grafiikka:

=== ASCII Equity Curve ===
10006.12 | ███████████████████████
10013.25 | █████████████████████████████
10016.73 | ████████████████████████████████
...


CSV-tiedoston muoto

Ohjelma hyväksyy monia päivämääräformaatteja:

yyyy-MM-dd
MM-dd-yyyy
dd-MM-yyyy


Ja otsikkoriviksi käy:

Date,Open,High,Low,Close,Volume

tai

timestamp,open,high,low,close,volume

Esimerkki:

11-06-2025,196.42,197.62,186.38,188.08,223029797


Teknologiat ja rakenne
Osa:	                    Kuvaus:
Swift CLI	              Komentoriviohjelma
CSVDataSource	          CSV-markkinadatan lukija
Simulator	              Ajaa strategiaa kynttilädatan yli
Broker & Portfolio	    Ostot, myynnit, käteinen, positio
Strategies/	            DCA ja MA Crossover -strategiat
Reporting	              CAGR, Drawdown, Sharpe, Equity Curve
ASCII Chart Renderer	  Visualisoi salkun kehityksen tekstigrafiikkana
