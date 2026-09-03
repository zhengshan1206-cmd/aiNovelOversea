import 'dart:convert';
import 'dart:io';

import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:novel_oversea/core/cache/byhy_aes_storage_utils.dart';
import 'package:novel_oversea/core/network/http_utils.dart';
import 'package:novel_oversea/core/network/novel_apis.dart';
import 'package:novel_oversea/core/ui/view/muti_status_view.dart';
import 'package:novel_oversea/core/util/by_nav_router_utils.dart';
import 'package:novel_oversea/global/const/consts.dart';
import 'package:novel_oversea/global/pay/bean/integral_pay_list_bean.dart';
import 'package:novel_oversea/global/pay/bean/vip_type_bean.dart';
import 'package:novel_oversea/me/user/user_menu_bean.dart';
import 'package:in_app_purchase_storekit/store_kit_2_wrappers.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase_android/billing_client_wrappers.dart';

import '../../const/const_string.dart';

class AppConfig extends GetxController {
  List protocolList = [];

  Map<String, String> normalKeyProtocal = {
    'User Agreement': Consts.termsOfServiceUrl,
    'Privacy Policy': Consts.privacyPolicyUrl,
    'Member Service Agreement': Consts.seviceAgreement,
    'Complaint Reporting': Consts.complaintReporting,
    'About Us': Consts.aboutUs,
    'Feedback': Consts.feedback,
  };

  bool isLoading = false;

  @override
  void onInit() {
    super.onInit();

    ///添加默认项
    final List<String> titles = ['User Agreement', 'Privacy Policy', 'Member Service Agreement'];
    for (final title in titles) {
      protocolList.add(UserMenusBean(title: title, show: true, url: normalKeyProtocal[title]!));
    }
  }

  ///获取协议列表
  void getProtocolList() {
    if(isLoading) {
      return;
    }
    HttpUtils.get(
      NovelApis.novelAppMenus,
      showMsgWhenFailed: false,
      {},
      success: (data) {
        // byDebugPrint(data, tag: "协议列表");
        isLoading = true;
        if (data != null && data['data'] != null) {
          List<dynamic> list = data['data'];
          protocolList = list.map((e) => UserMenusBean.fromJson(e)).toList();
        }
      },
    );
  }
  ///获取默认的协议页地址
  String _getNormalProtocal(String title) {
    if(normalKeyProtocal.containsKey(title)) {
      return normalKeyProtocal[title]!;
    }
    return Consts.termsOfServiceUrl;
  }

  ///跳转至指定协议页
  void goPrivacyPageWithTitle(String title) {
    try {
      UserMenusBean? bean =
          protocolList.firstWhereOrNull((element) => element.title == title);
      if (bean == null || bean.url.isEmpty) {
        ByNavRouterUtils.jumpWebViewPage(Get.context!, title, _getNormalProtocal(title));
        return;
      }
      ByNavRouterUtils.jumpWebViewPage(Get.context!, title, bean.url);
    } catch (e) {
      // throw(e);
    }
  }
}

///付费页数据，包含套餐，运营位数据，字数包套餐，返回拦截弹窗数据
class PayData extends GetxController {

  ///底部须知说明
  RxString inform = ''.obs;
  ///vip套餐列表数据
  RxList<VipTypeBean> vipList = <VipTypeBean>[].obs;
  RxList<VipTypeBean> vipListTrialOn = <VipTypeBean>[].obs;  ///试用开启
  RxList<VipTypeBean> vipListTrialOff = <VipTypeBean>[].obs;  ///试用关闭
  RxList<VipTypeBean> vipListTrialUse = <VipTypeBean>[].obs;  ///已经试用过
  RxList<VipTypeBean> vipListGuide = <VipTypeBean>[].obs;  ///引导页
  RxList<VipTypeBean> vipListiOSInterceptor = <VipTypeBean>[].obs;  ///ios删除拦截页
  RxList<VipTypeBean> vipListHomeDiscount = <VipTypeBean>[].obs;  ///首页折扣套餐
  RxList<VipTypeBean> vipListPush = <VipTypeBean>[].obs;  ///推送套餐
  List<VipTypeBean> vipListGuideDialog = [];
  List<VipTypeBean> vipListGuideDialogClose = [];
  List<VipTypeBean> vipListLoginClose = [];
  ///vip套餐返回拦截列表数据
  RxList<VipTypeBean> vipInterceptList = <VipTypeBean>[].obs;
  ///字数包列表数据
  RxList<IntegralPayListBean> wordsPackageList = <IntegralPayListBean>[].obs;
  ///字数包协议
  String? wordsPackIllustrate = '';
  //支付方式支持
  String paySupport = Platform.isAndroid ? "google" : "apple";
  ///vip支付方式配置
  Map<String, dynamic>? payConfig = {};
  ///字数包支付方式配置
  Map<String, dynamic>? wordPackagePayConfig = {};

