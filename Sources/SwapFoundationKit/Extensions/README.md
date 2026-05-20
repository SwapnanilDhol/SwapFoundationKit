# Extensions

Type extensions for Date, String, Number, Collection, Bundle, URL, FileManager, Result, Data, JSON Codable, and async collection operations.

## Public API

### Date (`Date+Extensions.swift`)
| Property/Method | Description |
|-----------------|-------------|
| `.iso8601String`, `.shortDate`, `.mediumDate`, `.longDate`, `.fullDate` | Formatted strings |
| `.timeOnly`, `.time24Hour`, `.yyyyMMdd` | Common formats |
| `.relativeTime`, `.relativeTimeAbbreviated` | "2 hours ago", "2h ago" |
| `.year`, `.month`, `.day`, `.hour`, `.minute`, `.second`, `.weekday` | Components |
| `.isToday`, `.isYesterday`, `.isTomorrow`, `.isWeekend`, `.isThisWeek` | Checks |
| `.startOfDay`, `.endOfDay`, `.startOfWeek`, `.endOfMonth`, `.startOfYear` | Boundaries |
| `.adding(days:)`, `.adding(months:)`, `.adding(years:)` | Manipulation |
| `DateFormat` | Enum with 16 format presets |

### String (`String+.swift`)
| Property/Method | Description |
|-----------------|-------------|
| `.isBlank`, `.isNotBlank`, `.isNumeric`, `.isAlphabetic`, `.isAlphanumeric` | Validation |
| `.isValidEmail` | Email regex |
| `.isValidURL`, `.isValidPhoneNumber`, `.isValidCreditCard` | Format checks |
| `.trimmed`, `.capitalizedFirst`, `.withoutWhitespace` | Manipulation |
| `.truncated(to:with:)` | Truncation with suffix |
| `.masked(keepFirst:keepLast:)` | Privacy masking |
| `.md5`, `.sha1`, `.sha256` | Hashing |
| `.localized`, `.localized(bundle:)`, `.localizedFormat(...)` | Localization |
| `.htmlStripped`, `.base64Encoded`, `.base64Decoded` | Conversion |
| `.levenshteinDistance(to:)` | String similarity |

### Number (`Number+.swift`)
| Property/Method | Description |
|-----------------|-------------|
| `CGFloat.random` | Random CGFloat |
| `Double.clean` | Trailing-zero removal |
| `Double.wordRepresentation` | Spell-out (1-999,999) |

### Collection (`Collection+.swift`)
| Property/Method | Description |
|-----------------|-------------|
| `[safe: index]` | Bounds-safe subscript |
| `.isNotEmpty` | Inverse of isEmpty |
| `.chunked(into:)` | Split into equal-sized chunks |

### Collection Async (`Collection+Async.swift`)
| Method | Description |
|--------|-------------|
| `Sequence.asyncReduce(_:_:)` | Sequential async reduce |
| `Dictionary.asyncMap(_:)` | Async map over dictionary entries |

### Bundle (`Bundle+InfoPlist.swift`)
| Property/Method | Description |
|-----------------|-------------|
| `.appName`, `.displayName`, `.bundleIdentifier` | Info.plist values |
| `.releaseVersionNumber`, `.buildVersionNumber` | Version info |
| `.isDebugBuild` | Debug detection |
| `InfoPlistKey` | Typed key enum with `.custom(String)` |

### URL (`URL+Extensions.swift`)
| Property/Method | Description |
|-----------------|-------------|
| `.queryParameters` | Query string as dictionary |
| `.isHTTPS`, `.isHTTP` | Scheme checks |
| `.appendingQueryItem(name:value:)` | Add parameter |
| `.removingQueryParameters()` | Strip query |
| `.fileExtension`, `.fileName` | Path helpers |

### FileManager (`FileManager+Extensions.swift`)
| Property/Method | Description |
|-----------------|-------------|
| `.documentsDirectory`, `.cachesDirectory` | Directory URLs |
| `.fileSize(at:)`, `.fileSizeFormatted(at:)` | Size helpers |
| `.directorySize(at:)` | Recursive directory size |
| `.createDirectoryIfNeeded(at:)` | Safe creation |
| `.removeItemSafely(at:)` | Non-throwing removal |

### Result (`Result+Extensions.swift`)
| Property/Method | Description |
|-----------------|-------------|
| `.isSuccess`, `.isFailure` | State checks |
| `.getOrElse(_:)`, `.getOrNil`, `.getOrThrow()` | Value access |
| `.map(_:)`, `.mapError(_:)`, `.flatMap(_:)` | Transformation |

### Data Crypto (`Data+Crypto.swift`)
| Property | Description |
|----------|-------------|
| `.md5` | MD5 hex string |
| `.sha1` | SHA1 hex string |
| `.sha256` | SHA256 hex string |

### JSON Codable (`JSON+Codable.swift`)
| Method | Description |
|--------|-------------|
| `JSONCodable.encode(_:prettyPrinted:)` | Encode to Data |
| `JSONCodable.decode(_:from:)` | Decode from Data |
| `JSONCodable.encodeToString(_:prettyPrinted:)` | Encode to JSON string |
| `JSONCodable.decodeFromString(_:from:)` | Decode from JSON string |
| `JSONCodable.jsonFromFile(_:in:fileExtension:)` | Load and decode from bundle |

## Source Files

- `Date+Extensions.swift` — 296 lines, cached formatters and calendar
- `String+.swift` — Validation, manipulation, crypto, localization
- `Number+.swift` — Double, Float, CGFloat formatting
- `Collection+.swift` — Safe subscript, chunking
- `Collection+Async.swift` — asyncReduce, asyncMap
- `Bundle+InfoPlist.swift` — Info.plist accessors
- `URL+Extensions.swift` — URL manipulation
- `FileManager+Extensions.swift` — File system helpers
- `Result+Extensions.swift` — Result transformation
- `Data+Crypto.swift` — MD5, SHA1, SHA256
- `JSON+Codable.swift` — JSON encode/decode utilities
