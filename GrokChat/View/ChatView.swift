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
    
    @State private var scrollID = UUID()
    @State private var pauseScrolling = false
    @State private var showDownButton = false
    
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
                    guard !message.isEmpty else { return }
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
                                .opacity(0.25)
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
                                .foregroundStyle(.clear)
                                .frame(height: 1)
                                .id(bottomID)
                                .onScrollVisibilityChange { isVisible in
                                    withAnimation {
                                        showDownButton = !isVisible
                                    }
                                }
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
                .onChange(of: scrollID) {
                    if !pauseScrolling {
                        withAnimation {                        
                            reader.scrollTo(bottomID, anchor: .bottom)
                        }
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
        if showDownButton {
            VStack {
                Spacer()
                
                Button {
                    pauseScrolling = false
                    scrollID = UUID()
                } label: {
                    Image(systemName: "arrow.down")
                        .imageScale(.small)
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
