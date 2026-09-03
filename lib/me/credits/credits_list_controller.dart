


import 'package:get/get.dart';
import 'package:novel_oversea/core/network/http_utils.dart';
import 'package:novel_oversea/core/network/novel_apis.dart';
import 'package:novel_oversea/core/ui/view/muti_status_view.dart';
import 'package:novel_oversea/core/ui/widget/by_refresh.dart';
import 'package:novel_oversea/me/credits/credits_bean.dart';

import '../../core/ui/dialog/toast.dart';

class CreditsListController extends GetxController {

  final RefreshManager refreshManager= RefreshManager();
  
  Rx<MultiStatusType> statusType = MultiStatusType.statusLoading.obs;

  RxList<CreditsBean> dataList = <CreditsBean>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchCreditsItemList(true);
  }


  ///拉取积分商品列表
  void fetchCreditsItemList(bool isRefresh, {
    Function(dynamic data)? onSuccess,
    Function(int code, String msg)? onFail,
  }) {
    if (isRefresh) {
      if (dataList.isEmpty) {
        statusType.value = MultiStatusType.statusLoading;
      }
      refreshManager.pageHelper.resetPage(); // 如果是刷新操作，清空当前列表
    }
    HttpUtils.get(
      NovelApis.getIntegralConsumeList, 
      {
        'page_size': refreshManager.pageHelper.row, // 每页数量
        'page': refreshManager.pageHelper.page, // 页数
      },
      showMsgWhenFailed: false,
      success: (data) {
        //处理数据
        statusType.value = MultiStatusType.statusContent;
        final List<dynamic> list = data['data']['data'] ?? [];
        final List<CreditsBean> beans = list.map((e) => CreditsBean.fromJson(e)).toList();
        if (isRefresh) {
          dataList.value = beans; // 刷新时清空列表
        } else {
          dataList.addAll(beans); // 加载更多时追加数据
        }
        if (dataList.isEmpty) {
          statusType.value = MultiStatusType.statusEmpty;
        } else {
          statusType.value = MultiStatusType.statusContent;
        }
        refreshManager.pageHelper.addPage();

        final hasMore = beans.length < refreshManager.pageHelper.row
            ? false
            : true;
        refreshManager.refreshSuccess(isRefresh, hasMore);
        onSuccess?.call(data);
      },
      fail: (code, msg) {
        if (dataList.isEmpty) {
          statusType.value = MultiStatusType.statusNoNetWork;
        }
        Toast.showText(text: msg);
        onFail?.call(code, msg);
      });
  }

}