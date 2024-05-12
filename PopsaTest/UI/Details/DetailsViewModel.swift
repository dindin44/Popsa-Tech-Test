//
//  DetailsViewModel.swift
//  PopsaTest
//
//  Created by Dinesh Vijaykumar on 12/05/2024.
//

import SwiftUI
import Vision

@MainActor
final class DetailsViewModel: ObservableObject {
    @Injected(\.photoService) var photoService: PhotoService
    @Injected(\.saliencyService) var saliencyService: SaliencyService
    private let assetID: String
    
    @Published var image: Image?
    @Published var salientRect: CGRect?
    
    init(assetID: String) {
        self.assetID = assetID
    }
    
    func loadImage(targetSize: CGSize) async {
        guard let uiImage = try? await photoService.fetchImage(id: assetID, targetSize: targetSize) else {
            image = nil
            return
        }

        let img = await saliencyService.process(uiImage)
        image = Image(uiImage: img)
    }
}
