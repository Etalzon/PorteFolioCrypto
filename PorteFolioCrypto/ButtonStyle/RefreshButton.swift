//
//  RefreshButton.swift
//  PorteFolioCrypto
//
//  Created by eric locci on 07/12/2025.
//

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
