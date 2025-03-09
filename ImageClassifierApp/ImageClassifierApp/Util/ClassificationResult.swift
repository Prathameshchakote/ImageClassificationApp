//
//  ClassificationResult.swift
//  ImageClassifierApp
//
//  Created by Prathamesh on 3/8/25.
//

import Foundation

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
