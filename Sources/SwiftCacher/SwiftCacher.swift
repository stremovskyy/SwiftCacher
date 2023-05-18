import Foundation

public struct SwiftCacher {
    private let cacheDirectory: URL

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

    func setObject<T: NSCoding>(_ object: T, forKey key: String) {
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

    func getObject<T: NSObject & NSCoding>(forKey key: String) -> T? {
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

    func removeObject(forKey key: String) {
        let fileURL = cacheDirectory.appendingPathComponent(key)

        // Remove the object from disk
        do {
            try FileManager.default.removeItem(at: fileURL)
        } catch {
            fatalError("Failed to remove object from cache: \(error)")
        }
    }

    func removeAllObjects() {
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
