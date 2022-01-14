//
//  AppDelegate.swift
//  LazyFish
//
//  Created by zjj on 2021/9/29.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let root = UINavigationController(rootViewController: ViewController())
        let sp = UISplitViewController()
        sp.viewControllers = [root]
        sp.preferredPrimaryColumnWidthFraction = 0.45
        self.window?.rootViewController = sp
        self.window?.makeKeyAndVisible()
        return true
    }
}
