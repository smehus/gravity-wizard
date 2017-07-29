//
//  LavaSection.swift
//  GravityWizard2
//
//  Created by scott mehus on 2/28/17.
//  Copyright © 2017 scott mehus. All rights reserved.
//

import SpriteKit

fileprivate struct Names {
    static let lava = "lava"
}

fileprivate struct Physics {
    static let category = PhysicsCategory.Lava
    static let contactTest = PhysicsCategory.Hero
    static let collision = PhysicsCategory.None
}

final class LavaSection: SKSpriteNode {
    
    fileprivate func setupNodes() {
        enumerateChildNodes(withName: "//\(Names.lava)") { [weak self] node, _ in
            guard let body = node.physicsBody else { return }
            self?.update(physicsBody: body)
        }
    }
    
    fileprivate func update(physicsBody: SKPhysicsBody) {
        physicsBody.categoryBitMask = Physics.category
        physicsBody.contactTestBitMask = Physics.contactTest
        physicsBody.collisionBitMask = Physics.collision
        physicsBody.isDynamic = false
        physicsBody.affectedByGravity = false
    }
}

extension LavaSection: LifecycleListener {
    func didMoveToScene() {
        setupNodes()
    }
}

final class GenericLavaCategoryNode: SKSpriteNode {
    private func setupNode() {
        physicsBody?.categoryBitMask = PhysicsCategory.Lava
        physicsBody?.contactTestBitMask = PhysicsCategory.Hero
    }
}

extension GenericLavaCategoryNode: LifecycleListener {
    func didMoveToScene() {
        setupNode()
    }
}
