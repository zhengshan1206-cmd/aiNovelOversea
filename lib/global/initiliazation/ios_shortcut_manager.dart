/*
 * @Author: duncy
 * @Date: 2025-11-12 10:52:37
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2025-11-19 16:04:35
 * @FilePath: /novel_oversea/lib/global/initiliazation/ios_shortcut_manager.dart
 * @Description: 
 */


import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:novel_oversea/global/pay/view/shortcut_dialog.dart';
import 'package:novel_oversea/me/user/user.dart';
import '../launch/controller/launch_manager.dart';
import '../routes/app_pages.dart';

class ShortcutiOSManager {
  static const MethodChannel _channel = MethodChannel('com.penman.shortcut_ios');

  static void handleShortcutAction({Function(int)? tabChanged}) {
    _channel.setMethodCallHandler((MethodCall call) async {
      if (call.method == 'onShortcutTapped') {
        final String url = call.arguments as String;
        Get.offAllNamed(Routes.main);
        switch (url) {
          case "com.penman.write":
            /// 写小说
            tabChanged?.call(0);
            break;
          case "com.penman.feedback":
            /// 反馈
            tabChanged?.call(2);
            break;
          case "com.penman.record":
            /// 记录
            Get.toNamed(Routes.novelRecord);
            break;
          case "com.penman.gift":
            /// 付费弹窗
            if(GlobalController.instance.pay.vipListiOSInterceptor.isEmpty || Get.find<UserController>().isVip) {
              return;
            }
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Get.bottomSheet(
                const ShortcutIosDialog(),
                isDismissible: false,
                isScrollControlled: true,
                enableDrag: false,
              );
            });
            break;
        }
      }
    });
  }
}