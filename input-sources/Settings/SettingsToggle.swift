//
//  SettingsToggle.swift
//  Input Sources
//
//  Created by Jed Fox on 7/3/20.
//  Copyright © 2020 Jed Fox. All rights reserved.
//

import SwiftUI

struct IdentifiableLine: Identifiable {
    let id: Int
    let line: String
}

func lines(_ text: String) -> [IdentifiableLine] {
    text.split(separator: "\n").enumerated()
        .map { lineThing in
            IdentifiableLine(id: lineThing.offset, line: String(lineThing.element))
    }
}

struct SettingsToggle: View {
    let title: String
    let description: String
    let value: Binding<Bool>
    var body: some View {
        VStack(alignment: .leading) {
            Toggle(title, isOn: value)
            ForEach(lines(description)) { line in
                Text(line.line).preferenceDescription()
            }
        }
    }
}

struct SettingsToggle_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SettingsToggle(
                title: "Title",
                description: "Description",
                value: .constant(true)
            )
            SettingsToggle(
                title: "Title",
                description: "Description",
                value: .constant(false)
            )
        }
    }
}
