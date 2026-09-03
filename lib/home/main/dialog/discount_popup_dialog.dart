import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:novel_oversea/global/pay/view/countdown_view.dart';
import 'package:novel_oversea/global/ui/colors.dart';

class PayDiscountPopView extends StatelessWidget{
  const PayDiscountPopView({
    super.key,
    required this.type,
    this.action,
    this.timeOut,
    this.cancel,
  });

  final int type;   ///0 新手底部引导  1 付费页二次弹窗拦截取消底部引导 2 非vip未完成小说
  final VoidCallback? action;
  final VoidCallback? cancel;
  final VoidCallback? timeOut;


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        action?.call();
      },
      child: Stack(
        children: [
          Container(height: type == 1 ? 90.h : 65.h,),
          if(type == 1)
          Positioned(
            top: 0.h,
            right: 20.w,
            child: Container(
              height: 32.h,
              padding: EdgeInsets.symmetric(horizontal: 2.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(6.w),
                  topRight: Radius.circular(6.w),
                ),
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFE9FD37),
                    Color(0xFFFEBF31),
                  ],
                ),
              ),
              child: CountdownView(
                fontSize: 14.sp,
                textColor: ByColor.colorF1,
                bgColor: Colors.black,
                separatorColor: ByColor.colorF1,
                timeItemWidth: 24.w,
                borderRadius: 4.w,
                showMilliseconds: false,
                type: 0,
                timeOut: timeOut,
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: 60.h,
              padding: EdgeInsets.symmetric(horizontal: 7.w),
              child: Stack(
                children: [
                  Image.asset(
                      type == 2 ? 'assets/pay/icon_pay_uncomplete_novel.png' : 'assets/pay/icon_pay_${type == 0 ? 'vip': 'retain'}_dialog.png',
                    width: double.infinity,
                    height: 60.h,
                    fit: BoxFit.fill,
                  ),
                  if(type != 2)
                  Positioned(
                    right: 12.w,
                    top: 14.h,
                    child: Image.asset(
                      'assets/pay/icon_pay_retain_go.png',
                      width: 68.h,
                      height: 32.h,
                  ),)
                ],
              ),
            ),
          ),
          Positioned(
            top: type == 1 ? 20.w : 0.w,
            right: 5.w,
            child: GestureDetector(
              onTap: () {
                // 点击关闭按钮，关闭底部运营条
                cancel?.call();
              },
              child: Image.asset(
                "assets/home/main/dialog_close.png",
                width: 20.w,
                height: 20.w,
              ),
            ),
          ),
        ],
      ),
    );
  }

}