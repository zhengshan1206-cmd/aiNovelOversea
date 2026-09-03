/*
 * @Author: duncy
 * @Date: 2025-09-15 17:34:41
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2026-02-10 10:13:48
 * @FilePath: /novel_oversea/lib/tutorial/page/tutorial.dart
 * @Description: 
 */




import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:novel_oversea/core/ui/view/muti_status_view.dart';
import 'package:novel_oversea/core/ui/widget/by_refresh.dart';
import 'package:novel_oversea/core/ui/widget/by_text.dart';
import 'package:novel_oversea/global/routes/app_pages.dart';
import 'package:novel_oversea/global/ui/colors.dart';
import 'package:novel_oversea/me/user/user.dart';
import 'package:novel_oversea/tutorial/controller/tutorial_controller.dart';
import 'package:novel_oversea/tutorial/view/tutorial_cell.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:skeletonizer/skeletonizer.dart';


class TutorialPage extends StatefulWidget {
  const TutorialPage({super.key});

  @override
  State<TutorialPage> createState() => _TutorialPageState();
}

class _TutorialPageState extends State<TutorialPage> {

  final TutorialController controller = Get.find<TutorialController>();
  final userController = Get.find<UserController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ByColor.colorBg1,
      body: buildBody(context),
    );
  }

  Widget buildBody(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          if(Platform.isAndroid)
            SizedBox(height: 8.h),
          Row(
            children: [
              Container(
                height: 40.w,
                margin: EdgeInsets.only(left: 16.w),
                alignment: Alignment.centerLeft,
                child: ByText.text(
                  text: "Tutorial",
                  fontSize: 28.sp,
                  fontWeight: FontWeight.bold,
                  textColor: ByColor.colorF1,
                ),
              ),
              const Spacer(),
              GestureDetector(
                child: Image.asset('assets/tutorial/tutorial_check.png',width: 52.w, height: 52.w,),
                onTap: () {
                  FirebaseAnalytics.instance.logEvent(name: 'event_center_click');
                  Get.toNamed(Routes.checkinPage);
                },
              ),
              const SizedBox(width: 6,),
            ],
          ),
          SizedBox(height: 6.h),
          Obx(() => Expanded(
            child: Skeletonizer(
            enableSwitchAnimation: true,
            enabled: !controller.loadComplete.value,
            effect: ShimmerEffect(
              baseColor: Colors.grey[500]!,
              highlightColor: Colors.grey[300]!,
              duration: Duration(seconds: 1),
            ),
            child: MultiStatusView(
              currentStatus: controller.statusType.value,
              child: _squareListView())))),
        ],
      ),
    );
  }

  ///广场列表
  Widget _squareListView() {
    controller.refreshManager.refreshController = RefreshController();      
    return ByRefresh.refresh(
      controller: controller.refreshManager.refreshController,
      onLoad: () async {
        controller.getStrategyGuideList(isRefresh: false);
      },
      child: ListView.builder(
          padding: EdgeInsets.only(left: 12.w, right: 12.w, top: 12.w),
          itemCount: controller.tutorialList.length,
          itemBuilder: (context, index) {
            final strategy = controller.tutorialList[index];
            return StrategyListItem(
              strategy: strategy,
              onTap: () {
                userController.checkPreLogin(
                    source: 'square',
                    actionCallback: () {
                      Get.toNamed(Routes.tutorialDetail,
                          arguments: {"id": strategy.id});
                    });
              },
            );
          },
        ),
    );
  }
}
