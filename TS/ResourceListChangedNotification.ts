/**
 * An optional notification from the server to the client, informing it that the list of resources it can read from has changed. This may be issued by servers without any previous subscription from the client.
 */
import { Notification } from './Notification';

export interface ResourceListChangedNotification extends Notification {
  method: "notifications/resources/list_changed";
}
