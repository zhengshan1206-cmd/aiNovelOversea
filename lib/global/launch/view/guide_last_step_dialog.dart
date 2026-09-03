/*
 * @Author: duncy
 * @Date: 2026-01-05 15:32:40
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2026-01-09 17:25:47
 * @FilePath: /novel_oversea/lib/global/launch/view/guide_last_step_dialog.dart
 * @Description: 
 */


import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:novel_oversea/core/ui/widget/by_text.dart';
import 'package:novel_oversea/global/launch/controller/launch_manager.dart';
import 'package:novel_oversea/global/launch/view/guide_last_step_view.dart';
import 'package:novel_oversea/global/pay/bean/vip_type_bean.dart';
import 'package:novel_oversea/global/ui/colors.dart';

import '../../../core/pay/pay_manager.dart';
import '../../routes/app_pages.dart';

class GuideLastStepDialog extends StatefulWidget {
  const GuideLastStepDialog({super.key});

  @override
  State<GuideLastStepDialog> createState() => _GuideLastStepDialogState();
}

class _GuideLastStepDialogState extends State<GuideLastStepDialog> {

  late final SinglePayManager pay;

  @override
  void initState() {
    FirebaseAnalytics.instance.logEvent(name: 'OB_end_pay_intercept');
    VipTypeBean bean = GlobalController.instance.pay.vipListGuideDialog.first;
    pay = SinglePayManager(bean, PayManager(), sourcePosition: 7);
    pay.init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Stack(
            children: [
              Container(
                height: 433.w,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Color(0xFFECF9FF),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Column(
                  children: [
                    SizedBox(height: 74.w),
                    Image.asset(
                      'assets/global/launch/icon_guide_step_retain_tips.png',
                      width: 159.w,
                      height: 29.w,
                    ),
                    SizedBox(height: 17.w),
                    Image.asset(
                      'assets/global/launch/icon_guide_step_retain_trial.png',
                      width: 171.w,
                      height: 24.w,
                    ),
                    SizedBox(height: 16.w),
                    Container(
                      height: 102.w,
                      padding: EdgeInsets.all(18.w),
                      margin: EdgeInsets.symmetric(horizontal: 24.w),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.w),
                        color: Color(0xFFB6DBFF),
                      ),
                      child: Center(
                        child: ByText.text(
                          text:
                              'Today only, enjoy all premium benefits free for first 3 days ${pay.getPrice(isDiscount: true)}, then ${pay.getPrice()}/year.',
                          fontSize: 16.sp,
                          maxLines: 3,
                          textColor: ByColor.colorF8,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const Spacer(),
                    GuidePayBottomView(
                      pravacyStyle: 1, 
                      nextBtnText: pay.getButtonText(),
                      nextStep: () {
                        FirebaseAnalytics.instance.logEvent(name: 'OB_end_pay_intercept_pay');
                        pay.startPay();
                    },),
                  ],
                ),
              ),
              Transform.translate(
                offset: Offset(0, -100.w),
                child: SizedBox(
                  child: Center(
                    child: Image.asset(
                      'assets/global/launch/icon_guide_step_retain_gift.png',
                      width: 201.w,
                      height: 159.w,
                    ),
                  ),
                ),
              ),

              Positioned(
                right: 12,
                top: 12,
                child: GestureDetector(
                  onTap: () {
                    GlobalController.instance.isFirstIn = true;
                    Get.offAllNamed(Routes.main);
                    FirebaseAnalytics.instance.logEvent(name: 'OB_end_pay_intercept_close');
                  },
                  child: Opacity(
                    opacity: 0.6,
                    child: SizedBox(
                      width: 32.w,
                      height: 32.w,
                      child: Image.asset(
                        'assets/global/common/btn_close_black_transparent.png',
                        width: 16.w,
                        height: 16.w,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    pay.dispose();
    super.dispose();
  }
}