/*
 * @Author: duncy
 * @Date: 2026-01-15 16:26:36
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2026-02-12 11:54:09
 * @FilePath: /novel_oversea/lib/me/checkin/page/checkin_page.dart
 * @Description: 
 */


import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:novel_oversea/core/service/words.dart';
import 'package:novel_oversea/core/ui/page/base_page.dart';
import 'package:novel_oversea/core/ui/view/by_widgets_util.dart';
import 'package:novel_oversea/core/ui/view/muti_status_view.dart';
import 'package:novel_oversea/core/ui/widget/by_text.dart';
import 'package:novel_oversea/core/util/extentions.dart';
import 'package:novel_oversea/global/ui/colors.dart';
import 'package:novel_oversea/me/checkin/bean/checkin_bean.dart';
import 'package:novel_oversea/me/checkin/controller/checkin_controller.dart';

import '../../../global/routes/app_pages.dart';

// ignore: must_be_immutable
class CheckinPage extends BasePage{
  CheckinPage({super.key});

  @override
  String get title => 'Check in';

  @override
  CheckinController get controller => Get.find<CheckinController>();

  final Map<String, String> missionAssets = {
    'invite': 'check_mission_invite.png',
    'novel_complete': 'check_mission_write.png',
    'vip': 'check_mission_credits.png',
  };

  final Map<String, String> missionContents= {
    'invite': 'Invite one friend and earn writing credits for stories, chapters, and ideas.',
  };


