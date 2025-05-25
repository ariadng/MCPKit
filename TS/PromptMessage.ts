/**
 * Describes a message returned as part of a prompt.
 *
 * This is similar to `SamplingMessage`, but also supports the embedding of
 * resources from the MCP server.
 */
import { Role } from './Role';
import { TextContent } from './TextContent';
import { ImageContent } from './ImageContent';
import { AudioContent } from './AudioContent';
import { EmbeddedResource } from './EmbeddedResource';

export interface PromptMessage {
  role: Role;
  content: TextContent | ImageContent | AudioContent | EmbeddedResource;
}
