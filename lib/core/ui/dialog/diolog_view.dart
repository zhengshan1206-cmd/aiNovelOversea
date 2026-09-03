/*
 * @Author: cold-x
 * @Date: 2025-06-11 20:34:47
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2025-10-11 15:34:34
 * @FilePath: /novel_oversea/lib/core/ui/dialog/diolog_view.dart
 * @Description: 
 */

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:novel_oversea/core/ui/widget/by_button.dart';
import 'package:novel_oversea/core/ui/widget/by_text.dart';
import 'package:novel_oversea/core/util/extentions.dart';

import '../../../global/ui/colors.dart';

enum CommomDiologTye {
  normal,

  ///默认文本
  textfeild,

  ///输入框
}

class CommomDiolog extends StatelessWidget {
  CommomDiolog({
    super.key,
    this.onConfirm,
    this.title,
    this.content,
    this.cancelText,
    this.confirmText,
    this.cancelColor,
    this.confirmBgColor,
    this.confirmTextColor,
    this.maxLength = 20,
    this.type = CommomDiologTye.normal,
  });

  final Function(String)? onConfirm;
  final String? title;
  final String? content;
  final String? cancelText;
  final String? confirmText;
  final Color? cancelColor;
  final Color? confirmBgColor;
  final Color? confirmTextColor;
  final CommomDiologTye? type;
  final int? maxLength; ///输入框最大长度

  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    if (type == CommomDiologTye.textfeild) {
      controller.text = content ?? '';
    }
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: SizedBox(
          width: 320.w,
          height: 230.w,
          child: Stack(
            children: [
              Positioned(
                top: 0,
                width: 320.w,
                bottom: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: ByColor.colorF0,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                          height: 78.w),
                      ///dialog类型判断
                      type == CommomDiologTye.normal
                          ? ByText.text(
                              text: content ?? "文件删除后无法恢复哦",
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              textColor: ByColor.colorF8,
                            )
                          : _buildTextFeild(),
                      SizedBox(height: 29.w),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 50.w,
                                child: ByButton.textButton(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 20.w),
                                    backgroundColor:
                                        cancelColor ?? ByColor.colorBg2.withAlphaValue(0.2),
                                    title: cancelText ?? "取消",
                                    titleColor: ByColor.colorF8,
                                    fontSize: 17.sp,
                                    fontWeight: FontWeight.w500,
                                    onPressed: () {
                                      Get.back();
                                    }),
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: SizedBox(
                                height: 50.w,
                                child: ByButton.textButton(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 20.w),
                                    title: confirmText ?? "确认",
                                    backgroundColor: confirmBgColor ?? ByColor.colorF8,
                                    titleColor: confirmTextColor ?? ByColor.colorF1,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w500,
                                    onPressed: () {
                                      Get.back();
                                      onConfirm?.call(controller.text);
                                    }),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 23.w,
                left: 0,
                right: 0,
                child: Center(
                  child: ByText.text(
                    text: title ?? "确认",
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    textColor: ByColor.colorF8,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextFeild() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: Container(
        height: 50.w,
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: ByColor.colorBg2.withAlphaValue(0.1),
          borderRadius: BorderRadius.circular(12.w),
          border: Border.all(
            width: 1,
            color: ByColor.colorBg2.withAlphaValue(0.05),
          )
        ),
        child: TextField(
          controller: controller,
          style: TextStyle(
            color: ByColor.colorF8,
            fontSize: 16.sp,
          ),
          selectionControls: MaterialTextSelectionControls(),
          maxLines: 1,
          autofocus: false,
          focusNode: FocusNode(),
          scrollController: ScrollController(),
          decoration: InputDecoration(
            contentPadding: EdgeInsets.zero,
            isCollapsed: true,
            border: InputBorder.none,
            labelStyle: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.normal,
              color: Colors.white,
            ),
          ),
          onChanged: (value) {
            ///限制输入长度
            if (value.length > maxLength!) {
              controller.text = value.substring(0, maxLength!);
              controller.selection = TextSelection.fromPosition(
                TextPosition(offset: controller.text.length),
              );
            }
          },
        ),
      ),
    );
  }
}

class NovelDialog extends StatelessWidget {
  const NovelDialog({
    super.key,
    this.title,
    this.content,
    this.cancelText,
    this.cancelTextColor,
    this.confirmText,
    this.cancelColor,
    this.confirmBgColor,
    this.confirmTextColor,
    this.showCancelBtn = true,
    this.onConfirm, 
    this.contentAlign = TextAlign.center,
    this.onCancel});

  final Function()? onConfirm;
  final Function()? onCancel;
  final String? title;
  final String? content;
  final String? cancelText;
  final String? confirmText;
  final Color? cancelColor;
  final Color? confirmBgColor;
  final Color? confirmTextColor;
  final Color? cancelTextColor;
  final bool? showCancelBtn;///是否显示取消
  final TextAlign? contentAlign;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: ByColor.colorBg2,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 30.w),
                ByText.text(
                  text: title ?? "Kind Tips",
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  textColor: Colors.white,
                ),
                SizedBox(height: 20.w),
                ByText.text(
                  text: content ?? 'Network error, need retry, \nGenerate failed would not consume credits',
                  fontSize: 15,
                  maxLines: 10,
                  textAlign: contentAlign ?? TextAlign.center,
                  fontWeight: FontWeight.w500,
                  textColor: Colors.white,
                ),
                SizedBox(height: 26.w),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Row(
                    children: [
                      if (!showCancelBtn!)
                      Expanded(
                        child: SizedBox(
                          height: 50.w,
                          // child: ByWidgetsUtil.commonBtn(
                          //     padding: EdgeInsets.symmetric(horizontal: 20.w),
                          //     bgColor: cancelColor ?? ByColor.color2E3038,
                          //     title: cancelText ?? "取消",
                          //     textColor: cancelTextColor ?? ByColor.colorF2,
                          //     fontSize: 17,
                          //     borderRadius: 15,
                          //     fontWeight: FontWeight.w500,
                          //     onClick: () {
                          //       Get.back();
                          //       onCancel?.call();
                          //     }),
                        ),
                      ),
                      if(!showCancelBtn!)
                      SizedBox(width: 12.w),
                      Expanded(
                        child: SizedBox(
                          height: 50.w,
                          // child: ByButton.gradientBtn(
                          //     padding: EdgeInsets.symmetric(horizontal: 20.w),
                          //     title: confirmText ?? "确认",
                          //     bgColor: confirmBgColor ?? ByColor.colorC1,
                          //     textColor: confirmTextColor ?? Colors.black,
                          //     fontSize: 17,
                          //     borderRadius: 15,
                          //     fontWeight: FontWeight.w500,
                          //     onClick: () {
                          //       Get.back();
                          //       onConfirm?.call();
                          //     }),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.w,),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
