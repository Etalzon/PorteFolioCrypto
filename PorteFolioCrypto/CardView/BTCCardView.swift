//
//  BTCCardView.swift
//  PorteFolioCrypto
//
//  Created by eric locci on 07/12/2025.
//

import SwiftUI
import Charts

struct BTCCardView: View {
   @ObservedObject var vm: BTCViewModel
   @EnvironmentObject private var settings: CurrencySettings
   @State private var appear = false
   
   struct PricePointBTC: Identifiable {
      let id = UUID()
      let date: Date
      let BTCPrice: Double
   }
   
   // Prix courant selon la devise sélectionnée
   private var displayedPrice: Double {
      settings.selectedFiat == "EUR" ? vm.BTCPriceEUR : vm.BTCPriceUSD
   }

   var body: some View {
      VStack(spacing: 8) { // Réduit l’espacement vertical
         Image("Bitcoin_logo")
            .resizable()
            .frame(width: 48, height: 48)
            .foregroundColor(.orange)
            .padding(.top, 8)
         
         Text("BTC")
            .font(.headline)
         
         // Affiche le prix dans la devise choisie
         Text(displayedPrice, format: .currency(code: settings.selectedFiat))
            .font(.title)
            .bold()
            .foregroundColor(.primary)
            .lineLimit(1)
            .minimumScaleFactor(0.7)
         
         // Variation: conservée telle quelle (calculée sur USD dans le VM)
         Text(vm.changeText)
            .font(.subheadline)
            .foregroundColor(vm.BTCChange >= 0 ? .green : .red)
            .minimumScaleFactor(0.7)
         
         // Graphiques des prix
         Chart(vm.BTCPriceHistory) { point in
            LineMark(
               x: .value("Date", point.date),
               y: .value("Prix", point.BTCPrice)
            )
         }
         .frame(height: 120)
         .padding(.bottom, -16)
         
         //  Historique simplifié
         Chart {
            ForEach(Array(vm.BTCHistory.enumerated()), id: \.offset) { index, value in
               LineMark(
                  x: .value("Jour", index),
                  y: .value("Prix", value)
               )
            }
         }
         .frame(height: 120)
         .padding(.top, -16)
         .animation(.easeInOut(duration: 0.5), value: vm.BTCHistory)
         
         // Navigation vers Vente/Achat
         HStack(spacing: 16) {
            NavigationLink {
               VenteCrypto()
            } label: {
               Text("Vente")
            }
            .buttonStyle(.bordered)
            
            NavigationLink {
               AchatCrypto()
            } label: {
               Text("Achat")
            }
            .buttonStyle(.borderedProminent)
         }
         .padding(.top, 8)
      }
      .scaleEffect(appear ? 1 : 0.8)
      .opacity(appear ? 1 : 0)
      .animation(.spring(), value: appear)
      .frame(minHeight: 300)
      .padding()
      .background(vm.changeColor.opacity(0.1))
      .cornerRadius(16)
      .shadow(radius: 4)
      .animation(.easeInOut(duration: 0.4), value: vm.changeColor)
      .onAppear {
         appear = true
         withAnimation(.spring()) {
            vm.refresh()
            vm.fetchHistory()
         }
      }
   }
}

#Preview {
   BTCCardView(vm: BTCViewModel())
     .environmentObject(CurrencySettings())
}
