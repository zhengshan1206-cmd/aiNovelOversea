


import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:novel_oversea/core/ui/view/by_text_field.dart';
import 'package:novel_oversea/core/ui/widget/by_text.dart';
import 'package:novel_oversea/core/util/extentions.dart';
import 'package:novel_oversea/global/ui/colors.dart';
import 'package:novel_oversea/home/create/controller/create_chat_controller.dart';
import 'package:novel_oversea/home/create/view/chat_cell.dart';

class ChatAudioView extends StatelessWidget {
  const ChatAudioView({super.key});

  CreateChatController get controller => Get.find<CreateChatController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ByColor.colorBg2.withAlphaValue(0.8),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const SizedBox(height: 12,),
            GestureDetector(
              onTap: () {
                controller.checkAudioDialog();
              },
              child: Image.asset(
                'assets/global/common/btn_close.png',
                fit: BoxFit.fill,
                width: 32.w,
                height: 32.w,
              ),
            ),

            Expanded(
              child: Container(
                padding: EdgeInsets.all(12),
                child: Center(
                  child: buildPointedBubble(text: '', isSender: true),
                ),
              ),
            ),
            // const Spacer(),
            GestureDetector(
              onLongPressStart: (details) {
                if(controller.currentRecognizedText.value.isNotEmpty) {
                  return;
                }
                controller.startListening();
              },
              onLongPressEnd: (details) {
                if(controller.currentRecognizedText.value.isNotEmpty) {
                  return;
                }
                controller.stopListening();
              },
              onTap: () {
                controller.addChat(ChatCellType.me, controller.currentRecognizedText.value);
                controller.closeAudioDialog();
              },
              child: Stack(
                children: [
                  Image.asset('assets/home/create/icon_chat_audio_slider.png'),
                  Positioned(
                    top: 24.w,
                    left: 0,
                    right: 0,
                    child: Center(child: Obx(() => ByText.text(
                      text: controller.currentRecognizedText.value.isNotEmpty ? 'Send' : controller.isRecording.value ?  'Slide to Send' : 'Press to peak',
                      fontSize: 17.sp,
                      fontWeight: FontWeight.bold))))
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  ///气泡
  Widget buildPointedBubble({required String text, bool isSender = false}) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      width: double.infinity,
      constraints: BoxConstraints(minHeight: 65.w),
      child: Obx(() => CustomPaint(
        painter: BubbleShape(
          isSender: isSender,
          dialog: true,
          color: controller.currentRecognizedText.value.isEmpty && !controller.isRecording.value ? ByColor.colorG4 : ByColor.colorC1,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.w),
          child: controller.isRecording.value && controller.currentRecognizedText.value.isEmpty ? Container(
                  alignment: Alignment.topLeft,
                  width: double.infinity,
                  height: 50.w,
                  child: CupertinoActivityIndicator(
                    color: ByColor.colorF8,
                    radius: 10.w,
                  ),
                ) : controller.currentRecognizedText.value.isNotEmpty
              // ? ByText.text(
              //     maxLines: 9999,
              //     textColor: ByColor.colorF7,
              //     text: controller.currentRecognizedText.value,
              //     fontSize: 15.sp,
              //   )
              ? ByTextField(
                maxLines: null,
                textColor: ByColor.colorF7,
                fontSize: 15.sp,
                cursorColor: ByColor.colorF8,
                controller: controller.textEdit,
                change: (value) {
                  controller.currentRecognizedText.value = value;
                },
              )
              : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/global/common/icon_novel_warning_gray.png', width: 16.w, height: 16.w,),
                  SizedBox(width: 8.w,),
                  ByText.text(
                    text: 'No sound detected, try again',
                    fontSize: 15.sp,
                    textColor: ByColor.colorF0,
                  ),
                ],
              )),
        ),
      ),
    );
  }
}


class BubbleShape extends CustomPainter {
  final bool isSender;
  final Color color;
  final bool? dialog;

  BubbleShape({required this.isSender, required this.color, this.dialog = false});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path();

    // 气泡主体（圆角矩形）
    final radius = Radius.circular(12);
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    path.addRRect(RRect.fromRectAndRadius(rect, radius));

    // 尖角位置（发送者在右侧，接收者在左侧）
    double arrowX = isSender ? size.width - 20 : 10;
    final double arrowY = size.height;
    if(dialog!) {
      arrowX = size.width / 2 - 6;
      path.moveTo(arrowX, arrowY);
      path.lineTo(arrowX + 6, arrowY + 6);
      path.lineTo(arrowX + 12, arrowY);
    }
    else {
      path.moveTo(arrowX, arrowY);
      path.lineTo(isSender ? arrowX + 6 : arrowX + 6, arrowY + 6);
      path.lineTo(isSender ? arrowX + 12 : arrowX + 12, arrowY);
    }
    
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}