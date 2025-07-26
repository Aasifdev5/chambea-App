# Firebase
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# Firebase Messaging
-keep class com.google.firebase.messaging.** { *; }

# Gson (for JSON parsing)
-keep class com.google.gson.** { *; }

# Retrofit / OkHttp (if using)
-keep class okhttp3.** { *; }
-dontwarn okhttp3.**

# Your models (optional)
-keep class com.newchambea.com.** { *; }
