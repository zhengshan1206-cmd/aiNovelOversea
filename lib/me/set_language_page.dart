/*
 * @Author: cold-x
 * @Date: 2025-09-10 14:41:17
 * @LastEditors: cold-x 474647591@qq.com
 * @LastEditTime: 2025-09-16 16:48:19
 * @FilePath: /novel_oversea/lib/me/set_language_page.dart
 * @Description: 
 */


import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:novel_oversea/core/ui/dialog/toast.dart';
import 'package:novel_oversea/core/ui/page/base_page.dart';
import 'package:novel_oversea/core/ui/widget/by_text.dart';
import 'package:novel_oversea/global/ui/colors.dart';
import '../../core/service/app_translations.dart';

// ignore: must_be_immutable
class SetLanguagePage extends BasePage {
  SetLanguagePage({super.key});

  @override
  String get title => '设置语言';

  Map<String, Map<String, String>> languages = AppTranslations().keys;

  @override
  Widget buildBody(BuildContext context) {
    final keys = languages.keys.toList();
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.w),
      margin: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: ByColor.colorBg2,
        borderRadius: BorderRadius.circular(12.w),
      ),
      child: ListView.separated(
        itemCount: keys.length,
        shrinkWrap: true,
        clipBehavior: Clip.antiAlias,
        separatorBuilder: (context, index) {
          return Container(
            height: 0.5,
            decoration: BoxDecoration(
              color: ByColor.colorF1.withValues(alpha: 0.5),
            ),
          );
        },
        itemBuilder: (context, index) {
          final item = languages[keys[index]];
        return GestureDetector(
          onTap: () {
            final languageCode = keys[index].split('_')[0];
            final languageCountry = keys[index].split('_')[1];

            // 切换语言
            if (Get.locale != Locale(languageCode, languageCountry)) {
              Get.updateLocale(Locale(languageCode, languageCountry));
              Toast.showText(text: '已切换为${item['language_show']!.tr}');
              LanguageService.saveLanguage(keys[index]);
            }
          },
          child: SizedBox(
            height: 64.w,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ByText.text(
                  textColor: ByColor.colorF1,
                  fontSize: 15.sp,
                  text: item!['language']!.tr),
                // const SizedBox(height: 10,),
                ByText.text(
                  textColor: ByColor.colorF1,
                  fontSize: 16.sp,
                  text: item['language_show']!.tr),
              ],
            ),
          ),
        );
      }),
    );
  }

}