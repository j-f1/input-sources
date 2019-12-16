//
//  AppDelegate.swift
//  Input Sources
//
//  Created by Jed Fox on 12/16/19.
//  Copyright © 2019 Jed Fox. All rights reserved.
//

import Cocoa
import HotKey

let shortNames = [
    "com.apple.keylayout.UnicodeHexInput": "U+",
]

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    let statusItem = NSStatusBar.system.statusItem(withLength: 25)
    let kb = WLKeyboardManager.shared()!
    let hotKey = HotKey(key: .space, modifiers: [.control])

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        if let btn = statusItem.button {
            btn.image = #imageLiteral(resourceName: "AppIconTemplate")
            btn.imagePosition = .imageOverlaps
        }
        render()
        NotificationCenter.default.addObserver(self, selector: #selector(render), name: NSTextInputContext.keyboardSelectionDidChangeNotification, object: nil)

        hotKey.keyUpHandler = {
            let currentId = self.kb.currentKeyboardLayout()!.inputSourceID
            let layouts = self.kb.enabledLayouts()!
            let idx = layouts.firstIndex { (source) -> Bool in
                source.inputSourceID == currentId
            }!
            let next = layouts[(idx + 1) % layouts.count]
            self.kb.selectLayout(withID: next.inputSourceID)
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        NotificationCenter.default.removeObserver(self)
    }

    @objc func render() {
        let menu = statusItem.menu ?? NSMenu()
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

        statusItem.menu = menu

        let id = current!.inputSourceID!
        let title = shortNames[id] ?? String(id.dropFirst(id.lastIndex(of: ".")!.utf16Offset(in: id) + 1))
        statusItem.button!.attributedTitle = NSAttributedString(string: title, attributes: [.font: NSFont.systemFont(ofSize: 8, weight: .semibold)])
    }

    @objc func selectLayout(_ sender: NSMenuItem) {
        let layout = sender.representedObject as! WLKeyboardSource
        kb.selectLayout(withID: layout.inputSourceID)
        render()
    }
}
