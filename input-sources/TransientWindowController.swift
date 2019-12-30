import Cocoa

class TransientWindowController: NSWindowController, NSWindowDelegate {
    override func windowDidLoad() {
        window?.center()
    }
    func open() {
        NSApp.activate(ignoringOtherApps: true)
        self.showWindow(nil)
        if !window!.isKeyWindow {
            window!.makeKey()
        }
    }
}

