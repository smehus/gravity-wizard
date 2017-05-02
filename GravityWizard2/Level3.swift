//
//  Level3.swift
//  GravityWizard2
//
//  Created by scott mehus on 4/29/17.
//  Copyright © 2017 scott mehus. All rights reserved.
//

import SpriteKit

fileprivate struct NodeNames {
    static let foreground = "//Foreground"
}

final class Level3: GameScene {
    
    /// Container nodes
    fileprivate var background: SKNode?
    fileprivate var foreground: SKNode?
    
    var currentLevel: Level {
        return .three
    }
    
    override var shouldAddScenePhysicsEdge: Bool {
        return false
    }
    
    override func setupNodes() {
        super.setupNodes()
        
        guard
            let foregroundNode = childNode(withName: NodeNames.foreground)
        else {
            assertionFailure("Level 3: Failed obtain child nodes from scene")
            return
        }
        
        foreground = foregroundNode
    }
    
    override func update(subClassWith currentTime: TimeInterval, delta: TimeInterval) {
        
        
        updateHeroForSceneWrapping()
    }
    
    override func collisionDidBegin(with contact: SKPhysicsContact) {
        super.collisionDidBegin(with: contact)
    }
    
    override func levelCompleted() {
        
    }
    
    override func gameOver() {
        
    }
}

extension Level3: HeroSceneWrappingProtocol {
    func updateHeroForSceneWrapping() {
        guard let hero = rose, let foreground = self.foreground else { return }
        let heroPosition = convert(hero.position, from: foreground)
        if (heroPosition.x + hero.size.width) < 0 {
            hero.position = hero.position.offset(dx: scene!.size.width, dy: 0)
        }
    }
}
