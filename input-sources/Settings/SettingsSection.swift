//
//  SettingsSection.swift
//  Input Sources
//
//  Created by Jed Fox on 7/3/20.
//  Copyright © 2020 Jed Fox. All rights reserved.
//

import SwiftUI

struct SettingsSection<Content>: View where Content: View {
    let title: String
    let content: Content
    init(_ title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .bold()
                .frame(width: 80, alignment: .topTrailing)
            VStack(alignment: .leading, spacing: 16) {
                content
            }
        }
    }
}


struct SettingsSection_Previews: PreviewProvider {
    static var previews: some View {
        SettingsSection("Section") {
            Text("test")
        }
    }
}
