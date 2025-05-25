/**
 * Represents a root directory or file that the server can operate on.
 */
export interface Root {
  /**
   * The URI of the root. The URI can use any protocol; it is up to the server how to interpret it.
   * 
   * @format uri
   */
  uri: string;
  
  /**
   * A human-readable name for the root.
   */
  name?: string;
}
