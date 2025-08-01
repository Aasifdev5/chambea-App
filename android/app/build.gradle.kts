plugins {
    id("com.android.application")
    id("com.google.gms.google-services")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.newchambea.com"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    defaultConfig {
        applicationId = "com.newchambea.com"
        minSdk = 23
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    signingConfigs {
        create("release") {
            storeFile = file("../clientchambea_release.jks")
            storePassword = "Chambea@2025"
            keyAlias = "chambeaKey"
            keyPassword = "Chambea@2025"
        }
        // ✅ No need to define debug — Flutter uses default debug config
    }

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = false
            isShrinkResources = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }

        getByName("debug") {
            // Default debug config
        }
    }
}

dependencies {
    // Firebase BoM (Bill of Materials) to align versions
    implementation(platform("com.google.firebase:firebase-bom:33.5.0"))

    // Firebase core services
    implementation("com.google.firebase:firebase-auth")
    implementation("com.google.firebase:firebase-firestore")
    implementation("com.google.firebase:firebase-storage")
    implementation("com.google.firebase:firebase-messaging")

    // Firebase App Check
    implementation("com.google.firebase:firebase-appcheck")
    implementation("com.google.firebase:firebase-appcheck-playintegrity") // ✅ Required for real device
    implementation("com.google.firebase:firebase-appcheck-debug")         // ✅ For dev/emulator only

    // Google Sign-In
    implementation("com.google.android.gms:play-services-auth:21.2.0")

    // Optional: Legacy App Check fallback
    implementation("com.google.android.gms:play-services-safetynet:18.1.0")
}

flutter {
    source = "../.."
}
