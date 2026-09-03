/*
 * @Author: duncy
 * @Date: 2026-01-27 16:35:07
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2026-02-10 10:22:47
 * @FilePath: /novel_oversea/lib/me/checkin/controller/checkin_controller.dart
 * @Description: 
 */


import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:get/get.dart';
import 'package:novel_oversea/core/pay/pay_manager.dart';
import 'package:novel_oversea/core/ui/dialog/loading_dialog.dart';
import 'package:novel_oversea/core/ui/view/muti_status_view.dart';
import 'package:novel_oversea/global/main/main_controller.dart';
import 'package:novel_oversea/me/user/user.dart';

import '../../../core/network/http_utils.dart';
import '../../../core/network/novel_apis.dart';
import '../../../core/ui/dialog/toast.dart';
import '../../../global/launch/controller/launch_manager.dart';
import '../../../global/pay/view/home_discount_dialog.dart';
import '../bean/checkin_bean.dart';
import '../dialog/checkin_dialog.dart';


class CheckinController extends GetxController {


  Rx<MultiStatusType> statusType = MultiStatusType.statusLoading.obs;

  /// 签到任务
  RxList<CheckinTaskBean> dataList = <CheckinTaskBean>[].obs;
  /// 签到数据
  CheckinTaskBean? checkinBean;
  /// 签到统计数据
  CheckinStats? checkinStats;
  /// 连续签到次数
  RxInt checkContinueDays = 0.obs;

  /// 套餐数据
  SinglePayManager? payManager;

  /// 需要显示的任务
  final List<String> showMission = ['novel_complete', 'vip'];

  final Map<String, String> missionTitles = {
    'invite': 'Invite Friends',
    'novel_complete': 'Today’s Writing Mission',
    'vip': 'Special Credits Offer',
  };

  final Map<String, String> btnTitles = {
    'invite': 'Invite',
    'novel_complete': 'Create',
    'vip': 'Get',
  };

  final UserController user = Get.find<UserController>();

  @override
  void onInit() {
    super.onInit();
    fetchTasks();
  }

  /// 添加优惠套餐
  void _addDiscountPackage() {
    if(!user.isVip && GlobalController.instance.pay.vipListHomeDiscount.isNotEmpty) {
      payManager = SinglePayManager(GlobalController.instance.pay.vipListHomeDiscount.first, PayManager(), sourcePosition: 4);
      CheckinTaskBean bean = CheckinTaskBean(id: 0, type: 'vip');
      dataList.add(bean);
    }
  }

  /// 跳转或领取积分
  void toggleAction(CheckinTaskBean bean) {
    if(bean.type == 'vip') {
      _showPackage();
    }
    else if(bean.type == 'novel_complete') {
      /// 去创建
      if(bean.claimStatus == 1) {
        Get.back();
        FirebaseAnalytics.instance.logEvent(name: 'event_center_create_click');
        Get.find<MainController>().tabChanged(0);
      }
      /// 领取奖励
      else if(bean.claimStatus == 2) {
        _getRewards(bean, onSuccess: () {
          int index = dataList.indexOf(bean);
          bean.claimStatus = 3;
          dataList[index] = bean;
        },);
      }
    }
    else {
      //  Get.toNamed(Routes.surveyPage);
    }
  }

  /// 显示优惠套餐
  void _showPackage() {
    Get.bottomSheet(
      const HomeDiscountDialog(isHomeGift: true,),
      isDismissible: false,
      isScrollControlled: true,
      enableDrag: false,
    );
  }

  ///拉取积分商品列表
  void fetchTasks({
    Function(dynamic data)? onSuccess,
    Function(int code, String msg)? onFail,
  }) {
    HttpUtils.get(
      NovelApis.checkinTask, 
      {},
      showMsgWhenFailed: false,
      success: (data) {
        //处理数据
        final List<dynamic> list = data['data']['tasks'] ?? [];
        final List<CheckinTaskBean> beans = list.map((e) => CheckinTaskBean.fromJson(e)).toList();
        checkinStats = CheckinStats.fromJson(data['data']['signin_stats'] ?? {});
        checkContinueDays.value = checkinStats?.currentStreak ?? 0;
        dataList.clear();
        for (final bean in beans) {
          if(bean.type == 'signin') {
            checkinBean = bean;
          } else {
            if(showMission.contains(bean.type)) {
              dataList.add(bean);
            }
          }
        }
        _addDiscountPackage();
        statusType.value = MultiStatusType.statusContent;
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

  /// 领取奖励
  void _getRewards(CheckinTaskBean bean, {Function()? onSuccess,}) {
    FirebaseAnalytics.instance.logEvent(name: 'event_center_create_get');
    LoadingDialog().show(message: 'getting...');
    HttpUtils.post(
      NovelApis.checkinReward, 
      {
        'task_id': bean.id,
      },
      showMsgWhenFailed: false,
      success: (data) {
        LoadingDialog().dismiss();
        CheckinDialogManager.showCheckinDialog(CheckinMissionType.novelComplete, bean.rewardsValue ?? 1000);
        user.reloadUserInfo();
        onSuccess?.call();
      },
      fail: (code, msg) {
        LoadingDialog().dismiss();
        Toast.showText(text: msg);
      });
  }

  /// 签到
  void checkin({
    Function(dynamic data)? onSuccess,
    Function(int code, String msg)? onFail,
  }) {
    FirebaseAnalytics.instance.logEvent(name: 'checkin_click');
    if(checkinStats == null || checkinStats!.signed!) {
      Toast.showText(
        type: ToastType.success,
        text: 'You have already checked in today.');
      return;
    }
    LoadingDialog().show(message: 'checkin...');
    HttpUtils.post(
      NovelApis.checkin, 
      {},
      showMsgWhenFailed: false,
      success: (data) {
        LoadingDialog().dismiss();
        FirebaseAnalytics.instance.logEvent(name: 'checkin_suc');
        int rewards = 1000;
        checkContinueDays.value += 1;
        try {
          rewards = data['data']['record']['reward_words'];
        } catch (e) {
          rewards = 1000;
        }
        CheckinDialogManager.showCheckinDialog(CheckinMissionType.checkin, rewards);
        user.reloadUserInfo();
        fetchTasks();
      },
      fail: (code, msg) {
        LoadingDialog().dismiss();
        Toast.showText(text: msg);
      });
  }
}