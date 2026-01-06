package com.example.swiftandroid

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Button
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.swiftandroid.ui.theme.SwiftAndroidTheme

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        
        // Copy Python stdlib from assets on first run
        copyPythonStdlib()
        
        // Get greeting from Swift
        val swiftGreeting = SwiftBridge.getGreetingFromSwift()
        
        setContent {
            SwiftAndroidTheme {
                Scaffold(modifier = Modifier.fillMaxSize()) { innerPadding ->
                    SwiftJavaDemo(
                        greeting = swiftGreeting,
                        modifier = Modifier.padding(innerPadding)
                    )
                }
            }
        }
    }
    
    private fun copyPythonStdlib() {
        val pythonDir = java.io.File(filesDir, "python3.13")
        if (!pythonDir.exists()) {
            pythonDir.mkdirs()
            try {
                copyAssetFolder("python3.13", pythonDir.absolutePath)
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }
    }
    
    private fun copyAssetFolder(assetPath: String, destPath: String) {
        val assets = assets.list(assetPath) ?: return
        if (assets.isEmpty()) {
            // It's a file
            copyAssetFile(assetPath, destPath)
        } else {
            // It's a directory
            java.io.File(destPath).mkdirs()
            for (asset in assets) {
                copyAssetFolder("$assetPath/$asset", "$destPath/$asset")
            }
        }
    }
    
    private fun copyAssetFile(assetPath: String, destPath: String) {
        assets.open(assetPath).use { input ->
            java.io.FileOutputStream(destPath).use { output ->
                input.copyTo(output)
            }
        }
    }
}

@Composable
fun SwiftJavaDemo(greeting: String, modifier: Modifier = Modifier) {
    // Sample CSV data
    val sampleCSV = """
        Name,Age,City
        Alice,30,New York
        Bob,25,San Francisco
        Charlie,35,Los Angeles
    """.trimIndent()
    
    var csvResult by remember { mutableStateOf("") }
    var systemInfo by remember { mutableStateOf("") }
    
    Surface(
        modifier = modifier.fillMaxSize(),
        color = MaterialTheme.colorScheme.background
    ) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(16.dp)
                .verticalScroll(rememberScrollState()),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            // Greeting Card
            Card(
                modifier = Modifier.fillMaxWidth(),
                colors = CardDefaults.cardColors(
                    containerColor = MaterialTheme.colorScheme.primaryContainer
                )
            ) {
                Text(
                    text = greeting,
                    fontSize = 16.sp,
                    textAlign = TextAlign.Center,
                    fontFamily = FontFamily.Monospace,
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(16.dp),
                    color = MaterialTheme.colorScheme.onPrimaryContainer
                )
            }
            
            Spacer(modifier = Modifier.height(16.dp))
            
            // CSV Demo Section
            Text(
                text = "🔧 Swift-Java Interop Demo",
                fontSize = 20.sp,
                color = MaterialTheme.colorScheme.primary
            )
            
            Spacer(modifier = Modifier.height(8.dp))
            
            // CSV Data Card
            Card(
                modifier = Modifier.fillMaxWidth(),
                colors = CardDefaults.cardColors(
                    containerColor = MaterialTheme.colorScheme.surfaceVariant
                )
            ) {
                Column(modifier = Modifier.padding(12.dp)) {
                    Text(
                        text = "Sample CSV Data:",
                        fontSize = 14.sp,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                    Text(
                        text = sampleCSV,
                        fontFamily = FontFamily.Monospace,
                        fontSize = 12.sp,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                }
            }
            
            Spacer(modifier = Modifier.height(12.dp))
            
            // Buttons Row
            Button(
                onClick = {
                    csvResult = try {
                        SwiftBridge.parseCSV(sampleCSV)
                    } catch (e: Exception) {
                        "Error: ${e.message}"
                    }
                },
                modifier = Modifier.fillMaxWidth()
            ) {
                Text("Parse CSV (Swift)")
            }
            
            Spacer(modifier = Modifier.height(8.dp))
            
            Button(
                onClick = {
                    csvResult = try {
                        SwiftBridge.parseCSVWithJava(sampleCSV)
                    } catch (e: Exception) {
                        "Error: ${e.message}"
                    }
                },
                modifier = Modifier.fillMaxWidth()
            ) {
                Text("Parse CSV (Swift→Java)")
            }
            
            Spacer(modifier = Modifier.height(8.dp))
            
            Button(
                onClick = {
                    systemInfo = try {
                        SwiftBridge.getSystemInfo()
                    } catch (e: Exception) {
                        "Error: ${e.message}"
                    }
                },
                modifier = Modifier.fillMaxWidth()
            ) {
                Text("Get System Info (Swift→Java)")
            }
            
            Spacer(modifier = Modifier.height(8.dp))
            
            // Phase 3: Python Button
            Button(
                onClick = {
                    systemInfo = try {
                        // Get the app's files directory for Python home
                        val pythonHome = "/data/data/com.example.swiftandroid/files/python3.13"
                        
                        // Initialize Python if not already done
                        val wasInit = SwiftBridge.isPythonInitialized()
                        val initResult = if (!wasInit) {
                            SwiftBridge.initializePython(pythonHome)
                        } else true
                        
                        // Get Python demo info (shows full chain)
                        val info = SwiftBridge.getPythonDemoInfo()
                        "Init was: $wasInit, Init result: $initResult\n$info"
                    } catch (e: Exception) {
                        "Error: ${e.message}\n${e.stackTraceToString()}"
                    }
                },
                modifier = Modifier.fillMaxWidth()
            ) {
                Text("🐍 Python Demo (Kotlin→Swift→Python)")
            }
            
            Spacer(modifier = Modifier.height(16.dp))
            
            // Results
            if (csvResult.isNotEmpty()) {
                Card(
                    modifier = Modifier.fillMaxWidth(),
                    colors = CardDefaults.cardColors(
                        containerColor = MaterialTheme.colorScheme.secondaryContainer
                    )
                ) {
                    Text(
                        text = csvResult,
                        fontFamily = FontFamily.Monospace,
                        fontSize = 12.sp,
                        modifier = Modifier.padding(12.dp),
                        color = MaterialTheme.colorScheme.onSecondaryContainer
                    )
                }
                Spacer(modifier = Modifier.height(12.dp))
            }
            
            if (systemInfo.isNotEmpty()) {
                Card(
                    modifier = Modifier.fillMaxWidth(),
                    colors = CardDefaults.cardColors(
                        containerColor = MaterialTheme.colorScheme.tertiaryContainer
                    )
                ) {
                    Text(
                        text = systemInfo,
                        fontFamily = FontFamily.Monospace,
                        fontSize = 12.sp,
                        modifier = Modifier.padding(12.dp),
                        color = MaterialTheme.colorScheme.onTertiaryContainer
                    )
                }
            }
        }
    }
}

@Preview(showBackground = true)
@Composable
fun SwiftJavaDemoPreview() {
    SwiftAndroidTheme {
        SwiftJavaDemo("Hello from Swift! 🚀\nSwift-Java Demo")
    }
}
