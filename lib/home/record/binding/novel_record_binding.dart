/*
 * @Author: cold-x
 * @Date: 2025-06-26 11:09:13
 * @LastEditors: cold-x 474647591@qq.com
 * @LastEditTime: 2025-07-07 13:42:03
 * @FilePath: /fastcreationmaster/lib/home/long_novel/binding/novel_record_binding.dart
 * @Description: 
 */


import 'package:get/get.dart';
import 'package:novel_oversea/home/create/controller/novel_create_controller.dart';
import 'package:novel_oversea/home/record/controller/novel_record_controller.dart';

class NovelRecordBinding extends Bindings {
  @override
  void dependencies() {
    final args = Get.arguments as Map<String, dynamic>?;
    final type = args?['type'];
    Get.lazyPut<NovelRecordController>(
      () => NovelRecordController(type: type ?? CreationType.longNovel),
    );
  }
}