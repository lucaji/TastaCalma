//
//  ContentView.swift
//  TastaCalma
//
//  Created by Luca Cipressi - milletgrain on 12/09/2026.
//

import AppKit
import SwiftUI

struct ContentView: View {
    @Binding var showingAbout: Bool
    @Binding var hasPresentedAccessibilitySetupThisLaunch: Bool
    @AppStorage(AppLanguage.storageKey) private var language = AppLanguage.system
    @State private var lock = KeyboardLockController()
    @State private var windowLayout = CleaningWindowLayout()
    @State private var showingAccessibilitySetup = false
    @Environment(\.self) private var environment
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var style: ClothStyle { ClothStyle(environment: environment) }
    private var tint: Color { lock.didFinish ? style.sage : style.accent }
    private var navigationAnimation: Animation {
        .easeInOut(duration: reduceMotion ? 0.26 : 0.44)
    }

    var body: some View {
        ZStack {
            // Keep the timer view mounted so navigation preserves its state,
            // window size, and active keyboard lock. Only the visible page
            // participates in interaction and accessibility.
            ScrollView(.vertical) {
                keyboardView
                    .fixedSize(horizontal: false, vertical: true)
                    .onGeometryChange(for: CGFloat.self) { geometry in
                        ceil(geometry.size.height)
                    } action: { height in
                        windowLayout.naturalHeight = height
                    }
            }
            .scrollBounceBehavior(.basedOnSize)
            .opacity(showingAbout ? 0 : 1)
            .offset(x: showingAbout && !reduceMotion ? -16 : 0)
            .disabled(showingAbout)
            .allowsHitTesting(!showingAbout)
            .accessibilityHidden(showingAbout)

            // Animate existing layers in both directions instead of relying
            // on an insertion transition triggered from a menu command.
            ScrollView(.vertical) {
                AboutView {
                    withAnimation(navigationAnimation) {
                        showingAbout = false
                    }
                }
                .frame(minHeight: windowLayout.contentSize.height)
                .fixedSize(horizontal: false, vertical: true)
            }
            .scrollBounceBehavior(.basedOnSize)
            .opacity(showingAbout ? 1 : 0)
            .offset(x: showingAbout || reduceMotion ? 0 : 16)
            .disabled(!showingAbout)
            .allowsHitTesting(showingAbout)
            .accessibilityHidden(!showingAbout)
            .zIndex(1)
        }
        .frame(width: windowLayout.contentSize.width, height: windowLayout.contentSize.height)
        .background {
            CleaningWindowConfiguration(
                layout: windowLayout,
                naturalHeight: windowLayout.naturalHeight,
                showingAbout: showingAbout
            )
                .allowsHitTesting(false)
        }
        .background(style.paper)
        .clipped()
        .animation(navigationAnimation, value: showingAbout)
        .animation(ClothStyle.appearanceAnimation(reduceMotion: reduceMotion), value: environment.colorScheme)
        .sheet(isPresented: $showingAccessibilitySetup) {
            AccessibilitySetupView(
                hasAccess: lock.hasAccessibilityAccess,
                openSettings: lock.openAccessibilitySettings,
                checkAccess: lock.refreshAccess
            )
            .frame(
                width: max(280, min(500, windowLayout.contentSize.width - 32)),
                height: max(320, min(650, windowLayout.contentSize.height - 32))
            )
            .preferredColorScheme(environment.colorScheme)
        }
        .task {
            refreshAccessibilitySetup()
        }
        .focusedSceneValue(\.showTastaCalmaAbout, {
            withAnimation(navigationAnimation) {
                showingAbout = true
            }
        })
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)) { _ in
            refreshAccessibilitySetup()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.willTerminateNotification)) { _ in
            lock.stop()
        }
        .onReceive(NSWorkspace.shared.notificationCenter.publisher(for: NSWorkspace.willSleepNotification)) { _ in
            if lock.isLocked { lock.stop(message: .sleep) }
        }
        .onReceive(NSWorkspace.shared.notificationCenter.publisher(for: NSWorkspace.sessionDidResignActiveNotification)) { _ in
            if lock.isLocked { lock.stop(message: .sessionChanged) }
        }
        .onDisappear { lock.stop() }
    }

    private var keyboardView: some View {
        VStack(spacing: 0) {
            masthead
                .padding(.bottom, 24)
                .zIndex(1)

            VStack(spacing: 13) {
                Text("A little pause.\nA cleaner keyboard.")
                    .font(.system(size: 35, weight: .regular, design: .serif))
                    .tracking(-1.1)
                    .lineSpacing(-2)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)

                Text("Give your keys a fresh start. Choose a little time, lock your keyboard, and wipe away. Typing returns automatically.")
                    .font(.system(size: 13))
                    .lineSpacing(5)
                    .lineLimit(3, reservesSpace: true)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(style.muted)
                    .fixedSize(horizontal: false, vertical: true)
            }

            countdown
                .padding(.top, 20)
                .padding(.bottom, 20)

            durationPicker

            Button {
                if lock.isLocked {
                    lock.stop()
                } else {
                    lock.refreshAccess()
                    if lock.hasAccessibilityAccess {
                        lock.start()
                    } else {
                        presentAccessibilitySetup()
                    }
                }
            } label: {
                HStack(spacing: 9) {
                    Image(systemName: lock.isLocked ? "lock.open" : "lock")
                        .font(.system(size: 14, weight: .semibold))
                    Text(lock.isLocked ? "Unlock now" : "Lock keyboard")
                        .font(.system(size: 15, weight: .semibold))
                    if !lock.isLocked {
                        Image(systemName: "arrow.right")
                            .font(.system(size: 12, weight: .semibold))
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 49)
                .foregroundStyle(style.buttonText)
                .background(lock.isLocked ? style.ink : style.buttonFill, in: .rect(cornerRadius: 14))
                .contentShape(.rect(cornerRadius: 14))
            }
            .buttonStyle(PressStyle())
            .accessibilityHint(lock.isLocked ? "Immediately restores keyboard input." : "Temporarily blocks keyboard input for the selected duration.")
            .padding(.top, 22)

            statusMessage
                .frame(height: 57)
                .padding(.top, 11)

            Rectangle()
                .fill(style.ink.opacity(0.10))
                .frame(height: 1)
                .padding(.vertical, 14)

            HStack(spacing: 20) {
                Label("Mouse stays active", systemImage: "computermouse")
                Label("Unlocks automatically", systemImage: "timer")
            }
            .font(.system(size: 11, weight: .medium))
            .foregroundStyle(style.muted)

            Text("Avoid the power / Touch ID key. It cannot be locked.")
                .font(.system(size: 10)).bold()
                .foregroundStyle(.red)
                .padding(.top, 10)
        }
        .padding(.horizontal, 44)
        .padding(.top, 20)
        .padding(.bottom, 20)
        .frame(maxWidth: .infinity)
        .foregroundStyle(style.ink)
        .background {
            style.paper
                .overlay(alignment: .topTrailing) {
                    Circle().fill(style.accent.opacity(0.045))
                        .frame(width: 330, height: 330)
                        .blur(radius: 65)
                        .offset(x: 140, y: -150)
                }
        }
    }

    private var masthead: some View {
        HStack(spacing: 10) {
            Button {
                withAnimation(navigationAnimation) {
                    showingAbout = true
                }
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "keyboard")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundStyle(style.accent)
                        .frame(width: 36, height: 36)
                        .background(style.accent.opacity(0.09), in: .rect(cornerRadius: 11))
                    Text(TastaCalmaAppName.appName.displayName)
                        .font(.system(size: 19, weight: .semibold, design: .rounded))
                        .tracking(-0.4)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(MastheadButtonStyle())
            .focusEffectDisabled()
            .accessibilityLabel("About \(Text(TastaCalmaAppName.appName.displayName))")
            .help("About \(Text(TastaCalmaAppName.appName.displayName))")
            Spacer()
            ViewThatFits(in: .horizontal) {
                HStack(spacing: 6) {
                    statusIndicator
                    Text(lock.isLocked ? "KEYBOARD LOCKED" : "A MOMENT OF CARE")
                        .font(.system(size: 9, weight: .semibold))
                        .tracking(1)
                }
                .padding(.horizontal, 11)
                .padding(.vertical, 8)
                .background(style.surface.opacity(0.65), in: Capsule())
                .fixedSize()

                statusIndicator
                    .accessibilityLabel(lock.isLocked ? "Keyboard locked" : "Keyboard unlocked")
            }

            LanguageMenu()
            ThemeToggle()
        }
    }

    private var statusIndicator: some View {
        Circle().fill(lock.isLocked ? style.accent : style.sage)
            .frame(width: 6, height: 6)
    }

    private struct MastheadButtonStyle: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
        }
    }

    private var countdown: some View {
        ZStack {
            Circle()
                .fill(style.surface.opacity(0.55))
                .padding(17)
                .shadow(color: tint.opacity(0.07), radius: 24, y: 9)
            ForEach(0..<60) { tick in
                Capsule()
                    .fill(style.ink.opacity(tick.isMultiple(of: 5) ? 0.22 : 0.10))
                    .frame(width: tick.isMultiple(of: 5) ? 2 : 1, height: tick.isMultiple(of: 5) ? 7 : 4)
                    .offset(y: -111)
                    .rotationEffect(.degrees(Double(tick) * 6))
            }
            Circle()
                .stroke(tint.opacity(0.10), lineWidth: 5)
                .padding(18)
            Circle()
                .trim(from: 0, to: lock.progress)
                .stroke(
                    AngularGradient(colors: [tint.opacity(0.45), tint], center: .center, startAngle: .zero, endAngle: .degrees(360)),
                    style: StrokeStyle(lineWidth: 5, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .padding(18)
                .animation(reduceMotion ? nil : .linear(duration: 0.05), value: lock.progress)

            VStack(spacing: 7) {
                Image(systemName: lock.didFinish ? "checkmark.seal" : (lock.isLocked ? "lock.fill" : "sparkles"))
                    .font(.system(size: 21, weight: .light))
                    .foregroundStyle(tint)
                    .contentTransition(.symbolEffect(.replace))
                    .padding(.bottom, 1)
                Text(String(format: "%02d:%02d", lock.displayedSeconds / 60, lock.displayedSeconds % 60))
                    .font(.system(size: 50, weight: .light, design: .rounded))
                    .monospacedDigit()
                    .tracking(-2)
                    .contentTransition(.numericText(countsDown: true))
                    .animation(reduceMotion ? nil : .easeOut(duration: 0.2), value: lock.displayedSeconds)
                Text(lock.isLocked ? "TIME TO CLEAN" : (lock.didFinish ? "HELLO, FRESH KEYS" : "READY WHEN YOU ARE"))
                    .font(.system(size: 9, weight: .semibold))
                    .tracking(1.8)
                    .foregroundStyle(style.muted)
                KeyboardDrawing(isLocked: lock.isLocked, tint: tint)
                    .frame(width: 74, height: 27)
                    .padding(.top, 6)
            }
        }
        .frame(width: 232, height: 232)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(lock.isLocked ? "Keyboard locked" : (lock.didFinish ? "Keyboard unlocked" : "Selected duration"))
        .accessibilityValue(lock.isLocked ? "\(lock.displayedSeconds) seconds remaining" : "\(lock.displayedSeconds) seconds")
    }

    private var durationPicker: some View {
        VStack(spacing: 11) {
            Text("MAKE TIME FOR A QUICK CLEAN")
                .font(.system(size: 9, weight: .semibold))
                .tracking(1.5)
                .foregroundStyle(style.muted)
            HStack(spacing: 5) {
                ForEach(KeyboardLockController.durations, id: \.self) { duration in
                    Button {
                        lock.selectDuration(duration)
                    } label: {
                        Text(duration < 60 ? "\(duration) sec" : "\(duration / 60) min")
                            .font(.system(size: 12, weight: lock.selectedDuration == duration ? .semibold : .medium))
                            .frame(maxWidth: .infinity)
                            .frame(height: 35)
                            .foregroundStyle(lock.selectedDuration == duration ? style.accent : style.muted)
                            .background {
                                if lock.selectedDuration == duration {
                                    RoundedRectangle(cornerRadius: 9)
                                        .fill(style.surface)
                                        .shadow(color: .black.opacity(0.05), radius: 3, y: 1)
                                }
                            }
                            .contentShape(.rect(cornerRadius: 9))
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("\(duration) seconds")
                    .accessibilityAddTraits(lock.selectedDuration == duration ? [.isSelected] : [])
                }
            }
            .padding(5)
            .background(style.ink.opacity(0.045), in: .rect(cornerRadius: 13))
            .disabled(lock.isLocked)
            .opacity(lock.isLocked ? 0.55 : 1)
        }
    }

    private var statusMessage: some View {
        VStack(spacing: 5) {
            if let notice = lock.notice {
                let message = notice.message(in: language)
                Text(message)
                    .foregroundStyle(style.accent)
                    .accessibilityLabel("Notice: \(message)")
            } else if lock.isLocked {
                Text("Wipe gently. Your keyboard will be back in a moment.")
                Text("Use your mouse to unlock early.")
            } else if lock.didFinish {
                Text("All done. Your keyboard is yours again.")
                    .foregroundStyle(style.sage)
            } else if !lock.hasAccessibilityAccess {
                Text("One-time setup: allow Accessibility access to lock your keys.")
            } else {
                Text("Ready for a little refresh?")
                Text("Key presses are blocked, never recorded.")
            }
            if !lock.hasAccessibilityAccess {
                Button("Set Up Accessibility", action: presentAccessibilitySetup)
                    .buttonStyle(.plain)
                    .foregroundStyle(style.accent)
                    .underline()
            }
        }
        .font(.system(size: 11))
        .lineSpacing(2)
        .lineLimit(2, reservesSpace: true)
        .multilineTextAlignment(.center)
        .foregroundStyle(style.muted)
        .fixedSize(horizontal: false, vertical: true)
    }

    private func refreshAccessibilitySetup() {
        lock.refreshAccess()
        if !lock.hasAccessibilityAccess && !hasPresentedAccessibilitySetupThisLaunch {
            presentAccessibilitySetup()
        }
    }

    private func presentAccessibilitySetup() {
        hasPresentedAccessibilitySetupThisLaunch = true
        showingAccessibilitySetup = true
    }
}

private struct KeyboardDrawing: View {
    let isLocked: Bool
    let tint: Color

    var body: some View {
        VStack(spacing: 2) {
            ForEach(0..<3) { row in
                HStack(spacing: 2) {
                    ForEach(0..<(row == 2 ? 7 : 10), id: \.self) { key in
                        RoundedRectangle(cornerRadius: 1.2)
                            .fill(tint.opacity(isLocked ? 0.40 : 0.22))
                            .frame(width: row == 2 && key == 3 ? 24 : 4, height: 4)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay(RoundedRectangle(cornerRadius: 4).stroke(tint.opacity(0.25), lineWidth: 1))
        .accessibilityHidden(true)
    }
}

private struct PressStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.86 : 1)
            .scaleEffect(configuration.isPressed && !reduceMotion ? 0.99 : 1)
            .animation(reduceMotion ? nil : .easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

#Preview {
    ContentView(
        showingAbout: .constant(false),
        hasPresentedAccessibilitySetupThisLaunch: .constant(false)
    )
}
