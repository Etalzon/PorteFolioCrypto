// PorteFolioCrypto/Models/ETHViewModel.swift

import SwiftUI
import Combine

class ETHViewModel: ObservableObject {
   @Published var ETHPrice: Double = 0.0
   @Published var ETHChange: Double = 0.0
   @Published var ETHHistory: [Double] = []
   @Published var ETHPriceHistory: [ETHCardView.PricePointETH] = []
   
   private var timer: Timer?
   
   var changeText: String {
      let sign = ETHChange >= 0 ? "+" : ""
      return "\(sign)\(String(format: "%.2f", ETHChange)) $"
   }
   
   var changeColor: Color {
      ETHChange >= 0 ? .blue : .red
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
      let url = URL(string: "https://api.coingecko.com/api/v3/simple/price?ids=ethereum&vs_currencies=usd")!
      URLSession.shared.dataTask(with: url) { data, _, _ in
         guard
             let data = data,
             let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
             let ethDict = json["Ethereum"] as? [String: Any],
             let newPrice = ethDict["USD"] as? Double
         else { return }
         DispatchQueue.main.async {
            self.ETHChange = newPrice - self.ETHChange
            self.ETHPrice = newPrice
         }
      }.resume()
   }
   
   func fetchHistory() {
      let url = URL(string: "https://api.coingecko.com/api/v3/coins/ethereum/market_chart?vs_currency=usd&days=7")!
      URLSession.shared.dataTask(with: url) { data, _, _ in
         guard let data = data,
               let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let prices = json["prices"] as? [[Any]] else { return }
         let values = prices.compactMap { $0[1] as? Double }
         DispatchQueue.main.async {
            self.ETHHistory = values
         }
      }.resume()
   }
}
