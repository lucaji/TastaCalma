//
//  AppLanguage.swift
//  TastaCalma
//
//  Created by Luca Cipressi - milletgrain on 12/09/2026.
//

import Foundation

enum AppLanguage: String, CaseIterable {
    static let storageKey = "interfaceLanguage"

    case system
    case english = "en"
    case german = "de"
    case spanish = "es"
    case french = "fr"
    case hindi = "hi"
    case italian = "it"
    case japanese = "ja"
    case portuguese = "pt-PT"
    case russian = "ru"
    case turkish = "tr"
    case ukrainian = "uk"
    case simplifiedChinese = "zh-Hans"
    case traditionalChinese = "zh-Hant"

    var nativeName: String {
        switch self {
        case .system: "Follow System"
        case .english: "English"
        case .german: "Deutsch"
        case .spanish: "Español"
        case .french: "Français"
        case .hindi: "हिन्दी"
        case .italian: "Italiano"
        case .japanese: "日本語"
        case .portuguese: "Português (Portugal)"
        case .russian: "Русский"
        case .turkish: "Türkçe"
        case .ukrainian: "Українська"
        case .simplifiedChinese: "简体中文"
        case .traditionalChinese: "繁體中文"
        }
    }

    func resolvedIdentifier(preferences: [String] = Locale.preferredLanguages) -> String {
        guard self == .system else { return rawValue }
        return Bundle.preferredLocalizations(
            from: Self.allCases.filter { $0 != .system }.map(\.rawValue),
            forPreferences: preferences
        ).first ?? "en"
    }

    var locale: Locale { Locale(identifier: resolvedIdentifier()) }

    // Foundation strings need an explicit resource bundle as well as a locale.
    // Keep Apple's language preferences untouched so Follow System restores them.
    func bundle(in resources: Bundle = .main) -> Bundle {
        guard let path = resources.path(forResource: resolvedIdentifier(), ofType: "lproj"),
              let bundle = Bundle(path: path) else { return resources }
        return bundle
    }

    var shortCode: String {
        switch resolvedIdentifier() {
        case "zh-Hans": "ZH-S"
        case "zh-Hant": "ZH-T"
        case "pt-PT": "PT"
        case let identifier: identifier.uppercased()
        }
    }

    var appName: String {
        String(localized: "TastaCalma", bundle: bundle(), locale: locale)
    }
}
