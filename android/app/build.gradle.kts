plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    // The Google services Gradle plugin
    id("com.google.gms.google-services")
}

android {
    // Ensure this namespace matches your package structure
    namespace = "com.example.talcove"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // 1. MUST use 'isCoreLibraryDesugaringEnabled' for Kotlin DSL
        isCoreLibraryDesugaringEnabled = true

        // Updated to VERSION_17 for Firebase compatibility
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // This ID must match exactly with what is in your google-services.json
        applicationId = "com.example.talcove"
        
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

dependencies {
    // 2. Upgraded to 2.1.4 to meet the plugin's metadata requirements
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")

    // Import the Firebase BoM
    implementation(platform("com.google.firebase:firebase-bom:33.1.0"))

    // Add the dependencies for Firebase products
    implementation("com.google.firebase:firebase-analytics")
}

flutter {
    source = "../.."
}