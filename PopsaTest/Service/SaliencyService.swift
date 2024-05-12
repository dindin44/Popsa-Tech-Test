//
//  SaliencyService.swift
//  PopsaTest
//
//  Created by Dinesh Vijaykumar on 12/05/2024.
//

import Foundation
import Vision
import UIKit

protocol SaliencyService {
    func process(_ image: UIImage) async -> UIImage
}

final class VisionService: SaliencyService {
    func process(_ image: UIImage) async -> UIImage {
        guard let cgImage = image.cgImage else { return image }
        let request = VNGenerateAttentionBasedSaliencyImageRequest()
        
        let hander = VNImageRequestHandler(cgImage: cgImage, orientation: .up)
        
        return await withCheckedContinuation { continuation in
            do {
                try hander.perform([request])
            } catch {
                print("Can't make the request due to \(error)")
                continuation.resume(returning: image)
                return
            }
            
            // Get the first observation (should be the only one for attention based)
            guard let observation = request.results else {
                print("Can't find observations")
                continuation.resume(returning: image)
                return
            }
            
            let rectangles = observation
                            .flatMap { $0.salientObjects?.map { $0.boundingBox.rectangle(in: image) } ?? [] }
                            .map { CGRect(origin: $0.origin.translate(using: image.size.height - $0.size.height),
                                          size: $0.size) }

            let newImage = image.draw(rectangles: rectangles)
            continuation.resume(returning: newImage ?? image)
        }
    }
}
