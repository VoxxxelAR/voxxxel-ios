//
//  SceneViewInteractor.swift
//  Voxxxel
//
//  Created by Vadym Sidorov on 10/24/17.
//  Copyright © 2017 Gleb Radchenko. All rights reserved.
//

import Foundation

protocol SceneViewInteractorInput: class {
}

protocol SceneViewInteractorOutput: class {
}

class SceneViewInteractor: Interactor, SceneViewInteractorInput {
    typealias Presenter = SceneViewPresenter
    
    weak var output: Presenter!
}
