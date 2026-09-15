//  PorteFolioCrypto/Models/Crypto.swift.swift

import Foundation
import SwiftUI

struct Crypto: Identifiable {
    let id = UUID()
    let name: String
    let view: AnyView
    let detailView: AnyView
}
