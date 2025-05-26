/**
 * A request from the client to the server, to enable or adjust logging.
 */
public struct SetLevelRequest: Request, Codable {
    public var method: String = "logging/setLevel"
    public var params: RequestParams?
    
    public struct Params: Codable {
        /**
         * The level of logging that the client wants to receive from the server. 
         * The server should send all logs at this level and higher (i.e., more severe) to the client as notifications/message.
         */
        public var level: LoggingLevel
        
        public init(level: LoggingLevel) {
            self.level = level
        }
    }
    
    public init(level: LoggingLevel) {
        var params = RequestParams()
        params["level"] = AnyCodable(level.rawValue)
        self.params = params
    }
}
