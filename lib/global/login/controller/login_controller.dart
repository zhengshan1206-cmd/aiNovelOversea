import 'dart:async';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:novel_oversea/core/network/apis.dart';
import 'package:novel_oversea/core/network/http_utils.dart';
import 'package:novel_oversea/core/ui/dialog/loading_dialog.dart';
import 'package:novel_oversea/core/ui/dialog/toast.dart';
import 'package:novel_oversea/global/const/consts.dart';
import 'package:novel_oversea/global/launch/controller/launch_manager.dart';
import 'package:novel_oversea/global/login/controller/firebase_auth.dart';
import 'package:novel_oversea/global/login/controller/login_manager.dart';
import 'package:novel_oversea/me/user/user.dart';
import '../../../core/util/by_device_info_utils.dart';

enum LoginType { oneKey, phone, wx, apple, facebook, google, email }


// firebase设备类型 0.未知 1.匿名 2.电话 3.电子邮件地址/密码 4.Google 5.Apple 6.Twitter 7.GitHub 8. Yahoo 9. Facebook 10.Microsoft 11.Play 游戏 12.Game Center
extension LoginTypeExt on LoginType {
  int get typeIndex {
    switch (this) {
      case LoginType.apple:
        return 5;
      case LoginType.google:
        return 4;
      case LoginType.email:
        return 3;
      case LoginType.facebook:
      case LoginType.oneKey:
      case LoginType.phone:
      case LoginType.wx:
        return 0; // 微信登录未集成firebase
    }
  }
}


class LoginController extends GetxController {

  /// 登录方式，默认为一键登录
  Rx<LoginType> loginType = LoginType.wx.obs;

  /// 用来记录上次的页面
  List<LoginType> pages = [];

  /// 是否允许点击登陆按钮
  Rx<bool> loginEnbled = false.obs;

  /// 手机号
  Rx<String> phoneNO = ''.obs;

  /// 验证码
  String vCode = '';

  /// 是否允许点击验证码按钮
  Rx<bool> vCodeBtnEnabled = false.obs;

  ///是否只允许手机登录
  bool? onlyPhone = false;

  Function? loginSuccess;

  /// 登录成功后的回调函数
  VoidCallback? onLoginSuccessCallback;

  /// 手机号是否有输入
  Rx<bool> isInputedPhone = false.obs;

  ///验证码是否错误
  Rx<bool> vcodeInputRight = true.obs;

  ///是否正在登录中
  Rx<bool> isLogin = false.obs;

  ///邮箱是否输入正确
  Rx<bool> emailValid = false.obs;

  ///是否显示邮箱登录页面
  bool showEmailPage = false;

  final FocusNode phoneNode = FocusNode();
  final FocusNode codeNode = FocusNode();

  LoginController({
    this.onLoginSuccessCallback,
    this.binding,
    this.isGuide,
    this.source,
  });

  final bool? binding;
  final String? source;
  final bool? isGuide;

  // late final OneKeyController oneKey;


  @override
  void dispose() {
    // 清理其他资源
    _clearPhoneAndPwd();

    // 如果是正常关闭（不是登录成功），清除待执行的操作
    if (onLoginSuccessCallback == null) {
      Get.find<UserController>().clearPendingAction();
    }
    super.dispose();
  }

  ///游客身份进入付费页
  void visitorForPayPage() {
    // 清除待执行的操作
    Get.find<UserController>().clearPendingAction();
    Get.back();
    Get.find<UserController>().jumpToPayPage();
  }

  ///更改验证手机号
  void changePhoneNO(String phone) {
    phoneNO.value = phone;
    isInputedPhone.value = true;
    vCodeBtnEnabled.value = checkVCodeBtnEnabled();
    loginEnbled.value = checkLoginBtnEnabled();
  }

  ///更改验证验证码
  void changeVCode(String code) {
    vCode = code;
    loginEnbled.value = checkLoginBtnEnabled();
    // 验证是否为4位数字
    if (RegExp(r'^\d{4}$').hasMatch(code)) {
        if (!loginEnbled.value) return;
        loginWithVCode(Get.context!);
    }
  }

  /// 检查登录按钮是否可用
  bool checkLoginBtnEnabled() => (phoneNO.value.length == 11 && vCode.length == 4);

  /// 检查验证码按钮是否可用
  bool checkVCodeBtnEnabled() =>
      (phoneNO.value.length == 11 || !isInputedPhone.value);

