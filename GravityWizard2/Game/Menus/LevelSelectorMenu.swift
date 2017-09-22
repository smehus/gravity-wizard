//
//  LevelSelectorMenu.swift
//  GravityWizard2
//
//  Created by scott mehus on 9/22/17.
//  Copyright © 2017 scott mehus. All rights reserved.
//

import SpriteKit

class LevelSelectorNode: SKNode {
    var level: Level?
}

class LevelSelectorMenu: SKScene {
    
    static func instantiate() -> LevelSelectorMenu {
        return SKScene(fileNamed: String(describing: LevelSelectorMenu.self)) as! LevelSelectorMenu
    }
    
    override func didMove(to view: SKView) {
        
    }
}
