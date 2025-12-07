//
//  CurrencySettings.swift
//  PorteFolioCrypto
//
//  Created by eric locci on 07/12/2025.
//

import Foundation
import Combine

final class CurrencySettings: ObservableObject {
   
    // "EUR" par défaut comme demandé
    @Published var selectedFiat: String = "EUR"

    // Si vous souhaitez persister la préférence:
     init() {
         selectedFiat = UserDefaults.standard.string(forKey: "selectedFiat") ?? "EUR"
     }
   
   // Persister la préférence
     func save() {
         UserDefaults.standard.set(selectedFiat, forKey: "selectedFiat")
     }
}
