//
//  Swiftris.swift
//  swiftris
//
//  Created by Lisa on 6/14/16.
//  Copyright © 2016 Bloc. All rights reserved.
//


let NumColumns = 10
let NumRows = 20

let StartingColumn = 4
let StartingRow = 0

let PreviewColumn = 12
let PreviewRow = 1

//"Even a game as sophisticated and well-traveled as Swiftris must admit that its players feed off of small psychological rewards, meaningless as they may be
let PointsPerLine = 10
let LevelThreshold = 500

protocol SwiftrisDelegate {
    // Invoked when the current round of Swiftris ends
    func gameDidEnd(swiftris: Swiftris)
    
    // Invoked after a new game has begun
    func gameDidBegin(swiftris: Swiftris)
    
    // Invoked when the falling shape has become part of the game board
    func gameShapeDidLand(swiftris: Swiftris)
    
    // Invoked when the falling shape has changed its location
    func gameShapeDidMove(swiftris: Swiftris)
    
    // Invoked when the falling shape has changed its location after being dropped
    func gameShapeDidDrop(swiftris: Swiftris)
    
    // Invoked when the game has reached a new level
    func gameDidLevelUp(swiftris: Swiftris)
}

class Swiftris {
    var blockArray:Array2D<Block>
    var nextShape:Shape?
    var fallingShape:Shape?
    var delegate:SwiftrisDelegate?
    
    var score = 0
    var level = 1
    
    init() {
        fallingShape = nil
        nextShape = nil
        blockArray = Array2D<Block>(columns: NumColumns, rows: NumRows)
    }
    
    func beginGame() {
        if (nextShape == nil) {
            nextShape = Shape.random(PreviewColumn, startingRow: PreviewRow)
        }
        delegate?.gameDidBegin(self)
    }
    
    func newShape() -> (fallingShape:Shape?, nextShape:Shape?) {
        fallingShape = nextShape
        nextShape = Shape.random(PreviewColumn, startingRow: PreviewRow)
        fallingShape?.moveTo(StartingColumn, row: StartingRow)
        
        //when there's no more room to move a new shape
        guard detectIllegalPlacement() == false else {
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
        score = 0
        level = 1
        delegate?.gameDidEnd(self)
    }
    
    //this function returns a tuple composed of two arrays (linesRemoved and fallenBlocks)
    //linesRemoved maintains each row of blocks which the user has filled in
    func removeCompletedLines() -> (linesRemoved: Array<Array<Block>>, fallenBlocks: Array<Array<Block>>) {
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
        
        //did we recover any lines? if not, we return empty arrays
        if removedLines.count == 0 {
            return ([], [])
        }
        
        //we add points to the player's score based on the number of lines they've created and their level
        //if the user's points exceed their level times 1000, they level up and we inform the delegate
        let pointsEarned = removedLines.count * PointsPerLine * level
        score += pointsEarned
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
        return (removedLines, fallenBlocks)
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
}
