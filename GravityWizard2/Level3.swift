//
//  Level3.swift
//  GravityWizard2
//
//  Created by scott mehus on 4/29/17.
//  Copyright © 2017 scott mehus. All rights reserved.
//

import SpriteKit

final class Level3: GameScene {
    
    var currentLevel: Level {
        return .three
    }
    
    override func setupNodes() {
        super.setupNodes()
    }
    
    override func update(subClassWith currentTime: TimeInterval) {
        
    }
    
    override func collisionDidBegin(with contact: SKPhysicsContact) {
        super.collisionDidBegin(with: contact)
    }
    
    override func levelCompleted() {
        
    }
    
    override func gameOver() {
        
    }
    
}
