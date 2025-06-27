import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val gptProperties = Properties()
val gptPropertiesFile = file("../../gpt.properties") // 상대경로로 지정

if (gptPropertiesFile.exists()) {
    gptProperties.load(FileInputStream(gptPropertiesFile))
    println("client_id: ${gptProperties.getProperty("client_id")}")
    println("client_secret: ${gptProperties.getProperty("client_secret")}")
    println("client_name: ${gptProperties.getProperty("client_name")}")
}


android {
    namespace = "com.example.flutter_gpt_project"
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

        
        applicationId = "com.example.flutter_gpt_project"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        resValue("string", "client_id", gptProperties.getProperty("client_id")?:"" );
        resValue("string", "client_secret", gptProperties.getProperty("client_secret")?:"" );
        resValue("string", "client_name", gptProperties.getProperty("client_name")?:"" );
  
    } // <-- Close defaultConfig here!

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
