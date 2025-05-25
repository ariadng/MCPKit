/**
 * Union type of all result types that can be returned from the client to the server.
 */
import { EmptyResult } from './EmptyResult';
import { ListRootsResult } from './ListRootsResult';
import { CreateMessageResult } from './CreateMessageResult';

export type ClientResult =
  | EmptyResult
  | ListRootsResult
  | CreateMessageResult;
