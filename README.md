# SwiftCacher

SwiftCacher is a Swift package that provides a simple key-value caching mechanism with persistence. It allows you to store objects in a cache directory on disk, making them easily retrievable for future use.

## Features

- Create a cache directory on disk if it doesn't exist.
- Save objects to the cache using secure coding and serialization.
- Retrieve objects from the cache.
- Remove specific objects from the cache.
- Remove all objects from the cache.

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
let cache = SwiftCacher()

// Store an object in the cache
let objectToCache = MyObject(name: "John Doe")
cache.setObject(objectToCache, forKey: "user")

// Retrieve the object from the cache
if let cachedObject: MyObject = cache.getObject(forKey: "user") {
    print("Cached object: \(cachedObject)")
} else {
    print("Object not found in the cache.")
}

// Remove the object from the cache
cache.removeObject(forKey: "user")

// Remove all objects from the cache
cache.removeAllObjects()
```

## Precautions

SwiftCacher uses the `NSKeyedArchiver` and `NSKeyedUnarchiver` classes to serialize and deserialize objects. 

This means that all objects that you want to store in the cache must conform to the `NSSecureCoding` protocol.
For more information, see [Archives and Serializations Programming Guide](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/Archiving/Archiving.html) and [NSSecureCoding](https://developer.apple.com/documentation/foundation/nssecurecoding).

In other words, you need to implement the following methods in your object:

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
 

## License

SwiftCacher is released under the MIT license. See [LICENSE](LICENSE) for details.

## Contributing

Contributions are welcome! Please see [CONTRIBUTING](CONTRIBUTING.md) for details.
If you have any ideas, suggestions, or bug reports, please open an issue or submit a pull request.

## Acknowledgements

SwiftCacher is inspired by the need for a simple and efficient caching mechanism in Swift projects. It aims to provide an easy-to-use solution for storing and retrieving objects with persistence.



