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
    allLayouts[allLayouts.firstIndex(of: InputSource(source: TISCopyCurrentKeyboardInputSource().takeUnretainedValue()))!]
}

struct InputSource: Equatable {
    let source: TISInputSource

    var localizedName: String { getStringProp(source, kTISPropertyLocalizedName) }
    var id: ID { getStringProp(source, kTISPropertyInputSourceID) }
    var enabled: Bool { getBoolProp(source, kTISPropertyInputSourceIsEnabled) }
    
    func activate() {
        TISSelectInputSource(source)
    }
}
extension InputSource: Identifiable {
    typealias ID = String
}
