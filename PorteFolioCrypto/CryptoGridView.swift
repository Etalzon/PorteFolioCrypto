// PorteFolioCrypto/CryptoGridView.swift

import SwiftUI

struct CryptoGridView: View {
    @StateObject private var btcVM = BTCViewModel()
    @StateObject private var ethVM = ETHViewModel()
    @StateObject private var solVM = SOLViewModel()
    @StateObject private var xrpVM = XRPViewModel()
    @State private var searchText = ""

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var cryptos: [Crypto] {
        [
            Crypto(name: "BTC", view: AnyView(CryptoCardView(name: "BTC", image: "bitcoin_logo")), detailView: AnyView(GenericCryptoCardView(vm: btcVM, coinName: "Bitcoin", coinSymbol: "BTC", logoName: "bitcoin_logo"))),
            Crypto(name: "ETH", view: AnyView(CryptoCardView(name: "ETH", image: "ethereum_logo")), detailView: AnyView(GenericCryptoCardView(vm: ethVM, coinName: "Ethereum", coinSymbol: "ETH", logoName: "ethereum_logo"))),
            Crypto(name: "SOL", view: AnyView(CryptoCardView(name: "SOL", image: "solana_logo")), detailView: AnyView(GenericCryptoCardView(vm: solVM, coinName: "Solana", coinSymbol: "SOL", logoName: "solana_logo"))),
            Crypto(name: "XRP", view: AnyView(CryptoCardView(name: "XRP", image: "xrp_logo")), detailView: AnyView(GenericCryptoCardView(vm: xrpVM, coinName: "Ripple", coinSymbol: "XRP", logoName: "xrp_logo")))
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

#Preview {
   CryptoGridView()
}
