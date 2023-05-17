//
// Created by Anton Stremovskyy on 17.05.2023.
//

import Foundation

class MyObject: NSObject, NSCoding, NSSecureCoding {
    static var supportsSecureCoding: Bool {
        return true
    }
    
    var name: String
    
    init(name: String) {
        self.name = name
    }
    
    required init?(coder aDecoder: NSCoder) {
        guard let name = aDecoder.decodeObject(of: NSString.self, forKey: "name") as String? else {
            return nil
        }
        self.name = name
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name as NSString, forKey: "name")
    }
}
