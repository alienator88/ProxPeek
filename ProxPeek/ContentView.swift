//
//  ContentView.swift
//  ProxPeek
//
//  Created by Alin Lupascu on 11/14/24.
//

import SwiftUI
import AlinFoundation

struct ContentView: View {
    @EnvironmentObject var api : ProxmoxAPI
    
    var body: some View {
        VStack(alignment: .leading) {

            HStack {
                Spacer()
                Image("proxmox")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 25, height: 25)
                Text(Bundle.main.name)
                    .font(.title)
                    .bold()


//                    .foregroundStyle(
//                        LinearGradient(
//                            colors: [.orange, .black.opacity(0.5), .orange],
//                            startPoint: .leading,
//                            endPoint: .trailing
//                        )
//                    )
                Spacer()
            }


            if api.appReady() {
                ScrollView(showsIndicators: false) {
                    // Filter and display LXC VMs
                    let lxcVMs = api.vms.filter { $0.type == "lxc" }.sorted(by: { $0.id < $1.id })
                    if !lxcVMs.isEmpty {
                        Text("Containers")
                            .font(.headline)
                            .padding(.horizontal)

                        ForEach(lxcVMs, id: \.vmid) { vm in
                            VMItemView(vm: vm)
                                .padding(2)
                        }

                    }

                    // Filter and display QEMU VMs
                    let qemuVMs = api.vms.filter { $0.type == "qemu" }.sorted(by: { $0.id < $1.id })
                    if !qemuVMs.isEmpty {
                        Text("Virtual Machines")
                            .font(.headline)
                            .padding(.horizontal)
                            .padding(.top, !lxcVMs.isEmpty ? 10 : 0)

                        ForEach(qemuVMs, id: \.vmid) { vm in
                            VMItemView(vm: vm)
                                .padding(2)
                        }
                    }


                }
                .frame(maxHeight: 700)
            } else {
                HStack {
                    Spacer()
                    Text("Please check your configuration 😢")
                    Spacer()
                }
                .padding()

            }

            Divider()

            HStack {

                Spacer()

                if !api.configError.isEmpty {
                    InfoButton(text: api.configError, color: .orange, warning: true, edge: .bottom)
                }

                Button("Refresh") {
                    api.fetchVMsAndLXCs()
                }
                .buttonStyle(AFButtonStyle(image: "arrow.circlepath"))
                .help("Refresh the list of VMs and LXCs")

                if #available(macOS 14.0, *) {
                    SettingsLink {}
                        .buttonStyle(AFButtonStyle(image: "gear"))
                        .help("Settings")
                } else {
                    Button("Settings") {
                        if #available(macOS 13.0, *) {
                            NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
                        } else {
                            NSApp.sendAction(Selector(("showPreferencesWindow:")), to: nil, from: nil)
                        }
                    }
                    .buttonStyle(AFButtonStyle(image: "gear"))

                }



                Button("Quit") {
                    NSApp.terminate(nil)
                }
                .buttonStyle(AFButtonStyle(image: "xmark"))
                .help("Quit")
            }


        }
        .padding()

    }
}



