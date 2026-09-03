-keep class com.reyun.** {*; }
-keep class route.**{*;}
-keep interface com.reyun.** {*; }
-keep interface route.**{*;}
-dontwarn com.reyun.**
-dontwarn org.json.**
-keep class org.json.**{*;}
# Google lib库
-keep class com.google.android.gms.ads.identifier.AdvertisingIdClient {
    com.google.android.gms.ads.identifier.AdvertisingIdClient$Info getAdvertisingIdInfo(android.content.Context);
}
-keep class com.google.android.gms.ads.identifier.AdvertisingIdClient$Info {
    java.lang.String getId();
    boolean isLimitAdTrackingEnabled();
}
-keep public class com.android.installreferrer.** { *; }
# 如果使用到了获取oaid插件，请添加以下混淆策略
-keep class com.huawei.hms.**{*;}
-keep class com.hihonor.**{*;}