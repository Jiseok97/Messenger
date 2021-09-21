//
//  AppDelegate.swift
//  Messenger
//
//  Created by 이지석 on 2021/09/10.
//

import UIKit
import Firebase
import FBSDKCoreKit
import GoogleSignIn
import GoogleUtilities


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        // Firebase
        FirebaseApp.configure()
        
        ApplicationDelegate.shared.application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )
        
        // Google SignIn → FirebaseApp.configure() 선언 후 하기
        let clientID = FirebaseApp.app()?.options.clientID!
        let gSigninConfig = GIDConfiguration.init(clientID: clientID!)
        

        return true
    }
          
    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey : Any] = [:]
    ) -> Bool {

        ApplicationDelegate.shared.application(
            app,
            open: url,
            sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
            annotation: options[UIApplication.OpenURLOptionsKey.annotation]
        )
        
        return GIDSignIn.sharedInstance.handle(url)
    }
    
    
}
    
