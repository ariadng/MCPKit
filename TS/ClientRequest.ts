/**
 * Union type of all requests that can be sent from the client to the server.
 */
import { InitializeRequest } from './InitializeRequest';
import { PingRequest } from './PingRequest';
import { ListResourcesRequest } from './ListResourcesRequest';
import { ListResourceTemplatesRequest } from './ListResourceTemplatesRequest';
import { ReadResourceRequest } from './ReadResourceRequest';
import { SubscribeRequest } from './SubscribeRequest';
import { UnsubscribeRequest } from './UnsubscribeRequest';
import { ListPromptsRequest } from './ListPromptsRequest';
import { GetPromptRequest } from './GetPromptRequest';
import { ListToolsRequest } from './ListToolsRequest';
import { CallToolRequest } from './CallToolRequest';
import { SetLevelRequest } from './SetLevelRequest';
import { CompleteRequest } from './CompleteRequest';

export type ClientRequest =
  | InitializeRequest
  | PingRequest
  | ListResourcesRequest
  | ListResourceTemplatesRequest
  | ReadResourceRequest
  | SubscribeRequest
  | UnsubscribeRequest
  | ListPromptsRequest
  | GetPromptRequest
  | ListToolsRequest
  | CallToolRequest
  | SetLevelRequest
  | CompleteRequest;
