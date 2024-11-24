//
//  InputField.swift
//  GrokChat
//
//  Created by John Martino on 11/24/24.
//

import SwiftUI

struct InputField: View {
    @Binding var isQuerying: Bool
    var action: (_ message: String) -> Void
    
    @State private var message: String = ""
    @FocusState private var focus
    
    var body: some View {
        HStack(spacing: 0) {
            TextField("Query Grok", text: $message, axis: .vertical)
                .multilineTextAlignment(.leading)
                .foregroundStyle(isQuerying ? .secondary : .primary)
                .focused($focus)
                .lineLimit(3)
                .padding()
                .submitLabel(.return)
                .overlay {
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.secondary, lineWidth: 1)
                }
                .padding([.horizontal, .bottom])
                .disabled(isQuerying)
            
            Button {
                action(message)
                focus = false
                withAnimation {
                    message = ""
                }
            } label: {
                Image(systemName: "paperplane.fill")
                    .tint(.white)
                    .padding()
                    .background {
                        Circle()
                            .foregroundStyle(isQuerying ? .gray : .black)
                    }
                    .padding([.trailing, .bottom])
            }
            .disabled(isQuerying)
        }
    }
}

#Preview {
    InputField(isQuerying: .constant(false)) { message in
        
    }
}
