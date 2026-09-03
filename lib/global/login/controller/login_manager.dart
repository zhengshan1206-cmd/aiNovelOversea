/*
 * @Author: cold-x
 * @Date: 2025-06-09 11:08:18
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2026-01-09 18:19:29
 * @FilePath: /novel_oversea/lib/global/login/controller/login_manager.dart
 * @Description: 
 */


import 'dart:ui';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:novel_oversea/global/login/controller/firebase_auth.dart';
import 'package:novel_oversea/global/login/controller/login_controller.dart';
import '../../../core/network/http_utils.dart';
import '../../../core/network/intercept.dart';
import '../../../core/network/novel_apis.dart';
import '../../../core/ui/dialog/loading_dialog.dart';
import '../../../core/ui/dialog/toast.dart';
import '../../../core/util/by_device_info_utils.dart';
import '../../../me/user/user.dart';
import '../../launch/bean/launch_bean.dart';
import '../../launch/controller/launch_controller.dart';
import '../../routes/app_pages.dart';
import '../bean/login_bean.dart';
import '../view/first_login_dialog.dart';

class LoginManager {
  
  static final LoginManager _instance = LoginManager._internal();
  factory LoginManager() => _instance;
  LoginManager._internal();

  static void login({
    String? source = 'normal',
    bool? binding = false,
    bool? isGuide = false,
    VoidCallback? successLogin,
    Function()? failed}) {
    // _instance.getPayStyle();
    if (Get.find<UserController>().isVisitor) {
      Get.toNamed(
        Routes.login,
        arguments: {
          "onLoginSuccess": successLogin,
          "bind": binding,
          "isGuide": isGuide,
          'source': source
        },
      );
    }
    
  }
  ///firebase服务器登录验证
  static void createLogin(
    FirebaseUser user, 
    LoginType type, {
    void Function(dynamic, int)? onSuccess,
    void Function(int, String)? onFailed,
    }) async {
    final imei = await ByDeviceInfoUtils.deviceInfo();
    HttpUtils.post(
      // binding! ? NovelApis.firebaseBinding : NovelApis.firebaseLogin,
      NovelApis.firebaseLogin,
      showMsgWhenFailed: false,
      { 
        "fireType": type.typeIndex,
        "firebaseUId": user.uid,
        "uuid": imei.item2,
        "email": user.email ?? '',
        "nickname": user.displayName ?? '',
        "avatar": user.photoURL ?? '',
      },
      success: (data) async {
        LoadingDialog().dismiss();
        onSuccess?.call(data, 0);
        handleLoginResponse(data, type: type);
      },
      fail: (code, msg) {
        LoadingDialog().dismiss();
        onFailed?.call(code, msg);
      },
    );
  }

  ///登录成功
  static Future<void> handleLoginResponse(dynamic data, {
    bool? binding = false,
    LoginType? type,
    void Function(dynamic, int)? onSuccess,
    }) async {
    // 根据是否为绑定模式显示不同的提示
    final successMessage = binding! ? 'binding success' : 'login success';
    Toast.showText(text: successMessage);

    if (data["status"] != 200) return;

    final LoginInfoBean userInfo = LoginInfoBean.fromJson(data["data"]);
    userInfo.isFormal = 1;

    LaunchInfoBean? launchInfo = Get.find<LaunchController>().launchInfo;
    launchInfo?.userId = userInfo.userId;
    launchInfo?.isVip = userInfo.isVip;
    launchInfo?.token = userInfo.token;
    launchInfo?.isFormal = userInfo.isFormal ?? 1;

    ///存储本地信息
    setToken(userInfo.token)?.then((onValue) {
      if (onValue) {
        Get.find<UserController>().reloadUserInfo(
          successAction: (userInfo) {
            if (Get.isRegistered<LoginController>()) {
              Get.back();
              final LoginController login = Get.find<LoginController>();
              if (login.showEmailPage == true) {
                Get.back();
              }
            }
            FirebaseAnalytics.instance.logLogin(
              loginMethod: type.toString().split('.').last,
            );
            /// 显示赠送字数弹窗
            FirstLoginDialogManager.showLoginDialog(launchInfo?.hasGiveWords! == 1);
            onSuccess?.call(data, 1);
          },
        );
      }
    });
  }
}