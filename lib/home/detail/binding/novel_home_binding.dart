/*
 * @Author: cold-x
 * @Date: 2025-06-12 18:56:29
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2025-09-26 10:14:48
 * @FilePath: /novel_oversea/lib/home/detail/binding/novel_home_binding.dart
 * @Description: 
 */



import 'package:get/get.dart';
import 'package:novel_oversea/home/detail/controller/novel_home_controller.dart';
import 'package:novel_oversea/home/detail/controller/novel_manager_controller.dart';

class NovelHomeBinding extends Bindings {
  @override
  void dependencies() {
    // 获取传递的参数
    final args = Get.arguments as Map<String, dynamic>?;
    final id = args?['id'];
    final selected = args?['select'];
    Get.lazyPut<NovelHomeController>(
      () => NovelHomeController(novelID: id ?? 0, selectNovelType: selected),
    );

    Get.lazyPut<NovelManagerController>(
      () => NovelManagerController(),
    );
  }
}