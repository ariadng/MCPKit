/**
 * Union type of all notifications that can be sent from the server to the client.
 */
import { CancelledNotification } from './CancelledNotification';
import { ProgressNotification } from './ProgressNotification';
import { ResourceListChangedNotification } from './ResourceListChangedNotification';
import { ResourceUpdatedNotification } from './ResourceUpdatedNotification';
import { PromptListChangedNotification } from './PromptListChangedNotification';
import { ToolListChangedNotification } from './ToolListChangedNotification';
import { LoggingMessageNotification } from './LoggingMessageNotification';

export type ServerNotification =
  | CancelledNotification
  | ProgressNotification
  | ResourceListChangedNotification
  | ResourceUpdatedNotification
  | PromptListChangedNotification
  | ToolListChangedNotification
  | LoggingMessageNotification;
