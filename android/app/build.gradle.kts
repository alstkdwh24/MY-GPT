import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

val gptProps = Properties()
val gptPropsFile = rootProject.file("gpt.properties")
if (gptPropsFile.exists()) {
    gptProps.load(FileInputStream(gptPropsFile))
}

android {
    namespace = "com.example.flutter_gpt_project"
    compileSdk = 35
    ndkVersion = "27.0.12077973"

    defaultConfig {
        applicationId = "com.example.flutter_gpt_project"
        minSdk = 24
        targetSdk = 35
        versionCode = 1
        versionName = "1.0.0"
                manifestPlaceholders.put("nativeAppKey", gptProps["NativeKey"] ?: "")

        manifestPlaceholders.put("naver-secret-client-id", gptProps["naver-secret-client-id"] ?: "")
        manifestPlaceholders.put("naver-secret-client-secret", gptProps["naver-secret-client-secret"] ?: "")
        resValue("string", "client_name", "YOUR_CLIENT_NAME")
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = "11"
    }

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

dependencies {
    implementation("com.kakao.sdk:v2-user:2.18.0")
}

flutter {
    source = "../.."
}