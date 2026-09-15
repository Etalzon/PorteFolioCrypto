// PorteFolioCrypto/PorteFolioCryptoApp.swift

import SwiftUI

@main
struct PorteFolioCryptoApp: App {
    // Injecté à la racine
    @StateObject private var currencySettings = CurrencySettings()

    var body: some Scene {
    //Fenêtre principale
        WindowGroup {
           CryptoGridView()
             .environmentObject(currencySettings)
        }
    }
}
