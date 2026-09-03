
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:novel_oversea/core/ui/view/by_widgets_util.dart';
import 'package:novel_oversea/core/ui/widget/by_text.dart';
import 'package:novel_oversea/core/util/by_screen_utils.dart';
import 'package:novel_oversea/core/util/extentions.dart';
import 'package:novel_oversea/global/pay/bean/vip_type_bean.dart';
import 'package:novel_oversea/global/pay/controller/pay_controller.dart';
import 'package:novel_oversea/global/pay/page/pay_center_page.dart';
import 'package:novel_oversea/home/core/view/bottom_view.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import '../../../global/ui/colors.dart';



class HomeDiscountDialog extends StatefulWidget {
  const HomeDiscountDialog({super.key, this.isHomeGift = false, this.isPush = false});

  final bool isHomeGift;

  /// 是否是推送页面
  final bool isPush;

  @override
  State<HomeDiscountDialog> createState() => _HomeDiscountDialogState();
}

class _HomeDiscountDialogState extends State<HomeDiscountDialog> with SingleTickerProviderStateMixin{


  ///流式描述内容
  static const String desc = 'For limited time only, offer ends soon';

  late final PayController controller;

  VipTypeBean? bean;

  ///透明度
  double _opacity = 0.0;

  ///最大折扣比例
  final int _maxDiscount = 80;

  ///推送倒计时
  int _maxSecond = 30;

  ///当前折扣比例
  int _curentDiscount = 0;

  late AnimationController _aniController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  late Timer? _timer;

  @override
  void initState() {
    super.initState();
    _opacity = 1.0;
    controller = Get.put(PayController(), tag: 'discount');

    if(widget.isPush) {
      controller.sourcePosition = 10;
      bean = controller.payManager.payData.vipListPush.first;
    }
    else {
      if (widget.isHomeGift) {
        controller.sourcePosition = 6;
        bean = controller.payManager.payData.vipListHomeDiscount.first;
      } else {
        controller.sourcePosition = 0;
        bean = controller.payManager.payData.vipInterceptList.first;
      }
    }
    
    // _maxDiscount = controller.getPackageDiscount(bean!);

    // 初始化动画控制器（时长 300ms，控制动画速度）
    _aniController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    // 2. 缩放动画：从 1.0（原尺寸）→ maxScale（放大后尺寸）
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.6,
    ).animate(
      CurvedAnimation(parent: _aniController, curve: Curves.linear), // 动画曲线（自然过渡）
    );

    // 3. 透明度动画：从 1.0（完全显示）→ 0.0（完全消失）
    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(
      CurvedAnimation(parent: _aniController, curve: Curves.linear), // 与缩放动画用同一曲线
    );

    _timer = Timer.periodic(Duration(milliseconds: 50), (timer) {
      if(_curentDiscount < _maxDiscount && _maxSecond > 0) {
        setState(() {
          if(widget.isPush) {
            _curentDiscount ++;
            if(_curentDiscount >= 20) {
              _curentDiscount = 0;
              _maxSecond = _maxSecond - 1;
            }
          }
          else {
            _curentDiscount = min(_curentDiscount + 2, _maxDiscount);
          }
        });
      }
      else {
        _timer?.cancel();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_){
      _aniController.repeat();
    });
  }



  @override
  void dispose() {
    _timer?.cancel();
    _aniController.dispose(); 
    super.dispose();
  }

  Widget _chooseDialog() {
    if(widget.isPush) {
      return _buildPushDialog();
    }
    return _buildRetainDialog();
  }

