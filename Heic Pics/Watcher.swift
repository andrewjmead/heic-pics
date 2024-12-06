//
//  Watcher.swift
//  Heic Pics
//
//  Created by Andrew Mead on 11/22/24.
//

import FileWatcher
import Foundation

// TODO: Can this be a struct now? 🤷‍♂️
struct Watcher {
    init(_ callback: @escaping (URL) -> Void) {
        // TODO: This should move into a start method so I can return a bool if it attached successfully or not...
        let sandboxedDownloadsURL = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first
        
        guard let sandboxedDownloadsURL else {
            return
        }
        
        let filewatcher = FileWatcher([sandboxedDownloadsURL.path])

        filewatcher.callback = { [self] event in
            guard event.fileCreated || event.fileRenamed else {
                return
            }

            guard let fileURL = URL(string: event.path) else {
                return
            }
            
            guard let sandboxedURL = self.getSandboxedURL(for: fileURL) else {
                return
            }
            
            guard FileManager.default.fileExists(atPath: sandboxedURL.path) else {
                return
            }

            guard sandboxedURL.pathExtension.lowercased() == "heic" else {
                return
            }

            callback(sandboxedURL)
        }

        filewatcher.start()
    }

    private func getSandboxedURL(for fileURL: URL) -> URL? {
        // Get the sandboxed Downloads directory URL
        guard let sandboxedDownloadsURL = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first else {
            return nil
        }

        // Get the standard Downloads directory URL
        guard let downloadsURL = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first?.resolvingSymlinksInPath() else {
            return nil
        }

        // Ensure the fileURL is inside the Downloads directory
        guard fileURL.path.hasPrefix(downloadsURL.path) else {
            return nil
        }

        // Calculate the relative path from the Downloads directory to the file
        var relativePath = fileURL.path.replacingOccurrences(of: downloadsURL.path, with: "")

        // Trim the leading character if it's a slash
        if relativePath.first == "/" {
            relativePath.removeFirst()
        }

        // Append the relative path to the sandboxed Downloads URL
        return sandboxedDownloadsURL.appendingPathComponent(relativePath)
    }
}
