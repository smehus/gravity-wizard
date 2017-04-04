//
//  BreakableStoneStructure.swift
//  GravityWizard2
//
//  Created by scott mehus on 3/31/17.
//  Copyright © 2017 scott mehus. All rights reserved.
//

import Foundation
import SpriteKit

final class BreakableStoneStructure: SKNode {
    
    fileprivate struct Names {
        static let breakable = "breakable"
    }
    
    fileprivate struct Physics {
        static let category = PhysicsCategory.destructible
    }
    
    fileprivate func setupBreakables() {
        enumerateChildNodes(withName: Names.breakable) { [weak self] (node, stop) in
            guard let body = node.physicsBody else { return }
            self?.setup(withBody: body)
        }
    }
    
    fileprivate func setup(withBody body: SKPhysicsBody) {
        body.affectedByGravity = true
        body.isDynamic = true
        body.pinned = false
        body.categoryBitMask = Physics.category
    }
}

extension BreakableStoneStructure: LifecycleListener {
    func didMoveToScene() {
        setupBreakables()
    }
}
