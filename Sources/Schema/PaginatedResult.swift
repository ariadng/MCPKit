/**
 * Base interface for paginated results.
 */
public protocol PaginatedResult {
    /**
     * An opaque token representing the next pagination position.
     * If provided, there are more results available after this cursor.
     */
    var nextCursor: Cursor? { get set }
}
