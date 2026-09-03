/*
 * @Author: cold-x
 * @Date: 2025-05-14 17:26:29
 * @LastEditors: cold-x 474647591@qq.com
 * @LastEditTime: 2025-05-14 17:29:41
 * @FilePath: /video_clip_edit/lib/v2/Me/AboutUs/bindings/abount_us_binding.dart
 * @Description: 
 */


import 'package:get/get.dart';
import 'package:novel_oversea/me/aboutus/controller/about_us_controller.dart';

class AboutUsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AboutUsController>(
      () => AboutUsController(),
    );
  }
}