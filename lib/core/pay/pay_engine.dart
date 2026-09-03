import 'dart:async';
import 'dart:io';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';
import 'package:novel_oversea/core/common/event/common_event.dart';
import 'package:novel_oversea/core/ui/dialog/loading_dialog.dart';
import 'package:novel_oversea/core/ui/dialog/toast.dart';
import 'package:novel_oversea/core/ui/view/by_common_utils.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';

///ios 支付工具
class PayEngine {
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  late InAppPurchase _inAppPurchase;
  List<ProductDetails> _products = [];

  ///内购的商品对象集合
  // late final StreamSubscription _iosBuyStreamSubscription;

  bool purchaseSuccess = false;

  void Function(PurchaseStatus)? onPayStatus; 

  ///是否是消耗性物品，消耗性物品可重复购买
  bool _isComsume = false;

  /// 界面来源
  int sourceType = 3;

  //初始化购买组件
  void initializeInAppPurchase({bool? isComsume = false}) {
    /// 初始化in_app_purchase插件
    _inAppPurchase = InAppPurchase.instance;
    _isComsume = isComsume!;
    //监听购买的事件
    final Stream<List<PurchaseDetails>> purchaseUpdated =
        _inAppPurchase.purchaseStream;
    _subscription = purchaseUpdated.listen((purchaseDetailsList) {
      _listenToPurchaseUpdated(purchaseDetailsList);
    }, onDone: () {
      _subscription.cancel();
    }, onError: (error) {
      error.printError();
      byDebugPrint("===购买失败了");
    });
  }

  void resumePurchase() async{
    _inAppPurchase.restorePurchases();
  }

  /// 加载全部的商品
  Future loadProductDataAndBuy(
    String productId,
    String orderId,
  ) async {
    byDebugPrint("===请求商品id $productId");
    List<String> outProducts = [productId];
    final bool available = await _inAppPurchase.isAvailable();
    if (!available) {
      byDebugPrint("===无法连接到商店");
      LoadingDialog().dismiss();
      return;
    }

    ///开始购买
    byDebugPrint("===连接成功-开始查询全部商品");
    List<String> kIds = outProducts;
    final ProductDetailsResponse response =
        await _inAppPurchase.queryProductDetails(kIds.toSet());
    byDebugPrint("===商品获取结果${response.productDetails}");
    if (response.notFoundIDs.isNotEmpty) {
      byDebugPrint("===无法找到指定的商品");
      byDebugPrint("===无法找到指定的商品：${response.error?.message}");
      LoadingDialog().dismiss();
      return;
    }

    /// 处理查询到的商品列表
    List<ProductDetails> products = response.productDetails;
    byDebugPrint("====products  ${products.length}");
    if (products.isNotEmpty) {
      ///赋值内购商品集合
      _products = products;
    }
    byDebugPrint("===全部商品加载完成了，可以启动购买了,总共商品数量为：${products.first.title}");
    startPurchase(productId, orderId);
  }

  ///调用此函数以启动购买过程
  void startPurchase(String productId, String orderId) async {
    byDebugPrint("===购买的商品id为$productId");
    if (_products.isNotEmpty) {
      try {
        ProductDetails productDetails = _getProduct(productId);
        byDebugPrint(
          "===一切正常，开始购买,信息如下：title: ${productDetails.title}  desc:${productDetails.description} "
          "price:${productDetails.price}  currencyCode:${productDetails.currencyCode}  currencySymbol:${productDetails.currencySymbol}",
        );
        if (Platform.isIOS) {
          await clearPendingPurchases();
        }
        final String offerID = getOfferID(productDetails);
        print('_____开始购买——————$_isComsume===>>>$offerID');
        ///消耗型
        if (_isComsume) {
          await _inAppPurchase.buyConsumable(
            purchaseParam: PurchaseParam(
              productDetails: productDetails,
            ),
          );
        }
        ///订阅或者一次性购买型
        else {
          await _inAppPurchase.buyNonConsumable(
            purchaseParam: PurchaseParam(
              productDetails: productDetails,
              applicationUserName: offerID.isNotEmpty ? offerID : null,
            ),
          );
        }
        FirebaseAnalytics.instance.logEvent(
          name: 'user_purchase',
          parameters: {
            'item_id': productId,
            'source_type': sourceType,
          },
        );
      } catch (e) {
        LoadingDialog().dismiss();
        Toast.showText(text: "Purchase failed, please try again.");
        byDebugPrint("=====购买失败了");
      }
    } else {
      byDebugPrint("===当前没有商品无法调用购买逻辑");
    }
  }

