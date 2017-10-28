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

class SceneViewRouter: Router, SceneViewRouterInput {
    typealias ModuleView = SceneViewController
    
    static func moduleInput<T>() throws -> T {
        guard let view = UIStoryboard(name: ModuleView.storyboardName, bundle: nil).instantiateInitialViewController() else {
            throw RouterError.wrongView
        }
        
        return try SceneViewRouter.moduleInput(with: view)
    }
    
    static func moduleInput<T>(with view: UIViewController) throws -> T {
        guard let view = view as? ModuleView else {
            throw RouterError.wrongView
        }
        
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
