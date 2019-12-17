//
//  PreferencesViewControllers.swift
//  Input Sources
//
//  Created by Jed Fox on 12/16/19.
//  Copyright © 2019 Jed Fox. All rights reserved.
//

import AppKit
import Foundation
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

    @IBOutlet var openAtLoginCheckbox: NSButton!
    @IBAction func openAtLoginChanged(_: NSButton) {
    }

    @IBOutlet var showInDockCheckbox: NSButton!
    @IBAction func showInDockChanged(_: NSButton) {
    }

    @IBOutlet var showMenuBGCheckbox: NSButton!
    @IBAction func showMenuBGChanged(_: NSButton) {
    }

    @IBOutlet var clickToCycleCheckbox: NSButton!
    @IBAction func clickToCycleChanged(_: NSButton) {
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

class AboutViewController: NSViewController, PreferencePane {
    let preferencePaneIdentifier = PreferencePane.Identifier.about
    let preferencePaneTitle = "About"
    let toolbarItemIcon = NSImage(named: NSImage.infoName)!
    override var nibName: NSNib.Name { "AboutViewController" }

    @IBOutlet var appNameField: NSTextField!
    @IBOutlet var versionField: NSTextField!
    @IBOutlet var copyrightField: NSTextField!
    override func viewDidLoad() {
        appNameField.stringValue = getString(for: "CFBundleName")
        versionField.stringValue = "Version \(getString(for: "CFBundleShortVersionString")) (\(getString(for: "CFBundleVersion")))"
        copyrightField.stringValue = getString(for: "NSHumanReadableCopyright")
    }

    func getString(for key: String) -> String {
        Bundle.main.object(forInfoDictionaryKey: key) as! String
    }
}
