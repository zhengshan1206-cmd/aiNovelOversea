/*
 * @Author: cold-x
 * @Date: 2025-07-04 16:08:36
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2025-10-17 16:30:07
 * @FilePath: /novel_oversea/lib/core/service/share_service.dart
 * @Description: 
 */


import 'package:share_plus/share_plus.dart';

///分享服务
class ShareService {

  ///分享文件、图片
  static Future<void> shareFile(String filePath, {String? desc = 'Share book', 
    void Function()? success}) async {
    final params = ShareParams(
      text: desc,
      files: [XFile(filePath)],
    );
    final result = await SharePlus.instance.share(params);
    if (result.status == ShareResultStatus.success) {
      success?.call();
    }
  }
}
