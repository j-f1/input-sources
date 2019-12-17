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
import LaunchAtLogin
import Defaults

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
    
    func set(_ checkbox: NSButton, to value: Bool) -> Void {
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
