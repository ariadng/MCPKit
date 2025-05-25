/**
 * An out-of-band notification used to inform the receiver of a progress update for a long-running request.
 */
import { Notification } from './Notification';
import { ProgressToken } from './ProgressToken';

export interface ProgressNotification extends Notification {
  method: "notifications/progress";
  params: {
    /**
     * The progress token which was given in the initial request, used to associate this notification with the request that is proceeding.
     */
    progressToken: ProgressToken;
    /**
     * The progress thus far. This should increase every time progress is made, even if the total is unknown.
     *
     * @TJS-type number
     */
    progress: number;
    /**
     * Total number of items to process (or total progress required), if known.
     *
     * @TJS-type number
     */
    total?: number;
    /**
     * An optional message describing the current progress.
     */
    message?: string;
  };
}
