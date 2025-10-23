import Foundation

@objc class PasswordEntry: NSObject, NSSecureCoding {
    static var supportsSecureCoding: Bool { return true }

    let identifier: UUID
    var title: String
    var username: String
    var password: String
    var notes: String?

    init(title: String, username: String, password: String, notes: String?) {
        self.identifier = UUID()
        self.title = title
        self.username = username
        self.password = password
        self.notes = notes
        super.init()
    }

    required init?(coder: NSCoder) {
        guard let identifier = coder.decodeObject(of: NSUUID.self, forKey: "id") as? UUID,
            let title = coder.decodeObject(of: NSString.self, forKey: "title") as? String,
            let username = coder.decodeObject(of: NSString.self, forKey: "username") as? String,
            let password = coder.decodeObject(of: NSString.self, forKey: "password") as? String
        else {
            return nil
        }

        self.identifier = identifier
        self.title = title
        self.username = username
        self.password = password
        self.notes = coder.decodeObject(of: NSString.self, forKey: "notes") as? String
        super.init()
    }

    func encode(with coder: NSCoder) {
        coder.encode(identifier as NSUUID, forKey: "id")
        coder.encode(title as NSString, forKey: "title")
        coder.encode(username as NSString, forKey: "username")
        coder.encode(password as NSString, forKey: "password")
        if let notes = notes {
            coder.encode(notes as NSString, forKey: "notes")
        }
    }

    override var description: String {
        return """
            PasswordEntry:
              ID: \(identifier)
              Title: \(title)
              Username: \(username)
              Password: \(password)
              Notes: \(notes ?? "none")
            """
    }
}
