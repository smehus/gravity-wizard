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
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = Level.five.levelScene() {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                
                // Present the scene
                view.presentScene(scene)
            }
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
            view.showsPhysics = false
            view.showsFields = false
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

    override var prefersStatusBarHidden: Bool {
        return true
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
        
        let levelZero = UIAlertAction(title: "Level Zero", style: .default) { _ in
            guard let skView = self.view as? SKView, let scene = self.generateScene(level: .zero) else { return }
            skView.presentScene(scene, transition: self.sceneTransition())
        }
        
        let levelOne = UIAlertAction(title: "Level One", style: .default) { _ in
            guard let skView = self.view as? SKView, let scene = self.generateScene(level: .one) else { return }
            skView.presentScene(scene, transition: self.sceneTransition())
        }
        
        let levelTwo = UIAlertAction(title: "Level Two", style: .default) { _ in
            guard let skView = self.view as? SKView, let scene = self.generateScene(level: .two) else { return }
            skView.presentScene(scene, transition: self.sceneTransition())
        }
        
        let levelThree = UIAlertAction(title: "Level three", style: .default) { _ in
            guard let skView = self.view as? SKView, let scene = self.generateScene(level: .three) else { return }
            skView.presentScene(scene, transition: self.sceneTransition())
        }
        
        let levelFour = UIAlertAction(title: "Level four", style: .default) { _ in
            guard let skView = self.view as? SKView, let scene = self.generateScene(level: .four) else { return }
            skView.presentScene(scene, transition: self.sceneTransition())
        }
        
        let levelFive = UIAlertAction(title: "Level five", style: .default) { _ in
            guard let skView = self.view as? SKView, let scene = self.generateScene(level: .five) else { return }
            skView.presentScene(scene, transition: self.sceneTransition())
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(levelZero)
        alert.addAction(levelOne)
        alert.addAction(levelTwo)
        alert.addAction(levelThree)
        alert.addAction(levelFour)
        alert.addAction(levelFive)
        
        alert.addAction(cancel)
        alert.popoverPresentationController?.sourceView = view
        present(alert, animated: true, completion: nil)
    }
}
