import SwiftUI
import Combine
import AVFoundation

@MainActor
class CameraViewModel: ObservableObject {
    @Published var cameraService = CameraService()
    @Published var isShowingCamera = false
    @Published var selectedAspectRatio: CameraService.AspectRatio = .sixteenByNine
    @Published var isCapturing = false
    @Published var showPermissionAlert = false
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupBindings()
    }
    
    private func setupBindings() {
        // Bind camera service properties to view model
        cameraService.$isCameraAvailable
            .sink { [weak self] isAvailable in
                if !isAvailable {
                    self?.showPermissionAlert = true
                }
            }
            .store(in: &cancellables)
        
        cameraService.$currentAspectRatio
            .sink { [weak self] ratio in
                self?.selectedAspectRatio = ratio
            }
            .store(in: &cancellables)
    }
    
    func startCamera() {
        guard cameraService.isCameraAvailable else {
            showPermissionAlert = true
            return
        }
        
        isShowingCamera = true
        cameraService.startSession()
    }
    
    func stopCamera() {
        isShowingCamera = false
        cameraService.stopSession()
    }
    
    func toggleAspectRatio() {
        cameraService.switchAspectRatio()
    }
    
    func capturePhoto() {
        guard !isCapturing else { return }
        
        isCapturing = true
        cameraService.capturePhoto()
        
        // Reset capturing state after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.isCapturing = false
        }
    }
    
    func requestCameraPermission() {
        cameraService.checkCameraPermission()
    }
}