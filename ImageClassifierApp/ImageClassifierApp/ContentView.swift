//
//  ContentView.swift
//  ImageClassifierApp
//
//  Created by Prathamesh on 3/8/25.
//
//
import SwiftUI
//
//struct ContentView: View {
//    var body: some View {
//        VStack {
//            Image(systemName: "globe")
//                .imageScale(.large)
//                .foregroundStyle(.tint)
//            Text("Hello, world!")
//        }
//        .padding()
//    }
//}
//
//#Preview {
//    ContentView()
//}

// MARK: - Content View
struct ContentView: View {
    @StateObject private var viewModel = ClassificationViewModel()
    @State private var showImagePicker = false
    @State private var showCamera = false
    @State private var inputImage: UIImage?
    @State private var showResultsHistory = false
    
    var body: some View {
        NavigationView {
            VStack {
                if let image = viewModel.selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .padding()
                        .cornerRadius(10)
                        .shadow(radius: 5)
                } else {
                    Image(systemName: "photo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                        .foregroundColor(.gray)
                        .padding()
                }
                
                if viewModel.isClassifying {
                    ProgressView("Classifying...")
                        .padding()
                } else if let result = viewModel.classificationResult {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Classification Results:")
                            .font(.headline)
                        
                        ForEach(result.classifications.prefix(3), id: \.self) { classification in
                            HStack {
                                Text(classification.identifier)
                                    .font(.body)
                                Spacer()
                                Text("\(Int(classification.confidence * 100))%")
                                    .font(.body)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    .padding()
                }
                
                HStack(spacing: 20) {
                    Button(action: {
                        showImagePicker = true
                    }) {
                        VStack {
                            Image(systemName: "photo.on.rectangle")
                                .font(.largeTitle)
                            Text("Gallery")
                                .font(.caption)
                        }
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(10)
                    }
                    
                    Button(action: {
                        showCamera = true
                    }) {
                        VStack {
                            Image(systemName: "camera")
                                .font(.largeTitle)
                            Text("Camera")
                                .font(.caption)
                        }
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(10)
                    }
                }
                .padding()
            }
            .navigationTitle("Image Classifier")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showResultsHistory = true
                    }) {
                        Image(systemName: "clock.arrow.circlepath")
                    }
                }
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(image: $inputImage, sourceType: .photoLibrary)
            }
            .sheet(isPresented: $showCamera) {
                ImagePicker(image: $inputImage, sourceType: .camera)
            }
            .sheet(isPresented: $showResultsHistory) {
                HistoryView(history: viewModel.history)
            }
            .onChange(of: inputImage) { newImage in
                if let image = newImage {
                    viewModel.selectedImage = image
                    viewModel.classifyImage(image)
                }
            }
        }
    }
}

// MARK: - Image Picker

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    let sourceType: UIImagePickerController.SourceType
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = sourceType
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            picker.dismiss(animated: true)
        }
    }
}

// MARK: - Classification Result
struct ClassificationResult: Identifiable, Codable {
    let id = UUID()
    let classifications: [Classification]
    let date: Date
    let imageName: String
    
    struct Classification: Hashable, Codable {
        let identifier: String
        let confidence: Float
    }
}

// MARK: - History View
struct HistoryView: View {
    let history: [ClassificationResult]
    @State private var searchText = ""
    
    var filteredHistory: [ClassificationResult] {
        if searchText.isEmpty {
            return history
        } else {
            return history.filter { result in
                result.classifications.contains { classification in
                    classification.identifier.lowercased().contains(searchText.lowercased())
                }
            }
        }
    }
    
    var body: some View {
        NavigationView {
            List(filteredHistory) { result in
                VStack(alignment: .leading) {
                    Text(result.imageName)
                        .font(.headline)
                    Text(result.date, style: .date)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    ForEach(result.classifications.prefix(2), id: \.identifier) { classification in
                        HStack {
                            Text(classification.identifier)
                            Spacer()
                            Text("\(Int(classification.confidence * 100))%")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.vertical, 5)
            }
            .navigationTitle("Classification History")
            .searchable(text: $searchText, prompt: "Search objects")
        }
    }
}

import Vision
import CoreML


// MARK: - View Model
class ClassificationViewModel: ObservableObject {
    @Published var selectedImage: UIImage?
    @Published var classificationResult: ClassificationResult?
    @Published var isClassifying = false
    @Published var history: [ClassificationResult] = []
    
    private var classificationRequest: VNCoreMLRequest?
    
    init() {
        setupClassifier()
    }
    
    private func setupClassifier() {
        // Load the ML model
        guard let modelURL = Bundle.main.url(forResource: "MobileNetV2", withExtension: "mlmodelc") else {
            print("Failed to find model file.")
            return
        }
        
        do {
            let model = try VNCoreMLModel(for: MLModel(contentsOf: modelURL))
            classificationRequest = VNCoreMLRequest(model: model) { [weak self] request, error in
                guard let self = self else { return }
                self.processClassifications(request: request, error: error)
            }
            classificationRequest?.imageCropAndScaleOption = .centerCrop
        } catch {
            print("Failed to load model: \(error)")
        }
    }
    
    func classifyImage(_ image: UIImage) {
        guard let classificationRequest = classificationRequest else { return }
        
        self.selectedImage = image
        self.isClassifying = true
        
        guard let ciImage = CIImage(image: image) else {
            print("Failed to create CIImage from UIImage.")
            self.isClassifying = false
            return
        }
        
        let handler = VNImageRequestHandler(ciImage: ciImage)
        
        do {
            try handler.perform([classificationRequest])
        } catch {
            print("Failed to perform classification: \(error)")
            self.isClassifying = false
        }
    }
    
    private func processClassifications(request: VNRequest, error: Error?) {
        DispatchQueue.main.async {
            self.isClassifying = false
            
            if let error = error {
                print("Classification error: \(error)")
                return
            }
            
            guard let results = request.results as? [VNClassificationObservation] else {
                print("Unexpected result type from VNCoreMLRequest")
                return
            }
            
            let classifications = results.prefix(5).map { ClassificationResult.Classification(identifier: $0.identifier, confidence: $0.confidence) }
            
            let result = ClassificationResult(
                classifications: classifications,
                date: Date(),
                imageName: "Image \(self.history.count + 1)"
            )
            
            self.classificationResult = result
            self.history.append(result)
        }
    }
}
