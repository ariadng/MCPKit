/**
 * Base interface for paginated requests.
 */
public protocol PaginatedRequest {
    var params: RequestParams? { get set }
}

public extension PaginatedRequest {
    /**
     * An opaque token representing the current pagination position.
     * If provided, the server should return results starting after this cursor.
     */
    var cursor: Cursor? {
        guard let paramsDict = self.params, // Unwraps self.params to [String: AnyCodable]
              let anyCodableCursor = paramsDict["cursor"] // Unwraps the value from dict to AnyCodable
        else {
            return nil // If params is nil or "cursor" key doesn't exist
        }
        // anyCodableCursor is of type AnyCodable
        // Attempt to decode it to String. If it's not a string or represents JSON null,
        // try? will result in nil.
        return try? anyCodableCursor.decode(to: String.self)
    }
    
    mutating func setCursor(_ cursor: Cursor?) {
        if var params = self.params {
            if let cursor = cursor {
                params["cursor"] = AnyCodable(cursor)
            } else {
                // Remove cursor if nil
                params["cursor"] = nil
            }
            self.params = params
        } else if let cursor = cursor {
            // Create params if they don't exist
            var newParams = RequestParams()
            newParams["cursor"] = AnyCodable(cursor)
            self.params = newParams
        }
    }
}
