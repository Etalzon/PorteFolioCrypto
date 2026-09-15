// PorteFolioCrypto/CardView/ETHCardView.swift

import SwiftUI
import Charts

struct ETHCardView: View {
    @ObservedObject var vm: ETHViewModel
    @State private var appear = false
    
    /// Structure des prix pour l’historique des prix Ethereum
    struct PricePointETH: Identifiable {
        let id = UUID()
        let date: Date
        let ETHPrice: Double
    }
    
    var body: some View {
        ZStack {
            /// 1. Le dégradé qui prend tout l'écran
            LinearGradient(
                gradient: Gradient(colors: [.blue.opacity(0.1), .white]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            /// 2. Le contenu de la carte (votre code actuel)
            VStack(spacing: 8) {
                /// Logo Ethereum
                Image("ethereum_logo")
                    .resizable()
                    .frame(width: 48, height: 48)
                    .foregroundColor(.purple)
                    .padding(.top, 8)
                
                /// Symbole ETH
                Text("ETH")
                    .font(.headline)
                    .foregroundColor(.black) // Ajouté pour la clarté
                
                /// Prix actuel en USD
                Text(String(format: "%.2f $", vm.ETHPrice))
                    .font(.title)
                    .bold()
                    .foregroundColor(.black) // Changé de .primary à .black
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                
                
                /// Variation du prix
                Text(vm.changeText)
                    .font(.subheadline)
                    .foregroundColor(vm.ETHChange >= 0 ? .blue : .red)
                    .minimumScaleFactor(0.7)
                
                /// Graphique de l’historique des prix Ethereum
                Chart(vm.ETHPriceHistory) { point in
                    LineMark(
                        x: .value("Date", point.date),
                        y: .value("Prix", point.ETHPrice)
                    )
                }
                .frame(height: 120)
                .padding(.bottom, -16)
                
                /// Graphique simplifié de l’historique des prix
                Chart {
                    ForEach(Array(vm.ETHHistory.enumerated()), id: \.offset) { index, value in
                        LineMark(
                            x: .value("Jour", index),
                            y: .value("Prix", value)
                        )
                    }
                }
                .frame(height: 120)
                .padding(.top, -16)
                .animation(.easeInOut(duration: 0.5), value: vm.ETHHistory)
            }
            /// effet rebond
            .scaleEffect(appear ? 1 : 0.8)
            .opacity(appear ? 1 : 0)
            .animation(.spring(), value: appear)
            .frame(minHeight: 300)
            .padding() // Espacement interne pour que le contenu ne touche pas les bords
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(LinearGradient(
                        colors: [Color.white, Color(white: 0.94)],// Dégradé du blanc vers un gris très léger
                        startPoint: .top,
                        endPoint: .bottom
                    ))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(Color.black.opacity(0.08), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 5)
            )
            /// 4. On garde ton effet de couleur dynamique en overlay léger
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .fill(vm.changeColor.opacity(0.1))
            )
            .animation(.easeInOut(duration: 0.4), value: vm.changeColor)
            .onAppear {
                appear = true
                withAnimation(.spring()) {
                    vm.refresh()
                    vm.fetchHistory()
                }
            }
            /// 5. Marges extérieures pour que la carte ne colle pas aux bords de l'écran
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
        }
    }
}
#Preview {
    ETHCardView(vm: ETHViewModel())
}
