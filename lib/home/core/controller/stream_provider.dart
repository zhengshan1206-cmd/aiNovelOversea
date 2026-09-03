/*
 * @Author: cold-x
 * @Date: 2025-06-17 17:28:03
 * @LastEditors: cold-x 474647591@qq.com
 * @LastEditTime: 2025-09-02 11:39:07
 * @FilePath: /fastcreationmaster/lib/home/long_novel/controller/stream_controller.dart
 * @Description: 
 */


import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:novel_oversea/core/network/result.dart';
import 'package:novel_oversea/core/ui/dialog/toast.dart';
import 'package:novel_oversea/core/ui/view/muti_status_view.dart';
import 'package:web_socket_channel/io.dart';

class StreamingProvider extends ChangeNotifier {
  ///流式输出内容
  String content = '';

  ///流式输出思考内容
  String thinkingContent = '';

  ///是否正在流式输出
  bool isGenerating = false;

  ///滚动控制器
  ScrollController scrollController = ScrollController();
  
  ///界面状态
  MultiStatusType statusType = MultiStatusType.statusContent;

  ///生成进度
  double progress = 0.0;

  ///是否正在准备下一章内容
  bool isGeneratingNextChapter = false;

  ///流式输出，走中台
  IOWebSocketChannel? channel;

  ///是否需要轮循数据
  bool needRecirleData = true;

  int maxWords = 800;


  ///网络连接状态监听
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  
  @override
  void dispose() {
    channel?.sink.close();
    needRecirleData = false;
    _subscription?.cancel();
    super.dispose();
  }

  // 初始化监听
  void startListening() {
    _subscription = _connectivity.onConnectivityChanged.listen((result) {
      _handleConnectivityChange(result);
    });
  }

  // 处理网络变化
  void _handleConnectivityChange(List<ConnectivityResult> result) {
    print('________OOO__$result');
    if (result.contains(ConnectivityResult.none)) {
      if(isGenerating) {
        statusType = MultiStatusType.statusNoNetWork;
        // finishStream();
        Toast.showText(text: 'Network disconnnected, streaming stopped');
      }
    } else {
      // 恢复在线功能
    }
  }

  ///更新流式内容
  void updateStreamingContent(String content) {
    content = content;
    notifyListeners();
  }

  void wsConnect(
    String taskId, 
    String? taskURL,
    {bool? hasNext = false, 
    bool? delayToFinish = false, ///延迟进度
    void Function()? successStream}) async {
    Map<String, String> params = {
      "action": 'subscribeTask', //id
      "taskId": taskId, // 使用传入的 type
    };
    print('________开始流式输出__$taskURL----____$taskId');
    channel = IOWebSocketChannel.connect(
      Uri.parse(taskURL!),
    );
    channel?.sink.add(params.toString());
    channel?.stream.listen(
      (message) {
        // 处理接收到的消息
        try {
          final receivedData = json.decode(message);
          final String receivedType = receivedData['type'];
          ///深度思考内容
          final String receivedThinkingContent = receivedData['reasoningContent'] ?? '';
          ///正文内容
          final  String receivedContent = (receivedData['content'] ?? '');
          ///历史消息或者当前流式输出的消息
          if (receivedType == 'token' || receivedType == 'history' || receivedType == 'reasoning') {
            ///历史输出时
            if(receivedType == 'history') {
              content = receivedContent;
              thinkingContent = receivedThinkingContent;
              content.replaceAll('[HIDE]', '');
            }
            else if(!receivedContent.contains('[HIDE]')) {
              content += receivedContent;
              thinkingContent += receivedThinkingContent;
            }
            ///替换正文结束后流式输出的标识符
            if (receivedContent.isNotEmpty && receivedContent.contains('[HIDE]')) {
              isGeneratingNextChapter = true;
              if(!hasNext!) {
                successStream?.call();
                finishStream();
                return;
              }
            }
            isGenerating = true;
            updateProgress();
            if ((receivedContent.isNotEmpty && !receivedContent.contains('[HIDE]') || receivedThinkingContent.isNotEmpty)) {
              scrollToBottom();
            }
            
          }
          ///结束消息
          else if(receivedType == 'done') {
            if(delayToFinish!) {
              delayToFinishStream();
            }
            else {
              finishStream(hasNext: hasNext!);
            }
            print("_______$message");
            successStream?.call();
          }
          
        } catch(e) {
          print('处理消息失败');
        }
      },
      onDone: () {
        // print("_______流式输出结束");
        // finishStream();
      },
      onError: (error) {
        // 处理连接错误
        print('WebSocket error____: $error');
        finishStream();
        if (error is APIError) {
          Toast.showText(text: error.message);
      }
      },
    );
  }

  ///更新生成进度
  void updateProgress({bool? isComplete = false}) {
    if (isComplete == true) {
      progress = 0.99; // 完成时进度为100%
      notifyListeners();
      return;
    }
    double t = content.length / maxWords;
    ///进度控制在99%
    if (t > 0 && t < 0.99) {
      progress = ((t * 100).round()) / 100; //进度保留两位小数
    }
    notifyListeners();
  }

  ///延迟结束流式输出
  void delayToFinishStream() {
    final double tmpProgress = progress;
    updateProgress(isComplete: true);
    Future.delayed(Duration(milliseconds: (1000 * (1 - tmpProgress)).floor()), () {
      finishStream();
    });
  }

  ///结束流式输出
  void finishStream({bool hasNext = false}) {
    // 连接关闭时的处理
    print('WebSocket connection closed____.');
    channel?.sink.close();
    // if(!hasNext) {
      isGenerating = false;
      isGeneratingNextChapter = false;
    // }
    notifyListeners();
    Future.delayed(const Duration(milliseconds: 300), scrollToBottom);
  }

  void scrollToBottom() {
    // 确保在下一帧滚动到底部
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.jumpTo(scrollController.position.maxScrollExtent);
      }
    });
  }
}
