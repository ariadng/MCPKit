/**
 * The server's response to a resources/templates/list request from the client.
 */
import { Result } from './Result';
import { PaginatedResult } from './PaginatedResult';
import { ResourceTemplate } from './ResourceTemplate';

export interface ListResourceTemplatesResult extends Result, PaginatedResult {
  resourceTemplates: ResourceTemplate[];
}
