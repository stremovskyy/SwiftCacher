# SwiftCacher

SwiftCacher is a Swift package that provides a simple key-value caching mechanism with persistence. It allows you to store objects in a cache directory on disk, making them easily retrievable for future use.

## Features

- Create a cache directory on disk if it doesn't exist.
- Save objects to the cache using secure coding and serialization.
- Retrieve objects from the cache.
- Remove specific objects from the cache.
- Remove all objects from the cache.
- Remove expired objects from the cache.

## Requirements

- iOS 10.0+ / macOS 10.12+ / tvOS 10.0+ / watchOS 3.0+
- Xcode 11.0+
- Swift 5.0+

## Installation

You can integrate SwiftCacher into your Swift project using Swift Package Manager.

1. Open your project in Xcode.
2. Select your project in the Project Navigator.
3. Select the "Swift Packages" tab.
4. Click the "+" button to add a package dependency.
5. Enter the URL of this repository: [https://github.com/stremovskyy/SwiftCacher.git](https://github.com/stremovskyy/SwiftCacher.git)
6. Choose the desired version or branch.
7. Click "Next" and follow the Xcode instructions to complete the installation.

## Usage

```swift
import SwiftCacher

// Create an instance of the cache
let cache = try SwiftCacher()

// Store an object in the cache
let objectToCache = MyObject(name: "John Doe")
try cache.setObject(objectToCache, forKey: "user")

// Retrieve the object from the cache
do {
    if let cachedObject: MyObject = try cache.getObject(forKey: "user") {
        print("Cached object: \(cachedObject)")
    } else {
        print("Object not found in the cache.")
    }
} catch {
    print("Failed to retrieve cached object: \(error)")
}

// Remove the object from the cache
do {
    try cache.removeObject(forKey: "user")
} catch {
    print("Failed to remove object from cache: \(error)")
}

// Remove all objects from the cache
do {
    try cache.removeAllObjects()
} catch {
    print("Failed to remove all objects from cache: \(error)")
}

// Remove expired objects from the cache
do {
    try cache.removeExpired()
} catch {
    print("Failed to remove expired objects from cache: \(error)")
}
```

## Precautions

 - SwiftCacher uses the `NSKeyedArchiver` and `NSKeyedUnarchiver` classes to serialize and deserialize objects. 

>This means that all objects that you want to store in the cache must conform to the `NSSecureCoding` protocol.
For more information, see [Archives and Serializations Programming Guide](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/Archiving/Archiving.html) and [NSSecureCoding](https://developer.apple.com/documentation/foundation/nssecurecoding).

> In other words, you need to implement the following methods in your object:

```swift
class MyObject: NSObject, NSSecureCoding {
    static var supportsSecureCoding: Bool = true

    func encode(with coder: NSCoder) {
        // Encode the object
    }

    required init?(coder: NSCoder) {
        // Decode the object
    }
}
```

- SwiftCacher uses the `FileManager` class to create a cache directory on disk.

> This means that you need to add the `NSFileProtectionKey` key to your app's `Info.plist` file to protect the cache directory with data protection. For more information, see [Data Protection](https://developer.apple.com/documentation/uikit/core_app/protecting_the_user_s_privacy/encrypting_your_app_s_files).

- Do not use `coder.decodeObject(forKey:)` to decode objects from the cache. Instead, use `cache.getObject(forKey:)` to retrieve objects from the cache.

> This is because `coder.decodeObject(forKey:)` returns an optional object, which can be `nil`. If you try to decode a `nil` object, you will get a `nil` object. This is not what you want. Instead, you should use `cache.getObject(forKey:)` to retrieve objects from the cache. This method returns an optional object, which can be `nil`. If you try to retrieve a `nil` object, you will get a `nil` object. This is what you want.
 

## License

SwiftCacher is released under the MIT license. See [LICENSE](LICENSE) for details.

## Contributing

Contributions are welcome! Please see [CONTRIBUTING](CONTRIBUTING.md) for details.
If you have any ideas, suggestions, or bug reports, please open an issue or submit a pull request.

## Acknowledgements

SwiftCacher is inspired by the need for a simple and efficient caching mechanism in Swift projects. It aims to provide an easy-to-use solution for storing and retrieving objects with persistence.
