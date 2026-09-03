
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:novel_oversea/core/service/email_service.dart';
import 'package:novel_oversea/core/ui/dialog/by_dialog_util.dart';
import 'package:novel_oversea/core/ui/widget/by_text.dart';
import 'package:novel_oversea/core/util/clipboard.dart';
import 'package:novel_oversea/core/util/extentions.dart';
import 'package:novel_oversea/global/login/controller/login_manager.dart';
import 'package:novel_oversea/global/routes/app_pages.dart';
import 'package:novel_oversea/global/ui/colors.dart';
import 'package:novel_oversea/home/create/controller/novel_create_controller.dart';
import 'package:novel_oversea/me/main/controller/me_controller.dart';
import 'package:novel_oversea/me/user/user.dart';

import '../../../global/const/consts.dart';

class MePage extends GetView<MeController> {
  MePage({super.key});

  final userController = Get.find<UserController>();

  // 添加路由名称支持
  String? get routeName => '/profile';

  ///消息-设置按钮
  Widget _messageSetting() {
    return GestureDetector(
      onTap: () {
        FirebaseAnalytics.instance.logEvent(name: 'user_center_setting_click');
        Get.toNamed(Routes.setting);
      },
      child: SizedBox(
        width: 40,
        height: 40,
        child: Center(
          child: Image.asset('assets/me/me_setting_icon.png',
              width: 24, height: 24),
        ),
      ),
    );
  }

