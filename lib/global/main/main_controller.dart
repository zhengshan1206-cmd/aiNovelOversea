/*
 * @Author: cold-x
 * @Date: 2025-05-28 14:51:03
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2026-02-10 10:05:46
 * @FilePath: /novel_oversea/lib/global/main/main_controller.dart
 * @Description: 
 */

import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:novel_oversea/core/ui/view/muti_status_view.dart';
import 'package:novel_oversea/global/initiliazation/ios_shortcut_manager.dart';
import 'package:novel_oversea/global/launch/controller/launch_controller.dart';
import 'package:novel_oversea/global/launch/controller/launch_manager.dart';
import 'package:novel_oversea/home/core/controller/words_controller.dart';
import 'package:novel_oversea/home/main/controller/home_controller.dart';
import 'package:novel_oversea/home/main/page/home.dart';
import 'package:novel_oversea/me/main/controller/me_controller.dart';
import 'package:novel_oversea/me/main/page/me.dart';
import 'package:novel_oversea/tutorial/page/tutorial.dart';
import 'package:novel_oversea/tutorial/controller/tutorial_controller.dart';

import '../push/push.dart';
import '../routes/app_pages.dart';
import '../routes/routes_service.dart';

class MainController extends GetxController {
  Rx<int> currentIndex = 0.obs;

  ///启动接口状态
  Rx<MultiStatusType> launchStatus = MultiStatusType.statusLoading.obs;
  LaunchController launchController = Get.find<LaunchController>();

  List<Widget> tabBarPages = [];


  // 页面进入时间记录
  final Map<int, DateTime> _pageEnterTimes = {};

  // 当前活跃页面索引
  int? _currentActivePageIndex;

  // 是否正在处理路由变化（避免重复上报）
  bool _isHandlingRouteChange = false;

  @override
  void onInit() {
    super.onInit();
    fetchLaunchData();
    Push.setupInteractedMessage();
  }

  ///加载启动数据
  void fetchLaunchData() {
    ///是否有启动接口
    if (launchController.isLaunched.value) {
      launchStatus.value = MultiStatusType.statusContent;
      loadData();
    } else {
      launchStatus.value = MultiStatusType.statusLoading;
      launchController.appLaunch(
        onSuccess: (p0) {
          launchStatus.value = MultiStatusType.statusContent;
          loadData();
        },
        onFail: () {
          launchStatus.value = MultiStatusType.statusNoNetWork;
        },
      );
    }
  }

  ///加载主页以及各个tab页数据
  void loadData() {
    
    Get.put(WordsController(), permanent: true);
    Get.put(HomeController(), permanent: true);
    Get.put(MeController(), permanent: true);
    Get.put(TutorialController(), permanent: true);
    GlobalController.instance.init();

    tabBarPages.add(HomePage());
    tabBarPages.add(TutorialPage());
    tabBarPages.add(MePage());

    ///iOS快捷方式处理
    if(Platform.isIOS) {
      ShortcutiOSManager.handleShortcutAction(tabChanged: (index) => tabChanged(index),);
    }
  }

  void tabChanged(
    int index,
  ) {
    if(currentIndex.value == index) {
      return;
    }

    // 如果正在处理路由变化，跳过tab切换的埋点
    if (_isHandlingRouteChange) {
      currentIndex.value = index;
      return;
    }

    // 保存当前页面的索引作为上一个页面
    final int? previousPageIndex = _currentActivePageIndex;

    // 上报上一个页面的停留时长
    if (previousPageIndex != null) {
      reportPageDuration(previousPageIndex, index);
    }

    currentIndex.value = index;

    // 记录新页面进入时间
    recordPageEnter(index);


    if(index == 1) {
      FirebaseAnalytics.instance.logEvent(name: 'tutorial_click');
      final TutorialController tutorial = Get.find<TutorialController>();
      if(!tutorial.loadComplete.value) {
        tutorial.getStrategyGuideList(isRefresh: true);
      }
    }
    else if(index == 2) {
      FirebaseAnalytics.instance.logEvent(name: 'user_center_click');
      Get.find<MeController>().getNovelCreateCount();
    }
    else if(index ==0) {
      FirebaseAnalytics.instance.logEvent(name: 'home_show');
    }
  }


  /// 记录页面进入时间
  void recordPageEnter(int index) {
    _pageEnterTimes[index] = DateTime.now();
    _currentActivePageIndex = index;
  }

  /// 记录页面进入时间（用于路由变化）
  void recordPageEnterFromRoute(int index) {
    _isHandlingRouteChange = true;
    recordPageEnter(index);
    currentIndex.value = index;
    _isHandlingRouteChange = false;
  }

  /// 上报页面停留时长
  void reportPageDuration(int pageIndex, [int? nextPageIndex]) {
    final DateTime? enterTime = _pageEnterTimes[pageIndex];
    if (enterTime == null) return;

    // 计算停留时长（秒，保留两位小数）
    final double duration =
        DateTime.now().difference(enterTime).inMilliseconds / 1000.0;

    // 获取页面路由名称
    final String pagePath = _getPagePath(pageIndex);
    final String prePagePath =
        nextPageIndex != null ? _getPagePath(nextPageIndex) : '';

    // 上报页面访问数据
    PageRouteService.reportPageView(
      duration: duration,
      pagePath: pagePath,
      prePagePath: prePagePath,
    );

    // 移除已上报的页面时间记录
    _pageEnterTimes.remove(pageIndex);

    print(
        '主页面路由上报: 页面=$pagePath, 时长=${PageRouteService.getDurationText(duration.round())}, 下一页=$prePagePath');
  }

  /// 上报主页面离开时的埋点（用于路由监听器调用）
  void reportMainPageLeave(String nextPagePath) {
    if (_currentActivePageIndex == null) return;

    final DateTime? enterTime = _pageEnterTimes[_currentActivePageIndex];
    if (enterTime == null) return;

    // 计算停留时长（秒，保留两位小数）
    final double duration =
        DateTime.now().difference(enterTime).inMilliseconds / 1000.0;

    // 获取页面路由名称
    final String pagePath = _getPagePath(_currentActivePageIndex!);

    // 上报页面访问数据
    PageRouteService.reportPageView(
      duration: duration,
      pagePath: pagePath,
      prePagePath: nextPagePath,
    );

    // 移除已上报的页面时间记录
    _pageEnterTimes.remove(_currentActivePageIndex);

    // 清空当前活跃页面索引，因为主页面已经离开
    _currentActivePageIndex = null;

    print(
        '主页面离开上报: 页面=$pagePath, 时长=${PageRouteService.getDurationText(duration.round())}, 下一页=$nextPagePath');
  }

  /// 获取页面路由路径
  String _getPagePath(int index) {
    switch (index) {
      case 0:
        return Routes.home;
      case 1:
        return Routes.square;
      case 2:
        return Routes.profile;
      default:
        return Routes.main;
    }
  }
}
