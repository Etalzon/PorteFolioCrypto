// PorteFolioCrypto/CardView/GenericCryptoCardView.swift

import SwiftUI
import Charts

struct GenericCryptoCardView<VM: CryptoViewModelProtocol>: View {
    @ObservedObject var vm: VM
    let coinName: String
    let coinSymbol: String
    let logoName: String
    
    @State private var appear = false

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [.blue.opacity(0.1), .white]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 15) {
                Image(logoName)
                    .resizable()
                    .frame(width: 48, height: 48)
                    .padding(.top, 8)
                
                Text(coinSymbol).font(.headline).foregroundColor(.black)
                
                Text(String(format: "%.2f $", vm.price))
                    .font(.title).bold().foregroundStyle(.black)
                
                Text(vm.changeText)
                    .font(.subheadline)
                    .foregroundColor(vm.changeColor)
                
                // APPEL DE LA FONCTION EXTERNE POUR EVITER L'ERREUR DE COMPILATION
                chartView()

                Text("Dernière mise à jour : \(vm.lastUpdated, style: .time)")
                    .font(.caption2).foregroundStyle(.secondary).padding(.top, 4)
            }
            .scaleEffect(appear ? 1 : 0.8)
            .opacity(appear ? 1 : 0)
            .animation(.spring(), value: appear)
            .frame(minHeight: 380)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(LinearGradient(colors: [.white, Color(white: 0.94)], startPoint: .top, endPoint: .bottom))
                    .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.black.opacity(0.08), lineWidth: 1))
                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 5)
            )
            .overlay(RoundedRectangle(cornerRadius: 20).fill(vm.changeColor.opacity(0.1)))
//            .overlay {
//                if vm.isLoading {
//                    ZStack {
//                        Color.white.opacity(0.7)
//                        ProgressView().tint(.blue).padding(20).background(Color.white).clipShape(Circle()).shadow(radius: 10)
//                    }
//                    .cornerRadius(24)
//                }
//            }
            .overlay(alignment: .topTrailing) {
                RefreshButton(action: {
                    vm.refreshAll()
                })
                .offset(x: 14, y: -14)
            }
            .padding(.horizontal, 20).padding(.vertical, 10)
            .colorScheme(.light)
        }
        .onAppear {
            appear = true
            vm.refreshAll()
        }
    }

    // FONCTION SEPAREE POUR LE GRAPHIQUE (CORRIGE L'ERREUR TYPE-CHECK)
    @ViewBuilder
    private func chartView() -> some View {
        if vm.history.isEmpty {
            HStack {
                Spacer()
                ProgressView().tint(.gray)
                Spacer()
            }
            .frame(height: 160)
            .padding(.top, 30)
        } else {
            Chart {
                ForEach(vm.history) { point in
                    // 1. Le remplissage dégradé (Aspect Premium)
                    AreaMark(
                        x: .value("Date", point.date),
                        y: .value("Prix", point.price)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [vm.brandColor.opacity(0.3), .clear],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .interpolationMethod(.catmullRom) // Courbe lissée

                    // 2. La ligne principale lissée (Aspect Premium)
                    LineMark(
                        x: .value("Date", point.date),
                        y: .value("Prix", point.price)
                    )
                    .foregroundStyle(vm.brandColor)
                    .lineStyle(StrokeStyle(lineWidth: 2))
                    .interpolationMethod(.catmullRom) // Courbe lissée
                }
            }
            .frame(height: 160)
            .chartYScale(domain: .automatic(includesZero: false)) // Échelle dynamique
            .chartXAxis {
                // RESTAURATION DE LA GRILLE DES ANNÉES
                AxisMarks(values: .stride(by: .year)) { value in
                    AxisGridLine() // Ligne verticale de la grille
                    AxisTick()     // Petit trait de graduation
                    AxisValueLabel(format: .dateTime.year()) // Affiche l'année (ex: 2023)
                }
            }
            .chartYAxis {
                // RESTAURATION DE LA GRILLE DES PRIX
                AxisMarks { _ in
                    AxisGridLine() // Ligne horizontale de la grille
                    AxisValueLabel() // Affiche le prix (ex: 60 000)
                }
            }
            .padding(.top, 30)
        }
    }
}
