/**
 * The client's response to a roots/list request from the server.
 * This result contains an array of Root objects, each representing a root directory
 * or file that the server can operate on.
 */
import { Result } from './Result';
import { Root } from './Root';

export interface ListRootsResult extends Result {
  roots: Root[];
}
