//
//  WriteScreen.swift
//  soso
//
//  Created by 서지우 on 3/12/26.
//

import SwiftUI

struct WriteScreen: View {
    @Environment(\.dismiss) private var dismiss
    @State private var text: String = ""
    @FocusState private var isFocused: Bool
    
    let onSave: (String) -> Void
    
    private let maxLength = 100
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("오늘 나의 소소한 행복은 무엇이었나요?")
                    .font(.title2)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.primary)
                    .padding(.top, 40)
                
                TextField("행복을 기록해보세요", text: $text, axis: .vertical)
                    .textFieldStyle(.plain)
                    .padding()
                    .frame(minHeight: 120, maxHeight: 200)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .lineLimit(4...6)
                    .focused($isFocused)
                    .onChange(of: text) { _, newValue in
                        if newValue.count > maxLength {
                            text = String(newValue.prefix(maxLength))
                        }
                    }
                
                Text("\(text.count)/\(maxLength)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                
                Spacer()
                
                Button {
                    onSave(text)
                } label: {
                    Text("저장하기")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(red: 0.2, green: 0.6, blue: 0.35))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding(.bottom, 32)
            }
            .padding(.horizontal, 24)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            isFocused = true
        }
    }
}
