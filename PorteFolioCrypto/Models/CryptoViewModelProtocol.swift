// PorteFolioCrypto/Models/CryptoViewModelProtocol.swift

import SwiftUI

protocol CryptoViewModelProtocol: ObservableObject {
    var price: Double { get }
    var changeText: String { get }
    var changeColor: Color { get }
    var history: [PricePoint] { get }
    var isLoading: Bool { get set }
    var lastUpdated: Date { get set }
    var brandColor: Color { get }
    
    func refresh()
    func fetchHistory()
    func refreshAll()
}
