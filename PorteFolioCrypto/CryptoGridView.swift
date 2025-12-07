//
//  CryptoGridView.swift
//  PorteFolioCrypto
//
//  Created by eric locci on 07/12/2025.
//

import SwiftUI

struct Crypto: Identifiable {
    let id = UUID()
    let name: String
    let view: AnyView
    let detailView: AnyView
}

import SwiftUI

struct CryptoGridView: View {
    @StateObject private var btcVM = BTCViewModel()
//    @StateObject private var ethVM = ETHViewModel()
//    @StateObject private var solVM = SOLViewModel()
//    @StateObject private var xrpVM = XRPViewModel()
    @State private var searchText = ""

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var cryptos: [Crypto] {
        [
            Crypto(name: "BTC", view: AnyView(CryptoCardView(name: "BTC", image: "bitcoin_logo")), detailView: AnyView(BTCCardView(vm: btcVM))),
//            Crypto(name: "ETH", view: AnyView(CryptoCardView(name: "ETH", image: "ethereum_logo")), detailView: AnyView(ETHCardView(vm: ethVM))),
//            Crypto(name: "SOL", view: AnyView(CryptoCardView(name: "SOL", image: "solana_logo")), detailView: AnyView(SOLCardView(vm: solVM))),
//            Crypto(name: "XRP", view: AnyView(CryptoCardView(name: "XRP", image: "xrp_logo")), detailView: AnyView(XRPCardView(vm: xrpVM)))
        ]
    }

    var filteredCryptos: [Crypto] {
        if searchText.isEmpty {
            return cryptos
        } else {
            return cryptos.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }

    var body: some View {
        NavigationStack {
            VStack {
                TextField("Rechercher une crypto...", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                ScrollView {
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(filteredCryptos) { crypto in
                            NavigationLink {
                                crypto.detailView
                            } label: {
                                crypto.view
                                    .shadow(radius: 5)
                                    .scaleEffect(0.95)
                                    .animation(.spring(), value: searchText)
                            }
                        }
                    }
                    .padding()
                }
            }
            .background(
                LinearGradient(gradient: Gradient(colors: [.blue.opacity(0.1), .white]), startPoint: .top, endPoint: .bottom)
            )
        }
    }
}

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
#Preview {
   CryptoGridView()
}
