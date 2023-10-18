

-verbose
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile

-keep public class com.nhn.android.naverlogin.** {
       public protected *;
}

## Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }
-dontwarn io.flutter.embedding.*







