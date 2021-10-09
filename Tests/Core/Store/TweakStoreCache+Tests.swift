//
//  TweakStoreCache+Tests.swift
//  TweaKitTests
//
//  Created by cokile
//

import XCTest
@testable import TweaKit

class TweakStoreCacheTests: XCTestCase {
    let cache1 = TweakStoreCache()
    let cache2 = TweakStoreCache()
    
    override func setUp() {
        super.setUp()
        cache1.removeAll()
        cache2.removeAll()
    }
    
    func testCRUD() {
        XCTAssertFalse(cache1.hasValue(forKey: "k1"))
        XCTAssertFalse(cache1.hasValue(forKey: "k2"))
        XCTAssertFalse(cache1.hasValue(forKey: "k3"))
        
        cache1.setValue(1, forKey: "k1")
        cache1.setValue(2, forKey: "k2")
        
        XCTAssertEqual(cache1.int(forKey: "k1"), 1)
        XCTAssertTrue(cache1.hasValue(forKey: "k1"))
        XCTAssertEqual(cache1.int(forKey: "k2"), 2)
        XCTAssertTrue(cache1.hasValue(forKey: "k2"))
        
        cache1.removeValue(forKey: "k3")
        XCTAssertEqual(cache1.int(forKey: "k1"), 1)
        XCTAssertTrue(cache1.hasValue(forKey: "k1"))
        XCTAssertEqual(cache1.int(forKey: "k2"), 2)
        XCTAssertTrue(cache1.hasValue(forKey: "k2"))
        
        cache1.removeValue(forKey: "k1")
        XCTAssertNil(cache1.int(forKey: "k1"))
        XCTAssertFalse(cache1.hasValue(forKey: "k1"))
        XCTAssertEqual(cache1.int(forKey: "k2"), 2)
        XCTAssertTrue(cache1.hasValue(forKey: "k2"))
        
        cache1.removeAll()
        XCTAssertNil(cache1.int(forKey: "k1"))
        XCTAssertFalse(cache1.hasValue(forKey: "k1"))
        XCTAssertNil(cache1.int(forKey: "k2"))
        XCTAssertFalse(cache1.hasValue(forKey: "k2"))
    }
    
    func testIsolation() {
        XCTAssertFalse(cache1.hasValue(forKey: "k1"))
        XCTAssertFalse(cache2.hasValue(forKey: "k1"))
        
        cache1.setValue(1, forKey: "k1")
        XCTAssertEqual(cache1.int(forKey: "k1"), 1)
        XCTAssertTrue(cache1.hasValue(forKey: "k1"))
        XCTAssertNil(cache2.int(forKey: "k1"))
        XCTAssertFalse(cache2.hasValue(forKey: "k1"))
        
        cache2.setValue(2, forKey: "k1")
        XCTAssertEqual(cache1.int(forKey: "k1"), 1)
        XCTAssertTrue(cache1.hasValue(forKey: "k1"))
        XCTAssertEqual(cache2.int(forKey: "k1"), 2)
        XCTAssertTrue(cache2.hasValue(forKey: "k1"))
        
        cache1.removeValue(forKey: "k1")
        XCTAssertNil(cache1.int(forKey: "k1"))
        XCTAssertFalse(cache1.hasValue(forKey: "k1"))
        XCTAssertEqual(cache2.int(forKey: "k1"), 2)
        XCTAssertTrue(cache2.hasValue(forKey: "k1"))
    }
}

private extension TweakStoreCache {
    func int(forKey key: String) -> Int? {
        value(forKey: key)
    }
}
