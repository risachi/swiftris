//
//  GameScene.swift
//  swiftris
//
//  Created by Lisa on 6/5/16.
//  Copyright (c) 2016 Bloc. All rights reserved.
//

import SpriteKit

let BlockSize:CGFloat = 20.0

// represents the slowest speed at which the shapes will travel (600 milliseconds - every 6/10ths of a second, our shape should decend by one row)
let TickLengthLevelOne = NSTimeInterval(600)

class GameScene: SKScene {
    
    let gameLayer = SKNode() //sits above the background visuals
    let shapeLayer = SKNode() //sits above gameLayer
    let LayerPosition = CGPoint(x: 6, y: -6) // gives an offset from the edge of the screen
    
    var tick:(() -> ())? // tick is a closure which takes no parameters and returns nothing. Its question mark indicates that it's optional and may be nil
    var tickLengthMillis = TickLengthLevelOne //GameScene's curring tick length (set to TickLengthLevelOne by default)
    var lastTick:NSDate? //tracks the last time we experienced a tick
    
    var textureCache = Dictionary<String, SKTexture>()
    
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
        
        addChild(gameLayer)
        
        let gameBoardTexture = SKTexture(imageNamed: "gameboard")
        let gameBoard = SKSpriteNode(texture: gameBoardTexture, size: CGSizeMake(BlockSize * CGFloat(NumColumns), BlockSize * CGFloat(NumRows)))
        gameBoard.anchorPoint = CGPoint(x:0, y:1.0)
        gameBoard.position = LayerPosition
        
        shapeLayer.position = LayerPosition
        shapeLayer.addChild(gameBoard)
        gameLayer.addChild(shapeLayer)
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
    
    //returns a precise coordinate on the screen for where a block sprite belongs based on its row and column position
    //we anchor each sprite at its center, so we need to find the center coordinates before placing it in our shapeLayer object
    func pointForColumn(column: Int, row: Int) -> CGPoint {
        let x = LayerPosition.x + (CGFloat(column) * BlockSize) + (BlockSize / 2)
        let y = LayerPosition.y - ((CGFloat(row) * BlockSize) + (BlockSize / 2))
        return CGPointMake(x, y)
    }
    
    func addPreviewShapeToScene(shape:Shape, completion:() -> ()) {
        for block in shape.blocks {
            // adds a shape for the first time to the scene as a preview shape
            var texture = textureCache[block.spriteName]
            if texture == nil {
                texture = SKTexture(imageNamed: block.spriteName)
                textureCache[block.spriteName] = texture
            }
            let sprite = SKSpriteNode(texture: texture)
            // we use pointForColumn to place each block's sprite in the proper location
            // we start at row - 2 such that the preview piece animates smoothly into place from a higher location
            sprite.position = pointForColumn(block.column, row:block.row - 2)
            shapeLayer.addChild(sprite)
            block.sprite = sprite
            
            // Animation
            sprite.alpha = 0
            // SKAction objects are responsible for visually manipulating SKNode objects
            // each block will fade and move into place as it appears as part of the next piece
            // each block will move two rows down and fade from complete transparency to 70% opacity
            let moveAction = SKAction.moveTo(pointForColumn(block.column, row: block.row), duration: NSTimeInterval(0.2))
            moveAction.timingMode = .EaseOut
            let fadeInAction = SKAction.fadeAlphaTo(0.7, duration: 0.4)
            fadeInAction.timingMode = .EaseOut
            sprite.runAction(SKAction.group([moveAction, fadeInAction]))
        }
        runAction(SKAction.waitForDuration(0.4), completion: completion)
    }
    
    func movePreviewShape(shape:Shape, completion:() -> ()) {
        for block in shape.blocks {
            let sprite = block.sprite!
            let moveTo = pointForColumn(block.column, row:block.row)
            let moveToAction:SKAction = SKAction.moveTo(moveTo, duration: 0.2)
            moveToAction.timingMode = .EaseOut
            sprite.runAction(
                SKAction.group([moveToAction, SKAction.fadeAlphaTo(1.0, duration: 0.2)]), completion: {})
        }
        runAction(SKAction.waitForDuration(0.2), completion: completion)
    }
    
    func redrawShape(shape:Shape, completion:() -> ()) {
        for block in shape.blocks {
            let sprite = block.sprite!
            let moveTo = pointForColumn(block.column, row:block.row)
            let moveToAction:SKAction = SKAction.moveTo(moveTo, duration: 0.05)
            moveToAction.timingMode = .EaseOut
            if block == shape.blocks.last {
                sprite.runAction(moveToAction, completion: completion)
            } else {
                sprite.runAction(moveToAction)
            }
        }
    }
}


