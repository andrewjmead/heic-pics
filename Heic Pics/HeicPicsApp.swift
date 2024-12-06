//
//  Heic_PicsApp.swift
//  Heic Pics
//
//  Created by Andrew Mead on 11/20/24.
//

import CoreGraphics
import FileWatcher
import Foundation
import ImageIO
import LaunchAtLogin
import SwiftUI
import UniformTypeIdentifiers

// TODO: Add an option to drag an image onto the item to convert it on the fly (but where to put it and with what permissions...)
// TODO: Does not seem to work with HEIC images download via Safari
// tccutil reset All io.mead.Heic-Pics

@main
struct HeicPicsApp: App {
    private var hasAccessToDownloads = false
    @Environment(\.openSettings) private var openSettings
    @Environment(\.openWindow) private var openWindow
    @AppStorage("convertedImagesCount") private var convertedImagesCount: Int = 0
    @AppStorage("hasSeenGettingStarted") private var hasSeenGettingStarted: Bool = false

    init() {
        hasAccessToDownloads = checkDownloadsAccess()

        // App has no dock icon but does have menu bar icons. I originally used LSUIElement instead, but
        // it caused issues where windows weren't always brought into view when created.
        DispatchQueue.main.async {
            NSApp.setActivationPolicy(.accessory)
        }

        // Show the getting started window if they haven't seen it before
        DispatchQueue.main.async { [self] in
            if hasSeenGettingStarted == false && hasAccessToDownloads == true {
                showGettingStarted()
                hasSeenGettingStarted = true
            }
        }

        _ = Watcher { [self] imageURL in
            let imageFormat = UserDefaults.standard.string(forKey: "imageFormat") ?? "jpeg"
            let deleteOriginal = UserDefaults.standard.bool(forKey: "deleteOriginal")
            let wasSuccessful = ImageConverter.convert(imageURL, imageFormat: imageFormat)

            // Update the statistics
            if wasSuccessful {
                convertedImagesCount += 1
            }

            // Delete the original
            if wasSuccessful && deleteOriginal {
                do {
                    try FileManager.default.removeItem(at: imageURL)
                } catch {
                }
            }
        }
    }

    var body: some Scene {
        // Menu bar scene
        MenuBarExtra("HEIC Pics", systemImage: "photo.on.rectangle.angled") {
            Text("HEIC Pics")
                .font(.headline)
            Text("\(convertedImagesCount) Images Converted")
            
            if hasAccessToDownloads == false {
                Divider()
                Text("Unable to access downloads folder!")
                Button("Enable Access in System Preferences", action: handleOpenSystemPreferences)
            }
            
            Divider()
            Button("Getting Started", action: showGettingStarted)
                .keyboardShortcut("g")
            Button("Settings", action: handleOpenSettings)
                .keyboardShortcut(",")
            Button("Quit", action: handleQuit)
                .keyboardShortcut("q")
        }

        // Settings scene
        Settings {
            SettingsView()
                .frame(width: 400)
        }

        // Getting started window
        Window("Getting Started", id: "gettingStartedWindow") {
            GettingStartedView()
                .frame(width: 500)
        }
        .windowResizability(.contentSize)
        .windowStyle(.hiddenTitleBar)
    }

    func showGettingStarted() {
        openWindow(id: "gettingStartedWindow")
        FocusWindow.focus(id: "gettingStartedWindow")
    }

    func handleOpenSettings() {
        openSettings()
        FocusWindow.focus(title: "HEIC Pics Settings")
    }

    func handleOpenSystemPreferences() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_FilesAndFolders") {
            NSWorkspace.shared.open(url)
        }
    }

    func handleQuit() {
        NSApplication.shared.terminate(nil)
    }

    func checkDownloadsAccess() -> Bool {
        guard let downloadsURL = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first else {
            return false
        }

        do {
            _ = try FileManager.default.contentsOfDirectory(atPath: downloadsURL.path)
            return true
        } catch {
            return false
        }
    }
}
