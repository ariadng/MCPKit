/**
 * Binary contents of a resource.
 */
import { ResourceContents } from './ResourceContents';

export interface BlobResourceContents extends ResourceContents {
  /**
   * The base64-encoded binary content of the resource.
   * 
   * @format byte
   */
  blob: string;
}
