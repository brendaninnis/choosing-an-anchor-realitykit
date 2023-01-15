//
//  ViewController.swift
//  Choosing an Anchor for Your RealityKit Scene
//
//  Created by Brendan Innis on 2023-01-15.
//

import UIKit


class ViewController: UIViewController {
    
    @IBOutlet var arView: MySceneView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
         
//        arView.debugOptions = [
//            .showAnchorOrigins,
//            .showAnchorGeometry
//        ]
        
        // Setup world tracking configuration with horizontal plane detection
        arView.configureViewSession()
       
        // Capture taps to place the scene
        let recognizer = UITapGestureRecognizer(target: self,
                                                action: #selector(self.viewTapped(_:)))
        arView.addGestureRecognizer(recognizer)
    }
    
    @objc private func viewTapped(_ recognizer: UITapGestureRecognizer) {
        guard !arView.manager.sceneAttached else {
            return
        }
        let point = recognizer.location(in: arView)
        guard let anchor = arView.raycast(from: point,
                                          allowing: .existingPlaneInfinite,
                                          alignment: .horizontal).first?.anchor else {
            return
        }
        arView.manager.attachScene(toAnchor: anchor)
    }
}
