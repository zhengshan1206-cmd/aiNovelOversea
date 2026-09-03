/*
 * @Author: duncy
 * @Date: 2025-10-14 17:42:39
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2025-11-20 16:08:18
 * @FilePath: /novel_oversea/lib/global/launch/page/guide_page.dart
 * @Description: 
 */


import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:novel_oversea/core/ui/widget/by_text.dart';
import 'package:novel_oversea/core/util/by_screen_utils.dart';
import 'package:novel_oversea/global/launch/controller/launch_manager.dart';
import 'package:novel_oversea/global/launch/page/guide_step_page.dart';
import 'package:novel_oversea/global/ui/colors.dart';
import 'package:novel_oversea/home/core/view/bottom_view.dart';

class GuidePage extends StatefulWidget {
  const GuidePage({super.key});

  @override
  State<GuidePage> createState() => _GuidePageState();
}

class _GuidePageState extends State<GuidePage> {

  bool switchValue = true;

  final guideTips = const [
    "Improve work efficiency by more than 30%",
    "No watermark, more professional",
    "Save paper, always protect the environment",
    "No ads, more comfortable experience",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ByColor.colorBg1,
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/pay/icon_pay_vip_bg.png'),
          fit: BoxFit.cover,
        ),
      ),
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ByText.text(
                  text: "Our Advantages", 
                  fontSize: 20.sp, 
                  textColor: ByColor.colorF1, 
                  fontWeight: FontWeight.w600,),
          SizedBox(height: 16.h),
          for (var tip in guideTips) 
            Container(
              margin: EdgeInsets.only(bottom: 4.h),
              child: Row(
                children: [
                  Image.asset(
                    'assets/pay/icon_pay_crown.png',
                    width: 16.w,
                    height: 16.w,
                  ),
                  const SizedBox(width: 8),
                  ByText.text(text: tip, textColor: ByColor.colorF2),
                ],
              ),
            ),
          SizedBox(height: 40.h),

          Container(
            height: 60.w,
            margin: EdgeInsets.symmetric(vertical: 12.w),
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            decoration: const BoxDecoration(
              color: ByColor.colorBg2,
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ByText.text(
                  text: "Free Trial", 
                  fontSize: 17.sp, 
                  textColor: ByColor.colorF1, 
                  fontWeight: FontWeight.bold,),
                Switch(
                  value: switchValue, 
                  inactiveThumbColor: ByColor.colorF1,
                  inactiveTrackColor: ByColor.color2E3038,
                  activeThumbColor: ByColor.colorF1,
                  activeTrackColor: ByColor.colorC1,
                  onChanged: (value) {
                    setState(() {
                      switchValue = value;
                    });
                  }),
              ],
            )
          ),

          BottomView(
            padding: 0,
            showWords: false,
            nextBtnText: 'CONTINUE',
            nextStep: () {
              Get.to(() => GuideStepPage());
            },
          ),
          SizedBox(height: 10.w),
          SizedBox(
            height: 20.w,
            // child: Row(
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   children: [
            //     Image.asset(
            //       'assets/pay/icon_pay_tips.png',
            //       width: 16.w,
            //       height: 16.w,
            //     ),
            //     const SizedBox(width: 8),
            //     ByText.text(
            //       text: "NO PAYMENT NOW",
            //       fontSize: 13.sp,
            //       textColor: ByColor.colorF1,
            //     ),
            //   ],
            // ),
          ),
          SizedBox(height: 10.w),
          AgreementView(),
          SizedBox(height: 10.w + ByScreenUtils.bottomSafeHeight,),
        ],
      ),
    );
  }
  }

  class AgreementView extends StatelessWidget {
    const AgreementView({super.key});
  
    @override
    Widget build(BuildContext context) {
      return _buildAgreement();
    }

    /// 协议
  Widget _buildAgreement() {
    return Container(
      height: 20.w,
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              child: Wrap(
                alignment: WrapAlignment.center,
                children: [
                  RichText(
                    maxLines: 2,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: "Pravacy Policy",
                          style: const TextStyle(
                            fontSize: 12,
                            color: ByColor.colorF1,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              GlobalController.instance.config
                                  .goPrivacyPageWithTitle("Privacy Policy");
                            },
                        ),
                        const TextSpan(
                          text: ',',
                          style: TextStyle(
                            fontSize: 12,
                            color: ByColor.colorF2,
                          ),
                        ),
                        TextSpan(
                          text: "Terms of Service",
                          style: const TextStyle(
                            fontSize: 12,
                            color: ByColor.colorF1,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              GlobalController.instance.config
                                  .goPrivacyPageWithTitle("User Agreement");
                            },
                        ),
                        const TextSpan(
                          text: ' & ',
                          style: TextStyle(
                            fontSize: 12,
                            color: ByColor.colorF2,
                          ),
                        ),
                        TextSpan(
                          text: " Subscription Terms",
                          style: const TextStyle(
                            color: ByColor.colorF1,
                            fontSize: 12,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              GlobalController.instance.config
                                  .goPrivacyPageWithTitle("Member Service Agreement");
                            },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}