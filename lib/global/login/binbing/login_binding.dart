/*
 * @Author: duncy
 * @Date: 2025-12-16 14:35:11
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2026-01-09 18:19:47
 * @FilePath: /novel_oversea/lib/global/login/binbing/login_binding.dart
 * @Description: 
 */

import 'package:get/get.dart';
import 'package:novel_oversea/global/login/controller/login_controller.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    final args = Get.arguments ?? {};
    Get.put<LoginController>(LoginController(
      onLoginSuccessCallback: args["onLoginSuccess"],
      binding: args['bind'] ?? false,
      isGuide: args['isGuide'] ?? false,
      source: args['source'] ?? 'normal',
    ));
  }
}
