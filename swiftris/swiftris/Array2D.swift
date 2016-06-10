//
//  Array2D.swift
//  swiftris
//
//  Created by Lisa on 6/9/16.
//  Copyright © 2016 Bloc. All rights reserved.
//

// define a class named Array2D
// <T> allows the array to store any data type
class Array2D<T> {
    let columns: Int
    let rows: Int
    // declare an array with type <T?>
    var array: Array<T?>
    
    init(columns: Int, rows: Int) {
        self.columns = columns
        self.rows = rows
        
        //instantiate our array structure with a size of rows x columns
        //this guarantees that Array2D can store all the objects our goame board requires, 200 in our case
        array = Array<T?>(count:rows * columns, repeatedValue: nil)
    }
    
    //create a custom subscript for Array2D
    subscript(column: Int, row: Int) -> T? {
        get {
            return array[(row * columns) + column]
        }
        set(newValue) {
            array[(row * columns) + column] = newValue
        }
    }
}