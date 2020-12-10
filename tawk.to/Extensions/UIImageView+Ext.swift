//
//  UIImageView+Ext.swift
//  tawk.to
//
//  Created by Dominic Valencia on 12/3/20.
//  Copyright © 2020 Dominic Valencia. All rights reserved.
//

import UIKit

public extension UIImageView {
    func processLink(_ string: String?, _ isNotInverted: Bool = true, _ complete: (()->())? = nil) {
        if let string = string {
            guard let rest = REST.make(urlString: string) else {
                print("Bad URL")
                return
            }

            rest.get(withDeserializer: ImageDeserializer()) { result, httpResponse in
                do {
                    let img = try result.value()
                    DispatchQueue.main.async {
                        self.image = isNotInverted ? img : img.invertedImage()
                    }
                } catch {
                    print("Error performing GET: \(error)")
                }
            }
        } else {
            complete?()
        }
    }
}

extension UIImage {
    func invertedImage() -> UIImage? {
        guard let cgImage = self.cgImage else { return nil }
        let ciImage = CoreImage.CIImage(cgImage: cgImage)
        guard let filter = CIFilter(name: "CIColorInvert") else { return nil }
        filter.setDefaults()
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        let context = CIContext(options: nil)
        guard let outputImage = filter.outputImage else { return nil }
        guard let outputImageCopy = context.createCGImage(outputImage, from: outputImage.extent) else { return nil }
        return UIImage(cgImage: outputImageCopy, scale: self.scale, orientation: .up)
    }
}

