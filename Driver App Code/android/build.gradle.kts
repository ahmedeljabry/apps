allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)

    // Only apply the Kotlin 2.0 Compose compiler plugin to the module that triggered the error
    // to avoid compatibility issues/ICE (Internal Compiler Error) in other modules like :app_settings
    if (project.name == "biometric_authorization") {
        pluginManager.withPlugin("com.android.library") {
            apply(plugin = "org.jetbrains.kotlin.plugin.compose")
        }
    }
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}