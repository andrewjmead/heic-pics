//
//  ImageConverter.swift
//  Heic Pics
//
//  Created by Andrew Mead on 11/26/24.
//

import CoreGraphics
import Foundation
import ImageIO
import SwiftUI
import UniformTypeIdentifiers

struct ImageConverter {
    private let imageURL: URL
    private let imageFormat: String

    init(_ imageURL: URL, imageFormat: String) {
        self.imageURL = imageURL
        self.imageFormat = imageFormat
    }

    func convert() -> Bool {
        let fileExtension: String = imageFormat == "jpeg" ? "jpg" : "png"
        let identifier: CFString = imageFormat == "jpeg" ? UTType.jpeg.identifier as CFString : UTType.png.identifier as CFString

        // Define the destination path for the JPEG file
        let newImageURL = imageURL.deletingPathExtension().appendingPathExtension(fileExtension)

        // Create a CGImageSource from the HEIC file
        guard let imageSource = CGImageSourceCreateWithURL(imageURL as CFURL, nil) else {
            print("Failed to create image source from HEIC file.")
            return false
        }

        // Read the image properties (metadata)
        guard let properties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) as? [CFString: Any],
              let orientation = properties[kCGImagePropertyOrientation] as? UInt32 else {
            print("Failed to read image properties or orientation.")
            return false
        }

        // Create a CGImage from the image source
        guard let cgImage = CGImageSourceCreateImageAtIndex(imageSource, 0, nil) else {
            print("Failed to create CGImage from HEIC file.")
            return false
        }

        // Apply orientation to the CGImage
        let adjustedImage = applyOrientation(to: cgImage, orientation: orientation)

        // Create a destination for the JPEG file
        guard let destination = CGImageDestinationCreateWithURL(newImageURL as CFURL, identifier, 1, nil) else {
            print("Failed to create destination for JPEG file.")
            return false
        }

        // Add the CGImage to the destination and finalize
        CGImageDestinationAddImage(destination, adjustedImage, nil)
        if !CGImageDestinationFinalize(destination) {
            print("Failed to finalize the JPEG file.")
            return false
        }

        print("Successfully converted HEIC to JPEG: \(newImageURL.path)")
        return true
    }

    private func applyOrientation(to image: CGImage, orientation: UInt32) -> CGImage {
        let ciImage = CIImage(cgImage: image)
        let transformedImage = ciImage.oriented(forExifOrientation: Int32(orientation))
        let context = CIContext(options: nil)
        return context.createCGImage(transformedImage, from: transformedImage.extent) ?? image
    }

    static func convert(_ imageURL: URL, imageFormat: String) -> Bool {
        let imageConverter = ImageConverter(imageURL, imageFormat: imageFormat)
        return imageConverter.convert()
    }
}
