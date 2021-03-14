//
//  ExpenseTrackerApp.swift
//  ExpenseTracker
//
//  Created by yongseongkim on 2021/03/07.
//

import SwiftUI

@main
struct ExpenseTrackerApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            RootView(model: .init())
        }
    }
}
