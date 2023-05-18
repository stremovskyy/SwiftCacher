import Foundation

/// Errors that can occur during caching operations.
public enum SwiftCacherError: Error {
    case cacheDirectoryCreationFailed
    case cacheDirectoryAccessFailed
    case objectCachingFailed
    case objectRetrievalFailed
    case objectRemovalFailed
}

/// A cache for storing objects on disk.
public struct SwiftCacher {
    private let cacheDirectory: URL

    /// Creates a new cache instance.
    /// - Parameter cacheDirectoryName: The name of the cache directory.
    /// - Parameter fileManager: The file manager to use for creating the cache directory. Defaults to `FileManager.default`.
    public init() throws {
        // Create a directory for the cache
        let cacheDirectoryName = "CacheDirectory"
        let fileManager = FileManager.default

        guard let cacheDirectoryURL = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            throw SwiftCacherError.cacheDirectoryAccessFailed
        }
        cacheDirectory = cacheDirectoryURL.appendingPathComponent(cacheDirectoryName)

        // Create the cache directory if it doesn't exist
        if !fileManager.fileExists(atPath: cacheDirectory.path) {
            do {
                try fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true, attributes: nil)
            } catch {
                throw SwiftCacherError.cacheDirectoryCreationFailed
            }
        }
    }


    /// Caches an object with an optional expiration duration.
    /// - Parameters:
    ///   - object: The object to cache.
    ///   - key: The key to associate with the object.
    ///   - expirationDuration: The duration in seconds after which the object should expire. Pass `nil` for no expiration.
    /// - Throws: An error if the object cannot be cached.
    /// - Note: The object must be a subclass of `NSObject` and conform to `NSCoding` and `NSSecureCoding`.
    public func setObject<T: NSCoding>(_ object: T, forKey key: String, expirationDuration: TimeInterval? = nil) throws {
        let fileURL = cacheDirectory.appendingPathComponent(key)

        // Serialize the object
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: object, requiringSecureCoding: true)

            // Write the serialized object to disk
            try data.write(to: fileURL)

            // Set expiration date if provided
            if let duration = expirationDuration {
                let expirationDate = Date().addingTimeInterval(duration)
                try setExpirationDate(expirationDate, forFileAtPath: fileURL.path)
            }
        } catch {
            throw SwiftCacherError.objectCachingFailed
        }
    }


    /// Retrieves a cached object.
    /// - Parameters:
    /// - Parameter key: The key associated with the object.
    /// - Returns: The cached object, or `nil` if no object is cached for the given key or the object has expired.
    /// - Throws: An error if the cached object cannot be retrieved.
    /// - Note: The object must be a subclass of `NSObject` and conform to `NSCoding` and `NSSecureCoding`.
    public func getObject<T: NSObject & NSCoding>(forKey key: String) throws -> T? {
        let fileURL = cacheDirectory.appendingPathComponent(key)

        // Read the serialized object from disk
        guard let data = try? Data(contentsOf: fileURL) else {
            return nil
        }

        // Check expiration date
        if let expirationDate = getExpirationDate(forFileAtPath: fileURL.path), expirationDate < Date() {
            // Object has expired
            try removeObject(forKey: key)
            return nil
        }

        // Deserialize the object
        do {
            let unarchiver = try NSKeyedUnarchiver(forReadingFrom: data)
            unarchiver.requiresSecureCoding = true

            guard let object = unarchiver.decodeObject(of: T.self, forKey: NSKeyedArchiveRootObjectKey) else {
                throw SwiftCacherError.objectRetrievalFailed
            }

            unarchiver.finishDecoding()

            return object
        } catch {
            throw SwiftCacherError.objectRetrievalFailed
        }
    }


    /// Removes a cached object.
    /// - Parameters:
    /// - Parameter key: The key associated with the object.
    /// - Throws: An error if the object cannot be removed.
    public func removeObject(forKey key: String) throws {
        let fileURL = cacheDirectory.appendingPathComponent(key)

        // Remove the object from disk
        do {
            try FileManager.default.removeItem(at: fileURL)
        } catch {
            throw SwiftCacherError.objectRemovalFailed
        }
    }

    /// Removes all objects from the cache.
    /// - Throws: An error if the objects cannot be removed.
    /// - Note: This method is not atomic.
    public func removeAllObjects() throws {
        // Remove all objects from the cache directory
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: nil, options: [])
            for fileURL in fileURLs {
                try FileManager.default.removeItem(at: fileURL)
            }
        } catch {
            throw SwiftCacherError.objectRemovalFailed
        }
    }

    /// Removes all expired objects from the cache.
    /// - Throws: An error if the expired objects cannot be removed.
    public func removeExpired() throws {
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: [.creationDateKey], options: [])
            let currentDate = Date()

            for fileURL in fileURLs {
                if let expirationDate = getExpirationDate(forFileAtPath: fileURL.path), expirationDate < currentDate {
                    try FileManager.default.removeItem(at: fileURL)
                }
            }
        } catch {
            throw SwiftCacherError.objectRemovalFailed
        }
    }

    // MARK: - Private Methods

    private func setExpirationDate(_ expirationDate: Date, forFileAtPath path: String) throws {
        let attributes = [FileAttributeKey.creationDate: expirationDate]
        try FileManager.default.setAttributes(attributes, ofItemAtPath: path)
    }

    private func getExpirationDate(forFileAtPath path: String) -> Date? {
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: path)
            return attributes[FileAttributeKey.creationDate] as? Date
        } catch {
            return nil
        }
    }
}
