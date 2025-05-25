/**
 * Capabilities a client may support. Known capabilities are defined here, in this schema, but this is not a closed set: any client can define its own, additional capabilities.
 */
export interface ClientCapabilities {
  /**
   * Experimental capabilities. These are not standardized and may change at any time.
   */
  experimental?: { [key: string]: object };

  /**
   * Capabilities related to roots.
   */
  roots?: {
    /**
     * Whether the client supports notifications for changes to the roots list.
     */
    listChanged?: boolean;
  };

  /**
   * Capabilities related to sampling.
   */
  sampling?: object;
}
