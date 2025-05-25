/**
 * Base interface for paginated results.
 */
import { Cursor } from './Cursor';

export interface PaginatedResult {
  /**
   * An opaque token representing the next pagination position.
   * If provided, there are more results available after this cursor.
   */
  nextCursor?: Cursor;
}
