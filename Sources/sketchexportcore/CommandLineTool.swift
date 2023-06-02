import Foundation

public final class CommandLineTool {
    
    private let fm = FileManager.default
    
    private let sketchtoolExecutable: String
    
    private let sketchFile: String
    
    private let assetsFile: String
    
    public init(arguments: [String] = CommandLine.arguments) {
        sketchtoolExecutable = arguments[1]
        sketchFile = arguments[2]
        assetsFile = arguments[3]
    }
    
    public func run() throws {
        let timestamp = TimestampDiffer(input: sketchFile, rootFolder: assetsFile)

        if try !timestamp.shouldExport() {
            print("Sketch File not modified. Skipping exporting.")
            exit(0)
        }
        
        let start = Date()
        
        let inspector = SlicesInspector(sketchtoolExecutable: sketchtoolExecutable, input: sketchFile)
        let output = try inspector.read()
        
        let assetsGrouper = AssetsGrouper(output: output)
        let assets = try assetsGrouper.getAssets()
        
        let assetsExporter = AssetsExporter(sketchtoolExecutable: sketchtoolExecutable, input: sketchFile, assets: assets, rootFolder: assetsFile)
        try assetsExporter.export()
        
        try timestamp.writeCurrentTimestamp()
        
        let diff = Date().timeIntervalSince(start)
        
        print("Export Completed in", diff)
    }
    
}
