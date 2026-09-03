

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:novel_oversea/core/network/http_utils.dart';
import 'package:novel_oversea/core/network/novel_apis.dart';
import 'package:novel_oversea/core/ui/dialog/by_dialog_util.dart';
import 'package:novel_oversea/core/ui/dialog/loading_dialog.dart';
import 'package:novel_oversea/core/ui/dialog/toast.dart';
import 'package:novel_oversea/core/ui/view/muti_status_view.dart';
import 'package:novel_oversea/global/routes/app_pages.dart';
import 'package:novel_oversea/home/core/controller/websocket_manager.dart';
import 'package:novel_oversea/home/create/bean/novel_category_bean.dart';
import 'package:novel_oversea/home/create/controller/novel_create_controller.dart';
import 'package:novel_oversea/home/create/view/chat_cell.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../../../core/util/util.dart';
import '../../brief/bean/novel_bean.dart';

enum ChatInputType {
  ///文本
  text,

  ///语音
  audio
}

class ChatBean {
  ChatCellType type;
  String text;

  ChatBean({
    required this.type,
    required this.text,
  });
}

class CreateChatController extends GetxController {

  ///loading
  Rx<MultiStatusType> statusType = MultiStatusType.statusContent.obs;
  
  ///输入类型
  Rx<ChatInputType> inputType = ChatInputType.text.obs;

  ///是否显示录音弹窗
  Rx<bool> audioDialog = false.obs;

  ///是否正在录音
  Rx<bool> isRecording = false.obs;

  ///当前识别的文本
  Rx<String> currentRecognizedText = ''.obs;

  ///创建小说类型
  CreationType type = CreationType.longNovel;

  ///当前taskID, 用于配置生成
  String taskID = '';

  ///选择的小说partner
  late NovelCategoryBean partner;

  ///文字输入控制器
  TextEditingController textEditingController = TextEditingController();

  ///语音输入后的输入控制器
  final TextEditingController textEdit = TextEditingController();

  ScrollController scroll = ScrollController();

  ///发送的消息列表
  RxList<ChatBean> chatList = <ChatBean>[].obs;

  ///流式输出内容
  RxString streamContent = ''.obs;

  ///是否正在生成
  Rx<SocketStatus> socketStatus = SocketStatus.normal.obs;

  // ///录音滑动是否可以发送
  // Rx<bool> canSendBySlide = false.obs;

  /// 长按录音按钮的key，用于计算位置
  final GlobalKey longPressKey = GlobalKey();

  stt.SpeechToText speech = stt.SpeechToText();

  late WebsocketManager wsManager;

  ///是否显示引导遮罩
  bool isGuide = false;
  NovelBean? novelBean;

  @override
  void onInit() {
    final args = Get.arguments as Map<String, dynamic>?;
    type = args?['type'] ?? CreationType.longNovel;
    partner = args?['partner'];
    isGuide = args?['guide'] ?? false;
    initChatList();
    initStream();
    
    FirebaseAnalytics.instance.logEvent(
      name: 'create_novel_chat_page_view',
      parameters: {
        'type': type == CreationType.longNovel ? 'long_novel' : 'short_novel',
        'partner': partner.name,
      },
    );
    if(isGuide) {
      guideNovel();
    }
    else {
      ///初始化语音管理器
      initSpeech();
    }
    super.onInit();
  }

  @override
  void dispose() {
    wsManager.dispose();
    super.dispose();
  }

  ///初始化流式输出
  void initStream() {
    wsManager = WebsocketManager(
      statusChanged: (status) {
        socketStatus.value = status;
        if(status == SocketStatus.comlete) {
          addChat(ChatCellType.other, streamContent.value);
        }
        if(status != SocketStatus.generating) {
          streamContent.value = '';
        }
      },
      streamContent: (value) {
        streamContent.value += value;
        scrollToBottom();
      },
    );
  }

  ///初始化问询信息
  void initChatList() {
    ChatBean bean = ChatBean(
      type: ChatCellType.other, 
      text: "Hi, I'm ${partner.name} your writing partner. Please tell which kind of story you want to write");
    chatList.add(bean);
  }

  ///添加对话
  void addChat(ChatCellType type, String message) {
    if(message.isEmpty) {
      return;
    }
    ChatBean bean = ChatBean(
      type: type, 
      text: message);
    chatList.add(bean);
    scrollToBottom();
    if (type == ChatCellType.me) {
      FocusScope.of(Get.context!).unfocus();
      fetchStreamURL(message: message);
      textEditingController.clear();
      currentRecognizedText.value = '';
    }
  }

  ///初始化语音
  void initSpeech() async {
    bool available = await speech.initialize(onStatus: (status) {
      print("onStatus___$status");
    }, onError:(error) {
      print("onError=====$error");
    });
    if (!available ) {
        print("The user has denied the use of speech recognition.");
    }
  }

