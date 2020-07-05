import Defaults
import KeyboardShortcuts

extension Defaults.Keys {
    static let showInDock = Key<Bool>("showInDock", default: false)
    static let showMenuBG = Key<Bool>("showMenuBG", default: true)
    static let clickToCycle = Key<Bool>("clickToCycle", default: false)
//    static let shortcut = Key<String>("shortcut", default: nil)
}

extension KeyboardShortcuts.Name {
    static let nextInputSource = Self("nextInputSource", default: .init(.space, modifiers: [.control]))
}
