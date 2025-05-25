/**
 * Describes an argument that a prompt can accept.
 */
export interface PromptArgument {
  /**
   * The name of the argument.
   */
  name: string;
  
  /**
   * An optional human-readable description of the argument.
   */
  description?: string;
  
  /**
   * Whether this argument is required.
   */
  required?: boolean;
}
