/*
 * @Author: cold-x
 * @Date: 2025-06-16 20:30:05
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2025-10-30 10:11:50
 * @FilePath: /novel_oversea/lib/home/chapter/page/novel_chapter_detail_page.dart
 * @Description: 章节细纲详情生成和展示页面
 */


import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:novel_oversea/core/ui/view/muti_status_view.dart';
import 'package:novel_oversea/core/ui/widget/by_text.dart';
import 'package:novel_oversea/global/const/const_utils.dart';
import 'package:novel_oversea/home/chapter/bean/novel_chapter_bean.dart';
import 'package:novel_oversea/home/core/view/novel_stream_view.dart';
import 'package:novel_oversea/home/create/view/create_step_view.dart';
import 'package:provider/provider.dart';
import '../../../global/routes/app_pages.dart';
import '../../../global/ui/colors.dart';
import '../controller/chapter_detail_provider.dart';




///章节细纲详情生成和展示页面
class NovelChapterDetailPage extends StatefulWidget {
  const NovelChapterDetailPage({
    super.key,
    required this.bean});

  final ChapterBean bean;

  @override
  State<NovelChapterDetailPage> createState() => _NovelChapterDetailPageState();
}

class _NovelChapterDetailPageState extends State<NovelChapterDetailPage> {

  String title = 'Chapter Detail';

  @override
  void initState() {
    final provider = context.read<ChapterDetailProvider>();
    provider.fetchChapterDetail(widget.bean.novelID!, widget.bean.id!);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ByColor.colorBg1,
      appBar: buildAppBar(context),
      body: buildBody(context),
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      toolbarHeight: ConstUtils.getNavigationHeight(),
      leading: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          Get.back();
        },
        child: Container(
          width: 56,
          height: ConstUtils.getNavigationHeight(),
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
      title: ByText.text(
          text: title,
          textColor: Colors.white,
          fontSize: 17,
          fontWeight: FontWeight.w500),
      // actions: [
      //   buildActions(context),
      // ],
    );
  }

  Widget buildActions(BuildContext context) {
    return GestureDetector(
      child: Container(
        padding: EdgeInsets.all(12.w),
        child: ByText.text(
          bgColor: Colors.transparent,
          textColor: ByColor.colorC1,
          fontWeight: FontWeight.w500,
          fontSize: 14,
          text: 'Record',
        ),
      ),
      onTap: () {
        Get.toNamed(Routes.novelRecord);
      },
    );
  }

  Widget buildBody(BuildContext context) {
    return Consumer<ChapterDetailProvider>(builder: (context, provider, child) {
      return MultiStatusView(
        currentStatus: provider.statusType,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: Column(
            children: [
              ///顶部进度视图
              const CreateStepView(currentStep: 2),
              SizedBox(
                height: 12.w,
              ),
              Expanded(
                child: NovelStreamView(
                  controller: provider.scrollController,
                  isStreaming: provider.isGenerating,
                  content: provider.content,
                  title: provider.chapterBean?.title ?? '',
                  // novelID: provider.,
                ),
              ),
              SizedBox(
                height: 12.w,
              ),
            ],
          ),
        ),
      );
    });
  }
}
