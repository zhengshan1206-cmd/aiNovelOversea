/*
 * @Author: cold-x
 * @Date: 2025-06-16 16:00:40
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2025-10-20 09:46:15
 * @FilePath: /novel_oversea/lib/home/core/view/chapter_choose_view.dart
 * @Description: 章节选择页,用于章节选择生成和下载
 */

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:novel_oversea/core/ui/dialog/toast.dart';
import 'package:novel_oversea/core/ui/widget/by_text.dart';
import 'package:novel_oversea/core/util/extentions.dart';
import 'package:novel_oversea/global/ui/colors.dart';
import 'package:novel_oversea/home/core/controller/words_controller.dart';
import 'package:novel_oversea/home/core/view/bottom_view.dart';
import 'package:novel_oversea/me/user/user.dart';
import '../../../core/util/by_screen_utils.dart';

enum ChapterChooseType {
  ///下载
  download,

  ///一键成文
  generate,
}

class ChapterChooseView extends StatefulWidget {
  const ChapterChooseView({
    super.key,
    this.type = ChapterChooseType.generate,
    this.finishedNum = 0,
    required this.charpterNum,
    this.downloadSelected,
    this.startChapter = 0,
    this.endChapter = 0,
    this.chapterSelected});

  ///选择结果
  final void Function(int)? chapterSelected;
  ///类型
  final ChapterChooseType? type;
  ///完成数(章节)
  final int finishedNum;
  ///总章节数
  final int charpterNum;
  ///选择下载结果
  final void Function(List<int>)? downloadSelected;

  ///起始章节数
  final int? startChapter;

  ///结束章节数
  final int? endChapter;

  @override
  State<ChapterChooseView> createState() => _ChapterChooseViewState();
}

class _ChapterChooseViewState extends State<ChapterChooseView> {

  ///每个大纲的章节数
  int chaptersPerOutline = 36;

  ///大纲标题
  List<String> outlines = [];

  ///当前选择的章节数
  int _currentSelectedChapter = 0;

  ///当前选择的大纲
  int _outlineIndex = 0;

  ///是否全选
  bool selectAll = false;

  ///选择的章节index
  List<int> selectedIndexes = [];


  @override
  void initState() {
    super.initState();
    int outlineNum = (widget.charpterNum/36).ceil();
    ///细纲生成列表时只显示当前大纲的细纲选择页
    if (widget.type == ChapterChooseType.generate) {
      _outlineIndex = outlineNum - 1;
    }
    for (int i = 0; i < outlineNum; i++){
      ///大纲的起始章节
      int startChapter = chaptersPerOutline * i + 1;
      ///大纲的结束章节，如果大于总章节数，则为总章节数
      int endChapter = chaptersPerOutline * (i + 1);
      if(endChapter > widget.charpterNum){
        endChapter = widget.charpterNum;
      }
      outlines.add('$startChapter-$endChapter');
    }
  }


