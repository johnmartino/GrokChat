//
//  ChatView.swift
//  GrokChat
//
//  Created by John Martino on 11/24/24.
//

import SwiftUI
import SwiftData

struct ChatView: View {
    @Environment(\.modelContext) var context
    @Bindable private var service = GrokService()
    @Bindable private var conversation = Conversation()
    @Query(sort: \Message.id) var messages: [Message]
    
    private let bottomID = UUID()
    private let systemMessage = "You are Grok, my personal assistant."
    
    @State private var scrollID = UUID()
    @State private var pauseScrolling = false
    @State private var showDownButton = false
    @State private var showSettings = false
    @State private var showSettingsMessage = false
    
    @State private var showErrorAlert = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationStack {
            contentView
                .navigationBarTitleDisplayMode(.inline)
                .background(.screen)
                .fullScreenCover(isPresented: $showSettings) {
                    SettingsView(valuesStatus: $showSettingsMessage)
                }
                .task {
                    let keyValue = Settings.key ?? ""
                    let modelValue = Settings.model ?? ""
                    showSettingsMessage = keyValue.isEmpty || modelValue.isEmpty
                }
                .alert("Service Error", isPresented: $showErrorAlert) {
                    Button("OK") {
                        errorMessage = nil
                        showErrorAlert = false
                    }
                } message: {
                    Text(errorMessage ?? "An unknown error occurred.")
                }
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            showSettings.toggle()
                        } label: {
                            Image(systemName: "gear")
                        }
                        .tint(.primary)
                    }
                    
                    ToolbarItem(placement: .principal) {
                        Text("Grok")
                            .font(.custom("Futura", size: 20, relativeTo: .headline))
                            .fontWeight(.semibold)
                    }
                    
                    if !conversation.messages.isEmpty {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button {
                                for message in messages {
                                    context.delete(message)
                                }
                                conversation.messages.removeAll()
                                showDownButton = false
                            } label: {
                                Image(systemName: "square.and.pencil")
                            }
                            .foregroundStyle(.primary)
                        }
                    }
                }
        }
    }
    
    @ViewBuilder private var contentView: some View {
        if showSettingsMessage {
            ContentUnavailableView("Settings", systemImage: "gear", description: Text("Open the Settings view and select your data model and API key."))
        } else {
            VStack(spacing: 0) {
                ZStack {
                    conversationView
                    moreButton
                }
                
                inputField
            }
        }
    }
    
    private var inputField: some View {
        InputField(isQuerying: $service.busy) { message, images in
            Task {
                guard !message.isEmpty else { return }
                conversation.add(text: message, images: images, type: .user, context: context)
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
                
                do {
                    if images.isEmpty {
                        try await service.query(system: systemMessage, user: message, history: conversation.messages)
                    } else {
                        try await service.query(text: message, images: images)
                    }
                } catch {
                    errorMessage = error.localizedDescription
                    showErrorAlert = true
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
                            HStack {
                                Spacer()
                                Image(.logo)
                                    .resizable()
                                    .renderingMode(.template)
                                    .foregroundStyle(.secondary)
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 64, height: 64)
                                    .opacity(0.25)
                                Spacer()
                            }
                        } else {
                            Spacer()
                            ForEach(conversation.messages) { message in
                                MessageView(message: message)
                                    .contextMenu {
                                        ShareLink("Share", item: message.text) 
                                    }
                            }
                            
                            if !service.responseMessage.isEmpty {
                                MessageView(message: Message(id: -1, text: service.responseMessage, images: nil, type: .system))
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
                .scrollDismissesKeyboard(.immediately)
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
                .onChange(of: service.busy) {
                    if !service.busy && !service.responseMessage.isEmpty {
                        conversation.add(text: service.responseMessage, images: nil, type: .system, context: context)
                        service.responseMessage = ""
                    }
                }
                .onTapGesture {
                    pauseScrolling = true
                }
                .onLongPressGesture {
                    pauseScrolling = true
                }
                .task {
                    conversation.messages = messages
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
                    Circle()
                        .foregroundStyle(.background)
                }
                .overlay {
                    Circle()
                        .stroke(lineWidth: 1)
                        .foregroundStyle(.primary)
                        .opacity(0.1)
                }
            }
            .padding(.bottom, 4)
        }
    }
}

#Preview {
    ChatView()
}
