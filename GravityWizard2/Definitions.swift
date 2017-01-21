//
//  Definitions.swift
//  GravityWizard2
//
//  Created by scott mehus on 12/26/16.
//  Copyright © 2016 scott mehus. All rights reserved.
//

import SpriteKit

struct Interval {
    static let gravityProjectileLife = 0.8
}

enum ActionType {
    case arrow
    case gravity
    case walk
}

enum GravityState {
    case climbing
    case falling
    case ground
    case pull
    case landing
    
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
    static let rosePulled = "rose-pulled"
    static let roseIdle = "rose-full-small"
    static let roseFalling = "rose-falling"
    static let roseHardLanding = "rose-hard-land"
    static let walkingIcon = "walking-icon"
    
    struct Literals {
        static let walkingIcon = #imageLiteral(resourceName: "walking-icon")
    }
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
    case heroHitsGround
    case rockHitsWizard
    case heroCollidesWithGravityField
    
    case bloodCollidesWithGround
    
    case gravityProjectileHitsGround
    
    case arrowCollidesWithEdge
    case arrowCollidesWithBreakable
    case arrowCollidesWithGround
    case arrowCollidesWithVikingBodyPart
    
    case heroCollidesWithChest
    case none
}
extension UInt32 {
    func collisionCombination() -> CollisionCombination {
        switch self {
        case PhysicsCategory.Ground | PhysicsCategory.Hero:
            return .heroHitsGround
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
            return .heroCollidesWithGravityField
        case PhysicsCategory.Hero | PhysicsCategory.TreasureChest:
            return .heroCollidesWithChest
        default: return .none
        }
    }
}
