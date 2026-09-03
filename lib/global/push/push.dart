/*
 * @Author: duncy
 * @Date: 2026-01-23 16:29:47
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2026-02-26 15:28:53
 * @FilePath: /novel_oversea/lib/global/push/push.dart
 * @Description: 
 */



import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:novel_oversea/core/cache/byhy_aes_storage_utils.dart';
import 'package:novel_oversea/global/launch/controller/launch_controller.dart';
import 'package:novel_oversea/global/launch/controller/launch_manager.dart';
import 'package:novel_oversea/global/push/push_bean.dart';
import 'package:novel_oversea/me/user/user.dart';
import '../../core/ui/view/by_common_utils.dart';
import '../../core/util/by_nav_router_utils.dart';
import '../../firebase_options.dart';
import '../../home/create/controller/novel_create_controller.dart';
import '../const/const_string.dart';
import '../pay/view/home_discount_dialog.dart';
import '../routes/app_pages.dart';

class Push {
  /// 初始化
  /// 初始化通知消息注册
  static void init() async{
    /// 获取通知权限
    NotificationSettings settings = await FirebaseMessaging.instance.requestPermission(provisional: false);
    if(settings.authorizationStatus != AuthorizationStatus.authorized) {
      return;
    }
    FirebaseMessaging.instance.subscribeToTopic(Platform.isAndroid ? 'android': 'ios');
    final String? token = await FirebaseMessaging.instance.getToken() ;
    // For apple platforms, make sure the APNS token is available before making any FCM plugin API calls
    print('_______通知token::=======>>>>>>>$token');
    if(token != null) {
      ByStorageUtils.saveString(ConstString.kFirebasePushToken, token);
      if(DeviceInfoUpload.instance.isUploaded > 0) {
        DeviceInfoUpload.uploadUserDeviceInfo();
      }
    }
    /// 自定义iOS apns推送
    // if (Platform.isIOS) {
    //   final apnsToken = await FirebaseMessaging.instance.getAPNSToken();
    //   if (apnsToken != null) {}
    // }
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  @pragma('vm:entry-point')
  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    // If you're going to use other Firebase services in the background, such as Firestore,
    // make sure you call `initializeApp` before using other Firebase services.
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    print("Handling a background message: ${message.messageId}");
  } 

  /// 监听通知消息
  static Future<void> setupInteractedMessage() async {

    /// 应用内消息
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('______Message data: ${message.data}');

      if (message.notification != null) {
        print('____Message also contained a notification: ${message.notification}');
      }
      // _handleMessage(message, 0);
      // Toast.showText(text: message.notification?.body ?? '');
    });

    /// 远程推送通知消息(冷启动)
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _handleMessage(initialMessage, 1);
    }

    /// 后台推送点击消息
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleMessage(message, 2);
    });
  }


  /// 处理消息推送
  static void _handleMessage(RemoteMessage message, int click) {
    print('_________点击通知: ===>>>${message.data}, 类型: $click');
    PushBean bean = PushBean.fromJson(message.data);
    // 消息处理
    switch (PushType.fromRawValue(bean.type!)) {
      /// 跳转至指定页面
      case PushType.page:
        PushRoutes.routesToPage(bean.url!);
        break;
      /// 跳转至内部网页链接
      case PushType.internalWebView:
        ByNavRouterUtils.jumpWebViewPage(
            Get.context!,
            "",
            bean.url!,
            isRisk: false,
          );
        break;
      /// 跳转至外部网页链接
      case PushType.externalWebView:
        ByCommonUtils.launchWebURL(bean.url!);
        break;
      default:
        break;
    }
  }
}

class PushRoutes {
  static void routesToPage(String routeName) {
    print('_________点击通知进入页面: $routeName');
    switch (routeName) {
      /// 长文创作
      case '/create_long_novel':
      /// 短文创作
      case '/create_short_novel':
        Get.toNamed(
            Routes.novelCreateCategory ,
            arguments: {'type': routeName == '/create_long_novel' ?  CreationType.longNovel : CreationType.shortNovel},
          );
        break;

      /// 长文记录
      case '/record_long_novel':
      /// 短文记录
      case '/record_short_novel':
        Get.toNamed(
            Routes.novelRecord ,
            arguments: {'type': routeName == '/record_long_novel' ?  CreationType.longNovel : CreationType.shortNovel},
          );
        break;

      /// 默认付费页
      case '/member_center':
        Get.find<UserController>().jumpToPayPage(source: 'push');
        break;
      /// 首次打开后5分钟推送的付费页
      case '/member_first':
        if (GlobalController.instance.pay.vipListPush.isNotEmpty &&
            !Get.find<UserController>().isVip) {
          Get.bottomSheet(
            HomeDiscountDialog(isPush: true),
            isDismissible: false,
            isScrollControlled: true,
            enableDrag: false,
          );
        }
        break;
      
      default:
        break;
    }
  }
}