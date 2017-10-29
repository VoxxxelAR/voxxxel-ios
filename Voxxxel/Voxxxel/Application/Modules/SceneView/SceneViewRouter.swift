//
//  SceneViewRouter.swift
//  Voxxxel
//
//  Created by Vadym Sidorov on 10/24/17.
//  Copyright © 2017 Gleb Radchenko. All rights reserved.
//

import UIKit

protocol SceneViewRouterInput: class {
}

//TODO: - Move to extension
extension UIStoryboard {
    static func specificView<T: View>() throws -> T {
        guard let view = UIStoryboard(name: T.storyboardName, bundle: nil).instantiateInitialViewController() as? T else {
            //TODO: - Creatae storyboard error
            fatalError()
        }
        
        return view
    }
}

class SceneViewRouter: Router, SceneViewRouterInput {
    typealias ModuleView = SceneViewController
    
    static func moduleInput<T>() throws -> T {
        let view: ModuleView = try UIStoryboard.specificView()
        return try SceneViewRouter.moduleInput(with: view)
    }
    
    static func moduleInput<T>(with view: UIViewController) throws -> T {
        let view: ModuleView = try view.specific()
        let presenter = SceneViewPresenter()
        let interactor = SceneViewInteractor()
        let router = SceneViewRouter()
        
        view.output = presenter
        
        presenter.view = view
        presenter.interactor = interactor
        presenter.router = router
        
        interactor.output = presenter
        
        return try presenter.specific()
    }
}

