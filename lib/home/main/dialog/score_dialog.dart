/*
 * @Author: duncy
 * @Date: 2025-12-23 15:41:39
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2025-12-25 15:17:54
 * @FilePath: /novel_oversea/lib/home/main/dialog/score_dialog.dart
 * @Description: 
 */



import 'dart:io';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:novel_oversea/core/ui/widget/by_text.dart';
import 'package:novel_oversea/global/const/const_string.dart';
import 'package:novel_oversea/global/ui/colors.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/cache/byhy_aes_storage_utils.dart';
import '../../../core/cache/daily_cache_manager.dart';
import '../../../global/const/consts.dart';
import '../../../global/launch/controller/launch_manager.dart';


class ScoreDialogManager {
  ///type: 0 首页自动弹出  1 设置页用户手动点击
  static void showScore({int type = 0}) {
    FirebaseAnalytics.instance.logEvent(
      name: 'rate_us_show',
      parameters: {'page': type},
    );
    DailyManager.recordPopupDate(ConstString.kScoreHomeDialog);
    showDialog(
      context: Get.context!,
      builder: (context) {
        return ScoreDialog(
          starAction: (index) {
            ///三星以上跳转至商店
            if (index > 2) {
              ByStorageUtils.saveBool(ConstString.kUserScoreInStore, true);
              launchUrl(
                Uri.parse(Platform.isAndroid ? Consts.playStoreUrl : Consts.appStoreUrl),
                mode: LaunchMode.externalApplication,
              );
            }
            ///跳转至feedback
            else {
              GlobalController.instance.config.goPrivacyPageWithTitle('Feedback');
            }
          },
        );
      }
    );
  }
}

class ScoreDialog extends StatefulWidget {
  const ScoreDialog({super.key, this.starAction});
  final Function(int)? starAction; ///选中星级

  @override
  State<ScoreDialog>  createState() => _ScoreDialogState();
}

class _ScoreDialogState extends State<ScoreDialog> {


  int _selectIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 300.w,
              padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 12.w),
              decoration: BoxDecoration(
                color: ByColor.colorF0,
                borderRadius: BorderRadius.circular(Platform.isAndroid ? 4 : 12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 8,),
                  ByText.text(
                    text: 'Loving Penman Pro',
                    fontSize: 17.sp,
                    fontWeight: FontWeight.bold,
                    textColor: ByColor.colorF8),
                  const SizedBox(height: 10,),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 8.w),
                    child: ByText.text(
                      text: 'We’re a small team working hard to make Penman Pro better for you. If you enjoy using it, would you mind leaving us a review?',
                      maxLines: 10,
                      textAlign: TextAlign.center,
                      textColor: ByColor.colorF8),
                  ),
                  const SizedBox(height: 36,),
                  Container(
                    height: 32.w,
                    padding: EdgeInsets.symmetric(horizontal: 38.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(5, (int index) {
                        return GestureDetector(
                          onTap: () {
                            FirebaseAnalytics.instance.logEvent(
                              name: 'rate_us_show_click',
                              parameters: {'score': index + 1},
                            );
                            setState(() {
                              _selectIndex = index;
                            });
                            Get.back();
                            widget.starAction?.call(index);
                          },
                          child: Image.asset('assets/home/main/score_star_${index <= _selectIndex ? "selected" : "unselected"}.png'));
                      }),
                    ),
                  ),
                  const SizedBox(height: 32,),
                ],
              ),
            ),
            const SizedBox(height: 24,),
            IconButton(
              onPressed: () => Get.back(), 
              icon: Image.asset(
                'assets/home/main/score_close.png',
                width: 32,
                height: 32,))
          ],
        ),
      ),
    );
  }
}