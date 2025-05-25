/**
 * Text contents of a resource.
 */
import { ResourceContents } from './ResourceContents';

export interface TextResourceContents extends ResourceContents {
  /**
   * The text content of the resource.
   */
  text: string;
}
