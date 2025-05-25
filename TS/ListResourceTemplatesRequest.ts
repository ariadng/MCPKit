/**
 * Sent from the client to request a list of resource templates the server has.
 */
import { Request } from './Request';
import { PaginatedRequest } from './PaginatedRequest';

export interface ListResourceTemplatesRequest extends Request, PaginatedRequest {
  method: "resources/templates/list";
}
