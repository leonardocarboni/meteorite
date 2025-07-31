import SwiftUI

struct MLRecommendationView: View {
    let recommendedComposition: CompositionType
    let confidence: Float
    let isAnalyzing: Bool
    let onApplyRecommendation: (CompositionType) -> Void
    
    private var confidencePercentage: Int {
        Int(confidence * 100)
    }
    
    private var confidenceColor: Color {
        switch confidence {
        case 0.8...1.0:
            return .green
        case 0.5..<0.8:
            return .yellow
        case 0.3..<0.5:
            return .orange
        default:
            return .red
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Header
            HStack(spacing: 6) {
                Image(systemName: "brain")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.green)
                
                Text("AI Suggestion")
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                
                if isAnalyzing {
                    ProgressView()
                        .scaleEffect(0.6)
                        .frame(width: 12, height: 12)
                }
            }
            
            // Recommendation Card
            if confidence > 0.3 {
                Button(action: {
                    onApplyRecommendation(recommendedComposition)
                }) {
                    HStack(spacing: 8) {
                        // Composition Icon
                        Image(systemName: recommendedComposition.icon)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white)
                            .frame(width: 16)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(recommendedComposition.displayName)
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                            
                            // Confidence Bar
                            HStack(spacing: 4) {
                                Text("\(confidencePercentage)%")
                                    .font(.caption2)
                                    .foregroundColor(confidenceColor)
                                
                                GeometryReader { geometry in
                                    ZStack(alignment: .leading) {
                                        Rectangle()
                                            .fill(Color.white.opacity(0.3))
                                            .frame(height: 2)
                                        
                                        Rectangle()
                                            .fill(confidenceColor)
                                            .frame(width: geometry.size.width * CGFloat(confidence), height: 2)
                                    }
                                }
                                .frame(height: 2)
                            }
                        }
                        
                        // Apply Button
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.blue)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(6)
                }
                .buttonStyle(PlainButtonStyle())
            } else {
                // Low confidence or no recommendation
                HStack(spacing: 8) {
                    Image(systemName: "eye")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    
                    Text("Analyzing scene...")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(Color.black.opacity(0.5))
                .cornerRadius(6)
            }
        }
        .frame(maxWidth: 200)
    }
}

#Preview {
    VStack(spacing: 20) {
        MLRecommendationView(
            recommendedComposition: .ruleOfThirds,
            confidence: 0.85,
            isAnalyzing: false,
            onApplyRecommendation: { _ in }
        )
        
        MLRecommendationView(
            recommendedComposition: .goldenSpiral,
            confidence: 0.45,
            isAnalyzing: true,
            onApplyRecommendation: { _ in }
        )
        
        MLRecommendationView(
            recommendedComposition: .diagonal,
            confidence: 0.15,
            isAnalyzing: false,
            onApplyRecommendation: { _ in }
        )
    }
    .padding()
    .background(Color.gray)
}