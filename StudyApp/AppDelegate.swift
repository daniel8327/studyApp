//
//  AppDelegate.swift
//  StudyApp
//
//  Created by 장태현 on 2020/09/07.
//  Copyright © 2020 장태현. All rights reserved.
//

import UIKit
import KakaoSDKCommon
import KakaoSDKAuth
import KakaoSDKUser

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        //Thread.sleep(forTimeInterval: 3.0)
        
        KakaoSDKCommon.initSDK(appKey: "ba4ea422b238a8f4b64aab395b4ebde5")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0) {
            
            UIApplication.shared.keyWindow?.rootViewController = UIStoryboard(name: "Intro", bundle: nil).instantiateViewController(withIdentifier: "IntroNavigation")
        }
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if (AuthApi.isKakaoTalkLoginUrl(url)) {
            return AuthController.handleOpenUrl(url: url)
        }

        return false
    }
}
