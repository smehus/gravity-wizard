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
    
    fileprivate func setupBreakables() {
        enumerateChildNodes(withName: Names.breakable) { [weak self] (node, stop) in
            guard
                let stone = node as? DesctructibleStone
            else {
                return
            }
            
            stone.setupPhysicsBody()
        }
    }
}

extension BreakableStoneStructure: LifecycleListener {
    func didMoveToScene() {
        setupBreakables()
    }
}
