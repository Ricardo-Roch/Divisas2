//
//  Divisas_2App.swift
//  Divisas 2
//
//  Created by Ricardo Rocha Moreno on 15/10/25.
//

import SwiftUI

@main
struct Divisas_2: App {
    @AppStorage("appColorScheme") private var appColorScheme: AppColorScheme = .system
    
    var body: some Scene {
        WindowGroup {
            HomeView()
                .preferredColorScheme(appColorScheme.colorScheme)
        }
    }
}
