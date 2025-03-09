# SwiftUI CoreML Image Classifier

A modern iOS application that demonstrates the integration of SwiftUI with CoreML for real-time image classification. This project serves as a practical example of implementing machine learning in iOS applications.

## Features

- Real-time image classification using CoreML
- Camera integration for capturing images
- Photo library access for selecting existing images
- Classification history with search functionality
- Clean, intuitive SwiftUI interface
- MVVM architecture pattern

## Requirements

- iOS 15.0+
- Xcode 13.0+
- Swift 5.5+

## Installation

1. Clone this repository
   ```bash
   https://github.com/Prathameshchakote/ImageClassificationApp
   ```

2. Open the project in Xcode
   ```bash
   cd SwiftUI-CoreML-ImageClassifier
   open ImageClassifier.xcodeproj
   ```

3. Download a CoreML model (if not included)
   - This project uses MobileNetV2 for image classification
   - Place the .mlmodel file in the project directory
   - Add the model to the Xcode project

4. Build and run the application on a device or simulator

## Project Structure

- **ContentView.swift**: Main interface showing image and classification results
- **ClassificationViewModel.swift**: Handles the CoreML integration and business logic
- **ImagePicker.swift**: UIViewControllerRepresentable for camera and photo library access
- **HistoryView.swift**: Display of past classifications with search functionality

## How It Works

1. The app allows users to take a picture using the device camera or select an image from the photo library
2. The selected image is processed through a pre-trained CoreML model (MobileNetV2)
3. The app displays the top classification results with confidence scores
4. Each classification is saved to a history list for future reference
5. Users can search through past classifications by object name

## Privacy Permissions

This app requires the following permissions which are defined in the Info.plist file:
- Camera access (`NSCameraUsageDescription`)
- Photo Library access (`NSPhotoLibraryUsageDescription`)

## Future Enhancements

- Support for custom model training with CreateML
- Export functionality for classification results
- Offline storage using CoreData
- Multiple model comparison
- Image annotation capabilities

## License

[Specify your license here - e.g., MIT, Apache 2.0, etc.]

## Acknowledgments

- Apple for SwiftUI and CoreML frameworks
- MobileNetV2 model creators
