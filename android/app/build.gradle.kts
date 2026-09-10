plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    // ⚠ Must come AFTER the Flutter plugin. It needs google-services.json to
    // be present at build time — the file is gitignored, so a clean checkout
    // without it fails here rather than shipping an app that cannot register.
    id("com.google.gms.google-services")
}

android {
    namespace = "com.shrutivtuber.astrolabe"
    // ⚠ compileSdk is NOT targetSdk.
    //
    // Compiling against a newer SDK only makes newer APIs visible to the
    // compiler; it changes nothing about which devices can install the app.
    // It is raised here because sweph pulls androidx.fragment 1.7.1, which
    // refuses to be compiled against anything older than 34 — twenty AAR
    // metadata errors, none of which name the real cause.
    //
    // `minSdk` and `targetSdk` deliberately still follow Flutter's defaults
    // below: raising those DOES change who can install, and that is a decision
    // rather than a build fix.
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.shrutivtuber.astrolabe"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
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
