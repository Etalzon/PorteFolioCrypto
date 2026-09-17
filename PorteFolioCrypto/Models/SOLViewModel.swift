// PorteFolioCrypto/Models/SOLViewModel.swift

import SwiftUI
import Combine

class SOLViewModel: ObservableObject, CryptoViewModelProtocol {
    // MARK: - Mapping Protocole
    var price: Double { SOLPrice }
    var history: [PricePoint] { SOLHistory }
    var brandColor: Color { .purple }
    
    @Published var SOLPrice: Double = 0.0
    @Published var SOLPriceUSD: Double = 0.0
    @Published var SOLPriceEUR: Double = 0.0
    @Published var SOLChange: Double = 0.0
    @Published var SOLHistory: [PricePoint] = []
    @Published var isLoading: Bool = false
    @Published var lastUpdated: Date = Date()
    @Published var useMockData: Bool = false
    
    private var timer: Timer?
    
    var changeText: String {
        let sign = SOLChange >= 0 ? "+" : ""
        return "\(sign)\(String(format: "%.2f", SOLChange)) $"
    }
    
    var changeColor: Color {
        SOLChange >= 0 ? .green : .red
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
        guard let url = URL(string: "https://api.coingecko.com/api/v3/simple/price?ids=solana&vs_currencies=usd,eur") else { return }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard
                let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                let solana = json["solana"] as? [String: Any]
                    else { return }
            
            let usd = (solana["usd"] as? Double) ?? 0.0
            let eur = (solana["eur"] as? Double) ?? 0.0
            
            let previousUSD = self.SOLPriceUSD
            self.SOLPriceUSD = usd
            self.SOLPriceEUR = eur
            self.SOLPrice = usd
            
            if previousUSD != 0 {
                self.SOLChange = usd - previousUSD
            } else {
                self.SOLChange = 0
            }
            self.lastUpdated = Date()
        } catch {
            print("Erreur lors du refresh SOL: \(error)")
        }
    }
    // MARK: - Récupération de l'historique des prix
    @MainActor
    func fetchHistoryAsync() async {
        guard let url = URL(string: "https://api.coingecko.com/api/v3/coins/solana/market_chart?vs_currency=usd&days=max") else { return }
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 429 {
                self.useMockData = true
                self.SOLHistory = generateMockData()
                return
            }

            guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let prices = json["prices"] as? [[Any]] else { return }
            
            self.SOLHistory = prices.compactMap { item in
                guard let timestamp = item[0] as? Double,
                      let price = item[1] as? Double else { return nil }
                return PricePoint(date: Date(timeIntervalSince1970: timestamp / 1000), price: price)
            }
        } catch {
            print("Erreur réseau SOL : \(error.localizedDescription)")
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
        let fixedPrices = [10.0, 20.0, 5.0, 100.0, 250.0, 150.0, 80.0, 120.0, 160.0, 200.0, 180.0]
        for (i, price) in fixedPrices.enumerated() {
            if let date = calendar.date(byAdding: .year, value: (10 - i) * -1, to: now) {
                points.append(PricePoint(date: date, price: price))
            }
        }
        return points
    }
}
