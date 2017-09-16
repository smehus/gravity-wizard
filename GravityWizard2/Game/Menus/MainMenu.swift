//
//  MainMenu.swift
//  GravityWizard2
//
//  Created by scott mehus on 9/16/17.
//  Copyright © 2017 scott mehus. All rights reserved.
//

import SpriteKit

class MainMenu: SKScene {
    
    private var rose: SKSpriteNode?
    private var startButton: SKLabelNode?
    
    override func didMove(to view: SKView) {
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        // Change color of label
    }
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        // move forward to level picker
    }
}
