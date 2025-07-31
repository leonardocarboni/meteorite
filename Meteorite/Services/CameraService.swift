import AVFoundation
import SwiftUI
import Combine
import Photos
import UIKit

class CameraService: NSObject, ObservableObject {
    @Published var captureSession = AVCaptureSession()
    @Published var isRunning = false
    @Published var isCameraAvailable = false
    @Published var currentAspectRatio: AspectRatio = .sixteenByNine
    @Published var isPhotoLibraryAvailable = false
    @Published var lastCapturedImage: UIImage?
    @Published var captureStatus: CaptureStatus = .idle
    
    private var videoOutput = AVCaptureVideoDataOutput()
    private var photoOutput = AVCapturePhotoOutput()
    private var currentDevice: AVCaptureDevice?
    private var currentCompositionType: CompositionType = .ruleOfThirds
    private var currentConfidence: Float = 0.0
    
    enum AspectRatio: String, CaseIterable {
        case sixteenByNine = "16:9"
        case nineBysixteen = "9:16"
        
        var ratio: CGFloat {
            switch self {
            case .sixteenByNine:
                return 16.0 / 9.0
            case .nineBysixteen:
                return 9.0 / 16.0
            }
        }
    }
    
    enum CaptureStatus {
        case idle
        case capturing
        case processing
        case saved
        case failed(Error)
    }
    
    enum CameraError: Error {
        case noCameraAvailable
        case permissionDenied
        case sessionConfigurationFailed
        case captureError
        case photoLibraryError
        case imageProcessingError
    }
    
    override init() {
        super.init()
        checkCameraPermission()
        checkPhotoLibraryPermission()
    }
    
    func checkCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setupCamera()
        case .notDetermined:
            requestCameraPermission()
        case .denied, .restricted:
            isCameraAvailable = false
        @unknown default:
            isCameraAvailable = false
        }
    }
    
    private func requestCameraPermission() {
        AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
            DispatchQueue.main.async {
                if granted {
                    self?.setupCamera()
                } else {
                    self?.isCameraAvailable = false
                }
            }
        }
    }
    
    private func setupCamera() {
        captureSession.beginConfiguration()
        
        // Configure session preset
        if captureSession.canSetSessionPreset(.photo) {
            captureSession.sessionPreset = .photo
        }
        
        // Setup camera input
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let videoInput = try? AVCaptureDeviceInput(device: videoDevice),
              captureSession.canAddInput(videoInput) else {
            captureSession.commitConfiguration()
            isCameraAvailable = false
            return
        }
        
        captureSession.addInput(videoInput)
        currentDevice = videoDevice
        
        // Setup video output for real-time processing
        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
            videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "camera.output.queue"))
        }
        
        // Setup photo output
        if captureSession.canAddOutput(photoOutput) {
            captureSession.addOutput(photoOutput)
            photoOutput.isHighResolutionCaptureEnabled = true
        }
        
        captureSession.commitConfiguration()
        isCameraAvailable = true
    }
    
    func startSession() {
        guard !isRunning else { return }
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession.startRunning()
            DispatchQueue.main.async {
                self?.isRunning = true
            }
        }
    }
    
    func stopSession() {
        guard isRunning else { return }
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession.stopRunning()
            DispatchQueue.main.async {
                self?.isRunning = false
            }
        }
    }
    
    func switchAspectRatio() {
        currentAspectRatio = currentAspectRatio == .sixteenByNine ? .nineBysixteen : .sixteenByNine
    }
    
    func checkPhotoLibraryPermission() {
        switch PHPhotoLibrary.authorizationStatus() {
        case .authorized, .limited:
            isPhotoLibraryAvailable = true
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { [weak self] status in
                DispatchQueue.main.async {
                    self?.isPhotoLibraryAvailable = (status == .authorized || status == .limited)
                }
            }
        case .denied, .restricted:
            isPhotoLibraryAvailable = false
        @unknown default:
            isPhotoLibraryAvailable = false
        }
    }
    
    func capturePhoto(compositionType: CompositionType, confidence: Float) {
        guard captureStatus == .idle else { return }
        
        self.currentCompositionType = compositionType
        self.currentConfidence = confidence
        self.captureStatus = .capturing
        
        let settings = AVCapturePhotoSettings()
        settings.isHighResolutionPhotoEnabled = true
        
        // Add metadata for composition guidance
        if let availableFormat = settings.availablePreviewPhotoPixelFormatTypes.first {
            settings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: availableFormat]
        }
        
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    func configureDeviceSettings() {
        guard let device = currentDevice else { return }
        
        do {
            try device.lockForConfiguration()
            
            // Set focus mode
            if device.isFocusModeSupported(.continuousAutoFocus) {
                device.focusMode = .continuousAutoFocus
            }
            
            // Set exposure mode
            if device.isExposureModeSupported(.continuousAutoExposure) {
                device.exposureMode = .continuousAutoExposure
            }
            
            device.unlockForConfiguration()
        } catch {
            print("Failed to configure device: \(error)")
        }
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
extension CameraService: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        // Send frame to composition analysis service for ML processing
        NotificationCenter.default.post(
            name: NSNotification.Name("NewCameraFrame"),
            object: sampleBuffer
        )
    }
}

// MARK: - AVCapturePhotoCaptureDelegate
extension CameraService: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            print("Photo capture error: \(error)")
            DispatchQueue.main.async {
                self.captureStatus = .failed(error)
            }
            return
        }
        
        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else {
            print("Failed to get image data")
            DispatchQueue.main.async {
                self.captureStatus = .failed(CameraError.imageProcessingError)
            }
            return
        }
        
        DispatchQueue.main.async {
            self.captureStatus = .processing
            self.lastCapturedImage = image
        }
        
        // Save to photo library with composition metadata
        savePhotoToLibrary(image: image, compositionType: currentCompositionType, confidence: currentConfidence)
    }
    
    private func savePhotoToLibrary(image: UIImage, compositionType: CompositionType, confidence: Float) {
        guard isPhotoLibraryAvailable else {
            DispatchQueue.main.async {
                self.captureStatus = .failed(CameraError.photoLibraryError)
            }
            return
        }
        
        PHPhotoLibrary.shared().performChanges({
            let request = PHAssetChangeRequest.creationRequestForAsset(from: image)
            
            // Add composition metadata to the photo's location description
            let metadata = "Meteorite: \(compositionType.displayName) (\(Int(confidence * 100))% confidence)"
            request.location = nil // We could add GPS location here if needed
            
            // We'll use the asset's creation date and description for our metadata
            // In a more advanced implementation, we could write EXIF data
            
        }) { [weak self] success, error in
            DispatchQueue.main.async {
                if success {
                    self?.captureStatus = .saved
                    // Reset status after a delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        self?.captureStatus = .idle
                    }
                } else {
                    self?.captureStatus = .failed(error ?? CameraError.photoLibraryError)
                }
            }
        }
    }
}