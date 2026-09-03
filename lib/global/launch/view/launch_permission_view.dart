import 'dart:io';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:novel_oversea/core/common/channel/by_channel_operate.dart';
import 'package:novel_oversea/core/ui/view/by_widgets_util.dart';
import 'package:novel_oversea/core/ui/widget/by_button.dart';
import 'package:novel_oversea/core/ui/widget/by_text.dart';
import 'package:novel_oversea/core/util/by_nav_router_utils.dart';
import 'package:novel_oversea/core/util/extentions.dart';
import 'package:novel_oversea/global/const/consts.dart';

import '../../ui/colors.dart';

class PermissionConfirmPage extends StatelessWidget {
  const PermissionConfirmPage({
    super.key,
    required this.onConfirm,
    this.title,
    this.content,
    this.confirmText,
    this.cancelText,
  });

  final String? title;
  final String? content;
  final String? confirmText;
  final String? cancelText;
  final void Function() onConfirm;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ByColor.colorBg2,
      body: Stack(
        children: [
          Container(),
          // Positioned.fill(
          //   child: Image.asset(
          //     "assets/global/launch/launch_bg.png",
          //     fit: BoxFit.cover,
          //   ),
          // ),
          Positioned.fill(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 27.w),
              color: ByColor.colorBg2,
              alignment: Alignment.center,
              child: SizedBox(
                width: double.infinity,
                child: ByWidgetsUtil.commonContainer(
                    bgColor: ByColor.colorF0,
                    padding: EdgeInsets.only(
                        left: 16.w, right: 16.w, top: 20.h, bottom: 10.h),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ByText.text(
                          text: title ?? "Welcome to use PENMAN PRO",
                          textColor: ByColor.colorF8,
                          fontWeight: FontWeight.bold,
                          fontSize: 16.sp,
                        ),
                        SizedBox(height: 15.h),
                        ByWidgetsUtil.commonRichText(
                          maxLines: 9999,
                          height: 1.3,
                          texts: [
                            TextSpan(
                              style: const TextStyle(
                                color: ByColor.colorF8,
                              ),
                              text: content ??
                                  "Thank you for trusting and using Penman Pro! \nWe will continue to adopt the technical measures and data security protection measures commonly used in the Internet industry to safeguard your privacy and personal information security. You can learn more details by reading the complete ",
                            ),
                            TextSpan(
                              text: " Terms of Service",
                              style: const TextStyle(
                                color: ByColor.colorC1,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  ByNavRouterUtils.jumpWebViewPage(
                                      context,
                                      "User Agreement",
                                      Consts.termsOfServiceUrl);
                                },
                            ),
                            const TextSpan(
                              style: TextStyle(
                                color: ByColor.colorF8,
                              ),
                              text: " and",
                            ),
                            TextSpan(
                              text: " Privacy Policy ",
                              style: const TextStyle(
                                color: ByColor.colorC1,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  ByNavRouterUtils.jumpWebViewPage(
                                      context,
                                      "Privacy Policy",
                                      Consts.privacyPolicyUrl);
                                },
                            ),
                            const TextSpan(
                              style: TextStyle(
                                color: ByColor.colorF8,
                              ),
                              text:
                                  "In the above agreement, we will explain to you how we provide services to you and protect your user rights, how we collect, use, store, share and protect your relevant information, as well as the ways we provide for you to access, modify and delete information related to you. To use this product, you need to be connected to a data network or WLAN network. Data charges may apply. For specific details, please consult your local operator. If you have fully read, understood and accepted the contents of the above two agreements, please click Agree to start accepting our services.",
                            ),
                          ],
                          fontSize: 13.sp,
                          fontWeight: FontWeight.normal,
                        ),
                        SizedBox(height: 20.h),
                        SizedBox(
                          height: 48.h,
                          width: double.infinity,
                          child: ByButton.textButton(
                                    title: confirmText ?? "Agree",
                                    fontSize: 17.sp,
                                    titleColor: ByColor.colorF0,
                                    backgroundColor: ByColor.colorF8,
                                    fontWeight: FontWeight.w600,
                                    onPressed: () async {
                                      FirebaseAnalytics.instance.logEvent(
                                        name: 'privacy_click_agree',
                                        parameters: {
                                          'page': 0
                                        }
                                      );
                                      onConfirm.call();
                                    },
                                  ),
                        ),
                        SizedBox(height: 4.h,),
                        SizedBox(
                          height: 40.h,
                          width: double.infinity,
                          child: ByButton.textButton(
                                    backgroundColor: Colors.transparent,
                                    title: cancelText ?? "Cancel",
                                    fontSize: 14.sp,
                                    titleColor: ByColor.colorF2,
                                    onPressed: () async {
                                      FirebaseAnalytics.instance.logEvent(
                                        name: 'privacy_click_cancel',
                                        parameters: {
                                          'page': 0
                                        }
                                      );
                                      Navigator.of(context).pop();
                                      showDialog(
                                        context: context,
                                        builder: (ctx) {
                                          return ExistConfirmPage(
                                            onConfirm: onConfirm,
                                          );
                                        },
                                      );
                                    },
                                  ),
                        ),
                      ],
                    )),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class ExistConfirmPage extends StatelessWidget {
  const ExistConfirmPage({
    super.key,
    required this.onConfirm,
    this.title,
    this.content,
    this.confirmText,
    this.cancelText,
  });

  final String? title;
  final String? content;
  final String? confirmText;
  final String? cancelText;
  final void Function() onConfirm;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(),
          // Positioned.fill(
          //   child: Image.asset(
          //     "assets/global/launch/launch_bg.png",
          //     fit: BoxFit.cover,
          //   ),
          // ),
          Positioned.fill(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 27.w),
              color: ByColor.colorBg2,
              alignment: Alignment.center,
              child: SizedBox(
                width: double.infinity,
                child: ByWidgetsUtil.commonContainer(
                    bgColor: ByColor.colorF0,
                    margin: EdgeInsets.symmetric(horizontal: 12.w),
                    padding: EdgeInsets.only(
                        left: 16.w, right: 16.w, top: 20.h, bottom: 20.h),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ByText.text(
                          text: title ?? "Comfirm Tips",
                          textColor: ByColor.colorF8,
                          fontWeight: FontWeight.bold,
                          fontSize: 16.sp,
                        ),
                        SizedBox(height: 15.h),
                        ByWidgetsUtil.commonRichText(
                          maxLines: 9999,
                          height: 1.8,
                          texts: [
                            TextSpan(
                              text: content ?? "Before using our services, please read and agree to the ",
                            ),
                            TextSpan(
                              text: "Terms of Service",
                              style: const TextStyle(
                                color: ByColor.colorC1,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  ByNavRouterUtils.jumpWebViewPage(context, "",
                                      Consts.termsOfServiceUrl);
                                },
                            ),
                            const TextSpan(
                              text: " and ",
                            ),
                            TextSpan(
                              text: "Privacy Policy",
                              style: const TextStyle(
                                color: ByColor.colorC1,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  ByNavRouterUtils.jumpWebViewPage(context, "",
                                      Consts.privacyPolicyUrl);
                                },
                            ),
                            const TextSpan(
                              text: ", or you will exit the app.",
                            ),
                          ],
                          fontSize: 13.sp,
                          textColor: ByColor.colorF7,
                          fontWeight: FontWeight.normal,
                        ),
                        SizedBox(height: 20.h),
                        SizedBox(
                          height: 44.h,
                          child: Row(
                            children: [
                              Expanded(
                                child: ByWidgetsUtil.commonBtn(
                                  padding: EdgeInsets.zero,
                                  borderRadius: 12.w,
                                  title: cancelText ?? "Exit",
                                  bgColor: ByColor.colorF2.withAlphaValue(0.5),
                                  fontWeight: FontWeight.normal,
                                  textColor: ByColor.colorF8,
                                  fontSize: 16.sp,
                                  onClick: () async {
                                    FirebaseAnalytics.instance.logEvent(
                                        name: 'privacy_click_cancel',
                                        parameters: {
                                          'page': 1
                                        }
                                      );
                                    if (Platform.isAndroid) {
                                      SystemNavigator.pop();
                                    } else {
                                      await ChannelOperate.exitApp();
                                    }
                                  },
                                ),
                              ),
                              SizedBox(width: 20.w),
                              Expanded(
                                child: ByWidgetsUtil.commonBtn(
                                  padding: EdgeInsets.zero,
                                  // borderColor: ByColor.colorC1,
                                  borderRadius: 12.w,
                                  title: confirmText ?? "Agree",
                                  fontSize: 16.sp,
                                  bgColor: ByColor.colorBg2,
                                  textColor: ByColor.colorF1,
                                  fontWeight: FontWeight.w500,
                                  onClick: () async {
                                    FirebaseAnalytics.instance.logEvent(
                                        name: 'privacy_click_agree',
                                        parameters: {
                                          'page': 1
                                        }
                                      );
                                    onConfirm.call();
                                  },
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    )),
              ),
            ),
          )
        ],
      ),
    );
  }
}
