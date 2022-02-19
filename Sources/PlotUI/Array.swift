import SwiftUI

extension Array where Self.Element == Double {

    static func asDouble<S: Sequence, E: BinaryInteger>(_ elements: S) -> Self
    where S.Element == E {
        return elements.map { e in Double(e) }
    }

    static func asDouble<S: Sequence, E: BinaryFloatingPoint>(_ elements: S) -> Self
    where S.Element == E {
        return elements.map { e in Double(e) }
    }

    internal func formatEach(_ format: String) -> [LocalizedStringKey] {
        return map({ (e: Element) -> LocalizedStringKey in
            LocalizedStringKey(String(format: format, e))
        })
    }
}

extension Array where Self.Element == LocalizedStringKey {
    internal subscript(_ index: Int, defaultValue: Element) -> Element {
        if (0..<count).contains(index) {
            return self[index]
        }
        return defaultValue
    }
}
