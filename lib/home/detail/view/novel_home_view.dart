
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:novel_oversea/core/service/words.dart';
import 'package:novel_oversea/core/ui/widget/by_button.dart';
import 'package:novel_oversea/core/ui/widget/by_refresh.dart';
import 'package:novel_oversea/core/ui/widget/by_text.dart';
import 'package:novel_oversea/core/util/clipboard.dart';
import 'package:novel_oversea/core/util/extentions.dart';
import 'package:novel_oversea/home/brief/controller/novel_brief_provider.dart';
import 'package:novel_oversea/home/brief/page/novel_brief_page.dart';
import 'package:novel_oversea/home/chapter/view/chapter_list_view.dart';
import 'package:novel_oversea/home/detail/controller/novel_home_controller.dart';
import 'package:novel_oversea/me/user/user.dart';
import 'package:provider/provider.dart';
import '../../../global/routes/app_pages.dart';
import '../../../global/routes/routes_provider_track.dart';
import '../../../global/ui/colors.dart';

class NovelHomeView extends StatefulWidget {
  const NovelHomeView({super.key});

  @override
  State<NovelHomeView> createState() => _NovelHomeViewState();
}

class _NovelHomeViewState extends State<NovelHomeView> {
  final NovelHomeController controller = Get.find<NovelHomeController>();
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return ByRefresh.refresh(
      controller: controller.refreshManager.refreshController,
      ///分两个接口是为了防止小说被爬
      // onRefresh: () {
      //   controller.loadData();
      // },
      onLoad: () {
        controller.fetchNovelInfoList(isReverse: controller.reverse.value);
      },
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 12.w,),
            _buildCoverView(),
            SizedBox(height: 16.w,),
            ///标题
            Obx(() => ByText.text(
                        fontSize: 25.sp,
                        textColor: ByColor.colorF1,
                        text: controller.manager.title.value)),
            SizedBox(height: 10.w,),
            _buildTagsView(),
            SizedBox(height: 16.w,),
            _buildPausedView(),
            if(controller.novelBean.value!.stage! >= 4)
            SizedBox(height: 10.w,),
            if(controller.novelBean.value!.stage! >= 4)
            _buildBriefView(),
            if(controller.novelBean.value!.stage! >= 5)
            SizedBox(height: 12.w,),
            if(controller.novelBean.value!.stage! >= 5)
            _buildOutlineView(),
            if(controller.novelBean.value!.stage! >= 5)
            SizedBox(
              height: 12.w,
            ),
            if(controller.novelBean.value!.stage! >= 5)
            Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                child: Obx(() => ChapterListView(
                      length: controller.itemList.length,
                      itemList: controller.itemList,
                      reverse: controller.reverse.value,
                      ///正反序列
                      reverseAction: (reverse) {
                        controller.refreshManager.pageHelper.resetPage();
                        controller.fetchNovelInfoList(isReverse: reverse);
                      },
            
                      ///点击进入章节详情
                      action: (p0, p1) {
                        Get.find<UserController>().checkPreLogin(
                          source: 'novel_home',
                          actionCallback: () {
                            controller.gotoNovelInfoPage(
                              p0.id!,
                              isSquare: false,
                              isGuide: false,
                              stage: Get.arguments["stage"],
                            );
                          },
                        );
                      },
                    ))),

          ],
        ),
      ),
    );
  }

  ///生成封面图
  Widget _buildCoverView() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.w),
      child: Container(
        width: 168.w,
        height: 209.w,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(8.w)),
        child: Stack(
          children: [
            GestureDetector(
              ///重新生成封面
              onTap: () {
                // 灵感生成完成后才能修改封面
                // if (controller.novelBean.value!.stage! >= 4) {
                //   controller.redrawNovelCover();
                // } else {
                //   Toast.showText(text: '灵感生成完成后才能修改封面');
                // }
              },
              child: NovelCoverView(
                cover: controller.novelBean.value?.cover,
                title: '',
                // controller.source == NovelHomeSourceType.guide
                //     ? ''
                //     : controller.novelBean.value?.title,
                radio: 0.6,
              ),
            ),
            ///小说字数
              Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.w, vertical: 1.w),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(8.w),
                        bottomLeft: Radius.circular(8.w),
                      ),
                      color: ByColor.colorC1,
                    ),
                    child: ByText.text(
                        fontSize: 12,
                        textColor: Colors.black,
                        text:
                            '${WordsService.wordsDisplay('${controller.novelBean.value?.realityWords}')} credits'),
                  )),
          ],
        ),
      ),
    );
  }

  ///标签视图
  Widget _buildTagsView() {
    return Center(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        height: 30.w,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final tags = controller.novelBean.value!.tags!;
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(tags.length, (index) {
                  final String text = tags[index];
                  return Padding(
                    padding: EdgeInsets.only(left: index == 0 ? 0 : 3, right: 3),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.w),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlphaValue(0.16),
                        borderRadius: BorderRadius.circular(8.w),
                      ),
                      child: ByText.text(
                        fontSize: 12,
                        textColor: Colors.white,
                        text: text,
                      ),
                    ),
                  );
                }),
              ),
            );
          },
        ),
      ),
    );
  }

  ///简介视图
  Widget _buildBriefView() {
    return Obx(() => Container(
      height: _isExpanded ? 237.w : 119.w,
      margin: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.w),
          color: ByColor.colorBg2,
          border: Border.all(
            width: 1,
            color: Colors.white.withAlphaValue(0.1),
            ///ui上的透明度0.2，感觉边框太亮了
          ),
        ),
      child: Padding(
        padding: EdgeInsets.symmetric( vertical: 12.w),
        child: Column(
          children: [
            Row(
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 18.w),
                  child: ByText.text(
                    fontSize: 15,
                    textColor: Colors.white,
                    fontWeight: FontWeight.w600,
                    text: 'Brief',
                  ),
                ),
      
                ///引导页进入的简介复制
                Padding(
                  padding: EdgeInsets.only(right: 18.w),
                  child: Container(
                    height: 24.w,
                    padding: EdgeInsets.only(left: 9.w, right: 9.w),
                    child: ByButton.iconButton(
                      icon: Image.asset('assets/home/novel/icon_novel_brief.png'),
                      padding: EdgeInsets.zero,
                      title: 'Copy Introduction',
                      backgroundColor: Colors.transparent,
                      titleColor: ByColor.colorF2,
                      fontSize: 13.sp,
                      onPressed: () {
                        ///复制简介
                        ClipboardManager.clip(
                          controller.novelBean.value?.introduce,
                        );
                      },
                    ),
                  ),
                ),
                const Spacer(),
      
                ///
                ///小说灵感进入
                Padding(
                  padding: EdgeInsets.only(right: 18.w),
                  child: Container(
                    height: 24.w,
                    width: 90.w,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.w),
                      border: Border.all(width: 1, color: ByColor.colorC1),
                    ),
                    child: Row(
                      children: [
                        SizedBox(width: 12.w),
                        ByButton.textButton(
                          padding: EdgeInsets.zero,
                          title: 'Inspiration',
                          backgroundColor: Colors.transparent,
                          titleColor: ByColor.colorC1,
                          fontSize: 12.sp,
                          onPressed: () {
                            ///进入灵感页
                            final provider = BriefDetailProvider();
                            ProviderPageTrackerManager.trackProviderPage(
                                pageId: '/novel_brief_page',
                                widget: ChangeNotifierProvider(
                                  create: (context) => provider,
                                  child: NovelBriefPage(
                                    novelID: controller.novelID,
                                  ),
                                ),
                              );
                          },
                        ),
                        SizedBox(width: 4.w),
                        Image.asset(
                          'assets/home/novel/icon_novel_detail.png',
                          width: 10.w,
                          height: 10.w,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.w),
            Padding(
              padding: EdgeInsets.only(left: 18.w, right: 18.w),
              child: ExpandableText(
                text: controller.novelBean.value?.introduce ?? '',
                maxLines: 3,
                onExpand: (p0) {
                  setState(() {
                    _isExpanded = p0;
                  });
                },
              ),
              // child: ByText.text(
              //         fontSize: 14,
              //         textColor: ByColor.colorF1,
              //         maxLines: 3,
              //         text: controller.novelBean.value?.introduce ?? ''),
            ),
          ],
        ),
      ),
    ));
  }

  ///断更视图
  Widget _buildPausedView() {
    return Obx(() => controller.novelBean.value?.stage != 10
        ? GestureDetector(
            onTap: () {
              if (!controller.isPaused()) {
                controller.pauseNovel();
              }
            },
            child: !controller.isPaused()
                ? ByText.text(
                    text: 'Not satisfied, stop updating',
                    fontSize: 12.sp,
                    decoration: TextDecoration.underline,
                    decorationColor: ByColor.colorF1.withAlphaValue(0.5),
                    decorationThickness: 2,
                    textColor: ByColor.colorF1.withAlphaValue(0.5),
                  )
                : ByText.text(
                    fontSize: 12,
                    textColor: ByColor.colorG4,
                    text: 'Stoped',
                  ),
          )
        : Container());
  }


  ///生成中部大纲页
  Widget _buildOutlineView() {
    return GestureDetector(
      onTap: () {
        Get.toNamed(Routes.novelCreateOutline,
            arguments: {'novelID': controller.novelID})?.then((_) {
          controller.loadData();
        });
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        child: Container(
          height: 44.w,
          decoration: BoxDecoration(
            color: ByColor.colorBg2,
            borderRadius: BorderRadius.circular(10.w),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 12.w,
              ),
              Image.asset(
                'assets/home/novel/icon_novel_home_outline.png',
                width: 16.w,
                height: 16.w,
              ),
              SizedBox(
                width: 4.0.w,
              ),
              ByText.text(
                text: 'Outline',
                textColor: Colors.white,
                fontSize: 15,
              ),
              const Spacer(),
              Obx(() => _setOutlineStatus(controller.novelBean.value!.stage!)),
              SizedBox(
                width: 10.0.w,
              ),
              Image.asset(
                'assets/home/novel/btn_novel_home_outline.png',
                width: 8.w,
                height: 8.w,
              ),
              SizedBox(
                width: 12.w,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _setOutlineStatus(int stage) {
    if (stage == 5) {
      return const GenerateProgressView(
        progress: -1,
      );
    } else if (stage == 6) {
      return const GenerateFailedView();
    } else {
      return Container();
    }
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
        ByText.text(textColor: ByColor.colorG4, text: 'Generation Failed'),
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

///生成中的进度
class GenerateProgressView extends StatelessWidget {
  const GenerateProgressView(
      {super.key, this.progressText = 'generating ', this.progress = 0});
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

///小说封面图
class NovelCoverView extends StatelessWidget {
  const NovelCoverView({
    super.key,
    this.cover,
    this.title = '',
    this.radio = 1.0,
  });

  ///封面
  final String? cover;

  ///标题
  final String? title;

  ///缩放比
  final double? radio;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        cover!.isEmpty ? Container() : Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.w),
              child: CachedNetworkImage(
                        imageUrl: cover!,
                        // placeholder: (context, url) => const CircularProgressIndicator(),
                        // errorWidget: (context, url, error) {
                        //   return Container();
                        // },
                        fit: BoxFit.cover,
                      ),
            )),

        Positioned(
          left: 0,
          top: 0,
          bottom: 0,
          child: Image.asset(
          'assets/home/novel/icon_book_cover_mask.png',
          fit: BoxFit.cover,
          width: 19.w,
        )),
        // Positioned(
        //     top: radio! * 30.w,
        //     left: 0,
        //     right: 0,
        //     child: Padding(
        //       padding: EdgeInsets.symmetric(horizontal: 12.w),
        //       child: ByText.text(
        //           maxLines: 2,
        //           textColor: const Color(0xFF576367),
        //           fontSize: 18 * radio!,
        //           fontFamily: 'AlimamaShuHeiTi',
        //           fontWeight: FontWeight.w500,
        //           text: title!),
        //     ))
      ],
    );
  }
}

class ExpandableText extends StatefulWidget {
  final String text;
  final int maxLines;
  final String expandText;
  final String collapseText;
  final Function(bool)? onExpand;

  const ExpandableText(
      {super.key,
      required this.text,
      this.maxLines = 3,
      this.expandText = '【More】',
      this.collapseText = '收起',
      this.onExpand});

  @override
  State<ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(
      fontSize: 14,
      color: ByColor.colorF1,
    );

    // 创建一个TextPainter来计算文本行数
    final painter = TextPainter(
      text: TextSpan(text: widget.text, style: textStyle),
      maxLines: widget.maxLines,
      textDirection: TextDirection.ltr,
    );
    painter.layout(maxWidth: MediaQuery.of(context).size.width - 24.w - 36.w);

    // 判断文本是否需要截断
    final needsTruncation = painter.didExceedMaxLines;

    if (!needsTruncation || _expanded) {
      return Column(
        children: [
          SizedBox(
            height: 140.w,
            child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Text(
                  widget.text,
                  style: textStyle,
                  maxLines: 9999,
                )),
          ),
          SizedBox(
            height: 8.w,
          ),
          GestureDetector(
            onTap: () => setState(() {
              _expanded = !_expanded;
              widget.onExpand?.call(_expanded);
            }),
            child: SizedBox(
              height: 24.w,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ByText.text(
                      textColor: ByColor.colorF1, text: 'Pick up'),
                  SizedBox(
                    width: 4.w,
                  ),
                  AnimatedRotation(
                    turns: 0.5,
                    duration: const Duration(milliseconds: 0),
                    child: Image.asset(
                      'assets/home/novel/btn_novel_create_tags_more.png',
                      width: 12.w,
                      height: 12.w,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    // 计算截断位置
    final endIndex = painter
        .getPositionForOffset(
          Offset(
            painter.width -
                textStyle.fontSize! * ('...${widget.expandText}'.length),
            double.infinity,
          ),
        )
        .offset;

    // final painterExpanded = TextPainter(
    //   text: TextSpan(text: '...${widget.expandText}', style: textStyle),
    //   maxLines: 1,
    //   textDirection: TextDirection.ltr,
    // );
    // painterExpanded.layout(maxWidth:  double.infinity);
    // print('____________${textStyle.fontSize! * ('...${widget.expandText}'.length)}====>>>>${painter.width}.......${painterExpanded.width}');

    return GestureDetector(
      onTap: () => setState(() {
        _expanded = !_expanded;
        widget.onExpand?.call(_expanded);
      }),
      child: Text.rich(
        TextSpan(
          text: '${widget.text.substring(0, endIndex)}...',
          style: textStyle,
          children: [
            TextSpan(
              text: widget.expandText,
              style: const TextStyle(color: ByColor.colorC1, fontSize: 14),
            ),
          ],
        ),
        maxLines: widget.maxLines,
        // overflow: TextOverflow.clip,
      ),
    );
  }
}
