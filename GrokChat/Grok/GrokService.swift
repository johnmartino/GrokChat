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
    
    @MainActor func query(system: String? = nil, user: String) async throws {
        guard !busy else {
            hapticGenerator.notificationOccurred(.error)
            throw URLError(.callIsActive)
        }
        responseMessage = ""
        
        let request = try await queryRequest(system: system, user: user)
        let (stream, _) = try await URLSession.shared.bytes(for: request)
        
        for try await line in stream.lines {
            guard let message = try? parse(line) else { continue }
            responseMessage += message
        }
        hapticGenerator.notificationOccurred(.success)
    }
    
    private func queryRequest(system: String? = nil, user: String) async throws -> URLRequest {
        let grokRequest = GrokRequest(userMessage: user, systemMessage: system)
        
        guard let url = URL(string: "https://api.x.ai/v1/chat/completions") else { throw URLError(.badURL) }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try JSONEncoder().encode(grokRequest)
        request.allHTTPHeaderFields = [
            "Content-Type": "application/json",
            "Authorization": "Bearer xai-i8I7DeH2ebfAGdS8X0cnfMVBiS4RknqHekTJQBTxNWNEXiLh5r3bjZOLKFF6nZ20uou7eh0ycOWD8bmZ"
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
