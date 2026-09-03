/*
 * @Author: duncy
 * @Date: 2026-01-05 11:21:34
 * @LastEditors: duncy 474647591@qq.com
<<<<<<< HEAD
 * @LastEditTime: 2026-01-26 11:40:26
=======
 * @LastEditTime: 2026-01-22 17:16:15
>>>>>>> 1.0.9_dev
 * @FilePath: /novel_oversea/lib/global/launch/view/guide_last_step_view.dart
 * @Description: 
 */


import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:novel_oversea/core/util/extentions.dart';
import 'package:novel_oversea/global/launch/controller/launch_manager.dart';
import 'package:novel_oversea/global/launch/view/guide_last_step_dialog.dart';
import 'package:novel_oversea/global/pay/page/pay_center_page.dart';
import '../../../core/ui/widget/by_text.dart';
import '../../../core/util/by_screen_utils.dart';
import '../../../home/core/view/bottom_view.dart';
import '../../routes/app_pages.dart';
import '../../ui/colors.dart';
import '../controller/guide_step_controller.dart';

class GuideLastStepView extends StatefulWidget {
  const GuideLastStepView({super.key});

  @override
  State<GuideLastStepView> createState() => _GuideLastStepViewState();
}

class _GuideLastStepViewState extends State<GuideLastStepView> {

  final GuideStepController controller = Get.find<GuideStepController>();
  int _pageIndex = 0;

  final List<String> desTitles = [
    'From prompt to video, instantly',
    'Create AI images & videos in one app',
    'Turn ideas into motion',
    'Own the copyright to the generated content',
    'Get 30K generation credits'
  ];

  @override
  void initState() {
    FirebaseAnalytics.instance.logEvent(name: 'OB_end_pay_show');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _buildPage(context);
  }

  ///页码内容
  Widget _buildPage(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            alignment: Alignment.topCenter,
            image: AssetImage('assets/global/launch/icon_guide_step_bg.png'),
            fit: BoxFit.contain,
          ),
        ),
        alignment: Alignment.center,
        child: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                top: 0,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SizedBox(height: 30.w,),
                    Image.asset(
                      'assets/global/launch/icon_guide_step_top.png',
                      width: 330.w,),
                    SizedBox(height: 24.w,),
                    for (int i in [0,1,2,3,4]) 
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.w),
                        height: 30.w,
                        child: Row(
                        children: [
                          Image.asset(
                            'assets/global/launch/icon_guide_title_icon_$i.png',
                            width: 18,
                            height: 18,
                          ),
                          SizedBox(width: 10.w,),
                          ByText.text(
                            text: i == 4 ? controller.selectPackage.des : desTitles[i],
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w500,
                            textAlign: TextAlign.left,
                            textColor: ByColor.colorF1,
                          ),
                        ],
                        ),
                      ),
                    SizedBox(height: 24.w,),
                    SizedBox(
                      height: 106.w,
                      width: 375.w,
                      child: CarouselSlider(
                        options: CarouselOptions(
                          height: 106.w,
                          viewportFraction: 0.9,
                          autoPlayInterval: Duration(seconds: 3),
                          onPageChanged: (value, reason) {
                            setState(() {
                              _pageIndex = value;
                            });
                          },
                          autoPlay: true,
                        ),
                        items: [0, 1, 2, 3, 4].map((index) {
                          return Image.asset(
                            'assets/global/launch/icon_guide_comments_$index.png',
                          );
                        }).toList(),
                      ),
                    ),
                    SizedBox(height: 6.w,),
                    SizedBox(
                      height: 2.w,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          return Row(
                            children: [
                              SizedBox(width: 1.5,),
                              Container(
                                width: _pageIndex == index ? 20.w : 12.w,
                                height: 2.w,
                                decoration: BoxDecoration(
                                  color: _pageIndex == index ? Color(0xFF1780FF) : ByColor.colorF0.withAlphaValue(0.12),
                                  borderRadius: BorderRadius.circular(1.w)
                                ),
                              ),
                              SizedBox(width: 1.5,),
                            ],
                          );
                        })
                      ),
                    ),
                    SizedBox(height: 12.w,),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: ByText.text(
                        text:
                            'Your subscription will automatically renew at ${controller.getPrice()} ${controller.selectPackage.des} until it expires. You can cancel your subscription at any time in the ${Platform.isAndroid ? 'Play' : 'App'} Store.',
                        fontSize: 11.sp,
                        maxLines: 3,
                        textAlign: TextAlign.center,
                        textColor: Color(0xFF8A959C).withAlphaValue(0.7),
                      ),
                    ),
                    const Spacer(),
                    GuidePayBottomView(
                      showFinger: false,
                      nextStep: () {
                      FirebaseAnalytics.instance.logEvent(name: 'OB_end_pay_continue');
                      controller.startPay();
                    },),
                  ],
                ),
              ),

              Positioned(
                left: 0,
                top: 12,
                child: GestureDetector(
                  onTap: () {
                    FirebaseAnalytics.instance.logEvent(name: 'OB_end_pay_close');
                    if (GlobalController.instance.pay.vipListGuideDialog.isNotEmpty) {
                      Get.bottomSheet(
                        GuideLastStepDialog(),
                        isScrollControlled: true,
                      );
                    }
                    else {
                      GlobalController.instance.isFirstIn = true;
                      Get.offAllNamed(Routes.main);
                    }
                  },
                  child: Container(
                    width: 36.w,
                    height: 36.w,
                    margin: EdgeInsets.only(left: 12.w),
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: ByColor.colorF8.withAlphaValue(0.25)
                    ),
                    child: SizedBox(
                        width: 32.w,
                        height: 32.w,
                        child: Image.asset(
                          'assets/global/common/btn_close.png',
                          width: 16.w,
                          height: 16.w,)
                      ),
                  ),
                ),)
            ],
          ),
        ),
      );
  }
}


