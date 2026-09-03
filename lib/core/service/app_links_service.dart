/*
 * @Author: duncy
 * @Date: 2025-11-10 11:22:05
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2025-11-10 14:29:20
 * @FilePath: /novel_oversea/lib/core/service/app_links_service.dart
 * @Description: 
 */



import 'package:app_links/app_links.dart';
import 'package:novel_oversea/global/const/consts.dart';
import 'package:novel_oversea/global/login/controller/firebase_auth.dart';

class AppLinksService {

  ///初始化unversal link
  static void initAppLink() {
    final appLinks = AppLinks(); // AppLinks is singleton
    // Subscribe to all events (initial link and further)
    appLinks.uriLinkStream.listen((uri) {
      final String url = uri.toString();
      print('____外部链接____--->>>: $url');
      _handleLink(url);
    });
  }

  static void _handleLink(String url) {
    ///邮箱登录
    if(url.startsWith(Consts.firebaseSignin) || url.startsWith("${Consts.firebaseHosts}/__/auth/links")) {
      LoginUtil.verifyEmail(url);
    }
  }
}