  @override
  Widget buildBody(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Obx(() => MultiStatusView(
        currentStatus: controller.statusType.value,
        action: () => controller.fetchTasks(),
        child: Stack(
          children: [
            Positioned(
              top: 17.w,
              right: 15.w,
              child: Image.asset(
                  'assets/tutorial/checkin/check_top_bg.png',
                  width: 80.w,
                  height: 160.w,),
              ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 8.w,),
                  GestureDetector(
                    onTap: () {
                      Get.toNamed(Routes.creditsItemList);
                    },
                    child: Row(
                      children: [
                        Image.asset(
                          'assets/tutorial/checkin/check_credits.png',
                          width: 24.w,
                          height: 24.w,),
                        SizedBox(width: 8.w,),
                        ByText.text(
                          text: controller.user.getUserWords(),
                          fontWeight: FontWeight.bold,
                          fontSize: 36.sp,),
                        SizedBox(width: 8.w,),
                        Image.asset(
                          'assets/global/common/arrow_right.png',
                          width: 14.w,
                          height: 14.w,),
                      ],
                    ),
                  ),
                  SizedBox(height: 8.w,),
                  GestureDetector(
                    child: Image.asset(
                      'assets/tutorial/checkin/check_get_more.png',
                      width: 80.w,
                      height: 24.w,
                    ),
                    onTap: () {
                      FirebaseAnalytics.instance.logEvent(name: 'event_center_sub_click');
                      controller.user.jumpToPayPage(source: 'checkin');
                    },
                  ),
                  SizedBox(height: 32.w,),
                  _buildCheckinView(),
                  SizedBox(height: 11.w,),
                  _buildMissionView(),
                ],
              ),
            ),
          ],
        ),
      )),
    );
  }

  /// 签到页面
  Widget _buildCheckinView() {
    return Container(
      height: 156.w,
      padding: EdgeInsets.symmetric(vertical: 12.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14.w),
        border: Border.all(color: ByColor.colorF0.withAlphaValue(0.08)),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        child: Column(
          children: [
            Row(
              children: [
                Obx(() => ByText.text(text: 'Check - in Streak ${controller.checkContinueDays.value} days', fontSize: 15.sp)),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    /// 签到
                    controller.checkin();
                  },
                  child: Container(
                    height: 24.w,
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.w),
                      border: Border.all(
                        color: ByColor.colorF0.withAlphaValue(0.2)
                      )
                    ),
                    child: Center(child: ByText.text(text: 'Check in', fontSize: 12.sp))),
                ),
              ],
            ),
            SizedBox(height: 10.w,),
            SizedBox(
              height: 94.w,
              child: ListView.separated(
                itemCount: controller.checkinBean != null ? controller.checkinBean!.config!.rewards!.length : 0,
                scrollDirection: Axis.horizontal,
                separatorBuilder: (context, index) {
                  return SizedBox(width: 8.w,);
                },
                itemBuilder: (context, index) {
                  CheckinRewards rewards = controller.checkinBean?.config?.rewards?[index];
                return Opacity(
                  opacity: rewards.claim ? 0.5 : 1.0,
                  child: Column(
                    children: [
                      Container(
                        width: 65.w,
                        height: 74.w,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.w),
                          color: Color(0xFFFFCFCF).withAlphaValue(0.15),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Image.asset(
                              'assets/tutorial/checkin/check_${rewards.claim ? 'date_uncheck' : 'credits'}.png',
                              width: 24.w,
                              height: 24.w,
                            ),
                            ByText.text(
                              text: 'x${WordsService.wordsDisplay(rewards.reward.toString())}',
                              fontWeight: FontWeight.w500,
                              textColor: ByColor.colorF1,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 20.w,
                        child: Center(
                          child: ByText.text(
                            text: rewards.name, 
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w500,
                            textColor: ByColor.colorF0.withAlphaValue(0.5)),
                        ),
                      )
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  /// 签到任务页面
  Widget _buildMissionView() {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(14.w)),
      child: Obx(() => ListView.separated(
        itemCount: controller.dataList.length + 1,
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        separatorBuilder: (context, index) {
          return Container(
            height: 1.h,
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            color: Color(0xFF1A171E),
            child: Container(
              color: ByColor.colorBg3,
            ),
          );
        },
        itemBuilder: (context, index) {
          return index == 0
              ? Container(
                  height: 58.w,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(14.w), topRight: Radius.circular(14.w)),
                    image: DecorationImage(
                      alignment: Alignment.topCenter,
                      fit: BoxFit.fill,
                      image: AssetImage(
                        'assets/tutorial/checkin/check_mission_bg.png',
                      ),
                    ),
                  ),
                  child: Container(
                    margin: EdgeInsets.only(top: 10.w),
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    child: ByText.text(
                      text: 'Activity List',
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w500,
                      textColor: ByColor.colorF1,
                    ),
                  ),
                )
              :  _buildMissionItem(index - 1);
        },
      )),
    );
  }

  /// 任务item
  Widget _buildMissionItem(int index) {
    CheckinTaskBean bean = controller.dataList[index];
    print('______${bean.claimStatus},${bean.type}');
    return Container(
      height: 80.w,
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      decoration: BoxDecoration(
        color: Color(0xFF1A171E),
        borderRadius: index == 2 ? BorderRadius.only(bottomLeft: Radius.circular(14.w), bottomRight: Radius.circular(14.w)) : null,
      ),
      child: Row(
        children: [
          Image.network(
            bean.icon ?? '',
            width: 32.w,
            height: 32.w,
            errorBuilder: (context, error, stackTrace) {
              return Image.asset(
                'assets/tutorial/checkin/${missionAssets[bean.type]}',
                width: 32.w,
                height: 32.w,
              );
            },
          ),
          SizedBox(width: 8.w,),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ByText.text(
                text: controller.missionTitles[bean.type] ?? '',
                fontWeight: FontWeight.w500,
                textColor: ByColor.colorF1,
              ),
              Container(
                constraints: BoxConstraints(
                  maxWidth: 201.w,
                ),
                child: _buildDescView(bean)
              ),
            ],
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {
              controller.toggleAction(bean);
            },
            child: Container(
              height: 30.w,
              width: 72.w,
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15.w),
                color: bean.type == 'novel_complete' && bean.claimStatus != null && bean.claimStatus! > 2 ? ByColor.colorF2 : Color(0xFF6367EC),
              ),
              child: Center(
                child: ByText.text(
                  text: bean.claimStatus == 1 ? (controller.btnTitles[bean.type] ?? 'Get') : 'Get',
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  textColor: ByColor.colorF1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 创建描述视图
  Widget _buildDescView(CheckinTaskBean bean) {
    if (bean.type == 'novel_complete') {
      return ByWidgetsUtil.commonRichText(
        maxLines: 2,
        textColor: ByColor.colorF2.withAlphaValue(0.6),
        fontSize: 11.sp,
        texts: [
          TextSpan(text: 'Complete one small task and earn '),
          TextSpan(text: WordsService.wordsDisplay(bean.rewardsValue.toString()), style: TextStyle(color: ByColor.colorG3)),
          TextSpan(text: ' credits.'),],
      );
    }

    if (bean.type == 'vip') {
      // return ByWidgetsUtil.commonRichText(
      //   maxLines: 2,
      //   textColor: ByColor.colorF2.withAlphaValue(0.6),
      //   fontSize: 11.sp,
      //   texts: [
      //     TextSpan(text: 'Complete one small task and earn '),
      //     TextSpan(text: WordsService.wordsDisplay(bean.rewardsValue.toString()), style: TextStyle(color: ByColor.colorG3)),
      //     TextSpan(text: ' credits.'),],
      // );
      return ByText.text(
                  text: 'Available for a limited time，${controller.payManager?.getPrice()} ${controller.payManager?.bean.des}.',
                  maxLines: 2,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w500,
                  textColor: ByColor.colorF2.withAlphaValue(0.6)
      );
    }
      
    return ByText.text(
                  text: missionContents[bean.type] ?? '',
                  maxLines: 2,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w500,
                  textColor: ByColor.colorF2.withAlphaValue(0.6)
    );
  }
}