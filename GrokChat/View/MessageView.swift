//
//  MessageView.swift
//  GrokChat
//
//  Created by John Martino on 11/24/24.
//

import SwiftUI
import MarkdownUI

struct MessageView: View {
    let message: Message
    
    private let radius: CGFloat = 16
    
    @State private var text = ""
    
    var body: some View {
        VStack(alignment: .trailing) {
            HStack(alignment: .top) {
                message.type.icon?
                    .resizable()
                    .renderingMode(.template)
                    .foregroundStyle(.primary)
                    .frame(width: 16, height: 16)
                    .padding(8)
                    .background {
                        Circle()
                            .stroke(lineWidth: 1)
                            .foregroundStyle(.secondary)
                    }
                
                Markdown {
                    message.text.trimmingCharacters(in: .whitespacesAndNewlines)
                }
            }
            .foregroundStyle(.primary)
            .padding(.horizontal, message.type == .system ? 0 : 16)
            .padding(.vertical, 8)
            .background {
                message.type.backgroundColor
                    .clipShape(.rect(cornerRadius: radius))
            }
            
            if let images = message.images, !images.isEmpty {
                HStack {
                    ForEach(images, id: \.self) { data in
                        if let image = UIImage(data: data) {
                            Image(uiImage: image)
                                .resizable()
                                .frame(width: 100, height: 100)
                                .clipShape(.rect(cornerRadius: radius))
                        }
                    }
                }
            }
        }
        .padding(.horizontal)
        .frame(maxWidth: .infinity, alignment: message.type.alignment)
    }
}

#Preview {
    ScrollView {
        VStack {
            MessageView(
                message: Message(
                    id: 0,
                    text: "What is Fight Club about?",
                    images: nil,
                    type: .user))
            MessageView(
                message: Message(
                    id: 1,
                    text: "\"Fight Club,\" released in 1999 and directed by David Fincher, is based on the novel by Chuck Palahniuk. Here's a summary of its plot:\n\n1. **Introduction to the Narrator**: The film begins with an unnamed insomniac narrator (played by Edward Norton) who works as a recall coordinator for an automobile company. He's disillusioned with his life, suffering from insomnia, and finds temporary relief by attending various support groups for diseases he doesn't have, where he can cry and feel a sense of belonging.\n\n2. **Meeting Tyler Durden**: On a business trip, the narrator meets Tyler Durden (Brad Pitt), a charismatic soap salesman with a nihilistic philosophy. After his apartment explodes due to a mysterious gas leak, the narrator calls Tyler, and they meet at a bar. Here, Tyler asks him what he wants, leading to the creation of Fight Club.\n\n3. **Formation of Fight Club**: Tyler and the narrator start Fight Club in the basement of the bar, where men come to fight for the release of their frustrations and to feel alive. The first rule of Fight Club is \"you do not talk about Fight Club,\" emphasizing its secretive nature.\n\n4. **Expansion and Ideology**: Fight Club grows, spreading to other cities. Tyler begins to preach about the decay of modern society, consumerism, and the need for men to reclaim their masculinity and identity through primal experiences. The club evolves into Project Mayhem, a more organized group with a mission to destroy symbols of corporate America.\n\n5. **Relationship with Marla**: Marla Singer (Helena Bonham Carter) is another insomniac who attends the same support groups. She becomes a love interest for both the narrator and Tyler, creating tension. Marla's presence also forces the narrator to confront his own identity and the reality of his situation.\n\n6. **The Twist**: The pivotal twist in the movie reveals that Tyler Durden is not a separate person but an alter ego of the narrator. This revelation comes when the narrator discovers that Tyler has been using his body to carry out actions while he was \"asleep.\" Tyler's philosophy and actions are manifestations of the narrator's own suppressed desires and frustrations.\n\n7. **Climax and Resolution**: The narrator tries to stop Tyler's plan to destroy the city's financial records, which would erase all debt. This leads to a confrontation where he attempts to kill Tyler, which symbolically means trying to kill part of himself. In the end, he shoots himself in the cheek, which causes Tyler to disappear. The narrator and Marla watch as the buildings explode, but the narrator's acceptance of his identity and his relationship with Marla suggest a form of personal resolution.\n\n\"Fight Club\" is known for its critique of consumer culture, exploration of identity, and its commentary on masculinity in modern society. The film's ending leaves viewers with much to ponder about the nature of reality, identity, and the consequences of one's actions.",
                    images: nil,
                    type: .system))
            MessageView(
                message: Message(
                    id: 2,
                    text: "Show code.",
                    images: nil,
                    type: .user))
            MessageView(
                message: Message(
                    id: 3,
                    text: "Here's a Swift function to calculate the nth Fibonacci number:\n\n```swift\nfunc fibonacci(_ n: Int) -> Int {\n    // Base cases\n    if n <= 1 {\n        return n\n    }\n    \n    // Initialize the first two Fibonacci numbers\n    var a = 0\n    var b = 1\n    \n    // Loop to calculate the nth Fibonacci number\n    for _ in 2...n {\n        let temp = a + b\n        a = b\n        b = temp\n    }\n    \n    return b\n}\n\n// Example usage:\nlet n = 10\nprint(\"The \\(n)th Fibonacci number is: \\(fibonacci(n))\")\n```\n\n### Explanation:\n- **Base Cases:** If `n` is 0 or 1, the function returns `n` directly since these are the first two numbers in the Fibonacci sequence.\n- **Initialization:** We initialize `a` and `b` to represent the first two Fibonacci numbers (0 and 1).\n- **Loop:** We use a loop to calculate subsequent Fibonacci numbers. In each iteration, we calculate the next number by adding the previous two (`a + b`), then update `a` and `b` for the next iteration.\n- **Return:** After the loop, `b` will contain the nth Fibonacci number, which we return.\n\nThis function uses an iterative approach which is more efficient than a recursive one for larger values of `n` due to avoiding stack overflow and having a time complexity of O(n). Remember, however, that Fibonacci numbers grow exponentially, so for very large `n`, you might encounter integer overflow issues with this implementation.",
                    images: nil,
                    type: .system))
        }
    }
}
