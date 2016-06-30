//
//  GameViewController.swift
//  swiftris
//
//  Created by Lisa on 6/5/16.
//  Copyright (c) 2016 Bloc. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController, SwiftrisDelegate, UIGestureRecognizerDelegate {
    var scene: GameScene!
    var swiftris: Swiftris!
    var panPointReference:CGPoint? //keep track of the last point on th screen at which a shape movement occurred or where a pan begins
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var levelLabel: UILabel!

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
        swiftris.delegate = self
        swiftris.beginGame()
        
        // present the scene
        skView.presentScene(scene)
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    @IBAction func didTap(sender: UITapGestureRecognizer) {
        swiftris.rotateShape()
    }
    
    @IBAction func didPan(sender: UIPanGestureRecognizer) {
        // we recover a point which defines the translation of the gesture relative to where it began
        // this is a measure of the distance that the user's finger has traveled
        let currentPoint = sender.translationInView(self.view)
        if let originalPoint = panPointReference {
            // we check whether the x translation has crossed our threshold - 90% of BlockSize - before proceeding
            if abs(currentPoint.x - originalPoint.x) > (BlockSize * 0.9) {
                // we check the velocity of a gesture
                //a positive velocity represents a gesture moving towards the right side of the screen
                //a negative velocity represents a gesture moving towards the left side of the screen
                if sender.velocityInView(self.view).x > CGFloat(0) {
                    swiftris.moveShapeRight()
                    panPointReference = currentPoint
                } else {
                    swiftris.moveShapeLeft()
                    panPointReference = currentPoint
                }
            }
        } else if sender.state == .Began {
            panPointReference = currentPoint
        }
    }
    
    @IBAction func didSwipe(sender: UISwipeGestureRecognizer) {
        swiftris.dropShape()
    }
    
    // GameViewController will implement an optional delegate method found in UIGestureRecognizerDelegate which will allow each gesture recognizer to work in tandem with the others
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    // "is" conditionals
    // these conditionals check whether the generic UIGestureRecognizer parameters is of the specific types of recognizers we expect to see.
    // if the check succeeds, we execute the code block
    // our code lets the pan gesture recognizer take precedence over the swipe gesture and the tap to do likewise over the pan
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailByGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer is UISwipeGestureRecognizer {
            if otherGestureRecognizer is UIPanGestureRecognizer {
                return true
            }
        } else if gestureRecognizer is UIPanGestureRecognizer {
            if otherGestureRecognizer is UITapGestureRecognizer {
                return true
            }
        }
        return false
    }
    
    // Handles all the actions which should happen on each tick.
    // when time in a timed game has elapsed, gestures are disabled
    func didTick() {
        view.userInteractionEnabled = !swiftris.detectTimedGameOver()
        swiftris.letShapeFall()
    }
    
    func nextShape() {
        let newShapes = swiftris.newShape()
        guard let fallingShape = newShapes.fallingShape else {
            return
        }
        self.scene.addPreviewShapeToScene(newShapes.nextShape!) {}
        self.scene.movePreviewShape(fallingShape) {
            // the user will not be able to manipulate Swiftris in any way
            // this is useful during intermediate states when we animate or shift blocks, and perform calculations
            self.view.userInteractionEnabled = true
            self.scene.startTicking()
        }
    }
    
    func gameDidBegin(swiftris: Swiftris) {
        //reset the score and level labels as well a the speed at which the ticks occur, beginning with TickLengthLevelOne
        levelLabel.text = "\(swiftris.level)"
        scoreLabel.text = "\(swiftris.score)"
        scene.tickLengthMillis = TickLengthLevelOne
        
        // The following is false when restarting a new game
        if swiftris.nextShape != nil && swiftris.nextShape!.blocks[0].sprite == nil {
            scene.addPreviewShapeToScene(swiftris.nextShape!) {
                self.nextShape()
            }
        } else {
            nextShape()
        }
    }
    
    func gameDidEnd(swiftris: Swiftris) {
        view.userInteractionEnabled = false
        scene.stopTicking()
        
        scene.playSound("gameover.mp3")
        scene.animateCollapsingLines(swiftris.removeAllBlocks(), fallenBlocks: swiftris.removeAllBlocks()) {
            swiftris.beginGame()
        }
    }
    
    func gameDidLevelUp(swiftris: Swiftris) {
        levelLabel.text = "\(swiftris.level)"
        if scene.tickLengthMillis >= 100 {
            scene.tickLengthMillis -= 100
        } else if scene.tickLengthMillis > 50 {
            scene.tickLengthMillis -= 50
        }
        scene.playSound("levelup.mp3")
    }
    
    func gameShapeDidDrop(swiftris: Swiftris) {
        // we stop the ticks, redraw the shape at its new location and then let it drop
        // this will in turn call back to GameViewController and report that the shape has landed
        scene.stopTicking()
        scene.redrawShape(swiftris.fallingShape!) {
            swiftris.letShapeFall()
        }
        scene.playSound("drop.mp3")
    }
    
    func gameShapeDidLand(swiftris: Swiftris) {
        scene.stopTicking()
        self.view.userInteractionEnabled = false

        let removedLines = swiftris.removeCompletedLines()
        if removedLines.linesRemoved.count > 0 {
            self.scoreLabel.text = "\(swiftris.score)"
            scene.animateCollapsingLines(removedLines.linesRemoved, fallenBlocks:removedLines.fallenBlocks) {
                // a recursive call: one which invokes itself
                self.gameShapeDidLand(swiftris)
            }
            scene.playSound("bomb.mp3")
        } else {
            nextShape()
        }
    }
    
    // after a shape has moved, we have to redraw its representative sprites at its new location
    func gameShapeDidMove(swiftris: Swiftris) {
        scene.redrawShape(swiftris.fallingShape!) {}
    }
}
