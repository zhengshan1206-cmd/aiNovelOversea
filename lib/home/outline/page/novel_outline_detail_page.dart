
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:novel_oversea/core/ui/view/muti_status_view.dart';
import 'package:novel_oversea/core/ui/widget/by_text.dart';
import 'package:novel_oversea/global/const/const_utils.dart';
import 'package:novel_oversea/home/core/controller/words_controller.dart';
import 'package:novel_oversea/home/core/view/bottom_view.dart';
import 'package:novel_oversea/home/core/view/novel_stream_view.dart';
import 'package:novel_oversea/home/create/view/create_step_view.dart';
import 'package:novel_oversea/home/outline/controller/outline_detail_provider.dart';
import 'package:novel_oversea/me/user/user.dart';
import 'package:provider/provider.dart';
import '../../../global/routes/app_pages.dart';
import '../../../global/ui/colors.dart';

///大纲详情生成和展示页面
// ignore: must_be_immutable

class NovelOutlineDetailPage extends StatefulWidget {
  const NovelOutlineDetailPage({
    super.key,
    required this.id});

  final int id; ///大纲id

  @override
  State<NovelOutlineDetailPage> createState() => _NovelOutlineDetailPageState();
}

class _NovelOutlineDetailPageState extends State<NovelOutlineDetailPage> {

  @override
  void initState() {
    final provider = context.read<OutlineDetailProvider>();
    provider.fetchOutlineDetail(widget.id);
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
      title: Consumer<OutlineDetailProvider>(builder: (context, provider, child){
        return ByText.text(
            text: provider.outlineBean != null ? 'Outline ${provider.outlineBean?.index}' : '',
            textColor: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w500);
      }),
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
          fontSize: 14.sp,
          text: 'Record',
        ),
      ),
      onTap: () {
        Get.toNamed(Routes.novelRecord);
      },
    );
  }


  Widget buildBody(BuildContext context) {
    WordsController words = Get.find<WordsController>();
    return Consumer<OutlineDetailProvider>(
      builder: (context, provider, child) {
        return MultiStatusView(
          currentStatus: provider.statusType,
          action: () => provider.fetchOutlineDetail(widget.id),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: Column(
              children: [
                ///顶部进度视图
                const CreateStepView(currentStep: 1),
                SizedBox(
                  height: 12.w,
                ),

                Expanded(
                  child: NovelStreamView(
                    controller: provider.scrollController,
                    isStreaming: provider.isGenerating,
                    content: provider.content,
                    title: provider.outlineBean?.title,
                  ),
                ),
                SizedBox(
                  height: 12.w,
                ),

                if (provider.outlineBean != null && provider.outlineBean!.stage! < 3)
                ///底部提示
                Container(
                  height: 30.w,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: ByColor.colorBg1,
                  ),
                  child: ByText.text(
                      fontSize: 12.sp,
                      textColor: ByColor.colorG4,
                      text: 'outline is generating, please wait...'),
                ),

                if (provider.outlineBean != null)
                ///底部进度条
                provider.isGenerating
                    ? Container()
                    : BottomView(
                        padding: 0,
                        words: words.getWords(WordsType.outline, provider.outlineBean!.chaptersNum!),
                        showWords: provider.outlineBean!.allowGenerateChapter! && provider.outlineBean!.stage! == 3,
                        enable: provider.outlineBean!.allowGenerateChapter! || provider.outlineBean!.stage! >= 5,
                        nextBtnText: provider.outlineBean!.stage! >= 5 || provider.outlineBean!.stage == 7 ? 'View Chapter Outline' : 'Create Chapter Outline',
                        nextStep: () {
                          ///生成细纲
                          if (provider.outlineBean!.allowGenerateChapter!) {
                              ///字数不够
                              if (!words.isWordsEnable(WordsType.outline,
                                  provider.outlineBean!.chaptersNum!)) {
                                Get.find<UserController>().jumpToPayPage(source: 'novel_outline_detail_words_unable',);
                                return;
                              } else {
                                provider.createNovelChapter();
                              }
                            }
                          ///查看细纲
                          if (provider.outlineBean!.stage! >= 5) {
                            provider.gotoChapterList();
                          }
                        },
                      ),
              ],
            ),
          ),
        );
      },
    );
  }
}
