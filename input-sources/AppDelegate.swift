import Cocoa
import Defaults
import KeyboardShortcuts

let shortNames = (try? String(contentsOf: Bundle.main.url(forResource: "codes", withExtension: "plist")!).propertyList() as? [String: String])

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    let statusItem = NSStatusBar.system.statusItem(withLength: Defaults[.showMenuBG] ? 25 : NSStatusItem.variableLength)
    let menu = NSMenu()
    var lastActivation = Date()
    
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
            btn.action = #selector(onMouse)
            btn.sendAction(on: [.rightMouseUp, .leftMouseUp, .rightMouseDown, .leftMouseDown])
        }

        Defaults.observe(.showMenuBG, options: [.initial], handler: { _ in self.render() })
            .tieToLifetime(of: self)
        NotificationCenter.default.addObserver(self, selector: #selector(render), name: NSTextInputContext.keyboardSelectionDidChangeNotification, object: nil)

        KeyboardShortcuts.onKeyUp(for: .nextInputSource, action: selectNextLayout)

        NSApp.setActivationPolicy(Defaults[.showInDock] ? .regular : .accessory)
        Defaults.observe(.showInDock) { [unowned self] change in
            NSApp.setActivationPolicy(Defaults[.showInDock] ? .regular : .accessory)
            if change.oldValue && !change.newValue {
                self.settingsWC.open()
            }
        }.tieToLifetime(of: self)
    }
    
    @objc func onMouse() {
        updateLayouts()
        render()
        let event = NSApplication.shared.currentEvent!
        let override =
            event.modifierFlags.contains(.control) ||
            event.modifierFlags.contains(.option) ||
            event.type == .rightMouseDown ||
            event.type == .rightMouseUp
        let shouldCycle = Defaults[.clickToCycle] ? !override : override
            
        if shouldCycle && (event.type == .leftMouseUp || event.type == .rightMouseUp) {
            selectNextLayout()
            render()
        } else if !shouldCycle {
            statusItem.popUpMenu(menu)
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        NotificationCenter.default.removeObserver(self)
    }

    @objc func render() {
        updateLayouts()
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
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "About", action: #selector(showAbout), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Send Feedback…", action: #selector(sendFeedback), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit Input Sources", action: #selector(NSApplication.terminate), keyEquivalent: "q"))

        let name = String(currentId.dropFirst(currentId.lastIndex(of: ".")!.utf16Offset(in: currentId) + 1))
//        print(name, shortNames!)
        let title = shortNames![name] ?? name
        if let btn = statusItem.button {
            if Defaults[.showMenuBG] {
                btn.image = #imageLiteral(resourceName: "AppIconTemplate")
                let size: CGFloat = title.count == 1 ? 13 : 8
                btn.attributedTitle = NSAttributedString(string: title, attributes: [.font: NSFont.systemFont(ofSize: size, weight: .semibold)])
            } else {
                btn.image = nil
                btn.title = title
            }
        }
    }
    
    @objc func sendFeedback(_ sender: NSMenuItem) {
        NSWorkspace.shared.open(URL(string: "https://github.com/j-f1/input-sources/issues/new")!)
    }

    @objc func selectLayout(_ sender: NSMenuItem) {
        (sender.representedObject as! InputSource).activate()
        render()
    }

    func selectNextLayout() {
        let idx = enabledLayouts.firstIndex(of: currentKeyboardLayout)!
        if !Defaults[.easyReset] || idx == 0 || lastActivation.distance(to: Date()) < 2 {
            enabledLayouts[(idx + 1) % enabledLayouts.count].activate()
        } else {
            enabledLayouts.first?.activate()
        }
        lastActivation = Date()
    }
}
