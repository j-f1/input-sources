import Foundation
import Carbon

func fetchLayouts() -> [InputSource] {
    let sources = TISCreateInputSourceList([
        kTISPropertyInputSourceCategory: kTISCategoryKeyboardInputSource!,
        kTISPropertyInputSourceIsSelectCapable: true
    ] as CFDictionary, false)
    return (
        sources?.takeRetainedValue() as? [TISInputSource] ?? []
    ).map(InputSource.init)
}

var allLayouts = fetchLayouts()
func updateLayouts() {
    allLayouts = fetchLayouts()
}

var enabledLayouts: [InputSource] { allLayouts.filter { $0.enabled } }
var currentKeyboardLayout: InputSource {
    allLayouts[allLayouts.firstIndex(of: InputSource(source: TISCopyCurrentKeyboardInputSource().takeRetainedValue()))!]
}

struct InputSource: Equatable, Identifiable {
    let source: TISInputSource

    var localizedName: String { self[string: kTISPropertyLocalizedName]! }
    var id: String { self[string: kTISPropertyInputSourceID]! }
    var enabled: Bool { self[bool: kTISPropertyInputSourceIsEnabled]! }
    
    func activate() {
        TISSelectInputSource(source)
    }
    
    subscript(string key: CFString) -> String? {
        let value: CFString? = getValue(for: key)
        return value as String?
    }
    subscript(bool key: CFString) -> Bool? {
        let value: CFNumber? = getValue(for: key)
        return (value as NSNumber?)?.boolValue
    }

    // Thanks Martin R! https://stackoverflow.com/a/59522437/5244995
    func getValue<T: AnyObject>(for key: CFString) -> T? {
        if let ptr = TISGetInputSourceProperty(source, key) {
            return Unmanaged<T>
                .fromOpaque(ptr)
                .takeUnretainedValue()
                as T
        } else {
            print(source, key)
            return nil
        }
    }
}
