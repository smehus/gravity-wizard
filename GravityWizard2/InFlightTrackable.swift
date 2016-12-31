//
//  InFlightTrackable.swift
//  GravityWizard2
//
//  Created by scott mehus on 12/31/16.
//  Copyright © 2016 scott mehus. All rights reserved.
//

import SpriteKit

protocol InFlightTrackable {
    var isInFlight: Bool { get }
    func launch(at vector: CGVector)
    func collide()
}

extension InFlightTrackable where Self: SKNode {
    func launch(at vector: CGVector) {
        guard let body = physicsBody else { return }
        body.velocity = vector
    }
}

extension InFlightTrackable where Self: SKSpriteNode {
    func launch(at vector: CGVector) {
        guard let body = physicsBody else { return }
        body.velocity = vector
    }
}
