//
//  AssetsGrouper.swift
//  SketchExport
//
//  Created by Vitaliy Kuzmenko on 11/09/2019.
//  Copyright © 2019 Faceter. All rights reserved.
//

import Foundation

extension String {
    
    fileprivate static let forbiddenSymbols = "\"\\/?<>:*| "
    
}


extension CharacterSet {
    
    fileprivate static let forbiddenCharacterSet = CharacterSet(charactersIn: .forbiddenSymbols)
    
}


enum AssetsGrouperError: Error {
    case containsSimilarNameAndAppearance(String)
    case containsForbiddenCharactersInPage(String)
    case containsForbiddenCharactersInSlice(String)
}

extension AssetsGrouperError: LocalizedError {

    var errorDescription: String? {
        switch self {
        case .containsSimilarNameAndAppearance(let name):
            return String(format: "Sketch file contains slices with similar name \"%@\"", name)
        case .containsForbiddenCharactersInPage(let page):
            return String(format: "Sketch file contains invalid character in page named \"%@\". Forbidden Characters: %@ and space", page, String.forbiddenSymbols)
        case .containsForbiddenCharactersInSlice(let name):
            return String(format: "Sketch file contains invalid character in slice named \"%@\". Forbidden Characters: %@ and space", name, String.forbiddenSymbols)
        }
    }

}

class AssetsGrouper {
    
    let output: Output
    
    init(output: Output) {
        self.output = output
    }
    
    func getAssets() throws -> [Asset] {
        var assets: [Asset] = []
        for page in output.pages {
            
            if page.name.rangeOfCharacter(from: .forbiddenCharacterSet) != nil {
                throw AssetsGrouperError.containsForbiddenCharactersInPage(page.name)
            }
            
            for slice in page.slices {
                if slice.name.rangeOfCharacter(from: .forbiddenCharacterSet) != nil {
                    throw AssetsGrouperError.containsForbiddenCharactersInSlice(slice.name)
                } else if assets.contains(where: { $0.items.contains(slice: slice) }) {
                    throw AssetsGrouperError.containsSimilarNameAndAppearance(slice.name)
                } else if let asset = assets.first(where: { $0.items.containsGroup(slice: slice) }) {
                    let assetItem = AssetItem(slice: slice)
                    asset.items.append(assetItem)
                } else {
                    let asset = Asset(page: page, slice: slice)
                    assets.append(asset)
                }
            }
        }
        return assets
    }
    
}
