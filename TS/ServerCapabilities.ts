/**
 * Capabilities that a server may support. Known capabilities are defined here, in this schema, but this is not a closed set: any server can define its own, additional capabilities.
 */
export interface ServerCapabilities {
  /**
   * Experimental capabilities. These are not standardized and may change at any time.
   */
  experimental?: { [key: string]: object };

  /**
   * Capabilities related to logging.
   */
  logging?: object;

  /**
   * Capabilities related to completions.
   */
  completions?: object;

  /**
   * Capabilities related to prompts.
   */
  prompts?: {
    /**
     * Whether this server supports notifications for changes to the prompt list.
     */
    listChanged?: boolean;
  };

  /**
   * Capabilities related to resources.
   */
  resources?: {
    /**
     * Whether this server supports subscribing to resource updates.
     */
    subscribe?: boolean;
    /**
     * Whether this server supports notifications for changes to the resource list.
     */
    listChanged?: boolean;
  };

  /**
   * Capabilities related to tools.
   */
  tools?: {
    /**
     * Whether this server supports notifications for changes to the tool list.
     */
    listChanged?: boolean;
  };
}
