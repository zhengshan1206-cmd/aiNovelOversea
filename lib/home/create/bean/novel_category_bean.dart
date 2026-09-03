/*
 * @Author: duncy
 * @Date: 2025-10-15 17:05:38
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2025-10-15 17:10:00
 * @FilePath: /novel_oversea/lib/home/create/bean/novel_category_bean.dart
 * @Description: 
 */


import 'dart:convert';

class NovelCategoryBean {
  String key;  ///类型key
  String value; //类型值
  String icon;  
  String name; //名称
  String remark;   //

  NovelCategoryBean({
    required this.key,
    required this.value,
    required this.icon,
    required this.name,
    required this.remark,
  });

  NovelCategoryBean copyWith({
    String? key,
    String? value,
    String? icon,
    String? name,
    String? remark,
  }) =>
      NovelCategoryBean(
        key: key ?? this.key,
        value: value ?? this.value,
        icon: icon ?? this.icon,
        name: name ?? this.name,
        remark: remark ?? this.remark,
      );

  factory NovelCategoryBean.fromRawJson(String str) =>
      NovelCategoryBean.fromJson(json.decode(str));
  String toRawJson() => json.encode(toJson());

  factory NovelCategoryBean.fromJson(Map<String, dynamic> json) =>
      NovelCategoryBean(
        key: json["key"],
        value: json["value"],
        icon: json["icon"],
        name: json["name"],
        remark: json["remark"],
      );

  Map<String, dynamic> toJson() => {
        "key": key,
        "value": value,
        "icon": icon,
        "name": name,
        "remark": remark,
      };
}
