import Foundation

enum AppConfig {
    static let canopyAnchor = URL(string: "https://djmorzat.com/1j7SY9")!
    static let privacyPolicyURL = URL(string: "https://www.termsfeed.com/live/eac7b698-87fe-4452-93d1-19e3c0bc4faa")!
    static let supportEmail = "jelegafa@icloud.com"

    static var versionLine: String {
        let mv = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
        let bn = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1"
        return "\(mv).\(bn)"
    }
}
