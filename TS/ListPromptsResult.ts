/**
 * The server's response to a prompts/list request from the client.
 */
import { Result } from './Result';
import { PaginatedResult } from './PaginatedResult';
import { Prompt } from './Prompt';

export interface ListPromptsResult extends Result, PaginatedResult {
  prompts: Prompt[];
}
