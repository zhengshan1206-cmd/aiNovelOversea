/*
 * @Author: duncy
 * @Date: 2025-10-13 13:57:23
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2026-01-20 17:28:31
 * @FilePath: /novel_oversea/lib/global/pay/page/pay_center_page.dart
 * @Description: 
 */

import 'dart:io';
import 'dart:math';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:novel_oversea/core/ui/view/by_widgets_util.dart';
import 'package:novel_oversea/core/ui/view/muti_status_view.dart';
import 'package:novel_oversea/core/ui/widget/by_text.dart';
import 'package:novel_oversea/core/util/by_screen_utils.dart';
import 'package:novel_oversea/core/util/extentions.dart';
import 'package:novel_oversea/global/launch/controller/launch_controller.dart';
import 'package:novel_oversea/global/launch/controller/launch_manager.dart';
import 'package:novel_oversea/global/launch/page/guide_step_page.dart';
import 'package:novel_oversea/global/pay/controller/pay_controller.dart';
import 'package:novel_oversea/global/pay/bean/vip_type_bean.dart';
import 'package:novel_oversea/global/routes/app_pages.dart';
import 'package:novel_oversea/global/ui/colors.dart';
import 'package:novel_oversea/home/core/view/bottom_view.dart';
import 'package:shimmer/shimmer.dart';
import 'package:video_player/video_player.dart';


class PayCenterPage extends StatefulWidget {
  const PayCenterPage({super.key});

  @override
  State<PayCenterPage> createState() => _PayCenterPageState();
}

class _PayCenterPageState extends State<PayCenterPage> with TickerProviderStateMixin{
  PayController get controller => Get.find<PayController>();
  bool switchValue = true;
  late VideoPlayerController _videoController;
  late AnimationController _controller;
  int _pageIndex = 0;

  double _closeOpacity = 0.0;

