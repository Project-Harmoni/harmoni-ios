//
//  UIImage+Extension.swift
//  harmoni
//
//  Created by Kyle Stokes on 3/23/24.
//

import UIKit

// https://designcode.io/swiftui-advanced-handbook-compress-a-uiimage
extension UIImage {
    func aspectFitToHeight(_ newHeight: CGFloat = 200) -> UIImage {
        let scale = newHeight / self.size.height
        let newWidth = self.size.width * scale
        let newSize = CGSize(width: newWidth, height: newHeight)
        let renderer = UIGraphicsImageRenderer(size: newSize)

        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}
