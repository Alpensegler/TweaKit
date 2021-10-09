//
//  TweakStorePersistency+Tests.swift
//  TweaKitTests
//
//  Created by cokile
//

import XCTest
@testable import TweaKit

class TweakStorePersistencyTests: XCTestCase {
    let persistency1 = TweakStorePersistency(name: "p1", appGroupID: nil)
    let persistency2 = TweakStorePersistency(name: "p2", appGroupID: nil)
    
    override func setUp() {
        super.setUp()
        do {
            try persistency1.removeAll()
            try persistency2.removeAll()
        } catch {
            fatalError("fail to remove all persistencies")
        }
    }
    
    func testCRUD() throws {
        XCTAssertFalse(persistency1.hasData(forKey: "k1"))
        XCTAssertFalse(persistency1.hasData(forKey: "k2"))
        XCTAssertFalse(persistency1.hasData(forKey: "k3"))
        
        persistency1.setInt(1, forKey: "k1")
        persistency1.setInt(2, forKey: "k2")
        
        XCTAssertEqual(persistency1.int(forKey: "k1"), 1)
        XCTAssertTrue(persistency1.hasData(forKey: "k1"))
        XCTAssertEqual(persistency1.int(forKey: "k2"), 2)
        XCTAssertTrue(persistency1.hasData(forKey: "k2"))
        
        try persistency1.removeData(forKey: "k3")
        XCTAssertEqual(persistency1.int(forKey: "k1"), 1)
        XCTAssertTrue(persistency1.hasData(forKey: "k1"))
        XCTAssertEqual(persistency1.int(forKey: "k2"), 2)
        XCTAssertTrue(persistency1.hasData(forKey: "k2"))
        
        try persistency1.removeData(forKey: "k1")
        XCTAssertNil(persistency1.int(forKey: "k1"))
        XCTAssertFalse(persistency1.hasData(forKey: "k1"))
        XCTAssertEqual(persistency1.int(forKey: "k2"), 2)
        XCTAssertTrue(persistency1.hasData(forKey: "k2"))
        
        try persistency1.removeAll()
        XCTAssertNil(persistency1.int(forKey: "k1"))
        XCTAssertFalse(persistency1.hasData(forKey: "k1"))
        XCTAssertNil(persistency1.int(forKey: "k2"))
        XCTAssertFalse(persistency1.hasData(forKey: "k2"))
    }
    
    func testIsolation() throws {
        XCTAssertFalse(persistency1.hasData(forKey: "k1"))
        XCTAssertFalse(persistency2.hasData(forKey: "k1"))
        
        persistency1.setInt(1, forKey: "k1")
        XCTAssertEqual(persistency1.int(forKey: "k1"), 1)
        XCTAssertTrue(persistency1.hasData(forKey: "k1"))
        XCTAssertNil(persistency2.int(forKey: "k1"))
        XCTAssertFalse(persistency2.hasData(forKey: "k1"))
        
        persistency2.setInt(2, forKey: "k1")
        XCTAssertEqual(persistency1.int(forKey: "k1"), 1)
        XCTAssertTrue(persistency1.hasData(forKey: "k1"))
        XCTAssertEqual(persistency2.int(forKey: "k1"), 2)
        XCTAssertTrue(persistency2.hasData(forKey: "k1"))
        
        try persistency1.removeData(forKey: "k1")
        XCTAssertNil(persistency1.int(forKey: "k1"))
        XCTAssertFalse(persistency1.hasData(forKey: "k1"))
        XCTAssertEqual(persistency2.int(forKey: "k1"), 2)
        XCTAssertTrue(persistency2.hasData(forKey: "k1"))
    }
}

private extension TweakStorePersistency {
    func int(forKey key: String) -> Int? {
        do {
            return try data(forKey: key).flatMap(Int.convert(from:))
        } catch {
            fatalError("fail to get int for \(key)")
        }
    }
    
    func setInt(_ int: Int, forKey key: String) {
        do {
            try setData(int.convertToData(), forKey: key)
        } catch {
            fatalError("fail to set int for \(key)")
        }
    }
}
