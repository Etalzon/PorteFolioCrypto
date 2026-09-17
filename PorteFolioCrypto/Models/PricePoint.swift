// PorteFolioCrypto/Models/PricePoint.swift

import Foundation

struct PricePoint: Identifiable {
    let id = UUID()
    let date: Date
    let price: Double
}
