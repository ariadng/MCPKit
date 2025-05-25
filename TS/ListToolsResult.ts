/**
 * The server's response to a tools/list request from the client.
 */
import { Result } from './Result';
import { PaginatedResult } from './PaginatedResult';
import { Tool } from './Tool';

export interface ListToolsResult extends Result, PaginatedResult {
  tools: Tool[];
}
