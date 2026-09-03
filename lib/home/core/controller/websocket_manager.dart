/*
 * @Author: duncy
 * @Date: 2025-10-23 13:58:37
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2025-10-23 17:39:52
 * @FilePath: /novel_oversea/lib/home/core/controller/websocket_manager.dart
 * @Description: 
 */


import 'dart:convert';
import 'package:novel_oversea/core/network/result.dart';
import 'package:novel_oversea/core/ui/dialog/toast.dart';
import 'package:web_socket_channel/io.dart';

enum SocketStatus{
  ///未连接状态
  normal,
  ///正在连接
  connecting,
  ///正在输出内容
  generating,
  ///结束输出内容
  comlete,
  ///错误
  error,
}

class WebsocketManager {

  SocketStatus status = SocketStatus.normal;
  ///流式输出，走中台
  IOWebSocketChannel? channel;
  ///状态变化
  Function(SocketStatus)? statusChanged;
  ///流式内容
  Function(String)? streamContent;

  WebsocketManager({this.statusChanged, this.streamContent});

  void dispose() {
    channel?.sink.close();
  }

  void connect(
    String taskId, 
    String taskURL,
    {void Function()? successStream}) async {
    Map<String, String> params = {
      "action": 'subscribeTask', //id
      "taskId": taskId, // 使用传入的 type
    };
    print('________开始流式输出__$taskURL----____$taskId');
    channel = IOWebSocketChannel.connect(
      Uri.parse(taskURL),
    );
    changeStatus(SocketStatus.connecting);
    channel?.sink.add(params.toString());
    channel?.stream.listen(
      (message) {
        // 处理接收到的消息
        try {
          final receivedData = json.decode(message);
          final String receivedType = receivedData['type'];
          ///正文内容
          final  String received = (receivedData['content'] ?? '');
          ///历史消息或者当前流式输出的消息
          if (receivedType == 'token' || receivedType == 'history') {
            changeStatus(SocketStatus.generating);
            streamContent?.call(received);
          }
          ///结束消息
          else if(receivedType == 'done') {
            statusChanged?.call(SocketStatus.comlete);
            streamComplete();
          }
        } catch(e) {
          print('处理消息失败');
        }
      },
      onDone: () {

      },
      onError: (error) {
        // 处理连接错误
        print('WebSocket error____: $error');
        statusChanged?.call(SocketStatus.error);
        streamComplete();
        if (error is APIError) {
          Toast.showText(text: error.message);
        }
      },
    );
  }

  void changeStatus(SocketStatus value) {
    status = value;
    statusChanged?.call(status);
  }

  void streamComplete() {
    // 连接关闭时的处理
    print('WebSocket connection closed____.');
    channel?.sink.close();
  }
}