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
    
    private static var singleInstance: ApplicationManager = ApplicationManager()
    
    var window: UIWindow?
    
    var initialModule: ModuleInput!
    
    @IBOutlet weak var initialViewController: UIViewController! {
        didSet { configure() }
    }
    
    private override init() { super.init() }
    
    override func awakeAfter(using aDecoder: NSCoder) -> Any? {
        return ApplicationManager.singleInstance
    }
    
    func configure() {
        initialModule = try? SceneViewRouter.moduleInput(with: initialViewController)
    }
}


extension ApplicationManager: UIApplicationDelegate { }
