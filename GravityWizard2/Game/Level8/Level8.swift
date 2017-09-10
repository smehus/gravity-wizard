//
//  Level8.swift
//  GravityWizard2
//
//  Created by scott mehus on 9/2/17.
//  Copyright © 2017 scott mehus. All rights reserved.
//

import SpriteKit

private enum Nodes {
    case background
    case windStreams
    
    var name: String {
        switch self {
        case .background: return "background"
        case .windStreams: return "wind-streams"
        }
    }
}

private enum GameState {
    case playing
    case gameOver
    case levelComplete
}

class Level8: GameScene {
    
    var currentLevel: Level {
        return .eight
    }
    
    private var windStreamLayer: WindStreamLayer?
    private var gameState = GameState.playing
    
    override var shouldAddScenePhysicsEdge: Bool {
        return false
    }
    
    override var yConstraintMultiplier: CGFloat {
        return 2
    }
    
    override var xConstraintMultiplier: CGFloat {
        return 2
    }
    
    override var totalSceneSize: CGSize {
        let width = size.width * xConstraintMultiplier
        let height = playableHeight * yConstraintMultiplier
        return CGSize(width: width, height: height)
    }
    
    override func setupNodes() {
        super.setupNodes()
        
        guard
            let windLayer = childNode(withName: Nodes.windStreams.name) as? WindStreamLayer
        else {
            conditionFailure(with: "Failed to resolve nodes")
            return
        }

        windLayer.setupStreams(size: totalSceneSize)
        windStreamLayer = windLayer
    }
    
    override func update(levelWith currentTime: TimeInterval, delta: TimeInterval) {
        guard gameState == .playing else { return }
        roseCheck()
    }
    
    override func didSimulatePhysicsForLevel() {
        guard gameState == .playing else { return }
    }
    
    override func contactDidBegin(with contact: SKPhysicsContact) {
        super.contactDidBegin(with: contact)
        
        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        ArrowCollision: if collision.collisionCombination() == .arrowCollidesWithEnemy {
            let enemyNode = contact.bodyA.categoryBitMask == PhysicsCategory.enemy ? contact.bodyA.node : contact.bodyB.node
            guard let enemy = enemyNode as? FlyingEnemy else { break ArrowCollision }
            guard !enemy.isHit  else { break ArrowCollision }
            
            enemy.isHit = true
            enemy.physicsBody?.affectedByGravity = true
            rose?.jumpCount += 2
        }
    }
    
    override func levelCompleted() {
        guard let successLevel = LevelCompleteLabel.createLabel(), let camera = camera else { return }
        successLevel.move(toParent: camera)
        successLevel.position = CGPoint.zero
        
        
        let presentScene = SKAction.afterDelay(2.0) {
            guard let nextLevel = self.currentLevel.nextLevel()?.levelScene() else { return }
            nextLevel.scaleMode = self.scaleMode
            let transition = SKTransition.doorsOpenHorizontal(withDuration: 1.0)
            self.view?.presentScene(nextLevel, transition: transition)
            
        }
        
        run(presentScene)
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
    
    private func roseCheck() {
        guard let rose = rose else { return }
        let rosePosition = convert(rose.position, from: rose.parent!)
        
        if rosePosition.y < 0 {
            gameState = .gameOver
            gameOver()
        }
    }
    
}
