/*
 * @Author: duncy
 * @Date: 2025-09-23 09:45:36
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2026-01-20 16:55:11
 * @FilePath: /novel_oversea/lib/core/pay/pay_manager.dart
 * @Description: 
 */


import 'dart:async';
import 'dart:io';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:novel_oversea/core/common/event/common_event.dart';
import 'package:novel_oversea/core/network/http_utils.dart';
import 'package:novel_oversea/core/network/novel_apis.dart';
import 'package:novel_oversea/core/pay/pay_engine.dart';
import 'package:novel_oversea/core/ui/dialog/loading_dialog.dart';
import 'package:novel_oversea/core/ui/dialog/toast.dart';
import 'package:novel_oversea/core/ui/view/by_common_utils.dart';
import 'package:novel_oversea/global/launch/controller/launch_controller.dart';
import 'package:novel_oversea/global/launch/controller/launch_manager.dart';
import 'package:novel_oversea/global/pay/bean/vip_type_bean.dart';
import 'package:novel_oversea/me/user/user.dart';

import '../../global/routes/app_pages.dart';


class SinglePayManager {

  ///套餐数据
  VipTypeBean bean;

  PayManager payManager;

  ///是否需要回到主页
  bool? returnHome;

  /// 支付页位置
  int sourcePosition;

  SinglePayManager(this.bean, this.payManager, {this.returnHome = true, required this.sourcePosition});

  void init() {
    payManager.payEngine.sourceType = sourcePosition;
    payManager.initManager(0, success: () {
      FirebaseAnalytics.instance.logPurchase(
        parameters: {
          'type': 0,
          'value': getPrice(),
          'item_id': bean.appleVipId,
          'item_name': bean.title,
          'source_type': sourcePosition,
        },
      );
      if(returnHome!) {
        Get.offNamed(Routes.main);
      }
      else {
        Get.back();
      }
    },);
  }

  ///开始支付
  void startPay() {
    payManager.startPay(bean: bean);
    FirebaseAnalytics.instance.logEvent(
      name: 'start_purchase',
        parameters: {
          'item_id': bean.appleVipId,
          'source_type': sourcePosition,
        }
      );
  }

  ///获取本地符号
  String getLocalSymbol() {
    return bean.localSymbol!.isNotEmpty ? bean.localSymbol! : '\$';
  }

  ///获取价格
  String getPrice({bool isDiscount = false,}) {
    try {
      String price = isDiscount ? bean.discountLocalPrice! : bean.localPrice!;
      return price.isNotEmpty ? price : '\$${bean.money}';
    }
    catch(e) {
      return '\$${bean.money}';
    }
  }

  ///获取均价, 0表示每日均价， 1表示每月
  String getAveragePrice({bool isDiscount = false, int type = 0}) {
    String localprice = getPrice(isDiscount: isDiscount);
    int average = bean.day!;
    if(type == 1 && bean.vipLevel! > 30) {
      average = (bean.day!/365 * 12).ceil();
    }
    try {
      double price = double.parse(localprice.replaceAll(bean.localSymbol!, '')) ;
      return '${(price/average * 100).round()/100}';
    }
    catch(e) {
      return '${(double.parse(localprice.replaceAll(getLocalSymbol(), ''))/average * 100).round()/100}';
    }
  }

  ///获取均价, 0表示每日均价， 1表示每月
  String getAverageText() {
    if(bean.vipLevel! > 30) {
      return '/mo';
    }
    return '/day';
  }

  /// 获取套餐按钮文案
  String getButtonText() {
    String buttonTitle = "Purchase";
    return bean.buttonTitle ?? buttonTitle;
  }

  void dispose() {
    payManager.dispose();
  }

}


class PayManager {
  PayEngine payEngine = PayEngine();
  ///创建订单的配置ID
  String createOrderID = '';
  ///支付订单ID
  String orderID = '';
  ///苹果支付成功后查询订单状态的监听
  late StreamSubscription paySuccessSubscription;
  ///付费页数据
  PayData payData = Get.find<PayData>();
  ///选中的会员套餐
  RxInt selectIndex = 0.obs;
  ///类型
  int payType = 0; //0 会员 1 积分
  ///是否正在查询支付订单
  bool isQuerying = false;

  Function ()? completePay;

  ///初始化
  void initManager(int type, {Function()? success}) {
    payType = type;
    payEngine.initializeInAppPurchase(isComsume: payType == 1);
    payEngine.onPayStatus = (status) {
      if (status == PurchaseStatus.purchased || status == PurchaseStatus.restored || status == PurchaseStatus.error || status == PurchaseStatus.canceled) {
        LoadingDialog().dismiss();
      } else if (status == PurchaseStatus.pending) {
        LoadingDialog().show(message: 'order pending...');
      }
    };
    completePay = success;
    payResult();
  }

  /*
    平台支付成功后
  */
  ///监听支付结果
  void payResult() {
      paySuccessSubscription =
          eventBus.on<QueryOrderEvent>().listen((event) {
            Get.log('__________监听订单status：${event.product.status}，——————$createOrderID,   ==>>${event.product.purchaseID}， ==>>${event.product.productID}}');
            Get.log('__________监听订单status===== >>>>>${event.product.status}：${event.product.verificationData.serverVerificationData}');
        ///已经购买
        if(event.product.productID == createOrderID && event.product.status == PurchaseStatus.purchased) {
          queryOrder(event.product, receiptData: event.product.verificationData.serverVerificationData);
        }
        ///恢复购买
        else if(event.product.status == PurchaseStatus.restored) {
          createOrderID = '';
          orderRestore(event.product);
        }
      });
  }

