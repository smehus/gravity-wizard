//
//  ParticleFactory.swift
//  GravityWizard2
//
//  Created by scott mehus on 12/26/16.
//  Copyright © 2016 scott mehus. All rights reserved.
//

import SpriteKit

class ParticleFactory {
    
    private enum Particle {
        case waterSplash
        case sandStorm
        case snowyLand
        
        var filename: String {
            switch self {
            case .waterSplash:
                return "WaterSplash"
            case .sandStorm:
                return "SandStorm"
            case .snowyLand:
                return "SnowParticle"
            }
        }
    }
    
    static let sharedFactory = ParticleFactory()
    
    func waterSplash(scene: SKScene, position: CGPoint) {
        guard let emitter = SKEmitterNode(fileNamed: Particle.waterSplash.filename) else {
            assertionFailure("Failed to find file name \(Particle.waterSplash)")
            return
        }
    
        emitter.advanceSimulationTime(0.2)
        emitter.run(SKAction.removeFromParentAfterDelay(2.0))
        emitter.position = position
        scene.addChild(emitter)
    }
    
    func addWinterSnowyBackground(scene: GameScene) {
        guard
            let emitter = SKEmitterNode(fileNamed: Particle.snowyLand.filename)
        else {
            fatalError("Failed to find file \(Particle.snowyLand.filename)")
        }
        
        emitter.zPosition = 20
        emitter.particleBirthRate = 600
        emitter.particleLifetime = 8
        emitter.particlePositionRange = CGVector(dx: scene.totalSceneSize.width , dy: scene.totalSceneSize.height)
        emitter.particlePosition = CGPoint(x: 0, y: 0)
        emitter.position = CGPoint(x: scene.totalSceneSize.width / 2, y: scene.totalSceneSize.height / 2)
        scene.addChild(emitter)
        emitter.advanceSimulationTime(4)
    }
    
    func sandStorm(width: CGFloat, height: CGFloat) -> SKEmitterNode {
        guard let emitter = SKEmitterNode(fileNamed: Particle.sandStorm.filename) else {
            fatalError("Failed to create \(Particle.sandStorm)")
        }
        
        emitter.particlePositionRange = CGVector(dx: width, dy: height * 2)
        return emitter
    }
    
    func explosion(intensity: CGFloat) -> SKEmitterNode {
        let emitter = SKEmitterNode()
        let particleTexture = SKTexture(imageNamed: "spark")
        
        emitter.zPosition = 2
        emitter.particleTexture = particleTexture
        emitter.particleBirthRate = 4000 * intensity
        emitter.numParticlesToEmit = Int(400 * intensity)
        emitter.particleLifetime = 2.0
        emitter.emissionAngle = CGFloat(90.0).degreesToRadians()
        emitter.emissionAngleRange = CGFloat(360.0).degreesToRadians()
        emitter.particleSpeed = 600 * intensity
        emitter.particleSpeedRange = 1000 * intensity
        emitter.particleAlpha = 1.0
        emitter.particleAlphaRange = 0.25
        emitter.particleScale = 1.2
        emitter.particleScaleRange = 2.0
        emitter.particleScaleSpeed = -1.5
        
        emitter.particleColorBlendFactor = 1
        emitter.particleBlendMode = SKBlendMode.add
        emitter.run(SKAction.removeFromParentAfterDelay(2.0))
        
        let sequence = SKKeyframeSequence(capacity: 5)
        sequence.addKeyframeValue(SKColor.white, time: 0)
        sequence.addKeyframeValue(SKColor.yellow, time: 0.10)
        sequence.addKeyframeValue(SKColor.orange, time: 0.15)
        sequence.addKeyframeValue(SKColor.red, time: 0.75)
        sequence.addKeyframeValue(SKColor.black, time: 0.95)
        emitter.particleColorSequence = sequence
        
        return emitter
    }
}
