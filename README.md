# Meteorite

An iPhone app for photographers that uses machine learning to suggest optimal composition grids based on real-time scene analysis.

## Features

- **ML-Powered Composition Analysis**: Real-time scene analysis using Core ML and Vision frameworks
- **Multiple Grid Types**: Support for rule of thirds, golden spiral, diagonal, S curve, L shape, leading lines, and framing
- **Aspect Ratio Control**: Constrained shooting in 16:9 or 9:16 formats
- **Real-time Suggestions**: Live grid overlays based on composition analysis
- **Native iOS**: Built with SwiftUI for optimal performance

## Requirements

- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+

## Development

This project uses SwiftUI with MVVM architecture pattern and integrates AVFoundation for camera functionality.

## Architecture

- **SwiftUI**: Modern, reactive user interface
- **MVVM**: Model-View-ViewModel architecture pattern
- **Core ML**: On-device machine learning for composition analysis
- **Vision**: Image analysis framework
- **AVFoundation**: Camera controls and capture functionality

## License

MIT License