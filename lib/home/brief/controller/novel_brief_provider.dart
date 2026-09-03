/*
 * @Author: cold-x
 * @Date: 2025-06-26 16:24:05
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2026-01-09 11:01:53
 * @FilePath: /novel_oversea/lib/home/brief/controller/novel_brief_provider.dart
 * @Description: 
 */



import 'package:get/get.dart';
import 'package:novel_oversea/core/network/http_utils.dart';
import 'package:novel_oversea/core/ui/dialog/by_dialog_util.dart';
import 'package:novel_oversea/core/ui/dialog/loading_dialog.dart';
import 'package:novel_oversea/core/ui/dialog/toast.dart';
import 'package:novel_oversea/core/ui/view/muti_status_view.dart';
import 'package:novel_oversea/home/brief/bean/novel_bean.dart';
import 'package:novel_oversea/home/core/controller/stream_provider.dart';
import 'package:novel_oversea/home/create/controller/novel_create_controller.dart';
import 'package:novel_oversea/me/user/user.dart';
import '../../../core/network/novel_apis.dart';
import '../../../core/service/local_streaming.dart';
import '../../../global/routes/app_pages.dart';
import '../../main/controller/home_controller.dart';

class BriefDetailProvider extends StreamingProvider {
   ///小说详情内容
  NovelBean? novelBean;
  ///小说id
  late final int? novelID; 

  ///灵感页类型
  CreationType type = CreationType.longNovel;

  ///是否回首页
  bool isBackToMain = false;

  ///页面标题
  String pageTitle = 'Book Inspiration';

  ///是否显示下方生成按钮
  bool showBottom = true;

  ///引导页小说的灵感内容
  String guideBriefContent = '';
  ///引导页小说的灵感内容
  String guideBriefTitle = '';

  LocalStreamManager? localStreamManager;

  ///是否第一次触达
  bool isFirstCreate = false;

  @override
  void dispose() {
    localStreamManager?.dispose();
    needRecirleData = false;
    super.dispose();
  }

  ///更新首页是否有未完成小说
  void updateUserUnCompleteNovel() {
    if(isFirstCreate) {
      Get.find<HomeController>().checkUnCompleteNovel();
    }
  }
  
  ///引导页假流式输出
  void guideStreamOutput() {
    localStreamManager = LocalStreamManager(
      intervalMs: 100,
      charsPerStep: 12,
    );
    
    localStreamManager?.setTargetString(guideBriefContent);
    maxWords = guideBriefContent.length;
    localStreamManager?.output = (String substring, bool isGen) {
      isGenerating = isGen;
      content += substring;
      if(isGenerating) {
        pageTitle = '创意酝酿中...';
      }
      else {
        pageTitle = '爆款创意完成';
      }
      updateProgress();
      scrollToBottom();
    };
    localStreamManager?.start();
  }

  ///延迟加载
  void delayToLoad() {
    if(needRecirleData) {
      Future.delayed(const Duration(seconds: 3),() {
        fetchNovelDetail(novelID!);
      });
    }
    
  }

  ///灵感是否生成失败
  void briefGenerateFailed() {
    if (novelBean!.stage! == 3) {
      ByDialogUtil.showPopScopeDialog(
        context: Get.context!,
        confirmBtnTitle: 'Retry',
        confirmCallback: () {
          retryBrief(novelBean!.id!);
        },
        cancelCallback: () {
          Get.back();
        });
    }
  }

  /// 试用小说需要取消后台暂停的该小说
  void _cancelPausedTryoutNovel() {
    HttpUtils.post(
      NovelApis.continuePausedNovel,
      {'id': novelID!},
      showMsgWhenFailed: false,
    );
  }

  
  ///获取小说详情
  void fetchNovelDetail(
    int id, {
    void Function()? onSuccess,
    void Function(int, String)? onFailed,
  }) {
    statusType = MultiStatusType.statusLoading;
    HttpUtils.get(
      NovelApis.novelInfo,
      {
        'id': id,
      },
      success: (data) {
        if (data['status'] == 200) {
          novelBean = NovelBean.fromJson(data['data']);
          statusType = MultiStatusType.statusContent;
          onSuccess?.call();
          ///生成完成时
          if(novelBean!.stage! > 2){
            briefGenerateFailed();
            content = data['data']['details']['inspiration'];
            updateStreamingContent(content);
          }
          ///生成中时流式输出
          else if(novelBean?.stage == 2 && novelBean!.streamTaskID!.isNotEmpty){
            wsConnect(
              novelBean!.streamTaskID!, 
              novelBean!.streamURL!,
              delayToFinish: true,
              successStream: () {
                /// 灵感完成时取消暂停的小说
                if(isFirstCreate) {
                  _cancelPausedTryoutNovel();
                } 
              },);
          }
          ///状态未改变时循环拉取数据
          else if (novelBean?.stage == 1) {
            delayToLoad();
            return;
          }
          needRecirleData = false;
        }
        else {
          statusType = MultiStatusType.statusNoNetWork;
        }
      },
      fail: (code, msg) {
        statusType = MultiStatusType.statusNoNetWork;
        notifyListeners();
        onFailed?.call(code, msg);
        Toast.showText(text: msg);
      },
    );
  }

  ///创建大纲
  void createNovelOutline({
    void Function()? onSuccess,
    void Function(int, String)? onFailed,
  }) {
    LoadingDialog().show(message: 'Outline generating...');
    HttpUtils.post(
      NovelApis.createOutline,
      showMsgWhenFailed: false,
      {
        'id': novelID
      },
      success: (data) {
        LoadingDialog().dismiss();
        if (data['status'] == 200) {
          fetchNovelDetail(novelID!);
          Get.toNamed(Routes.novelCreateOutline, arguments: {'novelID': novelID});
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

  ///重新生成灵感
  void retryBrief(int novelID,{
    void Function()? success,
  }) {

    LoadingDialog().show(message: 'Inspiration generating...');
    HttpUtils.post(
      NovelApis.retryBrief,
      {
        'id': novelID
      },
      showMsgWhenFailed: false,
      success: (data) {
        LoadingDialog().dismiss();
        if (data['status'] == 200) {
          needRecirleData = true;
          delayToLoad();
          success?.call();
        } else {
          Toast.showText(text: 'Inspiration generation failed');
        }
      },
      fail: (code, msg) {
        LoadingDialog().dismiss();
        if (code == 1003) {
          ///如果是字数不够
          Get.back();
          Get.find<UserController>().jumpToPayPage(source: 'novel_brief_retry',);
          return;
        }
        Toast.showText(text: msg);
      },
    );
  }
}