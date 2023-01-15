//
//  MySceneManager.swift
//  Choosing an Anchor for a RealityKit Scene
//
//  Created by Brendan Innis on 2023-01-15.
//

import ARKit
import Foundation
import RealityKit

// MARK: - Types

protocol MySceneManagerDelegate: NSObjectProtocol {
    func didAttach(sceneAnchor: AnchorEntity)
    func didRemove(sceneAnchor: AnchorEntity)
}

// MARK: - MySceneManager class

class MySceneManager: NSObject {
    // MARK: Manager Configuration

    enum PlacementStrategy {
        case firstAvailable
        case manual
    }

    struct Options {
        static let `default` = Options(strategy: .manual)

        let strategy: PlacementStrategy
    }

    // MARK: Properties

    let options: Options
    var sceneAnchor: AnchorEntity?
    private var isLoading = false
    var sceneAttached: Bool {
        return isLoading || sceneAnchor != nil
    }

    weak var delegate: MySceneManagerDelegate?

    // MARK: Public methods

    init(options: Options = .default) {
        self.options = options
    }

    func attachScene(toAnchor anchor: ARAnchor) {
        isLoading = true
        Experience.loadBoxAsync(completion: { [weak self] result in
            guard let self else {
                return
            }
            switch result {
            case let .failure(error):
                fatalError("Could not load Experience: \(error)")
            case let .success(boxAnchor):
                let sceneAnchor = AnchorEntity(anchor: anchor)
                sceneAnchor.addChild(boxAnchor)
                self.sceneAnchor = sceneAnchor
                self.delegate?.didAttach(sceneAnchor: sceneAnchor)
            }
            self.isLoading = false
        })
    }

    // MARK: Private methods

    private func removeScene() {
        guard let sceneAnchor else {
            return
        }
        self.sceneAnchor = nil
        delegate?.didRemove(sceneAnchor: sceneAnchor)
    }
}

// MARK: - ARSessionDelegate

extension MySceneManager: ARSessionDelegate {
    func session(_: ARSession, didAdd anchors: [ARAnchor]) {
        guard options.strategy == .firstAvailable, !sceneAttached else {
            return
        }
        for anchor in anchors {
            guard let plane = anchor as? ARPlaneAnchor,
                  plane.alignment == .horizontal
            else {
                continue
            }
            attachScene(toAnchor: plane)
            break
        }
    }

    func session(_: ARSession, didRemove anchors: [ARAnchor]) {
        guard sceneAttached else {
            return
        }
        for anchor in anchors {
            if anchor.identifier == sceneAnchor?.anchorIdentifier {
                removeScene()
                break
            }
        }
    }
}
