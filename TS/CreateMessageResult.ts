/**
 * The client's response to a sampling/create_message request from the server. The client should inform the user before returning the sampled message, to allow them to inspect the response (human in the loop) and decide whether to allow the server to see it.
 */
import { Result } from './Result';
import { SamplingMessage } from './SamplingMessage';

export interface CreateMessageResult extends Result, SamplingMessage {
  /**
   * The name of the model that generated the message.
   */
  model: string;
  /**
   * The reason why sampling stopped, if known.
   */
  stopReason?: "endTurn" | "stopSequence" | "maxTokens" | string;
}
