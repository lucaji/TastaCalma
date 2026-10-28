//
//  AccessibilitySetupView.swift
//  TastaCalma
//
//  Created by Luca Cipressi - milletgrain on 12/09/2026.
//

// MARK: - Implementation Contract
//
// Purpose:
// Guide Accessibility setup and recovery using the controller's trust state.
//
// Responsibilities:
// - Recheck access while this sheet is waiting, including while Settings is active.
// - Explain recovery for an enabled entry that does not authorize this app copy.
//
// Design rules:
// - Checks never prompt or start a keyboard lock; the controller owns access state.
// - Rechecking stops when access is granted or the sheet disappears.

import SwiftUI

struct AccessibilitySetupView: View {
    let hasAccess: Bool
    let openSettings: () -> Void
    let checkAccess: () -> Void

    @Environment(\.dismiss) private var dismiss
    @Environment(\.self) private var environment
    @Environment(\.scenePhase) private var scenePhase
    @State private var illustratedStep = 0
    @AccessibilityFocusState private var successFocused: Bool

    private var style: ClothStyle { ClothStyle(environment: environment) }
    private var shouldAnimate: Bool {
        !hasAccess && !environment.accessibilityReduceMotion && scenePhase == .active
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 22) {
                    if hasAccess {
                        success
                    } else {
                        introduction
                        illustration
                        instructions
                        recoveryInstructions
                    }
                }
                .padding(28)
                .frame(maxWidth: .infinity)
            }
            .scrollBounceBehavior(.basedOnSize)

            Divider().overlay(style.ink.opacity(0.08))
            actions.padding(20)
        }
        .foregroundStyle(style.ink)
        .background(style.paper)
        .tint(style.accent)
        .animation(environment.accessibilityReduceMotion ? nil : .easeInOut(duration: 0.3), value: hasAccess)
        .task(id: hasAccess) { @MainActor in
            guard !hasAccess else { return }
            // Keep this independent of scenePhase and the decorative animation:
            // the user grants access while System Settings is in front.
            while !Task.isCancelled {
                checkAccess()
                do { try await Task.sleep(for: .seconds(1)) }
                catch { return }
            }
        }
        .task(id: shouldAnimate) {
            guard shouldAnimate else { return }
            while !Task.isCancelled {
                do { try await Task.sleep(for: .seconds(3)) }
                catch { return }
                guard !Task.isCancelled else { return }
                withAnimation(.easeInOut(duration: 0.5)) {
                    illustratedStep = (illustratedStep + 1) % 3
                }
            }
        }
        .onChange(of: hasAccess) { _, granted in
            successFocused = granted
        }
    }

    private var introduction: some View {
        VStack(spacing: 10) {
            Text("A little setup, just once")
                .font(.system(size: 25, weight: .semibold, design: .rounded))
                .accessibilityAddTraits(.isHeader)
            Text("Allow Accessibility access so the timer can temporarily block your keys. Key presses are never recorded.")
                .font(.system(size: 13))
                .foregroundStyle(style.muted)
                .fixedSize(horizontal: false, vertical: true)
        }
        .multilineTextAlignment(.center)
    }

    private var illustration: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: "accessibility")
                Text("Accessibility").font(.system(size: 12, weight: .semibold))
                Spacer()
                Image(systemName: "gearshape")
                    .foregroundStyle(illustratedStep == 0 ? style.accent : style.muted)
            }
            HStack(spacing: 10) {
                Image(systemName: "keyboard")
                    .font(.system(size: 19))
                    .foregroundStyle(style.accent)
                // The installed bundle keeps this filename in every language.
                Text(verbatim: "TastaCalma.app")
                    .font(.system(size: 13, weight: .medium))
                Spacer()
                Capsule()
                    .fill(illustratedStep == 2 ? style.sage : style.muted.opacity(0.3))
                    .frame(width: 36, height: 22)
                    .overlay(alignment: illustratedStep == 2 ? .trailing : .leading) {
                        Circle().fill(.white).frame(width: 18, height: 18).padding(2)
                    }
            }
            .padding(12)
            .background(style.paper, in: .rect(cornerRadius: 10))

            Image(systemName: "plus")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(illustratedStep == 1 ? style.buttonText : style.muted)
                .frame(width: 28, height: 26)
                .background(illustratedStep == 1 ? style.buttonFill : style.paper, in: .rect(cornerRadius: 6))
                .scaleEffect(illustratedStep == 1 && !environment.accessibilityReduceMotion ? 1.12 : 1)
        }
        .padding(16)
        .background(style.surface, in: .rect(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(style.ink.opacity(0.08)))
        // Static instructions below provide the complete accessible equivalent.
        .accessibilityHidden(true)
        .allowsHitTesting(false)
    }

    private var instructions: some View {
        VStack(alignment: .leading, spacing: 16) {
            step(0, title: "Open Accessibility Settings",
                 detail: "Go to System Settings → Privacy & Security → Accessibility.")
            step(1, title: "Add TastaCalma",
                 detail: "Click +, select TastaCalma.app in Applications, then click Open.")
            step(2, title: "Enable the switch",
                 detail: "Turn on the switch beside the app, then return here.")
        }
    }

    private func step(_ index: Int, title: LocalizedStringKey, detail: LocalizedStringKey) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text(verbatim: "\(index + 1)")
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .frame(width: 26, height: 26)
                .foregroundStyle(illustratedStep == index ? style.buttonText : style.accent)
                .background(illustratedStep == index ? style.buttonFill : style.accent.opacity(0.1), in: Circle())
            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(.system(size: 13, weight: .semibold))
                Text(detail)
                    .font(.system(size: 12))
                    .foregroundStyle(style.muted)
            }
            .fixedSize(horizontal: false, vertical: true)
        }
        .accessibilityElement(children: .combine)
    }

    private var recoveryInstructions: some View {
        DisclosureGroup("Switch is on, but setup is still waiting?") {
            VStack(alignment: .leading, spacing: 12) {
                Text("Click Check Again. If access is still unavailable, quit TastaCalma and reopen the same copy.")
                Button("Check Again", action: checkAccess)
                    .buttonStyle(.bordered)
                Text("Still waiting? Quit TastaCalma. In Accessibility settings, select its old entry and click −. Click +, select the copy you actually open, and enable its switch. Reopen that same copy.")
                Text("This copy of TastaCalma:")
                    .fontWeight(.medium)
                Text(verbatim: Bundle.main.bundleURL.path)
                    .textSelection(.enabled)
                Text("For normal use, keep TastaCalma.app in Applications. A previous development build may have a different permission entry.")
            }
            .fixedSize(horizontal: false, vertical: true)
            .padding(.top, 8)
        }
        .font(.system(size: 12))
        .foregroundStyle(style.muted)
    }

    private var success: some View {
        VStack(spacing: 18) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 64, weight: .light))
                .foregroundStyle(style.sage)
                .accessibilityHidden(true)
            Text("You’re ready")
                .font(.system(size: 27, weight: .semibold, design: .rounded))
                .accessibilityAddTraits(.isHeader)
                .accessibilityFocused($successFocused)
            Text("Accessibility access is enabled. Choose a duration and start the timer when you’re ready to clean.")
                .font(.system(size: 14))
                .foregroundStyle(style.muted)
                .fixedSize(horizontal: false, vertical: true)
        }
        .multilineTextAlignment(.center)
        .padding(.vertical, 60)
    }

    @ViewBuilder private var actions: some View {
        if hasAccess {
            Button("Done") { dismiss() }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .keyboardShortcut(.defaultAction)
        } else {
            // A vertical arrangement keeps long translations readable.
            VStack(spacing: 12) {
                Button(action: openSettings) {
                    Text("Open Accessibility Settings")
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .keyboardShortcut(.defaultAction)
                Button("Later") { dismiss() }
                    .buttonStyle(.plain)
                    .keyboardShortcut(.cancelAction)
            }
        }
    }
}

#Preview("Accessibility setup") {
    AccessibilitySetupView(hasAccess: false, openSettings: {}, checkAccess: {})
        .frame(width: 500, height: 650)
}

#Preview("Accessibility ready") {
    AccessibilitySetupView(hasAccess: true, openSettings: {}, checkAccess: {})
        .frame(width: 500, height: 650)
}
