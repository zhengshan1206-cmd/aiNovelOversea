


import 'dart:io';

import 'package:get/get.dart';
import 'package:novel_oversea/core/network/file_download.dart';
import 'package:novel_oversea/core/network/http_utils.dart';
import 'package:novel_oversea/core/service/share_service.dart';
import 'package:novel_oversea/core/ui/dialog/by_dialog_util.dart';
import 'package:novel_oversea/core/ui/dialog/diolog_view.dart';
import 'package:novel_oversea/core/ui/dialog/loading_dialog.dart';
import 'package:novel_oversea/core/ui/dialog/toast.dart';
import 'package:novel_oversea/home/brief/bean/novel_bean.dart';
import 'package:novel_oversea/home/core/view/chapter_choose_view.dart';
import '../../../core/network/novel_apis.dart';


class NovelManagerItem {
  Rx<bool> downloading = false.obs;///是否可下载
  String title = ''; ///标题
  Rx<bool> isActive = true.obs; ///是否能交互、可点击
  Rx<int> progress  = 0.obs; ///下载进度
}

class NovelManagerController extends GetxController {

  ///小说数据
  NovelBean? bean;

  ///小说标题
  Rx<String> title = ''.obs;

  ///是否有违禁词
  bool hasIllegalWords = false;

  final List<String> titles = ['Download Book', 'Download Chapter', 'Rename', 'Delete'];
  List<NovelManagerItem> items = [];
  final int novelID = 0;

  @override
  void onInit() {
    super.onInit();
    for (final title in titles){
      NovelManagerItem item = NovelManagerItem();
      item.title = title;
      items.add(item);
    }
  }

  ///更新小说状态
  void updateNovelStatus() {
    for(int index in [0,1,3]){
        NovelManagerItem item = items[index];
        if(bean!.stage! == 10) {
          item.isActive.value = true;
          continue;
        }
        ///是否能删除(暂停中或者已完结的小说能被删除)
        if(index == 3 && bean!.pauseStatus == 1) {
          item.isActive.value = true;
          continue;
        }
        if (index == 1) {
        if (bean!.generateChapters! > 0) {
          item.isActive.value = true;
          continue;
        }
      }
        item.isActive.value = false;
      }
  }

  ///管理页点击action
  void clickManagerItemIndex(int index) {
    NovelManagerItem item = items[index];
    if (!item.isActive.value){
      if(bean?.stage == 10) {
        // if ([0,1].contains(index) && hasIllegalWords){
        //   Toast.showText(text: '为了保证您作品过审，完成违禁词检测后才能下载哦');
        // }
      }
      else {
        if ([0,1].contains(index)){
          Toast.showText(text: 'Download after the whole book is generated');
        }
        // if(index == 3) {
        //   Toast.showText(text: '整本小说生成完成后才能进行检测哦');
        // }
      }
      return;
    }
    switch (index) {
      ///整本下载
      case 0:
        novelLoading(item);
        break;
      ///章节下载
      case 1:
        Get.bottomSheet(
          ChapterChooseView(
            charpterNum: bean!.generateChapters!,
            type: ChapterChooseType.download,
            downloadSelected: (chapter) {
            novelLoading(item, indexes: chapter);
          },),
          isScrollControlled: true,
        );
        break;
      ///重命名
      case 2:
        Get.dialog(CommomDiolog(
          type: CommomDiologTye.textfeild,
          content: bean!.title,
          title: 'Rename',
          onConfirm: (text) {
            ///重命名
            novelRename(text);
          },
        ));
        break;
      ///违禁词检测
      // case 3:
      //   if(hasIllegalWords) {
      //     ///修复修改违禁词后不能再点击的问题
      //     Get.put(IllegalWordsController(novelID: bean!.id!));
      //     navigator?.pushNamed(
      //       Routes.illegalWords,
      //       arguments: {'novelID': bean!.id},
      //     ).then((_){
      //       checkNovel(onSuccess: (p0) {
      //         updateNovelStatus();
      //       },);
      //     });
      //   }
      //   break;
      // ///分享
      // case 4:
      //   Get.bottomSheet(
      //     const ShareView(),
      //   );
      //   break;
      ///删除
      case 3:
        ByDialogUtil.showPopScopeDialog(
          context: Get.context!,
          contents: 'Comfirm delete this book?',
          confirmCallback: () {
            deleteNovel();
          },
        );
        break;
      default:
        break;
    }
  }

