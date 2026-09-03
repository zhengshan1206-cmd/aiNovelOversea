

import 'package:flutter/material.dart';
import 'package:novel_oversea/core/network/http_utils.dart';
import 'package:novel_oversea/core/ui/dialog/toast.dart';

import '../../../core/network/novel_apis.dart';
import '../../../core/util/page_helper.dart';
import '../bean/novel_chapter_bean.dart';

class ChapterListProvider extends ChangeNotifier {

  int? novelID;
  int? outlineID;
  ///大纲列表数据
  List<ChapterBean> itemList = [];
  ///分页上拉
  // final EasyRefreshController refreshController = EasyRefreshController(
  //   controlFinishRefresh: true,
  //   controlFinishLoad: true,
  // );
  final PageHelper _pageHelper = PageHelper();
  PageHelper get pageHelper => _pageHelper;

  ///广场创作页
  ///获取章节细纲列表页
  void fetchSquareNovelInfoList(
    bool isGuide,
    {
    bool? showLoading,
    void Function()? onSuccess,
    void Function(int, String)? onFailed,
  }) {
    HttpUtils.get(
      isGuide ? NovelApis.novelGuideDetailList : NovelApis.novelSquareDetailList,
      {
        'id': novelID,
        'page': pageHelper.page,
        'page_size': pageHelper.row
      },
      success: (data) {
        if (data['status'] == 200) {
          final List items = data["data"]['data'] ?? [];
          List<ChapterBean> beans = List<ChapterBean>.from(items.map(
            (ele) => ChapterBean.fromJson(ele),
          ));
          if(pageHelper.page == 1) {
            itemList.clear();
          }
          itemList.addAll(beans);
          pageHelper.addPage();
          // final hasMore = beans.length < pageHelper.row ? false : true;
          // refreshSuccess(false, hasMore);
          notifyListeners();
          onSuccess?.call();
        }
      },
      fail: (code, msg) {
        onFailed?.call(code, msg);
        Toast.showText(text: msg);
      },
    );
  }
  ///获取章节细纲列表页
  void fetchNovelInfoList({
    bool? showLoading,
    bool? jumptoStreamChapter = false,
    void Function()? onSuccess,
    void Function(int, String)? onFailed,
  }) {
    HttpUtils.get(
      NovelApis.novelDetailList,
      {
        'id': novelID,
        'page': pageHelper.page,
        'page_size': pageHelper.row
      },
      success: (data) {
        if (data['status'] == 200) {
          final List items = data["data"]['data'] ?? [];
          List<ChapterBean> beans = List<ChapterBean>.from(items.map(
            (ele) => ChapterBean.fromJson(ele),
          ));
          if(pageHelper.page == 1 || itemList.first.id == beans.first.id) {
            itemList.clear();
          }
          itemList.addAll(beans);
          pageHelper.addPage();
          // final hasMore = beans.length < pageHelper.row ? false : true;
          // refreshSuccess(false, hasMore);
          notifyListeners();
          onSuccess?.call();
        }
      },
      fail: (code, msg) {
        onFailed?.call(code, msg);
        Toast.showText(text: msg);
      },
    );
  }

  /*
    上拉刷新相关
  */

  // void refreshSuccess(bool isRefresh, bool hasMore) {
  //   if (isRefresh) {
  //     refreshController.finishRefresh(IndicatorResult.success, false);
  //     if (hasMore) {
  //       refreshController.resetFooter();
  //     }
  //   } else {
  //     refreshController.finishLoad(
  //         hasMore ? IndicatorResult.success : IndicatorResult.noMore, true);
  //   }
  // }

  // void refreshFailed(bool isRefresh) {
  //   if (isRefresh) {
  //     refreshController.finishRefresh(IndicatorResult.fail, false);
  //   } else {
  //     refreshController.finishLoad(IndicatorResult.fail, false);
  //   }
  // }
}