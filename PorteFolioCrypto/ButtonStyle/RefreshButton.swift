// PorteFolioCrypto/ButtonStyle/RefreshButton.swift
import SwiftUI

struct RefreshButton: View {
    let action: () -> Void
    @State private var rotation = 0.0 // Parameter : Angle de rotation pour l'animation

    var body: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.5)) {
                rotation += 360 // Animation de rotation
            }
            action()
        }) {
            Image(systemName: "arrow.clockwise")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 32, height: 32)
                .background(Color.blue)
                .clipShape(Circle())
                .shadow(color: .black.opacity(0.2), radius: 3, x: 0, y: 2)
                .rotationEffect(.degrees(rotation))
        }
    }
}

//MARK: - Preview
#Preview {
    RefreshButton(action: {})
        .padding()
}