  /// 推送的付费页样式
  Widget _buildPushDialog() {
    final Color mainColor = Color(0xFF41FA35);
    return Container(
      height: ByScreenUtils.screenHeight,
      decoration: BoxDecoration(
        image: DecorationImage(
          alignment: AlignmentGeometry.topCenter,
          image: AssetImage('assets/pay/icon_pay_push_bg.png')),
        color: ByColor.colorBg1,
      ),
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SizedBox(height: ByScreenUtils.topSafeHeight),
          _buildCloseBtn(),
          const Spacer(),
          ByText.text(
              text: 'Limeted Offer:',
              fontSize: 38.sp,
              textColor: ByColor.colorF1,
              fontWeight: FontWeight.w500,
            ),
          SizedBox(height: 3.w,),
          ByText.text(
              text: '80% Off',
              fontSize: 38.sp,
              textColor: mainColor,
              fontWeight: FontWeight.w500,
            ),
          SizedBox(height: 38.w,),
          SizedBox(
            height: 190.w,
            child: Center(
              child: SleekCircularSlider(
                appearance: CircularSliderAppearance(
                  size: 190.w,
                  // spinnerMode: false,
                  startAngle: 270,
                  angleRange: 360,
                  animationEnabled: false,
                  customColors: CustomSliderColors(
                    trackColor: ByColor.colorF2.withAlphaValue(0.1),
                    progressBarColors: [Color(0xFFD7F97D), mainColor],
                    dotColor: Colors.transparent,
                  ),
                  customWidths: CustomSliderWidths(
                    trackWidth: 15,
                    progressBarWidth: 15,
                  ),
                ),
                min: 0,
                max: 600,
                initialValue: _maxSecond * 600/30 - _curentDiscount,
                innerWidget: (percentage) {
                  return Center(
                    child: ByText.text(
                      text: '00:${_maxSecond >= 10 ? _maxSecond : '0$_maxSecond'}',
                      fontSize: 44.sp,
                      textColor: _maxSecond > 0 ? mainColor : ByColor.colorG4,
                      fontWeight: FontWeight.w500,
                    ),
                  );
                },
              ),
            ),
          ),
          SizedBox(height: 38.w,),
          Row(
            children: [
              ByText.text(
                  text: 'Save 80%',
                  fontSize: 17.sp,
                  textColor: mainColor,
                  fontWeight: FontWeight.w500,
                ),
              ByText.text(
                  text: ' vs our weekly plan ',
                  fontSize: 17.sp,
                  textColor: ByColor.colorF3,
                  fontWeight: FontWeight.w500,
                ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6),
                decoration: BoxDecoration(
                  color: ByColor.colorF2.withAlphaValue(0.2),
                  borderRadius: BorderRadius.circular(12)
                ),
                child: ByText.text(
                    text: '${controller.styleManager.getLocalSymbol(bean!)}${double.parse(controller.styleManager.getDayPrice(bean, type: 1))/0.2}',
                    fontSize: 15.sp,
                    decoration: TextDecoration.lineThrough,
                    textColor: ByColor.colorF1,
                    fontWeight: FontWeight.w500,
                  ),
              ),
            ],
          ),
          SizedBox(height: 5.w,),
          ByWidgetsUtil.commonRichText(
            texts: [
              TextSpan(text: '${controller.styleManager.getLocalSymbol(bean!)}${controller.styleManager.getDayPrice(bean, type: 1)}', style: TextStyle(color: ByColor.colorF1, fontSize: 28.sp, fontWeight: FontWeight.w600)),
              TextSpan(text: ' per week'),
            ],
            textColor: ByColor.colorF3,
            fontSize: 15.sp,
          ),
          SizedBox(height: 24.w,),
          Stack(
            children: [
              ShimmerBtn(
                backgroundColor: mainColor,
                child: Container(
                  height: 56.w,
                  padding: EdgeInsets.symmetric(vertical: 4.w),
                  child: Container(
                    decoration: BoxDecoration(
                      color: mainColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 56.w,
                child: BottomView(
                  showWords: false,
                  padding: 0,
                  isBottom: false,
                  titleColor: ByColor.colorF8,
                  backgroundColor: Colors.transparent,
                  nextBtnText: controller.getPackageButtonText(bean: bean),
                  nextStep: () {
                    controller.startPay(bean: bean);
                  },
                ),
              ),
            ],
          ),
          Container(
            height: 40.w,
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: ByText.text(
              text: 'This price is valid for the first Month. Then ${controller.getPrice(bean)} every year.',
              fontSize: 12.sp,
              maxLines: 2,
              textAlign: TextAlign.center,
              textColor: ByColor.colorF2.withAlphaValue(0.5),
              fontWeight: FontWeight.w600,
            ),
          ),
          AgreementView(),
          SizedBox(height: 4.w + max(6.w, ByScreenUtils.bottomSafeHeight)),
        ]
      ),
    );
  }
  /// 带波纹的付费页样式
  Widget _buildRetainDialog() {
    return Container(
      height: ByScreenUtils.screenHeight,
      decoration: BoxDecoration(
        image: DecorationImage(
          alignment: AlignmentGeometry.topCenter,
          image: AssetImage('assets/pay/icon_pay_retain_bg.png')),
        color: ByColor.colorBg1,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: ByScreenUtils.topSafeHeight),
          _buildCloseBtn(paddingLeft: true),
          SizedBox(height: 15.w,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ByText.text(
                  text: 'Special Offer',
                  fontSize: 28.sp,
                  textAlign: TextAlign.center,
                  fontWeight: FontWeight.bold,
                ),
              Transform.translate(
                offset: Offset(-12.w, -9.w),
                child: Image.asset(
                  'assets/pay/icon_pay_retain_ring.png',
                  width: 29.w,
                  height: 24.w,),
              ),
            ],
          ),
          SizedBox(height: 15.w),
          ByText.text(
              text: desc,
              fontSize: 15.sp,
              textColor: ByColor.colorF2,
              textAlign: TextAlign.center,
              fontWeight: FontWeight.w500,
            ),

          SizedBox(
            width: 327.w,
            height: 327.w,
            child: Stack(
              children: [
                Center(
                  child: AnimatedBuilder(
                    animation: _aniController,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _opacityAnimation.value,
                        child: Transform.scale(
                          scale: _scaleAnimation.value,
                          child: Image.asset(
                            'assets/pay/icon_pay_retain_wave.png',
                            width: 240.w,
                            height: 240.w,),
                        ),
                      );
                    }
                  ),
                ),
                Center(
                  child: AnimatedBuilder(
                    animation: _aniController,
                    builder: (context, child) {
                      double op = _opacityAnimation.value + 0.66 >= 1 ? _opacityAnimation.value - 0.34 : _opacityAnimation.value + 0.66;
                      double sc = _scaleAnimation.value + 0.2 > 1.6 ? _scaleAnimation.value - 0.4 : _scaleAnimation.value + 0.2;
                      return Opacity(
                        opacity: op,
                        child: Transform.scale(
                          scale: sc,
                          child: Image.asset(
                            'assets/pay/icon_pay_retain_wave.png',
                            width: 240.w,
                            height: 240.w,),
                        ),
                      );
                    }
                  ),
                ),
                Center(
                  child: AnimatedBuilder(
                    animation: _aniController,
                    builder: (context, child) {
                      double op = _opacityAnimation.value + 0.34 >= 1 ? _opacityAnimation.value - 0.66 : _opacityAnimation.value + 0.34;
                      double sc = _scaleAnimation.value + 0.4 > 1.6 ? _scaleAnimation.value - 0.2 : _scaleAnimation.value + 0.4;
                      return Opacity(
                        opacity: op,
                        child: Transform.scale(
                          scale: sc,
                          child: Image.asset(
                            'assets/pay/icon_pay_retain_wave.png',
                            width: 240.w,
                            height: 240.w,),
                        ),
                      );
                    }
                  ),
                ),
                Image.asset(
                  'assets/pay/icon_pay_retain_discount.png',
                  width: 327.w,
                  height: 327.w,),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Transform.translate(
                        offset: Offset(0, 10),
                        child: ByText.text(
                          text: '$_curentDiscount%',
                          fontSize: 70.sp,
                          textAlign: TextAlign.center,
                          textColor: ByColor.colorF0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Transform.translate(
                        offset: Offset(0, -10),
                        child: ByText.text(
                          text: 'OFF',
                          fontSize: 32.sp,
                          textAlign: TextAlign.center,
                          textColor: ByColor.colorF0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          Expanded(child: Container()),
          ByText.text(
              // text: 'Was ${controller.getPrice(bean)}${bean?.illustrate ?? ''}',
              text: 'Was ${controller.styleManager.getLocalSymbol(bean!)}${controller.getPriceForDiscount(bean!)}${bean?.illustrate ?? ''}',
              decoration: TextDecoration.lineThrough,
              decorationThickness: 2.0,
              fontSize: 15.sp,
              textAlign: TextAlign.center,
              textColor: ByColor.colorF2,
              fontWeight: FontWeight.w500,
            ),
          SizedBox(height: 12.w),
          ByText.text(
              text: 'Total ${controller.getPrice(bean,)}${bean?.illustrate ?? ''}',
              fontSize: 28.sp,
              textAlign: TextAlign.center,
              textColor: Color(0xFF3BB9FD),
              fontWeight: FontWeight.bold,
            ),
          SizedBox(height: 4.w),
          ByText.text(
              text: 'only ${controller.styleManager.getLocalSymbol(bean!)}${controller.styleManager.getDayPrice(bean!,)}/day',
              fontSize: 16.sp,
              textAlign: TextAlign.center,
              fontWeight: FontWeight.w600,
            ),
          SizedBox(height: 49.w),
          opacityView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: Stack(
                children: [
                  ShimmerBtn(
                    child: Container(
                      height: 56.w,
                      padding: EdgeInsets.symmetric(vertical: 4.w),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Color(0xFF0552FB),
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 56.w,
                    child: BottomView(
                      showWords: false,
                      padding: 0,
                      isBottom: false,
                      titleColor: ByColor.colorF0,
                      backgroundColor: Colors.transparent,
                      arrowStyle: 1,
                      nextBtnText: controller.getPackageButtonText(bean: bean),
                      nextStep: () {
                        controller.startPay(
                          bean: bean,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 30.w),
          opacityView(child: SizedBox(
            height: 20.w,
            child: ByText.text(
              text: bean?.des ?? '',
              fontSize: 16.sp,
              textAlign: TextAlign.center,
              fontWeight: FontWeight.w600,
            ),
          )),
          SizedBox(height: 8.w + max(12.w, ByScreenUtils.bottomSafeHeight)),
        ],
      ),
    );
  }

  /// 关闭按钮
  Widget _buildCloseBtn({bool? paddingLeft = false}) {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            Get.back();
          },
          child: Container(
            width: 32,
            height: 32,
            margin: EdgeInsets.only(top: 12, left: paddingLeft! ? 12.w : 0),
            decoration: BoxDecoration(
              color: ByColor.colorF8.withAlphaValue(0.25),
              borderRadius: BorderRadius.circular(8)
            ),
            child: Image.asset(
              "assets/global/common/btn_close.png",
              width: 16,
              height: 16,
            ),
          ),
        ),
      ],
    );
  }

  ///透明度渐变
  Widget opacityView({required Widget child}) {
    return AnimatedOpacity(
      opacity: _opacity, duration: const Duration(milliseconds: 1000),
      child: child,);
  }

  @override
  Widget build(BuildContext context) {
    return _chooseDialog();
  }
}