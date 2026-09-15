// PorteFolioCrypto/ButtonStyle/RefreshButton.swift

import SwiftUI

struct RefreshButton: View {
    let action: () -> Void

    var body: some View {
        Button("Refresh") {
            action()
        }
        .buttonStyle(.borderedProminent)
        .padding(.top, 8)
    }
}
#Preview("Refresh Button Context") {
    VStack(spacing: 10) {
        Text("Dernière mise à jour : il y a 5 min")
            .font(.caption)
            .foregroundStyle(.secondary)
        
        RefreshButton(action: {
            print("Rafraîchissement...")
        })
    }
}
