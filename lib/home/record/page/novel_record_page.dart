/*
 * @Author: cold-x
 * @Date: 2025-06-26 11:05:30
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2025-11-01 00:49:40
 * @FilePath: /novel_oversea/lib/home/record/page/novel_record_page.dart
 * @Description: 
 */

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:novel_oversea/core/ui/dialog/toast.dart';
import 'package:novel_oversea/core/ui/view/by_widgets_util.dart';
import 'package:novel_oversea/core/ui/view/muti_status_view.dart';
import 'package:novel_oversea/core/ui/view/progress_bar.dart';
import 'package:novel_oversea/core/ui/widget/by_button.dart';
import 'package:novel_oversea/core/ui/widget/by_refresh.dart';
import 'package:novel_oversea/core/ui/widget/by_text.dart';
import 'package:novel_oversea/core/util/extentions.dart';
import 'package:novel_oversea/global/ui/colors.dart';
import 'package:novel_oversea/home/brief/bean/novel_bean.dart';
import 'package:novel_oversea/home/detail/view/novel_home_view.dart';
import 'package:novel_oversea/home/record/controller/novel_record_controller.dart';
import 'package:novel_oversea/home/record/page/base_record_page.dart';
import '../../../core/util/by_screen_utils.dart';

///长文、短篇小说记录页； 短故事和其他小说工具类记录在BaseRecordPage页中
// ignore: must_be_immutable
class NovelRecordPage extends BaseRecordPage {
  NovelRecordPage({
    super.key,
  });

  @override
  NovelRecordController get controller => Get.find<NovelRecordController>();

  @override
  Widget buildActions(BuildContext context) {
    return Obx(() {
      return controller.novelList.isNotEmpty
          ? super.buildActions(context)
          : Container();
    });
  }

  @override
  Widget buildBody(BuildContext context) {
    return Column(
      children: [
        Expanded(child: buildContentView(0)),
      ],
    );
  }

