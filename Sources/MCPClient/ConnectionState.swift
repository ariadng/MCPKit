//
//  ConnectionState.swift
//  MCPKit
//
//  Created by Cascade on 2025-05-26.
//

import Foundation

/// Represents the connection state of the MCPClient.
public enum ConnectionState: Equatable {
    case disconnected(reason: DisconnectReason?)
    case connecting
    case connected
    case disconnecting

    public static func == (lhs: ConnectionState, rhs: ConnectionState) -> Bool {
        switch (lhs, rhs) {
        case (.disconnected(let reasonLHS), .disconnected(let reasonRHS)):
            return reasonLHS == reasonRHS
        case (.connecting, .connecting):
            return true
        case (.connected, .connected):
            return true
        case (.disconnecting, .disconnecting):
            return true
        default:
            return false
        }
    }
}
