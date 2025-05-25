/**
 * Sent from the client to the server, to read a specific resource URI.
 */
import { Request } from './Request';

export interface ReadResourceRequest extends Request {
  method: "resources/read";
  params: {
    /**
     * The URI of the resource to read. The URI can use any protocol; it is up to the server how to interpret it.
     *
     * @format uri
     */
    uri: string;
  };
}
