/**
 * Union type of all notifications that can be sent from the client to the server.
 */
import { CancelledNotification } from './CancelledNotification';
import { InitializedNotification } from './InitializedNotification';
import { RootsListChangedNotification } from './RootsListChangedNotification';

export type ClientNotification =
  | CancelledNotification
  | InitializedNotification
  | RootsListChangedNotification;
