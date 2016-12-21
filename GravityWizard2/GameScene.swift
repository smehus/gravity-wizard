//
//  GameScene.swift
//  GravityWizard2
//
//  Created by scott mehus on 12/20/16.
//  Copyright © 2016 scott mehus. All rights reserved.
//

import SpriteKit
import GameplayKit

struct PhysicsCategory {
    static let None:  UInt32 = 0
    static let Wizard:   UInt32 = 0b1 // 1
    static let Block: UInt32 = 0b10 // 2
    static let Bed:   UInt32 = 0b100 // 4
    static let Edge:  UInt32 = 0b1000 // 8
    static let Label: UInt32 = 0b10000 // 16
    static let Spring:UInt32 = 0b100000 // 32
    static let Hook:  UInt32 = 0b1000000 // 64
}

class GameScene: SKScene {

    var wizardNode: WizardNode!
    
    override func didMove(to view: SKView) {
        setupNodes()
    }
    
    fileprivate func setupNodes() {
        
        wizardNode = childNode(withName: "//Wizard") as! WizardNode
        wizardNode.run(SKAction.sequence([SKAction.wait(forDuration: 2.0), SKAction.moveBy(x: 500, y: 0, duration: 4.0)]))
    }
    
}
