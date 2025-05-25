/**
 * A request that expects a response.
 */
import { Request } from './Request';
import { RequestId } from './RequestId';
import { JSONRPC_VERSION } from './constants';

export interface JSONRPCRequest extends Request {
  jsonrpc: typeof JSONRPC_VERSION;
  id: RequestId;
}
