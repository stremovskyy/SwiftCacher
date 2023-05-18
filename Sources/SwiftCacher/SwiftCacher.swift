import Foundation

/// A cache for storing objects on disk.
public struct SwiftCacher {
    private let cacheDirectory: URL

    /// Creates a new cache instance.
    /// - Parameter cacheDirectoryName: The name of the cache directory.
    /// - Parameter fileManager: The file manager to use for creating the cache directory. Defaults to `FileManager.default`.
    public init() {
        // Create a directory for the cache
        let cacheDirectoryName = "CacheDirectory"
        let fileManager = FileManager.default

        guard let cacheDirectoryURL = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            fatalError("Failed to retrieve caches directory URL.")
        }
        cacheDirectory = cacheDirectoryURL.appendingPathComponent(cacheDirectoryName)

        // Create the cache directory if it doesn't exist
        if !fileManager.fileExists(atPath: cacheDirectory.path) {
            do {
                try fileManager.createDirectory(atPath: cacheDirectory.path, withIntermediateDirectories: true, attributes: nil)
            } catch {
                fatalError("Failed to create cache directory: \(error)")
            }
        }
    }

    /// Caches an object.
    /// - Parameters:
    ///  - object: The object to cache.
    /// - key: The key to associate with the object.
    /// - Throws: An error if the object cannot be cached.
    /// - Note: The object must be a subclass of `NSObject` and conform to `NSCoding` and `NSSecureCoding`.
    public func setObject<T: NSCoding>(_ object: T, forKey key: String) {
        let fileURL = cacheDirectory.appendingPathComponent(key)

        // Serialize the object
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: object, requiringSecureCoding: true)

            // Write the serialized object to disk
            try data.write(to: fileURL)
        } catch {
            fatalError("Failed to write object to cache: \(error)")
        }
    }

    /// Retrieves a cached object.
    /// - Parameters:
    /// - Parameter key: The key associated with the object.
    /// - Returns: The cached object, or `nil` if no object is cached for the given key.
    /// - Throws: An error if the cached object cannot be retrieved.
    /// - Note: The object must be a subclass of `NSObject` and conform to `NSCoding` and `NSSecureCoding`.
    public func getObject<T: NSObject & NSCoding>(forKey key: String) -> T? {
        let fileURL = cacheDirectory.appendingPathComponent(key)

        // Read the serialized object from disk
        guard let data = try? Data(contentsOf: fileURL) else {
            return nil
        }

        // Deserialize the object
        do {
            let unarchiver = try NSKeyedUnarchiver(forReadingFrom: data)
            unarchiver.requiresSecureCoding = true

            guard let object = unarchiver.decodeObject(of: T.self, forKey: NSKeyedArchiveRootObjectKey) else {
                return nil
            }

            unarchiver.finishDecoding()

            return object
        } catch {
            fatalError("Failed to unarchive object from cache: \(error)")
        }
    }

    /// Removes a cached object.
    /// - Parameters:
    /// - Parameter key: The key associated with the object.
    /// - Throws: An error if the object cannot be removed.
    public func removeObject(forKey key: String) {
        let fileURL = cacheDirectory.appendingPathComponent(key)

        // Remove the object from disk
        do {
            try FileManager.default.removeItem(at: fileURL)
        } catch {
            fatalError("Failed to remove object from cache: \(error)")
        }
    }

    /// Removes all objects from the cache.
    /// - Throws: An error if the objects cannot be removed.
    /// - Note: This method is not atomic.
    public func removeAllObjects() {
        // Remove all objects from the cache directory
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: nil, options: [])
            for fileURL in fileURLs {
                try FileManager.default.removeItem(at: fileURL)
            }
        } catch {
            fatalError("Failed to remove all objects from cache: \(error)")
        }
    }
}
