//
//  GrokRequest.swift
//  GrokChat
//
//  Created by John Martino on 11/24/24.
//

import Foundation

struct GrokMessage: Codable {
    let role: String
    let content: String
}

struct GrokRequest: Codable {
    let messages: [GrokMessage]
    let model: String
    let stream: Bool
    let temperature: Double
    
    init(userMessage: String, systemMessage: String?) {
        self.model = "grok-beta"
        self.stream = true
        self.temperature = 0
        
        var messages = [GrokMessage]()
        messages.append(GrokMessage(role: "user", content: userMessage))
        if let systemMessage {
            messages.append(GrokMessage(role: "system", content: systemMessage))
        }
        self.messages = messages
    }
}
