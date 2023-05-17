import XCTest
@testable import SwiftCacher

final class SwiftCacherTests: XCTestCase {
    func testBasic() throws {

        // Create a cache instance
        let cache = SwiftCacher()

        // Cache an object
        let myObject = MyObject(name: "Cached Object")
        cache.setObject(myObject, forKey: "myObjectKey")

        // Retrieve the cached object
        if let cachedObject : MyObject = cache.getObject(forKey: "myObjectKey")  {
            print(cachedObject.name) // Output: "Cached Object"
            
            XCTAssertEqual(cachedObject.name, "Cached Object")
        }

        // Remove the cached object
        cache.removeObject(forKey: "myObjectKey")

        // Remove all objects from the cache
        cache.removeAllObjects()
    }
}
