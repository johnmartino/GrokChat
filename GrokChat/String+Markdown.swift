//
//  String+Markdown.swift
//  GrokChat
//
//  Created by John Martino on 11/24/24.
//

import Foundation

extension String {
    var markdown: AttributedString {
        do {
            return try AttributedString(markdown: self, options: AttributedString.MarkdownParsingOptions(allowsExtendedAttributes: false, interpretedSyntax: .inlineOnlyPreservingWhitespace))
        } catch {
            return AttributedString(error.localizedDescription)
        }
    }
}
