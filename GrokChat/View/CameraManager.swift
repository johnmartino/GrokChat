//
//  CameraManager.swift
//  GrokChat
//
//  Created by John Martino on 12/10/24.
//

import PhotosUI

class CameraManager: ObservableObject {
    @MainActor @Published var status = AVAuthorizationStatus.notDetermined
    @MainActor @Published var granted = false
    
    @MainActor func requestPermission() async {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .notDetermined:
            self.granted = false
            self.granted = await AVCaptureDevice.requestAccess(for: .video)
        case .restricted:
            self.granted = false
        case .denied:
            self.granted = false
        case .authorized:
            self.granted = true
        @unknown default:
            self.granted = false
        }
        self.status = status
    }
}
