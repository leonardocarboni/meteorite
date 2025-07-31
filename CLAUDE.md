# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Meteorite is an iPhone app for photographers that uses machine learning to suggest optimal composition grids based on real-time scene analysis. The app constrains shooting to 16:9 or 9:16 aspect ratios and provides intelligent grid overlays including rule of thirds, golden spiral, diagonal, S curve, L shape, leading lines, and framing.

## Technology Stack

- **Language**: Swift 5.9+
- **Framework**: SwiftUI (iOS 17.0+)
- **Architecture**: MVVM (Model-View-ViewModel)
- **ML Frameworks**: Core ML and Vision for on-device composition analysis
- **Camera**: AVFoundation for camera controls and capture
- **Development**: Xcode 15.0+

## Project Structure

```
Meteorite/
├── Meteorite.xcodeproj/          # Xcode project file
├── Meteorite/                    # Main app source code
│   ├── MeteoriteApp.swift        # App entry point
│   ├── ContentView.swift         # Main content view
│   ├── Views/                    # SwiftUI views
│   ├── ViewModels/               # MVVM view models
│   ├── Models/                   # Data models
│   ├── Services/                 # Business logic and services
│   ├── Utilities/                # Helper utilities
│   ├── Resources/                # Images, sounds, etc.
│   └── Assets.xcassets/          # Asset catalog
└── README.md                     # Project documentation
```

## Key Features to Implement

1. **Camera Integration**: Real-time camera preview using AVFoundation
2. **Aspect Ratio Control**: Lock camera to 16:9 or 9:16 formats only
3. **ML Composition Analysis**: Use Core ML/Vision for scene analysis
4. **Grid Overlay System**: Dynamic grid overlays based on ML analysis
5. **Composition Types**: Rule of thirds, golden spiral, diagonal, S curve, L shape, leading lines, framing

## Development Guidelines

### Architecture Patterns
- Use MVVM architecture with SwiftUI
- Keep ViewModels separate from Views for testability
- Use Combine for reactive programming where appropriate
- Implement proper separation of concerns

### Camera Implementation
- Use AVFoundation's AVCaptureSession for camera control
- Implement custom camera controls rather than using system camera
- Handle camera permissions properly with Info.plist configuration
- Support both portrait and landscape orientations for different aspect ratios

### ML Integration
- Use Core ML for on-device processing (no cloud dependencies)
- Implement Vision framework for image analysis
- Create custom ML models for composition analysis if needed
- Process frames in real-time without blocking UI

### Code Organization
- Place camera-related code in `Services/CameraService.swift`
- ML analysis logic goes in `Services/CompositionAnalysisService.swift`
- Grid overlay views in `Views/Overlays/`
- Keep models lightweight and focused

## Common Development Commands

Since this is an iOS project, development is primarily done through Xcode:

```bash
# Open project in Xcode
open Meteorite.xcodeproj

# Build project (command line)
xcodebuild -project Meteorite.xcodeproj -scheme Meteorite build

# Run tests (when implemented)
xcodebuild test -project Meteorite.xcodeproj -scheme Meteorite -destination 'platform=iOS Simulator,name=iPhone 15'
```

## Important Considerations

### Privacy & Permissions
- Camera usage description is configured in project settings
- No data collection or analytics - purely on-device processing
- Respect user privacy with all camera operations

### Performance
- Real-time ML processing must not impact camera performance
- Use background queues for ML analysis
- Optimize grid rendering for smooth 60fps camera preview
- Memory management is critical for camera apps

### User Experience
- Instant feedback with grid suggestions
- Smooth transitions between different grid types
- Clear visual indicators for optimal composition
- Minimal UI that doesn't distract from photography

## Git Workflow

- Use GitHub for all development
- Commit frequently with descriptive messages
- Use feature branches for major implementations
- All commits should include the Claude Code signature

## Testing Strategy

- Unit tests for ML analysis algorithms
- UI tests for camera functionality
- Test on real devices for camera performance
- Validate ML model accuracy with various scene types

## Future Considerations

- Support for additional composition rules
- Custom ML model training for improved accuracy
- Export functionality for analyzed compositions
- Integration with photo library for composition analysis of existing images