  ///是否有免费试用
  RxBool hasTrial = true.obs;

  ///用户是否进入过vip页面
  bool hasEnteredVip = false;

  Rx<MultiStatusType> statusType = MultiStatusType.statusLoading.obs;

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;

  bool loadIntercept = false;
  bool loadVip = false;
  bool loadWordPackage = false;

  @override
  void onInit() {
    super.onInit();
    getCacheData();
    // init();
  }

  ///获取初始本地化数据
  void getCacheData() {
    final String vipData = ByStorageUtils.getString(ConstString.kVipData) ?? '';
    if(vipData.isEmpty) {
      return;
    }
    final List vip = jsonDecode(vipData);
    List<VipTypeBean> typeBeans =
            vip.map((e) => VipTypeBean.fromJson(e as Map<String, dynamic>)).toList();
      vipListCategory(typeBeans);
    final String integralData = ByStorageUtils.getString(ConstString.kIntegralData) ?? '';
    if(integralData.isEmpty) {
      return;
    }
    final List integral = jsonDecode(integralData);
    List<IntegralPayListBean> beans =
            integral.map((e) => IntegralPayListBean.fromJson(e as Map<String, dynamic>)).toList();
      wordsPackageList.clear();
      wordsPackageList.addAll(beans);
  }

  void init({bool isReload = false, void Function(int)? onSuccess,}) {
    _loadVipHappys(isReload: isReload, onSuccess: onSuccess);
    _loadWordPackageList(isReload: isReload, onSuccess: onSuccess);
    _loadVipHappys(isReload: isReload, onSuccess: onSuccess, vipType: 2);
  }

  Future<void> getProduct(dynamic list, {bool? vipList = false}) async{
    // 检查设备是否支持内购（iOS通常支持）
    final bool isAvailable = await _inAppPurchase.isAvailable();
    if (!isAvailable) {
      print('___设备不支持内购');
      return;
      // throw Exception("设备不支持内购");
    }
    List<String> ids = [];
    for (dynamic t in list) {
      ids.add(t['apple_vip_id']);
    }
    if(ids.isEmpty) {
      return;
    }
    // 监听产品信息返回
    final productDetailsResponse = await _inAppPurchase.queryProductDetails(
      ids.toSet(), // 你的产品ID列表
    );
    // print('______商品查询id:_$ids，，${productDetailsResponse.productDetails.length}, ${productDetailsResponse.notFoundIDs}');
    if (productDetailsResponse.error != null) {
      // 处理错误（如网络问题、产品ID无效）
      print("________查询产品失败：${productDetailsResponse.error?.message}");
      throw Exception("查询产品失败：${productDetailsResponse.error?.message}");
    }
    // 存储有效的产品信息
    List<ProductDetails> details = productDetailsResponse.productDetails;
    print("________查询产品结果：$details");
    for (ProductDetails detail in details) {
      // print('_____商品查询信息details:===>>>${detail.id}, ${detail.price}, ${detail.currencyCode}, ${detail.title}, ${detail.description},${detail.rawPrice},${detail.currencySymbol}');
      final package = list.firstWhere((p) => p['apple_vip_id'] == detail.id);
      package['local_price'] = detail.price.replaceAll(',', '');
      package['local_symbol'] = detail.currencySymbol;
      if(vipList == true) {
        ///苹果折扣商品价格
        if (Platform.isIOS) {
          final AppStoreProductDetails iosDetails =
              detail as AppStoreProductDetails;
          if (iosDetails.skProduct.discounts.isNotEmpty) {
            package['discount_local_price'] =
                '${iosDetails.skProduct.discounts.first.priceLocale.currencySymbol}${iosDetails.skProduct.discounts.first.price}'.replaceAll(',', '');
            // print('______IOS ==>>${package['discount_local_price']}');
          }
        }
        ///Google折扣商品价格
        else if(Platform.isAndroid) {
          final GooglePlayProductDetails googleDetails =
              detail as GooglePlayProductDetails;
          try {
            if (googleDetails.productDetails.subscriptionOfferDetails!.length >
                1) {
              for (SubscriptionOfferDetailsWrapper item
                  in googleDetails.productDetails.subscriptionOfferDetails!) {
                for (PricingPhaseWrapper price in item.pricingPhases) {
                  if (price.recurrenceMode != RecurrenceMode.infiniteRecurring) {
                    package['discount_local_price'] = price.formattedPrice.replaceAll(',', '');
                  } else {
                    package['local_price'] = price.formattedPrice.replaceAll(',', '');
                  }
                }
              }
            }
            // print('______Android ==>>${package['discount_local_price']},${package['local_price']}');
          } catch (e) {
            // print('');
          }
        }
      }
      if(hasTrial.value && vipList! && package['is_first_free'] == 1) {
        if(Platform.isIOS) {
          hasTrial.value = await hasSubscribedToAppleProduct(detail.id);
        }
        else if(Platform.isAndroid) {
          hasTrial.value = await hasSubscribedToGoogleProduct(detail.id);
        }
      }
    }
    // print('______免费试用:_${productDetailsResponse.productDetails},${hasTrial.value}');
  }

