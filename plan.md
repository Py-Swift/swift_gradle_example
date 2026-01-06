


# Phase 1 Gradle + Swift app setup

create a gradle + swift setup for swift + android app that can run a basic app where it shows text like here 
https://developer.android.com/codelabs/basic-android-kotlin-compose-first-app#0

but text is provided by swift.

https://www.swift.org/blog/nightly-swift-sdk-for-android/


# Phase 2 Swift-Java support

implement some swift-java stuff into the app 
like the CSV part in samples 

https://github.com/swiftlang/swift-java

https://github.com/swiftlang/swift-java/tree/main/Samples

https://github.com/swiftlang/swift-java/tree/101337b68d2564c9d665fbee56e32c4c0863f251/Samples/JavaDependencySampleApp/Sources/JavaCommonsCSV



# Phase 3 build and implement CPython / PySwiftKit

* figure out how to build python 3.13 for android and implement it in the CPython Package
* https://github.com/Py-Swift/CPython just clone it and modify to what is required for linking with the Android Python Build, all python runtime / launching will be done through that / PySwiftKit
* so no need for Java to fool with Python api, just important that it launches the swift runtime / swift library startup

https://github.com/Py-Swift/PySwiftKit

