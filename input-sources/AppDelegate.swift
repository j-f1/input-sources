//
//  AppDelegate.swift
//  Input Sources
//
//  Created by Jed Fox on 12/16/19.
//  Copyright © 2019 Jed Fox. All rights reserved.
//

import Cocoa
import Defaults
import HotKey
import Preferences

let shortNames = [
    "com.apple.keylayout.UnicodeHexInput": "U+",
]

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    let statusItem = NSStatusBar.system.statusItem(withLength: Defaults[.showMenuBG] ? 25 : NSStatusItem.variableLength)
    let kb = WLKeyboardManager.shared()!
    let hotKey = HotKey(key: .space, modifiers: [.control])
    let menu = NSMenu()
    var justOpened = true

    lazy var preferencesWindowController = PreferencesWindowController(
        preferencePanes: [
            SettingsViewController(),
            AboutViewController(rootView: AboutView()),
        ],
        style: .segmentedControl
    )
    @IBAction func showPrefs(_: Any) {
        preferencesWindowController.show()
    }

    func applicationDidFinishLaunching(_: Notification) {
        statusItem.behavior = [.terminationOnRemoval]
        if let btn = statusItem.button {
            btn.imagePosition = .imageOverlaps
            btn.target = self
            btn.action = #selector(onclick)
            btn.sendAction(on: [.rightMouseUp, .leftMouseUp])
        }

        Defaults.observe(.showMenuBG, options: [.initial], handler: { _ in self.render() })
            .tieToLifetime(of: self)
        NotificationCenter.default.addObserver(self, selector: #selector(render), name: NSTextInputContext.keyboardSelectionDidChangeNotification, object: nil)

        hotKey.keyUpHandler = selectNextLayout

        NSApp.setActivationPolicy(Defaults[.showInDock] ? .regular : .accessory)
        Defaults.observe(.showInDock, options: [.old, .new]) { [unowned self] change in
            NSApp.setActivationPolicy(Defaults[.showInDock] ? .regular : .accessory)
            if change.oldValue && !change.newValue {
                self.preferencesWindowController.show()
            }
        }.tieToLifetime(of: self)
    }
    
    func applicationDidBecomeActive(_: Notification) {
        if justOpened {
            justOpened = false
        } else {
            preferencesWindowController.show()
        }
    }

    @objc func onclick() {
        let event = NSApplication.shared.currentEvent!
        if Defaults[.clickToCycle]
            && event.type == .leftMouseUp
            && !event.modifierFlags.contains(.control)
            && !event.modifierFlags.contains(.option) {
            selectNextLayout()
            render()
        } else {
            statusItem.popUpMenu(menu)
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        NotificationCenter.default.removeObserver(self)
    }

    @objc func render() {
        statusItem.length = Defaults[.showMenuBG] ? 25 : NSStatusItem.variableLength
        menu.removeAllItems()
        let current = kb.currentKeyboardLayout()
        for layout in kb.enabledLayouts()! {
            let item = NSMenuItem(title: layout.localizedName!, action: #selector(selectLayout(_:)), keyEquivalent: "")
            item.state = layout.inputSourceID == current?.inputSourceID ? .on : .off
            item.representedObject = layout
            menu.addItem(item)
        }

        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Preferences…", action: #selector(showPrefs), keyEquivalent: ","))
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate), keyEquivalent: "q"))

        let id = current!.inputSourceID!
        let title = shortNames[id] ?? String(id.dropFirst(id.lastIndex(of: ".")!.utf16Offset(in: id) + 1))
        if let btn = statusItem.button {
            if Defaults[.showMenuBG] {
                btn.image = #imageLiteral(resourceName: "AppIconTemplate")
                btn.attributedTitle = NSAttributedString(string: title, attributes: [.font: NSFont.systemFont(ofSize: 8, weight: .semibold)])
            } else {
                btn.image = nil
                btn.title = title
            }
        }
    }

    @objc func selectLayout(_ sender: NSMenuItem) {
        let layout = sender.representedObject as! WLKeyboardSource
        kb.selectLayout(withID: layout.inputSourceID)
        render()
    }

    func selectNextLayout() {
        let currentId = kb.currentKeyboardLayout()!.inputSourceID
        let layouts = kb.enabledLayouts()!
        let idx = layouts.firstIndex { (source) -> Bool in
            source.inputSourceID == currentId
        }!
        let next = layouts[(idx + 1) % layouts.count]
        kb.selectLayout(withID: next.inputSourceID)
    }
}
