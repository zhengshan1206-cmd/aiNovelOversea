/*
 * @Author: duncy
 * @Date: 2025-10-15 15:47:56
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2026-02-04 14:40:16
 * @FilePath: /novel_oversea/lib/home/main/controller/home_controller.dart
 * @Description: 
 */


import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:novel_oversea/core/cache/byhy_aes_storage_utils.dart';
import 'package:novel_oversea/global/launch/controller/launch_manager.dart';
import 'package:novel_oversea/home/main/dialog/score_dialog.dart';
import 'package:novel_oversea/me/user/user.dart';
import '../../../core/cache/daily_cache_manager.dart';
import '../../../core/network/http_utils.dart';
import '../../../core/network/novel_apis.dart';
import '../../../global/const/const_string.dart';
import '../../../global/login/controller/login_manager.dart';
import '../../../global/pay/view/home_discount_dialog.dart';
import '../../../global/routes/app_pages.dart';
import '../../create/bean/novel_category_bean.dart';
import '../../create/controller/novel_create_controller.dart';
import 'new_user_pay_controller.dart';

class HomeController extends GetxController{
  

  ///获取用户信息
  final UserController user = Get.find<UserController>();

  ///是否显示底部vip运营条
  RxBool showVipTips = true.obs;
  ///是否显示取消二次付费页拦截弹窗
  RxBool showRetainTips = false.obs;

  ///是否显示引导遮罩
  RxBool showGuideMask = false.obs;

  ///是否显示未完成小说
  RxBool showUnCompleteNovel = false.obs;

  @override
  void onInit() {
    FirebaseAnalytics.instance.logEvent(
      name: 'home_show_new',
    );
    _getTodayVipTips();
    checkUnCompleteNovel();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      
      ///首次进入
      if(GlobalController.instance.isFirstIn) {
        if(!user.isVip && GlobalController.instance.pay.vipListGuideDialogClose.isNotEmpty) {
          FirebaseAnalytics.instance.logEvent(name: 'OB_home_pay');
          Get.toNamed(Routes.newUserPayPage, arguments: {'type': SinglePayType.firstIn});
        }
        else {
          FirebaseAnalytics.instance.logEvent(name: 'OB_login');
          LoginManager.login(source: 'new_user', isGuide: true);
        }
      }
      else {
        showAppScore();
      }
    });
    super.onInit();
  }

  ///显示app评分
  void showAppScore() async{
    ///今日是否有弹出过星级评分
    final bool showtodayTips = await DailyManager.shouldShowPopup(ConstString.kScoreHomeDialog);
    ///用户是否进行过3星以上的打分
    bool scored = ByStorageUtils.getBool(ConstString.kUserScoreInStore) ?? false;
    if(!showtodayTips || scored) {
      return;
    }
    Future.delayed(Duration(seconds: 1), (){
      ScoreDialogManager.showScore();
    });
  }

  ///是否显示底部vip小条
  bool showBottomPayTips() {
    return (showVipTips.value || showRetainTips.value || showUnCompleteNovel.value) && !user.isVip;
  }

  void _getTodayVipTips() async{
    // showtodayTips = await DailyManager.shouldShowPopup(ConstString.kVipHomeTips);
    if(GlobalController.instance.pay.hasEnteredVip) {
      updataRetainValue();
    }
  }

  ///更新底部小条状态
  void updataRetainValue() {
    // if(showtodayTips) {
      showRetainTips.value = true;
    //   DailyManager.recordPopupDate(ConstString.kVipHomeTips);
    // }
  }

  ///底部小条显示类型
  int tipsType(){ 
    if(showUnCompleteNovel.value) {
      return 2;
    }
    if(showRetainTips.value) {
      return 1;
    }
    return 0;
  }

  ///关闭底部vip运营条
  void closeBottomOperation(int type) {
    if(type == 2) {
      showUnCompleteNovel.value = false;
      return;
    }
    showVipTips.value = false;
    showRetainTips.value = false;
  }

  ///运营条时间到
  void timeOutForTips(int type) {
    closeBottomOperation(type);
  }

  ///显示拦截弹窗付费页
  void showGift() {
    Get.bottomSheet(
      const HomeDiscountDialog(isHomeGift: true,),
      isDismissible: false,
      isScrollControlled: true,
      enableDrag: false,
    );
  }

  /// 点击bannner进入小说创作页
  void onBannerTap(int index) {
    Get.toNamed(
        Routes.novelCreateChat,
        arguments: {'type': CreationType.longNovel, 'partner': _generatePartner(index-1)},
      );
  }

  NovelCategoryBean _generatePartner(int index) {
    final List cate = [
      {
        "key": "urban_fantasy",
        "value": "Urban Fantasy",
        "name": "Conal",
        "icon":
            "https://cdn.aipenman.com/inchat/sys/general/2025-11-01/536c08131d4022e9c5600c14affef1b0.png",
        "remark":
            "Thirty years of demon-hunting experience had honed his ability to see through the city's deceptions, allowing him to det",
      },
      {
        "key": "dystopian_post_apocalyptic",
        "value": "Dystopian / Post-apocalyptic",
        "name": "Martin",
        "icon":
            "https://cdn.aipenman.com/inchat/sys/general/2025-11-01/39023e02b09cff3fe99bd0488ce31e84.png",
        "remark":
            "After the city's archives were tampered with, his existence became a rebellion against the creed that “whoever controls the past controls the future.”",
      },
      {
        "key": "space_opera",
        "value": "Space Opera",
        "name": "Margot",
        "icon": "",
        "remark":
            "A princess, she bore the scars of her homeworld's destruction, forging a rebel army from the ashes of a lif",
      },
      {
        "key": "historical_fiction",
        "value": "Historical Fiction",
        "name": "Albert",
        "icon":
            "https://cdn.aipenman.com/inchat/sys/general/2025-11-01/fe86f92b7e0cdcc83ccbe2a5d3255345.png",
        "remark":
            "He was once a fierce warrior under Caesar's command, yet at the Battle of Actium, he abandoned his knightly duty for Cleopatra.",
      },
    ];
    return NovelCategoryBean.fromJson(cate[index]);
  }

  ///检查非vip用户引导页是否有未完成的小说
  void checkUnCompleteNovel() async {
    if(!user.isVip) {
      HttpUtils.get(
        NovelApis.unCompleteNovel,
        {},
        showMsgWhenFailed: false,
        success: (data) {
            if (data['data']['is_show']) {
              showUnCompleteNovel.value = true;
            }
        },
      );
    }
  }
}