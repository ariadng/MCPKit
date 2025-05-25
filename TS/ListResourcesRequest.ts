/**
 * Sent from the client to request a list of resources the server has.
 */
import { Request } from './Request';
import { PaginatedRequest } from './PaginatedRequest';

export interface ListResourcesRequest extends Request, PaginatedRequest {
  method: "resources/list";
}
