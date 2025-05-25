/**
 * A prompt or prompt template that the server offers.
 */
import { PromptArgument } from './PromptArgument';

export interface Prompt {
  /**
   * The name of the prompt or prompt template.
   */
  name: string;
  
  /**
   * An optional human-readable description of the prompt.
   */
  description?: string;
  
  /**
   * The arguments that this prompt template accepts, if any.
   */
  arguments?: PromptArgument[];
}
