//
//  HomeViewController.swift
//  swiftris
//
//  Created by Lisa on 6/27/16.
//  Copyright © 2016 Bloc. All rights reserved.
//

import UIKit
import SpriteKit
import GameKit


class HomeViewController: UIViewController, SwiftrisDelegate, UIGestureRecognizerDelegate {
    
    func authenticateLocalPlayer(){
        var localPlayer = GKLocalPlayer.localPlayer()
        localPlayer.authenticateHandler = {(viewController, error) -> Void in
            if ((viewController) != nil) {
                self.presentViewController(viewController!, animated: true, completion: nil)
            }else{
                print("(GameCenter) Player authenticated: \(GKLocalPlayer.localPlayer().authenticated)")
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        
        if segue.identifier == "Classic" || segue.identifier == "Timed" {
            // we downcast (as!) from UIViewController to GameViewController because UIViewController doesn't have a "gameType" property, which we access below
            let gameViewController = segue.destinationViewController as! GameViewController
        
            gameViewController.gameType = GamePlayChoice(rawValue: segue.identifier!)
        } else {
            let gameCenterViewController = segue.destinationViewController as! GameCenterViewController
            gameCenterViewController.showLeaderboard();
        }
    }
    
    var scene: GameScene!
    var swiftris: Swiftris!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        authenticateLocalPlayer();
    }
    
    
    func gameDidEnd(swiftris: Swiftris) {}
    func gameDidBegin(swiftris: Swiftris) {}
    func gameShapeDidLand(swiftris: Swiftris) {}
    func gameShapeDidMove(swiftris: Swiftris) {}
    func gameShapeDidDrop(swiftris: Swiftris) {}
    func gameDidLevelUp(swiftris: Swiftris) {}

}




