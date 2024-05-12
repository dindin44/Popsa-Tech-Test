//
//  UIImage+Extensions.swift
//  PopsaTest
//
//  Created by Dinesh Vijaykumar on 12/05/2024.
//

import UIKit

extension UIImage {
    /// Draw rectangles onto UIImage
    func draw(rectangles: [CGRect],
              strokeColor: UIColor = .red,
              lineWidth: CGFloat = 2) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            draw(in: CGRect(origin: .zero, size: size))
                        
            context.cgContext.setStrokeColor(strokeColor.cgColor)
            context.cgContext.setLineWidth(lineWidth)
            rectangles.forEach { context.cgContext.addRect($0) }
            context.cgContext.drawPath(using: .stroke)
        }
    }
}
