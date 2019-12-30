import Cocoa

class TransientWindowController: NSWindowController, NSWindowDelegate {
    func windowDidResignKey(_: Notification) {
        window!.setIsVisible(false)
    }
    func open() {
        NSApp.activate(ignoringOtherApps: true)
        showWindow(self)
        if !window!.isKeyWindow {
            window!.makeKey()
        }
    }
}

