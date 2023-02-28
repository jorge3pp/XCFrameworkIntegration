# XCFrameworkIntegration
There is an issue with the generated dynamic frameworks.
- We can't embed a framework inside another because it is forbidden by Apple and they report an error when trying to upload an app with this structure to Testflight.
- While the framework is not embedded inside the dependency, seems like the source code is present inside it. Because of that, it doesn't matter if we are importing and using a dependency in X version, as it will execute the code of the version used to compile our dependency.
- If we don't embed it nor import later the framework inside the app that integrates our dependencies, an error is shown when trying to archive as it "Missing required module". For that reason, we need to add the dependency while knowing that our program won't use it.

## Steps to reproduce
1. Download the repository.
2. Go to PackageDepRoot/Sources/PackageDepRoot/PackageDepRoot.swift and set the version number (i.e. 1.0.0). Print the version when called to its main method.
3. Use the script $ generateXCFramework.sh -t=PackageDepA to create PackageDepA.xcframework. This version is compiled with the version 1.0.0 of PackageDepRoot.
4. Open IntegratorApp.xcodeproj and try to use the dependency PackageDepA.
5. If we try to archive the IntegratorApp.xcodeproj an error is shown: "Missing required module 'PackageDepRoot'"
6. Go to PackageDepRoot/Sources/PackageDepRoot/PackageDepRoot.swift and change the version number (i.e. 1.1.0)
7. Use the script $ generateXCFramework.sh -t=PackageDepRoot to create PackageDepRoot.xcframework.
8. Add this PackageDepRoot.xcframework to our IntegratorApp project try to archive. It works.
9. Launch the app

### Expected behaviour
It prints the version setted in PackageDepRoot.xcframework (for this case, would be 1.1.0)

### Actual behaviour
PackageDepA.xcframework was compiled using the version of PackageDepRoot 1.0.0, so even if we are importing PackageDepRoot1.1.0.xcframework, it stills prints 1.0.0.
