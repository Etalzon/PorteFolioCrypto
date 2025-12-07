//
//  ButtonViewCard.swift
//  PorteFolioCrypto
//
//  Created by eric locci on 07/12/2025.
//

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
