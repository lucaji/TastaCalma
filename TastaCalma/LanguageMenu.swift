//
//  LanguageMenu.swift
//  TastaCalma
//
//  Created by Luca Cipressi - milletgrain on 12/09/2026.
//

import SwiftUI

/// Both entry points share the same persisted selection and native checkmarks.
struct LanguagePicker: View {
    @AppStorage(AppLanguage.storageKey) private var language = AppLanguage.system

    var body: some View {
        Picker(selection: $language) {
            Text("Follow System", bundle: language.bundle())
                .tag(AppLanguage.system)
            Divider()
            ForEach(AppLanguage.allCases.filter { $0 != .system }, id: \.self) { option in
                Text(verbatim: option.nativeName).tag(option)
            }
        } label: {
            Text("Language", bundle: language.bundle())
        }
        .pickerStyle(.inline)
        .environment(\.locale, language.locale)
    }
}

struct LanguageMenu: View {
    @AppStorage(AppLanguage.storageKey) private var language = AppLanguage.system
    @Environment(\.self) private var environment

    var body: some View {
        Menu {
            LanguagePicker()
        } label: {
            Text(verbatim: language.shortCode)
                .font(.system(size: 10, weight: .semibold, design: .rounded))
                .monospaced()
                .foregroundStyle(ClothStyle(environment: environment).ink)
                .frame(minWidth: 30, minHeight: 30)
                .contentShape(Rectangle())
        }
        .menuStyle(.borderlessButton)
        .menuIndicator(.hidden)
        .fixedSize()
        .help("Language")
        .accessibilityLabel("Language")
        .accessibilityValue(language == .system
            ? Text("Follow System", bundle: language.bundle())
            : Text(verbatim: language.nativeName))
    }
}
