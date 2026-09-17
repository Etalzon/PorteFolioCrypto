// PorteFolioCrypto/Models/BTCViewModel.swift

import SwiftUI
import Combine

class BTCViewModel: ObservableObject, CryptoViewModelProtocol {
    // MARK: - Mapping Protocole
    var price: Double { BTCPrice }
    var history: [PricePoint] { BTCHistory }
    var brandColor: Color { .orange }
    
    @Published var BTCPrice: Double = 0.0
    @Published var BTCPriceUSD: Double = 0.0
    @Published var BTCPriceEUR: Double = 0.0
    @Published var BTCChange: Double = 0.0
    @Published var BTCHistory: [PricePoint] = []
    @Published var isLoading: Bool = false
    @Published var lastUpdated: Date = Date()
    @Published var useMockData: Bool = false
    
    private var timer: Timer?
    
    var changeText: String {
        let sign = BTCChange >= 0 ? "+" : ""
        return "\(sign)\(String(format: "%.2f", BTCChange)) $"
    }
    
    var changeColor: Color {
        BTCChange >= 0 ? .green : .red
    }
    
    init() {
        Task {
            await refreshAsync()
            await fetchHistoryAsync()
        }
        timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            Task {
                await self.refreshAsync()
            }
        }
    }
    
    deinit {
        timer?.invalidate()
    }
    // MARK: - Récupération du prix actuel
    @MainActor
    func refreshAsync() async {
        isLoading = true
        defer { isLoading = false }
        guard let url = URL(string: "https://api.coingecko.com/api/v3/simple/price?ids=bitcoin&vs_currencies=usd,eur") else { return }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard
                let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                let bitcoin = json["bitcoin"] as? [String: Any]
                    else { return }
            
            let usd = (bitcoin["usd"] as? Double) ?? 0.0
            let eur = (bitcoin["eur"] as? Double) ?? 0.0
            
            let previousUSD = self.BTCPriceUSD
            self.BTCPriceUSD = usd
            self.BTCPriceEUR = eur
            self.BTCPrice = usd
            
            if previousUSD != 0 {
                self.BTCChange = usd - previousUSD
            } else {
                self.BTCChange = 0
            }
            self.lastUpdated = Date()
        } catch {
            print("Erreur lors du refresh BTC: \(error)")
        }
    }
    // MARK: - Récupération de l'historique des prix
    @MainActor
    func fetchHistoryAsync() async {
        guard let url = URL(string: "https://api.coingecko.com/api/v3/coins/bitcoin/market_chart?vs_currency=usd&days=max") else { return }
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 429 {
                print("--- Debug BTC: API Bloquée (429). Activation Simulation ---")
                self.useMockData = true
                self.BTCHistory = generateMockData()
                return
            }

            guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let prices = json["prices"] as? [[Any]] else { return }
            
            self.BTCHistory = prices.compactMap { item in
                guard let timestamp = item[0] as? Double,
                      let price = item[1] as? Double else { return nil }
                return PricePoint(date: Date(timeIntervalSince1970: timestamp / 1000), price: price)
            }
        } catch {
            print("Erreur réseau BTC : \(error.localizedDescription)")
        }
    }
    // MARK: - Rafraîchissement des données
    func refresh() {
        Task { await refreshAsync() }
    }
    // MARK: - Récupération de l'historique
    func fetchHistory() {
        Task { await fetchHistoryAsync() }
    }
    // MARK: - Rafraîchissement complet
    func refreshAll() {
        Task {
            isLoading = true
            await refreshAsync()
            await fetchHistoryAsync()
            isLoading = false
        }
    }
    // MARK: - Génération de données simulées
    private func generateMockData() -> [PricePoint] {
        var points: [PricePoint] = []
        let calendar = Calendar.current
        let now = Date()
        let fixedPrices = [20000.0, 25000.0, 40000.0, 30000.0, 60000.0, 45000.0, 55000.0, 68000.0, 50000.0, 62000.0, 76000.0]
        for (i, price) in fixedPrices.enumerated() {
            if let date = calendar.date(byAdding: .year, value: (10 - i) * -1, to: now) {
                points.append(PricePoint(date: date, price: price))
            }
        }
        return points
    }
}
