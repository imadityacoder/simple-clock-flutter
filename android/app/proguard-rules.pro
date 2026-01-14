# Flutter Proguard Rules
# ProGuard configuration for Flutter app release builds

# Keep Flutter classes
-keep class io.flutter.** { *; }
-keep class com.google.android.** { *; }

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep custom app classes
-keep class com.example.analog_clock_app.** { *; }

# Remove logging in release builds
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
    public static *** i(...);
}

# Keep Shared Preferences
-keep class androidx.preference.** { *; }

# Preserve line numbers for debugging
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile
