# ===== REGRAS PROGUARD PARA TREINO APP =====

# ===== GOOGLE SIGN IN =====
-keep class com.google.android.gms.** { *; }
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.auth.api.signin.** { *; }
-keep class com.google.android.gms.common.** { *; }

# ===== FLUTTER =====
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# ===== HTTP/NETWORK =====
-keep class okhttp3.** { *; }
-keep class retrofit2.** { *; }
-keepclassmembers class * {
    @retrofit2.http.* <methods>;
}

# ===== JSON/GSON =====
-keep class com.google.gson.** { *; }
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer

# ===== SHARED PREFERENCES =====
-keep class androidx.preference.** { *; }

# ===== ANDROIDX =====
-keep class androidx.lifecycle.** { *; }
-keep class androidx.arch.core.** { *; }

# ===== MANTER ANOTAÇÕES =====
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes Exception

# ===== ENUM =====
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# ===== SERIALIZABLE =====
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

# ===== REMOVER LOGS EM RELEASE =====
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
    public static *** i(...);
}