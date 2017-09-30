//
//  GameViewController.swift
//  GravityWizard2
//
//  Created by scott mehus on 12/20/16.
//  Copyright © 2016 scott mehus. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Update this when ios 11 comes out
        // This is need to let the system know the preferredScreenEdgesDeferringSystemGestures has changed
        //            setNeedsUpdateOfScreenEdgesDeferringSystemGestures()
        
//        restrictAllLevels()
        Level.zero.setAccess(access: true)
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = MainMenu.instantiate() {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                
                // Present the scene
                view.presentScene(scene)
            }
            
            view.ignoresSiblingOrder = true
            view.showsFPS = false
            view.showsNodeCount = false
            view.showsPhysics = false
            view.showsFields = true
        }
    }

    override var shouldAutorotate: Bool {
        return true
    }
    
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        if event?.subtype == UIEventSubtype.motionShake {
            showLevelSelector()
        }
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
    
    override func preferredScreenEdgesDeferringSystemGestures() -> UIRectEdge {
        return .top
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    private func restrictAllLevels() {
        for level in Level.all() {
            level.setAccess(access: false)
        }
    }
    
    fileprivate func sceneTransition() -> SKTransition {
         return SKTransition.doorsOpenHorizontal(withDuration: 2.0)
    }
    
    fileprivate func generateScene(level: Level) -> SKScene? {
        guard
            let skView = self.view as? SKView,
            let scene = level.levelScene(),
            let currentScene = skView.scene
            else {
                return nil
        }
        
        scene.scaleMode = currentScene.scaleMode
        return scene
    }
    
    fileprivate func showLevelSelector() {
        let alert = UIAlertController(title: "Pick Level", message: nil, preferredStyle: .actionSheet)
        
        for (idx, level) in Level.all().enumerated() {
            let action = UIAlertAction(title: "Level \(idx)", style: .default) { _ in
                guard let skView = self.view as? SKView, let scene = self.generateScene(level: level) else { return }
                skView.presentScene(scene, transition: self.sceneTransition())
            }
            
            alert.addAction(action)
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(cancel)
        alert.popoverPresentationController?.sourceView = view
        present(alert, animated: true, completion: nil)
    }
}
