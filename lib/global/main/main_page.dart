/*
 * @Author: cold-x
 * @Date: 2025-05-28 14:45:37
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2025-11-14 16:11:45
 * @FilePath: /novel_oversea/lib/global/main/main_page.dart
 * @Description: 
 */

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:novel_oversea/core/ui/view/muti_status_view.dart';
import 'package:novel_oversea/global/main/main_controller.dart';
import 'package:novel_oversea/global/ui/colors.dart';
import 'package:stylish_bottom_bar/stylish_bottom_bar.dart';
import '../ui/assets.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with SingleTickerProviderStateMixin {
  final MainController controller = Get.put(MainController(), permanent: true);

  @override
  void initState() {
    super.initState();
  }

  BottomBarItem tabbarItem(
      {String? label, String? assets, String? selectedAssets}) {
    return BottomBarItem(
      selectedColor: ByColor.colorF1,
      // title: ByText.text(
      //   text: label ?? '',
      //   fontSize: 10.sp,
      //   fontWeight: FontWeight.w500,
      //   textColor: ByColor.colorF1,
      // ),
      title: Container(
        width: 6,
        height: 6,
        margin: EdgeInsets.only(top: 5),
        decoration: BoxDecoration(
          color: ByColor.colorF1,
          borderRadius: BorderRadius.circular(3),
        ),
      ),
      // title: Image.asset(selectedAssets!, width: 28, height: 28),
      icon: assets == null
          ? const SizedBox()
          : Image.asset(assets, width: 28, height: 28),
      selectedIcon: Image.asset(selectedAssets!, width: 28, height: 28),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _bodyView(context);
  }

  Widget _bodyView(BuildContext context) {
    return GetBuilder<MainController>(
      builder: (controller) {
        return Scaffold(
          extendBodyBehindAppBar: true,
          backgroundColor: ByColor.colorBg1,
          bottomNavigationBar: Obx(() => StylishBottomBar(
            items: [
              tabbarItem(
                label: 'Home'.tr,
                assets: Assets.tabHome,
                selectedAssets: Assets.tabHomeSelected,
              ),
              tabbarItem(
                label: 'Tutorial'.tr,
                assets: Assets.tabSquare,
                selectedAssets: Assets.tabSquareSelected,
              ),
              tabbarItem(
                label: 'Me'.tr,
                assets: Assets.tabProfile,
                selectedAssets: Assets.tabProfileSelected,
              ),
            ],
            // option: DotBarOptions(
            //   // inkEffect: true
            //   gradient: LinearGradient(
            //     colors: [AppTheme.primaryColor, AppTheme.primaryColor],
            //     begin: Alignment.topCenter,
            //     end: Alignment.bottomCenter,
            //   ),
            // ),
            
            option: AnimatedBarOptions(
              barAnimation: BarAnimation.fade,
              iconStyle: IconStyle.animated,
            ),
            hasNotch: true,
            currentIndex: controller.currentIndex.value,
            backgroundColor: ByColor.colorBg1,
            onTap: (index) {
              controller.tabChanged(index);
            },
          )),
          body: Obx(
            () => MultiStatusView(
              hasAppBar: false,
              currentStatus: controller.launchStatus.value,
              action: () {
                controller.fetchLaunchData();
              },
              child: Stack(
                children: [
                  ...controller.tabBarPages.map((e) {
                    return Obx(
                      () => Offstage(
                        offstage:
                            controller.currentIndex.value !=
                            controller.tabBarPages.indexOf(e),
                        child: e,
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
