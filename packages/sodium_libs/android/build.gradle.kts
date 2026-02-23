group = "de.skycoder42.sodium_libs"
version = "3.4.6+5"

buildscript {
    val kotlinVersion = "2.2.20"
    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        classpath("com.android.tools.build:gradle:8.11.1")
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlinVersion")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

plugins {
    id("com.android.library")
    id("kotlin-android")
}

android {
    namespace = "de.skycoder42.sodium_libs"

    compileSdk = 36

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    sourceSets {
        getByName("main") {
            java.srcDirs("src/main/kotlin")
        }
    }

    defaultConfig {
        minSdk = 24
    }

    // task downloadLibsodium(type: Exec) {
    //     if (os.isWindows()) {
    //         executable sdkDir + "\\bin\\dart.bat"
    //     } else {
    //         executable sdkDir + "/bin/dart"
    //     }
    //     args "run", "../tool/libsodium/download.dart", "android"
    // }
    // preBuild.dependsOn downloadLibsodium
}
