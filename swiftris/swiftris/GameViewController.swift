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
    var swiftris: Swiftris!

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
        
        // a closure for the tick property of GameScene.swift:
        scene.tick = didTick
        
        swiftris = Swiftris()
        swiftris.beginGame()
        
        // present the scene
        skView.presentScene(scene)
        
        // we add nextShape to the game layer at the preview location
        // when that animation completes, we reposition the underlying Shape object at the starting row and starting column before we ask GameScene to move it form the preview location to its starting position
        // once that completes, we ask Swiftris for a new shape, begin ticking, and add the newly established upcoming piece to the preview area
        scene.addPreviewShapeToScene(swiftris.nextShape!) {
            self.swiftris.nextShape?.moveTo(StartingColumn, row: StartingRow)
            self.scene.movePreviewShape(self.swiftris.nextShape!) {
                let nextShapes = self.swiftris.newShape()
                self.scene.startTicking()
                self.scene.addPreviewShapeToScene(nextShapes.nextShape!) {}
            }
        }
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    //lowers the falling shape by onerow and then asks GameScene to redraw the shape at its new location
    func didTick() {
        swiftris.fallingShape?.lowerShapeByOneRow()
        scene.redrawShape(swiftris.fallingShape!, completion: {})
    }
}
