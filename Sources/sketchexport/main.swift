import sketchexportcore

let tool = CommandLineTool()

do {
    try tool.run()
} catch {
    print("Sketch Export! An error occurred: \(error)")
}
