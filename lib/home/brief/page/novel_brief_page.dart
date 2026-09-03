/*
 * @Author: cold-x
 * @Date: 2025-06-16 20:30:05
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2026-01-09 18:28:28
 * @FilePath: /novel_oversea/lib/home/brief/page/novel_brief_page.dart
 * @Description: 灵感生成页面
 */

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:novel_oversea/core/ui/dialog/loading_dialog.dart';
import 'package:novel_oversea/core/ui/view/muti_status_view.dart';
import 'package:novel_oversea/core/ui/view/progress_view.dart';
import 'package:novel_oversea/core/ui/widget/by_button.dart';
import 'package:novel_oversea/core/ui/widget/by_text.dart';
import 'package:novel_oversea/core/util/by_screen_utils.dart';
import 'package:novel_oversea/global/const/const_utils.dart';
import 'package:novel_oversea/home/brief/controller/novel_brief_provider.dart';
import 'package:novel_oversea/home/core/controller/words_controller.dart';
import 'package:novel_oversea/home/core/view/bottom_view.dart';
import 'package:novel_oversea/home/core/view/novel_stream_view.dart';
import 'package:novel_oversea/home/create/view/create_step_view.dart';
import 'package:novel_oversea/me/user/user.dart';
import 'package:provider/provider.dart';
import '../../../global/routes/app_pages.dart';
import '../../../global/ui/colors.dart';

///灵感生成页面
// ignore: must_be_immutable
class NovelBriefPage extends StatefulWidget {
  const NovelBriefPage({super.key, required this.novelID});

  final int novelID;

  ///小说id

  @override
  State<NovelBriefPage> createState() => _NovelBriefPageState();
}

class _NovelBriefPageState extends State<NovelBriefPage> {
  late WordsController words = Get.find<WordsController>();
  bool showFirstAnimate = false; ///赚钱动效是否显示首次动画效果
  ///短故事小说深度思考是否是展开模式
  bool isExpanded = true;

  @override 
  void initState(){
    final provider = context.read<BriefDetailProvider>();
    provider.maxWords = words.words!.brief!;
    provider.novelID = widget.novelID;
    provider.fetchNovelDetail(provider.novelID!);
    if(provider.isFirstCreate) {
      FirebaseAnalytics.instance.logEvent(name: 'Create_OB_story_ins_show');
    }
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
          final provider = context.read<BriefDetailProvider>();
          provider.updateUserUnCompleteNovel();
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
      title: Consumer<BriefDetailProvider>(builder: (context, provider, child) {
          return ByText.text(
              text: provider.pageTitle,
              // text: "小说灵感111",
              textColor: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w500);
        })
    );
  }

  Widget buildBody(BuildContext context) {
    return Consumer<BriefDetailProvider>(
      builder: (context, provider, child) {
        return PopScope(
          canPop: true,
          onPopInvokedWithResult: (didPop, p0) {
            if(didPop) {
              provider.updateUserUnCompleteNovel();
            }
          },
          child: Stack(
            children: [
              Positioned(
                child: MultiStatusView(
                  currentStatus: provider.statusType,
                  loadingWidget: const Center(
                    child: LoadingView(
                      loadingText: 'loading...',
                      bgColor: Colors.transparent,
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    child: Column(
                      children: [
                        ///顶部进度视图
                        if (provider.novelBean != null && provider.novelBean!.stage! < 5)
                          CreateStepView(
                            type: provider.type,
                            currentStep: 0,
                          ),
                        SizedBox(
                          height: 12.w,
                        ),
                        Expanded(
                          child: _buildNovelMDView()
                        ),
                        SizedBox(
                          height: 4.w,
                        ),
                        ///底部进度条
                        provider.isGenerating
                            ? _buildProgressView()
                            : provider.novelBean != null && provider.showBottom
                                    ? BottomView(
                                        padding: 0,
                                        words: words.getWords(
                                                WordsType.brief,
                                                provider
                                                    .novelBean!.chaptersNum!, novelType: provider.type),
                                        nextBtnText:
                                            provider.novelBean!.stage! <= 4
                                                ? 'Generate Outline'
                                                : 'View Outline',

                                        ///引导页或者生成大纲后不显示字数
                                        showWords: provider.novelBean!.stage! < 5,
                                        nextStep: () {
                                          if(provider.isFirstCreate) {
                                            FirebaseAnalytics.instance.logEvent(name: 'Create_OB_story_ins');
                                          }
                                          if (provider.novelBean!.stage! <= 4) {
                                            ///字数检测
                                            if (words.isWordsEnable(
                                                    WordsType.brief,
                                                    provider.novelBean!
                                                        .chaptersNum!, novelType: provider.type)) {
                                                provider.createNovelOutline();
                                            } else {
                                              Get.find<UserController>()
                                                  .jumpToPayPage(
                                                      source:
                                                          'novel_brief_words');
                                            }
                                          } else {
                                              Get.toNamed(
                                                Routes.novelCreateOutline,
                                                arguments: {
                                                  'novelID': widget.novelID
                                                });
                                            }
                                        },
                                      )
                                    : Container(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  ///长文、短文markdown
  Widget _buildNovelMDView() {
    final provider = context.read<BriefDetailProvider>();
    return NovelStreamView(
      showTitle: true,
      controller: provider.scrollController,
      isStreaming: provider.isGenerating,
      content: provider.content,
      title: provider.isGenerating
              ? 'Book Creating...'
              : provider.novelBean?.title ?? '',
    );
  }

  Widget _buildProgressView() {
    final provider = context.read<BriefDetailProvider>();
    return Container(
        height: 56.w  + ByScreenUtils.bottomSafeHeight,
        padding: EdgeInsets.only(
            top: 4.w, bottom: ByScreenUtils.bottomSafeHeight + 5.w),
        child: Row(
          children: [
            ByButton.textButton(
              title: 'Read Later',
              padding: EdgeInsets.symmetric(horizontal: 15),
              titleColor: ByColor.colorC1,
              backgroundColor: ByColor.color2E3038,
              onPressed: () {
                  Get.back();
              },
            ),
            SizedBox(
              width: 12.w,
            ),
            Expanded(
              child: ProgressView(
              progress: provider.progress,
            )),
          ],
        ));
  }
}
