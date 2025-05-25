/**
 * Used by the client to invoke a tool provided by the server.
 */
import { Request } from './Request';

export interface CallToolRequest extends Request {
  method: "tools/call";
  params: {
    name: string;
    arguments?: { [key: string]: unknown };
  };
}
