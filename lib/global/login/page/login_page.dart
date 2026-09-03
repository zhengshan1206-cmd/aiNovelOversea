/*
 * @Author: cold-x
 * @Date: 2025-05-30 14:29:21
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2026-01-26 11:40:35
 * @FilePath: /novel_oversea/lib/global/login/page/login_page.dart
 * @Description: 登录页面
 */

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:novel_oversea/core/ui/page/base_page.dart';
import 'package:novel_oversea/core/ui/view/by_widgets_util.dart';
import 'package:novel_oversea/core/ui/widget/by_button.dart';
import 'package:novel_oversea/core/ui/widget/by_text.dart';
import 'package:novel_oversea/core/util/extentions.dart';
import 'package:novel_oversea/global/login/binbing/login_binding.dart';
import 'package:novel_oversea/global/login/controller/login_controller.dart';
import 'package:novel_oversea/global/login/page/login_email_page.dart';
import 'package:novel_oversea/global/routes/app_pages.dart';
import 'package:novel_oversea/global/ui/colors.dart';
import 'package:novel_oversea/me/user/user.dart';

import '../../../home/main/controller/new_user_pay_controller.dart';
import '../../launch/controller/launch_manager.dart';

///登录页面
// ignore: must_be_immutable
class LoginPage extends BasePage {
  LoginPage({super.key});

  @override
  bool get hasAppBar => false;

