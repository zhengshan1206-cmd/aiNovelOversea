


import 'dart:async';
import 'dart:math';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:novel_oversea/core/service/app_permisson/byhy_permission_utils.dart';
import 'package:novel_oversea/core/ui/dialog/by_dialog_util.dart';
import 'package:novel_oversea/core/ui/view/muti_status_view.dart';
import 'package:novel_oversea/core/ui/view/progress_bar.dart';
import 'package:novel_oversea/core/ui/widget/by_text.dart';
import 'package:novel_oversea/core/util/by_screen_utils.dart';
import 'package:novel_oversea/core/util/extentions.dart';
import 'package:novel_oversea/global/launch/controller/launch_controller.dart';
import 'package:novel_oversea/global/launch/controller/launch_manager.dart';
import 'package:novel_oversea/global/ui/colors.dart';
import 'package:novel_oversea/home/core/view/bottom_view.dart';
import 'package:novel_oversea/me/user/user.dart';

import '../../../core/cache/byhy_aes_storage_utils.dart';
import '../../const/const_string.dart';
import '../../routes/app_pages.dart';


class LaunchPage extends StatefulWidget {
  const LaunchPage({
    super.key,
  });

  @override
  State<LaunchPage> createState() => _LaunchPageState();
}

class _LaunchPageState extends State<LaunchPage> {

  final controller = Get.put(LaunchController(), permanent: true);
  final userController = Get.put(UserController(), permanent: true);

  ///网络连接状态监听
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  @override
  void initState() {
    super.initState();
    if(controller.needNetworkAuth()) {
      _startListening();
    }
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        controller.checkAgreement();
      }
    );
  }

  // 初始化监听
  void _startListening() {
    _subscription = _connectivity.onConnectivityChanged.listen((result) {
      _handleConnectivityChange(result);
    });
  }

  // 处理网络变化
  void _handleConnectivityChange(List<ConnectivityResult> result) {
    if (!result.contains(ConnectivityResult.none)) {
      controller.hasNetwork = true;
      controller.appLaunch();
    } else {
      // 恢复在线功能
      controller.hasNetwork = false;
      controller.payData.statusType.value = MultiStatusType.statusContent;
    }
  }

  @override
  void dispose() {
    super.dispose();
    _subscription?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: Container(
          width: width,
          height: height,
          alignment: Alignment.center,
          decoration: const BoxDecoration(color: Colors.white),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                child: Image.asset(
                  "assets/global/launch/launch_bg.png",
                  fit: BoxFit.cover,
                ),
              ),

              /// 文字
              Positioned(
                left: 0,
                right: 0,
                top: 414.h,
                child: SizedBox(
                height: 55.w,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                      ByText.text(
                        text: 'Trusted By',
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w500),
                      Obx(() =>  ByText.text(
                        text: '${NumberFormat.decimalPattern('en_US').format(controller.timerCount.value * 10000/2.5)}+ Writers',
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w500)),
                    ]
                ),
              )),

              /// 五星
              Positioned(
                left: 0,
                right: 0,
                top: 479.h,
                child: SizedBox(
                height: 28.w,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: 
                    List.generate(5, (index) {
                      return Obx(() => Offstage(
                        offstage: index > controller.starCount.value,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 2.5.w),
                          child: Image.asset(
                            'assets/global/launch/icon_launch_star.png',
                            width: 28.w,
                            height: 28.w,),
                        ),
                      ));
                    }),
                ),
              )),
              
              /// 两边叶子
              Positioned(
                left: 87.w,
                top: 420.h,
                child: Obx(() => LeafView(timerCount: controller.timerCount.value))
              ),
              Positioned(
                right: 87.w - 28.w,
                top: 420.h,
                child: Transform(
                  transform: Matrix4.rotationY(pi),
                  child: Obx(() => LeafView(timerCount: controller.timerCount.value)))
              ),
              /// 底部按钮
              Positioned(
                bottom: 73.w + ByScreenUtils.bottomSafeHeight,
                child: Column(
                  children: [
                    Obx(() => ByText.text(
                      text: controller.starCount.value >= 5 ? "Write your first bestseller." : 'Create AI art effortlessly, right from your pocket.',
                      fontSize: 13.sp,
                      textColor: ByColor.colorF2,
                    )),
                    SizedBox(height: 12.w,),
                    
                    Obx(() => Offstage(
                      offstage: controller.starCount.value >= 5,
                      child: SizedBox(
                        height: 6.w,
                        width: 303.w,
                        child: Obx(() => ProgressBar(
                          border: 3.w,
                          progress: min(controller.timerCount.value/250, 1.0),
                          trackColor: Color(0xFF343C48).withAlphaValue(0.4),
                          progressGradiantColor: LinearGradient(colors: [Color(0xFF27EEFB), Color(0xFFBADDFF)]),
                        ),
                      )),
                    )),
                    if(!controller.hasGuide())
                    Obx(() => Offstage(
                      offstage: controller.starCount.value < 5,
                      child: SizedBox(
                        height: 56.w,
                        width: width - 24.w,
                        child: Stack(
                          children: [
                            Obx(() => BottomView(
                                showWords: false,
                                isBottom: false,
                                margin: 0,
                                nextBtnText: controller.payData.statusType.value == MultiStatusType.statusContent ? 'Continue' : 'Retry',
                                // backgroundColor: Color(0xFF1780FF),
                                // arrowStyle: 1,
                                // titleColor: ByColor.colorF0,
                                nextStep: () {
                                  if(controller.payData.statusType.value == MultiStatusType.statusContent && controller.isLaunched.value) {
                                    ByStorageUtils.saveBool(ConstString.kLaunchGuideCheck, true);
                                    if(userController.isVip) {
                                      Get.offAllNamed(Routes.main);
                                      return;
                                    }
                                    FirebaseAnalytics.instance.logEvent(name: 'OB_sub_show');
                                    controller.gotoGuide();
                                  }
                                  else {
                                    if(controller.isLaunched.value) {
                                      GlobalController.instance.init();
                                    }
                                    else {
                                      if(controller.payData.statusType.value == MultiStatusType.statusNoNetWork) {
                                        ByDialogUtil.showPopScopeDialog(
                                          context: context,
                                          title: 'Network Error',
                                          contents: 'Unable to connect to the server due to a network issue.Please verify your connection or switch networks',
                                          confirmBtnTitle: 'Settings',
                                          confirmCallback: () {
                                            /// 更新设置
                                            ByPermissionUtils.openPermissionSettings();
                                          },
                                          cancelBtnTitle: 'Retry',
                                          cancelCallback: () {
                                            controller.payData.statusType.value = MultiStatusType.statusLoading;
                                            Future.delayed(Duration(seconds: 1),(){
                                              controller.appLaunch();
                                            });
                                          });
                                      }
                                      else {
                                        controller.payData.statusType.value = MultiStatusType.statusLoading;
                                            Future.delayed(Duration(seconds: 1),(){
                                              controller.appLaunch();
                                            });
                                      }
                                    }
                                  }
                                },
                              )),
                            Obx(() => controller.payData.statusType.value == MultiStatusType.statusLoading ? Container(
                              margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.w),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20.w),
                                color: ByColor.colorC1,
                              ),
                              child: Center(
                                child: CupertinoActivityIndicator(
                                  color: ByColor.colorF8,
                                ),
                              ),
                            ) : Container())
                          ],
                        ),
                      ),
                    )),
                  ],
                )),
                if(!controller.hasGuide())
                Obx(() => [MultiStatusType.statusNoNetWork, MultiStatusType.statusLoading].contains(controller.payData.statusType.value) && controller.starCount.value >= 5 ? Positioned(
                  bottom: 53.w + ByScreenUtils.bottomSafeHeight,
                  child: ByText.text(
                    fontSize: 12.sp,
                    textColor: controller.payData.statusType.value == MultiStatusType.statusNoNetWork ? ByColor.colorG4 : ByColor.colorF1,
                    text: controller.payData.statusType.value == MultiStatusType.statusNoNetWork ? 'Loading fail, please retry or check your network.' : 'Loading configuration, wait a moment...'),) : Container()),
            ],
          ),
        ),
      ),
    );
  }
}