  @override
  void initState() {
    _videoController = VideoPlayerController.asset(
      'assets/pay/pay_bg.mp4',  // 与 pubspec.yaml 配置一致
      // 可选配置：自动播放、循环、音量等
      videoPlayerOptions: VideoPlayerOptions(
        mixWithOthers: true, // 是否允许与其他音频混合播放
      ),
    );
    if(controller.styleManager.style != 2) {
      _videoController.initialize();
      _videoController.setLooping(true); // 循环播放
      _videoController.play();
    }
    super.initState();

    // 1. 初始化动画控制器：时长1秒完成一圈旋转
    _controller = AnimationController(
      vsync: this, // 绑定当前State的Ticker
      duration: const Duration(seconds: 10), // 旋转一圈的时间（越短转速越快）
    );
    // 2. 启动无限循环旋转（reverse: false 顺时针，true 逆时针）
    _controller.repeat(reverse: false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(Duration(seconds: 2), () {
        setState(() {
          _closeOpacity = 1.0;
        });
      });
    });
  }

  @override
  void dispose() {
    _videoController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: ByColor.colorBg1,
      body: buildBody(context),
    );
  }

  Widget buildBody(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Stack(
        children: [
          ///视频播放
          if(controller.styleManager.style != 2)
          AspectRatio(
            aspectRatio: 704/1248,
            child: VideoPlayer(_videoController)),
      
          if(controller.styleManager.style == 2)
          SizedBox(
            width: double.infinity,
            child: CarouselSlider(
                options: CarouselOptions(
                  height: 566.w,
                  viewportFraction: 1.0,
                  autoPlayInterval: Duration(seconds: 4),
                  autoPlay: true,
                  onPageChanged: (index, reason) {
                    setState(() {
                      _pageIndex = index;
                    });
                  },
                ),
                items: List.generate(2, (index) {
                  return Image.asset(
                    'assets/pay/icon_pay_bg__2_$index.png',
                    fit: BoxFit.fill,);
                }),
              ),
          ),
          
          
          ///上层渐变遮罩
          Positioned(
            top: 350.w,
            left: 0,
            right: 0,
            child: Container(
              height: 180.w,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: AlignmentGeometry.topCenter,
                  end: AlignmentGeometry.bottomCenter,
                  colors: [ByColor.colorBg1.withAlphaValue(0), ByColor.colorBg1. withAlphaValue(0.5), ByColor.colorBg1],
                  stops: [0, 0.5, 1]),
              ),
            ),
          ),
      
          ///下层遮罩
          Positioned(
            top: 530.w,
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(color: ByColor.colorBg1,)),
      
          Obx(() {
            final itemList = controller.getCurrentDataList();
            double height = 300.w;
            if(itemList.isNotEmpty) {
              ///横版
              if(controller.styleManager.type == 1) {
                height = 88.w * itemList.length;
              }
              else {
                height = 191.w;
              }
            }
            if(controller.showTrial()) {
              height = 144.w;
            }
            if(controller.styleManager.type == 1 && controller.styleManager.style == 1) {
              return Positioned(
                top: 120.w,
                bottom: 140.w + height + ByScreenUtils.bottomSafeHeight,
                child: Container(
                  alignment: Alignment.bottomCenter,
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(
                          width: 355.w,
                          child: ByText.text(
                            text: "Write your next bestseller.",
                            fontSize: 20.sp,
                            maxLines: 2,
                            textAlign: TextAlign.left,
                            textColor: ByColor.colorF1,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        for (var tip in controller.guideTips)
                          Container(
                            width: 351.w,
                            margin: EdgeInsets.only(bottom: 4.h),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Image.asset(
                                  'assets/pay/icon_pay_crown.png',
                                  width: 16.w,
                                  height: 16.w,
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  constraints: BoxConstraints(maxWidth: 322.w),
                                  child: ByText.text(
                                    text: tip,
                                    maxLines: 2,
                                    textColor: ByColor.colorF2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }
            ///中部说明图片
            return Positioned(
              bottom: 140.w + height + ByScreenUtils.bottomSafeHeight,
              left: 0,
              right: 0,
              child: Container(
                margin: EdgeInsets.only(bottom: 12.w),
                child: Column(
                  children: [
                    if(controller.styleManager.style == 2)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: _pageIndex == 0 ? 20.w : 12.w,
                          height: 2.w,
                          decoration: BoxDecoration(
                            color: _pageIndex == 0 ? Color(0xFF1780FF) : ByColor.colorF0.withAlphaValue(0.11),
                            borderRadius: BorderRadius.circular(1.w),
                          ),
                        ),
                        const SizedBox(width: 4,),
                        Container(
                          width: _pageIndex == 1 ? 20.w : 12.w,
                          height: 2.w,
                          decoration: BoxDecoration(
                            color: _pageIndex == 1 ? Color(0xFF1780FF) : ByColor.colorF0.withAlphaValue(0.11),
                            borderRadius: BorderRadius.circular(1.w),
                          ),
                        ),
                      ],
                    ),
                    if(controller.styleManager.style == 2)
                    const SizedBox(height: 10,),
                    Center(
                      child: Image.asset(
                        controller.styleManager.style == 2 ? 'assets/pay/icon_pay_des__2_$_pageIndex.png' : 'assets/pay/icon_pay_vip_center_bg.png',
                        width: controller.styleManager.style == 2 ? 332.w : 264.w,
                        height: controller.styleManager.style == 2 ? 76.w : 200.w,
                        ),
                    ),
                  ],
                ),
              ));
          }), 
          ///付费页
          Positioned(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Obx(() {
                    ///开启会员免费试用
                    if(controller.showTrial()) {
                      return _buildTrialView();
                    }
                    final itemList = controller.getCurrentDataList();
                    if (itemList.isEmpty) {
                      return SizedBox(
                        height: 300.w,
                        child: MultiStatusView(
                          currentStatus: controller.payManager.payData.statusType.value,
                          action: () {
                            final LaunchController launch = Get.find<LaunchController>();
                            if(!launch.isLaunched.value) {
                              launch.appLaunch(onSuccess: (bean) {
                                GlobalController.instance.init();
                              },);
                            }
                            else {
                              controller.payManager.payData.init();
                            }
                          },
                          loadingWidget: const Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                ByColor.colorC1,
                              ),
                              strokeWidth: 1,
                            ),
                          ),
                          child: Container(),
                        ),
                      );
                    }
                    double height = 191.w;
                    ///横版
                    if(controller.styleManager.type == 1) {
                      height = 88.w * itemList.length;
                    }
                    return SizedBox(
                      height: height,
                      child: _buildPayList(),
                    );
                  }),
      
                  Stack(
                    children: [
                      ///支付按钮扫光
                      shimmerView(child: Container(
                        height: 56.w,
                        padding: EdgeInsets.symmetric(vertical: controller.isGuide ? 0 : 4.w),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Color(0xFF0552FB),
                            borderRadius: BorderRadius.circular(20)
                          ),
                        ),
                      ),),
      
                      ///底部支付按钮
                      SizedBox(
                        height: 56.w,
                        child: Obx(() => controller.getCurrentDataList().isNotEmpty ? 
                        BottomView(
                            showWords: false,
                            padding: 0,
                            isBottom: false,
                            margin: controller.isGuide ? 0 : 4.w,
                            titleColor: ByColor.colorF0,
                            backgroundColor: Colors.transparent,
                            arrowStyle: 1,
                            nextBtnText: controller.getPackageButtonText(),
                            nextStep: () {
                              if(controller.showTrial()) {
                                controller.startPay(bean: controller.getTrialPackage(switchValue));
                              }
                              else {
                                ///引导页非试用版
                                if(controller.isGuide) {
                                  controller.sourcePosition = 2;
                                  VipTypeBean selectPackage  = controller.payManager.payData.vipListTrialUse[controller.payManager.selectIndex.value];
                                  controller.startPay(bean: selectPackage);
                                }
                                else {
                                  controller.sourcePosition = 4;
                                  controller.startPay();
                                }
                              }
                            },
                        ) : Container()),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.w),
                  SizedBox(
                    height: 20.w,
                    child: switchValue && controller.showTrial() ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/pay/icon_pay_tips.png',
                          width: 16.w,
                          height: 16.w,
                        ),
                        const SizedBox(width: 8),
                        ByText.text(
                          text: "NO PAYMENT NOW",
                          fontSize: 13.sp,
                          textColor: ByColor.colorF1,
                        ),
                      ],
                    ) : Container(),
                  ),
                  SizedBox(height: 10.w),
                  Obx(() => controller.getCurrentDataList().isEmpty ? SizedBox(height: 20.w,) : AgreementView()),
                  SizedBox(height: 10.w + ByScreenUtils.bottomSafeHeight,),
                ],
              ),
            ),
          ),
          if(controller.isGuide)
          Obx(() => controller.payManager.payData.vipList.isEmpty ? Container() : closeView()),
          if(!controller.isGuide)
          closeView(),
          if(Platform.isIOS && !controller.isGuide && controller.payType.value == PayType.vip)
          restoreView(),
      
          ///顶部tip图片标签
          if(controller.styleManager.style != 2)
          Positioned(
            top: MediaQuery.of(Get.context!).padding.top + 50.w,
            right: 20.w,
            child: SizedBox(
              width: 62.w,
              height: 62.w,
              child: Stack(
                children: [
                  RotationTransition(
                    turns: _controller.drive(
                      Tween<double>(begin: 0, end: 1),
                    ),
                    child: Image.asset(
                      'assets/pay/icon_pay_top_tips_bg.png',),
                  ),
                  Image.asset(
                    'assets/pay/icon_pay_top_tips.png',),
                ],
              ),
            ))
        ],
      ),
    );
  }

  ///shimmer按钮
  Widget shimmerView({required Widget child}) {
    return ShimmerBtn(
      child: child,
    );
  }

  ///会员试用套餐
  Widget _buildTrialView() {
    VipTypeBean vipTypeBean = controller.getTrialPackage(switchValue);
    return Column(
      children: [
        Container(
          height: 60.w,
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          decoration: const BoxDecoration(
            color: ByColor.colorBg2,
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ByText.text(
                text: "Free Trial",
                fontSize: 17.sp,
                textColor: ByColor.colorF1,
                fontWeight: FontWeight.bold,
              ),
              Switch(
                value: switchValue,
                inactiveThumbColor: ByColor.colorF1,
                inactiveTrackColor: ByColor.color2E3038,
                activeThumbColor: ByColor.colorF1,
                activeTrackColor: ByColor.colorC1,
                onChanged: (value) {
                  FirebaseAnalytics.instance.logEvent(name: 'OB_sub_free_${value ? 'open' : 'close'}');
                  setState(() {
                    switchValue = value;
                  });
                },
              ),
            ],
          ),
        ),
        Container(
          height: 60.w,
          margin: EdgeInsets.symmetric(vertical: 12.w),
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: Stack(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ///标题位
                      ByText.text(
                        text: vipTypeBean.title,
                        fontSize: 21.sp,
                        fontWeight: FontWeight.bold,
                        textColor: ByColor.colorF1,
                      ),
                      ByText.text(
                        text: 'then ${controller.getPrice(vipTypeBean)} ${vipTypeBean.des}',
                        fontSize: 13.sp,
                        textColor: ByColor.colorF2,
                      ),
                    ],
                  ),
                ),
                // const Spacer(),
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: ByText.text(
                      text: vipTypeBean.illustrate ?? '',
                      fontSize: 17.sp,
                      textColor: ByColor.colorC1,
                    ),
                  ),
                ),
              ],
            ),
        )
      ],
    );
  }

  ///会员支付列表
  Widget _buildPayList() {
    return Obx(() {
      final dataList = controller.getCurrentDataList();
      if (controller.styleManager.type == 1) {
        return SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            children: List.generate(
              dataList.length,
              (index) => _buildPayItem(index, 'vip'),
            ),
          ),
        );
      }
      final bean = dataList[controller.payManager.selectIndex.value];
      return Column(
        children: [
          SizedBox(
            height: 150.w,
            child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: dataList.length,
                separatorBuilder: (context, index) {
                  return SizedBox(width: 8.w,);
                },
                itemBuilder: (context, index) {
                return _buildPayItem(index, 'vip');
              }),
          ),

          ByText.text(
            text: '${bean.des}',
            fontSize: 15.sp,
            fontWeight: FontWeight.w500,
            textColor: ByColor.colorF2,
          ),
          
        ],
      );
    });
  }

  ///会员支付列表
  Widget _buildPayItem(int index, String payType) {
    final dataList = controller.getCurrentDataList();
    final vipTypeBean = dataList[index];
    double width = dataList.length <= 2 ? 167.w : 111.w;
    return GestureDetector(
      onTap: () {
        controller.switchVipListCurrent(index);
      },
      child: Obx(() {
        final isSelected = controller.payManager.selectIndex.value == index;
        return Padding(
          padding: EdgeInsets.only(bottom: 12.w, top: controller.styleManager.type == 1 ? 0 : 12.w),
          child: Container(
            width: controller.styleManager.type == 1 ? double.infinity : width,
            height: controller.styleManager.type == 1 ? 76.w : 130.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: controller.styleManager.type == 1 ? null : LinearGradient(
                        begin: isSelected ? AlignmentGeometry.topLeft : AlignmentGeometry.bottomLeft,
                        end: isSelected ? AlignmentGeometry.bottomRight : AlignmentGeometry.topRight,
                        colors: isSelected ? [Color(0xFF002AC3), Color(0xFF6556FF)] : 
                        [Color(0xFF101113), Color(0xFF282421)]),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlphaValue(0.04), // 阴影颜色（带透明度）
                  spreadRadius: 5, // 阴影扩散半径
                  blurRadius: 6, // 阴影模糊半径
                  offset: const Offset(0, 2), // 阴影偏移量（x: 水平偏移, y: 垂直偏移）
                ),
              ],
              border: Border.all(
                color: controller.styleManager.type == 1 ? isSelected ? Color(0xFF3BB9FD) : Colors.transparent : ByColor.colorF0.withAlphaValue(0.1),
                width: controller.styleManager.type == 1 ? 2 : 1,
              ),
              color: ByColor.colorBg2,
            ),
            child: Stack(
              children: [
                if(isSelected && controller.styleManager.type != 1)
                Positioned(
                  right: 0,
                  bottom: 7.w,
                  child: Image.asset(
                    'assets/pay/icon_pay_item_select.png',
                    width: 68.w,
                    height: 54.w,)),
                ///横版
                controller.styleManager.type == 1 || controller.payType.value == PayType.token ? 
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.only(top: 9.w, left: 16, right: 16),
                    child: Row(
                      children: [
                        Image.asset('assets/global/common/btn_checkbox_${isSelected ? "selected" : "normal"}.png',
                            width: 16.w, height: 16.w),
                        SizedBox(width: 12.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ///标题位
                            ByText.text(
                              text: vipTypeBean.title,
                              fontSize: 21.sp,
                              fontWeight: FontWeight.bold,
                              textColor:ByColor.colorF1,
                            ),
                            ByText.text(
                              text: '${controller.getPrice(vipTypeBean)} ${vipTypeBean.des}',
                              fontSize: 13.sp,
                              textColor:ByColor.colorF2,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ) : 
              ///竖版
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ///标题位
                            ByText.text(
                              // text: vipTypeBean.title,
                              text: controller.styleManager.getPayTypeName(vipTypeBean, 1),
                              fontSize: 21.sp,
                              fontWeight: FontWeight.bold,
                              textColor:ByColor.colorF1,
                            ),
                            if(controller.payType.value == PayType.vip)
                            SizedBox(height: 8.w,),
                            if(controller.payType.value == PayType.vip)
                            ByWidgetsUtil.commonRichText(
                              texts: [
                                TextSpan(
                                  text: controller.styleManager.getPayTypeName(vipTypeBean, 3),
                                  // text: vipTypeBean.localSymbol!.isNotEmpty ? '${vipTypeBean.localSymbol} ' : '\$'
                                ),
                                TextSpan(
                                  // text: controller.getDayPrice(vipTypeBean),
                                  text: controller.styleManager.getPayTypeName(vipTypeBean, 4),
                                  style: TextStyle(
                                    fontSize: 25.sp,
                                    color: Color(0xFFFFF374),
                                  )
                                ),
                                TextSpan(
                                  // text: '/day'
                                  text: controller.styleManager.getPayTypeName(vipTypeBean, 5),
                                ),
                              ],
                              textColor: ByColor.colorF1,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500
                            ),
                            SizedBox(height: 8.w,),
                            ByText.text(
                              // text: '${controller.getPrice(vipTypeBean)} ${vipTypeBean.des}',
                              // text: controller.getPrice(vipTypeBean),
                              text: controller.styleManager.getPayTypeName(vipTypeBean, 2),
                              fontSize: 13.sp,
                              textColor:ByColor.colorF2,
                            )
                          ],
                        ),
                ),
                if (vipTypeBean.isDefault == 1) _builditemLabel(vipTypeBean),
              ],
            ),
          ),
        );
      }),
    );
  }

  ///列表 label
  Widget _builditemLabel(dynamic vipTypeBean) {
    String deMarkString = "Most popular";
    return Positioned(
      top: 0,
      right: 0,
      child: Container(
                height: 24,
                transform: Matrix4.identity()
                  ..translateByDouble(0, -12, 0, 1.0),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Color(0xFF77FF8B),
                      Color(0xFF15FFFE),
                    ],
                    stops: [0.3818, 0.9963],
                  ),
                ),
                alignment: Alignment.center,
                child: ByText.text(
                  text:  vipTypeBean.mark.isNotEmpty ? vipTypeBean.mark : deMarkString,
                  fontSize: 10.sp,
                  textColor: ByColor.colorF7,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
  }

  ///恢复购买
  Widget restoreView() {
    return Positioned(
      top: MediaQuery.of(Get.context!).padding.top,
      right: 20.w,
      child: GestureDetector(
        onTap: () {
          FirebaseAnalytics.instance.logEvent(name: 'purchase_restore');
          controller.payManager.payEngine.resumePurchase();
        },
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: 45.w,
          alignment: Alignment.centerRight,
          child: ByText.text(
            text: 'Restore',
            textColor: ByColor.colorF1,
          ),
        ),
      ),
    );
  }

  ///关闭按钮
  Widget closeView() {
    return Positioned(
      top: MediaQuery.of(Get.context!).padding.top,
      child: AnimatedOpacity(
        opacity: _closeOpacity, // 控制透明度（0→1）
        duration: const Duration(seconds: 1), // 动画时长（1秒）
        curve: Curves.easeInOut,
        child: GestureDetector(
          onTap: () {
            if(controller.isGuide) {
              if(controller.user.isVip || controller.returnHome || controller.payManager.payData.vipListGuide.isEmpty) {
                GlobalController.instance.isFirstIn = true;
                Get.offAllNamed(Routes.main);
                return;
              }
              FirebaseAnalytics.instance.logEvent(name: 'OB_sub_close');
              Get.off(() => GuideStepPage());
            }
            else {
              controller.closePayPage();
            }
          },
          behavior: HitTestBehavior.opaque,
          child: Container(
            width: 45.w,
            height: 45.w,
            alignment: Alignment.center,
            child: Image.asset(
              "assets/global/common/btn_close.png",
              width: 36,
              height: 36,
            ),
          ),
        ),
      ),
    );
  }
}


