//
//  MenuView.swift
//  otenki
//
//  Created by mdigix on 2025/04/22.
//

import SwiftUI

struct MenuView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            Text("メニュー項目 1")
            Text("メニュー項目 2")
            Button("閉じる") {
                dismiss()
            }
        }
        .padding()
    }
}

// MARK: - Preview
struct MenuView_Previews: PreviewProvider {
    static var previews: some View {
        MenuView()
    }
}
