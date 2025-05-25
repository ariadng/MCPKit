/**
 * Used by the client to get a prompt provided by the server.
 */
import { Request } from './Request';

export interface GetPromptRequest extends Request {
  method: "prompts/get";
  params: {
    /**
     * The name of the prompt or prompt template.
     */
    name: string;
    /**
     * Arguments to use for templating the prompt.
     */
    arguments?: { [key: string]: string };
  };
}
