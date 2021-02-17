//
//  TweakPrimaryViewRecycler+Tests.swift
//  TweaKitTests
//
//  Created by cokile
//

import XCTest
@testable import TweaKit

class TweakPrimaryViewRecyclerTests: XCTestCase {
    func testNormalRecycle() {
        let recycler = TweakPrimaryViewRecycler()
        XCTAssertNil(recycler.dequeue(withReuseID: "k1"))
        
        let mock1 = MockPrimaryView(reuseID: "k1")
        recycler.enqueue(mock1)
        XCTAssertNotNil(recycler.dequeue(withReuseID: "k1"))
        XCTAssertNil(recycler.dequeue(withReuseID: "k1"))
        
        recycler.enqueue(mock1)
        XCTAssertNotNil(recycler.dequeue(withReuseID: "k1"))
        XCTAssertNil(recycler.dequeue(withReuseID: "k1"))
    }
    
    func testDuplicatedEnqueue() {
        let recycler = TweakPrimaryViewRecycler()
        XCTAssertNil(recycler.dequeue(withReuseID: "k1"))
        
        let mock1 = MockPrimaryView(reuseID: "k1")
        recycler.enqueue(mock1)
        recycler.enqueue(mock1)
        XCTAssertNotNil(recycler.dequeue(withReuseID: "k1"))
        XCTAssertNil(recycler.dequeue(withReuseID: "k1"))
    }

    func testRecycleIsolation() {
        let recycler = TweakPrimaryViewRecycler()
        let mock1 = MockPrimaryView(reuseID: "k1")
        let mock2 = MockPrimaryView(reuseID: "k2")
        
        XCTAssertNil(recycler.dequeue(withReuseID: "k1"))
        XCTAssertNil(recycler.dequeue(withReuseID: "k2"))
        recycler.enqueue(mock1)
        XCTAssertNotNil(recycler.dequeue(withReuseID: "k1"))
        XCTAssertNil(recycler.dequeue(withReuseID: "k2"))
        
        XCTAssertNil(recycler.dequeue(withReuseID: "k1"))
        recycler.enqueue(mock2)
        XCTAssertNotNil(recycler.dequeue(withReuseID: "k2"))
        XCTAssertNil(recycler.dequeue(withReuseID: "k1"))
    }
}

private final class MockPrimaryView: UIView, TweakPrimaryView {
    let reuseID: String
    
    init(reuseID: String) {
        self.reuseID = reuseID
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func reload(withTweak tweak: AnyTweak, manually: Bool) -> Bool {
        false
    }
}
