/*
 * @Author: duncy
 * @Date: 2025-10-15 17:54:13
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2026-01-07 14:57:12
 * @FilePath: /novel_oversea/lib/home/create/controller/create_category_controller.dart
 * @Description: 
 */


import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:get/get.dart';
import 'package:novel_oversea/core/network/http_utils.dart';
import 'package:novel_oversea/core/network/novel_apis.dart';
import 'package:novel_oversea/core/ui/dialog/toast.dart';
import 'package:novel_oversea/core/ui/view/muti_status_view.dart';
import 'package:novel_oversea/home/create/bean/novel_category_bean.dart';
import 'package:novel_oversea/home/create/controller/novel_create_controller.dart';

import '../../../global/routes/app_pages.dart';

class CreateCategoryController extends GetxController{

  ///小说类型数据
  RxList<NovelCategoryBean> categoryList = <NovelCategoryBean>[].obs;

  ///页面加载状态
  Rx<MultiStatusType> statusType = MultiStatusType.statusLoading.obs;

  ///创建小说类型
  CreationType type = CreationType.longNovel;

  ///选择的小说partner index
  Rx<int> index = 1.obs;

  ///是否显示引导遮罩
  bool isGuide = false;
  
  @override
  void onInit() {
    final args = Get.arguments as Map<String, dynamic>?;
    type = args?['type'] ?? CreationType.longNovel;
    isGuide = args?['guide'] ?? false;
    fetchNovelCategory();
    FirebaseAnalytics.instance.logEvent(
      name: 'create_novel_category_page_view',
      parameters: {
        'type': type == CreationType.longNovel ? 'long_novel' : 'short_novel',
      },
    );
    super.onInit();
  }


  void fetchNovelCategory({
    void Function()? onSuccess,
    void Function(int, String)? onFailed,
  }) {
    statusType.value = MultiStatusType.statusLoading;
    HttpUtils.get(
      NovelApis.novelCategory,
      {'func': type == CreationType.longNovel ? 'long_novel_professional' : 'short_novel_professional'},
      showMsgWhenFailed: false,
      success: (data) {
        if (data['status'] == 200) {
          final List items = data["data"] ?? [];
          List<NovelCategoryBean> beans = List<NovelCategoryBean>.from(items.map(
            (ele) => NovelCategoryBean.fromJson(ele),
          ));
          categoryList.addAll(beans);
          statusType.value = MultiStatusType.statusContent;
          onSuccess?.call();
        }
      },
      fail: (code, msg) {
        statusType.value = MultiStatusType.statusNoNetWork;
        Toast.showText(text: msg);
      },
    );
  }

  ///下一步
  void nextStep() {
    if (categoryList.length <= index.value) {
      return;
    }
    if (isGuide) {
      Get.offNamed(
        Routes.novelCreateChat,
        arguments: {'type': type, 'partner': categoryList[index.value], 'guide': true},
      );
    } else {
      Get.toNamed(
        Routes.novelCreateChat,
        arguments: {'type': type, 'partner': categoryList[index.value]},
      );
    }
  }
}