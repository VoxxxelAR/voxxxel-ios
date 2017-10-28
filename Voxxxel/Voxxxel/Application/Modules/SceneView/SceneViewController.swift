//
//  SceneViewController.swift
//  Voxxxel
//
//  Created by Vadym Sidorov on 10/24/17.
//  Copyright © 2017 Gleb Radchenko. All rights reserved.
//

import Foundation

import UIKit
import ARKit
import SceneKit
import ARVoxelKit

protocol SceneViewInput: class {
    var sceneView: ARSCNView! { get }
    var view: UIView! { get }
    var statusView: UIView? { get }
    var statusLabel: UILabel? { get }
}

protocol SceneViewOutput: class {
    func viewDidLoad()
    func viewDidAppear()
    func viewWillDisappear()
    
    func handleTap(gesture: UITapGestureRecognizer)
    func handlePinch(gesture: UIPinchGestureRecognizer)
    func handleRotation(gesture: UIRotationGestureRecognizer)
}

open class SceneViewController: UIViewController, View {
    typealias Presenter = SceneViewOutput
    
    static var storyboardName: String { return "SceneView" }
    
    weak var output: SceneViewOutput!
    
    @IBOutlet open var sceneView: ARSCNView!
    
    weak var statusView: UIView?
    weak var statusLabel: UILabel?

    
    override open func viewDidLoad() {
        super.viewDidLoad()
        output.viewDidLoad()
        
        addStatusLabel()
        setupGestures()
        
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        output.viewDidAppear()
    }
    
    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        output.viewWillDisappear()
    }
    
    func setupGestures() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(gesture:)))
        view.addGestureRecognizer(tap)
        
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(gesture:)))
        view.addGestureRecognizer(pinch)
        
        let rotation = UIRotationGestureRecognizer(target: self, action: #selector(handleRotation(gesture:)))
        view.addGestureRecognizer(rotation)
        
        pinch.delegate = self
        rotation.delegate = self
    }
    
    @objc func handleTap(gesture: UITapGestureRecognizer) {
        output.handleTap(gesture: gesture)
    }
    
    @objc func handlePinch(gesture: UIPinchGestureRecognizer) {
        output.handlePinch(gesture: gesture)
    }
    
    @objc func handleRotation(gesture: UIRotationGestureRecognizer) {
        output.handleRotation(gesture: gesture)
    }
}

extension SceneViewController: SceneViewInput {
    
}

//MARK: - UI Gesture Recognizer
extension SceneViewController: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

//MARK: - UI Setuping
extension SceneViewController {
    func addStatusLabel() {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        
        view.layer.cornerRadius = 5
        view.clipsToBounds = true
        
        view.translatesAutoresizingMaskIntoConstraints = false
        sceneView.addSubview(view)
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        label.font = UIFont(name: "HelveticeNeue", size: 15)
        label.numberOfLines = 0
        label.text = "Initializing AR session"
        
        view.contentView.addSubview(label)
        
        [view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 8),
         view.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 16),
         label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 4),
         label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -4),
         label.topAnchor.constraint(equalTo: view.topAnchor, constant: 4),
         label.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -4),
         label.widthAnchor.constraint(lessThanOrEqualToConstant: 200),
         label.heightAnchor.constraint(greaterThanOrEqualToConstant: 20)].forEach { $0.isActive = true }
        
        label.sizeToFit()
        
        statusLabel = label
        statusView = view
    }
}

