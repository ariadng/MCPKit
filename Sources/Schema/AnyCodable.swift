import Foundation

/// A type-erased wrapper that allows encoding and decoding of heterogeneous JSON values.
/// This is particularly useful for fields in JSON structures that can contain values of any valid JSON type.
/// - Note: This type is marked as `@unchecked Sendable`. It is the developer's responsibility to ensure that
///   the underlying `value` is `Sendable` if `AnyCodable` instances are passed across actor boundaries.
///   Standard JSON types (String, Int, Double, Bool, and collections of these) are `Sendable`.
public struct AnyCodable: Codable, Equatable, @unchecked Sendable {
    private let value: Any

    /// Initializes `AnyCodable` with any value. If `nil` is provided, it's stored as an internal representation of null.
    public init<T>(_ value: T?) {
        self.value = value ?? ()
    }

    /// Attempts to decode the wrapped value to a specific `Decodable` type.
    /// This typically involves re-encoding `self` to `Data` and then decoding that `Data` to the target type.
    public func decode<T: Decodable>(to type: T.Type) throws -> T {
        let data = try JSONEncoder().encode(self)
        return try JSONDecoder().decode(T.self, from: data)
    }

    /// Encodes the wrapped value.
    /// This implementation handles common JSON primitive types, arrays, and dictionaries.
    /// For more complex `Encodable` types, a more robust implementation might be needed.
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch value {
        case let val as String: try container.encode(val)
        case let val as Int: try container.encode(val)
        case let val as Double: try container.encode(val)
        case let val as Bool: try container.encode(val)
        case let val as [Any?]: try container.encode(val.map { AnyCodable($0) })
        case let val as [String: Any?]: try container.encode(val.mapValues { AnyCodable($0) })
        case is (): try container.encodeNil() // Represents a JSON null
        default:
            // This part is tricky. If `value` is an `Encodable` but not one of the above,
            // trying to cast to `Encodable` and call `encode(to:)` directly is problematic
            // due to `Self` requirements in `Encodable`.
            // A full AnyCodable often involves more complex type erasure or specific strategies.
            // For this basic version, we'll throw an error for unhandled Encodable types.
            if value is Encodable {
                 throw EncodingError.invalidValue(value, EncodingError.Context(codingPath: encoder.codingPath, debugDescription: "AnyCodable can currently only encode basic JSON types, collections of them, or values that are directly Encodable and handled by the JSONEncoder's default strategies. Complex custom Encodable types might require a more specialized AnyCodable implementation."))
            } else {
                 try container.encodeNil() // Fallback for other unhandled types, treating them as null.
            }
        }
    }

    /// Initializes `AnyCodable` by decoding from a decoder.
    /// It attempts to decode the value as one of the common JSON types.
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if container.decodeNil() { self.value = () } // Represents JSON null
        else if let bool = try? container.decode(Bool.self) { self.value = bool }
        else if let int = try? container.decode(Int.self) { self.value = int }
        else if let double = try? container.decode(Double.self) { self.value = double }
        else if let string = try? container.decode(String.self) { self.value = string }
        else if let array = try? container.decode([AnyCodable].self) { self.value = array.map { $0.value } } 
        else if let dictionary = try? container.decode([String: AnyCodable].self) { self.value = dictionary.mapValues { $0.value } }
        else { throw DecodingError.dataCorruptedError(in: container, debugDescription: "AnyCodable value cannot be decoded into any known JSON type.") }
    }
}

extension AnyCodable {
    public static func == (lhs: AnyCodable, rhs: AnyCodable) -> Bool {
        switch (lhs.value, rhs.value) {
        case (let l as String, let r as String):
            return l == r
        case (let l as Int, let r as Int):
            return l == r
        case (let l as Double, let r as Double):
            return l == r
        case (let l as Bool, let r as Bool):
            return l == r
        case (is (), is ()): // Both are nil
            return true
        case (let l as [AnyCodable], let r as [AnyCodable]):
             return l == r
        case (let l as [String: AnyCodable], let r as [String: AnyCodable]):
             return l == r
        // Attempt to compare arrays of other equatable types if necessary, e.g., [String], [Int]
        // This basic implementation might need to be expanded for more complex scenarios
        // or rely on a more robust underlying comparison if values are custom Equatable types.
        default:
            // Fallback: if types are different or not directly comparable with above, consider them not equal.
            // For a more comprehensive equality, one might convert to Data and compare, or stringify.
            // However, that can be lossy or inefficient.
            // If one is nil and the other is not, they are not equal.
            if (lhs.value is () && !(rhs.value is ())) || (!(lhs.value is ()) && rhs.value is ()) {
                return false
            }
            // If types are different, they are not equal.
            // This check is a bit simplistic as it relies on Swift's dynamic type checking.
            if type(of: lhs.value) != type(of: rhs.value) {
                return false
            }
            // As a last resort, if they are of the same type but not covered above, consider them unequal.
            // This part is tricky without knowing all possible types.
            // A more robust solution might involve trying to cast to specific Equatable types
            // or using a library that handles deep equality for Any.
            return false // Or a more sophisticated comparison if needed
        }
    }
}
