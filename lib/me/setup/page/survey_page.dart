/*
 * @Author: duncy
 * @Date: 2026-01-15 18:35:19
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2026-01-16 14:15:34
 * @FilePath: /novel_oversea/lib/me/setup/page/survey_page.dart
 * @Description: 
 */



// ignore: must_be_immutable
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:novel_oversea/core/ui/dialog/toast.dart';
import 'package:novel_oversea/core/util/extentions.dart';

import '../../../core/ui/page/base_page.dart';
import '../../../core/ui/widget/by_text.dart';
import '../../../global/ui/colors.dart';
import '../../../home/core/view/bottom_view.dart';

// ignore: must_be_immutable
class SurveyPage extends BasePage{
  SurveyPage({super.key});

  @override
  String get title => 'Questionnaire Survey';

  @override
  Widget buildActions(BuildContext context) {
    return GestureDetector(
      onTap: () {
        /// 分享
      },
      child: Container(
        width: 56.w,
        height: 30.w,
        margin: EdgeInsets.only(right: 12.w),
        alignment: Alignment.centerRight,
        child: Image.asset(
          'assets/me/survey/survey_share.png',
          width: 16.w,
          height: 16.w,),
      ),
    );
  }

  @override
  Widget buildBody(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: ListView.separated(
              itemCount: 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              separatorBuilder: (context, index) {
                return SizedBox(height: 10.w);
              },
              itemBuilder: (context, index) {
                return Container(
                  height: 296.w,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Stack(
                    children: [
                      /// 问卷items
                      Positioned(
                        top: 45.w,
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 255.w,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(14.w),
                              bottomRight: Radius.circular(14.w),
                            ),
                            color: Color(0xFFECF9FF)
                          ),
                          child: Container(
                            margin: EdgeInsets.all(16.w),
                            alignment: Alignment.centerLeft,
                            child: ListView.separated(
                              itemCount: 5,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              separatorBuilder: (context, index) {
                                return SizedBox(height: 16.w);
                              },
                              itemBuilder: (context, index) {
                                return _buildItem(index);
                              },
                            ),
                          ),
                        ),
                      ),
            
                      /// 标题
                      Positioned(
                        top: 0,
                        height: 50.w,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 50.w,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              alignment: Alignment.topCenter,
                              fit: BoxFit.fill,
                              image: AssetImage(
                                'assets/me/survey/survey_category_bg_${index%3}.png',
                              ),
                            ),
                          ),
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 12.w),
                            alignment: Alignment.centerLeft,
                            child: ByText.text(
                                text: 'Activity List',
                                fontSize: 15.sp,
                                textAlign: TextAlign.left,
                                maxLines: 2,
                                fontWeight: FontWeight.bold,
                                textColor: ByColor.colorF8,
                              ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 10,),
        SizedBox(
              height: 58.w,
              child: BottomView(
                showWords: false,
                nextBtnText: 'Submit',
                nextStep: () {
                  Toast.showText(
                    text: 'sadadas', 
                    type: ToastType.success,
                    align: Alignment.topCenter,
                    clickText: 'View more',
                    action: () {
                      print('____AAAAAA');
                    });
                },
              ),
            )
      ],
    );
  }

  /// 选项item
  Widget _buildItem(int index) {
    return SizedBox(
      height: 24.w,
      child: Row(
        children: [
          Container(
            width: 24.w,
            height: 24.w,
            alignment: Alignment.center,
            child: Image.asset(
              'assets/me/survey/survey_item_selected.png',
              width: 16.w,
              height: 16.w,
            ),
          ),
          SizedBox(width: 6.w),
          ByText.text(
            text: 'Activity List',
            fontSize: 15.sp,
            maxLines: 2,
            textColor: ByColor.colorF8.withAlphaValue(0.7),
          ),
        ],
      ),
    );
  }

}