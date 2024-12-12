//
//  CameraPickerView.swift
//  GrokChat
//
//  Created by John Martino on 12/10/24.
//

import UIKit
import SwiftUI

struct CameraPickerView: UIViewControllerRepresentable {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedImage: UIImage?
        
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .camera
        imagePicker.cameraFlashMode = .off
        imagePicker.delegate = context.coordinator
        return imagePicker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: CameraPickerView
        
        init(_ parent: CameraPickerView) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            parent.dismiss()
        }
    }
}

#Preview {
    CameraPickerView(selectedImage: .constant(nil))
        .ignoresSafeArea()
}
