/*
 * @Author: duncy
 * @Date: 2025-10-30 17:38:46
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2026-01-21 18:22:45
 * @FilePath: /novel_oversea/lib/global/launch/controller/guide_step_controller.dart
 * @Description: 
 */



import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:novel_oversea/core/pay/pay_manager.dart';
import 'package:novel_oversea/global/pay/bean/vip_type_bean.dart';
import 'package:novel_oversea/global/routes/app_pages.dart';

class GuideStepController extends GetxController {

  PayManager payManager = PayManager();

  PageController pageController = PageController();

  late final VipTypeBean selectPackage;

  ///当前index
  int currentIndex = 0;



  @override
  void onInit() {
    super.onInit();

    payManager.payEngine.sourceType = 3;
    payManager.initManager(0, success: () {
      FirebaseAnalytics.instance.logPurchase(
        parameters: {
          'type': 0,
          'value': getPrice(),
          'item_id': selectPackage.appleVipId,
          'item_name': selectPackage.title,
          'source_type': 3  /// 支付页位置
        },
      );
      Get.offNamed(Routes.main);
    },);
    selectPackage  = payManager.payData.vipListGuide.first;
  }

  ///开始支付
  void startPay() {
    payManager.startPay(bean: selectPackage);
    FirebaseAnalytics.instance.logEvent(
        name: 'start_purchase',
        parameters: {
          'item_id': selectPackage.appleVipId,
          'source_type': 3  /// 支付页位置
        },
      );
  }

  ///获取价格
  String getPrice() {
    try {
      return selectPackage.localPrice!.isNotEmpty ? selectPackage.localPrice! : '\$${selectPackage.money}';
    }
    catch(e) {
      return '\$${selectPackage.money}';
    }
  }

  @override
  void onClose() {
    super.onClose();
    payManager.dispose();
  }
}