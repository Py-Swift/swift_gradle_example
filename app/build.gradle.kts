plugins {
    alias(libs.plugins.android.application)
    alias(libs.plugins.kotlin.android)
    alias(libs.plugins.kotlin.compose)
}

android {
    namespace = "com.example.swiftandroid"
    compileSdk = 35
    
    // NDK version required for libc++_shared.so
    ndkVersion = "26.1.10909125"

    defaultConfig {
        applicationId = "com.example.swiftandroid"
        minSdk = 28
        targetSdk = 35
        versionCode = 1
        versionName = "1.0"

        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
        
        ndk {
            // Architectures supported by Swift SDK for Android
            abiFilters += listOf("arm64-v8a", "x86_64")
        }
    }

    buildTypes {
        release {
            isMinifyEnabled = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
    
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    
    @Suppress("DEPRECATION")
    kotlinOptions {
        jvmTarget = "17"
    }
    
    buildFeatures {
        compose = true
    }
    
    // Configure native library paths
    sourceSets {
        getByName("main") {
            jniLibs.srcDirs("src/main/jniLibs")
        }
    }
}

dependencies {
    implementation(libs.androidx.core.ktx)
    implementation(libs.androidx.lifecycle.runtime.ktx)
    implementation(libs.androidx.activity.compose)
    implementation(platform(libs.androidx.compose.bom))
    implementation(libs.androidx.ui)
    implementation(libs.androidx.ui.graphics)
    implementation(libs.androidx.ui.tooling.preview)
    implementation(libs.androidx.material3)
    debugImplementation(libs.androidx.ui.tooling)
    
    // Apache Commons CSV - required for Swift-Java interop demo
    implementation("org.apache.commons:commons-csv:1.10.0")
}

// Task to build Swift library before assembling
tasks.register<Exec>("buildSwiftLibrary") {
    workingDir = file("${project.rootDir}/swift-library")
    commandLine("bash", "${project.rootDir}/scripts/build-swift.sh")
}

// Make sure Swift library is built before packaging
tasks.matching { it.name.startsWith("merge") && it.name.contains("JniLibFolders") }.configureEach {
    dependsOn("buildSwiftLibrary")
}
