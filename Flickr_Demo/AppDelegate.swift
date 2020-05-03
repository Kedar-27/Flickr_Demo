//
//  AppDelegate.swift
//  Flickr_Demo
//
//  Created by Kedar Sukerkar on 03/05/20.
//  Copyright © 2020 Kedar-27. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    // MARK: - Properties
    var window: UIWindow?

    // MARK: AppDelegate Lifecycle
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        self.setupInitialVC()
        return true
    }

    // MARK: - Setup Initial VC
    func setupInitialVC(){
        let mainTabBarVC = FRMainTabBarController()
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = mainTabBarVC
        self.window?.makeKeyAndVisible()
    }

    

}

