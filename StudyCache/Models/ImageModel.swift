//
//  ImageModel.swift
//  StudyCache
//
//  Created by Nguyen Minh Duc on 15/12/2023.
//

import Foundation
import UIKit

class ImageModel: NSObject {
    var id: String
    var author: String
    var width: CGFloat
    var height: CGFloat
    var url: String
    var image: UIImage?

    init(_ dict: [String: Any]) {
        id = dict["id"] as? String ?? ""
        author = dict["author"] as? String ?? ""
        url = dict["download_url"] as? String ?? ""
        width = dict["width"] as? CGFloat ?? 0
        height = dict["height"] as? CGFloat ?? 0
    }
}