  ///是否是促销产品，获取促销ID
  String getOfferID(ProductDetails detail) {
    try {
      ///苹果折扣商品价格
      if (Platform.isIOS) {
        final AppStoreProductDetails iosDetails =
            detail as AppStoreProductDetails;
        if (iosDetails.skProduct.discounts.isNotEmpty) {
          return iosDetails.skProduct.discounts.first.identifier ?? '';
        }
      }
      return '';
    } catch (e) {
      return '';
    }
  }

  ///根据产品ID获取产品信息
  ProductDetails _getProduct(String productId) {
    return _products.firstWhere((product) => product.id == productId);
  }

  /// 内购的购买更新监听
  void _listenToPurchaseUpdated(
    List<PurchaseDetails> purchaseDetailsList) async {
    for (PurchaseDetails purchase in purchaseDetailsList) {
      print('________订单状态变更${purchase.status}');
      onPayStatus?.call(purchase.status);
      if (purchase.status == PurchaseStatus.pending) {
        /// 等待支付完成
        _handlePending();
      } else if (purchase.status == PurchaseStatus.canceled) {
        /// 取消支付
        _handleCancel(purchase);
      } else if (purchase.status == PurchaseStatus.error) {
        /// 购买失败
        // _inAppPurchase.completePurchase(purchase);
        _handleError(purchase);
      } else if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        ///todo 完成购买, 到服务器验证
        LoadingDialog().dismiss();
        // if (purchase.status == PurchaseStatus.purchased) {
            eventBus.fire(QueryOrderEvent(product: purchase));
        // }
      }
    }
  }

  /// 购买失败
  void _handleError(PurchaseDetails purchase) {
    LoadingDialog().dismiss();
    byDebugPrint("===购买失败===");
    FirebaseAnalytics.instance.logEvent(
          name: 'purchase_error',
          parameters: {
            'item_id': purchase.productID,
            'reason': purchase.error?.message ?? 'purchase error',
            'source_type': sourceType,
          },
        );
  }

  /// 等待支付
  void _handlePending() {
    LoadingDialog().show();
    byDebugPrint("===等待支付===");
  }

  /// 取消支付
  void _handleCancel(PurchaseDetails purchase) {
    LoadingDialog().dismiss();
    byDebugPrint("===取消支付===");
    FirebaseAnalytics.instance.logEvent(
          name: 'purchase_cancel',
          parameters: {
            'item_id': purchase.productID,
            'source_type': sourceType,
          },
        );
    // _inAppPurchase.completePurchase(purchase);
  }

  ///完成支付消耗订单
  void completePurchase(PurchaseDetails purchase) {
    _inAppPurchase.completePurchase(purchase);
  }

  void onClose() {
    if (Platform.isIOS) {
      final InAppPurchaseStoreKitPlatformAddition iosPlatformAddition =
          _inAppPurchase
              .getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
      iosPlatformAddition.setDelegate(null);
    }
    _subscription.cancel();
  }

  ///清除其他交易记录
  Future<void> clearPendingPurchases() async {
    try {
      final transactions = await SKPaymentQueueWrapper().transactions();
      for (final transaction in transactions) {
        try {
          await SKPaymentQueueWrapper().finishTransaction(transaction);
        } catch (e) {
          debugPrint("Error clearing pending purchases::in::loop");
          debugPrint(e.toString());
          rethrow;
        }
      }
    } catch (e) {
      debugPrint("Error clearing pending purchases");
      debugPrint(e.toString());
      rethrow;
    }
  }
}

///查询苹果订单状态事件
class QueryOrderEvent {
  final PurchaseDetails product;
  const QueryOrderEvent({required this.product});
}
