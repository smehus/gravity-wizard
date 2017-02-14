//
//  Wall.swift
//  GravityWizard2
//
//  Created by scott mehus on 2/11/17.
//  Copyright © 2017 scott mehus. All rights reserved.
//

import Foundation
import SpriteKit

fileprivate struct Names {
    static let flatWall = "flat-wall"
    static let baseWall = "base-wall"
    static let complexWall = "complex-wall"
}

fileprivate struct Physics {
    static let defaultCategory = PhysicsCategory.Ground
    static let levelComplete = PhysicsCategory.LevelComplete
    static let collision = PhysicsCategory.Arrow | PhysicsCategory.Blood | PhysicsCategory.Rock | PhysicsCategory.Hero
}

final class MossyWall: SKSpriteNode {
    
    fileprivate func setupNodes() {
        
        enumerateChildNodes(withName: Names.flatWall) { [weak self] node, stop in
            guard let strongSelf = self else { return }
            guard let wall = node as? SKSpriteNode else { return }
            strongSelf.addPhysics(forFlatWall: wall)
        }

        enumerateChildNodes(withName: Names.baseWall) { [weak self] node, stop in
            guard let strongSelf = self else { return }
            guard let node = node as? SKSpriteNode else { return }
            strongSelf.addPhysics(forComplexWall: node)
        }
        
        enumerateChildNodes(withName: Names.complexWall) { [weak self] node, stop in
            guard let strongSelf = self else { return }
            guard let node = node as? SKSpriteNode else { return }
            strongSelf.addPhysics(forComplexWall: node)
        }
    }
    
    fileprivate func addPhysics(forComplexWall node: SKSpriteNode) {
        guard let text = node.texture else { return }
        let body = SKPhysicsBody(texture: text, size: text.size())
        body.categoryBitMask = Physics.defaultCategory
        body.collisionBitMask = Physics.collision
        body.contactTestBitMask = PhysicsCategory.Hero
        body.isDynamic = false
        node.lightingBitMask = 1
        node.physicsBody = body
    }
    
    fileprivate func addPhysics(forFlatWall node: SKSpriteNode) {
        guard let text = node.texture else { return }
        let body = SKPhysicsBody(rectangleOf: text.size())
        body.categoryBitMask = Physics.defaultCategory
        body.collisionBitMask = Physics.collision
        body.isDynamic = false
        node.lightingBitMask = 1
        node.physicsBody = body
    }
}

extension MossyWall: LifecycleListener {
    func didMoveToScene() {
        setupNodes()
    }
}
