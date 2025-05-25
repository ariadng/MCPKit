/**
 * Base interface for paginated requests.
 */
import { Cursor } from './Cursor';

export interface PaginatedRequest {
  params?: {
    /**
     * An opaque token representing the current pagination position.
     * If provided, the server should return results starting after this cursor.
     */
    cursor?: Cursor;
  };
}
