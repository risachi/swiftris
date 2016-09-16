//
//  Swiftris.swift
//  swiftris
//
//  Created by Lisa on 6/14/16.
//  Copyright © 2016 Bloc. All rights reserved.
//

import Foundation

let NumColumns = 10
let NumRows = 20

let StartingColumn = 4
let StartingRow = 0

let PreviewColumn = 12
let PreviewRow = 1

//"Even a game as sophisticated and well-traveled as Swiftris must admit that its players feed off of small psychological rewards, meaningless as they may be
let PointsPerLine = 10
let LevelThreshold = 100


protocol SwiftrisDelegate {
    func gameDidEnd(swiftris: Swiftris)
    
    func gameDidPause(swiftris: Swiftris)
    
    func gameDidUnpause(swiftris: Swiftris)
    
    func gameDidBegin(swiftris: Swiftris)
    
    func gameShapeDidLand(swiftris: Swiftris)
    
    func gameShapeDidMove(swiftris: Swiftris)
    
    func gameShapeDidDrop(swiftris: Swiftris)
    
    func gameDidLevelUp(swiftris: Swiftris)
}

enum GamePlayChoice: String {
    case Classic, Timed
}

class Swiftris {
    var blockArray:Array2D<Block>
    var nextShape:Shape?
    var fallingShape:Shape?
    var delegate:SwiftrisDelegate?
    
    var isPaused = false
    
    var score = 0
    var level = 1
    var gameChoice = GamePlayChoice.Timed
    
    var startTime:NSDate
    let gameLengthInSeconds = 120.0
    
    init() {
        fallingShape = nil
        nextShape = nil
        blockArray = Array2D<Block>(columns: NumColumns, rows: NumRows)
        self.startTime = NSDate()
    }
    
    func beginGame() {
        if (nextShape == nil) {
            nextShape = Shape.random(PreviewColumn, startingRow: PreviewRow)
        }
        delegate?.gameDidBegin(self)
        
        self.startTime = NSDate()
    }
        
    func newShape() -> (fallingShape:Shape?, nextShape:Shape?) {
        fallingShape = nextShape
        nextShape = Shape.random(PreviewColumn, startingRow: PreviewRow)
        fallingShape?.moveTo(StartingColumn, row: StartingRow)
        
        // When there's no more room to move a new shape or we're out of time
        guard detectIllegalPlacement() == false && detectTimedGameOver() == false else {
            nextShape = fallingShape
            nextShape!.moveTo(PreviewColumn, row: PreviewRow)
            endGame()
            return (nil, nil)
        }
        return (fallingShape, nextShape)
    }
    
    func detectIllegalPlacement() -> Bool {
        guard let shape = fallingShape else {
            return false
        }
        for block in shape.blocks {
            if block.column < 0 || block.column >= NumColumns
                || block.row < 0 || block.row >= NumRows {
                return true
            } else if blockArray[block.column, block.row] != nil {
                return true
            }
        }
        return false
    }
    
    // adds the falling shape to the collection of blocks maintained by Swiftris
    // once the falling shape's blocks are part of the game board, we nullify fallingShape and notify the delegate of a new shape settling onto the game board
    func settleShape() {
        guard let shape = fallingShape else {
            return
        }
        for block in shape.blocks {
            blockArray[block.column, block.row] = block
        }
        fallingShape = nil
        delegate?.gameShapeDidLand(self)
    }
    
    // detects when a block should settle
    // a block settles either 1) when one of the shapes' bottom blocks touches a block on the game board, or
    // 2) when one of those same blocks has reached the bottom of the game board
    func detectTouch() -> Bool {
        guard let shape = fallingShape else {
            return false
        }
        for bottomBlock in shape.bottomBlocks {
            if bottomBlock.row == NumRows - 1
                || blockArray[bottomBlock.column, bottomBlock.row + 1] != nil {
                return true
            }
        }
        return false
    }
    
    
    func endGame() {
        AppDelegate.gc.reportScore(score);
        score = 0
        level = 1
        delegate?.gameDidEnd(self)
    }
    
    
    func togglePauseState() {
        if isPaused {
            _unpauseGame()
            isPaused = false
        } else {
            _pauseGame()
            isPaused = true
        }
    }
    
    
    func _unpauseGame() {
        delegate?.gameDidUnpause(self)
    }
    
    
    func _pauseGame() {
        delegate?.gameDidPause(self)
    }
    
    
    //linesRemoved maintains each row of blocks which the user has filled in
    func removeCompletedLines() -> (linesRemoved: Array<Array<Block>>, fallenBlocks: Array<Array<Block>>, beQuiet: Bool) {
        var beQuiet: Bool
        var removedLines = Array<Array<Block>>()
        for row in (1..<NumRows).reverse() {
            var rowOfBlocks = Array<Block>()
            
            //adds every block in a given row to a local array variable named rowOfBlocks
            //if it ends up with a full set, 10 blocks in total, it counts that as a removed line and adds it to the return variable
            for column in 0..<NumColumns {
                guard let block = blockArray[column, row] else {
                    continue
                }
                rowOfBlocks.append(block)
            }
            if rowOfBlocks.count == NumColumns {
                removedLines.append(rowOfBlocks)
                for block in rowOfBlocks {
                    blockArray[block.column, block.row] = nil
                }
            }
        }
        
        // Did we recover any lines? if not, we return empty arrays
        if removedLines.count == 0 {
            return ([], [], false)
        }
        
        //we add points to the player's score based on the number of lines they've created and their level
        //if the user's points exceed their level times 1000, they level up and we inform the delegate
        let pointsEarned = removedLines.count * PointsPerLine * level
        score += pointsEarned
        beQuiet = reportAchievements(score)
        
        if score >= level * LevelThreshold {
            level += 1
            delegate?.gameDidLevelUp(self)
        }
        
        var fallenBlocks = Array<Array<Block>>()
        for column in 0..<NumColumns {
            var fallenBlocksArray = Array<Block>()
            
            //starting in the left-most column and above the bottom-most removed line, we count upwards towards the top of the game board
            //as we count up, we take each remaining block we find on the game board and lower it as far as possible
            //fallenBlocks is an array of arrays and we've filled each sub-array with blocks that fell to a new position as a result of the user clearing lines beneath them
            for row in (1..<removedLines[0][0].row).reverse() {
                guard let block = blockArray[column, row] else {
                    continue
                }
                var newRow = row
                while (newRow < NumRows - 1 && blockArray[column, newRow + 1] == nil) {
                    newRow += 1
                }
                block.row = newRow
                blockArray[column, row] = nil
                blockArray[column, newRow] = block
                fallenBlocksArray.append(block)
            }
            if fallenBlocksArray.count > 0 {
                fallenBlocks.append(fallenBlocksArray)
            }
        }
        return (removedLines, fallenBlocks, beQuiet)
    }
    
