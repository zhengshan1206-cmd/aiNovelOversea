/*
 * @Author: duncy
 * @Date: 2025-09-24 17:35:51
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2025-11-03 16:41:58
 * @FilePath: /novel_oversea/lib/home/create/view/chat_cell.dart
 * @Description: 
 */

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:novel_oversea/core/ui/widget/by_text.dart';
import 'package:novel_oversea/core/util/by_screen_utils.dart';
import 'package:novel_oversea/global/ui/colors.dart';
import 'package:novel_oversea/home/core/view/novel_stream_view.dart';


enum ChatCellType {
  ///自己发出的消息
  me, 
  ///他人的消息
  other,
}

class ChatCell extends StatelessWidget {
  const ChatCell({
    super.key, 
    this.text = '',
    this.url = '',
    required this.type,
  });
  ///聊天主体类型
  final ChatCellType type;
  ///文本
  final String? text;
  ///头像
  final String? url;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: ByScreenUtils.screenWidth),
      // padding: EdgeInsetsGeometry.symmetric(horizontal: 12.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        textDirection: type == ChatCellType.me
            ? TextDirection.rtl
            : TextDirection.ltr,
        children: [
          if (type == ChatCellType.other)
            SizedBox(
              width: 32.w,
              height: 32.w,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16.w),
                // child: Image.asset('assets/home/create/icon_chat_avatar.png'),
                child: Image.network(
                  url!,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset('assets/home/create/icon_chat_avatar.png');
                  },),
              ),
            ),
          // Expanded(
          //   child: BubbleSpecialOne(text: text!,
          //         isSender: type == ChatCellType.me,
          //         color: type == ChatCellType.me ? ByColor.colorC1 : ByColor.colorBg2,
          //         tail: true,
          //         textStyle: TextStyle(
          //           fontSize: 16.sp,
          //           color: type == ChatCellType.me ? ByColor.colorF8 : ByColor.colorF2
          //         ),
          //       ),
          // )
          type == ChatCellType.other
              ? Expanded(
                  child: Container(
                    margin: EdgeInsets.only(left: 10, right: 60),
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: ByColor.colorBg2,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Markdown(
                      padding: EdgeInsets.zero,
                      physics: const NeverScrollableScrollPhysics(),
                      selectable: true,
                      styleSheet: MarkdownStyleManager.createNightModeStyle(),
                      shrinkWrap: true,
                      data: text!,
                    ),
                  ),
                )
              : Container(
                  constraints: BoxConstraints(
                    maxWidth: ByScreenUtils.screenWidth - 70,
                  ),
                  margin: EdgeInsets.only(left: 60, right: 10),
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: ByColor.colorC1,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ByText.text(
                    maxLines: 9999,
                    fontSize: 14.sp,
                    textColor: ByColor.colorF8,
                    text: text!,
                  ),
                ),
        ],
      ),
    );
  }
}