import XCTest
@testable import Cacher

final class CacherTests: XCTestCase {
    func testExample() throws {

        // Create a cache instance
        let cache = Cacher()

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
