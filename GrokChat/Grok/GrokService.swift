//
//  GrokService.swift
//  GrokChat
//
//  Created by John Martino on 11/24/24.
//

import SwiftUI

@Observable
class GrokService {
    var responseMessage = ""
    var busy = false
    
    private let hapticGenerator = UINotificationFeedbackGenerator()
    
    @MainActor func query(system: String? = nil, user: String, history: [Message]) async throws {
        guard !busy else {
            hapticGenerator.notificationOccurred(.error)
            throw URLError(.callIsActive)
        }
        responseMessage = ""
        
        busy = true
        let request = try await queryRequest(system: system, user: user, history: history)
        let (stream, _) = try await URLSession.shared.bytes(for: request)
        
        for try await line in stream.lines {
            guard let message = try? parse(line) else { continue }
            responseMessage += message
        }
        hapticGenerator.notificationOccurred(.success)
        busy = false
    }
    
    @MainActor func query(text: String, images: [UIImage]) async throws {
        guard !busy else {
            hapticGenerator.notificationOccurred(.error)
            throw URLError(.callIsActive)
        }
        responseMessage = ""
        
        busy = true
        let request = try await queryRequest(text: text, images: images)
        let (stream, _) = try await URLSession.shared.bytes(for: request)
        
        for try await line in stream.lines {
            guard let message = try? parse(line) else { continue }
            responseMessage += message
        }
        hapticGenerator.notificationOccurred(.success)
        busy = false
    }
    
    @MainActor func querySingle(text: String, images: [UIImage]) async throws {
        let request = try await queryRequest(text: text, images: images)
        let (data, _) = try await URLSession.shared.data(for: request)
        let json = try JSONDecoder().decode(GrokSingleResponse.self, from: data)
        responseMessage = json.choices.first?.message.content ?? ""
    }
    
    private func queryRequest(system: String? = nil, user: String, history: [Message]?) async throws -> URLRequest {
        let grokRequest = GrokRequest(userMessage: user, systemMessage: system, history: history)
        
        guard let key = Settings.key, !key.isEmpty else { throw URLError(.zeroByteResource) }
        guard let url = URL(string: "https://api.x.ai/v1/chat/completions") else { throw URLError(.badURL) }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try JSONEncoder().encode(grokRequest)
        request.allHTTPHeaderFields = [
            "Content-Type": "application/json",
            "Authorization": "Bearer \(key)"
        ]
        return request
    }
    
    private func queryRequest(text: String, images: [UIImage]) async throws -> URLRequest {
        let grokRequest = GrokImageRequest(text: text, images: images)
        
        guard let key = Settings.key, !key.isEmpty else { throw URLError(.zeroByteResource) }
        guard let url = URL(string: "https://api.x.ai/v1/chat/completions") else { throw URLError(.badURL) }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try JSONEncoder().encode(grokRequest)
        request.allHTTPHeaderFields = [
            "Content-Type": "application/json",
            "Authorization": "Bearer \(key)"
        ]
        return request
    }
    
    private func parse(_ line: String) throws -> String? {
        let components = line.split(separator: ":", maxSplits: 1, omittingEmptySubsequences: true)
        guard components.count == 2, components[0] == "data" else { return nil }
        
        let message = components[1].trimmingCharacters(in: .whitespacesAndNewlines)
        
        if message == "[DONE]" {
            return "\n"
        } else {
            if let data = message.data(using: .utf8) {
                let chunk = try JSONDecoder().decode(GrokResponse.self, from: data)
                return chunk.choices.first?.delta.content
            } else {
                return nil
            }
        }
    }
}
