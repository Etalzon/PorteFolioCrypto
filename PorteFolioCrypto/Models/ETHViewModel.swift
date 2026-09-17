// PorteFolioCrypto/Models/ETHViewModel.swift

import SwiftUI
import Combine

class ETHViewModel: ObservableObject, CryptoViewModelProtocol {
    // MARK: - Mapping Protocole
    var price: Double { ETHPrice }
    var history: [PricePoint] { ETHHistory }
    var brandColor: Color { .blue }
    
    @Published var ETHPrice: Double = 0.0
    @Published var ETHPriceUSD: Double = 0.0
    @Published var ETHPriceEUR: Double = 0.0
    @Published var ETHChange: Double = 0.0
    @Published var ETHHistory: [PricePoint] = []
    @Published var isLoading: Bool = false
    @Published var lastUpdated: Date = Date()
    @Published var useMockData: Bool = false
    
    private var timer: Timer?
    
    var changeText: String {
        let sign = ETHChange >= 0 ? "+" : ""
        return "\(sign)\(String(format: "%.2f", ETHChange)) $"
    }
    
    var changeColor: Color {
        ETHChange >= 0 ? .green : .red
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
        guard let url = URL(string: "https://api.coingecko.com/api/v3/simple/price?ids=ethereum&vs_currencies=usd,eur") else { return }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard
                let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                let ethereum = json["ethereum"] as? [String: Any]
                    else { return }
            
            let usd = (ethereum["usd"] as? Double) ?? 0.0
            let eur = (ethereum["eur"] as? Double) ?? 0.0
            
            let previousUSD = self.ETHPriceUSD
            self.ETHPriceUSD = usd
            self.ETHPriceEUR = eur
            self.ETHPrice = usd
            
            if previousUSD != 0 {
                self.ETHChange = usd - previousUSD
            } else {
                self.ETHChange = 0
            }
            self.lastUpdated = Date()
        } catch {
            print("Erreur lors du refresh ETH: \(error)")
        }
    }
    // MARK: - Récupération de l'historique des prix
    @MainActor
    func fetchHistoryAsync() async {
        guard let url = URL(string: "https://api.coingecko.com/api/v3/coins/ethereum/market_chart?vs_currency=usd&days=max") else { return }
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 429 {
                self.useMockData = true
                self.ETHHistory = generateMockData()
                return
            }

            guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let prices = json["prices"] as? [[Any]] else { return }
            
            self.ETHHistory = prices.compactMap { item in
                guard let timestamp = item[0] as? Double,
                      let price = item[1] as? Double else { return nil }
                return PricePoint(date: Date(timeIntervalSince1970: timestamp / 1000), price: price)
            }
        } catch {
            print("Erreur réseau ETH : \(error.localizedDescription)")
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
        let fixedPrices = [500.0, 800.0, 2000.0, 1500.0, 4000.0, 3000.0, 3500.0, 4800.0, 3200.0, 3800.0, 4100.0]
        for (i, price) in fixedPrices.enumerated() {
            if let date = calendar.date(byAdding: .year, value: (10 - i) * -1, to: now) {
                points.append(PricePoint(date: date, price: price))
            }
        }
        return points
    }
}
