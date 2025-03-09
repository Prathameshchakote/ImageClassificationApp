//
//  ContentView.swift
//  ImageClassifierApp
//
//  Created by Prathamesh on 3/8/25.
//
//

import SwiftUI

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
