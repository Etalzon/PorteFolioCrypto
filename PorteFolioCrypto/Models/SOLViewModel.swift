// PorteFolioCrypto/Models/SOLViewModel.swift

import SwiftUI
import Combine

class SOLViewModel: ObservableObject {
   @Published var SOLPrice: Double = 0.0
   @Published var SOLChange: Double = 0.0
   @Published var SOLHistory: [Double] = []
   @Published var SOLPriceHistory: [SOLCardView.PricePointSol] = []

   private var timer: Timer?

   var changeText: String {
      let sign = SOLChange >= 0 ? "+" : ""
      return "\(sign)\(String(format: "%.2f", SOLChange)) $"
   }

   var changeColor: Color {
      SOLChange >= 0 ? .orange : .red
   }

   init() {
      refresh()
      fetchHistory()
      timer = Timer.scheduledTimer(withTimeInterval: 15,
          repeats: true) { [weak self] _ in
         self?.refresh()
         self?.fetchHistory()
      }
   }

   deinit {
      timer?.invalidate()
   }

   func refresh() {
      let url = URL(string: "https://api.coingecko.com/api/v3/simple/price?ids=solana&vs_currencies=usd")!
      URLSession.shared.dataTask(with: url) { data, _, _ in
         guard
             let data = data,
             let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
             let solana = json["Solana"] as? [String: Any],
             let newPrice = solana["USD"] as? Double
         else { return }
         DispatchQueue.main.async {
            self.SOLChange = newPrice - self.SOLPrice
            self.SOLPrice = newPrice
         }
      }.resume()
   }

   func fetchHistory() {
      let url = URL(string: "https://api.coingecko.com/api/v3/coins/solana/market_chart?vs_currency=usd&days=7")!
      URLSession.shared.dataTask(with: url) { data, _, _ in
         guard let data = data,
               let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let prices = json["prices"] as? [[Any]] else { return }
         let values = prices.compactMap { $0[1] as? Double }
         DispatchQueue.main.async {
            self.SOLHistory = values
         }
      }.resume()
   }
}
