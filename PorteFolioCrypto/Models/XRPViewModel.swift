// PorteFolioCrypto/Models/XRPViewModel.swift

import SwiftUI
import Combine

class XRPViewModel: ObservableObject {
   @Published var XRPPrice: Double = 0.0
   @Published var XRPChange: Double = 0.0
   @Published var XRPHistory: [Double] = []
   @Published var XRPPriceHistory: [XRPCardView.PricePointXrp] = []
   
   private var timer: Timer?
   
   var changeText: String {
      let sign = XRPChange >= 0 ? "+" : ""
      return "\(sign)\(String(format: "%.2f", XRPChange)) $"
   }
   
   var changeColor: Color {
      XRPChange >= 0 ? .purple : .red
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
      let url = URL(string: "https://api.coingecko.com/api/v3/simple/price?ids=ripple&vs_currencies=usd")!
      URLSession.shared.dataTask(with: url) { data, _, _ in
         guard
            let data = data,
            let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
            let ripple = json["Ripple"] as? [String: Any],
            let newPrice = ripple["USD"] as? Double else {
            return
         }
         DispatchQueue.main.async {
            self.XRPChange = newPrice - self.XRPPrice
            self.XRPPrice = newPrice
         }
      }.resume()
   }
   
   func fetchHistory() {
      let url = URL(string: "https://api.coingecko.com/api/v3/coins/ripple/market_chart?vs_currency=usd&days=7")!
      URLSession.shared.dataTask(with: url) { data, _, _ in
         guard let data = data,
               let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let prices = json["prices"] as? [[Any]] else { return
         }
         let values = prices.compactMap { $0[1] as? Double }
         DispatchQueue.main.async {
            self.XRPHistory = values
         }
      }.resume()
   }
}
