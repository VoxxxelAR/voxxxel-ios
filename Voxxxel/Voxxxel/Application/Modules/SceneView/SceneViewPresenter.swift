//
//  SceneViewPresenter.swift
//  Voxxxel
//
//  Created by Vadym Sidorov on 10/24/17.
//  Copyright © 2017 Gleb Radchenko. All rights reserved.
//

import Foundation
import ARVoxelKit
import ARKit

class SceneViewPresenter: NSObject, Presenter {
    typealias View = SceneViewInput
    typealias Router = SceneViewRouterInput
    typealias Interactor = SceneViewInteractor
    
    var view: View!
    var interactor: Interactor!
    var router: Router!
    
    var focusedNode: VKDisplayable?
    var focusedFace: VKVoxelFace?
    var cursorVoxel: VKVoxelNode?
    
    let pinchScalingFactor: CGFloat = 0.1
    let minPlatformScale = SCNVector3(0.4, 0.4, 0.4)
    let maxPlatformScale = SCNVector3(6.0, 6.0, 6.0)
    
    let rotationFactor: CGFloat = 1.0
    
    var lastPlatformScale = SCNVector3(1, 1, 1)
    var lastPlatformEulerAngles = SCNVector3(0, 0, 0)
    
    var sceneManager: VKSceneManager!
}

extension SceneViewPresenter: SceneViewOutput {

    func viewDidLoad() {
        sceneManager = VKSceneManager(with: view.sceneView)
        sceneManager.delegate = self
    }
    
    func viewDidAppear() {
        sceneManager?.launchSession()
    }
    
    func viewWillDisappear() {
        sceneManager?.pauseSession()
    }
    
    func handleTap(gesture: UITapGestureRecognizer) {
        guard let sceneManager = sceneManager else { return }
        guard let focusedNode = focusedNode else { return }
        
        if let surface = focusedNode as? VKPlatformNode {
            sceneManager.setSelected(surface: surface)
            surface.apply(.transparency(value: 0), animated: true)
            return
        }
        
        guard let uiView = view.view else {
            print("SceneViewController's view was not created")
            return
        }
        
        if gesture.location(in: uiView).x < uiView.bounds.midX {
            removeVoxel()
        } else {
            addVoxel()
        }
    }
    
    func handlePinch(gesture: UIPinchGestureRecognizer) {
        guard let platformScale = sceneManager.focusContainer.selectedSurface?.scale else {
            print("Trying to perform pinch when platform not selected.")
            return
        }
        
        let gestureScale = Float(gesture.scale * ((gesture.scale - 1.0) * pinchScalingFactor + 1.0))
        var newPlatformScale = lastPlatformScale * gestureScale
        
        newPlatformScale = max(newPlatformScale, minPlatformScale)
        newPlatformScale = min(newPlatformScale, maxPlatformScale)
        
        switch gesture.state {
        case .began:
            lastPlatformScale = platformScale
        case .changed:
            sceneManager.focusContainer.selectedSurface?.scale = newPlatformScale
        default:
            lastPlatformScale = newPlatformScale
        }
    }
    
    func handleRotation(gesture: UIRotationGestureRecognizer) {
        guard let platformEulerAngles = sceneManager.focusContainer.selectedSurface?.eulerAngles else {
            print("Trying to perform rotation when platform not selected.")
            return
        }
        
        let gestureRotation = Float(gesture.rotation * rotationFactor)
        var newPlatformEulerAngles = lastPlatformEulerAngles
        newPlatformEulerAngles.y -= gestureRotation
        
        switch gesture.state {
        case .began:
            lastPlatformEulerAngles = platformEulerAngles
        case .changed:
            sceneManager.focusContainer.selectedSurface?.eulerAngles = newPlatformEulerAngles
        default:
            lastPlatformEulerAngles = newPlatformEulerAngles
        }
    }
    
    func addVoxel() {
        guard let voxel = cursorVoxel else { return }
        
        cursorVoxel = nil
        voxel.apply([.color(content: VKConstants.defaultFaceColor), .transparency(value: 1)], animated: true)
        voxel.isInstalled = true
    }
    
    func removeVoxel() {
        guard let focusedVoxel = focusedNode as? VKVoxelNode else { return }
        focusedNode = nil
        
        focusedVoxel.apply(.transparency(value: 0), animated: true) {
            self.sceneManager.remove(focusedVoxel)
        }
        
        removeCursorVoxel()
    }
    
    func removeCursorVoxel() {
        guard let currentCursor = cursorVoxel else { return }
        cursorVoxel = nil
        
        currentCursor.removeFromParentNode()
    }
    
}

extension SceneViewPresenter: VKSceneManagerDelegate {
    public func vkSceneManager(_ manager: VKSceneManager, didFocus node: VKDisplayable, face: VKVoxelFace) {
        
        focusedNode = node
        focusedFace = face
        
        if let surface = node as? VKPlatformNode {
            surface.apply(.transparency(value: 1), animated: true)
        } else if let tile = node as? VKTileNode {
            let prototype = VKVoxelNode(color: .white)
            prototype.isInstalled = false
            
            prototype.apply(.transparency(value: 0.4), animated: false)
            manager.add(new: prototype, to: tile)
            
            cursorVoxel = prototype
        } else if let voxel = node as? VKVoxelNode {
            let propotype = VKVoxelNode(color: .white)
            propotype.isInstalled = false
            
            propotype.apply(.transparency(value: 0.4), animated: false)
            manager.add(new: propotype, to: voxel, face: face)
            
            cursorVoxel = propotype
        }
    }
    
    public func vkSceneManager(_ manager: VKSceneManager, didDefocus node: VKDisplayable?) {
        focusedNode = nil
        focusedFace = nil
        
        if let surface = node as? VKPlatformNode {
            surface.apply(.transparency(value: 0.5), animated: true, completion: nil)
        }
        
        removeCursorVoxel()
    }
    
    public func vkSceneManager(_ manager: VKSceneManager, didUpdateState state: VKARSessionState) {
        view.statusLabel?.text = state.hint
        view.statusView?.isHidden = state.hint.isEmpty
    }
    
    public func vkSceneManager(_ manager: VKSceneManager, countOfVoxelsIn scene: ARSCNView) -> Int {
        return 0
    }
    
    public func vkSceneManager(_ manager: VKSceneManager, voxelFor index: Int) -> VKVoxelNode {
        return VKVoxelNode()
    }
}

extension SceneViewPresenter: SceneViewInteractorOutput {
}
