//
//  TweakStore+Tests.swift
//  TweaKitTests
//
//  Created by cokile
//

import XCTest
@testable import TweaKit

class TweakStoreTests: XCTestCase {
    let store1 = TweakStore(name: "Test_Store_1")
    let store2 = TweakStore(name: "Test_Store_2")
    
    override func setUp() {
        super.setUp()
        store1.removeAll()
        store2.removeAll()
    }
    
    func testCRUD() {
        XCTAssertFalse(store1.hasValue(forKey: "k1"))
        XCTAssertFalse(store1.hasValue(forKey: "k2"))
        XCTAssertFalse(store1.hasValue(forKey: "k3"))
        
        store1.setValue(1, forKey: "k1")
        store1.setValue(2, forKey: "k2")
        
        XCTAssertEqual(store1.int(forKey: "k1"), 1)
        XCTAssertTrue(store1.hasValue(forKey: "k1"))
        XCTAssertEqual(store1.int(forKey: "k2"), 2)
        XCTAssertTrue(store1.hasValue(forKey: "k2"))
        
        store1.removeValue(forKey: "k3")
        XCTAssertEqual(store1.int(forKey: "k1"), 1)
        XCTAssertTrue(store1.hasValue(forKey: "k1"))
        XCTAssertEqual(store1.int(forKey: "k2"), 2)
        XCTAssertTrue(store1.hasValue(forKey: "k2"))
        
        store1.removeValue(forKey: "k1")
        XCTAssertNil(store1.int(forKey: "k1"))
        XCTAssertFalse(store1.hasValue(forKey: "k1"))
        XCTAssertEqual(store1.int(forKey: "k2"), 2)
        XCTAssertTrue(store1.hasValue(forKey: "k2"))
        
        store1.removeAll()
        XCTAssertNil(store1.int(forKey: "k1"))
        XCTAssertFalse(store1.hasValue(forKey: "k1"))
        XCTAssertNil(store1.int(forKey: "k2"))
        XCTAssertFalse(store1.hasValue(forKey: "k2"))
    }
    
    func testStoreIsolation() {
        XCTAssertFalse(store1.hasValue(forKey: "k1"))
        XCTAssertFalse(store2.hasValue(forKey: "k1"))
        
        store1.setValue(1, forKey: "k1")
        XCTAssertEqual(store1.int(forKey: "k1"), 1)
        XCTAssertTrue(store1.hasValue(forKey: "k1"))
        XCTAssertNil(store2.int(forKey: "k1"))
        XCTAssertFalse(store2.hasValue(forKey: "k1"))
        
        store2.setValue(2, forKey: "k1")
        XCTAssertEqual(store1.int(forKey: "k1"), 1)
        XCTAssertTrue(store1.hasValue(forKey: "k1"))
        XCTAssertEqual(store2.int(forKey: "k1"), 2)
        XCTAssertTrue(store2.hasValue(forKey: "k1"))
        
        store1.removeValue(forKey: "k1")
        XCTAssertNil(store1.int(forKey: "k1"))
        XCTAssertFalse(store1.hasValue(forKey: "k1"))
        XCTAssertEqual(store2.int(forKey: "k1"), 2)
        XCTAssertTrue(store2.hasValue(forKey: "k1"))
    }
    
    func testNotifyNew() {
        let exp1 = expectation(description: "k1 notify 1")
        let exp2 = expectation(description: "k1 notify 2")
        let exp3 = expectation(description: "k1 notify 3")
        let exp4 = expectation(description: "k1 notify nil")
        
        _ = store1.startNotifying(forKey: "k1") { _, new, _ in
            let int = new.flatMap(Int.convert(from:))
            if int == 1 {
                exp1.fulfill()
            } else if int == 2 {
                exp2.fulfill()
            } else if int == 3 {
                exp3.fulfill()
            } else if int == nil {
                exp4.fulfill()
            }
        }
        
        store1.setValue(1, forKey: "k1")
        store1.setValue(2, forKey: "k1")
        store1.setValue(3, forKey: "k1")
        store1.removeValue(forKey: "k1")
        
        wait(for: [exp1, exp2, exp3, exp4], timeout: 1, enforceOrder: false)
    }
    
    func testNotifyOld() {
        let exp1 = expectation(description: "k1 notify nil")
        let exp2 = expectation(description: "k1 notify 1")
        let exp3 = expectation(description: "k1 notify 2")
        let exp4 = expectation(description: "k1 notify 3")

        _ = store1.startNotifying(forKey: "k1") { old, _, _ in
            let int = old.flatMap(Int.convert(from:))
            if old == nil {
                exp1.fulfill()
            } else if int == 1 {
                exp2.fulfill()
            } else if int == 2 {
                exp3.fulfill()
            } else if int == 3 {
                exp4.fulfill()
            }
        }
        
        store1.setValue(1, forKey: "k1")
        store1.setValue(2, forKey: "k1")
        store1.setValue(3, forKey: "k1")
        store1.removeValue(forKey: "k1")
        
        wait(for: [exp1, exp2, exp3, exp4], timeout: 1, enforceOrder: false)
    }
    
