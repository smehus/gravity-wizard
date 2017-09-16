//
//  MainMenu.swift
//  GravityWizard2
//
//  Created by scott mehus on 9/16/17.
//  Copyright © 2017 scott mehus. All rights reserved.
//

import SpriteKit

private enum Sprite {
    case hero
    case startLabel
    
    var name: String {
        switch self {
        case .hero: return "rose"
        case .startLabel: return "start"
        }
    }
}

class MainMenu: SKScene {
    
    private var rose: SKSpriteNode?
    private var startButton: SKLabelNode?
    
    static func instantiate() -> MainMenu? {
        return SKScene(fileNamed: String(describing: MainMenu.self)) as? MainMenu
    }
    
    override func didMove(to view: SKView) {
        guard
            let roseNode = childNode(withName: Sprite.hero.name) as? SKSpriteNode,
            let start = childNode(withName: Sprite.startLabel.name) as? SKLabelNode
        else {
            conditionFailure(with: "failed to resolve sprites")
            return
        }
        
        rose = roseNode
        startButton = start
        
        // begin animating the character
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard let touch = touches.first else { return }
        let position = touch.location(in: self)
        let touchNodes = nodes(at: position)
        
        if let _ = touchNodes.filter({ $0.name == Sprite.startLabel.name }).first as? SKLabelNode {
            // make label different color
        }
    }
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        guard let touch = touches.first else { return }
        let position = touch.location(in: self)
        let touchNodes = nodes(at: position)
        // move forward to level picker
        
        if let _ = touchNodes.filter({ $0.name == Sprite.startLabel.name }).first as? SKLabelNode {
            // got to level selector
        }
    }
}
