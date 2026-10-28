# TastaCalma

<p align="center">
  <img src="assets/tastacalma-app-icon.png" width="240" alt="Cloth artwork from the mammamia icon: a sage-green cleaning cloth with an embroidered Italian pinched-fingers gesture.">
</p>

<p align="center"><strong>A little pause. A cleaner keyboard.</strong></p>

TastaCalma is a small native macOS utility that temporarily blocks keyboard input
while you wipe your Mac's keys. Choose a timer, click **Lock keyboard**, and take a
moment to clean. Typing returns automatically when the countdown ends, and your
mouse or trackpad stays available throughout.

Built with **Swift 6 and SwiftUI**, with a quiet interface and a playful Italian
touch.

## Features

- **Five cleaning timers:** 30 seconds, 1, 2, 3, or 5 minutes.
- **Automatic unlock**, plus an **Unlock now** button to finish early.
- **Mouse and trackpad stay active** while keyboard events are filtered.
- **Remembers your last timer** and your preferred appearance.
- **System, Light, and Dark appearances**, with support for Reduce Motion.
- **Accessibility labels and spoken lock/unlock announcements.**
- **English and 12 translations**, including localized app names.
- **Works offline**, with no account, analytics, or third-party dependencies.

## Meet “mammamia” 🤌

The new icon has a nickname: **mammamia**. An ivory keyboard, a sage-green cloth,
an embroidered Italian pinched-fingers gesture, a tricolour cuff, and a tiny
tomato-red smudge give this little utility its sense of humour. Even a keyboard
deserves a moment of care after a messy snack.

The image above is the cloth layer from the bundled icon. The complete layered
icon lives in [`TastaCalma/AppIcon.icon`](TastaCalma/AppIcon.icon). All icon and
colour resources needed to build the app are included in this repository.
The author's separate design and exploration folder is private and is not
required to build the app.

## Download and install

Download **TastaCalma 1.0 (build 23)** for **macOS 15.6 or later**, with native
support for **Intel and Apple silicon**. It is distributed outside the Mac App
Store as a **Developer ID signed and notarized ZIP download**.

