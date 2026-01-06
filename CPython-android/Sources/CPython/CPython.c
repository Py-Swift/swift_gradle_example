//
//  CPython.c
//  CPython for Android
//

#define PY_SSIZE_T_CLEAN
#include "Python.h"
#include "CPython.h"
#include <string.h>
#include <stdlib.h>
#include <stdio.h>

// Initialize Python interpreter
int CPython_Initialize(const char* pythonHome) {
    if (Py_IsInitialized()) {
        return 1; // Already initialized
    }
    
    // Use PyConfig for Python 3.8+
    PyConfig config;
    PyConfig_InitIsolatedConfig(&config);
    
    // Disable site import to avoid issues with Android
    config.site_import = 0;
    
    // Disable writing bytecode since we can't write to assets
    config.write_bytecode = 0;
    
    // Set Python home if provided
    if (pythonHome != NULL && pythonHome[0] != '\0') {
        PyStatus status = PyConfig_SetBytesString(&config, &config.home, pythonHome);
        if (PyStatus_Exception(status)) {
            fprintf(stderr, "CPython: Failed to set Python home: %s\n", pythonHome);
            PyConfig_Clear(&config);
            return 0;
        }
        
        // Also set the program name
        char programPath[1024];
        snprintf(programPath, sizeof(programPath), "%s/bin/python3", pythonHome);
        status = PyConfig_SetBytesString(&config, &config.program_name, programPath);
        if (PyStatus_Exception(status)) {
            fprintf(stderr, "CPython: Failed to set program name\n");
        }
    }
    
    // Initialize Python
    PyStatus status = Py_InitializeFromConfig(&config);
    PyConfig_Clear(&config);
    
    if (PyStatus_Exception(status)) {
        fprintf(stderr, "CPython: Py_InitializeFromConfig failed\n");
        if (PyStatus_IsError(status)) {
            fprintf(stderr, "CPython: Error: %s\n", status.err_msg ? status.err_msg : "unknown");
        }
        return 0;
    }
    
    return Py_IsInitialized() ? 1 : 0;
}

// Shutdown Python interpreter
void CPython_Finalize(void) {
    if (Py_IsInitialized()) {
        Py_Finalize();
    }
}

// Check if Python is initialized
int CPython_IsInitialized(void) {
    return Py_IsInitialized();
}

// Execute Python code string
int CPython_RunString(const char* code) {
    if (!Py_IsInitialized()) {
        return -1;
    }
    return PyRun_SimpleString(code);
}

// Get Python version string
const char* CPython_GetVersion(void) {
    return Py_GetVersion();
}
