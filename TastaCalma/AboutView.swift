//
//  AboutView.swift
//  TastaCalma
//
//  Created by Luca Cipressi - milletgrain on 12/09/2026.
//

import SwiftUI
internal import System

struct AboutView: View {
    let onBack: () -> Void
    @AppStorage(AppLanguage.storageKey) private var language = AppLanguage.system
    @Environment(\.self) private var environment

    private var style: ClothStyle { ClothStyle(environment: environment) }

    private var versionDescription: String {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String
        let versionText = String(localized: "Version", bundle: language.bundle(), locale: language.locale)
        switch (version, build) {
        case let (version?, build?):
            return String("\(versionText) \(version) (\(build))")
        case let (version?, nil):
            return String("\(versionText) \(version)")
        default:
            return String(localized: "Version unavailable", bundle: language.bundle(), locale: language.locale)
        }
    }

    private var copyright: String? {
        guard let text = Bundle.main.object(forInfoDictionaryKey: "NSHumanReadableCopyright") as? String,
              !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return nil
        }
        return text
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: onBack) {
                    Label("Back", systemImage: "chevron.left")
                }
                .buttonStyle(.borderless)
                .keyboardShortcut(.cancelAction)
                .accessibilityHint("Returns to the keyboard timer.")

                Spacer()

                Text("About \(Text(TastaCalmaAppName.appName.displayName))")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(style.muted)

                LanguageMenu()
                ThemeToggle()
            }
            .zIndex(1)

            Spacer(minLength: 24)
            details
            Spacer(minLength: 24)
        }
        .padding(.horizontal, 44)
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .foregroundStyle(style.ink)
        .tint(style.accent)
        .background(style.paper)
    }

    private var details: some View {
        VStack(spacing: 0) {
            Image(systemName: "keyboard")
                .font(.system(size: 36, weight: .light))
                .foregroundStyle(style.accent)
                .frame(width: 88, height: 88)
                .background(style.accent.opacity(0.09), in: .rect(cornerRadius: 25))
                .overlay(alignment: .topTrailing) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 19, weight: .medium))
                        .foregroundStyle(style.accent)
                        .padding(7)
                        .background(style.paper, in: Circle())
                        .offset(x: 8, y: -8)
                }
                .accessibilityHidden(true)

            Text(TastaCalmaAppName.appName.displayName)
                .font(.system(size: 30, weight: .semibold, design: .rounded))
                .tracking(-0.7)
                .padding(.top, 20)

            Text(versionDescription)
                .font(.system(size: 12))
                .foregroundStyle(style.muted)
                .textSelection(.enabled)
                .padding(.top, 5)
            
            Text("written by Luca Cipressi (Milletgrain)")
                .padding(.top, 10)
            Divider().padding(10)
            HStack(spacing: 10) {
                AboutDestinationLink(
                    title: Text("Website"),
                    subtitle: Text(verbatim: "lucaji.github.io/tastacalma/"),
                    symbol: "globe",
                    destination: URL(string: "https://lucaji.github.io/tastacalma")!
                )
                AboutDestinationLink(
                    title: Text("Discord"),
                    subtitle: Text("MILLETGRAIN community"),
                    symbol: "bubble.left.and.bubble.right",
                    destination: URL(string: "https://discord.gg/2AMS8MKx5G")!
                )
            }
            .fixedSize(horizontal: false, vertical: true)
            .padding(.vertical, 8)
            Divider().padding(.top, 10)

            Text("A little pause.\nA cleaner keyboard.")
                .font(.system(size: 21, weight: .regular, design: .serif))
                .padding(.top, 24)
                .lineLimit(2, reservesSpace: true)
                .multilineTextAlignment(.center)

            Text("\(Text(TastaCalmaAppName.appName.displayName)) temporarily pauses keyboard input so you can wipe your keys clean.\nYour keyboard returns automatically when the timer ends.")
                .font(.system(size: 13))
                .lineLimit(4, reservesSpace: true)
                .lineSpacing(5)
                .foregroundStyle(style.muted)
                .padding(.top, 12)
                .multilineTextAlignment(.center)
            HStack {
                AboutDestinationLink(
                    title: Text("App Store"),
                    subtitle: Text("My app catalog."),
                    symbol: "storefront",
                    destination: URL(string: "https://apps.apple.com/developer/luca-cipressi/id941617723")!
                )
                AboutDestinationLink(
                    title: Text("OPEN SOURCE"),
                    subtitle: Text("\(Text(TastaCalmaAppName.appName.displayName)) on GitHub."),
                    symbol: "swirl.circle.righthalf.filled.inverse",
                    destination: URL(string: "https://github.com/lucaji/TastaCalma")!
                )
            }
            .padding(.top, 22)
            
            if let copyright {
                Text(copyright)
                    .font(.system(size: 10))
                    .foregroundStyle(style.muted)
                    .padding(.top, 16)
            }
        }
        .fixedSize(horizontal: false, vertical: true)
        .frame(maxWidth: 360)
    }
}

private struct AboutDestinationLink: View {
    let title: Text
    let subtitle: Text?
    let symbol: String
    let destination: URL

    @Environment(\.self) private var environment
    @State private var isHovering = false

    private var style: ClothStyle { ClothStyle(environment: environment) }

    init(title: Text, subtitle: Text? = nil, symbol: String, destination: URL) {
        self.title = title
        self.subtitle = subtitle
        self.symbol = symbol
        self.destination = destination
    }
    
    var body: some View {
        Link(destination: destination) {
            VStack(spacing: 7) {
                Image(systemName: symbol)
                    .font(.system(size: 17, weight: .regular))
                    .accessibilityHidden(true)

                HStack(spacing: 4) {
                    title
                        .font(.system(size: 13, weight: .medium))
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 10, weight: .medium))
                        .accessibilityHidden(true)
                }
                if self.subtitle != nil {
                    subtitle
                        .font(.system(size: 11))
                        .foregroundStyle(style.muted)
                }
            }
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal, 8)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .foregroundStyle(style.accent)
            .background(isHovering ? style.accent.opacity(0.10) : style.surface, in: .rect(cornerRadius: 12))
            .contentShape(.rect(cornerRadius: 12))
        }
        .buttonStyle(.plain)
        .onHover { isHovering = $0 }
        .onDisappear { isHovering = false }
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    ContentView(
        showingAbout: .constant(true),
        hasPresentedAccessibilitySetupThisLaunch: .constant(false)
    )
}
