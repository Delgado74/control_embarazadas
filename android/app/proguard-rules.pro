# Ignore missing classes from Google Play
-dontwarn com.google.android.play.core.**

# Flutter specific rules
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Keep database
-keep class com.tekartik.sqflite.** { *; }
