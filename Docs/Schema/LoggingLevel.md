# LoggingLevel

## Overview

The `LoggingLevel` enumeration represents the severity of a log message in the MCP system. These map to syslog message severities, as specified in [RFC-5424](https://datatracker.ietf.org/doc/html/rfc5424#section-6.2.1).

## Declaration

```swift
public enum LoggingLevel: String, Codable
```

## Cases

### debug

```swift
case debug = "debug"
```

Debug-level messages.

### info

```swift
case info = "info"
```

Informational messages.

### notice

```swift
case notice = "notice"
```

Normal but significant condition.

### warning

```swift
case warning = "warning"
```

Warning conditions.

### error

```swift
case error = "error"
```

Error conditions.

### critical

```swift
case critical = "critical"
```

Critical conditions.

### alert

```swift
case alert = "alert"
```

Action must be taken immediately.

### emergency

```swift
case emergency = "emergency"
```

System is unusable.
