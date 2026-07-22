import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

// Charge les credentials de signature depuis key.properties (non versionné)
val keyPropertiesFile = rootProject.file("key.properties")
val keyProperties = Properties()
if (keyPropertiesFile.exists()) {
    keyProperties.load(FileInputStream(keyPropertiesFile))
}

android {
    namespace = "com.a2digit.arif_quiz"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.a2digit.arif_quiz"
        minSdk = flutter.minSdkVersion           // Android 5.0 — couvre 99 %+ des appareils actifs
        // Android 16 — exigé par le Play Store (échéance 31 août 2026).
        // Conséquences de ce palier, déjà absorbées par l'app :
        //  • edge-to-edge imposé sans opt-out (déjà le cas depuis targetSdk 35,
        //    les écrans passent par SafeArea) ;
        //  • retour prédictif activé par défaut (géré par PopScope) ;
        //  • sur écrans ≥ 600 dp, la contrainte d'orientation portrait devient
        //    indicative — les écrans défilent, la rotation reste utilisable.
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // Multidex pour les gros APK (> 65 k méthodes)
        multiDexEnabled = true
    }

    // Vérifie que le keystore existe réellement avant de créer la config release
    val keystoreReady = keyPropertiesFile.exists() &&
        keyProperties.containsKey("storeFile") &&
        file(keyProperties.getProperty("storeFile", "")).exists()

    if (keystoreReady) {
        signingConfigs {
            create("release") {
                keyAlias = keyProperties["keyAlias"] as String
                keyPassword = keyProperties["keyPassword"] as String
                storeFile = file(keyProperties["storeFile"] as String)
                storePassword = keyProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (keystoreReady)
                signingConfigs.getByName("release")
            else
                signingConfigs.getByName("debug")

            // Minification et obfuscation R8
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
        debug {
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }

    // Exclut les fichiers de licence dupliqués (évite les conflits de merge)
    packaging {
        resources {
            excludes += listOf(
                "META-INF/LICENSE",
                "META-INF/LICENSE.txt",
                "META-INF/NOTICE",
                "META-INF/NOTICE.txt",
                "META-INF/*.kotlin_module"
            )
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
