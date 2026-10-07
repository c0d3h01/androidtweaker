plugins {
    alias(libs.plugins.android.application)
    alias(libs.plugins.kotlin.android)
    alias(libs.plugins.kotlin.compose)
}

import java.util.Properties

val localProps = Properties().apply {
    // Shared dev key (committed) + machine-local overrides (ignored).
    rootProject.file("app/release.properties").takeIf { it.exists() }?.inputStream()?.use(::load)
    rootProject.file("local.properties").takeIf { it.exists() }?.inputStream()?.use(::load)
}

android {
    namespace = "com.c0d3h01.androidtweaker"
    compileSdk = 34

    defaultConfig {
        applicationId = "com.c0d3h01.androidtweaker"
        minSdk = 26
        targetSdk = 34
        versionCode = 160
        versionName = "1.6.0"
    }

    signingConfigs {
        create("release") {
            // Official key lives in local.properties (never committed).
            // Falls back to the debug key so assembleRelease always signs.
            val ksFile = localProps.getProperty("KEYSTORE_FILE")?.let { rootProject.file(it) }
                ?: file("release.keystore")
            if (ksFile.exists()) {
                storeFile = ksFile
                storePassword = localProps.getProperty("KEYSTORE_PASSWORD")
                keyAlias = localProps.getProperty("KEY_ALIAS", "androidtweaker")
                keyPassword = localProps.getProperty("KEY_PASSWORD")
            } else {
                initWith(getByName("debug"))
            }
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }

    buildFeatures {
        compose = true
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    kotlinOptions {
        jvmTarget = "17"
    }
}

dependencies {
    implementation(platform(libs.compose.bom))
    implementation(libs.compose.ui)
    implementation(libs.compose.material3)
    implementation(libs.activity.compose)
    testImplementation(libs.junit)
}

// Stable release path for module packing: app/release/androidtweaker.apk
tasks.register<Copy>("stageReleaseApk") {
    dependsOn("assembleRelease")
    from(layout.buildDirectory.dir("outputs/apk/release"))
    include("app-release.apk")
    rename("app-release.apk", "androidtweaker.apk")
    into(rootProject.file("app/release"))
}
