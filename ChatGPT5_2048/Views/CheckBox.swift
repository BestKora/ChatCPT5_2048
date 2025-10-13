//
//  CheckBox.swift
//  ChatGPT5_2048
//
//  Created by Tatiana Kornilova on 17.09.2025.
//
import SwiftUI

struct CheckBoxView: View {
    @Binding var isChecked: Bool
    var title: String

    var body: some View {
        Button(action: {
            withAnimation {
                isChecked.toggle()
            }
        }) {
            HStack {
                Image(systemName: isChecked ? "checkmark.square.fill" : "square")
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundColor(isChecked ? .blue : .gray)

                Text(title)
                    .font(.headline)
                    .foregroundColor(Color.accentColor)
            }
        }
        .buttonStyle(.plain)
    }
}
