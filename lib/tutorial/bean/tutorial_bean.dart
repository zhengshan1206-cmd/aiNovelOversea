/*
 * @Author: duncy
 * @Date: 2025-09-26 14:15:30
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2025-10-11 11:56:30
 * @FilePath: /novel_oversea/lib/tutorial/bean/tutorial_bean.dart
 * @Description: 
 */
// To parse this JSON data, do
//
//     final tutorialListBean = tutorialListBeanFromJson(jsonString);

import 'dart:convert';

StrategyListBean tutorialListBeanFromJson(String str) =>
    StrategyListBean.fromJson(json.decode(str));

String tutorialListBeanToJson(StrategyListBean data) =>
    json.encode(data.toJson());

class StrategyListBean {
  int id;
  String name;
  int isFree;
  String describe;
  String iconUrl;
  String authorName;
  int showNumber;
  String createdAt;

  String wechat;
  String authorAvatar;
  StrategyListBean({
    required this.id,
    required this.name,
    required this.isFree,
    required this.describe,
    required this.iconUrl,
    required this.authorName,
    required this.showNumber,
    required this.wechat,
    required this.authorAvatar,
    required this.createdAt,
  });

  factory StrategyListBean.fromJson(Map<String, dynamic> json) =>
      StrategyListBean(
        id: json["id"],
        name: json["name"],
        isFree: json["is_free"],
        describe: json["describe"],
        iconUrl: json["icon_url"],
        authorName: json["author_name"],
        showNumber: json["show_number"],
        wechat: json["wechat"] ?? '',
        authorAvatar: json["author_avatar"],
        createdAt: json["created_at"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "is_free": isFree,
        "describe": describe,
        "icon_url": iconUrl,
        "author_name": authorName,
        "show_number": showNumber,
        "wechat": wechat,
        "authorAvatar": authorAvatar,
        "created_at": createdAt,
      };

  ///骨架测试数据
  factory StrategyListBean.initSkeletonizer() {
    return StrategyListBean(
      id: 0,
      name: '标题测试数据',
      createdAt: '',
      isFree: 2000,
      showNumber: 1000,
      wechat: '1',
      iconUrl: 'http://gamecdn.beiyinapp.com/inchat/wujie/2023-07-07/487f3788dc4245c5f072f7a893d29c4b.webp',
      authorName: '1',
      describe: ',',
      authorAvatar: 'http://gamecdn.beiyinapp.com/inchat/wujie/2023-07-07/487f3788dc4245c5f072f7a893d29c4b.webp',
    );
  }
}
