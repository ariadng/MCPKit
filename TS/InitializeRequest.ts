/**
 * This request is sent from the client to the server when it first connects, asking it to begin initialization.
 */
import { Request } from './Request';
import { ClientCapabilities } from './ClientCapabilities';
import { Implementation } from './Implementation';

export interface InitializeRequest extends Request {
  method: "initialize";
  params: {
    /**
     * The latest version of the Model Context Protocol that the client supports. The client MAY decide to support older versions as well.
     */
    protocolVersion: string;
    capabilities: ClientCapabilities;
    clientInfo: Implementation;
  };
}
