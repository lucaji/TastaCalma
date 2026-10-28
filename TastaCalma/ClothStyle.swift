//
//  ClothStyle.swift
//  TastaCalma
//
//  Created by Luca Cipressi - milletgrain on 12/09/2026.
//

import SwiftUI

struct ClothStyle {
    let environment: EnvironmentValues

    static func appearanceAnimation(reduceMotion: Bool) -> Animation? {
        reduceMotion ? nil : .easeInOut(duration: 0.35)
    }

    var paper: Color { resolved("Paper") }
    var ink: Color { resolved("Ink") }
    var muted: Color { resolved("Muted") }
    var accent: Color { resolved("ClothAccent") }
    var sage: Color { resolved("Sage") }
    var surface: Color { resolved("Surface") }
    var buttonFill: Color { resolved("ButtonFill") }
    var buttonText: Color { resolved("ButtonText") }

    private func resolved(_ name: String) -> Color {
        // Concrete color values let SwiftUI interpolate between appearances
        // instead of switching a dynamic asset's rendering in one step.
        Color(Color(name).resolve(in: environment))
    }
}
