import AVFoundation
import SwiftUI
import Combine

class CameraService: NSObject, ObservableObject {
    @Published var captureSession = AVCaptureSession()
    @Published var isRunning = false
    @Published var isCameraAvailable = false
    @Published var currentAspectRatio: AspectRatio = .sixteenByNine
    
    private var videoOutput = AVCaptureVideoDataOutput()
    private var photoOutput = AVCapturePhotoOutput()
    private var currentDevice: AVCaptureDevice?
    
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
    
    enum CameraError: Error {
        case noCameraAvailable
        case permissionDenied
        case sessionConfigurationFailed
        case captureError
    }
    
    override init() {
        super.init()
        checkCameraPermission()
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
    
    func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        settings.isHighResolutionPhotoEnabled = true
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
        // This will be used for ML processing in the next phase
        // For now, we just ensure the delegate is properly implemented
    }
}

// MARK: - AVCapturePhotoCaptureDelegate
extension CameraService: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            print("Photo capture error: \(error)")
            return
        }
        
        guard let imageData = photo.fileDataRepresentation() else {
            print("Failed to get image data")
            return
        }
        
        // Save photo to photo library or handle as needed
        // Implementation will be completed in the capture functionality phase
        print("Photo captured successfully: \(imageData.count) bytes")
    }
}