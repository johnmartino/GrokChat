//
//  Conversation.swift
//  GrokChat
//
//  Created by John Martino on 11/24/24.
//

import SwiftUI

@Observable
class Conversation {
    var messages = [Message]()
    
    func add(text: String, type: MessageType) {
        messages.append(Message(text: text, type: type))
    }
}
