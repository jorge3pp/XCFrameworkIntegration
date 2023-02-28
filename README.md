# XCFrameworkIntegration
There is an issue with the generated dynamic frameworks.

## Steps to reproduce
- Download the repository.
- Go to PackageDepRoot/Sources/PackageDepRoot/PackageDepRoot.swift and set the version number (i.e. 1.0.0). Print the version when called to its main method.
- Use the script $ generateXCFramework.sh -t=PackageDepA to create PackageDepA.xcframework. This version is compiled with the version 1.0.0 of PackageDepRoot.
- Open IntegratorApp.xcodeproj and try to use the dependency PackageDepA.
- If we try to archive the IntegratorApp.xcodeproj an error is shown: "Missing required module 'PackageDepRoot'"
- Go to PackageDepRoot/Sources/PackageDepRoot/PackageDepRoot.swift and change the version number (i.e. 1.1.0)
- Use the script $ generateXCFramework.sh -t=PackageDepRoot to create PackageDepRoot.xcframework.
- Add this PackageDepRoot.xcframework to our IntegratorApp project try to archive. It works.
- Launch the app

### Expected behaviour
It prints the version setted in PackageDepRoot.xcframework (for this case, would be 1.1.0)

### Actual behaviour
PackageDepA.xcframework was compiled using the version of PackageDepRoot 1.0.0, so even if we are importing PackageDepRoot1.1.0.xcframework, it stills prints 1.0.0.
