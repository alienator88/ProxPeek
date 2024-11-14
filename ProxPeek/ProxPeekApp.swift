//
//  ProxPeekApp.swift
//  ProxPeek
//
//  Created by Alin Lupascu on 11/14/24.
//

import SwiftUI
import AppKit
import AlinFoundation

@main
struct ProxPeekApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var api = ProxmoxAPI.shared
    @StateObject private var updater = Updater(owner: "alienator88", repo: "ProxPeek")

    var body: some Scene {
        
        MenuBarExtra("Proxmox", systemImage: "xserve") {
            ContentView()
                .environmentObject(api)
                .onAppear {
                    api.fetchVMsAndLXCs()
                }
        }
        .menuBarExtraStyle(.window)

        Settings {
            SettingsView()
                .environmentObject(updater)
                .toolbarBackground(.clear)
        }


    }
}



class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
//        ProxmoxAPI.shared.fetchVMsAndLXCs()
    }
}
