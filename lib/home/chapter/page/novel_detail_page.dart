/*
 * @Author: cold-x
 * @Date: 2025-06-16 20:40:17
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2025-11-01 10:18:51
 * @FilePath: /novel_oversea/lib/home/chapter/page/novel_detail_page.dart
 * @Description: 
 */

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:novel_oversea/core/ui/dialog/toast.dart';
import 'package:novel_oversea/core/ui/view/muti_status_view.dart';
import 'package:novel_oversea/core/ui/widget/by_button.dart';
import 'package:novel_oversea/core/ui/widget/by_text.dart';
import 'package:novel_oversea/global/const/const_utils.dart';
import 'package:novel_oversea/home/chapter/controller/chapter_list_provider.dart';
import 'package:novel_oversea/home/chapter/controller/novel_detail_provider.dart';
import 'package:novel_oversea/home/chapter/view/chapter_list_view.dart';
import 'package:novel_oversea/home/core/view/novel_stream_view.dart';
import 'package:provider/provider.dart';
import '../../../core/util/by_screen_utils.dart';
import '../../../core/util/clipboard.dart';
import '../../../global/ui/colors.dart';


class NovelDetailPage extends StatefulWidget {
  const NovelDetailPage({super.key});

  @override
  State<NovelDetailPage> createState() => _NovelDetailPageState();
}

class _NovelDetailPageState extends State<NovelDetailPage> {
  // 滑动偏移量（用于视觉反馈）
  double _offsetX = 0;
  // 滑动开始X坐标
  double _startX = 0;


