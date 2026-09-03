/*
 * @Author: cold-x
 * @Date: 2025-06-17 19:01:51
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2025-09-25 15:05:02
 * @FilePath: /novel_oversea/lib/home/chapter/binding/novel_chapter_binding.dart
 * @Description: 
 */


import 'package:get/get.dart';
import 'package:novel_oversea/home/chapter/controller/novel_chapter_controller.dart';

class NovelChapterBinding extends Bindings {
  @override
  void dependencies() {
    final args = Get.arguments as Map<String, dynamic>?;
    final novelID = args?['novelID'];
    final outlineID = args?['outlineID'];
    Get.lazyPut<NovelChapterController>(
      () => NovelChapterController(novelID: novelID, outlineID: outlineID),
    );
  }
}