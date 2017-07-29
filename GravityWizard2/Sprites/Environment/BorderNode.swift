//
//  BorderNode.swift
//  GravityWizard2
//
//  Created by scott mehus on 7/29/17.
//  Copyright © 2017 scott mehus. All rights reserved.
//

import SpriteKit

private enum BorderConfig: SpriteConfiguration {
    case defaultBorder
    
    var name: String {
        return "Border Config"
    }
    
    
    var categoryBitMask: UInt32 {
        switch self {
        case .defaultBorder:
            return PhysicsCategory.border
        }
    }
    
    var contactTestBitMask: UInt32 {
        switch self {
        case .defaultBorder:
            return PhysicsCategory.Hero
        }
    }
    
    var collisionBitMask: UInt32 {
        switch self {
        case .defaultBorder:
            return PhysicsCategory.Hero
        }
    }
    
    // Physics
    
    var isDynamic: Bool {
        switch self {
        case .defaultBorder:
            return false
        }
    }
    
    var affectedByGravity: Bool {
        switch self {
        case .defaultBorder:
            return false
        }
    }
    
    var allowsRotation: Bool {
        switch self {
        case .defaultBorder:
            return false
        }
    }
}

final class BorderNode: SKSpriteNode {
    fileprivate func setupBorder() {
        configure(with: BorderConfig.defaultBorder)
    }
}

extension BorderNode: LifecycleListener {
    func didMoveToScene() {
        setupBorder()
    }
}
