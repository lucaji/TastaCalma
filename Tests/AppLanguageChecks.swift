//
//  AppLanguageChecks.swift
//  TastaCalma
//
//  Created by Luca Cipressi - milletgrain on 12/09/2026.
//

import Foundation

@main
struct AppLanguageChecks {
    static func main() throws {
        precondition(AppLanguage.system.resolvedIdentifier(preferences: ["it-IT", "en"]) == "it")
        precondition(AppLanguage.system.resolvedIdentifier(preferences: ["de-CH", "en"]) == "de")
        precondition(AppLanguage.system.resolvedIdentifier(preferences: ["zh-TW", "en"]) == "zh-Hant")
        precondition(AppLanguage.system.resolvedIdentifier(preferences: ["zh-CN", "en"]) == "zh-Hans")
        precondition(AppLanguage.system.resolvedIdentifier(preferences: ["nl", "fr-FR"]) == "fr")
        precondition(AppLanguage.system.resolvedIdentifier(preferences: ["nl"]) == "en")
        precondition(AppLanguage.italian.resolvedIdentifier(preferences: ["de"]) == "it")
        precondition(AppLanguage.simplifiedChinese.shortCode != AppLanguage.traditionalChinese.shortCode)

        // Run against a built app to catch resource/catalog drift as well as
        // accidental dependence on the process's preferred language.
        precondition(CommandLine.arguments.count == 2, "Pass the built TastaCalma.app path")
        let resources = Bundle(path: CommandLine.arguments[1])!
        for language in AppLanguage.allCases where language != .system {
            precondition(resources.localizations.contains(language.rawValue), "Missing \(language.rawValue)")
            precondition(language.bundle(in: resources) != resources, "No resource bundle for \(language.rawValue)")
        }
        func name(_ language: AppLanguage) -> String {
            String(localized: "TastaCalma", bundle: language.bundle(in: resources), locale: language.locale)
        }
        precondition(name(.german) == "Tastenruhe")
        precondition(name(.french) == "ToucheCalme")
        precondition(name(.italian) == "TastaCalma")
        precondition(name(.german) == "Tastenruhe", "Switching back must not reuse the last language")
        print("Language resolution and all 13 bundled localizations passed.")
    }
}
