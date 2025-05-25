/**
 * A JSON-RPC batch request, as described in https://www.jsonrpc.org/specification#batch.
 */
import { JSONRPCRequest } from './JSONRPCRequest';
import { JSONRPCNotification } from './JSONRPCNotification';

export type JSONRPCBatchRequest = (JSONRPCRequest | JSONRPCNotification)[];
