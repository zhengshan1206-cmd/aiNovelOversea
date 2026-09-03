/*
 * @Author: cold-x
 * @Date: 2025-05-15 16:49:21
 * @LastEditors: cold-x 474647591@qq.com
 * @LastEditTime: 2025-08-01 14:54:47
 * @FilePath: /fastcreationmaster/lib/profile/AboutUs/beans/version_update_bean.dart
 * @Description: 版本更新数据
 */

import 'dart:convert';

class VersionUpdateBean {
  String version;  //商店版本号
  String content; //更新内容
  String url;  //下载地址
  int type; //更新类型 1、弱提示更新 2、强提示更新 3、强制更新
  int frequency;   //提示频次 1、每天一次 2、每天两次 3、两天一次 4、一周一次

  VersionUpdateBean({
    required this.version,
    required this.content,
    required this.url,
    required this.type,
    required this.frequency,
  });

  VersionUpdateBean copyWith({
    String? version,
    String? content,
    String? url,
    int? type,
    int? frequency,
  }) =>
      VersionUpdateBean(
        version: version ?? this.version,
        content: content ?? this.content,
        url: url ?? this.url,
        type: type ?? this.type,
        frequency: frequency ?? this.frequency,
      );

  factory VersionUpdateBean.fromRawJson(String str) =>
      VersionUpdateBean.fromJson(json.decode(str));
  String toRawJson() => json.encode(toJson());

  factory VersionUpdateBean.fromJson(Map<String, dynamic> json) =>
      VersionUpdateBean(
        version: json["now_version"],
        content: json["describe"],
        url: json["upgrade_url"],
        type: json["type_id"],
        frequency: json["frequency_id"],
      );

  Map<String, dynamic> toJson() => {
        "now_version": version,
        "describe": content,
        "upgrade_url": url,
        "type_id": type,
        "frequency_id": frequency,
      };
}