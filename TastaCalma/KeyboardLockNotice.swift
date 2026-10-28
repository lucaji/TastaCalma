//
//  KeyboardLockNotice.swift
//  TastaCalma
//
//  Created by Luca Cipressi - milletgrain on 12/09/2026.
//

import Foundation

/// Keep notices semantic so an already-visible message follows a language change.
enum KeyboardLockNotice {
    case accessRemoved
    case enableAccess
    case secureInput
    case releaseModifiers
    case checkAccess
    case couldNotStart
    case lockNotEnabled
    case secureInputInterrupted
    case systemInterrupted
    case sleep
    case sessionChanged

    func message(in language: AppLanguage) -> String {
        switch self {
        case .accessRemoved:
            String(localized: "Keyboard unlocked. Accessibility access was removed.", bundle: language.bundle(), locale: language.locale)
        case .enableAccess:
            String(localized: "Enable \(language.appName) in System Settings → Privacy & Security → Accessibility, then return here.", bundle: language.bundle(), locale: language.locale)
        case .secureInput:
            String(localized: "Secure Keyboard Entry is active. Close password fields or turn it off in the app using it, then try again.", bundle: language.bundle(), locale: language.locale)
        case .releaseModifiers:
            String(localized: "Release the modifier keys, then click Lock keyboard.", bundle: language.bundle(), locale: language.locale)
        case .checkAccess:
            String(localized: "Keyboard locking could not start. Check \(language.appName)’s Accessibility access and reopen the app if you just enabled it.", bundle: language.bundle(), locale: language.locale)
        case .couldNotStart:
            String(localized: "Keyboard locking could not start. Please try again.", bundle: language.bundle(), locale: language.locale)
        case .lockNotEnabled:
            String(localized: "macOS did not enable the keyboard lock. Please check Accessibility access.", bundle: language.bundle(), locale: language.locale)
        case .secureInputInterrupted:
            String(localized: "Keyboard unlocked: another app enabled Secure Keyboard Entry. Stop cleaning before continuing.", bundle: language.bundle(), locale: language.locale)
        case .systemInterrupted:
            String(localized: "macOS interrupted the keyboard lock. Stop cleaning and start a new timer when ready.", bundle: language.bundle(), locale: language.locale)
        case .sleep:
            String(localized: "Keyboard unlocked because your Mac is going to sleep.", bundle: language.bundle(), locale: language.locale)
        case .sessionChanged:
            String(localized: "Keyboard unlocked because your Mac’s session changed.", bundle: language.bundle(), locale: language.locale)
        }
    }
}
