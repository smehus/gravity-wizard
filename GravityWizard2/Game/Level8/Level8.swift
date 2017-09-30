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
    private var backgroundLayer: SKNode?
    private var gameState = GameState.playing
    
    override var shouldAddScenePhysicsEdge: Bool {
        return false
    }
    
    override var yConstraintMultiplier: CGFloat {
        return 2
    }
    
    override var xConstraintMultiplier: CGFloat {
        return 5
    }
    
    override var totalSceneSize: CGSize {
        let width = size.width * xConstraintMultiplier
        let height = playableHeight * yConstraintMultiplier
        return CGSize(width: width, height: height)
    }
    
    override func setupNodes() {
        super.setupNodes()
        
        guard
            let backgroundSprite = childNode(withName: Nodes.background.name),
            let windLayer = childNode(withName: Nodes.windStreams.name) as? WindStreamLayer
        else {
            conditionFailure(with: "Failed to resolve nodes")
            return
        }

        backgroundLayer = backgroundSprite
        windLayer.setupStreams(size: totalSceneSize)
        windStreamLayer = windLayer
        
        repeatBackground()
        
        rose?.MAX_JUMP_COUNT = 5
    }
    
    override func update(levelWith currentTime: TimeInterval, delta: TimeInterval) {
        guard gameState == .playing else { return }
        roseCheck()
        killOffscreenSprites()
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
    
    private func repeatBackground() {
        guard
            let background = backgroundLayer,
            let sprite = background.childNode(withName: "background-image") as? SKSpriteNode
        else { assertionFailure(); return }
        
        var currentSprite = sprite
        
        for _ in 0...Int(xConstraintMultiplier) {
            let newPosition = currentSprite.position.x + size.width
            let newBG = sprite.copy() as! SKSpriteNode
            newBG.position = CGPoint(x: newPosition, y: currentSprite.position.y)
            background.addChild(newBG)
            currentSprite = newBG
        }
    }
    
    private func killOffscreenSprites() {
        
        for node in children {
            let minY = self.camera!.position.y - (self.playableHeight / 2)
            if node is ArrowNode, node.position.y < (minY - 100) {
                node.removeFromParent()
            }
            
            for child in node.children.filter({ $0 is FlyingEnemy }) {
                if child.position.y < (minY - 100) {
                    child.removeFromParent()
                }
            }
        }
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
