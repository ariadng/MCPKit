/**
 * Additional properties describing a Tool to clients.
 *
 * NOTE: all properties in ToolAnnotations are **hints**.
 * They are not guaranteed to provide a faithful description of
 * tool behavior (including descriptive properties like `title`).
 *
 * Clients should never make tool use decisions based on ToolAnnotations
 * received from untrusted servers.
 */
export interface ToolAnnotations {
  /**
   * A human-readable title for the tool.
   */
  title?: string;
  
  /**
   * Indicates that the tool does not modify any state.
   */
  readOnlyHint?: boolean;
  
  /**
   * Indicates that the tool may modify state in a way that cannot be undone.
   */
  destructiveHint?: boolean;
  
  /**
   * Indicates that the tool is idempotent (calling it multiple times with the same arguments has the same effect as calling it once).
   */
  idempotentHint?: boolean;
  
  /**
   * Indicates that the tool may accept arguments not explicitly listed in its schema.
   */
  openWorldHint?: boolean;
}
