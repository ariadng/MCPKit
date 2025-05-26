/**
 * The severity of a log message.
 *
 * These map to syslog message severities, as specified in RFC-5424:
 * https://datatracker.ietf.org/doc/html/rfc5424#section-6.2.1
 */
public enum LoggingLevel: String, Codable {
    case debug = "debug"
    case info = "info"
    case notice = "notice"
    case warning = "warning"
    case error = "error"
    case critical = "critical"
    case alert = "alert"
    case emergency = "emergency"
}
