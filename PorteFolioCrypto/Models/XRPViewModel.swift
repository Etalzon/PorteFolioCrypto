// PorteFolioCrypto/Models/XRPCViewModel.swift

import SwiftUI
import Combine

class XRPViewModel: ObservableObject, CryptoViewModelProtocol {
    // MARK: - Mapping Protocole
    var price: Double { XRPPrice }
    var history: [PricePoint] { XRPHistory }
    var brandColor: Color { .cyan }
    
    @Published var XRPPrice: Double = 0.0
    @Published var XRPPriceUSD: Double = 0.0
    @Published var XRPPriceEUR: Double = 0.0
    @Published var XRPChange: Double = 0.0
    @Published var XRPHistory: [PricePoint] = []
    @Published var isLoading: Bool = false
    @Published var lastUpdated: Date = Date()
    @Published var useMockData: Bool = false
    
    private var timer: Timer?
    
    var changeText: String {
        let sign = XRPChange >= 0 ? "+" : ""
        return "\(sign)\(String(format: "%.2f", XRPChange)) $"
    }
    
    var changeColor: Color {
        XRPChange >= 0 ? .green : .red
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
        guard let url = URL(string: "https://api.coingecko.com/api/v3/simple/price?ids=ripple&vs_currencies=usd,eur") else { return }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard
                let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                let ripple = json["ripple"] as? [String: Any]
                    else { return }
            
            let usd = (ripple["usd"] as? Double) ?? 0.0
            let eur = (ripple["eur"] as? Double) ?? 0.0
            
            let previousUSD = self.XRPPriceUSD
            self.XRPPriceUSD = usd
            self.XRPPriceEUR = eur
            self.XRPPrice = usd
            
            if previousUSD != 0 {
                self.XRPChange = usd - previousUSD
            } else {
                self.XRPChange = 0
            }
            self.lastUpdated = Date()
        } catch {
            print("Erreur lors du refresh XRP: \(error)")
        }
    }
    // MARK: - Récupération de l'historique des prix
    @MainActor
    func fetchHistoryAsync() async {
        guard let url = URL(string: "https://api.coingecko.com/api/v3/coins/ripple/market_chart?vs_currency=usd&days=max") else { return }
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 429 {
                self.useMockData = true
                self.XRPHistory = generateMockData()
                return
            }

            guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let prices = json["prices"] as? [[Any]] else { return }
            
            self.XRPHistory = prices.compactMap { item in
                guard let timestamp = item[0] as? Double,
                      let price = item[1] as? Double else { return nil }
                return PricePoint(date: Date(timeIntervalSince1970: timestamp / 1000), price: price)
            }
        } catch {
            print("Erreur réseau XRP : \(error.localizedDescription)")
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
        let fixedPrices = [0.2, 0.4, 0.6, 0.3, 0.8, 0.5, 0.4, 0.7, 0.5, 0.6, 0.6]
        for (i, price) in fixedPrices.enumerated() {
            if let date = calendar.date(byAdding: .year, value: (10 - i) * -1, to: now) {
                points.append(PricePoint(date: date, price: price))
            }
        }
        return points
    }
}
