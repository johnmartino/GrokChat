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
    
    @StateObject private var cameraManager = CameraManager()
    @State private var showCameraPermissionMessage = false
    @State private var showCamera = false
    @State private var cameraImage: UIImage?
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Group {
                    if !selectedImages.isEmpty {
                        HStack {
                            ForEach(0 ..< selectedImages.count, id: \.self) { index in
                                attachment(image: selectedImages[index]) {
                                    selectedImages.remove(at: index)
                                    photoItems.remove(at: index)
                                }
                            }
                            Spacer()
                        }
                    }
                    
                    if let cameraImage {
                        attachment(image: cameraImage) {
                            self.cameraImage = nil
                        }
                        
                        if selectedImages.isEmpty {
                            Spacer()
                        }
                    }
                }
                .padding(.bottom, 8)
            }
            
            inputField
            HStack {
                menuButton
                Spacer()
                submitButton
            }
            .disabled(isQuerying)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
        .clipShape(.rect(cornerRadius: 16))
        .padding([.horizontal, .bottom])
        .disabled(isQuerying)
        .photosPicker(isPresented: $showImagePicker, selection: $photoItems, maxSelectionCount: 3, selectionBehavior: .default, matching: .images, preferredItemEncoding: .automatic, photoLibrary: .shared())
        .tint(.primary)
        .task(id: photoItems) {
            self.selectedImages.removeAll()
            for photoItem in photoItems {
                if let image = await extractImage(photoItem) {
                    self.selectedImages.append(image)
                }
            }
        }
        .alert("Unable to access the Camera", isPresented: $showCameraPermissionMessage) {
            Button("Cancel") { }
            Button("Settings") {
                guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
                if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl) { success in }
                }
            }
        } message: {
            Text("To enable access, go to Settings > Privacy > Camera and turn on access for NYC 311.")
        }
        .fullScreenCover(isPresented: $showCamera) {
            if cameraManager.granted {
                CameraPickerView(selectedImage: $cameraImage)
                    .ignoresSafeArea()
            }
        }
    }
    
    private var shouldShowFullField: Bool {
        !selectedImages.isEmpty || !message.isEmpty
    }
    
    private var inputField: some View {
        TextField("Query", text: $message, axis: .vertical)
            .multilineTextAlignment(.leading)
            .foregroundStyle(isQuerying ? .secondary : .primary)
            .focused($focus)
            .submitLabel(.return)
    }
    
    private var submitButton: some View {
        Button {
            if !message.isEmpty {
                if let cameraImage {
                    selectedImages.append(cameraImage)
                }
                action(message, selectedImages)
                focus = false
                withAnimation {
                    message = ""
                    photoItems.removeAll()
                    selectedImages.removeAll()
                    cameraImage = nil
                }
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
    
    private var menuButton: some View {
        Menu {
            Button {
                Task {
                    await cameraManager.requestPermission()
                    if cameraManager.granted {
                        showCamera = true
                    } else if cameraManager.status == .denied {
                        showCameraPermissionMessage = true
                    }
                }
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
    }
    
    @MainActor private func extractImage(_ photoItem: PhotosPickerItem) async -> UIImage? {
        guard let imageData = try? await photoItem.loadTransferable(type: Data.self) else { return nil }
        return UIImage(data: imageData)
    }
    
    func attachment(image: UIImage, onDelete: @escaping () -> Void) -> some View {
        Image(uiImage: image)
            .resizable()
            .frame(width: 60, height: 60)
            .clipShape(.rect(cornerRadius: 8))
            .transition(.opacity)
            .contextMenu {
                Button(role: .destructive) {
                    onDelete()
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            }
            .onTapGesture {
                selectedImage = image
            }
            .fullScreenCover(item: $selectedImage) { image in
                ImageView(uiImage: image)
                    .tint(.primary)
                    .ignoresSafeArea()
            }
    }
}

#Preview {
    InputField(isQuerying: .constant(false)) { message, images in
        
    }
}
