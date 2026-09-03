/*
 * @Author: duncy
 * @Date: 2025-09-24 16:35:48
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2026-01-08 21:33:53
 * @FilePath: /novel_oversea/lib/home/create/page/create_chat_page.dart
 * @Description: 
 */


import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:novel_oversea/core/service/app_permisson/byhy_permission_utils.dart';
import 'package:novel_oversea/core/ui/dialog/by_dialog_util.dart';
import 'package:novel_oversea/core/ui/page/base_page.dart';
import 'package:novel_oversea/core/ui/view/by_text_field.dart';
import 'package:novel_oversea/core/ui/view/muti_status_view.dart';
import 'package:novel_oversea/core/ui/widget/by_button.dart';
import 'package:novel_oversea/core/ui/widget/by_text.dart';
import 'package:novel_oversea/global/ui/colors.dart';
import 'package:novel_oversea/home/core/controller/websocket_manager.dart';
import 'package:novel_oversea/home/create/controller/create_chat_controller.dart';
import 'package:novel_oversea/home/create/controller/novel_create_controller.dart';
import 'package:novel_oversea/home/create/page/create_partner_page.dart';
import 'package:novel_oversea/home/create/view/chat_audio_view.dart';
import 'package:novel_oversea/home/create/view/chat_cell.dart';

import '../../../core/util/by_screen_utils.dart';
import '../../main/view/guide_mask_view.dart';

// ignore: must_be_immutable
class CreateChatPage extends BasePage {
  CreateChatPage({super.key});

  @override
  bool get hasAppBar => false;

  @override
  CreateChatController get controller => Get.put(CreateChatController());

  @override
  String get title => controller.type == CreationType.longNovel ?  'Generate Book' : 'Generate Story';

