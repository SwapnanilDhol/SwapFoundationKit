import Foundation

/// A bounded, actor-isolated key-value store whose values expire automatically.
///
/// Values are JSON-encoded into a caller-owned `UserDefaults` key, making the
/// store suitable for lightweight refresh metadata, retry cooldowns, and small
/// cached responses that need to survive app launches. Expired records are
/// removed lazily during reads and writes. When the capacity is exceeded, the
/// least recently set record is evicted.
///
/// ## Usage
/// ```swift
/// enum LookupStatus: String, Codable, Sendable {
///     case unavailable
/// }
///
/// let store = PersistentTTLStore<LookupStatus>(
///     storageKey: "merchant-lookup-status",
///     maximumEntryCount: 500
/// )
///
/// await store.set(.unavailable, forKey: "merchant-id", ttl: 60 * 60)
/// if await store.value(forKey: "merchant-id") == .unavailable {
///     // Skip the remote lookup until the record expires.
/// }
/// ```
public actor PersistentTTLStore<Value: Codable & Sendable> {
    private struct Record: Codable {
        let key: String
        let value: Value
        let expiresAt: Date
    }

    private let userDefaults: UserDefaults
    private let storageKey: String
    private let maximumEntryCount: Int
    private var records: [Record]

    /// Creates a persistent expiring-value store.
    ///
    /// - Parameters:
    ///   - userDefaults: Defaults database used for persistence.
    ///   - storageKey: Caller-owned key. Use a versioned key when changing the stored value type.
    ///   - maximumEntryCount: Maximum records retained. Values smaller than one are clamped to one.
    ///   - now: Reference date used to discard expired records during initialization.
    public init(
        userDefaults: UserDefaults = .standard,
        storageKey: String,
        maximumEntryCount: Int = 500,
        now: Date = Date()
    ) {
        self.userDefaults = userDefaults
        self.storageKey = storageKey
        self.maximumEntryCount = max(1, maximumEntryCount)

        let decodedRecords = userDefaults.data(forKey: storageKey)
            .flatMap { try? JSONDecoder().decode([Record].self, from: $0) }
            ?? []
        self.records = Array(
            decodedRecords
                .filter { $0.expiresAt > now }
                .suffix(self.maximumEntryCount)
        )

        if records.count != decodedRecords.count {
            persist()
        }
    }

    /// Returns a value while its record remains unexpired.
    public func value(forKey key: String, at date: Date = Date()) -> Value? {
        removeExpiredRecords(at: date)
        return records.first { $0.key == key }?.value
    }

    /// Returns the expiration date for an active record.
    public func expirationDate(forKey key: String, at date: Date = Date()) -> Date? {
        removeExpiredRecords(at: date)
        return records.first { $0.key == key }?.expiresAt
    }

    /// Stores a value until `date + ttl`. A non-positive TTL removes the key.
    public func set(_ value: Value, forKey key: String, ttl: TimeInterval, at date: Date = Date()) {
        guard ttl > 0 else {
            removeValue(forKey: key)
            return
        }
        set(value, forKey: key, expiresAt: date.addingTimeInterval(ttl), at: date)
    }

    /// Stores a value until an absolute expiration date.
    public func set(
        _ value: Value,
        forKey key: String,
        expiresAt: Date,
        at date: Date = Date()
    ) {
        guard !key.isEmpty else { return }

        records.removeAll { $0.key == key }
        records.append(Record(key: key, value: value, expiresAt: expiresAt))
        removeExpiredRecords(at: date, persistChanges: false)
        if records.count > maximumEntryCount {
            records.removeFirst(records.count - maximumEntryCount)
        }
        persist()
    }

    /// Removes one value, if present.
    public func removeValue(forKey key: String) {
        let previousCount = records.count
        records.removeAll { $0.key == key }
        if records.count != previousCount {
            persist()
        }
    }

    /// Removes every stored value.
    public func removeAll() {
        guard !records.isEmpty || userDefaults.object(forKey: storageKey) != nil else { return }
        records.removeAll()
        userDefaults.removeObject(forKey: storageKey)
    }

    /// Returns the number of active values.
    public func count(at date: Date = Date()) -> Int {
        removeExpiredRecords(at: date)
        return records.count
    }

    private func removeExpiredRecords(at date: Date, persistChanges: Bool = true) {
        let previousCount = records.count
        records.removeAll { $0.expiresAt <= date }
        if persistChanges, records.count != previousCount {
            persist()
        }
    }

    private func persist() {
        do {
            userDefaults.set(try JSONEncoder().encode(records), forKey: storageKey)
        } catch {
            Logger.error("PersistentTTLStore failed to encode records for key \"\(storageKey)\": \(error.localizedDescription)")
        }
    }
}
