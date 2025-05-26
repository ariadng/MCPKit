//
//  MCPClientError.swift
//  MCPKit
//
//  Created by Cascade on 2025-05-26.
//

import Foundation
import Schema
// Assumes AnyCodable and JSONRPCErrorObject from Schema are available in the same target.

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
    case typeCastingFailed(expectedType: String, actualValue: Any)
    case jsonRpcError(Schema.JSONRPCError.ErrorObject) // Corrected to use type from Schema
    case transportNotAvailable
    case alreadyConnected
    case notImplemented
    case handshakeFailed(underlyingError: Error)
    case pingFailed(underlyingError: Error)
    case maxReconnectAttemptsReached

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
        case (.serverError(let lErrorObj), .serverError(let rErrorObj)):
            return lErrorObj.code == rErrorObj.code && lErrorObj.message == rErrorObj.message && lErrorObj.data == rErrorObj.data
        case (.unexpectedMessageFormat, .unexpectedMessageFormat):
            return true
        case (.continuationNotFound(let lId), .continuationNotFound(let rId)):
            return lId == rId
        case (.typeCastingFailed(let lExpectedType, let lActualValue), .typeCastingFailed(let rExpectedType, let rActualValue)):
            // Basic comparison for simplicity
            return lExpectedType == rExpectedType && String(describing: lActualValue) == String(describing: rActualValue)
        case (.jsonRpcError(let lObj), .jsonRpcError(let rObj)):
            // Compare based on Schema.JSONRPCError.ErrorObject fields
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
        default:
            return false
        }
    }
}
