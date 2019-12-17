//
//  AppDelegate.swift
//  Input Sources
//
//  Created by Jed Fox on 12/16/19.
//  Copyright © 2019 Jed Fox. All rights reserved.
//

import Cocoa
import HotKey
import Preferences

let shortNames = [
    "com.apple.keylayout.UnicodeHexInput": "U+",
]

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    let statusItem = NSStatusBar.system.statusItem(withLength: 25)
    let kb = WLKeyboardManager.shared()!
    let hotKey = HotKey(key: .space, modifiers: [.control])
    let menu = NSMenu()

    lazy var preferencesWindowController = PreferencesWindowController(
        preferencePanes: [
            SettingsViewController(),
            AboutViewController()
        ]
    )
    @IBAction func showPrefs(_: Any) {
        preferencesWindowController.show()
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        statusItem.behavior = [.terminationOnRemoval]
        if let btn = statusItem.button {
            btn.image = #imageLiteral(resourceName: "AppIconTemplate")
            btn.imagePosition = .imageOverlaps
            btn.target = self
            btn.action = #selector(onclick)
            btn.sendAction(on: [.rightMouseUp, .leftMouseUp])
        }

        render()
        NotificationCenter.default.addObserver(self, selector: #selector(render), name: NSTextInputContext.keyboardSelectionDidChangeNotification, object: nil)

        hotKey.keyUpHandler = selectNextLayout
    }

    @objc func onclick() {
        let event = NSApplication.shared.currentEvent!
        if event.type == .leftMouseUp && !event.modifierFlags.contains(.control) && !event.modifierFlags.contains(.option) {
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
        menu.removeAllItems()
        let current = kb.currentKeyboardLayout()
        for layout in kb.enabledLayouts()! {
            let item = NSMenuItem(title: layout.localizedName!, action: #selector(selectLayout(_:)), keyEquivalent: "")
            item.state = layout.inputSourceID == current?.inputSourceID ? .on : .off
            item.representedObject = layout
            menu.addItem(item)
        }

        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))

        let id = current!.inputSourceID!
        let title = shortNames[id] ?? String(id.dropFirst(id.lastIndex(of: ".")!.utf16Offset(in: id) + 1))
        statusItem.button!.attributedTitle = NSAttributedString(string: title, attributes: [.font: NSFont.systemFont(ofSize: 8, weight: .semibold)])
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
