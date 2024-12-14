//
//  SettingsView.swift
//  GrokChat
//
//  Created by John Martino on 12/13/24.
//

import SwiftUI

enum GrokModel: String, CaseIterable {
    case beta = "beta"
    case v2 = "v2"
    
    var vision: String {
        switch self {
        case .beta: return "grok-vision-beta"
        case .v2: return "grok-2-vision-1212"
        }
    }
    
    var text: String {
        switch self {
        case .beta: return "grok-beta"
        case .v2: return "grok-2-1212"
        }
    }
}

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    
    private let hAPIKey = "xai-g5zVTwq8obqbI3vbHDPcX7Aawg9xs6CftcFKxdjUiwjihJE95ecD8pvTbgaJJczYzkTQqnDcPeRVI72L"
    private let jAPIKey = "xai-i8I7DeH2ebfAGdS8X0cnfMVBiS4RknqHekTJQBTxNWNEXiLh5r3bjZOLKFF6nZ20uou7eh0ycOWD8bmZ"
    
    @AppStorage("model") var model = ""
    @AppStorage("key") var key: String = ""
    @Binding var valuesStatus: Bool
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Model", text: $model)
                } header: {
                    Text("Model").font(.headline)
                } footer: {
                    HStack {
                        Text("Available:")
                            .italic()
                        Button("β") { model = GrokModel.beta.rawValue }
                            .buttonStyle(.bordered)
                        Button("v2") { model = GrokModel.v2.rawValue }
                            .buttonStyle(.bordered)
                    }
                }
                
                Section {
                    TextField("Enter your API Key", text: $key)
                } header: {
                    Text("API Key").font(.headline)
                } footer: {
                    HStack {
                        Text("Keys:")
                            .italic()
                        Button("H") { key = hAPIKey }
                            .buttonStyle(.bordered)
                        Button("J") { key = jAPIKey }
                            .buttonStyle(.bordered)
                    }
                }
            }
            .navigationTitle(Text("Settings"))
            .toolbar {
                Button {
                    valuesStatus = key.isEmpty || model.isEmpty
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                }
            }
            .tint(.primary)
        }
    }
}

#Preview {
    SettingsView(valuesStatus: .constant(false))
}
