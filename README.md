# PortfolioSimulator – Sijoitusstrategioiden backtester (Swift / CLI)

Kuvaus:
Tämä projekti on osa kurssin Olio-ohjelmointi harjoitustyötä. Toteutin täysin komentorivipohjaisen sijoitussimulaattorin, joka tukee eri sijoitusstrategioita, CSV-datan lataamista, salkun kehityksen laskentaa sekä ASCII-grafiikkapohjaisen equity-käyrän piirtämistä.

Projektissa on selkeä modulaarinen arkkitehtuuri (OOP), ja kaikki strategiat, datalähteet ja laskentalogiikka ovat helposti laajennettavissa.


Ominaisuudet:
	- Kaksi valmista sijoitusstrategiaa:
		- Dollar-Cost Averaging (DCA)
		- Moving Average Crossover (10/25 SMA)
	- Lataa markkinadata CSV-tiedostosta
	- Moniformaattinen päivämääräparseri
	- ASCII-grafiikkapohjainen equity curve
	- Raporttigeneraattori, joka laskee:
		- CAGR
		- Max Drawdown
		- Sharpe Ratio
		- Voittavat/häviävät kaupat
	- Selkeä CLI-valikko
	- Modulaarinen arkkitehtuuri (Strategy/DataSource/Portfolio/Report)

	
Projketin rakenne:
olioohjelmointiHT/
└── PortfolioSimulator/
    ├── Package.swift
    ├── README.md
    ├── Sources/
    │   └── PortfolioSimulator/
    │       ├── main.swift
    │       ├── CLI.swift
    │       ├── Candle.swift
    │       ├── DataSource.swift
    │       ├── CSVDataSource.swift
    │       ├── Strategy.swift
    │       ├── DCA.swift
    │       ├── MovingAverageCrossover.swift
    │       ├── Portfolio.swift
    │       ├── Report.swift
    │       └── ASCIIChart.swift
    └── data.csv (valinnainen)

	
Käyttöohje:
Käynnistä projektin juurihakemistossa:
	swift run
	
Saat näkyviin valikon:
1. Run Dollar-Cost Averaging (DCA)
2. Run Moving Average Crossover
3. Load & run with CSV data
4. Show ASCII Equity Curve
5. Exit
-----------------------------------------
Select option:


CSV-tuonti:
Ohjelma hyväksyy kolme eri päivämääräformaattia:

	- YYYY-MM-DD
	- MM-DD-YYYY
	- DD-MM-YYYY

Esimerkki:
Date,Open,High,Low,Close,Volume
11-06-2025,196.42,197.62,186.38,188.08,223029797

Huomaa:
Volume voi sisältää pilkkuja tai ei
Hinnat voivat olla merkkijonoissa "123.45"


ASCII-käyrä:
Ohjelma tuottaa visuaalisen käyrän ilman grafiikkakirjastoja:

ASCII Equity Curve
-----------------------------------------
$200 |
$180 | ███████
$160 | ████▇▇██
$140 | ███▇▇███▇
$120 | ██▇▇█▇███
$100 |
-----------------------------------------
Start → … → End


Esimerkki simulaatiotuloksesta:
=== Report ===
Strategy: Moving Average Crossover (10/25)
Trades: 12
CAGR: 13.84%
Max Drawdown: -10.72%
Sharpe: 0.91

ASCII Equity Curve:
██████▇▇▇▇▇███████


Teknologiat:
	- Swift 5.9+
	- Swift Package Manager
	- Olio-ohjelmointi (protocol-oriented design)
	- CSV-datan käsittely
	- CLI-sovellus
	- Rahoituksen tunnusluvut (Sharpe, CAGR, MDD)