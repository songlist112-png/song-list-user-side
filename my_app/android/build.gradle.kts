allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    // Automatically patch isar_flutter_libs AndroidManifest.xml for AGP 8 compatibility
    if (project.name == "isar_flutter_libs") {
        val manifestFile = file("src/main/AndroidManifest.xml")
        if (manifestFile.exists()) {
            val content = manifestFile.readText()
            if (content.contains("package=\"dev.isar.isar_flutter_libs\"")) {
                manifestFile.writeText(content.replace("package=\"dev.isar.isar_flutter_libs\"", ""))
            }
        }
    }

    plugins.withId("com.android.library") {
        extensions.configure<com.android.build.gradle.LibraryExtension> {
            if (namespace == null) {
                namespace = "com.example.${project.name.replace("-", "_")}"
            }
            if (compileSdk == null || compileSdk!! < 34) {
                compileSdk = 34
            }
        }
    }

    plugins.withId("com.android.application") {
        extensions.configure<com.android.build.gradle.AppExtension> {
            if (namespace == null) {
                namespace = "com.example.${project.name.replace("-", "_")}"
            }
        }
    }
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
