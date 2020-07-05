//
//  SettingsWindow.swift
//  Input Sources
//
//  Created by Jed Fox on 7/3/20.
//  Copyright © 2020 Jed Fox. All rights reserved.
//

import SwiftUI
import LaunchAtLogin
import Defaults
import Preferences

func title(_ text: String) -> () -> Text {
    { Text(text).fontWeight(.semibold) }
}

var _launchAtLogin = LaunchAtLogin.isEnabled

struct SettingsView: View {
    var launchAtLogin = Binding(get: { _launchAtLogin }, set: { enabled in
        LaunchAtLogin.isEnabled = enabled
        _launchAtLogin = enabled
    })
    @Default(.showInDock) var showInDock
    @Default(.showMenuBG) var showMenuBG
    @Default(.clickToCycle) var clickToCycle
    var body: some View {
        Preferences.Container(contentWidth: 450.0) {
            Preferences.Section(label: title("Startup")) {
                SettingsToggle(
                    title: "Open Input Sources at Login",
                    description: "Open Input Sources automatically at login.",
                    value: self.launchAtLogin
                )
            }
            Preferences.Section(label: title("Appearance")) {
                SettingsToggle(
                    title: "Show in Dock",
                    description: "Hiding the Input Sources icon from the Dock means you’ll need to quit\nit using its menu in the menu bar.",
                    value: self.$showInDock
                )
                SettingsToggle(
                    title: "Show background in menu bar",
                    description: "By default, the current input method is displayed in a box in the\nmenu bar. You can disable the box here.",
                    value: self.$showMenuBG
                )
                SettingsToggle(
                    title: "Click to cycle inputs",
                    description: "When this is enabled, right-click or option-click the menu bar item\nto open the menu.",
                    value: self.$clickToCycle
                )
                Button("Open Keyboard Settings…", action: { NSWorkspace.shared.openFile("/System/Library/PreferencePanes/Keyboard.prefPane") })
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
