/**
 * The server's response to a resources/read request from the client.
 */
import { Result } from './Result';
import { TextResourceContents } from './TextResourceContents';
import { BlobResourceContents } from './BlobResourceContents';

export interface ReadResourceResult extends Result {
  contents: (TextResourceContents | BlobResourceContents)[];
}
