//
//  AboutView.swift
//  Heic Pics
//
//  Created by Andrew Mead on 11/26/24.
//

import LaunchAtLogin
import SwiftUI

struct GettingStartedView: View {
    @State private var hasAccessToDownloads = false
    @State private var unableToGrantAccess = false
    @Environment(\.openURL) private var openURL
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openSettings) private var openSettings
    @FocusState private var focusedButton: ButtonFocus?

    enum ButtonFocus: Hashable {
        case done
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Getting started content
            Text("Getting Started with HEIC Pics")
                .font(.title.weight(.semibold))
            Text("HEIC Pics is an application that lives in your Mac's menu bar.")
            Text("Whenever a HEIC image is added to your downloads folder, HEIC Pics will convert it to your your preferred image format.")
            Text("That's it!")

            // Error box if downloads access was not granted
            if hasAccessToDownloads == false {
                VStack() {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Unable to access downloads folder!")
                            .font(.title3.weight(.semibold))
                        Text("HEIC Pics must be able to read and write to the downloads folder.")
                            .padding(.bottom, 6)
                        Button("Enable Access in System Preferences") {
                            openSystemPreferences()
                        }
                    }
                    .frame(
                          minWidth: 0,
                          maxWidth: .infinity,
                          alignment: .topLeading
                        )
                    .padding()
                    .background(.red.opacity(0.1))
                    .cornerRadius(7)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10) // Match the corner radius here
                            .stroke(Color.red.opacity(0.3), lineWidth: 1)
                    )
                }
                .padding(.top)
            }

            // Bottom window actions
            Divider()
                .padding(.top)
            HStack {
                Button("Done") {
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .focused($focusedButton, equals: .done)
                Spacer()
                Button("Settings") {
                    openSettings()
                    FocusWindow.focus(title: "HEIC Pics Settings")
                }
                Button("Andrew on Bluesky") {
                    if let url = URL(string: "https://bsky.app/profile/mead.io") {
                        openURL(url)
                    }
                }
            }
        }
        .padding()
        .onAppear {
            hasAccessToDownloads = checkDownloadsAccess()
            focusedButton = .done
        }
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

    func openSystemPreferences() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_FilesAndFolders") {
            NSWorkspace.shared.open(url)
        }
    }
}

#Preview {
    GettingStartedView()
}
