//
//  Conversation.swift
//  GrokChat
//
//  Created by John Martino on 11/24/24.
//

import SwiftUI
import SwiftData

@Observable
class Conversation {
    var messages = [Message]()
    
    func add(text: String, images: [UIImage]?, type: MessageType, context: ModelContext) {
        let message = Message(id: messages.count, text: text, images: images, type: type)
        messages.append(message)
        context.insert(message)
        try? context.save()
    }
}
