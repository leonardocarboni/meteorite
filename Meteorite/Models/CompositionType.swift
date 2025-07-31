import Foundation
import SwiftUI

enum CompositionType: String, CaseIterable, Identifiable {
    case ruleOfThirds = "rule_of_thirds"
    case goldenSpiral = "golden_spiral"
    case diagonal = "diagonal"
    case sCurve = "s_curve"
    case lShape = "l_shape"
    case leadingLines = "leading_lines"
    case framing = "framing"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .ruleOfThirds:
            return "Rule of Thirds"
        case .goldenSpiral:
            return "Golden Spiral"
        case .diagonal:
            return "Diagonal"
        case .sCurve:
            return "S Curve"
        case .lShape:
            return "L Shape"
        case .leadingLines:
            return "Leading Lines"
        case .framing:
            return "Framing"
        }
    }
    
    var description: String {
        switch self {
        case .ruleOfThirds:
            return "Divide the frame into thirds horizontally and vertically"
        case .goldenSpiral:
            return "Follows the golden ratio spiral for natural composition"
        case .diagonal:
            return "Uses diagonal lines to create dynamic composition"
        case .sCurve:
            return "Creates flowing S-shaped curves for elegant composition"
        case .lShape:
            return "Uses L-shaped elements for strong structural composition"
        case .leadingLines:
            return "Lines that guide the eye toward the subject"
        case .framing:
            return "Natural frames within the scene to focus attention"
        }
    }
    
    var icon: String {
        switch self {
        case .ruleOfThirds:
            return "grid"
        case .goldenSpiral:
            return "spiral"
        case .diagonal:
            return "diagonal.arrow"
        case .sCurve:
            return "scribble.variable"
        case .lShape:
            return "l.joystick"
        case .leadingLines:
            return "arrow.forward"
        case .framing:
            return "viewfinder"
        }
    }
}