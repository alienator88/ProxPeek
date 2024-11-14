//
//  VMItemView.swift
//  ProxPeek
//
//  Created by Alin Lupascu on 11/14/24.
//
import SwiftUI

struct VMItemView: View {
    let vm: VM
    @EnvironmentObject var api: ProxmoxAPI
    @State private var isHovered = false // Track hover state

    var body: some View {
        HStack {
            Image(systemName: vm.type == "qemu" ? "desktopcomputer" : "cube.box.fill")
            Text("\(vm.vmid)").font(.footnote)
            Text("-")
            Text(vm.name)
            Spacer()
            Text(vm.status.capitalized).font(.caption)
                .foregroundColor(vm.status == "running" ? .green : .secondary)
//            Button(action: {
//                api.toggleVMState(id: vm.id, currentState: vm.status, vmType: vm.type)
//            }) {
//                Image(systemName: vm.status == "running" ? "stop.fill" : "play.square.fill")
//                    .foregroundColor(vm.status != "running" ? .green : .red)
//            }
//            .buttonStyle(.plain)
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isHovered ? .thickMaterial : .ultraThinMaterial)
//                .opacity(isHovered ? 0.2 : 1)

        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(.primary.opacity(0.2), lineWidth: 0.8)
        )
        .onHover { hovering in
            isHovered = hovering
        }
        .help(vm.status.capitalized)
        .onTapGesture {
            api.toggleVMState(id: vm.id, currentState: vm.status, vmType: vm.type)
        }
    }
}
