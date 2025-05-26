import Foundation

/**
 * A request from the client to the server, to ask for completion options.
 */
public struct CompleteRequest: Request, Codable {
    public var method: String = "completion/complete"
    public var params: RequestParams?
    
    public struct Params: Codable {
        /**
         * Reference to a prompt or resource
         */
        public var ref: Reference
        
        /**
         * The argument's information
         */
        public var argument: Argument
        
        public init(ref: Reference, argument: Argument) {
            self.ref = ref
            self.argument = argument
        }
        
        public enum Reference: Codable {
            case prompt(PromptReference)
            case resource(ResourceReference)
            
            private enum CodingKeys: String, CodingKey {
                case type
            }
            
            public init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                let type = try container.decode(String.self, forKey: .type)
                
                switch type {
                case "ref/prompt":
                    self = .prompt(try PromptReference(from: decoder))
                case "ref/resource":
                    self = .resource(try ResourceReference(from: decoder))
                default:
                    throw DecodingError.dataCorruptedError(forKey: .type, in: container, debugDescription: "Unknown reference type: \(type)")
                }
            }
            
            public func encode(to encoder: Encoder) throws {
                switch self {
                case .prompt(let reference):
                    try reference.encode(to: encoder)
                case .resource(let reference):
                    try reference.encode(to: encoder)
                }
            }
        }
        
        public struct Argument: Codable {
            /**
             * The name of the argument
             */
            public var name: String
            
            /**
             * The value of the argument to use for completion matching.
             */
            public var value: String
            
            public init(name: String, value: String) {
                self.name = name
                self.value = value
            }
        }
    }
    
    public init(ref: Params.Reference, argument: Params.Argument) {
        let params = Params(ref: ref, argument: argument)
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(params),
           let jsonObject = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let jsonData = try? JSONSerialization.data(withJSONObject: jsonObject),
           (try? JSONDecoder().decode(AnyCodable.self, from: jsonData)) != nil {
            var requestParams = RequestParams()
            for (key, value) in jsonObject {
                requestParams[key] = AnyCodable(value)
            }
            self.params = requestParams
        }
    }
}
