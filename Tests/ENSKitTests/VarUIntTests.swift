//
// VarUIntTests.swift
//
//
//  Created by Shu Lyu on 2022-03-28.
//

import XCTest
@testable import ENSKit

final class VarUIntTests: XCTestCase {
    func testEncode() throws {
        let zero = VarUInt.encodeBytes(0)
        XCTAssertEqual(zero, [0])
        let one = VarUInt.encodeBytes(1)
        XCTAssertEqual(one, [1])
        let a = VarUInt.encodeBytes(127)
        XCTAssertEqual(a, [127])
        let b = VarUInt.encodeBytes(128)
        XCTAssertEqual(b, [128, 1])
        let c = VarUInt.encodeBytes(255)
        XCTAssertEqual(c, [255, 1])
        let d = VarUInt.encodeBytes(300)
        XCTAssertEqual(d, [172, 2])
        let e = VarUInt.encodeBytes(16384)
        XCTAssertEqual(e, [128, 128, 1])

        let overflow = VarUInt.encodeBytes(0x7fffffffffffffff)
        XCTAssertNil(overflow)
    }

    func testDecode() throws {
        let zero = VarUInt.decodeBytes([0])
        XCTAssertTrue(zero! == (0, 1))
        let one = VarUInt.decodeBytes([1])
        XCTAssertTrue(one! == (1, 1))
        let a = VarUInt.decodeBytes([127])
        XCTAssertTrue(a! == (127, 1))
        let b = VarUInt.decodeBytes([128, 1])
        XCTAssertTrue(b! == (128, 2))
        let c = VarUInt.decodeBytes([255, 1])
        XCTAssertTrue(c! == (255, 2))
        let d = VarUInt.decodeBytes([172, 2])
        XCTAssertTrue(d! == (300, 2))
        let e = VarUInt.decodeBytes([128, 128, 1])
        XCTAssertTrue(e! == (16384, 3))

        let eWithOffset = VarUInt.decodeBytes([0, 0, 128, 128, 1], offset: 2)
        XCTAssertTrue(eWithOffset! == (16384, 5))
        let eWithSuffix = VarUInt.decodeBytes([0, 0, 128, 128, 1, 0, 0], offset: 2)
        XCTAssertTrue(eWithSuffix! == (16384, 5))

        let incorrect = VarUInt.decodeBytes([128])
        XCTAssertNil(incorrect)
        let notMinimal = VarUInt.decodeBytes([128, 0])
        XCTAssertNil(notMinimal)
        let overflow = VarUInt.decodeBytes([128, 128, 128, 128, 128, 128, 128, 128, 1])
        XCTAssertNil(overflow)
    }
}
