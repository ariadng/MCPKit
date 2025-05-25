/**
 * A successful (non-error) response to a request.
 */
import { RequestId } from './RequestId';
import { Result } from './Result';
import { JSONRPC_VERSION } from './constants';

export interface JSONRPCResponse {
  jsonrpc: typeof JSONRPC_VERSION;
  id: RequestId;
  result: Result;
}
