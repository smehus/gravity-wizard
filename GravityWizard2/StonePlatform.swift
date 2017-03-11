//
//  StonePlatform.swift
//  GravityWizard2
//
//  Created by scott mehus on 3/10/17.
//  Copyright © 2017 scott mehus. All rights reserved.
//

import Foundation
import SpriteKit

fileprivate struct Names {
    static let tile = "tile"
    static let container = "container"
    static let anchor = "StaticAnchor"
}

final class StonePlatform: SKNode {
    
    fileprivate var anchor: SKNode?
    
    fileprivate func setupAnchorBody() {
        guard let node = childNode(withName: Names.anchor) else {
            assertionFailure("Failed to find anchor")
            return
        }
        
        anchor = node
    }
    
    fileprivate func setupTileBodies() {
        enumerateChildNodes(withName: "//\(Names.tile)") { [weak self] node, _ in
            guard
                let sprite = node as? SKSpriteNode,
                let text = sprite.texture
            else {
                assertionFailure("Failed to cast tile as sprite node")
                return
            }
            
            let body = SKPhysicsBody(rectangleOf: text.size())
            
        }
    }
    
    fileprivate func setupContainerBody(with node: SKNode) {
        
    }
}

extension StonePlatform: LifecycleListener {
    func didMoveToScene() {
        setupAnchorBody()
        setupTileBodies()
    }
}
