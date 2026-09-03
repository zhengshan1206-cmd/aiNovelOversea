/*
 * @Author: cold-x
 * @Date: 2025-06-06 11:11:43
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2025-10-30 10:09:34
 * @FilePath: /novel_oversea/lib/home/record/page/base_record_page.dart
 * @Description: 
 */

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:novel_oversea/core/ui/page/base_page.dart';
import 'package:novel_oversea/core/ui/widget/by_text.dart';
import 'package:novel_oversea/global/const/const_utils.dart';
import 'package:novel_oversea/global/ui/colors.dart';
import 'package:novel_oversea/home/create/controller/novel_create_controller.dart';
import 'package:novel_oversea/home/record/controller/base_record_controller.dart';
import 'package:novel_oversea/me/user/user.dart';


// ignore: must_be_immutable
class BaseRecordPage extends BasePage {
  BaseRecordPage({
    super.key,
  });

  @override
  String get title => 'Record';

  final userController = Get.find<UserController>();

  @override
  BaseRecordController get controller => Get.find<BaseRecordController>();

  @override
  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: ByColor.colorBg1,
      leadingWidth: 100,
      toolbarHeight: ConstUtils.getNavigationHeight(),
      leading: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          ///如果是管理状态，点击取消管理，否则返回
          controller.isManaging.value
              ? controller.cancelManaging()
              : Get.back();
        },
        child: Obx(() =>  Container(
          padding: EdgeInsets.only(left: 12.w),
          alignment: Alignment.centerLeft,
          child: controller.isManaging.value
                    ? ByText.text(
                        bgColor: Colors.transparent,
                        textColor: ByColor.colorC1,
                        fontWeight: FontWeight.w500,
                        text: 'Cancel',
                      )
                    : Image.asset(
                        "assets/global/common/btn_back.png",
                        width: 16,
                        height: 16,
                      ),
              )),
      ),
      title: ByText.text(
          text: title,
          textColor: ByColor.colorF1,
          fontSize: 17.sp,
          fontWeight: FontWeight.w700),
      actions: [
        buildActions(context),
      ],
    );
  }

  @override
  Widget buildActions(BuildContext context) {
    return Obx(() {
      return ([CreationType.longNovel, CreationType.shortNovel]
                  .contains(controller.type) ||
              controller.recordList.isNotEmpty)
          ? GestureDetector(
              child: Container(
                padding: EdgeInsets.all(12.w),
                child: ByText.text(
                  bgColor: Colors.transparent,
                  textColor: ByColor.colorC1,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  text: controller.updateManagingText(),
                ),
              ),
              onTap: () {
                controller.updateManagingStatus();
              },
            )
          : Container();
    });
  }

  @override
  Widget buildBody(BuildContext context) {
    return Container();
  }
}
