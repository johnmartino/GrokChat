//
//  ImageView.swift
//  GrokChat
//
//  Created by John Martino on 12/10/24.
//

import SwiftUI

struct ImageView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.safeAreaInsets) private var safeAreaInsets
    @Environment(\.scenePhase) var scenePhase
    
    let uiImage: UIImage
    
    var body: some View {
        ZoomableScrollView {
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
        }
        .overlay(alignment: .topLeading) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .padding(8)
                    .background(.ultraThinMaterial)
                    .clipShape(.circle)
                    .padding(.top, safeAreaInsets.top)
                    .padding(.leading, safeAreaInsets.leading)
                    .padding(.leading)
            }
        }
        .overlay(alignment: .topTrailing) {
            let image = Image(uiImage: uiImage)
            ShareLink(item: image, preview: SharePreview("", image: image))
                .padding(8)
                .background(.ultraThinMaterial)
                .clipShape(.rect(cornerRadius: 10))
                .padding(.top, safeAreaInsets.top)
                .padding(.leading, safeAreaInsets.trailing)
                .padding(.trailing)
        }
        .onChange(of: scenePhase) { oldValue, newValue in
            if newValue != .active {
                dismiss()
            }
        }
    }
}

extension UIImage: @retroactive Identifiable {
    public var id: String { UUID().uuidString }
}

#Preview {
    ImageView(uiImage: UIImage(systemName: "camera")!)
}

