
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:novel_oversea/core/ui/page/base_page.dart';
import 'package:novel_oversea/core/util/by_screen_utils.dart';
import 'package:novel_oversea/global/login/controller/login_manager.dart';
import 'package:novel_oversea/global/routes/app_pages.dart';
import 'package:novel_oversea/global/ui/colors.dart';
import 'package:novel_oversea/home/main/dialog/score_dialog.dart';

import 'package:novel_oversea/me/setup/controller/setup_controller.dart';
import 'package:novel_oversea/core/ui/widget/by_text.dart';
import 'package:novel_oversea/me/user/user_menu_bean.dart';


// ignore: must_be_immutable
class SetupPage extends BasePage {
  SetupPage({super.key});

  @override
  SetupController get controller => Get.find<SetupController>();

  @override
  String get title => "Settings";

  @override
  Widget buildBody(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
          child: Obx(
            () => Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  decoration: const BoxDecoration(
                    color: ByColor.colorBg2,
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  child: Column(
                    children: 
                      List.generate(controller.protocolList.length, (index) {
                        final UserMenusBean bean = controller.protocolList[index];
                        return _infoItem(bean.title, 'image');
                      }),
                      // _infoItem('User Agreement', 'assets/me/icon_setup_pact.png'),
                      // _infoItem(
                      //     'Privacy Policy', 'assets/me/icon_setup_privacy.png'),
                      // _infoItem(
                      //     'Member Service Agreement', 'assets/me/icon_setup_member.png'),
                  ),
                ),
                SizedBox(height: 4.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  decoration: const BoxDecoration(
                    color: ByColor.colorBg2,
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  child: Column(
                    children: [
                      _infoItem('Rating Us', 'assets/me/icon_setup_us.png'),
                      _infoItem('About Us', 'assets/me/icon_setup_us.png'),
                      if (controller.userInfo?.isFormal == 0)
                      _infoItem('Binding account', 'assets/me/icon_setup_us.png'),
                      if (controller.userInfo?.isFormal == 1)
                        _infoItem('Log Out Of Account', 'assets/me/icon_setup_logout.png'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Obx(() {
          return controller.userInfo?.isFormal == 1
              ? Positioned(
                  left: 0,
                  right: 0,
                  bottom: ByScreenUtils.bottomSafeHeight + 4.w,
                  child: GestureDetector(
                    onTap: () {
                      controller.showLogoutConfirm();
                    },
                    child: Container(
                      width: double.infinity,
                      color: ByColor.colorBg1,
                      padding:
                          EdgeInsets.symmetric(horizontal: 12.w),
                      child: Container(
                        height: 48.w,
                        decoration: BoxDecoration(
                          color: ByColor.colorB1,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Center(
                          child: ByText.text(
                            text: 'Log out',
                            fontSize: 17,
                            textColor: ByColor.colorG4,
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              : const SizedBox.shrink();
        }),
      ],
    );
  }

  ///信息列表-item
  Widget _infoItem(String title, String image) {
    return GestureDetector(
      onTap: () {
        if (title == 'Log Out Of Account') {
          controller.showDeleteAccountConfirm();
        } else if(title == 'About Us') {
          FirebaseAnalytics.instance.logEvent(name: 'setting_about_click');
          Get.toNamed(Routes.aboutUs);
        } else if(title == 'Rating Us') {
          FirebaseAnalytics.instance.logEvent(name: 'setting_rate_click');
          ScoreDialogManager.showScore(type: 1);
        } else if(title == 'Binding account') {
          FirebaseAnalytics.instance.logEvent(name: 'setting_binding_click');
          LoginManager.login(binding: true, source: 'setup');
        } else {
          FirebaseAnalytics.instance.logEvent(name: 'setting_${title.trim()}_click');
          controller.getProtocolByTitle(title);
        }
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
                // Image.asset(image, width: 18, height: 18, fit: BoxFit.fill),
                // const SizedBox(width: 6),
                ByText.text(
                  text: title,
                  fontSize: 14,
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
}
