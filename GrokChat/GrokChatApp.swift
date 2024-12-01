//
//  GrokChatApp.swift
//  GrokChat
//
//  Created by John Martino on 11/24/24.
//

import SwiftUI
import SwiftData

@main
struct GrokChatApp: App {
    var container: ModelContainer
    
    init() {
        do {
            let config = ModelConfiguration(for: Message.self)
            container = try ModelContainer(for: Message.self, configurations: config)
        } catch {
            fatalError("Failed to configure SwiftData container.")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ChatView()
        }
        .modelContainer(container)
    }
}
