


import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:novel_oversea/core/ui/view/muti_status_view.dart';
import 'package:novel_oversea/core/ui/widget/by_text.dart';
import 'package:novel_oversea/global/ui/colors.dart';
import 'package:novel_oversea/home/core/page/novel_base_page.dart';
import 'package:novel_oversea/home/create/view/create_step_view.dart';
import 'package:novel_oversea/home/outline/bean/novel_outline_bean.dart';
import 'package:novel_oversea/home/outline/controller/novel_outline_controller.dart';
import 'package:novel_oversea/home/outline/controller/outline_detail_provider.dart';
import 'package:novel_oversea/home/outline/page/novel_outline_detail_page.dart';
import 'package:provider/provider.dart';

import '../../../global/routes/routes_provider_track.dart';

// ignore: must_be_immutable
class NovelOutlinePage extends NovelBasePage {
  NovelOutlinePage({super.key});

  @override
  String get title => 'Outline';

  @override
  NovelOutlineController get controller => Get.find<NovelOutlineController>();

  @override
  NovelCreateStepType get stepType => NovelCreateStepType.outline;

  @override
  Widget buildBody(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: Column(
        children: [
          ///顶部进度视图
          buildStepView(),
          SizedBox(
            height: 12.w,
          ),
          Expanded(
              child: Obx(() => MultiStatusView(
                    currentStatus: controller.statusType.value,
                    child: ListView.builder(
                        itemCount: controller.itemList.length,
                        itemBuilder: (context, index) {
                          OutlineBean bean = controller.itemList[index];
                          return GestureDetector(
                            onTap: () {
                              ///提交状态下的大纲无法查看详情页
                              if (bean.stage! < 2) {
                                return;
                              }
                              controller.viewDidDisappear();
                              final provider = OutlineDetailProvider();
                              ProviderPageTrackerManager.trackProviderPage(
                                pageId: '/novel_outline_detail_page',
                                widget: ChangeNotifierProvider(
                                  create: (context) => provider,
                                  child:  NovelOutlineDetailPage(
                                      id: bean.id!,
                                    ),
                                ),
                                after: () {
                                  controller.viewDidAppear();
                                },
                              );
                            },
                            child: Padding(
                              padding: EdgeInsets.only(
                                  top: index == 0 ? 0 : 6.w, bottom: 6.w),
                              child: Container(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 12.w),
                                  height: 50.w,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10.w),
                                    color: ByColor.colorBg2,
                                  ),
                                  child: Row(
                                    children: [
                                      ///是否生成结束的标识
                                      Offstage(
                                        offstage:
                                            [1, 2, 4].contains(bean.stage),
                                        child: Image.asset(
                                          'assets/home/novel/icon_checkbox_selected.png',
                                          width: 14.w,
                                          height: 14.w,
                                        ),
                                      ),
                                      if (![1, 2, 4].contains(bean.stage))
                                        SizedBox(
                                          width: 10.w,
                                        ),
                                      Container(
                                        constraints: BoxConstraints(
                                          maxWidth: 110.w,
                                        ),
                                        child: ByText.text(
                                            textColor: ByColor.colorF1,
                                            text: 'Outline${bean.index}'),
                                      ),
                                      SizedBox(
                                        width: 6.w,
                                      ),
                                      Container(
                                        child: ByText.text(
                                            textColor: ByColor.colorF2,
                                            text:
                                                '(Outline ${bean.bindChapter?[0]}-${bean.bindChapter?[1]})'),
                                      ),
                                      const Spacer(),
                                      _chooseOutlineStatus(bean),
                                    ],
                                  )),
                            ),
                          );
                        }),
                  ))),
        ],
      ),
    );
  }

  Widget _chooseOutlineStatus(OutlineBean bean) {
    ///大纲生成完毕，并且当前符合可生成细纲的篇章
    if (controller.novelStatus >= 7 &&
        bean.index == controller.currentOutlineIndex.value &&
        bean.stage! != 5) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        height: 32.w,
        decoration: BoxDecoration(
          color: ByColor.colorC1,
          borderRadius: BorderRadius.circular(16.w),
        ),
        child: Center(
          child:
              ByText.text(textColor: Colors.black, text: 'Create Chapter'),
        ),
      );
    }
    switch (bean.stage) {
      ///生成失败
      case 4:
        return Container();

      ///生成中
      case 2:
      case 5:
        return GenerateProgressView(
          progressText: bean.stage! == 2 ? 'Generating' : 'Generating',
          progress: -1,
        );

      ///等待生成
      case 1:
        return ByText.text(
            textColor: ByColor.colorF2, text: 'Pending');

      ///生成完成
      default:
        return Row(
          children: [
            if (bean.stage == 6)
              ByText.text(
                  textColor: ByColor.colorC1, text: 'Detail'),
            SizedBox(
              width: 4.w,
            ),
            Image.asset(
              'assets/home/novel/icon_novel_detail.png',
              width: 14.w,
              height: 14.w,
            ),
          ],
        );
    }
  }
}

///生成中的进度
class GenerateProgressView extends StatelessWidget {
  const GenerateProgressView(
      {super.key, this.progressText = 'Generating ', this.progress = 0});
  final int? progress;
  final String progressText;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CupertinoActivityIndicator(
          color: ByColor.colorC1,
          radius: 7.w,
        ),
        SizedBox(
          width: 10.0.w,
        ),
        ByText.text(
            text: progress! < 0 ? progressText : '$progressText $progress%',
            textColor: ByColor.colorC1),
      ],
    );
  }
}


///生成失败
class GenerateFailedView extends StatelessWidget {
  const GenerateFailedView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Image.asset(
          'assets/global/common/icon_novel_warning.png',
          width: 16.w,
          height: 16.w,
        ),
        SizedBox(
          width: 4.w,
        ),
        ByText.text(textColor: ByColor.colorG4, text: 'Failed'),
        SizedBox(
          width: 4.w,
        ),
        Image.asset(
          'assets/global/common/icon_novel_detail_error.png',
          width: 14.w,
          height: 14.w,
        ),
      ],
    );
  }
}