//
//  KeyboardLockSession.swift
//  TastaCalma
//
//  Created by Luca Cipressi - milletgrain on 12/09/2026.
//

import CoreGraphics
import Foundation

/// A monotonic deadline shared by the display timer and the event filter.
/// ContinuousClock also advances while the Mac is asleep.
nonisolated struct KeyboardLockSession {
    let duration: TimeInterval
    let deadline: ContinuousClock.Instant

    init(duration: TimeInterval, now: ContinuousClock.Instant = .now) {
        self.duration = duration
        deadline = now.advanced(by: .seconds(duration))
    }

    func remaining(at now: ContinuousClock.Instant = .now) -> TimeInterval {
        let components = now.duration(to: deadline).components
        let seconds = Double(components.seconds) + Double(components.attoseconds) / 1e18
        return min(duration, max(0, seconds))
    }

    func shouldSuppress(
        _ type: CGEventType,
        systemDefinedSubtype: Int16? = nil,
        at now: ContinuousClock.Instant = .now
    ) -> Bool {
        guard remaining(at: now) > 0 else { return false }
        switch type {
        case .keyDown, .keyUp, .flagsChanged:
            return true
        default:
            // NX_SYSDEFINED / NX_SUBTYPE_AUX_CONTROL_BUTTONS: media keys.
            // Other system-defined events and all pointer events pass through.
            return type.rawValue == 14 && systemDefinedSubtype == 8
        }
    }
}
