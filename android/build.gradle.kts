import java.util.Properties
import java.io.FileInputStream
import org.gradle.api.tasks.Delete
import org.gradle.api.file.Directory

allprojects {
    repositories {
        google()
        mavenCentral()
        maven { url = java.net.URI("https://devrepo.kakao.com/nexus/content/groups/public/") }
    }
}

val localProperties = Properties()
val localPropertiesFile = rootProject.file("local.properties")
if (localPropertiesFile.exists()) {
    FileInputStream(localPropertiesFile).use { stream ->
        localProperties.load(stream)
    }
}

val nativeAppKey: String? = localProperties.getProperty("nativeAppKey")

subprojects {
    afterEvaluate {
        extensions.findByName("android")?.let { ext ->
            val androidExt = ext as com.android.build.gradle.BaseExtension
            androidExt.defaultConfig.manifestPlaceholders += mapOf("nativeAppKey" to (nativeAppKey ?: ""))
        }
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}