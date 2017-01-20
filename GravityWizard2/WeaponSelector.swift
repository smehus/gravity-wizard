//
//  WeaponSelector.swift
//  GravityWizard2
//
//  Created by scott mehus on 1/12/17.
//  Copyright © 2017 scott mehus. All rights reserved.
//

import SpriteKit

class WeaponSelector: SKNode {
    
    fileprivate var arrowButton: SKSpriteNode?
    fileprivate var gravityButton: SKSpriteNode?

    let fadeOff = SKAction.fadeAlpha(to: 0.5, duration: 0.1)
    let fadeOn = SKAction.fadeAlpha(to: 1.0, duration: 0.1)
    let bounce = SKAction.scaleX(by: 1.2, y: 1.2, duration: 0.1)
    
    var halfWidth: CGFloat {
        guard let arrow = arrowButton, let gravity = gravityButton else { return 100 }
        let total = arrow.size.width + gravity.size.width
        return total / 2
    }
    
    var halfHeight: CGFloat {
        guard let arrow = arrowButton else { return 100 }
        let total = arrow.size.height
        return total / 2
    }
    
    static func generateWeaponSelector() -> WeaponSelector? {
        guard
            let file = SKScene(fileNamed: "WeaponSelector"),
            let node = file.childNode(withName: "container") as? WeaponSelector,
            let arrow = file.childNode(withName: "//arrow") as? SKSpriteNode,
            let gravity = file.childNode(withName: "//gravity") as? SKSpriteNode
            else {
                assertionFailure("Failed to load button sprites")
                return nil
        }
        
        node.isUserInteractionEnabled = true
        node.arrowButton = arrow
        node.gravityButton = gravity
        node.selectedArrow()
        
        return node
    }

    var turnOn: SKAction {
        let bounceSequence = SKAction.sequence([bounce, bounce.reversed()])
        return SKAction.group([bounceSequence, fadeOn])
    }
    
    var turnOff: SKAction {
        return SKAction.sequence([fadeOff])
    }
    
    fileprivate func selectedArrow() {
        gravityButton?.run(turnOff)
        arrowButton?.run(turnOn)
        selected(projectile: .arrow)
    }
    
    fileprivate func selectedGravity() {
        arrowButton?.run(turnOff)
        gravityButton?.run(turnOn)
        selected(projectile: .gravity)
    }
    
    fileprivate func selected(projectile: ProjectileType) {
        guard let scene = scene as? GameScene else {
            return
        }
        
        scene.currentPojectileType = projectile
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        guard let touch = touches.first else { return }
        let touchPoint = touch.location(in: self)
        touchPoint.x < 0 ? selectedArrow() : selectedGravity()
    }
}

extension WeaponSelector: LifecycleListener {
    func didMoveToScene() {
        isUserInteractionEnabled = true
        
        guard
            let arrow = childNode(withName: "arrow") as? SKSpriteNode,
            let gravity = childNode(withName: "gravity") as? SKSpriteNode
        else {
            assertionFailure("Failed to load button sprites")
            return
        }
        
        arrowButton = arrow
        gravityButton = gravity
        
        selectedGravity()
    }
}
