/*
 * @Author: duncy
 * @Date: 2025-09-24 16:35:48
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2026-01-09 14:22:32
 * @FilePath: /novel_oversea/lib/home/create/page/create_partner_page.dart
 * @Description: 
 */


import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:novel_oversea/core/ui/page/base_page.dart';
import 'package:novel_oversea/core/ui/view/muti_status_view.dart';
import 'package:novel_oversea/core/ui/widget/by_button.dart';
import 'package:novel_oversea/core/ui/widget/by_text.dart';
import 'package:novel_oversea/core/util/by_screen_utils.dart';
import 'package:novel_oversea/global/const/const_utils.dart';
import 'package:novel_oversea/global/ui/colors.dart';
import 'package:novel_oversea/home/create/controller/create_category_controller.dart';
import 'package:novel_oversea/home/create/view/image_picker.dart';

import '../../main/view/guide_mask_view.dart';

// ignore: must_be_immutable
class ChoosePartnerPage extends BasePage {
  ChoosePartnerPage({super.key});

  @override
  String get title => 'Choose Your Write Partner';

  @override
  bool get hasAppBar => false;

  @override
  CreateCategoryController get controller => Get.put(CreateCategoryController());

  List<String> items = ['assets/home/create/icon_home_create_partner_0.png',
                        'assets/home/create/icon_home_create_partner_1.png',
                        'assets/home/create/icon_home_create_partner_2.png',];
  List<String> names = ['Steve','Yoseph','Cristina',];


  @override
  Widget buildBody(BuildContext context) {
    return PopScope(
      canPop: !controller.isGuide,
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.contain,
            alignment: AlignmentGeometry.topCenter,
            image: AssetImage('assets/home/create/icon_create_bg.png'),
          ),
        ),
        child: Stack(
          children: [
            SafeArea(
              child: Column(
                children: [
                  NavigationTitleView(title: title),
                  Obx(() => Expanded(
                    child: MultiStatusView(
                      currentStatus: controller.statusType.value,
                      action: () {
                        controller.fetchNovelCategory();
                      },
                      child: Column(
                        children: [
                          SizedBox(height: 20.h),
                          RotatingImagePicker(
                            imageWidth: 218.w,
                            imageHeight: 267.w,
                          ),
                          SizedBox(height: 28.h),
                          SizedBox(
                            height: 40.w,
                            child: ByText.text(
                              text: "Choose to write",
                              fontSize: 28.sp,
                              fontWeight: FontWeight.bold,
                              textColor: ByColor.colorF1,
                            ),
                          ),
                          SizedBox(height: 16.h),
                          Container(
                            alignment: Alignment.center,
                            padding: EdgeInsets.symmetric(horizontal: 20.w),
                            margin: EdgeInsets.symmetric(horizontal: 12.w),
                            child: Obx(() => ByText.text(
                              textAlign: TextAlign.center,
                              text:
                                  controller.categoryList[controller.index.value].remark,
                              fontSize: 15.sp,
                              maxLines: 4,
                              fontWeight: FontWeight.bold,
                              textColor: ByColor.colorF2,
                            )),
                          ),
                          const Spacer(),
                          if(!controller.isGuide)
                          Stack(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 20.w),
                                width: double.infinity,
                                child: ByButton.textButton(
                                  title: 'CONTINUE',
                                  borderRadius: BorderRadius.circular(24.w),
                                  onPressed: () {
                                    controller.nextStep();
                                  },
                                ),
                              ),
                              Positioned(
                                right: 32.w,
                                top: 16.w,
                                bottom: 16.w,
                                child: Image.asset(
                                  'assets/home/create/icon_home_create_continue.png',
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 48.w + ByScreenUtils.bottomSafeHeight),
                        ],
                      ),
                    ),
                  )),
                ],
              ),
            ),
            if(controller.isGuide)
              Obx(() => controller.categoryList.isNotEmpty ? GuideBottomMaskView(
                offY: 48.w + ByScreenUtils.bottomSafeHeight,
                onMaskTap: () {
                  FirebaseAnalytics.instance.logEvent(name: 'Create_OB_story_type');
                  controller.nextStep();
                },
              ) : Container())
          ],
        ),
      ),
    );
  }
}

class NavigationTitleView extends StatelessWidget {
  const NavigationTitleView({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: ConstUtils.getNavigationHeight(),
      child: Stack(
        children: [
          Center(
            child: ByText.text(
              text: title,
              fontSize: 17.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          Positioned(
            left: 0,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                Get.back();
              },
              child: Container(
                width: 56.w,
                height: ConstUtils.getNavigationHeight(),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                alignment: Alignment.centerLeft,
                child: Image.asset(
                    "assets/global/common/btn_back.png",
                    width: 16.w,
                    height: 16.w,
                  ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}