  /// 检查用户是否订阅过目标套餐（通过productId）
  Future<bool> hasSubscribedToGoogleProduct(String targetProductId) async {
    try {
      // Query past purchases via in_app_purchase
      // Some versions of in_app_purchase expose queryPastPurchases; use a dynamic
      // invocation to be resilient to API differences across plugin versions.

      final InAppPurchaseAndroidPlatformAddition androidAddition =
          _inAppPurchase
              .getPlatformAddition<InAppPurchaseAndroidPlatformAddition>();
      final pastPurchasesResponse = await androidAddition.queryPastPurchases();
      for (final purchase in pastPurchasesResponse.pastPurchases) {
        final productId = purchase.productID;
        final isPurchased = purchase.status == PurchaseStatus.purchased;
        if (productId == targetProductId && isPurchased) {
          // Found a past purchase for this product -> user has subscribed before
          return false;
        }
      }
      // No matching purchase found
      return true;
    } catch (e) {
      print('Error querying past purchases (Google): $e');
      // On error assume not subscribed (so trial remains available)
      return true;
    }
  }

  /// 检查用户是否订阅过目标套餐（通过productId）
  Future<bool> hasSubscribedToAppleProduct(String targetProductId) async {
    try {
      // 调用StoreKit 2的API获取所有交易（包括已完成、已过期、已退款的）
      final transactions = await SK2Transaction.transactions();
      
      // 3. 筛选目标productId的有效订阅记录（排除退款的交易）
      for (final transaction in transactions) {
        // 交易对应的产品ID
        final productId = transaction.productId;
        final isPurchased = transaction.purchaseDate.isNotEmpty;
        if (productId == targetProductId && isPurchased) {
          // 存在有效订阅记录（无论当前是否过期，只要曾经订阅过）
          return false;
        }
      }
      return true;
    } catch (e) {
      print('查询交易历史失败：$e');
      return true;
    }
  }

  ///获取VIP套餐与返回拦截套餐列表
  void _loadVipHappys({
    int vipType = 1,
    bool isReload = false,
    void Function(int)? onSuccess,
    void Function()? onFailed,
  }) {
    if(vipType == 1 && vipList.isNotEmpty && !isReload && loadVip) {
      return;
    }
    if(vipType == 2 && !isReload && loadIntercept) {
      return;
    }
    statusType.value = MultiStatusType.statusLoading;
    HttpUtils.get(
      NovelApis.vip,
      showMsgWhenFailed: false,
      {"ver": 2, "support_pays": paySupport, 'vip_type': vipType},
      success: (data) async{
        final respData = data["data"];
        final List items = respData["items"] ?? [];
        await getProduct(items, vipList: true);
        /// VIP套餐列表
        List<VipTypeBean> typeBeans =
            items.map((e) => VipTypeBean.fromJson(e)).toList();
        if(vipType == 1) {
          if(Platform.isAndroid) {
            payConfig = respData["pays"] ?? {};
          }
          if(items.isNotEmpty) {
            ByStorageUtils.saveString(ConstString.kVipData, jsonEncode(items));
          }
          vipListCategory(typeBeans);
          statusType.value = MultiStatusType.statusContent;
          onSuccess?.call(0);
          loadVip = true;
        }
        ///vip返回拦截套餐
        else {
          loadIntercept = true;
          vipInterceptList.clear();
          vipInterceptList.addAll(typeBeans);
        }
      },
      fail: (code, msg) {
        statusType.value = MultiStatusType.statusNoNetWork;
        onFailed?.call();
      },
    );
  }

