//
//  ChatView.swift
//  GrokChat
//
//  Created by John Martino on 11/24/24.
//

import SwiftUI

struct ChatView: View {
    @Bindable private var service = GrokService()
    @Bindable private var conversation = Conversation()
    @State private var bottomID = UUID()
    
    private let systemMessage = "You are Grok, my personal assistant."
    
    var body: some View {
        NavigationStack {
            contentView
                .navigationTitle("Grok")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private var contentView: some View {
        VStack {
            conversationView
            
            InputField(isQuerying: $service.busy) { message in
                Task {
                    if !service.responseMessage.isEmpty {
                        conversation.messages.append(Message(text: service.responseMessage, type: .system))
                    }
                    conversation.messages.append(Message(text: message, type: .user))
                    try? await service.query(system: systemMessage, user: message)
                }
            }
        }
    }
    
    private var conversationView: some View {
        GeometryReader { proxy in
            ScrollViewReader { reader in
                ScrollView {
                    VStack {
                        if conversation.messages.isEmpty && service.responseMessage.isEmpty {
                            Image(.logo)
                                .resizable()
                                .renderingMode(.template)
                                .foregroundStyle(.secondary)
                                .aspectRatio(contentMode: .fit)
                                .padding(32)
                        } else {
                            Spacer()
                            ForEach(conversation.messages) { message in
                                MessageView(message: message)
                                    .frame(maxWidth: .infinity, alignment: message.type.alignment)
                            }
                            
                            if !service.responseMessage.isEmpty {
                                MessageView(message: Message(text: service.responseMessage, type: .system))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            Rectangle()
                                .foregroundStyle(.background)
                                .frame(height: 1)
                                .id(bottomID)
                        }
                    }
                    .frame(minHeight: proxy.size.height)
                }
                .scrollIndicators(.hidden)
                .scrollDismissesKeyboard(.interactively)
                .onChange(of: service.responseMessage) {
                    reader.scrollTo(bottomID, anchor: .bottom)
                }
            }
        }
    }
}

#Preview {
    ChatView()
}
