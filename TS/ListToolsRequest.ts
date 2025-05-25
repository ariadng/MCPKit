/**
 * Sent from the client to request a list of tools the server has.
 */
import { Request } from './Request';
import { PaginatedRequest } from './PaginatedRequest';

export interface ListToolsRequest extends Request, PaginatedRequest {
  method: "tools/list";
}
