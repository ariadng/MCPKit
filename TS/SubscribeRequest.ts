/**
 * Sent from the client to request resources/updated notifications from the server whenever a particular resource changes.
 */
import { Request } from './Request';

export interface SubscribeRequest extends Request {
  method: "resources/subscribe";
  params: {
    /**
     * The URI of the resource to subscribe to. The URI can use any protocol; it is up to the server how to interpret it.
     *
     * @format uri
     */
    uri: string;
  };
}
