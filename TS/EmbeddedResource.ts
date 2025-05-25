/**
 * The contents of a resource, embedded into a prompt or tool call result.
 *
 * It is up to the client how best to render embedded resources for the benefit
 * of the LLM and/or the user.
 */
import { TextResourceContents } from './TextResourceContents';
import { BlobResourceContents } from './BlobResourceContents';
import { Annotations } from './Annotations';

export interface EmbeddedResource {
  type: "resource";
  resource: TextResourceContents | BlobResourceContents;
  annotations?: Annotations;
}
