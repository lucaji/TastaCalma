//
//  TastaCalmaApp.swift
//  TastaCalma
//
//  Created by Luca Cipressi - milletgrain on 12/09/2026.
//

import SwiftUI

enum TastaCalmaAppName: String, Identifiable {
    case appName
    
    var id: String { rawValue }

    var displayName: LocalizedStringKey {
        switch self {
        case .appName:
            "TastaCalma"
        }
    }
}

@main
struct TastaCalmaApp: App {
    @State private var showingAbout = false
    // Keep setup dismissal across window recreation, but never across launches.
    @State private var hasPresentedAccessibilitySetupThisLaunch = false
    @AppStorage(AppLanguage.storageKey) private var language = AppLanguage.system
    @AppStorage(AppTheme.storageKey) private var theme = AppTheme.system

    var body: some Scene {
        Window(Text("TastaCalma", bundle: language.bundle()), id: "main") {
            ContentView(
                showingAbout: $showingAbout,
                hasPresentedAccessibilitySetupThisLaunch: $hasPresentedAccessibilitySetupThisLaunch
            )
                .preferredColorScheme(theme.colorScheme)
                .environment(\.locale, language.locale)
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .windowBackgroundDragBehavior(.enabled)
        .defaultPosition(.center)
        .commands {
            TastaCalmaCommands(showingAbout: $showingAbout)
        }
    }
}

private struct TastaCalmaCommands: Commands {
    @Binding var showingAbout: Bool
    @AppStorage(AppLanguage.storageKey) private var language = AppLanguage.system
    @Environment(\.openWindow) private var openWindow
    @FocusedValue(\.showTastaCalmaAbout) private var showAbout

    var body: some Commands {
        CommandGroup(replacing: .appInfo) {
            Button {
                if let showAbout {
                    showAbout()
                } else {
                    // Only reopen the window when there is no visible scene
                    // to navigate. Its first page will already be About.
                    showingAbout = true
                    openWindow(id: "main")
                }
            } label: {
                Text("About \(language.appName)", bundle: language.bundle())
            }
        }
        CommandGroup(after: .appInfo) {
            Menu {
                LanguagePicker()
            } label: {
                Text("Language", bundle: language.bundle())
            }
        }
    }
}

private struct ShowTastaCalmaAboutKey: FocusedValueKey {
    typealias Value = @MainActor () -> Void
}

extension FocusedValues {
    var showTastaCalmaAbout: (@MainActor () -> Void)? {
        get { self[ShowTastaCalmaAboutKey.self] }
        set { self[ShowTastaCalmaAboutKey.self] = newValue }
    }
}
