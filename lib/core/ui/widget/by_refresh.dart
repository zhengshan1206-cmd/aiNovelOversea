/*
 * @Author: duncy
 * @Date: 2025-09-24 15:36:51
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2025-09-26 17:47:26
 * @FilePath: /novel_oversea/lib/core/ui/widget/by_refresh.dart
 * @Description: 
 */


import 'package:flutter/cupertino.dart';
import 'package:novel_oversea/core/util/page_helper.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';

class ByRefresh {
  static Widget refresh({
    required Widget child,
    required RefreshController controller,
    void Function()? onRefresh,
    void Function()? onLoad,
  }) {
    return SmartRefresher(
        enablePullDown: onRefresh != null ? true : false,
        enablePullUp: onLoad != null ? true : false,
        // header: ClassicHeader(),
        // footer: CustomFooter(
        //   builder: (context, mode){
        //     Widget body ;
        //     if(mode == LoadStatus.idle){
        //       body =  ByText.text(text: "Refresh");
        //     }
        //     else if(mode == LoadStatus.loading){
        //       body =  CupertinoActivityIndicator();
        //     }
        //     else if(mode == LoadStatus.failed){
        //       body = ByText.text(text: "Loading Fail");
        //     }
        //     else if(mode == LoadStatus.canLoading){
        //        body = ByText.text(text: "Load More");
        //     }
        //     else{
        //       body = ByText.text(text: "No Data");
        //     }
        //     return SizedBox(
        //       height: 55.0,
        //       child: Center(child:body),
        //     );
        //   },
        // ),
        controller: controller,
        onRefresh: onRefresh,
        onLoading: onLoad,
        child: child
      );
  }
}


///上下拉刷新控制器
class RefreshManager {

  RefreshController refreshController = RefreshController();

  final PageHelper _pageHelper = PageHelper();
  PageHelper get pageHelper => _pageHelper;

  void refreshSuccess(bool isRefresh, bool hasMore) {
    if (isRefresh) {
      refreshController.refreshCompleted();
    }
    hasMore ? refreshController.loadComplete() : refreshController.loadNoData();
  }

  void refreshFailed(bool isRefresh) {
    if (isRefresh) {
      refreshController.refreshFailed();
    } else {
      refreshController.loadFailed();
    }
  }
}