  ///用户头像
  Widget _userAvatar() {
    return Obx(
      () => Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        child: Column(
          children: [
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () {
                if (controller.userInfo!.isFormal == 0) {
                  LoginManager.login(source: 'profile');
                }
              },
              child: SizedBox(
                width: 100.w,
                height: 112.w,
                child: Stack(
                  children: [
                    Positioned(
                      left: 2.w,
                      top: 14.w,
                      right: 2.w,
                      bottom: 4.w,
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(44.w),
                          child: controller.userInfo?.avatar != null &&
                                    controller.userInfo!.avatar.isNotEmpty
                                ? CachedNetworkImage(
                                  fit: BoxFit.fill,
                                  imageUrl: controller.userInfo!.avatar)
                                : Image.asset(
                                  'assets/me/profile_bg_icon.png'),
                        ),
                    ),
                    if(controller.userInfo?.isVip == 1)
                    Image.asset('assets/me/icon_profile_${controller.getUserVipTypeString()}_avatar.png'),
                  ],
                )
              ),
            ),
            SizedBox(height: 12.w),
            GestureDetector(
              onTap: () {
                userController.checkPreLogin(source: 'profile');
              },
              child: Column(
                children: [
                  ByText.text(
                    text: controller.userInfo?.nickName ?? 'visitor',
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w500,
                    textColor: ByColor.colorF1,
                  ),
                  SizedBox(height: 6.w),
                  GestureDetector(
                    onTap: () {
                      ClipboardManager.clip('${controller.userInfo?.userId}');
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ByText.text(
                          text: 'id：${controller.userInfo?.userId ?? ''}',
                          fontSize: 13.sp,
                          textColor: ByColor.colorF2,
                        ),
                        SizedBox(width: 4.h),
                        Image.asset(
                          'assets/me/btn_profile_copy.png',
                          width: 12,
                          height: 12,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  ///主体内容
  Widget _mainContent() {
    return Obx(
      () => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Column(
          children: [
            if (controller.userInfo?.isVip == 0) _openVip(),
            if (controller.userInfo?.isVip == 1) _openVipAlready(),
            const SizedBox(height: 4),
            _myCreation(),
            _infoList(),
          ],
        ),
      ),
    );
  }

  ///开通会员
  Widget _openVip() {
    return Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: GestureDetector(
              onTap: () {
                FirebaseAnalytics.instance.logEvent(name: 'user_center_sub_click');
                userController.checkPreLogin(
                    source: 'profile',
                    actionCallback: () {
                      userController.jumpToPayPage(source: 'profile');
                    });
              },
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: 88,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                          fit: BoxFit.fill,
                          image: AssetImage(
                              'assets/me/icon_profile_monthly_bg.png')),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    // height: 88,
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ByText.text(
                              fontSize: 17.sp,
                              text: 'Upgrade to Premium',
                            ),
                            const SizedBox(height: 4),
                            ByText.text(
                              text: 'Get more information about write',
                              fontSize: 12.sp,
                              textColor: ByColor.colorF1.withAlphaValue(0.6),
                            ),
                          ],
                        ),
                        Container(
                          height: 34,
                          padding: EdgeInsets.symmetric(horizontal: 12.w),
                          decoration: BoxDecoration(
                            color: Color(0xFF27EEFB),
                            borderRadius: BorderRadius.circular(44),
                          ),
                          child: Center(
                            child: ByText.text(
                              text: 'Go Premium',
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                              textColor: ByColor.colorF8,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
    );
  }

  ///已开通会员
  Widget _openVipAlready() {
    final String type = controller.getUserVipTypeString();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 8),
      child: GestureDetector(
        onTap: () {
          FirebaseAnalytics.instance.logEvent(name: 'user_center_sub_click');
          userController.checkPreLogin(actionCallback: () {
            userController.jumpToPayPage();
          });
          // SystemDialog dialog = SystemDialog();
          // dialog.show(
          //   Get.context!,
          //   child: SystemPopupDialog(close: dialog.dismiss,)
          // );
        },
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              height: 80,
              padding: const EdgeInsets.only(left: 16),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                    'assets/me/icon_profile_${type}_bg.png'
                  ),
                  fit: BoxFit.fill,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Image.asset(
                    'assets/me/icon_profile_${type}_title.png',
                    width: 48,
                    height: 48,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(width: 6,),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ByText.text(
                        text: '${controller.userInfo?.vipLevelName}',
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w700,
                        textColor: type == 'monthly' ? Color(0xFF8AE5EB) : type == 'year' ? Color(0xFFF0AAAB) : Color(0xFFFEF4D8)
                      ),
                      ByText.text(
                        text: 'Credits ${controller.getUserWords()}${controller.userInfo?.isVip == 0 ? ' (Insufficient)' : ''}',
                        fontSize: 12.sp,
                        textColor: type == 'monthly' ? Color(0xFF8AE5EB).withAlphaValue(0.6) : 
                                    type == 'year' ? Color(0xFFF0AAAB).withAlphaValue(0.6) : Color(0xFFFEF4D8).withAlphaValue(0.6)
                      ),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    height: 34.w,
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(
                          'assets/me/icon_profile_${type}_info.png',
                        ),
                      ),
                    ),
                    child: Center(
                            child: ByText.text(
                              text: 'Get More',
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                              textColor: type == 'monthly' ? ByColor.colorF8 : ByColor.colorF1,
                            ),
                          ),
                  ),
                  const SizedBox(width: 12,),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  ///创作记录
  Widget _creationRecord(
    String title,
    int number,
    CreationType type, {
    String? routeName = Routes.record,
  }) {
    return Expanded(
      child: InkResponse(
        onTap: () {
          userController.checkPreLogin(
            source: 'profile',
            actionCallback: () {
              FirebaseAnalytics.instance.logEvent(name: 'user_center_${type == CreationType.longNovel ? 'book' : 'story'}_click');
              Get.toNamed(routeName!, arguments: {'type': type})?.then((_) {
                ///刷新创作记录
                controller.getNovelCreateCount();
              });
            },
          );
        },
        child: Container(
          decoration: BoxDecoration(
            image: const DecorationImage(
              fit: BoxFit.fill,
              image: AssetImage('assets/me/icon_profile_record_bg.png'),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlphaValue(0.3), // 阴影颜色（带透明度）
                spreadRadius: 5, // 阴影扩散半径
                blurRadius: 10, // 阴影模糊半径
                offset: const Offset(0, -6), // 阴影偏移量（x: 水平偏移, y: 垂直偏移）
              ),
            ],
          ),
          child: Row(
            children: [
              const SizedBox(width: 16,),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ByText.text(
                    text: '$number',
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                    textColor: ByColor.colorF1,
                  ),
                  SizedBox(height: 4.w),
                  ByText.text(
                    text: title,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    textColor: ByColor.colorF1,
                  ),
                ],
              ),

              const Spacer(),
              SizedBox(
                width: 58.w,
                height: 58.w,
                child: Image.asset('assets/me/icon_me_${type == CreationType.longNovel ? 'book' : 'story'}.png')),
              const SizedBox(width: 12,),
            ],
          ),
        ),
      ),
    );
  }

  ///我的创作
  Widget _myCreation() {
    return Obx(
      () => SizedBox(
        height: 74.w,
        child: Row(
          children: [
            _creationRecord(
              'Stories',
              controller.recordBean.value?.shortNovel ?? 0,
              CreationType.shortNovel,
              routeName: Routes.novelRecord,
            ),
            const SizedBox(width: 12),
            _creationRecord(
              'Books',
              controller.recordBean.value?.longNovel ?? 0,
              CreationType.longNovel,
              routeName: Routes.novelRecord,
            ),
          ],
        ),
      ),
    );
  }

  ///信息列表-item
  Widget _infoItem(String title, String image) {
    return GestureDetector(
      onTap: () async {
        if(title == 'Contact Us') {
          FirebaseAnalytics.instance.logEvent(name: 'user_center_contact_click');
          EmailService.launchEmail(failed: () {
            ByDialogUtil.showPopScopeDialog(
              context: Get.context!, 
              contents: 'You have no email client. Copy email ${Consts.supportEmail} address to clipboard? ',
              confirmBtnTitle: 'Copy',
              confirmCallback: () {
                ClipboardManager.clip(Consts.supportEmail);
              });
          });
        }
        else if(title == 'Credits Items List') {
          FirebaseAnalytics.instance.logEvent(name: 'user_center_item_click');
          Get.toNamed(Routes.creditsItemList);
        }
        // else if(title == 'Feedback') {
        //   Get.toNamed(Routes.feedback);
        // }
        // controller.getProtocolByTitle(title);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.only(top: 17, bottom: 17),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: ByColor.colorL1,
              width: 1,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Image.asset(image, width: 18, height: 18, fit: BoxFit.fill),
                const SizedBox(width: 6),
                ByText.text(
                  text: title,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  textColor: ByColor.colorF1,
                ),
              ],
            ),
            Image.asset('assets/me/profile_right-icon.png',
                width: 12, height: 12, fit: BoxFit.fill),
          ],
        ),
      ),
    );
  }

  ///信息列表
  Widget _infoList() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        children: [
          _infoItem('Credits Items List', 'assets/me/icon_me_credits.png'),
          _infoItem('Contact Us', 'assets/me/icon_me_contact.png'),
          // _infoItem('Feedback', 'assets/me/icon_me_contact.png'),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ByColor.colorBg1,
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: ClampingScrollPhysics(),
        ),
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 455,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/me/me_top_bg.png'),
                      fit: BoxFit.cover,
                      opacity: 0.6,
                    ),
                  ),
                ),
                SafeArea(
                  child: Column(
                    children: [
                      if(Platform.isAndroid)
                      SizedBox(height: 8.h),
                      Row(
                        children: [
                          Container(
                            height: 40.w,
                            margin: EdgeInsets.only(left: 16.w),
                            alignment: Alignment.centerLeft,
                            child: ByText.text(
                              text: "My Space",
                              fontSize: 28.sp,
                              fontWeight: FontWeight.bold,
                              textColor: ByColor.colorF1,
                            ),
                          ),
                          const Spacer(),
                          _messageSetting(),
                          SizedBox(width: 12.w,)
                        ],
                      ),
                      _userAvatar(),
                      const SizedBox(height: 24),
                      _mainContent(),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
