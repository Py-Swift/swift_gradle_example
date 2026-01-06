//
//  CPython.h
//  CPython for Android - Minimal interface for Swift
//

#ifndef CPython_h
#define CPython_h

#ifdef __cplusplus
extern "C" {
#endif

// Initialize Python interpreter
// Returns 1 on success, 0 on failure
int CPython_Initialize(const char* pythonHome);

// Shutdown Python interpreter
void CPython_Finalize(void);

// Check if Python is initialized
int CPython_IsInitialized(void);

// Execute Python code string
// Returns 0 on success, -1 on error
int CPython_RunString(const char* code);

// Get Python version string
const char* CPython_GetVersion(void);

#ifdef __cplusplus
}
#endif

#endif /* CPython_h */
