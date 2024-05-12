//
//  DetailsViewModel.swift
//  PopsaTest
//
//  Created by Dinesh Vijaykumar on 12/05/2024.
//

import SwiftUI

@MainActor
final class DetailsViewModel: ObservableObject {
    @Injected(\.photoService) var photoService: PhotoService
    private let assetID: String
    
    @Published var image: Image?
    
    init(assetID: String) {
        self.assetID = assetID
    }
    
    func loadImage(targetSize: CGSize) async {
        guard let uiImage = try? await photoService.fetchImage(id: assetID, targetSize: targetSize) else {
            image = nil
            return
        }
        image = Image(uiImage: uiImage)
    }
    
}
