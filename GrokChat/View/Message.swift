//
//  Message.swift
//  GrokChat
//
//  Created by John Martino on 11/24/24.
//

import SwiftUI
import SwiftData

enum MessageType: Codable {
    case user
    case system 
    
    var backgroundColor: Color {
        switch self {
        case .user: return Color(.systemGray5)
        case .system: return Color(.systemBackground)
        }
    }
    
    var alignment: Alignment {
        switch self {
        case .user: return .trailing
        case .system: return .leading
        }
    }
    
    @ViewBuilder var icon: Image? {
        if self == .system {
            Image(.logo)
        }
    }
}

@Model
class Message: Identifiable {
    var id: Int
    var text: String
    var type: MessageType
    
    init(id: Int, text: String, type: MessageType) {
        self.id = id
        self.text = text
        self.type = type
    }
}

#Preview {
    VStack {
        MessageView(
            message: Message(
                id: 0,
                text: "What is Fight Club about?",
                type: .user))
        
        MessageView(
            message: Message(
                id: 1,
                text: "\"Fight Club,\" released in 1999 and directed by David Fincher, is based on the novel by Chuck Palahniuk. Here's a summary of its plot:\n\n1. **Introduction to the Narrator**: The film begins with an unnamed insomniac narrator (played by Edward Norton) who works as a recall coordinator for an automobile company. He's disillusioned with his life, suffering from insomnia, and finds temporary relief by attending various support groups for diseases he doesn't have, where he can cry and feel a sense of belonging.\n\n2. **Meeting Tyler Durden**: On a business trip, the narrator meets Tyler Durden (Brad Pitt), a charismatic soap salesman with a nihilistic philosophy. After his apartment explodes due to a mysterious gas leak, the narrator calls Tyler, and they meet at a bar. Here, Tyler asks him what he wants, leading to the creation of Fight Club.\n\n3. **Formation of Fight Club**: Tyler and the narrator start Fight Club in the basement of the bar, where men come to fight for the release of their frustrations and to feel alive. The first rule of Fight Club is \"you do not talk about Fight Club,\" emphasizing its secretive nature.\n\n4. **Expansion and Ideology**: Fight Club grows, spreading to other cities. Tyler begins to preach about the decay of modern society, consumerism, and the need for men to reclaim their masculinity and identity through primal experiences. The club evolves into Project Mayhem, a more organized group with a mission to destroy symbols of corporate America.\n\n5. **Relationship with Marla**: Marla Singer (Helena Bonham Carter) is another insomniac who attends the same support groups. She becomes a love interest for both the narrator and Tyler, creating tension. Marla's presence also forces the narrator to confront his own identity and the reality of his situation.\n\n6. **The Twist**: The pivotal twist in the movie reveals that Tyler Durden is not a separate person but an alter ego of the narrator. This revelation comes when the narrator discovers that Tyler has been using his body to carry out actions while he was \"asleep.\" Tyler's philosophy and actions are manifestations of the narrator's own suppressed desires and frustrations.\n\n7. **Climax and Resolution**: The narrator tries to stop Tyler's plan to destroy the city's financial records, which would erase all debt. This leads to a confrontation where he attempts to kill Tyler, which symbolically means trying to kill part of himself. In the end, he shoots himself in the cheek, which causes Tyler to disappear. The narrator and Marla watch as the buildings explode, but the narrator's acceptance of his identity and his relationship with Marla suggest a form of personal resolution.\n\n\"Fight Club\" is known for its critique of consumer culture, exploration of identity, and its commentary on masculinity in modern society. The film's ending leaves viewers with much to ponder about the nature of reality, identity, and the consequences of one's actions.",
                type: .system))
    }
}
