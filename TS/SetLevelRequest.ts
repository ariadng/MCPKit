/**
 * A request from the client to the server, to enable or adjust logging.
 */
import { Request } from './Request';
import { LoggingLevel } from './LoggingLevel';

export interface SetLevelRequest extends Request {
  method: "logging/setLevel";
  params: {
    /**
     * The level of logging that the client wants to receive from the server. The server should send all logs at this level and higher (i.e., more severe) to the client as notifications/message.
     */
    level: LoggingLevel;
  };
}