  ///开始识别语音
  void startListening() {
    audioDialog.value = true;
    isRecording.value = true;
    print('=====START');
    currentRecognizedText.value = '';
    speech.listen(
      localeId: 'en_US',
      onResult: (result) {
        if(result.finalResult) {
          print('---->>>FINAL: ${result.recognizedWords}');
        }
        currentRecognizedText.value = speech.lastRecognizedWords;
        textEdit.text = currentRecognizedText.value;
        print("onResult ---->>>${result.recognizedWords},,, isFinal: ${result.finalResult},,__${currentRecognizedText.value}");
    });
  }

  ///停止识别语音
  void stopListening() {
    print('_____END');
    isRecording.value = false;
    speech.stop();
  }

  ///检查并关闭语音弹窗
  void checkAudioDialog() {
    if(currentRecognizedText.value.isEmpty) {
      closeAudioDialog();
      return;
    }
    ByDialogUtil.showPopScopeDialog(
      context: Get.context!, 
      title: 'Cancel',
      contents: 'Are you sure to cancel the current recording? Your current recording will not be saved.', 
      confirmCallback: () {
        closeAudioDialog();
      },
    );
  }

  ///关闭语音弹窗
  void closeAudioDialog() {
    audioDialog.value = false;
    isRecording.value = false;
    currentRecognizedText.value = '';
    speech.stop();
  }

  ///重试，清空生成的数据
  void clearAndRetry() {
    chatList.removeRange(1, chatList.length);
    taskID = '';
    if(socketStatus.value != SocketStatus.normal) {
      wsManager.streamComplete();
      wsManager.changeStatus(SocketStatus.normal);
    }
  }

  @override
  void onClose() {
    stopListening();
    super.onClose();
  }

  // 计算上滑取消的阈值（按钮底部为起点，上滑200px取消）
  bool isSlideToCancel(Offset globalPosition) {
    final renderBox = longPressKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return false;
    final buttonBottom = renderBox.localToGlobal(Offset(0, renderBox.size.height)).dy;
    return (buttonBottom - globalPosition.dy) > 200; // 上滑距离超过200px
  }

  ///滑动到最底部
  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scroll.hasClients) {
        scroll.animateTo(scroll.position.maxScrollExtent, duration: Duration(milliseconds: 100), curve: Curves.bounceOut);
      }
    });
  }

  ///获取流式输出地址
  void fetchStreamURL({required String message}) {
    HttpUtils.post(
      NovelApis.novelChatURL, 
      showMsgWhenFailed: false,
      {
        'message': message,
        'novel_genres': partner.key,
        'is_short_story': type == CreationType.shortNovel ? '1' : '2',
      },
      success: (data) {
        try {
          final String taskURL = data['data']['websocket_url'];
          taskID = data['data']['task_id'];
          if(taskURL.isNotEmpty && taskID.isNotEmpty) {
            wsManager.connect(taskID, taskURL);
          }
        }
        catch(e) {
          // throw(e);
        }
      },
      fail: (code, msg) {
        Toast.showText(text: 'Network error');
      },);
  }

  ///获取流式输出地址
  void fetchBookConfig() {
    LoadingDialog().show(message: 'Creating...');
    HttpUtils.get(
      NovelApis.novelChatConfig,
      {'task_id': taskID},
      showMsgWhenFailed: false,
      success: (data) {
        LoadingDialog().dismiss();
        try {
          final config = data['data']['config_info'];
          Get.toNamed(
            Routes.novelCreate,
            arguments: config is Map ? {
              'params': config,
              'novel_type': type,
              'func': type == CreationType.longNovel
                  ? 'long_novel_professional'
                  : 'short_novel_professional',
            } : {
              'novel_type': type ,
              'func': type == CreationType.longNovel
                  ? 'long_novel_professional'
                  : 'short_novel_professional',
            },
          );
        }
        catch(e) {
          // throw(e);
        }
        
      },
      fail: (code, msg) {
        LoadingDialog().dismiss();
        Toast.showText(text: 'Network error');
      },
    );
  }

  ///引导页随机生成的小说
  void guideNovel({
    bool isFirstLoad = false,
    void Function()? onSuccess,
    void Function(int, String)? onFailed,
  }) {
    statusType.value = MultiStatusType.statusLoading;
    ///随机一个参数
    final int randomSex = Util.randomInt(0, 3);
    HttpUtils.get(
      NovelApis.guideNovel,
      {'novel_type': randomSex},
      success: (data) {
        statusType.value = MultiStatusType.statusContent;
        novelBean =
              NovelBean.fromSquareJson(data['data']['novel_info']);
      },
      fail: (code, msg) {
        statusType.value = MultiStatusType.statusNoNetWork;
      },
    );
  }

  ///引导页进入创作页
  void nextStepForGuide() {
    Get.offNamed(
            Routes.novelCreate,
            arguments: {
              'novel_type': type,
              'params': novelBean?.params,
              'func': novelBean?.func,
              'guide': true
            },
          );
  }
}