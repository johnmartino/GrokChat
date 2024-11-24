//
//  GrokResponse.swift
//  GrokChat
//
//  Created by John Martino on 11/24/24.
//

import Foundation

struct PromptTokensDetails: Codable {
    let textTokens: Int
    let audioTokens: Int
    let imageTokens: Int
    let cachedTokens: Int
    
    enum CodingKeys: String, CodingKey {
        case textTokens = "text_tokens"
        case audioTokens = "audio_tokens"
        case imageTokens = "image_tokens"
        case cachedTokens = "cached_tokens"
    }
}

struct Usage: Codable {
    let promptTokens: Int
    let completionTokens: Int
    let totalTokens: Int
    let promptTokensDetails: PromptTokensDetails
    
    enum CodingKeys: String, CodingKey {
        case promptTokens = "prompt_tokens"
        case completionTokens = "completion_tokens"
        case totalTokens = "total_tokens"
        case promptTokensDetails = "prompt_tokens_details"
    }
}

struct Delta: Codable {
    let content: String?
    let role: String
}

struct Choice: Codable {
    let index: Int
    let delta: Delta
}

struct GrokResponse: Codable {
    let id: String
    let object: String
    let created: Int
    let model: String
    let choices: [Choice]
    let usage: Usage
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
