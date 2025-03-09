//
//  HistoryView.swift
//  ImageClassifierApp
//
//  Created by Prathamesh on 3/8/25.
//

import SwiftUI

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
