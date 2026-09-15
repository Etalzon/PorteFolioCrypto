// PorteFolioCrypto/CardView/CryptoCardView.swift

import SwiftUI

struct CryptoCardView: View {
    let name: String
    let image: String

    var body: some View {
        VStack {
            Image(image)
                .resizable()
            .frame(width: 50, height: 50)
            .clipShape(Circle())
            Text(name)
                .font(.headline)
                .padding(.top, 5)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 15).fill(Color.white).shadow(radius: 3))
    }
}

