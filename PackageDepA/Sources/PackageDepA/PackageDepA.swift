import PackageDepRoot

public struct PackageDepA {
    public var version = "1.0.0"
    
    public init() {
        print("PackageDepA \(version)")
        PackageDepRoot()
    }
}
