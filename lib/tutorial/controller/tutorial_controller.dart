/*
 * @Author: duncy
 * @Date: 2025-09-25 17:15:23
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2025-10-28 09:29:35
 * @FilePath: /novel_oversea/lib/tutorial/controller/tutorial_controller.dart
 * @Description: 
 */



import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:novel_oversea/core/network/http_utils.dart';
import 'package:novel_oversea/core/network/novel_apis.dart';
import 'package:novel_oversea/core/ui/dialog/toast.dart';
import 'package:novel_oversea/core/ui/view/muti_status_view.dart';
import 'package:novel_oversea/core/ui/widget/by_refresh.dart';
import 'package:novel_oversea/tutorial/bean/tutorial_bean.dart';

class TutorialController extends GetxController {

  final RefreshManager refreshManager = RefreshManager();

  Rx<bool> loadComplete = false.obs;

  ///教程列表
  RxList<StrategyListBean> tutorialList = <StrategyListBean>[].obs;

   ///内容状态
  Rx<MultiStatusType> statusType = MultiStatusType.statusContent.obs;

  @override
  void onInit() {
    super.onInit();
    tutorialList = List.filled(5, StrategyListBean.initSkeletonizer()).obs;
    // getStrategyGuideList();
  }

  @override
  void onClose() {
    super.onClose();
    refreshManager.refreshController.dispose();
  }

  ///获取所有攻略列表
  void getStrategyGuideList({bool isRefresh = false}) {
    if (isRefresh) {
      if (tutorialList.isEmpty) {
        statusType.value = MultiStatusType.statusLoading;
      }
      refreshManager.pageHelper.resetPage();
    }

    HttpUtils.get(
      NovelApis.getNovelGuideList,
      {
        "type": 'app_ai_novel_square_guide',
        "page": refreshManager.pageHelper.page,
        "pageSize": refreshManager.pageHelper.row,
      },
      showMsgWhenFailed: false,
      success: (data) {
        final List strategyData = data["data"]["data"] ?? [];
        List<StrategyListBean> beans =
            strategyData.map((e) => StrategyListBean.fromJson(e)).toList();
        if (isRefresh) {
          tutorialList.value = beans;
        } else {
          tutorialList.addAll(beans);
        }
        if (tutorialList.isEmpty) {
            statusType.value = MultiStatusType.statusEmpty;
          } else {
            statusType.value = MultiStatusType.statusContent;
          }
        loadComplete.value = true;
        refreshManager.pageHelper.addPage();
        final hasMore =
            beans.length < refreshManager.pageHelper.row ? false : true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          refreshManager.refreshSuccess(isRefresh, hasMore);
        });
        
      },
      fail: (code, msg) {
        if (tutorialList.isEmpty) {
          statusType.value = MultiStatusType.statusNoNetWork;
        }
        Toast.showText(text: msg);
      },
    );
  }
}