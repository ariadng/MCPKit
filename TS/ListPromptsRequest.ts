/**
 * Sent from the client to request a list of prompts and prompt templates the server has.
 */
import { Request } from './Request';
import { PaginatedRequest } from './PaginatedRequest';

export interface ListPromptsRequest extends Request, PaginatedRequest {
  method: "prompts/list";
}
