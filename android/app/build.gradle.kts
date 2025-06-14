plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")

}

android {
    namespace = "com.example.flutter_gpt_project"
    compileSdk = 35 // 원하는 compileSdk 버전으로 지정
    ndkVersion = "27.0.12077973" // NDK 버전 명시

    defaultConfig {
        applicationId = "com.example.flutter_gpt_project"
        minSdk = 24 // 원하는 minSdk 버전으로 지정
        //noinspection EditedTargetSdkVersion
        targetSdk = 35 // 원하는 targetSdk 버전으로 지정
        versionCode = 1
        versionName = "1.0.0"
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = "11"
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }

}
dependencies {
    // ...existing code...
    implementation("com.kakao.sdk:v2-user:2.18.0")
}

flutter {

    source = "../.."
}