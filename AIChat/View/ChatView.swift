//
//  ChatView.swift
//  AIChat
//
//  Created by John Martino on 11/24/24.
//

import SwiftUI
import SwiftData

struct ChatView: View {
    @Environment(\.modelContext) var context
    @Bindable private var service = AIService()
    @Bindable private var conversation = Conversation()
    @Query(sort: \Message.id) var messages: [Message]
    
    private let bottomID = UUID()
    
    @State private var scrollID = UUID()
    @State private var pauseScrolling = false
    @State private var showDownButton = false
    @State private var isQuerying = false
    
    @State private var showErrorAlert = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationStack {
            contentView
                .navigationBarTitleDisplayMode(.inline)
                .background(.screen)
                .task {
                    if let last = conversation.messages.last, let specialMessage = service.specialMessage, last.text != specialMessage {
                        conversation.add(text: specialMessage, images: nil, type: .auto, context: context)
                        service.specialMessage = nil
                    }
                }
                .onChange(of: service.busy) { oldValue, newValue in
                    if newValue != oldValue {
                        isQuerying = newValue
                    }
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
                    ToolbarItem(placement: .principal) {
                        Image(systemName: "apple.intelligence")
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
        let (isAvailable, reason) = service.isAvailable()
        if !isAvailable {
            ContentUnavailableView("Language Model", systemImage: "apple.intelligence", description: Text(reason ?? "Unexpected error occurred."))
        } else {
            VStack(spacing: 0) {
                ZStack {
                    conversationView
                    moreButton
                }
            }
            .safeAreaInset(edge: .bottom) {
                inputField.padding(.horizontal)
            }
        }
    }
    
    private var inputField: some View {
        InputField(isQuerying: $isQuerying) { message, images in
            Task {
                guard !message.isEmpty else { return }
                conversation.add(text: message, images: images, type: .user, context: context)
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
                
                do {
                    try await service.respond(to: message)
                    
//                    if images.isEmpty {
//                        try await service.respond(to: message)
//                    } else {
//                        try await service.query(text: message, images: images)
//                    }
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
                        if conversation.messages.isEmpty && service.response.isEmpty {
                            HStack {
                                Spacer()
                                Image(systemName: "apple.intelligence")
                                    .resizable()
                                    .renderingMode(.template)
                                    .foregroundStyle(.secondary)
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 160, height: 160)
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
                            
                            if !service.response.isEmpty {
                                MessageView(message: Message(id: -1, text: service.response, images: nil, type: .system))
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
                .onChange(of: service.response) {
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
                    if !service.busy && !service.response.isEmpty {
                        conversation.add(text: service.response, images: nil, type: .system, context: context)
                        service.response = ""
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
                        .glassEffect(.regular.interactive(), in: .circle)
                }
            }
            .padding(.bottom, 4)
        }
    }
}

#Preview {
    ChatView()
}
