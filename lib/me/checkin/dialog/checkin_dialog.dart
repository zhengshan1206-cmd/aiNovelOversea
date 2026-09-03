/*
 * @Author: duncy
 * @Date: 2026-01-16 17:13:44
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2026-02-05 17:30:59
 * @FilePath: /novel_oversea/lib/me/checkin/dialog/checkin_dialog.dart
 * @Description: 
 */

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:novel_oversea/core/service/words.dart';
import 'package:novel_oversea/core/ui/view/by_widgets_util.dart';
import 'package:novel_oversea/core/ui/widget/by_text.dart';
import 'package:novel_oversea/core/util/extentions.dart';
import 'package:novel_oversea/global/ui/colors.dart';

enum CheckinMissionType {
  /// 签到
  checkin,
  /// 小说完成
  novelComplete,
}

class CheckinDialogManager {
  static void showCheckinDialog(CheckinMissionType type, int rewards) {
    showDialog(
      context: Get.context!,
      builder: (context) {
        return CheckinDialog(type: type, rewards: rewards,);
      },
    );
  }
}

class CheckinDialog extends StatelessWidget {
  const CheckinDialog({super.key, required this.type, required this.rewards});

  final int rewards;
  final CheckinMissionType type;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Center(
          child: Container(
            height: 494.w,
            width: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/tutorial/checkin/check_toast_bg.png'))
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ByText.text(
                      text: type == CheckinMissionType.checkin ? 'Check In Success' : 'Congratulations !',
                      fontSize: 28.sp,
                      fontStyle: FontStyle.italic,
                      textColor: ByColor.colorF0,
                      fontWeight: FontWeight.bold),
                SizedBox(height: 16.w,),
                Container(
                  height: 48.w,
                  width: 200.w,
                  alignment: Alignment.center,
                  child: ByWidgetsUtil.commonRichText(
                    maxLines: 3,
                    textAlign: TextAlign.center,
                    height: 1.4,
                    texts: [
                      TextSpan(
                        text: 'Congratulations! You’ve received',
                      ),
                      TextSpan(
                        text: ' ${WordsService.wordsDisplay(rewards.toString())} Credits',
                        style: TextStyle(
                          color: ByColor.colorG3,
                          fontWeight: FontWeight.w600
                        )
                      )
                    ],
                    textColor: ByColor.colorF0.withAlphaValue(0.45),
                    fontSize: 16.sp)),
                SizedBox(height: 20.w,),
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(
                    width: 170.w,
                    height: 48.w,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24.w),
                      gradient: LinearGradient(colors: [Color(0xFFFFB660), Color(0xFFFFDA89)]),
                    ),
                    child: ByText.text(
                      text: 'Get',
                      fontSize: 20.sp,
                      textColor: ByColor.colorF8,
                      fontWeight: FontWeight.w500)),
                ),
                SizedBox(height: 56.w,),
                GestureDetector(
                  onTap: () {
                    Get.back();
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
                SizedBox(height: 81.w,),
              ],
            ),
          ),
        ),
      ),
    );
  }
}