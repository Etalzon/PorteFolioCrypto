// PorteFolioCrypto/ButtonTrading/AchatCripto.swift

import SwiftUI

struct AchatCrypto: View {
   @State private var nombreBTCAchat: String = ""
   @State private var errorMessage: String = ""
   @FocusState private var isAchatFocused: Bool

   // ViewModel pour obtenir le prix BTC en temps réel (USD + EUR)
   @StateObject private var btcVM = BTCViewModel()

   // Devise partagée (EUR par défaut via CurrencySettings)
   @EnvironmentObject private var settings: CurrencySettings
   private let supportedFiats = ["EUR", "USD"]
   
   // Calcul de la contre-valeur fiat
   private var fiatAmount: Double {
      let btc = Double(nombreBTCAchat) ?? 0
      let price = (settings.selectedFiat == "EUR") ? btcVM.BTCPriceEUR : btcVM.BTCPriceUSD
      return btc * price
   }

   var body: some View {
      Form {
         Section(header: Text("Achat")) {
            TextField("Nombre de BTC à l'achat", text: $nombreBTCAchat)
               .keyboardType(.decimalPad)
               .focused($isAchatFocused)
               .toolbar {
                  ToolbarItemGroup(placement: .keyboard) {
                     Spacer()
                     Button("Terminé") {
                        isAchatFocused = false
                        validateInput()
                     }
                  }
               }
               .onChange(of: nombreBTCAchat) { oldValue, newValue in
                  nombreBTCAchat = formatDecimalInput(newValue)
               }

            // Sélecteur de devise (pilotant l’environnement partagé)
            Picker("Devise", selection: $settings.selectedFiat) {
               ForEach(supportedFiats, id: \.self) { code in
                  Text(code).tag(code)
               }
            }
            .pickerStyle(.segmented)

            // Affichage de la contre-valeur, formaté selon la devise sélectionnée
            HStack {
               Text("Équivalent")
               Spacer()
               Text(fiatAmount, format: .currency(code: settings.selectedFiat))
                  .monospacedDigit()
                  .foregroundColor(.primary)
            }

            if !errorMessage.isEmpty {
               Text(errorMessage)
                  .foregroundColor(.red)
                  .font(.caption)
            }
         }

         Section {
            HStack {
               Spacer()
               Button {
                  Task {
                     await btcVM.refreshAsync()
                     await btcVM.fetchHistoryAsync()
                  }
               } label: {
                  Label("Actualiser", systemImage: "arrow.clockwise")
               }
               .buttonStyle(.borderedProminent)
               Spacer()
            }
         }
      }
      .navigationTitle("Achat Crypto")
      // Chargement/rafraîchissement des prix à l’apparition
      .task {
         await btcVM.refreshAsync()
         await btcVM.fetchHistoryAsync()
      }
   }
   
   private func formatDecimalInput(_ input: String) -> String {
      var filtered = input.filter { $0.isNumber || $0 == "." || $0 == "," }
      // Remplacer la virgule par un point
      filtered = filtered.replacingOccurrences(of: ",", with: ".")
      // Ne garder qu'un seul séparateur décimal
      let components = filtered.components(separatedBy: ".")
      if components.count > 2 {
         filtered = components[0] + "." + components[1...].joined()
      }
      return filtered
   }
   
   private func validateInput() {
      guard !nombreBTCAchat.isEmpty else {
         errorMessage = "Veuillez entrer un montant"
         return
      }
      guard Double(nombreBTCAchat) != nil else {
         errorMessage = "Format invalide"
         return
      }
      guard let value = Double(nombreBTCAchat), value > 0 else {
         errorMessage = "Le montant doit être supérieur à 0"
         return
      }
      errorMessage = ""
   }
}
