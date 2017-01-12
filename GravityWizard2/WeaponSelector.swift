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
    let turnOn = SKAction.colorize(with: .white, colorBlendFactor: 1.0, duration: 0.3)
    let turnOff = SKAction.colorize(withColorBlendFactor: 0.0, duration: 0.3)
    
    fileprivate func selectedArrow() {
        arrowButton?.run(turnOn)
        gravityButton?.run(turnOff)
        selected(projectile: .arrow)
    }
    
    fileprivate func selectedGravity() {
        arrowButton?.run(turnOff)
        gravityButton?.run(turnOn)
        selected(projectile: .gravity)
    }
    
    fileprivate func selected(projectile: ProjectileType) {
        guard let scene = scene as? GameScene else {
            assertionFailure("Failed to cast scene")
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
            let arrow = childNode(withName: "//arrow") as? SKSpriteNode,
            let gravity = childNode(withName: "//gravity") as? SKSpriteNode
        else {
            assertionFailure("Failed to load button sprites")
            return
        }
        
        arrowButton = arrow
        gravityButton = gravity
    }
}
