import Foundation
import Carbon

var allLayouts: [InputSource] {
    let keyboards = TISCreateInputSourceList([kTISPropertyInputSourceType: kTISTypeKeyboardLayout] as CFDictionary, false)
    let inputModes = TISCreateInputSourceList([kTISPropertyInputSourceType: kTISTypeKeyboardInputMode] as CFDictionary, false)
    return (
        keyboards?.takeRetainedValue() as? [TISInputSource] ?? []
        + (inputModes?.takeRetainedValue() as? [TISInputSource] ?? [])
    ).map(InputSource.init)
}

var enabledLayouts: [InputSource] { allLayouts.filter { $0.enabled } }
var currentKeyboardLayout: InputSource {
    allLayouts[allLayouts.firstIndex(of: InputSource(source: TISCopyCurrentKeyboardInputSource().takeRetainedValue()))!]
}

struct InputSource: Equatable {
    let source: TISInputSource

    var localizedName: String { self[string: kTISPropertyLocalizedName] }
    var id: ID { self[string: kTISPropertyInputSourceID] }
    var enabled: Bool { self[bool: kTISPropertyInputSourceIsEnabled] }
    
    func activate() {
        TISSelectInputSource(source)
    }
    
    subscript(string key: CFString) -> String {
        let value: CFString = getValue(for: key)
        return value as String
    }
    subscript(bool key: CFString) -> Bool {
        let value: CFNumber = getValue(for: key)
        return (value as NSNumber).boolValue
    }

    // Thanks Martin R! https://stackoverflow.com/a/59522437/5244995
    func getValue<T: AnyObject>(for key: CFString) -> T {
        Unmanaged<T>
            .fromOpaque(TISGetInputSourceProperty(source, key))
            .takeUnretainedValue()
            as T
    }
}
extension InputSource: Identifiable {
    typealias ID = String
}
