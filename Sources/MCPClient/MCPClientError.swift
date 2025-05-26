//
//  MCPClientError.swift
//  MCPKit
//
//  Created by Cascade on 2025-05-26.
//

import Foundation
// Assumes AnyCodable and JSONRPCErrorObject from Schema are available in the same target.

/// Custom errors specific to MCPClient operations.
public enum MCPClientError: Error {
    case notConnected
    case requestEncodingFailed(Error)
    case responseDecodingFailed(Error)
    case transportError(Error)
    case unsolicitedResponse(id: String)
    case serverError(code: Int, message: String, data: AnyCodable?) // Assuming AnyCodable for flexible error data
    case unexpectedMessageFormat
    case continuationNotFound(id: String)
    case typeCastingFailed(expectedType: String, actualValue: Any)
    case jsonRpcError(JSONRPCErrorObject) // Assumes JSONRPCErrorObject is defined in schema
    case transportNotAvailable
    case alreadyConnected
    case notImplemented
}
