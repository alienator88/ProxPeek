//
//  SettingsView.swift
//  ProxPeek
//
//  Created by Alin Lupascu on 11/14/24.
//

import SwiftUI
import AlinFoundation

struct SettingsView: View {
    @EnvironmentObject var updater: Updater
    @AppStorage("proxmoxIP") var proxmoxIP: String = ""
    @AppStorage("proxmoxPort") var proxmoxPort: String = ""
    @AppStorage("apiToken") var apiToken: String = ""
    @AppStorage("tokenID") var tokenID: String = ""

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Proxmox URL")
                Spacer()
                TextField("https://10.0.0.2", text: $proxmoxIP)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 350)
                if proxmoxIP.isEmpty {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                }
            }

            HStack {
                Text("Proxmox Port")
                Spacer()
                TextField("8006", text: $proxmoxPort)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 350)
                if proxmoxPort.isEmpty {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                }
            }

            HStack {
                Text("API User")
                Spacer()
                TextField("user@realm", text: $tokenID)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 350)
                if tokenID.isEmpty {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                }

            }

            HStack {
                Text("API Token")
                Spacer()
                SecureField("xxxxxxxxxxxxxxxx", text: $apiToken)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 350)
                if apiToken.isEmpty {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                }
            }

            Divider().padding(.vertical)
            // Updater =========================================================================================

            VStack {
                HStack {
                    Spacer()
                    if updater.updateAvailable {
                        UpdateBadge(updater: updater)
                            .frame(width: 200)
                            .padding()
                    } else {
                        HStack {
                            Text("No updates available")
                                .foregroundStyle(.secondary)
                            Button("Refresh") {
                                updater.checkForUpdatesForce(showSheet: false)
                            }
                        }
                        .padding()

                    }
                    Spacer()
                }

                FrequencyView(updater: updater)
                    .padding()
                    .frame(width: 350)
                    .background {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.secondary.opacity(0.1))
                    }


                Divider().padding(.vertical)

                Image(nsImage: NSApp.applicationIconImage ?? NSImage())
                    .padding()

                Text(Bundle.main.name)
                    .font(.title)
                    .bold()
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.orange, .black, .orange],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )

                Text("Version \(Bundle.main.version) (Build \(Bundle.main.buildVersion))")
                    .padding(.top, 4)

                Spacer()

                HStack(spacing: 0){
                    Spacer()
                    Text("Made with ❤️ by ")
                    Text("Alin Lupascu")
                        .bold()
                    Spacer()
                }
                .padding()

                Button("Reset Settings") {
                    DispatchQueue.global(qos: .userInitiated).async {
                        UserDefaults.standard.dictionaryRepresentation().keys.forEach(UserDefaults.standard.removeObject(forKey:))
                    }
                }
            }



        }
        .padding()
        .frame(maxWidth: 500)
    }
}
