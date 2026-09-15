// PorteFolioCrypto/ButtonStyle/TwoButtonsView.swift

import SwiftUI

struct TwoButtonsView: View {
    let leftButtonTitle: String
    let rightButtonTitle: String
    let leftAction: () -> Void
    let rightAction: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            Button(leftButtonTitle) {
                leftAction()
            }
            .buttonStyle(.bordered)
            
            Button(rightButtonTitle) {
                rightAction()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(.top, 8)
    }
}
#Preview("Crypto Action") {
    TwoButtonsView(
        leftButtonTitle: "Vendre",
        rightButtonTitle: "Acheter",
        leftAction: {},
        rightAction: {}
    )
}
