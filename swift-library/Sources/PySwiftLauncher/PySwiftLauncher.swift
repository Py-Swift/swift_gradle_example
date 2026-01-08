//
//  PySwiftLauncher.swift
//  SwiftAndroidLib
//
//  A simplified Python launcher without Kivy/SDL dependencies.
//  Inherits from PythonLauncher's PyLauncherIsolated protocol.
//

import Foundation
import PythonLauncher
import PySwiftKit
import PySerializing

#if canImport(UIKit)
import UIKit
#endif

#if os(Android)
import Android
#elseif os(Linux)
import Glibc
#else
import Darwin
#endif


/// A Python launcher for running Python code directly from Swift.
/// Unlike KivyLauncher, this does not require SDL or any graphical framework.
public final class PySwiftLauncher: PyLauncherIsolated {
    
    public static var pyswiftImports: [PySwiftModuleImport] = [
        .init(name: "py_java_csv", module: PyJavaCSVModule.py_init)
    ]
    
    public static let shared: PySwiftLauncher = try! .init()
    
    public var env: PyEnvironment = .init()
    
    public static var Env: PyEnvironment {
        get { shared.env }
        set { }
    }
    
    public let PYTHON_VERSION: String = "3.13"
    
    public var prog: String?
    
    /// The resource path where Python files are located.
    /// On Android, this should be set via setResourcePath() to point to the extracted assets directory.
    /// On iOS/macOS, this defaults to Bundle.main.resourcePath.
    public var resourcePath: String?
    
    /// Initialize the launcher.
    /// - Throws: `CocoaError.fileNoSuchFile` if `app/__main__.py` is not found
    /// - Note: On Android, use `init(mainPath:)` or `setProg()` instead, 
    ///         passing the path from Java after extracting assets.
    public init() throws {
        #if os(Android)
        // On Android, Bundle.main doesn't work as expected.
        // The Java/Kotlin layer should:
        // 1. Extract assets to getFilesDir()
        // 2. Call setResourcePath() with the extracted path
        // 3. Call setProg() with the path to __main__.py
        prog = nil
        resourcePath = nil
        #elseif os(iOS)
        let YourApp = Bundle.main.url(forResource: "app", withExtension: nil)!
        let main_py = Bundle.main.path(forResource: "app/__main__", ofType: "py")
        resourcePath = Bundle.main.resourcePath
        chdir(YourApp.path)
        if let _prog = main_py {
            prog = _prog
        }
        #else
        let YourApp = Bundle.main.url(forResource: "app", withExtension: nil)!
        let main_py = Bundle.main.path(forResource: "app/__main__", ofType: "py")
        resourcePath = Bundle.main.resourcePath
        chdir(YourApp.path)
        if let _prog = main_py {
            prog = _prog
        }
        #endif
    }
    
    /// Initialize the launcher with a custom main file path.
    /// - Parameter mainPath: The path to the Python main file
    public init(mainPath: String) {
        self.prog = mainPath
        if let dir = URL(string: mainPath)?.deletingLastPathComponent().path {
            chdir(dir)
        }
    }
    
    /// Set the program path (useful for Android where Bundle is not available)
    public func setProg(_ path: String) {
        self.prog = path
        // Also derive resourcePath from prog path if not already set
        // e.g., /data/data/.../files/app/__main__.py -> /data/data/.../files
        if self.resourcePath == nil {
            if let url = URL(string: path) {
                // prog is in .../app/__main__.py, resourcePath should be .../
                let filesDir = url.deletingLastPathComponent().deletingLastPathComponent().path
                self.resourcePath = filesDir
                print("PySwiftLauncher: derived resourcePath from prog: \(filesDir)")
            }
        }
    }
    
    /// Set the resource path where Python stdlib and app are located.
    /// On Android, this should be the filesDir where assets are extracted.
    public func setResourcePath(_ path: String) {
        self.resourcePath = path
    }
    
    /// Configure Python environment settings before launch.
    public func setup() {
        pythonSettings()
    }
    
    private func pythonSettings() {
        // Python environment settings
        // Uncomment and modify as needed:
        // env.PYTHONOPTIMIZE = 2
        // env.PYTHONDONTWRITEBYTECODE = 1
        // env.PYTHONNOUSERSITE = 1
        // env.PYTHONPATH = "."
    }
    
