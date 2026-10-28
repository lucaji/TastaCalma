//
//  KeyboardLockSessionChecks.swift
//  TastaCalma
//
//  Created by Luca Cipressi - milletgrain on 12/09/2026.
//

import CoreGraphics
import Foundation

@main
struct KeyboardLockSessionChecks {
    static func main() {
        let start = ContinuousClock.now
        for duration in [30.0, 60, 120, 180, 300] {
            let session = KeyboardLockSession(duration: duration, now: start)
            precondition(session.remaining(at: start) == duration)
            precondition(session.remaining(at: start.advanced(by: .seconds(duration / 2))) == duration / 2)
            precondition(session.remaining(at: start.advanced(by: .seconds(duration))) == 0)
            precondition(session.remaining(at: start.advanced(by: .seconds(duration + 300))) == 0)
        }
        let session = KeyboardLockSession(duration: 30, now: start)
        let beforeExpiry = start.advanced(by: .seconds(29.999))
        let deadline = start.advanced(by: .seconds(30))
        for type: CGEventType in [.keyDown, .keyUp, .flagsChanged] {
            precondition(session.shouldSuppress(type, at: start))
            precondition(session.shouldSuppress(type, at: beforeExpiry))
            precondition(!session.shouldSuppress(type, at: deadline))
            precondition(!session.shouldSuppress(type, at: deadline.advanced(by: .seconds(600))))
        }
        for type: CGEventType in [.leftMouseDown, .leftMouseUp, .rightMouseDown,
                                  .rightMouseUp, .mouseMoved, .leftMouseDragged,
                                  .scrollWheel, .tapDisabledByTimeout, .tapDisabledByUserInput] {
            precondition(!session.shouldSuppress(type, at: start))
        }
        let systemDefined = CGEventType(rawValue: 14)!
        precondition(session.shouldSuppress(systemDefined, systemDefinedSubtype: 8, at: start))
        precondition(!session.shouldSuppress(systemDefined, systemDefinedSubtype: 8, at: deadline))
        precondition(!session.shouldSuppress(systemDefined, systemDefinedSubtype: 1, at: start))
        precondition(!session.shouldSuppress(systemDefined, at: start))
        precondition(Int(ceil(session.remaining(at: beforeExpiry))) == 1)
        print("Passed: all five durations, exact expiry, overdue event delivery, keyboard and media filtering, pointer passthrough, countdown rounding.")
    }
}
