plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.aplikasi_presensi"
    compileSdk = flutter.compileSdkVersion

    compileOptions {
        // Menggunakan Java 11 untuk source dan target compatibility
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        // Menggunakan JVM Target 11 untuk Kotlin
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // Tentukan ID aplikasi yang unik
        applicationId = "com.example.aplikasi_presensi"
        // Menyesuaikan nilai SDK untuk aplikasi
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // Menambahkan konfigurasi signing jika diperlukan untuk build release
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
