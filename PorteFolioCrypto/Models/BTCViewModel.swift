//
//  BTCViewModel.swift
//  PorteFolioCrypto
//
//  Created by eric locci on 07/12/2025.
//

import SwiftUI
import Combine

class BTCViewModel: ObservableObject {
   // Compatibilité avec les vues existantes
   @Published var BTCPrice: Double = 0.0         // pour compatibilité: prix USD
   @Published var BTCChange: Double = 0.0
   @Published var BTCHistory: [Double] = []
   @Published var BTCPriceHistory: [BTCCardView.PricePointBTC] = []
   
   // Nouveaux prix multi-devises
   @Published var BTCPriceUSD: Double = 0.0
   @Published var BTCPriceEUR: Double = 0.0

   private var timer: Timer?
   
   var changeText: String {
      let sign = BTCChange >= 0 ? "+" : ""
      return "\(sign)\(String(format: "%.2f", BTCChange)) $"
   }
   
   var changeColor: Color {
      BTCChange >= 0 ? .green : .red
   }
   
   init() {
      Task { await refreshAsync() }
      Task { await fetchHistoryAsync() }
      // Conserver le timer pour ne pas changer le comportement ailleurs
      timer = Timer.scheduledTimer(withTimeInterval: 15, repeats: true) { [weak self] _ in
         guard let self else { return }
         Task {
            await self.refreshAsync()
            await self.fetchHistoryAsync()
         }
      }
   }
   
   deinit {
      timer?.invalidate()
   }
   
   // MARK: - Async/await versions
   
   // Récupère USD et EUR en une seule requête
   @MainActor
   func refreshAsync() async {
      guard let url = URL(string: "https://api.coingecko.com/api/v3/simple/price?ids=bitcoin&vs_currencies=usd,eur") else { return }
      do {
         let (data, _) = try await URLSession.shared.data(from: url)
         // Réponse attendue: { "bitcoin": { "usd": Double, "eur": Double } }
         guard
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
            let bitcoin = json["bitcoin"] as? [String: Any]
         else { return }
         
         let usd = (bitcoin["usd"] as? Double) ?? 0.0
         let eur = (bitcoin["eur"] as? Double) ?? 0.0
         
         let previousUSD = self.BTCPriceUSD
         self.BTCPriceUSD = usd
         self.BTCPriceEUR = eur
         
         // Compatibilité: BTCPrice = USD
         self.BTCPrice = usd
         
         if previousUSD != 0 {
            self.BTCChange = usd - previousUSD
         } else {
            self.BTCChange = 0
         }
      } catch {
         // Vous pouvez logger l'erreur si besoin
      }
   }
   
   @MainActor
   func fetchHistoryAsync() async {
      guard let url = URL(string: "https://api.coingecko.com/api/v3/coins/bitcoin/market_chart?vs_currency=usd&days=7") else { return }
      do {
         let (data, _) = try await URLSession.shared.data(from: url)
         guard
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
            let prices = json["prices"] as? [[Any]]
         else { return }
         
         let values = prices.compactMap { $0[1] as? Double }
         self.BTCHistory = values
         
         // Optionnel: si vous voulez aussi alimenter BTCPriceHistory avec des points (date/prix)
         // Ici on ne le reconstruit pas entièrement car BTCCardView l’utilise peut-être ailleurs.
         // Vous pouvez l’ajouter si nécessaire.
      } catch {
         // Logger si besoin
      }
   }
   
   // MARK: - API de compatibilité (conservée)
   
   func refresh() {
      Task { await refreshAsync() }
   }
   
   func fetchHistory() {
      Task { await fetchHistoryAsync() }
   }
}
