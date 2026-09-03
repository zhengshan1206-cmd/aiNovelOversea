
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:novel_oversea/core/cache/byhy_aes_storage_utils.dart';
import 'package:novel_oversea/core/network/apis.dart';
import 'package:novel_oversea/core/network/http_utils.dart';
import 'package:novel_oversea/core/service/words.dart';
import 'package:novel_oversea/core/ui/dialog/toast.dart';
import 'package:novel_oversea/global/const/const_string.dart';
import 'package:novel_oversea/global/login/controller/login_manager.dart';
import 'package:novel_oversea/global/routes/app_pages.dart';
import 'package:novel_oversea/me/user/user_bean.dart';

import '../../core/network/novel_apis.dart';


class UserController extends GetxController {
  ///用户信息
  final Rx<UserInfoBean?> userInfoBean = Rx<UserInfoBean?>(null);

  ///是否可以前置登录
  bool isPreLogin = false;

  /// 存储被前置登录限制的操作回调
  VoidCallback? _pendingActionCallback;

  ///是否可以尝试
  bool couldTry = false;

  ///是否是游客，当前是否未登录
  bool get isVisitor {
    return userInfoBean.value?.isFormal == 0;
  }

  ///是否是会员
  bool get isVip {
    return userInfoBean.value?.isVip == 1;
  }

  @override
  void onInit() { 
    super.onInit();
    initLocalUserData();
  }

  ///初始化本地用户数据
  void initLocalUserData() {
    final String userData = ByStorageUtils.getString(ConstString.kUserData) ?? '';
    if (userData.isEmpty) {
      return;
    }
    UserInfoBean bean = UserInfoBean.fromJson(jsonDecode(userData));
    userInfoBean.value = bean;
  }


  ///初始化loading用户信息
  void initinfo() {
    reloadUserInfo();
    getCouldUse();
    // preLoginConfig();
  }

  ///获取用户当前字数包字数
  ///是否需要显示详细字数
  String getUserWords({bool? needDetail = false}) {
    final userInfo = userInfoBean.value;
    final words = userInfo?.wordsPack != null ? '${userInfo?.wordsPack}' : '0';
    if (needDetail!) {
      return words;
    }
    return WordsService.wordsDisplay(words);
  }

  Future<void> getUserInfo({
    void Function(UserInfoBean? userInfo)? onSuccess,
  }) async {
    HttpUtils.get(
      APIs.loadUserInfo,
      {},
      success: (data) {
        final userInfoData = data["data"];
        UserInfoBean bean = UserInfoBean.fromJson(userInfoData);
        userInfoBean.value = bean;
        ByStorageUtils.saveString(ConstString.kUserData, jsonEncode(userInfoData));
        onSuccess?.call(bean);
      },
      fail: (code, msg) {

      },
    );
  }

  ///更新用户信息
  Future reloadUserInfo(
      {void Function(UserInfoBean? userInfo)? successAction,
      VoidCallback? goBack}) async {
    await getUserInfo(onSuccess: (userInfo) {
      Get.log("保存用户数据===>${userInfo?.toJson()}");
      if (goBack != null) {
        goBack();
      }
      if (successAction != null) {
        successAction(userInfo);
      }
    });
  }

  ///获取是否可以尝试
  void getCouldUse(){

    HttpUtils.post(NovelApis.isAllowTryout, {}, success: (data) {
      if(data["data"]!=null){
        if(data["data"]["result"] != null){
          couldTry = data["data"]["result"];
        }
      }
      Get.log("获取是否可以尝试===>$data  couldTry==>$couldTry");
    }, fail: (code, msg) {
      // BotToast.showText(text: msg);
    });
  }

  ///清空用户信息
  void clearUserInfo() {
    userInfoBean.value = null;
  }

  /// 获取所有配置
  void preLoginConfig({
    void Function()? onSuccess,
  }) {
    HttpUtils.get(
      APIs.getConfig,
      {"group": "xiao_shuo_chuang_zuo_jing_ling"},
      success: (data) {
        try {
          final config = data["data"]["deng_lu_qian_zhi"];
          if (config != null && config is! List) {
            if (config['val_text'] == "1") {
              isPreLogin = true;
              update();
            }
          }
        } catch (e) {
          // throw(e);
        }
      },
      fail: (code, msg) {
        Toast.showText(text: msg);
      },
    );
  }

  ///根据启动页下发路径，跳转不同付费页面
  ///是否直接返回首页，默认false
  ///是否需要显示特定的付费SKU弹窗
  ///[isWordsEmpty]字数包付费页样式
  void jumpToPayPage({String? payPage, bool isBackHome = false, String source = 'unknown', void Function()? back}) {
    Get.toNamed(
      Routes.payCenterPage,
      arguments: {
        'isBackHome': isBackHome,
      },
    )?.then((_) {
      back?.call();
    });
  }

  ///检查是否前置登录
  /// [actionCallback] 如果需要登录，登录成功后要执行的操作

  void checkPreLogin({VoidCallback? actionCallback, String? source, bool binbing = false}) {
    if (isPreLogin && userInfoBean.value?.isFormal == 0 && !binbing) {
      // 保存被限制的操作回调
      if (actionCallback != null) {
        _pendingActionCallback = actionCallback;
      }
      LoginManager.login(
          source: source,
          successLogin: _executePendingAction);
    } else {
      ///未开启前置登录，未登录并且是会员，则强制绑定
      // if (userInfoBean.value?.isFormal == 0 && userInfoBean.value?.isVip == 1) {
      //   LoginManager.login(
      //     source: source,
      //     successLogin: _executePendingAction);
      //   _executePendingAction();
      //   return;
      // }
      actionCallback?.call();
    }
  }

  /// 执行被前置登录限制的操作
  void _executePendingAction() {
    if (_pendingActionCallback != null) {
      _pendingActionCallback!();
      _pendingActionCallback = null; // 执行后清空回调
    }
  }

  /// 清除待执行的操作（用于正常关闭登录页面时）
  void clearPendingAction() {
    _pendingActionCallback = null;
  }
}
