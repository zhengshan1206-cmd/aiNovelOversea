/*
 * @Author: cold-x
 * @Date: 2025-06-04 09:23:10
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2025-10-30 10:57:22
 * @FilePath: /novel_oversea/lib/core/cache/environment.dart
 * @Description: 
 */

// ignore_for_file: constant_identifier_names
enum Environment {
  LOCAL('https://apitest.zhuifengtxt.com/'),
  TEST('https://inchattest.mianfeiread.com/'),
  PRODUCTION('https://api.aipenman.com/');

  final String domain;
  const Environment(this.domain);

  bool get isProduction => this == Environment.PRODUCTION;
}