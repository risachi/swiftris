//
//  GameScene.swift
//  swiftris
//
//  Created by Lisa on 6/5/16.
//  Copyright (c) 2016 Bloc. All rights reserved.
//

import SpriteKit

// represents the slowest speed at which the shapes will travel (600 milliseconds - every 6/10ths of a second, our shape should decend by one row)
let TickLengthLevelOne = NSTimeInterval(600)

class GameScene: SKScene {
    
    var tick:(() -> ())? // tick is a closure which takes no parameters and returns nothing. Its question mark indicates that it's optional and may be nil
    var tickLengthMillis = TickLengthLevelOne //GameScene's curring tick length (set to TickLengthLevelOne by default)
    var lastTick:NSDate? //tracks the last time we experienced a tick
    
    required init(coder aDecoder: NSCoder) {
        fatalError("NSCoder not supported")
    }
    
    override init(size: CGSize) {
        super.init(size: size)
        
        anchorPoint = CGPoint(x: 0, y: 1.0)
        
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: 0, y: 0)
        background.anchorPoint = CGPoint(x: 0, y: 1.0)
        addChild(background)
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        
        // guard checks the conditions which follow it
        // if the conditions fail, guard executes the else block
        // if lastTick is missing, the game is in a paused state and not reporting elapsed ticks, so we return
        guard let lastTick = lastTick else {
            return
        }
        // but if lastTick is present, we recover the time passed since the last execution of update by invoking timeIntervalSinceNow on our lastTick object
        // we multiply the result by -1000 to calculate a positive millisecond value
        let timePassed = lastTick.timeIntervalSinceNow * -1000.0
        // then we check if the time passed has exceeded our tickLengthMillis variable
        // if enough time has elapsed, we must report a tick, which we do by first updating our last known tick time ot hte present and then invoking our closure
        if timePassed > tickLengthMillis {
            self.lastTick = NSDate()
            // by using ? after "tick", we ask Swift to first check if tick exists and if so, invoke it with no parameters
            tick?() // this is shorthand for: if tick != nil { tick!() }
        }
    }
    
    // we provide accessor methods to let external classes stop and start the ticking process
    func startTicking() {
        lastTick = NSDate()
    }
    
    func stopTicking() {
        lastTick = nil
    }
}


