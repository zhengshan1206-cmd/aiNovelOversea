/*
 * @Author: cold-x
 * @Date: 2025-06-12 15:40:13
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2025-10-22 11:56:07
 * @FilePath: /novel_oversea/lib/core/util/clipboard.dart
 * @Description: 
 */


import 'package:flutter/services.dart';
import 'package:novel_oversea/core/ui/dialog/toast.dart';

class ClipboardManager {
  static void clip(String? content) {
    Clipboard.setData(
      ClipboardData(
        text: content ?? '',
      ),
    );
    Toast.showText(text: "Copied to the clipboard");
  }
}