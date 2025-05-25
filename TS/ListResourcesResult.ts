/**
 * The server's response to a resources/list request from the client.
 */
import { Result } from './Result';
import { PaginatedResult } from './PaginatedResult';
import { Resource } from './Resource';

export interface ListResourcesResult extends Result, PaginatedResult {
  resources: Resource[];
}
