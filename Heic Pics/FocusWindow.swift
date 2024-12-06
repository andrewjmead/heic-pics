//
//  FocusWindow.swift
//  Heic Pics
//
//  Created by Andrew Mead on 11/26/24.
//

import Foundation
import SwiftUI

struct FocusWindow {
    static func focus(title: String) {
        NSApp.windows.forEach { window in
            guard window.title == title else {
                return
            }
            
            NSApp.activate(ignoringOtherApps: true) // Activate app
            window.makeKeyAndOrderFront(nil) // Bring window to the front
            window.center()
        }
    }

    static func focus(id: String) {
        NSApp.windows.forEach { window in
            guard window.identifier?.rawValue == id else {
                return
            }

            NSApp.activate(ignoringOtherApps: true) // Activate app
            window.makeKeyAndOrderFront(nil) // Bring window to the front
            window.center()
        }
    }
}
