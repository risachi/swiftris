//
//  HomeViewController.swift
//  swiftris
//
//  Created by Lisa on 6/27/16.
//  Copyright © 2016 Bloc. All rights reserved.
//

import UIKit
import SpriteKit



class HomeViewController: UIViewController, SwiftrisDelegate, UIGestureRecognizerDelegate {
    
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        // we downcast (as!) from UIViewController to GameViewController because UIViewController doesn't have a "gameType" property, which we access below
        let gameViewController = segue.destinationViewController as! GameViewController
        
        gameViewController.gameType = GamePlayChoice(rawValue: segue.identifier!)
    }
    
    
    
    
    
    var scene: GameScene!
    var swiftris: Swiftris!
    override func viewDidLoad() {
        super.viewDidLoad()
        let skView = view as! SKView
        skView.multipleTouchEnabled = false
        
        // create and configure the scene
        scene = GameScene(size: CGSize(width: 320, height: 568))
        scene.scaleMode = .AspectFill
        
        // present the scene
        skView.presentScene(scene)
    }
    
    func gameDidEnd(swiftris: Swiftris) {}
    func gameDidBegin(swiftris: Swiftris) {}
    func gameShapeDidLand(swiftris: Swiftris) {}
    func gameShapeDidMove(swiftris: Swiftris) {}
    func gameShapeDidDrop(swiftris: Swiftris) {}
    func gameDidLevelUp(swiftris: Swiftris) {}

}




