//
//  BlocFitTests.swift
//  BlocFitTests
//
//  Created by Colin Conduff on 9/30/16.
//  Copyright © 2016 Colin Conduff. All rights reserved.
//

import XCTest
@testable import BlocFit

class BlocFitTests: XCTestCase {
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation 
        //   of each test method in the class.
    }
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation 
        //   of each test method in the class.
        super.tearDown()
    }
    
    func testStringFrom() {
        let testCases: [(seconds: Double, expected: String)] = [
            (seconds: 0, expected: "0:00"),
            (seconds: 59, expected: "0:59"),
            (seconds: 60, expected: "1:00"),
            (seconds: 119, expected: "1:59"),
            (seconds: 10*60, expected: "10:00"),
            (seconds: 10*60+59, expected: "10:59"),
            (seconds: 60*60, expected: "01:00:00"),
            (seconds: 60*60+59*60+59, expected: "01:59:59"),
        ]
        
        for testCase in testCases {
            let received = BFFormatter.stringFrom(totalSeconds: testCase.seconds)
            XCTAssertTrue(received == testCase.expected)
        }
    }
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
}
