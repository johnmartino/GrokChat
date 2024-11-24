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
    
    private let bottomID = UUID()
    private let systemMessage = "You are Grok, my personal assistant."
    
    @State private var pauseScrolling = false
    
    var body: some View {
        NavigationStack {
            contentView
                .navigationTitle("Grok")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private var contentView: some View {
        VStack {
            ZStack {
                conversationView
                moreButton
            }
            
            InputField(isQuerying: $service.busy) { message in
                Task {
                    if !service.responseMessage.isEmpty {
                        conversation.messages.append(Message(text: service.responseMessage, type: .system))
                    }
                    conversation.messages.append(Message(text: message, type: .user))
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.success)
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
                    if !pauseScrolling {
                        reader.scrollTo(bottomID, anchor: .bottom)
                    }
                }
                .onChange(of: pauseScrolling) {
                    if !pauseScrolling {
                        reader.scrollTo(bottomID, anchor: .bottom)
                    }
                }
                .onTapGesture {
                    pauseScrolling = true
                }
                .onLongPressGesture {
                    pauseScrolling = true
                }
            }
        }
    }
    
    @ViewBuilder private var moreButton: some View {
        if pauseScrolling {
            VStack {
                Spacer()
                
                Button {
                    pauseScrolling = false
                } label: {
                    Image(systemName: "arrow.down")
                        .imageScale(.large)
                        .font(.headline)
                        .tint(.primary)
                        .padding()
                }
                .background {
                    Circle().foregroundStyle(Color(.systemGray6))
                }
            }
        }
    }
}

#Preview {
    ChatView()
}
