//
//  TweakStoreNotifier+Tests.swift
//  TweaKitTests
//
//  Created by cokile
//

import XCTest
@testable import TweaKit

class TweakStoreNotifierTests: XCTestCase {
    // use different name from TweakStoreTests
    let store = TweakStore(name: "Test_Store_Notifier")

    override func setUp() {
        super.setUp()
        store.removeAll()
    }
    
    func testNotifyNew() {
        let exp1 = expectation(description: "k1 notify 1")
        let exp2 = expectation(description: "k1 notify 2")
        let exp3 = expectation(description: "k1 notify 3")
        let exp4 = expectation(description: "k1 notify nil")
        
        _ = store.startNotifying(forKey: "k1") { _, new, _ in
            if new?.int == 1 {
                exp1.fulfill()
            } else if new?.int == 2 {
                exp2.fulfill()
            } else if new?.int == 3 {
                exp3.fulfill()
            } else if new?.int == nil {
                exp4.fulfill()
            }
        }
        
        store.setValue(1, forKey: "k1")
        store.setValue(2, forKey: "k1")
        store.setValue(3, forKey: "k1")
        store.removeValue(forKey: "k1")
        
        wait(for: [exp1, exp2, exp3, exp4], timeout: 1, enforceOrder: false)
    }
    
    func testNotifyOld() {
        let exp1 = expectation(description: "k1 notify nil")
        let exp2 = expectation(description: "k1 notify 1")
        let exp3 = expectation(description: "k1 notify 2")
        let exp4 = expectation(description: "k1 notify 3")

        _ = store.startNotifying(forKey: "k1") { old, _, _ in
            if old == nil {
                exp1.fulfill()
            } else if old?.int == 1 {
                exp2.fulfill()
            } else if old?.int == 2 {
                exp3.fulfill()
            } else if old?.int == 3 {
                exp4.fulfill()
            }
        }
        
        store.setValue(1, forKey: "k1")
        store.setValue(2, forKey: "k1")
        store.setValue(3, forKey: "k1")
        store.removeValue(forKey: "k1")
        
        wait(for: [exp1, exp2, exp3, exp4], timeout: 1, enforceOrder: false)
    }
    
    func testNotifyManually() {
        let exp = expectation(description: "k1 notify 1")
        
        _ = store.startNotifying(forKey: "k1") { _, new, manually in
            if new?.int == 1 {
                XCTAssertTrue(manually)
                exp.fulfill()
            }
        }
        
        store.setValue(1, forKey: "k1", manually: true)
        
        wait(for: [exp], timeout: 1)
    }
    
    func testNotifyNotManually() {
        let exp = expectation(description: "k1 notify 1")
        
        _ = store.startNotifying(forKey: "k1") { _, new, manually in
            if new?.int == 1 {
                XCTAssertFalse(manually)
                exp.fulfill()
            }
        }
        
        store.setValue(1, forKey: "k1", manually: false)
        
        wait(for: [exp], timeout: 1)
    }
    
    func testNotifyRemoveAll() {
        let exp1 = expectation(description: "k1 notify")
        let exp2 = expectation(description: "k2 notify")
        let exp3 = expectation(description: "k3 notify")
        exp3.isInverted = true
        
        store.setValue(1, forKey: "k1")
        store.setValue(2, forKey: "k2")
        
        _ = store.startNotifying(forKey: "k1") { _, new, _ in
            if new == nil {
                exp1.fulfill()
            }
        }
        _ = store.startNotifying(forKey: "k2") { _, new, _ in
            if new == nil {
                exp2.fulfill()
            }
        }
        _ = store.startNotifying(forKey: "k3") { _, new, _ in
            if new == nil {
                exp3.fulfill()
            }
        }
        store.removeAll()
        
        wait(for: [exp1, exp2, exp3], timeout: 1, enforceOrder: false)
    }
    
    func testStopNotifyingKey() {
        let exp1 = expectation(description: "k1 notify 1")
        exp1.expectedFulfillmentCount = 2
        let exp2 = expectation(description: "k1 notify 2")
        exp2.expectedFulfillmentCount = 2
        let exp3 = expectation(description: "k1 notify 3")
        exp3.isInverted = true
        
        _ = store.startNotifying(forKey: "k1") { _, new, _ in
            if new?.int == 1 {
                exp1.fulfill()
            } else if new?.int == 2 {
                exp2.fulfill()
            } else if new?.int == 3 {
                exp3.fulfill()
            }
        }
        _ = store.startNotifying(forKey: "k1") { _, new, _ in
            if new?.int == 1 {
                exp1.fulfill()
            } else if new?.int == 2 {
                exp2.fulfill()
            } else if new?.int == 3 {
                exp3.fulfill()
            }
        }
        
        store.setValue(1, forKey: "k1")
        store.setValue(2, forKey: "k1")
        store.stopNotifying(forKey: "k1")
        store.setValue(3, forKey: "k1")
        
        wait(for: [exp1, exp2, exp3], timeout: 1, enforceOrder: false)
    }
    
    func testStopNotifyingToken() {
        let exp1 = expectation(description: "k1 notify 1")
        exp1.expectedFulfillmentCount = 2
        let exp2 = expectation(description: "k1 notify 2")
        exp2.expectedFulfillmentCount = 2
        let exp3 = expectation(description: "k1 notify 3")
        
        _ = store.startNotifying(forKey: "k1") { _, new, _ in
            if new?.int == 1 {
                exp1.fulfill()
            } else if new?.int == 2 {
                exp2.fulfill()
            } else if new?.int == 3 {
                exp3.fulfill()
            }
        }
        let token = store.startNotifying(forKey: "k1") { _, new, _ in
               if new?.int == 1 {
                   exp1.fulfill()
               } else if new?.int == 2 {
                   exp2.fulfill()
               } else if new?.int == 3 {
                   exp3.fulfill()
               }
        }
        
        store.setValue(1, forKey: "k1")
        store.setValue(2, forKey: "k1")
        store.stopNotifying(ForToken: token)
        store.setValue(3, forKey: "k1")
        
        wait(for: [exp1, exp2, exp3], timeout: 1, enforceOrder: false)
    }
}

private extension Data {
    var int: Int? {
        Int.convert(from: self)
    }
}
