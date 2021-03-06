//
//  LevelSelectorMenu.swift
//  GravityWizard2
//
//  Created by scott mehus on 9/22/17.
//  Copyright © 2017 scott mehus. All rights reserved.
//

import SpriteKit

class LevelSelectorNode: SKNode {
    
    private enum Sprite {
        case button
        case label
        
        var name: String {
            switch self {
            case .button: return "level"
            case .label: return "label"
            }
        }
    }
    
    var level: Level?
    private var label: SKLabelNode?
    private var button: SKSpriteNode?
    
    func setup(with level: Level) {
        self.level = level
        
        guard
            let labelNode = childNode(withName: Sprite.label.name) as? SKLabelNode,
            let buttonNode = childNode(withName: Sprite.button.name) as? SKSpriteNode
            else {
                conditionFailure(with: "FAiled to setup nodes")
                return
        }
        
        labelNode.zPosition = 10
        labelNode.position = CGPoint(x: buttonNode.position.x, y: buttonNode.position.y - (labelNode.frame.size.halfHeight))
        
        if level.hasAccess() {
            buttonNode.texture = SKTexture(image: #imageLiteral(resourceName: "available-level"))
        }
        
        label = labelNode
        button = buttonNode
    }
}

class LevelSelectorMenu: SKScene {
    
    var selectedNode: LevelSelectorNode?
    
    static func instantiate() -> LevelSelectorMenu {
        return SKScene(fileNamed: String(describing: LevelSelectorMenu.self)) as! LevelSelectorMenu
    }
    
    override func didMove(to view: SKView) {
        for node in children.filter({ $0 is LevelSelectorNode }) {
            guard
                let level = Level(string: node.name),
                let levelNode = node as? LevelSelectorNode
                else { continue }
            
            levelNode.setup(with: level)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard let touch = touches.first else { return }
        let noddePosition = touch.location(in: self)
        let touchedNodes = nodes(at: noddePosition)
        
        if let node = touchedNodes.filter({ $0 is LevelSelectorNode }).first as? LevelSelectorNode {
            selectedNode = node
            node.run(SKAction.scale(by: 0.8, duration: 0.1))
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        guard let touch = touches.first else { return }
        let position = touch.location(in: self)
        let touchNodes = nodes(at: position)
        
        selectedNode?.run(SKAction.scale(to: 1.0, duration: 0.1))
        
        guard
            let node = touchNodes.filter({ $0 is LevelSelectorNode }).first as? LevelSelectorNode,
            let level = node.level,
            level.hasAccess(),
            let levelScene = level.levelScene()
        else { return }
        
        levelScene.scaleMode = self.scaleMode
        let transition = SKTransition.doorsCloseHorizontal(withDuration: 1.0)
        view?.presentScene(levelScene, transition: transition)
    }
}
