//
//  Level2.swift
//  GravityWizard2
//
//  Created by scott mehus on 1/7/17.
//  Copyright © 2017 scott mehus. All rights reserved.
//

import Foundation

class Level2: GameScene {
    
    var currentLevel: Level {
        return .two
    }
}

extension Level2 {
    
    override func didSimulatePhysics() {
        updateFollowNodePosition(followNode: light, originNode: wizardNode)
    }
}
