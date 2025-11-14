import Foundation

public final class CLI {

    private let simulatorFactory: SimulatorFactory

    public init(simulatorFactory: SimulatorFactory) {
        self.simulatorFactory = simulatorFactory
    }

    public func start() {
        print("""
        ========================================
              Portfolio Simulator (CLI)
        ========================================
        """)

        while true {
            printMenu()
            print("\nSelect option: ", terminator: "")

            guard let choice = readLine() else {
                continue
            }

            switch choice {
            case "1":
                runDCA()
            case "2":
                runMA()
            case "3":
                runCSV()
            case "4":
                showLastEquityCurve()
            case "5":
                print("Exiting…")
                return
            default:
                print("Invalid choice.\n")
            }
        }
    }

    private func printMenu() {
        print("""
        \n--- MENU ---------------------------------
        1. Run Dollar-Cost Averaging (DCA)
        2. Run Moving Average Crossover
        3. Load & run with CSV data
        4. Show ASCII Equity Curve
        5. Exit
        -----------------------------------------
        """)
    }

    private var lastReport: Report? = nil

    private func runDCA() {
        let dataSource = CSVDataSource(filePath: "data.csv", instrument: Instrument(symbol: "AAPL", currency: .USD))
        let companyName = dataSource.getCompanyName() ?? "Unknown Company"
        
        print("\nDCA Strategy Setup (using data.csv)")
        print("Company: \(companyName)")
        print("-----------------")
        
        print("Enter investment amount (USD): ", terminator: "")
        guard let amountStr = readLine(), let amount = Double(amountStr) else {
            print("Invalid amount. Using default $500")
            let sim = simulatorFactory.createSimulator(strategy: .dca, csvPath: "data.csv")
            runSimulation(sim)
            return
        }
        
        print("Enter interval (days): ", terminator: "")
        guard let intervalStr = readLine(), let interval = Int(intervalStr) else {
            print("Invalid interval. Using default 20 days")
            let sim = simulatorFactory.createSimulator(strategy: .dca, csvPath: "data.csv")
            runSimulation(sim)
            return
        }
        
        let sim = simulatorFactory.createSimulator(
            strategy: .dca,
            dcaAmount: Money(amount, currency: .USD),
            dcaInterval: interval,
            csvPath: "data.csv"
        )
        runSimulation(sim)
    }

    private func runMA() {
        let dataSource = CSVDataSource(filePath: "data.csv", instrument: Instrument(symbol: "AAPL", currency: .USD))
        let companyName = dataSource.getCompanyName() ?? "Unknown Company"
        
        print("\nMoving Average Strategy Setup (using data.csv)")
        print("Company: \(companyName)")
        print("--------------------------")
        
        print("Enter short period (e.g., 5): ", terminator: "")
        guard let shortStr = readLine(), let short = Int(shortStr) else {
            print("Invalid period. Using default 10 days")
            let sim = simulatorFactory.createSimulator(strategy: .ma, csvPath: "data.csv")
            runSimulation(sim)
            return
        }
        
        print("Enter long period (e.g., 20): ", terminator: "")
        guard let longStr = readLine(), let long = Int(longStr) else {
            print("Invalid period. Using default 25 days")
            let sim = simulatorFactory.createSimulator(strategy: .ma, csvPath: "data.csv")
            runSimulation(sim)
            return
        }
        
        if short >= long {
            print("Short period must be less than long period. Using defaults.")
            let sim = simulatorFactory.createSimulator(strategy: .ma, csvPath: "data.csv")
            runSimulation(sim)
            return
        }
        
        let sim = simulatorFactory.createSimulator(
            strategy: .ma,
            maShortPeriod: short,
            maLongPeriod: long,
            csvPath: "data.csv"
        )
        runSimulation(sim)
    }
    
    private func runSimulation(_ simulator: Simulator) {
        let report = simulator.run()
        lastReport = report
        report.printSummary()

        print("\nASCII Equity Curve:")
        drawEquityChart(values: report.equityCurve.map { $0.amount })
    }

    private func runCSV() {
        print("Enter CSV path: ", terminator: "")
        guard let path = readLine() else { return }
        
        // Show company name before running simulation
        let dataSource = CSVDataSource(filePath: path, instrument: Instrument(symbol: "AAPL", currency: .USD))
        if let companyName = dataSource.getCompanyName() {
            print("\nCompany: \(companyName)")
        }
        print("Running simulation with CSV data...\n")

        let sim = simulatorFactory.createSimulator(csvPath: path)
        let report = sim.run()
        lastReport = report
        report.printSummary()

        print("\nASCII Equity Curve:")
        drawEquityChart(values: report.equityCurve.map { $0.amount })

    }

    private func showLastEquityCurve() {
        guard let report = lastReport else {
            print("No simulation run yet.")
            return
        }

        print("\nASCII Equity Curve:")
        drawEquityChart(values: report.equityCurve.map { $0.amount })

    }
}
