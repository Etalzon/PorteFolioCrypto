// PorteFolioCrypto/ButtonTrading/VenteCrypto.swift

import SwiftUI

struct VenteCrypto: View {
   @State private var nombreBTCVente: String = ""
   @State private var errorMessage: String = ""
   @FocusState private var isVenteFocused: Bool
   
   var body: some View {
      Form {
         Section(header: Text("Vente")) {
            TextField("Nombre de BTC à la vente", text: $nombreBTCVente)
               .keyboardType(.decimalPad)
               .focused($isVenteFocused)
               .toolbar {
                  ToolbarItemGroup(placement: .keyboard) {
                     Spacer()
                     Button("Terminé") {
                        isVenteFocused = false
                        validateInput()
                     }
                  }
               }
               .onChange(of: nombreBTCVente) { oldValue, newValue in
                  nombreBTCVente = formatDecimalInput(newValue)
               }
            if !errorMessage.isEmpty {
               Text(errorMessage)
                  .foregroundColor(.red)
                  .font(.caption)
            }
         }
      }
      .navigationTitle("Vente Crypto")
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
      guard !nombreBTCVente.isEmpty else {
         errorMessage = "Veuillez entrer un montant"
         return
      }
      guard Double(nombreBTCVente) != nil else {
         errorMessage = "Format invalide"
         return
      }
      guard let value = Double(nombreBTCVente), value > 0 else {
         errorMessage = "Le montant doit être supérieur à 0"
         return
      }
      errorMessage = ""
   }
}
#Preview("Vente Crypto") {
    NavigationStack {
        VenteCrypto()
    }
}
