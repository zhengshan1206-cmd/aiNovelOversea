/*
 * @Author: cold-x
 * @Date: 2025-06-16 20:32:39
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2026-01-07 17:41:42
 * @FilePath: /novel_oversea/lib/home/create/binding/novel_create_binding.dart
 * @Description: 
 */


import 'package:get/get.dart';
import 'package:novel_oversea/home/create/controller/novel_create_controller.dart';
import 'package:novel_oversea/home/detail/controller/novel_home_controller.dart';

class NovelCreateBinding extends Bindings {
  @override
  void dependencies() {
    final args = Get.arguments as Map<String, dynamic>?;
    final params = args?['params'];
    final isGuide = args?['guide'] ?? false;
    var novelType = args?['novel_type'];
    Get.lazyPut<NovelCreateController>(
      () => NovelCreateController(
        writeArgs: params, 
        isGuide: isGuide,
        type: novelType ?? CreationType.longNovel, 
        isProfessional: true,
        source: NovelHomeSourceType.normal,),
    );
  }
}