/*
 * @Author: duncy
 * @Date: 2025-10-13 14:37:06
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2026-03-02 13:49:48
 * @FilePath: /novel_oversea/lib/global/pay/controller/pay_controller.dart
 * @Description: 
 */


import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:novel_oversea/core/pay/pay_manager.dart';
import 'package:novel_oversea/global/launch/controller/launch_controller.dart';
import 'package:novel_oversea/global/pay/bean/integral_pay_list_bean.dart';
import 'package:novel_oversea/global/pay/bean/vip_type_bean.dart';
import 'package:novel_oversea/global/pay/controller/pay_style_manager.dart';
import 'package:novel_oversea/global/pay/view/vip_to_credits_dialog.dart';
import 'package:novel_oversea/global/routes/app_pages.dart';
import 'package:novel_oversea/home/main/controller/home_controller.dart';
import 'package:novel_oversea/me/user/user.dart';

import '../view/home_discount_dialog.dart';

///付费类型
enum PayType {
  ///vip付费
  vip,
  ///增加token付费
  token,
}

class PayController extends GetxController {
  
  PayManager payManager = PayManager();

  ///付费页类型
  Rx<PayType> payType = PayType.vip.obs;

  ///是否是流程引导页
  bool isGuide = false;

  ///付费页样式管理器
  late PayStyleManager styleManager;

  ///是否需要回到主页
  bool returnHome = false;

  ///试用开关
  bool trialSwitch = true;

  ///来源位置
  int sourcePosition = 4;

  final UserController user = Get.find<UserController>();

  ///付费页说明
  List<String> guideTips = const [
    "Improve work efficiency by more than 30%",
    "No watermark, more professional",
    "Save paper, always protect the environment",
    "No ads, more comfortable experience",
  ];

