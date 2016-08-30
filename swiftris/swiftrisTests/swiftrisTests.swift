//
//  swiftrisTests.swift
//  swiftrisTests
//
//  Created by Lisa on 6/5/16.
//  Copyright © 2016 Bloc. All rights reserved.
//

import XCTest
@testable import swiftris

class swiftrisTests: XCTestCase {
    
    var game : Swiftris = Swiftris();
    
    
    override func setUp() {
        super.setUp()
        game = Swiftris()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testCanCallASwiftrisFunction() {
        game.reportAchievements(0)
        XCTAssert(true)
    }
    
    func testCalculateAchievements1() {
        let config_rows = [10, 20, 30]
        let user_score  = 150
        let expected_progress : [Double] = [100.0, 75.0, 50.0]
        
        let actual_progress : [Double] = game.calculateProgress(config_rows, score: user_score)
        
        XCTAssertEqual(actual_progress, expected_progress)
    }
    
    func testCalculateAchievements2() {
        let config_rows = [25, 44, 90, 300, 700, 1000, 1844]
        let user_score  = 220
        let expected_progress : [Double] = [88.0, 50.0, 24.4, 7.3, 3.1, 2.2, 1.2]
        
        let actual_progress : [Double] = game.calculateProgress(config_rows, score: user_score)
        
        XCTAssertEqual(actual_progress, expected_progress)
    }
}
