/*
 * @Author: duncy
 * @Date: 2025-09-18 11:47:24
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2026-02-10 10:03:15
 * @FilePath: /novel_oversea/lib/tutorial/controller/tutorial_details_controller.dart
 * @Description: 
 */


import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:novel_oversea/core/network/http_utils.dart';
import 'package:novel_oversea/core/network/novel_apis.dart';
import 'package:novel_oversea/core/ui/dialog/toast.dart';
import 'package:novel_oversea/core/ui/view/muti_status_view.dart';
import 'package:novel_oversea/me/user/user.dart';
import 'package:novel_oversea/me/user/user_bean.dart';
import 'package:novel_oversea/tutorial/bean/zoon_detail_bean.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as parser;

// 攻略类型1.图文 2.视频
class TutorialDetailController extends GetxController {
  ///页面加载
  final RxBool showLoading = true.obs;


   ///内容状态
  Rx<MultiStatusType> statusType = MultiStatusType.statusContent.obs;
  
  ///详情id
  final int id;

  ScrollController scrollController = ScrollController();

  TutorialDetailController({required this.id});

  Rx<ZoonDetailBean?> detailsData = Rx<ZoonDetailBean?>(null);

  ///用户控制器
  final UserController _userController = Get.find<UserController>();

  ///获取用户信息
  UserInfoBean? get userInfo => _userController.userInfoBean.value;

  ///所有图片链接
  List<NetworkImage> imgList = [];

  ///显示标题
  RxString showTitle = ''.obs;

  @override
  void onInit() {
    super.onInit();
    getStrategyGuideDetail();
    FirebaseAnalytics.instance.logEvent(name: 'tutorial_read', parameters: {'id': id.toString()});
    // 注册滚动监听
    scrollController.addListener(_onScroll);
  }

  // 滚动监听回调：实时获取滚动距离
  void _onScroll() {
    if(scrollController.offset > 100) {
      showTitle.value = detailsData.value!.name;
    }
    else {
      showTitle.value = 'Tutorial Detail';
    }
  }

  /// 从 HTML 字符串中提取所有图片链接（<img> 的 src 属性）
  void extractImageUrls(String htmlString) {
    // 1. 解析 HTML 字符串为 DOM 树
    dom.Document document = parser.parse(htmlString);
    
    // 2. 获取所有 <img> 标签
    List<dom.Element> imgElements = document.getElementsByTagName('img');
    
    // 3. 提取每个 <img> 的 src 属性（过滤空值）
    for (var img in imgElements) {
      String? src = img.attributes['src'];
      if (src != null && src.isNotEmpty) {
        imgList.add(NetworkImage(src));
      }
    }
  }

  void getStrategyGuideDetail() {
    // statusType.value = MultiStatusType.statusLoading;
    showLoading.value = true;
    HttpUtils.get(
      NovelApis.getStrategyGuideDetail,
      {"id": id},
      showMsgWhenFailed: false,
      success: (data) {
        detailsData.value = ZoonDetailBean.fromJson(data["data"]);
        statusType.value = MultiStatusType.statusContent;
        Get.log("===系列课详情数据===${detailsData.value?.toJson()}");
        showLoading.value = false;
        extractImageUrls(detailsData.value!.content);
        update();
      },
      fail: (code, msg) {
        Toast.showText(text: msg);
        showLoading.value = false;
        statusType.value = MultiStatusType.statusNoNetWork;
      },
    );
  }

  @override
  void dispose() {
    // 销毁控制器，避免内存泄漏
    scrollController.dispose();
    super.dispose();
  }
}
