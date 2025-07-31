import SwiftUI
import AVFoundation

struct CameraView: View {
    @StateObject private var viewModel = CameraViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var selectedComposition: CompositionType = .ruleOfThirds
    @State private var showGrid = true
    
    var body: some View {
        ZStack {
            // Camera Preview
            CameraPreviewView(session: viewModel.cameraService.captureSession)
                .ignoresSafeArea()
                .aspectRatio(viewModel.selectedAspectRatio.ratio, contentMode: .fit)
                .clipped()
            
            // Grid Overlay
            if showGrid {
                GridOverlayView(
                    compositionType: selectedComposition,
                    aspectRatio: viewModel.selectedAspectRatio,
                    opacity: 0.8
                )
                .aspectRatio(viewModel.selectedAspectRatio.ratio, contentMode: .fit)
                .clipped()
                .allowsHitTesting(false)
            }
            
            // Camera Controls Overlay
            VStack {
                // Top Controls
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black.opacity(0.6))
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    // ML Analysis Toggle
                    Button(action: { viewModel.toggleMLAnalysis() }) {
                        Image(systemName: viewModel.isMLAnalysisEnabled ? "brain" : "brain.slash")
                            .font(.title3)
                            .foregroundColor(viewModel.isMLAnalysisEnabled ? .green : .white)
                            .padding()
                            .background(Color.black.opacity(0.6))
                            .clipShape(Circle())
                    }
                    
                    // Grid Toggle
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            showGrid.toggle()
                        }
                    }) {
                        Image(systemName: showGrid ? "grid" : "grid.slash")
                            .font(.title3)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black.opacity(0.6))
                            .clipShape(Circle())
                    }
                    
                    // Aspect Ratio Toggle
                    Button(action: { viewModel.toggleAspectRatio() }) {
                        Text(viewModel.selectedAspectRatio.rawValue)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.black.opacity(0.6))
                            .cornerRadius(8)
                    }
                }
                .padding()
                
                // Grid Selector and ML Recommendation
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        GridSelectorView(selectedComposition: $selectedComposition)
                        
                        // ML Recommendation Display
                        if viewModel.isMLAnalysisEnabled {
                            MLRecommendationView(
                                recommendedComposition: viewModel.compositionAnalysisService.recommendedComposition,
                                confidence: viewModel.compositionAnalysisService.confidenceScore,
                                isAnalyzing: viewModel.compositionAnalysisService.isAnalyzing,
                                onApplyRecommendation: { recommendation in
                                    selectedComposition = recommendation
                                }
                            )
                        }
                    }
                    .padding(.leading)
                    
                    Spacer()
                }
                
                Spacer()
                
                // Bottom Controls
                HStack {
                    // Last captured photo thumbnail
                    if let lastImage = viewModel.cameraService.lastCapturedImage {
                        Button(action: {
                            // Could navigate to photo review/gallery view
                        }) {
                            Image(uiImage: lastImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 50, height: 50)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.white, lineWidth: 2)
                                )
                        }
                    } else {
                        // Placeholder
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.clear)
                            .frame(width: 50, height: 50)
                    }
                    
                    Spacer()
                    
                    // Capture Button
                    Button(action: { 
                        viewModel.capturePhoto(with: selectedComposition)
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 70, height: 70)
                            
                            Circle()
                                .stroke(Color.black, lineWidth: 2)
                                .frame(width: 60, height: 60)
                            
                            // Capture status indicator
                            Group {
                                switch viewModel.cameraService.captureStatus {
                                case .idle:
                                    Image(systemName: "camera")
                                        .font(.title2)
                                        .foregroundColor(.black)
                                case .capturing:
                                    ProgressView()
                                        .scaleEffect(0.8)
                                case .processing:
                                    Image(systemName: "gear")
                                        .font(.title2)
                                        .foregroundColor(.blue)
                                        .rotationEffect(.degrees(viewModel.isCapturing ? 360 : 0))
                                        .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: viewModel.isCapturing)
                                case .saved:
                                    Image(systemName: "checkmark")
                                        .font(.title2)
                                        .foregroundColor(.green)
                                case .failed:
                                    Image(systemName: "xmark")
                                        .font(.title2)
                                        .foregroundColor(.red)
                                }
                            }
                        }
                    }
                    .disabled(viewModel.isCapturing)
                    .scaleEffect(viewModel.isCapturing ? 0.9 : 1.0)
                    .animation(.easeInOut(duration: 0.1), value: viewModel.isCapturing)
                    
                    Spacer()
                }
                .padding(.bottom, 50)
            }
        }
        .background(Color.black)
        .onAppear {
            viewModel.startCamera()
        }
        .onDisappear {
            viewModel.stopCamera()
        }
        .alert("Camera Permission Required", isPresented: $viewModel.showPermissionAlert) {
            Button("Settings") {
                if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsUrl)
                }
            }
            Button("Cancel", role: .cancel) {
                dismiss()
            }
        } message: {
            Text("Meteorite needs camera access to provide composition guidance. Please enable camera access in Settings.")
        }
    }
}

struct CameraPreviewView: UIViewRepresentable {
    let session: AVCaptureSession
    
    func makeUIView(context: Context) -> VideoPreviewView {
        let view = VideoPreviewView()
        view.previewLayer.session = session
        view.previewLayer.videoGravity = .resizeAspectFill
        return view
    }
    
    func updateUIView(_ uiView: VideoPreviewView, context: Context) {
        // Update view if needed
    }
}

class VideoPreviewView: UIView {
    override class var layerClass: AnyClass {
        AVCaptureVideoPreviewLayer.self
    }
    
    var previewLayer: AVCaptureVideoPreviewLayer {
        return layer as! AVCaptureVideoPreviewLayer
    }
}

#Preview {
    CameraView()
}