// CSV Parsing using Java's String.split from Swift
// Demonstrates swift-java-style interop on Android

#if os(Android)
import Android
#endif

/// A simple CSV parser that uses Java's string operations via JNI
/// This is similar to swift-java's JavaCommonsCSV example but uses basic Java APIs
public struct CSVParser {
    private let jniEnv: JNIEnvironment
    
    public init(env: UnsafeMutablePointer<JNIEnv?>) {
        self.jniEnv = JNIEnvironment(env)
    }
    
    /// Parse CSV data into an array of rows, where each row is an array of fields
    /// Uses Java's String.split() method for parsing
    public func parse(_ csvData: String) -> [[String]] {
        var result: [[String]] = []
        
        // Split by newlines first (handle both \n and \r\n)
        let lines = csvData.split(separator: "\n", omittingEmptySubsequences: false)
        
        for line in lines {
            // Trim carriage return if present
            var cleanLine = String(line)
            if cleanLine.hasSuffix("\r") {
                cleanLine.removeLast()
            }
            
            // Skip empty lines
            guard !cleanLine.isEmpty else { continue }
            
            // Parse the row using Swift's split (simple CSV without quoted fields)
            let fields = cleanLine.split(separator: ",", omittingEmptySubsequences: false).map { String($0) }
            result.append(fields)
        }
        
        return result
    }
    
    /// Parse CSV using Java's String.split via JNI
    /// This demonstrates calling Java methods from Swift
    public func parseUsingJava(_ csvData: String) -> [[String]]? {
        #if os(Android)
        var result: [[String]] = []
        
        // Find java.lang.String class
        guard let stringClass = jniEnv.findClass("java/lang/String") else {
            return nil
        }
        
        // Get the split method ID: String[] split(String regex)
        guard let splitMethodID = jniEnv.getMethodID(stringClass, name: "split", signature: "(Ljava/lang/String;)[Ljava/lang/String;") else {
            return nil
        }
        
        // Get the trim method ID: String trim()
        guard let trimMethodID = jniEnv.getMethodID(stringClass, name: "trim", signature: "()Ljava/lang/String;") else {
            return nil
        }
        
        // Create Java string for the CSV data
        guard let javaCSVData = jniEnv.newString(csvData) else {
            return nil
        }
        
        // Create Java string for newline regex
        guard let newlineRegex = jniEnv.newString("\r?\n") else {
            return nil
        }
        
        // Split by newlines
        guard let linesArray = jniEnv.callObjectMethod(javaCSVData, methodID: splitMethodID, args: [.object(newlineRegex)]) else {
            return nil
        }
        
        let lineCount = jniEnv.getArrayLength(linesArray)
        
        // Create comma regex for field splitting
        guard let commaRegex = jniEnv.newString(",") else {
            return nil
        }
        
        for i in 0..<lineCount {
            guard let lineObj = jniEnv.getObjectArrayElement(linesArray, index: i) else {
                continue
            }
            
            // Trim the line
            guard let trimmedLine = jniEnv.callObjectMethod(lineObj, methodID: trimMethodID) else {
                continue
            }
            
            // Get the trimmed line as Swift string to check if empty
            guard let lineStr = jniEnv.getStringUTFChars(trimmedLine), !lineStr.isEmpty else {
                continue
            }
            
            // Split by comma
            guard let fieldsArray = jniEnv.callObjectMethod(trimmedLine, methodID: splitMethodID, args: [.object(commaRegex)]) else {
                continue
            }
            
            let fieldCount = jniEnv.getArrayLength(fieldsArray)
            var row: [String] = []
            
            for j in 0..<fieldCount {
                if let fieldObj = jniEnv.getObjectArrayElement(fieldsArray, index: j),
                   let fieldStr = jniEnv.getStringUTFChars(fieldObj) {
                    row.append(fieldStr)
                }
            }
            
            result.append(row)
        }
        
        return result
        #else
        return nil
        #endif
    }
    