  @override
  void onInit() {
    super.onInit();
    payType.value = user.isVip ? PayType.token : PayType.vip;
    final args = Get.arguments as Map<String, dynamic>?;
    isGuide = args?['guide'] ?? false;
    returnHome = args?['isBackHome'] ?? false;
    sourcePosition = args?['sourcePosition'] ?? 4;

    ///更新主页小条状态
    if (Get.isRegistered<HomeController>() &&
        !payManager.payData.hasEnteredVip) {
      final HomeController home = Get.find<HomeController>();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        home.updataRetainValue();
      });
    }
    payManager.payData.hasEnteredVip = true; 

    ///付费页数据未加载时
    if(payManager.payData.vipList.isEmpty || payManager.payData.vipInterceptList.isEmpty) {
      if(!isGuide) {
        payManager.payData.init();
      }
    }

    if(!isGuide) {
      guideTips = const [
        "Unlimited Story Generation – Write without limits.",
        "Advanced AI Assistance – From idea to full draft in minutes.",
        "Voice & Text Input – Just speak or type and watch your novel come alive.",
        "Priority Updates & Exclusive Features – Get early access and lifetime perks."];
    }

    getPayPageStyle();
    payManager.payEngine.sourceType = sourcePosition;
    payManager.initManager(
      payType.value == PayType.vip ? 0 : 1,
      success: () {
        try {
          dynamic package;
          if (showTrial()) {
            package = getTrialPackage(trialSwitch);
          } else {
            package = getCurrentDataList()[payManager.selectIndex.value];
          }
          FirebaseAnalytics.instance.logPurchase(
            parameters: {
              'type': payType.value == PayType.vip ? 0 : 1,
              'value': getPrice(package),
              'item_id': package.appleVipId,
              'item_name': package.title,
              'source_type': sourcePosition
            },
          );
        } catch (e) {
          // print('_____付费页日志: 记录购买日志失败 $e');
        }
        if (isGuide) {
          Get.offNamed(Routes.main);
          VipToCreditsDialogManager.showRetainDialog(
              action: () {
                user.jumpToPayPage();
              }
            );
        } else {
          Get.back();
          if(payType.value == PayType.vip) {
            VipToCreditsDialogManager.showRetainDialog(
              action: () {
                user.jumpToPayPage();
              }
            );
          }
        }
      },
    );
  }

  ///获取付费页样式
  void getPayPageStyle() {
    String landingPage = Get.find<LaunchController>().launchInfo?.config?.landingPage ?? "";
    if(!landingPage.contains('pay_center_page__')) {
      landingPage = "pay_center_page__1__1";
    }
    int screenType = 1;
    int style = 1;
    try {
      screenType = int.parse(landingPage.split('__')[1]);
      ///检查横竖屏是否配置错误
      if (![0, 1].contains(screenType)) {
        screenType = 1;
      }
      ///检查样式是否配置错误
      style = int.parse(landingPage.split('__')[2]);
      if (![1, 2].contains(style)) {
        style = 1;
      }
    }
    catch(e) {
      // throw(e);
    }
    ///字数包默认样式
    if(payType.value == PayType.token) {
      screenType = 1;
      style = 1;
    }
    styleManager = PayStyleManager(
      type: screenType,
      style: style, // 1: 默认样式, 2: 黑色样式,
    );
  }

  ///获取80%折扣比例的原价
  double getPriceForDiscount(VipTypeBean bean) {
    try {
      // double money = double.parse(bean.money);
      double money = double.parse(getPrice(bean,).replaceAll(styleManager.getLocalSymbol(bean), ''));

      return (money * 5 * 100).floor()/100;
    }
    catch(e) {
      return double.parse(bean.money) * 5;
    }
  }

  ///获取当前套餐折扣比例
  int getPackageDiscount(VipTypeBean bean) {
    try {
      // double money = double.parse(bean.money);
      double money = double.parse(getPrice(bean, isDiscount: true).replaceAll(styleManager.getLocalSymbol(bean), ''));
      // double crossMoney = double.parse(bean.crossedMoney ?? '0');
      double crossMoney = double.parse(getPrice(bean).replaceAll(styleManager.getLocalSymbol(bean), ''));
      if(crossMoney > money) {
        return ((1 - money/crossMoney) * 100).floor();
      }
    }
    catch(e) {
      return 0;
    }
    return 0;
  }

  ///获取当前套餐数据
  List<dynamic> getCurrentDataList() {
    ///引导页非试用套餐
    if(isGuide) {
      return payManager.payData.vipListTrialUse.cast<VipTypeBean>().toList();
    }
    final List<dynamic> dataList = payType.value == PayType.vip
        ? payManager.payData.vipList.cast<VipTypeBean>().toList()
        : payManager.payData.wordsPackageList.cast<IntegralPayListBean>().toList();
    return dataList;
  }

  ///获取免费试用套餐
  VipTypeBean getTrialPackage(bool isOn) {
    if(isOn) {
      try {
        sourcePosition = 1;
        return payManager.payData.vipListTrialOn.first;
      }
      catch(e) {
        sourcePosition = 4;
        return payManager.payData.vipList.first;
      }
    }
    else {
      sourcePosition = 1;
      return payManager.payData.vipListTrialOff.first;
    }
  }

  ///是否显示免费使用套餐
  bool showTrial() {
    if(isGuide && payManager.payData.hasTrial.value && payManager.payData.vipListTrialOn.isNotEmpty && payManager.payData.vipListTrialOff.isNotEmpty) {
      return true;
    }
    return false;
  }

  ///套餐切换
  void switchVipListCurrent(int index) {
    payManager.selectIndex.value = index;
  }

  /// 获取套餐按钮文案
  String getPackageButtonText({VipTypeBean? bean}) {
    String buttonTitle = "Purchase";
    if(bean != null) {
      return bean.buttonTitle ?? buttonTitle;
    }
    buttonTitle = getCurrentDataList()[payManager.selectIndex.value].buttonTitle;
    return buttonTitle;
  }

  ///开始支付
  void startPay({VipTypeBean? bean}) {
    payManager.startPay(bean: bean);
    dynamic package = bean;
    if (bean == null) {
      if (showTrial()) {
        package = getTrialPackage(trialSwitch);
      } else {
        package = getCurrentDataList()[payManager.selectIndex.value];
      }
    }
    FirebaseAnalytics.instance.logEvent(
        name: 'start_purchase',
        parameters: {
          'item_id': package.appleVipId,
          'source_type': sourcePosition  /// 支付页位置
        },
      );
  }

  ///获取价格
  String getPrice(dynamic package, {bool isDiscount = false}) {
    return styleManager.getPrice(package, isDiscount: isDiscount);
  }


  ///关闭支付页,检查是否需要二次弹窗
  void closePayPage() async{
    if(payType.value == PayType.token || payManager.payData.vipList.isEmpty) {
      closeAndBack();
      return;
    }
    if(payManager.payData.vipInterceptList.isNotEmpty) {
      // final result = await Get.bottomSheet(
      //   const HomeDiscountDialog(),
      //   isDismissible: false,
      //   isScrollControlled: true,
      //   enableDrag: false,
      // );
      // if (result == "true") {
      //   startPay();
      // } else {
      //   closeAndBack();
      // }
      await Get.bottomSheet(
        const HomeDiscountDialog(isHomeGift: false,),
        isDismissible: false,
        isScrollControlled: true,
        enableDrag: false,
      );
      closeAndBack();
    }
    else {
      closeAndBack();
    }
  }

  ///关闭返回
  void closeAndBack() {
    if (returnHome) {
      Get.offAllNamed(Routes.main);
    } else {
      Get.back();
    }
  }

  @override
  void onClose() {
    super.onClose();
    payManager.dispose();
  }
}