/*
 * @Author: duncy
 * @Date: 2026-01-07 11:14:18
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2026-01-09 18:49:44
 * @FilePath: /novel_oversea/lib/home/main/controller/new_user_pay_controller.dart
 * @Description: 
 */


import 'package:get/get.dart';
import 'package:novel_oversea/core/pay/pay_manager.dart';
import 'package:novel_oversea/global/launch/controller/launch_manager.dart';
import 'package:novel_oversea/global/pay/bean/vip_type_bean.dart';


enum SinglePayType{

  ///默认
  defalut,

  ///首次进入
  firstIn,

  ///登录关闭后
  loginClose,
}

class NewUserPayController extends GetxController {


  late final SinglePayManager pay;

  SinglePayType payType = SinglePayType.defalut;

  int sourcePosition = 1;

  @override
  void onInit() {

    final args = Get.arguments as Map<String, dynamic>?;
    payType = args?['type'] ?? SinglePayType.defalut;
    
    VipTypeBean bean = _getBean();
    pay = SinglePayManager(bean, PayManager(), returnHome: false, sourcePosition: sourcePosition);
    pay.init();
    super.onInit();
  }

  ///根据类型获取套餐数据
  VipTypeBean _getBean() {
    

    switch (payType) {
      case SinglePayType.firstIn:
        sourcePosition = 8;
        return GlobalController.instance.pay.vipListGuideDialogClose.first;
      case SinglePayType.loginClose:
        sourcePosition = 9;
        return GlobalController.instance.pay.vipListLoginClose.first;
      case SinglePayType.defalut:
        sourcePosition = 4;
        return GlobalController.instance.pay.vipList.first;
    }
  }

  @override
  void onClose() {
    pay.dispose();
    super.onClose();
  }
}