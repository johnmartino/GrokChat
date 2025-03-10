//
//  GrokImageRequest.swift
//  GrokChat
//
//  Created by John Martino on 12/9/24.
//

import SwiftUI

struct GrokImageURL: Codable {
    let detail: String
    let url: String?
}

struct GrokImageContent: Codable {
    let type: String
    let imageURL: GrokImageURL?
    let text: String?
    
    init(base64: String) {
        self.type = "image_url"
        self.text = nil
        self.imageURL = GrokImageURL(detail: "high", url: "data:image/jpeg;base64,\(base64)")
    }

    init(text: String) {
        self.type = "text"
        self.text = text
        self.imageURL = nil
    }
    
    enum CodingKeys: String, CodingKey {
        case type, text
        case imageURL = "image_url"
    }
}

struct GrokImageMessage: Codable {
    let role: String
    let content: [GrokImageContent]
    
    init(role: String, text: String, images: [UIImage]) {
        self.role = role
        var content = [GrokImageContent]()
        for image in images {
            if let base64Image = image.jpegData(compressionQuality: 0.5)?.base64EncodedString() {
                content.append(GrokImageContent(base64: base64Image))
            }
        }
        content.append(GrokImageContent(text: text))
        self.content = content
    }
}

struct GrokImageRequest: Codable {
    let messages: [GrokImageMessage]
    let model: String
    let stream: Bool
    let temperature: Double

    init(text: String, images: [UIImage], stream: Bool = true) {
        self.model = Settings.visionModel 
        self.stream = stream
        self.temperature = 0.01
        self.messages = [GrokImageMessage(role: "user", text: text, images: images)]
    }
}
