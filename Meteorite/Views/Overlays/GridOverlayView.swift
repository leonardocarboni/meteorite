import SwiftUI

struct GridOverlayView: View {
    let compositionType: CompositionType
    let aspectRatio: CameraService.AspectRatio
    let opacity: Double
    
    init(compositionType: CompositionType, aspectRatio: CameraService.AspectRatio, opacity: Double = 0.7) {
        self.compositionType = compositionType
        self.aspectRatio = aspectRatio
        self.opacity = opacity
    }
    
    var body: some View {
        ZStack {
            switch compositionType {
            case .ruleOfThirds:
                RuleOfThirdsGrid(aspectRatio: aspectRatio)
            case .goldenSpiral:
                GoldenSpiralGrid(aspectRatio: aspectRatio)
            case .diagonal:
                DiagonalGrid(aspectRatio: aspectRatio)
            case .sCurve:
                SCurveGrid(aspectRatio: aspectRatio)
            case .lShape:
                LShapeGrid(aspectRatio: aspectRatio)
            case .leadingLines:
                LeadingLinesGrid(aspectRatio: aspectRatio)
            case .framing:
                FramingGrid(aspectRatio: aspectRatio)
            }
        }
        .opacity(opacity)
    }
}

// MARK: - Rule of Thirds Grid
struct RuleOfThirdsGrid: View {
    let aspectRatio: CameraService.AspectRatio
    
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            
            Path { path in
                // Vertical lines
                let verticalStep = width / 3
                path.move(to: CGPoint(x: verticalStep, y: 0))
                path.addLine(to: CGPoint(x: verticalStep, y: height))
                path.move(to: CGPoint(x: verticalStep * 2, y: 0))
                path.addLine(to: CGPoint(x: verticalStep * 2, y: height))
                
                // Horizontal lines
                let horizontalStep = height / 3
                path.move(to: CGPoint(x: 0, y: horizontalStep))
                path.addLine(to: CGPoint(x: width, y: horizontalStep))
                path.move(to: CGPoint(x: 0, y: horizontalStep * 2))
                path.addLine(to: CGPoint(x: width, y: horizontalStep * 2))
            }
            .stroke(Color.white, lineWidth: 1)
            
            // Intersection points for focal points
            ForEach(0..<4, id: \.self) { index in
                let x = (index % 2 == 0) ? width / 3 : (width / 3) * 2
                let y = (index < 2) ? height / 3 : (height / 3) * 2
                
                Circle()
                    .fill(Color.white)
                    .frame(width: 6, height: 6)
                    .position(x: x, y: y)
            }
        }
    }
}

// MARK: - Golden Spiral Grid
struct GoldenSpiralGrid: View {
    let aspectRatio: CameraService.AspectRatio
    
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            let goldenRatio: CGFloat = 1.618
            
            Path { path in
                // Create golden spiral rectangles
                let rect1Width = width / goldenRatio
                let rect1Height = height
                
                // Main rectangle division
                path.addRect(CGRect(x: 0, y: 0, width: rect1Width, height: rect1Height))
                path.addRect(CGRect(x: rect1Width, y: 0, width: width - rect1Width, height: rect1Height / goldenRatio))
                
                // Spiral curve (simplified)
                let centerX = rect1Width + (width - rect1Width) / 2
                let centerY = rect1Height / goldenRatio / 2
                let radius = min(width - rect1Width, rect1Height / goldenRatio) / 2
                
                path.addArc(center: CGPoint(x: centerX, y: centerY), 
                           radius: radius,
                           startAngle: .degrees(0),
                           endAngle: .degrees(90),
                           clockwise: false)
            }
            .stroke(Color.white, lineWidth: 1.5)
        }
    }
}

// MARK: - Diagonal Grid
struct DiagonalGrid: View {
    let aspectRatio: CameraService.AspectRatio
    
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            
            Path { path in
                // Main diagonals
                path.move(to: CGPoint(x: 0, y: 0))
                path.addLine(to: CGPoint(x: width, y: height))
                
                path.move(to: CGPoint(x: width, y: 0))
                path.addLine(to: CGPoint(x: 0, y: height))
                
                // Additional diagonal guides
                path.move(to: CGPoint(x: width / 2, y: 0))
                path.addLine(to: CGPoint(x: width, y: height / 2))
                
                path.move(to: CGPoint(x: 0, y: height / 2))
                path.addLine(to: CGPoint(x: width / 2, y: height))
            }
            .stroke(Color.white, lineWidth: 1)
        }
    }
}

