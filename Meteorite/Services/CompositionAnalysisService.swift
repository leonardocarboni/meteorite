import Foundation
import CoreML
import Vision
import AVFoundation
import SwiftUI
import Combine

class CompositionAnalysisService: ObservableObject {
    @Published var recommendedComposition: CompositionType = .ruleOfThirds
    @Published var confidenceScore: Float = 0.0
    @Published var analysisResults: [CompositionAnalysis] = []
    @Published var isAnalyzing = false
    
    private var visionQueue = DispatchQueue(label: "vision.analysis.queue", qos: .userInitiated)
    private var lastAnalysisTime: Date = Date()
    private let analysisInterval: TimeInterval = 0.5 // Analyze every 500ms
    
    struct CompositionAnalysis {
        let compositionType: CompositionType
        let confidence: Float
        let detectedFeatures: [String]
        let suggestedGridPosition: CGPoint?
    }
    
    enum AnalysisError: Error {
        case visionRequestFailed
        case imageProcessingFailed
        case noFeaturesDetected
    }
    
    func analyzeFrame(_ sampleBuffer: CMSampleBuffer) {
        // Throttle analysis to prevent overwhelming the system
        let now = Date()
        guard now.timeIntervalSince(lastAnalysisTime) >= analysisInterval else { return }
        lastAnalysisTime = now
        
        guard !isAnalyzing else { return }
        
        visionQueue.async { [weak self] in
            self?.performVisionAnalysis(sampleBuffer)
        }
    }
    
    private func performVisionAnalysis(_ sampleBuffer: CMSampleBuffer) {
        DispatchQueue.main.async {
            self.isAnalyzing = true
        }
        
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            DispatchQueue.main.async {
                self.isAnalyzing = false
            }
            return
        }
        
        // Create Vision requests
        let requests: [VNRequest] = [
            createSaliencyRequest(),
            createHorizonDetectionRequest(),
            createEdgeDetectionRequest(),
            createFaceDetectionRequest(),
            createObjectDetectionRequest()
        ]
        
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
        
