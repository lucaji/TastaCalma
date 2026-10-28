//
//  KeyboardLockController.swift
//  TastaCalma
//
//  Created by Luca Cipressi - milletgrain on 12/09/2026.
//

import AppKit
import ApplicationServices
import Carbon
import Observation

@MainActor
@Observable
final class KeyboardLockController {
    static let durations = [30, 60, 120, 180, 300]
    private static let selectedDurationKey = "selectedTimerDuration"

    private(set) var selectedDuration: Int
    private(set) var isLocked = false
    private(set) var hasAccessibilityAccess = AXIsProcessTrusted()
    private(set) var remaining: TimeInterval
    private(set) var didFinish = false
    private(set) var notice: KeyboardLockNotice?

    @ObservationIgnored private var session: KeyboardLockSession?
    @ObservationIgnored private var eventTap: CFMachPort?
    @ObservationIgnored private var runLoopSource: CFRunLoopSource?
    @ObservationIgnored private var timer: Timer?
    @ObservationIgnored private var activity: NSObjectProtocol?
    @ObservationIgnored private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        let savedDuration = defaults.integer(forKey: Self.selectedDurationKey)
        let duration = Self.durations.contains(savedDuration) ? savedDuration : 60
        selectedDuration = duration
        remaining = TimeInterval(duration)
    }

    var displayedSeconds: Int {
        isLocked ? Int(ceil(remaining)) : (didFinish ? 0 : selectedDuration)
    }

    var progress: Double {
        guard let session else { return didFinish ? 0 : 1 }
        return remaining / session.duration
    }

    func selectDuration(_ seconds: Int) {
        guard !isLocked, Self.durations.contains(seconds) else { return }
        selectedDuration = seconds
        defaults.set(seconds, forKey: Self.selectedDurationKey)
        didFinish = false
        notice = nil
    }

    func refreshAccess() {
        let previouslyGranted = hasAccessibilityAccess
        hasAccessibilityAccess = AXIsProcessTrusted()
        if hasAccessibilityAccess && !previouslyGranted {
            notice = nil
        }
        if isLocked && !hasAccessibilityAccess {
            stop(message: .accessRemoved)
        }
    }

    func requestAccess() {
        // The SDK exposes kAXTrustedCheckOptionPrompt as a mutable C global.
        // Use its documented key value without importing mutable shared state.
        let options = ["AXTrustedCheckOptionPrompt": true]
        hasAccessibilityAccess = AXIsProcessTrustedWithOptions(options as CFDictionary)
        if !hasAccessibilityAccess {
            notice = .enableAccess
        }
    }

    func openAccessibilitySettings() {
        requestAccess()
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
            NSWorkspace.shared.open(url)
        }
    }

    func start() {
        guard !isLocked else { return }
        refreshAccess()
        guard hasAccessibilityAccess else {
            requestAccess()
            return
        }
        guard !IsSecureEventInputEnabled() else {
            notice = .secureInput
            return
        }

        // Avoid starting with a modifier already held. That state may have
        // reached other apps before this filter was installed.
        let modifiers: CGEventFlags = [.maskCommand, .maskControl, .maskAlternate, .maskShift, .maskSecondaryFn]
        guard CGEventSource.flagsState(.combinedSessionState).intersection(modifiers).isEmpty else {
            notice = .releaseModifiers
            return
        }

        let types: [UInt32] = [CGEventType.keyDown.rawValue, CGEventType.keyUp.rawValue,
                               CGEventType.flagsChanged.rawValue, 14]
        let mask = types.reduce(CGEventMask(0)) { $0 | (CGEventMask(1) << $1) }
        guard let tap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: mask,
            callback: tastaCalmaEventCallback,
            userInfo: Unmanaged.passUnretained(self).toOpaque()
        ) else {
            notice = .checkAccess
            return
        }
        guard let source = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0) else {
            CFMachPortInvalidate(tap)
            notice = .couldNotStart
            return
        }

        eventTap = tap
        runLoopSource = source
        // The C callback and all controller state are confined to this run loop.
        CFRunLoopAddSource(CFRunLoopGetMain(), source, .commonModes)
        CGEvent.tapEnable(tap: tap, enable: true)
        guard CGEvent.tapIsEnabled(tap: tap) else {
            stop(message: .lockNotEnabled)
            return
        }

        session = KeyboardLockSession(duration: TimeInterval(selectedDuration))
        remaining = TimeInterval(selectedDuration)
        didFinish = false
        notice = nil
        isLocked = true
        activity = ProcessInfo.processInfo.beginActivity(
            options: [.userInitiated, .idleDisplaySleepDisabled],
            reason: "Keep the temporary keyboard lock and countdown responsive."
        )
        let timer = Timer(timeInterval: 0.05, repeats: true) { [weak self] _ in
            MainActor.assumeIsolated { self?.tick() }
        }
        self.timer = timer
        RunLoop.main.add(timer, forMode: .common)
        announce(String(localized: "Keyboard locked for \(selectedDuration) seconds.", bundle: language.bundle(), locale: language.locale))
    }

    func stop(completed: Bool = false, message: KeyboardLockNotice? = nil) {
        // Release input first, before touching the presentation state.
        if let eventTap {
            CGEvent.tapEnable(tap: eventTap, enable: false)
            CFMachPortInvalidate(eventTap)
        }
        if let runLoopSource {
            CFRunLoopRemoveSource(CFRunLoopGetMain(), runLoopSource, .commonModes)
        }
        eventTap = nil
        runLoopSource = nil
        session = nil
        timer?.invalidate()
        timer = nil
        if let activity { ProcessInfo.processInfo.endActivity(activity) }
        activity = nil
        let wasLocked = isLocked
        isLocked = false
        didFinish = completed
        remaining = completed ? 0 : TimeInterval(selectedDuration)
        notice = message
        if wasLocked { announce(String(localized: "Keyboard unlocked.", bundle: language.bundle(), locale: language.locale)) }
    }

    private var language: AppLanguage {
        AppLanguage(rawValue: defaults.string(forKey: AppLanguage.storageKey) ?? "") ?? .system
    }

    private func announce(_ message: String) {
        NSAccessibility.post(element: NSApp as Any, notification: .announcementRequested,
                             userInfo: [.announcement: message,
                                        .priority: NSAccessibilityPriorityLevel.high.rawValue])
    }

    private func tick() {
        guard let session else { return }
        remaining = session.remaining()
        if remaining <= 0 {
            stop(completed: true)
        } else if IsSecureEventInputEnabled() {
            stop(message: .secureInputInterrupted)
        } else if let eventTap, !CGEvent.tapIsEnabled(tap: eventTap) {
            stop(message: .systemInterrupted)
        } else {
            refreshAccess()
        }
    }

    fileprivate func shouldSuppress(type: CGEventType, systemDefinedSubtype: Int16?) -> Bool {
        if type == .tapDisabledByTimeout || type == .tapDisabledByUserInput {
            // Never silently re-arm a lock after macOS has disabled it.
            stop(message: .systemInterrupted)
            return false
        }
        guard let session else { return false }
        // Enforce expiry here as well, so delayed UI timer delivery cannot
        // cause subsequent events to be swallowed beyond the deadline.
        guard session.remaining() > 0 else {
            stop(completed: true)
            return false
        }
        return session.shouldSuppress(type, systemDefinedSubtype: systemDefinedSubtype)
    }
}

// A C callback has no actor isolation of its own. Its source is installed
// exclusively on the main run loop above, making the actor assertion valid.
private nonisolated func tastaCalmaEventCallback(
    proxy: CGEventTapProxy, type: CGEventType, event: CGEvent, userInfo: UnsafeMutableRawPointer?
) -> Unmanaged<CGEvent>? {
    guard let userInfo else { return Unmanaged.passUnretained(event) }
    let controller = Unmanaged<KeyboardLockController>.fromOpaque(userInfo).takeUnretainedValue()
    let subtype = type.rawValue == 14 ? NSEvent(cgEvent: event)?.subtype.rawValue : nil
    let suppress = MainActor.assumeIsolated {
        controller.shouldSuppress(type: type, systemDefinedSubtype: subtype)
    }
    return suppress ? nil : Unmanaged.passUnretained(event)
}
