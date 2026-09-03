/*
 * @Author: cold-x
 * @Date: 2025-08-05 09:53:50
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2025-10-22 11:26:52
 * @FilePath: /novel_oversea/lib/home/create/view/content_random_view.dart
 * @Description: 
 */
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:novel_oversea/core/network/http_streaming.dart';
import 'package:novel_oversea/core/ui/dialog/by_dialog_util.dart';
import 'package:novel_oversea/core/ui/widget/by_button.dart';
import 'package:novel_oversea/core/ui/widget/by_text.dart';
import 'package:novel_oversea/core/util/by_screen_utils.dart';
import 'package:novel_oversea/global/ui/colors.dart';

///AI帮我写页面
class ContentRandomView extends StatefulWidget {
  const ContentRandomView({
    super.key,
    required this.args,
    required this.interface,
    this.userAction});
  ///使用文本信息
  final Function(String)? userAction;
  ///参数
  final dynamic args;
  ///流式输出接口
  final String interface;

  @override
  State<ContentRandomView > createState() => _ContentRandomViewState();
}

class _ContentRandomViewState extends State<ContentRandomView > {

  late final ContentRecreateController controller;

  @override
  void initState() {
    controller = Get.put(ContentRecreateController());
    controller.args = widget.args;
    controller.startStreaming(widget.interface);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        controller.comfirmBack();
      },
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: ByColor.colorBg2,
          borderRadius: BorderRadius.circular(12.w)
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                ByText.text(
                  text: 'Introduce',
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  textColor: ByColor.colorF1),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    controller.comfirmBack();
                  },
                  child: Container(
                    alignment: Alignment.centerRight,
                    width: 48,
                    height: 32,
                    child: Image.asset(
                      'assets/global/common/btn_close.png',
                      width: 32,
                      height: 32,
                    ),
                  ),
                )
              ],
            ),
            SizedBox(height: 12.w,),
            Container(
              height: 566.h,
              width: double.infinity,
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.w),
                color: ByColor.color2E3038,
              ),
              child: Obx(() => SingleChildScrollView(
                controller: controller.scroll,
                child: ByText.text(
                  maxLines: 99999,
                  text: controller.content.value, 
                  textColor: ByColor.colorF2),
              )),
            ),
            SizedBox(height: 12.w,),
            SizedBox(
              height: 48.w,
              child: Obx(() => Opacity(
                opacity: controller.isGenerating.value ? 0.3 : 1.0,
                child: Row(
                  children: [
                    ByButton.textButton(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      title: 'Retry', 
                      backgroundColor: ByColor.color2E3038,
                      titleColor: ByColor.colorF8,
                      onPressed: (){
                        ///重新生成
                        if (!controller.isGenerating.value) {
                          controller.startStreaming(widget.interface);
                        }
                    }),
                    SizedBox(width: 12.w,),
                    Expanded(
                      child: ByButton.textButton(
                          title: 'Use',
                          titleColor: Colors.black,
                          onPressed: () {
                            ///使用AI生成的文本
                            if(!controller.isGenerating.value) {
                              widget.userAction?.call(controller.content.value);
                              Get.back();
                            }
                          }),
                    )
                  ],
                )),
              ),
            ),
            SizedBox(height: ByScreenUtils.bottomSafeHeight + 4.w,),
          ],
        ),
      ),
    );
  }
}


class ContentRecreateController extends GetxController {

  ScrollController scroll = ScrollController();
  ///流式输出参数
  Map<String, dynamic> args = {};
  HttpSteaming? streaming;
  ///是否流式中
  Rx<bool> isGenerating = false.obs;
  ///流式输出内容
  Rx<String> content = 'Ai生成中...'.obs;

  ///生成中时返回拦截
  void comfirmBack() {
    if (isGenerating.value) {
      ByDialogUtil.showPopScopeDialog(
        context: Get.context!,
        contents: 'Current content is still generating, do you comfirm to back?',
        confirmCallback: () {
          Get.back();
        }
      );
    }
    else {
      Get.back();
    }
  }

  ///开始流式输出
  void startStreaming(String api) {
    streaming ??= HttpSteaming();
    content.value = 'Ai is thinking...';
    isGenerating.value = true;
    streaming?.fetchContentGeneration(args, api,
      streaming: (p0) {
        if(content.value == 'Ai is thinking...') {
          content.value = p0;
        }
        else {
          content.value += p0;
        }
        _scrollToBottom();
      },
      complete: () {
        isGenerating.value = false;
        _scrollToBottom();
      },
      error: (p0) {
        isGenerating.value = false;
      },);
  }

  @override
  void dispose() {
    streaming?.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    // 确保在下一帧滚动到底部
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scroll.hasClients) {
        scroll.jumpTo(scroll.position.maxScrollExtent);
      }
    });
  }
}