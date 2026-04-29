# Flutter
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.embedding.**

# Google Sign-In / Play Services
-keep class com.google.android.gms.** { *; }
-keep class com.google.firebase.** { *; }
-dontwarn com.google.android.gms.**

# Kotlin
-dontwarn kotlin.**
-keep class kotlin.** { *; }
-keep class kotlinx.** { *; }
