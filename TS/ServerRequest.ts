/**
 * Union type of all requests that can be sent from the server to the client.
 */
import { PingRequest } from './PingRequest';
import { ListRootsRequest } from './ListRootsRequest';
import { CreateMessageRequest } from './CreateMessageRequest';

export type ServerRequest =
  | PingRequest
  | ListRootsRequest
  | CreateMessageRequest;
