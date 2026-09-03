


import 'package:novel_oversea/core/network/http_utils.dart';
import 'package:novel_oversea/core/ui/dialog/loading_dialog.dart';
import 'package:novel_oversea/core/ui/dialog/toast.dart';

import '../../../core/network/novel_apis.dart';

class ChapterRequest {
  static Future<void> retryChapter(
    ///小说ID
    int novelID, 
    ///章节ID
    int contentID, {
    void Function()? onSuccess,
    void Function(int, String)? onFailed,
  }) async{
    ///创建细纲
    LoadingDialog().show(message: 'Retrying...');
    HttpUtils.post(
      NovelApis.retryNovelContent,
      {
        'id': novelID,
        'content_id': contentID,
      },
      showMsgWhenFailed: false,
      success: (data) {
        LoadingDialog().dismiss();
        if (data['status'] == 200) {
          onSuccess?.call();
        }
        else {
          Toast.showText(text: data['message']);
        }
      },
      fail: (code, msg) {
        LoadingDialog().dismiss();
        Toast.showText(text: msg);
      },
    );
  }
}