//
//  Defaults.swift
//  Input Sources
//
//  Created by Jed Fox on 12/17/19.
//  Copyright © 2019 Jed Fox. All rights reserved.
//

import Defaults

extension Defaults.Keys {
    static let showInDock = Key<Bool>("showInDock", default: false)
    static let showMenuBG = Key<Bool>("showMenuBG", default: true)
    static let clickToCycle = Key<Bool>("clickToCycle", default: false)
//    static let shortcut = Key<String>("shortcut", default: nil)
}
