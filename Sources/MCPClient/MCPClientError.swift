//
//  MCPClientError.swift
//  MCPKit
//
//  Created by Cascade on 2025-05-26.
//

import Foundation
import MCPSchema
// Assumes AnyCodable and JSONRPCErrorObject from MCPSchema are available in the same target.

/// Custom errors specific to MCPClient operations.
public enum MCPClientError: Error, Equatable {
    case notConnected
    case requestEncodingFailed(Error)
    case responseDecodingFailed(Error)
    case transportError(Error)
    case unsolicitedResponse(id: String)
    case serverError(code: Int, message: String, data: AnyCodable?) // Assuming AnyCodable for flexible error data
    case unexpectedMessageFormat
    case continuationNotFound(id: String)
    case typeCastingFailed(expectedType: String, actualValueDescription: String)
    case jsonRpcError(MCPSchema.JSONRPCError.ErrorObject) // Corrected to use type from MCPSchema
    case transportNotAvailable
    case alreadyConnected
    case notImplemented
    case handshakeFailed(underlyingError: Error)
    case pingFailed(underlyingError: Error)
    case maxReconnectAttemptsReached
    case operationCancelled // New case for cancelled operations

    public static func == (lhs: MCPClientError, rhs: MCPClientError) -> Bool {
        switch (lhs, rhs) {
        case (.alreadyConnected, .alreadyConnected):
            return true
        case (.notConnected, .notConnected):
            return true
        case (.requestEncodingFailed(let lError), .requestEncodingFailed(let rError)):
            // Basic Error comparison by description for simplicity
            return String(describing: lError) == String(describing: rError)
        case (.responseDecodingFailed(let lError), .responseDecodingFailed(let rError)):
            // Basic Error comparison by description for simplicity
            return String(describing: lError) == String(describing: rError)
        case (.transportError(let lError), .transportError(let rError)):
            // Basic Error comparison by description for simplicity
            return String(describing: lError) == String(describing: rError)
        case (.unsolicitedResponse(let lId), .unsolicitedResponse(let rId)):
            return lId == rId
        case (.serverError(let lCode, let lMessage, let lData), .serverError(let rCode, let rMessage, let rData)):
            return lCode == rCode && lMessage == rMessage && lData == rData
        case (.unexpectedMessageFormat, .unexpectedMessageFormat):
            return true
        case (.continuationNotFound(let lId), .continuationNotFound(let rId)):
            return lId == rId
        case (.typeCastingFailed(let lExpectedType, let lActualValueDesc), .typeCastingFailed(let rExpectedType, let rActualValueDesc)):
            // Basic comparison for simplicity
            return lExpectedType == rExpectedType && lActualValueDesc == rActualValueDesc
        case (.jsonRpcError(let lObj), .jsonRpcError(let rObj)):
            // Compare based on MCPSchema.JSONRPCError.ErrorObject fields
            return lObj.code == rObj.code && lObj.message == rObj.message && String(describing: lObj.data) == String(describing: rObj.data)
        case (.transportNotAvailable, .transportNotAvailable):
            return true
        case (.notImplemented, .notImplemented):
            return true
        case (.handshakeFailed(let lError), .handshakeFailed(let rError)):
            // Basic Error comparison by description for simplicity
            return String(describing: lError) == String(describing: rError)
        case (.pingFailed(let lError), .pingFailed(let rError)):
            // Basic Error comparison by description for simplicity
            return String(describing: lError) == String(describing: rError)
        case (.maxReconnectAttemptsReached, .maxReconnectAttemptsReached):
            return true
        case (.operationCancelled, .operationCancelled):
            return true
        default:
            return false
        }
    }
}
