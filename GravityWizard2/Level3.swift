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
    
    // MARK: - Game Protocol
    
    var currentLevel: Level {
        return .three
    }
    
    
    // MARK: - SceneEdgeDecider Protocol
    
    override var shouldAddScenePhysicsEdge: Bool {
        return false
    }
    
    override var yConstraintMultiplier: CGFloat {
        return 3
    }
    
    // MARK: - GameScene overrides
    
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
    
    override func update(levelWith currentTime: TimeInterval, delta: TimeInterval) {
        
    }
    
    override func didSimulatePhysicsForLevel() {
        updateHeroForSceneWrapping()
    }
    
    override func contactDidBegin(with contact: SKPhysicsContact) {
        super.contactDidBegin(with: contact)
    }
    
    override func levelCompleted() {
        
    }
    
    override func gameOver() {
        
        guard let gameOverLabel = LevelCompleteLabel.createLabel(with: "Game Over"), let camera = camera else { return }
        gameOverLabel.move(toParent: camera)
        gameOverLabel.position = CGPoint.zero
        
        runZoomOutAction()
        let presentScene = SKAction.afterDelay(2.0) {
            guard let reloadLevel = self.currentLevel.levelScene() else {
                self.conditionFailure(with: "Failed to load level scene on game over")
                return
            }
            
            reloadLevel.scaleMode = self.scaleMode
            let transition = SKTransition.doorsOpenHorizontal(withDuration: 1.0)
            self.view?.presentScene(reloadLevel, transition: transition)
            
        }
        
        run(presentScene)
    }
}

extension Level3: HeroSceneWrappingProtocol {
    func updateHeroForSceneWrapping() {
        guard let hero = rose else { return }
        let heroPosition = convert(hero.position, from: hero.parent!)
        if (heroPosition.x + hero.size.width) < 0 {
            hero.position = hero.position.offset(dx: scene!.size.width, dy: 0)
        } else if heroPosition.x > scene!.size.width {
            hero.position = CGPoint(x: 0, y: heroPosition.y)
        }
    }
}
