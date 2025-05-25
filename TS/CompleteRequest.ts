/**
 * A request from the client to the server, to ask for completion options.
 */
import { Request } from './Request';
import { PromptReference } from './PromptReference';
import { ResourceReference } from './ResourceReference';

export interface CompleteRequest extends Request {
  method: "completion/complete";
  params: {
    ref: PromptReference | ResourceReference;
    /**
     * The argument's information
     */
    argument: {
      /**
       * The name of the argument
       */
      name: string;
      /**
       * The value of the argument to use for completion matching.
       */
      value: string;
    };
  };
}
