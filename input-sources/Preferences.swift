import SwiftUI
import Defaults
import LaunchAtLogin
import Preferences

extension PreferencePane.Identifier {
    static let settings = Identifier("settings")
    static let about = Identifier("about")
}

class SettingsViewController: NSViewController, PreferencePane {
    let preferencePaneIdentifier = PreferencePane.Identifier.settings
    let preferencePaneTitle = "Settings"
    let toolbarItemIcon = NSImage(named: NSImage.preferencesGeneralName)!
    override var nibName: NSNib.Name { "SettingsViewController" }

    override func viewDidLoad() {
        super.viewDidLoad()
        set(openAtLoginCheckbox, to: LaunchAtLogin.isEnabled)
        set(showInDockCheckbox, to: Defaults[.showInDock])
        set(showMenuBGCheckbox, to: Defaults[.showMenuBG])
        set(clickToCycleCheckbox, to: Defaults[.clickToCycle])
    }

    func set(_ checkbox: NSButton, to value: Bool) {
        checkbox.state = value ? .on : .off
    }

    func getValue(of checkbox: NSButton) -> Bool {
        checkbox.state == .on
    }

    @IBOutlet var openAtLoginCheckbox: NSButton!
    @IBAction func openAtLoginChanged(_: NSButton) {
        LaunchAtLogin.isEnabled = getValue(of: openAtLoginCheckbox)
    }

    @IBOutlet var showInDockCheckbox: NSButton!
    @IBAction func showInDockChanged(_: NSButton) {
        Defaults[.showInDock] = getValue(of: showInDockCheckbox)
    }

    @IBOutlet var showMenuBGCheckbox: NSButton!
    @IBAction func showMenuBGChanged(_: NSButton) {
        Defaults[.showMenuBG] = getValue(of: showMenuBGCheckbox)
    }

    @IBOutlet var clickToCycleCheckbox: NSButton!
    @IBAction func clickToCycleChanged(_: NSButton) {
        Defaults[.clickToCycle] = getValue(of: clickToCycleCheckbox)
    }
    @IBAction func openKeyboardSettings(_: NSButton) {
        NSWorkspace.shared.openFile("/System/Library/PreferencePanes/Keyboard.prefPane")
    }
    
    @IBOutlet var shortcutField: NSTextField!

    @IBAction func deleteShortcut(_: NSButton) {
    }
}

class ShortcutField: NSTextField {
    override func performKeyEquivalent(with event: NSEvent) -> Bool {
        print(event)
        return true
    }
}

// MARK: -

class AboutViewController: NSHostingController<AboutView>, PreferencePane {
    let preferencePaneIdentifier = PreferencePane.Identifier.about
    let preferencePaneTitle = "About"
    let toolbarItemIcon = NSImage(named: NSImage.infoName)!
}
