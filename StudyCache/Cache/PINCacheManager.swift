//
//  PINCacheManager.swift
//  StudyCache
//
//  Created by Nguyen Minh Duc on 21/12/2023.
//

import Foundation
import PINCache

class PINCacheManager: NSObject {
    static let shared = PINCacheManager()
    private var cache = PINCache(name: "OMG")

    override init() {
        super.init()
        cache.memoryCache.ageLimit = 60 * 60 * 24 // 1 day
        cache.memoryCache.costLimit = 5 * 1024 * 1024 // 5MB
    }

    func setData(_ data: Any?, forKey key: String) {
        guard let data = data as? Data else { return }
        cache.memoryCache.setObjectAsync(data, forKey: key, withCost: UInt(data.count))
    }

    func object(forKey key: String) -> Any? {
        return cache.object(forKey: key)
    }

    func removeAllObjects() {
        cache.memoryCache.removeExpiredObjects()
    }
}