- [Download TastaCalma-1.0.zip](https://github.com/lucaji/TastaCalma/releases/download/v1.0/TastaCalma-1.0.zip)
- [Download SHA256SUMS](https://github.com/lucaji/TastaCalma/releases/download/v1.0/SHA256SUMS)
- [Read the 1.0 release notes](https://github.com/lucaji/TastaCalma/releases/tag/v1.0)

GitHub's automatic
**Source code (zip)** and **Source code (tar.gz)** downloads contain source code,
not the ready-to-run app.

1. Check that your Mac runs macOS 15.6 or later. The ZIP contains a universal app
   for Intel and Apple silicon Macs, together with `LICENSE.txt`.
2. Put the app ZIP and `SHA256SUMS` in the same folder. In Terminal, change to that
   folder and run `shasum -a 256 -c SHA256SUMS`; the ZIP should be reported as `OK`.
   This confirms that the download matches the published checksum.
3. Extract the ZIP, move **TastaCalma.app** into **Applications**, and open it.
4. Complete the Accessibility setup described below. Notarization does not grant
   Accessibility permission automatically.

The `v1.0` tag identifies the public source snapshot for this release. The app ZIP
and checksum are release attachments; neither is part of the source repository.

## First use

1. Once per app launch when Accessibility permission is missing or disabled, an
   animated setup sheet explains the steps. Click **Open Accessibility Settings**
   in the sheet. **Later** dismisses it for that launch;
   **Set Up Accessibility** or attempting to start a lock opens it again.
2. In **System Settings → Privacy & Security → Accessibility**, enable the app.
   If it is missing, click **+**, select **TastaCalma.app** in Applications, click
   **Open**, and enable its switch. The installed filename is TastaCalma.app even
   when the app uses a translated name in its interface.
3. While the setup sheet is open, the app checks permission once a second,
   including while System Settings is in front. Once access is detected, the
   sheet shows **You’re ready**; return to the app and click **Done**.
4. Choose a duration, release any held modifier keys, and click **Lock keyboard**.
5. Wipe your keys while the countdown runs. Click **Unlock now** with your mouse
   or trackpad to finish early, or wait for the timer to expire.

Granting Accessibility permission does not start a lock automatically. Every
cleaning session starts with an explicit click.

If the switch is already on but setup is still waiting, expand **Switch is on,
but setup is still waiting?** and click **Check Again**. If access is still
unavailable, quit TastaCalma and reopen the same copy. If that does not resolve
it, quit the app, remove its stale entry from Accessibility settings with **−**,
then use **+** to add the copy you actually open and enable its switch. Reopen
that same copy. The recovery section shows the running app's path so you can
identify it. For normal use, keep the app in Applications; an earlier development
build may have a different permission entry. Rechecking does not prompt or change
macOS permissions, and stops when access is granted or the sheet closes.

All setup instructions stay visible while a decorative illustration highlights
each step. Reduce Motion disables the repeating animation. The sheet scrolls on
smaller displays, keeps its action buttons visible, and follows the app's language
and appearance. It automatically appears at most once per launch, including if
access is disabled while the app is running and you return to it. Dismissing it
never requests permission or starts a timer. Closing and reopening the window
does not reset the launch-only dismissal.

The appearance button cycles through **System → Light → Dark**. Click the app
name at the top of the window, or use the app menu's **About** command, to view
the author and version information. Changing appearance or visiting About keeps
the current timer running; return to the timer page to unlock early.

## Permissions, privacy, and limits

TastaCalma uses Accessibility permission to install a temporary Core Graphics
event filter. During a cleaning session it suppresses key-down, key-up,
modifier-change, and supported media-key events delivered to that filter.
It does not record, store, or transmit the content of your keystrokes.

The app saves your timer and appearance preferences locally. There is no account,
analytics service, or background network feature. The optional website and
Discord links in About open external services when clicked.

Keep these limits in mind:

- **Power / Touch ID cannot be blocked.** Avoid that key while cleaning.
- **Secure Keyboard Entry can prevent filtering.** TastaCalma refuses to start
  when it detects this mode and ends an active lock if another app enables it.
- **The lock can end early.** Closing the window, quitting, sleeping, changing
  user sessions, losing Accessibility access, or an interrupted event filter
  releases keyboard input. Stop cleaning if an interruption notice appears.
- **Hardware and system shortcuts vary.** Media keys and system-reserved actions
  need verification on your own Mac and keyboard.
- **Keep a mouse or trackpad available.** Keyboard shortcuts are filtered during
  the countdown, including shortcuts you might otherwise use to leave the app.

This is a short-session cleaning aid. It does not replace the macOS login screen
or provide a security lock for your computer.

## Languages

The [string catalog](TastaCalma/Localizable.xcstrings) includes English as the
source language and 12 translations:

| Language | Locale | App name in the interface |
| --- | --- | --- |
| English | `en` | TastaCalma |
| Italian · Italiano | `it` | TastaCalma |
| German · Deutsch | `de` | Tastenruhe |
| French · Français | `fr` | ToucheCalme |
| Spanish · Español | `es` | TeclaCalma |
| Portuguese (Portugal) · Português | `pt-PT` | TastaCalma |
| Hindi · हिन्दी | `hi` | तास्ताकाल्मा |
| Japanese · 日本語 | `ja` | タスタカルマ |
| Russian · Русский | `ru` | ТастаКальма |
| Turkish · Türkçe | `tr` | TastaKalma |
| Ukrainian · Українська | `uk` | Тастакальма |
| Simplified Chinese · 简体中文 | `zh-Hans` | 塔斯塔卡尔玛 |
| Traditional Chinese · 繁體中文 | `zh-Hant` | 塔斯塔卡爾瑪 |

Language selection follows macOS language preferences by default. Choose
**Language** in the app menu, or click the short language code beside the
appearance button on the timer or About page, to select a language directly.
The choice is saved and updates the app's interface without restarting or
interrupting a cleaning timer. **Follow System** restores macOS language selection.
Language names appear in their native script; `ZH-S` and `ZH-T` distinguish
Simplified and Traditional Chinese. Standard macOS menu commands and system
permission dialogs continue to use the language selected by macOS.

Many catalog entries are
marked as machine-translated, and some interface text may still appear in
English. Native-speaker corrections, clearer permission instructions, and layout
checks in every language are welcome.


## Build and run from source

The app target is configured for **macOS 15.6 or later** and **Swift 6**.
The shared scheme currently carries **Xcode 27.1** metadata; use Xcode 27.1 or a
compatible version that supports the project and its Icon Composer assets.
Compatibility with older Xcode versions has not been established.

Paths in this README are relative to the **public repository root**, which
contains `TastaCalma.xcodeproj`, `TastaCalma/`, and `Tests/`. In the author's
private parent workspace, this public content lives inside `src/`; change into
that folder before following repository-root commands.

1. Download or clone this repository.
2. Open [`TastaCalma.xcodeproj`](TastaCalma.xcodeproj) in Xcode.
3. Select the **TastaCalma** scheme and **My Mac** as the destination.
4. In **Signing & Capabilities**, select your own development team or local
   signing identity. The checked-in project contains the author's signing
   settings; use a bundle identifier appropriate to your own signed build.
5. Choose **Product → Build**, then **Product → Run**. The shared scheme already
   selects **TastaCalma.app** as its Run executable.
6. Follow the Accessibility setup below before starting your first timer.

The shared scheme selects these configurations:

| Scheme | Run configuration | Archive configuration | App Sandbox |
| --- | --- | --- | --- |
| **TastaCalma** | Debug | **Release** | Disabled |

**Debug is a build configuration, not a separate shared scheme.** Use
**TastaCalma** for normal development and direct-distribution archives. Hardened
Runtime is enabled in its Debug and Release configurations.

All required app resources are included. No package installation or download of
the private design folder is required. A local development build is not the
Developer ID signed and notarized release download.

## Archive and notarize a release

For the direct-distribution binary, select **TastaCalma**. Its Archive action is
already configured to use **Release**, even when the Run action uses Debug.

1. Finalize the release version and build number, and identify the exact public
   source commit that the release tag will reference. Build from that source
   without additional unpublished implementation changes.
2. Select **TastaCalma → My Mac**. Under **Product → Scheme → Edit Scheme →
   Archive**, confirm that **Build Configuration** is **Release**, then choose
   **Product → Archive**.
3. In Xcode Organizer, choose **Distribute App** and the workflow for distribution
   outside the Mac App Store using **Developer ID** signing and notarization.
   Export the processed app after notarization succeeds. The distributed app
   needs a **Developer ID Application** signature, Hardened Runtime, a secure
   timestamp, and no enabled `get-task-allow` entitlement. Development signing
   alone is insufficient.
4. Verify the exported app's signature and notarization result, and ensure the
   notarization ticket is stapled to **TastaCalma.app**. For a custom workflow,
   submit with `notarytool`, then staple and validate the app after acceptance.
   A ZIP can be submitted for notarization, but the ticket must be stapled to the
   app inside it; the ZIP itself cannot be stapled.
5. Test the actual release download on a Gatekeeper-enabled Mac, including first
   launch, Accessibility setup, automatic expiry, early unlock, and pointer
   access. Verify the architectures and macOS versions claimed in its release
   notes; source settings alone do not establish compatibility.
6. Package the final stapled app as a ZIP using `ditto`, and include a copy of
   the MIT `LICENSE` with the binary distribution. Compute the SHA-256 checksum
   of the **final ZIP** and save the checksum and ZIP filename in `SHA256SUMS`.
   Any subsequent ZIP change requires regenerating the checksum.
7. Attach the app ZIP and `SHA256SUMS` to a GitHub release whose tag points to the
   matching **public source commit**. State the app version/build, supported
   architectures, and macOS requirements in the release notes.

Apple's references:
[Notarizing macOS software before distribution](https://developer.apple.com/documentation/security/notarizing-macos-software-before-distribution),
[Customizing the notarization workflow](https://developer.apple.com/documentation/security/customizing-the-notarization-workflow),
and [Packaging Mac software for distribution](https://developer.apple.com/documentation/xcode/packaging-mac-software-for-distribution).

## Source guide

| Location | Purpose |
| --- | --- |
| `TastaCalma.xcodeproj` | Xcode project and shared scheme. |
| `TastaCalma/TastaCalmaApp.swift` | App entry point, window, and About menu. |
| `TastaCalma/ContentView.swift` | Timer interface, duration selection, status, and lifecycle handling. |
| `TastaCalma/KeyboardLockController.swift` | Permissions, event filter, countdown updates, and cleanup. |
| `TastaCalma/AccessibilitySetupView.swift` | Animated Accessibility setup, manual-add instructions, and permission success state. |
| `TastaCalma/KeyboardLockSession.swift` | Monotonic deadline and event-filtering rules. |
| `TastaCalma/CleaningWindowLayout.swift` | Window sizing, placement, and display changes. |
| `TastaCalma/AppTheme.swift` and `TastaCalma/ClothStyle.swift` | Saved appearance choice and shared colours. |
| `TastaCalma/AboutView.swift` | About page and author links. |
| `TastaCalma/Localizable.xcstrings` | Translations and localized app names. |
| `TastaCalma/AppIcon.icon` and `TastaCalma/Assets.xcassets` | Bundled icon and colour resources. |
| `Tests/KeyboardLockSessionChecks.swift` | Standalone deadline and filtering checks. |
| `Tests/AppLanguageChecks.swift` | Language resolution and localization checks against a built app bundle. |
| `Tests/CleaningWindowLayoutChecks.swift` | Standalone window-layout checks. |

The deadline is checked both by the display timer and by the event callback, so
delayed display updates do not extend event suppression beyond the deadline.
The filter is installed for an active session and removed when that session ends.

## Checks and contributions

The keyboard-session checks below exercise all five durations, exact expiry,
overdue event delivery, keyboard and media-event filtering, pointer passthrough,
and countdown rounding. They do not start a live keyboard lock.

Run these commands from the repository root with Xcode's command-line tools
selected:

```sh
tastacalma_check_dir="$(mktemp -d "${TMPDIR:-/tmp}/tastacalma-checks.XXXXXX")"
xcrun swiftc -swift-version 6 \
  -module-cache-path "$tastacalma_check_dir/module-cache" \
  TastaCalma/KeyboardLockSession.swift \
  Tests/KeyboardLockSessionChecks.swift \
  -o "$tastacalma_check_dir/KeyboardLockSessionChecks"
"$tastacalma_check_dir/KeyboardLockSessionChecks"
```

This command checks the filtering policy and timer logic. The other check files
listed above are separate entry points; `AppLanguageChecks.swift` additionally
requires the path to a built app bundle to inspect its localized resources.
Live permission handling, physical keyboards, VoiceOver, translated layouts,
and behaviour across macOS versions also require testing in the running app.

Bug reports, focused improvements, and translation corrections are welcome.
For a useful issue, include your macOS version, app version/build, keyboard model,
interface language, steps to reproduce, and the expected and actual behaviour.
For build problems, include your Xcode version and the relevant error message.

For changes to keyboard locking, check automatic expiry and early unlock, pointer
access, permission refusal, Secure Keyboard Entry, and cleanup on window closure,
sleep, or session changes. For interface changes, check both appearances, Reduce
Motion, and long translated strings. Keep contributions independent of the
unpublished design folder.

## Author

Created by **Luca Cipressi · Milletgrain**.

- [Website](https://lucaji.github.io)
- [Milletgrain community on Discord](https://discord.gg/2AMS8MKx5G)

## License

The source code, documentation, and bundled artwork, including the “mammamia”
app icon, are available under the [MIT License](LICENSE).

The separate parent-level `assets` folder is private, is not included in the
public repository, and is not covered by this license grant.
