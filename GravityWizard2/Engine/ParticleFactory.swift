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
        
        var filename: String {
            switch self {
            case .waterSplash:
                return "WaterSplash"
            case .sandStorm:
                return "SandStorm"
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
