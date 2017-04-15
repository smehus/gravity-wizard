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
    
    func createExplosion(at pos: CGPoint) {
        guard let gameScene = scene else { return }
        let text = SKTexture(image: #imageLiteral(resourceName: "round-rock"))
        for _ in 0...4 {
            let rockNode = SKSpriteNode(texture: text, size: text.size() / 2)
            let rockBody = SKPhysicsBody(circleOfRadius: text.size().width / 4)
            rockBody.categoryBitMask = PhysicsCategory.brokenRockParts
            rockBody.collisionBitMask = PhysicsCategory.Edge | PhysicsCategory.Ground
            rockBody.affectedByGravity = true
            rockBody.isDynamic = true
            rockBody.allowsRotation = true
            
            rockBody.density = 0.5
            rockNode.physicsBody = rockBody
            
            rockNode.position = convert(pos, to: gameScene)
            gameScene.addChild(rockNode)
            let vect = CGVector(dx: CGFloat.random(min: -50, max: 50), dy: 0)
            rockNode.physicsBody?.applyForce(vect)
        }
    }
}

extension BreakableStoneStructure: LifecycleListener {
    func didMoveToScene() {
        setupBreakables()
    }
}