    //this function allows the user interface to remove the blocks
    //loops through, creates rows of blocks in order for the game scene to animate them off the game board
    //it nullifies each location in the block array to empty it entirely, preparing it for a new game
    func removeAllBlocks() -> Array<Array<Block>> {
        var allBlocks = Array<Array<Block>>()
        for row in 0..<NumRows {
            var rowOfBlocks = Array<Block>()
            for column in 0..<NumColumns {
                guard let block = blockArray[column, row] else {
                    continue
                }
                rowOfBlocks.append(block)
                blockArray[column, row] = nil
            }
            allBlocks.append(rowOfBlocks)
        }
        return allBlocks
    }
    
    func dropShape() {
        guard let shape = fallingShape else {
            return
        }
        while detectIllegalPlacement() == false {
            shape.lowerShapeByOneRow()
        }
        shape.raiseShapeByOneRow()
        delegate?.gameShapeDidDrop(self)
    }
    
    func detectTimedGameOver() -> Bool {
        return (gameChoice == GamePlayChoice.Timed) && (gameLengthInSeconds < elapsedTime())
    }
    
    func timeRemaining() -> String {
        let result = gameLengthInSeconds - elapsedTime()
        
        let time = Int(result)
        let secs = String(format: "%02d", time % 60)
        let mins = String(time / 60)
        let formattedString = "\(mins):\(secs)"

        return (result > 0) ? formattedString : "0:00"
    }
    
    func elapsedTime() -> Double {
        return startTime.timeIntervalSinceNow * -1
    }
    
    // every tick, the shape is lowered by one row
    // the game ends if it fails to do so without finding legal placement for it
    func letShapeFall() {
        guard let shape = fallingShape else {
            return
        }

        shape.lowerShapeByOneRow()
        
        if detectIllegalPlacement() {
            shape.raiseShapeByOneRow()
            if detectIllegalPlacement() {
                endGame()
            } else {
                settleShape()
            }
        } else {
            delegate?.gameShapeDidMove(self)
            if detectTouch() {
                settleShape()
            }
        }
    }
    
    // the player can rotate the shape clockwise as it falls
    // if the new block posititons violate the boundaries of the game or overlap with settled blocks, we revert the rotation and return
    // otherwise, we let the delegate know that the shape has moved
    func rotateShape() {
        guard let shape = fallingShape else {
            return
        }
        shape.rotateClockwise()
        guard detectIllegalPlacement() == false else {
            AppDelegate.a11y.say("Cannot move further")
            shape.rotateCounterClockwise()
            return
        }
        delegate?.gameShapeDidMove(self)
    }

    func moveShapeLeft() {
        guard let shape = fallingShape else {
            return
        }
        shape.shiftLeftByOneColumn()
        guard detectIllegalPlacement() == false else {
            shape.shiftRightByOneColumn()
            return
        }
        delegate?.gameShapeDidMove(self)
    }
    
    func moveShapeRight() {
        guard let shape = fallingShape else {
            return
        }
        shape.shiftRightByOneColumn()
        guard detectIllegalPlacement() == false else {
            shape.shiftLeftByOneColumn()
            return
        }
        delegate?.gameShapeDidMove(self)
    }
    
    //
    // Return true if a new achievement was earned
    //
    func reportAchievements(score: Int) -> Bool {
        var newAchievementWasEarned = false
        
        let achievements = [25, 44, 90, 300, 700, 1000, 1844]
        let progress     = calculateProgress(achievements, score: score)
        for (index, achievement) in achievements.enumerate() {
            let id = "break_\(achievement)_rows"
            let percent = progress[index]
            if (AppDelegate.gc.addProgressToAnAchievement(percent, achievementID: id)) {
                newAchievementWasEarned = true
            }
        }
        
        return newAchievementWasEarned
    }
    
    func calculateProgress(config: [Int], score: Int) -> [Double] {
        let rowsCleared = score / 10
        return config.map { roundToOneDecimal(min(100, Double(rowsCleared) / Double($0) * 100)) }
    }
    
    func roundToOneDecimal(n: Double) -> Double {
        return round(n * 10) / 10
    }
    
}