class AgreementView extends StatelessWidget {
    const AgreementView({super.key, this.style = 0});

    final int? style; /// 类型0为浅色，1为深色
  
    @override
    Widget build(BuildContext context) {
      return _buildAgreement();
    }

    /// 协议
  Widget _buildAgreement() {
    return Container(
      height: 20.w,
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              child: Wrap(
                alignment: WrapAlignment.center,
                children: [
                  RichText(
                    maxLines: 2,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: "Pravacy Policy",
                          style: TextStyle(
                            fontSize: 12,
                            color: style == 1 ? ByColor.colorF2 : ByColor.colorF1,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              GlobalController.instance.config
                                  .goPrivacyPageWithTitle("Privacy Policy");
                            },
                        ),
                        const TextSpan(
                          text: ',',
                          style: TextStyle(
                            fontSize: 12,
                            color: ByColor.colorF2,
                          ),
                        ),
                        TextSpan(
                          text: "Terms of Service",
                          style: TextStyle(
                            fontSize: 12,
                            color: style == 1 ? ByColor.colorF2 : ByColor.colorF1,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              GlobalController.instance.config
                                  .goPrivacyPageWithTitle("User Agreement");
                            },
                        ),
                        const TextSpan(
                          text: ' & ',
                          style: TextStyle(
                            fontSize: 12,
                            color: ByColor.colorF2,
                          ),
                        ),
                        TextSpan(
                          text: " Subscription Terms",
                          style: TextStyle(
                            color: style == 1 ? ByColor.colorF2 : ByColor.colorF1,
                            fontSize: 12,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              GlobalController.instance.config
                                  .goPrivacyPageWithTitle("Member Service Agreement");
                            },
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
}


class ShimmerBtn extends StatelessWidget {
  const ShimmerBtn({super.key, this.child, this.backgroundColor});

  final Color? backgroundColor;

  final Widget? child;

  @override
  Widget build(BuildContext context) {

    Color color = backgroundColor ?? Color(0xFF0552FB);
    return Shimmer(
      period: Duration(seconds: 2),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        transform: GradientRotation(pi / 8),
        // colors: <Color>[
        //   color,
        //   color,
        //   ByColor.colorF1.withAlphaValue(0.7),
        //   color,
        //   color,
        // ],
        colors: <Color>[
          color,
          color,
          ByColor.colorF0.withAlphaValue(backgroundColor == null ? 0.65 : 0.95),
          // ByColor.colorF0,
          color,
          color,
        ],
        stops: const <double>[0.0, 0.45, 0.5, 0.55, 1.0],
      ),
      child: child ?? Container(
        height: 48.w,
        padding: EdgeInsets.symmetric(vertical: 4.w),
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(14.w),
          ),
        ),
      ),
    );
  }
}
