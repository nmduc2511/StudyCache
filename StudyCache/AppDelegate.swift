//
//  AppDelegate.swift
//  StudyCache
//
//  Created by Nguyen Minh Duc on 12/12/2023.
//

import UIKit
import SDWebImage
import Kingfisher

enum CachingType {
case pinCache
case sdWebImage
case kingfisher
}

var cachingType: CachingType = .kingfisher

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        SDImageCache.shared.clearDisk {
            SDImageCache.shared.config.maxMemoryCost = 50 * 1024 * 1024
            SDImageCache.shared.config.maxDiskSize = 1000 * 1024 * 1024
        }

        ImageCache.default.clearDiskCache {
            ImageCache.default.memoryStorage.config.totalCostLimit = 50 * 1024 * 1024
            ImageCache.default.diskStorage.config.sizeLimit = 1000 * 1024 * 1024
        }
        return true
    }
}