  @override
  Widget buildBody(BuildContext context) {
    return PopScope(
      canPop: !controller.isGuide,
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.contain,
            alignment: AlignmentGeometry.topCenter,
            image: AssetImage('assets/home/create/icon_create_bg.png'),
          ),
        ),
        child: Obx(() => MultiStatusView(
          currentStatus: controller.statusType.value,
          action: () {
            controller.guideNovel();
          },
          child: Stack(
            children: [
              SafeArea(
                child: Stack(
                  children: [
                    Column(
                      children: [
                        NavigationTitleView(title: title),
                        SizedBox(height: 12,),
                        Expanded(
                          child: SingleChildScrollView(
                            controller: controller.scroll,
                            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                            child: Column(
                              children: [
                                Obx(() => ListView.builder(
                                    physics: const NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    itemCount: controller.chatList.length,
                                    itemBuilder: (context, index) {
                                      ChatBean bean = controller.chatList[index];
                                      return Container(
                                        margin: EdgeInsets.only(bottom: 12),
                                        child: ChatCell(
                                          url: controller.partner.icon,
                                          type: bean.type,
                                          text: bean.text,),
                                      );
                                  })),
                                Obx(() {
                                  if([SocketStatus.generating, SocketStatus.connecting, SocketStatus.normal].contains(controller.socketStatus.value) && controller.chatList.length > 1) {
                                    return ChatCell(
                                      type: ChatCellType.other,
                                      text: controller.socketStatus.value != SocketStatus.generating ? 'Ai is thinking...' : controller.streamContent.value,);
                                  }
                                  return Container();
                                })
                              ],
                            ),
                          ),
                        ),
                        if(!controller.isGuide)
                        Obx(() => controller.chatList.length > 1 || controller.isGuide ? Opacity(
                          opacity: [SocketStatus.generating, SocketStatus.connecting, SocketStatus.normal].contains(controller.socketStatus.value) ? 0.3 : 1.0,
                          child: Container(
                            padding: EdgeInsets.only(left: 12.w, right: 12.w, top: 6.w, bottom: 6.w),
                            child: Row(
                              children: [
                                Expanded(
                                  child: ByButton.textButton(
                                    titleColor: ByColor.colorF1,
                                    backgroundColor: ByColor.color2E3038,
                                    title: 'Retry', onPressed: () {
                                      if([SocketStatus.generating, SocketStatus.connecting, SocketStatus.normal].contains(controller.socketStatus.value)) {
                                        return;
                                      }
                                      controller.clearAndRetry();
                                      controller.inputType.value = ChatInputType.text;
                                      controller.currentRecognizedText.value = '';
                                  }),
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: ByButton.textButton(title: 'Continue', onPressed: () {
                                    if([SocketStatus.generating, SocketStatus.connecting].contains(controller.socketStatus.value)) {
                                        return;
                                      }
                                    controller.fetchBookConfig();
                                  }),
                                ),
                              ],
                            ),
                          ),
                        ) :
                        Row(
                          children: [
                            Expanded(
                              child: Obx(() => controller.inputType.value == ChatInputType.text ?  _buildInputView() : _buildAudioBtn()
                            )),
                            Container(
                              width: 48.w,
                              height: 48.w,
                              margin: EdgeInsets.only(right: 6.w, bottom: 12.w),
                              child: Obx(() => ByButton.buttonWidget(
                                padding: EdgeInsetsGeometry.all(5.w),
                                child: Image.asset('assets/home/create/btn_${controller.inputType.value == ChatInputType.text ? 'audio' : 'keyboard'}.png'),
                                onPressed: () async {
                                  FirebaseAnalytics.instance.logEvent(name: 'chat_toggle_input_mode', parameters: {
                                    'from': controller.inputType.value == ChatInputType.text ? 'text' : 'audio',
                                    'to': controller.inputType.value == ChatInputType.text ? 'audio' : 'text',
                                  });
                                  if (controller.inputType.value == ChatInputType.text) {
                                    // 切换到audio前先检查权限
                                    // bool micGranted = await ByPermissionUtils.microphone(message: 'You have turned off the micphone, go to the settings to turn it on?');
                                    bool speechGranted = await controller.speech.hasPermission;
                                    // 语音识别权限一般和麦克风一致，iOS可用speech_to_text的hasPermission判断
                                    // 若需更细致可用speech_to_text插件的hasPermission
                                    // 这里假设只需麦克风权限
                                    if (!speechGranted) {
                                      ByDialogUtil.showPopScopeDialog(
                                        context: Get.context!,
                                        contents: 'You have turned off the microphone or speech permission, go to the settings to Authorize?',
                                        confirmCallback: (){
                                          ByPermissionUtils.openPermissionSettings();
                                        });
                                      // Toast.showText(text: 'You have turned off the auth, go to the settings to turn it on?');
                                      return;
                                    }
                                  }
                                  controller.inputType.value = controller.inputType.value  == ChatInputType.text ? ChatInputType.audio : ChatInputType.text;
                                },
                              )),
                            )
                          ],
                        )),
                      ],
                    ),
                    Obx(() => controller.audioDialog.value ? Positioned.fill(child: ChatAudioView()) : Container()),
                  ],
                ),
              ),
          
              if(controller.isGuide)
                GuideBottomMaskView(
                  offY: 20.w + ByScreenUtils.bottomSafeHeight,
                  onMaskTap: () {
                    FirebaseAnalytics.instance.logEvent(name: 'Create_OB_talk');
                    controller.nextStepForGuide();
                  },
                )
            ],
          ),
        ),
      )),
    ); 
  }

  ///输入框视图
  Widget _buildInputView() {
    return Container(
      margin: EdgeInsets.only(left: 12.w, bottom: 12.w),
      height: 48.w,
      padding: EdgeInsets.all(0.5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.w),
        gradient: LinearGradient(
          colors: [
            Color(0xFF27EEFB),
            Color(0xFFFEFFFF),
            Color(0xFFF3DF9B),
            Color(0xFFFEFFFF),
            Color(0xFFF3430D),
          ],
        ),
      ),
      child: Container(
        padding: EdgeInsets.only(left: 12.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.w),
          color: ByColor.colorBg1,
        ),
        child: Row(
          children: [
            Expanded(
              child: ByTextField(
                controller: controller.textEditingController,
                hintText: 'Tell Joseph which story you want.',
                maxLines: 1,
              ),
            ),
            SizedBox(width: 12.w),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: ByButton.textButton(
                padding: EdgeInsets.zero,
                backgroundColor: ByColor.colorC1,
                titleColor: ByColor.colorF8,
                title: 'Send',
                onPressed: () {
                  controller.addChat(ChatCellType.me, controller.textEditingController.text);
                  // Get.toNamed(
                  //   Routes.novelCreate,
                  //   arguments: {'novel_type': CreationType.longNovel},
                  // );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  ///语音发送按钮
  Widget _buildAudioBtn() {
    return GestureDetector(
      key: controller.longPressKey,
      onLongPressStart: (details) {
        controller.startListening();
      },
      onLongPressMoveUpdate: (details) {
        // final isCancel = controller.isSlideToCancel(details.globalPosition);
        // print('____$isCancel');
      },
      onLongPressEnd: (details) {
        controller.stopListening();
        bool canSend = controller.isSlideToCancel(details.globalPosition);
        if(canSend) {
          // 发送语音
        } else {
          // 取消发送
        }
      },
      child: Container(
        height: 48.w,
        margin: EdgeInsets.only(left: 12.w, bottom: 12.w),
        decoration: BoxDecoration(
          color: ByColor.colorBg2,
          borderRadius: BorderRadius.circular(16.w),
        ),
        child: Center(
          child: ByText.text(
            text: 'Press to peak',
            fontSize: 17.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}