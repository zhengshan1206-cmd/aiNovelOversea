/*
 * @Author: duncy
 * @Date: 2026-01-06 10:56:09
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2026-01-09 18:11:03
 * @FilePath: /novel_oversea/lib/global/login/view/first_login_dialog.dart
 * @Description: 
 */



import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:novel_oversea/core/ui/widget/by_text.dart';
import 'package:novel_oversea/core/util/extentions.dart';
import 'package:novel_oversea/global/main/main_controller.dart';
import 'package:novel_oversea/global/pay/page/pay_center_page.dart';
import 'package:novel_oversea/global/ui/colors.dart';

import '../../../home/main/controller/new_user_pay_controller.dart';
import '../../../me/user/user.dart';
import '../../launch/controller/launch_manager.dart';
import '../../routes/app_pages.dart';

class FirstLoginDialogManager {
  static void showLoginDialog(bool isFirstLogin) {
    showDialog(
      context: Get.context!,
      builder: (context) {
        return FirstLoginDialog(isFirstLogin: isFirstLogin,);
      },
    );
  }
}

class FirstLoginDialog extends StatelessWidget {
  const FirstLoginDialog({super.key, required this.isFirstLogin});

  final bool isFirstLogin;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Container(
          height: 494.w,
          width: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/global/login/icon_login_success${isFirstLogin ? '_first' : ''}_bg.png'))
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              isFirstLogin ? Container(
                height: 80.w,
                padding: EdgeInsets.symmetric(horizontal: 75.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                  ByText.text(
                          text: '10K',
                          textColor: ByColor.colorF8,
                          fontSize: 38.sp,
                          fontWeight: FontWeight.w600
                        ),
                  SizedBox(height: 24.w,),
                  SizedBox(
                    width: 120.w,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ByText.text(
                                text: 'Congratulations!',
                                textColor: ByColor.colorF8,
                                fontSize: 15.sp,
                              ),
                        ByText.text(
                                text: 'You’ve received',
                                textColor: ByColor.colorF8,
                                fontSize: 13.sp,
                              ),
                        ByText.text(
                                text: '10K Credits',
                                textColor: ByColor.colorG3,
                                fontSize: 13.sp,
                                fontWeight: FontWeight.bold
                              ),
                      ],
                    ),
                  ),
                ],),
              ) : ByText.text(
                                text: 'Start creating story now.',
                                textColor: ByColor.colorF2,
                                fontSize: 17.sp,
                              ),
              SizedBox(height: 60.w,),
              GestureDetector(
                onTap: () {
                  Get.back();
                  final MainController mainController = Get.find<MainController>();
                  mainController.tabChanged(0);
                  if (!Get.find<UserController>().isVip && GlobalController.instance.pay.vipListLoginClose.isNotEmpty) {
                    FirebaseAnalytics.instance.logEvent(name: 'OB_login_pay');
                    Get.toNamed(
                      Routes.newUserPayPage,
                      arguments: {'type': SinglePayType.loginClose},
                    );
                  }
                },
                child: Stack(
                  children: [
                    ShimmerBtn(
                      child: Container(
                        height: 56.w,
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          vertical: 4.w,
                          horizontal: 60.w,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Color(0xFF0552FB),
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: Center(
                        child: ByText.text(
                          text: 'Start Creating',
                          textColor: ByColor.colorF0,
                          fontSize: 17.sp,
                          fontWeight: FontWeight.w600
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: isFirstLogin ? 16.w : 72.w,),
              GestureDetector(
                onTap: () {
                  Get.back();
                  if (!Get.find<UserController>().isVip && GlobalController.instance.pay.vipListLoginClose.isNotEmpty) {
                    FirebaseAnalytics.instance.logEvent(name: 'OB_login_pay');
                    Get.toNamed(
                      Routes.newUserPayPage,
                      arguments: {'type': SinglePayType.loginClose},
                    );
                  }
                },
                child: Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.w),
                    color: ByColor.colorF0.withAlphaValue(0.1)
                  ),
                  child: Image.asset('assets/global/common/btn_close.png'),
                ),
              ),
              SizedBox(height: 40.w,),
            ],
          ),
        ),
      ),
    );
  }
}