plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.pokemon_flutter"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.example.pokemon_flutter"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    flavorDimensions += "environment"

    productFlavors {
        create("dev") {
            dimension = "environment"
            applicationIdSuffix = ".dev"
            versionNameSuffix = "-dev"
            resValue("string", "app_name", "Pokédex Dev")
            manifestPlaceholders["googleMapsApiKey"] =
                System.getenv("GOOGLE_MAPS_API_KEY_DEV") ?: ""
        }
        create("staging") {
            dimension = "environment"
            applicationIdSuffix = ".staging"
            versionNameSuffix = "-staging"
            resValue("string", "app_name", "Pokédex Staging")
            manifestPlaceholders["googleMapsApiKey"] =
                System.getenv("GOOGLE_MAPS_API_KEY_STAGING") ?: ""
        }
        create("prod") {
            dimension = "environment"
            resValue("string", "app_name", "Pokédex")
            manifestPlaceholders["googleMapsApiKey"] =
                System.getenv("GOOGLE_MAPS_API_KEY") ?: ""
        }
    }

    androidResources {
        // Prevent .tflite from being compressed so it loads faster at runtime
        noCompress += "tflite"
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
