/**
 * A notification from the client to the server, informing it that the list of roots has changed.
 * This notification should be sent whenever the client adds, removes, or modifies any root.
 * The server should then request an updated list of roots using the ListRootsRequest.
 */
import { Notification } from './Notification';

export interface RootsListChangedNotification extends Notification {
  method: "notifications/roots/list_changed";
}
