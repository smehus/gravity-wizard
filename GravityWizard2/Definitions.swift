//
//  Definitions.swift
//  GravityWizard2
//
//  Created by scott mehus on 12/26/16.
//  Copyright © 2016 scott mehus. All rights reserved.
//

import SpriteKit

struct Interval {
    static let gravityProjectileLife = 0.5
}

enum ProjectileType {
    case arrow
    case gravity
}

enum GravityState {
    case climbing
    case falling
    case ground
    
    var animationKey: String {
        return "GravityAnimation"
    }
}

enum Level: Int {
    case zero = 0
    case one
    case two
    
    func nextLevel() -> Level? {
        let nextInt = self.rawValue + 1
        return Level(rawValue: nextInt)
    }
    
    func levelScene() -> GameScene? {
        switch self {
        case .zero:
            return SKScene(fileNamed: "Level0") as? Level0
        case .one:
            return SKScene(fileNamed: "Level1") as? Level1
        case .two:
            return SKScene(fileNamed: "Level2") as? Level2
        }
    }
}

enum Direction {
    case left
    case right
    case up
    case down
}

struct Images {
    static let radialGravity = "deathtex1"
    static let arrow = "arrow"
    static let arrowBig = "arrow_big"
    static let spark = "spark"
}

struct Actions {
    static let lightMoveAction = "lightMoveAction"
}

struct PhysicsCategory {
    static let None:                UInt32 = 0
    static let Hero:                UInt32 = 0x1 << 1 // 01
    static let Ground:              UInt32 = 0x1 << 2 // 010
    static let Rock:                UInt32 = 0x1 << 3 // 0100
    static let Edge:                UInt32 = 0x1 << 4 // 01000
    static let Arrow:               UInt32 = 0x1 << 5
    static let Blood:               UInt32 = 0x1 << 6
    static let RadialGravity:       UInt32 = 0x1 << 7
    static let BreakableFormation:  UInt32 = 0x1 << 8
    static let VikingBodyPart:      UInt32 = 0x1 << 9
    static let GravityProjectile:   UInt32 = 0x1 << 10
    static let TreasureChest:       UInt32 = 0x1 << 11
    
}

enum CollisionCombination {
    case wizardHitsGround
    case rockHitsWizard
    case wizardCollidesWithGravityField
    
    case bloodCollidesWithGround
    
    case gravityProjectileHitsGround
    
    case arrowCollidesWithEdge
    case arrowCollidesWithBreakable
    case arrowCollidesWithGround
    case arrowCollidesWithVikingBodyPart
    
    case wizardCollidesWithChest
    case none
}
extension UInt32 {
    func collisionCombination() -> CollisionCombination {
        switch self {
        case PhysicsCategory.Ground | PhysicsCategory.Hero:
            return .wizardHitsGround
        case PhysicsCategory.Rock | PhysicsCategory.Hero:
            return .rockHitsWizard
        case PhysicsCategory.Blood | PhysicsCategory.Ground:
            return .bloodCollidesWithGround
        case PhysicsCategory.Arrow | PhysicsCategory.Edge:
            return .arrowCollidesWithEdge
        case PhysicsCategory.Arrow | PhysicsCategory.BreakableFormation :
            return .arrowCollidesWithBreakable
        case PhysicsCategory.Arrow | PhysicsCategory.Ground :
            return .arrowCollidesWithGround
        case PhysicsCategory.Arrow | PhysicsCategory.VikingBodyPart:
            return .arrowCollidesWithVikingBodyPart
        case PhysicsCategory.GravityProjectile | PhysicsCategory.Ground:
            return .gravityProjectileHitsGround
        case PhysicsCategory.Hero | PhysicsCategory.GravityProjectile:
            return .wizardCollidesWithGravityField
        case PhysicsCategory.Hero | PhysicsCategory.TreasureChest:
            return .wizardCollidesWithChest
        default: return .none
        }
    }
}
