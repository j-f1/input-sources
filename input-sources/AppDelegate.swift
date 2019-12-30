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
    let hotKey = HotKey(key: .space, modifiers: [.control])
    let menu = NSMenu()
    var justOpened = true
    
    lazy var aboutWC = NSStoryboard.main!.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("AboutWC")) as! TransientWindowController
    lazy var settingsWC = NSStoryboard.main!.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("SettingsWC")) as! TransientWindowController

    @IBAction func showPrefs(_ sender: Any) {
        settingsWC.open()
    }
    @IBAction func showAbout(_ sender: Any) {
        aboutWC.open()
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
                self.settingsWC.showWindow(self)
            }
        }.tieToLifetime(of: self)
    }
    
    func applicationDidBecomeActive(_: Notification) {
        if justOpened {
            justOpened = false
        } else {
            settingsWC.showWindow(self)
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
        let currentId = currentKeyboardLayout.id
        for layout in enabledLayouts {
            let item = NSMenuItem(title: layout.localizedName, action: #selector(selectLayout(_:)), keyEquivalent: "")
            item.state = layout.id == currentId ? .on : .off
            item.representedObject = layout
            menu.addItem(item)
        }

        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Preferences…", action: #selector(showPrefs), keyEquivalent: ","))
        menu.addItem(NSMenuItem(title: "About", action: #selector(showAbout), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate), keyEquivalent: "q"))

        let title = shortNames[currentId] ?? String(currentId.dropFirst(currentId.lastIndex(of: ".")!.utf16Offset(in: currentId) + 1))
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
        (sender.representedObject as! InputSource).activate()
        render()
    }

    func selectNextLayout() {
        let idx = enabledLayouts.firstIndex(of: currentKeyboardLayout)!
        enabledLayouts[(idx + 1) % enabledLayouts.count].activate()
    }
}
