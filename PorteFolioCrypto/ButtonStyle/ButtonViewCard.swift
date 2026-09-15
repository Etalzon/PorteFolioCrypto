// PorteFolioCrypto/ButtonStyle/ButtonViewCard.swift

import SwiftUI

struct ButtonCard<Content: View>: View {
    let action: () -> Void
    let content: Content

    init(action: @escaping () -> Void, @ViewBuilder content: () -> Content) {
        self.action = action
        self.content = content()
    }

    var body: some View {
        Button(action: action) {
            content
                .padding()
        }
        .buttonStyle(PlainButtonStyle())
    }
}
#Preview("Crypto Style") {
    ButtonCard(action: {}) {
        VStack(spacing: 4) {
            Text("Échanger")
                .font(.headline)
            Text("Convertir vos BTC en ETH")
                .font(.caption)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .background(Color.blue)
        .cornerRadius(10)
    }
}
