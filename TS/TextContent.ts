/**
 * Text provided to or from an LLM.
 */
import { Annotations } from './Annotations';

export interface TextContent {
  type: "text";

  /**
   * The text content of the message.
   */
  text: string;

  /**
   * Optional annotations for the client.
   */
  annotations?: Annotations;
}
