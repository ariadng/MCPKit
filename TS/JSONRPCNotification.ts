/**
 * A notification which does not expect a response.
 */
import { Notification } from './Notification';
import { JSONRPC_VERSION } from './constants';

export interface JSONRPCNotification extends Notification {
  jsonrpc: typeof JSONRPC_VERSION;
}
