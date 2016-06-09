//
//  GameViewController.swift
//  swiftris
//
//  Created by Lisa on 6/5/16.
//  Copyright (c) 2016 Bloc. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {
    var scene: GameScene!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // configure the view
        // as! is a forced downcast; use only when you are sure the downcast will always succeed, otherwise this form will trigger a runtime error if you try to downcast to an incorrect class type
        // the view object is actually of type SKView but before downcasting our code treats is like a basic UIView; without downcasting, we are unable to access SKView methods and properties, such as presentScene(SKScene)
        let skView = view as! SKView
        skView.multipleTouchEnabled = false
        
        // create and configure the scene
        scene = GameScene(size: skView.bounds.size)
        scene.scaleMode = .AspectFill
        
        // present the scene
        skView.presentScene(scene)
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
