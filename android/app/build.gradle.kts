plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.newchambea.com"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.newchambea.com"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 23
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
dependencies {
    // Import the BoM for the Firebase platform
    implementation(platform("com.google.firebase:firebase-bom:33.15.0"))

    // Firebase Authentication
    implementation("com.google.firebase:firebase-auth")

    // Firebase App Check
    implementation("com.google.firebase:firebase-appcheck")
    implementation("com.google.firebase:firebase-appcheck-playintegrity")  // For Play Integrity
    implementation("com.google.firebase:firebase-appcheck-debug")          // For debug mode

    // Cloud Firestore (optional, based on your Flutter dependencies)
    implementation("com.google.firebase:firebase-firestore")

    // Firebase Storage (optional, based on your Flutter dependencies)
    implementation("com.google.firebase:firebase-storage")

    // Firebase Messaging (if using push notifications)
    implementation("com.google.firebase:firebase-messaging")

    // Google Sign-In (required for Firebase Auth Google Sign-In)
    implementation("com.google.android.gms:play-services-auth")
}

flutter {
    source = "../.."
}
