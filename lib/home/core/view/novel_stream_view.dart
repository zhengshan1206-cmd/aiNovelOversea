


import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:novel_oversea/core/ui/widget/by_text.dart';
import 'package:novel_oversea/core/util/clipboard.dart';
import 'package:novel_oversea/core/util/extentions.dart'; 
import '../../../global/ui/colors.dart';

class NovelStreamView extends StatelessWidget {
  const NovelStreamView({
    super.key,
    this.title = '',
    this.content = '',
    this.isGeneratingNext = false,
    this.isMarkdown = true,
    this.controller,
    this.showBg = false,
    this.showTitle = true,
    this.isStreaming = true});

  ///标题
  final String? title; 
  ///内容
  final String? content; 
  ///是否正在流式输出
  final bool? isStreaming;
  ///是否需要markdown格式
  final bool? isMarkdown;
  ///是否正在生成下一部分内容
  final bool? isGeneratingNext;
  ///是否显示背景图
  final bool? showBg;
  ///是否显示标题
  final bool? showTitle;

  final ScrollController? controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.w),
          image: showBg! ? const DecorationImage(
            alignment: Alignment.topCenter,
            image: AssetImage('assets/home/novel/icon_novel_content_bg.png')) : null,
          color: ByColor.colorBg2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ///标题和字数
          if(showTitle!)
          Row(
              children: [
                Container(
                  constraints: BoxConstraints(
                    maxWidth: 220.w
                  ),
                  child: ByText.text(
                      fontSize: 16.sp,
                      textColor: ByColor.colorF1,
                      text: title!),
                ),
                const Spacer(),
                ByText.text(
                    textColor: ByColor.colorF2, text: '${content!.length} characters'),
              ],
            ),
          if(showTitle!)
          SizedBox(
            height: 12.w,
          ),
          showTitle! ? Expanded(
            child: !isMarkdown! && !isStreaming! ? SelectableText(
                      content!,
                      key: UniqueKey(), ///SelectableText不支持选择重置，必须重新绘制
                      maxLines: 9999,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: ByColor.colorF2,
                      ),
                    ) : SingleChildScrollView(
              controller: controller,
              child: _buildMarkDownView()),
          ) : _buildMarkDownView(),
        ],
      ),
    );
  }

  ///创建markdown
  Widget _buildMarkDownView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        //生成内容
        if (content!.isNotEmpty)
          isMarkdown!
              ? Markdown(
                  padding: EdgeInsets.symmetric(vertical: 12.w),
                  physics: const NeverScrollableScrollPhysics(),
                  selectable: true,
                  styleSheet: MarkdownStyleManager.createNightModeStyle(),
                  shrinkWrap: true,
                  data: content!,
                  // builders: {
                  //   'p': CustomParagraphBuilder(),
                  //   'h3': CustomParagraphBuilder(),
                  //   'h4': CustomParagraphBuilder(),
                  //   'blockquote': CustomParagraphBuilder(),
                  //   'listBullet': CustomParagraphBuilder(),
                  // },
                )
              : ByText.text(
                  maxLines: 9999,
                  fontSize: 14.sp,
                  textColor: ByColor.colorF2,
                  text: content!),

        if (content!.isNotEmpty)
          SizedBox(
            height: 12.w,
          ),
        if (content!.isEmpty)
          ///加载提示框
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.w),
              color: const Color(0xFFD7F97D).withAlphaValue(0.1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CupertinoActivityIndicator(
                  color: ByColor.colorC1,
                  radius: 6,
                ),
                SizedBox(
                  width: 4.w,
                ),
                ByText.text(
                    fontSize: 14.sp,
                    textColor: ByColor.colorC1,
                    text: 'AI is creating....'),
              ],
            ),
          ),
        if (isGeneratingNext!)
          SizedBox(
            height: 12.w,
          ),
        if (isGeneratingNext!)

          ///下一章内容准备提示框
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.w),
              color: const Color(0xFFD7F97D).withAlphaValue(0.1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CupertinoActivityIndicator(
                  color: ByColor.colorC1,
                  radius: 6,
                ),
                SizedBox(
                  width: 4.w,
                ),
                ByText.text(
                    fontSize: 14.sp,
                    textColor: ByColor.colorC1,
                    text: 'Preparing next chapter...'),
              ],
            ),
          ),
        // if (!isStreaming!)
        //   SizedBox(
        //     height: 10.w,
        //   ),
        // if (!isStreaming! && content!.isNotEmpty)
        //   Row(
        //     mainAxisAlignment: MainAxisAlignment.center,
        //     children: [
        //       Image.asset(
        //         'assets/global/common/icon_novel_warning_gray.png',
        //         width: 12.w,
        //         height: 12.w,
        //       ),
        //       SizedBox(
        //         width: 6.w,
        //       ),
        //       ByText.text(
        //           textColor: ByColor.colorF2,
        //           text: '内容由AI生成，禁止利用功能从事违法活动。'),
        //     ],
        //   ),
      ],
    );
  }
}

