//
//  PossamApp.swift
//  Possam
//
//  Created by Akash Thakur on 4/29/25.
//


import SwiftUI

@main
struct PossamApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            AppCoordinator()
        }
    }
}
