//
//  GrokRequest.swift
//  GrokChat
//
//  Created by John Martino on 11/24/24.
//

import Foundation
import SwiftUI

struct GrokMessage: Codable {
    let role: String
    let content: String
}

struct GrokRequest: Codable {
    let messages: [GrokMessage]
    let model: String
    let stream: Bool
    let temperature: Double
    
    init(userMessage: String, systemMessage: String?, history: [Message]?) {
        self.model = Settings.textModel 
        self.stream = true
        self.temperature = 0
        
        var messages = [GrokMessage]()
        if let systemMessage {
            messages.append(GrokMessage(role: "system", content: systemMessage))
        }
        
        if let history {
            for item in history {
                let grokMessage = GrokMessage(role: item.type.value, content: item.text)
                messages.append(grokMessage)
            }
        }
        
        messages.append(GrokMessage(role: "user", content: userMessage))
        self.messages = messages
    }
}