  ///记录页内容
  Widget buildContentView(int index) {
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              left: 12.w,
              right: 12.w,
              bottom: 12.w,
              top: 12.w,
            ),
            child: Obx(
              () => MultiStatusView(
                emptyActionType: EmptyActionType.all,
                emptyText: 'No Records',
                emptyActionText: 'Go Creation',
                currentStatus: controller.statusType.value,
                emptyAction: () {
                  // NavigateUtils.navigateToPageAfterBacktoMain(
                  //     Routes.novelCreate, {
                  //   'novel_type': controller.type,
                  // });
                },
                action: () {
                  controller.fetchNovelRecordList(true);
                },
                child: ByRefresh.refresh(
                  controller: controller.refreshManager.refreshController,
                  onRefresh: () {
                    controller.fetchNovelRecordList(true);
                  },
                  onLoad: () {
                    controller.fetchNovelRecordList(false);
                  },
                  child: GridView.builder(
                    padding: EdgeInsets.zero,
                    clipBehavior: Clip.none,
                    // shrinkWrap: true,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 11.w,
                      crossAxisSpacing: 11.w,
                      childAspectRatio: 230 / 375, // 宽高比
                    ),
                    itemCount: controller.novelList.length,
                    itemBuilder: (context, index) {
                      NovelBean bean = controller.novelList[index];
                      return GestureDetector(
                        onTap: () {
                          if (controller.isManaging.value) {
                            if (bean.pauseStatus == 1 || bean.stage == 10) {
                              controller.updateDeleteRecordIds(bean.id!);
                            } else {
                              Toast.showText(text: 'Delete after book finished or stopped');
                            }
                          } else {
                            controller.gotoPage(
                              bean,
                              goNovelHome: true,
                              stage: bean.stage,
                            );
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadiusDirectional.circular(
                              10.w,
                            ),
                            // color: const Color(0xFF1E1F24),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadiusDirectional.circular(
                              10.w,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: 209.w,
                                  child: Stack(
                                    children: [
                                      ///状态设置
                                      Positioned.fill(
                                        child: _setNovelStatus(bean),
                                      ),

                                      Obx(
                                        () => Positioned.fill(
                                          child: Offstage(
                                            offstage:
                                                !(controller.isManaging.value &&
                                                    (bean.pauseStatus == 1 ||
                                                        bean.stage == 10) &&
                                                    controller.deleteRecordIds
                                                        .contains(bean.id)),
                                            child: Container(
                                              color: ByColor.colorF8
                                                  .withAlphaValue(0.64),
                                            ),
                                          ),
                                        ),
                                      ),

                                      ///生成失败、完成、断更的标签
                                      if ([3, 6, 9, 10].contains(bean.stage) ||
                                          bean.pauseStatus != 2 ||
                                          bean.chapterStage == 4 ||
                                          bean.contentStage == 4)
                                        Positioned(
                                          left: 0,
                                          top: 0,
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 8.w,
                                              vertical: 6.w,
                                            ),
                                            decoration: BoxDecoration(
                                              color: bean.stage == 10
                                                  ? ByColor.colorC1
                                                  : ByColor.colorG4,
                                              borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(10.w),
                                                bottomRight: Radius.circular(
                                                  10.w,
                                                ),
                                              ),
                                            ),
                                            child: ByText.text(
                                              text: controller.setStatusTag(
                                                bean,
                                              ),
                                              textColor: bean.stage == 10
                                                  ? Colors.black
                                                  : ByColor.colorF1,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),

                                      Obx(
                                        () => Positioned(
                                          right: 8.w,
                                          top: 8.w,
                                          child: Offstage(
                                            offstage:
                                                !(controller.isManaging.value &&
                                                    (bean.pauseStatus == 1 ||
                                                        bean.stage == 10)),

                                            ///管理选择和未选中的按钮
                                            child: GestureDetector(
                                              onTap: () {
                                                controller
                                                    .updateDeleteRecordIds(
                                                      bean.id!,
                                                    );
                                              },
                                              child: SizedBox(
                                                width: 20.w,
                                                height: 20.w,
                                                child: Image.asset(
                                                  controller.deleteRecordIds
                                                          .contains(bean.id)
                                                      ? 'assets/global/common/btn_record_selected.png'
                                                      : 'assets/global/common/btn_record.png',
                                                  width: 20.w,
                                                  height: 20.w,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 12.w),

                                ///标题
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12.w,
                                  ),
                                  child: ByText.text(
                                    text: bean.title ?? '',
                                    textColor: ByColor.colorF1,
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(height: 8.w),

                                ///简介
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12.w,
                                  ),
                                  child: ByText.text(
                                    // maxLines: 2,
                                    text: bean.introduce ?? '',
                                    textColor: ByColor.colorF2,
                                    fontSize: 12,
                                  ),
                                ),
                                SizedBox(height: 12.w),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
        Obx(
          () => Offstage(
            offstage: !controller.isManaging.value,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: Container(
                height: 56.w + ByScreenUtils.bottomSafeHeight,
                padding: EdgeInsets.only(
                  top: 4.w,
                  bottom: ByScreenUtils.bottomSafeHeight + 4.w,
                ),
                child: SizedBox(
                  height: 48.w,
                  width: double.infinity,
                  child: ByButton.textButton(
                    titleColor: ByColor.colorG4,
                    backgroundColor: ByColor.color2E3038,
                    title: 'Delete',
                    onPressed: () {
                      controller.deleteRecordAction();
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  ///设置状态
  Widget _setNovelStatus(NovelBean bean) {
    ///小说暂停状态 并且未完成时
    if (bean.pauseStatus != 2 && bean.stage! != 10) {
      return NovelCoverView(
        cover: bean.cover,
        title: bean.title,
      );
    }
    switch (bean.stage) {
      ///已提交
      case 1:

      ///灵感生成中
      case 2:

      ///5=大纲生成中
      case 5:
        return _buildGeneratingView(bean.stage == 5 ? 'outline' : 'inspiration');

      ///灵感生成完成
      case 4:

      ///大纲生成成功
      case 7:
        return _buildCompeleView(bean);

      ///灵感生成失败
      case 3:

      ///大纲生成失败
      case 6:
        return _buildFailedView(bean);

      ///正文生成中【包含细纲生成，正文生成】
      case 8:

        ///优先级：失败的优先展示
        ///正文生成有失败时
        if (bean.contentStage == 4) {
          return _buildFailedView(bean);
        }

        ///细纲生成有失败时
        if (bean.chapterStage == 4) {
          return _buildFailedView(bean);
        }

        ///有正文时
        if (bean.contentStage! > 1 ||
            (bean.contentStage == 1 && bean.chapterStage == 1)) {
          double progress = bean.generateChapters! / bean.chaptersNum!;
          return _buildStatusBgView(children: [
            ByWidgetsUtil.commonRichText(
                textColor: ByColor.colorC1,
                texts: [
                  TextSpan(
                      text: '${(progress * 100).floor()}',
                      style: const TextStyle(fontSize: 24)),
                  const TextSpan(text: '%'),
                ]),
            SizedBox(
              height: 4.w,
            ),
            SizedBox(
                width: 123.w,
                height: 4.w,
                child: ProgressBar(
                  trackColor: ByColor.colorL1,
                  progressGradiantColor: const LinearGradient(colors: [
                    ByColor.colorC1,
                    Color(0xFF0BBA92),
                    Color(0xFF0181FC)
                  ]),
                  progress: progress,
                )),
            SizedBox(
              height: 8.w,
            ),
            ByText.text(
                textColor: ByColor.colorF1, text: 'Generating Book'),
          ]);
        }

        ///没有正文并且细纲在生成中
        if (bean.contentStage == 1 && bean.chapterStage == 2) {
          return _buildGeneratingView('chapter');
        }

        ///没有正文并且没有正在生成的细纲
        if (bean.contentStage == 1 && [3, 5].contains(bean.chapterStage)) {
          return _buildCompeleView(bean);
        }
        return Container();

      ///暂停中
      case 9:

      ///生成完成
      case 10:

        ///封面图
        return NovelCoverView(
          cover: bean.cover,
          title: bean.title,
        );
      case 11:
      default:
        return Container();
    }
  }

  ///生成中
  Widget _buildGeneratingView(String title) {
    return _buildStatusBgView(children: [
      CupertinoActivityIndicator(
        color: ByColor.colorC1,
        radius: 15.w,
      ),
      SizedBox(
        height: 20.0.w,
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: ByText.text(
          textAlign: TextAlign.center,
            maxLines: 3,
            text: '$title is generating, please wait...', textColor: ByColor.colorC1),
      ),
    ]);
  }

  ///生成失败
  Widget _buildFailedView(NovelBean bean) {
    return _buildStatusBgView(children: [
      SizedBox(
        height: 30.w,
      ),
      Image.asset(
        'assets/home/novel/icon_novel_record_failed.png',
        width: 80.w,
        height: 80.w,
      ),
      SizedBox(
        height: 8.w,
      ),
      ByText.text(textColor: ByColor.colorF2, text: 'Inspiration Failed'),
      const Spacer(),
      GestureDetector(
        onTap: () {
          controller.gotoPage(bean, goNovelHome: bean.stage! >= 8);
        },
        child: Container(
          width: 100.w,
          height: 36.w,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18.w),
              color: ByColor.colorC1),
          child: Center(
            child: ByText.text(
                fontWeight: FontWeight.w500,
                textColor: Colors.black,
                text: 'Retry'),
          ),
        ),
      ),
      SizedBox(
        height: 20.w,
      ),
    ]);
  }

  ///阶段生成完成
  Widget _buildCompeleView(NovelBean bean) {
    final String title = bean.stage == 4
        ? 'Inspiration Finished'
        : bean.stage == 7
            ? 'Outline Finished'
            : 'Final Step For Novel Text';
    final String next = bean.stage == 4
        ? 'Continue Outline'
        : bean.stage == 7
            ? 'Continue Chapter'
            : 'Continue Novel';
    return _buildStatusBgView(children: [
      SizedBox(
        height: 50.w,
      ),
      Image.asset(
        'assets/home/main/icon_novel_record_finish.png',
        width: 40.w,
        height: 40.w,
      ),
      SizedBox(
        height: 8.w,
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: ByText.text(
            textColor: ByColor.colorF1,
            text: title,
            textAlign: TextAlign.center,
            maxLines: 2),
      ),
      const Spacer(),
      GestureDetector(
        onTap: () {
          controller.gotoPage(bean);
        },
        child: Container(
          // width: 100.w,
          height: 36.w,
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18.w),
              color: ByColor.colorC1),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              ByText.text(
                  fontWeight: FontWeight.w500,
                  textColor: Colors.black,
                  text: next),
              SizedBox(
                width: 4.w,
              ),
              Image.asset(
                'assets/global/common/icon_detail_black.png',
                width: 12.w,
                height: 12.w,
              ),
            ],
          ),
        ),
      ),
      SizedBox(
        height: 30.w,
      ),
    ]);
  }

  ///状态背景
  Widget _buildStatusBgView({dynamic children = const <Widget>[]}) {
    return Stack(
      children: [
        // Positioned.fill(
        //   child: Container(
        //     decoration: const BoxDecoration(
        //       gradient: LinearGradient(colors: [
        //         ByColor.colorC1,
        //         Color(0xFF0BBA92),
        //         Color(0xFF0181FC)
        //       ]),
        //     ),
        //   ),
        // ),
        Image.asset(
          'assets/home/novel/icon_novel_record_bg.png',
          fit: BoxFit.fill,),
        Positioned.fill(
          child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: children,
              ),
            ),
        )
      ],
    );
  }
}
