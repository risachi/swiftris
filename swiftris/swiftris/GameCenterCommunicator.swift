//
//  GameCenterCommunicator.swift
//  swiftris
//
//  Created by Lisa on 8/21/16.
//  Copyright © 2016 Bloc. All rights reserved.
//

import Foundation
import GameKit


class GameCenterCommunicator {
    var achievements = [String:GKAchievement]()
    
    
    func authenticateLocalPlayer(aViewController: UIViewController) {
        let localPlayer = GKLocalPlayer.localPlayer()
        localPlayer.authenticateHandler = {
            (viewController, error) -> Void in
                if ((viewController) != nil) {
                    aViewController.presentViewController(viewController!, animated: true, completion: nil)
                } else {
                    print("(GameCenter) Player authenticated: \(GKLocalPlayer.localPlayer().authenticated)")
                    self.loadAchievements();
                }
        }
    }
    
    
    func loadAchievements(){
        // load all prev. achievements for GameCenter for the user to progress can be added
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
    
    
    func gameCenterAddProgressToAnAchievement(progress:Double, achievementID:String) {
        let lookupAchievement:GKAchievement? = achievements[achievementID]
        
        if let achievement = lookupAchievement {
            if achievement.percentComplete != 100 {
                achievement.percentComplete = progress
                if progress == 100.0  {
                    achievement.showsCompletionBanner = true
                }
                
                // Try to report the progress to the Game Center
                GKAchievement.reportAchievements([achievement], withCompletionHandler:  { (error:NSError?) -> Void in
                    if error != nil {
                        print("ERROR: Couldn't save achievement (\(achievementID)) progress to \(progress) %")
                    }
                })
            }
        } else { // never added  progress for this achievement, create achievement now, recall to add progress
            achievements[achievementID] = GKAchievement(identifier: achievementID)
            // Recursive recall this func now that the achievement exists
            gameCenterAddProgressToAnAchievement(progress, achievementID: achievementID)
        }
    }

}