  @override
  Widget build(BuildContext context) {
    double height = 580.w + ByScreenUtils.bottomSafeHeight;
    if (widget.type == ChapterChooseType.generate){
      height -= 44.w;
    }
    return SizedBox(
      height: height,
      child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          color: ByColor.colorBg1,
          child: widget.type == ChapterChooseType.download ? _buildDownloadBody() : _buildChapterBody()),
    );
  }

  ///章节时的组件布局
  Widget _buildChapterBody() {
    WordsController words = Get.find<WordsController>();
    return Column(
      // mainAxisSize: MainAxisSize.min,
      children: [
        _buildTopView(),
        _buildChapterView(),
        SizedBox(height: 15.w,),
        _buildSelectAllView(),
        SizedBox(height: 4.w,),
        BottomView(
          words: words.getWords(WordsType.chapter, _currentSelectedChapter - widget.finishedNum),
          nextBtnText: 'Generating Novel',
          padding: 0,
          nextStep: (){
            if (_currentSelectedChapter > 0){
              ///字数不够
              if(!words.isWordsEnable(WordsType.chapter, _currentSelectedChapter - widget.finishedNum)){
                Get.find<UserController>().jumpToPayPage(source: 'chapter_choose_words_unable');
              }
              else {
                Get.back();
                widget.chapterSelected?.call(_currentSelectedChapter);
              }
            }
            else{
              Toast.showText(text: 'You mush choose at least one chapter');
            }
          },
        ),
      ],
    );
  }

  ///下载时的组件布局
  Widget _buildDownloadBody() {
    return Column(
      // mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTopView(),
        ///显示大纲
        _buildOutlineView(),
        SizedBox(height: 20.w,),
        _buildChapterView(),
        SizedBox(height: 15.w,),
        _buildSelectAllView(),
        SizedBox(height: 5.w,),
        BottomView(
          showWords: false,
          nextBtnText: 'Download',
          padding: 0,
          nextStep: (){
            if (selectedIndexes.isNotEmpty){
              Get.back();
              widget.downloadSelected?.call(selectedIndexes);
            }
            else{
              Toast.showText(text: 'You mush choose at least one chapter');
            }
          },
        ),
      ],
    );
  }

  ///顶部组件
  Widget _buildTopView() {
    return SizedBox(
      height: 56.w,
      child: Row(
        children: [
          ByText.text(
              fontSize: 17,
              textColor: Colors.white,
              fontWeight: FontWeight.w500,
              text: widget.type == ChapterChooseType.download ? 'Choose Download Chapters' : 'Choose Chapters'),
          const Spacer(),
          GestureDetector(
            onTap: () => Get.back(),
            child: Image.asset(
              'assets/global/common/btn_close.png',
              width: 30,
              height: 30,
            ),
          )
        ],
      ),
    );
  }

  ///大纲选择组件
  Widget _buildOutlineView() {
    return SizedBox(
      height: 44.w,
      child: ListView.separated(
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          itemCount: outlines.length,
          separatorBuilder: (context, index) {
            return const SizedBox(
              width: 10,
            );
          },
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                if(_outlineIndex != index){
                  setState(() {
                    _outlineIndex = index;
                  });
                }
              },
              child: Container(
                height: 44.w,
                padding: EdgeInsets.symmetric(horizontal: 15.w),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: ByColor.color2E3038,
                    border: _outlineIndex == index ? Border.all(
                      width: 1,
                      color:ByColor.colorC1,
                    ) : null
                ),
                child: Center(
                  child: ByText.text(
                      textColor: _outlineIndex == index ? ByColor.colorC1 : ByColor.colorF1,
                      text: outlines[index]),
                ),
              ),
            );
          }),
    );
  }

  ///章节选择组件
  Widget _buildChapterView() {
    ///计算章节高度
    final height = (ByScreenUtils.screenWidth - 2 * 12.w - 5 * 17.w)/6;
    final gridHeight = height * 6 + 5 * 16.w;

    ///计算最后一个大纲的章节数
    int lastOutlineChapters = widget.charpterNum%chaptersPerOutline;
    if (lastOutlineChapters == 0){
      lastOutlineChapters = chaptersPerOutline;
    }
    return SizedBox(
      height: gridHeight,
      child: GridView.count(
        crossAxisCount: 6, // 每行标签个数
        crossAxisSpacing: 17.w, // 水平间距
        mainAxisSpacing: 16.w, // 垂直间距
        physics: const NeverScrollableScrollPhysics(),
        children: List.generate(widget.type == ChapterChooseType.generate ? widget.endChapter! - widget.startChapter! + 1 : _outlineIndex == outlines.length - 1 ? lastOutlineChapters : chaptersPerOutline, (index) {
          ///章节
          int chapter = _outlineIndex * chaptersPerOutline + index + 1;
          if(widget.type == ChapterChooseType.generate) {
            chapter = widget.startChapter! + index;
          }
          ///完成的章节
          int finishChapterNum = widget.finishedNum;
          return GestureDetector(
            onTap: () {
              if(widget.type == ChapterChooseType.generate){
                ///选择的章节
                if (chapter != _currentSelectedChapter && chapter > finishChapterNum) {
                  setState(() {
                    _currentSelectedChapter = chapter;
                    if(_currentSelectedChapter == widget.charpterNum) {
                      selectAll = true;
                    }
                    else {
                      selectAll = false;
                    }
                  });
                }
              }
              else {
                ///移除
                if(selectedIndexes.contains(chapter)) {
                  setState(() {
                    selectedIndexes.remove(chapter);
                    selectAll = false;
                  });
                }
                ///添加
                else {
                  setState(() {
                    selectedIndexes.add(chapter);
                    if(selectedIndexes.length == widget.charpterNum) {
                      selectAll = true;
                    }
                  });
                }
              }

            },
            child: Stack(
              children: [
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                        color: chapter <= finishChapterNum ? ByColor.colorC1.withAlphaValue(0.1) : ByColor.color2E3038,
                        borderRadius: BorderRadius.circular(8),
                        border: isSelected(chapter, finishChapterNum)
                            ? Border.all(
                          color: ByColor.colorC1,
                          width: 1,
                          style: BorderStyle.solid,
                        )
                            : null),
                    child: Center(
                      child: ByText.text(
                          text: '$chapter',
                          textColor: isSelected(chapter, finishChapterNum)
                              ? ByColor.colorC1
                              : ByColor.colorF1.withAlphaValue(0.5),
                          fontSize: 13),
                    ),
                  ),
                ),
                ///完成的章节
                if(chapter <= finishChapterNum)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Image.asset(
                      'assets/home/novel/icon_novel_chapter_finished.png',
                      width: 16.w,
                      height: 16.w,
                    ),
                  )
              ],
            ),
          );
        }
        ),
      ),
    );
  }

  ///是否在当前选择列表中
  bool isSelected(int chapter, int finishCharpter) {
    if(widget.type == ChapterChooseType.generate){
      return chapter <= _currentSelectedChapter && chapter > finishCharpter;
    }
    else {
      return selectedIndexes.contains(chapter);
    }
  }

  ///底部全选下载按钮
  Widget _buildSelectAllView() {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectAll = !selectAll;
          if(widget.type == ChapterChooseType.generate){
            _currentSelectedChapter = selectAll ? widget.charpterNum : 0;
          }
          else {
            selectedIndexes = selectAll ? List.generate(widget.charpterNum, (int index) => index + 1, growable: true) : [];
          }

        });
      },
      child: SizedBox(
        height: 20.w,
        child: Opacity(
          opacity: selectAll ? 1.0 : 0.5,
          child: Row(
            children: [
              Image.asset(
                'assets/global/common/btn_checkbox_${selectAll ? 'white' : 'normal'}.png',
                width: 14.w,
                height: 14.w,
              ),
              SizedBox(width: 4.w,),
              ByText.text(
                textColor: ByColor.colorF1,
                text: selectAll ? 'Selected' : 'Select All',),
            ],
          ),
        ),
      ),
    );
  }
}
