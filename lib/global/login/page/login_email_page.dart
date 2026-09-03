/*
 * @Author: cold-x
 * @Date: 2025-05-30 14:29:21
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2025-11-11 16:59:10
 * @FilePath: /novel_oversea/lib/global/login/page/login_email_page.dart
 * @Description: 登录页面
 */

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:novel_oversea/core/ui/page/base_page.dart';
import 'package:novel_oversea/core/ui/widget/by_text.dart';
import 'package:novel_oversea/core/util/extentions.dart';
import 'package:novel_oversea/global/login/binbing/login_binding.dart';
import 'package:novel_oversea/global/login/controller/firebase_auth.dart';
import 'package:novel_oversea/global/login/controller/login_controller.dart';
import 'package:novel_oversea/global/ui/colors.dart';
import 'package:novel_oversea/me/user/user.dart';
import '../view/login_textfield.dart';

///登录页面
// ignore: must_be_immutable
class LoginEmailPage extends BasePage {
  LoginEmailPage({
    super.key,
    this.type,
  });
  LoginType? type;

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

  ///输入的邮箱
  String sendEmail = '';

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
          'assets/home/create/icon_create_bg.png',
          fit: BoxFit.fill,
        ),
        Positioned(
          child: Padding(
          padding: EdgeInsets.all(24.w),
          child:
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SizedBox(
              height: 108.h,
            ),
            
            ByText.text(
              text: 'Sign in with Email',
              fontSize: 32.sp,
              fontWeight: FontWeight.bold
            ),
            SizedBox(
              height: 10.h,
            ),
            ByText.text(
              text: 'Enter your email to sign in',
              fontSize: 17.sp,
              textColor: ByColor.colorF2
            ),
            SizedBox(
              height: 24.h,
            ),
            _buildEmailView(context),
          ]),
        )),
        closeView(),
      ],
    );
  }

  ///邮箱输入
  Widget _buildEmailView(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 10.h),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.w),
          ),
          child: Stack(
            children: [
              Positioned(
                child: LoginTextField(
                  hintText: "Enter the email",
                  maxLength: 999,
                  focusNode: controller.codeNode,
                  inputCallBack: (value) {
                    sendEmail = value;
                    controller.checkEmailEnable(value);
                  },
                ),
              ),
              SizedBox(
                width: 10.w,
              ),
              // Positioned(
              //   right: 4,
              //   top: 4,
              //   bottom: 4,
              //   child: SizedBox(
              //     width: 94.w,
              //     child: const CountDownBtn(
              //       fontSize: 14,
              //       textColor: ByColor.colorC1,
              //       resendAfterText: "重新发送",
              //       showBorder: true,
              //       // getVCode: controller.getVCode,
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
        SizedBox(height: 5.h),
        Obx(() => Offstage(
                  offstage: controller.emailValid.value,
                  child: Row(
                    children: [
                      SizedBox(width: 5.w),
                      ByText.text(
                        text: "Incorrect email",
                        fontSize: 12.sp,
                        textColor: ByColor.colorG4,
                      ),
                    ],
                  ),
                )),
        SizedBox(height: 20.h),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            FocusScope.of(context).unfocus();
            ///测试账号
            if(controller.isCheckAccount(sendEmail)) {
              controller.loginWithVCode(
                context,
                phone: sendEmail,
                code: '1234');
              return;
            }
            // final String sendEmail = 'ziyuzile0825@gmail.com';
            if(controller.emailValid.value && !controller.isLogin.value) {
              controller.isLogin.value = true;
              LoginUtil.signInWithEmail(sendEmail, onSuccess: (){
                controller.isLogin.value = false;
              });
            }
          },
          child: Obx(() => Container(
                height: 48.h,
                width: double.infinity,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: controller.emailValid.value
                      ? ByColor.colorC1
                      : ByColor.colorC1.withAlphaValue(0.3),
                  borderRadius: BorderRadius.circular(12.w),
                ),
                child: Obx(
                  () => !controller.isLogin.value
                      ? ByText.text(
                          text: controller.isCheckAccount(sendEmail) ? "Sign In" : "Send Email",
                          textColor: ByColor.colorF8,
                          fontSize: 17.sp,
                          fontWeight: FontWeight.w600,
                        )
                      : CupertinoActivityIndicator(
                          color: Colors.black,
                          radius: 10.w,
                        ),
                ),
              )),
        ),
      ],
    );
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
        },
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: 50.w,
          height: 45.w,
          alignment: Alignment.center,
          child: Image.asset(
            "assets/global/common/btn_back.png",
            width: 20,
            height: 20,
          ),
        ),
      ),
    );
  }
}