    /// Format parsed CSV data as a readable string
    public static func formatAsTable(_ rows: [[String]]) -> String {
        guard !rows.isEmpty else { return "No data" }
        
        var output = ""
        for (rowIndex, row) in rows.enumerated() {
            if rowIndex == 0 {
                // Header row
                output += "📊 Headers: \(row.joined(separator: " | "))\n"
                output += String(repeating: "─", count: 40) + "\n"
            } else {
                // Data row
                output += "Row \(rowIndex): \(row.joined(separator: " | "))\n"
            }
        }
        return output
    }
}

// MARK: - JNI Export Functions

/// JNI function to parse CSV data and return formatted result
@_cdecl("Java_com_example_swiftandroid_SwiftBridge_parseCSV")
public func parseCSV(
    env: UnsafeMutablePointer<JNIEnv?>?,
    thisObj: jobject?,
    csvDataJava: jstring?
) -> jstring? {
    guard let env = env else { return nil }
    
    let jniEnv = JNIEnvironment(env)
    
    // Convert Java string to Swift string
    guard let csvDataJava = csvDataJava,
          let csvData = jniEnv.getStringUTFChars(csvDataJava) else {
        return jniEnv.newString("Error: No CSV data provided")
    }
    
    // Parse CSV (using Swift implementation for simplicity)
    let parser = CSVParser(env: env)
    let rows = parser.parse(csvData)
    
    // Format result
    let formatted = CSVParser.formatAsTable(rows)
    
    return jniEnv.newString(formatted)
}

/// JNI function to parse CSV using Java's String.split (demonstrates Java interop)
@_cdecl("Java_com_example_swiftandroid_SwiftBridge_parseCSVWithJava")
public func parseCSVWithJava(
    env: UnsafeMutablePointer<JNIEnv?>?,
    thisObj: jobject?,
    csvDataJava: jstring?
) -> jstring? {
    guard let env = env else { return nil }
    
    let jniEnv = JNIEnvironment(env)
    
    // Convert Java string to Swift string
    guard let csvDataJava = csvDataJava,
          let csvData = jniEnv.getStringUTFChars(csvDataJava) else {
        return jniEnv.newString("Error: No CSV data provided")
    }
    
    // Parse CSV using Java's String.split
    let parser = CSVParser(env: env)
    if let rows = parser.parseUsingJava(csvData) {
        let formatted = CSVParser.formatAsTable(rows)
        return jniEnv.newString("🔧 Parsed using Java String.split:\n" + formatted)
    } else {
        // Fall back to Swift implementation
        let rows = parser.parse(csvData)
        let formatted = CSVParser.formatAsTable(rows)
        return jniEnv.newString("🦅 Parsed using Swift:\n" + formatted)
    }
}

/// JNI function to demonstrate getting system information via Java
@_cdecl("Java_com_example_swiftandroid_SwiftBridge_getSystemInfo")
public func getSystemInfo(
    env: UnsafeMutablePointer<JNIEnv?>?,
    thisObj: jobject?
) -> jstring? {
    guard let env = env else { return nil }
    
    let jniEnv = JNIEnvironment(env)
    
    #if os(Android)
    // Get java.lang.System class
    guard let systemClass = jniEnv.findClass("java/lang/System") else {
        return jniEnv.newString("Could not find System class")
    }
    
    // Get getProperty method ID
    guard let getPropertyMethodID = jniEnv.getStaticMethodID(systemClass, name: "getProperty", signature: "(Ljava/lang/String;)Ljava/lang/String;") else {
        return jniEnv.newString("Could not find getProperty method")
    }
    
    var info = "📱 System Information (via Java from Swift):\n"
    info += String(repeating: "─", count: 40) + "\n"
    
    // Get various system properties
    let properties = [
        ("java.version", "Java Version"),
        ("os.name", "OS Name"),
        ("os.arch", "Architecture"),
        ("os.version", "OS Version"),
        ("java.vm.name", "VM Name"),
        ("java.vm.version", "VM Version")
    ]
    
    for (propName, displayName) in properties {
        if let propNameJava = jniEnv.newString(propName),
           let valueJava = jniEnv.callStaticObjectMethod(systemClass, methodID: getPropertyMethodID, args: [.object(propNameJava)]),
           let value = jniEnv.getStringUTFChars(valueJava) {
            info += "\(displayName): \(value)\n"
        }
    }
    
    return jniEnv.newString(info)
    #else
    return jniEnv.newString("System info only available on Android")
    #endif
}
