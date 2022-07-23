//
//  TweakTrader+Tests.swift
//  TweaKit
//
//  Created by cokile
//

@testable import TweaKit
import XCTest

class TweakTraderTests: XCTestCase {
    var context: TweakContext!

    @Tweak(name: "Array", defaultValue: [1, 2, 3])
    var array: [Int]
    @Tweak(name: "Bool 1", defaultValue: true)
    var bool1: Bool
    @Tweak(name: "Bool 2", defaultValue: true)
    var bool2: Bool
    @Tweak(name: "String", defaultValue: "1")
    var string: String
    @Tweak(name: "Int", defaultValue: 1, from: 1, to: 10, stride: 1)
    var int: Int
    @Tweak(name: "Double", defaultValue: 1, from: 1, to: 10, stride: 0.5)
    var double: Double

    override func setUp() {
        super.setUp()

        $array.testableReset()
        $bool1.testableReset()
        $bool2.testableReset()
        $string.testableReset()
        $int.testableReset()
        $double.testableReset()

        context = TweakContext {
            TweakList("Test List") {
                TweakSection("Test Section") {
                    $array
                    $bool1
                        .setImportedValueTrumpsManuallyChangedValue()
                    $bool2
                    $string
                    $int
                    $double
                }
            }
        }
        context?.store.removeAll()
    }

