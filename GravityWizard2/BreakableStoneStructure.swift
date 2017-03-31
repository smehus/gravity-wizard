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
    
    fileprivate func setupBreakables() {
        
    }
}

extension BreakableStoneStructure: LifecycleListener {
    func didMoveToScene() {
        setupBreakables()
    }
}
