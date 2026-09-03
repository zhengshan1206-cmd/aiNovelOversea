/*
 * @Author: cold-x
 * @Date: 2025-05-14 17:45:42
 * @LastEditors: cold-x 474647591@qq.com
 * @LastEditTime: 2025-08-07 18:03:07
 * @FilePath: /fastcreationmaster/lib/profile/aboutUs/pages/version_update_page.dart
 * @Description: 更新弹窗页面
 */


import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:novel_oversea/core/ui/view/progress_bar.dart';
import 'package:novel_oversea/core/ui/widget/by_button.dart';
import 'package:novel_oversea/core/ui/widget/by_text.dart';
import 'package:novel_oversea/core/util/extentions.dart';
import 'package:novel_oversea/me/aboutus/controller/about_us_controller.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../global/ui/colors.dart';


class CurrentVersionUpdatePage extends StatelessWidget {
  const CurrentVersionUpdatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 320.w,
        height: 261.w,
        child: Stack(
          children: [
            Positioned(
              top: 30.w,
              width: 320.w,
              height: 231.w,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  children: [
                    SizedBox(height: 60.w),
                    ByText.text(
                      text: "温馨提示",
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      textColor: ByColor.colorF1,
                    ),
                    SizedBox(height: 20.w),
                    ByText.text(
                      text: "您当前已是最新版本，无需更新",
                      fontSize: 14.sp,
                      textColor: ByColor.colorF1,
                    ),
                    SizedBox(height: 49.w),
                    SizedBox(
                      width: 270.w,
                      height: 48.w,
                      child: ByButton.textButton(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                          title: "确认",
                          titleColor: ByColor.colorC1,
                          fontSize: 16.sp,
                          onPressed: () {
                            Get.back();
                          }),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 125.w,
              child: SizedBox(
                width: 70.w,
                height: 70.w,
                child: Image.asset(
                  "assets/me/icon_upgrade_top_rocket.png",
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class VersionUpdatePage extends StatelessWidget {
  VersionUpdatePage({
    super.key,
  });
  final AboutUsController controller = Get.find<AboutUsController>();

  @override
  Widget build(BuildContext context) {
    bool isForceUpdate = controller.bean.value?.type == 3 ? true : false;
    return PopScope(
      canPop: false,
      child: Center(
          child: SizedBox(
            width: 300.w,
            height: 400.w,
            child: Stack(
              children: [
                Positioned(
                  top: 32.w,
                  left: 0.w,
                  right: 0.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        alignment: Alignment.topCenter,
                        image: AssetImage("assets/me/icon_upgrade_top_bg.png")),
                      color: Color(0xFF404044),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(70),
                        bottomLeft: Radius.circular(24),
                        bottomRight: Radius.circular(24),
                      )),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 28.w,),
                        Container(
                          alignment: Alignment.centerLeft,
                          child: ByText.text(
                            text: "发现新版本",
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w700,
                            textColor: ByColor.colorF1,
                          ),
                        ),
                        SizedBox(height: 6.w),
                        Container(
                          height: 22.w,
                          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.w),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [Color(0xFFE0D234), Color(0xFFEAE6B0),]),
                            borderRadius: BorderRadius.circular(11.w),
                          ),
                          child: ByText.text(
                            text: "V${controller.bean.value?.version}",
                            fontWeight: FontWeight.w700,
                            textColor: Colors.black,
                          ),
                        ),
                        SizedBox(height: 23.w),
                        ByText.text(
                            text: "更新内容",
                            fontSize: 16.sp,
                            textColor: ByColor.colorF1,
                            fontWeight: FontWeight.w700,
                          ),
                        SizedBox(height: 12.w),
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            // minHeight: 74.w,
                            maxHeight: 104.w,
                          ),
                          child: SingleChildScrollView(
                            child: Container(
                              alignment: Alignment.centerLeft,
                              child: ByText.text(
                                text: controller.bean.value?.content ?? '',
                                fontSize: 14.sp,
                                textColor: ByColor.colorF1.withAlphaValue(0.5),
                                maxLines: 999,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 30.w),
                        Obx(() => Row(
                          children: [
                          if(controller.isLoadingApk.value > 0)
                          Expanded(
                            child: SizedBox(
                              height: 44.w,
                              child: ProgressBar(
                                trackColor: ByColor.colorC1,
                                progressGradiantColor: const LinearGradient(colors: [ByColor.colorC1, Color(0xFFF3FFD2)]),
                                border: 12.w,
                                progress: controller.progress.value/100,
                                loadingText: '下载中...',)),
                          ),
                          if (!isForceUpdate && controller.isLoadingApk.value == 0)
                            Expanded(
                              child: SizedBox(
                                  height: 44.w,
                                  child: ByButton.textButton(
                                      padding: EdgeInsets.zero,
                                      title: '暂不更新',
                                      backgroundColor: ByColor.colorBg3,
                                      titleColor: ByColor.colorF1,
                                      onPressed: () {
                                        Get.back();
                                      })),
                            ),
                          if (!isForceUpdate && controller.isLoadingApk.value == 0)
                            SizedBox(
                              width: 8.w,
                            ),
                          if(controller.isLoadingApk.value == 0)
                          Expanded(
                            child: SizedBox(
                              height: 44.w,
                              child: ByButton.textButton(
                                  padding: EdgeInsets.zero,
                                  title: '立即更新',
                                  titleColor: Colors.black,
                                  onPressed: () {
                                    if(Platform.isAndroid) {
                                      controller.downLoadApp(controller.bean.value!.url, onSuccess: () {
                                      Get.back();
                                    },);
                                    }
                                    else if (Platform.isIOS) {
                                      // 跳转到 App Store（外部应用模式）
                                      launchUrl(
                                        Uri.parse('https://apps.apple.com/cn/app/ai小说创作精灵/id6747186147'),
                                        mode:
                                            LaunchMode.externalApplication,
                                      );
                                    }
                                  }),
                            ),
                          ),
                        ],
                        )),
                        SizedBox(height: 20.w,),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: Image.asset(
                      "assets/me/icon_upgrade_top_rocket.png",
                      fit: BoxFit.cover,
                      width: 162.w,
                    height: 155.w,
                    ),
                ),
              ],
            ),
          ),
        ),
    );
  }
}