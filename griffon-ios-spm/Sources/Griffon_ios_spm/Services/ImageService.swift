//
//  ImageService.swift
//  griffon-sdk
//
//  Created by Farabi Bimbetov on 23.09.2020.
//  Copyright © 2020 Dar. All rights reserved.
//

import Foundation
import UIKit

public struct ImageService {
    
    public func write(fileName: String, image: UIImage) throws {
        do {
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let fileURL = documentsURL.appendingPathComponent("\(fileName).png")
            if let uiImage = image.pngData() {
                try uiImage.write(to: fileURL, options: .atomic)
            }
        } catch let error {
            print("Error in write image to fileManager: \(error.localizedDescription)")
        }
    }
    
    public func read(fileName: String) -> UIImage? {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let filePath = documentsURL.appendingPathComponent("\(fileName).png").path
        if FileManager.default.fileExists(atPath: filePath) {
            return UIImage(contentsOfFile: filePath)
        }
        return nil
    }
}
