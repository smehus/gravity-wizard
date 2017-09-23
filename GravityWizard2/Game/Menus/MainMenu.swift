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
    case startButton
    
    var name: String {
        switch self {
        case .hero: return "rose"
        case .startLabel: return "startLabel"
        case .startButton: return "startButton"
        }
    }
}

class MainMenu: SKScene {
    
    private var rose: SKSpriteNode?
    private var startLabel: SKLabelNode?
    private var startButton: SKSpriteNode?
    
    static func instantiate() -> MainMenu? {
        return SKScene(fileNamed: String(describing: MainMenu.self)) as? MainMenu
    }
    
    override func didMove(to view: SKView) {
        guard
            let roseNode = childNode(withName: Sprite.hero.name) as? SKSpriteNode,
            let start = childNode(withName: Sprite.startLabel.name) as? SKLabelNode,
            let button = childNode(withName: Sprite.startButton.name) as? SKSpriteNode
        else {
            conditionFailure(with: "failed to resolve sprites")
            return
        }
        
        rose = roseNode
        startLabel = start
        startButton = button
        
        // begin animating the character
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard let touch = touches.first else { return }
        let position = touch.location(in: self)
        let touchNodes = nodes(at: position)
        
        if let _ = touchNodes.filter({ $0.name == Sprite.startLabel.name || $0.name == Sprite.startButton.name }).first {
            // make label different color
            startButton?.run(SKAction.scale(by: 0.8, duration: 0.1))
            startLabel?.run(SKAction.scale(by: 0.8, duration: 0.1))
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        guard let touch = touches.first else { return }
        let position = touch.location(in: self)
        let touchNodes = nodes(at: position)
        // move forward to level picker
        
        startButton?.run(SKAction.scale(by: 1.2, duration: 0.1))
        startLabel?.run(SKAction.scale(by: 1.2, duration: 0.1))
        
        if let _ = touchNodes.filter({ $0.name == Sprite.startButton.name || $0.name == Sprite.startButton.name }).first {
           
            // got to level selector
            let nextMenu = LevelSelectorMenu.instantiate()
            nextMenu.scaleMode = self.scaleMode
            let transition = SKTransition.flipHorizontal(withDuration: 0.5)
            view?.presentScene(nextMenu, transition: transition)
        }
    }
}
