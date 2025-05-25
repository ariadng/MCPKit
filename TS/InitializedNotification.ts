/**
 * This notification is sent from the client to the server after initialization has finished.
 */
import { Notification } from './Notification';

export interface InitializedNotification extends Notification {
  method: "notifications/initialized";
}
