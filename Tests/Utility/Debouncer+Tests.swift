//
//  Debouncer+Tests.swift
//  TweaKitTests
//
//  Created by cokile
//

@testable import TweaKit
import XCTest

class DebouncerTests: XCTestCase {
    let debouncer1 = Debouncer(dueTime: 0.3)
    let debouncer2 = Debouncer(dueTime: 0)

    override func setUp() {
        super.setUp()
        debouncer1.cancel()
    }

    func testNormalDebounceHasDueTime() {
        let exp = XCTestExpectation(description: "exp")
        exp.isInverted = true
        debouncer1.call { exp.fulfill() }
        wait(for: [exp], timeout: 0)
    }

    func testNormalDebounceHasDueTime2() {
        let exp = XCTestExpectation(description: "exp")
        debouncer1.call { exp.fulfill() }
        wait(for: [exp], timeout: debouncer1.dueTime + 0.1)
    }

    func testNormalDebounceWithinDueTime() {
        let exp1 = XCTestExpectation(description: "exp1")
        exp1.isInverted = true
        let exp2 = XCTestExpectation(description: "exp2")
        exp2.isInverted = true
        let exp3 = XCTestExpectation(description: "exp3")

        debouncer1.call { exp1.fulfill() }
        debouncer1.call { exp2.fulfill() }
        debouncer1.call { exp3.fulfill() }

        wait(for: [exp1, exp2, exp3], timeout: 2)
    }

    func testNormalDebounceExceedDueTime() {
        let exp1 = XCTestExpectation(description: "exp1")
        exp1.isInverted = true
        let exp2 = XCTestExpectation(description: "exp2")
        exp2.isInverted = true
        let exp3 = XCTestExpectation(description: "exp3")
        exp3.expectedFulfillmentCount = 3

        debouncer1.call { exp1.fulfill() }
        debouncer1.call { exp2.fulfill() }
        debouncer1.call { exp3.fulfill() }

        DispatchQueue.main.asyncAfter(deadline: .now() + debouncer1.dueTime + 0.1) {
            self.debouncer1.call { exp3.fulfill() }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + debouncer1.dueTime * 2 + 0.2) {
            self.debouncer1.call { exp3.fulfill() }
        }

        wait(for: [exp1, exp2, exp3], timeout: 2)
    }

    func testNormalDebounceCancel() {
        let exp1 = XCTestExpectation(description: "exp1")
        exp1.isInverted = true
        let exp2 = XCTestExpectation(description: "exp2")
        exp2.isInverted = true
        let exp3 = XCTestExpectation(description: "exp3")
        exp3.isInverted = true

        debouncer1.call { exp1.fulfill() }
        debouncer1.call { exp2.fulfill() }
        debouncer1.call { exp3.fulfill() }
        debouncer1.cancel()

        wait(for: [exp1, exp2, exp3], timeout: 2)
    }

    func testNormalDebounceAfterCancel() {
        let exp1 = XCTestExpectation(description: "exp1")
        exp1.isInverted = true
        let exp2 = XCTestExpectation(description: "exp2")
        exp2.isInverted = true
        let exp3 = XCTestExpectation(description: "exp3")

        debouncer1.call { exp1.fulfill() }
        debouncer1.call { exp2.fulfill() }
        debouncer1.cancel()
        debouncer1.call { exp3.fulfill() }

        wait(for: [exp1, exp2, exp3], timeout: 2)
    }

    func testInstantDebounce() {
        var seed = 0
        debouncer2.call { seed += 1 }
        debouncer2.call { seed += 1 }
        XCTAssertEqual(seed, 2)
    }

    func testInstantDebounceCancel() {
        var seed = 0
        debouncer2.call { seed += 1 }
        debouncer2.cancel()
        XCTAssertEqual(seed, 1)
    }

    func testInstantDebounceAfterCancel() {
        var seed = 0
        debouncer2.call { seed += 1 }
        debouncer2.cancel()
        XCTAssertEqual(seed, 1)

        debouncer2.call { seed += 1 }
        XCTAssertEqual(seed, 2)
    }
}
