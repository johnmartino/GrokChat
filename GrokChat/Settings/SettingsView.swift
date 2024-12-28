//
//  SettingsView.swift
//  GrokChat
//
//  Created by John Martino on 12/13/24.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    
    private let hAPIKey = "xai-g5zVTwq8obqbI3vbHDPcX7Aawg9xs6CftcFKxdjUiwjihJE95ecD8pvTbgaJJczYzkTQqnDcPeRVI72L"
    private let jAPIKey = "xai-i8I7DeH2ebfAGdS8X0cnfMVBiS4RknqHekTJQBTxNWNEXiLh5r3bjZOLKFF6nZ20uou7eh0ycOWD8bmZ"
    
    @AppStorage("text-model") var textModel: String = "grok-2-beta"
    @AppStorage("vision-model") var visionModel: String = "grok-2-vision-beta"
    @AppStorage("key") var key: String = ""
    @Binding var valuesStatus: Bool
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    VStack(alignment: .leading) {
                        if !textModel.isEmpty {
                            Text("text").font(.caption).bold()
                        }
                        TextField("Text model", text: $textModel)
                    }
                    VStack(alignment: .leading) {
                        if !visionModel.isEmpty {
                            Text("vision").font(.caption).bold()
                        }
                        TextField("Vision model", text: $visionModel)
                    }
                } header: {
                    Text("Models").font(.headline)
                }
                
                Section {
                    TextField("Enter your API Key", text: $key, axis: .vertical)
                        .multilineTextAlignment(.leading)
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
                    valuesStatus = key.isEmpty || textModel.isEmpty || visionModel.isEmpty
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
