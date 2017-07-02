//
//  Level4.swift
//  GravityWizard2
//
//  Created by scott mehus on 6/9/17.
//  Copyright © 2017 scott mehus. All rights reserved.
//

import SpriteKit

final class Level4: GameScene {
    
    var currentLevel: Level {
        return .four
    }
    
    
    override var shouldAddScenePhysicsEdge: Bool {
        return false
    }
    
    override var yConstraintMultiplier: CGFloat {
        return 5
    }

    override var xConstraintMultiplier: CGFloat {
        return 5
    }
}
