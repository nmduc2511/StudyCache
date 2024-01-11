//
//  NSCacheManager.swift
//  StudyCache
//
//  Created by Nguyen Minh Duc on 15/12/2023.
//

import Foundation
import UIKit

final class NSCacheManager: NSObject {
    static let shared = NSCacheManager()
    private let cache = NSCache<NSString, AnyObject>()

    override init() {
        super.init()
        cache.totalCostLimit = 1024 * 1024 * 3 // 50 MB
        cache.evictsObjectsWithDiscardedContent = true
        cache.delegate = self
    }

    func clearAll() {
        cache.removeAllObjects()
    }

    func cacheObject(_ obj: AnyObject, key: String) {
        DispatchQueue.global(qos: .background).async { [weak self] in
            self?.cache.setObject(obj, forKey: key as NSString)
        }
    }

    func object(_ key: String) -> AnyObject? {
        let obj = cache.object(forKey: key as NSString)
        return obj
    }
}

extension NSCacheManager: NSCacheDelegate {
    func cache(_ cache: NSCache<AnyObject, AnyObject>, willEvictObject obj: Any) {
        print("aaaaaaaaaaaa")
    }
}
