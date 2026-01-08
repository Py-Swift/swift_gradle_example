//
//  PyJavaCSV.swift
//  SwiftAndroidLib
//
//  Created by CodeBuilder on 08/01/2026.
//

import PySwiftKit
import PySerializing
import PySwiftWrapper

import JavaCSV
import SwiftJava
import JavaIO
import JavaUtil

/// Global cached JNI environment for use by Python-called Swift code
/// This must be set by Kotlin before Python runs
public nonisolated(unsafe) var cachedJNIEnv: UnsafeMutablePointer<JNIEnv?>? = nil

public func parseCSVWithJava(_ csvData: String) throws -> String {

    guard let env = cachedJNIEnv else {
            return "Error: JNI environment not initialized. Call initializePython from Kotlin first."
        }
    let environment = JNIEnvironment(env)

    // Get the CSVFormat class and use RFC4180 format
    let csvFormatClass = try JavaClass<CSVFormat>(environment: environment)
    guard let format = csvFormatClass.RFC4180 else {
        return "Error: Could not get RFC4180 format"
    }
    
    // Create a StringReader from the CSV data
    let reader = StringReader(csvData, environment: environment)
    
    // Parse the CSV using the Java library
    guard let parser = try format.parse(reader) else {
        return "Error: Could not create parser"
    }
    guard let records = parser.getRecords() else {
        return "Error: Could not get records"
    }
    
    var result = "📊 CSV Parsed by Java (Apache Commons CSV):\n"
    result += String(repeating: "─", count: 45) + "\n"
    
    var rowIndex = 0
    for record in records {
        guard let fields = record.toList() else { continue }
        
        if rowIndex == 0 {
            result += "Headers: "
        } else {
            result += "Row \(rowIndex): "
        }
        
        var fieldStrings: [String] = []
        for field in fields {
            fieldStrings.append("\(field)")
        }
        result += fieldStrings.joined(separator: " | ")
        result += "\n"
        
        if rowIndex == 0 {
            result += String(repeating: "─", count: 45) + "\n"
        }
        rowIndex += 1
    }
    
    return result
}

public func __parseCSVWithJava(_ csvData: String) throws {

    guard let env = cachedJNIEnv else {
            return //"Error: JNI environment not initialized. Call initializePython from Kotlin first."
        }
    let environment = JNIEnvironment(env)

    // Get the CSVFormat class and use RFC4180 format
    let csvFormatClass = try JavaClass<CSVFormat>(environment: environment)
    guard let format = csvFormatClass.RFC4180 else {
        return //"Error: Could not get RFC4180 format"
    }
    
    // Create a StringReader from the CSV data
    let reader = StringReader(csvData, environment: environment)
    
    // Parse the CSV using the Java library
    guard let parser = try format.parse(reader) else {
        return //"Error: Could not create parser"
    }
    guard let records = parser.getRecords() else {
        return //"Error: Could not get records"
    }
}

@PyClass
class PyJavaCSV {
    
    @PyMethod
    static func readCSV(_ csvData: String) throws -> String {

        return try parseCSVWithJava(csvData)
    }

    @PyMethod
    static func __readCSV(_ csvData: String) throws {

        try __parseCSVWithJava(csvData)
    }

    @PyMethod
    static func joinList(_ data: [String]) throws -> String {
        guard let env = cachedJNIEnv else {
            return "Error: JNI environment not initialized"
        }
        let environment = JNIEnvironment(env)
        
        let java_data = data.map { JavaString($0, environment: environment) }
        // 1. Convert Swift array to Java ArrayList
        let arrayList = ArrayList<JavaString>(environment: environment)
        
        // Add each Swift string to Java ArrayList
        for str in java_data {
            _ = arrayList.add(str.as(JavaObject.self))
        }
        
            // 2. Use Java's String.join(delimiter, collection) 
            let stringClass = try JavaClass<JavaString>(environment: environment)
            let charSeqArray: [CharSequence?] = java_data.map { CharSequence(javaHolder: $0.javaHolder) }
            let result = stringClass.join(CharSequence(javaHolder: JavaString(", ", environment: environment).javaHolder), charSeqArray)
            
        // 3. Return the joined string back to Swift
        return result
    }
}


@PyModule
public struct PyJavaCSVModule: PyModuleProtocol {
    public static var py_classes: [any (PyClassProtocol & AnyObject).Type] = [
        PyJavaCSV.self
    ]
}
