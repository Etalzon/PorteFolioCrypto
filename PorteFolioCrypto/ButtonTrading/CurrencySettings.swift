// PorteFolioCrypto/ButtonTrading/CurrencySettings.swift

import Foundation
import Combine

final class CurrencySettings: ObservableObject {
    // "EUR" par défaut comme demandé
    @Published var selectedFiat: String = "EUR"

    // Si vous souhaitez persister la préférence:
     init() {
         selectedFiat = UserDefaults.standard.string(forKey: "selectedFiat") ?? "EUR"
     }
     func save() {
         UserDefaults.standard.set(selectedFiat, forKey: "selectedFiat")
     }
}
