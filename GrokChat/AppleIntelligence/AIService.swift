//
//  AIService.swift
//  GrokChat
//
//  Created by John Martino on 6/28/25.
//

import SwiftUI
import FoundationModels

@MainActor @Observable
class AIService {
    var response = ""
    private var model = SystemLanguageModel.default
    private let options = GenerationOptions(temperature: 2.0)
    private let session = LanguageModelSession(instructions: "You are a movie critic.")
    
    func isAvailable() -> (Bool, String?) {
        switch model.availability {
            case .available:
                return (true, nil)
            case .unavailable(.deviceNotEligible):
                return(false, "This device isn't eligible for Apple Intelligence.")
            case .unavailable(.appleIntelligenceNotEnabled):
                return(false, "Apple Intelligence isn't enabled on your device.")
            case .unavailable(.modelNotReady):
                return(false, "The Apple Intelligence model isn't ready yet.")
            case .unavailable(let other):
                return(false, "An unknown error occurred: \(other)")
        }
    }
    
    var busy: Bool {
        session.isResponding
    }
    
    func respond(to text: String) async throws {
        let stream = session.streamResponse(to: text, options: options)
        for try await partialResponse in stream {
            self.response = partialResponse
        }
    }
}