    func testNotifyManually() {
        let exp = expectation(description: "k1 notify 1")
        
        _ = store1.startNotifying(forKey: "k1") { _, new, manually in
            if new.flatMap(Int.convert(from:)) == 1 {
                XCTAssertTrue(manually)
                exp.fulfill()
            }
        }
        
        store1.setValue(1, forKey: "k1", manually: true)
        
        wait(for: [exp], timeout: 1)
    }
    
    func testNotifyNotManually() {
        let exp = expectation(description: "k1 notify 1")
        
        _ = store1.startNotifying(forKey: "k1") { _, new, manually in
            if new.flatMap(Int.convert(from:)) == 1 {
                XCTAssertFalse(manually)
                exp.fulfill()
            }
        }
        
        store1.setValue(1, forKey: "k1", manually: false)
        
        wait(for: [exp], timeout: 1)
    }
    
    func testNotifyRemoveAll() {
        let exp1 = expectation(description: "k1 notify")
        let exp2 = expectation(description: "k2 notify")
        let exp3 = expectation(description: "k3 notify")
        exp3.isInverted = true
        
        store1.setValue(1, forKey: "k1")
        store1.setValue(2, forKey: "k2")
        
        _ = store1.startNotifying(forKey: "k1") { _, new, _ in
            if new == nil {
                exp1.fulfill()
            }
        }
        _ = store1.startNotifying(forKey: "k2") { _, new, _ in
            if new == nil {
                exp2.fulfill()
            }
        }
        _ = store1.startNotifying(forKey: "k3") { _, new, _ in
            if new == nil {
                exp3.fulfill()
            }
        }
        store1.removeAll()
        
        wait(for: [exp1, exp2, exp3], timeout: 1, enforceOrder: false)
    }
    
    func testStopNotifyingKey() {
        let exp1 = expectation(description: "k1 notify 1")
        exp1.expectedFulfillmentCount = 2
        let exp2 = expectation(description: "k1 notify 2")
        exp2.expectedFulfillmentCount = 2
        let exp3 = expectation(description: "k1 notify 3")
        exp3.isInverted = true
        
        _ = store1.startNotifying(forKey: "k1") { _, new, _ in
            let int = new.flatMap(Int.convert(from:))
            if int == 1 {
                exp1.fulfill()
            } else if int == 2 {
                exp2.fulfill()
            } else if int == 3 {
                exp3.fulfill()
            }
        }
        _ = store1.startNotifying(forKey: "k1") { _, new, _ in
            let int = new.flatMap(Int.convert(from:))
            if int == 1 {
                exp1.fulfill()
            } else if int == 2 {
                exp2.fulfill()
            } else if int == 3 {
                exp3.fulfill()
            }
        }
        
        store1.setValue(1, forKey: "k1")
        store1.setValue(2, forKey: "k1")
        store1.stopNotifying(forKey: "k1")
        store1.setValue(3, forKey: "k1")
        
        wait(for: [exp1, exp2, exp3], timeout: 1, enforceOrder: false)
    }
    
    func testStopNotifyingToken() {
        let exp1 = expectation(description: "k1 notify 1")
        exp1.expectedFulfillmentCount = 2
        let exp2 = expectation(description: "k1 notify 2")
        exp2.expectedFulfillmentCount = 2
        let exp3 = expectation(description: "k1 notify 3")
        
        _ = store1.startNotifying(forKey: "k1") { _, new, _ in
            let int = new.flatMap(Int.convert(from:))
            if int == 1 {
                exp1.fulfill()
            } else if int == 2 {
                exp2.fulfill()
            } else if int == 3 {
                exp3.fulfill()
            }
        }
        let token = store1.startNotifying(forKey: "k1") { _, new, _ in
            let int = new.flatMap(Int.convert(from:))
            if int == 1 {
                exp1.fulfill()
            } else if int == 2 {
                exp2.fulfill()
            } else if int == 3 {
                exp3.fulfill()
            }
        }
        
        store1.setValue(1, forKey: "k1")
        store1.setValue(2, forKey: "k1")
        store1.stopNotifying(ForToken: token)
        store1.setValue(3, forKey: "k1")
        
        wait(for: [exp1, exp2, exp3], timeout: 1, enforceOrder: false)
    }
    
    func testRawData() {
        XCTAssertNil(store1.rawData(forKey: "k1"))
        store1.setValue(1, forKey: "k1")
        XCTAssertNotNil(store1.rawData(forKey: "k1"))
        XCTAssertEqual(store1.rawData(forKey: "k1"), 1.convertToData())
    }
}

private extension TweakStore {
    func int(forKey key: String) -> Int? {
        value(forKey: key)
    }
}
