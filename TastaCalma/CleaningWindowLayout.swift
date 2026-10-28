//
//  CleaningWindowLayout.swift
//  TastaCalma
//
//  Created by Luca Cipressi - milletgrain on 12/09/2026.
//

import AppKit
import Observation
import SwiftUI

/// The timer determines the preferred height while visible. About keeps that
/// height even when a language change reflows the hidden timer underneath it.
@MainActor
@Observable
final class CleaningWindowLayout {
    var naturalHeight: CGFloat = 760
    var contentSize = CGSize(width: 552, height: 760)
    @ObservationIgnored private var preferredHeight: CGFloat?

    func updateContentSize(availableSize: CGSize, showingAbout: Bool) {
        if !showingAbout || preferredHeight == nil {
            preferredHeight = naturalHeight
        }
        // Keep the preferred height separate from the display limit so moving
        // back to a larger display restores the same viewport, including About.
        let size = CGSize(
            width: min(552, max(1, availableSize.width)),
            height: min(preferredHeight ?? naturalHeight, max(1, availableSize.height))
        )
        if contentSize != size { contentSize = size }
    }
}

struct CleaningWindowConfiguration: NSViewRepresentable {
    let layout: CleaningWindowLayout
    // A value input makes intrinsic-height changes update the native window too.
    let naturalHeight: CGFloat
    let showingAbout: Bool

    func makeNSView(context: Context) -> WindowConfigurationView {
        WindowConfigurationView()
    }

    func updateNSView(_ view: WindowConfigurationView, context: Context) {
        view.layout = layout
        view.showingAbout = showingAbout
        view.scheduleConfiguration()
    }
}

@MainActor
final class WindowConfigurationView: NSView {
    var layout: CleaningWindowLayout?
    var showingAbout = false
    private var configurationPending = false
    private var exitingFullScreen = false

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        NotificationCenter.default.removeObserver(self)
        guard let window else { return }
        for name in [NSWindow.didChangeScreenNotification, NSWindow.didBecomeKeyNotification,
                     NSWindow.didExitFullScreenNotification] {
            NotificationCenter.default.addObserver(self, selector: #selector(screenChanged), name: name, object: window)
        }
        NotificationCenter.default.addObserver(
            self, selector: #selector(screenChanged),
            name: NSApplication.didChangeScreenParametersNotification, object: nil
        )
        scheduleConfiguration()
    }

    @objc private func screenChanged(_ notification: Notification) {
        scheduleConfiguration()
    }

    func scheduleConfiguration() {
        guard !configurationPending else { return }
        configurationPending = true
        // Allow scene restoration to finish and avoid changing observed SwiftUI
        // state during updateNSView. Multiple layout updates coalesce here.
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.configurationPending = false
            self.configureWindow()
        }
    }

    private func configureWindow() {
        guard let window, let layout, let screen = window.screen ?? NSScreen.main else { return }

        // Recover a full-screen session saved by an older resizable build too.
        if window.styleMask.contains(.fullScreen) {
            if !exitingFullScreen {
                exitingFullScreen = true
                window.toggleFullScreen(nil)
            }
            return
        }
        exitingFullScreen = false

        window.styleMask.remove(.resizable)
        window.collectionBehavior.remove(.fullScreenPrimary)
        window.collectionBehavior.insert([.fullScreenNone, .fullScreenDisallowsTiling])
        window.standardWindowButton(.zoomButton)?.isEnabled = false
        window.isMovable = true
        window.isMovableByWindowBackground = true

        // visibleFrame excludes the menu bar and Dock. Convert using this actual
        // window's chrome, rather than assuming a title-bar height.
        let availableFrame = screen.visibleFrame.insetBy(dx: 12, dy: 12)
        let availableContent = window.contentRect(forFrameRect: availableFrame)
        layout.updateContentSize(availableSize: availableContent.size, showingAbout: showingAbout)
        let size = layout.contentSize

        let oldFrame = window.frame
        let frameSize = window.frameRect(forContentRect: CGRect(origin: .zero, size: size)).size
        let frame = CleaningWindowGeometry.recoveredFrame(
            oldFrame: oldFrame, size: frameSize, visibleFrame: screen.visibleFrame
        )
        if window.frame != frame {
            window.setFrame(frame, display: true, animate: false)
        }
    }
}

enum CleaningWindowGeometry {
    /// Keep a valid window's top-left position. Recover oversized/off-screen
    /// restored frames by centering the corrected frame on the current display.
    nonisolated static func recoveredFrame(oldFrame: CGRect, size: CGSize, visibleFrame: CGRect) -> CGRect {
        var frame = CGRect(x: oldFrame.minX, y: oldFrame.maxY - size.height, width: size.width, height: size.height)
        if !visibleFrame.contains(oldFrame) || !visibleFrame.contains(frame) {
            frame.origin = CGPoint(
                x: visibleFrame.midX - size.width / 2,
                y: visibleFrame.midY - size.height / 2
            )
        }
        return frame
    }
}
