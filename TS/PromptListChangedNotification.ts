/**
 * An optional notification from the server to the client, informing it that the list of prompts it offers has changed. This may be issued by servers without any previous subscription from the client.
 */
import { Notification } from './Notification';

export interface PromptListChangedNotification extends Notification {
  method: "notifications/prompts/list_changed";
}