// MARK: - S Curve Grid
struct SCurveGrid: View {
    let aspectRatio: CameraService.AspectRatio
    
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            
            Path { path in
                // Create S-curve guidelines
                path.move(to: CGPoint(x: 0, y: height * 0.8))
                path.addQuadCurve(to: CGPoint(x: width * 0.5, y: height * 0.5),
                                control: CGPoint(x: width * 0.2, y: height * 0.2))
                path.addQuadCurve(to: CGPoint(x: width, y: height * 0.2),
                                control: CGPoint(x: width * 0.8, y: height * 0.8))
                
                // Mirror S-curve
                path.move(to: CGPoint(x: 0, y: height * 0.2))
                path.addQuadCurve(to: CGPoint(x: width * 0.5, y: height * 0.5),
                                control: CGPoint(x: width * 0.2, y: height * 0.8))
                path.addQuadCurve(to: CGPoint(x: width, y: height * 0.8),
                                control: CGPoint(x: width * 0.8, y: height * 0.2))
            }
            .stroke(Color.white, lineWidth: 1.5)
        }
    }
}

// MARK: - L Shape Grid
struct LShapeGrid: View {
    let aspectRatio: CameraService.AspectRatio
    
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            
            Path { path in
                // L-shape guides (4 corners)
                let margin: CGFloat = width * 0.15
                
                // Top-left L
                path.move(to: CGPoint(x: margin, y: margin))
                path.addLine(to: CGPoint(x: margin, y: height * 0.4))
                path.addLine(to: CGPoint(x: width * 0.4, y: height * 0.4))
                
                // Top-right L
                path.move(to: CGPoint(x: width - margin, y: margin))
                path.addLine(to: CGPoint(x: width - margin, y: height * 0.4))
                path.addLine(to: CGPoint(x: width * 0.6, y: height * 0.4))
                
                // Bottom-left L
                path.move(to: CGPoint(x: margin, y: height - margin))
                path.addLine(to: CGPoint(x: margin, y: height * 0.6))
                path.addLine(to: CGPoint(x: width * 0.4, y: height * 0.6))
                
                // Bottom-right L
                path.move(to: CGPoint(x: width - margin, y: height - margin))
                path.addLine(to: CGPoint(x: width - margin, y: height * 0.6))
                path.addLine(to: CGPoint(x: width * 0.6, y: height * 0.6))
            }
            .stroke(Color.white, lineWidth: 1.5)
        }
    }
}

// MARK: - Leading Lines Grid
struct LeadingLinesGrid: View {
    let aspectRatio: CameraService.AspectRatio
    
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            let centerX = width / 2
            let centerY = height / 2
            
            Path { path in
                // Lines converging to center
                let points = [
                    CGPoint(x: 0, y: 0),
                    CGPoint(x: width, y: 0),
                    CGPoint(x: width, y: height),
                    CGPoint(x: 0, y: height),
                    CGPoint(x: width / 2, y: 0),
                    CGPoint(x: width / 2, y: height),
                    CGPoint(x: 0, y: height / 2),
                    CGPoint(x: width, y: height / 2)
                ]
                
                for point in points {
                    path.move(to: point)
                    path.addLine(to: CGPoint(x: centerX, y: centerY))
                }
            }
            .stroke(Color.white.opacity(0.4), lineWidth: 1)
            
            // Center focal point
            Circle()
                .fill(Color.white)
                .frame(width: 8, height: 8)
                .position(x: centerX, y: centerY)
        }
    }
}

// MARK: - Framing Grid
struct FramingGrid: View {
    let aspectRatio: CameraService.AspectRatio
    
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            let margin: CGFloat = width * 0.1
            
            Path { path in
                // Outer frame
                path.addRect(CGRect(x: margin, y: margin, 
                                  width: width - (margin * 2), 
                                  height: height - (margin * 2)))
                
                // Inner frame (golden ratio)
                let innerMargin = margin * 2
                path.addRect(CGRect(x: innerMargin, y: innerMargin,
                                  width: width - (innerMargin * 2),
                                  height: height - (innerMargin * 2)))
                
                // Corner brackets
                let bracketSize: CGFloat = 20
                let corners = [
                    CGPoint(x: margin, y: margin),
                    CGPoint(x: width - margin, y: margin),
                    CGPoint(x: width - margin, y: height - margin),
                    CGPoint(x: margin, y: height - margin)
                ]
                
                for corner in corners {
                    // Small bracket lines at each corner
                    path.move(to: CGPoint(x: corner.x - bracketSize/2, y: corner.y))
                    path.addLine(to: CGPoint(x: corner.x + bracketSize/2, y: corner.y))
                    path.move(to: CGPoint(x: corner.x, y: corner.y - bracketSize/2))
                    path.addLine(to: CGPoint(x: corner.x, y: corner.y + bracketSize/2))
                }
            }
            .stroke(Color.white, lineWidth: 1.5)
        }
    }
}

#Preview {
    VStack {
        GridOverlayView(compositionType: .ruleOfThirds, aspectRatio: .sixteenByNine)
            .frame(width: 300, height: 200)
            .background(Color.black)
        
        GridOverlayView(compositionType: .goldenSpiral, aspectRatio: .sixteenByNine)
            .frame(width: 300, height: 200)
            .background(Color.black)
    }
}