//
//  Debouncer+Tests.swift
//  TweaKitTests
//
//  Created by cokile
//

import XCTest
@testable import TweaKit

class DebouncerTests: XCTestCase {
    let deboncer1 = Debouncer(dueTime: 0.3)
    let deboncer2 = Debouncer(dueTime: 0)
    
    override func setUp() {
        super.setUp()
        deboncer1.cancel()
    }
    
    func testNormalDebounceHasDueTime() {
        let exp = XCTestExpectation(description: "exp")
        exp.isInverted = true
        deboncer1.call { exp.fulfill() }
        wait(for: [exp], timeout: 0)
    }
    
    func testNormalDebounceHasDueTime2() {
        let exp = XCTestExpectation(description: "exp")
        deboncer1.call { exp.fulfill() }
        wait(for: [exp], timeout: deboncer1.dueTime + 0.1)
    }
    
    func testNormalDebounceWithinDueTime() {
        let exp1 = XCTestExpectation(description: "exp1")
        exp1.isInverted = true
        let exp2 = XCTestExpectation(description: "exp2")
        exp2.isInverted = true
        let exp3 = XCTestExpectation(description: "exp3")
        
        deboncer1.call { exp1.fulfill() }
        deboncer1.call { exp2.fulfill() }
        deboncer1.call { exp3.fulfill() }
        
        wait(for: [exp1, exp2, exp3], timeout: 2)
    }
    
    func testNormalDebounceExceedDueTime() {
        let exp1 = XCTestExpectation(description: "exp1")
        exp1.isInverted = true
        let exp2 = XCTestExpectation(description: "exp2")
        exp2.isInverted = true
        let exp3 = XCTestExpectation(description: "exp3")
        exp3.expectedFulfillmentCount = 3
        
        deboncer1.call { exp1.fulfill() }
        deboncer1.call { exp2.fulfill() }
        deboncer1.call { exp3.fulfill() }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + deboncer1.dueTime + 0.1) {
            self.deboncer1.call { exp3.fulfill() }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + deboncer1.dueTime * 2 + 0.2) {
            self.deboncer1.call { exp3.fulfill() }
        }

        wait(for: [exp1, exp2, exp3], timeout: 2)
    }
    
    func testNormalDebonceCancel() {
        let exp1 = XCTestExpectation(description: "exp1")
        exp1.isInverted = true
        let exp2 = XCTestExpectation(description: "exp2")
        exp2.isInverted = true
        let exp3 = XCTestExpectation(description: "exp3")
        exp3.isInverted = true
        
        deboncer1.call { exp1.fulfill() }
        deboncer1.call { exp2.fulfill() }
        deboncer1.call { exp3.fulfill() }
        deboncer1.cancel()
        
        wait(for: [exp1, exp2, exp3], timeout: 2)
    }
    
    func testlNormalDebounceAfterCancel() {
        let exp1 = XCTestExpectation(description: "exp1")
        exp1.isInverted = true
        let exp2 = XCTestExpectation(description: "exp2")
        exp2.isInverted = true
        let exp3 = XCTestExpectation(description: "exp3")
        
        deboncer1.call { exp1.fulfill() }
        deboncer1.call { exp2.fulfill() }
        deboncer1.cancel()
        deboncer1.call { exp3.fulfill() }
        
        wait(for: [exp1, exp2, exp3], timeout: 2)
    }
    
    func testInstantDebounce() {
        var seed = 0
        deboncer2.call { seed += 1 }
        deboncer2.call { seed += 1 }
        XCTAssertEqual(seed, 2)
    }
    
    func testInstantDebounceCancel() {
        var seed = 0
        deboncer2.call { seed += 1 }
        deboncer2.cancel()
        XCTAssertEqual(seed, 1)
    }
    
    func testInstantDebounceAfterCancel() {
        var seed = 0
        deboncer2.call { seed += 1 }
        deboncer2.cancel()
        XCTAssertEqual(seed, 1)
        
        deboncer2.call { seed += 1 }
        XCTAssertEqual(seed, 2)
    }
}
