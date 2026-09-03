

import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:novel_oversea/core/ui/view/by_widgets_util.dart';
import 'package:novel_oversea/core/ui/widget/by_text.dart';
import 'package:novel_oversea/global/launch/view/guide_last_step_view.dart';
import 'package:novel_oversea/global/login/controller/login_manager.dart';
import 'package:novel_oversea/home/main/controller/new_user_pay_controller.dart';

import '../../../core/util/extentions.dart';
import '../../../global/ui/colors.dart';

class NewUserPayPage extends StatelessWidget {
  NewUserPayPage({super.key});

  final NewUserPayController controller = Get.put(NewUserPayController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0552FB),
      body: SafeArea(
        child: SizedBox(
          // decoration: BoxDecoration(
          //   image: DecorationImage(
          //     alignment: Alignment.topCenter,
          //     image: AssetImage('assets/home/main/new_user_pay_bg.png',),
          //     fit: BoxFit.contain,
          //   ),
          // ),
          child: Stack(
            children: [
              Positioned(
                left: 30.w,
                right: 30.w,
                top: 0,
                child: Transform.translate(
                  offset: Offset(0, Platform.isIOS ? -180.w : -50.w),
                  child: Image.asset(
                          'assets/home/main/new_user_pay_bg.png',),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    child: Image.asset(
                        'assets/home/main/new_user_pay_tip.png',),
                  ),
                  SizedBox(height: 25.w,),
                  Container(
                    height: 249.w,
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    margin: EdgeInsets.symmetric(horizontal: 12.w),
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        alignment: Alignment.topCenter,
                        image: AssetImage('assets/home/main/new_user_pay_offer.png',),
                        fit: BoxFit.fill,
                      ),
                    ),
                    child: Column(
                      children: [
                        SizedBox(height: 91.w,),
                        ByText.text(
                          text: controller.pay.bean.title,
                          fontSize: 20.sp,
                          textColor: ByColor.colorF8,
                          fontWeight: FontWeight.bold),
                        SizedBox(height: 4.w,),
                        ByWidgetsUtil.commonRichText(
                          textColor: ByColor.colorG4,
                          fontWeight: FontWeight.bold,
                          texts: [
                          TextSpan(
                            text: controller.pay.getLocalSymbol(),
                            style: TextStyle(
                              fontSize: 26.sp
                            )
                          ),
                          TextSpan(
                            text: '  ',
                          ),
                          TextSpan(
                            text: controller.pay.getAveragePrice(type: 1),
                            style: TextStyle(
                              fontSize: 52.sp
                            )
                          ),
                          TextSpan(
                            text: '  ',
                          ),
                          TextSpan(
                            text: controller.pay.getAverageText(),
                            style: TextStyle(
                              fontSize: 32.sp
                            )
                          ),
                        ]),
                        SizedBox(height: 8.w,),
                        ByText.text(
                          text: '${controller.pay.getPrice(isDiscount: true)} ${controller.pay.bean.des} ${controller.pay.getPrice()} ${controller.pay.bean.illustrate}',
                          fontSize: 17.sp,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          textColor: ByColor.colorF2,
                          fontWeight: FontWeight.w500),
                      ],
                    ),
                  ),
                  SizedBox(height: 40.w,),
                  GuidePayBottomView(
                    btnColor: Color(0xFFFFDC4E),
                    style: 0,
                    nextBtnText: controller.pay.getButtonText(),
                    nextStep: () {
                      FirebaseAnalytics.instance.logEvent(name: 'OB_${controller.payType == SinglePayType.firstIn ? 'home' : 'login'}_pay_continue');
                      controller.pay.startPay();
                  }),
                ],
              ),
              Positioned(
                  left: 0,
                  top: 12,
                  child: GestureDetector(
                    onTap: () {
                      Get.back();
                      FirebaseAnalytics.instance.logEvent(name: 'OB_${controller.payType == SinglePayType.firstIn ? 'home' : 'login'}_pay_close');
                      ///新用户进入登录页
                      if(controller.payType == SinglePayType.firstIn) {
                        FirebaseAnalytics.instance.logEvent(name: 'OB_login');
                        LoginManager.login(source: 'new_user', isGuide: true);
                      }
                    },
                    child: Container(
                      width: 36.w,
                      height: 36.w,
                      margin: EdgeInsets.only(left: 12.w),
                      padding: EdgeInsets.all(2.w),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: ByColor.colorF8.withAlphaValue(0.25)
                      ),
                      child: SizedBox(
                          width: 32.w,
                          height: 32.w,
                          child: Image.asset(
                            'assets/global/common/btn_close.png',
                            width: 16.w,
                            height: 16.w,)
                        ),
                    ),
                  ),)
            ],
          ),
        ),
      ),
    );
  }
}