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
    func analyzeSaliency(_ image: UIImage) -> CGRect?
}

final class VisionService: SaliencyService {
    func analyzeSaliency(_ image: UIImage) -> CGRect? {
        guard let ciImage = CIImage(image: image) else {
            print("Cant create ciimage")
            return nil
        }
        let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])
        
        let request: VNImageBasedRequest = VNGenerateAttentionBasedSaliencyImageRequest()
        request.revision = VNGenerateAttentionBasedSaliencyImageRequestRevision1
        
        do {
            try handler.perform([request])
            // Get the first observation (should be the only one for attention based)
            guard let observation = request.results?.first as? VNSaliencyImageObservation else {
                return nil
            }
            
            // Check for salient objects (should have one for attention-based)
            guard let salientObject = observation.salientObjects?.first else {
                return nil
            }
            
            return normaliseBoundingBox(box: salientObject, imageSize: image.size)
        } catch {
            print("Error analyzing saliency: \(error.localizedDescription)")
            return nil
        }
    }
    
    func normaliseBoundingBox(box:VNRectangleObservation, imageSize: CGSize)->CGRect
    {
        let bbBox = box.boundingBox
        let bottomToTopTransform = CGAffineTransform(scaleX: 1, y: -1).translatedBy(x: 0, y: -1)
        let rect = bbBox.applying(bottomToTopTransform)
        return VNImageRectForNormalizedRect(rect, Int(imageSize.width), Int(imageSize.height))
    }
}