class GuidePayBottomView extends StatefulWidget {
  const GuidePayBottomView({
    super.key, 
    required this.nextStep, 
    this.pravacyStyle, 
    this.btnColor, 
    this.style = 1, 
    this.showFinger = true,
    this.nextBtnText});

  final int? pravacyStyle; ///协议风格
  final Function nextStep;
  final Color? btnColor;
  final String? nextBtnText;
  final bool? showFinger;
  final int? style; /// 按钮风格 0黑色 1白色

  @override
  State<GuidePayBottomView> createState() => _GuidePayBottomViewState();
}

class _GuidePayBottomViewState extends State<GuidePayBottomView>
    with SingleTickerProviderStateMixin {

  late AnimationController _aniController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // 初始化动画控制器（时长 300ms，控制动画速度）
    _aniController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    // 2. 缩放动画：从 1.0（原尺寸）→ maxScale（放大后尺寸）
    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(
        parent: _aniController,
        curve: Curves.linear,
      ), // 动画曲线（自然过渡）
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _aniController.repeat(reverse: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 70.w + 56.w + ByScreenUtils.bottomSafeHeight,
      child: Stack(
        children: [
          Column(
            children: [
              Stack(
                children: [
                  ShimmerBtn(
                    backgroundColor: widget.btnColor,
                    child: Container(
                      height: 56.w,
                      padding: EdgeInsets.symmetric(
                        vertical: 0.w,
                        horizontal: 12.w,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: widget.btnColor ?? Color(0xFF0552FB),
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 56.w,
                    child: BottomView(
                      showWords: false,
                      isBottom: false,
                      margin: 0,
                      backgroundColor: Colors.transparent,
                      nextBtnText: widget.nextBtnText ?? 'CONTINUE',
                      arrowStyle: widget.style!,
                      titleColor: widget.style! == 0 ? ByColor.colorF8 : ByColor.colorF0,
                      nextStep: () {
                        widget.nextStep.call();
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 40.w),
              AgreementView(style: widget.pravacyStyle,),
              SizedBox(height: 10.w + ByScreenUtils.bottomSafeHeight),
            ],
          ),
          if(widget.showFinger!)
          Positioned(
            right: 41.w,
            bottom: 59.w + ByScreenUtils.bottomSafeHeight,
            child: ExpandedAnimateView(),
          ),
          if(widget.showFinger!)
          Positioned(
            right: 11.w,
            bottom: 45.w + ByScreenUtils.bottomSafeHeight,
            width: 74.w,
            height: 67.w,
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _aniController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    origin: Offset(-32.w, -20.w),
                    child: Image.asset(
                      'assets/global/launch/icon_guide_finger.png',
                      width: 74.w,
                      height: 67.w,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _aniController.dispose(); 
    super.dispose();
  }

}

class FingerScaleAnimateView extends StatefulWidget {
  const FingerScaleAnimateView({super.key});

  @override
  State<FingerScaleAnimateView> createState() => _FingerScaleAnimateViewState();
}

class _FingerScaleAnimateViewState extends State<FingerScaleAnimateView> with SingleTickerProviderStateMixin {

  late AnimationController _aniController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // 初始化动画控制器（时长 300ms，控制动画速度）
    _aniController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    // 2. 缩放动画：从 1.0（原尺寸）→ maxScale（放大后尺寸）
    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(
        parent: _aniController,
        curve: Curves.linear,
      ), // 动画曲线（自然过渡）
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _aniController.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _aniController.dispose(); 
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          Transform.translate(
            offset: Offset(-32.5.w, -22.5.w),
            child: ExpandedAnimateView()),
          SizedBox(
            width: 74.w,
            height: 67.w,
            child: AnimatedBuilder(
              animation: _aniController,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  origin: Offset(-32.w, -10.w),
                  child: Image.asset(
                    'assets/global/launch/icon_guide_finger.png',
                    width: 74.w,
                    height: 67.w,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ExpandedAnimateView extends StatefulWidget {
  const ExpandedAnimateView({super.key});

  @override
  State<ExpandedAnimateView> createState() => _ExpandedAnimateViewState();
}

class _ExpandedAnimateViewState extends State<ExpandedAnimateView>
    with SingleTickerProviderStateMixin {

  late AnimationController _aniController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    // 初始化动画控制器（时长 300ms，控制动画速度）
    _aniController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    // 2. 缩放动画：从 1.0（原尺寸）→ maxScale（放大后尺寸）
    _scaleAnimation = Tween<double>(begin: 0, end: 1.0).animate(
      CurvedAnimation(
        parent: _aniController,
        curve: Curves.linear,
      ), // 动画曲线（自然过渡）
    );

    // 3. 透明度动画：从 1.0（完全显示）→ 0.0（完全消失）
    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _aniController,
        curve: Curves.linear,
      ), // 与缩放动画用同一曲线
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _aniController.repeat();
    });
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SizedBox(
        width: 75.w,
        height: 75.w,
        child: Stack(
          children: [
            _bulildSingleView(0, 4),
            _bulildSingleView(1, 4),
            _bulildSingleView(2, 4),
            _bulildSingleView(3, 4),
          ],
        ),
      ),
    );
  }

  Widget _bulildSingleView(int index, int count) {
    double avg = 1/count;
    return Center(
      child: AnimatedBuilder(
        animation: _aniController,
        builder: (context, child) {
          double op = _opacityAnimation.value + avg * index >= 1
              ? _opacityAnimation.value - avg * (count - index)
              : _opacityAnimation.value + avg * index;
          double sc = _scaleAnimation.value + avg * (count - index) > 1.0
              ? _scaleAnimation.value - avg * index
              : _scaleAnimation.value + avg * (count - index);
          return Opacity(
            opacity: op,
            child: Transform.scale(
              scale: sc,
              child: Container(
                width: 75.w,
                height: 75.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(37.5.w),
                  // color: Color(0xFF53EC27),
                  color: op > 0.5 ? ByColor.colorF0 : Colors.transparent,
                  border: Border.all(
                    width: 3,
                    color: ByColor.colorF0
                  )
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _aniController.dispose(); 
    super.dispose();
  }
}
