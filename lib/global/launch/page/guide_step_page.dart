/*
 * @Author: duncy
 * @Date: 2025-10-14 18:43:30
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2026-01-20 17:30:23
 * @FilePath: /novel_oversea/lib/global/launch/page/guide_step_page.dart
 * @Description: 
 */


import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:novel_oversea/core/ui/view/by_widgets_util.dart';
import 'package:novel_oversea/core/ui/widget/by_text.dart';
import 'package:novel_oversea/core/util/by_screen_utils.dart';
import 'package:novel_oversea/global/launch/controller/guide_step_controller.dart';
import 'package:novel_oversea/global/launch/view/guide_last_step_view.dart';
import 'package:novel_oversea/global/pay/page/pay_center_page.dart';
import 'package:novel_oversea/global/ui/colors.dart';
import 'package:novel_oversea/home/core/view/bottom_view.dart';

import '../../routes/app_pages.dart';

class GuideStepPage extends StatelessWidget {
  GuideStepPage({super.key});

  final GuideStepController controller = Get.put(GuideStepController());


  final List<String> stepTitles = [
    "CREATE YOUR OWN STORY \n WITH FEW WORDS",
    "PENMAN HELPS YOU \n WRITE FASTER",
    "PENMAN HELPS YOU PUBLISH \n YOUR WORK FASTER",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ByColor.colorBg1,
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return PopScope(
      canPop: false,
      child: PageView.builder(
        controller: controller.pageController,
        itemCount: stepTitles.length,
        onPageChanged: (value) {
          controller.currentIndex = value;
        },
        itemBuilder: (context, index) {
          return index == 2 ? GuideLastStepView() : _buildPage(context, index);
        },
      )
    );
  }

  ///页码内容
  Widget _buildPage(BuildContext context, int index) {
    return Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            alignment: Alignment.topCenter,
            image: AssetImage('assets/global/launch/icon_guide_step_$index.png'),
            fit: BoxFit.contain,
          ),
        ),
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        child: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ByText.text(
                      text: stepTitles[index],
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w500,
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      textColor: ByColor.colorF1,
                    ),
                    SizedBox(height: index == 2 && Platform.isAndroid ? 10 : 40,),
                    ///iOS 不显示套餐应对审核
                    if(index == 2 && Platform.isAndroid)
                    SizedBox(
                      height: 30,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ByText.text(
                              text: controller.selectPackage.title,
                              fontSize: 12.sp,
                              textColor: Color(0xFF8A959C),
                            ),
                          ByWidgetsUtil.commonRichText(
                              texts: [
                                TextSpan(text: 'Only ${controller.getPrice()} '),
                                TextSpan(
                                  text: controller.selectPackage.des,
                                  style: TextStyle(
                                    color: Color(0xFF8A959C)
                                  )),
                              ],
                              textColor: ByColor.colorF1,
                              fontSize: 12.sp
                            )
                        ],
                      ),
                    ),
                    SizedBox(height: 10,),
                    SizedBox(
                      height: 56.w,
                      child: BottomView(
                        padding: 0,
                        showWords: false,
                        isBottom: false,
                        margin: 0,
                        backgroundColor: Color(0xFF0048FF),
                        nextBtnText: index == 2 ? 'WRITE NOW' : 'CONTINUE',
                        arrowStyle: 1,
                        titleColor: ByColor.colorF0,
                        nextStep: () {
                          if(index == 2) {
                            ///iOS 直接跳主页面应对审核
                            if(Platform.isIOS) {
                              Get.offAllNamed(Routes.main);
                            }
                            else {
                              controller.startPay();
                            }
                            return;
                          }
                          controller.pageController.animateToPage(
                            controller.currentIndex + 1, 
                            duration: Duration(milliseconds: 200), 
                            curve: Curves.easeInOut);
                        },
                      ),
                    ),
                    SizedBox(height: index == 2 && Platform.isAndroid ? 40.w : 60.w,),
                    if(index == 2 && Platform.isAndroid)
                     AgreementView(),
                    SizedBox(height: 10.w + ByScreenUtils.bottomSafeHeight,),
                  ],
                ),
              ),
              if(index == 2)
              Positioned(
                left: 0,
                top: 12,
                child: GestureDetector(
                  onTap: () {
                    Get.offAllNamed(Routes.main);
                    return;
                  },
                  child: SizedBox(
                      width: 44.w,
                      height: 32.w,
                      child: Image.asset(
                        'assets/global/common/btn_close.png',
                        width: 16.w,
                        height: 16.w,)
                    ),
                ),)
            ],
          ),
        ),
      );
  }
}