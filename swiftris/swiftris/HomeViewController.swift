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

    var achievements=[String:GKAchievement]()
    
    
    func authenticateLocalPlayer(){
        var localPlayer = GKLocalPlayer.localPlayer()
        localPlayer.authenticateHandler = {(viewController, error) -> Void in
            if ((viewController) != nil) {
                self.presentViewController(viewController!, animated: true, completion: nil)
            }else{
                print("(GameCenter) Player authenticated: \(GKLocalPlayer.localPlayer().authenticated)")
                
                self.loadAchievements();
                self.gameCenterAddProgressToAnAchievement(100.00, achievementID: "break_25_rows")
                self.gameCenterAddProgressToAnAchievement(100.00, achievementID: "break_44_rows")
                self.gameCenterAddProgressToAnAchievement(50.00, achievementID: "break_90_rows")
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
    
    

    
    
    func loadAchievements(){
        // load all prev. achievements for GameCenter for the user to progress can be added
        var allAchievements=[GKAchievement]()
        
        GKAchievement.loadAchievementsWithCompletionHandler({ (allAchievements, error:NSError?) -> Void in
            if error != nil {
                print("Game Center: could not load achievements, error: \(error)")
            } else {
                print("Game Center loaded achievements")
                for anAchievement in allAchievements!  {
                    print("  \(anAchievement)")
                    if let oneAchievement = anAchievement as? GKAchievement {
                        self.achievements[oneAchievement.identifier!] = oneAchievement
                    }
                }
            }
        })
    }
    
    // add progress to an achievement
    func gameCenterAddProgressToAnAchievement(progress:Double,achievementID:String) {
        print("func gameCenterAddProgressToAnAchievement successfully called")
        let lookupAchievement:GKAchievement? = achievements[achievementID]
            
        if let achievement = lookupAchievement {
            print("looking up achievement...")
            // found the achievement with the given achievementID, check if it already 100% done
            if achievement.percentComplete != 100 {
                print("achievement != 100")
                // set new progress
                achievement.percentComplete = progress
                if progress == 100.0  {
                    print("achievement = 100")
                    achievement.showsCompletionBanner=true
                }  // show banner only if achievement is fully granted (progress is 100%)
                    
                // try to report the progress to the Game Center
                GKAchievement.reportAchievements([achievement], withCompletionHandler:  {(var error:NSError?) -> Void in
                    if error != nil {
                        print("Couldn't save achievement (\(achievementID)) progress to \(progress) %")
                    }
                })
            } else {// achievement already granted, nothing to do
                print("DEBUG: Achievement (\(achievementID)) already granted")}
        } else { // never added  progress for this achievement, create achievement now, recall to add progress
            print("No achievement with ID (\(achievementID)) was found, no progress for this one was recoreded yet. Create achievement now.")
            achievements[achievementID] = GKAchievement(identifier: achievementID)
            // recursive recall this func now that the achievement exist
            gameCenterAddProgressToAnAchievement(progress, achievementID: achievementID)
        }
    }
}




