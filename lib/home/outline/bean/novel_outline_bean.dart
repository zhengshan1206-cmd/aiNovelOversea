/*
 * @Author: cold-x
 * @Date: 2025-06-25 17:37:37
 * @LastEditors: cold-x 474647591@qq.com
 * @LastEditTime: 2025-07-01 17:14:02
 * @FilePath: /fastcreationmaster/lib/home/long_novel/bean/novel_outline_bean.dart
 * @Description: 
 */




class OutlineBean {
  int? id; ///大纲id
  int? novelID; ///小说id
  String? title; ///大纲标题
  String? streamURL; ///长链接地址
  int? index; ///大纲顺序
  /*
   * 1=已提交
   * 2=生成中
   * 3=生成成功
   * 4=生成失败
   * 5=细纲生成中
   * 6=细纲生成成功
   * 7=细纲生成失败
   */
  int? stage; ///大纲生成阶段
  String? createTime; ///创建时间
  int? chaptersNum; ///当前大纲将会生成的章节数量
  int? words; ///大纲字数
  List<dynamic>? bindChapter; ///当前大纲绑定的章节范围
  String? streamTaskID; ///灵感输出任务ID
  String? content; ///大纲内容
  bool? allowGenerateChapter; ///是否能生成细纲

  OutlineBean({
    this.id,
    this.title,
    this.novelID,
    this.streamURL,
    this.words,
    this.index,
    this.createTime,
    this.stage,
    this.chaptersNum,
    this.bindChapter,
    this.streamTaskID,
    this.content,
    this.allowGenerateChapter,
  });

  factory OutlineBean.fromJson(Map<String, dynamic> json) {
    return OutlineBean(
      id: json['id'],
      title: json['folk_title'] ?? '',
      novelID: json['ai_novel_id'],
      streamURL: json['outline_ws_url'],
      words: json['words'],
      index: json['index'],
      createTime: json['created_at'],
      stage: json['stage'],
      chaptersNum: json['chapters_num'],
      bindChapter: json["bind_chapter"],
      streamTaskID: json['outline_task_id'] ?? '',
      content: json['content'] ?? '',
      allowGenerateChapter: json['is_allow_create_chapter_overview'] ?? false,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'folk_title': title,
      'ai_novel_id': novelID,
      'outline_ws_url': streamURL,
      'words': words,
      'index': index,
      'created_at': createTime,
      'stage': stage,
      'chapters_num': chaptersNum,
      "bind_chapter": bindChapter,
      'outline_task_id': streamTaskID,
      'content': content,
      'is_allow_create_chapter_overview': allowGenerateChapter,
    };
  }
}