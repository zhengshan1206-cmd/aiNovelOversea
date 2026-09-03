/*
 * @Author: duncy
 * @Date: 2025-09-26 16:23:59
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2025-10-11 11:57:25
 * @FilePath: /novel_oversea/lib/tutorial/bean/zoon_detail_bean.dart
 * @Description: 
 */
// To parse this JSON data, do
//
//     final zoonDetailBean = zoonDetailBeanFromJson(jsonString);

import 'dart:convert';

ZoonDetailBean zoonDetailBeanFromJson(String str) =>
    ZoonDetailBean.fromJson(json.decode(str));

String zoonDetailBeanToJson(ZoonDetailBean data) => json.encode(data.toJson());

class ZoonDetailBean {
  int id;
  int type;
  String name;
  String content;
  String describe;
  String iconUrl;
  String videoUrl;
  int isFree;
  int lookTime;
  int readTime;
  String authorName;
  int isForceRead;
  DateTime createdAt;
  int showNumber;
  String authorAvatar;
  String wechat;

  ZoonDetailBean({
    required this.id,
    required this.type,
    required this.name,
    required this.content,
    required this.describe,
    required this.iconUrl,
    required this.videoUrl,
    required this.isFree,
    required this.lookTime,
    required this.readTime,
    required this.authorName,
    required this.isForceRead,
    required this.createdAt,
    required this.showNumber,
    required this.authorAvatar,
    required this.wechat,
  });

  factory ZoonDetailBean.fromJson(Map<String, dynamic> json) => ZoonDetailBean(
        id: json["id"],
        type: json["type"],
        name: json["name"],
        content: json["content"],
        describe: json["describe"],
        iconUrl: json["icon_url"],
        videoUrl: json["video_url"],
        isFree: json["is_free"],
        lookTime: json["look_time"],
        readTime: json["read_time"],
        authorName: json["author_name"],
        isForceRead: json["is_force_read"],
        createdAt: DateTime.parse(json["created_at"]),
        showNumber: json["show_number"],
        authorAvatar: json["author_avatar"],
        wechat: json["wechat"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "type": type,
        "name": name,
        "content": content,
        "describe": describe,
        "icon_url": iconUrl,
        "video_url": videoUrl,
        "is_free": isFree,
        "look_time": lookTime,
        "read_time": readTime,
        "author_name": authorName,
        "is_force_read": isForceRead,
        "created_at": createdAt.toIso8601String(),
        "show_number": showNumber,
        "author_avatar": authorAvatar,
        "wechat": wechat,
      };
}