  @override
  void initState() {
    super.initState();
    final provider = context.read<NovelDetailProvider>();
    provider.startListening();
    
    provider.statusType = MultiStatusType.statusLoading;
    if(provider.isSquare){
      provider.fetchSquareNovelInfoList();
      provider.fetchSquareNovelInfo();
    }
    else {
      provider.delayToLoad();
    }
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
      title: Consumer<NovelDetailProvider>(builder: (context, provider, child){
        return ByText.text(
            text: provider.chapterBean != null ? 'Chapter ${provider.chapterBean?.index}' : '',
            textColor: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w500);
      }));
  }

  Widget buildBody(BuildContext context) {
    return Consumer<NovelDetailProvider>(builder: (context, provider, child) {
      return MultiStatusView(
        currentStatus: provider.statusType,
        action: () {
          provider.reloadData();
        },
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: Column(
            children: [
              Expanded(
                child: GestureDetector(
                  // 滑动开始
                  onHorizontalDragStart: (details) {
                    _startX = details.globalPosition.dx;
                    _offsetX = 0; // 重置偏移
                  },

                  // 滑动过程中更新偏移
                  onHorizontalDragUpdate: (details) {
                    // 计算当前偏移（限制范围，避免过度滑动）
                    _offsetX = details.globalPosition.dx - _startX;
                    if (_offsetX > 100) _offsetX = 100;
                    if (_offsetX < -100) _offsetX = -100;
                  },

                  // 滑动结束判断
                  onHorizontalDragEnd: (details) {
                    // 计算总滑动距离
                    final distance = _offsetX;
                    // 计算滑动速度（水平方向）
                    final velocity = details.velocity.pixelsPerSecond.dx;

                    // 阈值判断：距离≥80 或 速度≥300 视为有效滑动
                    if (distance >= 80 || velocity >= 300) {
                      // _handleSwipeRight();
                      provider.toggleChapter(false);
                    } else if (distance <= -80 || velocity <= -300) {
                      // _handleLeft();
                      provider.toggleChapter(true);
                    }

                    // 复位偏移
                    _offsetX = 0;
                  },

                  child: NovelStreamView(
                    isMarkdown: false,
                    controller: provider.scrollController,
                    isStreaming: provider.isGenerating,
                    isGeneratingNext: provider.isGeneratingNextChapter,
                    content: provider.content,
                    title: provider.chapterBean?.title,
                  )
                ),
              ),
              SizedBox(
                height: 12.w,
              ),
              if(provider.itemList.isNotEmpty)
              _buildBottomView(),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildBottomView() {
    ///目录，切换章节
    final provider = context.read<NovelDetailProvider>();
    return Container(
        height: 56.w + ByScreenUtils.bottomSafeHeight,
        padding: EdgeInsets.only(
            top: 4.w,
            bottom: ByScreenUtils.bottomSafeHeight + 4.w),
        child: SizedBox(
          height: 48.w,
          child: Row(
            children: [
              Container(
                width: 48.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.w),
                  color: ByColor.color2E3038,
                ),
                child: Opacity(
                  opacity:  1.0,
                  child: ByButton.buttonWidget(
                      padding: EdgeInsets.all(6.w),
                      child: Image.asset('assets/home/novel/btn_novel_contents.png'),
                      onPressed: () {
                        // if(provider.isGenerating) {
                        //   Toast.showText(text: '正文生成完成之后才能查看哦~');
                        // }
                        final listProvider = ChapterListProvider();
                        listProvider.novelID = provider.novelID;
                        listProvider.outlineID = provider.outlineID;
                        listProvider.itemList = provider.itemList;
                        provider.isSquare ?  listProvider.fetchSquareNovelInfoList(provider.isGuide) : listProvider.fetchNovelInfoList();
                        Get.bottomSheet(
                          ChangeNotifierProvider(
                            create: (context) => listProvider,
                            child: Container(
                              color: ByColor.colorBg2,
                              child: Column(
                                children: [
                                  Container(
                                    padding: EdgeInsets.only(left: 12.w),
                                    height: 45.w,
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Row(
                                        children: [
                                          ByText.text(
                                            text: 'Contents',
                                            textColor: Colors.white,
                                            fontSize: 15,
                                          ),
                                          const Spacer(),
                                          GestureDetector(
                                            onTap: () {
                                              Get.back();
                                            },
                                            child: Image.asset(
                                                'assets/global/common/btn_close.png',
                                                fit: BoxFit.fill,
                                                width: 32.w,
                                                height: 32.w,)),
                                          SizedBox(width: 12.w,),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: SingleChildScrollView(
                                            child: mounted ? Consumer<ChapterListProvider>(builder: (context, listProvider, child) {
                                              return ChapterListView(
                                              length: listProvider.itemList.length,
                                              itemList: listProvider.itemList,
                                              showReverse: false,
                                              action: (bean, index) {
                                                ///正在生成或者生成完成时，进入查看页
                                                if(bean.stage == 6 || bean.stage == 5) {
                                                  Get.back();
                                                  if(provider.currentChapter != index) {
                                                    provider.currentChapter = index;
                                                    provider.contentID = bean.id;
                                                    provider.reloadData();
                                                  }
                                                }
                                              },);
                                            }) : Container()),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                ),
              ),
              if(provider.isSquare)
              const Spacer(),
              SizedBox(width: 12.w,),
              Opacity(
                opacity: provider.currentChapter == 0 || provider.isGenerating ? 0.5 : 1.0,
                child: SizedBox(
                  width: 48.w,
                  child: ByButton.buttonWidget(
                      padding: EdgeInsets.all(6.w),
                      child: Image.asset('assets/home/novel/btn_novel_next.png'),
                      backgroundColor: ByColor.color2E3038,
                      onPressed: () {
                        ///上一页
                        provider.toggleChapter(false);
                      }),
                ),
              ),
              if(!provider.isSquare)
              SizedBox(width: 12.w,),
              if(!provider.isSquare)
              Expanded(
                child: Opacity(
                  opacity: provider.isGenerating ? 0.5 : 1.0,
                  child: ByButton.textButton(
                      titleColor: Colors.black,
                      title: 'Copy',
                      onPressed: () {
                        if(!provider.isGenerating){
                          ClipboardManager.clip(provider.content);
                        }
                      }),
                ),
              ),
              SizedBox(width: 12.w,),
              provider.currentChapter != provider.chapterNum - 1 ?
              Opacity(
                opacity: provider.isGenerating || (provider.chapterBean !=null && provider.chapterBean!.nextStage! <= 3) ? 0.5 : 1.0,
                child: SizedBox(
                  width: 48.w,
                  child: ByButton.buttonWidget(
                      padding: EdgeInsets.all(6.w),
                      child: Transform.rotate(
                        angle: pi,
                        child: Image.asset('assets/home/novel/btn_novel_next.png')),
                      backgroundColor: ByColor.color2E3038,
                      onPressed: () {
                        provider.toggleChapter(true);
                      }),
                ),
              ) :
              Opacity(
                opacity: provider.isGenerating ? 0.5 : 1.0,
                child: SizedBox(
                  width: 88,
                  child: ByButton.textButton(
                      titleColor: ByColor.colorC1,
                      title: 'End',
                      backgroundColor: ByColor.color2E3038,
                      onPressed: () {
                        Toast.showText(text: 'Already the last chapter~');
                      }),
                ),
              ),
              
            ],
          ),
        ),
      );
  }
}