    func testNormalImport() {
        XCTAssertEqual(array, [1, 2, 3])
        XCTAssertEqual(bool1, true)
        XCTAssertEqual(bool2, true)
        XCTAssertEqual(string, "1")
        XCTAssertEqual(int, 1)
        XCTAssertEqual(double, 1)

        let source = TweakTradeTestSource(json: importString)
        XCTAssertNoThrow(context.trader.import(from: source))
        XCTAssertEqual(array, [2, 3, 1])
        XCTAssertEqual(bool1, false)
        XCTAssertEqual(bool2, false)
        XCTAssertEqual(string, "2")
        XCTAssertEqual(int, 2)
        XCTAssertEqual(double, 2)

        let destination = TweakTradeTestDestination()
        let exp = XCTestExpectation(description: "normal import")
        XCTAssertNil(destination.string)
        context.trader.export(tweaks: context.tweaks.compactMap { $0 as? AnyTradableTweak }, to: destination) { [unowned self] error in
            XCTAssertNil(error)
            XCTAssertEqual(destination.string?.removingWhiteSpace(), importString.removingWhiteSpace())
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
    }

    func testImportedValueTrumpsManuallyChangedValue() {
        XCTAssertEqual(bool1, true)
        $bool1.didChangeManually = true
        XCTAssertEqual(bool2, true)
        $bool2.didChangeManually = true

        let source = TweakTradeTestSource(json: importString)
        XCTAssertNoThrow(context.trader.import(from: source))
        XCTAssertEqual(bool1, false)
        XCTAssertEqual(bool2, true)

        let destination = TweakTradeTestDestination()
        let exp = XCTestExpectation(description: "import trumped")
        XCTAssertNil(destination.string)
        context.trader.export(tweaks: context.tweaks.compactMap { $0 as? AnyTradableTweak }, to: destination) { [unowned self] error in
            XCTAssertNil(error)
            XCTAssertEqual(destination.string?.removingWhiteSpace(), importString.removingWhiteSpace().replacingOccurrences(of: #""tweak":"Bool2","value":false"#, with: #""tweak":"Bool2","value":true"#))
            exp.fulfill()
        }
        wait(for: [exp], timeout: 0.5)
    }

    func testImportCorruptedSource() {
        let exp = XCTestExpectation(description: "import corrupted source")
        let source = TweakTradeTestSource(json: importString.replacingOccurrences(of: "supported_version", with: "version"))
        context.trader.import(from: source) { error in
            XCTAssertNotNil(error)
            guard case .trade(let reason) = error! else {
                XCTAssert(false, "error should be trade error")
                return
            }
            switch reason {
            case .corruptedData:
                XCTAssert(true)
            default:
                XCTAssert(false, "reason should be corruptedData")
            }
            exp.fulfill()
        }

        wait(for: [exp], timeout: 0.5)
    }

    func testImportUnsupportedVersion() {
        let exp = XCTestExpectation(description: "import unsupported version")
        let source = TweakTradeTestSource(json: importString.replacingOccurrences(of: #""supported_version" : 1"#, with: #""supported_version" : 2"#))
        context.trader.import(from: source) { error in
            XCTAssertNotNil(error)
            guard case .trade(let reason) = error! else {
                XCTAssert(false, "error should be trade error")
                return
            }
            switch reason {
            case let .unsupportedVersion(expected, current):
                XCTAssertEqual(expected, 1)
                XCTAssertEqual(current, 2)
            default:
                XCTAssert(false, "reason should be unsupportedVersion")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 0.5)
    }

    func testNormalExport() {
        let exp = XCTestExpectation(description: "normal export")
        let destination = TweakTradeTestDestination()
        XCTAssertNil(destination.string)
        context.trader.export(tweaks: context.tweaks.compactMap { $0 as? AnyTradableTweak }, to: destination) { [unowned self] error in
            XCTAssertNil(error)
            XCTAssertEqual(destination.string?.removingWhiteSpace(), exportString.removingWhiteSpace())
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
    }
}

private extension TweakTraderTests {
    var importString: String {
        """
        {
          "supported_version" : 1,
          "tweaks" : [
            {
              "list" : "Test List",
              "section" : "Test Section",
              "tweak" : "Array",
              "value" : [2, 3, 1]
            },
            {
              "list" : "Test List",
              "section" : "Test Section",
              "tweak" : "Bool 1",
              "value" : false
            },
            {
              "list" : "Test List",
              "section" : "Test Section",
              "tweak" : "Bool 2",
              "value" : false
            },
            {
              "list" : "Test List",
              "section" : "Test Section",
              "tweak" : "Double",
              "value" : 2
            },
            {
              "list" : "Test List",
              "section" : "Test Section",
              "tweak" : "Int",
              "value" : 2
            },
            {
              "list" : "Test List",
              "section" : "Test Section",
              "tweak" : "String",
              "value" : "2"
            }
          ]
        }
        """
    }

    var exportString: String {
        """
        {
          "supported_version" : 1,
          "tweaks" : [
            {
              "list" : "Test List",
              "section" : "Test Section",
              "tweak" : "Array",
              "value" : [1, 2, 3]
            },
            {
              "list" : "Test List",
              "section" : "Test Section",
              "tweak" : "Bool 1",
              "value" : true
            },
            {
              "list" : "Test List",
              "section" : "Test Section",
              "tweak" : "Bool 2",
              "value" : true
            },
            {
              "list" : "Test List",
              "section" : "Test Section",
              "tweak" : "Double",
              "value" : 1
            },
            {
              "list" : "Test List",
              "section" : "Test Section",
              "tweak" : "Int",
              "value" : 1
            },
            {
              "list" : "Test List",
              "section" : "Test Section",
              "tweak" : "String",
              "value" : "1"
            }
          ]
        }
        """
    }
}

private final class TweakTradeTestSource: TweakTradeSource {
    let name = "String"
    let json: String

    init(json: String) {
        self.json = json
    }

    func receive(completion: @escaping (Result<TweakTradeCargo, Error>) -> Void) {
        completion(.success(json.data(using: .utf8)!))
    }
}

private final class TweakTradeTestDestination: TweakTradeDestination {
    let name = "Test"
    var string: String?

    func ship(_ cargo: TweakTradeCargo, completion: @escaping (Error?) -> Void) {
        string = String(data: cargo, encoding: .utf8)
        completion(nil)
    }
}

private extension String {
    func removingWhiteSpace() -> String {
        replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "\n", with: "")
    }
}
