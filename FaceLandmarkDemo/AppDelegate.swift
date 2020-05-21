//
//  AppDelegate.swift
//  FaceLandmarkDemo
//
//  Created by nigel on 2020/4/27.
//  Copyright © 2020 tutorabc. All rights reserved.
//

import UIKit
import Toast_Swift


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        let manager = ToastManager.shared
        manager.position = .center
        return true
    }


}

