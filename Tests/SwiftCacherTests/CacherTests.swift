import XCTest
@testable import SwiftCacher

final class SwiftCacherTests: XCTestCase {

    func testCachingAndRetrieval() throws {
        // Create a cache instance
        let cache = try SwiftCacher()

        // Cache an object
        let myObject = MyObject(name: "Cached Object")
        try cache.setObject(myObject, forKey: "myObjectKey")

        // Retrieve the cached object
        do {
            if let cachedObject: MyObject = try cache.getObject(forKey: "myObjectKey") {
                XCTFail("object myObjectKey exists: \(cachedObject.name)")
            }
        } catch {
            XCTFail("Failed to retrieve cached object: \(error)")
        }
    }

    func testObjectRemoval() throws {
        // Create a cache instance
        let cache = try SwiftCacher()

        // Cache an object
        let myObject = MyObject(name: "Cached Object")
        try cache.setObject(myObject, forKey: "myObjectKey")

        // Remove the cached object
        try cache.removeObject(forKey: "myObjectKey")

        // Try to retrieve the removed object
        do {
            let removedObject: MyObject? = try cache.getObject(forKey: "myObjectKey")
            XCTAssertNil(removedObject, "Object was not removed from cache")
        } catch {
            XCTFail("Failed to retrieve removed object: \(error)")
        }
    }

    func testObjectExpiration() throws {
        // Create a cache instance
        let cache = try SwiftCacher()

        // Cache an object with an expiration duration of 1 second
        let expiringObject = MyObject(name: "Expiring Object")
        try cache.setObject(expiringObject, forKey: "expiringObjectKey", expirationDuration: 1)

        // Wait for the object to expire
        Thread.sleep(forTimeInterval: 2)

        // Try to retrieve the expired object
        do {
            let expiredObject: MyObject? = try cache.getObject(forKey: "expiringObjectKey")
            XCTAssertNil(expiredObject, "Expired object was not removed from cache")
        } catch {
            XCTFail("Failed to retrieve expired object: \(error)")
        }
    }

    func testRemovingAllObjects() throws {
        // Create a cache instance
        let cache = try SwiftCacher()

        // Cache multiple objects
        let object1 = MyObject(name: "Object 1")
        let object2 = MyObject(name: "Object 2")
        try cache.setObject(object1, forKey: "object1Key")
        try cache.setObject(object2, forKey: "object2Key")

        // Remove all objects from the cache
        do {
            try cache.removeAllObjects()
        } catch {
            XCTFail("Failed to remove all objects from cache: \(error)")
        }

        // Try to retrieve the removed objects
        do {
            let retrievedObject1: MyObject? = try cache.getObject(forKey: "object1Key")
            let retrievedObject2: MyObject? = try cache.getObject(forKey: "object2Key")
            XCTAssertNil(retrievedObject1, "Object 1 was not removed from cache")
            XCTAssertNil(retrievedObject2, "Object 2 was not removed from cache")
        } catch {
            XCTFail("Failed to retrieve removed objects: \(error)")
        }
    }

    func testRemovingExpiredObjects() throws {
        // Create a cache instance
        let cache = try SwiftCacher()

        // Cache objects with different expiration durations
        let object3 = MyObject(name: "Object 3")
        let object4 = MyObject(name: "Object 4")
        try cache.setObject(object3, forKey: "object3Key", expirationDuration: 5)
        try cache.setObject(object4, forKey: "object4Key", expirationDuration: 10)

        // Wait for some objects to expire
        Thread.sleep(forTimeInterval: 7)

        // Try to retrieve the expired and non-expired objects
        do {
            let expiredObject3: MyObject? = try cache.getObject(forKey: "object3Key")
            let nonExpiredObject4: MyObject? = try cache.getObject(forKey: "object4Key")
            XCTAssertNil(expiredObject3, "Expired object 3 was not removed from cache")
            XCTAssertNotNil(nonExpiredObject4, "Non-expired object 4 was removed from cache")
        } catch {
            XCTFail("Failed to retrieve expired and non-expired objects: \(error)")
        }

        // Remove all expired objects from the cache
        do {
            try cache.removeExpired()
        } catch {
            XCTFail("Failed to remove expired objects from cache: \(error)")
        }

        // Try to retrieve the remaining object
        do {
            let remainingObject4: MyObject? = try cache.getObject(forKey: "object4Key")
            XCTAssertNotNil(remainingObject4, "Remaining object 4 was removed from cache")
        } catch {
            XCTFail("Failed to retrieve remaining object: \(error)")
        }
    }
}
