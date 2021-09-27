import Foundation
import RealmSwift

class Note: Object {
    @Persisted var text: String = ""
    @Persisted var noteID = UUID().uuidString
    @Persisted var data: Data?
    convenience init(text: String) {
        self.init()
        self.text = text
    }

    override static func primaryKey() -> String? {
        return "noteID"
    }
}