  ///分类vip套餐数据
  void vipListCategory(List<VipTypeBean> typeBeans) {
    vipList.clear();
    vipListTrialOff.clear();
    vipListTrialOn.clear();
    vipListTrialUse.clear();
    vipListGuide.clear();
    vipListHomeDiscount.clear();
    vipListGuideDialog.clear();
    vipListGuideDialogClose.clear();
    vipListLoginClose.clear();
    vipListPush.clear();
    for (final bean in typeBeans) {
      if(bean.showArea != null && bean.showArea!.isNotEmpty) {
        for (final area in bean.showArea!) {
          ///免费试用版
          if(area.contains("1")) {
            ///免费试用版开启
            if(bean.isFirstFree == 1) {
              vipListTrialOn.add(bean);
            }
            ///免费试用版关闭
            else {
              vipListTrialOff.add(bean);
            }
          }
          ///免费试用版
          if(area.contains("2")) {
            vipListTrialUse.add(bean);
          }
          ///跳过引导页
          if(area.contains("3")) {
            vipListGuide.add(bean);
          }
          ///非引导页，默认支付
          if(area.contains("4")) {
            vipList.add(bean);
          }
          ///iOS删除拦截
          if(area.contains("5")) {
            vipListiOSInterceptor.add(bean);
          }
          ///首页这个套餐
          if(area.contains("6")) {
            vipListHomeDiscount.add(bean);
          }
          ///OB流程这个套餐
          if(area.contains("7")) {
            vipListGuideDialog.add(bean);
          }
          /// 首页新用户第一次进入套餐
          if(area.contains("8")) {
            vipListGuideDialogClose.add(bean);
          }
          ///首次登录套餐
          if(area.contains("9")) {
            vipListLoginClose.add(bean);
          }
          ///推送套餐
          if(area.contains("10")) {
            vipListPush.add(bean);
          }
        }
      }
    }
    print('_____vip与引导页付费：_$vipList,  ___$vipListGuide');
    print('_____试用版：_$vipListTrialOff,  ___$vipListTrialOn');
    print('_____试用过付费页：_$vipListTrialUse');
  }

  /// 获取字数包列表
  void _loadWordPackageList({
    bool isReload = false,
    void Function(int)? onSuccess,
    void Function()? onFailed,
  }) {
    if(wordsPackageList.isNotEmpty && !isReload && loadWordPackage) {
      return;
    }
    HttpUtils.get(
      NovelApis.token,
      {
        "ver": 2,
        "support_pays": paySupport,
        "source_type": 2,
      },
      showMsgWhenFailed: false,
      success: (data) async{
        final List items = data["data"]["items"] ?? [];
        wordsPackIllustrate = data["data"]["words_pack_illustrate"];
        await getProduct(items);
        /// 字数包套餐列表
        List<IntegralPayListBean> typeBeans =
            items.map((e) => IntegralPayListBean.fromJson(e)).toList();
        if (Platform.isAndroid) {
          wordPackagePayConfig = data["data"]["pays"] ?? {};
        }
        ByStorageUtils.saveString(ConstString.kIntegralData, jsonEncode(items));
        wordsPackageList.clear();
        wordsPackageList.addAll(typeBeans);
        loadWordPackage = true;
        onSuccess?.call(1);
      },
      fail: (code, msg) {
        onFailed?.call();
      },
    );
  }
}

// 全局依赖注入绑定
class GlobalBinding implements Bindings {
  @override
  void dependencies() {
    // 注册全局控制器
    Get.put(GlobalController());
    
    // 注册各模块控制器
    Get.put(PayData());

    // 注册app配置控制器
    Get.put(AppConfig());
  }
}

class BannerManager {
  ///小说正文页
  bool novelDetailBanner = false;
  ///支付成功页
  Rx<bool> paySuccessBanner = false.obs;
}

// 全局状态管理类
class GlobalController extends GetxController {
  // 单例模式
  static GlobalController get instance => Get.find();

  ///支付相关数据
  PayData get pay => Get.find();

  ///配置相关
  AppConfig get config => Get.find();

  BannerManager banner = BannerManager();

  ///是否是首次进入
  bool isFirstIn = false;

  void init() {
    pay.init();
    config.getProtocolList();
  }
  
  // // 初始化 - 从本地加载数据
  // @override
  // void onInit() {
  //   super.onInit();
  // }
}
