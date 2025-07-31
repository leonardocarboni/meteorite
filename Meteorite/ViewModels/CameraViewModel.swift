import SwiftUI
import Combine
import AVFoundation

@MainActor
class CameraViewModel: ObservableObject {
    @Published var cameraService = CameraService()
    @Published var compositionAnalysisService = CompositionAnalysisService()
    @Published var isShowingCamera = false
    @Published var selectedAspectRatio: CameraService.AspectRatio = .sixteenByNine
    @Published var isCapturing = false
    @Published var showPermissionAlert = false
    @Published var isMLAnalysisEnabled = true
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupBindings()
        setupMLAnalysis()
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
    
    private func setupMLAnalysis() {
        // Listen for camera frames and pass them to ML analysis
        NotificationCenter.default.publisher(for: NSNotification.Name("NewCameraFrame"))
            .compactMap { $0.object as? CMSampleBuffer }
            .receive(on: DispatchQueue.global(qos: .userInitiated))
            .sink { [weak self] sampleBuffer in
                guard let self = self, self.isMLAnalysisEnabled else { return }
                self.compositionAnalysisService.analyzeFrame(sampleBuffer)
            }
            .store(in: &cancellables)
    }
    
    func toggleMLAnalysis() {
        isMLAnalysisEnabled.toggle()
        if !isMLAnalysisEnabled {
            compositionAnalysisService.resetAnalysis()
        }
    }
    
    func getCurrentRecommendation() -> CompositionType {
        return compositionAnalysisService.recommendedComposition
    }
    
    func getConfidenceScore() -> Float {
        return compositionAnalysisService.confidenceScore
    }
}