
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svga/flutter_svga.dart';
import 'package:get/get.dart';
import 'package:novel_oversea/core/service/local_streaming.dart';
import 'package:novel_oversea/core/ui/widget/by_text.dart';
import 'package:novel_oversea/core/util/by_screen_utils.dart';
import 'package:novel_oversea/core/util/extentions.dart';
import 'package:novel_oversea/global/pay/controller/pay_controller.dart';
import 'package:novel_oversea/global/pay/page/pay_center_page.dart';
import 'package:novel_oversea/global/pay/view/countdown_view.dart';
import 'package:novel_oversea/global/pay/view/gift_svga_player.dart';
import '../../../global/ui/colors.dart';



class ShortcutIosDialog extends StatefulWidget {
  const ShortcutIosDialog({super.key});

  @override
  State<ShortcutIosDialog> createState() => _ShortcutIosDialogState();
}

class _ShortcutIosDialogState extends State<ShortcutIosDialog> {


  ///流式描述内容
  static const String desc = 'Last chance to upgrade! Subscribe now to unblock premum features at low cost!';

  ///流式当前内容
  String content = '';

  late LocalStreamManager localStreamManager;

  late final PayController controller;

  ///透明度
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();
    controller = Get.put(PayController());
    controller.sourcePosition = 5;
    localStreamManager = LocalStreamManager(
      intervalMs: (3150/desc.length).floor(),
      charsPerStep: 1,
    );
    
    localStreamManager.setTargetString(desc);
    localStreamManager.output = (String substring, bool isGen) {
      setState(() {
        content += substring;
        if(content == desc) {
          _opacity = 1.0;
        }
      });
    };
    localStreamManager.start();
  }

  @override
  void dispose() {
    localStreamManager.dispose();
    super.dispose();
  }

  Widget _chooseDialog() {
    return _buildRetainDialog();
  }

  Widget _buildRetainDialog() {
    return Container(
      height: ByScreenUtils.screenHeight,
      color: ByColor.colorBg1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: ByScreenUtils.topSafeHeight,),
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  Get.back();
                },
                child: Container(
                  width: 48,
                  height: 32,
                  margin: EdgeInsets.only(top: 12),
                  child: Image.asset(
                    "assets/global/common/btn_close.png",
                    width: 16,
                    height: 16,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 15.w,),
          SizedBox(
            height: 400.w,
            child: GiftSvgaPlayer(),
          ),
          const Spacer(),
          
          Container(
            padding: EdgeInsetsDirectional.symmetric(horizontal: 20.w),
            child: ByText.text(
              text: content,
              fontSize: 15.sp,
              textAlign: TextAlign.center,
              maxLines: 3,
              fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 24.w,),
          opacityView(
            child: CountdownView(
                  fontSize: 24.sp,
                  textColor: ByColor.colorF1,
                  borderColor: Color(0xFFB5FCCF).withAlphaValue(0.6),
                  borderWidth: 1.5,
                  bgColor: ByColor.colorBg2,
                  separatorColor: Color(0xFFB5FCCF).withAlphaValue(0.6),
                  timeItemWidth: 42.w,
                  borderRadius: 9.w,
                  showMilliseconds: false,
                  type: 0,
                ),
          ),
          SizedBox(height: 24.w,),
          opacityView(
            child: GestureDetector(
              onTap: () {
                controller.startPay(bean: controller.payManager.payData.vipListiOSInterceptor.first);
              },
              child: Container(
                height: 64.w,
                margin: EdgeInsets.symmetric(horizontal: 12.w),
                child: Stack(
                  children: [
                    SVGAEasyPlayer(
                      assetsName: 'assets/pay/svga_pay_submit.svga',
                    ),
                    Obx(() {
                      final bean = controller.payManager.payData.vipListiOSInterceptor.first;
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Center(
                            child: ByText.text(
                              text:
                                  '${bean.discountLocalPrice!.isNotEmpty && bean.localPrice!.isNotEmpty ? bean.discountLocalPrice : '\$${bean.firstCheapMoney}'} for the first week',
                              fontSize: 17,
                              textColor: ByColor.colorF8,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          ByText.text(
                            text:
                                'then ${bean.discountLocalPrice!.isNotEmpty && bean.localPrice!.isNotEmpty ? bean.localPrice : '\$${bean.money}'} per week',
                            // text: controller.getPrice(bean),
                            textColor: ByColor.colorF7,
                          ),
                        ],
                      );
                    }),
                    Positioned(
                      right: 20.w,
                      top: 22.w,
                      bottom: 22.w,
                      child: Image.asset(
                        'assets/home/create/icon_home_create_continue.png',
                      ),
                    ),
                  ],
                )
              ),
            ),
          ),
          SizedBox(height: 24.w,),
          opacityView(child: AgreementView()),
          SizedBox(
              height: 2.w + max(12.w, ByScreenUtils.bottomSafeHeight),
            ),
        ],
      ),
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