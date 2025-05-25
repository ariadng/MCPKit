/**
 * Identifies a prompt.
 */
export interface PromptReference {
  type: "ref/prompt";
  
  /**
   * The name of the prompt.
   */
  name: string;
}
