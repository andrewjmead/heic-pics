//
//  SettingsView.swift
//  Heic Pics
//
//  Created by Andrew Mead on 11/20/24.
//

import LaunchAtLogin
import SwiftUI

struct SettingsView: View {
    @State private var hiddenControlClicks: Int = 0 // 5 clicks to show hidden controls
    @State private var showResetStatisticsSuccessMessage: Bool = false
    @AppStorage("imageFormat") private var imageFormat: String = "jpeg"
    @AppStorage("deleteOriginal") private var deleteOriginal: Bool = false
    @AppStorage("convertedImagesCount") private var convertedImagesCount: Int = 0

    var body: some View {
        VStack(alignment: .leading) {
            Form {
                // Format
                Picker("Preferred format", selection: $imageFormat) {
                    Text("JPEG").tag("jpeg")
                    Text("PNG").tag("png")
                }
                .padding(.bottom)

                // Delete original
                LabeledContent {
                    Toggle(isOn: $deleteOriginal) {
                        Text("Delete original after conversion")
                    }
                    .toggleStyle(.checkbox)
                } label: {
                    Text("Originals")
                }
                .padding(.bottom)

                // Launch at login
                LabeledContent {
                    LaunchAtLogin.Toggle()
                } label: {
                    Text("Startup")
                        .onTapGesture {
                            hiddenControlClicks += 1
                        }
                }

                // Secret area
                if hiddenControlClicks >= 5 {
                    Divider()
                        .padding(.vertical)
                    LabeledContent {
                        Button("Reset all app data") {
                            if let bundleID = Bundle.main.bundleIdentifier {
                                UserDefaults.standard.removePersistentDomain(forName: bundleID)
                            }
                        }
                    } label: {
                        Text("🤫")
                    }
                }
            }
        }
        .padding()
    }

    private func resetSuccessMessageAfterDelay() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            showResetStatisticsSuccessMessage = false
        }
    }
}

#Preview {
    SettingsView()
}
