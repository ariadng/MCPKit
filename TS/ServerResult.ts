/**
 * Union type of all result types that can be returned from the server to the client.
 */
import { EmptyResult } from './EmptyResult';
import { InitializeResult } from './InitializeResult';
import { ListResourcesResult } from './ListResourcesResult';
import { ListResourceTemplatesResult } from './ListResourceTemplatesResult';
import { ReadResourceResult } from './ReadResourceResult';
import { ListPromptsResult } from './ListPromptsResult';
import { GetPromptResult } from './GetPromptResult';
import { ListToolsResult } from './ListToolsResult';
import { CallToolResult } from './CallToolResult';
import { CompleteResult } from './CompleteResult';

export type ServerResult =
  | EmptyResult
  | InitializeResult
  | ListResourcesResult
  | ListResourceTemplatesResult
  | ReadResourceResult
  | ListPromptsResult
  | GetPromptResult
  | ListToolsResult
  | CallToolResult
  | CompleteResult;
