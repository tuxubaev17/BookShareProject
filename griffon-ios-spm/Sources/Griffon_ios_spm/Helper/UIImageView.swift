//
//  UIImageView.swift
//  OAuthSwift
//
//  Created by Farabi Bimbetov on 20.08.2020.
//  Copyright © 2020 Dongri Jin. All rights reserved.
//

import Foundation
import UIKit

extension UIImageView {
    public func downloaded(from url: URL, contentMode mode: UIView.ContentMode = .scaleAspectFit, completion: @escaping (UIImage) -> ()) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            completion(image)
            DispatchQueue.main.async() { [weak self] in
                self?.image = image
            }
        }.resume()
    }
    public func downloaded(from link: String, contentMode mode: UIView.ContentMode = .scaleAspectFit, completion: @escaping (UIImage) -> ()) {
        guard let url = URL(string: link) else { return }
        downloaded(from: url, contentMode: mode, completion: completion)
    }
}