class LeafView extends StatelessWidget {
  LeafView({super.key, required this.timerCount});

  final int timerCount;

  final List<int> positionX = [0, 7, 12, 15, 15, 12, 8,];
  final List<int> positionY = [0, 5, 12, 20, 28, 36, 43];
  final List<double> angles = [-pi/3, -pi/5, -pi/7, -pi/20, pi/15, pi/12, pi/6,];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 28.w,
      height: 48.w,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (int i in [0, 1, 2, 3, 4, 5, 6]) 
            Positioned(
              right: positionX[i].w,
              bottom: positionY[i].w,
              child: Offstage(
                offstage: (timerCount/10).round() < i,
                child: _doubleLeaf(angles[i]))),
          Positioned(
            right: 7.w,
            bottom: 48.w,
            child: Offstage(
              offstage: (timerCount/10).round() < 7,
              child: Transform.rotate(
                angle: pi/3,
                child: _singleLeaf()),
            )),
        ],
      ),
    );
  }

  /// 单片叶子
  Widget _singleLeaf() {
    return Image.asset(
      'assets/global/launch/icon_launch_leaf.png',
      width: 8.w,
      height: 8.w,
    );
  }

  /// 双叶
  Widget _doubleLeaf(double angle) {
    return Transform.rotate(
      angle: angle,
      child: Row(
        children: [
          Transform.rotate(
            angle: pi/2 + pi/8,
            child: _singleLeaf(),),
          Transform.rotate(
            angle: -pi/2 - pi/8,
            child: _singleLeaf(),),
        ],
      ),
    );
  }
}