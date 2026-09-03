// To parse this JSON data, do
//
//     final recordBean = recordBeanFromJson(jsonString);

import 'dart:convert';

RecordBean recordBeanFromJson(String str) =>
    RecordBean.fromJson(json.decode(str));

String recordBeanToJson(RecordBean data) => json.encode(data.toJson());

class RecordBean {
  int folkStory;
  int novelName;
  int penName;
  int novelSpread;
  int videoScript;
  int titleAide;
  int xhsAide;
  int shortNovel;
  int longNovel;
  int shortStory; ///短故事

  RecordBean({
    required this.folkStory,
    required this.novelName,
    required this.penName,
    required this.novelSpread,
    required this.videoScript,
    required this.titleAide,
    required this.xhsAide,
    required this.shortNovel,
    required this.longNovel,
    required this.shortStory,
  });

  factory RecordBean.fromJson(Map<String, dynamic> json) => RecordBean(
        folkStory: json["folk_story"],
        novelName: json["novel_name"],
        penName: json["pen_name"],
        novelSpread: json["novel_spread"],
        videoScript: json["video_script"],
        titleAide: json["title_aide"],
        xhsAide: json["xhs_aide"],
        shortNovel: json["short_novel"],
        longNovel: json["long_novel"],
        shortStory: json['short_ai_novel'],
      );

  Map<String, dynamic> toJson() => {
        "folk_story": folkStory,
        "novel_name": novelName,
        "pen_name": penName,
        "novel_spread": novelSpread,
        "video_script": videoScript,
        "title_aide": titleAide,
        "xhs_aide": xhsAide,
        "short_novel": shortNovel,
        "long_novel": longNovel,
        'short_ai_novel': shortStory,
      };
}
