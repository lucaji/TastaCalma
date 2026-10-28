//
//  AppTheme.swift
//  TastaCalma
//
//  Created by Luca Cipressi - milletgrain on 12/09/2026.
//

import SwiftUI

enum AppTheme: String {
    static let storageKey = "appearanceTheme"

    case system
    case light
    case dark

    var next: AppTheme {
        switch self {
        case .system: .light
        case .light: .dark
        case .dark: .system
        }
    }

    func title(in language: AppLanguage) -> String {
        switch self {
        case .system: String(localized: "System", bundle: language.bundle(), locale: language.locale)
        case .light: String(localized: "Light", bundle: language.bundle(), locale: language.locale)
        case .dark: String(localized: "Dark", bundle: language.bundle(), locale: language.locale)
        }
    }

    var symbol: String {
        switch self {
        case .system: "circle.lefthalf.filled"
        case .light: "sun.max"
        case .dark: "moon"
        }
    }

    func description(in language: AppLanguage) -> String {
        switch self {
        case .system: String(localized: "Automatically follows your Mac’s light or dark appearance.", bundle: language.bundle(), locale: language.locale)
        case .light: String(localized: "Keeps \(language.appName) light, regardless of your Mac’s appearance.", bundle: language.bundle(), locale: language.locale)
        case .dark: String(localized: "Keeps \(language.appName) dark, regardless of your Mac’s appearance.", bundle: language.bundle(), locale: language.locale)
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: nil
        case .light: .light
        case .dark: .dark
        }
    }
}

struct ThemeToggle: View {
    @Environment(\.self) private var environment
    @AppStorage(AppLanguage.storageKey) private var language = AppLanguage.system
    @AppStorage(AppTheme.storageKey) private var theme = AppTheme.system
    @State private var isHovering = false

    var body: some View {
        Button {
            theme = theme.next
        } label: {
            Image(systemName: theme.symbol)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(ClothStyle(environment: environment).ink)
                .frame(width: 30, height: 30)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .focusEffectDisabled()
        .fixedSize()
        .onHover { isHovering = $0 }
        .overlay(alignment: .topTrailing) {
            AppearanceHoverCard(theme: theme)
                .padding(.top, 40)
                .opacity(isHovering ? 1 : 0)
                .animation(environment.accessibilityReduceMotion ? nil : .easeInOut(duration: 0.15), value: isHovering)
                // The card must never interrupt the button's hover tracking
                // or consume clicks, including while its colors are fading.
                .allowsHitTesting(false)
                .accessibilityHidden(true)
        }
        .onChange(of: environment.isEnabled) { _, isEnabled in
            if !isEnabled { isHovering = false }
        }
        .onDisappear { isHovering = false }
        .accessibilityLabel("Appearance")
        .accessibilityValue(theme.title(in: language))
        .accessibilityHint("\(theme.description(in: language)) Switches to \(theme.next.title(in: language)) appearance. Your choice is saved.")
    }
}

private struct AppearanceHoverCard: View {
    let theme: AppTheme
    @Environment(\.self) private var environment
    @AppStorage(AppLanguage.storageKey) private var language = AppLanguage.system

    private var style: ClothStyle { ClothStyle(environment: environment) }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: theme.symbol)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(style.accent)
                    .frame(width: 34, height: 34)
                    .background(style.accent.opacity(0.10), in: .rect(cornerRadius: 10))

                VStack(alignment: .leading, spacing: 3) {
                    Text("Appearance")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(style.muted)
                    Text(theme.title(in: language))
                        .font(.system(size: 15, weight: .semibold))
                }
            }

            Text(theme.description(in: language))
                .font(.system(size: 12))
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)

            Rectangle()
                .fill(style.ink.opacity(0.10))
                .frame(height: 1)

            VStack(alignment: .leading, spacing: 5) {
                Label("Click for \(theme.next.title(in: language))", systemImage: "arrow.triangle.2.circlepath")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(style.accent)
                Text("System → Light → Dark")
                Text("Your choice is saved for next time.")
            }
            .font(.system(size: 10))
            .foregroundStyle(style.muted)
        }
        .padding(16)
        .frame(width: 264, alignment: .leading)
        .fixedSize(horizontal: false, vertical: true)
        .foregroundStyle(style.ink)
        .background(style.surface, in: .rect(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(style.ink.opacity(0.10), lineWidth: 1)
        }
        .shadow(color: .black.opacity(0.18), radius: 16, y: 7)
        .animation(ClothStyle.appearanceAnimation(reduceMotion: environment.accessibilityReduceMotion), value: environment.colorScheme)
    }
}