        do {
            try handler.perform(requests)
        } catch {
            print("Vision analysis failed: \(error)")
            DispatchQueue.main.async {
                self.isAnalyzing = false
            }
        }
    }
    
    // MARK: - Vision Request Creators
    
    private func createSaliencyRequest() -> VNGenerateAttentionBasedSaliencyImageRequest {
        let request = VNGenerateAttentionBasedSaliencyImageRequest { [weak self] request, error in
            guard let self = self,
                  let observations = request.results as? [VNSaliencyImageObservation] else {
                return
            }
            
            self.processSaliencyResults(observations)
        }
        return request
    }
    
    private func createHorizonDetectionRequest() -> VNDetectHorizonRequest {
        let request = VNDetectHorizonRequest { [weak self] request, error in
            guard let self = self,
                  let observations = request.results as? [VNHorizonObservation] else {
                return
            }
            
            self.processHorizonResults(observations)
        }
        return request
    }
    
    private func createEdgeDetectionRequest() -> VNGenerateImageFeaturePrintRequest {
        let request = VNGenerateImageFeaturePrintRequest { [weak self] request, error in
            guard let self = self,
                  let observations = request.results as? [VNFeaturePrintObservation] else {
                return
            }
            
            self.processEdgeResults(observations)
        }
        return request
    }
    
    private func createFaceDetectionRequest() -> VNDetectFaceRectanglesRequest {
        let request = VNDetectFaceRectanglesRequest { [weak self] request, error in
            guard let self = self,
                  let observations = request.results as? [VNFaceObservation] else {
                return
            }
            
            self.processFaceResults(observations)
        }
        return request
    }
    
    private func createObjectDetectionRequest() -> VNRecognizeObjectsRequest {
        let request = VNRecognizeObjectsRequest { [weak self] request, error in
            guard let self = self,
                  let observations = request.results as? [VNRecognizedObjectObservation] else {
                return
            }
            
            self.processObjectResults(observations)
        }
        return request
    }
    
    // MARK: - Result Processors
    
    private func processSaliencyResults(_ observations: [VNSaliencyImageObservation]) {
        guard let saliencyObservation = observations.first else { return }
        
        // Analyze salient regions to suggest composition
        let saliencyMap = saliencyObservation.salientObjects
        var analyses: [CompositionAnalysis] = []
        
        // Rule of thirds analysis based on salient objects
        for object in saliencyMap {
            let boundingBox = object.boundingBox
            let centerX = boundingBox.midX
            let centerY = boundingBox.midY
            
            // Check if object aligns with rule of thirds
            let ruleOfThirdsScore = calculateRuleOfThirdsScore(centerX: centerX, centerY: centerY)
            
            if ruleOfThirdsScore > 0.5 {
                analyses.append(CompositionAnalysis(
                    compositionType: .ruleOfThirds,
                    confidence: ruleOfThirdsScore,
                    detectedFeatures: ["Salient object at optimal position"],
                    suggestedGridPosition: CGPoint(x: centerX, y: centerY)
                ))
            }
            
            // Check for framing opportunities
            if boundingBox.width < 0.8 && boundingBox.height < 0.8 {
                analyses.append(CompositionAnalysis(
                    compositionType: .framing,
                    confidence: 0.7,
                    detectedFeatures: ["Centrally positioned subject suitable for framing"],
                    suggestedGridPosition: CGPoint(x: centerX, y: centerY)
                ))
            }
        }
        
        updateAnalysisResults(analyses)
    }
    
    private func processHorizonResults(_ observations: [VNHorizonObservation]) {
        guard let horizon = observations.first else { return }
        
        let angle = horizon.angle
        var analyses: [CompositionAnalysis] = []
        
        // If horizon is detected, suggest rule of thirds for landscape
        if abs(angle) < 0.1 { // Nearly horizontal horizon
            analyses.append(CompositionAnalysis(
                compositionType: .ruleOfThirds,
                confidence: 0.8,
                detectedFeatures: ["Horizontal horizon line detected"],
                suggestedGridPosition: nil
            ))
        }
        
        // Diagonal composition if horizon is tilted
        if abs(angle) > 0.2 {
            analyses.append(CompositionAnalysis(
                compositionType: .diagonal,
                confidence: 0.6,
                detectedFeatures: ["Tilted horizon suggests diagonal composition"],
                suggestedGridPosition: nil
            ))
        }
        
        updateAnalysisResults(analyses)
    }
    
    private func processEdgeResults(_ observations: [VNFeaturePrintObservation]) {
        // Process edge detection for leading lines and curves
        var analyses: [CompositionAnalysis] = []
        
        // This is a simplified analysis - in a real implementation,
        // you would analyze the feature print to detect line patterns
        analyses.append(CompositionAnalysis(
            compositionType: .leadingLines,
            confidence: 0.5,
            detectedFeatures: ["Linear features detected"],
            suggestedGridPosition: nil
        ))
        
        updateAnalysisResults(analyses)
    }
    
    private func processFaceResults(_ observations: [VNFaceObservation]) {
        guard !observations.isEmpty else { return }
        
        var analyses: [CompositionAnalysis] = []
        
        for face in observations {
            let boundingBox = face.boundingBox
            let centerX = boundingBox.midX
            let centerY = boundingBox.midY
            
            // Rule of thirds for portrait photography
            let ruleOfThirdsScore = calculateRuleOfThirdsScore(centerX: centerX, centerY: centerY)
            
            analyses.append(CompositionAnalysis(
                compositionType: .ruleOfThirds,
                confidence: ruleOfThirdsScore,
                detectedFeatures: ["Face detected - portrait composition"],
                suggestedGridPosition: CGPoint(x: centerX, y: centerY)
            ))
            
            // Golden spiral for single face portraits
            if observations.count == 1 {
                analyses.append(CompositionAnalysis(
                    compositionType: .goldenSpiral,
                    confidence: 0.7,
                    detectedFeatures: ["Single portrait subject"],
                    suggestedGridPosition: CGPoint(x: centerX, y: centerY)
                ))
            }
        }
        
        updateAnalysisResults(analyses)
    }
    
    private func processObjectResults(_ observations: [VNRecognizedObjectObservation]) {
        guard !observations.isEmpty else { return }
        
        var analyses: [CompositionAnalysis] = []
        
        // Analyze object arrangements for different compositions
        if observations.count == 1 {
            // Single object - suggest rule of thirds or golden spiral
            let object = observations.first!
            let centerX = object.boundingBox.midX
            let centerY = object.boundingBox.midY
            
            analyses.append(CompositionAnalysis(
                compositionType: .ruleOfThirds,
                confidence: 0.6,
                detectedFeatures: ["Single object composition"],
                suggestedGridPosition: CGPoint(x: centerX, y: centerY)
            ))
        } else if observations.count > 1 {
            // Multiple objects - analyze arrangement
            let sortedObjects = observations.sorted { $0.boundingBox.midX < $1.boundingBox.midX }
            
            // Check for L-shape arrangement
            if sortedObjects.count >= 2 {
                analyses.append(CompositionAnalysis(
                    compositionType: .lShape,
                    confidence: 0.5,
                    detectedFeatures: ["Multiple objects suggest L-shape composition"],
                    suggestedGridPosition: nil
                ))
            }
            
            // Check for S-curve potential
            if sortedObjects.count >= 3 {
                analyses.append(CompositionAnalysis(
                    compositionType: .sCurve,
                    confidence: 0.4,
                    detectedFeatures: ["Multiple objects suggest flowing arrangement"],
                    suggestedGridPosition: nil
                ))
            }
        }
        
        updateAnalysisResults(analyses)
    }
    
    // MARK: - Helper Functions
    
    private func calculateRuleOfThirdsScore(centerX: CGFloat, centerY: CGFloat) -> Float {
        let thirdLines = [1.0/3.0, 2.0/3.0]
        let tolerance: CGFloat = 0.1
        
        var score: Float = 0.0
        
        // Check proximity to vertical third lines
        for line in thirdLines {
            if abs(centerX - line) < tolerance {
                score += 0.5
            }
        }
        
        // Check proximity to horizontal third lines
        for line in thirdLines {
            if abs(centerY - line) < tolerance {
                score += 0.5
            }
        }
        
        return min(score, 1.0)
    }
    
    private func updateAnalysisResults(_ newAnalyses: [CompositionAnalysis]) {
        DispatchQueue.main.async {
            self.analysisResults.append(contentsOf: newAnalyses)
            
            // Keep only recent results
            if self.analysisResults.count > 20 {
                self.analysisResults = Array(self.analysisResults.suffix(20))
            }
            
            // Update recommended composition based on highest confidence
            if let bestAnalysis = self.analysisResults.max(by: { $0.confidence < $1.confidence }) {
                self.recommendedComposition = bestAnalysis.compositionType
                self.confidenceScore = bestAnalysis.confidence
            }
            
            self.isAnalyzing = false
        }
    }
    
    func resetAnalysis() {
        DispatchQueue.main.async {
            self.analysisResults.removeAll()
            self.recommendedComposition = .ruleOfThirds
            self.confidenceScore = 0.0
            self.isAnalyzing = false
        }
    }
}