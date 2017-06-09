//
//  BreakableStoneStructure.swift
//  GravityWizard2
//
//  Created by scott mehus on 3/31/17.
//  Copyright © 2017 scott mehus. All rights reserved.
//

import Foundation
import SpriteKit

final class BreakableStoneStructure: SKNode {
    
    fileprivate struct Names {
        static let breakable = "breakable"
    }
    
    fileprivate func setupBreakables() {
        enumerateChildNodes(withName: Names.breakable) { (node, stop) in
            guard
                let stone = node as? DesctructibleStone
            else {
                return
            }
            
            stone.setupPhysicsBody()
        }
    }
    
    func createExplosion(at pos: CGPoint, mainTexture: SKTexture, animationTextures: [SKTexture]) {
        guard let gameScene = scene else { return }
        
        for _ in 0...10 {
            let rockNode = SKSpriteNode(texture: mainTexture, size: mainTexture.size())
            let rockBody = SKPhysicsBody(circleOfRadius: mainTexture.size().width / 2)
            rockBody.categoryBitMask = PhysicsCategory.brokenRockParts
            rockBody.collisionBitMask = PhysicsCategory.Edge | PhysicsCategory.Ground
            rockBody.affectedByGravity = true
            rockBody.isDynamic = true
            rockBody.allowsRotation = true
            
            rockBody.density = 0.5
            rockNode.physicsBody = rockBody
            
            rockNode.position = convert(pos, to: gameScene)
            gameScene.addChild(rockNode)

            let impulseVect = CGVector(dx: CGFloat.random(min: -5, max: 5), dy: CGFloat.random(min: 0, max: 5))
            rockNode.physicsBody?.applyImpulse(impulseVect)
            
            let wait = SKAction.wait(forDuration: 2.0)
            let removeAction = SKAction.removeFromParent()
            
            let moveAction = SKAction.moveBy(x: 0, y: 40, duration: 0.4)
            let stretchAction = SKAction.scaleX(by: 2.0, y: 2.0, duration: 0.4)
            let smokeAnimation = SKAction.animate(with: animationTextures, timePerFrame: 0.01)
            let removeGravityAction = SKAction.customAction(withDuration: 0.0, actionBlock: { (node, _) in
                node.physicsBody?.affectedByGravity = false
                node.physicsBody?.isDynamic = false
            })
            
            let smokeGroup = SKAction.group([removeGravityAction, stretchAction, moveAction, smokeAnimation])
            let sequence = SKAction.sequence([wait, smokeGroup, removeAction])
            rockNode.run(sequence)
        }
    }
}

extension BreakableStoneStructure: LifecycleListener {
    func didMoveToScene() {
        setupBreakables()
    }
}