  @override
  LoginController get controller {
    // 确保控制器正确初始化
    if (!Get.isRegistered<LoginController>()) {
      LoginBinding().dependencies();
    }
    return Get.find<LoginController>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: ByColor.colorBg1,
      body: buildBody(context),
    );
  }

  @override
  Widget buildBody(BuildContext context) {
    return Stack(
      children: [
        Image.asset(
          'assets/global/login/icon_login_bg.png',
          fit: BoxFit.contain,
        ),
        Positioned(
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 120.w),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10.w),
                  child: Image.asset(
                    'assets/icon.png',
                    width: 80.w,
                    height: 80.w,
                  ),
                ),

                SizedBox(height: 16.h),

                ByText.text(
                  text: "Penman Pro",
                  textColor: ByColor.colorF1,
                  fontSize: 20.sp),

                SizedBox(height: 8.h),
                SizedBox(
                  height: 29.w,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ByText.text(
                        text: "New User Reward:",
                        textColor: ByColor.colorF1,
                        fontSize: 16.sp),
                      const SizedBox(width: 6,),
                      Image.asset(
                        'assets/global/login/icon_login_new_user.png',
                        height: 14.w,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 2.h),
                ByText.text(
                  text: "Log in now and write your first story.",
                  textColor: ByColor.colorF2.withAlphaValue(0.75),
                  fontSize: 15.sp),
                SizedBox(height: 24.h),
                ///google登录
                SizedBox(
                  height: 48.w,
                  width: double.infinity,
                  child: ByButton.iconButton(
                    icon: Image.asset('assets/global/login/btn_login_google.png'),
                    title: 'Sign in with Google',
                    size: 36.w,
                    backgroundColor: ByColor.colorF0,
                    onPressed: () {
                      controller.firebaseLoginAction(LoginType.google);
                    },
                  ),
                ),
                SizedBox(height: 20),

                ///苹果登录
                SizedBox(
                  height: 48.w,
                  width: double.infinity,
                  child: ByButton.iconButton(
                    icon: Image.asset('assets/global/login/btn_login_apple.png'),
                    backgroundColor: Color(0xFF0094F6),
                    size: 36.w,
                    titleColor: ByColor.colorF1,
                    title: 'Sign in with Apple',
                    onPressed: () {
                      controller.firebaseLoginAction(LoginType.apple);
                    },
                  ),
                ),
                SizedBox(height: 20),

                ///邮箱登录
                SizedBox(
                  height: 48.w,
                  width: double.infinity,
                  child: ByButton.iconButton(
                    icon: Image.asset('assets/global/login/btn_login_email.png'),
                    backgroundColor: ByColor.color2E3038,
                    size: 36.w,
                    titleColor: ByColor.colorF1,
                    title: 'Sign in with Email',
                    onPressed: () {
                      // controller.firebaseLoginAction(LoginType.email);
                      FirebaseAnalytics.instance.logEvent(
                        name: controller.source == 'new_user'
                            ? 'OB_login_click'
                            : 'login_attempt',
                        parameters: {'method': 'email'},
                      );
                      controller.showEmailPage = true;
                      Get.to(() => LoginEmailPage())!.then((_){
                        controller.showEmailPage = false;
                      });
                    },
                  ),
                ),
                const Spacer(),
                checkProtocalView(),
              ],
            ),
          ),
        ),
        closeView(),
        // phoneLoginView(),
      ],
    );
  }



  ///用户协议与隐私
  Widget checkProtocalView() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      child: ByWidgetsUtil.commonRichText(
        maxLines: 4,
        height: 1.5,
        textAlign: TextAlign.center,
        texts: [
          const TextSpan(
            text: "By continuing with an account, you agree to our",
          ),
          TextSpan(
            text: " Terms of Service ",
            style: const TextStyle(color: ByColor.colorC1),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                controller.getProtocolByTitle("User Agreement");
              },
          ),
          const TextSpan(text: "and acknowledge that you have read our"),
          TextSpan(
            text: " Privacy Policy",
            style: const TextStyle(color: ByColor.colorC1),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                controller.getProtocolByTitle("Privacy Policy");
              },
          ),
        ],
        fontSize: 12.sp,
        textColor: ByColor.colorF2.withAlphaValue(0.6),
      ),
    );
  }

  ///其他手机号登录按钮
  Widget phoneLoginView() {
    return Positioned(
        top: MediaQuery.of(Get.context!).padding.top,
        right: 12.w,
        child: GestureDetector(
          child: Container(
            padding: EdgeInsets.all(12.w),
            child: ByText.text(
              bgColor: Colors.transparent,
              textColor: ByColor.colorC1,
              fontWeight: FontWeight.w500,
              fontSize: 14,
              text: 'Sign in with Phone',
            ),
          ),
          onTap: () {
            Get.toNamed(Routes.loginPhone);
          },
        ));
  }

  ///关闭按钮
  Widget closeView() {
    return Positioned(
      top: MediaQuery.of(Get.context!).padding.top,
      child: GestureDetector(
        onTap: () {
          // 清除待执行的操作
          Get.find<UserController>().clearPendingAction();
          Get.back();
          FirebaseAnalytics.instance.logEvent(
            name: controller.source == 'new_user'
                ? 'OB_login_close'
                : 'login_close',
          );
          if(controller.isGuide!  && GlobalController.instance.pay.vipListLoginClose.isNotEmpty && !Get.find<UserController>().isVip) {
            FirebaseAnalytics.instance.logEvent(name: 'OB_login_pay');
            Get.toNamed(Routes.newUserPayPage, arguments: {'type': SinglePayType.loginClose});
          }
        },
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: 45.w,
          height: 45.w,
          alignment: Alignment.center,
          margin: EdgeInsets.only(left: 8.w),
          child: Image.asset(
            "assets/global/common/btn_close.png",
            width: 36,
            height: 36,
          ),
        ),
      ),
    );
  }

  ///游客购买
  Widget visitorPay() {
    return Positioned(
      top: MediaQuery.of(Get.context!).padding.top,
      right: 24.w,
      child: GestureDetector(
        onTap: () {
          // 清除待执行的操作
          controller.visitorForPayPage();
        },
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: 45.w,
          alignment: Alignment.centerRight,
          child: ByText.text(
            text: '不登录直接购买',
            textColor: ByColor.colorF1.withAlphaValue(0.5))
        ),
      ),
    );
  }
}
