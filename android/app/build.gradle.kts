import java.util.Properties

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(keystorePropertiesFile.inputStream())
}

plugins {
    id("com.android.application")
    id("com.google.gms.google-services")
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.chambea.clientapp"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = "11"
    }

    defaultConfig {
        applicationId = "com.chambea.clientapp"
        minSdk = 23
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
    }

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
            storeFile = file(keystoreProperties["storeFile"] as String)
            storePassword = keystoreProperties["storePassword"] as String
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("androidx.multidex:multidex:2.0.1")
    implementation("androidx.lifecycle:lifecycle-viewmodel:2.8.7")
    implementation("androidx.lifecycle:lifecycle-viewmodel-savedstate:2.8.7")

    implementation("com.google.firebase:firebase-auth") {
        exclude(group = "androidx.lifecycle", module = "lifecycle-viewmodel-savedstate")
    }
    implementation("com.google.firebase:firebase-firestore") {
        exclude(group = "androidx.lifecycle", module = "lifecycle-viewmodel-savedstate")
    }
    implementation("com.google.firebase:firebase-storage") {
        exclude(group = "androidx.lifecycle", module = "lifecycle-viewmodel-savedstate")
    }
    implementation("com.google.firebase:firebase-appcheck") {
        exclude(group = "androidx.lifecycle", module = "lifecycle-viewmodel-savedstate")
    }
}

configurations.all {
    resolutionStrategy {
        force("androidx.lifecycle:lifecycle-viewmodel:2.8.7")
        force("androidx.lifecycle:lifecycle-viewmodel-savedstate:2.8.7")
    }
}
