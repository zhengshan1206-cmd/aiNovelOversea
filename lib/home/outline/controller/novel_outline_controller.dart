/*
 * @Author: cold-x
 * @Date: 2025-06-17 19:00:50
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2025-10-31 19:58:35
 * @FilePath: /novel_oversea/lib/home/outline/controller/novel_outline_controller.dart
 * @Description: 
 */


import 'dart:async';
import 'package:get/get.dart';
import 'package:novel_oversea/core/network/http_utils.dart';
import 'package:novel_oversea/core/ui/dialog/by_dialog_util.dart';
import 'package:novel_oversea/core/ui/dialog/loading_dialog.dart';
import 'package:novel_oversea/core/ui/dialog/toast.dart';
import 'package:novel_oversea/core/ui/view/muti_status_view.dart';
import 'package:novel_oversea/home/outline/bean/novel_outline_bean.dart';
import '../../../core/network/novel_apis.dart';

class NovelOutlineController extends GetxController{

  //小说id
  int novelID;
  NovelOutlineController({
    required this.novelID,
    });


  ///大纲列表数据
  RxList<OutlineBean> itemList = <OutlineBean>[].obs;

  ///当前可以生成的大纲
  Rx<int> currentOutlineIndex = 0.obs;

  ///小说状态
  int novelStatus = 0;

  ///内容状态
  Rx<MultiStatusType> statusType = MultiStatusType.statusContent.obs;

  ///定时器轮循进度
  Timer? _timer;
  bool _isRunning = false;///是否在轮循

  @override
  void onInit() {
    super.onInit();
    fetchOutlineList();
  }

  @override
  void onClose() {
    _stopTimer();
    super.onClose();
  }

  ///开始轮循
  void _startTimer() {
    if (_isRunning) return;
    _stopTimer();
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if(_isRunning) {
        fetchOutlineList(refreshData: true);
      }
    });
    _isRunning = true;
  }

  ///结束轮循
  void _stopTimer() {
    _timer?.cancel();
    _isRunning = false;
  }

  ///页面显示完成后开始轮循
  void viewDidAppear() {
    fetchOutlineList();
    _startTimer();
  }

  ///页面消失完成后停止轮循
  void viewDidDisappear() {
    _stopTimer();
  }

  ///更新大纲状态，若失败提示用户重新生成
  void updateOutlineGenerateStatus() {
    if(novelStatus == 6) {
      ByDialogUtil.showPopScopeDialog(
        context: Get.context!,
        confirmBtnTitle: 'Retry',
        confirmCallback: () {
          createNovelOutline();
        },
        cancelCallback: () {
          Get.back();
        });
    }
  }

  ///更新可生成细纲的大纲
  void updateChapterAwailable() {
    updateOutlineGenerateStatus();
    ///小说大纲未生成
    if (novelStatus < 7) {
      currentOutlineIndex.value = 0;
    } else {
      try {
        OutlineBean bean = itemList.firstWhere((item) => [3,5,7].contains(item.stage));
        currentOutlineIndex.value = bean.index!;
      } catch (e) {
        currentOutlineIndex.value = 0;
      }
    }
  }

  ///获取大纲列表页
  void fetchOutlineList({
    bool? refreshData = false,
    void Function()? onSuccess,
    void Function(int, String)? onFailed,
  }) {
    if(itemList.isEmpty) {
      statusType.value = MultiStatusType.statusLoading;
    }
    HttpUtils.get(
      NovelApis.outlineList,
      {
        'id': novelID
      },
      showMsgWhenFailed: false,
      success: (data) {
        if (data['status'] == 200) {
          final List items = data["data"]["outline_list"] ?? [];
          novelStatus = data['data']['novel_stage'];
          List<OutlineBean> beans = List<OutlineBean>.from(items.map(
            (ele) => OutlineBean.fromJson(ele),
          ));
          itemList.value = beans;
          updateChapterAwailable();
          if(!refreshData!) {
            _startTimer();
          }
          onSuccess?.call();
          if (itemList.isEmpty) {
            statusType.value = MultiStatusType.statusEmpty;
          } else {
            statusType.value = MultiStatusType.statusContent;
          }
        }
        else {
          if (itemList.isEmpty) {
          statusType.value = MultiStatusType.statusNoNetWork;
        }
        }
      },
      fail: (code, msg) {
        if (itemList.isEmpty) {
          statusType.value = MultiStatusType.statusNoNetWork;
        }
        onFailed?.call(code, msg);
      },
    );
  }

  ///创建大纲
  void createNovelOutline({
    void Function()? onSuccess,
    void Function(int, String)? onFailed,
  }) {
    LoadingDialog().show(message: 'Outline Creating...');
    HttpUtils.post(
      NovelApis.createOutline,
      {
        'id': novelID
      },
      showMsgWhenFailed: false,
      success: (data) {
        LoadingDialog().dismiss();
        if (data['status'] == 200) {
          fetchOutlineList(refreshData: true);
          onSuccess?.call();
        }
      },
      fail: (code, msg) {
        LoadingDialog().dismiss();
        onFailed?.call(code, msg);
        Toast.showText(text: msg);
      },
    );
  }

}