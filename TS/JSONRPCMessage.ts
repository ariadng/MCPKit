/**
 * Refers to any valid JSON-RPC object that can be decoded off the wire, or encoded to be sent.
 */
import { JSONRPCRequest } from './JSONRPCRequest';
import { JSONRPCNotification } from './JSONRPCNotification';
import { JSONRPCBatchRequest } from './JSONRPCBatchRequest';
import { JSONRPCResponse } from './JSONRPCResponse';
import { JSONRPCError } from './JSONRPCError';
import { JSONRPCBatchResponse } from './JSONRPCBatchResponse';

export type JSONRPCMessage =
  | JSONRPCRequest
  | JSONRPCNotification
  | JSONRPCBatchRequest
  | JSONRPCResponse
  | JSONRPCError
  | JSONRPCBatchResponse;
