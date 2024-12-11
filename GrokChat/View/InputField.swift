//
//  InputField.swift
//  GrokChat
//
//  Created by John Martino on 11/24/24.
//

import SwiftUI
import PhotosUI

struct InputField: View {
    @Binding var isQuerying: Bool
    var action: (_ message: String, _ images: [UIImage]) -> Void
    
    @State private var message: String = ""
    @FocusState private var focus
    
    @State private var showImagePicker = false
    @State private var photoItems = [PhotosPickerItem]()
    @State private var selectedImages = [UIImage]()
    @State private var selectedImage: UIImage?
    
    var body: some View {
        VStack(spacing: 0) {
            if !selectedImages.isEmpty {
                HStack {
                    ForEach(0 ..< selectedImages.count, id: \.self) { index in
                        Image(uiImage: selectedImages[index])
                            .resizable()
                            .frame(width: 100, height: 100)
                            .clipShape(.rect(cornerRadius: 10))
                            .transition(.opacity)
                            .contextMenu {
                                Button(role: .destructive) {
                                    selectedImages.remove(at: index)
                                    photoItems.remove(at: index)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                            .onTapGesture {
                                selectedImage = selectedImages[index]
                            }
                            .fullScreenCover(item: $selectedImage) { image in
                                ImageView(uiImage: image)
                                    .ignoresSafeArea()
                            }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            TextField("Query Grok", text: $message, axis: .vertical)
                .multilineTextAlignment(.leading)
                .foregroundStyle(isQuerying ? .secondary : .primary)
                .focused($focus)
                .padding(.horizontal, 8)
                .padding(.vertical, 8)
                .submitLabel(.return)
            
            HStack {
                Menu {
                    Button {
                        
                    } label: {
                        Label("Take Photo", systemImage: "camera")
                    }
                    
                    Button {
                        showImagePicker.toggle()
                    } label: {
                        Label("Attach Photos", systemImage: "photo")
                    }
                } label: {
                    Image(systemName: "plus")
                        .imageScale(.large)
                        .font(.headline)
                        .tint(.primary)
                }
                .padding(8)
                
                Spacer()
                
                Button {
                    action(message, selectedImages)
                    focus = false
                    withAnimation {
                        message = ""
                        photoItems.removeAll()
                        selectedImages.removeAll()
                    }
                } label: {
                    Image(systemName: "arrow.up")
                        .tint(Color(.systemBackground))
                        .padding(8)
                        .background {
                            Circle()
                                .foregroundStyle(isQuerying ? Color(.systemGray6) : .primary)
                        }
                }
            }
            .disabled(isQuerying)
        }
        .padding()
        .overlay {
            RoundedRectangle(cornerRadius: 32)
                .stroke(Color.secondary, lineWidth: 1)
        }
        .padding([.horizontal, .bottom])
        .disabled(isQuerying)
        .photosPicker(isPresented: $showImagePicker, selection: $photoItems, maxSelectionCount: 3, selectionBehavior: .default, matching: .images, preferredItemEncoding: .automatic, photoLibrary: .shared())
        .task(id: photoItems) {
            self.selectedImages.removeAll()
            for photoItem in photoItems {
                if let image = await extractImage(photoItem) {
                    self.selectedImages.append(image)
                }
            }
        }
    }
    
    @MainActor private func extractImage(_ photoItem: PhotosPickerItem) async -> UIImage? {
        guard let imageData = try? await photoItem.loadTransferable(type: Data.self) else { return nil }
        return UIImage(data: imageData)
    }
}

#Preview {
    InputField(isQuerying: .constant(false)) { message, images in
        
    }
}
