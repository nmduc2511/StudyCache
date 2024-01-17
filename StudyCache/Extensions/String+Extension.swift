import Foundation

extension String {
    func asTrim() -> String {
        return self
            .replacingOccurrences(of: "https://", with: "")
            .replacingOccurrences(of: "http://", with: "")
            .replacingOccurrences(of: "/", with: "-")
    }
}
