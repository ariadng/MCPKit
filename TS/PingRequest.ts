/**
 * A ping, issued by either the server or the client, to check that the other party is still alive. The receiver must promptly respond, or else may be disconnected.
 */
import { Request } from './Request';

export interface PingRequest extends Request {
  method: "ping";
}
