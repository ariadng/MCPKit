/**
 * An optional notification from the server to the client, informing it that the list of tools it offers has changed. This may be issued by servers without any previous subscription from the client.
 */
import { Notification } from './Notification';

export interface ToolListChangedNotification extends Notification {
  method: "notifications/tools/list_changed";
}
