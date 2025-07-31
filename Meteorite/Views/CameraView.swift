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
                
                // Grid Selector (center-left)
                HStack {
                    GridSelectorView(selectedComposition: $selectedComposition)
                        .padding(.leading)
                    Spacer()
                }
                
                Spacer()
                
                // Bottom Controls
                HStack {
                    Spacer()
                    
                    // Capture Button
                    Button(action: { viewModel.capturePhoto() }) {
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 70, height: 70)
                            
                            Circle()
                                .stroke(Color.black, lineWidth: 2)
                                .frame(width: 60, height: 60)
                            
                            if viewModel.isCapturing {
                                Circle()
                                    .fill(Color.red)
                                    .frame(width: 50, height: 50)
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