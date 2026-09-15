// PorteFolioCrypto/CardView/XRPCardView.swift

import SwiftUI
import Charts

struct XRPCardView: View {
    @ObservedObject var vm: XRPViewModel
    @State private var appear = false
    
    struct PricePointXrp: Identifiable {
        let id = UUID()
        let date: Date
        let WRPPrice: Double
    }
    
    var body: some View {
        ZStack {
            // 1. Le dégradé qui prend tout l'écran
            LinearGradient(
                gradient: Gradient(colors: [.blue.opacity(0.1), .white]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 8) {
                Image("Xrp_logo")
                    .resizable()
                    .frame(width: 48, height: 48)
                    .foregroundColor(.blue)
                    .padding(.top, 8)
                
                Text("XRP")
                    .font(.headline)
                    .foregroundColor(.black) // Ajouté pour la clarté
                
                Text(String(format: "%.2f $", vm.XRPPrice))
                    .font(.title)
                    .bold()
                    .foregroundColor(.black) // Changé de .primary
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                
                Text(vm.changeText)
                    .font(.subheadline)
                    .foregroundColor(vm.XRPChange >= 0 ? .cyan : .red)
                    .minimumScaleFactor(0.7)
                
                Chart(vm.XRPPriceHistory) { point in
                    LineMark(
                        x: .value("Date", point.date),
                        y: .value("Prix", point.WRPPrice)
                    )
                }
                .frame(height: 120)
                .padding(.bottom, -16)
                
                Chart {
                    ForEach(Array(vm.XRPHistory.enumerated()), id: \.offset) { index, value in
                        LineMark(
                            x: .value("Jour", index),
                            y: .value("Prix", value)
                        )
                    }
                }
                .frame(height: 120)
                .padding(.top, -16)
                .animation(.easeInOut(duration: 0.5), value: vm.XRPHistory)
            }
            // effet rebond
            .scaleEffect(appear ? 1 : 0.8)
            .opacity(appear ? 1 : 0)
            .animation(.spring(), value: appear)
            
            .frame(minHeight: 300)
            .padding() // Espacement interne pour que le contenu ne touche pas les bords
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(LinearGradient(
                        colors: [Color.white, Color(white: 0.94)], // Dégradé du blanc vers un gris très léger
                        startPoint: .top,
                        endPoint: .bottom
                    ))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(Color.black.opacity(0.08), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 5)
            )
            
            // 4. On garde ton effet de couleur dynamique en overlay léger
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
            // 5. Marges extérieures pour que la carte ne colle pas aux bords de l'écran
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
        }
    }
}
#Preview {
    XRPCardView(vm: XRPViewModel())
}
