//
//  JoinSessionViewModel.swift
//  queued
//
//  Created by Ted Bennett on 15/03/2021.
//

import SwiftUI
import MultipeerConnectivity

class JoinSessionViewModel: NSObject, ObservableObject {
    @Published var sessions: [MCPeerID] = []
    private var nearbySessionBrowser: MCNearbyServiceBrowser
    private let myPeerId = MCPeerID(displayName: UIDevice.current.name)
    private static let service = "queued"
    
    override init() {
        
        nearbySessionBrowser = MCNearbyServiceBrowser(
            peer: myPeerId,
            serviceType: JoinSessionViewModel.service)
        super.init()
    }
}

extension JoinSessionViewModel: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String: String]?) {
        if !sessions.contains(peerID) {
            sessions.append(peerID)
        }
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        guard let index = sessions.firstIndex(of: peerID) else { return }
        sessions.remove(at: index)
    }
}
