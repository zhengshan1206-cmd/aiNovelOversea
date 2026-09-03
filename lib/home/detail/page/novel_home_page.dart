/*
 * @Author: cold-x
 * @Date: 2025-06-12 18:54:22
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2026-01-09 11:41:28
 * @FilePath: /novel_oversea/lib/home/detail/page/novel_home_page.dart
 * @Description: 小说首页页面
 */

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:novel_oversea/core/ui/page/base_page.dart';
import 'package:novel_oversea/core/ui/view/muti_status_view.dart';
import 'package:novel_oversea/core/ui/widget/by_button.dart';
import 'package:novel_oversea/core/ui/widget/by_text.dart';
import 'package:novel_oversea/home/detail/controller/novel_home_controller.dart';
import 'package:novel_oversea/home/detail/view/novel_home_view.dart';
import 'package:novel_oversea/home/detail/view/novel_manager_view.dart';
import 'package:novel_oversea/me/user/user.dart';
import '../../../core/util/by_screen_utils.dart';
import '../../../core/util/extentions.dart';
import '../../../global/ui/colors.dart';

// ignore: must_be_immutable
class NovelHomePage extends BasePage {
  NovelHomePage({
    super.key,
  });

  @override
  String get title => '';

  @override
  bool get hasAppBar => false;

  @override
  NovelHomeController get controller => Get.find<NovelHomeController>();

  final userController = Get.find<UserController>();

  ///非vip才显示文案提示
  Widget _hintTextView() {
    return Container(
      padding: EdgeInsets.only(left: 0.w, right: 0.w, top: 0.w, bottom: 12.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              ByText.text(
                text: "Your words is only enough for ",
                fontSize: 12,
                textColor: ByColor.colorF1.withAlphaValue(0.64),
              ),
              ByText.text(
                text: " 0.5 books",
                fontSize: 12,
                textColor: ByColor.colorG4,
              ),
            ],
          ),
          // GestureDetector(
          //   onTap: () {
          //     userController.checkPreLogin(
          //       source: 'novel_manage',
          //       actionCallback: () {
          //         userController.jumpToPayPage(source: 'novel_manage');
          //       },
          //     );
          //   },
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.end,
          //     children: [
          //       ByText.text(
          //         text: "recharge",
          //         fontSize: 12,
          //         textColor: Color(0XFF98FC4A),
          //       ),
          //       const SizedBox(
          //         width: 4,
          //       ),
          //       Image.asset(
          //         'assets/global/common/btn_info_black.png',
          //         width: 8,
          //         height: 8,
          //       ),
          //     ],
          //   ),
          // )
        ],
      ),
    );
  }

  @override
  Widget buildBody(BuildContext context) {
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            alignment: AlignmentGeometry.topCenter,
            image: AssetImage('assets/home/novel/icon_novel_home_bg.png'),
          ),
        ),
        child: Column(
          children: [
            SizedBox(
              height: ByScreenUtils.topSafeHeight + 44.w,
              child: Column(
                children: [
                  SizedBox(height: ByScreenUtils.topSafeHeight),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          Get.back();
                        },
                        child: Container(
                          width: 56,
                          height: 30,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.all(7.0),
                            child: Image.asset(
                              "assets/global/common/btn_back.png",
                              width: 16,
                              height: 16,
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        child: Container(
                          padding: EdgeInsets.all(12.w),
                          child: ByText.text(
                            bgColor: Colors.transparent,
                            textColor: ByColor.colorC1,
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                            text: 'Manage',
                          ),
                        ),
                        onTap: () {
                          controller.manager.updateNovelStatus();
                          ///管理
                          Get.bottomSheet(NovelManagerView());
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: Obx(
                () => MultiStatusView(
                  currentStatus: controller.statusType.value,
                  action: () {
                    controller.fetchLaunchData();
                  },
                  child: Column(
                    children: [
                      const Expanded(child: NovelHomeView()),
                      SizedBox(height: 10.w),
                      if (controller.novelBean.value?.pauseStatus == 3)
                        SizedBox(
                          height: 36.w,
                          child: Center(
                            child: ByText.text(
                              text: 'Paused after current generating chapter is finished',
                              fontSize: 12,
                              textColor: ByColor.colorG4,
                            ),
                          ),
                        ),
                      Obx(() {
                        return (controller.novelBean.value == null ||
                                controller.novelBean.value!.stage! == 10)
                            ? Container()
                            : Padding(
                                padding: EdgeInsets.only(
                                  left: 12.w,
                                  right: 12.w,
                                  top: 0,
                                  bottom: ByScreenUtils.bottomSafeHeight + 4.w,
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // 只在显示继续生成按钮且非会员时显示提示文案
                                    if (!controller.canContinueGenerateNovel()) _hintTextView(),
                                    Opacity(
                                      opacity:
                                          controller
                                                  .novelBean
                                                  .value
                                                  ?.pauseStatus ==
                                              3
                                          ? 0.3
                                          : 1.0,
                                      child: Stack(
                                        children: [
                                          SizedBox(
                                            width: double.infinity,
                                            child: ByButton.textButton(
                                              fontSize: 17.sp,
                                              titleColor: const Color(
                                                0xFF162408,
                                              ),
                                              title:
                                                  !controller
                                                      .canContinueGenerateNovel()
                                                  ? "Charge"
                                                  : 'Continue',
                                              fontWeight: FontWeight.w600,
                                              onPressed: () {
                                                userController.checkPreLogin(
                                                  source: 'novel_home',
                                                  actionCallback: () {
                                                    ///字数不够时
                                                    if (!controller
                                                        .canContinueGenerateNovel()) {
                                                      Get.find<UserController>()
                                                          .jumpToPayPage(
                                                            source:
                                                                'novel_home_words_unable',
                                                          );
                                                    } else {
                                                      ///暂停状态时
                                                      if (controller
                                                              .novelBean
                                                              .value!
                                                              .pauseStatus! ==
                                                          1) {
                                                        controller
                                                            .continuePausedNovel(
                                                              onSuccess: () {
                                                                controller
                                                                    .gotoPage();
                                                              },
                                                            );
                                                      } else {
                                                        controller.gotoPage();
                                                      }
                                                    }
                                                  },
                                                );
                                              },
                                            ),
                                          ),
                                          Positioned(
                                            right: 16.w,
                                            top: 16.w,
                                            bottom: 16.w,
                                            child: Image.asset(
                                              'assets/home/create/icon_home_create_continue.png',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                      }),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
