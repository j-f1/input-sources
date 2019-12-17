//
//  InputSources.swift
//  Input Sources
//
//  Created by Jed Fox on 12/16/19.
//  Copyright © 2019 Jed Fox. All rights reserved.
//

import Foundation
import Carbon

class InputSource: Identifiable, Equatable {
    typealias ID = String
    static func == (lhs: InputSource, rhs: InputSource) -> Bool {
        lhs.id == rhs.id
    }

    // MARK: - Initializers

    let source: TISInputSource
    init(_ source: TISInputSource) {
        self.source = source
    }

    static var current: InputSource {
        InputSource(TISCopyCurrentKeyboardInputSource().takeRetainedValue())
    }

    class var sources: [InputSource] {
        getSources(with: [kTISPropertyInputSourceType: kTISTypeKeyboardLayout])
            + getSources(with: [kTISPropertyInputSourceType: kTISTypeKeyboardInputMode])
    }

    private static func getSources(with props: [NSString: NSString]) -> [InputSource] {
        let array = TISCreateInputSourceList(props as CFDictionary, false).takeRetainedValue() as! Array<TISInputSource>
        return array.map(InputSource.init)
    }

    // MARK: - Methods

    func activate() throws {
        let status = TISSelectInputSource(source)
        if status != noErr {
            throw NSError(domain: NSOSStatusErrorDomain, code: Int(status))
        }
    }

    // MARK: - Accessors

    var localizedName: String { getString(for: kTISPropertyLocalizedName) }
    var id: String { getString(for: kTISPropertyInputSourceID) }
    var enabled: Bool { getBool(for: kTISPropertyInputSourceIsEnabled) }

    // MARK: - String

    func getString(for property: String) -> String {
        getString(for: property as CFString)
    }

    func getString(for property: CFString) -> String {
        TISGetInputSourceProperty(source, property).load(as: CFString.self) as String
    }

    // MARK: - Bool

    func getBool(for property: String) -> Bool {
        getBool(for: property as CFString)
    }

    func getBool(for property: CFString) -> Bool {
        (TISGetInputSourceProperty(source, property).load(as: CFNumber.self) as NSNumber).boolValue
    }
}
