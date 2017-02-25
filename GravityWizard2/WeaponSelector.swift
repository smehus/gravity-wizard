//
//  WeaponSelector.swift
//  GravityWizard2
//
//  Created by scott mehus on 1/12/17.
//  Copyright © 2017 scott mehus. All rights reserved.
//

import SpriteKit

extension ActionType {
    static func action(for point: CGFloat, sectionWidth: CGFloat) -> ActionType? {
        let normalized = Int(point / sectionWidth)
        
        switch normalized {
        case 0:
            return .arrow
        case 1:
            return .gravity
        case 2:
            return .walk
        case 3:
            return .spring
        default:
            return nil
        }
    }
}

final class WeaponSelector: SKNode {
    
    fileprivate var arrowButton: SKSpriteNode?
    fileprivate var gravityButton: SKSpriteNode?
    fileprivate var walkingButton: SKSpriteNode?
    fileprivate var springButton: SKSpriteNode?

    let fadeOff = SKAction.fadeAlpha(to: 0.5, duration: 0.1)
    let fadeOn = SKAction.fadeAlpha(to: 1.0, duration: 0.1)
    let bounce = SKAction.scaleX(by: 1.2, y: 1.2, duration: 0.1)
    
    /// Constants
    fileprivate let buttonWidth: CGFloat = 200
    
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
            let gravity = file.childNode(withName: "//gravity") as? SKSpriteNode,
            let walking = file.childNode(withName: "//walking") as? SKSpriteNode,
            let spring = file.childNode(withName: "//spring") as? SKSpriteNode
        else {
                assertionFailure("Failed to load button sprites")
                return nil
        }
        
        node.isUserInteractionEnabled = true
        node.arrowButton = arrow
        node.gravityButton = gravity
        node.walkingButton = walking
        node.springButton = spring
        node.selectedGravity()
        node.zPosition = 100
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
        walkingButton?.run(turnOff)
        springButton?.run(turnOff)
        arrowButton?.run(turnOn)
        selected(action: .arrow)
    }
    
    fileprivate func selectedGravity() {
        arrowButton?.run(turnOff)
        walkingButton?.run(turnOff)
        springButton?.run(turnOff)
        gravityButton?.run(turnOn)
        selected(action: .gravity)
    }
    
    fileprivate func selectedWalking() {
        arrowButton?.run(turnOff)
        gravityButton?.run(turnOff)
        springButton?.run(turnOff)
        walkingButton?.run(turnOn)
        selected(action: .walk)
    }
    
    fileprivate func selectedSpring() {
        arrowButton?.run(turnOff)
        gravityButton?.run(turnOff)
        walkingButton?.run(turnOff)
        springButton?.run(turnOn)
        selected(action: .spring)
    }
    
    fileprivate func selected(action: ActionType) {
        guard let scene = scene as? GameScene else {
            return
        }
        
        scene.currentActionType = action
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        guard let touch = touches.first else { return }
        let touchPoint = touch.location(in: self)
        
        guard let type = ActionType.action(for: touchPoint.x, sectionWidth: buttonWidth) else { return }
        switch type {
        case .arrow:
            selectedArrow()
        case .gravity:
            selectedGravity()
        case .walk:
            selectedWalking()
        case .spring:
            selectedSpring()
        }
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
