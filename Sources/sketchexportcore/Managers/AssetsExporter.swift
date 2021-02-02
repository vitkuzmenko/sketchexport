//
//  AssetsExporter.swift
//  SketchExport
//
//  Created by Vitaliy Kuzmenko on 11/09/2019.
//  Copyright © 2019 Faceter. All rights reserved.
//

import Foundation

enum AssetsExporterError {
    case fileExporting
}

extension AssetsExporterError: LocalizedError {
    
    var errorDescription: String? {
        switch self {
        case .fileExporting:
            return String(format: "sketchtool exporting error. see log above")
        }
    }
    
}

class AssetsExporter {
    
    let sketchtoolExecutable: String
    
    let input: String
    
    let assets: [Asset]
    
    let rootFolder: String
    
    private let fm = FileManager.default
    
    private let pipe = Pipe()
    
    init(sketchtoolExecutable: String, input: String, assets: [Asset], rootFolder: String) {
        self.sketchtoolExecutable = sketchtoolExecutable
        self.input = input
        self.assets = assets
        self.rootFolder = rootFolder
    }
    
    func export() throws {
        
        var pages: Set<Page> = []
        
        for asset in assets {
            if !pages.contains(asset.page) {
                pages.insert(asset.page)
            }
        }
        
        do {
        
            for page in pages {
                let path = getPath(for: page)
                try removeItem(at: path)
            }
            
            for asset in assets {
                
                let relativePath = getPath(for: asset)
                try checkDirectory(at: relativePath)
                
                let contentsJSONPath = getContentsJSONPath(relative: relativePath)
                try writeContentsJSON(for: asset, at: contentsJSONPath)
                
                for assetItem in asset.items {
                    let filePath = getFilePath(for: assetItem, relative: relativePath)
                    try writeFile(for: assetItem, at: filePath, relativePath: relativePath)
                }
            
            }
        } catch {
            throw error
        }
    }
    
    // MARK: - Paths
    
    private func getPath(for page: Page) -> String {
        return String(format: "%@/%@", rootFolder, page.name)
    }
    
    private func getPath(for asset: Asset) -> String {
        return String(format: "%@/%@/%@.imageset", rootFolder, asset.page.name, asset.name)
    }
    
    private func getContentsJSONPath(relative: String) -> String {
        return String(format: "%@/Contents.json", relative)
    }
    
    private func getFilePath(for assetItem: AssetItem, relative: String) -> String {
        return String(format: "%@/%@", relative, assetItem.fileName)
    }
    
    // MARK: - Deleters
    
    private func removeItem(at path: String) throws {
        var isDir : ObjCBool = false
        if fm.fileExists(atPath: path, isDirectory: &isDir) {
            do {
                if isDir.boolValue {
                    let contents = try fm.contentsOfDirectory(atPath: path)
                    try contents.forEach { itemToDelete in
                        try removeItem(at: String(format: "%@/%@", path, itemToDelete))
                    }
                } else {
                    try fm.removeItem(atPath: path)
                }
            } catch {
                throw error
            }
        }
    }
    
    // MARK: - Writers
    
    private func checkDirectory(at path: String) throws {
        if !fm.fileExists(atPath: path) {
            do {
                try fm.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
            } catch {
                throw error
            }
        }
    }
    
    private func writeContentsJSON(for asset: Asset, at path: String) throws {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(asset)
            let url = URL(fileURLWithPath: path)
            try data.write(to: url)
            print("write Contents.json to \(path)")
        } catch {
            throw error
        }
    }
    
    private func writeFile(for assetItem: AssetItem, at path: String, relativePath: String) throws {
        print("write AssetItem to \(path)")
        let process = getExportSlicesProcess(for: assetItem, at: relativePath)
        process.launch()
        process.waitUntilExit()
        
        if process.terminationStatus == 1 {
            throw AssetsExporterError.fileExporting
        }

        let originalPath = String(format: "%@/%@.pdf", relativePath, assetItem.slice.name)
    
        do {
            try fm.moveItem(atPath: originalPath, toPath: path)
        } catch {
            throw error
        }
        
    }
    
    private func getExportSlicesProcess(for assetItem: AssetItem, at relativePath: String) -> Process {
        let process = Process()
        process.launchPath = "/usr/bin/env"
        process.arguments = [sketchtoolExecutable, "export", "slices", input, "--item=" + assetItem.slice.id, "--output=" + relativePath]
        return process
    }
    
}
