//
//  Settings.swift
//  GrokChat
//
//  Created by John Martino on 12/13/24.
//

import Foundation

struct Settings {
    static var key: String? {
        get {
            UserDefaults.standard.string(forKey: "key")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "key")
        }
    }
    
    static var model: String? {
        get {
            UserDefaults.standard.string(forKey: "model")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "model")
        }
    }
    
    static var textModel: String {
        let modelValue = Self.model ?? ""
        let model = GrokModel(rawValue: modelValue)
        return model?.text ?? ""
    }
    
    static var visionModel: String {
        let modelValue = Self.model ?? ""
        let model = GrokModel(rawValue: modelValue)
        return model?.vision ?? ""
    }
}