  ///小说下载
  void novelLoading(NovelManagerItem item,{List<int>? indexes = const []}) {
    ///正在下载时
    if (item.downloading.value) {
      return;
    }
    item.progress.value = 0;
    item.downloading.value = true;
    item.isActive.value = false;
    
    HttpUtils.post(
      NovelApis.downloadNovel,
      {
        'id': bean!.id,
        'index_ids': indexes
      },
      success: (data) {
        if (data['status'] == 200) {
          FileDownloader.downloadWordFile(
              url: data['data']['url'],
              fileName: '${bean!.title}.docx',
              onProgress: (p0) {
                item.progress.value = (p0 * 100).floor();
              },
              done: (file) async {
                item.isActive.value = true;
                item.downloading.value = false;
                ///分享小说
                await ShareService.shareFile(file, desc: bean!.title);
                // 分享后删除本地文件
                try {
                  final f = File(file);
                  if (await f.exists()) {
                    await f.delete();
                  }
                } catch (e) {
                  print('删除文件失败: $e');
                }
              },
              failed: (){
                item.downloading.value = false;
                item.isActive.value = true;
                Toast.showText(text: 'Download failed');
              });
        }
      },
      fail: (code, msg) {
        Toast.showText(text: msg);
        item.isActive.value = true;
        item.downloading.value = false;
      },
    );
  }

  ///重命名小说
  void novelRename(String titleName) {
    if(titleName.isEmpty) {
      Toast.showText(text: 'Title can not be empty');
      return;
    }
    LoadingDialog().show(message: 'Modifying...');
    HttpUtils.post(
      NovelApis.editNovelInfo,
      {
        'id': bean!.id,
        'title': titleName,
      },
      showMsgWhenFailed: false,
      success: (data) {
        LoadingDialog().dismiss();
        if (data['status'] == 200) {
          title.value = titleName;
          bean!.title = titleName;
          Toast.showText(text: 'Modified success');
        }
      },
      fail: (code, msg) {
        LoadingDialog().dismiss();
        Toast.showText(text: msg);
      },
    );

  }

  ///删除小说
  void deleteNovel({
    void Function()? onSuccess,
    void Function(int, String)? onFailed,}) {
    LoadingDialog().show(message: 'Book Deleting...');
    HttpUtils.post(
      NovelApis.deleteNovel,
      {
        'ids': [bean!.id]
      },
      showMsgWhenFailed: false,
      success: (data) {
        LoadingDialog().dismiss();
        if (data['status'] == 200) {
          Get.back();
          Get.back();
          Toast.showText(text: 'Book Deleted');
          onSuccess?.call();
        }
      },
      fail: (code, msg) {
        LoadingDialog().dismiss();
        Toast.showText(text: msg);
      },
    );
  }
  
  ///获取小说违禁词列表
  void checkNovel({
    void Function(dynamic)? onSuccess,
  }) {
    HttpUtils.post(
      NovelApis.checkNovel,
      {
        'id': bean!.id
      },
      success: (data) {
        if(data['status'] == 200) {
          int status = data['data']['check_status'];
          if(status == 4) {
            hasIllegalWords = true;
          }
          else if(status == 3) {
            hasIllegalWords = false;
          }
          // else {
          //   Get.dialog(const NovelDialog(
          //     content: '当前小说的违禁词正在被系统检测中，请稍候再试',
          //     confirmText: '我知道了',
          //   ));
          // }
          onSuccess?.call(data);
        }
      },
    );
  }
}