  ///iOS 恢复购买
  void orderRestore(
    PurchaseDetails detail,{
    void Function()? onSuccess,
    void Function()? onFailed,
    }) {
    if(detail.verificationData.serverVerificationData.isEmpty || isQuerying){
      return;
    }
    isQuerying = true;
    LoadingDialog().show(message: "order restoring...");
    HttpUtils.post(
      NovelApis.iOSRestorePurchase, 
      {
        'product_id': detail.productID,
        'transaction_id': detail.purchaseID,
        'receipt_data': detail.verificationData.serverVerificationData,
      },
      showMsgWhenFailed: false,
      success: (data) {
        LoadingDialog().dismiss();
        isQuerying = false;
        successPay(isRestore: true);
        onSuccess?.call();
      },
      fail: (code, msg) {
        LoadingDialog().dismiss();
        Toast.showText(text: "No subscription record found.");
        isQuerying = false;
        onFailed?.call();
      });
  }

  ///vip订单查询
  void queryOrder(
    PurchaseDetails detail,
    {
    void Function()? onSuccess,
    void Function()? onFailed,
    String? receiptData,
    int retryCount = 0,
  }) {
    if(orderID.isEmpty || isQuerying){
      return;
    }
    Map<String, dynamic> params = {
      "order_no": orderID,
    };

    if (receiptData != null) {
      params["receipt_data"] = receiptData;
    }
    if (retryCount > 15) {
      // showConfirmDialog();
      LoadingDialog().dismiss();
      onFailed?.call();
      return;
    }
    isQuerying = true;
    LoadingDialog().show(message: "order checking...");
    HttpUtils.post(
      payType == 0 ? NovelApis.orderQuery : NovelApis.tokenQuery,
      params,
      showMsgWhenFailed: false,
      success: (data) {
        isQuerying = false;
        byDebugPrint(data["data"], tag: "订单状态:");
        final status = data["data"]["order_status"] ?? "";
        if (status == "SUCCESS") {
          LoadingDialog().dismiss();
          onSuccess?.call();
          payEngine.completePurchase(detail);
          successPay();
        } else if (status == "FAIL") {
          LoadingDialog().dismiss();
          onFailed?.call();
        } else {
          Future.delayed(const Duration(seconds: 2), () {
            queryOrder(detail, receiptData: receiptData, retryCount: retryCount + 1);
          });
        }
      },
      fail: (code, msg) {
        isQuerying = false;
        LoadingDialog().dismiss();
        Toast.showText(text: msg);
      },
    );
  }

  ///支付成功
  void successPay({bool isRestore = false}) {
    completePay?.call();
    LoadingDialog().dismiss();
    Toast.showText(text: "Purchase success.");
    /// 充值成功更新用户信息
    if(isRestore) {
      ///退出登录
      
      Get.find<LaunchController>().appLaunch();
      return;
    }
    Get.find<UserController>().reloadUserInfo();
  }

  /*
    平台支付流程
  */
  ///开始支付
  void startPay({VipTypeBean? bean}) {
    LoadingDialog().show(message: 'purchasing...');
    getCreateOrderId(bean: bean);
  }
  ///获取创建会员套餐ID
  void getCreateOrderId({VipTypeBean? bean}) {
    dynamic package = bean;
    if(package == null) {
      if(payType == 0) {
        package = payData.vipList[selectIndex.value];
      } else {
        package = payData.wordsPackageList[selectIndex.value];
      }
    }
    String packageID = package.id;
    createOrderID = package.appleVipId;
    FirebaseAnalytics.instance.logBeginCheckout(
      parameters: {
        'type': payType,
        'item_id': package.appleVipId,
        'item_name': package.title,
      },
    );
    fetchOrderID(packageID);
  }

  ///获取套餐订单ID
  void fetchOrderID(String packageID) {
    HttpUtils.post(
      payType == 0 ? NovelApis.orderCreate : NovelApis.tokenCreate,
      showMsgWhenFailed: false,
      {
        "pay": Platform.isIOS ? "apple" : "google",
        "config_id": packageID,
        "support_pays": Platform.isIOS ? "apple" : "google",
      },
      success: (data) {
        byDebugPrint(data["data"], tag: "创建支付订单:");
        orderID = data["data"]["id"];
        platformPay();
      },
      fail: (code, msg) {
        LoadingDialog().dismiss();
        Toast.showText(text: msg);
      },
    );
  }

  ///平台支付开始
  void platformPay() {
    if (createOrderID.isEmpty) {
      Toast.showText(text: "No products, try again.");
      LoadingDialog().dismiss();
      return;
    }
    LoadingDialog().show(message: 'purchasing...');
    payEngine.loadProductDataAndBuy(createOrderID, orderID);
  }

  ///释放资源
  void dispose() {
    paySuccessSubscription.cancel();
  }
}