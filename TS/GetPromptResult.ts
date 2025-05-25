/**
 * The server's response to a prompts/get request from the client.
 */
import { Result } from './Result';
import { PromptMessage } from './PromptMessage';

export interface GetPromptResult extends Result {
  /**
   * An optional human-readable description of the prompt.
   */
  description?: string;
  
  /**
   * The messages that make up the prompt.
   */
  messages: PromptMessage[];
}
