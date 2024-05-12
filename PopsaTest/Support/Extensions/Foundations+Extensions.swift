//
//  Foundations+Extensions.swift
//  PopsaTest
//
//  Created by Dinesh Vijaykumar on 12/05/2024.
//

import UIKit
import Vision

extension CGRect {
    ///Retrieve normalised CGRect based on UIImage
    func rectangle(in image: UIImage) -> CGRect {
        VNImageRectForNormalizedRect(self,
                                     Int(image.size.width),
                                     Int(image.size.height))
    }
}

extension CGPoint {
    ///Translating the coordinates from CoreImage coordinate space to UIKit coordinate space
    func translate(using height: CGFloat) -> CGPoint {
        let transform = CGAffineTransform(scaleX: 1, y: -1)
            .translatedBy(x: 0, y: -height);
        
        return self.applying(transform)
    }
}
