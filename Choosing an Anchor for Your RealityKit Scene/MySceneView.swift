//
//  MySceneView.swift
//  Choosing an Anchor for Your RealityKit Scene
//
//  Created by Brendan Innis on 2023-01-15.
//

import UIKit
import ARKit
import RealityKit

class MySceneView: ARView {
    lazy var manager = {
        let manager = MySceneManager()
        manager.delegate = self
        return manager
    }()
    
    func configureViewSession() {
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal]
        session.run(config)
        session.delegate = manager
    }
}

// MARK: - MySceneManagerDelegate

extension MySceneView: MySceneManagerDelegate {
    func didAttach(sceneAnchor: AnchorEntity) {
        scene.anchors.append(sceneAnchor)
    }
    
    func didRemove(sceneAnchor: AnchorEntity) {
        scene.anchors.remove(sceneAnchor)
    }
}
