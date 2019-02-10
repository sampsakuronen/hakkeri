import Foundation

class UserSettings {
    static func readerMode() -> Bool {
        return UserDefaults.standard.bool(forKey: "reader_mode")
    }

    static func darkMode() -> Bool {
        return UserDefaults.standard.bool(forKey: "dark_mode")
    }

    static func dankMode() -> Bool {
        return UserDefaults.standard.bool(forKey: "dank_mode")
    }
}
