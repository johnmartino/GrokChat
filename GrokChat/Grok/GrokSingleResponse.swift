//
//  GrokSingleResponse.swift
//  GrokChat
//
//  Created by John Martino on 12/10/24.
//

import Foundation

struct SingleMessage: Codable {
    let role: String?
    let content: String
    let refusal: String?
}

struct SingleUsage: Codable {
    let promptTokens: Int
    let completionTokens: Int
    let totalTokens: Int
    
    enum CodingKeys: String, CodingKey {
        case promptTokens = "prompt_tokens"
        case completionTokens = "completion_tokens"
        case totalTokens = "total_tokens"
    }
}

struct SingleChoice: Codable {
    let index: Int
    let message: SingleMessage
}

struct GrokSingleResponse: Codable {
    let id: String
    let object: String
    let created: Int
    let model: String
    let choices: [SingleChoice]
    let usage: SingleUsage
    let systemFingerprint: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case object
        case created
        case model
        case choices
        case usage
        case systemFingerprint = "system_fingerprint"
    }
}
