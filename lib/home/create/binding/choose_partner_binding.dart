/*
 * @Author: duncy
 * @Date: 2025-10-23 10:20:01
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2025-10-23 10:21:58
 * @FilePath: /novel_oversea/lib/home/create/binding/choose_partner_binding.dart
 * @Description: 
 */


import 'package:get/get.dart';
import 'package:novel_oversea/home/create/controller/create_category_controller.dart';

class ChoosePartnerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CreateCategoryController>(
      () => CreateCategoryController(),
    );
  }
}