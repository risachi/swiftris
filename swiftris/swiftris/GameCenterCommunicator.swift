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
                GKAchievement.reportAchievements([achievement], withCompletionHandler:  {( error:NSError?) -> Void in
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