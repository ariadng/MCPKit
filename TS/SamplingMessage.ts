/**
 * Describes a message issued to or received from an LLM API.
 */
import { Role } from './Role';
import { TextContent } from './TextContent';
import { ImageContent } from './ImageContent';
import { AudioContent } from './AudioContent';

export interface SamplingMessage {
  role: Role;
  content: TextContent | ImageContent | AudioContent;
}
