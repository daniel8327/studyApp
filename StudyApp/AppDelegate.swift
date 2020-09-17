//
//  AppDelegate.swift
//  StudyApp
//
//  Created by 장태현 on 2020/09/07.
//  Copyright © 2020 장태현. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        //Thread.sleep(forTimeInterval: 3.0)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0) {
            
            UIApplication.shared.keyWindow?.rootViewController = UIStoryboard(name: "Intro", bundle: nil).instantiateViewController(withIdentifier: "IntroNavigation")
        }
        return true
    }
}
