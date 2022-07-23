//
//  Array+Extension+Tests.swift
//  TweaKitTests
//
//  Created by cokile
//

@testable import TweaKit
import XCTest

class ArrayExtensionTests: XCTestCase {
    func testUniqued() throws {
        var objects: [Object] = []
        XCTAssertEqual(objects.uniqued { $0.seq == $1.seq }, objects)
        XCTAssertEqual(objects.uniqued { $0.code == $1.code }, objects)
        XCTAssertEqual(objects.uniqued { $0.seq == $1.seq && $0.code == $1.code }, objects)

        let o1 = Object(seq: 1, code: 1)
        let o2 = Object(seq: 2, code: 1)
        let o3 = Object(seq: 2, code: 2)
        let o4 = Object(seq: 2, code: 2)
        objects = [o1, o2, o3, o4]
        XCTAssertEqual(objects.uniqued { $0.seq == $1.seq }, [o1, o2])
        XCTAssertEqual(objects.uniqued { $0.code == $1.code }, [o1, o3])
        XCTAssertEqual(objects.uniqued { $0.seq == $1.seq && $0.code == $1.code }, [o1, o2, o3])
    }
}

private extension ArrayExtensionTests {
    struct Object: Equatable {
        let seq: Int
        let code: Int
    }
}
