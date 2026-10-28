//
//  CleaningWindowLayoutChecks.swift
//  TastaCalma
//
//  Created by Luca Cipressi - milletgrain on 12/09/2026.
//

import AppKit

@main
struct CleaningWindowLayoutChecks {
    @MainActor
    static func main() {
        let layout = CleaningWindowLayout()
        let largeDisplay = CGSize(width: 1200, height: 1000)
        layout.naturalHeight = 780
        layout.updateContentSize(availableSize: largeDisplay, showingAbout: false)
        precondition(layout.contentSize == CGSize(width: 552, height: 780))

        // Longer and shorter translations of the hidden timer must not move About.
        layout.updateContentSize(availableSize: largeDisplay, showingAbout: true)
        for height: CGFloat in [840, 730, 810] {
            layout.naturalHeight = height
            layout.updateContentSize(availableSize: largeDisplay, showingAbout: true)
            precondition(layout.contentSize.height == 780)
        }

        // Display constraints still apply, without losing the preferred height.
        layout.updateContentSize(availableSize: CGSize(width: 500, height: 600), showingAbout: true)
        precondition(layout.contentSize == CGSize(width: 500, height: 600))
        layout.updateContentSize(availableSize: largeDisplay, showingAbout: true)
        precondition(layout.contentSize == CGSize(width: 552, height: 780))

        // Returning to the timer adopts the latest translation's measured height.
        layout.updateContentSize(availableSize: largeDisplay, showingAbout: false)
        precondition(layout.contentSize.height == 810)
        layout.naturalHeight = 730
        layout.updateContentSize(availableSize: largeDisplay, showingAbout: false)
        precondition(layout.contentSize.height == 730)
        layout.updateContentSize(availableSize: largeDisplay, showingAbout: true)
        precondition(layout.contentSize.height == 730)

        // Opening directly into About also establishes a stable preferred height.
        let aboutFirst = CleaningWindowLayout()
        aboutFirst.updateContentSize(availableSize: largeDisplay, showingAbout: true)
        let initialHeight = aboutFirst.contentSize.height
        aboutFirst.naturalHeight = 900
        aboutFirst.updateContentSize(availableSize: largeDisplay, showingAbout: true)
        precondition(aboutFirst.contentSize.height == initialHeight)
        aboutFirst.updateContentSize(availableSize: largeDisplay, showingAbout: false)
        precondition(aboutFirst.contentSize.height == 900)

        print("Window height preservation, display fitting, and timer return checks passed.")
    }
}
