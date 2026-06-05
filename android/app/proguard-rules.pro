# ── Flutter ──────────────────────────────────────────────────────────────────
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.embedding.**

# ── Kotlin ───────────────────────────────────────────────────────────────────
-keep class kotlin.** { *; }
-keep class kotlin.Metadata { *; }
-dontwarn kotlin.**
-keepclassmembers class **$WhenMappings { <fields>; }
-keepclassmembers class kotlin.Metadata { public <methods>; }

# ── Dio / OkHttp ─────────────────────────────────────────────────────────────
-dontwarn okhttp3.**
-dontwarn okio.**
-keepnames class okhttp3.internal.publicsuffix.PublicSuffixDatabase

# ── Flutter Secure Storage ───────────────────────────────────────────────────
-keep class com.it_nomads.fluttersecurestorage.** { *; }

# ── Shared Preferences ───────────────────────────────────────────────────────
-keep class io.flutter.plugins.sharedpreferences.** { *; }

# ── Cached Network Image ─────────────────────────────────────────────────────
-keep class com.baseflow.cachednetworkimage.** { *; }

# ── Share Plus ───────────────────────────────────────────────────────────────
-keep class dev.fluttercommunity.plus.share.** { *; }

# ── Connectivity Plus ────────────────────────────────────────────────────────
-keep class dev.fluttercommunity.plus.connectivity.** { *; }

# ── Évite de retirer les annotations utilisées par réflexion ─────────────────
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable
-keepattributes Signature
-keepattributes Exceptions

# ── Général : garder les classes de modèles JSON ─────────────────────────────
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

# ── Évite les avertissements inutiles ────────────────────────────────────────
-dontwarn com.google.**
-dontwarn javax.annotation.**
-dontwarn sun.misc.**
