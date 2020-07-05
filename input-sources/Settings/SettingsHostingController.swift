//
//  SettingsHostingController.swift
//  Input Sources
//
//  Created by Jed Fox on 7/3/20.
//  Copyright © 2020 Jed Fox. All rights reserved.
//

import SwiftUI

class SettingsHostingController: NSHostingController<SettingsView> {
    required init?(coder: NSCoder) {
        super.init(coder: coder, rootView: SettingsView())
    }
}
