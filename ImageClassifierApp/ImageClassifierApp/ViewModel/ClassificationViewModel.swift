//
//  ClassificationViewModel.swift
//  ImageClassifierApp
//
//  Created by Prathamesh on 3/8/25.
//

import Vision
import CoreML
import UIKit

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
