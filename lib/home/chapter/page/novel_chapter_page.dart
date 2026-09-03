/*
 * @Author: cold-x
 * @Date: 2025-06-16 20:40:06
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2025-11-01 10:14:51
 * @FilePath: /novel_oversea/lib/home/chapter/page/novel_chapter_page.dart
 * @Description: 
 */

import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:novel_oversea/core/ui/dialog/toast.dart';
import 'package:novel_oversea/core/ui/view/muti_status_view.dart';
import 'package:novel_oversea/core/ui/widget/by_text.dart';
import 'package:novel_oversea/home/chapter/bean/novel_chapter_bean.dart';
import 'package:novel_oversea/home/chapter/controller/novel_chapter_controller.dart';
import 'package:novel_oversea/home/core/page/novel_base_page.dart';
import 'package:novel_oversea/home/core/view/bottom_view.dart';
import 'package:novel_oversea/home/core/view/chapter_choose_view.dart';
import 'package:novel_oversea/home/create/view/create_step_view.dart';
import 'package:novel_oversea/home/outline/page/novel_outline_page.dart';
import '../../../global/ui/colors.dart';

// ignore: must_be_immutable
class NovelChapterPage extends NovelBasePage {
  NovelChapterPage({super.key});

  @override
  String get title => 'Chapter Outline';

  @override
  NovelChapterController get controller => Get.find<NovelChapterController>();

  @override
  NovelCreateStepType get stepType => NovelCreateStepType.chapter;

  @override
  Widget buildBody(BuildContext context) {
    return Obx(() => MultiStatusView(
          currentStatus: controller.statusType.value,
          action: () {
            controller.fetchChapterList();
          },
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ///顶部进度视图
                buildStepView(),
                SizedBox(
                  height: 12.w,
                ),
                Expanded(
                    child: ListView.builder(
                        controller: controller.scrollController,
                        itemCount: controller.itemList.length,
                        itemBuilder: (context, index) {
                          ChapterBean bean = controller.itemList[index];
                          return Padding(
                            padding: EdgeInsets.only(
                                top: index == 0 ? 0 : 6.w, bottom: 6.w),
                            child: Container(
                                padding: EdgeInsets.all(12.w),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.w),
                                  color: ByColor.colorBg2,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          constraints: BoxConstraints(
                                            maxWidth: 240.w,
                                          ),
                                          child: ByText.text(
                                              fontSize: 16,
                                              textColor: ByColor.colorF1,
                                              text:
                                                  'Chapter ${bean.index} ${bean.title}'),
                                        ),
                                        SizedBox(
                                          width: 10.w,
                                        ),
                                        // Offstage(
                                        //   offstage: false,
                                        //   child: ByText.text(
                                        //       textColor: ByColor.colorF2,
                                        //       text: '已完成'),
                                        // ),
                                        const Spacer(),
                                        _chooseOutlineStatus(bean),
                                      ],
                                    ),
                                    if (bean.introduce != null &&
                                        bean.introduce!.isNotEmpty)
                                      SizedBox(
                                        height: 12.w,
                                      ),
                                    if (bean.introduce != null &&
                                        bean.introduce!.isNotEmpty)
                                      ByText.text(
                                          maxLines: 3,
                                          textColor: ByColor.colorF2,
                                          text: bean.introduce ?? ''),
                                  ],
                                )),
                          );
                        })),
                Container(
                  height: 30.w,
                  width: double.infinity,
                  alignment: Alignment.centerLeft,
                  decoration: const BoxDecoration(
                    color: ByColor.colorBg1,
                  ),
                  child: ByText.text(
                      fontSize: 12.sp,
                      maxLines: 2,
                      textColor: controller.canSubmitContent() &&
                              controller.outlineStatus.value == 6
                          ? ByColor.colorC1
                          : ByColor.colorG4,
                      text: controller.outlineStatus.value != 6
                          ? 'Chapter outline is generating, wait for a while...'
                          : controller.canSubmitContent()
                              ? 'Already generate ${controller.generatedContentNum()} chapters, click continue'
                              : 'Submit all the front outline chapters to coninue'),
                ),
                BottomView(
                  showWords: false,
                  padding: 0,
                  enable: controller.outlineStatus.value == 6 &&
                      controller.canSubmitContent(),
                  nextBtnText: controller.submittedChapterNum.value >=
                          controller.lastContentIndex()
                      ? 'Read Novel'
                      : 'One-Tap Creation',
                  nextStep: () {
                    if (controller.submittedChapterNum.value >=
                        controller.lastContentIndex()) {
                      ///当前有小说生成时，跳转至小说正文页
                      if (controller.itemList.first.stage! > 4) {
                        controller.gotoNovelInfoPage(
                            controller.itemList.first.id!,
                            jumpToStream: false);
                      } else {
                        Toast.showText(text: 'Front outline chapter is generating, wait for a while~');
                      }
                      return;
                    }
                    Get.bottomSheet(
                      ChapterChooseView(
                        charpterNum: controller.itemList.last.index!,
                        startChapter: controller.itemList.first.index!,
                        endChapter: controller.itemList.last.index!,
                        finishedNum: controller.submittedChapterNum.value,
                        chapterSelected: (chapter) {
                          controller.generateAction(chapter);
                        },
                      ),
                      isScrollControlled: true,
                    );
                  },
                )
              ],
            ),
          ),
        ));
  }

  Widget _chooseOutlineStatus(ChapterBean bean) {
    switch (bean.stage) {
      ///生成失败
      case 7:
      case 8:
        return GestureDetector(
          onTap: () {
            controller.gotoChapterInfoPage(bean);
          },
          child: const GenerateFailedView(),
        );

      ///生成中
      case 2:
      case 5:
        return GestureDetector(
            onTap: () {
              controller.gotoChapterInfoPage(bean);
            },
            child: GenerateProgressView(
              progressText: bean.stage! == 2 ? 'Generating...' : 'Generating...',
              progress: -1,
            ));

      ///等待生成
      case 1:
        return ByText.text(
            textColor: ByColor.colorF2, text: 'Wait for generating');
      default:
        return GestureDetector(
          onTap: () {
            controller.gotoChapterInfoPage(bean);
          },
          child: Row(
            children: [
              ByText.text(
                  textColor: ByColor.colorC1, text: 'View'),
              SizedBox(
                width: 4.w,
              ),
              Image.asset(
                'assets/home/novel/icon_novel_detail.png',
                width: 14.w,
                height: 14.w,
              ),
            ],
          ),
        );
    }
  }
}
