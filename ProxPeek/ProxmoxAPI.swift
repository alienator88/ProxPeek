//
//  ProxmoxAPI.swift
//  ProxPeek
//
//  Created by Alin Lupascu on 11/14/24.
//

import Foundation
import SwiftUI
import AlinFoundation

struct APIResponse: Decodable {
    let data: [VM]
}

struct VM: Identifiable, Decodable {
    let id: String
    let name: String
    var status: String // Make status mutable
    let type: String
    let vmid: Int

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case status
        case type
        case vmid
    }

    // Helper initializer to create an updated VM with a new status
    init(copyOf vm: VM, newStatus: String) {
        self.id = vm.id
        self.name = vm.name
        self.status = newStatus
        self.type = vm.type
        self.vmid = vm.vmid
    }
}

class ProxmoxAPI: ObservableObject {
    static let shared = ProxmoxAPI()

    @Published var vms: [VM] = []
    @Published var configError: String = ""

    // Fetching from AppStorage for dynamic configuration
    @AppStorage("proxmoxIP") private var proxmoxIP: String = ""
    @AppStorage("proxmoxPort") private var proxmoxPort: String = ""
    @AppStorage("apiToken") private var apiToken: String = ""
    @AppStorage("tokenID") private var tokenID: String = ""

    private func authorizationHeader() -> [String: String] {
        return [
            "Authorization": "PVEAPIToken=\(tokenID)!api=\(apiToken)"
        ]
    }


    func fetchVMsAndLXCs() {
        self.configError = ""
        let proxmoxURL = proxmoxIP + ":" + proxmoxPort + "/api2/json"

        guard let url = URL(string: "\(proxmoxURL)/cluster/resources?type=vm") else {
            print("Invalid Proxmox URL.")
            updateOnMain {
                self.configError = "Invalid Proxmox URL."
            }
            return
        }

        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = authorizationHeader()

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Network error: \(error.localizedDescription)")
                updateOnMain {
                    self.configError = "Network error: \(error.localizedDescription)"
                }
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                guard httpResponse.statusCode == 200 else {
                    print("HTTP error: \(httpResponse.statusCode) - \(HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode))")
                    updateOnMain {
                        self.configError = "HTTP error: \(httpResponse.statusCode) - \(HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode))"
                    }
                    return
                }
            }

            guard let data = data else {
                print("No data received from Proxmox API.")
                updateOnMain {
                    self.configError = "No data received from Proxmox API."
                }
                return
            }

            // Print JSON response as a string for inspection
//            if let jsonString = String(data: data, encoding: .utf8) {
//                print("JSON Response: \(jsonString)")
//            }

            do {
                let apiResponse = try JSONDecoder().decode(APIResponse.self, from: data)
                DispatchQueue.main.async {
                    self.vms = apiResponse.data.filter { $0.type == "qemu" || $0.type == "lxc" }
                }
            } catch {
                print("Decoding error: \(error.localizedDescription)")
                updateOnMain {
                    self.configError = "Decoding error: \(error.localizedDescription)"
                }
            }
        }.resume()
    }

    func toggleVMState(id: String, currentState: String, vmType: String) {
        let statePath = (currentState == "running") ? "/stop" : "/start"
        let newStatus = (currentState == "running") ? "stopped" : "running" // Determine new status
        let actionTaken = (currentState == "running") ? "stopped" : "started"
        let proxmoxURL = proxmoxIP + ":" + proxmoxPort + "/api2/json"

        guard let url = URL(string: "\(proxmoxURL)/nodes/homelab/\(id)/status\(statePath)") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = authorizationHeader()

        URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                print("Failed to toggle state: \(error.localizedDescription)")
                updateOnMain {
                    self.configError = "Failed to toggle state: \(error.localizedDescription)"
                }
                return
            }

            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                print("Failed to toggle state, Status Code: \(httpResponse.statusCode)")
                updateOnMain {
                    self.configError = "Failed to toggle state, Status Code: \(httpResponse.statusCode)"
                }
                return
            }

            DispatchQueue.main.async {
                // Find the VM by `id` and replace it with a new instance with the updated status
                if let index = self.vms.firstIndex(where: { $0.id == id }) {
                    let updatedVM = VM(copyOf: self.vms[index], newStatus: newStatus) // Create a new VM with updated status
                    self.vms[index] = updatedVM // Replace the old VM in the array
                }
                print("\(actionTaken) \(vmType) successfully")
            }
        }.resume()
    }

    
    func appReady() -> Bool {
        return !proxmoxIP.isEmpty &&
        !proxmoxPort.isEmpty &&
        !apiToken.isEmpty &&
        !tokenID.isEmpty
    }


}
