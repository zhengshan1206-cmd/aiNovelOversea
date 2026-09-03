/*
 * @Author: cold-x
 * @Date: 2025-09-12 16:04:53
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2026-03-02 09:26:56
 * @FilePath: /novel_oversea/lib/main.dart
 * @Description: 
 */


import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:novel_oversea/core/cache/build_config.dart';
import 'package:novel_oversea/core/cache/environment.dart';
import 'package:novel_oversea/core/cache/environment_config.dart';
import 'package:novel_oversea/core/network/channel.dart';
import 'package:novel_oversea/core/service/app_translations.dart';
import 'package:novel_oversea/firebase_options.dart';
import 'package:novel_oversea/global/initiliazation/app_life_circle.dart';
import 'package:novel_oversea/global/initiliazation/initialize.dart';
import 'package:novel_oversea/global/initiliazation/theme.dart';
import 'package:novel_oversea/global/launch/controller/launch_manager.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'global/routes/app_pages.dart';
import 'global/routes/navigator_routes.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

Locale? language = Get.deviceLocale;


void main() async {

  BuildConfig.instantiate(
      envType: Environment.PRODUCTION,
      envConfig: EnvironmentConfig(),
      // channelType: Platform.isAndroid ? ChannelType.google : ChannelType.apple,
      channelType: ChannelType.test
    );

    WidgetsFlutterBinding.ensureInitialized();
    SystemChrome.setPreferredOrientations([
      // 强制竖屏
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    /// 全局注册app生命周期监听
    WidgetsBinding.instance.addObserver(
      AppLifecycleObserver(),
    );
    ///app 初始化
    await InitializeManager.initializition();
    language = await LanguageService.getSavedLanguage();
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
    
    FirebaseAnalytics.instance;
    runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      child: InitializeManager.initRefresh(
        GetMaterialApp(
          title: 'Penman Pro',
          // navigatorKey: navigatorKey,
          theme: AppTheme.lightTheme,
          defaultTransition: Platform.isIOS ? Transition.cupertino : Transition.fadeIn,
          supportedLocales: const [
            Locale('zh', 'CN'), // 简体中文
            Locale('en', 'US'),
            Locale('ja', 'JP'), 
          ],
          // 1. 配置翻译实例
          translations: AppTranslations(),
          // 2. 默认语言（未指定时使用）
          fallbackLocale: const Locale('en', 'US'),
          // 3. 初始语言（可选，不设置则跟随系统）
          // locale: language,
          locale: const Locale('en', 'US'),
          localizationsDelegates: [
            RefreshLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          getPages: AppPages.routes,
          debugShowCheckedModeBanner: false,
          initialRoute: Routes.launch,
          initialBinding: GlobalBinding(),
          builder: BotToastInit(),
          navigatorObservers: [
            // ToastNavigatorObserver(),
            // routeObserver,
            GetObserver(),
            MyRouteObserver(),
            BotToastNavigatorObserver(),
          ],
        ),
      ),
    );
  }
}
