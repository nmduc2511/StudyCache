//
//  AppDelegate.swift
//  StudyCache
//
//  Created by Nguyen Minh Duc on 12/12/2023.
//

import UIKit

enum CachingType {
case pinCache
case custom
}

var cachingType: CachingType = .custom

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }
}
