/**
 * Base interface for paginated requests.
 */
public protocol PaginatedRequest {
    var params: RequestParams? { get }
}

public extension PaginatedRequest {
    /**
     * An opaque token representing the current pagination position.
     * If provided, the server should return results starting after this cursor.
     */
    var cursor: Cursor? {
        if let params = self.params,
           let cursorValue = params["cursor"],
           case let .string(cursor) = cursorValue {
            return cursor
        }
        return nil
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
