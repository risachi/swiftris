//
//  HomeViewController.swift
//  swiftris
//
//  Created by Lisa on 6/27/16.
//  Copyright © 2016 Bloc. All rights reserved.
//

import UIKit
import SpriteKit


class HomeViewController: UIViewController, UIGestureRecognizerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        AppDelegate.gc.authenticateLocalPlayer(self);
    }
    
    
    override func prepareForSegue(segue: (UIStoryboardSegue!), sender: AnyObject!) {
        if segue.identifier == "Classic" || segue.identifier == "Timed" {
            // we downcast (as!) from UIViewController to GameViewController because UIViewController doesn't have a "gameType" property, which we access below
            let gameViewController = segue.destinationViewController as! GameViewController
            gameViewController.gameType = GamePlayChoice(rawValue: segue.identifier!)
        } else {
            let gameCenterViewController = segue.destinationViewController as! GameCenterViewController
            gameCenterViewController.showLeaderboard();
        }
    }
}




