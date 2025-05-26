//
//  DisconnectReason.swift
//  MCPKit
//
//  Created by Cascade on 2025-05-26.
//

import Foundation

/// Represents the reason for disconnection.
public enum DisconnectReason: Equatable {
    case normal
    case transportError(Error)
    case connectionFailed(Error)
    case disconnecting

    public static func == (lhs: DisconnectReason, rhs: DisconnectReason) -> Bool {
        switch (lhs, rhs) {
        case (.normal, .normal):
            return true
        case (.transportError(let lhsError), .transportError(let rhsError)):
            // Simplified comparison for demonstration. Consider more robust error comparison.
            return (lhsError as NSError).domain == (rhsError as NSError).domain &&
                   (lhsError as NSError).code == (rhsError as NSError).code
        case (.connectionFailed(let lhsError), .connectionFailed(let rhsError)):
            return (lhsError as NSError).domain == (rhsError as NSError).domain &&
                   (lhsError as NSError).code == (rhsError as NSError).code
        default:
            return false
        }
    }
}