    #if os(Android)
    /// Android-specific Python initialization.
    /// Overrides the protocol extension's default implementation which uses Bundle.main.
    public func initPython() throws {
        guard let resourcePath = self.resourcePath else {
            crash_dialog("resourcePath not set. Call setResourcePath() or setProg() first.")
            throw CocoaError(.fileNoSuchFile)
        }
        
        var preconfig = PyPreConfig()
        var config = PyConfig()
        
        var wtmp_str: UnsafeMutablePointer<wchar_t>?
        var app_packages_path_str: UnsafeMutablePointer<wchar_t>?
        var status: PyStatus
        
        print("Configuring isolated Python for Android...")
        PyPreConfig_InitIsolatedConfig(&preconfig)
        PyConfig_InitIsolatedConfig(&config)
        
        preconfig.utf8_mode = 1
        config.buffered_stdio = 0
        config.write_bytecode = 0
        config.module_search_paths_set = 1
        
        setenv("LC_CTYPE", "UTF-8", 1)
        
        print("Pre-initializing Python runtime...")
        status = Py_PreInitialize(&preconfig)
        if _PyStatus_Exception(status) {
            crash_dialog("Unable to pre-initialize Python interpreter: \(status.error)")
            PyConfig_Clear(&config)
            Py_ExitStatusException(status)
        }
        
        let python_tag = "3.13"
        let python_home = "\(resourcePath)/python"
        print("PythonHome: \(python_home)")
        
        wtmp_str = Py_DecodeLocale(python_home, nil)
        var config_home = config.home
        status = PyConfig_SetString(&config, &config_home, wtmp_str)
        config.home = config_home
        if _PyStatus_Exception(status) {
            crash_dialog("Unable to set PYTHONHOME: \(status.error)")
            PyConfig_Clear(&config)
            Py_ExitStatusException(status)
        }
        PyMem_RawFree(wtmp_str)
        
        status = PyConfig_Read(&config)
        if _PyStatus_Exception(status) {
            crash_dialog("Unable to read site config: \(status.error)")
            PyConfig_Clear(&config)
            Py_ExitStatusException(status)
        }
        
        print("PYTHONPATH:")
        var path = "\(python_home)/lib/python\(python_tag)"
        print(" - \(path)")
        wtmp_str = Py_DecodeLocale(path, nil)
        status = PyWideStringList_Append(&config.module_search_paths, wtmp_str)
        if _PyStatus_Exception(status) {
            crash_dialog("Unable to add stdlib path: \(status.error)")
            PyConfig_Clear(&config)
            Py_ExitStatusException(status)
        }
        PyMem_RawFree(wtmp_str)
        
        path = "\(python_home)/lib/python\(python_tag)/lib-dynload"
        print(" - \(path)")
        wtmp_str = Py_DecodeLocale(path, nil)
        status = PyWideStringList_Append(&config.module_search_paths, wtmp_str)
        if _PyStatus_Exception(status) {
            crash_dialog("Unable to add lib-dynload path: \(status.error)")
            PyConfig_Clear(&config)
            Py_ExitStatusException(status)
        }
        PyMem_RawFree(wtmp_str)
        
        path = "\(resourcePath)/app"
        print(" - \(path)")
        wtmp_str = Py_DecodeLocale(path, nil)
        status = PyWideStringList_Append(&config.module_search_paths, wtmp_str)
        if _PyStatus_Exception(status) {
            crash_dialog("Unable to set app path: \(status.error)")
            PyConfig_Clear(&config)
            Py_ExitStatusException(status)
        }
        PyMem_RawFree(wtmp_str)
        
        // Add PySwift imports
        for _import in Self.pyswiftImports {
            #if DEBUG
            print("Importing PySwiftModule:", String(cString: _import.name))
            #endif
            if PyImport_AppendInittab(_import.name, _import.module) == -1 {
                PyErr_Print()
                fatalError()
            }
        }
        
        print("Initializing Python runtime...")
        status = Py_InitializeFromConfig(&config)
        if _PyStatus_Exception(status) {
            crash_dialog("Unable to initialize Python interpreter: \(status.error)")
            PyConfig_Clear(&config)
            Py_ExitStatusException(status)
        }
        
        path = "\(resourcePath)/site_packages"
        app_packages_path_str = Py_DecodeLocale(path, nil)
        print("Adding site_packages: \(path)")
        
        if let module = PyImport_ImportModule("site"),
           let module_attr = PyObject_GetAttrString(module, "addsitedir"),
           PyCallable_Check(module_attr) == 1,
           let app_packages_path_str_unwrapped = app_packages_path_str,
           let app_packages_path = PyUnicode_FromWideChar(app_packages_path_str_unwrapped, wcslen(app_packages_path_str_unwrapped)) {
            PyMem_RawFree(app_packages_path_str)
            
            let args = VectorCallArgs.allocate(capacity: 1)
            args[0] = app_packages_path
            if let result = PyObject_Vectorcall(module_attr, args, 1, nil) {
                Py_DecRef(result)
            }
            Py_DecRef(args[0])
            args.deallocate()
        }
        
        print("---------------------------------------------------------------------------")
        print("Python initialized successfully for Android!")
    }
    
    private func _PyStatus_Exception(_ status: PyStatus) -> Bool {
        return PyStatus_Exception(status) == 1
    }
    #endif
    
    public func preLaunch() throws {
        // Override in subclass or configure before launch
    }
    
    public func onLaunch() throws -> Int32 {
        guard let prog else { return -1 }
        
        var ret: Int32
        
        let fd = fopen(prog, "r")
        
        if let fd {
            #if DEBUG
            print("Running __main__.py: \(prog)")
            #endif
            
            ret = PyRun_SimpleFileEx(fd, prog, 1)
            print("App ended")
            PyErr_Print()
            fclose(fd)
        } else {
            ret = 1
            print("Unable to open __main__.py, abort.")
        }
        return ret
    }
    
    public func onExit() throws {
        // Cleanup after Python execution
        Py_Finalize()
    }
    
    /// Run the Python application.
    /// - Returns: Exit code from Python execution
    @discardableResult
    public static func main() -> Int32 {
        var argv: [UnsafeMutablePointer<CChar>?] = []
        PySwiftLauncher.run(0, &argv)
        return 0
    }
    
    /// Run Python code from a string.
    /// - Parameter code: The Python code to execute
    /// - Returns: Exit code (0 for success)
    @discardableResult
    public func runCode(_ code: String) -> Int32 {
        return PyRun_SimpleString(code)
    }
    
    /// Run a Python file.
    /// - Parameter path: Path to the Python file
    /// - Returns: Exit code from Python execution
    @discardableResult
    public func runFile(_ path: String) throws -> Int32 {
        guard let fd = fopen(path, "r") else {
            throw CocoaError.error(.fileNoSuchFile)
        }
        
        let ret = PyRun_SimpleFileEx(fd, path, 1)
        PyErr_Print()
        fclose(fd)
        return ret
    }
}
