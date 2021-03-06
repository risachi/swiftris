//
//  ZShape.swift
//  swiftris
//
//  Created by Lisa on 6/14/16.
//  Copyright © 2016 Bloc. All rights reserved.
//

class ZShape:Shape {
    /*
     
     Orientation 0
     
       • | 0 |
     | 2 | 1 |
     | 3 |
     
     Orientation 90
     
     | 0 | 1•|
         | 2 | 3 |
     
     Orientation 180
     
       • | 0 |
     | 2 | 1 |
     | 3 |
     
     Orientation 270
     
     | 0 | 1•|
         | 2 | 3 |
     
     
     • marks the row/column indicator for the shape
     
     */
    
    override func color() -> BlockColor {
        return BlockColor.Teal
    }
    
    override func verbalDescription() -> String {
        return "Z shape"
    }
    
    override var blockRowColumnPositions: [Orientation: Array<(columnDiff: Int, rowDiff: Int)>] {
        return [
            Orientation.Zero:       [(1, 0), (1, 1), (0, 1), (0, 2)],
            Orientation.Ninety:     [(-1,0), (0, 0), (0, 1), (1, 1)],
            Orientation.OneEighty:  [(1, 0), (1, 1), (0, 1), (0, 2)],
            Orientation.TwoSeventy: [(-1,0), (0, 0), (0, 1), (1, 1)]
        ]
    }
    
    override var bottomBlocksForOrientations: [Orientation: Array<Block>] {
        return [
            Orientation.Zero:       [blocks[SecondBlockIdx], blocks[FourthBlockIdx]],
            Orientation.Ninety:     [blocks[FirstBlockIdx], blocks[ThirdBlockIdx], blocks[FourthBlockIdx]],
            Orientation.OneEighty:  [blocks[SecondBlockIdx], blocks[FourthBlockIdx]],
            Orientation.TwoSeventy: [blocks[FirstBlockIdx], blocks[ThirdBlockIdx], blocks[FourthBlockIdx]]
        ]
    }
}
