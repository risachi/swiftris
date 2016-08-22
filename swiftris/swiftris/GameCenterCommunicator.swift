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
    
    // add progress to an achievement
    func gameCenterAddProgressToAnAchievement(progress:Double, achievementID:String) {
        let lookupAchievement:GKAchievement? = achievements[achievementID]
        
        if let achievement = lookupAchievement {
            // found the achievement with the given achievementID, check if it already 100% done
            if achievement.percentComplete != 100 {
                achievement.percentComplete = progress
                if progress == 100.0  {
                    print("DEBUG: achievement == 100, showing banner")
                    achievement.showsCompletionBanner = true
                }
                
                // Try to report the progress to the Game Center
                print("DEBUG: Reporting progress...")
                GKAchievement.reportAchievements([achievement], withCompletionHandler:  { (error:NSError?) -> Void in
                    if error != nil {
                        print("ERROR: Couldn't save achievement (\(achievementID)) progress to \(progress) %")
                    } else {
                        print("DEBUG:   Success.")
                    }
                })
            } else {
                print("DEBUG: Achievement (\(achievementID)) already granted, doing nothing.")}
        } else { // never added  progress for this achievement, create achievement now, recall to add progress
            print("DEBUG: No achievement with ID (\(achievementID)) was found, no progress for this one was recorded yet. Creating achievement now.")
            achievements[achievementID] = GKAchievement(identifier: achievementID)
            
            // recursive recall this func now that the achievement exists
            gameCenterAddProgressToAnAchievement(progress, achievementID: achievementID)
        }
    }

}