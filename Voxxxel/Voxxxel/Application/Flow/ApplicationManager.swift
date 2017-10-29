//
//  ApplicationManager.swift
//  Voxxxel
//
//  Created by Gleb Radchenko on 10/15/17.
//  Copyright © 2017 Gleb Radchenko. All rights reserved.
//

import Foundation
import UIKit

@UIApplicationMain
class ApplicationManager: NSObject {
    
    var window: UIWindow?
    var initialModule: ModuleInput!
}


extension ApplicationManager: UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        guard let rootViewController = window?.rootViewController else { return false }
        initialModule = try? SceneViewRouter.moduleInput(with: rootViewController)
        return true
    }
}
