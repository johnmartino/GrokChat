//
//  Settings.swift
//  GrokChat
//
//  Created by John Martino on 12/28/24.
//

import Foundation

struct Settings {
    static var textModel: String {
        UserDefaults.standard.string(forKey: "text-model") ?? ""
    }
    
    static var visionModel: String {
        UserDefaults.standard.string(forKey: "vision-model") ?? ""
    }
    
    static var key: String? {
        UserDefaults.standard.string(forKey: "key") 
    }
}
