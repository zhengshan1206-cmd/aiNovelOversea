/*
 * @Author: cold-x
 * @Date: 2025-05-30 14:29:37
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2026-02-09 17:39:11
 * @FilePath: /novel_oversea/lib/global/initiliazation/initialize.dart
 * @Description: 初始化器
 */

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:novel_oversea/core/cache/byhy_aes_storage_utils.dart';
import 'package:novel_oversea/core/network/const_keys.dart';
import 'package:novel_oversea/core/service/app_links_service.dart';
import 'package:novel_oversea/core/util/by_device_info_utils.dart';
import 'package:novel_oversea/core/util/by_package_utils.dart';
import 'package:novel_oversea/global/initiliazation/adjust_manager.dart';
import 'package:novel_oversea/global/push/push.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:sp_util/sp_util.dart';
import '../ui/colors.dart';


///App 初始化器
class InitializeManager {

  ///初始化SDK
  static void initSDK() async {

    AppLinksService.initAppLink();

    ///初始化推送
    Push.init();

    if(Platform.isIOS) {
      await _requestTrackingAuthorization();
    }
  }

  ///初始化Adjust归因
  static void initAdjust({String? appid, String? fbAppID}) {
    AdjustManager adjust = AdjustManager();
    adjust.init(appid: appid, fbAppID: fbAppID);
  }

  ///初始化组件
  static Future<void> initializition() async {
    // 设置状态栏透明
    initStatusBar();

    /// 初始化PF
    await _initPF();

    final version = await ByPackageUtils.version();
    await ByStorageUtils.saveString(ConstKeys.kAppVersion, version);
    await ConstKeys().initUserAgentData();
    ByDeviceInfoUtils.saveTimeZone();
    // if(Platform.isAndroid) {
    //   ByDeviceInfoUtils.savePosition();
    // }
  }
  // 请求广告追踪授权
  static Future<void> _requestTrackingAuthorization() async {
    // 1. 检查 iOS 版本是否支持（需 iOS 14+）
    // final status = await AppTrackingTransparency.trackingAuthorizationStatus;
    // if (status == TrackingStatus.notDetermined) {
    //   // 2. 显示授权弹窗（会触发系统弹窗）
    //   Future.delayed(const Duration(milliseconds: 500),() async{
    //     await AppTrackingTransparency.requestTrackingAuthorization();
    //   }); 
    // }
    
    // // 3. 授权后可获取 IDFA（可选）
    // if (await AppTrackingTransparency.trackingAuthorizationStatus == TrackingStatus.authorized) {
    //   final idfa = await AdvertisingId.id;
    //   print("用户已授权，IDFA: $idfa");
    // } else {
    //   print("用户未授权或设备不支持");
    // }
  }

  static void initStatusBar() {
    // 设置状态栏透明
    SystemChrome.setSystemUIOverlayStyle(
      initOverlayStyle()
    );
  }

  static SystemUiOverlayStyle initOverlayStyle() {
    return const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent, // 状态栏透明
        statusBarIconBrightness: Brightness.light, // 状态栏图标颜色（深色/浅色）
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: ByColor.colorBg1,
        systemNavigationBarDividerColor: Colors.transparent, // 分隔线颜色
      );
  }

  ///初始化本地化组件
  static Future<void> _initPF() async {
    await SpUtil.getInstance(); // 这里也要 await
  }

  ///初始化上下拉刷新配置
  static RefreshConfiguration initRefresh(Widget child) {
    // 全局配置子树下的SmartRefresher,下面列举几个特别重要的属性
    return RefreshConfiguration(
         headerBuilder: () => WaterDropHeader(),        // 配置默认头部指示器,假如你每个页面的头部指示器都一样的话,你需要设置这个
         footerBuilder:  () => ClassicFooter(),        // 配置默认底部指示器
         headerTriggerDistance: 70.0,        // 头部触发刷新的越界距离
         springDescription: SpringDescription(stiffness: 180, damping: 20, mass: 0.5),         // 自定义回弹动画,三个属性值意义请查询flutter api
         maxOverScrollExtent :100, //头部最大可以拖动的范围,如果发生冲出视图范围区域,请设置这个属性
         maxUnderScrollExtent:0, // 底部最大可以拖动的范围
         enableScrollWhenRefreshCompleted: true, //这个属性不兼容PageView和TabBarView,如果你特别需要TabBarView左右滑动,你需要把它设置为true
         enableLoadingWhenFailed : true, //在加载失败的状态下,用户仍然可以通过手势上拉来触发加载更多
         hideFooterWhenNotFull: true, // Viewport不满一屏时,禁用上拉加载更多功能
         enableBallisticLoad: true, // 可以通过惯性滑动触发加载更多
        child: child
    );
  }
}
