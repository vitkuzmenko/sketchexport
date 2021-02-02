//
//  AssetItem.swift
//  SketchExport
//
//  Created by Vitaliy Kuzmenko on 11/09/2019.
//  Copyright © 2019 Faceter. All rights reserved.
//

import Foundation

struct AssetItem {
    
    let slice: Slice
    
    let name: String
    
    let appearance: Appearance
    
    let fileName: String
    
    init(slice: Slice) {
        self.slice = slice
        self.name = slice.name.assetFinalName
        self.appearance = slice.name.assetAppearance
        self.fileName = self.name.assetFileName(for: self.appearance)
    }

}

extension AssetItem: Encodable {
    
    enum CodingKeys: String, CodingKey {
        case idiom, filename, scale, appearances
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode("universal", forKey: .idiom)
        try container.encode(fileName, forKey: .filename)
        try container.encode("1x", forKey: .scale)
        if appearance == .dark {
            try container.encode([appearance], forKey: .appearances)
        }
    }
    
}

extension String {

    fileprivate var assetFinalName: String {
        return components(separatedBy: "~")[0]
    }
    
    fileprivate var assetAppearance: Appearance {
        let nameComponents = components(separatedBy: "~")
        switch nameComponents.count {
        case 2:
            return nameComponents[1] == "dark" ? .dark : .light
        default:
            return .light
        }
    }
    
    fileprivate func assetFileName(for appearance: Appearance) -> String {
        switch appearance {
        case .light:
            return String(format: "%@.pdf", self)
        case .dark:
            return String(format: "%@.dark.pdf", self)
        default:
            fatalError()
        }
    }
    
}

extension Sequence where Element == AssetItem {
    
    func contains(slice: Slice) -> Bool {
        return self.contains(where: { item -> Bool in
            return item.slice == slice
        })
    }
    
    func containsGroup(slice: Slice) -> Bool {
        return self.contains(where: { item -> Bool in
            return item.name == slice.name.components(separatedBy: "~")[0]
        })
    }
    
}
