//
//  Block.swift
//  swiftris
//
//  Created by Lisa on 6/10/16.
//  Copyright © 2016 Bloc. All rights reserved.
//

import SpriteKit

// define the number of colors available to Swiftris
let NumberOfColors: UInt32 = 7

// enums that implement CustomStringConvertible are capable of generating human-readable strings when debugging or printing their value to the console
enum BlockColor: Int, CustomStringConvertible {
    // provide the full list of enumerable options, one for each color beginning with Blue = 0 and ending with Yellow = 5
    case Blue = 0, Orange, Purple, Red, Teal, Yellow, Green
    
    // a code block generates the value of spriteName each time (this could be done with a function named spriteName() )
    var spriteName: String {
        switch self {
        case .Blue:
            return "blue"
        case .Orange:
            return "orange"
        case .Purple:
            return "purple"
        case .Red:
            return "red"
        case .Teal:
            return "teal"
        case .Yellow:
            return "yellow"
        case .Green:
            return "green"
        }
    }
    
    // adhering to the CustomStringConvertible property requires us to provide this function
    var description: String {
        return self.spriteName
    }
    
    // returns a random choice among the colors found in BlockColor
    static func random() -> BlockColor {
        return BlockColor(rawValue: Int(arc4random_uniform(NumberOfColors)))!
    }
}

// implements both CustomStringConvertible and Hashable protocols. Hashable allows us to store Block in Array2D
class Block: Hashable, CustomStringConvertible {
    // we don't want blocks to be able to change colors mid-game... unless this is Swiftris:Epileptic Adventures
    //Constants
    let color: BlockColor
    
    // these properties represent the location of the Block on our game board
    // the SKSpriteNode will represent the visual element of the Block which GameScene will use to render and animate each Block
    //Properties
    var column: Int
    var row: Int
    var sprite: SKSpriteNode?
    
    // this shortens the code from block.color.spriteName to block.spriteName
    var spriteName: String {
        return color.spriteName
    }
    
    // Hashable requires us to implement the hashValue calculate property
    // we return the exclusive-or of our row and column properties to generate a unique integer for each Block
    var hashValue: Int {
        return self.column ^ self.row
    }
    
    // we can place CustomStringConvertible object types in the middle of a string by surrounding them with \( and )
    // for a blue Block at row 3, column 8, printing that Block would look like:
    // print("This block is \(block)")
    // "This block is blue: [8, 3]"
    var description: String {
        return "\(color): [\(column), \(row)]"
    }
    
    init(column:Int, row:Int, color:BlockColor) {
        self.column = column
        self.row = row
        self.color = color
    }
}

// we create a custom operator == when comparing one Block with another
// returns true if both Blocks are in the same location and of the same color
// the Hashable protocol inherits from the Equitable protocol, which requires us to provide this operator
func ==(lhs: Block, rhs: Block) -> Bool {
    return lhs.column == rhs.column && lhs.row == rhs.row && lhs.color.rawValue == rhs.color.rawValue
}