class MarkdownStyleManager {
  // 微信读书深夜模式样式
  static MarkdownStyleSheet createNightModeStyle() {
    return MarkdownStyleSheet(
      // 普通文本样式
      p: const TextStyle(
        color: ByColor.colorF2, // 浅灰色文本
        fontSize: 14.0,
      ),
      
      // 标题样式
      h1: const TextStyle(
        color: Color(0xFFFFFFFF), // 白色标题
        fontSize: 18.0,
        fontWeight: FontWeight.bold,
      ),
      h2: const TextStyle(
        color: Color(0xFFFFFFFF),
        fontSize: 18.0,
        fontWeight: FontWeight.bold,
      ),
      h3: const TextStyle(
        color: ByColor.colorF1,
        fontSize: 16.0,
        fontWeight: FontWeight.bold,
      ),
      h4: const TextStyle(
        color: ByColor.colorF1,
        fontSize: 16.0,
        fontWeight: FontWeight.bold,
      ),
      
      strong: const TextStyle(
        color: ByColor.colorF1,
        fontWeight: FontWeight.bold,
        fontSize: 14.0),

      a: const TextStyle(
          color: ByColor.colorF1,
          decoration: TextDecoration.underline),
      
      em: const TextStyle(
          color: ByColor.colorC1,
          decoration: TextDecoration.underline),
      
      // 列表样式
      listBullet: const TextStyle(
        color: Color(0xFF8A8A8E),
      ),
      
      // 代码块样式
      code: const TextStyle(
        color: Color(0xFFD0D0D0),
        backgroundColor: Color(0xFF2C2C2E),
        fontSize: 14.0,
      ),
      codeblockDecoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(4.0),
      ),
      
      // 引用样式
      blockquote: const TextStyle(
        color: Color(0xFF8A8A8E),
        fontStyle: FontStyle.italic,
      ),
      
      // 表格样式
      tableHead: const TextStyle(
        color: Color(0xFFFFFFFF),
        fontWeight: FontWeight.bold,
      ),
      tableBody: const TextStyle(
        color: Color(0xFFBBBBBB),
      ),
      tableBorder: TableBorder.all(
        color: const Color(0xFF3A3A3C),
        width: 0.5,
      ),
    );
  }
}


// 1. 创建自定义段落 Builder
class CustomParagraphBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitText(md.Text text, TextStyle? preferredStyle) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 0.0), // 上下间距
        child: _buildSelectableText(text.text, Text(text.text, style: preferredStyle),
        style: preferredStyle
        ));
  }

  // 构建可选择的文本组件
  Widget _buildSelectableText(
    String text,
    Widget child, {
    TextStyle? style,
  }) {
    // 提取文本内容（处理嵌套结构）
    if (text.isEmpty) return child;

    return SelectableText.rich(
      TextSpan(
        text: text,
        style: style,
      ),
      // 自定义上下文菜单（添加复制选项）
      contextMenuBuilder: (context, editableTextState) {
        return AdaptiveTextSelectionToolbar(
          anchors: editableTextState.contextMenuAnchors,
          children: [
            TextSelectionToolbarTextButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                // 复制选中的文本到剪贴板
                final selectedText = editableTextState.textEditingValue.selection.textInside(
                  editableTextState.textEditingValue.text,
                );
                ClipboardManager.clip(selectedText);
                // 显示提示（可选）
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Copied to the clipboard')),
                );
              },
              child: const Text('Copy'),
            ),
          ],
        );
      },
    );
  }
}
