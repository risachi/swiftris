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
    var highScore: Int64 = 0
    
    
    func authenticateLocalPlayer(aViewController: UIViewController) {
        let localPlayer = GKLocalPlayer.localPlayer()
        localPlayer.authenticateHandler = {
            (viewController, error) -> Void in
                if ((viewController) != nil) {
                    aViewController.presentViewController(viewController!, animated: true, completion: nil)
                } else {
                    print("(GameCenter) Player authenticated: \(GKLocalPlayer.localPlayer().authenticated)")
                    self.loadAchievements();
                    self.loadHighScore();
                }
        }
    }
    
    
    func loadAchievements() {
        GKAchievement.loadAchievementsWithCompletionHandler({ (allAchievements, error:NSError?) -> Void in
            if error != nil {
                print("Game Center: could not load achievements, error: \(error)")
            } else {
                print("Game Center loaded achievements")
                for anAchievement in allAchievements!  {
                    print("  \(anAchievement)")
                    self.achievements[anAchievement.identifier!] = anAchievement
                }
            }
        })
    }
    
    
    func resetAchievements() {
        print("DEBUG: Resetting local player's achievements")
        
        GKAchievement.resetAchievementsWithCompletionHandler({ (error: NSError?) -> Void in
            if error != nil {
                print("   Couldn't: \(error)")
            } else {
                self.loadAchievements()
                print("   Done.")
            }
        })
    }
    
    
    func loadHighScore() {
        if (GKLocalPlayer.localPlayer().authenticated) {
            GKLeaderboard.loadLeaderboardsWithCompletionHandler { objects, error in
                if let e = error {
                    print("ERROR loading scores: \(e)")
                } else {
                    print("Loading the high score: searching for the leaderboard...")
                    if let leaderboards = objects! as [GKLeaderboard]? {
                        for leaderboard in leaderboards {
                            if let localPlayerScore = leaderboard.localPlayerScore {
                                self.highScore = localPlayerScore.value
                                print("  Got high score from the API: \(self.highScore)")
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    //
    // Return true if a new achievement was earned
    //
    func addProgressToAnAchievement(progress:Double, achievementID:String) -> Bool {
        var newAchievementWasEarned = false
        let lookupAchievement:GKAchievement? = achievements[achievementID]
        
        if let achievement = lookupAchievement {
            if achievement.percentComplete != 100 {
                achievement.percentComplete = progress
                
                if progress == 100.0  {
                    //achievement.showsCompletionBanner = true
                    notifyForNewAchievement()
                    newAchievementWasEarned = true
                }
                
                // Try to report the progress to the Game Center
                GKAchievement.reportAchievements([achievement], withCompletionHandler:  { (error:NSError?) -> Void in
                    if error != nil {
                        print("ERROR: Couldn't save achievement (\(achievementID)) progress to \(progress) %")
                    }
                })
            }
        } else { // never added progress for this achievement, create achievement now, recall to add progress
            achievements[achievementID] = GKAchievement(identifier: achievementID)
            // Recursive recall this func now that the achievement exists
            addProgressToAnAchievement(progress, achievementID: achievementID)
        }
        
        return newAchievementWasEarned
    }
    
    func reportScore(score: Int) {
        if GKLocalPlayer.localPlayer().authenticated {
            if Int64(score) > self.highScore {
                self.highScore = Int64(score)
                
                let gkScore = GKScore(leaderboardIdentifier: "scores")
                gkScore.value = Int64(score)
                GKScore.reportScores([gkScore], withCompletionHandler: ( { (error: NSError?) -> Void in
                    if (error != nil) {
                        // handle error
                        print("Error: " + error!.localizedDescription);
                    } else {
                        print("Score reported: \(gkScore.value)")
                    }
                }))
            }
        }
    }
    
    
    private func notifyForNewAchievement() {
        AppDelegate.a11y.say("Congratulations, you have a new achievement!")
        GKNotificationBanner.showBannerWithTitle("New Achievement!",
                                                 message: "Congratulations.",
                                                 duration: 7,
                                                 completionHandler: (nil)
        )
    }
    
}