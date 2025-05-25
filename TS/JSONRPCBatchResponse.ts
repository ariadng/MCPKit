/**
 * A JSON-RPC batch response, as described in https://www.jsonrpc.org/specification#batch.
 */
import { JSONRPCResponse } from './JSONRPCResponse';
import { JSONRPCError } from './JSONRPCError';

export type JSONRPCBatchResponse = (JSONRPCResponse | JSONRPCError)[];