  void checkEmailEnable(String input) {
    if(isCheckAccount(input)) {
      emailValid.value = true;
      return;
    }
    // 邮箱正则表达式
    final regex = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&\'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$",
    );
    emailValid.value = regex.hasMatch(input);
  }

  ///检查是否是测试账号
  bool isCheckAccount(String input) {
    return input == Consts.vipTestAccount;
  }

  ///firebase登录Action
  void firebaseLoginAction(LoginType type) async{
    LoadingDialog().show();
    FirebaseAnalytics.instance.logEvent(name: source == 'new_user' ? 'OB_login_click' : 'login_attempt', parameters: {
      'method': type.toString().split('.').last,
    });
    FirebaseUser? user;
    switch (type) {
      case LoginType.apple:
        user = await LoginUtil.signInWithApple();
      case LoginType.google:
        user = await LoginUtil.signInWithGoogle();
        break;
      case LoginType.email:
        user = await LoginUtil.signInWithEmail('');
        return;
      case LoginType.facebook:
      case LoginType.oneKey:
      case LoginType.phone:
      case LoginType.wx:
        break;
    }
    print('_____user:::==>>> $user');
    if(user != null && user.uid != null) {
      firebaseLogin(user, type);
    }
    else {
      LoadingDialog().dismiss();
      Toast.showText(text: "Authentication failed!");
    }
  }

  ///firebase登录
  void firebaseLogin(FirebaseUser user, LoginType type) async {
    if (isLogin.value) {
      return;
    }
    isLogin.value = true;
    LoginManager.createLogin(
      user, 
      type,
      onSuccess: (data, type) async{
        if(type == 0) {
          isLogin.value = false;
        }
        if(type == 1) {
          _handleLoginSuccess();
        }
      },
      onFailed: (code, msg) {
        isLogin.value = false;
        Toast.showText(text: msg);
      });
  }

  /// 手机号登陆,获取验证码
  void getVCode({
    void Function(dynamic)? onSuccess,
    void Function(int, String)? onFailed,
  }) async {
    final imei = await ByDeviceInfoUtils.deviceInfo();
    HttpUtils.post(
      APIs.sendVCode,
      {
        "phone": phoneNO.value,
        "uuid": imei.item2,
      },
      success: (data) {
        FocusScope.of(Get.context!).requestFocus(codeNode);
        Toast.showText(text: data["message"]);
        onSuccess?.call(data);
      },
      fail: (code, msg) {
        onFailed?.call(code, msg);
        Toast.showText(text: msg);
      },
    );
  }

  void loginWithVCode(
    BuildContext context, {
    String? code,
    String? phone,
    void Function()? onSuccess,
    void Function(int, String)? onFailed,
  }) async {
    if (isLogin.value) {
      return;
    }
    final imei = await ByDeviceInfoUtils.deviceInfo();
    isLogin.value = true;
    HttpUtils.post(
      APIs.loginByPhone,
      {
        "phone": phone ?? phoneNO.value,
        "code": code ?? vCode,
        "uuid": imei.item2,
      },
      success: (data) async {
        isLogin.value = false;
        await LoginManager.handleLoginResponse(
          data,
          onSuccess: (data, type) {
            _handleLoginSuccess();
          },);
        if (data["status"] == 200) {
          onSuccess?.call();
        } else {
          vcodeInputRight.value = false;
        }
      },
      fail: (code, msg) {
        isLogin.value = false;
        vcodeInputRight.value = false;
        onFailed?.call(code, msg);
        Toast.showText(text: msg);
      },
    );
  }

  /// 登录成功后的处理
  void _handleLoginSuccess() {
    // 执行登录成功回调
    if (onLoginSuccessCallback != null) {
      onLoginSuccessCallback!();
    }
    // 延迟销毁控制器，确保页面已经完全关闭
    Future.delayed(const Duration(milliseconds: 100), () {
      if (Get.isRegistered<LoginController>()) {
        Get.delete<LoginController>();
      }
    });
  }

  /// 清除手机号和验证码
  void _clearPhoneAndPwd() {
    phoneNO.value = "";
    vCode = "";
    loginEnbled.value = false;
  }

  ///根据标题匹配跳转协议
  void getProtocolByTitle(String title) {
    GlobalController.instance.config.goPrivacyPageWithTitle(title);
  }
}
