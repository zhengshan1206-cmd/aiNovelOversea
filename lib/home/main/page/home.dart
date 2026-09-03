
// ignore_for_file: avoid_print

/*
 * @Author: cold-x
 * @Date: 2025-09-15 17:34:20
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2026-02-26 16:42:48
 * @FilePath: /novel_oversea/lib/home/main/page/home.dart
 * @Description: 
 */

import 'dart:io';
import 'dart:math';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svga/flutter_svga.dart';
import 'package:get/get.dart';
import 'package:novel_oversea/core/ui/widget/by_text.dart';
import 'package:novel_oversea/core/util/by_screen_utils.dart';
import 'package:novel_oversea/global/launch/controller/launch_manager.dart';
import 'package:novel_oversea/global/routes/app_pages.dart';
import 'package:novel_oversea/global/ui/colors.dart';
import 'package:novel_oversea/home/create/controller/novel_create_controller.dart';
import 'package:novel_oversea/home/main/controller/home_controller.dart';
import 'package:novel_oversea/home/main/dialog/discount_popup_dialog.dart';
import 'package:novel_oversea/home/main/dialog/home_banner_view.dart';

import '../view/guide_mask_view.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late AnimationController _floatController;
  late Animation<double> _floatAnimation;

  final HomeController controller = Get.find<HomeController>();

  // 1. 定义目标组件的GlobalKey（用于定位遮罩）
  final GlobalKey _targetKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);
    _floatAnimation = Tween<double>(begin: 0, end: 15).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    if (controller.user.couldTry && GlobalController.instance.isFirstIn && !controller.user.isVip) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(Duration(milliseconds: 300), () {
          FirebaseAnalytics.instance.logEvent(name: 'Create_OB_show');
          controller.showGuideMask.value = true;
        });
      });
    }
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ByColor.colorBg1,
      body: buildBody(context),
    );
  }

  Widget buildBody(BuildContext context) {
    final double availableHeight = ScreenUtil().screenHeight - 360.w - ByScreenUtils.topSafeHeight - 84.w;
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          fit: BoxFit.contain,
          alignment: AlignmentGeometry.topCenter,
          image: AssetImage('assets/home/main/icon_home_bg.png'),
        ),
      ),
      child: Stack(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Container(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: (Platform.isAndroid ? 8.w : 0) + ByScreenUtils.topSafeHeight),
                      Row(
                        children: [
                          Container(
                            height: 40.w,
                            width: 100.w,
                            margin: EdgeInsets.only(left: 16.w),
                            alignment: Alignment.centerLeft,
                            child: ByText.text(
                              text: "Write",
                              fontSize: 28.sp,
                              fontWeight: FontWeight.bold,
                              textColor: ByColor.colorF1,
                            ),
                          ),
                          const Spacer(),
                          Obx(() => GlobalController.instance.pay.vipListHomeDiscount.isNotEmpty && !controller.user.isVip ? Stack(
                            children: [
                              SizedBox(
                                width: 52.w,
                                height: 52.w,
                                child: SVGAEasyPlayer(
                                  assetsName: 'assets/home/main/home_gift.svga',
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  controller.showGift();
                                },
                                child: Container(
                                  width: 52.w,
                                  height: 52.w,
                                  color: Colors.transparent,
                                ),
                              ),
                            ],
                          ) : Container()),
                        ],
                      ),
                      SizedBox(height: 12.w),
                      // SizedBox(
                      //   height: min(302.w, availableHeight),
                      //   width: double.infinity,
                      //   child: SVGAEasyPlayer(
                      //     assetsName: 'assets/home/main/svga_home_banner.svga',
                      //     // autoPlay: true,
                      //     // loop: true,
                      //   ),
                      // ),
                      SizedBox(
                        height: min(302.w, availableHeight),
                        width: double.infinity,
                        child: HomeBannerView(
                          height: min(302.w, availableHeight),
                          onTap: (index) {
                            controller.onBannerTap(index);
                          },
                        ),
                      ),
                      SizedBox(
                        height: 40.w,
                        child: ByText.text(
                          text: "Choose to write",
                          fontSize: 28.sp,
                          fontWeight: FontWeight.bold,
                          textColor: ByColor.colorF1,
                        ),
                      ),
                      SizedBox(height: 16.w),
                      Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        margin: EdgeInsets.symmetric(horizontal: 24.w),
                        child: ByText.text(
                          textAlign: TextAlign.center,
                          text:
                              "We have plenty writing experts to assist you with your writing",
                          fontSize: 15.sp,
                          maxLines: 2,
                          fontWeight: FontWeight.bold,
                          textColor: ByColor.colorF2,
                        ),
                      ),
                      SizedBox(height: 25.w),
                      Obx(() => !controller.showBottomPayTips() ? AnimatedBuilder(
                        animation: _floatAnimation,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(0, -_floatAnimation.value),
                            child: child,
                          );
                        },
                        child: SizedBox(
                            height: 40.w,
                            width: 40.w,
                            child: Image.asset('assets/home/main/icon_home_arrow_down.png'),
                          ),
                      ) : Container()),
                      SizedBox(height: 10.w),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        child: Row(
                          children: [
                            _buildWritingBtn('assets/home/main/btn_home_book_write.png', 'Story Writer', 'For Short stories or standalone scenes'),
                            SizedBox(width: 8.w),
                            _buildWritingBtn('assets/home/main/btn_home_story_write.png', 'Book Writer', 'Perfect for developing thorough, full-scale novels'),
                          ],
                        ),
                      ),
                      SizedBox(height: 20.w,),
                      Obx(
                        () => controller.showBottomPayTips()
                            ? SizedBox(height: controller.tipsType() == 0 ? 50.w : 70.w)
                            : Container(),
                      ),
                    ],
                  ),
                ),
              );
            }
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Obx(
              () => controller.showBottomPayTips()
                  ? PayDiscountPopView(
                      type: controller.tipsType(),
                      action: () {
                        Get.toNamed(Routes.payCenterPage);
                      },
                      cancel: () {
                        controller.closeBottomOperation(controller.tipsType());
                      },
                      timeOut: () {
                        controller.closeBottomOperation(controller.tipsType());
                      },
                    )
                  : Container(),
            ),
          ),
          // 引导遮罩层（仅当showGuideMask为true时显示）
          Obx(() => controller.showGuideMask.value ? GuideMask(
              targetKey: _targetKey, // 目标组件的Key
              onMaskTap: () {
                FirebaseAnalytics.instance.logEvent(name: 'Create_OB_type');
                Get.toNamed(
                  Routes.novelCreateCategory ,
                  arguments: {'type': CreationType.shortNovel, 'guide': true},
                );
                controller.showGuideMask.value = false;
              },
            ) : Container())
        ],
      ),
    );
  }

  ///写小说按钮
  Widget _buildWritingBtn(String background, String title, String desc) {
    return Expanded(
      key: title == 'Book Writer' ? null : _targetKey,
      child: GestureDetector(
        onTap: () {
          FirebaseAnalytics.instance.logEvent(
            name: title == 'Book Writer' ? 'book_click' : 'story_click',
          );
          Get.toNamed(
            Routes.novelCreateCategory ,
            arguments: {'type': title == 'Book Writer' ?  CreationType.longNovel : CreationType.shortNovel},
          );
        },
        child: Stack(
          children: [
            Positioned(child: Image.asset(background)),
            Positioned(
              left: 12.w,
              top: 12.w,
              child: ByText.text(
                textColor: ByColor.colorF8,
                fontSize: 17.sp,
                fontWeight: FontWeight.w700,
                text: title)),
            Positioned(
              left: 12.w,
              top: 40.w,
              right: 20.w,
              child: ByText.text(
                maxLines: 3,
                fontSize: 12.sp,
                textColor: ByColor.colorF8,
                text: desc)),
          ],
        ),
      ),
    );
  }
}